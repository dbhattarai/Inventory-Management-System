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
using IMS.Crystal;
using IMS.Report;
using System.Reflection;

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
            LoadComboBox();
            loadGRN();
        }
        private void loadGRN()
        {
            DataTable dt = _BsMgmt.getLatestGRNandISN();
            int GNR = string.IsNullOrEmpty(dt.Rows[0]["GRN"].ToString()) ? 0 : int.Parse(dt.Rows[0]["GRN"].ToString());
            txtGNR.Text = (GNR + 1).ToString();

        }
       
        private void loadGridview()
        {
            DataTable dt = new DataTable();
            dt = _BsMgmt.GetReceivedDetailReport(int.Parse(cmbItem.SelectedValue.ToString()));
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
            Item item = new Item();
                       
            {
                item.ItemName = (cmbItem.Text);
                item.Id= int.Parse(cmbItem.SelectedValue.ToString());
                item.quantity = string.IsNullOrEmpty(txtQuantity.Text) ? 0 : int.Parse(txtQuantity.Text);
                item.Rate = string.IsNullOrEmpty(txtRate.Text) ? 0 : decimal.Parse(txtRate.Text);
                item.amount = string.IsNullOrEmpty(txtAmount.Text) ? 0 : decimal.Parse(txtAmount.Text);
                item.unit = string.IsNullOrEmpty(txtUnit.Text) ? "" :Convert.ToString(txtUnit.Text);
                //foreach (DataGridViewRow row in dgvItem.Rows)
                //{
                //    if (row.Cells["item"].Value.ToString() == cmbItem.Text)
                //    {
                //        dupd = true;
                //    }
                //}
                    dgvItem.Rows.Add(item.ItemName, item.quantity, item.Rate,item.amount,item.Id,item.unit);
                    cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
                    cmbItem.SelectedIndex = -1;
                   txtQuantity.Text = string.Empty;
                   txtRate.Text = string.Empty;
                   txtAmount.Text = string.Empty;
                   txtUnit.Clear();
                   cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;
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

        //private void btnSave_Click(object sender, EventArgs e)
        //{
        //    DataTable dt = new DataTable();
        //    Received rec = new Received();
        //    Balance blnc = new Balance();
        //    int resultReceived=0;
        //    int resultBalance=0;

        //    //To add Column to datatable dt
        //    foreach (PropertyInfo property in rec.GetType().GetProperties())
        //    {
        //        dt.Columns.Add(new DataColumn(property.Name, property.PropertyType));
        //    }
        //    //
        //    //donardonates.Add(new DonarDonated
        //    //{
        //    //    donorId = int.Parse(donates.Cells["sourceId"].Value.ToString()),
        //    //    donatedAmount = decimal.Parse(donates.Cells["DonatedAmount"].Value.ToString()),
        //    //    releaseId = breleaseId
        //    //});
        //    if (dgvItem.Rows.Count > 0)
        //    {
        //        foreach (DataGridViewRow row in dgvItem.Rows)
        //        {
        //            Id = Convert.ToString(Guid.NewGuid().ToString());
        //            rec.Date = Convert.ToDateTime(txtDate.Text);
        //            rec.amount = decimal.Parse(row.Cells["amount"].Value.ToString());
        //            rec.GNR = int.Parse(txtGNR.Text);
        //            rec.itemId = int.Parse(row.Cells["itemId"].Value.ToString());
        //            rec.unit = (row.Cells["unit"].Value.ToString());
        //            rec.itemName = cmbItem.Text;
        //            rec.vendorName = cmbVendor.Text;
        //            rec.quantity = int.Parse(row.Cells["quantity"].Value.ToString());
        //            rec.Rate = decimal.Parse(row.Cells["rate"].Value.ToString());
        //            rec.receivedby = txtReceivedBy.Text;
        //            rec.remarks = txtRemarks.Text;
        //            rec.vendorId = int.Parse(cmbVendor.SelectedValue.ToString());
        //            rec.Id = Id;

        //            blnc.itemId = int.Parse(row.Cells["itemId"].Value.ToString());
        //            blnc.quantity = int.Parse(row.Cells["quantity"].Value.ToString());
        //            blnc.Rate = decimal.Parse(row.Cells["rate"].Value.ToString());
        //            blnc.amount = decimal.Parse(row.Cells["amount"].Value.ToString());
        //            blnc.date = Convert.ToDateTime(txtDate.Text);

        //            resultReceived = _BsMgmt.SaveReceived(rec);
        //            resultBalance = _BsMgmt.SaveBalance(blnc, 1, 0);


        //            DataRow newRow = dt.NewRow();
        //            foreach (PropertyInfo property in rec.GetType().GetProperties())
        //            {
        //                newRow[property.Name] = rec.GetType().GetProperty(property.Name).GetValue(rec, null);
        //            }
        //            dt.Rows.Add(newRow);
        //        }
        //    }
        //    else
        //    {
        //        Id = Convert.ToString(Guid.NewGuid().ToString());
        //        rec.Date = Convert.ToDateTime(txtDate.Text);
        //        rec.amount = decimal.Parse(txtAmount.Text);
        //        rec.GNR = int.Parse(txtGNR.Text);
        //        rec.itemId = int.Parse(cmbItem.SelectedValue.ToString());
        //        rec.itemName = cmbItem.Text;
        //        rec.vendorName = cmbVendor.Text;
        //        rec.unit = (txtUnit.Text.ToString());
        //        rec.quantity = int.Parse(txtQuantity.Text);
        //        rec.Rate = decimal.Parse(txtRate.Text);
        //        rec.receivedby = txtReceivedBy.Text;
        //        rec.remarks = txtRemarks.Text;
        //        rec.vendorId = int.Parse(cmbVendor.SelectedValue.ToString());
        //        rec.Id = Id;

        //        blnc.itemId = rec.itemId;
        //        blnc.quantity = rec.quantity;
        //        blnc.Rate = rec.Rate;
        //        blnc.amount = rec.amount;
        //        blnc.date = Convert.ToDateTime(txtDate.Text);

        //        resultReceived = _BsMgmt.SaveReceived(rec);
        //        resultBalance = _BsMgmt.SaveBalance(blnc, 1, 0);

        //        DataRow newRow = dt.NewRow();
        //        foreach (PropertyInfo property in rec.GetType().GetProperties())
        //        {
        //            newRow[property.Name] = rec.GetType().GetProperty(property.Name).GetValue(rec, null);
        //        }
        //        dt.Rows.Add(newRow);
        //    }
        //    if (resultReceived > 0 && resultBalance > 0)
        //    {
                
        //        MessageBox.Show("Saved Successfully", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
        //        DialogResult result = MessageBox.Show("Do you want to print?", "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
        //        if (result == DialogResult.Yes)
        //        {
        //            //DataSet ds = new DataSet();
        //            //ds.Tables.Add(dt);
        //            //ds.WriteXml("VoucherReceived.xml");

        //            receivedVoucherReport frmcrystal = new receivedVoucherReport(dt,rec.GNR,rec.Date,rec.vendorName,rec.receivedby);
        //            frmcrystal.Show();
        //        }
                
        //            cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
        //            Clear();
        //           // loadGridview();
        //            cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;
   
        //    }
        //    else
        //        MessageBox.Show("Insufficient Information", "Error", MessageBoxButtons.OK, MessageBoxIcon.Information);
        //}

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
            txtQuantity.Text = string.Empty;
            txtRate.Text = string.Empty;
            txtAmount.Text = string.Empty;
            txtUnit.Clear(); //txtRemarks.Clear(); cmbVendor.SelectedIndex = -1;
           // var unitList = _BsMgmt.GetReceivedItem();
            var unitList = _BsSetting.GetItem();
            int itemId = string.IsNullOrEmpty(cmbItem.SelectedValue.ToString()) ? 0 : int.Parse(cmbItem.SelectedValue.ToString());

            foreach (var unit in unitList)
            {
                if (itemId == unit.Id)
                {
                    txtUnit.Text = unit.unit;
                }
            }
            loadGridview();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
            Clear();
            cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;
        }

        private void dgvDetail_CellContentDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            DataTable dt = new DataTable();
            int gnr = Convert.ToInt32(dgvDetail.Rows[e.RowIndex].Cells["GRN_NO"].Value);
            dt=_BsMgmt.GetGRNWiseReceivedDetail(gnr);
            foreach (DataRow dr in dt.Rows)
            {
                cmbVendor.SelectedIndex = cmbVendor.FindString(dr["Vendorname"].ToString());
                txtDate.Text = (dr["ReceivedDate"].ToString());
                txtReceivedBy.Text = dr["receivedBy"].ToString();
                txtRemarks.Text = dr["remarks"].ToString();
                txtGNR.Text = dr["GRN_NO"].ToString();
                dgvItem.Rows.Add(dr["ItemName"].ToString(), dr["Quantity"].ToString(), dr["Rate"].ToString(), dr["Amount"].ToString(), dr["ItemId"].ToString(), dr["Unit"].ToString());
                
            }
           
        }

        private void dgvItem_CellContentDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            cmbItem.SelectedIndex = cmbItem.FindString(dgvItem.Rows[e.RowIndex].Cells["Item"].Value.ToString());
            txtUnit.Text=dgvItem.Rows[e.RowIndex].Cells["unit"].Value.ToString();
            txtQuantity.Text = dgvItem.Rows[e.RowIndex].Cells["quantity"].Value.ToString();
            txtRate.Text = dgvItem.Rows[e.RowIndex].Cells["rate"].Value.ToString();
            txtAmount.Text = dgvItem.Rows[e.RowIndex].Cells["amount"].Value.ToString();
        }

        private void btnPrint_Click(object sender, EventArgs e)
        {

        }
        public DataTable ToDataTable<T>(List<Received> items)
        {
            DataTable dataTable = new DataTable(typeof(T).Name);

            //Get all the properties
            PropertyInfo[] Props = typeof(T).GetProperties(BindingFlags.Public | BindingFlags.Instance);
            foreach (PropertyInfo prop in Props)
            {
                //Setting column names as Property names
                dataTable.Columns.Add(prop.Name);
            }
            foreach (Received item in items)
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
        private void btnSave_Click(object sender, EventArgs e)
        {
            List<Received> rec = new List<Received>();
            DataTable dt = new DataTable();
            List<Balance> blnc = new List<Balance>();
            int resultReceived = 0;
            int resultBalance = 0;
            if (dgvItem.Rows.Count > 0)
            {
                foreach (DataGridViewRow row in dgvItem.Rows)
                {
                    rec.Add(new Received
                    {
                        Date = Convert.ToDateTime(txtDate.Text),
                        amount = decimal.Parse(row.Cells["amount"].Value.ToString()),
                        GNR=int.Parse(txtGNR.Text),
                        itemId=int.Parse(row.Cells["itemId"].Value.ToString()),
                        unit=(row.Cells["unit"].Value.ToString()),
                        itemName=cmbItem.Text,
                        vendorId=int.Parse(cmbVendor.SelectedValue.ToString()),
                        vendorName=cmbVendor.Text,
                        quantity=int.Parse(row.Cells["quantity"].Value.ToString()),
                        Rate=decimal.Parse(row.Cells["rate"].Value.ToString()),
                        receivedby= txtReceivedBy.Text,
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
              //  resultBalance = _BsMgmt.SaveBalance(blnc, 1, 0);
                resultReceived = _BsMgmt.SaveReceived(rec,blnc,1,0);
            }
            else
            {
                rec.Add(new Received
                {
                    Date = Convert.ToDateTime(txtDate.Text),
                    amount = decimal.Parse(txtAmount.Text),
                    GNR = int.Parse(txtGNR.Text),
                    itemId = int.Parse(cmbItem.SelectedValue.ToString()),
                    unit = (txtUnit.Text.ToString()),
                    itemName = cmbItem.Text,
                    vendorId = int.Parse(cmbVendor.SelectedValue.ToString()),
                    vendorName = cmbVendor.Text,
                    quantity = int.Parse(txtQuantity.Text),
                    Rate = decimal.Parse(txtRate.Text),
                    receivedby = txtReceivedBy.Text,
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
                resultReceived = _BsMgmt.SaveReceived(rec, blnc, 1, 0);
               // resultBalance = _BsMgmt.SaveBalance(blnc, 1, 0);
              
            }
            if (resultReceived > 0  )
            {
                
                MessageBox.Show("Saved Successfully", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                DialogResult result = MessageBox.Show("Do you want to print?", "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                if (result == DialogResult.Yes)
                {
                    //DataSet ds = new DataSet();
                    //ds.Tables.Add(dt);
                    //ds.WriteXml("VoucherReceived.xml");
                    dt = ToDataTable<Received>(rec);
                    receivedVoucherReport frmcrystal = new receivedVoucherReport(dt,int.Parse(txtGNR.Text), Convert.ToDateTime(txtDate.Text), cmbVendor.Text, txtReceivedBy.Text);
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
    }
}
