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
        private string Id = Convert.ToString(Guid.NewGuid().ToString());
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
            txtDate.Text = DateTime.Today.ToString("yyyy/MM/dd");
            LoadComboBox();
            loadGridview();
            txtAmount.Text = "0";
            txtRate.Text = "0";
            txtQuantity.Text = "0";
        }

        private void cmbItem_SelectedIndexChanged(object sender, EventArgs e)
        {
            int itemId=string.IsNullOrEmpty(cmbItem.SelectedValue.ToString()) ? 0:int.Parse(cmbItem.SelectedValue.ToString());
         
            var unitList = _BsSetting.GetItem();
            foreach (var unit in unitList)
            {
                if (itemId == unit.Id)
                {
                    txtUnit.Text = unit.unit;
                }
            }
        }
        private void btnSave_Click(object sender, EventArgs e)
        {
            Received rec = new Received();
            Balance blnc = new Balance();

            blnc.itemId = int.Parse(cmbItem.SelectedValue.ToString());
            blnc.quantity = int.Parse(txtQuantity.Text);
            blnc.Rate = decimal.Parse(txtRate.Text);
            blnc.amount = decimal.Parse(txtAmount.Text);
            blnc.date = Convert.ToDateTime(txtDate.Text);

            rec.Date =Convert.ToDateTime(txtDate.Text);
            rec.amount = decimal.Parse(txtAmount.Text);
            rec.GNR = int.Parse(txtGNR.Text);
            rec.itemId = int.Parse(cmbItem.SelectedValue.ToString());
            rec.unit = (txtUnit.Text.ToString());
            rec.quantity = int.Parse(txtQuantity.Text);
            rec.Rate =decimal.Parse(txtRate.Text);
            rec.receivedby = txtReceivedBy.Text;
            rec.remarks = txtRemarks.Text;
            rec.vendorId=int.Parse(cmbVendor.SelectedValue.ToString());
            rec.Id = Id;
            int resultReceived = _BsMgmt.SaveReceived(rec);
            int resultBalance = _BsMgmt.SaveBalance(blnc,1,0);
            if (resultReceived>0 && resultBalance>0)
            {

                MessageBox.Show("Saved Successfully", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
               // Clear();
                cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
                loadGridview();
            }
            else
                MessageBox.Show("Insufficient Information", "Error", MessageBoxButtons.OK, MessageBoxIcon.Information);
      
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
            txtDate.Clear();
            txtGNR.Clear();
            txtQuantity.Clear();
            txtRate.Clear();
            txtReceivedBy.Clear();
            txtRemarks.Clear();
            txtUnit.Clear();
            cmbItem.SelectedIndex = -1;
            cmbVendor.SelectedIndex = -1;
        }
        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

       
        private void btnAdd_Click(object sender, EventArgs e)
        {
            bool dupd = false;
            Item item = new Item();
           
            
            {
                item.ItemName = (cmbItem.Text);
                item.quantity = string.IsNullOrEmpty(txtQuantity.Text) ? 0 : int.Parse(txtQuantity.Text);
                item.Rate = string.IsNullOrEmpty(txtRate.Text) ? 0 : decimal.Parse(txtRate.Text);
                item.amount = string.IsNullOrEmpty(txtAmount.Text) ? 0 : decimal.Parse(txtAmount.Text);
                foreach (DataGridViewRow row in dgvItem.Rows)
                {
                    if (row.Cells["item"].Value.ToString() == cmbItem.Text)
                    {
                        dupd = true;
                    }
                }
                if (!dupd)
                {
                    dgvItem.Rows.Add(item.ItemName, item.quantity, item.Rate,item.amount);
                   // cmbItem.SelectedIndex = -1;
                   // txtQuantity.Text = string.Empty;
                    //txtRate.Text = string.Empty;
                    //txtAmount.Text = string.Empty;
                }
                else
                    MessageBox.Show("Its Alreday Entered", "Duplication", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void txtRate_MouseLeave(object sender, EventArgs e)
        {
            decimal amount = (int.Parse(txtQuantity.Text)) * (decimal.Parse(txtRate.Text));
            txtAmount.Text = amount.ToString();
        }

    }
}
