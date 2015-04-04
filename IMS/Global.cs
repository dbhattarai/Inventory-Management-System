using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace IMS
{

   public static class Global
    {
        public static int UserId;
        public static string CurrentDate;
        public static string UserName;
        public static string fullName;
        public static string Password;
        public static string Utype;
        public static int deptId;
        public static void SetUserId(int uId)
        {
            UserId = uId;
        }

        public static void SetUserName(string username)
        {
            UserName = username;
        }
        public static void SetUserPassword(string password)
        {
            Password = password;
        }

        public static void SetFullName(string name)
        {
            fullName = name;
        }
        public static void SetUserType(string utype)
        {
            Utype = utype;
        }
       
    }
}
