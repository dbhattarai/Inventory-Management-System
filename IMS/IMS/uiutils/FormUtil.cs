using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Windows.Forms;

namespace IMS.uiutils
{
    class FormUtil
    {
        public static DataTable columnswidth = new DataTable();
        public static void ClearTexts(TextBox[] tbs)
        {
            foreach (TextBox tb in tbs)
            {
                tb.Text = string.Empty;
            }
        }

        public static bool EnsureNotEmpty(TextBox[] tbs)
        {
            foreach (TextBox tb in tbs)
            {
                if (tb.Text.Trim() == string.Empty || tb.Text=="")
                {
                   tb.BackColor = System.Drawing.Color.Lavender;
                    return false;
                }
            }
            return true;
        }

        public static bool MEnsureNotEmpty(MaskedTextBox[] tbs)
        {
            foreach (MaskedTextBox tb in tbs)
            {
                if (!tb.MaskCompleted)
                {
                    tb.Focus();
                    return false;
                }
            }
            return true;
        }

        public static void EmptyFormControls(Control ctrl)
        {
            foreach (Control c in ctrl.Controls)
            {
                if (c is System.Windows.Forms.TextBox)
                {
                    c.Text = string.Empty;
                }
                else if (c is System.Windows.Forms.ComboBox)
                {
                    ComboBox cc = new ComboBox();
                    //cc = (ComboBox) c;
                    //cc.SelectedItem = -1;
                    //c.Text = "";
                   // Type controlType = c.GetType();
                   // PropertyInfo[] properties = controlType.GetProperties();
                    //  typeof(ComboBox).GetProperty("SelectedItem").SetValue(c.Name, "", null);
                    try
                    {
                        typeof (ComboBox).GetProperty("SelectedIndex").SetValue((ComboBox) c, 0, null);
                        //(a)TRIED setting to -1 bt shows error on some forms
                        //(b)even setting it to 0 gives error son some textbox
                        //  a- is on the form , b- on textbox need to handle it later
                        //rajiv shrestha 5-23-2014
                    }
                    catch
                    {
                        // need to handle this too
                    }
                
                    
                   

                }
                else if (c is System.Windows.Forms.Panel || c is System.Windows.Forms.GroupBox || c is System.Windows.Forms.UserControl || c is System.Windows.Forms.TableLayoutPanel || c is System.Windows.Forms.TabControl)
                {
                    EmptyFormControls(c);
                }
            }


        }








    }
}
