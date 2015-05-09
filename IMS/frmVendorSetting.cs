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
using IMS.uiutils;
using System.Text.RegularExpressions;

namespace IMS
{
    public partial class frmVendorSetting : Form
    {
        private readonly BsSetting _BsSetting = new BsSetting();
        public frmVendorSetting()
        {
            InitializeComponent();
        }
        private bool ValidInputs()
        {
            return FormUtil.EnsureNotEmpty(new TextBox[] { txtAddress, txtPhNo, txtVendorName });
                   }

        private void btnVendorSet_Click(object sender, EventArgs e)
        {
            if (ValidInputs())
            {
                Vendor ven = new Vendor();
                ven.VendorName = txtVendorName.Text;
                ven.Address = txtAddress.Text;
                ven.phnNo = txtPhNo.Text;
               
                int result = _BsSetting.SaveVendor(ven);
                if (result > 0)
                {
                    MessageBox.Show("Vendor Saved Successfully ", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    clear();
                }
            }
            else
                MessageBox.Show("Please enter all required fields", "Required", MessageBoxButtons.OK, MessageBoxIcon.Question);

        }

        private void clear()
        {
            txtVendorName.Clear();
            txtAddress.Clear();
            txtPhNo.Clear();
           
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            clear();
        }

        private void txtPhNo_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar) && e.KeyChar != '.')
            {
                e.Handled = true;
            }
            if (e.KeyChar == '.' && (sender as System.Windows.Forms.TextBox).Text.IndexOf('.') > -1)
            {
                e.Handled = true;
            }
        }
        public bool phone(string no)
        {
            
            Regex expr = new Regex(@"^((\+){0,9}{0,9}{0,9}(\s){0,1}(\-){0,1}(\s){0,1}){0,1}9[0-9](\s){0,1}(\-){0,1}(\s){0,1}[1-9]{1}[0-9]{7}$");
            if (expr.IsMatch(no))
            {
                return true;
            }
            else return false;
        }
        private void txtPhNo_Leave(object sender, EventArgs e)
        {
            Regex re = new Regex("^[0-9][0-9][0-9]");

            if (re.IsMatch(txtPhNo.Text.Trim()) == false || txtPhNo.Text.Length > 10)
            {
                MessageBox.Show("Please enter Valid Phone Number", "Required", MessageBoxButtons.OK, MessageBoxIcon.Question);
                txtPhNo.Clear();
                txtPhNo.Focus();
            }
           
        }

       
    }
}
