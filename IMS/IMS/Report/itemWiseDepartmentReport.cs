﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using IMSBusinessService;
using IMS.Crystal.crystalForms;

namespace IMS.Report
{
    public partial class itemWiseDepartmentReport : Form
    {
        public itemWiseDepartmentReport()
        {
            InitializeComponent();
        }
        private readonly BSReport _report = new BSReport();
        private readonly BsManagement _BsMgmt = new BsManagement();
        private string type = "";
        private string item = "";
        DataTable dt;
        DateTime sDate;
        DateTime eDate;
        private void LoadComboBox()
        {
            cmbItem.SelectedIndexChanged -= cmbItem_SelectedIndexChanged;
            var dept = _BsMgmt.GetReceivedItem();
            cmbItem.DataSource = dept;
            cmbItem.DisplayMember = "ItemName";
            cmbItem.ValueMember = "ItemId";
            cmbItem.SelectedIndex = -1;
            cmbItem.SelectedIndexChanged += cmbItem_SelectedIndexChanged;

        }

        private void itemWiseDepartmentReport_Load(object sender, EventArgs e)
        {
            LoadComboBox();
            txtDateFrom.Text = DateTime.Today.ToString("yyyy/MM/dd");
            txtDateTo.Text = DateTime.Today.ToString("yyyy/MM/dd");
        }

        private void cmbItem_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void btnDetail_Click(object sender, EventArgs e)
        {
            if (cmbItem.SelectedIndex >-1)
            {
                

                print.Visible = true;
                printSummary.Visible = false;
                type = "detail";
                int itemId = int.Parse(cmbItem.SelectedValue.ToString());
                item = cmbItem.Text;
                sDate = DateTime.Parse((txtDateFrom.Text));
                eDate = DateTime.Parse((txtDateTo.Text));
                dt = _report.GetItemWiseDepartmentReport(sDate, eDate, itemId, type);
                dgvDetail.DataSource = dt;

                //to display input parameter details
                grpDepartmentDetail.Visible = true;
                lblDateFrom.Text = sDate.ToShortDateString();
                lblDateTo.Text = eDate.ToShortDateString();
                lblItem.Text = item;
                //
            }
            else
                MessageBox.Show("Please Select Item", "Required", MessageBoxButtons.OK, MessageBoxIcon.Question);

        }

        private void btnSummary_Click(object sender, EventArgs e)
        {
             if (cmbItem.SelectedIndex >-1)
            {

            print.Visible = false;
            printSummary.Visible = true;
            type = "summary";
            int itemId = int.Parse(cmbItem.SelectedValue.ToString());
            item = cmbItem.Text;
             sDate = DateTime.Parse((txtDateFrom.Text));
             eDate = DateTime.Parse((txtDateTo.Text));
            dt = _report.GetItemWiseDepartmentReport(sDate, eDate, itemId, type);
            dgvDetail.DataSource = dt;

            //to display input parameter details
            grpDepartmentDetail.Visible = true;
            lblDateFrom.Text = sDate.ToShortDateString();
            lblDateTo.Text = eDate.ToShortDateString();
            lblItem.Text = item;
            }
             else
                 MessageBox.Show("Please Select Item", "Required", MessageBoxButtons.OK, MessageBoxIcon.Question);

        }

        private void print_Click(object sender, EventArgs e)
        {
            //DataSet ds = new DataSet();
            //ds.Tables.Add(dt);
            //ds.WriteXml("ItemWiseDepartment.xml");
            frmItemWiseDepartmentRpt frmcrystal = new frmItemWiseDepartmentRpt(dt, sDate, eDate,item);
            frmcrystal.Show();
        }

        private void printSummary_Click(object sender, EventArgs e)
        {
            //DataSet ds = new DataSet();
            //ds.Tables.Add(dt);
            //ds.WriteXml("ItemWiseDepartmentSummary.xml");
            frmItemWiseDeptRptSummary frmcrystal = new frmItemWiseDeptRptSummary(dt, sDate, eDate,item);
            frmcrystal.Show();
        }

    }
}

