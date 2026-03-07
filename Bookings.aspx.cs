using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using System.Web.UI.WebControls;

namespace Data_and_Web_Coursework
{
    public partial class Bookings : System.Web.UI.Page
    {
        DatabaseHelper db = new DatabaseHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
                ClearFields();
            }
        }

        private void LoadData()
        {
            gvBookings.DataSource = db.GetDataTable(@"
                SELECT b.*, u.USER_NAME, m.TITLE as MOVIE_TITLE, TO_CHAR(s.START_TIME, 'DD-MON-YY HH24:MI') as SHOW_TIME
                FROM ""BOOKING"" b 
                JOIN ""User"" u ON b.USER_ID = u.USER_ID 
                JOIN ""SHOWTIME"" s ON b.SHOWTIME_ID = s.SHOW_ID
                JOIN ""MOVIE"" m ON s.MOVIE_ID = m.MOVIE_ID
                ORDER BY b.BOOKING_TIMESTAMP DESC");
            gvBookings.DataBind();

            ddlUser.DataSource = db.GetDataTable("SELECT USER_ID, USER_NAME FROM \"User\"");
            ddlUser.DataTextField = "USER_NAME";
            ddlUser.DataValueField = "USER_ID";
            ddlUser.DataBind();
            ddlUser.Items.Insert(0, new ListItem("-- Select User --", "0"));

            ddlShowtime.DataSource = db.GetDataTable(@"
                SELECT s.SHOW_ID, m.TITLE || ' | ' || TO_CHAR(s.START_TIME, 'DD-MON-YY HH24:MI') as ShowInfo 
                FROM ""SHOWTIME"" s 
                JOIN ""MOVIE"" m ON s.MOVIE_ID = m.MOVIE_ID 
                ORDER BY s.START_TIME DESC");
            ddlShowtime.DataTextField = "ShowInfo";
            ddlShowtime.DataValueField = "SHOW_ID";
            ddlShowtime.DataBind();
            ddlShowtime.Items.Insert(0, new ListItem("-- Select Showtime --", "0"));
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtBookingID.Text) && string.IsNullOrEmpty(hfBookingID.Value))
            {
                ShowError("Booking ID is required.");
                return;
            }
            if (ddlUser.SelectedValue == "0")
            {
                ShowError("Please select a user.");
                return;
            }
            if (ddlShowtime.SelectedValue == "0")
            {
                ShowError("Please select a showtime.");
                return;
            }

            string sql;
            OracleParameter[] parameters;

            if (string.IsNullOrEmpty(hfBookingID.Value))
            {
                sql = "INSERT INTO BOOKING (BOOKING_ID, BOOKING_TIMESTAMP, STATUS, TOTAL_AMOUNT, USER_ID, SHOWTIME_ID) VALUES (:b_id, SYSDATE, :b_status, :b_amount, :b_uid, :b_sid)";
                parameters = new OracleParameter[] {
                    new OracleParameter("b_id", txtBookingID.Text.Trim()),
                    new OracleParameter("b_status", ddlStatus.SelectedValue),
                    new OracleParameter("b_amount", txtAmount.Text.Trim()),
                    new OracleParameter("b_uid", ddlUser.SelectedValue),
                    new OracleParameter("b_sid", ddlShowtime.SelectedValue)
                };
            }
            else
            {
                sql = "UPDATE BOOKING SET STATUS=:b_status, TOTAL_AMOUNT=:b_amount, USER_ID=:b_uid, SHOWTIME_ID=:b_sid WHERE BOOKING_ID=:b_id";
                parameters = new OracleParameter[] {
                    new OracleParameter("b_status", ddlStatus.SelectedValue),
                    new OracleParameter("b_amount", txtAmount.Text.Trim()),
                    new OracleParameter("b_uid", ddlUser.SelectedValue),
                    new OracleParameter("b_sid", ddlShowtime.SelectedValue),
                    new OracleParameter("b_id", hfBookingID.Value)
                };
            }

            try 
            {
                db.ExecuteNonQuery(sql, parameters);

                // If cancelled, delete associated tickets
                if (ddlStatus.SelectedValue == "Cancelled")
                {
                    string bid = string.IsNullOrEmpty(hfBookingID.Value) ? txtBookingID.Text.Trim() : hfBookingID.Value;
                    db.ExecuteNonQuery("DELETE FROM \"TICKET\" WHERE BOOKING_ID = :b_id", 
                        new OracleParameter[] { new OracleParameter("b_id", bid) });
                }

                ShowSuccess("Booking saved successfully!");
                ClearFields();
                LoadData();
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearFields();
        }

        private void ClearFields()
        {
            txtBookingID.Text = "";
            txtAmount.Text = "0.00";
            ddlUser.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            ddlShowtime.SelectedIndex = 0;
            hfBookingID.Value = "";
            txtBookingID.Enabled = true;
            btnSave.Text = "Save Booking";
        }

        protected void gvBookings_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string id = e.CommandArgument?.ToString();
            if (string.IsNullOrEmpty(id)) return;

            if (e.CommandName == "EditBooking")
            {
                DataTable dt = db.GetDataTable("SELECT * FROM BOOKING WHERE BOOKING_ID = :b_id", new OracleParameter[] { new OracleParameter("b_id", id) });
                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    txtBookingID.Text = dr["BOOKING_ID"].ToString();
                    ddlUser.SelectedValue = dr["USER_ID"].ToString();
                    ddlShowtime.SelectedValue = dr["SHOWTIME_ID"].ToString();
                    ddlStatus.SelectedValue = dr["STATUS"].ToString();
                    txtAmount.Text = dr["TOTAL_AMOUNT"].ToString();
                    hfBookingID.Value = id;
                    txtBookingID.Enabled = false;
                    btnSave.Text = "Update Booking";
                }
            }
            else if (e.CommandName == "DeleteBooking")
            {
                try 
                {
                    db.ExecuteNonQuery("DELETE FROM BOOKING WHERE BOOKING_ID = :b_id", new OracleParameter[] { new OracleParameter("b_id", id) });
                    ShowSuccess("Booking deleted successfully.");
                    LoadData();
                }
                catch (Exception ex)
                {
                    ShowError(ex.Message);
                }
            }
        }
        
        // ─── Helpers ─────────────────────────────────────────────────────────
        private void ShowError(string msg)
        {
            string script = $"ShowPopup('Error', '{msg.Replace("'", "\\'")}', 'error');";
            ClientScript.RegisterStartupScript(this.GetType(), "Popup", script, true);
        }

        private void ShowSuccess(string msg)
        {
            string script = $"ShowPopup('Success!', '{msg.Replace("'", "\\'")}', 'success');";
            ClientScript.RegisterStartupScript(this.GetType(), "Popup", script, true);
        }
    }
}
