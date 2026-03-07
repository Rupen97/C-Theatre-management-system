using System;
using System.Data;
using System.Collections.Generic;
using Oracle.ManagedDataAccess.Client;
using System.Web.UI.WebControls;

namespace Data_and_Web_Coursework
{
    public partial class Users : System.Web.UI.Page
    {
        DatabaseHelper db = new DatabaseHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ClearFields();
                LoadUsers();
            }
        }

        private void LoadUsers()
        {
            DataTable dt = db.GetDataTable("SELECT * FROM \"User\" ORDER BY USER_ID");
            gvUsers.DataSource = dt;
            gvUsers.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtUserID.Text) && string.IsNullOrEmpty(hfUserID.Value))
            {
                ShowError("User ID is required.");
                return;
            }
            if (string.IsNullOrEmpty(txtName.Text))
            {
                ShowError("Name is required.");
                return;
            }
            if (string.IsNullOrEmpty(txtEmail.Text))
            {
                ShowError("Email is required.");
                return;
            }
            if (string.IsNullOrEmpty(txtPhone.Text))
            {
                ShowError("Phone is required.");
                return;
            }
            if (string.IsNullOrEmpty(txtAddress.Text))
            {
                ShowError("Address is required.");
                return;
            }

            string sql;
            OracleParameter[] parameters;

            if (string.IsNullOrEmpty(hfUserID.Value))
            {
                // Insert
                sql = "INSERT INTO \"User\" (USER_ID, USER_NAME, USER_EMAIL, USER_PHONE, ADDRESS) VALUES (:u_id, :u_name, :u_email, :u_phone, :u_address)";
                parameters = new OracleParameter[] {
                    new OracleParameter("u_id", txtUserID.Text.Trim()),
                    new OracleParameter("u_name", txtName.Text.Trim()),
                    new OracleParameter("u_email", txtEmail.Text.Trim()),
                    new OracleParameter("u_phone", txtPhone.Text.Trim()),
                    new OracleParameter("u_address", txtAddress.Text.Trim())
                };
            }
            else
            {
                // Update
                sql = "UPDATE \"User\" SET USER_NAME=:u_name, USER_EMAIL=:u_email, USER_PHONE=:u_phone, ADDRESS=:u_address WHERE USER_ID=:u_id";
                parameters = new OracleParameter[] {
                    new OracleParameter("u_name", txtName.Text.Trim()),
                    new OracleParameter("u_email", txtEmail.Text.Trim()),
                    new OracleParameter("u_phone", txtPhone.Text.Trim()),
                    new OracleParameter("u_address", txtAddress.Text.Trim()),
                    new OracleParameter("u_id", hfUserID.Value)
                };
            }

            try 
            {
                db.ExecuteNonQuery(sql, parameters);
                ShowSuccess("User saved successfully!");
                ClearFields();
                LoadUsers();
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
            txtUserID.Text = "";
            txtName.Text = "";
            txtEmail.Text = "";
            txtPhone.Text = "";
            txtAddress.Text = "";
            hfUserID.Value = "";
            txtUserID.Enabled = true;
            btnSave.Text = "Save User";
        }

        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string userId = e.CommandArgument.ToString();

            if (e.CommandName == "EditUser")
            {
                DataTable dt = db.GetDataTable("SELECT * FROM \"User\" WHERE USER_ID = :u_id", new OracleParameter[] { new OracleParameter("u_id", userId) });
                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    txtUserID.Text = dr["USER_ID"].ToString();
                    txtName.Text = dr["USER_NAME"].ToString();
                    txtEmail.Text = dr["USER_EMAIL"].ToString();
                    txtPhone.Text = dr["USER_PHONE"].ToString();
                    txtAddress.Text = dr["ADDRESS"].ToString();
                    hfUserID.Value = userId;
                    txtUserID.Enabled = false;
                    btnSave.Text = "Update User";
                }
            }
            else if (e.CommandName == "DeleteUser")
            {
                try 
                {
                    db.ExecuteNonQuery("DELETE FROM \"User\" WHERE USER_ID = :u_id", new OracleParameter[] { new OracleParameter("u_id", userId) });
                    ShowSuccess("User deleted successfully.");
                    LoadUsers();
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
