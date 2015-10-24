using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;

namespace IMS.uiutils
{
   public static class Validation
    {
        /*!Function: This Method Checks Whether The Text Is Empty Or Not*/
        public static bool IsEmpty(string stringText)
        {
            if (stringText.Trim() == "")
                return true;
            else
                return false;
        }

        /*!Function: This Method Converts Text Into Title Case*/
        public static string ToTitleCase(string stringText)
        {
            string returnVal = "";

            if (stringText.Trim() == "")
                returnVal = stringText;
            else
            {
                Regex reg = new Regex(" ");
                string[] stringList = reg.Split(stringText);

                for (int indx = 0; indx < stringList.Length; indx++)
                {
                    if (stringList[indx].Trim() != "")
                    {
                        if (stringList[indx].Trim().Length == 1)
                            stringList[indx] = stringList[indx].ToUpper().ToString();
                        else
                            stringList[indx] = stringList[indx].Substring(0, 1).ToUpper().ToString()
                       + stringList[indx].Substring(1).ToLower().ToString();
                    }
                }
                returnVal = String.Join(" ", stringList);
            }
            return returnVal;
        }

        /*!Function:Valiadting Email Address*/
        public static bool emailValidation(string txtEmailChecking)
        {
            //string pattern=@"^[a-z][a-z|0-9|]*([_][a-z|0-9]+)*([.][a-z|0-9]+([_][a-z|0-9]+)*)?@[a-z][a-z|0-9|]*\.([a-z][a-z|0-9]*(\.[a-z][a-z|0-9]*)?)$";
            string pattern = @"^[a-z][a-z|0-9|]*([_][a-z|0-9]+)*([.][a-z|0-9]+([_][a-z|0-9]+)*)?@[a-z|0-9]*\.([a-z][a-z]*(\.[a-z][a-z]*)?)$";
            System.Text.RegularExpressions.Match match = Regex.Match(txtEmailChecking.Trim(), pattern, RegexOptions.IgnoreCase);
            if (match.Success)
                return true;
            else
                return false;
        }

        /*!Function:Test whether the string is valid number or not*/
        public static bool numberValidation(String strNumber)
        {
            Regex objNotNumberPattern = new Regex("[^0-9.-]");
            Regex objTwoDotPattern = new Regex("[0-9]*[.][0-9]*[.][0-9]*");
            Regex objTwoMinusPattern = new Regex("[0-9]*[-][0-9]*[-][0-9]*");
            String strValidRealPattern = "^([-]|[.]|[-.]|[0-9])[0-9]*[.]*[0-9]+$";
            String strValidIntegerPattern = "^([-]|[0-9])[0-9]*$";
            Regex objNumberPattern = new Regex("(" + strValidRealPattern + ")|(" + strValidIntegerPattern + ")");
            return !objNotNumberPattern.IsMatch(strNumber) &&
                   !objTwoDotPattern.IsMatch(strNumber) &&
                   !objTwoMinusPattern.IsMatch(strNumber) &&
                   objNumberPattern.IsMatch(strNumber);
        }

        /*!Static Function: Returns the boolean result after comparing*/
        public static bool StringCompare(string stringA, string stringB)
        {
            return (string.Compare(stringA, stringB, true,
                 System.Globalization.CultureInfo.CurrentCulture) == 0);
        }

        /*!Static Function:Check ' character in a string and if find replace by ''   */
        public static string CheckQuotes(string str)
        {
            System.Text.StringBuilder buf = new System.Text.StringBuilder(str);
            int startindex = 0;
            for (int i = 0; i < buf.Length; i++)
            {
                int index = buf.ToString().IndexOf("'", startindex);
                if (index != -1)
                {
                    buf.Replace("'", "''", index, 1);
                    startindex = index + 2;
                    i = startindex - 1;
                }
            }
            return buf.ToString();
        }



