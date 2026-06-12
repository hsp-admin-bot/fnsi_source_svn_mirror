using System;
using System.Drawing;
using System.Windows.Forms;

namespace FNSICloudConvertClient.Forms
{
    internal class ProgressBarEx : Control
    {
        private int  _value   = 0;
        private bool _isError = false;

        public int Value
        {
            get { return _value; }
            set { _value = Math.Max(0, Math.Min(100, value)); Invalidate(); }
        }

        public bool IsError
        {
            get { return _isError; }
            set { _isError = value; Invalidate(); }
        }

        public void Reset()
        {
            _value   = 0;
            _isError = false;
            Invalidate();
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            var g    = e.Graphics;
            var rect = ClientRectangle;

            // Background
            using (var bgBrush = new SolidBrush(Color.FromArgb(50, 50, 50)))
                g.FillRectangle(bgBrush, rect);

            // Fill
            if (_value > 0)
            {
                int fillW = (int)(rect.Width * _value / 100.0);
                var fillColor = _isError ? Color.FromArgb(180, 0, 0) : Color.FromArgb(46, 139, 87);
                using (var fillBrush = new SolidBrush(fillColor))
                    g.FillRectangle(fillBrush, 0, 0, fillW, rect.Height);
            }

            // Border
            using (var pen = new Pen(Color.FromArgb(90, 90, 90)))
                g.DrawRectangle(pen, 0, 0, rect.Width - 1, rect.Height - 1);

            // Percentage text
            string text = _value + "%";
            using (var font = new Font("Consolas", 7.5F, FontStyle.Bold))
            {
                SizeF  sz = g.MeasureString(text, font);
                float  tx = (rect.Width  - sz.Width)  / 2f;
                float  ty = (rect.Height - sz.Height) / 2f;
                using (var shadow = new SolidBrush(Color.FromArgb(120, 0, 0, 0)))
                    g.DrawString(text, font, shadow, tx + 1, ty + 1);
                using (var fg = new SolidBrush(Color.White))
                    g.DrawString(text, font, fg, tx, ty);
            }
        }

        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams cp = base.CreateParams;
                cp.ExStyle |= 0x02000000; // WS_EX_COMPOSITED
                return cp;
            }
        }
    }
}
