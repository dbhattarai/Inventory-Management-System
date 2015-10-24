using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using IMSBusinessService;
using IMS.Crystal.crystalForms;

namespace IMS.Report
{
    public partial class departmentWiseItemReport : Form
    {

        public departmentWiseItemReport()
        {
            InitializeComponent();
        }
        private readonly BSReport _report = new BSReport();
        private readonly BsUser _BsUser = new BsUser();
        private string type = "";
        private string department = "";
        private DataTable dt;
        DateTime sDate;
        DateTime eDate;
        private void LoadComboBox()
        {
            cmbDepartment.SelectedIndexChanged -= cmbDepartment_SelectedIndexChanged;
            var dept = _BsUser.GetDepartment();
            cmbDepartment.DataSource = dept;
            cmbDepartment.DisplayMember = "DepartmentName";
            cmbDepartment.ValueMember = "DeptId";
            cmbDepartment.SelectedIndex = -1;
            cmbDepartment.SelectedIndexChanged += cmbDepartment_SelectedIndexChanged;

        }
      

        private void departmentWiseReport_Load(object sender, EventArgs e)
        {
            LoadComboBox();
            txtDateFrom.Text = DateTime.Today.ToString("yyyy/MM/dd");
            txtDateTo.Text = DateTime.Today.ToString("yyyy/MM/dd");
        }

        private void cmbDepartment_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void btnDetail_Click(object sender, EventArgs e)
        {
            if (cmbDepartment.SelectedIndex >-1)
            {
                

                printDetail.Visible = true;
                printSummary.Visible = false;
                type = "detail";
                int deptId = int.Parse(cmbDepartment.SelectedValue.ToString());
                department = cmbDepartment.Text;
                sDate = DateTime.Parse((txtDateFrom.Text));
                eDate = DateTime.Parse((txtDateTo.Text));
                dt = _report.GetDepartmentWiseItemReport(sDate, eDate, deptId, type);
                dgvDetail.DataSource = dt;

                //to display input parameter details
                grpDepartmentDetail.Visible = true;
                lblDateFrom.Text = sDate.ToShortDateString();//string.IsNullOrEmpty(txtDateFrom.Text) ? "" : txtDateFrom.Text;
                lblDateTo.Text = eDate.ToShortDateString();//string.IsNullOrEmpty(txtDateTo.Text) ? "" : txtDateTo.Text;
                lblDepartment.Text = department;
                //
            }
            else
                MessageBox.Show("Please Select Department", "Required", MessageBoxButtons.OK, MessageBoxIcon.Question);

        }

        private void btnSummary_Click(object sender, EventArgs e)
        {
            if (cmbDepartment.SelectedIndex >-1)
            {
                //to display input parameter details
                grpDepartmentDetail.Visible = true;
                lblDateFrom.Text = string.IsNullOrEmpty(txtDateFrom.Text) ? "" : txtDateFrom.Text;
                lblDateTo.Text = string.IsNullOrEmpty(txtDateTo.Text) ? "" : txtDateTo.Text;
                lblDepartment.Text = string.IsNullOrEmpty(cmbDepartment.Text) ? "" : cmbDepartment.Text;
                //
                printDetail.Visible = false;
                printSummary.Visible = true;
                type = "summary";
                int deptId = int.Parse(cmbDepartment.SelectedValue.ToString());
                department = cmbDepartment.Text;
                sDate = DateTime.Parse((txtDateFrom.Text));
                eDate = DateTime.Parse((txtDateTo.Text));
                dt = _report.GetDepartmentWiseItemReport(sDate, eDate, deptId, type);
                dgvDetail.DataSource = dt;
            }
            else
                MessageBox.Show("Please Select Department", "Required", MessageBoxButtons.OK, MessageBoxIcon.Question);

        }

        private void button1_Click(object sender, EventArgs e)
        {
           // DataSet ds = new DataSet();
            //ds.Tables.Add(dt);
            //ds.WriteXml("DepartmentWiseItem.xml");
            frmDepartmentWiseItemRpt frmcrystal = new frmDepartmentWiseItemRpt(dt,sDate,eDate,department);
            frmcrystal.Show();
        }

        private void printSummary_Click(object sender, EventArgs e)
        {
            //DataSet ds = new DataSet();
            //ds.Tables.Add(dt);
            //ds.WriteXml("DepartmentWiseItemSummary.xml");
            frmDepartmentWiseItemRptSummary frmcrystal = new frmDepartmentWiseItemRptSummary(dt, sDate, eDate,department);
            frmcrystal.Show();
        }

      

    }
}
