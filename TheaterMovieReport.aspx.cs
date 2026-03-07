using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using System.Web.UI.WebControls;

namespace Data_and_Web_Coursework
{
    public partial class TheaterMovieReport : System.Web.UI.Page
    {
        DatabaseHelper db = new DatabaseHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ddlCinema.DataSource = db.GetDataTable("SELECT THEATRE_ID, CINEMA_NAME FROM \"CINEMA\" ORDER BY CINEMA_NAME");
                ddlCinema.DataTextField = "CINEMA_NAME";
                ddlCinema.DataValueField = "THEATRE_ID";
                ddlCinema.DataBind();
                ddlCinema.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Select Cinema --", "0"));
            }
        }

        protected void btnView_Click(object sender, EventArgs e)
        {
            if (ddlCinema.SelectedValue == "0")
            {
                lblMsg.Text = "Please select a cinema.";
                lblMsg.ForeColor = System.Drawing.Color.OrangeRed;
                return;
            }

            // Enhanced query: includes genre, base price, and the linked pricing policy name
            string sql = @"
                SELECT 
                    h.HALL_NAME,
                    m.TITLE,
                    m.GENRE,
                    s.SHOW_TYPE,
                    s.START_TIME,
                    s.END_TIME,
                    s.BASE_PRICE,
                    NVL(p.POLICY_NAME, 'Standard') AS POLICY_NAME
                FROM ""SHOWTIME"" s
                JOIN ""MOVIE"" m          ON s.MOVIE_ID = m.MOVIE_ID
                JOIN ""HALL"" h           ON s.HALL_ID = h.HALL_ID
                LEFT JOIN PRICINGPOLICY p ON s.POLICY_ID = p.POLICY_ID
                WHERE h.CINEMA_THEATRE_ID = :c_id
                ORDER BY s.START_TIME ASC";

            try
            {
                gvDetails.DataSource = db.GetDataTable(sql, new OracleParameter[] {
                    new OracleParameter("c_id", ddlCinema.SelectedValue)
                });
                gvDetails.DataBind();
                pnlDetails.Visible = true;
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
