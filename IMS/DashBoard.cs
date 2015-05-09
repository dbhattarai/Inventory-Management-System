using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using IMS.Report;

namespace IMS
{
    public partial class DashBoard : Form
    {
        public DashBoard()
        {
            InitializeComponent();
        }
        private void addEditEmployToolStripMenuItem_Click(object sender, EventArgs e)
        {
            frmAddUser fau = new frmAddUser();
            fau.MdiParent = this;
            fau.Show();
            fau.Activate();
            fau.BringToFront();
        }

        private void itemToolStripMenuItem1_Click_1(object sender, EventArgs e)
        {
            frmItemSetting fis = new frmItemSetting();
            fis.MdiParent = this;
            fis.Show();
            fis.Activate();
            fis.BringToFront();
        }

        private void departmentToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            frmDeptSetting fds = new frmDeptSetting();
            fds.MdiParent = this;
            fds.Show();
            fds.Activate();
            fds.BringToFront();
        }

        private void vendorToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            frmVendorSetting fvs = new frmVendorSetting();
            fvs.MdiParent = this;
            fvs.Show();
            fvs.Activate();
            fvs.BringToFront();
            
        }

        private void changePasswordToolStripMenuItem_Click(object sender, EventArgs e)
        {
            frmChngPwd fcp = new frmChngPwd();
            fcp.MdiParent = this;
            fcp.Show();
            fcp.Activate();
            fcp.BringToFront();
        }

        private void receivedToolStripMenuItem_Click(object sender, EventArgs e)
        {
            frmReceived fr = new frmReceived();
            fr.MdiParent = this;
            fr.Show();
            fr.Activate();
            fr.BringToFront();
        }

        private void issuedToolStripMenuItem_Click(object sender, EventArgs e)
        {
            frmIssued fi = new frmIssued();
            fi.MdiParent = this;
            fi.Show();
            fi.Activate();
            fi.BringToFront();
        }

        private void DashBoard_Load(object sender, EventArgs e)
        {
            this.BackColor = Color.Maroon;
        }

        private void itemWiseDepartmentDetailsToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            itemWiseDepartmentReport fi = new itemWiseDepartmentReport();
            fi.MdiParent = this;
            fi.Show();
            fi.Activate();
            fi.BringToFront();
        }

        private void vendorWiseItemDetailsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            vendorWiseItemDetails fi = new vendorWiseItemDetails();
            fi.MdiParent = this;
            fi.Show();
            fi.Activate();
            fi.BringToFront();
           
        }

        private void itemWiseVendorDetailsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            itemWiseVendorDetails fi = new itemWiseVendorDetails();
            fi.MdiParent = this;
            fi.Show();
            fi.Activate();
            fi.BringToFront();
        }

        private void departmentWiseItemDetailsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            departmentWiseItemReport fi = new departmentWiseItemReport();
            fi.MdiParent = this;
            fi.Show();
            fi.Activate();
            fi.BringToFront();
        }

        private void ledgerReportToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ledgerReport fi = new ledgerReport();
            fi.MdiParent = this;
            fi.Show();
            fi.Activate();
            fi.BringToFront();
        }

        private void logOffToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            this.Dispose();
            frmLogin mw = new frmLogin();
            mw.Show();
            mw.Activate();
            mw.BringToFront();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void databaseBackupToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DatabaseBackup db = new DatabaseBackup();
            db.MdiParent = this;
            db.Show();
            db.Activate();
            db.BringToFront();
        }

        private void btnReceive_Click(object sender, EventArgs e)
        {
            frmReceived fr = new frmReceived();
            fr.MdiParent = this;
            fr.Show();
            fr.Activate();
            fr.BringToFront();
        }

        private void btnIssue_Click(object sender, EventArgs e)
        {
            frmIssued fi = new frmIssued();
            fi.MdiParent = this;
            fi.Show();
            fi.Activate();
            fi.BringToFront();
        }

        private void btnreceived_Click(object sender, EventArgs e)
        {
            frmReceived fr = new frmReceived();
            fr.MdiParent = this;
            fr.Show();
            fr.Activate();
            fr.BringToFront();
        }

        private void btnIssued_Click(object sender, EventArgs e)
        {
            frmIssued fi = new frmIssued();
            fi.MdiParent = this;
            fi.Show();
            fi.Activate();
            fi.BringToFront();
        }

        private void individualLedgerReportToolStripMenuItem_Click(object sender, EventArgs e)
        {
            frmItemwiseStockReport fi = new frmItemwiseStockReport();
            fi.MdiParent = this;
            fi.Show();
            fi.Activate();
        }

        private void btnBackup_Click(object sender, EventArgs e)
        {
            DatabaseBackup db = new DatabaseBackup();
            db.MdiParent = this;
            db.Show();
            db.Activate();
            db.BringToFront();
        }

    }
}
