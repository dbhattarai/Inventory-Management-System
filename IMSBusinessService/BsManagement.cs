using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using IMSModel;
using IMSDataRepository;
using System.Data;

namespace IMSBusinessService
{
    public class BsManagement
    {
        private readonly DsManagement _mgmt = new DsManagement();
        public int SaveReceived(Received rec)
        {
            return _mgmt.SaveReceived(rec);
        }
        public int SaveIssued(Issued iss)
        {
            return _mgmt.SaveIssued(iss);
        }
        public List<Received> GetReceivedDetail(int itemId)
        {
            return _mgmt.GetReceivedDetail(itemId);
        }
        public DataTable GetReceivedDetailReport()
        {
            return _mgmt.GetReceivedDetailReport();
        }
        public List<Received> GetReceivedItem()
        {
            return _mgmt.GetReceivedItem();
        }
        public int SaveBalance(Balance blnc,int rec,int issue)
        {
            return _mgmt.SaveBalance(blnc,rec,issue);
        }
        public DataTable getLatestGRNandISN()
        {
            return _mgmt.getLatestGRNandISN();
        }
    }
}
