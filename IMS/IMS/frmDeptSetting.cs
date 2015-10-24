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

namespace IMS
{
    public partial class frmDeptSetting : Form
    {
        private readonly BsSetting _BsSetting = new BsSetting();
        public frmDeptSetting()
        {
            InitializeComponent();
        }
        private bool ValidInputs()
        {
            return FormUtil.EnsureNotEmpty(new TextBox[] { txtDeptCode, txtDeptName, txtHod });
        }
        private void btnDeptSet_Click(object sender, EventArgs e)
        {
            if (ValidInputs())
            {
                Department dept = new Department();
                dept.DepartmentName = txtDeptName.Text;
                dept.DeptCode = txtDeptCode.Text;
                dept.HOD = txtHod.Text;
                int result = _BsSetting.SaveDepartment(dept);
                if (result > 0)
                {
                    MessageBox.Show("Department Saved Successfully ", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    clear();
                }
            }
            else
                MessageBox.Show("Please enter all required fields", "Required", MessageBoxButtons.OK, MessageBoxIcon.Question);


        }
        private void clear()
        {
            txtDeptName.Clear();
            txtDeptCode.Clear();
            txtHod.Clear();
        }
        private void btnCancel_Click(object sender, EventArgs e)
        {
            clear();
        }     
     
    }
}
