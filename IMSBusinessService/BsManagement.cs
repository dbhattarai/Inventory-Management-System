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
        //public int SaveReceived(Received rec)
        //{
        //    return _mgmt.SaveReceived(rec);
        //}
        //public int SaveReceived(List<Received> received)
        //{
        //    return _mgmt.SaveReceived(received);
        //}
        public int SaveReceived(List<Received> received, List<Balance> balance, int recFlag, int issue)
        {
            return _mgmt.SaveReceived(received,balance,recFlag,issue);
        }
        public int SaveIssued(List<Issued> issued, List<Balance> balance, int recFlag, int issue)
        {
            return _mgmt.SaveIssued(issued,balance,recFlag,issue);
        }
        public List<Received> GetReceivedDetail(int itemId)
        {
            return _mgmt.GetReceivedDetail(itemId);
        }
        public DataTable GetReceivedDetailReport(int itemId)
        {
            return _mgmt.GetReceivedDetailReport(itemId);
        }
        public List<Received> GetReceivedItem()
        {
            return _mgmt.GetReceivedItem();
        }
        public int SaveBalance(List<Balance> balance, int rec, int issue)
        {
            return _mgmt.SaveBalance(balance, rec, issue);
        }
        public int SaveDailyTransaction(List<Balance> balance, int rec, int issue)
        {
            return _mgmt.SaveDailyTransaction(balance, rec, issue);
        }
        public DataTable getLatestGRNandISN()
        {
            return _mgmt.getLatestGRNandISN();
        }
        public DataTable GetGRNWiseReceivedDetail(int grn)
        {
            return _mgmt.GetGRNWiseReceivedDetail(grn);
        }
    }
}
