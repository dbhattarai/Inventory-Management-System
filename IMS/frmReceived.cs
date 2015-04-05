using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using IMSCommonHelper;
using IMSModel;
using System.Globalization;
using IMSBusinessService;

namespace IMS
{
    public partial class frmReceived : Form
    {
        private readonly BsSetting _BsSetting = new BsSetting();
        private readonly BsManagement _BsMgmt = new BsManagement();
        private string Id = "";

        public frmReceived()
        {
            InitializeComponent();
        }
        private void LoadComboBox()
        {
            cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
            var item = _BsSetting.GetItem();
            cmbItem.DataSource = item;
            cmbItem.DisplayMember = "ItemName";
            cmbItem.ValueMember = "Id";
            cmbItem.SelectedIndex = -1;
            cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;

            var ven = _BsSetting.GetVendor();
            cmbVendor.DataSource = ven;
            cmbVendor.DisplayMember = "VendorName";
            cmbVendor.ValueMember = "venId";
            cmbVendor.SelectedIndex = -1;

        }

        private void frmReceived_Load(object sender, EventArgs e)
        {
            cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
            txtReceivedBy.Text = Global.fullName;
            DateTime theDate = txtDate.Value.Date;
            txtDate.Text = theDate.ToString(); //DateTime.Today.ToString("yyyy/MM/dd");
            LoadComboBox();
            loadGridview();
            loadGRN();
        }
        private void loadGRN()
        {
            DataTable dt = _BsMgmt.getLatestGRNandISN();
            int GNR = int.Parse(dt.Rows[0]["GRN"].ToString());
            txtGNR.Text = (GNR + 1).ToString();

        }
       
