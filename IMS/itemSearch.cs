using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using IMSBusinessService;
namespace IMS
{
    public partial class itemSearch : Form
    {
        private readonly BsSetting _setting = new BsSetting();
        DataTable dt;
        public itemSearch()
        {
            InitializeComponent();
        }

        private void itemSearch_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyData == System.Windows.Forms.Keys.Enter)
            {
                SendKeys.Send("{TAB}");
            }
        }

        private void textBox2_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)13)
            {
                dt = _setting.SearchItem(txtSearchName.Text);
                dgvItem.DataSource = dt;
                txtSearchName.Text = string.Empty;
            }
        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {
            dt = _setting.SearchItem(txtSearchName.Text);
            dgvItem.DataSource = dt;
            txtSearchName.Text = string.Empty;
        }

    }
}
