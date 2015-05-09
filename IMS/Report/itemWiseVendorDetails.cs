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
    public partial class itemWiseVendorDetails : Form
    {
        public itemWiseVendorDetails()
        {
            InitializeComponent();
        }
        private string type="";
        private readonly BSReport _report = new BSReport();
        private readonly BsUser _BsUser = new BsUser();
        private readonly BsManagement _BsMgmt = new BsManagement();
        private string item;
        DataTable dt;
        DateTime sDate;
        DateTime eDate;
        private void LoadComboBox()
        {
            cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
            var dept = _BsMgmt.GetReceivedItem();
            cmbItem.DataSource = dept;
            cmbItem.DisplayMember = "ItemName";
            cmbItem.ValueMember = "ItemId";
            cmbItem.SelectedIndex = -1;
            cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;

        }

        private void cmbItem_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void itemWiseVendorDetails_Load(object sender, EventArgs e)
        {
            LoadComboBox();
            txtDateFrom.Text = DateTime.Today.ToString("yyyy/MM/dd");
            txtDateTo.Text = DateTime.Today.ToString("yyyy/MM/dd");
        }

        private void btnDetail_Click(object sender, EventArgs e)
        {
            if(cmbItem.SelectedIndex>-1)
            {
            //to display input parameter details
            grpDepartmentDetail.Visible = true;
            lblDateFrom.Text = string.IsNullOrEmpty(txtDateFrom.Text) ? "" : txtDateFrom.Text;
            lblDateTo.Text = string.IsNullOrEmpty(txtDateTo.Text) ? "" : txtDateTo.Text;
            lblItem.Text = string.IsNullOrEmpty(cmbItem.Text) ? "" : cmbItem.Text;
            //

            print.Visible = true;
            printSummary.Visible = false;
            type = "detail";
            int itemId = int.Parse(cmbItem.SelectedValue.ToString());
            item = cmbItem.Text;
             sDate = DateTime.Parse((txtDateFrom.Text));
             eDate = DateTime.Parse((txtDateTo.Text));
            dt = _report.GetItemWiseVendorReport(sDate, eDate, itemId,type);
            dgvDetail.DataSource = dt;
            }
            else
                MessageBox.Show("Please Select Item", "Required", MessageBoxButtons.OK, MessageBoxIcon.Question);

        }

        private void btnSummary_Click(object sender, EventArgs e)
        {
            if(cmbItem.SelectedIndex>-1)
            {
            //to display input parameter details
            grpDepartmentDetail.Visible = true;
            lblDateFrom.Text = string.IsNullOrEmpty(txtDateFrom.Text) ? "" : txtDateFrom.Text;
            lblDateTo.Text = string.IsNullOrEmpty(txtDateTo.Text) ? "" : txtDateTo.Text;
            lblItem.Text = string.IsNullOrEmpty(cmbItem.Text) ? "" : cmbItem.Text;
            //

            print.Visible = false;
            printSummary.Visible = true;
            type = "summary";
            int itemId = int.Parse(cmbItem.SelectedValue.ToString());
            item = cmbItem.Text;
             sDate = DateTime.Parse((txtDateFrom.Text));
             eDate = DateTime.Parse((txtDateTo.Text));
            dt = _report.GetItemWiseVendorReport(sDate, eDate, itemId,type);
            dgvDetail.DataSource = dt;
            }
            else
                MessageBox.Show("Please Select Item", "Required", MessageBoxButtons.OK, MessageBoxIcon.Question);

        }

        private void print_Click(object sender, EventArgs e)
        {
            //DataSet ds = new DataSet();
            //ds.Tables.Add(dt);
            //ds.WriteXml("ItemWiseVendor.xml");
            frmItemWiseVendorRpt frmcrystal = new frmItemWiseVendorRpt(dt, sDate, eDate,item);
            frmcrystal.Show();
        }

        private void printSummary_Click_1(object sender, EventArgs e)
        {
            //DataSet ds = new DataSet();
            //ds.Tables.Add(dt);
            //ds.WriteXml("ItemWiseVendorSummary.xml");
            frmItemWiseVendorRptSummary frmcrystal = new frmItemWiseVendorRptSummary(dt, sDate, eDate,item);
            frmcrystal.Show();
        }

    }
}
