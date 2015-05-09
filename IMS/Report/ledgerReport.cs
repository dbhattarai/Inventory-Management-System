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
namespace IMS.Report
{
    public partial class ledgerReport : Form
    {
        DataTable dt;
        DateTime sDate;
        DateTime eDate;
        private readonly BSReport _report = new BSReport();
        public ledgerReport()
        {
            InitializeComponent();
        }
        private void ledgerReport_Load(object sender, EventArgs e)
        {
            txtDateFrom.Text = DateTime.Today.ToString("yyyy/MM/dd");
            txtDateTo.Text = DateTime.Today.ToString("yyyy/MM/dd");
        }
        private void btnShow_Click(object sender, EventArgs e)
        {
          
            DateTime sDate = DateTime.Parse((txtDateFrom.Text));
            DateTime eDate = DateTime.Parse((txtDateTo.Text));
            dt = _report.ledgerReport(sDate, eDate);
            dgvReceived.DataSource = dt;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            DataSet ds = new DataSet();
            ds.Tables.Add(dt);
            ds.WriteXml("LedgerReport.xml");
            frmLedgerReportRpt frmcrystal = new frmLedgerReportRpt(dt, sDate, eDate);
            frmcrystal.Show();
        }

       


    }
}

