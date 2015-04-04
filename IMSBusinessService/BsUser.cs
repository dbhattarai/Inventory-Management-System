using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using IMSModel;
using IMSDataRepository;

namespace IMSBusinessService
{
   public class BsUser
    {
       private readonly DsUser _user = new DsUser();
       public DataTable userLogin(User user)
       {
           return _user.userLogin(user);
       }
       public int SaveUser(User user)
       {
           return _user.SaveUser(user);
       }
       public List<Department> GetDepartment()
       {
           return _user.GetDepartment();
       }
    }
}
