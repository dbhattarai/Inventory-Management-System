using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.IO;
using System.Configuration;

namespace IMSCommonHelper
{
    public class DBConnect
    {
        public SqlConnection sqlcon = new SqlConnection();
        public void Connect()
        {
            //string connectionstring = "Data Source=ACER-PC\\SQLEXPRESS;Initial Catalog=PFS;Integrated Security=True";
           //string connectionstring= "Server=DALLS\\DALLS;UID=sa;PWD=dalls;Database=IMS";
           string connectionstring = ConfigurationManager.ConnectionStrings["ims"].ConnectionString;
            //TextReader treader = new StreamReader("default.ini");
            //string connectionstring = treader.ReadLine();
            //treader.Dispose();
              sqlcon.ConnectionString = connectionstring;
            try
            {
                sqlcon.Open();
            }
            catch (Exception e)
            {

            }

        }
        public SqlTransaction tansaction()
        {

            return sqlcon.BeginTransaction();
        }

        public SqlConnection Connection
        {
            get
            {
                return sqlcon;

            }
        }

        public bool Disconnect()
        {
            try
            {
                sqlcon.Close();
                sqlcon.Dispose();
                return true;
            }
            catch
            {
                return false;
            }
        }
    }
}
