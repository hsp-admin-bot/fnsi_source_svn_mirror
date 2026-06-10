using System;
using System.Windows.Forms;
using static NKKWeightScaleApp.Commons.Delegates;

namespace NKKWeightScaleApp.Views
{
    public partial class FrmMessageBox : Form
    {
        FlagClose send;
        bool flag = false;
        public FrmMessageBox(string message, string buttonText1, string buttonText2,string header, FlagClose sender)
        {
            InitializeComponent();

            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 start
            this.Icon = Properties.Resources.NKKWeight;
            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 end

            lblMessage.Text = message;
            button1.Text = buttonText1;
            button2.Text = buttonText2;
            Text = header;
            send = sender;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.send(false);
            flag = false;
            this.Close();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            this.send(true);
            flag = true;
            this.Close();
        }

        private void FrmMessageBox_FormClosed(object sender, FormClosedEventArgs e)
        {
            if (flag)
                this.send(true);
            else
            this.send(false);
            this.Close();
        }
    }
}
