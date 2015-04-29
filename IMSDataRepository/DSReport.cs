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
    
    public class DSReport
    {
        private readonly DBConnect dbc = new DBConnect();

        public DataTable GetItemWiseStockReport(DateTime dateFrom, DateTime dateTo,int itemId)
        {
            DataTable ds = new DataTable();
            dbc.Connect();

            using (var cmd = new SqlCommand()
            {
                Connection = dbc.Connection,
                CommandText = "[proc_GetItemWiseStockLedgerReportTest]",
                CommandType = CommandType.StoredProcedure
            })
            {
                cmd.Parameters.AddWithValue("@DateFrom", dateFrom);
                cmd.Parameters.AddWithValue("@DateTo", dateTo);
                cmd.Parameters.AddWithValue("@itemId", itemId);
                var adapter = new SqlDataAdapter(cmd);
                adapter.Fill(ds);
                cmd.Dispose();
            }
            dbc.Disconnect();
            return ds;
        }
        public DataTable ledgerReport(DateTime dateFrom, DateTime dateTo)
        {
            DataTable ds = new DataTable();
            dbc.Connect();

            using (var cmd = new SqlCommand()
            {
                Connection = dbc.Connection,
                CommandText = "[proc_GetLedgerReportTest]",
                CommandType = CommandType.StoredProcedure
            })
            {
                cmd.Parameters.AddWithValue("@DateFrom", dateFrom);
                cmd.Parameters.AddWithValue("@DateTo", dateTo);
                var adapter = new SqlDataAdapter(cmd);
                adapter.Fill(ds);
                cmd.Dispose();
            }
            dbc.Disconnect();
            return ds;
        }
        public DataTable GetDepartmentWiseItemReport(DateTime dateFrom, DateTime dateTo, int deptId,string type)
        {
            DataTable ds = new DataTable();
            dbc.Connect();
            if (type == "detail")
            {
                using (var cmd = new SqlCommand()
                {
                    Connection = dbc.Connection,
                    CommandText = "[proc_GetDepartmentWiseItemReport]",
                    CommandType = CommandType.StoredProcedure
                })
                {
                    cmd.Parameters.AddWithValue("@DateFrom", dateFrom);
                    cmd.Parameters.AddWithValue("@DateTo", dateTo);
                    cmd.Parameters.AddWithValue("@deptId", deptId);
                    var adapter = new SqlDataAdapter(cmd);
                    adapter.Fill(ds);
                    cmd.Dispose();
                }
            }
            else
            {
                using (var cmd = new SqlCommand()
                {
                    Connection = dbc.Connection,
                    CommandText = "[proc_GetDepartmentWiseItemReportSummary]",
                    CommandType = CommandType.StoredProcedure
                })
                {
                    cmd.Parameters.AddWithValue("@DateFrom", dateFrom);
                    cmd.Parameters.AddWithValue("@DateTo", dateTo);
                    cmd.Parameters.AddWithValue("@deptId", deptId);
                    var adapter = new SqlDataAdapter(cmd);
                    adapter.Fill(ds);
                    cmd.Dispose();
                }
            }
            dbc.Disconnect();
            return ds;
        }

        public DataTable GetItemWiseDepartmentReport(DateTime dateFrom, DateTime dateTo, int itemId,string type)
        {
            DataTable dt = new DataTable();
            dbc.Connect();
            if (type == "detail")
            {
                using (var cmd = new SqlCommand()
                {
                    Connection = dbc.Connection,
                    CommandText = "[proc_GetItemWiseDepartmentReport]",
                    CommandType = CommandType.StoredProcedure
                })
                {
                    cmd.Parameters.AddWithValue("@DateFrom", dateFrom);
                    cmd.Parameters.AddWithValue("@DateTo", dateTo);
                    cmd.Parameters.AddWithValue("@itemId", itemId);
                    var adapter = new SqlDataAdapter(cmd);
                    adapter.Fill(dt);
                    cmd.Dispose();
                }
            }
            else
            {
                using (var cmd = new SqlCommand()
                {
                    Connection = dbc.Connection,
                    CommandText = "[proc_GetItemWiseDepartmentReportSummary]",
                    CommandType = CommandType.StoredProcedure
                })
                {
                    cmd.Parameters.AddWithValue("@DateFrom", dateFrom);
                    cmd.Parameters.AddWithValue("@DateTo", dateTo);
                    cmd.Parameters.AddWithValue("@itemId", itemId);
                    var adapter = new SqlDataAdapter(cmd);
                    adapter.Fill(dt);
                    cmd.Dispose();
                }
            }

            dbc.Disconnect();
            return dt;
        }

        public DataTable GetItemWiseVendorReport(DateTime dateFrom, DateTime dateTo, int itemId,string type)
        {
            DataTable dt = new DataTable();
            dbc.Connect();
            if (type == "detail")
            {
                using (var cmd = new SqlCommand()
                {
                    Connection = dbc.Connection,
                    CommandText = "[proc_GetItemWiseVendorReport]",
                    CommandType = CommandType.StoredProcedure
                })
                {
                    cmd.Parameters.AddWithValue("@DateFrom", dateFrom);
                    cmd.Parameters.AddWithValue("@DateTo", dateTo);
                    cmd.Parameters.AddWithValue("@itemId", itemId);
                    var adapter = new SqlDataAdapter(cmd);
                    adapter.Fill(dt);
                    cmd.Dispose();
                }
            }
            else
            {
                using (var cmd = new SqlCommand()
                {
                    Connection = dbc.Connection,
                    CommandText = "[proc_GetItemWiseVendorReportSummary]",
                    CommandType = CommandType.StoredProcedure
                })
                {
                    cmd.Parameters.AddWithValue("@DateFrom", dateFrom);
                    cmd.Parameters.AddWithValue("@DateTo", dateTo);
                    cmd.Parameters.AddWithValue("@itemId", itemId);
                    var adapter = new SqlDataAdapter(cmd);
                    adapter.Fill(dt);
                    cmd.Dispose();
                }
            }
            dbc.Disconnect();
            return dt;
        }

        public DataTable GetVendorWiseItemReport(DateTime dateFrom, DateTime dateTo, int venId,string type)
        {
            DataTable dt = new DataTable();
            dbc.Connect();
            if (type == "detail")
            {
                using (var cmd = new SqlCommand()
                {
                    Connection = dbc.Connection,
                    CommandText = "[proc_VendorWiseItemReport]",
                    CommandType = CommandType.StoredProcedure
                })
                {
                    cmd.Parameters.AddWithValue("@DateFrom", dateFrom);
                    cmd.Parameters.AddWithValue("@DateTo", dateTo);
                    cmd.Parameters.AddWithValue("@venId", venId);
                    var adapter = new SqlDataAdapter(cmd);
                    adapter.Fill(dt);
                    cmd.Dispose();
                }
            }
            else
            {
                using (var cmd = new SqlCommand()
                {
                    Connection = dbc.Connection,
                    CommandText = "[proc_VendorWiseItemReportSummary]",
                    CommandType = CommandType.StoredProcedure
                })
                {
                    cmd.Parameters.AddWithValue("@DateFrom", dateFrom);
                    cmd.Parameters.AddWithValue("@DateTo", dateTo);
                    cmd.Parameters.AddWithValue("@venId", venId);
                    var adapter = new SqlDataAdapter(cmd);
                    adapter.Fill(dt);
                    cmd.Dispose();
                }
            }
            dbc.Disconnect();
            return dt;
        }
    }
}
