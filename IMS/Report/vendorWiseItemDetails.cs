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
    public partial class vendorWiseItemDetails : Form
    {
        public vendorWiseItemDetails()
        {
            InitializeComponent();
        }
        private string type = "";
        private readonly BSReport _report = new BSReport();
        private readonly BsSetting _BsSetting = new BsSetting();
        private string vendor;
        DataTable dt;
        DateTime sDate;
        DateTime eDate;
        private void LoadComboBox()
        {
            cmbVendor.SelectedIndexChanged -= cmbVendor_SelectedIndexChanged;
            var ven = _BsSetting.GetVendor();
            cmbVendor.DataSource = ven;
            cmbVendor.DisplayMember = "VendorName";
            cmbVendor.ValueMember = "venId";
            cmbVendor.SelectedIndex = -1;
            cmbVendor.SelectedIndexChanged += cmbVendor_SelectedIndexChanged;

        }
        

        private void cmbVendor_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void vendorWiseItemDetails_Load(object sender, EventArgs e)
        {
            LoadComboBox();
            txtDateFrom.Text = DateTime.Today.ToString("yyyy/MM/dd");
            txtDateTo.Text = DateTime.Today.ToString("yyyy/MM/dd");
        }

        private void btnDetail_Click(object sender, EventArgs e)
        {
            print.Visible = true;
            printSummary.Visible = false;
            type = "detail";
            int venId = int.Parse(cmbVendor.SelectedValue.ToString());
            vendor = cmbVendor.Text;
             sDate = DateTime.Parse((txtDateFrom.Text));
             eDate = DateTime.Parse((txtDateTo.Text));
            dt = _report.GetVendorWiseItemReport(sDate, eDate, venId,type);
            dgvDetail.DataSource = dt;
        }

        private void btnSummary_Click(object sender, EventArgs e)
        {
            print.Visible = false;
            printSummary.Visible = true;
            type = "summary";
            int venId = int.Parse(cmbVendor.SelectedValue.ToString());
            vendor = cmbVendor.Text;
             sDate = DateTime.Parse((txtDateFrom.Text));
             eDate = DateTime.Parse((txtDateTo.Text));
            dt = _report.GetVendorWiseItemReport(sDate, eDate, venId,type);
            dgvDetail.DataSource = dt;
        }

        private void print_Click(object sender, EventArgs e)
        {
            //DataSet ds = new DataSet();
            //ds.Tables.Add(dt);
            //ds.WriteXml("VendorWiseItem.xml");
            frmVendorWiseItemRpt frmcrystal = new frmVendorWiseItemRpt(dt, sDate, eDate,vendor);
            frmcrystal.Show();
        }

        private void printSummary_Click(object sender, EventArgs e)
        {
            //DataSet ds = new DataSet();
            //ds.Tables.Add(dt);
            //ds.WriteXml("VendorWiseItemSummary.xml");
            frmVendorWiseItemRptSummary frmcrystal = new frmVendorWiseItemRptSummary(dt, sDate, eDate,vendor);
            frmcrystal.Show();
        }

    }
}

