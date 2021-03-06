﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using IMSCommonHelper;
using IMSModel;

namespace IMSDataRepository
{

   public class DsManagement
    {
       private readonly DBConnect dbc = new DBConnect();
       private readonly Received rec = new Received();
       private readonly Issued iss = new Issued();

       public int SaveReceived(List<Received> received, List<Balance> balance, int recFlag, int issue)
       {
           dbc.Connect();
           SqlTransaction tran;
           int i = 0;
           tran = dbc.tansaction();
           try
           {
               using (var cmd = new SqlCommand
               {
                   Connection = dbc.Connection,
                   CommandText = "procSaveReceived",
                   CommandType = CommandType.StoredProcedure
               })
               {
                   cmd.Transaction = tran;
                   foreach (var rec in received)
                   {
                       cmd.Parameters.AddWithValue("@Date", rec.Date);
                       cmd.Parameters.AddWithValue("@itemId", rec.itemId);
                       cmd.Parameters.AddWithValue("@unit", rec.unit);
                       cmd.Parameters.AddWithValue("@quantity", rec.quantity);
                       cmd.Parameters.AddWithValue("@Rate", rec.Rate);
                       cmd.Parameters.AddWithValue("@amount", rec.amount);
                       cmd.Parameters.AddWithValue("@vendorId", rec.vendorId);
                       cmd.Parameters.AddWithValue("@GNR", rec.GNR);
                       cmd.Parameters.AddWithValue("@remarks", rec.remarks);
                       cmd.Parameters.AddWithValue("@receivedby", rec.receivedby);
                       cmd.Parameters.AddWithValue("@Id", rec.Id);
                      
                       i = cmd.ExecuteNonQuery();
                       cmd.Parameters.Clear();
                   }
               }

               using (var cmd = new SqlCommand
               {
                   Connection = dbc.Connection,
                   CommandText = "procSavedailyTransaction",
                   CommandType = CommandType.StoredProcedure
               })
               {
                   cmd.Transaction = tran;
                   foreach (var blnc in balance)
                   {
                       cmd.Parameters.AddWithValue("@itemId", blnc.itemId);
                       cmd.Parameters.AddWithValue("@date", blnc.date);
                       cmd.Parameters.AddWithValue("@quantity", blnc.quantity);
                       cmd.Parameters.AddWithValue("@Rate", blnc.Rate);
                       cmd.Parameters.AddWithValue("@amount", blnc.amount);
                       cmd.Parameters.AddWithValue("@Id", blnc.Id);
                       cmd.Parameters.AddWithValue("@rec", recFlag);
                       cmd.Parameters.AddWithValue("@issue", issue);
                       cmd.Parameters.AddWithValue("@grn",blnc.grn);
                       cmd.Parameters.AddWithValue("@isn", blnc.isn);
                       cmd.Parameters.AddWithValue("@transactionId", blnc.transactionId);
                       i = cmd.ExecuteNonQuery();
                       cmd.Parameters.Clear();
                   }
               }

               //using (var cmd = new SqlCommand
               //{
               //    Connection = dbc.Connection,
               //    CommandText = "procSaveBalance",
               //    CommandType = CommandType.StoredProcedure
               //})
               //{
               //    cmd.Transaction = tran;
               //    foreach (var blnc in balance)
               //    {
               //        cmd.Parameters.AddWithValue("@itemId", blnc.itemId);
               //        cmd.Parameters.AddWithValue("@date", blnc.date);
               //        cmd.Parameters.AddWithValue("@quantity", blnc.quantity);
               //        cmd.Parameters.AddWithValue("@Rate", blnc.Rate);
               //        cmd.Parameters.AddWithValue("@amount", blnc.amount);
               //        cmd.Parameters.AddWithValue("@Id", blnc.Id);
               //        cmd.Parameters.AddWithValue("@rec", recFlag);
               //        cmd.Parameters.AddWithValue("@issue", issue);
               //        i = cmd.ExecuteNonQuery();
               //        cmd.Parameters.Clear();
               //    }
               //}

               tran.Commit();
               dbc.Disconnect();
               return i;
           }
           catch (Exception ex)
           {
               tran.Rollback();
               throw;
           }

       }
       //public int SaveReceived(Received rec)
       //{
       //    try
       //    {
       //        dbc.Connect();
       //        using (var cmd = new SqlCommand
       //        {
       //            Connection = dbc.Connection,
       //            CommandText = "procSaveReceived",
       //            CommandType = CommandType.StoredProcedure
       //        })
       //        {
       //            cmd.Parameters.AddWithValue("@Date", rec.Date);
       //            cmd.Parameters.AddWithValue("@itemId", rec.itemId);
       //            cmd.Parameters.AddWithValue("@unit", rec.unit);
       //            cmd.Parameters.AddWithValue("@quantity", rec.quantity);
       //            cmd.Parameters.AddWithValue("@Rate", rec.Rate);
       //            cmd.Parameters.AddWithValue("@amount", rec.amount);
       //            cmd.Parameters.AddWithValue("@vendorId", rec.vendorId);
       //            cmd.Parameters.AddWithValue("@GNR", rec.GNR);
       //            cmd.Parameters.AddWithValue("@remarks", rec.remarks);
       //            cmd.Parameters.AddWithValue("@receivedby", rec.receivedby);
       //            cmd.Parameters.AddWithValue("@Id", rec.Id);
       //            int i = cmd.ExecuteNonQuery();
       //            dbc.Disconnect();
       //            return i;
       //        }
       //    }
       //    catch (Exception ex)
       //    {
       //        throw (ex);
       //    }
       //}
       public int SaveIssued(List<Issued> issued, List<Balance> balance, int recFlag, int issue)
       {
           dbc.Connect();
           SqlTransaction tran;
           int i = 0;
           tran = dbc.tansaction();
           try
           {
               using (var cmd = new SqlCommand
               {
                   Connection = dbc.Connection,
                   CommandText = "procSaveIssued",
                   CommandType = CommandType.StoredProcedure
               })
               {
                   cmd.Transaction = tran;
                   foreach (var iss in issued)
                   {
                       cmd.Parameters.AddWithValue("@Date", iss.Date);
                       cmd.Parameters.AddWithValue("@itemId", iss.itemId);
                       cmd.Parameters.AddWithValue("@unit", iss.unit);
                       cmd.Parameters.AddWithValue("@quantity", iss.quantity);
                       cmd.Parameters.AddWithValue("@Rate", iss.Rate);
                       cmd.Parameters.AddWithValue("@amount", iss.amount);
                       cmd.Parameters.AddWithValue("@deptId", iss.DeptId);
                       cmd.Parameters.AddWithValue("@ISN", iss.ISN);
                       cmd.Parameters.AddWithValue("@remarks", iss.remarks);
                       cmd.Parameters.AddWithValue("@receivedby", iss.receivedby);
                       cmd.Parameters.AddWithValue("@issuedby", iss.issuedby);
                       cmd.Parameters.AddWithValue("@Id", iss.Id);

                       i = cmd.ExecuteNonQuery();
                       cmd.Parameters.Clear();
                   }
               }
               using (var cmd = new SqlCommand
               {
                   Connection = dbc.Connection,
                   CommandText = "procSavedailyTransaction",
                   CommandType = CommandType.StoredProcedure
               })
               {
                   cmd.Transaction = tran;
                   foreach (var blnc in balance)
                   {
                       cmd.Parameters.AddWithValue("@itemId", blnc.itemId);
                       cmd.Parameters.AddWithValue("@date", blnc.date);
                       cmd.Parameters.AddWithValue("@quantity", blnc.quantity);
                       cmd.Parameters.AddWithValue("@Rate", blnc.Rate);
                       cmd.Parameters.AddWithValue("@amount", blnc.amount);
                       cmd.Parameters.AddWithValue("@Id", blnc.Id);
                       cmd.Parameters.AddWithValue("@rec", recFlag);
                       cmd.Parameters.AddWithValue("@issue", issue);
                       cmd.Parameters.AddWithValue("@grn", blnc.grn);
                       cmd.Parameters.AddWithValue("@isn", blnc.isn);
                       cmd.Parameters.AddWithValue("@transactionId", blnc.transactionId);
                       i = cmd.ExecuteNonQuery();
                       cmd.Parameters.Clear();
                   }
               }

               //using (var cmd = new SqlCommand
               //{
               //    Connection = dbc.Connection,
               //    CommandText = "procSaveBalance",
               //    CommandType = CommandType.StoredProcedure
               //})
               //{
               //    cmd.Transaction = tran;
               //    foreach (var blnc in balance)
               //    {
               //        cmd.Parameters.AddWithValue("@itemId", blnc.itemId);
               //        cmd.Parameters.AddWithValue("@date", blnc.date);
               //        cmd.Parameters.AddWithValue("@quantity", blnc.quantity);
               //        cmd.Parameters.AddWithValue("@Rate", blnc.Rate);
               //        cmd.Parameters.AddWithValue("@amount", blnc.amount);
               //        cmd.Parameters.AddWithValue("@Id", blnc.Id);
               //        cmd.Parameters.AddWithValue("@rec", recFlag);
               //        cmd.Parameters.AddWithValue("@issue", issue);
               //        i = cmd.ExecuteNonQuery();
               //        cmd.Parameters.Clear();
               //    }
               //}
               tran.Commit();
               dbc.Disconnect();
               return i;
           }
           catch (Exception ex)
           {
               tran.Rollback();
               throw;
           }

       }
       //public int SaveIssued(Issued iss)
       //{
       //    try
       //    {
       //        dbc.Connect();
       //        using (var cmd = new SqlCommand
       //        {
       //            Connection = dbc.Connection,
       //            CommandText = "procSaveIssued",
       //            CommandType = CommandType.StoredProcedure
       //        })
       //        {
       //            cmd.Parameters.AddWithValue("@Date", iss.Date);
       //            cmd.Parameters.AddWithValue("@itemId", iss.itemId);
       //            cmd.Parameters.AddWithValue("@unit", iss.unit);
       //            cmd.Parameters.AddWithValue("@quantity", iss.quantity);
       //            cmd.Parameters.AddWithValue("@Rate", iss.Rate);
       //            cmd.Parameters.AddWithValue("@amount", iss.amount);
       //            cmd.Parameters.AddWithValue("@deptId", iss.DeptId);
       //            cmd.Parameters.AddWithValue("@ISN", iss.ISN);
       //            cmd.Parameters.AddWithValue("@remarks", iss.remarks);
       //            cmd.Parameters.AddWithValue("@receivedby", iss.receivedby);
       //            cmd.Parameters.AddWithValue("@issuedby", iss.issuedby);
       //            cmd.Parameters.AddWithValue("@Id", iss.Id);
       //            int i = cmd.ExecuteNonQuery();
       //            dbc.Disconnect();
       //            return i;
       //        }
       //    }
       //    catch (Exception ex)
       //    {
       //        throw (ex);
       //    }
       //}

