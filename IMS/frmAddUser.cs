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
    public partial class frmAddUser : Form
    {
        private readonly BsUser _BsUser = new BsUser();
        private string userId =Convert.ToString(Guid.NewGuid().ToString());
        public frmAddUser()
        {
            InitializeComponent();
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            User user = new User();
            user.fullname = txtName.Text;
            user.username = txtUname.Text;
            user.password = txtPWD.Text;
            user.Usertype = cmbUtype.SelectedIndex.ToString();
           // user.DeptId = 1;
            user.DeptId = int.Parse(cmbDept.SelectedIndex.ToString()+1);
            user.userId = userId;
            int result = _BsUser.SaveUser(user);
            if (result > 0)
            {
                MessageBox.Show("User Saved Successfully ", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                Clear();
            }
        }

        private void frmAddUser_Load(object sender, EventArgs e)
        {
            var dept =_BsUser.GetDepartment();
            cmbDept.DataSource=dept;
            cmbDept.DisplayMember = "DepartmentName";
            cmbDept.ValueMember = "DeptId";
            cmbDept.SelectedIndex = -1;

        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            Clear();
        }
        private void Clear()
        {
            txtECode.Clear();
            txtName.Clear();
            txtPWD.Clear();
            txtUname.Clear();
            cmbDept.SelectedIndex = -1;
            cmbUtype.SelectedIndex = -1;
        }
    }
}
