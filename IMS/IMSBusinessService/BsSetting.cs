using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using IMSModel;
using IMSDataRepository;
using System.Data;

namespace IMSBusinessService
{
    public class BsSetting
    {
        private readonly DSSetting _Setting = new DSSetting();
        public int SaveItem(Item item)
        {
            return _Setting.SaveItem(item);
        }
        public int SaveDepartment(Department dept)
        {
            return _Setting.SaveDepartment(dept);
        }
        public int SaveVendor(Vendor ven)
        {
            return _Setting.SaveVendor(ven);
        }
        public List<Item> GetItem()
        {
            return _Setting.GetItem();
        }
        public List<Vendor> GetVendor()
        {
            return _Setting.GetVendor();
        }
        public DataTable SearchItem(string search)
        {
            return _Setting.SearchItem(search);
        }

    }
}
