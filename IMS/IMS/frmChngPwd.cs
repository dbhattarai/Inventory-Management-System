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
    public partial class frmChngPwd : Form
    {
        private readonly BsUser _Bsuser = new BsUser();
        private string userId = Convert.ToString(Guid.NewGuid().ToString());
        User user = new User();
        public frmChngPwd()
        {
            InitializeComponent();
        }

        private void btnSavePwd_Click(object sender, EventArgs e)
        {
            if (txtUName.Text == Global.UserName && txtOldPwd.Text == Global.Password)
            {
                user.username = txtUName.Text;
                user.password = txtNewPwd.Text;
                user.userId = Global.UserId;//userId;
                user.fullname = Global.fullName;
                user.Usertype = Global.Utype;
                user.DeptId = Global.deptId;
                int result = _Bsuser.SaveUser(user);
                if (result > 0)
                {
                    MessageBox.Show("Password Changed", "IMS");
                    Clear();
                }
            }
            else
            {
                MessageBox.Show("Please enter valid user name or password", "IMS");
                Clear();
            }
              
        }
        private void Clear()
        {
            txtUName.Clear();
            txtOldPwd.Clear();
            txtNewPwd.Clear();
            txtOldPwd.Focus();
        }
    }
}
