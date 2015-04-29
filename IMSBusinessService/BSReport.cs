using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using IMSModel;
using IMSDataRepository;
using System.Data;

namespace IMSBusinessService
{
   public class BSReport
    {
       private readonly DSReport _report = new DSReport();

       public DataTable GetItemWiseStockReport(DateTime dateFrom, DateTime dateTo, int itemId)
       {
           return _report.GetItemWiseStockReport(dateFrom, dateTo, itemId);
       }
       public DataTable GetItemWiseDepartmentReport(DateTime dateFrom, DateTime dateTo, int itemId,string type)
       {
           return _report.GetItemWiseDepartmentReport(dateFrom, dateTo, itemId,type);
       }
       public DataTable GetDepartmentWiseItemReport(DateTime dateFrom, DateTime dateTo, int deptId,string type)
       {
           return _report.GetDepartmentWiseItemReport(dateFrom, dateTo, deptId,type);
       }
       public DataTable GetItemWiseVendorReport(DateTime dateFrom, DateTime dateTo, int itemId,string type)
       {
           return _report.GetItemWiseVendorReport(dateFrom, dateTo, itemId,type);
       }
       public DataTable GetVendorWiseItemReport(DateTime dateFrom, DateTime dateTo, int venId,string type)
       {
           return _report.GetVendorWiseItemReport(dateFrom, dateTo, venId,type);
       }
       public DataTable ledgerReport(DateTime dateFrom, DateTime dateTo)
       {
           return _report.ledgerReport(dateFrom, dateTo);
       }
    }
}
