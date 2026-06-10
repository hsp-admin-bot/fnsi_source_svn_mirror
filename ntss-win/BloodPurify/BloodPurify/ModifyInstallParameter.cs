using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Windows.Forms;
using System.Xml;

namespace NKK.BloodPurify
{
    public partial class ModifyInstallParameter : Form
    {
        /// <summary>
        /// コンストラクター
        /// </summary>
        public ModifyInstallParameter()
        {
            InitializeComponent();
            GetConfig();
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
            filePath = filepath.TrimEnd(System.IO.Path.DirectorySeparatorChar, System.IO.Path.AltDirectorySeparatorChar) + System.IO.Path.DirectorySeparatorChar;
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
        /// 元の設定を読み込む
        /// </summary>
        public void GetConfig()
        {
            try
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(filePath + "BloodPurify.config");
                XmlNode xns = xmlDoc.SelectSingleNode("Settings");
                XmlNodeList xnl = xns.ChildNodes;
                string strHash = string.Empty;
                string strDomain = string.Empty;
                foreach (XmlNode xn in xnl)
                {
                    if (xn.NodeType == XmlNodeType.Element)
                    {
                        XmlElement xe = (XmlElement)xn;
                        if (xe.Name == "ClientCertificateSearchValue1")
                            strCer1 = xe.InnerText;
                        else if (xe.Name == "ClientCertificateSearchValue2")
                            strCer2 = xe.InnerText;
                        else if (xe.Name == "FacilityHash")
                            strHash = xe.InnerText;
                        else if (xe.Name == "BaseUri")
                            strDomain = xe.InnerText;
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
            catch (Exception ex)
            {
                MessageBox.Show("元の構成情報を取得できませんでした" + ex);
                throw;
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
                xmlDoc.Load(filePath + "BloodPurify.config");
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
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "ClientCertificateSearchValue1" }), strCer1);
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "ClientCertificateSearchValue2" }), strCer2);

                // 施設のハッシュ
                string facilityHash = string.Empty;
                foreach (string split in splits)
                {
                    if (split.Contains("key="))
                    {
                        facilityHash = split.Remove(0, 4);
                    }
                }
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "FacilityHash" }), facilityHash);

                // ドメイン名
                string domain = string.Empty;
                if (splits.Length >= 2)
                {
                    domain = splits[0] + "//" + splits[1];
                }
                TdcLib.TdcLib.SetXmlTagWithPath(ref xns, new Queue<string>(new[] { "BaseUri" }), domain);

                Encoding utf8WithoutBom = new UTF8Encoding(false);
                // mod #12110 アプリインストール時のサービス起動処理でエラーが発生し正常起動できない 高 start
                //TextWriter tw = new StreamWriter(filePath + "BloodPurify.config", false, utf8WithoutBom);
                using (TextWriter tw = new StreamWriter(filePath + "BloodPurify.config", false, utf8WithoutBom))
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
    }
}
