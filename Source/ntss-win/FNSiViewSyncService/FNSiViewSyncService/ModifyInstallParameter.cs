using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Windows.Forms;
using System.Xml;
using FNSiViewSyncLogicLib.Common.Utilities;

namespace FNSiViewSyncService
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
                xmlDoc.Load(filePath + "FNSiViewSync.config");
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
                                if (xe2.Name == "ConnectionString")
                                {
                                    if (xe2.InnerText != null && xe2.InnerText != "")
                                    {
                                        for (int i = 0; i < xe2.InnerText.Split(';').Length -1; i++)
                                        {
                                            if(xe2.InnerText.Split(';')[i].Substring(0,3)== "Dsn")
                                                Dsn.Text = xe2.InnerText.Split(';')[i].Trim().Remove(0, 4);
                                            else if(xe2.InnerText.Split(';')[i].Substring(0, 3) == "Dat")
                                                DataBase.Text = xe2.InnerText.Split(';')[i].Trim().Remove(0, 9);
                                            else if(xe2.InnerText.Split(';')[i].Substring(0, 3) == "Uid")
                                                Uid.Text = xe2.InnerText.Split(';')[i].Trim().Remove(0, 4);
                                            else if(xe2.InnerText.Split(';')[i].Substring(0, 3) == "Pwd")
                                                Pwd.Text = xe2.InnerText.Split(';')[i].Trim().Remove(0, 4);
                                        }
                                    }
                                }
                                else if (xe2.Name == "DataFolder")
                                    DataFolder.Text = xe2.InnerText;
                                else if (xe2.Name == "DataKeepNumberOfDays")
                                    DataKeepNumberOfDays.Text = xe2.InnerText;
                                else if (xe2.Name == "ViewSyncCnt")
                                    ViewSyncCnt.Text = xe2.InnerText;
                                else if (xe2.Name == "IFEdgeIPAddress")
                                    IFEdgeIPAddress.Text = xe2.InnerText;
                                else if (xe2.Name == "IFEdgePortNo")
                                    IFEdgePortNo.Text = xe2.InnerText;

                                else if (xe2.Name == "LocalIPAddress")
                                {
                                    List<string> ipList = new List<string>();
                                    string ip = xe2.InnerText;
                                    ipList.Add(ip);

                                    IPHostEntry IpEntry = Dns.GetHostEntry(Dns.GetHostName());
                                    for (int i = 0; i < IpEntry.AddressList.Length; i++)
                                    {
                                        if (IpEntry.AddressList[i].AddressFamily == AddressFamily.InterNetwork)
                                        {
                                            string wkip = IpEntry.AddressList[i].ToString();
                                            if (ipList.Contains(wkip) == false)
                                            {
                                                // リスト内に存在しないIPアドレスならリストに追加
                                                ipList.Add(wkip);
                                                if (string.IsNullOrEmpty(ip) == true)
                                                {
                                                    ip = wkip;
                                                }
                                            }
                                        }
                                    }
                                    LocalIPAddress.DataSource = ipList;
                                    LocalIPAddress.DisplayMember = ip;
                                }
                                else if (xe2.Name == "LocalPortNo")
                                    LocalPortNo.Text = xe2.InnerText;
                                else if (xe2.Name == "ReSyncPortNo")
                                    LocalManualPortNo.Text = xe2.InnerText;
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
                                else if (xe2.Name == "ViewSyncDay")
                                    ViewSyncDay.Text = xe2.InnerText;
                                else if (xe2.Name == "ViewSyncTimeSpan")
                                    ViewSyncTimeSpan.Text = xe2.InnerText;
                                else if (xe2.Name == "InitialUpdatedDate")
                                {
                                    if (String.IsNullOrEmpty(xe2.InnerText))
                                    {
                                        // 19700101000000
                                        InitialUpdatedDate.Value = DateTime.ParseExact("19700101000000", "yyyyMMddHHmmss", System.Globalization.CultureInfo.CurrentCulture);
                                    }
                                    else
                                    {
                                        InitialUpdatedDate.Value = DateTime.ParseExact(xe2.InnerText, "yyyyMMddHHmmss", System.Globalization.CultureInfo.CurrentCulture);
                                    }
                                }
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

        private void btnConcel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            try
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(filePath + "FNSiViewSync.config");
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
                                if (xe2.Name == "ConnectionString")
                                {
                                    string con = "Dsn=" + Dsn.Text.Trim() + ";DataBase=" + DataBase.Text.Trim() + ";Uid=" + Uid.Text.Trim() + ";Pwd=" + Pwd.Text.Trim() + ";";
                                    xe2.InnerText = con;
                                }
                                else if (xe2.Name == "DataFolder")
                                    xe2.InnerText = DataFolder.Text;
                                else if (xe2.Name == "DataKeepNumberOfDays")
                                    xe2.InnerText = DataKeepNumberOfDays.Text;
                                else if (xe2.Name == "ViewSyncCnt")
                                    xe2.InnerText = ViewSyncCnt.Text;
                                else if (xe2.Name == "IFEdgeIPAddress")
                                    xe2.InnerText = IFEdgeIPAddress.Text;
                                else if (xe2.Name == "IFEdgePortNo")
                                    xe2.InnerText = IFEdgePortNo.Text;
                                else if (xe2.Name == "LocalIPAddress")
                                    xe2.InnerText = LocalIPAddress.Text;
                                else if (xe2.Name == "LocalPortNo")
                                    xe2.InnerText = LocalPortNo.Text;
                                else if (xe2.Name == "ReSyncPortNo")
                                    xe2.InnerText = LocalManualPortNo.Text;
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
                                else if (xe2.Name == "ViewSyncDay")
                                    xe2.InnerText = ViewSyncDay.Text;
                                else if (xe2.Name == "InitialUpdatedDate")
                                {
                                    // 19700101000000
                                    if (InitialUpdatedDate.Value == null)
                                    {
                                        xe2.InnerText = "19700101000000";
                                    }
                                    else
                                    {
                                        xe2.InnerText = string.Format("{0:yyyyMMddHHmmss}", InitialUpdatedDate.Value);
                                    }
                                }
                                else if (xe2.Name == "ViewSyncTimeSpan")
                                {
                                    if (int.Parse(ViewSyncTimeSpan.Text) < 300)
                                    {
                                        MessageBox.Show("更新間隔（秒）300秒以上の値を入力してください");
                                        return;
                                    }
                                    xe2.InnerText = ViewSyncTimeSpan.Text;
                                }
                            }
                        }
                    }
                }
                Encoding utf8WithoutBom = new UTF8Encoding(false);
                // mod #12110 アプリインストール時のサービス起動処理でエラーが発生し正常起動できない 高 start
                //TextWriter tw = new StreamWriter(filePath + "FNSiViewSync.config", false, utf8WithoutBom);
                using (TextWriter tw = new StreamWriter(filePath + "FNSiViewSync.config", false, utf8WithoutBom))
                {
                    xmlDoc.Save(tw);
                }
                // mod #12110 アプリインストール時のサービス起動処理でエラーが発生し正常起動できない 高 end
            }
            catch (Exception ex)
            {
                MessageBox.Show("編集に失敗する" + ex);
                throw;
            }


            try
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(filePath + "FNSiViewUpdateApp.config");
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
                                if (xe2.Name == "ReSyncIPAddress")
                                    xe2.InnerText = LocalIPAddress.Text;
                                else if (xe2.Name == "ReSyncPortNo")
                                    xe2.InnerText = LocalManualPortNo.Text;                            }
                        }
                    }
                }
                Encoding utf8WithoutBom = new UTF8Encoding(false);
                // mod #12110 アプリインストール時のサービス起動処理でエラーが発生し正常起動できない 高 start
                //TextWriter tw = new StreamWriter(filePath + "FNSiViewUpdateApp.config", false, utf8WithoutBom);
                using (TextWriter tw = new StreamWriter(filePath + "FNSiViewUpdateApp.config", false, utf8WithoutBom))
                {
                    xmlDoc.Save(tw);
                }
                // mod #12110 アプリインストール時のサービス起動処理でエラーが発生し正常起動できない 高 end
            }
            catch (Exception ex)
            {
                MessageBox.Show("編集に失敗する" + ex);
                throw;
            }


            try
            {
                string srcFileName = "";
                string dstFileName = "FNSiViewSync.xml";
                string srcFilePath = "";
                string dstFilePath = "";

                if (ViewSettingOnpre.Checked == true)
                {
                    // オンプレ版の場合
                    srcFileName = "FNSiViewSync(オンプレ).xml";
                }
                else
                {
                    // クラウド版の場合
                    srcFileName = "FNSiViewSync(クラウド).xml";
                }

                srcFilePath = Path.Combine(filePath, srcFileName);
                dstFilePath = Path.Combine(filePath, dstFileName);

                // ファイルをコピーし、上書きを許可
                File.Copy(srcFilePath, dstFilePath, true);

                XmlDocument xdoc = CommonUtil.LoadDecryptedXml(dstFilePath);
                CommonUtil.SaveEncrypted(xdoc, dstFilePath);

            }
            catch (Exception ex)
            {
                MessageBox.Show("編集に失敗する" + ex);
                throw;
            }

            MessageBox.Show("正常に変更されました");
            this.Close();
        }
    }
}
