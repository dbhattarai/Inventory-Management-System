using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using IMSModel;
using IMSCommonHelper;

namespace IMSDataRepository
{
    public class DSSetting
    {
        private readonly DBConnect _dbConnect = new DBConnect();

        public int SaveItem(Item item)
        {
            _dbConnect.Connect();
            using (var cmd = new SqlCommand
            {
                Connection = _dbConnect.Connection,
                CommandText = "procSaveItem",
                CommandType = CommandType.StoredProcedure
            })
            {
                cmd.Parameters.AddWithValue("@ItemName",item.ItemName);
                cmd.Parameters.AddWithValue("@Unit",item.unit);
                cmd.Parameters.AddWithValue("@Company", item.company);
                cmd.Parameters.AddWithValue("@description", item.description);
                cmd.Parameters.AddWithValue("@ItemId", item.Id);
                int i = cmd.ExecuteNonQuery();
                _dbConnect.Disconnect();
                return i;
            }
        }
        public int SaveDepartment(Department dept)
        {
            _dbConnect.Connect();
            using (var cmd = new SqlCommand
            {
                Connection = _dbConnect.Connection,
                CommandText = "procSaveDepartment",
                CommandType = CommandType.StoredProcedure
            })
            {
                cmd.Parameters.AddWithValue("@DepartmentName",dept.DepartmentName);
                cmd.Parameters.AddWithValue("@DeptCode", dept.DeptCode);
                cmd.Parameters.AddWithValue("@HOD", dept.HOD);
                cmd.Parameters.AddWithValue("@DeptId", dept.DeptId);
                int i = cmd.ExecuteNonQuery();
                _dbConnect.Disconnect();
                return i;
            }
        }
        public int SaveVendor(Vendor ven)
        {
            _dbConnect.Connect();
            using (var cmd = new SqlCommand
            {
                Connection = _dbConnect.Connection,
                CommandText = "procSaveVendor",
                CommandType = CommandType.StoredProcedure
            })
            {
                cmd.Parameters.AddWithValue("@VendorName", ven.VendorName);
                cmd.Parameters.AddWithValue("@Address", ven.Address);
                cmd.Parameters.AddWithValue("@PhoneNo",ven.phnNo);
                cmd.Parameters.AddWithValue("@VendorId", ven.venId);
                int i = cmd.ExecuteNonQuery();
                _dbConnect.Disconnect();
                return i;
            }
        }
        public List<Item> GetItem()
        {
            var item = new List<Item>();
            try
            {
                _dbConnect.Connect();
                using (var cmd = new SqlCommand
                {
                    Connection = _dbConnect.Connection,
                    CommandText = "procGetItem",
                    CommandType = CommandType.StoredProcedure
                })
                {
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader != null)
                    {
                        while (reader.Read())
                        {

                            item.Add(new Item
                            {
                                ItemName = (string)reader["ItemName"],
                                Id = (int)reader["ItemId"],
                                unit = (string)reader["Unit"]
                            });
                        }
                    }
                    _dbConnect.Disconnect();
                    cmd.Dispose();
                    reader.Dispose();
                }
                return item;
            }
            catch (Exception ex)
            {
                throw (ex);
            }
        }

        public List<Vendor> GetVendor()
        {
            var ven = new List<Vendor>();
            try
            {
                _dbConnect.Connect();
                using (var cmd = new SqlCommand
                {
                    Connection = _dbConnect.Connection,
                    CommandText = "procGetVendor",
                    CommandType = CommandType.StoredProcedure
                })
                {
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader != null)
                    {
                        while (reader.Read())
                        {

                            ven.Add(new Vendor
                            {
                                VendorName = (string)reader["VendorName"],
                                venId = (int)reader["VendorId"]
                            });
                        }
                    }
                    _dbConnect.Disconnect();
                    cmd.Dispose();
                    reader.Dispose();
                }
                return ven;
            }
            catch (Exception ex)
            {
                throw (ex);
            }
        }

        public DataTable SearchItem(string search)
        {
            DataTable ds = new DataTable();
            _dbConnect.Connect();
                using (var cmd = new SqlCommand()
                {
                    Connection = _dbConnect.Connection,
                    CommandText = "[procSearchItem]",
                    CommandType = CommandType.StoredProcedure
                })
                {
                    cmd.Parameters.AddWithValue("@search", search);
                    var adapter = new SqlDataAdapter(cmd);
                    adapter.Fill(ds);
                    cmd.Dispose();
                }
            _dbConnect.Disconnect();
            return ds;
        }

    }
}
