using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Data.SqlClient;
using IMSModel;
using IMSCommonHelper;
using IMSDataRepository;

namespace IMS
{
    public partial class frmLogin : Form
    {

        DsUser ul = new DsUser();
       // Encrypt enc = new Encrypt();
        User user = new User();
        public frmLogin()
        {
            InitializeComponent();
        }

        private void btnLogin_Click(object sender, EventArgs e)
        {
            if (txtUname.Text == string.Empty || txtPwd.Text == string.Empty)
            {
                MessageBox.Show(@"Please provide User Name and Password", @"User Login", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
            }
            else
            {
                user.username = txtUname.Text;
                //  user.password = enc.PasswordEncrypt(txtPwd.Text);
                // bool result = ul.userLogin(user);
                user.password = (txtPwd.Text);
                DataTable dt = ul.userLogin(user);

                if (dt.Rows.Count <= 0)
                {
                    MessageBox.Show("Invalid User Name or Password", "User Login", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    txtUname.Clear();
                    txtPwd.Clear();
                    txtUname.Focus();
                }
                else
                {
                    foreach (DataRow dr in dt.Rows)
                    {
                        Global.UserName = dr["Username"].ToString();
                        Global.Password = (dr["Password"].ToString());
                        Global.fullName = (dr["FullName"].ToString());
                        Global.Utype = (dr["UserType"].ToString());
                        Global.deptId = Convert.ToInt16(dr["DeptId"]);
                    }

                    this.Hide();
                    DashBoard db = new DashBoard();
                    db.Show();
                }
            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void txtPwd_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                btnLogin_Click(sender, e);
            }
        }
    }
}
