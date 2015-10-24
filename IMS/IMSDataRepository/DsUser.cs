using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using IMSCommonHelper;
using IMSModel;

namespace IMSDataRepository
{
  public  class DsUser
    {
        private readonly DBConnect dbc = new DBConnect();

        public DataTable userLogin(User user)
        {
            try
            {
                dbc.Connect();
                SqlCommand cmdLogin = new SqlCommand();
                cmdLogin.Parameters.AddWithValue("@Username", user.username);
                cmdLogin.Parameters.AddWithValue("@Password", user.password);

                cmdLogin.CommandText = "procUserInfo";
                cmdLogin.CommandType = CommandType.StoredProcedure;
                cmdLogin.Connection = dbc.Connection;
                SqlDataAdapter adapter = new SqlDataAdapter(cmdLogin);
                DataTable dt = new DataTable();
                adapter.Fill(dt);
                cmdLogin.Dispose();
                dbc.Disconnect();
                return dt;
            }
            catch (Exception ex)
            {
                throw (ex);
            }
        }
        public int SaveUser(User user)
        {
            try
            {
                dbc.Connect();
                using (var cmdLogin = new SqlCommand
                {
                    Connection = dbc.Connection,
                    CommandText = "procSaveUser",
                    CommandType = CommandType.StoredProcedure
                })
                {
                    cmdLogin.Parameters.AddWithValue("@Username", user.username);
                    cmdLogin.Parameters.AddWithValue("@Password", user.password);
                    cmdLogin.Parameters.AddWithValue("@FullName", user.fullname);
                    cmdLogin.Parameters.AddWithValue("@UserType", user.Usertype);
                    cmdLogin.Parameters.AddWithValue("@DeptId", user.DeptId);
                    cmdLogin.Parameters.AddWithValue("@UserId", user.userId);
                    int i = cmdLogin.ExecuteNonQuery();
                    dbc.Disconnect();
                    return i;
                }
            }
            catch (Exception ex)
            {
                throw (ex);
            }
        }
        public List<Department> GetDepartment()
        {
            var dept = new List<Department>();
            try
            {
                dbc.Connect();
                using (var cmd = new SqlCommand
                {
                    Connection = dbc.Connection,
                    CommandText = "procGetDepartment",
                    CommandType = CommandType.StoredProcedure
                })
                {
                 SqlDataReader reader = cmd.ExecuteReader();
                if (reader != null)
                {
                    while (reader.Read())
                    {
 
                    dept.Add(new Department
                    {
                       DepartmentName = (string)reader["DepartmentName"],
                       DeptId = (int)reader["DeptId"]
                    });
                    }
                }
                dbc.Disconnect();
                cmd.Dispose();
                reader.Dispose();
            }
                return dept;
            }
            catch (Exception ex)
            {
                throw (ex);
            }
        }
    }
}
