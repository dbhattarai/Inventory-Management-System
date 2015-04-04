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
    public partial class frmVendorSetting : Form
    {
        private readonly BsSetting _BsSetting = new BsSetting();
        public frmVendorSetting()
        {
            InitializeComponent();
        }

        private void btnVendorSet_Click(object sender, EventArgs e)
        {
            Vendor ven = new Vendor();
            ven.VendorName = txtVendorName.Text;
            ven.Address = txtAddress.Text;
            ven.phnNo = txtPhNo.Text;
            int result = _BsSetting.SaveVendor(ven);
            if (result > 0)
            {
                MessageBox.Show("Vendor Saved Successfully ", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
