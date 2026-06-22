using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

using Fnw.StatisticsTool.Properties;

namespace Fnw.StatisticsTool
{
    /// <summary>
    /// 2015年版対応（各処理の完了状態を表示する）
    /// 各処理の完了状態と実行タイムスタンプの履歴を保存・表示します。
    /// </summary>
    public class CompletionStatus
    {
        #region インスタンス変数
        /// <summary>
        /// 唯一のインスタンス
        /// </summary>
        [NonSerialized()]
        private static CompletionStatus instance_;
        #endregion

        #region プロパティ
        /// <summary>
        /// 処理ごとの状態情報を取得・設定します。
        /// </summary>
        public List<ProcessItem> ProcessItems { get; set; }
        #endregion

        #region コンストラクタ
        /// <summary>
        /// 新しくインスタンスを生成します。
        /// </summary>
        public CompletionStatus()
        {
            this.ProcessItems = new List<ProcessItem>();
        }
        #endregion

        #region メソッド
        /// <summary>
        /// 所定のXMLファイルを読み込みます。
        /// </summary>
        public static void LoadFromXmlFile()
        {
            // 設定ファイルよりXMLファイルパス取得
            string xmlFilePath = Path.Combine(Settings.Default.PathCsv, Settings.Default.PathCompletionStatus);

            // XMLファイルが存在しない場合
            if (!File.Exists(xmlFilePath))
            {
                instance_ = Create();
                return;
            }

            using (FileStream fs = new FileStream(xmlFilePath, FileMode.Open, FileAccess.Read))
            {
                XmlSerializer xs = new XmlSerializer(typeof(CompletionStatus));
                // 読み込んで逆シリアル化する
                object obj = xs.Deserialize(fs);
                instance_ = (CompletionStatus)obj;
            }
        }

        /// <summary>
        /// 指定の名前の処理情報を取得します。
        /// </summary>
        /// <param name="procId">処理ID</param>
        /// <returns>処理情報</returns>
        public static ProcessItem GetProcessItem(ProcessId procId)
        {
            if (instance_ == null)
            {
                instance_ = Create();
            }
            return instance_.ProcessItems.FirstOrDefault(x => x.ProcId.Equals(procId));
        }

        /// <summary>
        /// 各処理の処理情報をすべて取得します。
        /// </summary>
        /// <returns>各処理の完了処理情報</returns>
        public static List<ProcessItem> GetProcessItems()
        {
            if (instance_ == null)
            {
                instance_ = Create();
            }
            return instance_.ProcessItems;
        }

        /// <summary>
        /// 現在の内容で処理情報を保存します。
        /// </summary>
        public static void Save()
        {
            // 設定ファイルよりXMLファイルパス取得
            string xmlFilePath = Path.Combine(Settings.Default.PathCsv, Settings.Default.PathCompletionStatus);

            using (FileStream fs = new FileStream(xmlFilePath, FileMode.Create, FileAccess.Write))
            {
                XmlSerializer xs = new XmlSerializer(typeof(CompletionStatus));
                xs.Serialize(fs, instance_);
            }
        }

        /// <summary>
        /// 初期値をもった状態でインスタンスを生成します。
        /// </summary>
        /// <returns>処理情報</returns>
        private static CompletionStatus Create()
        {
            CompletionStatus status = new CompletionStatus();
            foreach (ProcessId procId in Enum.GetValues(typeof(ProcessId)))
            {
                if (!procId.Equals(ProcessId.None))
                {
                    status.ProcessItems.Add(new ProcessItem(procId));
                }
            }
            return status;
        }
        #endregion
    }

    #region enum処理ID定義
    /// <summary>
    /// enum処理IDの定義
    /// </summary>
    public enum ProcessId
    {
        /// <summary>
        /// 未定義
        /// </summary>
        None,
        /// <summary>
        /// 登録済み患者一覧作成
        /// </summary>
        ExcelImport,
        /// <summary>
        /// 患者設定
        /// </summary>
        MatchPatient,
        /// <summary>
        /// 原疾患設定
        /// </summary>
        MatchMstDisease,
        /// <summary>
        /// 治療方法設定
        /// </summary>
        MatchMstTreatItem,
        /// <summary>
        /// 死因設定
        /// </summary>
        MatchMstDie,
        /// <summary>
        /// 施設設定
        /// </summary>
        MstFacility,
        /// <summary>
        /// 検査項目設定
        /// </summary>
        MatchMstExamItem,     
        /// <summary>
        /// 糖尿病設定
        /// </summary>
        SelectMstDiseaseDiabetes,
        /// <summary>
        /// 感染症設定
        /// </summary>
        MatchMstInfection,
        //2025年度対象項目
        /// <summary>
        /// バスキュラーアクセス項目設定
        /// </summary>
        MatchMstVa,
        //END  
        /// <summary>
        /// 抽出設定
        /// </summary>
        CustomizeSettings,
        /// <summary>
        /// 抽出
        /// </summary>
        ExtractCsv
    }

