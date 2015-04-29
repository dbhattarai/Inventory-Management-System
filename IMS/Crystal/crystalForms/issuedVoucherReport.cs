using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using IMS.Crystal.crystalRpts;

namespace IMS.Crystal.crystalForms
{
    public partial class issuedVoucherReport : Form
    {
        public issuedVoucherReport(DataTable dt)
        {
            InitializeComponent();
            IssuedVoucher cr = new IssuedVoucher();
            cr.SetDataSource(dt);
            crptViewer.ReportSource = cr;
        }
    }
}