        private void loadGridview()
        {
            //dgvDetail.Rows.Clear();
            DataTable dt = new DataTable();
            dt = _BsMgmt.GetReceivedDetailReport();
            dgvDetail.DataSource = dt;
        }
        private void Clear()
        {
            txtAmount.Clear();
            //txtDate.Clear();
            //txtGNR.Clear();
            txtQuantity.Clear();
            txtRate.Clear();
            txtReceivedBy.Clear();
            txtRemarks.Clear();
            txtUnit.Clear();
            cmbItem.SelectedIndex = -1;
            cmbVendor.SelectedIndex = -1;
            dgvItem.Rows.Clear();
            loadGRN();
        }

       
        private void btnAdd_Click(object sender, EventArgs e)
        {
            bool dupd = false;
            Item item = new Item();
                       
            {
                item.ItemName = (cmbItem.Text);
                item.Id= int.Parse(cmbItem.SelectedValue.ToString());
                item.quantity = string.IsNullOrEmpty(txtQuantity.Text) ? 0 : int.Parse(txtQuantity.Text);
                item.Rate = string.IsNullOrEmpty(txtRate.Text) ? 0 : decimal.Parse(txtRate.Text);
                item.amount = string.IsNullOrEmpty(txtAmount.Text) ? 0 : decimal.Parse(txtAmount.Text);
                item.unit = string.IsNullOrEmpty(txtUnit.Text) ? "" :Convert.ToString(txtUnit.Text);
                foreach (DataGridViewRow row in dgvItem.Rows)
                {
                    if (row.Cells["item"].Value.ToString() == cmbItem.Text)
                    {
                        dupd = true;
                    }
                }
                if (!dupd)
                {
                    dgvItem.Rows.Add(item.ItemName, item.quantity, item.Rate,item.amount,item.Id,item.unit);
                    cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
                    cmbItem.SelectedIndex = -1;
                   txtQuantity.Text = string.Empty;
                   txtRate.Text = string.Empty;
                   txtAmount.Text = string.Empty;
                   txtUnit.Clear();
                   cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;
                }
                else
                    MessageBox.Show("Its Alreday Entered", "Duplication", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void txtRate_MouseLeave(object sender, EventArgs e)
        {

            int quantity = 0;
            decimal Rate = 0;
            quantity = string.IsNullOrEmpty(txtQuantity.Text) ? 0 : int.Parse(txtQuantity.Text);
            Rate = string.IsNullOrEmpty(txtRate.Text) ? 0 : int.Parse(txtRate.Text);

            decimal amount = (quantity) * (Rate);
            txtAmount.Text = amount.ToString();
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            Received rec = new Received();
            Balance blnc = new Balance();
            int resultReceived=0;
              int resultBalance=0;
            if (dgvItem.Rows.Count > 0)
            {
                foreach (DataGridViewRow row in dgvItem.Rows)
                {
                    Id = Convert.ToString(Guid.NewGuid().ToString());
                    rec.Date = Convert.ToDateTime(txtDate.Text);
                    rec.amount = decimal.Parse(row.Cells["amount"].Value.ToString());
                    rec.GNR = int.Parse(txtGNR.Text);
                    rec.itemId = int.Parse(row.Cells["itemId"].Value.ToString());
                    rec.unit = (row.Cells["unit"].Value.ToString());
                    rec.quantity = int.Parse(row.Cells["quantity"].Value.ToString());
                    rec.Rate = decimal.Parse(row.Cells["rate"].Value.ToString());
                    rec.receivedby = txtReceivedBy.Text;
                    rec.remarks = txtRemarks.Text;
                    rec.vendorId = int.Parse(cmbVendor.SelectedValue.ToString());
                    rec.Id = Id;

                    blnc.itemId = int.Parse(row.Cells["itemId"].Value.ToString());
                    blnc.quantity = int.Parse(row.Cells["quantity"].Value.ToString());
                    blnc.Rate = decimal.Parse(row.Cells["rate"].Value.ToString());
                    blnc.amount = decimal.Parse(row.Cells["amount"].Value.ToString());
                    blnc.date = Convert.ToDateTime(txtDate.Text);

                    resultReceived = _BsMgmt.SaveReceived(rec);
                    resultBalance = _BsMgmt.SaveBalance(blnc, 1, 0);
                }
            }
            else
            {
                Id = Convert.ToString(Guid.NewGuid().ToString());
                rec.Date = Convert.ToDateTime(txtDate.Text);
                rec.amount = decimal.Parse(txtAmount.Text);
                rec.GNR = int.Parse(txtGNR.Text);
                rec.itemId = int.Parse(cmbItem.SelectedValue.ToString());
                rec.unit = (txtUnit.Text.ToString());
                rec.quantity = int.Parse(txtQuantity.Text);
                rec.Rate = decimal.Parse(txtRate.Text);
                rec.receivedby = txtReceivedBy.Text;
                rec.remarks = txtRemarks.Text;
                rec.vendorId = int.Parse(cmbVendor.SelectedValue.ToString());
                rec.Id = Id;

                blnc.itemId = rec.itemId;
                blnc.quantity = rec.quantity;
                blnc.Rate = rec.Rate;
                blnc.amount = rec.amount;
                blnc.date = Convert.ToDateTime(txtDate.Text);

                resultReceived = _BsMgmt.SaveReceived(rec);
                resultBalance = _BsMgmt.SaveBalance(blnc, 1, 0);
            }
            if (resultReceived > 0 && resultBalance > 0)
            {

                MessageBox.Show("Saved Successfully", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
                Clear();
                loadGridview();
                cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
            }
            else
                MessageBox.Show("Insufficient Information", "Error", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void txtQuantity_MouseLeave(object sender, EventArgs e)
        {
            int quantity = 0;
            decimal Rate = 0;
            quantity = string.IsNullOrEmpty(txtQuantity.Text) ? 0 : int.Parse(txtQuantity.Text);
            Rate = string.IsNullOrEmpty(txtRate.Text) ? 0 : int.Parse(txtRate.Text);

            decimal amount = (quantity) * (Rate);
            txtAmount.Text = amount.ToString();
        }

        private void cmbItem_SelectedIndexChanged(object sender, EventArgs e)
        {
            var unitList = _BsMgmt.GetReceivedItem();
            int itemId = string.IsNullOrEmpty(cmbItem.SelectedValue.ToString()) ? 0 : int.Parse(cmbItem.SelectedValue.ToString());

            foreach (var unit in unitList)
            {
                if (itemId == unit.itemId)
                {
                    txtUnit.Text = unit.unit;
                }
            }

        }

    
    }
}
