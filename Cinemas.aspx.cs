using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using System.Web.UI.WebControls;

namespace Data_and_Web_Coursework
{
    public partial class Cinemas : System.Web.UI.Page
    {
        DatabaseHelper db = new DatabaseHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        private void LoadData()
        {
            gvCinemas.DataSource = db.GetDataTable("SELECT * FROM \"CINEMA\"");
            gvCinemas.DataBind();

            gvHalls.DataSource = db.GetDataTable("SELECT h.*, c.CINEMA_NAME FROM \"HALL\" h JOIN \"CINEMA\" c ON h.CINEMA_THEATRE_ID = c.THEATRE_ID");
            gvHalls.DataBind();

            DataTable dtCinemas = db.GetDataTable("SELECT THEATRE_ID, CINEMA_NAME FROM \"CINEMA\"");
            ddlCinema.DataSource = dtCinemas;
            ddlCinema.DataTextField = "CINEMA_NAME";
            ddlCinema.DataValueField = "THEATRE_ID";
            ddlCinema.DataBind();
            ddlCinema.Items.Insert(0, new ListItem("-- Select Cinema --", "0"));
        }

        protected void btnSaveCinema_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtCinemaID.Text) && string.IsNullOrEmpty(hfCinemaID.Value))
            {
                ShowError("Cinema ID is required.");
                return;
            }
            if (string.IsNullOrEmpty(txtCinemaName.Text))
            {
                ShowError("Cinema Name is required.");
                return;
            }

            string sql;
            OracleParameter[] parameters;
            if (string.IsNullOrEmpty(hfCinemaID.Value))
            {
                sql = "INSERT INTO \"CINEMA\" (THEATRE_ID, CINEMA_NAME, CINEMA_LOCATION, CONTACT_INFO, EMAIL) VALUES (:c_id, :c_name, :c_loc, :c_phone, :c_email)";
                parameters = new OracleParameter[] {
                    new OracleParameter("c_id", txtCinemaID.Text.Trim()),
                    new OracleParameter("c_name", txtCinemaName.Text.Trim()),
                    new OracleParameter("c_loc", txtLocation.Text.Trim()),
                    new OracleParameter("c_phone", txtCinemaPhone.Text.Trim()),
                    new OracleParameter("c_email", txtCinemaEmail.Text.Trim())
                };
            }
            else
            {
                sql = "UPDATE \"CINEMA\" SET CINEMA_NAME=:c_name, CINEMA_LOCATION=:c_loc, CONTACT_INFO=:c_phone, EMAIL=:c_email WHERE THEATRE_ID=:c_id";
                parameters = new OracleParameter[] {
                    new OracleParameter("c_name", txtCinemaName.Text.Trim()),
                    new OracleParameter("c_loc", txtLocation.Text.Trim()),
                    new OracleParameter("c_phone", txtCinemaPhone.Text.Trim()),
                    new OracleParameter("c_email", txtCinemaEmail.Text.Trim()),
                    new OracleParameter("c_id", hfCinemaID.Value)
                };
            }

            try 
            {
                db.ExecuteNonQuery(sql, parameters);
                ShowSuccess("Cinema saved successfully!");
                ClearCinema();
                LoadData();
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        private void ClearCinema()
        {
            txtCinemaID.Text = "";
            txtCinemaName.Text = "";
            txtLocation.Text = "";
            txtCinemaPhone.Text = "";
            txtCinemaEmail.Text = "";
            hfCinemaID.Value = "";
            txtCinemaID.Enabled = true;
        }

        protected void btnSaveHall_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtHallID.Text) && string.IsNullOrEmpty(hfHallID.Value))
            {
                ShowError("Hall ID is required.");
                return;
            }
            if (string.IsNullOrEmpty(txtHallName.Text))
            {
                ShowError("Hall Name is required.");
                return;
            }
            if (ddlCinema.SelectedValue == "0")
            {
                ShowError("Please select a cinema.");
                return;
            }

            string sql;
            OracleParameter[] parameters;
            if (string.IsNullOrEmpty(hfHallID.Value))
            {
                sql = "INSERT INTO \"HALL\" (HALL_ID, HALL_NAME, TOTAL_CAPACITY, HALL_STATUS, HALL_TYPE, CINEMA_THEATRE_ID) VALUES (:h_id, :h_name, :h_cap, :h_status, :h_type, :h_cid)";
                parameters = new OracleParameter[] {
                    new OracleParameter("h_id", txtHallID.Text.Trim()),
                    new OracleParameter("h_name", txtHallName.Text.Trim()),
                    new OracleParameter("h_cap", txtCapacity.Text.Trim()),
                    new OracleParameter("h_status", ddlHallStatus.SelectedValue),
                    new OracleParameter("h_type", ddlHallType.SelectedValue),
                    new OracleParameter("h_cid", ddlCinema.SelectedValue)
                };
            }
            else
            {
                sql = "UPDATE \"HALL\" SET HALL_NAME=:h_name, TOTAL_CAPACITY=:h_cap, HALL_STATUS=:h_status, HALL_TYPE=:h_type, CINEMA_THEATRE_ID=:h_cid WHERE HALL_ID=:h_id";
                parameters = new OracleParameter[] {
                    new OracleParameter("h_name", txtHallName.Text.Trim()),
                    new OracleParameter("h_cap", txtCapacity.Text.Trim()),
                    new OracleParameter("h_status", ddlHallStatus.SelectedValue),
                    new OracleParameter("h_type", ddlHallType.SelectedValue),
                    new OracleParameter("h_cid", ddlCinema.SelectedValue),
                    new OracleParameter("h_id", hfHallID.Value)
                };
            }

            try 
            {
                db.ExecuteNonQuery(sql, parameters);
                ShowSuccess("Hall saved successfully!");
                ClearHall();
                LoadData();
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        private void ClearHall()
        {
            txtHallID.Text = "";
            txtHallName.Text = "";
            txtCapacity.Text = "";
            ddlHallStatus.SelectedIndex = 0;
            ddlHallType.SelectedIndex = 0;
            hfHallID.Value = "";
            txtHallID.Enabled = true;
        }

        protected void gvCinemas_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string id = e.CommandArgument?.ToString();
            if (string.IsNullOrEmpty(id)) return;

            if (e.CommandName == "EditCinema")
            {
                DataTable dt = db.GetDataTable("SELECT * FROM \"CINEMA\" WHERE THEATRE_ID = :c_id", new OracleParameter[] { new OracleParameter("c_id", id) });
                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    txtCinemaID.Text = dr["THEATRE_ID"].ToString();
                    txtCinemaName.Text = dr["CINEMA_NAME"].ToString();
                    txtLocation.Text = dr["CINEMA_LOCATION"].ToString();
                    txtCinemaPhone.Text = dr["CONTACT_INFO"].ToString();
                    txtCinemaEmail.Text = dr["EMAIL"].ToString();
                    hfCinemaID.Value = id;
                    txtCinemaID.Enabled = false;
                }
            }
            else if (e.CommandName == "DeleteCinema")
            {
                try 
                {
                    db.ExecuteNonQuery("DELETE FROM \"CINEMA\" WHERE THEATRE_ID = :c_id", new OracleParameter[] { new OracleParameter("c_id", id) });
                    ShowSuccess("Cinema deleted successfully.");
                    LoadData();
                }
                catch (Exception ex)
                {
                    ShowError(ex.Message);
                }
            }
        }

        protected void gvHalls_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string id = e.CommandArgument?.ToString();
            if (string.IsNullOrEmpty(id)) return;

            if (e.CommandName == "EditHall")
            {
                DataTable dt = db.GetDataTable("SELECT * FROM \"HALL\" WHERE HALL_ID = :h_id", new OracleParameter[] { new OracleParameter("h_id", id) });
                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    txtHallID.Text = dr["HALL_ID"].ToString();
                    txtHallName.Text = dr["HALL_NAME"].ToString();
                    txtCapacity.Text = dr["TOTAL_CAPACITY"].ToString();
                    ddlCinema.SelectedValue = dr["CINEMA_THEATRE_ID"].ToString();
                    ddlHallStatus.SelectedValue = dr["HALL_STATUS"].ToString();
                    ddlHallType.SelectedValue = dr["HALL_TYPE"].ToString();
                    hfHallID.Value = id;
                    txtHallID.Enabled = false;
                }
            }
            else if (e.CommandName == "DeleteHall")
            {
                try 
                {
                    db.ExecuteNonQuery("DELETE FROM \"HALL\" WHERE HALL_ID = :h_id", new OracleParameter[] { new OracleParameter("h_id", id) });
                    ShowSuccess("Hall deleted successfully.");
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
