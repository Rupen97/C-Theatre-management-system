using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;

namespace Data_and_Web_Coursework
{
    public partial class UserTicketReport : System.Web.UI.Page
    {
        DatabaseHelper db = new DatabaseHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ddlUser.DataSource = db.GetDataTable(
                    "SELECT USER_ID, USER_NAME || ' (' || USER_EMAIL || ')' as Display FROM \"User\" ORDER BY USER_NAME");
                ddlUser.DataTextField = "Display";
                ddlUser.DataValueField = "USER_ID";
                ddlUser.DataBind();
                ddlUser.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Select a User --", "0"));
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            if (ddlUser.SelectedValue == "0")
            {
                lblMsg.Text = "Please select a user first.";
                lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
                return;
            }

            // Full join: User → Booking → Ticket and Booking → Showtime → Movie
            // Returns tickets from the last 6 months for the selected user
            string sql = @"
                SELECT 
                    t.TICKET_ID,
                    m.TITLE,
                    m.GENRE,
                    h.HALL_NAME,
                    TO_CHAR(s.START_TIME, 'DD-MON-YYYY HH24:MI') AS SHOW_TIME,
                    t.FINAL_PRICE,
                    TO_CHAR(b.BOOKING_TIMESTAMP, 'DD-MON-YYYY') AS ISSUED_DATE,
                    b.STATUS AS BOOKING_STATUS
                FROM ""TICKET"" t
                JOIN ""BOOKING"" b         ON t.BOOKING_ID = b.BOOKING_ID
                JOIN ""SHOWTIME"" s        ON b.SHOWTIME_ID = s.SHOW_ID
                JOIN ""MOVIE"" m           ON s.MOVIE_ID = m.MOVIE_ID
                JOIN ""HALL"" h            ON s.HALL_ID = h.HALL_ID
                WHERE b.USER_ID = :u_id
                AND   b.BOOKING_TIMESTAMP >= ADD_MONTHS(SYSDATE, -6)
                ORDER BY b.BOOKING_TIMESTAMP DESC";

            try
            {
                DataTable dt = db.GetDataTable(sql, new OracleParameter[] {
                    new OracleParameter("u_id", ddlUser.SelectedValue)
                });

                gvUserTickets.DataSource = dt;
                gvUserTickets.DataBind();

                lblUserInfo.Text = "Showing results for: <strong>" + ddlUser.SelectedItem.Text + "</strong>";
                pnlReport.Visible = true;
                lblMsg.Text = "";

                // Calculate and display total spend
                decimal total = 0;
                foreach (DataRow row in dt.Rows)
                {
                    if (row["FINAL_PRICE"] != DBNull.Value)
                        total += Convert.ToDecimal(row["FINAL_PRICE"]);
                }
                litTotalSpend.Text = string.Format(
                    "<strong>{0}</strong> ticket(s) &nbsp;|&nbsp; Total Spend: <strong>NRS {1:N2}</strong>",
                    dt.Rows.Count, total);
            }
            catch (Exception ex)
            {
                lblMsg.Text = "Error: " + ex.Message;
                lblMsg.ForeColor = System.Drawing.Color.Red;
            }
        }
    }
}
