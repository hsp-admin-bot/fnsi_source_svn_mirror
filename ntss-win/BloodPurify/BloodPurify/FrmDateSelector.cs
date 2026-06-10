using LayoutDesignerUtilityLib;
using System;
using System.Drawing;
using System.Globalization;
using System.Reflection;
using System.Windows.Forms;

namespace NKK.BloodPurify
{
    public partial class FrmDateSelector : FrmDarkBase
    {
        public FrmDateSelector(string argYyyymmdd)
        {
            InitializeComponent();

            MonthCalendar.SelectionStart = DateTime.ParseExact(argYyyymmdd, "yyyyMMdd", DateTimeFormatInfo.InvariantInfo, DateTimeStyles.None);
        }

        private void FrmDateSelector_Load(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            // <> FrmDarkBaseを継承しているもので共通の処理
            SetTitle("日付選択");
            // 全部に「Yu Gothic UI」を適用 → 最小/最大/閉じるボタンに「Segoe MDL2 Assets」を適用
            foreach (Control ctrl in AppCmn.GetAllControls(this))
            {
                float size = ctrl.Font.Size;
                ctrl.Font = new Font(LayoutDesignerUtility.GetResourceFontFamily(LayoutDesignerUtility.ResourceFont.YU), size);
            }
            SetVisibleBtnMinMaxClose(null);
            // </>
        }
        private void FrmDateSelector_FormClosed(object sender, FormClosedEventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);
        }

        private void BtnOk_Click(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            DialogResult = DialogResult.OK;
            Close();
        }

        private void BtnCancel_Click(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            Close();
        }

        private void MonthCalendar_KeyDown(object sender, KeyEventArgs e)
        {
            if (Keys.Enter == e.KeyCode)
            {
                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + "[Enter]");

                BtnOk_Click(sender, e);
            }
            else if (Keys.Escape == e.KeyCode)
            {
                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + "[Esc]");

                Close();
            }
        }

        private void MonthCalendar_MyDoubleClick(object sender, MouseEventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            BtnOk_Click(sender, e);
        }
    }
}
