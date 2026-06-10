using Fnw.StatisticsTool;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using System.Xml;
using System.Reflection;

namespace InstallerCustomAction
{
    public partial class ModifyInstallParameter : Form
    {
        /// <summary>
        /// コンストラクター
        /// </summary>
        public ModifyInstallParameter(string configPath)
        {
            InitializeComponent();

            // 設定ファイルを読み込む(ここは他に利用しようないのでそのまま取得を記載)
            XmlDocument doc = new XmlDocument();
            doc.Load(configPath);

            XmlNode settingsNode =
                doc.SelectSingleNode("//configuration/userSettings/Fnw.StatisticsTool.Properties.Settings");

            string baseName =
                settingsNode?.SelectSingleNode("setting[@name='BaseName']/value")?.InnerText ?? "";

            string FacilityHashText = ConfigHelper.ReadSetting("FacilityHash");
            string domain = ConfigHelper.ReadSetting("BaseName");
            if (!string.IsNullOrEmpty(domain))
            {
                txtUrl.Text = string.Format(@"{0}/ntss-admin-web/#/?key={1}", domain, FacilityHashText);
            }
            else
            {
                txtUrl.Text = string.Format(@"{0}/ntss-admin-web/#/?key={1}", baseName, string.Empty);
                ConfigHelper.WriteSetting("BaseName", baseName);
            }
        }

        /// <summary>
        /// OnShown
        /// </summary>
        /// <param name="e"></param>
        protected override void OnShown(EventArgs e)
        {
            BringToFrontEx();
            base.OnShown(e);
            this.TopMost = true;
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
                if (string.IsNullOrEmpty(txtUrl.Text.Trim()))
                {
                    MessageBox.Show(this,"サインインのURLを入力してください");
                }
                else
                {
                    System.Uri uriResult;
                    bool isValidUrl = System.Uri.TryCreate(txtUrl.Text.Trim(), UriKind.Absolute, out uriResult) &&
                                      (uriResult.Scheme == System.Uri.UriSchemeHttp || uriResult.Scheme == System.Uri.UriSchemeHttps);
                    if (!isValidUrl)
                    {
                        MessageBox.Show(this,"無効なURLです。");
                        return;
                    }

                    string url = txtUrl.Text.Trim();
                    string facilityHash = string.Empty;
                    string domain = string.Empty;

                    // 正規表現を使用して、URLのハッシュとドメインを抽出
                    var match = Regex.Match(url, @"^(https?://[^/?#]+)(?:[/?#].*key=([a-zA-Z0-9$./%]+))?");

                    if (match.Success)
                    {
                        // ドメイン部分の抽出
                        domain = match.Groups[1].Value;

                        // ハッシュ部分の抽出（key=の後ろの部分）
                        if (match.Groups[2].Success)
                        {
                            string raw = match.Groups[2].Value;

                            // まずURLデコードを試す（%24 → $, %2F → /, など）
                            string decoded;
                            try
                            {
                                decoded = System.Uri.UnescapeDataString(raw);
                            }
                            catch
                            {
                                decoded = raw; // 失敗したらそのまま判定
                            }

                            // bcryptチェックパターン（全世代対応）
                            Regex bcrypt = new Regex(
                                @"^\$2[abxy]\$\d{2}\$[A-Za-z0-9./]{53}$"
                            );

                            // 長さチェック（bcryptは常に60文字固定）
                            bool isValidBcrypt = decoded.Length == 60 && bcrypt.IsMatch(decoded);

                            if (!isValidBcrypt)
                            {
                                MessageBox.Show("施設ハッシュ値の形式が正しくありません。値を確認してください。");
                                return;
                            }

                            facilityHash = decoded;

                        }
                        else
                        {
                            MessageBox.Show("施設ハッシュ値が見つかりませんでした。値を入力してください。");
                            return;
                        }
                    }
                    else
                    {
                        MessageBox.Show(this,"無効なURL形式です。");
                        return;
                    }

                    ConfigHelper.WriteSetting("FacilityHash", facilityHash);
                    ConfigHelper.WriteSetting("BaseName", domain);
                    ConfigHelper.WriteSetting("FacilityCd", string.Empty);

                    // 登録完了メッセージ
                    MessageBox.Show(this,"正常に登録されました");

                    // フォームを閉じる
                    this.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(this,"編集に失敗しました" + ex);
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
