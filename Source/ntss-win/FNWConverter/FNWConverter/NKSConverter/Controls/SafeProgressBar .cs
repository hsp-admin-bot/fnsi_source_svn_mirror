using System;
using System.Drawing;
using System.Windows.Forms;

public class SafeProgressBar : Control
{
    private int minimum = 0;
    private int maximum = 100;
    private int value = 0;

    public Color FillColor { get; set; } = Color.FromArgb(0, 64, 64);
    public Color BackgroundColor { get; set; } = Color.White;
    public Color BorderColor { get; set; } = Color.White; 
    public Color TextColor { get; set; } = Color.White;
    public Font TextFont { get; set; } = new Font("Arial", 12, FontStyle.Bold);
    public int BorderWidth { get; set; } = 2; 

    public int Minimum { get => minimum; set { minimum = value; Invalidate(); } }
    public int Maximum { get => maximum; set { maximum = value; Invalidate(); } }
    public int Value { get => this.value; set { this.value = Math.Max(minimum, Math.Min(maximum, value)); Invalidate(); } }

    public SafeProgressBar()
    {
        this.SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint |
                      ControlStyles.OptimizedDoubleBuffer, true);
        this.Height = 25;
        this.Width = 500;
        this.BackColor = BackgroundColor;
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        base.OnPaint(e);
        Graphics g = e.Graphics;

        Rectangle clientRect = this.ClientRectangle;

        using (Pen borderPen = new Pen(BorderColor, BorderWidth))
        {
            g.DrawRectangle(borderPen, 0, 0, clientRect.Width - 1, clientRect.Height - 1);
        }

        Rectangle innerRect = new Rectangle(BorderWidth, BorderWidth, clientRect.Width - 2 * BorderWidth, clientRect.Height - 2 * BorderWidth);

        using (SolidBrush backBrush = new SolidBrush(BackgroundColor))
        {
            g.FillRectangle(backBrush, innerRect);
        }

        float percent = (float)(value - minimum) / (maximum - minimum);
        int fillWidth = (int)(percent * innerRect.Width);
        if (value > minimum && fillWidth < 1) fillWidth = 1; 

        Rectangle fillRect = new Rectangle(innerRect.X, innerRect.Y, fillWidth, innerRect.Height);
        using (SolidBrush fillBrush = new SolidBrush(FillColor))
        {
            g.FillRectangle(fillBrush, fillRect);
        }

        string text = $"{(int)(percent * 100)}%";
        using (SolidBrush textBrush = new SolidBrush(TextColor))
        {
            StringFormat sf = new StringFormat
            {
                Alignment = StringAlignment.Center,
                LineAlignment = StringAlignment.Center
            };
            g.DrawString(text, TextFont, textBrush, clientRect, sf);
        }
    }
}