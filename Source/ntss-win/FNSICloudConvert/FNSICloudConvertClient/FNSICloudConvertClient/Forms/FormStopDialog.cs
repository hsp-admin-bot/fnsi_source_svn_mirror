using System;
using System.Drawing;
using System.Windows.Forms;

namespace FNSICloudConvertClient.Forms
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// 中止確認ダイアログ
    ///   DialogResult.Yes    = 中止
    ///   DialogResult.Cancel = キャンセル（何もしない）
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    internal class FormStopDialog : Form
    {
        public FormStopDialog()
        {
            this.Text            = "中止の確認";
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.StartPosition   = FormStartPosition.CenterParent;
            this.Size            = new Size(320, 160);
            this.MaximizeBox     = false;
            this.MinimizeBox     = false;

            var lbl = new Label
            {
                Text      = "処理を中止しますか？",
                Location  = new Point(16, 16),
                Size      = new Size(280, 20),
                Font      = new Font("MS UI Gothic", 9F),
            };

            var btnStop = new Button
            {
                Text      = "中止",
                Location  = new Point(76, 80),
                Size      = new Size(72, 34),
                Font      = new Font("MS UI Gothic", 9F, FontStyle.Bold),
                BackColor = Color.FromArgb(218, 165, 32),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
            };
            btnStop.Click += (s, e) => { this.DialogResult = DialogResult.Yes; this.Close(); };

            var btnCancel = new Button
            {
                Text      = "キャンセル",
                Location  = new Point(164, 80),
                Size      = new Size(80, 34),
                Font      = new Font("MS UI Gothic", 9F),
                FlatStyle = FlatStyle.Flat,
            };
            btnCancel.Click += (s, e) => { this.DialogResult = DialogResult.Cancel; this.Close(); };

            this.Controls.Add(lbl);
            this.Controls.Add(btnStop);
            this.Controls.Add(btnCancel);
        }
    }
}
