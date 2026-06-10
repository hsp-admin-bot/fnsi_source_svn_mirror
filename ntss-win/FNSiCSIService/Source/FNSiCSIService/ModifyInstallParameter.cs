using System;
using System.Windows.Forms;
using System.Xml;

namespace FNSiCSIService
{
    public partial class ModifyInstallParameter : Form
    {
        public ModifyInstallParameter()
        {
            InitializeComponent();
        }

        string filePath;
        public ModifyInstallParameter(string filepath)
        {
            filePath = filepath.TrimEnd(System.IO.Path.DirectorySeparatorChar, System.IO.Path.AltDirectorySeparatorChar) + System.IO.Path.DirectorySeparatorChar;
            InitializeComponent();
            // del 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 start
            //System.Timers.Timer timer = new System.Timers.Timer();
            //timer.Interval = 10;
            //timer.Enabled = true;
            //timer.AutoReset = false;
            //timer.Elapsed += new System.Timers.ElapsedEventHandler(timer_Elapsed);
            // del 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 end
            GetConfig();
        }

        // del 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 start
        //public void timer_Elapsed(object o, EventArgs args)
        //{
        //    this.TopMost = true;
        //    this.Activate();
        //}
        // del 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 end

        // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 start
        /// <summary>
        /// OnShown
        /// </summary>
        /// <param name="e"></param>
        protected override void OnShown(EventArgs e)
        {
            BringToFrontEx();
            base.OnShown(e);
        }

        /// <summary>
        /// 他の画面より前に持つ
        /// </summary>
        public void BringToFrontEx()
        {
            if (InvokeRequired)
            {
                Invoke(new Action(BringToFrontEx));
            }
            else
            {
                this.TopMost = true;
                this.TopMost = false;
            }
        }
        // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 end

        public void GetConfig()
        {
            try
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(filePath + "FNSiCSI.config");
                XmlNode xns = xmlDoc.SelectSingleNode("Settings");
                XmlNodeList xnl = xns.ChildNodes;
                foreach (XmlNode xn in xnl)
                {
                    if (xn.NodeType == XmlNodeType.Element)
                    {
                        XmlElement xe = (XmlElement)xn;
                        XmlNodeList xnl2 = xe.ChildNodes;
                        foreach (XmlNode xn2 in xnl2)
                        {
                            if (xn2.NodeType == XmlNodeType.Element)
                            {
                                XmlElement xe2 = (XmlElement)xn2;
                                if (xe2.Name == "IFEdgeIPAddress")
                                    IFEdgeIPAddress.Text = xe2.InnerText;
                                else if (xe2.Name == "FtpIPAddress")
                                    FtpIPAddress.Text = xe2.InnerText;
                                else if (xe2.Name == "FtpPortNo")
                                    FtpPortNo.Text = xe2.InnerText;
                                else if (xe2.Name == "FtpUserId")
                                    FtpUserId.Text = xe2.InnerText;
                                else if (xe2.Name == "FtpPW")
                                    FtpPW.Text = xe2.InnerText;
                                else if (xe2.Name == "LogKeepNumberOfDays")
                                    LogKeepNumberOfDays.Text = xe2.InnerText;
                                else if (xe2.Name == "IFEdgePatientPortNo")
                                    IFEdgePatientPortNo.Text = xe2.InnerText;
                                else if (xe2.Name == "IFEdgeExaminPortNo")
                                    IFEdgeExaminPortNo.Text = xe2.InnerText;
                                else if (xe2.Name == "LocalPortNo")
                                    LocalPortNo.Text = xe2.InnerText;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("元の構成情報を取得できませんでした" + ex);
                throw;
            }
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            try
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(filePath + "FNSiCSI.config");
                XmlNode xns = xmlDoc.SelectSingleNode("Settings");
                XmlNodeList xml = xns.ChildNodes;

                foreach (XmlNode xn in xml)
                {
                    if (xn.NodeType == XmlNodeType.Element)
                    {
                        XmlElement xe = (XmlElement)xn;
                        XmlNodeList xnl2 = xe.ChildNodes;
                        foreach (XmlNode xn2 in xnl2)
                        {
                            if (xn2.NodeType == XmlNodeType.Element)
                            {
                                XmlElement xe2 = (XmlElement)xn2;
                                if (xe2.Name == "IFEdgeIPAddress")
                                    xe2.InnerText = IFEdgeIPAddress.Text;
                                else if (xe2.Name == "FtpIPAddress")
                                    xe2.InnerText = FtpIPAddress.Text;
                                else if (xe2.Name == "FtpPortNo")
                                    xe2.InnerText = FtpPortNo.Text;
                                else if (xe2.Name == "FtpUserId")
                                    xe2.InnerText = FtpUserId.Text;
                                else if (xe2.Name == "FtpPW")
                                    xe2.InnerText = FtpPW.Text;
                                else if (xe2.Name == "LogKeepNumberOfDays")
                                    xe2.InnerText = LogKeepNumberOfDays.Text;
                                else if (xe2.Name == "IFEdgePatientPortNo")
                                    xe2.InnerText = IFEdgePatientPortNo.Text;
                                else if (xe2.Name == "IFEdgeExaminPortNo")
                                    xe2.InnerText = IFEdgeExaminPortNo.Text;
                                else if (xe2.Name == "LocalPortNo")
                                    xe2.InnerText = LocalPortNo.Text;
                            }
                        }
                    }
                }
                xmlDoc.Save(filePath + "FNSiCSI.config");
                MessageBox.Show("正常に変更されました");
                this.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("編集に失敗する" + ex);
                throw;
            }
        }

        private void btnConcel_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
