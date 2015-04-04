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
            txtQuantity.Text = "0";
            txtRate.Text = "0";
            txtAmount.Text = "0";
            cmbItem.SelectedValue = 0;
            
        }

        private void cmbItem_SelectedIndexChanged(object sender, EventArgs e)
        {
            var unitList = _BsMgmt.GetReceivedItem();
            int itemId=string.IsNullOrEmpty(cmbItem.SelectedValue.ToString()) ? 0:int.Parse(cmbItem.SelectedValue.ToString());
         
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

        private void btnSave_Click(object sender, EventArgs e)
        {
            Issued rec = new Issued();
            rec.Date = Convert.ToDateTime(txtDate.Text);
            rec.amount = decimal.Parse(txtAmount.Text);
            rec.ISN = txtISN.Text;
            rec.itemId = int.Parse(cmbItem.SelectedValue.ToString());
            rec.unit = (txtUnit.Text.ToString());
            rec.quantity = int.Parse(txtQuantity.Text);
            rec.Rate = float.Parse(txtRate.Text);
            rec.receivedby = txtReceivedBy.Text;
            rec.remarks = txtRemarks.Text;
            rec.DeptId = int.Parse(cmbDept.SelectedValue.ToString());
            rec.issuedby = txtIssuedBy.Text;
            rec.Id = Id;
            int result = _BsMgmt.SaveIssued(rec);

            Balance blnc = new Balance();

            blnc.itemId = int.Parse(cmbItem.SelectedValue.ToString());
            blnc.quantity = int.Parse(txtQuantity.Text);
            blnc.Rate = decimal.Parse(txtRate.Text);
            blnc.amount = decimal.Parse(txtAmount.Text);
            blnc.date = Convert.ToDateTime(txtDate.Text);
            int resultBalance = _BsMgmt.SaveBalance(blnc, 0, 1);
            if (result > 0 && resultBalance>0)
            {
                MessageBox.Show("Saved Successfully", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                //Clear();
            }
            else
                MessageBox.Show("Insufficient Information", "Error", MessageBoxButtons.OK, MessageBoxIcon.Information);
      
        }
        private void Clear()
        {
            txtAmount.Clear();
            txtDate.Clear();
            txtISN.Clear();
            txtQuantity.Clear();
            txtRate.Clear();
            txtReceivedBy.Clear();
            txtRemarks.Clear();
            txtUnit.Clear();
            txtIssuedBy.Clear();
            cmbItem.SelectedIndex = -1;
            cmbDept.SelectedIndex = -1;
        }
        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
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

        private void txtRate_MouseLeave(object sender, EventArgs e)
        {
            int quantity = 0;
            decimal Rate = 0;
            quantity=int.Parse(txtQuantity.Text);
            Rate=decimal.Parse(txtRate.Text);

            decimal amount = (quantity) * (Rate);
            txtAmount.Text = amount.ToString();
        }

        private void txtQuantity_MouseLeave(object sender, EventArgs e)
        {
            int quantity = 0;
            decimal Rate = 0;
            quantity = int.Parse(txtQuantity.Text);
            Rate = decimal.Parse(txtRate.Text);

            decimal amount = (quantity) * (Rate);
            txtAmount.Text = amount.ToString();
        }

    }
}