        /*!Static Function:Revest the check Quotes*/
        public static string UnCheckQuotes(string str)
        {
            System.Text.StringBuilder buf = new System.Text.StringBuilder(str);
            int startindex = 0;
            for (int i = 0; i < buf.Length; i++)
            {
                int index = buf.ToString().IndexOf("'", startindex);
                if (index != -1)
                {
                    buf.Replace("''", "'", index, 2);
                    startindex = index + 1;
                    i = startindex;
                }
            }
            return buf.ToString();
        }

        /*!Function: It checks the validation for tag tree structure*/
        private static bool ValidateTagStructure(string lineStr)
        {
            string[] tokens = lineStr.Split(',');
            if (tokens.Length == 6 && tokens[0].IndexOf('+') == -1 || tokens[0].IndexOf('+') == 0)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        /*!Function: It checks the for the restricted symbols*/
        public static bool ValidateRestrictedSymbols(string lineStr)//sep3
        {
            try
            {
                bool result = false;
                MatchCollection m = Regex.Matches(lineStr, "[@.,!]");
                if (m.Count > 0)
                    result = true;
                return result;
            }
            catch (Exception)
            {
                return true;
            }
        }


        /*!Function: Allow Data in Alpha Numeric Format for filepath*/

        public static void AllowOnlyAlphaNumericForUrl(object sender, KeyEventArgs e)
        {

            if (e.KeyValue != 35 && e.KeyValue != 36 && e.KeyValue != 37 && e.KeyValue != 39 && e.KeyValue != 38 && e.KeyValue != 40 && e.KeyValue != 46 && e.KeyValue != 8) //Not Up/Down/Right/Left Arrow, Backspace or Delete
            {

                if (e.KeyValue < 65 || e.KeyValue > 90) //Not between A-Z
                {



                    if (e.Shift) //If ShiftKey is pressed then suppress it
                    {

                        if (e.KeyValue == 189 || e.KeyValue == 186) //Leave hyphen or underscore
                        {

                            e.SuppressKeyPress = false;

                            return;

                        }

                    }



                    if ((e.KeyValue < 48 || e.KeyValue > 57))  //0-9 

                        if (e.KeyValue < 96 || e.KeyValue > 105) //0-9 from numeric key pad

                            if (e.KeyValue != 189) //Leave hyphen or underscore

                                e.SuppressKeyPress = true; //Other keys are not allowed



                    if (!e.Shift && e.KeyValue == 189) //For Hyphen
                    {

                        e.SuppressKeyPress = true;

                    }



                    if (e.KeyValue == 220 || e.KeyValue == 186 || e.KeyValue == 191 || e.KeyValue == 32 || e.KeyValue == 190)  //(:),(\),(/),(space),(.)

                        e.SuppressKeyPress = false; //Other keys are not allowed
                }

            }

        }

        /*!Function: This Method Checks Whether the String is Valid Alpha Numeric*/
        public static bool IsAlphaNumeric(string strText, bool allowSpecialCharacters, string[] allowedCharacters)
        {
            bool returnVal = true;
            //string deniedSymbols = "~`!:;@#$%^&*()-+=[{}]\\|/?<>,.'\"";
            string deniedSymbols = "~`!:;@#$%^&*()-+=[{}]\\|/?<>.'\""; // comma is allowed for each of use
            if (allowSpecialCharacters)
            {
                for (int indx = 0; indx < allowedCharacters.Length; indx++)
                {
                    deniedSymbols = Regex.Replace(deniedSymbols, "[" + allowedCharacters[indx] + "]", "");
                }
            }
            for (int xindx = 0; xindx < strText.Length; xindx++) //Check Every Character
            {
                for (int yindx = 0; yindx < deniedSymbols.Length; yindx++)
                {
                    if (strText.IndexOf(deniedSymbols[yindx]) >= 0) //If Found
                    {
                        returnVal = false;
                        break;
                    }
                }
                if (!returnVal) break;
            }
            return returnVal;
        }

        /*!Function: This Methed Checks Numbers and Decimals*/
        public static bool IsNumeric(string strText, bool allowDecimalPoint)
        {
            bool returnVal = true;
            if (strText == string.Empty)
            {
                return true;
            }
            if (allowDecimalPoint)
            {
                double result;
                if (double.TryParse(strText, out result))
                {
                    returnVal = true;
                }
                else
                {
                    returnVal = false;
                }
            }
            else
            {
                long result;
                if (Int64.TryParse(strText, out result))
                {
                    returnVal = true;
                }
                else
                {
                    returnVal = false;
                }
            }
            return returnVal;

            //string deniedSymbols = "~`!: ;@#$%^&*()-+=[{}]\\|/?<>,'\"";

            //if (!allowDecimalPoint) deniedSymbols += ".";

            //for (int indx = 65; indx <= 90; indx++)
            //{
            //    deniedSymbols += ((char)indx).ToString();
            //}
            //for (int indx = 97; indx <= 122; indx++)
            //{
            //    deniedSymbols += ((char)indx).ToString();
            //}
            //for (int xindx = 0; xindx < strText.Length; xindx++) //Check Every Character
            //{
            //    for (int yindx = 0; yindx < deniedSymbols.Length; yindx++)
            //    {
            //        if (strText.IndexOf(deniedSymbols[yindx]) >= 0) //If Found
            //        {
            //            returnVal = false;
            //            break;
            //        }
            //    }
            //    if (!returnVal) break;
            //}
            //return returnVal;
        }

        /*!Function: Function to mask the pattern*/
        public static void ApplyMask(object sender, KeyEventArgs e)
        {
            if (e.Alt || e.Control)
            {
                return;
            }
            string mode = ((Control)sender).Tag == null
                           ? "" : ((Control)sender).Tag.ToString().Trim().ToUpper();
            if (mode.Equals("ALPHA"))
            {
                AllowOnlyAlphaNumeric(sender, e);
            }
            else if (mode.Equals("SPECIAL_ALPHA"))
            {
                AllowSpecialAlphaNumeric(sender, e);
            }
            else if (mode.Equals("ALPHA_STOP"))
            {
                AllowSpecialAlphaNumericFullStop(sender, e);
            }
            else if (mode.Equals("NUM"))
            {
                AllowOnlyNumbers(sender, e);
            }
            else if (mode.Equals("CURRENCY"))
            {
                AllowOnlyCurrency(sender, e);
            }
            else if (mode.Equals("DECIMAL"))
            {
                AllowDecimals(sender, e);
            }
            else if (mode.Equals("ADD_SUB"))
            {
                AllowPlusMinus(sender, e);
            }
            else if (mode.Equals("LOV_ONLY"))
            {
                if (e.KeyCode != Keys.Enter || e.KeyCode != Keys.Tab)
                {
                    e.SuppressKeyPress = true;
                }
            }

        }

        /*!Function: Allow Data in Alpha Numeric Format With Space*/
        public static void AllowSpecialAlphaNumeric(object sender, KeyEventArgs e)
        {
            if (e.KeyValue != 189 && e.KeyValue != 35 && e.KeyValue != 36 && e.KeyValue != 37 && e.KeyValue != 39 && e.KeyValue != 38 && e.KeyValue != 40 && e.KeyValue != 46 && e.KeyValue != 8) //Not Up/Down/Right/Left Arrow, Backspace or Delete
            {
                if (e.KeyValue < 65 || e.KeyValue > 90) //Not between A-Z
                {

                    if (e.Shift) //If ShiftKey is pressed then suppress it
                    {
                        e.SuppressKeyPress = true;
                        return;
                    }

                    if ((e.KeyValue < 48 || e.KeyValue > 57))  //0-9 
                        if (e.KeyValue < 96 || e.KeyValue > 105) //0-9 from numeric key pad
                            if (e.KeyValue != 32) //Leave space
                                e.SuppressKeyPress = true; //Other keys are not allowed


                }
            }
        }


        /*!Function: Allow Data in Alpha Numeric Format With Space and full stop*/
        public static void AllowSpecialAlphaNumericFullStop(object sender, KeyEventArgs e)
        {
            if (e.KeyValue != 189 && e.KeyValue != 35 && e.KeyValue != 36 && e.KeyValue != 37 && e.KeyValue != 39 && e.KeyValue != 38 && e.KeyValue != 40 && e.KeyValue != 46 && e.KeyValue != 8) //Not Up/Down/Right/Left Arrow, Backspace or Delete
            {
                if (e.KeyValue < 65 || e.KeyValue > 90) //Not between A-Z
                {

                    if (e.Shift) //If ShiftKey is pressed then suppress it
                    {
                        e.SuppressKeyPress = true;
                        return;
                    }

                    if ((e.KeyValue < 48 || e.KeyValue > 57))  //0-9 
                        if (e.KeyValue < 96 || e.KeyValue > 105) //0-9 from numeric key pad
                            if (e.KeyValue != 32) //Leave space
                                if (e.KeyValue != 190 && e.KeyValue != 188)//Leave full stop
                                    e.SuppressKeyPress = true; //Other keys are not allowed


                }
            }
        }



        /*!Function: Allow Data in Alpha Numeric Format*/
        public static void AllowOnlyAlphaNumeric(object sender, KeyEventArgs e)
        {
            if (e.KeyValue != 35 && e.KeyValue != 36 && e.KeyValue != 37 && e.KeyValue != 39 && e.KeyValue != 38 && e.KeyValue != 40 && e.KeyValue != 46 && e.KeyValue != 8 && e.KeyCode != Keys.Space) //Not Up/Down/Right/Left Arrow, Backspace or Delete
            {
                if (e.KeyValue < 65 || e.KeyValue > 90) //Not between A-Z
                {

                    if (e.Shift) //If ShiftKey is pressed then suppress it
                    {
                        if (e.KeyValue != 189) //Leave hyphen or underscore
                        {
                            e.SuppressKeyPress = true;
                            return;
                        }
                    }

                    if ((e.KeyValue < 48 || e.KeyValue > 57))  //0-9 
                        if (e.KeyValue < 96 || e.KeyValue > 105) //0-9 from numeric key pad
                            if (e.KeyValue != 189 && e.KeyValue != 188) //Leave hyphen or underscore
                                e.SuppressKeyPress = true; //Other keys are not allowed

                    if (!e.Shift && e.KeyValue == 189) //For Hyphen
                    {
                        e.SuppressKeyPress = true;
                    }
                }
            }
        }


        /*!Function: Restricts characters other than 0-9, Up/Down/Right/Left Arrows, Backspace and Delete*/
        public static void AllowOnlyNumbers(object sender, KeyEventArgs e)
        {
            // int a = e.KeyValue;
            if (e.KeyValue != 35 && e.KeyValue != 36 && e.KeyValue != 37 && e.KeyValue != 39 && e.KeyValue != 38 && e.KeyValue != 40 && e.KeyValue != 46 && e.KeyValue != 8) //Not Up/Down/Right/Left Arrow, Backspace or Delete
            {
                if (e.Shift) //If ShiftKey is pressed then suppress it
                {
                    e.SuppressKeyPress = true;
                    return;
                }

                if ((e.KeyValue < 48 || e.KeyValue > 57))  //0-9 
                    if (e.KeyValue < 96 || e.KeyValue > 105) //0-9 from numeric key pad
                        e.SuppressKeyPress = true; //Other keys are not allowed
            }
        }
        //---------------------ADDED
        public static void AllowPlusMinus(object sender, KeyEventArgs e)
        {
            if (e.KeyValue != 35 && e.KeyValue != 36 && e.KeyValue != 37 && e.KeyValue != 39 && e.KeyValue != 38 && e.KeyValue != 40 && e.KeyValue != 46 && e.KeyValue != 8) //Not Up/Down/Right/Left Arrow, Backspace or Delete
            {
                if (e.Shift) //If ShiftKey is pressed then suppress it
                {
                    e.SuppressKeyPress = true;
                    return;
                }
                //if (e.Shift && e.KeyValue == 187) //For +
                //{
                //    e.SuppressKeyPress = false;
                //    return;
                //}
                if (!e.Shift && e.KeyValue == 189) //For Hyphen
                {
                    e.SuppressKeyPress = false;
                    return;
                }
                if (e.Shift && (e.KeyValue < 48 || e.KeyValue > 57) && e.KeyValue != 187) //For +
                {
                    e.SuppressKeyPress = true;
                    return;
                }

                if ((e.KeyValue < 48 || e.KeyValue > 57))  //0-9 
                    if (e.KeyValue < 96 || e.KeyValue > 105) //0-9 from numeric key pad
                        e.SuppressKeyPress = true; //Other keys are not allowed
                if (e.KeyValue == 107 || e.KeyValue == 109) e.SuppressKeyPress = false;


            }
        }
        public static void AllowOnlyCurrency(object sender, KeyEventArgs e)
        {
            // int a = e.KeyValue;
            if (e.KeyValue != 35 && e.KeyValue != 36 && e.KeyValue != 37 && e.KeyValue != 39 && e.KeyValue != 38 && e.KeyValue != 40 && e.KeyValue != 46 && e.KeyValue != 8) //Not Up/Down/Right/Left Arrow, Backspace or Delete
            {
                if (e.Shift) //If ShiftKey is pressed then suppress it
                {
                    e.SuppressKeyPress = true;
                    return;
                }

                if ((e.KeyValue < 48 || e.KeyValue > 57))  //0-9 
                    if (e.KeyValue < 96 || e.KeyValue > 105) //0-9 from numeric key pad
                        e.SuppressKeyPress = true; //Other keys are not allowed
            }
        }

        /*!Function: Restricts characters other than 0-9, Decimal Place (.), Up/Down/Right/Left Arrows, Backspace and Delete*/
        public static void AllowDecimals(object sender, KeyEventArgs e)
        {
            if (e.KeyValue != 35 && e.KeyValue != 36 && e.KeyValue != 37 && e.KeyValue != 39 && e.KeyValue != 38 && e.KeyValue != 40 && e.KeyValue != 46 && e.KeyValue != 8) //Not Up/Down/Right/Left Arrow, Backspace or Delete
            {
                if (e.Shift) //If ShiftKey is pressed then suppress it
                {
                    e.SuppressKeyPress = true;
                    return;
                }
                if ((e.KeyValue < 48 || e.KeyValue > 57))  //0-9 
                    if (e.KeyValue < 96 || e.KeyValue > 105) //0-9 from numeric key pad
                        if (e.KeyValue != 110 && e.KeyValue != 190 && e.KeyValue != 189) // 189:  minus Key
                            e.SuppressKeyPress = true; //Other keys are not allowed
            }
        }

        /*!Function: Function to mask the pattern*/
        public static void ApplyMaskLeave(object sender, CancelEventArgs e)
        {
            string mode = ((Control)sender).Tag == null
                           ? "" : ((Control)sender).Tag.ToString().Trim().ToUpper();
            if (mode.Equals("ALPHA"))
            {
                AllowAlphaOnValidating(sender, e);
            }
            else if (mode.Equals("SPECIAL_ALPHA"))
            {
                AllowSpecialAlphaOnValidating(sender, e);
            }
            else if (mode.Equals("NUM"))
            {
                if (!IsNumeric(((Control)sender).Text, false))
                {
                    e.Cancel = true;
                }
                if (((Control)sender).Text.Trim() == string.Empty)
                {
                    //e.Cancel = true;
                }

            }
            else if (mode.Equals("CURRENCY"))
            {
                AllowSpecialCURRENCYOnValidatingstop(sender, e);

            }
            else if (mode.Equals("ADD_SUB"))
            {
                AllowSpecialADD_SUBOnValidatingstop(sender, e);

            }
            else if (mode.Equals("ALPHA_STOP"))
            {
                AllowSpecialAlphaOnValidatingstop(sender, e);
            }
            else if (mode.Equals("DECIMAL"))
            {
                if (!IsNumeric(((Control)sender).Text, true))
                {
                    e.Cancel = true;
                }
                if (((Control)sender).Text.Trim() == string.Empty)
                {
                    e.Cancel = true;
                }
                //if
            }

        }

        private static void AllowSpecialAlphaOnValidating(object sender, CancelEventArgs e)
        {
            string[] quoteString = { " ", "-" };
            if (!IsAlphaNumeric(((Control)sender).Text, true, quoteString))
            {
                e.Cancel = true;
            }
        }

        private static void AllowSpecialAlphaOnValidatingstop(object sender, CancelEventArgs e)
        {
            string[] quoteString = { " ", "-", "." };
            if (!IsAlphaNumeric(((Control)sender).Text, true, quoteString))
            {
                e.Cancel = true;
            }
        }
        private static void AllowSpecialADD_SUBOnValidatingstop(object sender, CancelEventArgs e)
        {
            string[] quoteString = { "+", "-" };
            if (!IsAlphaNumeric(((Control)sender).Text, true, quoteString))
            {
                e.Cancel = true;
            }
        }
        private static void AllowSpecialCURRENCYOnValidatingstop(object sender, CancelEventArgs e)
        {
            string[] quoteString = { "," };
            if (!IsAlphaNumeric(((Control)sender).Text, true, quoteString))
            {
                e.Cancel = true;
            }
        }
        private static void AllowAlphaOnValidating(object sender, CancelEventArgs e)
        {
            if (!IsAlphaNumeric(((Control)sender).Text, false, null))
            {
                e.Cancel = true;
            }
        }

        public static string ValidateLikeOperatorWildcards(string curoperator, string searchTerm)
        {
            string likeOperator = (curoperator.ToLower().StartsWith("contains")) ? "LIKE" : "NOT LIKE";

            if (searchTerm.Contains("%"))
            {
                int indexOf = searchTerm.IndexOf('%');
                string str = searchTerm.Insert(indexOf, "!");
                return likeOperator + " '%" + Validation.CheckQuotes(str) + "%' ESCAPE '!'";
            }
            if (searchTerm.Contains("["))
            {
                int indexOf = searchTerm.IndexOf('[');
                string str = searchTerm.Insert(indexOf, "!");
                return likeOperator + " '%" + Validation.CheckQuotes(str) + "%' ESCAPE '!'";
            }
            if (searchTerm.Contains("_"))
            {
                int indexOf = searchTerm.IndexOf('_');
                string str = searchTerm.Insert(indexOf, "!");
                return likeOperator + " '%" + Validation.CheckQuotes(str) + "%' ESCAPE '!'";

            }
            return likeOperator + " '%" + Validation.CheckQuotes(searchTerm) + "%'";
        }

        public static string ValidateWildcardsOperatorsForSearch(string curoperator, string searchTerm)
        {
            string likeOperator = (curoperator.ToLower().StartsWith("contains")) ? "LIKE" : "NOT LIKE";

            if (searchTerm.Contains("%"))
            {
                //int indexOf = searchTerm.IndexOf('%');
                // string str = searchTerm.Insert(indexOf, "!");
                return likeOperator + " '%" + Validation.CheckQuotes(searchTerm) + "%' ESCAPE '!'";
            }
            if (searchTerm.Contains("["))
            {
                //int indexOf = searchTerm.IndexOf('[');
                // string str = searchTerm.Insert(indexOf, "!");
                return likeOperator + " '%" + Validation.CheckQuotes(searchTerm) + "%' ESCAPE '!'";
            }
            if (searchTerm.Contains("_"))
            {
                //int indexOf = searchTerm.IndexOf('_');
                // string str = searchTerm.Insert(indexOf, "!");
                return likeOperator + " '%" + Validation.CheckQuotes(searchTerm) + "%' ESCAPE '!'";

            }
            return likeOperator + " '%" + Validation.CheckQuotes(searchTerm) + "%'";
        }
    }
}
