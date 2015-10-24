using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using IMSCommonHelper;
using IMSModel;
using System.Security.Cryptography;

namespace IMSDataRepository
{
    public class DsUser
    {
        private readonly DBConnect dbc = new DBConnect();

        public DataTable userLogin(User user)
        {
            try
            {
                dbc.Connect();
                SqlCommand cmdLogin = new SqlCommand();
                cmdLogin.Parameters.AddWithValue("@Username", user.username);
                //cmdLogin.Parameters.AddWithValue("@Password", user.password);

                cmdLogin.CommandText = "procUserInfo";
                cmdLogin.CommandType = CommandType.StoredProcedure;
                cmdLogin.Connection = dbc.Connection;
                SqlDataAdapter adapter = new SqlDataAdapter(cmdLogin);
                DataTable dt = new DataTable();
                adapter.Fill(dt);
                cmdLogin.Dispose();
                dbc.Disconnect();
                var password = dt.Rows[0][3].ToString();
                var salt = dt.Rows[0][4].ToString();
                bool isValid = AuthenticateUser(password, salt, user.password);
                if (isValid)
                {
                    return dt;
                }
                else
                {
                    return new DataTable();
                }
            }
            catch (Exception ex)
            {
                throw (ex);
            }
        }
        public int SaveUser(User user)
        {
            user = EncryptPassword(user);
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
                    cmdLogin.Parameters.AddWithValue("@salt", user.salt);
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
        public User EncryptPassword(User user)
        {
            //Performs hashing using SHA256 algorithum
            SHA256Managed hash = new SHA256Managed();
            RNGCryptoServiceProvider random = new RNGCryptoServiceProvider();
            byte[] saltBytes = new byte[32]; // 32 bytes = 256-bit salt.
            //Fill saltBytes with cryptographically strong random values.
            random.GetBytes(saltBytes);
            //Get a byte representation of the password because the hash function 
            //works with byte arrays.
            byte[] passwordBytes = Encoding.UTF8.GetBytes(user.password);
            byte[] hashInput = new byte[passwordBytes.Length + saltBytes.Length];
            //Append the contents of the passwordBytes and hashBytes arrays to create 
            //the input to the hash function (value to be hashed)
            passwordBytes.CopyTo(hashInput, 0);
            saltBytes.CopyTo(hashInput, passwordBytes.Length);
            //Compute (generate) a hashed representation of the input value.
            byte[] hashValue = hash.ComputeHash(hashInput);
            //Hashes are often stored as strings in databases. 
            //Hashes should be stored using Base64 encoding.
            user.password = Convert.ToBase64String(hashValue);
            user.salt = Convert.ToBase64String(saltBytes);
            //store hashString and saltString in database.
            return user;
        }
        private static bool AuthenticateUser(string DBpassword, string DBsalt, string newPassword)
        {
            SHA256 hash = new SHA256Managed();
            //Convert hash and salts from Base64/
            byte[] storedSalt = Convert.FromBase64String(DBsalt);
            //Append salt to user password and hash the result
            byte[] attemptedPasswordBytes = Encoding.UTF8.GetBytes(newPassword);
            byte[] hashInput = new byte[attemptedPasswordBytes.Length + storedSalt.Length];
            attemptedPasswordBytes.CopyTo(hashInput, 0);
            storedSalt.CopyTo(hashInput, attemptedPasswordBytes.Length);
            byte[] attemptedHash = hash.ComputeHash(hashInput);
            string compateHash = Convert.ToBase64String(attemptedHash);
            //Check whether the password entered by the user matches the stored hash. 
            return compateHash == DBpassword;
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
