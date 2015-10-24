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
    
     public class DSDBService
    {
         private readonly DBConnect _connect = new DBConnect();
         public int CreateDBBackUp(string filepath, string dbname, int flag)
         {
             int result=0;
             try
             {
                 _connect.Connect();
                 using (SqlCommand cmd = new SqlCommand()
                 {
                     Connection = _connect.Connection,
                     CommandText = "proc_DBMgmt",
                     CommandType = CommandType.StoredProcedure,

                 })
                 {
                     cmd.Parameters.AddWithValue("@BkpName", filepath);
                     cmd.Parameters.AddWithValue("@DBNAME", dbname);
                     cmd.Parameters.AddWithValue("@flg", flag);
                     result=cmd.ExecuteNonQuery();
                 }
                 _connect.Disconnect();
                 return result;
                 
             }
             catch (Exception ex)
             {
                 throw ex;
             }
             finally
             {
                 _connect.Disconnect();
             }
         }

       public string GetCurrentDatabaseName()
       {
           string dataBasename = "";
           _connect.Connect();

           using (var cmd = new SqlCommand
           {
               CommandText = "proc_GetDatabaseName",
               Connection = _connect.Connection,
               CommandType = CommandType.StoredProcedure
           })
           {


               using (SqlDataReader reader = cmd.ExecuteReader())
               {
                   while (reader.Read())
                   {
                       dataBasename = reader.GetString(reader.GetOrdinal("DatabaseName"));
                   }

               }
               _connect.Disconnect();
               return dataBasename;
           }
       }

    }
}
