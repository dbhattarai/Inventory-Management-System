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
    public partial class itemWiseDepartmentReport : Form
    {
        public itemWiseDepartmentReport()
        {
            InitializeComponent();
        }
        private readonly BSReport _report = new BSReport();
        private readonly BsManagement _BsMgmt = new BsManagement();
        private string type = "";
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

        private void itemWiseDepartmentReport_Load(object sender, EventArgs e)
        {
            LoadComboBox();
            txtDateFrom.Text = DateTime.Today.ToString("yyyy/MM/dd");
            txtDateTo.Text = DateTime.Today.ToString("yyyy/MM/dd");
        }

        private void cmbItem_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void btnDetail_Click(object sender, EventArgs e)
        {
            type = "detail";
            int itemId = int.Parse(cmbItem.SelectedValue.ToString());
             sDate = DateTime.Parse((txtDateFrom.Text));
             eDate = DateTime.Parse((txtDateTo.Text));
            dt = _report.GetItemWiseDepartmentReport(sDate, eDate, itemId,type);
            dgvDetail.DataSource = dt;
        }

        private void btnSummary_Click(object sender, EventArgs e)
        {
            
            type = "summary";
            int itemId = int.Parse(cmbItem.SelectedValue.ToString());
             sDate = DateTime.Parse((txtDateFrom.Text));
             eDate = DateTime.Parse((txtDateTo.Text));
            dt = _report.GetItemWiseDepartmentReport(sDate, eDate, itemId, type);
            dgvDetail.DataSource = dt;
        }

        private void print_Click(object sender, EventArgs e)
        {
            //DataSet ds = new DataSet();
            //ds.Tables.Add(dt);
            //ds.WriteXml("ItemWiseDepartment.xml");
            frmItemWiseDepartmentRpt frmcrystal = new frmItemWiseDepartmentRpt(dt, sDate, eDate);
            frmcrystal.Show();
        }

    }
}

