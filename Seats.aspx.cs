using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using System.Web.UI.WebControls;

namespace Data_and_Web_Coursework
{
    public partial class Seats : System.Web.UI.Page
    {
        DatabaseHelper db = new DatabaseHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadHalls();
                LoadSeats();
                ClearFields();
            }
        }

        // ─── Load hall dropdown ───────────────────────────────────────────────
        private void LoadHalls()
        {
            DataTable dt = db.GetDataTable("SELECT HALL_ID, HALL_NAME FROM \"HALL\" ORDER BY HALL_NAME");
            ddlHall.DataSource = dt;
            ddlHall.DataTextField  = "HALL_NAME";
            ddlHall.DataValueField = "HALL_ID";
            ddlHall.DataBind();
            ddlHall.Items.Insert(0, new ListItem("-- Select Hall --", "0"));
        }

        // ─── Load grid (join to HALL to show name) ────────────────────────────
        private void LoadSeats()
        {
            DataTable dt = db.GetDataTable(@"
                SELECT s.SEAT_ID, h.HALL_NAME, s.SEAT_ROW, s.SEAT_COLUMN,
                       s.SEAT_NUMBER, s.STATUS
                FROM ""SEAT"" s
                JOIN ""HALL"" h ON s.HALL_ID = h.HALL_ID
                ORDER BY h.HALL_NAME, s.SEAT_ROW, s.SEAT_COLUMN");
            gvSeats.DataSource = dt;
            gvSeats.DataBind();
        }

        // ─── Save (Insert or Update) ─────────────────────────────────────────
        protected void btnSave_Click(object sender, EventArgs e)
        {
            bool isNew = string.IsNullOrEmpty(hfSeatID.Value);

            if (isNew && string.IsNullOrWhiteSpace(txtSeatID.Text))
            {
                ShowError("Seat ID is required."); return;
            }
            if (ddlHall.SelectedValue == "0")
            {
                ShowError("Please select a Hall."); return;
            }

            string sql;
            OracleParameter[] parameters;

            if (isNew)
            {
                sql = "INSERT INTO \"SEAT\" (SEAT_ID, HALL_ID, SEAT_ROW, SEAT_COLUMN, SEAT_NUMBER, STATUS) " +
                      "VALUES (:s_id, :s_hall, :s_row, :s_col, :s_num, :s_status)";
                parameters = new OracleParameter[] {
                    new OracleParameter("s_id",     txtSeatID.Text.Trim()),
                    new OracleParameter("s_hall",   ddlHall.SelectedValue),
                    new OracleParameter("s_row",    txtRow.Text.Trim()),
                    new OracleParameter("s_col",    txtColumn.Text.Trim()),
                    new OracleParameter("s_num",    txtSeatNumber.Text.Trim()),
                    new OracleParameter("s_status", ddlStatus.SelectedValue)
                };
            }
            else
            {
                sql = "UPDATE \"SEAT\" SET HALL_ID=:s_hall, SEAT_ROW=:s_row, SEAT_COLUMN=:s_col, " +
                      "SEAT_NUMBER=:s_num, STATUS=:s_status WHERE SEAT_ID=:s_id";
                parameters = new OracleParameter[] {
                    new OracleParameter("s_hall",   ddlHall.SelectedValue),
                    new OracleParameter("s_row",    txtRow.Text.Trim()),
                    new OracleParameter("s_col",    txtColumn.Text.Trim()),
                    new OracleParameter("s_num",    txtSeatNumber.Text.Trim()),
                    new OracleParameter("s_status", ddlStatus.SelectedValue),
                    new OracleParameter("s_id",     hfSeatID.Value)
                };
            }

            try
            {
                db.ExecuteNonQuery(sql, parameters);
                ShowSuccess(isNew ? "Seat added successfully!" : "Seat updated successfully!");
                ClearFields();
                LoadSeats();
            }
            catch (Exception ex)
            {
                ShowError("Database error: " + ex.Message);
            }
        }

        // ─── Clear ───────────────────────────────────────────────────────────
        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearFields();
        }

        private void ClearFields()
        {
            txtSeatID.Text         = "";
            txtRow.Text            = "";
            txtColumn.Text         = "";
            txtSeatNumber.Text     = "";
            ddlStatus.SelectedIndex = 0;
            ddlHall.SelectedIndex   = 0;
            hfSeatID.Value         = "";
            txtSeatID.Enabled      = true;
            btnSave.Text           = "Save Seat";
        }

        // ─── GridView commands ────────────────────────────────────────────────
        protected void gvSeats_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string id = e.CommandArgument?.ToString();
            if (string.IsNullOrEmpty(id)) return;

            if (e.CommandName == "EditSeat")
            {
                DataTable dt = db.GetDataTable(
                    "SELECT * FROM \"SEAT\" WHERE SEAT_ID = :s_id",
                    new OracleParameter[] { new OracleParameter("s_id", id) });

                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    txtSeatID.Text          = dr["SEAT_ID"].ToString();
                    ddlHall.SelectedValue   = dr["HALL_ID"].ToString();
                    txtRow.Text             = dr["SEAT_ROW"].ToString();
                    txtColumn.Text          = dr["SEAT_COLUMN"].ToString();
                    txtSeatNumber.Text      = dr["SEAT_NUMBER"].ToString();
                    ddlStatus.SelectedValue = dr["STATUS"].ToString();
                    hfSeatID.Value          = id;
                    txtSeatID.Enabled       = false;
                    btnSave.Text            = "Update Seat";
                }
            }
            else if (e.CommandName == "DeleteSeat")
            {
                try
                {
                    db.ExecuteNonQuery(
                        "DELETE FROM \"SEAT\" WHERE SEAT_ID = :s_id",
                        new OracleParameter[] { new OracleParameter("s_id", id) });
                    ShowSuccess("Seat deleted successfully.");
                    LoadSeats();
                    ClearFields();
                }
                catch (Exception ex)
                {
                    ShowError("Cannot delete: " + ex.Message);
                }
            }
        }

        protected void gvSeats_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvSeats.PageIndex = e.NewPageIndex;
            LoadSeats();
        }

        // ─── Popup helpers ────────────────────────────────────────────────────
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