       public List<Received> GetReceivedDetail(int itemId)
       {
           var receivedDetail = new List<Received>();
           try
           {
               dbc.Connect();
               using (var cmd = new SqlCommand
               {
                   Connection = dbc.Connection,
                   CommandText = "procGetBalanceDetail",
                   CommandType = CommandType.StoredProcedure
               })
               {
                cmd.Parameters.AddWithValue("@itemId", itemId); 
             
                   SqlDataReader reader = cmd.ExecuteReader();
                   if (reader != null)
                   {
                       while (reader.Read())
                       {

                           receivedDetail.Add(new Received
                           {
                               itemName = (string)reader["ItemName"],
                               itemId = (int)reader["itemId"],
                               quantity = Convert.ToDecimal(reader["quantity"]),
                               Rate = Convert.ToDecimal( reader["Rate"]),
                               amount = (decimal)reader["amount"]
                           });
                       }
                   }
                   dbc.Disconnect();
                   cmd.Dispose();
                   reader.Dispose();
               }
               return receivedDetail;
           }
           catch (Exception ex)
           {
               throw (ex);
           }
       }
       public DataTable GetReceivedDetailReport(int itemId)
       {
           dbc.Connect();

           var cmd = new SqlCommand
           {
               Connection = dbc.Connection,
               CommandText = "[procGetReceivedDetailReport]",
               CommandType = CommandType.StoredProcedure
           };
           cmd.Parameters.AddWithValue("@itemId", itemId);
           SqlDataAdapter adapter = new SqlDataAdapter(cmd);
           DataTable dt = new DataTable();
           adapter.Fill(dt);
           cmd.Dispose();
           dbc.Disconnect();
           return dt;

       }
       public DataTable GetGRNWiseReceivedDetail(int grn)
       {
           dbc.Connect();

           var cmd = new SqlCommand
           {
               Connection = dbc.Connection,
               CommandText = "procGetGnrWiseReceivedDetail",
               CommandType = CommandType.StoredProcedure
           };
           cmd.Parameters.AddWithValue("@gnr", grn);
           SqlDataAdapter adapter = new SqlDataAdapter(cmd);
           DataTable dt = new DataTable();
           adapter.Fill(dt);
           cmd.Dispose();
           dbc.Disconnect();
           return dt;

       }

