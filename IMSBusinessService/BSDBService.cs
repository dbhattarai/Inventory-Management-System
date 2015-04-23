using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using IMSDataRepository;

namespace IMSBusinessService
{
    public class BSDBService
    {
        private readonly DSDBService _dbrepo=new DSDBService();
        public int CreateDBBackUp(string filepath, string dbname, int flag = 1)
        {
            return _dbrepo.CreateDBBackUp(filepath, dbname, flag);
        }
        public string GetCurrentDatabaseName()
        {
            return _dbrepo.GetCurrentDatabaseName();
        }
    }

}
