using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;

namespace Data_and_Web_Coursework
{
    public partial class Movies : System.Web.UI.Page
    {
        DatabaseHelper db = new DatabaseHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadMovies();
                ClearFields();
            }
        }

        // ─── Load ────────────────────────────────────────────────────────────
        private void LoadMovies(string search = "")
        {
            DataTable dt;
            if (string.IsNullOrEmpty(search))
            {
                dt = db.GetDataTable("SELECT MOVIE_ID, TITLE, GENRE, DURATION, LANGUAGE FROM MOVIE ORDER BY MOVIE_ID");
            }
            else
            {
                string like = "%" + search.ToUpper() + "%";
                dt = db.GetDataTable(
                    "SELECT MOVIE_ID, TITLE, GENRE, DURATION, LANGUAGE FROM MOVIE WHERE UPPER(TITLE) LIKE :s1 OR UPPER(GENRE) LIKE :s2 ORDER BY TITLE",
                    new OracleParameter[] {
                        new OracleParameter("s1", like),
                        new OracleParameter("s2", like)
                    });
            }
            gvMovies.DataSource = dt;
            gvMovies.DataBind();
        }

        // ─── Search ──────────────────────────────────────────────────────────
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadMovies(txtSearch.Text.Trim());
        }

        protected void btnResetSearch_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            LoadMovies();
        }

        // ─── Save (Insert or Update) ─────────────────────────────────────────
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // ── Validation ──────────────────────────────────
            bool isNew = string.IsNullOrEmpty(hfMovieID.Value);

            if (isNew && string.IsNullOrWhiteSpace(txtMovieID.Text))
            {
                ShowError("Movie ID is required (NUMBER).");
                return;
            }
            if (string.IsNullOrWhiteSpace(txtTitle.Text))
            {
                ShowError("Title is required.");
                return;
            }
            if (string.IsNullOrWhiteSpace(txtDuration.Text))
            {
                ShowError("Duration is required (number of minutes).");
                return;
            }

            // Parse numeric ID and Duration exactly as Oracle NUMBER expects
            long movieId = 0;
            if (isNew && !long.TryParse(txtMovieID.Text.Trim(), out movieId))
            {
                ShowError("Movie ID must be a whole number.");
                return;
            }

            long duration = 0;
            if (!long.TryParse(txtDuration.Text.Trim(), out duration))
            {
                ShowError("Duration must be a whole number (minutes).");
                return;
            }

            string sql;
            OracleParameter[] parameters;

            if (isNew)
            {
                sql = "INSERT INTO MOVIE (MOVIE_ID, TITLE, GENRE, DURATION, LANGUAGE) " +
                      "VALUES (:m_id, :m_title, :m_genre, :m_dur, :m_lang)";
                parameters = new OracleParameter[] {
                    new OracleParameter("m_id",    movieId),
                    new OracleParameter("m_title", txtTitle.Text.Trim()),
                    new OracleParameter("m_genre", ddlGenre.SelectedValue),
                    new OracleParameter("m_dur",   duration),
                    new OracleParameter("m_lang",  txtLanguage.Text.Trim())
                };
            }
            else
            {
                sql = "UPDATE MOVIE SET TITLE=:m_title, GENRE=:m_genre, DURATION=:m_dur, LANGUAGE=:m_lang " +
                      "WHERE MOVIE_ID=:m_id";
                parameters = new OracleParameter[] {
                    new OracleParameter("m_title", txtTitle.Text.Trim()),
                    new OracleParameter("m_genre", ddlGenre.SelectedValue),
                    new OracleParameter("m_dur",   duration),
                    new OracleParameter("m_lang",  txtLanguage.Text.Trim()),
                    new OracleParameter("m_id",    long.Parse(hfMovieID.Value))
                };
            }

            try
            {
                db.ExecuteNonQuery(sql, parameters);
                ShowSuccess(isNew ? "Movie added successfully!" : "Movie updated successfully!");
                ClearFields();
                LoadMovies();
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
            txtMovieID.Text    = "";
            txtTitle.Text      = "";
            txtDuration.Text   = "";
            txtLanguage.Text   = "";
            ddlGenre.SelectedIndex = 0;
            hfMovieID.Value    = "";
            txtMovieID.Enabled = true;
            btnSave.Text       = "Save Movie";
        }

        // ─── GridView Commands ────────────────────────────────────────────────
        protected void gvMovies_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            string id = e.CommandArgument?.ToString();
            if (string.IsNullOrEmpty(id)) return;

            if (e.CommandName == "EditMovie")
            {
                DataTable dt = db.GetDataTable(
                    "SELECT * FROM MOVIE WHERE MOVIE_ID = :m_id",
                    new OracleParameter[] { new OracleParameter("m_id", long.Parse(id)) });

                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    txtMovieID.Text        = dr["MOVIE_ID"].ToString();
                    txtTitle.Text          = dr["TITLE"].ToString();
                    ddlGenre.SelectedValue = dr["GENRE"].ToString();
                    txtDuration.Text       = dr["DURATION"].ToString();
                    txtLanguage.Text       = dr["LANGUAGE"].ToString();
                    hfMovieID.Value        = id;
                    txtMovieID.Enabled     = false;
                    btnSave.Text           = "Update Movie";
                }
            }
            else if (e.CommandName == "DeleteMovie")
            {
                try
                {
                    db.ExecuteNonQuery(
                        "DELETE FROM MOVIE WHERE MOVIE_ID = :m_id",
                        new OracleParameter[] { new OracleParameter("m_id", long.Parse(id)) });
                    ShowSuccess("Movie deleted.");
                    LoadMovies();
                    ClearFields();
                }
                catch (Exception ex)
                {
                    ShowError("Cannot delete: " + ex.Message);
                }
            }
            else if (e.CommandName == "ScheduleMovie")
            {
                Response.Redirect("Showtimes.aspx?movieId=" + id);
            }
            else if (e.CommandName == "ViewOccupancy")
            {
                Response.Redirect("OccupancyReport.aspx?movieId=" + id);
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
