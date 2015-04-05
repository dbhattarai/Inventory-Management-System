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
    public partial class frmItemSetting : Form
    {
        private readonly BsSetting _BsSetting=new BsSetting();
        public frmItemSetting()
        {
            InitializeComponent();
        }

        private void btnSet_Click(object sender, EventArgs e)
        {
            Item item = new Item();
            item.ItemName = txtItemName.Text;
            item.unit = txtUnit.Text;
            item.company =txtCname.Text;
            item.description = txtDescription.Text;
            int result = _BsSetting.SaveItem(item);
            if (result > 0)
            {
                MessageBox.Show("Item Saved Successfully ", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                clear();
            }
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
