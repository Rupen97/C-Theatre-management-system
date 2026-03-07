using System;
using System.Data;
using System.Text;
using System.Linq;

namespace Data_and_Web_Coursework
{
    public partial class Default : System.Web.UI.Page
    {
        DatabaseHelper db = new DatabaseHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboardStats();
                LoadChartData();
            }
        }

        private void LoadDashboardStats()
        {
            try
            {
                litTotalUsers.Text       = db.ExecuteScalar("SELECT COUNT(*) FROM \"User\"").ToString();
                litTotalMovies.Text      = db.ExecuteScalar("SELECT COUNT(*) FROM MOVIE").ToString();
                litUpcomingShows.Text    = db.ExecuteScalar("SELECT COUNT(*) FROM SHOWTIME WHERE START_TIME > SYSDATE").ToString();
                litTotalTickets.Text     = db.ExecuteScalar("SELECT COUNT(*) FROM TICKET").ToString();
                litReservedBookings.Text = db.ExecuteScalar("SELECT COUNT(*) FROM BOOKING WHERE STATUS = 'Reserved'").ToString();
            }
            catch
            {
                litTotalUsers.Text       = "—";
                litTotalMovies.Text      = "—";
                litUpcomingShows.Text    = "—";
                litTotalTickets.Text     = "—";
                litReservedBookings.Text = "—";
            }
        }

        private void LoadChartData()
        {
            StringBuilder js = new StringBuilder();
            js.AppendLine("<script>");

            // ── 1. Top Halls by Occupancy (Limit 5) ──
            try
            {
                string occSql = @"
                    SELECT * FROM (
                        SELECT c.CINEMA_NAME || ' - ' || h.HALL_NAME AS FULL_HALL_NAME, 
                               ROUND(COUNT(t.TICKET_ID) * 100.0 / NULLIF(h.TOTAL_CAPACITY, 0), 1) AS OCCUPANCYPCT
                        FROM ""SHOWTIME"" s
                        JOIN ""HALL"" h ON s.HALL_ID = h.HALL_ID
                        JOIN ""CINEMA"" c ON h.CINEMA_THEATRE_ID = c.THEATRE_ID
                        LEFT JOIN ""BOOKING"" b ON s.SHOW_ID = b.SHOWTIME_ID
                        LEFT JOIN ""TICKET"" t ON b.BOOKING_ID = t.BOOKING_ID
                        GROUP BY c.CINEMA_NAME, h.HALL_NAME, h.TOTAL_CAPACITY
                        ORDER BY OCCUPANCYPCT DESC
                    ) WHERE ROWNUM <= 5";
                
                DataTable dtOcc = db.GetDataTable(occSql);
                
                var occLabels = dtOcc.AsEnumerable().Select(r => $"\"{r["FULL_HALL_NAME"]}\"");
                var occData   = dtOcc.AsEnumerable().Select(r => r["OCCUPANCYPCT"].ToString());

                js.AppendLine($"var occupancyLabels = [{string.Join(",", occLabels)}];");
                js.AppendLine($"var occupancyData = [{string.Join(",", occData)}];");
            }
            catch { /* Silently fail chart rendering if DB fails */ }

            // ── 2. Tickets by Movie (Top 5) ──
            try
            {
                string revSql = @"
                    SELECT * FROM (
                        SELECT m.TITLE, COUNT(t.TICKET_ID) as TICKET_COUNT
                        FROM ""TICKET"" t
                        JOIN ""BOOKING"" b ON t.BOOKING_ID = b.BOOKING_ID
                        JOIN ""SHOWTIME"" s ON b.SHOWTIME_ID = s.SHOW_ID
                        JOIN ""MOVIE"" m ON s.MOVIE_ID = m.MOVIE_ID
                        GROUP BY m.TITLE
                        ORDER BY TICKET_COUNT DESC
                    ) WHERE ROWNUM <= 5";
                
                DataTable dtRev = db.GetDataTable(revSql);
                
                var movLabels = dtRev.AsEnumerable().Select(r => $"\"{r["TITLE"].ToString().Replace("\"", "\\\"")}\"");
                var movData   = dtRev.AsEnumerable().Select(r => r["TICKET_COUNT"].ToString());

                js.AppendLine($"var movieLabels = [{string.Join(",", movLabels)}];");
                js.AppendLine($"var movieData = [{string.Join(",", movData)}];");
            }
            catch { }

            js.AppendLine("</script>");
            litChartData.Text = js.ToString();
        }

        protected void btnRunCancellation_Click(object sender, EventArgs e)
        {
            try
            {
                int cancelled = BookingCancellationWorker.RunNow();
                litCancelMsg.Text = cancelled > 0
                    ? string.Format("<div class='alert alert-success border-0 px-3 py-2 mb-0'><i class='fas fa-check-circle me-2'></i>Auto-cancellation complete. {0} booking(s) cancelled.</div>", cancelled)
                    : "<div class='alert alert-info border-0 px-3 py-2 mb-0'><i class='fas fa-info-circle me-2'></i>No expired bookings found.</div>";
                pnlCancelMsg.Visible = true;
                LoadDashboardStats();
            }
            catch (Exception ex)
            {
                litCancelMsg.Text = $"<div class='alert alert-danger border-0 px-3 py-2 mb-0'><i class='fas fa-exclamation-circle me-2'></i>{ex.Message}</div>";
                pnlCancelMsg.Visible = true;
            }
        }
    }
}
