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

namespace IMS
{
    public partial class frmItemwiseStockReport : Form
    {
        private readonly BSReport _report = new BSReport();
        private readonly BsSetting _setting = new BsSetting();
        DataTable dt;
        DateTime sDate;
        DateTime eDate;
        string item;
        public frmItemwiseStockReport()
        {
            InitializeComponent();
        }
        private void LoadComboBox()
        {
            cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
            var item = _setting.GetItem();
            cmbItem.DataSource = item;
            cmbItem.DisplayMember = "ItemName";
            cmbItem.ValueMember = "Id";
            cmbItem.SelectedIndex = -1;
            cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;

        }
        private void btnShow_Click(object sender, EventArgs e)
        {
            if (cmbItem.SelectedIndex >-1)
            {
               
                int itemId = int.Parse(cmbItem.SelectedValue.ToString());
                item = cmbItem.Text;
                sDate = DateTime.Parse((txtDateFrom.Text));
                eDate = DateTime.Parse((txtDateTo.Text));
                dt = _report.GetItemWiseStockReport(sDate, eDate, itemId);
                //dgvReceived.DataSource = ds.Tables[0];
                dgvIssued.DataSource = dt;
                //dgvBalance.DataSource = ds

                //to display input parameter details
                grpDepartmentDetail.Visible = true;
                lblDateFrom.Text = sDate.ToShortDateString();
                lblDateTo.Text = eDate.ToShortDateString();
                lblItem.Text = item;
                //
             
            }
            else
                MessageBox.Show("Please Select Item", "Required", MessageBoxButtons.OK, MessageBoxIcon.Question);

        }

        private void cmbItem_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void frmItemwiseStockReport_Load(object sender, EventArgs e)
        {
            LoadComboBox();
            txtDateFrom.Text = DateTime.Today.ToString("yyyy/MM/dd");
            txtDateTo.Text = DateTime.Today.ToString("yyyy/MM/dd");
        }

        private void button1_Click(object sender, EventArgs e)
        {
            //DataSet ds = new DataSet();
            //ds.Tables.Add(dt);
            //ds.WriteXml("ItemWiseLedger.xml");
            frmItemWiseStockLedgerRpt frmcrystal = new frmItemWiseStockLedgerRpt(dt, sDate, eDate, item);
            frmcrystal.Show();
        }


    }
}
