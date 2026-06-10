using NKKWeightScaleApp.Commons;
using NKKWeightScaleApp.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;
using static NKKWeightScaleApp.Commons.Delegates;

namespace NKKWeightScaleApp.Views
{
    public partial class FrmModalCommon : Form
    {
        private int countModified = 0;
        private string oldValue;
        private const string TXTVALUE = "txtValue";
        private const string TXTNAME = "txtName";
        private const string LBLUNIT = "lblUnit";
        private const string TXTVALUETAG = "value";
        private const string TXTNAMETAG = "name";
        private const string LBLUNITTAG = "unit";
        private Dictionary<string, string> textBoxList;
        public SendMessageList<Common> send;
        private string status;
        private bool flagClose = false;

        public FrmModalCommon(SendMessageList<Common> sender, List<Common> commons)
        {
            InitializeComponent();

            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 start
            this.Icon = Properties.Resources.NKKWeight;
            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 end

            send = sender;
            status = commons.Select(item => item.Status).FirstOrDefault();
            textBoxList = new Dictionary<string, string>();
            ChangeBackgroundButton(btnUnitg);
            AddData(commons);
        }

        private void AddData(List<Common> valueList)
        {
            if (valueList.Count != 0)
            {
                for (int index = 0; index < ConfigValue.COUNT_COMMON; index++)
                {
                    Common item = valueList[index];
                    TextBox txtValue = this.Controls.Find(string.Format("{0}{1}", TXTVALUE, index), true).FirstOrDefault() as TextBox;
                    TextBox txtName = this.Controls.Find(string.Format("{0}{1}", TXTNAME, index), true).FirstOrDefault() as TextBox;
                    Label lblUnit = this.Controls.Find(string.Format("{0}{1}", LBLUNIT, index), true).FirstOrDefault() as Label;
                    txtValue.Text = item.Value.ToString("G29");
                    txtName.Text = item.Name;
                    textBoxList.Add(txtValue.Name, item.Value.ToString());
                    textBoxList.Add(txtName.Name, item.Name);
                }
            }
        }

        private void SwitchUnit(string unit)
        {
            foreach (Control groupBox in this.Controls)
            {
                if (groupBox is GroupBox)
                {
                    foreach (Control control in groupBox.Controls)
                    {
                        if (control is Label && control.Tag.ToString() == LBLUNITTAG)
                        {
                            control.Text = unit;
                        }
                        if (control is TextBox && control.Tag.ToString() == TXTVALUETAG)
                        {
                            decimal.TryParse(control.Text.Trim(), out decimal value);
                            if (unit == ConfigValue.UNIT_G && control.Text.Trim() != string.Empty)
                            {
                                control.Text = (value * 1000).ToString("G29");
                            }
                            else if (unit == ConfigValue.UNIT_KG && control.Text.Trim() != string.Empty)
                            {
                                control.Text = (value / 1000).ToString("G29");
                            }
                        }
                    }
                }
            }
        }

        private void btnUnitg_Click(object sender, EventArgs e)
        {
            if ((sender as Button).BackColor == SystemColors.ActiveCaption)
                return;
            ChangeBackgroundButton(sender as Button);
            SwitchUnit(ConfigValue.UNIT_G);
        }

        private void btnUnitkg_Click(object sender, EventArgs e)
        {
            if ((sender as Button).BackColor == SystemColors.ActiveCaption)
                return;
            ChangeBackgroundButton(sender as Button);
            SwitchUnit(ConfigValue.UNIT_KG);
        }

