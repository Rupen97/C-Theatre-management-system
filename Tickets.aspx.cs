using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using System.Web.UI.WebControls;

namespace Data_and_Web_Coursework
{
    public partial class Tickets : System.Web.UI.Page
    {
        DatabaseHelper db = new DatabaseHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
                LoadUserDropdown();
                LoadShowtimeDropdown();
            }
        }

        // ─── Load grid + dropdowns ───────────────────────────────────────────
        private void LoadData()
        {
            DataTable dtTickets = db.GetDataTable(@"
                SELECT t.TICKET_ID, t.BOOKING_ID,
                       st.SEAT_ROW || st.SEAT_COLUMN || ' (' || st.SEAT_NUMBER || ')' AS SEAT_INFO,
                       m.TITLE, h.HALL_NAME, s.START_TIME,
                       t.FINAL_PRICE, b.BOOKING_TIMESTAMP AS ISSUED_DATE
                FROM ""TICKET"" t
                JOIN ""BOOKING"" b  ON t.BOOKING_ID = b.BOOKING_ID
                JOIN ""SHOWTIME"" s ON b.SHOWTIME_ID = s.SHOW_ID
                JOIN ""MOVIE"" m    ON s.MOVIE_ID = m.MOVIE_ID
                JOIN ""HALL"" h     ON s.HALL_ID = h.HALL_ID
                JOIN ""SEAT"" st    ON t.SEAT_ID = st.SEAT_ID
                ORDER BY b.BOOKING_TIMESTAMP DESC");
            gvTickets.DataSource = dtTickets;
            gvTickets.DataBind();

            LoadBookingDropdown();
        }

        private void LoadBookingDropdown()
        {
            DataTable dtBookings = db.GetDataTable(@"
                SELECT b.BOOKING_ID,
                       'Booking #' || b.BOOKING_ID || '  |  ' || u.USER_NAME || '  →  ' || m.TITLE as BookingInfo
                FROM ""BOOKING"" b
                JOIN ""User"" u ON b.USER_ID = u.USER_ID
                JOIN ""SHOWTIME"" s ON b.SHOWTIME_ID = s.SHOW_ID
                JOIN ""MOVIE"" m ON s.MOVIE_ID = m.MOVIE_ID
                WHERE b.STATUS != 'Cancelled'
                ORDER BY b.BOOKING_TIMESTAMP DESC");
            ddlBooking.DataSource = dtBookings;
            ddlBooking.DataTextField = "BookingInfo";
            ddlBooking.DataValueField = "BOOKING_ID";
            ddlBooking.DataBind();
            ddlBooking.Items.Insert(0, new ListItem("-- Select Booking --", "0"));
        }

        private void LoadUserDropdown()
        {
            DataTable dtUsers = db.GetDataTable("SELECT USER_ID, USER_NAME || ' (' || USER_EMAIL || ')' as Display FROM \"User\" ORDER BY USER_NAME");
            ddlUser.DataSource = dtUsers;
            ddlUser.DataTextField = "Display";
            ddlUser.DataValueField = "USER_ID";
            ddlUser.DataBind();
            ddlUser.Items.Insert(0, new ListItem("-- Select Customer --", "0"));
        }

        private void LoadShowtimeDropdown()
        {
            DataTable dtShows = db.GetDataTable(@"
                SELECT s.SHOW_ID, 
                       m.TITLE || ' | ' || h.HALL_NAME || ' | ' || TO_CHAR(s.START_TIME, 'DD-Mon HH:MI AM') as Display
                FROM ""SHOWTIME"" s
                JOIN ""MOVIE"" m ON s.MOVIE_ID = m.MOVIE_ID
                JOIN ""HALL"" h ON s.HALL_ID = h.HALL_ID
                WHERE s.START_TIME > SYSDATE - 1
                ORDER BY s.START_TIME ASC");
            ddlShowtime.DataSource = dtShows;
            ddlShowtime.DataTextField = "Display";
            ddlShowtime.DataValueField = "SHOW_ID";
            ddlShowtime.DataBind();
            ddlShowtime.Items.Insert(0, new ListItem("-- Select Showtime --", "0"));
        }

        // ─── Mode Switching ──────────────────────────────────────────────────
        protected void rblSaleType_SelectedIndexChanged(object sender, EventArgs e)
        {
            bool isQuick = rblSaleType.SelectedValue == "Quick";
            phExistingBooking.Visible = !isQuick;
            phQuickSale.Visible = isQuick;
            litSelectionType.Text = isQuick ? "showtime" : "booking";
            ClearFields(false); 
        }

        protected void ddlBooking_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlBooking.SelectedValue != "0")
            {
                object showId = db.ExecuteScalar("SELECT SHOWTIME_ID FROM \"BOOKING\" WHERE BOOKING_ID = :bid", 
                    new OracleParameter[] { new OracleParameter("bid", ddlBooking.SelectedValue) });
                if (showId != null) LoadSeatsAndPrice(showId.ToString(), ddlBooking.SelectedValue, false);
            }
            else ClearFields(false);
        }

        protected void ddlShowtime_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlShowtime.SelectedValue != "0")
                LoadSeatsAndPrice(ddlShowtime.SelectedValue, null, true);
            else ClearFields(false);
        }

        // ─── Reusable Price & Seat Loader ────────────────────────────────────
        private void LoadSeatsAndPrice(string showtimeId, string bookingId, bool isQuickSale)
        {
            cblSeats.Items.Clear();
            cblSeats.Visible = false;
            lblNoSeats.Visible = false;
            pnlNoSelection.Visible = false;
            lblPricingInfo.Visible = false;
            txtFinalPrice.Text = "";

            try
            {
                DataTable dtPrice = db.GetDataTable(@"
                    SELECT s.BASE_PRICE, NVL(p.MULTIPLIER, 1) AS MULTIPLIER,
                           NVL(p.POLICY_NAME, 'Standard') AS POLICY_NAME
                    FROM ""SHOWTIME"" s
                    LEFT JOIN PRICINGPOLICY p ON s.POLICY_ID = p.POLICY_ID
                    WHERE s.SHOW_ID = :sid",
                    new OracleParameter[] { new OracleParameter("sid", showtimeId) });

                if (dtPrice.Rows.Count > 0)
                {
                    decimal basePrice = Convert.ToDecimal(dtPrice.Rows[0]["BASE_PRICE"]);
                    decimal multiplier = Convert.ToDecimal(dtPrice.Rows[0]["MULTIPLIER"]);
                    string policy = dtPrice.Rows[0]["POLICY_NAME"].ToString();
                    decimal final = Math.Round(basePrice * multiplier, 2);

                    txtFinalPrice.Text = final.ToString("F2");
                    lblPricingInfo.Text = string.Format(
                        "<i class=\"fas fa-tag\"></i> Base: <strong>NRS {0:N2}</strong> × {1} ( {2} )",
                        basePrice, multiplier, policy);
                    lblPricingInfo.Visible = true;
                }

                DataTable dtSeats = db.GetDataTable(@"
                    SELECT st.SEAT_ID,
                           st.SEAT_ROW || st.SEAT_COLUMN || ' – ' || st.SEAT_NUMBER AS SeatLabel
                    FROM ""SEAT"" st
                    JOIN ""SHOWTIME"" s ON st.HALL_ID = s.HALL_ID
                    WHERE s.SHOW_ID = :sid
                    AND st.SEAT_ID NOT IN (
                        SELECT t2.SEAT_ID FROM ""TICKET"" t2
                        JOIN ""BOOKING"" b2 ON t2.BOOKING_ID = b2.BOOKING_ID
                        WHERE b2.SHOWTIME_ID = :sid AND b2.STATUS != 'Cancelled'
                    )
                    ORDER BY st.SEAT_ROW, st.SEAT_COLUMN",
                    new OracleParameter[] { new OracleParameter("sid", showtimeId) });

                if (dtSeats.Rows.Count == 0)
                {
                    lblNoSeats.Visible = true;
                }
                else
                {
                    foreach (DataRow row in dtSeats.Rows)
                    {
                        cblSeats.Items.Add(new ListItem(row["SeatLabel"].ToString(), row["SEAT_ID"].ToString()));
                    }
                    cblSeats.Visible = true;
                }
            }
            catch (Exception ex)
            {
                ShowError("Error loading data: " + ex.Message);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            bool isQuick = rblSaleType.SelectedValue == "Quick";
            string finalBookingId = ddlBooking.SelectedValue;

            if (isQuick)
            {
                if (ddlUser.SelectedValue == "0") { ShowError("Please select a customer."); return; }
                if (ddlShowtime.SelectedValue == "0") { ShowError("Please select a showtime."); return; }
            }
            else if (finalBookingId == "0") { ShowError("Please select a booking."); return; }

            var selectedSeats = new System.Collections.Generic.List<string>();
            foreach (ListItem item in cblSeats.Items)
                if (item.Selected) selectedSeats.Add(item.Value);

            if (selectedSeats.Count == 0) { ShowError("Please select at least one seat."); return; }

            decimal finalPrice;
            if (!decimal.TryParse(txtFinalPrice.Text.Trim(), out finalPrice)) { ShowError("Price invalid."); return; }

            try
            {
                if (isQuick)
                {
                    object maxB = db.ExecuteScalar("SELECT NVL(MAX(BOOKING_ID), 0) + 1 FROM \"BOOKING\"", null);
                    finalBookingId = maxB.ToString();

                    db.ExecuteNonQuery(@"
                        INSERT INTO ""BOOKING"" (BOOKING_ID, USER_ID, SHOWTIME_ID, BOOKING_TIMESTAMP, TOTAL_AMOUNT, STATUS)
                        VALUES (:bid, :uid, :sid, SYSDATE, :amt, 'Paid')",
                        new OracleParameter[] {
                            new OracleParameter("bid", finalBookingId),
                            new OracleParameter("uid", ddlUser.SelectedValue),
                            new OracleParameter("sid", ddlShowtime.SelectedValue),
                            new OracleParameter("amt", finalPrice * selectedSeats.Count)
                        });
                }

                object maxT = db.ExecuteScalar("SELECT NVL(MAX(TICKET_ID), 0) FROM \"TICKET\"", null);
                int nextId = Convert.ToInt32(maxT) + 1;

                int issued = 0;
                foreach (string seatId in selectedSeats)
                {
                    db.ExecuteNonQuery(
                        "INSERT INTO \"TICKET\" (TICKET_ID, FINAL_PRICE, BOOKING_ID, SEAT_ID) " +
                        "VALUES (:tid, :prc, :bid, :sid)",
                        new OracleParameter[] {
                            new OracleParameter("tid", nextId++),
                            new OracleParameter("prc", finalPrice),
                            new OracleParameter("bid", finalBookingId),
                            new OracleParameter("sid", seatId)
                        });
                    issued++;
                }

                ShowSuccess(issued + " ticket(s) issued successfully!");
                ClearFields(true);
                LoadData();
            }
            catch (Exception ex)
            {
                ShowError("Failed to issue tickets: " + ex.Message);
            }
        }

        protected void btnClear_Click(object sender, EventArgs e) { ClearFields(true); }

        private void ClearFields(bool resetRadio)
        {
            if (resetRadio) rblSaleType.SelectedValue = "Existing";
            
            ddlBooking.SelectedIndex = 0;
            if (ddlUser.Items.Count > 0) ddlUser.SelectedIndex = 0;
            if (ddlShowtime.Items.Count > 0) ddlShowtime.SelectedIndex = 0;
            txtFinalPrice.Text = "";
            cblSeats.Items.Clear();
            cblSeats.Visible = false;
            lblNoSeats.Visible = false;
            pnlNoSelection.Visible = true;
            lblPricingInfo.Visible = false;
            
            phExistingBooking.Visible = rblSaleType.SelectedValue == "Existing";
            phQuickSale.Visible = rblSaleType.SelectedValue == "Quick";
            litSelectionType.Text = rblSaleType.SelectedValue == "Quick" ? "showtime" : "booking";
        }

        protected void gvTickets_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string id = e.CommandArgument?.ToString();
            if (e.CommandName == "DeleteTicket" && !string.IsNullOrEmpty(id))
            {
                try
                {
                    db.ExecuteNonQuery("DELETE FROM \"TICKET\" WHERE TICKET_ID = :tid",
                        new OracleParameter[] { new OracleParameter("tid", id) });
                    ShowSuccess("Ticket cancelled.");
                    LoadData();
                }
                catch (Exception ex) { ShowError(ex.Message); }
            }
        }

        private void ShowError(string msg)
        {
            string s = $"ShowPopup('Error', '{msg.Replace("'", "\\'")}', 'error');";
            ClientScript.RegisterStartupScript(this.GetType(), "Popup", s, true);
        }

        private void ShowSuccess(string msg)
        {
            string s = $"ShowPopup('Success!', '{msg.Replace("'", "\\'")}', 'success');";
            ClientScript.RegisterStartupScript(this.GetType(), "Popup", s, true);
        }
    }
}
