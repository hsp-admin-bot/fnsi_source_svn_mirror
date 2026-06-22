using System.Collections.Generic;
using System.IO;
using System.Xml.Serialization;
using System;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace CoopExtractXMLMaker
{

    [XmlRoot("Root")]
    public class Root
    {
        /// <summary>
        /// 変換設定
        /// </summary>
        [XmlElement("Include")]
        public Condition Include { get; set; }

        /// <summary>
        /// 除外設定
        /// </summary>
        [XmlElement("Exclude")]
        public Condition Exclude { get; set; }

        /// <summary>
        /// 共通値変換設定
        /// </summary>
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

        public Item Clone()
        {
            return new Item
            {
                INI_SECTION = this.INI_SECTION,
                Key1 = this.Key1,
                INI_KEY = this.INI_KEY,
                Key2 = this.Key2,
                PublicList = this.PublicList,
                LocalList = this.LocalList != null ? this.LocalList.Select(x => x.Clone()).ToList() : null,
            };
        }
    }

    public class ValueMappingList
    {
        [XmlAttribute("name")]
        public string Name { get; set; }

        [XmlAttribute("type")]
        public string Type { get; set; } = "0";

        [XmlElement("Value")]
        public List<ValueMappingListItem> ValueList { get; set; }

        public ValueMappingList Clone() 
        { 
            return new ValueMappingList 
            { Name = this.Name,
                Type = this.Type,
                ValueList = this.ValueList != null ? this.ValueList.Select(x => x.Clone()).ToList() : null,
            }; 
        }
    }

    public class ValueMappingListItem
    {
        [XmlElement("Before")]
        public string Before { get; set; }

        [XmlElement("After")]
        public string After { get; set; }

        public ValueMappingListItem Clone()
        {
            return new ValueMappingListItem
            {
                Before = this.Before,
                After = this.After,
            };
        }
    }


    public static class MappingSettingManager
    {
        /// <summary>
        /// データ実体
        /// </summary>
        public static Root Data = new Root();

        /// <summary>
        /// データ実体(読み込みXML用)
        /// </summary>
        public static Root DataRead = new Root();

        /// <summary>
        /// データ実体の取得先指定用
        /// </summary>
        /// <param name="isDataRead"></param>
        /// <returns></returns>
        private static ref Root GetTargetRef(bool isDataRead)
        {
            if (isDataRead == true)
            {
                return ref DataRead;
            }
            else
            {
                return ref Data;
            }
        }

        /// <summary>
        /// XMLから設定を読み込む
        /// </summary>
        public static int ReadXML(string filePath, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (!File.Exists(filePath))
            {
                // ファイルが存在しない場合
                return Commons.RetCode_Nothing;
            }

            var fileInfo = new System.IO.FileInfo(filePath);
            if (fileInfo.Length == 0)
            {
                // ファイルの中身が無い場合
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
                data = (Root)serializer.Deserialize(sr);
                // ファイルを閉じる
                sr.Close();
            }
            catch
            {
                return Commons.RetCode_Error;
            }

            return Commons.RetCode_Success;
        }

        /// <summary>
        /// 設定をXMLに書き込む
        /// </summary>
        /// <param name="filePath"></param>
        /// <param name="isDataRead"></param>
        /// <returns></returns>
        public static int WriteXML(string filePath, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            try
            {
                // XmlSerializerオブジェクトを作成（型は Root）
                var serializer = new System.Xml.Serialization.XmlSerializer(typeof(Root));

                // 書き込み用のStreamWriterを作成（UTF-8 BOMなし）
                using (var sw = new System.IO.StreamWriter(filePath, false, new System.Text.UTF8Encoding(false)))
                {
                    // Data を XML にシリアル化して書き出す
                    serializer.Serialize(sw, data);
                }
            }
            catch
            {
                return Commons.RetCode_Error;
            }

            return Commons.RetCode_Success;
        }

        /// <summary>
        /// データ実体を初期化
        /// </summary>
        /// <param name="isDataRead"></param>
        public static void Initialization(bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);
            data = new Root();
        }

        /// <summary>
        /// Section（key1）変換設定を追加する
        /// </summary>
        /// <param name="item"></param>
        /// <param name="isDataRead"></param>
        public static void AddSectionItem(Item item, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (data.Include == null)
            {
                data.Include = new Condition();
            }
            if (data.Include.Section == null)
            {
                data.Include.Section = new ConditionItem();
            }
            if (data.Include.Section.Items == null)
            {
                data.Include.Section.Items = new List<Item>();
            }

            data.Include.Section.Items.Add(item);
        }

        /// <summary>
        /// Individual（key1+key2）変換設定を追加する
        /// </summary>
        /// <param name="item"></param>
        /// <param name="isDataRead"></param>
        public static void AddIndividualItem(Item item, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (data.Include == null)
            {
                data.Include = new Condition();
            }
            if (data.Include.Individual == null)
            {
                data.Include.Individual = new ConditionItem();
            }
            if (data.Include.Individual.Items == null)
            {
                data.Include.Individual.Items = new List<Item>();
            }

            data.Include.Individual.Items.Add(item);
        }

        /// <summary>
        /// Section（key1）変換設定を取得する
        /// </summary>
        /// <param name="INI_SECTION"></param>
        /// <param name="isDataRead"></param>
        /// <returns></returns>
        public static Item GetSectionItem(string INI_SECTION, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (data.Include == null || data.Include.Section == null || data.Include.Section.Items == null)
            {
                return null;
            }

            Item ret = data.Include.Section.Items.Find(d => d.INI_SECTION == INI_SECTION);

            return ret;
        }

        /// <summary>
        /// Section（key1）変換設定を取得する(key1から取得)
        /// </summary>
        /// <param name="key1"></param>
        /// <param name="isDataRead"></param>
        /// <returns></returns>
        public static Item GetSectionItem_FNSi(string key1, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (data.Include == null || data.Include.Section == null || data.Include.Section.Items == null)
            {
                return null;
            }

            Item ret = data.Include.Section.Items.Find(d => d.Key1 == key1);

            return ret;
        }

        /// <summary>
        /// Individual（key1+key2）変換設定を取得する
        /// </summary>
        /// <param name="INI_SECTION"></param>
        /// <param name="INI_KEY"></param>
        /// <param name="isDataRead"></param>
        /// <returns></returns>
        public static Item GetIndividualItem(string INI_SECTION, string INI_KEY, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (data.Include == null || data.Include.Individual == null || data.Include.Individual.Items == null)
            {
                return null;
            }

            Item ret = data.Include.Individual.Items.Find(d => d.INI_SECTION == INI_SECTION && d.INI_KEY == INI_KEY);

            return ret;
        }

        /// <summary>
        /// Individual（key1+key2）変換設定を取得する(key1とkey2から取得)
        /// </summary>
        /// <param name="key1"></param>
        /// <param name="key2"></param>
        /// <param name="isDataRead"></param>
        /// <returns></returns>
        public static Item GetIndividualItem_FNSi(string key1, string key2, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (data.Include == null || data.Include.Individual == null || data.Include.Individual.Items == null)
            {
                return null;
            }

            Item ret = data.Include.Individual.Items.Find(d => d.Key1 == key1 && d.Key2 == key2);

            return ret;
        }

        /// <summary>
        /// Section（key1）変換設定を削除する
        /// </summary>
        /// <param name="INI_SECTION"></param>
        /// <param name="isDataRead"></param>
        public static void DeleteSectionItem(string INI_SECTION, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (data.Include == null || data.Include.Section == null || data.Include.Section.Items == null)
            {
                return;
            }

            data.Include.Section.Items.RemoveAll(d => d.INI_SECTION == INI_SECTION);

            return;
        }

        /// <summary>
        /// Individual（key1+key2）変換設定を削除する
        /// </summary>
        /// <param name="INI_SECTION"></param>
        /// <param name="INI_KEY"></param>
        /// <param name="isDataRead"></param>
        public static void DeletIndividualItem(string INI_SECTION, string INI_KEY, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (data.Include == null || data.Include.Individual == null || data.Include.Individual.Items == null)
            {
                return;
            }

            data.Include.Individual.Items.RemoveAll(d => d.INI_SECTION == INI_SECTION && d.INI_KEY == INI_KEY);

            return;
        }

        /// <summary>
        /// 指定したNameが共通値変換設定で使用されているかチェックする
        /// </summary>
        /// <param name="name"></param>
        /// <param name="isDataRead"></param>
        /// <returns></returns>
        public static bool CheckPublicListUse(string name, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (data.Include != null && data.Include.Individual != null && data.Include.Individual.Items != null)
            {
                if (data.Include.Individual.Items.Exists(d => d.PublicList == name) == true)
                {
                    // 指定されたNameを使用している共通値変換設定を発見
                    return true;
                }
            }

            if (data.Include != null && data.Include.Section != null && data.Include.Section.Items != null)
            {
                if (data.Include.Section.Items.Exists(d => d.PublicList == name) == true)
                {
                    // 指定されたNameを使用している共通値変換設定を発見
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// 共通値変換設定を指定された変換設定名で置き換える（NULL指定は削除になる）
        /// </summary>
        /// <param name="name"></param>
        /// <param name="rename"></param>
        /// <param name="isDataRead"></param>
        public static void UpdaePublicList(string name, string rename, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (data.Include != null && data.Include.Individual != null && data.Include.Individual.Items != null)
            {
                for (int i = 0; i < data.Include.Individual.Items.Count; i++)
                {
                    if(data.Include.Individual.Items[i].PublicList== name)
                    {
                        data.Include.Individual.Items[i].PublicList = rename;
                    }
                }
            }

            if (data.Include != null && data.Include.Section != null && data.Include.Section.Items != null)
            {
                for (int i = 0; i < data.Include.Section.Items.Count; i++)
                {
                    if (data.Include.Section.Items[i].PublicList == name)
                    {
                        data.Include.Section.Items[i].PublicList = rename;
                    }
                }
            }
        }

        /// <summary>
        /// 除外設定を初期化する
        /// </summary>
        /// <param name="isDataRead"></param>
        public static void InitializationExclude(bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);
            data.Exclude = null;
        }

        /// <summary>
        /// Individual（key1+key2）除外設定を追加する
        /// </summary>
        /// <param name="item"></param>
        /// <param name="isDataRead"></param>
        public static void AddExcludeIndividualItem(Item item, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (data.Exclude == null)
            {
                data.Exclude = new Condition();
            }
            if (data.Exclude.Individual == null)
            {
                data.Exclude.Individual = new ConditionItem();
            }
            if (data.Exclude.Individual.Items == null)
            {
                data.Exclude.Individual.Items = new List<Item>();
            }

            data.Exclude.Individual.Items.Add(item);
        }

        /// <summary>
        /// Individual（key1+key2）除外設定を取得する
        /// </summary>
        /// <param name="INI_SECTION"></param>
        /// <param name="INI_KEY"></param>
        /// <param name="isDataRead"></param>
        /// <returns></returns>
        public static Item GetExcludeIndividualItem(string INI_SECTION, string INI_KEY, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (data.Exclude == null || data.Exclude.Individual == null || data.Exclude.Individual.Items == null)
            {
                return null;
            }

            Item ret = data.Exclude.Individual.Items.Find(d => d.INI_SECTION == INI_SECTION && d.INI_KEY == INI_KEY);

            return ret;
        }

        /// <summary>
        /// 共通値変換設定を取得する
        /// </summary>
        /// <param name="isDataRead"></param>
        /// <returns></returns>
        public static List<ValueMappingList> GetPublicValueMappingList(bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            return data.PublicValueMappingList;
        }

        /// <summary>
        /// 共通値変換設定をセットする
        /// </summary>
        /// <param name="list"></param>
        /// <param name="isDataRead"></param>
        public static void SetPublicValueMappingList(List<ValueMappingList> list, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (list == null || list.Count == 0)
            {
                data.PublicValueMappingList = null;
                return;
            }

            if (data.PublicValueMappingList == null)
            {
                data.PublicValueMappingList = new List<ValueMappingList>();
            }
            else
            {
                data.PublicValueMappingList.Clear();
            }

            foreach (var item in list)
            {
                if (string.IsNullOrEmpty(item.Name) == false)
                {
                    data.PublicValueMappingList.Add(item);
                }
            }           

            return ;
        }

        /// <summary>
        /// Key1とKwy2にINI_SECTIONとINI_KEYから値をコピーするか同じならNULLをセットする
        /// </summary>
        public static void SetKeyNull(bool isNullSet, bool isDataRead = false)
        {
            ref Root data = ref GetTargetRef(isDataRead);

            if (data.Include != null)
            {
                if (data.Include.Section != null)
                {
                    SetKeyList(data.Include.Section.Items, isNullSet);
                }

                if (data.Include.Individual != null)
                {
                    SetKeyList(data.Include.Individual.Items, isNullSet);
                }
            }
        }

        /// <summary>
        /// リストでKey1とKwy2がNULLの場合にINI_SECTIONとINI_KEYから値をコピーする
        /// </summary>
        /// <param name="list"></param>
        private static void SetKeyList(List<Item> list, bool isNullSet)
        {
            if (list == null) return;

            for (int i = 0; i < list.Count; i++)
            {
                if (isNullSet == false)
                {
                    if (string.IsNullOrEmpty(list[i].Key1) == true)
                    {
                        list[i].Key1 = list[i].INI_SECTION;
                    }

                    if (string.IsNullOrEmpty(list[i].Key2) == true)
                    {
                        list[i].Key2 = list[i].INI_KEY;
                    }
                }
                else
                {
                    if (list[i].Key1 == list[i].INI_SECTION)
                    {
                        list[i].Key1 = null;
                    }

                    if (list[i].Key2 == list[i].INI_KEY)
                    {
                        list[i].Key2 = null;
                    }
                }
            }
        }

    }
}
