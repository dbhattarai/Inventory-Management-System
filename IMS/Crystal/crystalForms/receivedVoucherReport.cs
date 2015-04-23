using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using IMS.Crystal.crystalRpts;

namespace IMS.Report
{
    public partial class receivedVoucherReport : Form
    {
        public receivedVoucherReport(DataTable dt,int gnr,DateTime date,string vendor,string receivedBy)
        {
            InitializeComponent();
            ReceivedVoucher cr = new ReceivedVoucher();
            cr.SetDataSource(dt);
            crptViewer.ReportSource = cr;
        }
    }
}
