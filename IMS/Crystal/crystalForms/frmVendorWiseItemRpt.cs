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
    public partial class frmVendorWiseItemRpt : Form
    {
        public frmVendorWiseItemRpt(DataTable ds, DateTime fromD, DateTime toD)
        {
            InitializeComponent();
            VendorWiseItem cr = new VendorWiseItem();
            cr.SetDataSource(ds);
            cr.SetParameterValue("DateFrom", fromD);
            cr.SetParameterValue("DateTo", toD);
            crptViewer.ReportSource = cr;
        }
    }
}