       public DataTable GetISNWiseIssuedDetail(int isn)
       {
           dbc.Connect();

           var cmd = new SqlCommand
           {
               Connection = dbc.Connection,
               CommandText = "[procGetIsnWiseIssuedDetail]",
               CommandType = CommandType.StoredProcedure
           };
           cmd.Parameters.AddWithValue("@isn", isn);
           SqlDataAdapter adapter = new SqlDataAdapter(cmd);
           DataTable dt = new DataTable();
           adapter.Fill(dt);
           cmd.Dispose();
           dbc.Disconnect();
           return dt;

       }

       public List<Received> GetReceivedItem()
       {
           var item = new List<Item>();
           var rec = new List<Received>();
           try
           {
               dbc.Connect();
               using (var cmd = new SqlCommand
               {
                   Connection = dbc.Connection,
                   CommandText = "procGetReceivedItem",
                   CommandType = CommandType.StoredProcedure
               })
               {
                   SqlDataReader reader = cmd.ExecuteReader();
                   if (reader != null)
                   {
                       while (reader.Read())
                       {
                           rec.Add(new Received
                           {
                                itemName = (string)reader["ItemName"],
                               itemId = (int)reader["ItemId"],
                               unit = (string)reader["Unit"]
                           });
                       }
                   }
                   dbc.Disconnect();
                   cmd.Dispose();
                   reader.Dispose();
               }
               return rec;
           }
           catch (Exception ex)
           {
               throw (ex);
           }
       }
       public int SaveBalance(List<Balance> balance, int rec, int issue)
       {
           dbc.Connect();
           SqlTransaction tran;
           int i = 0;
           tran = dbc.tansaction();
           try
           {
               using (var cmd = new SqlCommand
               {
                   Connection = dbc.Connection,
                   CommandText = "procSaveBalance",
                   CommandType = CommandType.StoredProcedure
               })
               {
                   cmd.Transaction = tran;
                   foreach (var blnc in balance)
                   {
                       cmd.Parameters.AddWithValue("@itemId", blnc.itemId);
                       cmd.Parameters.AddWithValue("@date", blnc.date);
                       cmd.Parameters.AddWithValue("@quantity", blnc.quantity);
                       cmd.Parameters.AddWithValue("@Rate", blnc.Rate);
                       cmd.Parameters.AddWithValue("@amount", blnc.amount);
                       cmd.Parameters.AddWithValue("@Id", blnc.Id);
                       cmd.Parameters.AddWithValue("@rec", rec);
                       cmd.Parameters.AddWithValue("@issue", issue);
                       i = cmd.ExecuteNonQuery();
                       cmd.Parameters.Clear();
                   }
               }
               //using (var cmd = new SqlCommand
               //{
               //    Connection = dbc.Connection,
               //    CommandText = "procSavedailyTransaction",
               //    CommandType = CommandType.StoredProcedure
               //})
               //{
               //    cmd.Transaction = tran;
               //    foreach (var blnc in balance)
               //    {
               //        cmd.Parameters.AddWithValue("@itemId", blnc.itemId);
               //        cmd.Parameters.AddWithValue("@date", blnc.date);
               //        cmd.Parameters.AddWithValue("@quantity", blnc.quantity);
               //        cmd.Parameters.AddWithValue("@Rate", blnc.Rate);
               //        cmd.Parameters.AddWithValue("@amount", blnc.amount);
               //        cmd.Parameters.AddWithValue("@Id", blnc.Id);
               //        cmd.Parameters.AddWithValue("@rec", rec);
               //        cmd.Parameters.AddWithValue("@issue", issue);
               //        i = cmd.ExecuteNonQuery();
               //        cmd.Parameters.Clear();
               //    }
               //}
               tran.Commit();
               dbc.Disconnect();
               return i;
           }
           catch (Exception ex)
           {
               tran.Rollback();
               throw;
           }

       }
        public int SaveDailyTransaction(List<Balance> balance, int rec, int issue)
       {
           dbc.Connect();
           SqlTransaction tran;
           int i = 0;
           tran = dbc.tansaction();
           try
           {
               using (var cmd = new SqlCommand
               {
                   Connection = dbc.Connection,
                   CommandText = "procSavedailyTransaction",
                   CommandType = CommandType.StoredProcedure
               })
               {
                   cmd.Transaction = tran;
                   foreach (var blnc in balance)
                   {
                       cmd.Parameters.AddWithValue("@itemId", blnc.itemId);
                       cmd.Parameters.AddWithValue("@date", blnc.date);
                       cmd.Parameters.AddWithValue("@quantity", blnc.quantity);
                       cmd.Parameters.AddWithValue("@Rate", blnc.Rate);
                       cmd.Parameters.AddWithValue("@amount", blnc.amount);
                       cmd.Parameters.AddWithValue("@Id", blnc.Id);
                       cmd.Parameters.AddWithValue("@rec", rec);
                       cmd.Parameters.AddWithValue("@issue", issue);
                       i = cmd.ExecuteNonQuery();
                       cmd.Parameters.Clear();
                   }
               }
               tran.Commit();
               dbc.Disconnect();
               return i;
           }
           catch (Exception ex)
           {
               tran.Rollback();
               throw;
           }

       }
       //public int SaveBalance(List<Balance> blnc,int rec,int issue)
       //{
       //     dbc.Connect();
       //    SqlTransaction tran;
       //    int i = 0;
       //    tran = dbc.tansaction();
       //    try
       //    {
       //        dbc.Connect();
       //        using (var cmd = new SqlCommand
       //        {
       //            Connection = dbc.Connection,
       //            CommandText = "procSaveBalance",
       //            CommandType = CommandType.StoredProcedure
       //        })
       //        {
       //            cmd.Parameters.AddWithValue("@itemId", blnc.itemId);
       //            cmd.Parameters.AddWithValue("@date", blnc.date);
       //            cmd.Parameters.AddWithValue("@quantity", blnc.quantity);
       //            cmd.Parameters.AddWithValue("@Rate", blnc.Rate);
       //            cmd.Parameters.AddWithValue("@amount", blnc.amount);
       //            cmd.Parameters.AddWithValue("@Id", blnc.Id);
       //            cmd.Parameters.AddWithValue("@rec", rec);
       //            cmd.Parameters.AddWithValue("@issue", issue);
       //            int i = cmd.ExecuteNonQuery();
       //            dbc.Disconnect();
       //            {
       //                dbc.Connect();
       //                using (var cmdDetail = new SqlCommand
       //                {
       //                    Connection = dbc.Connection,
       //                    CommandText = "procSavedailyTransaction",
       //                    CommandType = CommandType.StoredProcedure
       //                })
       //                {
       //                    cmdDetail.Parameters.AddWithValue("@itemId", blnc.itemId);
       //                    cmdDetail.Parameters.AddWithValue("@date", blnc.date);
       //                    cmdDetail.Parameters.AddWithValue("@quantity", blnc.quantity);
       //                    cmdDetail.Parameters.AddWithValue("@Rate", blnc.Rate);
       //                    //cmdDetail.Parameters.AddWithValue("@amount", blnc.amount);
       //                    cmdDetail.Parameters.AddWithValue("@Id", blnc.Id);
       //                    cmdDetail.Parameters.AddWithValue("@rec", rec);
       //                    cmdDetail.Parameters.AddWithValue("@issue", issue);
       //                    i = cmdDetail.ExecuteNonQuery();
       //                    dbc.Disconnect();
       //                    return i;
       //                }
       //            }
       //        }
       //    }
           
