using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using IMSBusinessService;
using IMSModel;
using IMS.Report;

namespace IMS
{
    public partial class frmGRNVoucherDetails : Form
    {
        private readonly BsManagement _BsMgmt = new BsManagement();
        public frmGRNVoucherDetails()
        {
            InitializeComponent();
            txtDateFrom.Text = (DateTime.Now).ToShortDateString();
            txtDateTo.Text = (DateTime.Now).ToShortDateString();
           // dataGridView1.DataSource = _BsMgmt.GetGRNVoucherDetails(Convert.ToDateTime("01/01/2015").Date,Convert.ToDateTime("01/01/2016").Date);
        }

        private void frmGRNVoucherDetails_Load(object sender, EventArgs e)
        {
            
           
        }
        private void loadGridVIew()
        {
            dgvReceived.Rows.Clear();
            List<Received> receive = new List<Received>();
            DateTime sDate = DateTime.Parse((txtDateFrom.Text));
            DateTime eDate = DateTime.Parse((txtDateTo.Text));
            receive = _BsMgmt.GetGRNVoucherDetails(sDate, eDate);
            foreach (var rec in receive)
            {
                dgvReceived.Rows.Add(rec.Id, rec.itemId, rec.vendorId, rec.unit, rec.receivedby, rec.remarks, rec.GNR, rec.Date.ToShortDateString(), rec.itemName, rec.vendorName, rec.quantity, rec.Rate, rec.amount);
            }
        }
        private void btnShow_Click(object sender, EventArgs e)
        {
            loadGridVIew();
        }

        private void dgvReceived_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            if (dgvReceived.Rows[e.RowIndex].Cells[e.ColumnIndex].Value.ToString() == "EDIT")
            {
                bool editmode = true;
                // dgvReceived.EditMode = DataGridViewEditMode.EditOnKeystrokeOrF2;
                List<Received> rec = new List<Received>();

                rec.Add(new Received
                {
                    Date = Convert.ToDateTime(dgvReceived.Rows[e.RowIndex].Cells["date"].Value.ToString()),
                    amount = decimal.Parse(dgvReceived.Rows[e.RowIndex].Cells["amount"].Value.ToString()),
                    itemId = int.Parse(dgvReceived.Rows[e.RowIndex].Cells["itemId"].Value.ToString()),
                    vendorId = int.Parse(dgvReceived.Rows[e.RowIndex].Cells["vendorId"].Value.ToString()),
                    quantity = decimal.Parse(dgvReceived.Rows[e.RowIndex].Cells["quantity"].Value.ToString()),
                    Rate = decimal.Parse(dgvReceived.Rows[e.RowIndex].Cells["rate"].Value.ToString()),
                    receivedby = string.IsNullOrEmpty(dgvReceived.Rows[e.RowIndex].Cells["receivedBy"].Value.ToString()) ? " " : Convert.ToString(dgvReceived.Rows[e.RowIndex].Cells["receivedBy"].Value.ToString()),
                    remarks = string.IsNullOrEmpty(dgvReceived.Rows[e.RowIndex].Cells["remarks"].Value.ToString()) ? " " : dgvReceived.Rows[e.RowIndex].Cells["remarks"].Value.ToString(),
                    itemName = (dgvReceived.Rows[e.RowIndex].Cells["item"].Value.ToString()),
                    vendorName = (dgvReceived.Rows[e.RowIndex].Cells["vendor"].Value.ToString()),
                    unit = (dgvReceived.Rows[e.RowIndex].Cells["unit"].Value.ToString()),
                    Id = dgvReceived.Rows[e.RowIndex].Cells["id"].Value.ToString(),
                    GNR = int.Parse(dgvReceived.Rows[e.RowIndex].Cells["grn"].Value.ToString()),
                });

                frmReceived fr = new frmReceived(editmode, rec);
                fr.Show();
                fr.Activate();
                fr.BringToFront();
            }

            if (dgvReceived.Rows[e.RowIndex].Cells[e.ColumnIndex].Value.ToString() == "DELETE")
            {
                //string Id = dgvReceived.Rows[e.RowIndex].Cells["id"].Value.ToString();
                // int result = _BsMgmt.DeleteGrnDetail(Id);
                DialogResult res = MessageBox.Show("All records associated with this GRN will be deleted.Are you sure you want to delete?", "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                if (res == DialogResult.Yes)
                {
                    int grn = int.Parse(dgvReceived.Rows[e.RowIndex].Cells["grn"].Value.ToString());
                    int result = _BsMgmt.DeleteGrnDetail(grn);
                    if (result > 0)
                    {
                        MessageBox.Show("Grn Detail Deleted Successfully", "Deleted", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        loadGridVIew();
                    }
                }

            }
            if (dgvReceived.Rows[e.RowIndex].Cells[e.ColumnIndex].Value.ToString() == "PRINT")
            {
                DataTable dt=_BsMgmt.GetGRNWiseReceivedDetail(int.Parse(dgvReceived.Rows[e.RowIndex].Cells["grn"].Value.ToString()));
                receivedVoucherReport frmcrystal = new receivedVoucherReport(dt);
                frmcrystal.Show();
            }
        }

       
       
    }
}