        private void TextBox_TextChanged(object sender, EventArgs e)
        {
            TextBox textBox = (TextBox)sender;
            if (textBox.Tag.ToString() == TXTVALUETAG)
            {
                int positionCursor = textBox.SelectionStart;
                decimal.TryParse(textBox.Text.Trim(), out decimal value);
                if ((btnUnitg.BackColor == SystemColors.ActiveCaption && value > ConfigValue.MAX_VALUE * 1000) ||
                    (btnUnitkg.BackColor == SystemColors.ActiveCaption && value > ConfigValue.MAX_VALUE))
                {
                    textBox.Text = oldValue;
                    textBox.SelectionStart = (positionCursor <= 0) ? 0 : positionCursor - 1;
                }
                else if ((btnUnitg.BackColor == SystemColors.ActiveCaption && value == ConfigValue.MAX_VALUE * 1000) ||
                    (btnUnitkg.BackColor == SystemColors.ActiveCaption && value == ConfigValue.MAX_VALUE))
                {
                    textBox.Text = textBox.Text.Replace(".", string.Empty);
                    textBox.SelectionStart = (positionCursor <= 0) ? 0 : positionCursor;
                }
                oldValue = textBox.Text.Trim();
            }
            foreach (KeyValuePair<string, string> oldTextBox in textBoxList)
            {
                if (textBox.Name == oldTextBox.Key)
                {
                    decimal.TryParse(textBox.Text.Trim(), out decimal valueChanged);
                    if (textBox.Tag.ToString() == TXTVALUETAG)
                    {
                        if (btnUnitkg.BackColor == SystemColors.ActiveCaption)
                        {
                            valueChanged = valueChanged * 1000;
                        }
                    }
                    decimal.TryParse(oldTextBox.Value, out decimal oldValue);
                    if ((valueChanged != oldValue && textBox.Tag.ToString()== TXTVALUETAG)||(textBox.Text!= oldTextBox.Value && textBox.Tag.ToString() == TXTNAMETAG) 
                        && textBox.ForeColor == SystemColors.WindowText)
                    {
                        textBox.ForeColor = Color.Green;
                        textBox.Font = new Font(textBox.Font, FontStyle.Bold);
                        countModified++;
                        break;
                    }
                    else if ((valueChanged == oldValue && textBox.Tag.ToString() == TXTVALUETAG) || (textBox.Text == oldTextBox.Value && textBox.Tag.ToString() == TXTNAMETAG) 
                        && textBox.ForeColor == Color.Green)
                    {
                        textBox.ForeColor = SystemColors.WindowText;
                        textBox.Font = new Font(textBox.Font, FontStyle.Regular);
                        countModified = (countModified == 0) ? 0 : (countModified - 1);
                        break;
                    }
                }
            }
        }

        private void TextBox_Enter(object sender, EventArgs e)
        {
            TextBox textBox = sender as TextBox;
            oldValue = textBox.Text.Trim();
        }

        private void TextBox_Leave(object sender, EventArgs e)
        {
            TextBox textBox = sender as TextBox;
            decimal.TryParse(textBox.Text.Trim(), out decimal value);
            textBox.Text = string.Format(ConfigValue.FORMAT, value);
        }

        private void TextBox_KeyPress(object sender, KeyPressEventArgs e)
        {
            TextBox textBox = sender as TextBox;
            decimal.TryParse(textBox.Text.Trim(), out decimal value);
            if (!char.IsDigit(e.KeyChar) && (e.KeyChar != '.') && (e.KeyChar != (char)Keys.Back))
            {
                e.Handled = true;
            }
            if ((e.KeyChar == '.') && ((sender as TextBox).Text.IndexOf('.') > -1))
            {
                e.Handled = true;
            }
            if (char.IsDigit(e.KeyChar))
            {
                int cursorPosLeft = textBox.SelectionStart;
                int cursorPosRight = textBox.SelectionStart + textBox.SelectionLength;
                string result = textBox.Text.Substring(0, cursorPosLeft) + e.KeyChar + textBox.Text.Substring(cursorPosRight);
                string[] parts = result.Split('.');
                if (parts.Length > 1)
                {
                    if (parts[1].Length > 2)
                    {
                        e.Handled = true;
                    }
                }
            }
        }

        private List<Common> GetValue()
        {
            List<Common> commons = new List<Common>();
            for (int index = 0; index < ConfigValue.COUNT_COMMON; index++)
            {
                TextBox txtValue = this.Controls.Find(string.Format("{0}{1}", TXTVALUE, index), true).FirstOrDefault() as TextBox;
                TextBox txtName = this.Controls.Find(string.Format("{0}{1}", TXTNAME, index), true).FirstOrDefault() as TextBox;
                decimal.TryParse(txtValue.Text.Trim(), out decimal value);
                if (btnUnitkg.BackColor == SystemColors.ActiveCaption)
                {
                    value = value * 1000;
                }
                commons.Add(new Common
                {
                    Name = txtName.Text,
                    Value = value,
                    Status = status,
                    Unit = ConfigValue.UNIT_KG
                });
            }
            return commons;
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            if (countModified != 0)
            {
                FrmMessageBox frmMessageBox = new FrmMessageBox(MessageShow.CONFIRM_COMMON, MessageShow.CANCEL_BUTTON_NAME, MessageShow.OK_BUTTON_NAME,Text,SetFlagClose);
                frmMessageBox.ShowDialog();
                if (flagClose == true)
                {
                    List<Common> commonList = new List<Common>();
                    commonList.AddRange(GetValue());
                    send(commonList);
                    this.Close();
                }
            }
            else
            {
                this.Close();
            }
        }
        private void SetFlagClose(bool value)
        {
            flagClose = value;
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void ChangeBackgroundButton(Button button)
        {
            btnUnitg.BackColor = SystemColors.Control;
            btnUnitkg.BackColor = SystemColors.Control;
            button.BackColor = SystemColors.ActiveCaption;
        }

        private void FrmModalCommon_FormClosed(object sender, FormClosedEventArgs e)
        {
            GC.Collect();
            Dispose();
        }
    }
}