       //    catch (Exception ex)
       //    {
       //        throw (ex);
       //    }
       //}

       public DataTable getLatestGRNandISN()
       {
           dbc.Connect();

           var cmd = new SqlCommand
           {
               Connection = dbc.Connection,
               CommandText = "[getLatestGRNandISN]",
               CommandType = CommandType.StoredProcedure
           };

           SqlDataAdapter adapter = new SqlDataAdapter(cmd);
           DataTable dt = new DataTable();
           adapter.Fill(dt);
           cmd.Dispose();
           dbc.Disconnect();
           return dt;

       }

       public List<Received> GetGRNVoucherDetails(DateTime dateFrom,DateTime dateTo)
       {
           var rec = new List<Received>();
           try
           {
               dbc.Connect();
               using (var cmd = new SqlCommand
               {
                   Connection = dbc.Connection,
                   CommandText = "proc_GetGRNVoucherDetails",
                   CommandType = CommandType.StoredProcedure
               })
               {
                   cmd.Parameters.AddWithValue("@datefrom", dateFrom);
                   cmd.Parameters.AddWithValue("@dateTo", dateTo);
                   SqlDataReader reader = cmd.ExecuteReader();
                   if (reader != null)
                   {
                       while (reader.Read())
                       {
                           rec.Add(new Received
                           {
                               itemName = (string)reader["ItemName"],
                               itemId = (int)reader["ItemId"],
                               unit = (string)reader["Unit"],
                               vendorName = (string)reader["VendorName"],
                               vendorId = (int)reader["VendorId"],
                               Id =Convert.ToString(reader["ReceivedId"]),
                               quantity = Convert.ToDecimal(reader["Quantity"]),
                               Rate = Convert.ToDecimal(reader["Rate"]),
                               amount = Convert.ToDecimal(reader["Amount"]),
                               Date =Convert.ToDateTime(reader["ReceivedDate"]),
                               remarks = (string)reader["Remarks"],
                               receivedby = (string)reader["ReceivedBy"],
                               GNR=(int)reader["GRN_NO"]
                           });
                       }
                   }
                   dbc.Disconnect();
                   cmd.Dispose();
                   reader.Dispose();
               }
               return rec;
           }
           catch (Exception ex)
           {
               throw (ex);
           }
       }

