using System;
using System.Collections.Generic;
using System.IO;
using System.Windows.Forms;
using System.Xml;
using FNSiViewSyncLogicLib.Common.Utilities;

namespace FNSiViewSyncTool
{
    public partial class ModifyInstallParameterUpdate : Form
    {
        private string filePath;

        public ModifyInstallParameterUpdate()
        {
            InitializeComponent();
        }

        public ModifyInstallParameterUpdate(string filepath)
        {
            filePath = filepath;
            InitializeComponent();
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

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            try
            {
                UpdateViewSyncXmlIfNeeded();
                DialogResult = DialogResult.OK;
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("編集に失敗する" + ex);
            }
        }

        /// <summary>
        /// 選択された構成のXMLから不足属性を追加する
        /// </summary>
        private void UpdateViewSyncXmlIfNeeded()
        {
            string templateXmlFileName = ViewSettingOnpre.Checked ? "FNSiViewSync(オンプレ).xml" : "FNSiViewSync(クラウド).xml";
            string templateXmlFile = Path.Combine(filePath, templateXmlFileName);
            string targetXmlFile = Path.Combine(filePath, "FNSiViewSync.xml");            

            if (File.Exists(targetXmlFile) == false || File.Exists(templateXmlFile) == false)
            {
                return;
            }

            XmlDocument targetDoc = CommonUtil.LoadDecryptedXml(targetXmlFile);
            XmlDocument templateDoc = CommonUtil.LoadDecryptedXml(templateXmlFile);

            Dictionary<string, XmlNode> templateViewMap = new Dictionary<string, XmlNode>();
            XmlNodeList templateViewList = templateDoc.SelectNodes("//viewList/view");

            // テンプレートXMLをkey_nameで検索できるようにする
            foreach (XmlNode templateView in templateViewList)
            {
                string viewKey = GetViewXmlCompareKey(templateView);
                if (string.IsNullOrEmpty(viewKey) || templateViewMap.ContainsKey(viewKey))
                {
                    continue;
                }

                templateViewMap.Add(viewKey, templateView);
            }

            bool isUpdated = false;
            XmlNodeList targetViewList = targetDoc.SelectNodes("//viewList/view");

            // 現行XMLに存在しないテンプレート側の属性を追加する
            foreach (XmlNode targetView in targetViewList)
            {
                string viewKey = GetViewXmlCompareKey(targetView);
                if (string.IsNullOrEmpty(viewKey) || templateViewMap.ContainsKey(viewKey) == false)
                {
                    continue;
                }

                XmlNode templateView = templateViewMap[viewKey];
                foreach (XmlAttribute templateAttribute in templateView.Attributes)
                {
                    if (targetView.Attributes[templateAttribute.Name] != null)
                    {
                        continue;
                    }

                    XmlAttribute targetAttribute = targetDoc.CreateAttribute(templateAttribute.Name);
                    targetAttribute.Value = templateAttribute.Value;
                    targetView.Attributes.Append(targetAttribute);
                    isUpdated = true;
                }
            }

            if (isUpdated)
            {
                CommonUtil.SaveEncrypted(targetDoc, targetXmlFile);
            }
        }

        /// <summary>
        /// VIEW定義の比較キーを取得する
        /// </summary>
        private string GetViewXmlCompareKey(XmlNode viewNode)
        {
            if (viewNode == null || viewNode.Attributes == null)
            {
                return string.Empty;
            }

            XmlAttribute keyNameAttribute = viewNode.Attributes["key_name"];
            if (keyNameAttribute != null && string.IsNullOrEmpty(keyNameAttribute.Value) == false)
            {
                return keyNameAttribute.Value.Trim();
            }

            return string.Empty;
        }
    }
}
