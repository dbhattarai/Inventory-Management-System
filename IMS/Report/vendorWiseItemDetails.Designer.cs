namespace IMS.Report
{
    partial class vendorWiseItemDetails
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.cmbVendor = new System.Windows.Forms.ComboBox();
            this.label3 = new System.Windows.Forms.Label();
            this.dgvDetail = new System.Windows.Forms.DataGridView();
            this.btnDetail = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.panel2 = new System.Windows.Forms.Panel();
            this.grpDetail = new System.Windows.Forms.GroupBox();
            this.print = new System.Windows.Forms.Button();
            this.btnPrint = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.printSummary = new System.Windows.Forms.Button();
            this.btnSummary = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.panel1 = new System.Windows.Forms.Panel();
            this.txtDateTo = new System.Windows.Forms.DateTimePicker();
            this.txtDateFrom = new System.Windows.Forms.DateTimePicker();
            ((System.ComponentModel.ISupportInitialize)(this.dgvDetail)).BeginInit();
            this.panel2.SuspendLayout();
            this.grpDetail.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.panel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // cmbVendor
            // 
            this.cmbVendor.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbVendor.FormattingEnabled = true;
            this.cmbVendor.Location = new System.Drawing.Point(213, 47);
            this.cmbVendor.Name = "cmbVendor";
            this.cmbVendor.Size = new System.Drawing.Size(83, 24);
            this.cmbVendor.TabIndex = 9;
            this.cmbVendor.SelectedIndexChanged += new System.EventHandler(this.cmbVendor_SelectedIndexChanged);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(210, 19);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(52, 16);
            this.label3.TabIndex = 8;
            this.label3.Text = "Vendor";
            // 
            // dgvDetail
            // 
            this.dgvDetail.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
            this.dgvDetail.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvDetail.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvDetail.Location = new System.Drawing.Point(3, 16);
            this.dgvDetail.Name = "dgvDetail";
            this.dgvDetail.RowHeadersVisible = false;
            this.dgvDetail.Size = new System.Drawing.Size(513, 479);
            this.dgvDetail.TabIndex = 0;
            // 
            // btnDetail
            // 
            this.btnDetail.Location = new System.Drawing.Point(326, 16);
            this.btnDetail.Name = "btnDetail";
            this.btnDetail.Size = new System.Drawing.Size(75, 23);
            this.btnDetail.TabIndex = 6;
            this.btnDetail.Text = "Detail";
            this.btnDetail.UseVisualStyleBackColor = true;
            this.btnDetail.Click += new System.EventHandler(this.btnDetail_Click);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(17, 53);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(60, 16);
            this.label2.TabIndex = 3;
            this.label2.Text = "Date To:";
            // 
            // panel2
            // 
            this.panel2.Controls.Add(this.grpDetail);
            this.panel2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel2.Location = new System.Drawing.Point(0, 76);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(519, 207);
            this.panel2.TabIndex = 1;
            // 
            // grpDetail
            // 
            this.grpDetail.Controls.Add(this.dgvDetail);
            this.grpDetail.Dock = System.Windows.Forms.DockStyle.Top;
            this.grpDetail.ForeColor = System.Drawing.SystemColors.WindowText;
            this.grpDetail.Location = new System.Drawing.Point(0, 0);
            this.grpDetail.Name = "grpDetail";
            this.grpDetail.Size = new System.Drawing.Size(519, 498);
            this.grpDetail.TabIndex = 0;
            this.grpDetail.TabStop = false;
            // 
            // print
            // 
            this.print.Location = new System.Drawing.Point(432, 15);
            this.print.Name = "print";
            this.print.Size = new System.Drawing.Size(75, 23);
            this.print.TabIndex = 11;
            this.print.Text = "Print";
            this.print.UseVisualStyleBackColor = true;
            this.print.Visible = false;
            this.print.Click += new System.EventHandler(this.print_Click);
            // 
            // btnPrint
            // 
            this.btnPrint.Location = new System.Drawing.Point(843, 62);
            this.btnPrint.Name = "btnPrint";
            this.btnPrint.Size = new System.Drawing.Size(75, 23);
            this.btnPrint.TabIndex = 10;
            this.btnPrint.Text = "Print";
            this.btnPrint.UseVisualStyleBackColor = true;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.txtDateTo);
            this.groupBox1.Controls.Add(this.txtDateFrom);
            this.groupBox1.Controls.Add(this.printSummary);
            this.groupBox1.Controls.Add(this.btnSummary);
            this.groupBox1.Controls.Add(this.print);
            this.groupBox1.Controls.Add(this.btnPrint);
            this.groupBox1.Controls.Add(this.cmbVendor);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.btnDetail);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Dock = System.Windows.Forms.DockStyle.Top;
            this.groupBox1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBox1.Location = new System.Drawing.Point(0, 0);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(519, 76);
            this.groupBox1.TabIndex = 0;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Report";
            // 
            // printSummary
            // 
            this.printSummary.Location = new System.Drawing.Point(432, 45);
            this.printSummary.Name = "printSummary";
            this.printSummary.Size = new System.Drawing.Size(75, 23);
            this.printSummary.TabIndex = 13;
            this.printSummary.Text = "Print";
            this.printSummary.UseVisualStyleBackColor = true;
            this.printSummary.Visible = false;
            this.printSummary.Click += new System.EventHandler(this.printSummary_Click);
            // 
            // btnSummary
            // 
            this.btnSummary.Location = new System.Drawing.Point(326, 45);
            this.btnSummary.Name = "btnSummary";
            this.btnSummary.Size = new System.Drawing.Size(75, 23);
            this.btnSummary.TabIndex = 12;
            this.btnSummary.Text = "Summary";
            this.btnSummary.UseVisualStyleBackColor = true;
            this.btnSummary.Click += new System.EventHandler(this.btnSummary_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(17, 22);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(74, 16);
            this.label1.TabIndex = 2;
            this.label1.Text = "Date From:";
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.panel2);
            this.panel1.Controls.Add(this.groupBox1);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(519, 283);
            this.panel1.TabIndex = 6;
            // 
            // txtDateTo
            // 
            this.txtDateTo.Location = new System.Drawing.Point(89, 48);
            this.txtDateTo.Name = "txtDateTo";
            this.txtDateTo.Size = new System.Drawing.Size(115, 22);
            this.txtDateTo.TabIndex = 125;
            this.txtDateTo.Value = new System.DateTime(2015, 4, 29, 0, 0, 0, 0);
            // 
            // txtDateFrom
            // 
            this.txtDateFrom.Location = new System.Drawing.Point(89, 20);
            this.txtDateFrom.Name = "txtDateFrom";
            this.txtDateFrom.Size = new System.Drawing.Size(115, 22);
            this.txtDateFrom.TabIndex = 124;
            this.txtDateFrom.Value = new System.DateTime(2015, 4, 29, 0, 0, 0, 0);
            // 
            // vendorWiseItemDetails
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(519, 283);
            this.Controls.Add(this.panel1);
            this.Name = "vendorWiseItemDetails";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Vendor Wise Item Details";
            this.Load += new System.EventHandler(this.vendorWiseItemDetails_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dgvDetail)).EndInit();
            this.panel2.ResumeLayout(false);
            this.grpDetail.ResumeLayout(false);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.panel1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ComboBox cmbVendor;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.DataGridView dgvDetail;
        private System.Windows.Forms.Button btnDetail;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.GroupBox grpDetail;
        private System.Windows.Forms.Button print;
        private System.Windows.Forms.Button btnPrint;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Button btnSummary;
        private System.Windows.Forms.Button printSummary;
        private System.Windows.Forms.DateTimePicker txtDateTo;
        private System.Windows.Forms.DateTimePicker txtDateFrom;
    }
}