using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml;

namespace Fnw.StatisticsTool
{
    public class ConfigHelper
    {
        // 設定ファイルのパス
        private static string userConfigPath = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData) + @"\Fnw.StatisticsTool\user.config";

        // 設定の読み込み
        public static string ReadSetting(string settingName)
        {
            // 設定ファイルが存在しない場合は空文字を返す
            if (!File.Exists(userConfigPath))
            {
                return string.Empty;
            }

            XmlDocument doc = new XmlDocument();
            doc.Load(userConfigPath);

            // 設定値を取得
            XmlNode settingsNode = doc.SelectSingleNode("//configuration/userSettings/Fnw.StatisticsTool.Properties.Settings");
            XmlNode settingNode = settingsNode.SelectSingleNode($"setting[@name='{settingName}']");

            return settingNode?.SelectSingleNode("value")?.InnerText ?? string.Empty; // 設定がない場合は空文字を返す
        }

        // 設定の書き込み
        public static void WriteSetting(string settingName, string value)
        {
            // フォルダが存在しない場合は作成
            string directoryPath = Path.GetDirectoryName(userConfigPath);
            if (!Directory.Exists(directoryPath))
            {
                Directory.CreateDirectory(directoryPath);
            }

            // 設定ファイルが存在しない場合は新規作成
            XmlDocument doc = new XmlDocument();
            if (File.Exists(userConfigPath))
            {
                doc.Load(userConfigPath);
            }
            else
            {
                // 新しいXML構造を作成
                XmlDeclaration xmlDecl = doc.CreateXmlDeclaration("1.0", "utf-8", null);
                doc.AppendChild(xmlDecl);
                XmlElement root = doc.CreateElement("configuration");
                doc.AppendChild(root);
                XmlElement userSettings = doc.CreateElement("userSettings");
                root.AppendChild(userSettings);
                XmlElement appSettings = doc.CreateElement("Fnw.StatisticsTool.Properties.Settings");
                userSettings.AppendChild(appSettings);
            }

            // 設定を変更
            XmlNode settingsNode = doc.SelectSingleNode("//configuration/userSettings/Fnw.StatisticsTool.Properties.Settings");
            XmlNode settingNode = settingsNode.SelectSingleNode($"setting[@name='{settingName}']");

            if (settingNode != null)
            {
                settingNode.SelectSingleNode("value").InnerText = value; // 設定値を変更
            }
            else
            {
                // 設定が存在しない場合、新しい設定を追加
                XmlElement newSettingNode = doc.CreateElement("setting");
                newSettingNode.SetAttribute("name", settingName);
                newSettingNode.SetAttribute("serializeAs", "String");

                XmlNode valueNode = doc.CreateElement("value");
                valueNode.InnerText = value;
                newSettingNode.AppendChild(valueNode);

                settingsNode.AppendChild(newSettingNode);
            }

            // 保存
            doc.Save(userConfigPath);
        }
    }
}
