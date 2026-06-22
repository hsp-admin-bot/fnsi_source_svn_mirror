using NKKCommon;
using NKKWebAccessLib;
using System;
using System.Drawing;
using System.Windows.Forms;

namespace NKK.BloodPurify
{
    public partial class FrmDarkBase : Form
    {
        // タイトルバー風ラベルを掴んでのフォーム移動をする際のマウス掴み位置メモ
        private Point LblTitleMouseDownPoint;

        // winフォームのフォームグリップ操作を示す定数(自前定義ではなくてシステム定義)
        private const int
           HTLEFT = 10,
           HTRIGHT = 11,
           HTTOP = 12,
           HTTOPLEFT = 13,
           HTTOPRIGHT = 14,
           HTBOTTOM = 15,
           HTBOTTOMLEFT = 16,
           HTBOTTOMRIGHT = 17;

        // フォームグリップの幅サイズ
        private readonly int Grip = 4;

        // フォームグリップの範囲指定(四隅と上下左右)
        private Rectangle GripTop { get { return new Rectangle(0, 0, ClientSize.Width, Grip); } }
        private Rectangle GripLeft { get { return new Rectangle(0, 0, Grip, ClientSize.Height); } }
        private Rectangle GripBottom { get { return new Rectangle(0, ClientSize.Height - Grip, ClientSize.Width, Grip); } }
        private Rectangle GripRight { get { return new Rectangle(ClientSize.Width - Grip, 0, Grip, ClientSize.Height); } }
        private Rectangle GripTopLeft { get { return new Rectangle(0, 0, Grip, Grip); } }
        private Rectangle GripTopRight { get { return new Rectangle(ClientSize.Width - Grip, 0, Grip, Grip); } }
        private Rectangle GripBottomLeft { get { return new Rectangle(0, ClientSize.Height - Grip, Grip, Grip); } }
        private Rectangle GripBottomRight { get { return new Rectangle(ClientSize.Width - Grip, ClientSize.Height - Grip, Grip, Grip); } }

        protected override void WndProc(ref Message message)
        {
            base.WndProc(ref message);

            if (message.Msg == 0x84) // WM_NCHITTEST
            {
                // フォームグリップ操作に変換
                var cursor = PointToClient(Cursor.Position);
                if (GripTopLeft.Contains(cursor)) message.Result = (IntPtr)HTTOPLEFT;
                else if (GripTopRight.Contains(cursor)) message.Result = (IntPtr)HTTOPRIGHT;
                else if (GripBottomLeft.Contains(cursor)) message.Result = (IntPtr)HTBOTTOMLEFT;
                else if (GripBottomRight.Contains(cursor)) message.Result = (IntPtr)HTBOTTOMRIGHT;
                else if (GripTop.Contains(cursor)) message.Result = (IntPtr)HTTOP;
                else if (GripLeft.Contains(cursor)) message.Result = (IntPtr)HTLEFT;
                else if (GripRight.Contains(cursor)) message.Result = (IntPtr)HTRIGHT;
                else if (GripBottom.Contains(cursor)) message.Result = (IntPtr)HTBOTTOM;
            }
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            // 枠線を自前で書く
            int thick = 1;
            SolidBrush sb = new SolidBrush(Color.FromArgb(100, 100, 100));
            Rectangle rc;

            // 上
            rc = new Rectangle(0, 0, ClientSize.Width, thick);
            e.Graphics.FillRectangle(sb, rc);
            // 左
            rc = new Rectangle(0, 0, thick, ClientSize.Height);
            e.Graphics.FillRectangle(sb, rc);
            // 下
            rc = new Rectangle(0, ClientSize.Height - thick, ClientSize.Width, thick);
            e.Graphics.FillRectangle(sb, rc);
            // 右
            rc = new Rectangle(ClientSize.Width - thick, 0, thick, ClientSize.Height);
            e.Graphics.FillRectangle(sb, rc);
        }

        public FrmDarkBase()
        {
            InitializeComponent();
        }

        private void FrmDarkBase_Load(object sender, EventArgs e)
        {
            // Sizableでない枠無しフォームでもサイズ変更可能にするために必要
            SetStyle(ControlStyles.ResizeRedraw, true);

            // 「Segoe MDL2 Assets」に含まれる「アイコンっぽい文字」をセット
            BtnMin.Text = Convert.ToChar(AppCmn.ChromeMinimize).ToString();
            BtnMax.Text = Convert.ToChar(AppCmn.ChromeMaximize).ToString();
            BtnClose.Text = Convert.ToChar(AppCmn.ChromeClose).ToString();
        }

        private void BtnMin_Click(object sender, EventArgs e)
        {
            WindowState = FormWindowState.Minimized;
        }

        private void BtnMax_Click(object sender, EventArgs e)
        {
            if (FormWindowState.Maximized != WindowState)
            {
                WindowState = FormWindowState.Maximized;
                BtnMax.Text = Convert.ToChar(AppCmn.ChromeRestore).ToString();
            }
            else
            {
                WindowState = FormWindowState.Normal;
                BtnMax.Text = Convert.ToChar(AppCmn.ChromeMaximize).ToString();
            }
        }

        private void BtnClose_Click(object sender, EventArgs e)
        {
            Close();

            // add mongodbに転載、サーバー停止ログ。 陳 start
            if (NKKWebAccess.Login)
            {
                LogManagement.LogMessage = "特殊浄化通信アプリサーバーが停止しました。";
                LogManagement.SetLogingProperties();
            }
            // add mongodbに転載、サーバー停止ログ。 陳 end
        }

        private void LblTitle_DoubleClick(object sender, EventArgs e)
        {
            BtnMax_Click(sender, e);
        }

        private void LblTitle_MouseDown(object sender, MouseEventArgs e)
        {
            if ((e.Button & MouseButtons.Left) == MouseButtons.Left)
            {
                LblTitleMouseDownPoint = new Point(e.X, e.Y);
            }
        }

        private void LblTitle_MouseMove(object sender, MouseEventArgs e)
        {
            if ((e.Button & MouseButtons.Left) == MouseButtons.Left)
            {
                Left += e.X - LblTitleMouseDownPoint.X;
                Top += e.Y - LblTitleMouseDownPoint.Y;
            }
        }

        /// <summary>
        /// フォームタイトルとタイトルバー風ラベルのテキストをセット
        /// </summary>
        /// <param name="argTitle">フォームタイトルとタイトルバー風ラベルにセットするテキスト</param>
        protected void SetTitle(string argTitle)
        {
            Text = argTitle;
            LblTitle.Text = argTitle;

            // タイトルバー風ラベルの横幅も動的にフォーム幅に合わせる
            Size old = LblTitle.Size;
            LblTitle.Size = new Size(ClientSize.Width, old.Height);
        }

        /// <summary>
        /// 最小/最大/閉じるボタンの表示／非表示を切り替え
        /// </summary>
        /// <param name="argFontFamily">{"null":"非表示", "nullでない":"表示フォント(※「Segoe MDL2 Assets」を想定)"}</param>
        protected void SetVisibleBtnMinMaxClose(FontFamily argFontFamily)
        {
            if (null != argFontFamily)
            {
                float size;

                size = BtnMin.Font.Size;
                BtnMin.Font = new Font(argFontFamily, size);

                size = BtnMax.Font.Size;
                BtnMax.Font = new Font(argFontFamily, size);

                size = BtnClose.Font.Size;
                BtnClose.Font = new Font(argFontFamily, size);
            }
            else
            {
                BtnMin.Visible = false;
                BtnMax.Visible = false;
                BtnClose.Visible = false;
            }
        }
    }
}
