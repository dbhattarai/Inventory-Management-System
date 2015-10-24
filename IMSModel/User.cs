using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace IMSModel
{
    public class User
    {
        public string userId { get; set; }
        public string fullname { get; set; }
        public string username { get; set; }
        public string password { get; set; }
        public string salt { get; set; }
        public string Usertype { get; set; }
        public int DeptId { get; set; }

    }
}
