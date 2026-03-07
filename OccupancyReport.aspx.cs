using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using System.Web.UI.WebControls;

namespace Data_and_Web_Coursework
{
    public partial class OccupancyReport : System.Web.UI.Page
    {
        DatabaseHelper db = new DatabaseHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ddlMovie.DataSource = db.GetDataTable("SELECT MOVIE_ID, TITLE FROM \"MOVIE\"");
                ddlMovie.DataTextField = "TITLE";
                ddlMovie.DataValueField = "MOVIE_ID";
                ddlMovie.DataBind();
                ddlMovie.Items.Insert(0, new ListItem("-- Select a Movie --", "0"));

                // Quick Action support
                if (Request.QueryString["movieId"] != null)
                {
                    ddlMovie.SelectedValue = Request.QueryString["movieId"];
                    btnAnalyze_Click(null, null);
                }
            }
        }

        protected void btnAnalyze_Click(object sender, EventArgs e)
        {
            if (ddlMovie.SelectedValue != "0")
            {
                // Occupancy = tickets actually issued (any booking status).
                // We deliberately do NOT filter by booking STATUS because a seat
                // is physically occupied the moment a ticket is issued — regardless
                // of whether the booking is 'Confirmed', 'Paid', or 'Pending'.
                string sql = @"
                    SELECT * FROM (
                        SELECT
                            c.CINEMA_NAME,
                            h.HALL_NAME,
                            h.TOTAL_CAPACITY,
                            COUNT(t.TICKET_ID) AS TICKETSSOLD,
                            ROUND(COUNT(t.TICKET_ID) * 100.0 / NULLIF(h.TOTAL_CAPACITY, 0), 1) AS OCCUPANCYPCT,
                            DENSE_RANK() OVER (
                                ORDER BY COUNT(t.TICKET_ID) * 100.0 / NULLIF(h.TOTAL_CAPACITY, 0) DESC
                            ) AS RANK
                        FROM ""SHOWTIME"" s
                        JOIN ""MOVIE"" m    ON s.MOVIE_ID = m.MOVIE_ID
                        JOIN ""HALL"" h     ON s.HALL_ID   = h.HALL_ID
                        JOIN ""CINEMA"" c   ON h.CINEMA_THEATRE_ID = c.THEATRE_ID
                        LEFT JOIN ""BOOKING"" b ON s.SHOW_ID = b.SHOWTIME_ID
                        LEFT JOIN ""TICKET"" t  ON b.BOOKING_ID = t.BOOKING_ID
                        WHERE m.MOVIE_ID = :rep_mid
                        GROUP BY c.CINEMA_NAME, h.HALL_NAME, h.TOTAL_CAPACITY
                    ) WHERE RANK <= 3
                    ORDER BY RANK ASC";


                try 
                {
                    DataTable dt = db.GetDataTable(sql, new OracleParameter[] { new OracleParameter("rep_mid", ddlMovie.SelectedValue) });
                    gvTop3.DataSource = dt;
                    gvTop3.DataBind();
                    pnlTop3.Visible = true;
                    lblMsg.Text = "";
                }
                catch (Exception ex)
                {
                    lblMsg.Text = "Error: " + ex.Message;
                    lblMsg.ForeColor = System.Drawing.Color.Red;
                }
            }
        }
    }
}
