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
    public partial class frmItemWiseVendorRptSummary : Form
    {
        public frmItemWiseVendorRptSummary(DataTable dt, DateTime fromD, DateTime toD,string item)
        {
            InitializeComponent();
            ItemWiseVendorSummary cr = new ItemWiseVendorSummary();
            cr.SetDataSource(dt);
            cr.SetParameterValue("DateFrom", fromD);
            cr.SetParameterValue("DateTo", toD);
            cr.SetParameterValue("item", item);
            crptViewer.ReportSource = cr;
        }
    }
}
