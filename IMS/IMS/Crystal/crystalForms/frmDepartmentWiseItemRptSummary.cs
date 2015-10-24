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
    public partial class frmDepartmentWiseItemRptSummary : Form
    {
        public frmDepartmentWiseItemRptSummary(DataTable dt, DateTime fromD, DateTime toD,string dept)
        {
            InitializeComponent();
            DepartmentWiseItemSummary cr = new DepartmentWiseItemSummary();
            cr.SetDataSource(dt);
            cr.SetParameterValue("DateFrom", fromD);
            cr.SetParameterValue("DateTo", toD);
            cr.SetParameterValue("department", dept);
            crptViewer.ReportSource = cr;


        }
    }
}
