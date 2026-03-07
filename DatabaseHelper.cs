using System;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using Oracle.ManagedDataAccess.Client;

namespace Data_and_Web_Coursework
{
    public class DatabaseHelper
    {
        private string connectionString;

        public DatabaseHelper()
        {
            connectionString = ConfigurationManager.ConnectionStrings["OracleConn"].ConnectionString;
        }

        private void PrepareCommand(OracleCommand cmd, string sql, OracleParameter[] parameters)
        {
            cmd.CommandText = sql;
            cmd.CommandType = CommandType.Text;
            cmd.BindByName = true;
            if (parameters != null)
            {
                cmd.Parameters.Clear();
                foreach (var p in parameters)
                {
                    cmd.Parameters.Add(p);
                }
            }
        }

        public DataTable GetDataTable(string sql, OracleParameter[] parameters = null)
        {
            using (OracleConnection conn = new OracleConnection(connectionString))
            {
                using (OracleCommand cmd = new OracleCommand())
                {
                    cmd.Connection = conn;
                    PrepareCommand(cmd, sql, parameters);
                    using (OracleDataAdapter adapter = new OracleDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        return dt;
                    }
                }
            }
        }

        public int ExecuteNonQuery(string sql, OracleParameter[] parameters = null)
        {
            using (OracleConnection conn = new OracleConnection(connectionString))
            {
                using (OracleCommand cmd = new OracleCommand())
                {
                    cmd.Connection = conn;
                    PrepareCommand(cmd, sql, parameters);
                    conn.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public object ExecuteScalar(string sql, OracleParameter[] parameters = null)
        {
            using (OracleConnection conn = new OracleConnection(connectionString))
            {
                using (OracleCommand cmd = new OracleCommand())
                {
                    cmd.Connection = conn;
                    PrepareCommand(cmd, sql, parameters);
                    conn.Open();
                    return cmd.ExecuteScalar();
                }
            }
        }
    }
}
