using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using System.Web.UI.WebControls;

namespace Data_and_Web_Coursework
{
    public partial class Showtimes : System.Web.UI.Page
    {
        DatabaseHelper db = new DatabaseHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
                if (Request.QueryString["movieId"] != null)
                {
                    ddlMovie.SelectedValue = Request.QueryString["movieId"];
                }
            }
        }

        private void LoadData()
        {
            // Enhanced grid: includes policy name for transparency
            DataTable dtShows = db.GetDataTable(@"
                SELECT s.SHOW_ID, m.TITLE, h.HALL_NAME, s.SHOW_TYPE,
                       s.START_TIME, s.BASE_PRICE,
                       NVL(p.POLICY_NAME, 'Standard') AS POLICY_NAME
                FROM ""SHOWTIME"" s
                JOIN ""MOVIE"" m            ON s.MOVIE_ID = m.MOVIE_ID
                JOIN ""HALL"" h             ON s.HALL_ID = h.HALL_ID
                LEFT JOIN PRICINGPOLICY p   ON s.POLICY_ID = p.POLICY_ID
                ORDER BY s.START_TIME DESC");
            gvShowtimes.DataSource = dtShows;
            gvShowtimes.DataBind();

            ddlMovie.DataSource = db.GetDataTable("SELECT MOVIE_ID, TITLE FROM MOVIE ORDER BY TITLE");
            ddlMovie.DataTextField = "TITLE";
            ddlMovie.DataValueField = "MOVIE_ID";
            ddlMovie.DataBind();
            ddlMovie.Items.Insert(0, new ListItem("-- Select Movie --", "0"));

            ddlHall.DataSource = db.GetDataTable("SELECT HALL_ID, HALL_NAME FROM HALL ORDER BY HALL_NAME");
            ddlHall.DataTextField = "HALL_NAME";
            ddlHall.DataValueField = "HALL_ID";
            ddlHall.DataBind();
            ddlHall.Items.Insert(0, new ListItem("-- Select Hall --", "0"));

            // Column in Oracle schema is POLICY_ID
            ddlPricing.DataSource = db.GetDataTable("SELECT POLICY_ID, POLICY_NAME FROM PRICINGPOLICY ORDER BY POLICY_NAME");
            ddlPricing.DataTextField = "POLICY_NAME";
            ddlPricing.DataValueField = "POLICY_ID";
            ddlPricing.DataBind();
            ddlPricing.Items.Insert(0, new ListItem("-- Select Policy --", "0"));
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtShowID.Text) && string.IsNullOrEmpty(hfShowID.Value))
            {
                ShowError("Show ID is required.");
                return;
            }
            if (ddlMovie.SelectedValue == "0" || ddlHall.SelectedValue == "0")
            {
                ShowError("Movie and Hall are required.");
                return;
            }
            if (string.IsNullOrEmpty(txtStart.Value) || string.IsNullOrEmpty(txtEnd.Value))
            {
                ShowError("Start and End times are required.");
                return;
            }

            string sql;
            OracleParameter[] parameters;
            DateTime start = DateTime.Parse(txtStart.Value);
            DateTime end = DateTime.Parse(txtEnd.Value);

            if (string.IsNullOrEmpty(hfShowID.Value))
            {
                sql = "INSERT INTO \"SHOWTIME\" (SHOW_ID, START_TIME, END_TIME, SHOW_TYPE, BASE_PRICE, HALL_ID, MOVIE_ID, POLICY_ID) VALUES (:s_id, :s_startT, :s_endT, :s_type, :s_price, :s_hall, :s_movie, :s_policy)";
                parameters = new OracleParameter[] {
                    new OracleParameter("s_id", txtShowID.Text.Trim()),
                    new OracleParameter("s_startT", start),
                    new OracleParameter("s_endT", end),
                    new OracleParameter("s_type", ddlType.SelectedValue),
                    new OracleParameter("s_price", txtPrice.Text.Trim()),
                    new OracleParameter("s_hall", ddlHall.SelectedValue),
                    new OracleParameter("s_movie", ddlMovie.SelectedValue),
                    new OracleParameter("s_policy", ddlPricing.SelectedValue)
                };
            }
            else
            {
                sql = "UPDATE \"SHOWTIME\" SET START_TIME=:s_startT, END_TIME=:s_endT, SHOW_TYPE=:s_type, BASE_PRICE=:s_price, HALL_ID=:s_hall, MOVIE_ID=:s_movie, POLICY_ID=:s_policy WHERE SHOW_ID=:s_id";
                parameters = new OracleParameter[] {
                    new OracleParameter("s_startT", start),
                    new OracleParameter("s_endT", end),
                    new OracleParameter("s_type", ddlType.SelectedValue),
                    new OracleParameter("s_price", txtPrice.Text.Trim()),
                    new OracleParameter("s_hall", ddlHall.SelectedValue),
                    new OracleParameter("s_movie", ddlMovie.SelectedValue),
                    new OracleParameter("s_policy", ddlPricing.SelectedValue),
                    new OracleParameter("s_id", hfShowID.Value)
                };
            }

            try 
            {
                db.ExecuteNonQuery(sql, parameters);
                ShowSuccess("Showtime saved successfully!");
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
            txtShowID.Text = "";
            txtPrice.Text = "";
            txtStart.Value = "";
            txtEnd.Value   = "";
            hfShowID.Value = "";
            txtShowID.Enabled = true;
            btnSave.Text = "Schedule Showtime";
        }

        protected void gvShowtimes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string id = e.CommandArgument?.ToString();
            if (string.IsNullOrEmpty(id)) return;

            if (e.CommandName == "EditShow")
            {
                DataTable dt = db.GetDataTable("SELECT * FROM \"SHOWTIME\" WHERE SHOW_ID = :s_id", new OracleParameter[] { new OracleParameter("s_id", id) });
                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    txtShowID.Text = dr["SHOW_ID"].ToString();
                    ddlMovie.SelectedValue = dr["MOVIE_ID"].ToString();
                    ddlHall.SelectedValue = dr["HALL_ID"].ToString();
                    ddlType.SelectedValue = dr["SHOW_TYPE"].ToString();
                    txtPrice.Text = dr["BASE_PRICE"].ToString();
                    txtStart.Value = Convert.ToDateTime(dr["START_TIME"]).ToString("yyyy-MM-ddTHH:mm");
                    txtEnd.Value   = Convert.ToDateTime(dr["END_TIME"]).ToString("yyyy-MM-ddTHH:mm");
                    ddlPricing.SelectedValue = dr["POLICY_ID"].ToString();
                    hfShowID.Value = id;
                    txtShowID.Enabled = false;
                    btnSave.Text = "Update Showtime";
                }
            }
            else if (e.CommandName == "DeleteShow")
            {
                try 
                {
                    db.ExecuteNonQuery("DELETE FROM \"SHOWTIME\" WHERE SHOW_ID = :s_id", new OracleParameter[] { new OracleParameter("s_id", id) });
                    ShowSuccess("Showtime deleted successfully.");
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
