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
    public partial class frmIssued : Form
    {
        private readonly BsUser _BsUser = new BsUser();
        private readonly BsSetting _BsSetting = new BsSetting();
        private string Id = Convert.ToString(Guid.NewGuid().ToString());
        private readonly BsManagement _BsMgmt = new BsManagement();
        public frmIssued()
        {
            InitializeComponent();
        }
        private void LoadComboBox()
        {
            var dept = _BsUser.GetDepartment();
            cmbDept.DataSource = dept;
            cmbDept.DisplayMember = "DepartmentName";
            cmbDept.ValueMember = "DeptId";
            cmbDept.SelectedIndex = -1;

            cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
            var item = _BsMgmt.GetReceivedItem();
            cmbItem.DataSource = item;
            cmbItem.DisplayMember = "ItemName";
            cmbItem.ValueMember = "itemId";
            cmbItem.SelectedIndex = -1;
            cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;
        }
        private void loadItemDetail()
        {
            dgvItemDetail.Rows.Clear();
            List<Received> itemDetail = _BsMgmt.GetReceivedDetail(int.Parse(cmbItem.SelectedValue.ToString()));
            foreach (var item in itemDetail)
            {
                dgvItemDetail.Rows.Add(item.quantity,item.Rate,item.amount);
            }
        }
       
        private void frmIssued_Load(object sender, EventArgs e)
        {
            txtIssuedBy.Text = Global.fullName;
            txtDate.Text = DateTime.Today.ToString("yyyy/MM/dd");
            LoadComboBox();
            loadISN();
        }

        private void loadISN()
        {
            DataTable dt = _BsMgmt.getLatestGRNandISN();
            int ISN = string.IsNullOrEmpty(dt.Rows[0]["ISN"].ToString()) ? 0 : int.Parse(dt.Rows[0]["ISN"].ToString());
           // string.IsNullOrEmpty(txtRate.Text) ? 0 : int.Parse(txtRate.Text);
            txtISN.Text = (ISN + 1).ToString();
        }
       
        private void Clear()
        {
            txtAmount.Clear();
            //txtDate.Clear();
            txtISN.Clear();
            txtQuantity.Clear();
            txtRate.Clear();
            txtReceivedBy.Clear();
            txtRemarks.Clear();
            txtUnit.Clear();
            txtIssuedBy.Clear();
            cmbItem.SelectedIndex = -1;
            cmbDept.SelectedIndex = -1;
            dgvItem.Rows.Clear();
            dgvItemDetail.Rows.Clear();
            loadISN();
        }
        
        private void dgvItemDetail_CellContentDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            txtQuantity.MouseLeave-= txtQuantity_MouseLeave;
            txtQuantity.Text = dgvItemDetail.Rows[e.RowIndex].Cells["colQty"].Value.ToString();
            txtRate.Text = dgvItemDetail.Rows[e.RowIndex].Cells["colRate"].Value.ToString();
            txtAmount.Text = dgvItemDetail.Rows[e.RowIndex].Cells["colAmt"].Value.ToString();
            txtQuantity.MouseLeave += txtQuantity_MouseLeave;
            txtRate.Enabled = false;
            txtAmount.Enabled = false;
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

            loadItemDetail();
            grpItemDetail.Visible = true;
        }

        private void txtQuantity_MouseLeave(object sender, EventArgs e)
        {
            int quantity = string.IsNullOrEmpty(txtQuantity.Text) ? 0 : int.Parse(txtQuantity.Text);
            int Rate = string.IsNullOrEmpty(txtRate.Text) ? 0 : int.Parse(txtRate.Text);

            decimal amount = (quantity) * (Rate);
            txtAmount.Text = amount.ToString();
        }

        private void txtRate_MouseLeave(object sender, EventArgs e)
        {
            int quantity = string.IsNullOrEmpty(txtQuantity.Text) ? 0 : int.Parse(txtQuantity.Text);
            int Rate = string.IsNullOrEmpty(txtRate.Text) ? 0 : int.Parse(txtRate.Text);

            decimal amount = (quantity) * (Rate);
            txtAmount.Text = amount.ToString();
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            bool dupd = false;
            int quantity=0;
            Item item = new Item();

            {
                item.ItemName = (cmbItem.Text);
                item.Id = int.Parse(cmbItem.SelectedValue.ToString());
                item.quantity = string.IsNullOrEmpty(txtQuantity.Text) ? 0 : int.Parse(txtQuantity.Text);
               decimal rate= item.Rate = string.IsNullOrEmpty(txtRate.Text) ? 0 : decimal.Parse(txtRate.Text);
                item.amount = string.IsNullOrEmpty(txtAmount.Text) ? 0 : decimal.Parse(txtAmount.Text);
                item.unit = string.IsNullOrEmpty(txtUnit.Text) ? "" : Convert.ToString(txtUnit.Text);
                foreach (DataGridViewRow row in dgvItem.Rows)
                {
                    if (row.Cells["item"].Value.ToString() == cmbItem.Text)
                    {
                        dupd = true;
                    }
                }
                foreach (DataGridViewRow row in dgvItemDetail.Rows)
                {
                    if (decimal.Parse(row.Cells["colRate"].Value.ToString()) == rate)
                    {
                        quantity = int.Parse(row.Cells["colQty"].Value.ToString()) - int.Parse(txtQuantity.Text);
                        decimal amount=(decimal.Parse(row.Cells["colAmt"].Value.ToString()) - decimal.Parse(txtAmount.Text));
                        if (quantity > 0)
                        {
                            row.Cells["colQty"].Value = quantity;
                            row.Cells["colAmt"].Value = amount;
                        }
                        break;
                    }
                }
                if (!dupd && quantity>0)
                {
                    dgvItem.Rows.Add(item.ItemName, item.quantity, item.Rate, item.amount, item.Id, item.unit);
                    cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
                    clearItemDetail();
                    cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;
                }
                else if(quantity<0)
                    {
                        MessageBox.Show("Quantity Exceeds", "Not Sufficient Number", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
                        clearItemDetail();
                        cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;
                    }
                else
                    MessageBox.Show("Its Alreday Entered", "Duplication", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
        private void clearItemDetail()
        {
            cmbItem.SelectedIndex = -1;
            txtQuantity.Text = string.Empty;
            txtRate.Text = string.Empty;
            txtAmount.Text = string.Empty;
            txtUnit.Clear();
        }
        private void btnSave_Click_1(object sender, EventArgs e)
        {

            Issued iss = new Issued();
            Balance blnc = new Balance();
            int resultisseived = 0;
            int resultBalance = 0;
            if (dgvItem.Rows.Count > 0)
            {
                foreach (DataGridViewRow row in dgvItem.Rows)
                {
                    Id = Convert.ToString(Guid.NewGuid().ToString());
                    iss.Date = Convert.ToDateTime(txtDate.Text);
                    iss.amount = decimal.Parse(row.Cells["amount"].Value.ToString());
                    iss.ISN = int.Parse(txtISN.Text);
                    iss.itemId = int.Parse(row.Cells["itemId"].Value.ToString());
                    iss.unit = (row.Cells["unit"].Value.ToString());
                    iss.quantity = int.Parse(row.Cells["quantity"].Value.ToString());
                    iss.Rate = decimal.Parse(row.Cells["rate"].Value.ToString());
                    iss.issuedby = txtIssuedBy.Text;
                    iss.receivedby = txtReceivedBy.Text;
                    iss.remarks = txtRemarks.Text;
                    iss.DeptId = int.Parse(cmbDept.SelectedValue.ToString());
                    iss.Id = Id;

                    blnc.itemId = int.Parse(row.Cells["itemId"].Value.ToString());
                    blnc.quantity = int.Parse(row.Cells["quantity"].Value.ToString());
                    blnc.Rate = decimal.Parse(row.Cells["rate"].Value.ToString());
                    blnc.amount = decimal.Parse(row.Cells["amount"].Value.ToString());
                    blnc.date = Convert.ToDateTime(txtDate.Text);

                    resultisseived = _BsMgmt.SaveIssued(iss);
                    resultBalance = _BsMgmt.SaveBalance(blnc, 1, 0);
                }
            }
            else
            {
                Id = Convert.ToString(Guid.NewGuid().ToString());
                iss.Date = Convert.ToDateTime(txtDate.Text);
                iss.amount = decimal.Parse(txtAmount.Text);
                iss.ISN = int.Parse(txtISN.Text);
                iss.itemId = int.Parse(cmbItem.SelectedValue.ToString());
                iss.unit = (txtUnit.Text.ToString());
                iss.quantity = int.Parse(txtQuantity.Text);
                iss.Rate = decimal.Parse(txtRate.Text);
                iss.issuedby = txtIssuedBy.Text;
                iss.receivedby = txtReceivedBy.Text;
                iss.remarks = txtRemarks.Text;
                iss.DeptId = int.Parse(cmbDept.SelectedValue.ToString());
                iss.Id = Id;

                blnc.itemId = iss.itemId;
                blnc.quantity = iss.quantity;
                blnc.Rate = iss.Rate;
                blnc.amount = iss.amount;
                blnc.date = Convert.ToDateTime(txtDate.Text);

                resultisseived = _BsMgmt.SaveIssued(iss);
                resultBalance = _BsMgmt.SaveBalance(blnc, 1, 0);
            }
            if (resultisseived > 0 && resultBalance > 0)
            {

                MessageBox.Show("Saved Successfully", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
                Clear();
                loadGridview();
                cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;
            }
            else
                MessageBox.Show("Insufficient Information", "Error", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
        private void loadGridview()
        {
        }

        private void btnCancel_Click_1(object sender, EventArgs e)
        {
            Clear();
        }

        private void cmbDept_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

     
    }
}
