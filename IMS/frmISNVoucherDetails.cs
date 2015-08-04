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
using IMS.Crystal.crystalForms;
namespace IMS
{
    public partial class frmISNVoucherDetails : Form
    {
        private readonly BsManagement _BsMgmt = new BsManagement();
        public frmISNVoucherDetails()
        {
            InitializeComponent();
            txtDateFrom.Text = (DateTime.Now).ToShortDateString();
            txtDateTo.Text = (DateTime.Now).ToShortDateString();
        }
        private void loadGridVIew()
        {
            dgvIssued.Rows.Clear();
            List<Issued> issue = new List<Issued>();
            DateTime sDate = DateTime.Parse((txtDateFrom.Text));
            DateTime eDate = DateTime.Parse((txtDateTo.Text));
            issue = _BsMgmt.GetISNVoucherDetails(sDate, eDate);
            foreach (var rec in issue)
            {
                dgvIssued.Rows.Add(rec.Id, rec.itemId, rec.DeptId, rec.unit, rec.receivedby,rec.issuedby, rec.remarks, rec.ISN, rec.Date.ToShortDateString(), rec.itemName, rec.departmentName, rec.quantity, rec.Rate, rec.amount);
            }
        }

        private void btnShow_Click(object sender, EventArgs e)
        {
            loadGridVIew();
        }

        private void dgvIssued_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            if (dgvIssued.Rows[e.RowIndex].Cells[e.ColumnIndex].Value.ToString() == "EDIT")
            {
                bool editmode = true;
                // dgvReceived.EditMode = DataGridViewEditMode.EditOnKeystrokeOrF2;
                List<Issued> iss = new List<Issued>();

                iss.Add(new Issued
                {
                    Date = Convert.ToDateTime(dgvIssued.Rows[e.RowIndex].Cells["date"].Value.ToString()),
                    amount = decimal.Parse(dgvIssued.Rows[e.RowIndex].Cells["amount"].Value.ToString()),
                    itemId = int.Parse(dgvIssued.Rows[e.RowIndex].Cells["itemId"].Value.ToString()),
                    DeptId = int.Parse(dgvIssued.Rows[e.RowIndex].Cells["deptId"].Value.ToString()),
                    quantity = decimal.Parse(dgvIssued.Rows[e.RowIndex].Cells["quantity"].Value.ToString()),
                    Rate = decimal.Parse(dgvIssued.Rows[e.RowIndex].Cells["rate"].Value.ToString()),
                    receivedby = string.IsNullOrEmpty(dgvIssued.Rows[e.RowIndex].Cells["receivedBy"].Value.ToString()) ? " " : Convert.ToString(dgvIssued.Rows[e.RowIndex].Cells["receivedBy"].Value.ToString()),
                    remarks = string.IsNullOrEmpty(dgvIssued.Rows[e.RowIndex].Cells["remarks"].Value.ToString()) ? " " : dgvIssued.Rows[e.RowIndex].Cells["remarks"].Value.ToString(),
                    itemName = (dgvIssued.Rows[e.RowIndex].Cells["item"].Value.ToString()),
                    departmentName = (dgvIssued.Rows[e.RowIndex].Cells["department"].Value.ToString()),
                    unit = (dgvIssued.Rows[e.RowIndex].Cells["unit"].Value.ToString()),
                    Id = dgvIssued.Rows[e.RowIndex].Cells["id"].Value.ToString(),
                    ISN = int.Parse(dgvIssued.Rows[e.RowIndex].Cells["isn"].Value.ToString()),
                    issuedby = string.IsNullOrEmpty(dgvIssued.Rows[e.RowIndex].Cells["issuedBy"].Value.ToString()) ? " " : Convert.ToString(dgvIssued.Rows[e.RowIndex].Cells["issuedBy"].Value.ToString())
                });

                frmIssued fr = new frmIssued(editmode, iss);
                fr.Show();
                fr.Activate();
                fr.BringToFront();
            }

            if (dgvIssued.Rows[e.RowIndex].Cells[e.ColumnIndex].Value.ToString() == "DELETE")
            {
                DialogResult res = MessageBox.Show("All records associated with this ISN will be deleted.Are you sure you want to delete?", "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                if (res == DialogResult.Yes)
                {
                    int isn = int.Parse(dgvIssued.Rows[e.RowIndex].Cells["isn"].Value.ToString());
                    int result = _BsMgmt.DeleteIsnDetail(isn);
                    if (result > 0)
                    {
                        MessageBox.Show("ISN Detail Deleted Successfully", "Deleted", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        dgvIssued.CurrentRow.Visible = false;
                       // loadGridVIew();
                    }
                }

            }
            if (dgvIssued.Rows[e.RowIndex].Cells[e.ColumnIndex].Value.ToString() == "PRINT")
            {
                DataTable dt = _BsMgmt.GetISNWiseIssuedDetail(int.Parse(dgvIssued.Rows[e.RowIndex].Cells["isn"].Value.ToString()));
                issuedVoucherReport frmcrystal = new issuedVoucherReport(dt);
                frmcrystal.Show();
            }
        }

        
    }
}
