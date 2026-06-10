using System.Collections.Generic;
using System.IO;
using System.Xml.Serialization;

namespace CoopExtractTool
{

    [XmlRoot("Root")]
    public class Root
    {
        [XmlElement("Include")]
        public Condition Include { get; set; }

        [XmlElement("Exclude")]
        public Condition Exclude { get; set; }

        [XmlArray("PublicValueMappingList")]
        [XmlArrayItem("PublicList")]
        public List<ValueMappingList> PublicValueMappingList { get; set; }
    }

    public class Condition
    {
        public ConditionItem Section { get; set; }

        public ConditionItem Individual { get; set; }
    }

    public class ConditionItem
    {
        [XmlElement("Item")]
        public List<Item> Items { get; set; }
    }

    public class Item
    {
        [XmlElement("INI_SECTION")]
        public string INI_SECTION { get; set; }

        [XmlElement("Key1")]
        public string Key1 { get; set; }

        [XmlElement("INI_KEY")]
        public string INI_KEY { get; set; }

        [XmlElement("Key2")]
        public string Key2 { get; set; }

        [XmlElement("PublicList")]
        public string PublicList { get; set; }

        [XmlElement("LocalList")]
        public List<ValueMappingList> LocalList { get; set; }
    }

    public class ValueMappingList
    {
        [XmlAttribute("name")]
        /// <summary>
        /// SQL DBからデータを抽出する時に使用される
        /// </summary>
        public string Name { get; set; }

        [XmlAttribute("type")]
        public string Type { get; set; } = "0";

        [XmlElement("Value")]
        public List<ValueMappingListItem> ValueList { get; set; }
    }


    public class ValueMappingListItem
    {
        [XmlElement("Before")]
        public string Before { get; set; }

        [XmlElement("After")]
        public string After { get; set; }
    }


    public static class MappingSettingManager
    {
        public static List<string> MappingFileList = new List<string>();


        /// <summary>
        /// データ実体
        /// </summary>
        public static Root Data = new Root();

        /// <summary>
        /// ＸＭＬから設定を読み込む
        /// </summary>
        public static int ReadXML(string filePath)
        {
            if (!File.Exists(filePath))
            {
                // ファイルが存在しない場合
                return Commons.RetCode_Nothing;
            }

            try
            {
                // XmlSerializerオブジェクトを作成
                System.Xml.Serialization.XmlSerializer serializer =
                    new System.Xml.Serialization.XmlSerializer(typeof(Root));
                // 読み込むファイルを開く
                System.IO.StreamReader sr = new System.IO.StreamReader(
                    filePath, new System.Text.UTF8Encoding(false));
                // XMLファイルから読み込み、逆シリアル化する
                Data = (Root)serializer.Deserialize(sr);
                // ファイルを閉じる
                sr.Close();
            }
            catch
            {
                return Commons.RetCode_Error;
            }

            return Commons.RetCode_Success;
        }

    }
}
