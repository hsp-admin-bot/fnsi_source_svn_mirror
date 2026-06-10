using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using Fnw.StatisticsTool.Properties;

namespace Fnw.StatisticsTool.FrmCustomize
{
    /// <summary>
    /// カスタマイズ設定クラス
    /// </summary>
    public class CustomizeSettings
    {
        /// <summary>
        /// メンバ変数
        /// </summary>
        private bool _isDispIndDialysisTime;
        private bool _isDispIndHemodiafiltrationInfo;
        private bool _isCorrectionCa;
        private bool _isCorrectionHbA1c;

        /// <summary>
        /// 透析時間取得先(true:指示値、false:実績値)
        /// </summary>
        public bool IsDispIndDialysisTime
        {
            get { return _isDispIndDialysisTime; }
            set { _isDispIndDialysisTime = value; }
        }

        /// <summary>
        /// ＨＤＦ情報取得先(true:指示値、false:実績値)
        /// </summary>
        public bool IsDispIndHemodiafiltrationInfo
        {
            get { return _isDispIndHemodiafiltrationInfo; }
            set { _isDispIndHemodiafiltrationInfo = value; }
        }

        /// <summary>
        /// カルシウム濃度検査値補正(true:補正あり、false:補正なし)
        /// </summary>
        public bool IsCorrectionCa
        {
            get { return _isCorrectionCa; }
            set { _isCorrectionCa = value; }
        }

        /// <summary>
        /// ヘモグロビンA1c検査値補正(true:補正あり、false:補正なし)
        /// </summary>
        public bool IsCorrectionHbA1c
        {
            get { return _isCorrectionHbA1c; }
            set { _isCorrectionHbA1c = value; }
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public CustomizeSettings()
        {
            // 初期値設定
            _isDispIndDialysisTime = false;
            _isDispIndHemodiafiltrationInfo = false;
            _isCorrectionCa = false;
            _isCorrectionHbA1c = false;
        }

        [NonSerialized()]
        private static CustomizeSettings _instance;

        /// <summary>
        /// CustomizeSettingsクラスのただ一つのインスタンス
        /// </summary>
        [XmlIgnore]
        public static CustomizeSettings Instance
        {
            get
            {
                if (_instance == null)
                    _instance = new CustomizeSettings();
                return _instance;
            }
            set {_instance = value;}
        }

        /// <summary>
        /// 設定をXMLファイルから読み込み復元する
        /// </summary>
        public static void LoadFromXmlFile()
        {
            // XMLファイルが存在しない場合
            if (!File.Exists(GetSettingPath()))
            {
                Instance = new CustomizeSettings();
                return;
            }

            FileStream fs = new FileStream(GetSettingPath(), FileMode.Open, FileAccess.Read);
            XmlSerializer xs = new XmlSerializer(typeof(CustomizeSettings));

            // 読み込んで逆シリアル化する
            object obj = xs.Deserialize(fs);
            fs.Close();

            Instance = (CustomizeSettings)obj;
        }

        /// <summary>
        /// 現在の設定をXMLファイルに保存する
        /// </summary>
        public static void SaveToXmlFile()
        {
            FileStream fs = new FileStream(GetSettingPath(), FileMode.Create, FileAccess.Write);
            XmlSerializer xs = new XmlSerializer(typeof(CustomizeSettings));

            // シリアル化して書き込む
            xs.Serialize(fs, Instance);
            fs.Close();
        }

        /// <summary>
        /// カスタマイズ設定ファイルのファイルパスを取得
        /// </summary>
        /// <returns></returns>
        private static string GetSettingPath()
        {
            return Path.Combine(Settings.Default.PathCsv, Settings.Default.PathCustomizeSettings);
        }
    }
}
