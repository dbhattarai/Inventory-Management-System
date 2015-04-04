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
        DataSet ds;
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
           
            int itemId = int.Parse(cmbItem.SelectedValue.ToString());
            item = cmbItem.Text;
             sDate = DateTime.Parse((txtDateFrom.Text));
             eDate = DateTime.Parse((txtDateTo.Text));
            ds = _report.GetItemWiseStockReport(sDate, eDate, itemId);
            //dgvReceived.DataSource = ds.Tables[0];
            dgvIssued.DataSource = ds.Tables[0];
            //dgvBalance.DataSource = ds
        }

        private void cmbItem_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void frmItemwiseStockReport_Load(object sender, EventArgs e)
        {
            LoadComboBox();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            //DataSet ds = new DataSet();
            //ds.Tables.Add(ds);
            ds.WriteXml("ItemWiseStockLedger.xml");
            frmItemWiseStockLedgerRpt frmcrystal = new frmItemWiseStockLedgerRpt(ds, sDate, eDate, item);
            frmcrystal.Show();
        }


    }
}