    /// <summary>
    /// ProcessId拡張クラス
    /// </summary>
    static class ProcessIdExtentions
    {
        #region 処理名称がXMLファイルに定義されていない場合に使用
        /// <summary>
        /// 処理の名称（初期値として使用）
        /// </summary>
        static string[] names = new string[]
        {
            string.Empty,
            "登録済み患者一覧作成",
            "患者設定",
            "原疾患設定",
            "治療方法設定",
            "死因設定",
            "施設設定",
            "検査項目設定",
            "糖尿病設定",
            "感染症設定",
            //2025年度対象項目
            "バスキュラーアクセス設定",
            //END
            "抽出設定",
            "抽出"
        };
        #endregion

        /// <summary>
        /// 表示用のProcessIdの名称を返します。
        /// </summary>
        /// <param name="procId">処理ID</param>
        /// <returns>表示用名称</returns>
        public static string DisplayName(this ProcessId procId)
        {
            if ((int)procId < 0 || (int)procId >= names.Length)
            {   // 範囲外の場合空文字
                return string.Empty;
            }
            return names[(int)procId];
        }
    }
    #endregion

    #region 処理情報を格納するクラス

    /// <summary>
    /// 各処理ごとの完了状態と実行時のタイムスタンプを格納します。
    /// </summary>
    public class ProcessItem
    {
        #region プロパティ

        /// <summary>
        /// 処理IDの定義を取得・設定します。
        /// </summary>
        [XmlIgnore]
        public ProcessId ProcId { get; set; }

        /// <summary>
        /// 処理IDを文字列で取得・設定します。
        /// </summary>
        [XmlAttribute("id")]
        public string Id {
            get
            {
                return this.ProcId.ToString();
            }
            set
            {
                this.ProcId = ProcessId.None;
                foreach (ProcessId procId in Enum.GetValues(typeof(ProcessId)))
                {
                    if (procId.ToString() == value)
                    {
                        this.ProcId = procId;
                    }
                }
            }
        }

        /// <summary>
        /// 処理の日本語名称を取得・設定します。
        /// </summary>
        [XmlAttribute("name")]
        public string Name { get; set; }

        /// <summary>
        /// 完了状態を取得・設定します。（0:未完了,1:完了）
        /// </summary>
        public int Status { get; set; }

        /// <summary>
        /// 完了状態を文字列で取得します。
        /// </summary>
        [XmlIgnore]
        public string StatusName
        {
            get
            {
                if (this.Status == 0)
                {
                    return "未完了";
                }
                if (this.Status == 1)
                {
                    return "完了";
                }
                return "不明";
            }
        }

        /// <summary>
        /// 実行時タイムスタンプを文字列として取得・設定します。
        /// </summary>
        [XmlElement("Timestamp")]
        public string TimestampString
        {
            get
            {
                if (this.Timestamp.HasValue)
                {
                    return this.Timestamp.Value.ToString("yyyy/MM/dd HH:mm:ss");
                }
                return string.Empty;
            }
            set
            {
                if (string.IsNullOrEmpty(value))
                {
                    this.Timestamp = null;
                }
                else
                {
                    this.Timestamp = DateTime.ParseExact(value, "yyyy/MM/dd HH:mm:ss", null);
                }
            }
        }

        /// <summary>
        /// 実行時タイムスタンプを取得・設定します。
        /// </summary>
        [XmlIgnore]
        public DateTime? Timestamp { get; set; }

        // TODO ログ情報も保有すること

        #endregion

        #region コンストラクタ
        /// <summary>
        /// 新しいインスタンスを生成します。
        /// </summary>
        public ProcessItem()
        {
            // 初期値
            this.ProcId = ProcessId.None;
            this.Status = 0;
            this.Timestamp = null;
        }

        /// <summary>
        /// 処理IDを格納して新しくインスタンスを生成します。
        /// </summary>
        /// <param name="id">処理ID</param>
        public ProcessItem(ProcessId id)
            : this()
        {
            this.ProcId = id;
            this.Name = this.ProcId.DisplayName();
        }
        #endregion
    }
    #endregion
}
