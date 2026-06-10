using LayoutDesignerUtilityLib;
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NKK.BloodPurify
{
    public class ExMonthCalendar : MonthCalendar
    {
        public delegate void OnMyDoubleClickEventHandler(object sender, MouseEventArgs e);
        public event OnMyDoubleClickEventHandler MyDoubleClick;

        private int PrevMouseDownTime = 0;

        [DllImport("uxtheme.dll", ExactSpelling = true, CharSet = CharSet.Unicode)]
        static extern int SetWindowTheme(IntPtr hwnd, string pszSubAppName, string pszSubIdList);

        protected override void OnHandleCreated(EventArgs e)
        {
            SetWindowTheme(Handle, string.Empty, string.Empty);
            base.OnHandleCreated(e);
        }

        protected override void OnMouseDown(MouseEventArgs e)
        {
            base.OnMouseDown(e);

            if (null != MyDoubleClick)
            {
                // 1回目のマウスダウン(※200+10ミリ秒後にはリセット)
                if (0 == PrevMouseDownTime)
                {
                    PrevMouseDownTime = Environment.TickCount;
                    AsyncDelayResetPrevMouseDownTime();
                    return;
                }

                int nowMouseDownTime = Environment.TickCount;
                if ((nowMouseDownTime - PrevMouseDownTime) < 200)
                {
                    // 2回目のマウスダウンが200ミリ秒以内なら「ダブルクリック」
                    MyDoubleClick(this, e);
                }
            }
        }

        private async void AsyncDelayResetPrevMouseDownTime()
        {
            await Task.Delay(210);
            PrevMouseDownTime = 0;
        }
    }
}
