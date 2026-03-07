using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using System.Web.UI.WebControls;

namespace Data_and_Web_Coursework
{
    public partial class PricingPolicies : System.Web.UI.Page
    {
        DatabaseHelper db = new DatabaseHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ClearFields();
                LoadPolicies();
            }
        }

        private void LoadPolicies()
        {
            gvPolicies.DataSource = db.GetDataTable("SELECT * FROM PRICINGPOLICY ORDER BY POLICY_ID");
            gvPolicies.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtPolicyID.Text) && string.IsNullOrEmpty(hfPolicyID.Value))
            {
                ShowError("Policy ID is required.");
                return;
            }
            if (string.IsNullOrEmpty(txtPolicyName.Text))
            {
                ShowError("Policy Name is required.");
                return;
            }

            string sql;
            OracleParameter[] parameters;
            DateTime policyDate = DateTime.TryParse(txtDate.Text, out DateTime d) ? d : DateTime.Now;

            if (string.IsNullOrEmpty(hfPolicyID.Value))
            {
                sql = "INSERT INTO PRICINGPOLICY (POLICY_ID, POLICY_NAME, MULTIPLIER, POLICY_DATE, DESCRIPTION) VALUES (:p_id, :p_name, :p_mult, :p_date, :p_desc)";
                parameters = new OracleParameter[] {
                    new OracleParameter("p_id", txtPolicyID.Text.Trim()),
                    new OracleParameter("p_name", txtPolicyName.Text.Trim()),
                    new OracleParameter("p_mult", txtMultiplier.Text.Trim()),
                    new OracleParameter("p_date", policyDate),
                    new OracleParameter("p_desc", txtDescription.Text.Trim())
                };
            }
            else
            {
                sql = "UPDATE PRICINGPOLICY SET POLICY_NAME=:p_name, MULTIPLIER=:p_mult, POLICY_DATE=:p_date, DESCRIPTION=:p_desc WHERE POLICY_ID=:p_id";
                parameters = new OracleParameter[] {
                    new OracleParameter("p_name", txtPolicyName.Text.Trim()),
                    new OracleParameter("p_mult", txtMultiplier.Text.Trim()),
                    new OracleParameter("p_date", policyDate),
                    new OracleParameter("p_desc", txtDescription.Text.Trim()),
                    new OracleParameter("p_id", hfPolicyID.Value)
                };
            }

            try 
            {
                db.ExecuteNonQuery(sql, parameters);
                ShowSuccess("Policy saved successfully!");
                ClearFields();
                LoadPolicies();
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
            txtPolicyID.Text = "";
            txtPolicyName.Text = "";
            txtMultiplier.Text = "1.0";
            txtDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            txtDescription.Text = "";
            hfPolicyID.Value = "";
            txtPolicyID.Enabled = true;
            btnSave.Text = "Save Policy";
        }

        protected void gvPolicies_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string id = e.CommandArgument?.ToString();
            if (string.IsNullOrEmpty(id)) return;

            if (e.CommandName == "EditPolicy")
            {
                DataTable dt = db.GetDataTable("SELECT * FROM PRICINGPOLICY WHERE POLICY_ID = :p_id", new OracleParameter[] { new OracleParameter("p_id", id) });
                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    txtPolicyID.Text = dr["POLICY_ID"].ToString();
                    txtPolicyName.Text = dr["POLICY_NAME"].ToString();
                    txtMultiplier.Text = dr["MULTIPLIER"].ToString();
                    txtDate.Text = Convert.ToDateTime(dr["POLICY_DATE"]).ToString("yyyy-MM-dd");
                    txtDescription.Text = dr["DESCRIPTION"].ToString();
                    hfPolicyID.Value = id;
                    txtPolicyID.Enabled = false;
                    btnSave.Text = "Update Policy";
                }
            }
            else if (e.CommandName == "DeletePolicy")
            {
                try 
                {
                    db.ExecuteNonQuery("DELETE FROM PRICINGPOLICY WHERE POLICY_ID = :p_id", new OracleParameter[] { new OracleParameter("p_id", id) });
                    ShowSuccess("Policy deleted successfully.");
                    LoadPolicies();
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
