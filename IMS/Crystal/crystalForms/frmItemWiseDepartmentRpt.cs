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
    public partial class frmItemWiseDepartmentRpt : Form
    {
        public frmItemWiseDepartmentRpt(DataTable dt, DateTime fromD, DateTime toD)
        {
            InitializeComponent();
            ItemWiseDepartment cr = new ItemWiseDepartment();
            cr.SetDataSource(dt);
            cr.SetParameterValue("DateFrom", fromD);
            cr.SetParameterValue("DateTo", toD);
            crptViewer.ReportSource = cr;
        }
    }
}
