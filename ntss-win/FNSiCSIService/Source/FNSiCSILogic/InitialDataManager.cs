using jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopCommonDefine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Threading;
using System.Xml;

namespace FNSiCSILogicLib
{

    /// <summary>
    /// 初期設定情報管理クラス
    /// </summary>
    public class InitialDataManager:MarshalByRefObject
    {
        #region "共通定義"
        /// <summary>初期設定テーブル/区分-[CATEGORY]</summary>
        private static readonly string NAME_INIT_DMP_CATEGORY = "0";
		/// <summary>初期設定テーブル/セクション-[SECTION]</summary>
        private static readonly string NAME_INIT_DMP_SECTION = "LOG";

        /// <summary>初期設定テーブル/キー-[KEY:通信ログ-出力先パス]</summary>
        private static readonly string NAME_INIT_KEY_DMP_OUTPUT_PATH = "DMP_OUTPUT_PATH";
        /// <summary>初期設定テーブル/キー-[KEY:通信ログ-出力先ファイル名]</summary>
        private static readonly string NAME_INIT_KEY_DMP_OUTPUT_FILENAME = "DMP_OUTPUT_FILENAME";
        /// <summary>初期設定テーブル/キー-[KEY:通信ログ-保存期間]</summary>
        private static readonly string NAME_INIT_KEY_DMP_INTERVAL = "DMP_INTERVAL";
        /// <summary>初期設定テーブル/キー-[KEY:通信ログ-ログ種別]</summary>
        private static readonly string NAME_INIT_KEY_MIN_OUTPUT_LEVEL = "MIN_OUTPUT_LEVEL";

        //書込み用スレッド処理
        delegate InitialDataManager ThreadMethodSetDelegate(string SectionName, string KeyName, string SetValue);

        #endregion

        #region メンバ定義
        /// <summary>通信ログ-出力先パス</summary>
        private string m_DmpOutputPath;
        /// <summary>通信ログ-出力先ファイル名</summary>
        private string m_DmpOutputFilename;
        /// <summary>通信ログ-保存期間</summary>
        private string m_DmpInterval;
        /// <summary>通信ログ-ログ種別</summary>
        private string m_MinOutputLevel;
        #endregion // メンバ定義

        #region プロパティ
        /// <summary>連携初期設定情報の通信ログ-出力先パス</summary>
        public string DmpOutputPath
        {
            set { m_DmpOutputPath = value; }
            get { return m_DmpOutputPath; }
        }

        /// <summary>連携初期設定情報の通信ログ-出力先ファイル名</summary>
        public string DmpOutputFilename
        {
            set { m_DmpOutputFilename = value; }
            get { return m_DmpOutputFilename; }
        }

        /// <summary>連携初期設定情報の通信ログ-保存期間</summary>
        public string DmpInterval
        {
            set { m_DmpInterval = value; }
            get { return m_DmpInterval; }
        }

        /// <summary>連携初期設定情報の通信ログ-ログ種別</summary>
        public string MinOutputLevel
        {
            set { m_MinOutputLevel = value; }
            get { return m_MinOutputLevel; }
        }
        #endregion // プロパティ

        #region "コンストラクタ"
        /// <summary>
        /// コンストラクタ
        /// </summary>
        public InitialDataManager()
        {
        }
        #endregion

        #region "パブリックメソッド"
        /// <summary>
        /// 初期設定情報の取得
        /// </summary>
        /// <param name="strCategory">初期設定テーブル-[区分]カラムの条件値</param>
        /// <param name="strSectionName">初期設定テーブル-[セクション]カラムの条件値</param>
        /// <param name="strKeyName">初期設定テーブル-[キー]カラムの条件値</param>
        /// <param name="htValueTable">取得結果</param>
        public ResultCode GetData(string strCategory, string strSectionName, string strKeyName, ref Hashtable htValueTable)
        {
            //戻り値
            ResultCode result = ResultCode.Ng;
            int nNGCnt = 0;

            if (htValueTable == null)
            {
                htValueTable = new Hashtable();
            }

            //パラメータチェック
            if( ((strCategory != null) && (strCategory != string.Empty)) && ((strSectionName != null) && (strSectionName != string.Empty)) )
            {
                // 区分=0、NAME_INIT_SECTION=LOG場合
                if (NAME_INIT_DMP_CATEGORY.Equals(strCategory) && NAME_INIT_DMP_SECTION.Equals(strSectionName))
                {
                    if (NAME_INIT_KEY_DMP_OUTPUT_PATH.Equals(strKeyName))
                    {
                        // 通信ログ-出力先パス
                        htValueTable.Add(NAME_INIT_KEY_DMP_OUTPUT_PATH, m_DmpOutputPath);
                    }
                    else if (NAME_INIT_KEY_DMP_OUTPUT_FILENAME.Equals(strKeyName))
                    {
                        // 通信ログ-出力先ファイル名
                        htValueTable.Add(NAME_INIT_KEY_DMP_OUTPUT_FILENAME, m_DmpOutputFilename);

                    }
                    else if (NAME_INIT_KEY_DMP_INTERVAL.Equals(strKeyName))
                    {
                        // 通信ログ-保存期間
                        htValueTable.Add(NAME_INIT_KEY_DMP_INTERVAL, m_DmpInterval);

                    }
                    else if (NAME_INIT_KEY_MIN_OUTPUT_LEVEL.Equals(strKeyName))
                    {
                        // 通信ログ-ログ種別
                        htValueTable.Add(NAME_INIT_KEY_MIN_OUTPUT_LEVEL, m_MinOutputLevel);

                    }
                }
            }
            if (htValueTable.Count > 0 && nNGCnt == 0)
            {
                result = ResultCode.Ok;
            }

            return result;
        }
        /// <summary>
        /// 初期設定情報の更新
        /// </summary>
        /// <param name="Category">初期設定テーブル-[区分]カラムの条件値</param>
        /// <param name="SectionName">初期設定テーブル-[セクション]カラムの条件値</param>
        /// <param name="KeyName">初期設定テーブル-[キー]カラムの条件値</param>
        /// <param name="SetValue">初期設定テーブル-[値]カラムのセット値</param>
        public ResultCode SetData(string Category,string SectionName, string KeyName, string SetValue)
        {
            ResultCode result = ResultCode.Ng;
            int Hit = -1;
            Hashtable ValueTable = new Hashtable();

            //各パラメータチェック
            if( ((Category != null) && (Category != string.Empty)) && ((SectionName != null) && (SectionName != string.Empty)) && ((KeyName != null) && (KeyName != string.Empty)) && ((SetValue != null) && (SetValue != string.Empty)))
            {
                
            }
            if (Hit != -1)
            {
                result = ResultCode.Ok;
            }
            
            return result;
        }
        #endregion
    }
}
