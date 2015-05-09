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
    public partial class frmItemSetting : Form
    {
        private readonly BsSetting _BsSetting=new BsSetting();
        public frmItemSetting()
        {
            InitializeComponent();
        }
        private bool ValidInputs()
        {
            return FormUtil.EnsureNotEmpty(new TextBox[] { txtCname, txtItemName, txtUnit});
        }
        private void btnSet_Click(object sender, EventArgs e)
        {
            if (ValidInputs())
            {
                Item item = new Item();
                item.ItemName = txtItemName.Text;
                item.unit = txtUnit.Text;
                item.company = txtCname.Text;
                item.description = txtDescription.Text;
                int result = _BsSetting.SaveItem(item);
                if (result > 0)
                {
                    MessageBox.Show("Item Saved Successfully ", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    clear();
                }
            }
            else
                MessageBox.Show("Please enter all required fields", "Required", MessageBoxButtons.OK, MessageBoxIcon.Question);

        }

        private void clear()
        {
            txtCname.Clear();
            txtDescription.Clear();
            txtItemName.Clear();
            txtUnit.Clear();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            clear();
        }

        private void btnSearch_Click(object sender, EventArgs e)
        {
            itemSearch sm =new itemSearch();
            sm.ShowDialog();
            //PopulateItembyId( "btnSearch");
        }
    }
}
