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
    public partial class frmItemWiseStockLedgerRpt : Form
    {
        public frmItemWiseStockLedgerRpt(DataTable ds, DateTime fromD, DateTime toD,string item)
        {
            InitializeComponent();
            ItemWiseLedger cr = new ItemWiseLedger();
            cr.SetDataSource(ds);
            cr.SetParameterValue("DateFrom", fromD);
            cr.SetParameterValue("DateTo", toD);
            crptViewer.ReportSource = cr;
        }
    }
}
