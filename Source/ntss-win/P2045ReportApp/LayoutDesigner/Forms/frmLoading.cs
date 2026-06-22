using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LayoutDesigner.Forms
{
    /// <summary>
    /// add 2020-08-06 FNSI-仕様追加 ページ追加 李
    /// </summary>
    public partial class frmLoading : Form
    {
        public delegate void dgtForm();
        private readonly Rectangle? workingArea;

        public frmLoading()
            : this(null)
        {
        }

        public frmLoading(Rectangle? aWorkingArea)
        {
            InitializeComponent();
            this.workingArea = aWorkingArea;

            if (this.workingArea.HasValue)
            {
                this.StartPosition = FormStartPosition.Manual;
            }
        }

        public void ShowLoadingDialog()
        {
            //Rectangle rect = Screen.GetWorkingArea(this);
            //this.Width = rect.Width;
            //this.Height = rect.Height;
            this.ShowDialog();
        }

        protected override void OnShown(EventArgs e)
        {
            base.OnShown(e);

            if (!this.workingArea.HasValue)
            {
                return;
            }

            var area = this.workingArea.Value;
            // CenterScreen のままだと主画面に出るため、指定された作業領域の中央へ寄せる。
            this.Location = new Point(
                area.Left + Math.Max(0, (area.Width - this.Width) / 2),
                area.Top + Math.Max(0, (area.Height - this.Height) / 2));
        }

        public void CloseForm()
        {
            if (this.InvokeRequired)
            {
                dgtForm UIinfo = new dgtForm(new Action(() =>
                {
                    while (!this.IsHandleCreated)
                    {
                        ;
                    }
                    if (this.IsDisposed)
                        return;
                    if (!this.IsDisposed)
                    {
                        this.Dispose();
                    }

                }));
                this.Invoke(UIinfo);
            }
            else
            {
                if (this.IsDisposed)
                    return;
                if (!this.IsDisposed)
                {
                    this.Dispose();
                }
            }
        }

        private void frmLoading_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (!this.IsDisposed)
            {
                this.Dispose(true);
            }
        }
    }
}
