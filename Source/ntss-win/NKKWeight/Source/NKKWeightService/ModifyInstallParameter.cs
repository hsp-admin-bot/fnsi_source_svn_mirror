using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Windows.Forms;
using System.Xml;

namespace NKKWeightService
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
            dtUpdateTime.Value = DateTime.ParseExact("02:00", "HH:mm", null);
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
                xmlDoc.Load(filePath + "NKKWeight.config");
                XmlNode xns = xmlDoc.SelectSingleNode("Settings");
                XmlNodeList xml = xns.ChildNodes;
                string[] seperator = new string[] { "//", "&", "/ntss-admin-web/#/?" };
                string[] splits = txtUrl.Text.Split(seperator, StringSplitOptions.RemoveEmptyEntries);

                // アプリ番号
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "Weight", "WeightNo" }), txtWeightNo.Text);

                // バージョンアップ時刻
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "Weight", "UpdateTime" }),
                    string.Format("{0:D2}:{1:D2}", dtUpdateTime.Value.Hour, dtUpdateTime.Value.Minute));

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
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "Common", "ClientCertificateSearchValue1" }), strCer1);
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "Common", "ClientCertificateSearchValue2" }), strCer2);

                // 施設のハッシュ
                string facilityHash = string.Empty;
                foreach (string split in splits)
                {
                    if (split.Contains("key="))
                    {
                        facilityHash = split.Remove(0, 4);
                    }
                }
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "Common", "FacilityHash" }), facilityHash);

                // ドメイン名
                string domain = string.Empty;
                // WebSocket設定 - 接続先
                string webSocketUri = string.Empty;
                if (splits.Length >= 2)
                {
                    if (splits[1].Contains("nksfn.com"))
                    {
                        domain = $"https://{splits[1]}";
                        if (splits[1].Contains("vpn"))
                        {
                            webSocketUri = "wss://fnwsi-vpn-aline.nksfn.com/ntss-client-comm/ntssclientcomm";
                        }
                        else
                        {
                            webSocketUri = "wss://fnwsi-aline.nksfn.com/ntss-client-comm/ntssclientcomm";
                        }
                    }
                    else
                    {
                        domain = $"http://{splits[1]}";

                        string s1 = splits[1];
                        if (s1.Contains(":"))
                        {
                            s1 = splits[1].Split(':')[0];
                        }
                        webSocketUri = $"ws://{s1}:8090/ntss-client-comm/ntssclientcomm";
                    } 
                }
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "Common", "BaseUri" }), domain);
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "WebSocket", "URI" }), webSocketUri);

                Encoding utf8WithoutBom = new UTF8Encoding(false);
                // mod #12110 アプリインストール時のサービス起動処理でエラーが発生し正常起動できない 高 start
                using (TextWriter tw = new StreamWriter(filePath + "NKKWeight.config", false, utf8WithoutBom))
                {
                    xmlDoc.Save(tw);
                }
                // mod #12110 アプリインストール時のサービス起動処理でエラーが発生し正常起動できない 高 end
                MessageBox.Show("正常に変更されました");
                this.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("編集に失敗する" + ex);
                throw;
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
                xmlDoc.Load(filePath + "NKKWeight.config");
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
                                if (xe2.Name == "WeightNo")
                                    txtWeightNo.Text = xe2.InnerText;
                                else if (xe2.Name == "ClientCertificateSearchValue1")
                                    strCer1 = xe2.InnerText;
                                else if (xe2.Name == "ClientCertificateSearchValue2")
                                    strCer2 = xe2.InnerText;
                                else if (xe2.Name == "FacilityHash")
                                    strHash = xe2.InnerText;
                                else if (xe2.Name == "BaseUri")
                                    strDomain = xe2.InnerText;
                                else if (xe2.Name == "UpdateTime")
                                    dtUpdateTime.Value = DateTime.ParseExact(xe2.InnerText, "HH:mm", null);
                            }
                        }
                    }
                }

                if(!string.IsNullOrEmpty(strDomain))
                {
                    txtUrl.Text = string.Format(@"{0}/ntss-admin-web/#/?key={1}", strDomain, strHash);
                }

                if(!string.IsNullOrEmpty(strCer1) || !string.IsNullOrEmpty(strCer2))
                {
                    orgCer = true;
                    rbtnUseCer.Checked = true;
                }
                else
                {
                    rbtnNoCer.Checked = true;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("元の構成情報を取得できませんでした" + ex);
                throw;
            }
        }
    }
}
