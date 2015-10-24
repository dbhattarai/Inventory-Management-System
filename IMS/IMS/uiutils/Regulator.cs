using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Printing;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Windows.Forms;

namespace IMS.uiutils
{
    class Regulator
    {



        public static void StandardButtonHeight(Control MainControl)
        {
            foreach (Control c in MainControl.Controls)
            {
                StandardButton(c);
            }
        }
        private static void StandardButton(Control MyControl)
        {
            foreach (Control c in MyControl.Controls)
            {
                if (c is System.Windows.Forms.Button)
                {
                    c.AutoSize = false;
                    c.Size = new System.Drawing.Size(c.Size.Width, 23);
                    //c.Height = 20;
                }
                else if (c is System.Windows.Forms.Panel || c is System.Windows.Forms.GroupBox || c is System.Windows.Forms.UserControl || c is System.Windows.Forms.TableLayoutPanel || c is System.Windows.Forms.TabControl)
                {
                    StandardButton(c);
                }
            }
        }


        /////****
        public static void FormatControls(Control ctrl)
        {
            List<Control> dateControls = new List<Control>();
            foreach (Control c in ctrl.Controls)
            {
                if (c is System.Windows.Forms.TextBox)
                {
                    if (c.Tag != null)
                    {
                        if (c.Tag.Equals("status"))
                        {
                            TextBox tb = (TextBox)c;
                            tb.BackColor = Color.Black;
                            tb.ForeColor = Color.GreenYellow;
                        }
                    }
                    c.KeyDown += new KeyEventHandler(c_KeyDown);
                    c.Validating += new System.ComponentModel.CancelEventHandler(c_Validating);
                }
                else if (c is System.Windows.Forms.DataGridView)
                {
                    DataGridView dgv = (DataGridView)c;
                    dgv.AllowUserToResizeRows = false;
                    dgv.ReadOnly = true;
                    dgv.EnableHeadersVisualStyles = false;
                    dgv.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
                    dgv.AllowUserToAddRows = false;
                    dgv.AllowUserToDeleteRows = false;
                    dgv.AlternatingRowsDefaultCellStyle.BackColor = Color.AliceBlue;
                    // dgv.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None;
                    dgv.RowHeadersVisible = false;
                    dgv.ColumnHeadersDefaultCellStyle.BackColor = Color.Honeydew;
                    //dgv.AutoSizeRowsMode = DataGridViewAutoSizeRowsMode.AllCells;
                    dgv.DefaultCellStyle.WrapMode = DataGridViewTriState.True;
                    dgv.ColumnHeadersDefaultCellStyle.Padding= new Padding(2,4,2,4);
                    dgv.ColumnHeadersDefaultCellStyle.Font = new Font("Microsoft Sans Serif", 9, FontStyle.Bold);

                }
                else if (c is System.Windows.Forms.ComboBox)
                {
                    if (c.Name == "cmbCurrency") c.Enabled = false;
                }

            }

        }


       




        public static void RegularizePrint(PrintDocument printDocument)
        {
            printDocument.DefaultPageSettings.Landscape = true;
            printDocument.DefaultPageSettings.Margins = new System.Drawing.Printing.Margins(100, 50, 100, 50);
            //new System.Drawing.Printing.Margins(5, 5, 12, 60);

            printDocument.DefaultPageSettings.PaperSize = new System.Drawing.Printing.PaperSize("Letter", 840, 1180);

            //printDocument.DefaultPageSettings.PaperSize = new System.Drawing.Printing.PaperSize("PaperA4",840
        }
        //public static void LargePrint(PrintDocument printDocument)
        //{
        //    printDocument.DefaultPageSettings.Margins =
        //       new System.Drawing.Printing.Margins(5, 5, 12, 60);
        //    //printDocument.DefaultPageSettings.Landscape = true;
        //    //printDocument.DefaultPageSettings.PaperSize = new System.Drawing.Printing.PaperSize("PaperA3", 1840, 1880);
        //    //printDocument.DefaultPageSettings.PaperSize = new System.Drawing.Printing.PaperSize("PaperA4",840
        //}

        static void c_Validating(object sender, System.ComponentModel.CancelEventArgs e)
        {
            Validation.ApplyMaskLeave(sender, e);
        }

        static void c_KeyDown(object sender, KeyEventArgs e)
        {
            Validation.ApplyMask(sender, e);
        }

        public static string EncodePassword(string originalPassword)
        {
            //Declarations
            Byte[] originalBytes;
            Byte[] encodedBytes;
            MD5 md5;

            //Instantiate MD5CryptoServiceProvider, get bytes for original password and compute hash (encoded password)
            md5 = new MD5CryptoServiceProvider();
            originalBytes = ASCIIEncoding.Default.GetBytes(originalPassword);
            encodedBytes = md5.ComputeHash(originalBytes);

            //Convert encoded bytes back to a 'readable' string
            return BitConverter.ToString(encodedBytes);
        }

        public static string InsertComma(string tb)
        {
            string value = "";
            try
            {
                value = tb;
                value = string.Format("{0:C}", Convert.ToDouble(value));
                // int _select = value.IndexOf('.');
                // tb.SelectionStart = _select - 1;
                value = value.TrimStart('$');
                int i = 0;
                foreach (char c in value)
                {
                    i++;
                }
                value = value.Remove(i - 3, 3);
                tb = value;

            }
            catch { }
            return tb;
        }
    }
}
