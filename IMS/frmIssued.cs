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
using System.Reflection;
using IMS.Report;
using IMS.Crystal.crystalForms;

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
            //bool dupd = false;
            int quantity=0;
            Item item = new Item();

            {
                item.ItemName = (cmbItem.Text);
                item.Id = int.Parse(cmbItem.SelectedValue.ToString());
                item.quantity = string.IsNullOrEmpty(txtQuantity.Text) ? 0 : int.Parse(txtQuantity.Text);
               decimal rate= item.Rate = string.IsNullOrEmpty(txtRate.Text) ? 0 : decimal.Parse(txtRate.Text);
                item.amount = string.IsNullOrEmpty(txtAmount.Text) ? 0 : decimal.Parse(txtAmount.Text);
                item.unit = string.IsNullOrEmpty(txtUnit.Text) ? "" : Convert.ToString(txtUnit.Text);
               
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
                if ( quantity>0)
                {
                    dgvItem.Rows.Add(item.ItemName, item.quantity, item.Rate, item.amount, item.Id, item.unit);
                    cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
                    clearItemDetail();
                    cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;
                }
                else 
                    {
                        MessageBox.Show("Quantity Exceeds", "Not Sufficient Number", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
                        clearItemDetail();
                        cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;
                    }
                
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
        //private void btnSave_Click_1(object sender, EventArgs e)
        //{

        //    Issued iss = new Issued();
        //    Balance blnc = new Balance();
        //    int resultisseived = 0;
        //    int resultBalance = 0;
        //    if (dgvItem.Rows.Count > 0)
        //    {
        //        foreach (DataGridViewRow row in dgvItem.Rows)
        //        {
        //            Id = Convert.ToString(Guid.NewGuid().ToString());
        //            iss.Date = Convert.ToDateTime(txtDate.Text);
        //            iss.amount = decimal.Parse(row.Cells["amount"].Value.ToString());
        //            iss.ISN = int.Parse(txtISN.Text);
        //            iss.itemId = int.Parse(row.Cells["itemId"].Value.ToString());
        //            iss.unit = (row.Cells["unit"].Value.ToString());
        //            iss.quantity = int.Parse(row.Cells["quantity"].Value.ToString());
        //            iss.Rate = decimal.Parse(row.Cells["rate"].Value.ToString());
        //            iss.issuedby = txtIssuedBy.Text;
        //            iss.receivedby = txtReceivedBy.Text;
        //            iss.remarks = txtRemarks.Text;
        //            iss.DeptId = int.Parse(cmbDept.SelectedValue.ToString());
        //            iss.Id = Id;

        //            blnc.itemId = int.Parse(row.Cells["itemId"].Value.ToString());
        //            blnc.quantity = int.Parse(row.Cells["quantity"].Value.ToString());
        //            blnc.Rate = decimal.Parse(row.Cells["rate"].Value.ToString());
        //            blnc.amount = decimal.Parse(row.Cells["amount"].Value.ToString());
        //            blnc.date = Convert.ToDateTime(txtDate.Text);

        //            resultisseived = _BsMgmt.SaveIssued(iss);
        //           // resultBalance = _BsMgmt.SaveBalance(blnc, 0, 1);
        //        }
        //    }
        //    else
        //    {
        //        Id = Convert.ToString(Guid.NewGuid().ToString());
        //        iss.Date = Convert.ToDateTime(txtDate.Text);
        //        iss.amount = decimal.Parse(txtAmount.Text);
        //        iss.ISN = int.Parse(txtISN.Text);
        //        iss.itemId = int.Parse(cmbItem.SelectedValue.ToString());
        //        iss.unit = (txtUnit.Text.ToString());
        //        iss.quantity = int.Parse(txtQuantity.Text);
        //        iss.Rate = decimal.Parse(txtRate.Text);
        //        iss.issuedby = txtIssuedBy.Text;
        //        iss.receivedby = txtReceivedBy.Text;
        //        iss.remarks = txtRemarks.Text;
        //        iss.DeptId = int.Parse(cmbDept.SelectedValue.ToString());
        //        iss.Id = Id;

        //        blnc.itemId = iss.itemId;
        //        blnc.quantity = iss.quantity;
        //        blnc.Rate = iss.Rate;
        //        blnc.amount = iss.amount;
        //        blnc.date = Convert.ToDateTime(txtDate.Text);

        //        resultisseived = _BsMgmt.SaveIssued(iss);
        //        //resultBalance = _BsMgmt.SaveBalance(blnc, 0, 1);
        //    }
        //    if (resultisseived > 0 && resultBalance > 0)
        //    {

        //        MessageBox.Show("Saved Successfully", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
        //        cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
        //        Clear();
        //        loadGridview();
        //        cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;
        //    }
        //    else
        //        MessageBox.Show("Insufficient Information", "Error", MessageBoxButtons.OK, MessageBoxIcon.Information);
        //}
        private void loadGridview()
        {
        }

        private void btnCancel_Click_1(object sender, EventArgs e)
        {
            cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
            Clear();
            cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;
        }

        private void dgvItemDetail_CellContentDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            txtQuantity.MouseLeave -= txtQuantity_MouseLeave;
            txtQuantity.Text = dgvItemDetail.Rows[e.RowIndex].Cells["colQty"].Value.ToString();
            txtRate.Text = dgvItemDetail.Rows[e.RowIndex].Cells["colRate"].Value.ToString();
            txtAmount.Text = dgvItemDetail.Rows[e.RowIndex].Cells["colAmt"].Value.ToString();
            txtQuantity.MouseLeave += txtQuantity_MouseLeave;
            txtRate.Enabled = false;
            txtAmount.Enabled = false;
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
             List<Issued> iss = new List<Issued>();
            DataTable dt = new DataTable();
            List<Balance> blnc = new List<Balance>();
            int resultissued = 0;
            int resultBalance = 0; int resTransaction = 0;
            if (dgvItem.Rows.Count > 0)
            {
                foreach (DataGridViewRow row in dgvItem.Rows)
                {
                    iss.Add(new Issued
                    {
                        Date = Convert.ToDateTime(txtDate.Text),
                        amount = decimal.Parse(row.Cells["amount"].Value.ToString()),
                        ISN=int.Parse(txtISN.Text),
                        itemId=int.Parse(row.Cells["itemId"].Value.ToString()),
                        unit=(row.Cells["unit"].Value.ToString()),
                        DeptId=int.Parse(cmbDept.SelectedValue.ToString()),
                        quantity=int.Parse(row.Cells["quantity"].Value.ToString()),
                        Rate=decimal.Parse(row.Cells["rate"].Value.ToString()),
                        receivedby= txtReceivedBy.Text,
                        issuedby=txtIssuedBy.Text,
                        remarks=txtRemarks.Text,
                        Id = Convert.ToString(Guid.NewGuid().ToString())
                    });
                    blnc.Add(new Balance
                    {
                        date = Convert.ToDateTime(txtDate.Text),
                        amount = decimal.Parse(row.Cells["amount"].Value.ToString()),
                        itemId = int.Parse(row.Cells["itemId"].Value.ToString()),
                        quantity = int.Parse(row.Cells["quantity"].Value.ToString()),
                        Rate = decimal.Parse(row.Cells["rate"].Value.ToString()),
                    });
                   
                }
               // resultBalance = _BsMgmt.SaveBalance(blnc, 0, 1);
                resultissued = _BsMgmt.SaveIssued(iss,blnc,0,1);
               // resTransaction = _BsMgmt.SaveDailyTransaction(blnc, 0, 1);
            }
            else
            {
                iss.Add(new Issued
                {
                    Date = Convert.ToDateTime(txtDate.Text),
                    amount = decimal.Parse(txtAmount.Text),
                    ISN = int.Parse(txtISN.Text),
                    itemId = int.Parse(cmbItem.SelectedValue.ToString()),
                    unit = (txtUnit.Text.ToString()),
                    DeptId = int.Parse(cmbDept.SelectedValue.ToString()),
                    quantity = int.Parse(txtQuantity.Text),
                    Rate = decimal.Parse(txtRate.Text),
                    receivedby = txtReceivedBy.Text,
                    issuedby=txtIssuedBy.Text,
                    remarks = txtRemarks.Text,
                    Id = Convert.ToString(Guid.NewGuid().ToString())
                });

                blnc.Add(new Balance
                {
                    date = Convert.ToDateTime(txtDate.Text),
                    amount = decimal.Parse(txtAmount.Text),
                    itemId = int.Parse(cmbItem.SelectedValue.ToString()),
                    quantity = int.Parse(txtQuantity.Text),
                    Rate = decimal.Parse(txtRate.Text),
                });
                resultissued = _BsMgmt.SaveIssued(iss, blnc, 0, 1);
              //  resultBalance = _BsMgmt.SaveBalance(blnc, 0, 1);
               // resTransaction = _BsMgmt.SaveDailyTransaction(blnc, 0, 1);
              
            }
            if (resultissued > 0 && resultBalance > 0 && resTransaction>0)
            {
                
                MessageBox.Show("Saved Successfully", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                DialogResult result = MessageBox.Show("Do you want to print?", "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                if (result == DialogResult.Yes)
                {
                    dt = ToDataTable<Issued>(iss);
                    //DataSet ds = new DataSet();
                    //ds.Tables.Add(dt);
                    //ds.WriteXml("IssuedVoucher.xml");
                   
                    issuedVoucherReport frmcrystal = new issuedVoucherReport(dt);
                   frmcrystal.Show();
                }

                cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
                Clear();
                // loadGridview();
                cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;

            }
            else
                MessageBox.Show("Insufficient Information", "Error", MessageBoxButtons.OK, MessageBoxIcon.Information);
        
        }
        public DataTable ToDataTable<T>(List<Issued> items)
        {
            DataTable dataTable = new DataTable(typeof(T).Name);

            //Get all the properties
            PropertyInfo[] Props = typeof(T).GetProperties(BindingFlags.Public | BindingFlags.Instance);
            foreach (PropertyInfo prop in Props)
            {
                //Setting column names as Property names
                dataTable.Columns.Add(prop.Name);
            }
            foreach (Issued item in items)
            {
                var values = new object[Props.Length];
                for (int i = 0; i < Props.Length; i++)
                {
                    //inserting property values to datatable rows
                    values[i] = Props[i].GetValue(item, null);
                }
                dataTable.Rows.Add(values);
            }
            //put a breakpoint here and check datatable
            return dataTable;
        }

    }
}
