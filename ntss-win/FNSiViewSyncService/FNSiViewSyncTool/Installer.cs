using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration.Install;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.Xml;
using System.Xml.Linq;
using System.Text;
using FNSiViewSyncLogicLib.Common.Utilities;


namespace FNSiViewSyncTool
{
    [RunInstaller(true)]
    public partial class Installer : System.Configuration.Install.Installer
    {
        public Installer()
        {
            InitializeComponent();
        }

        public override void Install(IDictionary stateSaver)
        {
            base.Install(stateSaver);
        }

        protected override void OnBeforeInstall(IDictionary savedState)
        {
            base.OnBeforeInstall(savedState);

            string targetdir = this.Context.Parameters["targetdir"];
            string installPath = targetdir.Substring(0, targetdir.Length - 1);

            string xmlFileName = @"FNSiViewSync.xml";

            string xmlPath = Path.Combine(installPath, xmlFileName);
            //ReadAllTextを確認
            string text = File.ReadAllText(xmlPath, Encoding.UTF8);
            //暗号化されていない場合
            if (text.Length > 0 && text[0] == '<')
            {
                var xdoc = new XmlDocument();
                using (FileStream fs = new FileStream(xmlPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
                {
                xdoc.Load(fs);
                 }
                CommonUtil.SaveEncrypted(xdoc, xmlPath);
            }

            // ------------------------------------
            // FNSiViewSync.configのマージ
            // ------------------------------------
            string baseFileName = @"FNSiViewSync_Init.config";
            string overFileName = @"FNSiViewSync.config";

            string baseFilePath = Path.Combine(installPath, baseFileName);
            string overFilePath = Path.Combine(installPath, overFileName);

            MergeConfigFile(baseFilePath, overFilePath, overFilePath);

            // ------------------------------------
            // FNSiViewUpdateApp.configのマージ
            // ------------------------------------
            baseFileName = @"FNSiViewUpdateApp\FNSiViewUpdateApp_Init.config";
            overFileName = @"FNSiViewUpdateApp\FNSiViewUpdateApp.config";

            baseFilePath = Path.Combine(installPath, baseFileName);
            overFilePath = Path.Combine(installPath, overFileName);

            MergeConfigFile(baseFilePath, overFilePath, overFilePath);



        }

        protected override void OnAfterInstall(IDictionary savedState)
        {
            base.OnAfterInstall(savedState);

            string previousVersionsInstalled = this.Context.Parameters["previousversionsinstalled"];
            if (string.IsNullOrEmpty(previousVersionsInstalled))
            {
                return;
            }

            string targetdir = this.Context.Parameters["targetdir"];
            string installPath = targetdir.Substring(0, targetdir.Length - 1);
            if (!HasMissingViewSyncXmlAttributeInInstallPath(installPath))
            {
                return;
            }

            ModifyInstallParameterUpdate parameterUpdate = new ModifyInstallParameterUpdate(installPath);
            parameterUpdate.ShowDialog();
        }

        // インストール先のVIEW連携XMLに不足属性があるか判定する
        private bool HasMissingViewSyncXmlAttributeInInstallPath(string installPath)
        {
            string targetXmlFile = Path.Combine(installPath, "FNSiViewSync.xml");
            string onpreXmlFile = Path.Combine(installPath, "FNSiViewSync(オンプレ).xml");
            string cloudXmlFile = Path.Combine(installPath, "FNSiViewSync(クラウド).xml");

            if (!File.Exists(targetXmlFile))
            {
                return false;
            }

            // ユーザーとVIEW連携設定を確認する前のためどちらの差分も確認する
            return HasMissingViewSyncXmlAttributeByTemplate(targetXmlFile, onpreXmlFile)
                || HasMissingViewSyncXmlAttributeByTemplate(targetXmlFile, cloudXmlFile);
        }

        // テンプレートXMLと比較して不足属性があるか判定する
        private bool HasMissingViewSyncXmlAttributeByTemplate(string targetXmlFile, string templateXmlFile)
        {
            if (File.Exists(templateXmlFile) == false)
            {
                return false;
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

            XmlNodeList targetViewList = targetDoc.SelectNodes("//viewList/view");

            // 現行XMLに存在しないテンプレート側の属性があるか確認する
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
                    if (targetView.Attributes[templateAttribute.Name] == null)
                    {
                        return true;
                    }
                }
            }

            return false;
        }

        // VIEW定義の比較キーを取得する
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

        private void MergeConfigFile(string baseFilePath, string overFilePath, string outFilePath)
        {
            // ファイルの読み込み
            XElement baseXml = XElement.Load(baseFilePath);
            XElement overrideXml = XElement.Load(overFilePath);

            MergeElements(baseXml, overrideXml);

            // 結果を保存
            baseXml.Save(outFilePath);
        }

        static void MergeElements(XElement baseElement, XElement overrideElement)
        {
            foreach (var overrideChild in overrideElement.Elements())
            {
                var baseChild = baseElement.Element(overrideChild.Name);

                if (baseChild != null)
                {
                    // 再帰的に子ノードを処理
                    MergeElements(baseChild, overrideChild);
                }
                else
                {
                    // 新しいノードを追加
                    baseElement.Add(new XElement(overrideChild));
                }
            }

            // 属性の上書き
            foreach (var attr in overrideElement.Attributes())
            {
                baseElement.SetAttributeValue(attr.Name, attr.Value);
            }

            // テキストの上書き（子要素がない場合）
            if (!overrideElement.HasElements)
            {
                baseElement.Value = overrideElement.Value;
            }
        }
    }
}
