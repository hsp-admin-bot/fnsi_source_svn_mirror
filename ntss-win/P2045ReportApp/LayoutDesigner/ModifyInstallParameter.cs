using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Windows.Forms;
using System.Xml;

namespace LayoutDesigner
{
    public partial class ModifyInstallParameter : Form
    {
        /// <summary>
        /// コンストラクター
        /// </summary>
        public ModifyInstallParameter()
        {
            InitializeComponent();
        }

        /// <summary>
        /// 設定ファイルのパス
        /// </summary>
        string filePath = string.Empty;

        /// <summary>
        /// 元の証明書を使うフラグ
        /// </summary>
        bool orgCer = false;

        /// <summary>
        /// 証明書キー１
        /// </summary>
        string strCer1 = string.Empty;

        /// <summary>
        /// 証明書キー２
        /// </summary>
        string strCer2 = string.Empty;

        /// <summary>
        /// コンストラクター
        /// </summary>
        /// <param name="filepath"></param>
        public ModifyInstallParameter(string filepath)
        {
            filePath = filepath;
            InitializeComponent();
            GetConfig();
        }

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

        /// <summary>
        /// 確認をクリックする
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnConfirm_Click(object sender, EventArgs e)
        {
            try
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(filePath + "ReportLayoutDesigner.config");
                XmlNode xns = xmlDoc.SelectSingleNode("Settings");
                XmlNodeList xml = xns.ChildNodes;
                string[] seperator = new string[] { "//", "&", "/ntss-admin-web/#/?" };
                string[] splits = txtUrl.Text.Split(seperator, StringSplitOptions.RemoveEmptyEntries);

                // 証明書
                if (rbtnUseCer.Checked)
                {
                    if (!orgCer)
                    {
                        strCer1 = "Medical Division";
                        strCer2 = "Nikkiso Co., Ltd.";
                    }
                }
                else
                {
                    strCer1 = string.Empty;
                    strCer2 = string.Empty;
                }
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "CommonSection", "ClientCertificateSearchValue1" }), strCer1);
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "CommonSection", "ClientCertificateSearchValue2" }), strCer2);

                // 施設のハッシュ
                string facilityHash = string.Empty;
                foreach (string split in splits)
                {
                    if (split.Contains("key="))
                    {
                        facilityHash = split.Remove(0, 4);
                    }
                }
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "CommonSection", "FacilityHash" }), facilityHash);

                // ドメイン名
                string domain = string.Empty;
                if (splits.Length >= 2)
                {
                    domain = splits[0] + "//" + splits[1];
                }
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "CommonSection", "BaseUri" }), domain);

                Encoding utf8WithoutBom = new UTF8Encoding(false);
                TextWriter tw = new StreamWriter(filePath + "ReportLayoutDesigner.config", false, utf8WithoutBom);
                xmlDoc.Save(tw);
                MessageBox.Show("正常に変更されました");
                this.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("編集に失敗する" + ex);
                // throw しない: InstallUtil が失敗コードを返すのを防ぐ
            }
        }

        /// <summary>
        /// キャンセルをクリックする
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnConcel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        /// <summary>
        /// 元の設定を読み込む
        /// </summary>
        private void GetConfig()
        {
            try
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(filePath + "ReportLayoutDesigner.config");
                XmlNode xns = xmlDoc.SelectSingleNode("Settings");
                XmlNodeList xnl = xns.ChildNodes;
                string strHash = string.Empty;
                string strDomain = string.Empty;
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
                                if (xe2.Name == "ClientCertificateSearchValue1")
                                    strCer1 = xe2.InnerText;
                                else if (xe2.Name == "ClientCertificateSearchValue2")
                                    strCer2 = xe2.InnerText;
                                else if (xe2.Name == "FacilityHash")
                                    strHash = xe2.InnerText;
                                else if (xe2.Name == "BaseUri")
                                    strDomain = xe2.InnerText;
                            }
                        }
                    }
                }

                if (!string.IsNullOrEmpty(strDomain))
                {
                    txtUrl.Text = string.Format(@"{0}/ntss-admin-web/#/?key={1}", strDomain, strHash);
                }

                if (!string.IsNullOrEmpty(strCer1) || !string.IsNullOrEmpty(strCer2))
                {
                    orgCer = true;
                    rbtnUseCer.Checked = true;
                }
                else
                {
                    rbtnNoCer.Checked = true;
                }
            }
            catch (FileNotFoundException)
            {
                // 新規インストール時はデフォルト値を使用（config はこれから配置される）
                rbtnNoCer.Checked = true;
            }
            catch (Exception ex)
            {
                MessageBox.Show("元の構成情報を取得できませんでした" + ex);
                // throw しない: InstallUtil が失敗コードを返すのを防ぐ
            }
        }
    }
}