       public int DeleteGrnDetail(int grn)
       {
           dbc.Connect();
           using (var cmd = new SqlCommand
           {
               Connection = dbc.Connection,
               CommandText = "[ProcDeleteReceiveDetail]",
               CommandType = CommandType.StoredProcedure
           })
           {
               cmd.Parameters.AddWithValue("@grn", grn);
               int result = cmd.ExecuteNonQuery();
               dbc.Disconnect();
               return result;
           }
       }

       public List<Issued> GetISNVoucherDetails(DateTime dateFrom, DateTime dateTo)
       {
           var iss = new List<Issued>();
           try
           {
               dbc.Connect();
               using (var cmd = new SqlCommand
               {
                   Connection = dbc.Connection,
                   CommandText = "[proc_GetISNVoucherDetails]",
                   CommandType = CommandType.StoredProcedure
               })
               {
                   cmd.Parameters.AddWithValue("@datefrom", dateFrom);
                   cmd.Parameters.AddWithValue("@dateTo", dateTo);
                   SqlDataReader reader = cmd.ExecuteReader();
                   if (reader != null)
                   {
                       while (reader.Read())
                       {
                           iss.Add(new Issued
                           {
                               itemName = (string)reader["ItemName"],
                               itemId = (int)reader["ItemId"],
                               unit = (string)reader["Unit"],
                               departmentName = (string)reader["DepartmentName"],
                               DeptId = (int)reader["DeptId"],
                               Id = Convert.ToString(reader["IssuedId"]),
                               quantity = Convert.ToDecimal(reader["Quantity"]),
                               Rate = Convert.ToDecimal(reader["Rate"]),
                               amount = Convert.ToDecimal(reader["Amount"]),
                               Date = Convert.ToDateTime(reader["IssuedDate"]),
                               remarks = (string)reader["Remarks"],
                               receivedby = (string)reader["ReceivedBy"],
                               ISN = (int)reader["ISN_NO"],
                               issuedby=Convert.ToString(reader["IssuedBy"])
                           });
                       }
                   }
                   dbc.Disconnect();
                   cmd.Dispose();
                   reader.Dispose();
               }
               return iss;
           }
           catch (Exception ex)
           {
               throw (ex);
           }
       }

       public int DeleteIsnDetail(int isn)
       {
           dbc.Connect();
           using (var cmd = new SqlCommand
           {
               Connection = dbc.Connection,
               CommandText = "[ProcDeleteIssueDetail]",
               CommandType = CommandType.StoredProcedure
           })
           {
               cmd.Parameters.AddWithValue("@isn", isn );
               int result = cmd.ExecuteNonQuery();
               dbc.Disconnect();
               return result;
           }
       }
    }
}
