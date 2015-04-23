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
    public partial class frmVendorWiseItemRptSummary : Form
    {
        public frmVendorWiseItemRptSummary(DataTable dt, DateTime fromD, DateTime toD,string vendor)
        {
            InitializeComponent();
            VendorWiseItemSummary cr = new VendorWiseItemSummary();
            cr.SetDataSource(dt);
            cr.SetParameterValue("DateFrom", fromD);
            cr.SetParameterValue("DateTo", toD);
            cr.SetParameterValue("vendor", vendor);
            crptViewer.ReportSource = cr;

        }
    }
}
