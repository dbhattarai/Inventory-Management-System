using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using IMS.Crystal.crystalRpts;

namespace IMS.Crystal.crystalForms
{
    public partial class frmLedgerReportRpt : Form
    {
        public frmLedgerReportRpt(DataTable dt,DateTime sDate,DateTime eDate)
        {
            InitializeComponent();
            ItemWiseStockLedger cr = new ItemWiseStockLedger();
            cr.SetDataSource(dt);
            cr.SetParameterValue("DateFrom", sDate);
            cr.SetParameterValue("DateTo", eDate);
            crptViewer.ReportSource = cr;
        }
    }
}
