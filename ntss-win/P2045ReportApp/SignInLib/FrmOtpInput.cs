using NKKLoggingLib;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SignInLib
{
    /// <summary>
    /// OTPを1文字以上入力して[送信]すると Tag に入力内容が入ります
    /// </summary>
    public partial class FrmOtpInput : Form
    {
        public FrmOtpInput()
        {
            InitializeComponent();
        }

        private void FrmOtpInput_Load(object sender, EventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, LayoutDesignerUtilityLib.LayoutDesignerUtility.PRODUCT_NAME,
                GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);
        }

        private void FrmOtpInput_FormClosed(object sender, FormClosedEventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, LayoutDesignerUtilityLib.LayoutDesignerUtility.PRODUCT_NAME,
                GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);
        }

        private void txtOtp_TextChanged(object sender, EventArgs e)
        {
            if (1 <= txtOtp.TextLength && false == string.IsNullOrWhiteSpace(txtOtp.Text))
            {
                btnSendOtp.Enabled = true;
            }
            else
            {
                btnSendOtp.Enabled = false;
            }
        }

        private void txtOtp_KeyDown(object sender, KeyEventArgs e)
        {
            if (Keys.Enter == e.KeyCode && 1 <= txtOtp.TextLength && false == string.IsNullOrWhiteSpace(txtOtp.Text))
            {
                btnSendOtp_Click(sender, e);
            }
        }

        private void btnSendOtp_Click(object sender, EventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, LayoutDesignerUtilityLib.LayoutDesignerUtility.PRODUCT_NAME,
                GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);

            DialogResult = DialogResult.OK;
            Tag = txtOtp.Text;
            Close();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, LayoutDesignerUtilityLib.LayoutDesignerUtility.PRODUCT_NAME,
                GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);

            DialogResult = DialogResult.Cancel;
            Close();
        }
    }
}
