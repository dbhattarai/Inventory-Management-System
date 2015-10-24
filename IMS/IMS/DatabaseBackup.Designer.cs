namespace IMS
{
    partial class DatabaseBackup
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
            this.saveDb = new System.Windows.Forms.SaveFileDialog();
            this.SuspendLayout();
            // 
            // saveDb
            // 
            this.saveDb.FileOk += new System.ComponentModel.CancelEventHandler(this.saveDb_FileOk);
            // 
            // DatabaseBackup
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(204, 124);
            this.Name = "DatabaseBackup";
            this.Text = "DatabaseBackup";
            this.Load += new System.EventHandler(this.DatabaseBackup_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SaveFileDialog saveDb;
    }
}