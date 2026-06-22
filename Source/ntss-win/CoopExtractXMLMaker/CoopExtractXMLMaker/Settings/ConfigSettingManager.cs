using System;
using System.IO;
using System.Xml.Serialization;

namespace CoopExtractXMLMaker
{
    public enum ConversionDefinitionType
    {
        FromDefinition, // デフォルト定義ファイルからXMLを新規作成
        XMLReedit,   // XMLを再編集
        OverwriteDefaultDefinition,  // デフォルト変換定義を修正
    }

    [XmlRoot("Settings")]
    public class Settings
    {
        /// <summary>
        /// 自動マッピング
        /// </summary>
        public bool AutoMapping { get; set; } = true;

        /// <summary>
        /// 変換定義
        /// </summary>
        public ConversionDefinitionType ConversionDefinition { get; set; } = ConversionDefinitionType.FromDefinition;

        /// <summary>
        /// XMLを再編集するファイルパス
        /// </summary>
        public string XMLReeditFilePath = "";
    }

    class ConfigSettingManager
    {
        /// <summary>
        /// データ実体
        /// </summary>
        public static Settings Data = new Settings();
    }
}
