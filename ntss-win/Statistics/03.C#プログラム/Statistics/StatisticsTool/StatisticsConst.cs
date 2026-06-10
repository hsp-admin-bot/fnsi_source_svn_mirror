using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using Fnw.StatisticsTool.Properties;
using Fnw.StatisticsTool.Csv;
using Fnw.StatisticsTool.FrmCustomize;
using Fnw.StatisticsTool.Models;
using System.Threading.Tasks;
using NKKLoggingLib;

namespace Fnw.StatisticsTool
{
    /// <summary>
    /// URI
    /// </summary>
    public static class Uri
    {
        /// <summary>
        /// アプリケーションURI
        /// </summary>
        public const string WEB_APP = @"/ntss-admin-web";
        /// <summary>
        /// 施設マスタ用APIルートURI
        /// </summary>
        private const string API_MST_FACILITY_ROOT = @"/api/master_maintenance";
        /// <summary>
        /// 施設マスタ:表示用URI
        /// </summary>
        public const string GET_MST_FACILITY_DATA = API_MST_FACILITY_ROOT + @"/mst_facility_setting/mst_facility";
        /// <summary>
        /// 施設マスタ用APIルートURI
        /// </summary>
        private const string API_PAT_EVENT_ROOT = @"/api/pat_event";
        /// <summary>
        /// 施設マスタ:表示用URI
        /// </summary>
        public const string GET_SYS_DATA_SET = API_PAT_EVENT_ROOT + @"/dataset-statistics";
    }
    /// <summary>
    /// 表示情報とコード情報
    /// </summary>
    internal class DispCode
    {
        /// <summary>
        /// コード用キー
        /// </summary>
        public const string KEY_CODE = "Code";
        /// <summary>
        /// 名称キー
        /// </summary>
        public const string KEY_NAME = "Name";
        /// <summary>
        /// 表示キー
        /// </summary>
        public const string KEY_DISP = "Disp";
        /// <summary>
        /// 県キー
        /// </summary>
        public const string KEY_PREF = "Pref";

        private string m_Code = null;
        private string m_Name = null;
        private string m_Pref = null;

        /// <summary>
        /// 表示情報とコード情報のコンストラクタ
        /// </summary>
        /// <param name="code">格納するコード</param>
        /// <param name="name">名称</param>
        internal DispCode(string code, string name)
        {
            this.m_Code = code;
            this.m_Name = name;
        }

        /// <summary>
        /// 表示情報とコード情報のコンストラクタ
        /// </summary>
        /// <param name="code">格納するコード</param>
        /// <param name="name">名称</param>
        /// <param name="pref">県</param>
        internal DispCode(string code, string name, string pref)
        {
            this.m_Code = code;
            this.m_Name = name;
            this.m_Pref = pref;
        }

        /// <summary>
        /// 格納している情報へのアクセス
        /// </summary>
        /// <param name="key">DispCode.KEY_CODE/DispCode.KEY_NAME/DispCode.KEY_DISPのいずれか</param>
        /// <returns></returns>
        internal string this[string key]
        {
            get
            {
                switch (key)
                {
                    case DispCode.KEY_CODE: return this.Code;
                    case DispCode.KEY_NAME: return this.Name;
                    case DispCode.KEY_DISP: return this.Disp;
                    case DispCode.KEY_PREF: return this.Pref;
                    default: return string.Empty;
                }
            }
        }



        /// <summary>
        /// コードを取得
        /// </summary>
        public string Code { get { return this.m_Code; } }
        /// <summary>
        /// 名称を取得
        /// </summary>
        public string Name { get { return this.m_Name; } }
        /// <summary>
        /// 表示用文字列を取得(コード:名称のフォーマット)
        /// </summary>
        public string Disp
        {
            get
            {
                if (string.IsNullOrEmpty(this.m_Code))
                {
                    return this.Name;
                }
                else
                {
                    if (string.IsNullOrEmpty(this.m_Pref))
                    {
                        return this.m_Code + ":" + this.m_Name;
                    }
                    else
                    {
                        return this.m_Code + "(" + (this.m_Pref + ")").PadRight(5, '　') + ":" + this.m_Name;
                    }
                }
            }
        }
        /// <summary>
        /// 県名を取得
        /// </summary>
        public string Pref { get { return this.Pref; } }
    }

    /// <summary>
    /// 検査区分
    /// </summary>
    public enum ExamOrderClass
    {
        /// <summary>
        /// 区分無し
        /// </summary>
        ANY,
        /// <summary>
        /// 透析前
        /// </summary>
        BEFORE,
        /// <summary>
        /// 透析後
        /// </summary>
        AFTER,
    }

    /// <summary>
    /// 統合シートの列名定義
    /// </summary>
    public enum SheetSum
    {
        ///// <summary>
        ///// 管理通番
        ///// </summary>
        //C00_管理通番 = 0,

        ///// <summary>
        ///// 氏名
        ///// </summary>
        //C01_氏名 = 1,

        ///// <summary>
        ///// 事務局使用欄1
        ///// </summary>
        //C02_事務局使用欄1 = 2,

        ///// <summary>
        ///// 事務局使用欄2
        ///// </summary>
        //C03_配布時姓 = 3,

        ///// <summary>
        ///// 事務局使用欄
        ///// </summary>
        //C04_配布時名 = 4,

        ///// <summary>
        ///// 事務局使用欄
        ///// </summary>
        //C05_事務局使用欄4 = 5,

        ///// <summary>
        ///// 事務局使用欄
        ///// </summary>
        //C06_事務局使用欄5 = 6,

        ///// <summary>
        ///// 事務局使用欄
        ///// </summary>
        //C07_事務局使用欄6 = 7,

        ///// <summary>
        ///// 事務局使用欄
        ///// </summary>
        //C08_事務局使用欄7 = 8,

        ///// <summary>
        ///// 事務局使用欄
        ///// </summary>
        //C09_事務局使用欄8 = 9,

        ///// <summary>
        ///// 事務局使用欄
        ///// </summary>
        //C10_事務局使用欄9 = 10,

        ///// <summary>
        ///// 事務局使用欄
        ///// </summary>
        //C11_事務局使用欄10 = 11,

        ///// <summary>
        ///// 事務局使用欄
        ///// </summary>
        //C12_事務局使用欄11 = 12,

        /// <summary>
        /// 患者区分
        /// </summary>
        C13_患者区分 = 0,

        /// <summary>
        /// 診察券番号
        /// </summary>
        C14_診察券番号 = 1,

        /// <summary>
        /// 氏名_姓（漢字）
        /// </summary>
        C15_氏名_姓_漢字 = 2,

        /// <summary>
        /// 氏名_名（漢字）
        /// </summary>
        C16_氏名_名_漢字 = 3,

        /// <summary>
        /// 氏名_姓（ｶﾀｶﾅ）
        /// </summary>
        C17_氏名_姓_カナ = 4,

        /// <summary>
        /// 氏名_名（ｶﾀｶﾅ）
        /// </summary>
        C18_氏名_名_カナ = 5,

        /// <summary>
        /// 並び替え
        /// </summary>
        C19_並び替え = 6,

        /// <summary>
        /// 性別
        /// </summary>
        C20_性別 = 7,

        /// <summary>
        /// 生年月日_西暦
        /// </summary>
        C21_生年月日_西暦 = 8,
        /// <summary>
        /// 生年月日_月
        /// </summary>
        C22_生年月日_月 = 9,

        /// <summary>
        /// 生年月日_日
        /// </summary>
        C23_生年月日_日 = 10,

        /// <summary>
        /// 12月末の年齢
        /// </summary>
        C24_12月末の年齢 = 11,

        /// <summary>
        /// 導入年月_西暦
        /// </summary>
        C25_導入年月_西暦 = 12,

        /// <summary>
        /// 導入年月_月
        /// </summary>
        C26_導入年月_月 = 13,

        /// <summary>
        /// 導入年月_月
        /// </summary>
        C27_12月末の透析歴 = 14,

        /// <summary>
        /// 原疾患
        /// </summary>
        C28_原疾患 = 15,

        /// <summary>
        /// 在住県コード
        /// </summary>
        C29_在住県コード = 16,

        /// <summary>
        /// 転入_西暦年
        /// </summary>
        C30_転入_西暦年 = 17,

        /// <summary>
        /// 転入_月
        /// </summary>
        C31_転入_月 = 18,

        /// <summary>
        /// 転入_転入前の施設コード
        /// </summary>
        C32_転入_転入前の施設コード = 19,

        /// <summary>
        /// 転帰欄_転帰区分
        /// </summary>
        C33_転帰欄_転帰区分 = 20,

        /// <summary>
        /// 転帰欄_西暦年
        /// </summary>
        C34_転帰欄_西暦年 = 21,

        /// <summary>
        /// 転帰欄_月
        /// </summary>
        C35_転帰欄_月 = 22,

        /// <summary>
        /// 転帰欄_転出先の施設コード
        /// </summary>
        C36_転帰欄_転出先の施設コード = 23,

        /// <summary>
        /// 転帰欄_死因コード
        /// </summary>
        C37_転帰欄_死因コード = 24,

        /// <summary>
        /// 患者情報変更訂正区分
        /// </summary>
        C38_患者情報変更訂正区分 = 25,

        /// <summary>
        /// 備考
        /// </summary>
        C39_備考 = 26,

        /// <summary>
        /// 備考後ろの謎枠
        /// </summary>
        C40_備考後ろの謎枠 = 27,

        /// <summary>
        /// 糖尿病の既往
        /// </summary>
        C41_糖尿病の既往 = 28,

        /// <summary>
        /// 心筋梗塞の既往
        /// </summary>
        C42_心筋梗塞の既往 = 29,

        /// <summary>
        /// 脳出血の既往
        /// </summary>
        C43_脳出血の既往 = 30,

        /// <summary>
        /// 脳梗塞の既往
        /// </summary>
        C44_脳梗塞の既往 = 31,

        /// <summary>
        /// 四肢切断の有無
        /// </summary>
        C45_四肢切断の有無 = 32,

        /// <summary>
        /// 大腿骨頸部骨折の既往
        /// </summary>
        C46_大腿骨頸部骨折の既往 = 33,

        /// <summary>
        /// 被嚢性腹膜硬化症の既往
        /// </summary>
        C47_被嚢性腹膜硬化症の既往 = 34,

        /// <summary>
        /// 降圧薬使用の有無
        /// </summary>
        C48_降圧薬使用の有無 = 35,

        //2025年度対象外項目
        ///// <summary>
        ///// 
        ///// </summary>
        //C49_アンジオテンシン受容体ネプリライシン阻害薬使用の有無 = 36,

        //2025年度対象外項目
        ///// <summary>
        ///// 
        ///// </summary>
        //C50_カルシウム拮抗薬使用の有無 = 37,

        //2025年度対象外項目
        ///// <summary>
        ///// 
        ///// </summary>
        //C51_レニンアンジオテンシン系阻害薬使用の有無 = 38,

        //2025年度対象外項目
        ///// <summary>
        ///// 
        ///// </summary>
        //C52_ミネラルコルチコイド受容体拮抗薬使用の有無 = 39,

        //2025年度対象外項目
        ///// <summary>
        ///// 
        ///// </summary>
        //C53_β遮断薬使用の有無 = 40,

        //2025年度対象外項目
        ///// <summary>
        ///// 
        ///// </summary>
        //C54_その他の降圧薬使用の有無 = 41,

        //2025年度対象外項目
        ///// <summary>
        ///// 
        ///// </summary>
        //C55_利尿薬使用の有無と種類 = 42,

        /// <summary>
        /// 喫煙の有無
        /// </summary>
        C49_喫煙の有無 = 36,

        //2025年度対象項目
        ///// <summary>
        ///// バスキュラーアクセス
        ///// </summary>
        C50_ﾊﾞｽｷｭﾗｰｱｸｾｽ = 37,

        /// <summary>
        /// 治療方法
        /// </summary>
        C51_治療方法 = 38,

        /// <summary>
        /// HDFとPDの併用状況
        /// </summary>
        C52_β2ミクログロブリン吸着カラム使用の有無 = 39,

        /// <summary>
        /// 腹膜透析の経験
        /// </summary>
        C53_腹膜透析の経験 = 40,

        /// <summary>
        /// ﾚｼﾋﾟｴﾝﾄとしての腎移植の回数
        /// </summary>
        C54_レシピエントとしての腎移植の回数 = 41,

        /// <summary>
        /// 腎移植ドナー_腎提供の既往
        /// </summary>
        C55_ドナーとしての腎提供の既往 = 42,

        /// <summary>
        /// (提供ありの場合)ドナーとしての 腎提供年月
        /// </summary>
        C56_腎提供年月_西暦年 = 43,

        /// <summary>
        /// (提供ありの場合)ドナーとしての 腎提供年月
        /// </summary>
        C57_腎提供年月_月 = 44,

        //// 2023年度対象
        ///// <summary>
        ///// 新型コロナ検査の有無
        ///// </summary>
        //C57_新型コロナの既往 = 57,

        //// 2023年度対象
        ///// <summary>
        ///// 新型コロナ検査の有無
        ///// </summary>
        //C58_2023年中の陽性診断月 = 58,

        /// <summary>
        /// 週透析回数
        /// </summary>
        C58_週透析回数 = 45,

        /// <summary>
        /// 透析時間
        /// </summary>
        C59_透析時間 = 46,

        /// <summary>
        /// 血流量
        /// </summary>
        C60_血流量 = 47,

        /// <summary>
        /// HDF希釈の方法
        /// </summary>
        C61_HDF希釈の方法 = 48,

        /// <summary>
        /// 1セッションあたりの置換液量
        /// </summary>
        C62_1セッションあたりの置換液量 = 49,

        /// <summary>
        /// 身長
        /// </summary>
        C63_身長 = 50,

        /// <summary>
        /// 体重_透析前
        /// </summary>
        C64_体重_透析前 = 51,

        /// <summary>
        /// 体重_透析後
        /// </summary>
        C65_体重_透析後 = 52,

        /// <summary>
        /// 透析前収縮期血圧
        /// </summary>
        C66_透析前収縮期血圧 = 53,

        /// <summary>
        /// 透析前拡張期血圧
        /// </summary>
        C67_透析前拡張期血圧 = 54,

        /// <summary>
        /// 透析前脈拍
        /// </summary>
        C68_透析前脈拍 = 55,

        //2025年度対象外項目
        ///// <summary>
        ///// 家庭での血圧測定の有無
        ///// </summary>
        //C75_家庭での血圧測定の有無 = 62,

        /// <summary>
        /// BUN_透析前
        /// </summary>
        C69_BUN_透析前 = 56,

        /// <summary>
        /// BUN_透析後
        /// </summary>
        C70_BUN_透析後 = 57,

        /// <summary>
        /// クレアチニン濃度_透析前
        /// </summary>
        C71_クレアチニン濃度_透析前 = 58,

        /// <summary>
        /// クレアチニン濃度_透析後
        /// </summary>
        C72_クレアチニン濃度_透析後 = 59,

        /// <summary>
        /// 透析前アルブミン濃度
        /// </summary>
        C73_透析前アルブミン濃度 = 60,

        /// <summary>
        /// 透析前CRP濃度
        /// </summary>
        C74_透析前CRP濃度 = 61,

        /// <summary>
        /// 透析前カルシウム濃度
        /// </summary>
        C75_透析前カルシウム濃度 = 62,

        /// <summary>
        /// 透析前リン濃度
        /// </summary>
        C76_透析前リン濃度 = 63,

        /// <summary>
        /// PTH測定法
        /// </summary>
        C77_PTH測定法 = 64,

        /// <summary>
        /// PTH値
        /// </summary>
        C78_PTH値 = 65,

        /// <summary>
        /// 透析前ヘモグロビン濃度
        /// </summary>
        C79_透析前ヘモグロビン濃度 = 66,

        /// <summary>
        /// 総コレステロール濃度
        /// </summary>
        C80_総コレステロール濃度 = 67,

        /// <summary>
        /// HDL_C濃度
        /// </summary>
        C81_HDL_C濃度 = 68,

        //2025年度対象外項目
        ///// <summary>
        ///// LDL_コレステロール濃度
        ///// </summary>
        //C89_LDL_コレステロール濃度 = 76,

        //2025年度対象外項目
        ///// <summary>
        ///// 中性脂肪
        ///// </summary>
        //C90_中性脂肪 = 77,

        //2025年度対象外項目
        ///// <summary>
        ///// スタチン使用の有無
        ///// </summary>
        //C91_スタチン使用の有無 = 78,

        //2025年度対象外項目
        ///// <summary>
        ///// エゼチミブ使用の有無
        ///// </summary>
        //C92_エゼチミブ使用の有無 = 79,

        //2025年度対象外項目
        ///// <summary>
        ///// ペマフィブラート使用の有無
        ///// </summary>
        //C93_ペマフィブラート使用の有無 = 80,

        /// <summary>
        /// HBs抗原
        /// </summary>
        C82_HBs抗原 = 69,

        /// <summary>
        /// HBs抗体
        /// </summary>
        C83_HBs抗体 = 70,

        /// <summary>
        /// HBc抗体
        /// </summary>
        C84_HBc抗体 = 71,

        /// <summary>
        /// HBV_DNA検査
        /// </summary>
        C85_HBV_DNA検査 = 72,

        /// <summary>
        /// HCV抗体
        /// </summary>
        C86_HCV抗体 = 73,

        /// <summary>
        /// HCV_RNA検査
        /// </summary>
        C87_HCV_RNA検査 = 74,

        ///// <summary>
        ///// 有酸素運動透析中
        ///// </summary>
        //C83_有酸素運動_透析中 = 83,

        ///// <summary>
        ///// 有酸素運動透析中以外
        ///// </summary>
        //C84_有酸素運動_透析中以外 = 84,

        ///// <summary>
        ///// レジスタンス運動透析中
        ///// </summary>
        //C85_レジスタンス運動_透析中 = 85,

        ///// <summary>
        ///// レジスタンス運動透析中以外
        ///// </summary>
        //C86_レジスタンス運動_透析中以外 = 86,

        ///// <summary>
        ///// 1年以内の栄養指導
        ///// </summary>
        //C87_1年以内の栄養指導 = 87,

        ///// <summary>
        ///// 生活活動度
        ///// </summary>
        //C88_生活活動度 = 88,

        ///// <summary>
        ///// 悪性腫瘍の新規発症と種類
        ///// </summary>
        //C89_悪性腫瘍の新規発症と種類 = 89,

        ///// <summary>
        ///// 深部静脈血栓発症の有無
        ///// </summary>
        //C90_深部静脈血栓発症の有無 = 90,       

        ///// <summary>
        ///// 肺塞栓症発症の有無
        ///// </summary>
        //C91_肺塞栓症発症の有無 = 91,       

        ///// <summary>
        ///// シャント閉塞発症の有無
        ///// </summary>
        //C92_シャント閉塞発症の有無 = 92,  

        ///// <summary>
        ///// 眼底出血発症の有無
        ///// </summary>
        //C93_眼底出血発症の有無 = 93,

        ///// <summary>
        ///// 入院の有無
        ///// </summary>
        //C94_入院の有無 = 94,

        ///// <summary>
        ///// 入院理由1
        ///// </summary>
        //C95_入院理由1 = 95,

        ///// <summary>
        ///// 入院理由2
        ///// </summary>
        //C96_入院理由2 = 96,

        ///// <summary>
        ///// 入院理由3
        ///// </summary>
        //C97_入院理由3 = 97,

        /// <summary>
        /// 現在施行中のPD歴_月
        /// </summary>
        C88_現在施行中のPD歴_月 = 75,

        /// <summary>
        /// 2023年中のPD実施月数_月
        /// </summary>
        C89_2025年中のPD実施月数_月 = 76,

        /// <summary>
        /// PET施行の有無
        /// </summary>
        C90_PET施行の有無 = 77,

        /// <summary>
        /// PET_CR_DP比
        /// </summary>
        C91_PET_CR_DP比 = 78,

        /// <summary>
        /// イコデキストリン透析液使用の有無
        /// </summary>
        C92_イコデキストリン透析液使用の有無 = 79,

        /// <summary>
        /// 一日透析液使用量
        /// </summary>
        C93_一日透析液使用量 = 80,

        /// <summary>
        /// 残存腎機能
        /// </summary>
        C94_残存腎機能 = 81,

        /// <summary>
        /// 一日平均除水量
        /// </summary>
        C95_一日平均除水量 = 82,

        /// <summary>
        /// 残腎KT_V
        /// </summary>
        C96_残腎KT_V = 83,

        /// <summary>
        /// PD_KT_V
        /// </summary>
        C97_PD_KT_V = 84,

        /// <summary>
        /// APD
        /// </summary>
        C98_APD = 85,

        /// <summary>
        /// PD透析液交換方法
        /// </summary>
        C99_PD透析液交換方法 = 86,

        /// <summary>
        /// 2023年中の腹膜炎罹患回数
        /// </summary>
        C100_2025年中の腹膜炎罹患回数 = 87,

        /// <summary>
        /// 2022年中の出口部感染罹患回数
        /// </summary>
        C101_2025年中の出口部感染罹患回数 = 88,

        /// <summary>
        /// 件数
        /// </summary>
        件数_ = 89,
    }


    /// <summary>
    /// 新患者枠のエラー情報
    /// </summary>
    public enum ErrorSheetNew
    {
        /// <summary>表示患者ID</summary>
        DISP_PATID,
        /// <summary>件数</summary>
        COL_COUNT,

    }

    /// <summary>
    /// 既存枠のエラー情報
    /// </summary>
    public enum ErrorSheetOld
    {
        /// <summary>表示患者ID</summary>
        DISP_PATID,
        /// <summary>氏名</summary>
        NAME,
        /// <summary>性別</summary>
        SEX,
        /// <summary>生年月日(年)</summary>
        BIRTHDAY_YEAR,
        /// <summary>生年月日(月)</summary>
        BIRTHDAY_MONTH,
        /// <summary>生年月日(日)</summary>
        BIRTHDAY_DAY,
        /// <summary>件数</summary>
        COL_COUNT,
    }



    /// <summary>
    /// 定数定義クラス
    /// </summary>
    static class StatisticsConst
    {
        //2015年版対応（透析前、透析後の表示接尾語の定数追加
        #region 検査項目表示用接尾語
        /// <summary>検査項目表示用接尾語文字列(透析前)</summary>
        public const string SUFFIX_BEFORE = "(前)";
        /// <summary>検査項目表示用接尾語文字列(透析後)</summary>
        public const string SUFFIX_AFTER = "(後)";
        #endregion

        #region 検査項目抽出文字列

        //2015年版修正（BUNとクレアチニンで透析前後で別の検査項目を指定可能とする対応）
        /// <summary>検査項目抽出文字列(BUN_後)</summary>
        public const string EXAM_BUN_AFTER = "BUN_AFTER";
        /// <summary>検査項目抽出文字列(クレアチニン_後)</summary>
        public const string EXAM_CREATININE_AFTER = "CREATININE_AFTER";
        /// <summary>検査項目抽出文字列(BUN)</summary>
        public const string EXAM_BUN = "BUN";
        /// <summary>検査項目抽出文字列(クレアチン)</summary>
        public const string EXAM_CREATININE = "CREATININE";
        /// <summary>検査項目抽出文字列(ｶﾙｼｳﾑ)</summary>
        public const string EXAM_CALCIUM = "CALCIUM";
        /// <summary>検査項目抽出文字列(ﾘﾝ)</summary>
        public const string EXAM_PHOSPHORUS = "PHOSPHORUS";
        /// <summary>検査項目抽出文字列(ｱﾙﾌﾞﾐﾝ)</summary>
        public const string EXAM_ALBUMIN = "ALBUMIN";
        /// <summary>検査項目抽出文字列(CRP)</summary>
        public const string EXAM_CRP = "CRP";
        /// <summary>検査項目抽出文字列(ヘモグロビン)</summary>
        public const string EXAM_HEMOGLOBIN = "HEMOGLOBIN";
        /// <summary>検査項目抽出文字列(PTH)</summary>
        public const string EXAM_PTH = "PTH";
        // <summary>検査項目抽出文字列(尿酸値)</summary>
        //public const string EXAM_URIC_ACID = "URIC_ACID";
        /// <summary>検査項目抽出文字列(総コレステロール濃度)</summary>
        public const string EXAM_TOTAL_CHOLESTEROL = "TOTAL_CHOLESTEROL";
        /// <summary>検査項目抽出文字列(HDL-C濃度)</summary>
        public const string EXAM_HDL_CHOLESTEROL = "HDL_CHOLESTEROL";
        //2025年度対象外項目
        ////2024年度　新設項目
        ///// <summary>検査項目抽出文字列(HDL-C濃度)</summary>
        //public const string EXAM_LDL_CHOLESTEROL = "LDL_CHOLESTEROL";
        ///// <summary>検査項目抽出文字列(中性脂肪)</summary>
        //public const string EXAM_TRIGLYCERIDE = "TRIGLYCERIDE";
        ////END
        //END
        /// <summary>検査項目抽出文字列(ALP値)</summary>
        public const string EXAM_ALP = "ALP";
        /// <summary>検査項目抽出文字列(マグネシウム濃度)</summary>
        public const string EXAM_MG = "MG";

        #endregion

        #region 感染症項目抽出文字列

        /// <summary>感染症項目抽出文字列(HBs抗原)</summary>
        public const string INFECT_HBS = "HBs抗原";
        /// <summary>感染症項目抽出文字列(HBs抗体)</summary>
        public const string INFECT_HBSAB = "HBs抗体";
        /// <summary>感染症項目抽出文字列(HBc抗体)</summary>
        public const string INFECT_HBC = "HBc抗体";
        /// <summary>感染症項目抽出文字列(HBs-DNA)</summary>
        public const string INFECT_HBV_DNA = "HBV-DNA";
        /// <summary>感染症項目抽出文字列(HBs抗原)</summary>
        public const string INFECT_HCV = "HCV抗体";
        /// <summary>感染症項目抽出文字列(HCV-RNA)</summary>
        public const string INFECT_HCV_RNA = "HCV-RNA";
        
        #endregion

        #region 状態

        /// <summary>状態：割当無し</summary>
        public const string ST_NO = "割当無し";
        /// <summary>状態：自動割当</summary>
        public const string ST_AUTO = "自動割当";
        /// <summary>状態：割当済み</summary>
        public const string ST_MATCH = "割当済み";

        #endregion

        #region 学会Excel用

        /// <summary>行番号：開始</summary>
        public const int EXCEL_ROW_START = 11;
        /// <summary>行番号：終了</summary>
        public const int EXCEL_ROW_END = 65535;

        #endregion
    }

    /// <summary>
    /// 静的関数群
    /// </summary>
    static class StaticFunctions
    {
        /// <summary>
        /// SheetSumの列定義から生年月日を生成
        /// </summary>
        /// <param name="row">SheetSum定義に従ったDataRow</param>
        /// <returns>生成した生年月日(エラー時はDateTime.MinValue)</returns>
        public static DateTime GetSheetSumBirthday(DataRow row)
        {
            DateTime work;
            if (DateTime.TryParse(row[(int)SheetSum.C21_生年月日_西暦] as string + "/" + row[(int)SheetSum.C22_生年月日_月] + "/" + row[(int)SheetSum.C23_生年月日_日], out work))
            {
                return work;
            }
            else
            {
                return DateTime.MinValue;
            }
        }

        /// <summary>
        /// YYYYMMDDフォーマットからDateTime型を生成
        /// </summary>
        /// <param name="yyyyMmDd">YYYYMMDDフォーマットの文字列</param>
        /// <returns>変換した生年月日(エラー時はDateTime.MinValue)</returns>
        public static DateTime YyyyMmDdToDay(string yyyyMmDd)
        {
            // nullや空文字列をチェック
            if (string.IsNullOrWhiteSpace(yyyyMmDd))
            {
                return DateTime.MinValue; // nullや空の場合はDateTime.MinValueを返す
            }

            try
            {
                // "yyyyMMdd"のフォーマットで変換して戻す
                return DateTime.ParseExact(yyyyMmDd, "yyyyMMdd", null);
            }
            catch
            {
                // 変換に失敗した場合もDateTime.MinValueを返す
                return DateTime.MinValue;
            }
        }

        /// <summary>
        /// 貴院導入（自施設にて期間内の一番古い日付）
        /// </summary>
        /// <param name="patID"></param>
        /// <returns></returns>
        public static async Task<(DateTime regDate, string fromFacility)> GetPatIntroduceToHospitalAsync(long patID, string facility)
        {
            // データ取得
            PatUniqueInitDateResponse patUniqueInitDateResult = await StatisticsLib.GetPatUniqueInitDate(
                new SysDataSetRequest(
                    sqlCd: -1000029,
                    patId: patID,
                    fromDate: Settings.Default.PeriodStart.ToString("yyyy/MM/dd"),
                    toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd")
                )
            );
            List<PatUniqueInitDateDataType> patUniqueInitDateList = patUniqueInitDateResult.Data;
            DataTable dt = StatisticsUtility.ConvertToDataTable(patUniqueInitDateList, null);

            // レコードなしの場合
            if (dt == null || dt.Rows.Count == 0)
            {
                return (DateTime.MinValue, string.Empty);
            }

            // facility に一致する行を探す
            foreach (DataRow row in dt.Rows)
            {
                string rowFacility = row["FROM_FACILITY"] as string ?? string.Empty;


                if (rowFacility != null)
                {
                    if (rowFacility == string.Empty)
                    {
                        if (DateTime.TryParseExact(row["REG_DATE"].ToString(), "yyyyMMdd",
                                                   CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime regDate))
                        {
                            return (regDate, rowFacility);
                        }
                    }
                    else
                    {
                        string matchcode = FrmStatistics.ConvFacility(rowFacility);
                        string configCode = ConfigHelper.ReadSetting("FacilityCode") ?? "";
                        if (matchcode == configCode)
                        {
                            if (DateTime.TryParseExact(row["REG_DATE"].ToString(), "yyyyMMdd",
                                                       CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime regDate))
                            {
                                return (regDate, rowFacility);
                            }
                        }
                    }
                }
            }

            // 一致する施設がなかった場合
            return (DateTime.MinValue, string.Empty);
        }

        /// <summary>
        /// 透析導入日の取得（一番古い日付）
        /// </summary>
        /// <param name="patID"></param>
        /// <returns></returns>
        public static async Task<DateTime> GetPatUniqueInitDateAsync(long patID)
        {
            PatUniqueInitDateResponse patUniqueInitDateResult = await StatisticsLib.GetPatUniqueInitDate(
                new SysDataSetRequest(
                    sqlCd: -1000029,
                    patId: patID,
                    fromDate:Settings.Default.SearchExamStart.ToString("yyyy/MM/dd"),
                    toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd")
                )
            );
            List<PatUniqueInitDateDataType> patUniqueInitDateList = patUniqueInitDateResult.Data;
            DataTable dt = StatisticsUtility.ConvertToDataTable(patUniqueInitDateList, null);

            // 透析導入日のレコードなしの場合
            if (null == dt)
            {
                return DateTime.MinValue;
            }

            if (0 == dt.Rows.Count)
            {
                return DateTime.MinValue;
            }
            DateTime regDate;
            if (DateTime.TryParseExact(dt.Rows[0]["REG_DATE"].ToString(), "yyyyMMdd", CultureInfo.InvariantCulture, DateTimeStyles.None, out regDate))
            {
                return regDate;
            }
            else
            {
                return DateTime.MinValue;
            }
        }

        /// <summary>
        /// 転入日情報
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="patID">患者ID</param>
        /// <param name="FicilityName">out 転入元施設名</param>
        /// <param name="pat_inoutCd">転入・転帰区分</param>
        /// <param name="FicilityCd">out 転入元施設コード</param>
        /// <returns>取得した日付(データ無しはDateTime.MinValue)</returns>
        //public static DateTime GetInDay(ILogInfo logInfo, string patID, out string FicilityName, string pat_inoutCd)
        // 2021年度対応　転入元施設コードの追加
        public static async Task<(DateTime acquiredDate, string fromFicilityCd, string toFicilityName)> GetInDayAsync(long patID, string pat_inoutCd)
        {
            string fromFicilityName = string.Empty;
            string toFicilityName = string.Empty;

            MovingInDateResponse movingInDateResult = await StatisticsLib.GetMovingInDate(
                new SysDataSetRequest(
                    sqlCd: -1000025,
                    patId: patID,
                    toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd")
                )
            );
            List<MovingInDateDataType> movingInDateList = movingInDateResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(movingInDateList, null);

            if (null == dt)
            {
                // エラーもここでは無し扱い
                return (DateTime.MinValue, string.Empty, string.Empty); 
            }
            if (0 == dt.Rows.Count)
            {
                return (DateTime.MinValue, string.Empty, string.Empty);
            }

            if (dt.Rows[0]["REG_DATE"] != DBNull.Value && !string.IsNullOrEmpty(dt.Rows[0]["REG_DATE"].ToString()))
            {
                if (dt.Rows[0]["FROM_FACILITY_NAME"] is string)
                {
                    toFicilityName = dt.Rows[0]["TO_FACILITY_NAME"] as string;
                    fromFicilityName = dt.Rows[0]["FROM_FACILITY_NAME"] as string;

                }
                DateTime regDate;
                //                if (DateTime.TryParseExact(dt.Rows[0]["REG_DATE"].ToString(), "yyyyMMdd", out regDate))
                if (DateTime.TryParseExact(dt.Rows[0]["REG_DATE"].ToString(), "yyyyMMdd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out regDate))
                {
                    return (regDate, fromFicilityName, toFicilityName);
                }
                else
                {
                    return (DateTime.MinValue, string.Empty, string.Empty);
                }              
            }

            return (DateTime.MinValue, string.Empty, string.Empty);
        }

        /// <summary>
        /// 患者の在住県コード取得
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="patID">患者ID</param>
        /// <returns>(学会)在住県コード</returns>
        public static async Task<string> GetZipCodeAsync(long patID)
        {
            ZipCodeResponse zipCodeResult = await StatisticsLib.GetZipCode(
                new SysDataSetRequest(
                    sqlCd: -1000104,
                    patId: patID
                )
            );
            List<ZipCodeDataType> zipCodeList = zipCodeResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(zipCodeList, null);
            if (null == dt)
            {
                // TODO 2015年度対応（未設定項目に不明コードを設定）←非対応
                return string.Empty;
                //return ZIP_CODE_Unknown;
            }

            if (1 != dt.Rows.Count)
            {
                // TODO 2015年度対応（未設定項目に不明コードを設定）←非対応
                return string.Empty;
                //return ZIP_CODE_Unknown;
            }
            // 住所から都道府県コードに変換
            if (dt.Rows[0]["ADDRESS"] == DBNull.Value)
            {
                return string.Empty;
            }
            return StaticFunctions.ConvZipCode((dt.Rows[0]["ADDRESS"] as string).Trim('\"'));
        }

        /// <summary>
        /// 住所を都道府県コードに変換
        /// </summary>
        /// <param name="address">都道府県から始まる住所</param>
        /// <returns>変換した学会都道府県コード</returns>
        private static string ConvZipCode(string address)
        {
            if (string.IsNullOrEmpty(address))
            {
                return string.Empty;
            }

            // 全件前方一致は処理が大変なので1文字目だけ評価してからチェック
            switch (address[0])
            {
                case '北': if (address.StartsWith("北海道")) { return "01"; } break;
                case '青': if (address.StartsWith("青森県")) { return "02"; } break;
                case '岩': if (address.StartsWith("岩手県")) { return "03"; } break;
                case '宮': if (address.StartsWith("宮城県")) { return "04"; } else if (address.StartsWith("宮崎県")) { return "45"; } break;
                case '秋': if (address.StartsWith("秋田県")) { return "05"; } break;
                case '山': if (address.StartsWith("山形県")) { return "06"; } else if (address.StartsWith("山梨県")) { return "19"; } else if (address.StartsWith("山口県")) { return "35"; } break;
                case '福': if (address.StartsWith("福島県")) { return "07"; } else if (address.StartsWith("福井県")) { return "18"; } else if (address.StartsWith("福岡県")) { return "40"; } break;
                case '茨': if (address.StartsWith("茨城県")) { return "08"; } break;
                case '栃': if (address.StartsWith("栃木県")) { return "09"; } break;
                case '群': if (address.StartsWith("群馬県")) { return "10"; } break;
                case '埼': if (address.StartsWith("埼玉県")) { return "11"; } break;
                case '千': if (address.StartsWith("千葉県")) { return "12"; } break;
                case '東': if (address.StartsWith("東京都")) { return "13"; } break;
                case '神': if (address.StartsWith("神奈川県")) { return "14"; } break;
                case '新': if (address.StartsWith("新潟県")) { return "15"; } break;
                case '富': if (address.StartsWith("富山県")) { return "16"; } break;
                case '石': if (address.StartsWith("石川県")) { return "17"; } break;
                case '長': if (address.StartsWith("長野県")) { return "20"; } else if (address.StartsWith("長崎県")) { return "42"; } break;
                case '岐': if (address.StartsWith("岐阜県")) { return "21"; } break;
                case '静': if (address.StartsWith("静岡県")) { return "22"; } break;
                case '愛': if (address.StartsWith("愛知県")) { return "23"; } else if (address.StartsWith("愛媛県")) { return "38"; } break;
                case '三': if (address.StartsWith("三重県")) { return "24"; } break;
                case '滋': if (address.StartsWith("滋賀県")) { return "25"; } break;
                case '京': if (address.StartsWith("京都府")) { return "26"; } break;
                case '大': if (address.StartsWith("大阪府")) { return "27"; } else if (address.StartsWith("大分県")) { return "44"; } break;
                case '兵': if (address.StartsWith("兵庫県")) { return "28"; } break;
                case '奈': if (address.StartsWith("奈良県")) { return "29"; } break;
                case '和': if (address.StartsWith("和歌山県")) { return "30"; } break;
                case '鳥': if (address.StartsWith("鳥取県")) { return "31"; } break;
                case '島': if (address.StartsWith("島根県")) { return "32"; } break;
                case '岡': if (address.StartsWith("岡山県")) { return "33"; } break;
                case '広': if (address.StartsWith("広島県")) { return "34"; } break;
                case '徳': if (address.StartsWith("徳島県")) { return "36"; } break;
                case '香': if (address.StartsWith("香川県")) { return "37"; } break;
                case '高': if (address.StartsWith("高知県")) { return "39"; } break;
                case '佐': if (address.StartsWith("佐賀県")) { return "41"; } break;
                case '熊': if (address.StartsWith("熊本県")) { return "43"; } break;
                case '鹿': if (address.StartsWith("鹿児島県")) { return "46"; } break;
                case '沖': if (address.StartsWith("沖縄県")) { return "47"; } break;
                //default: return "48";//外国
                default: return "";//市町村のみの入力も外国になってしまう為、外国廃止
            }

            return string.Empty;
        }

        /// <summary>
        /// 患者基本情報テーブルを取得
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="patID">患者ID</param>
        /// <returns>DataTable</returns>
        public static async Task<DataTable> GetPatBasicInfoAsync(long patID)
        {
            PatInfoResponse patInfoResult = await StatisticsLib.GetPatInfo(
                new SysDataSetRequest(
                    sqlCd: -1000105,
                    patId: patID
                )
            );
            List<PatInfoDataType> patInfoList = patInfoResult.Data;
            // DataTableに変換
            DataTable dt1 = StatisticsUtility.ConvertToDataTable(patInfoList, null);
            if (null == dt1)
            {
                return null;
            }
            PatMainInfoResponse patMainInfoResult = await StatisticsLib.GetPatMainInfo(
                new SysDataSetRequest(
                    sqlCd: -1000007,
                    patId: patID
                )
            );
            List<PatMainInfoDataType> patMainInfoList = patMainInfoResult.Data;
            // DataTableに変換
            DataTable dt2 = StatisticsUtility.ConvertToDataTable(patMainInfoList, null);
            // 結果を保持するためのDataTableを作成
            DataTable dt = new DataTable();
            dt.Columns.Add("PATID", typeof(long));
            dt.Columns.Add("DISP_PATID", typeof(string));
            dt.Columns.Add("NAME", typeof(string));
            dt.Columns.Add("SEX_CD", typeof(short));
            dt.Columns.Add("DIE_CD", typeof(int));
            dt.Columns.Add("DIE_DATE", typeof(DateTime));
            dt.Columns.Add("BIRTHDAY", typeof(string));
            dt.Columns.Add("NAME_KANA", typeof(string));
            dt.Columns.Add("INSTITUTION_CD", typeof(string));
            dt.Columns.Add("BASE_DISEASE_CD", typeof(int));
            dt.Columns.Add("DIAL_START_DATE", typeof(string));
            dt.Columns.Add("DIABETES", typeof(string));

            // テーブルのpatidに基づいて、テーブルからdisp_patidを取得し、結合する
            foreach (DataRow rowTemp in dt1.Rows)
            {
                DataRow newRow = dt.NewRow();
                newRow["PATID"] = rowTemp["PATID"];
                newRow["DISP_PATID"] = rowTemp["DISP_PATID"];
                newRow["NAME"] = rowTemp["NAME"];
                newRow["SEX_CD"] = rowTemp["SEX_CD"];
                newRow["DIE_CD"] = rowTemp["DIE_CD"];
                newRow["DIE_DATE"] = rowTemp["DIE_DATE"];
                newRow["BIRTHDAY"] = rowTemp["BIRTHDAY"];
                newRow["NAME_KANA"] = rowTemp["NAME_KANA"];
                newRow["BASE_DISEASE_CD"] = rowTemp["BASE_DISEASE_CD"];

                // テーブルからpatidをキーに探す
                DataRow[] matchingRows = dt2.Select($"PATID = {rowTemp["PATID"]}");
                if (matchingRows.Length > 0)
                {
                    newRow["INSTITUTION_CD"] = matchingRows[0]["INSTITUTION_CD"];
                    newRow["DIAL_START_DATE"] = matchingRows[0]["DIAL_START_DATE"];
                    newRow["DIABETES"] = matchingRows[0]["DIABETES"];
                }
                else
                {
                    newRow["DISP_PATID"] = DBNull.Value;
                    newRow["DIAL_START_DATE"] = DBNull.Value;
                    newRow["DIABETES"] = DBNull.Value;
                }
                dt.Rows.Add(newRow);
            }

            return dt;
        }

        /// <summary>
        /// 生年月日を和暦で指定列に格納
        /// </summary>
        /// <param name="birthday">生年月日を表すYYYYMMDDフォーマット文字列</param>
        /// <param name="row">格納先DataRow</param>
        /// <param name="year">年を格納する列インデックス</param>
        /// <param name="month">月を格納する列インデックス</param>
        /// <param name="day">日を格納する列インデックス</param>
        public static void SetBirthday(string birthday, ref DataRow row, int year, int month, int day)
        {
            // 文字列を日付に変換
            DateTime work = StaticFunctions.YyyyMmDdToDay(birthday);
            if (DateTime.MinValue.Equals(work))
            {
                // TODO 2015年度対応（未設定項目に不明コードを設定）←非対応
                //row[year] = "9999";
                //row[month] = "99";
                //row[day] = "99";
                return;
            }

            // 和暦にするためのカレンダー作成
            //JapaneseCalendar cal = new JapaneseCalendar();
            try
            {
                // 西暦の年月日を取得
                row[year] = work.ToString("yyyy");
                row[month] = work.ToString("%M");
                row[day] = work.ToString("%d");
            }
            catch (Exception ex)
            {
                // 例外が発生した場合は全部リセット
                row[year] = "";
                row[month] = "";
                row[day] = "";
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(StatisticsConst), NKKLogging.LOGGING_CLASS.ERROR, String.Format("西暦作成エラー 文字列：,{0},{1}", birthday, ex.ToString().Replace("\r\n", "{CRLF}")));
            }
        }

        /// <summary>
        /// 設定期間内の最後の透析番号を取得
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="patID">対象患者ID</param>
        /// <returns>透析番号</returns>
        /// public static string GetDialysisNo(ILogInfo logInfo, string patID, bool TreatTypeFlg)
        public static async Task<string> GetDialysisNoAsync(long patID)
        {
            LastOrdNoResponse lastOrdNoResult = await StatisticsLib.GetLastOrdNo(
                new SysDataSetRequest(
                    sqlCd: -1000008,
                    patId: patID,
                    fromDate: Settings.Default.PeriodStart.ToString("yyyy/MM/dd"),
                    toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd")
                )
            );
            List<LastOrdNoDataType> lastOrdNoList = lastOrdNoResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(lastOrdNoList, null);
            if (null == dt)
            {
                return null;
            }

            if (0 == dt.Rows.Count)
            {
                return string.Empty;
            }

            if (dt.Rows[0]["DIALYSIS_NO"] is long)
            {
                return ((long)dt.Rows[0]["DIALYSIS_NO"]).ToString();
            }

            return string.Empty;
        }

        /// <summary>
        /// 転出情報のセット
        /// </summary>
        /// <param name="logInfo">db操作</param>
        /// <param name="patID">患者ID</param>
        /// <param name="row">行情報</param>
        /// <param name="kbn">区分位置</param>
        /// <param name="yyyy">年位置</param>
        /// <param name="month">月位置</param>
        /// <param name="facility">施設コード</param>
        /// <param name="die_info">死因コード</param>
        /// <param name="die_date">死亡日時</param>
        /// <param name="die_code">死亡コード</param>
        /// <param name="treat_method">治療コード</param>
        /// <returns></returns>
        public static async Task<(bool sccess, DataRow row)> SetOutInfoAsync(long patID, DataRow row, int kbn,
                                            int yyyy, int month, int facility, int die_info, int treat_method, string die_date,
                                            string die_code)
        {
            MovingOutInfoResponse movingOutInfoResult = await StatisticsLib.GetMovingOutInfo(
                new SysDataSetRequest(
                    sqlCd: -1000009,
                    patId: patID,
                    fromDate: Settings.Default.PeriodStart.ToString("yyyy/MM/dd"),
                    toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd")
                )
            );
            List<MovingOutInfoDataType> movingOutInfoList = movingOutInfoResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(movingOutInfoList, null);
            if (null == dt)
            {
                return (false, row);
            }
            if (0 != dt.Rows.Count)
            {

                if (!string.IsNullOrEmpty(dt.Rows[0]["REG_DATE"].ToString()))
                {
                    //転出区分をセットする
                    //転出区分
                    //1:転出
                    //2:死亡
                    //3:離脱
                    //4:移植
                    if (dt.Rows[0]["INOUT_CD"].ToString().Equals("3"))
                    {
                        //転出
                        row[kbn] = "1";
                        row[facility] = FrmStatistics.ConvFacility(dt.Rows[0]["FACILITY_NAME"] as string);
                    }
                    else if (dt.Rows[0]["INOUT_CD"].ToString().Equals("11"))
                    {
                        //死亡
                        //2012.11.29 
                        //死亡の場合は施設コードを出力しない
                        //但し死亡の場合は死因コードを入力する
                        row[kbn] = "2";
                        row[facility] = "";
                        if (!string.IsNullOrEmpty(die_date))
                        {
                            DateTime day = DateTime.Parse(die_date);
                            if ((Settings.Default.PeriodStart <= day) &&
                                        (day < Settings.Default.PeriodEnd))
                            {
                                row[die_info] = FrmStatistics.ConvDie(die_code);
                            }
                        }
                    }
                    //2014年版修正（離脱・移植の追加）
                    else if (dt.Rows[0]["INOUT_CD"].ToString().Equals("7"))
                    {
                        //離脱
                        //離脱の場合は治療方法を"70"を出力
                        row[kbn] = "3";
                        row[facility] = "";
                        row[treat_method] = "70";
                    }
                    else if (dt.Rows[0]["INOUT_CD"].ToString().Equals("8"))
                    {
                        //移植
                        row[kbn] = "4";
                        row[facility] = "";
                    }
                    DateTime reg = DateTime.ParseExact(dt.Rows[0]["REG_DATE"].ToString(), "yyyyMMdd", CultureInfo.InvariantCulture);
                    row[yyyy] = reg.ToString("yyyy");
                    row[month] = reg.Month.ToString("00");

                }
            }
            return (true, row);
        }

        /// <summary>
        /// 治療方法コード取得(学会コードへの変換済み)
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="dialysisNo">取得する実績の透析番号</param>
        /// <returns>取得したコード(null：エラー)</returns>
        public static async Task<string> GetTreatItemAsync(long dialysisNo)
        {
            TreatmentCdResponse treatmentCdResult = await StatisticsLib.GetTreatmentCd(
                new SysDataSetRequest(
                    sqlCd: -1000010,
                    ordNo: dialysisNo
                )
            );
            List<TreatmentCdDataType> treatmentCdList = treatmentCdResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(treatmentCdList, null);

            if (null == dt)
            {
                return null;
            }

            if (1 != dt.Rows.Count)
            {
                return string.Empty;
            }

            return FrmStatistics.ConvTreatItem(dt.Rows[0]["VALUE"] as string);
        }

        /// <summary>
        /// 週透析回数取得
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="dialysisNo">基準となる透析番号</param>
        /// <returns>基準となる透析日を含め前7日間の透析実績数</returns>
        public static async Task<string> GetDialysisWeeklyCountAsync(long dialysisNo )
        {
            //(1)最終透析日から１週間前の日を基準とする過去一週間の透析回数を取得
            string count = await GetDialysisWeeklyCountSubAsync(dialysisNo, -7);

            if (null == count)
            {
                return null;
            }

            //(1)の透析回数が０回でない場合のみ値を返す
            if ("0" != count)
            {
                return count;
            }

            //(2)最終透析日を基準とする過去一週間の透析回数を取得
            return await GetDialysisWeeklyCountSubAsync(dialysisNo, 0);
        }

        /// <summary>
        /// 週透析回数取得(サブ)　※旧GetDialysisWeeklyCountを引数daysを追加し、サブメソッド化
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="dialysisNo">基準となる透析番号</param>
        /// <param name="days">基準日算出日数(最終透析日からの加算日数)</param>
        /// <returns>週透析回数(実績数)</returns>
        public static async Task<string> GetDialysisWeeklyCountSubAsync(long dialysisNo, int days)
        {
            //2013年版修正(ECUMについてはDBバージョンに関わらず除外する)
            //特殊血液浄化は回数に入れないよう修正
            DialysisCountInRangeResponse dialysisCountInRangeResult = await StatisticsLib.GetDialysisCountInRange(
                new SysDataSetRequest(
                    sqlCd: -1000011,
                    ordNo: dialysisNo,
                    days: days
                )
            );
            List<DialysisCountInRangeDataType> dialysisCountInRangeList = dialysisCountInRangeResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(dialysisCountInRangeList, null);


            if (null == dt)
            {
                return null;
            }

            return ((long)dt.Rows[0][0]).ToString();
        }

        /// <summary>
        /// 透析時間取得
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="dialysisNo">透析時間を取得する透析番号</param>
        /// <returns>透析時間(分を文字列で)</returns>
        public static async Task<string> GetDialysisTimeAsync(long dialysisNo)
        {
            //2013年版修正(設定ファイルの設定値により透析時間を指示値または実績値に切り替える)
            //指示データを使用する設定の場合
            if (CustomizeSettings.Instance.IsDispIndDialysisTime)
            {
                //指示データ取得(001:透析時間)
                DataTable dtInd = await StaticFunctions.GetIndDialysisCondAsync(dialysisNo, "1");

                if (null == dtInd)
                {
                    return null;
                }

                if (0 != dtInd.Rows.Count)
                {
                    //データが抽出できていれば値を返す
                    if (dtInd.Rows[0]["VALUE"] is string)
                    {
                        return dtInd.Rows[0]["VALUE"] as string;
                    }
                }
            }

            //実績データの透析時間取得
            DialysisTimeResponse dialysisTimeResult = await StatisticsLib.GetDialysisTime(
                new SysDataSetRequest(
                    sqlCd: -1000012,
                    ordNo: dialysisNo
                )
            );
            List<DialysisTimeDataType> dialysisTimeList = dialysisTimeResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(dialysisTimeList, null);
            if (null == dt)
            {
                return null;
            }
            if (0 == dt.Rows.Count)
            {
                return string.Empty;
            }
            if (dt.Rows[0]["DIALYSIS_TIME"] is decimal)
            {
                return ((decimal)dt.Rows[0]["DIALYSIS_TIME"]).ToString();
            }

            return string.Empty;
        }


        /// <summary>
        /// 条件指示展開データ取得
        /// ※「GetDialysisBlood：最新透析番号から血流量を調べ返す」内にあったロジックを汎用的に使用するため独立
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="dialysisNo">透析時間を取得する透析番号</param>
        /// <param name="ctlNo">項目番号</param>
        /// <returns>設定値</returns>
        private static async Task<DataTable> GetIndDialysisCondAsync(long dialysisNo,string ctlNo)
        {
            //今まで通り取得
            //実績データの透析時間取得
            IndDialysisCondResponse indDialysisCondResult = await StatisticsLib.GetIndDialysisCond(
                new SysDataSetRequest(
                    sqlCd: -1000013,
                    ordNo: dialysisNo,
                    ctlNo: ctlNo
                )
            );
            List<IndDialysisCondDataType> indDialysisCondList = indDialysisCondResult.Data;

            return StatisticsUtility.ConvertToDataTable(indDialysisCondList, null); 
        }

        /// <summary>
        /// 最新透析番号から血流量を調べ返す
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="dialysisNo">透析時間を取得する透析番号</param>
        /// <returns>血流量</returns>
        public static async Task<string> GetDialysisBloodAsync(long dialysisNo)
        {
            //条件指示展開データ取得(010:血流量)
            DataTable dtInd = await StaticFunctions.GetIndDialysisCondAsync(dialysisNo, "14");

            if (null == dtInd)
            {
                return null;
            }

            if (0 != dtInd.Rows.Count)
            {
                //データが抽出できていれば処理を続行
                if (dtInd.Rows[0]["VALUE"] is string)
                {
                    return dtInd.Rows[0]["VALUE"] as string;
                }
            }
            else
            {
                //指示展開からデータ取得できなかった。
                //実績からデータを取得する
                DataTable dtRst = await StaticFunctions.GetRstDialysisCondAsync(dialysisNo, "14");

                if (null == dtRst)
                {
                    return null;
                }
                if (0 == dtRst.Rows.Count)
                {
                    return string.Empty;
                }
                if (dtRst.Rows[0]["VALUE"] is string)
                {
                    return dtRst.Rows[0]["VALUE"] as string;
                }
            }

            return string.Empty;
        }

        /// <summary>
        /// 透析実績透析条件データ取得
        /// ※「GetDialysisBlood：最新透析番号から血流量を調べ返す」内にあったロジックを汎用的に使用するため独立
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="dialysisNo">透析時間を取得する透析番号</param>
        /// <param name="ctlNo">項目番号</param>
        /// <returns>設定値</returns>
        private static async Task<DataTable> GetRstDialysisCondAsync(long dialysisNo, string ctlNo)
        {
            RstDialysisCondResponse rstDialysisCondResult = await StatisticsLib.GetRstDialysisCond(
                new SysDataSetRequest(
                    sqlCd: -1000014,
                    ordNo: dialysisNo,
                    ctlNo: ctlNo
                )
            );
            List<RstDialysisCondDataType> rstDialysisCondList = rstDialysisCondResult.Data;

            return StatisticsUtility.ConvertToDataTable(rstDialysisCondList, null);
        }

        /// <summary>
        /// HDF希釈方法取得
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="dialysisNo">透析時間を取得する透析番号</param>
        /// <returns>HDF希釈方法</returns>
        public static async Task<string> GetDilutionAsync(long dialysisNo)
        {
            //2013年版修正(FNWデータ取得化)
            //指示データを使用する設定の場合
            if (CustomizeSettings.Instance.IsDispIndHemodiafiltrationInfo)
            {
                //指示データ取得(024:補液選択)
                DataTable dtInd = await StaticFunctions.GetIndDialysisCondAsync(dialysisNo, "21");

                if (null == dtInd)
                {
                    return null;
                }

                if (0 != dtInd.Rows.Count)
                {
                    //データが抽出できていれば値を返す
                    if (dtInd.Rows[0]["VALUE"] is string)
                    {
                        return StaticFunctions.ConvDilutionCode(dtInd.Rows[0]["VALUE"] as string);
                    }
                }
            }

            //実績データ取得(024:補液選択)
            DataTable dtRst = await StaticFunctions.GetRstDialysisCondAsync(dialysisNo, "21");

            if (null == dtRst)
            {
                return null;
            }
            if (0 == dtRst.Rows.Count)
            {
                return string.Empty;
            }
            if (dtRst.Rows[0]["VALUE"] is string)
            {
                return StaticFunctions.ConvDilutionCode(dtRst.Rows[0]["VALUE"] as string);
            }

            return string.Empty;
        }

        /// <summary>
        /// 補液選択を学会コード(希釈方法)に変換
        /// </summary>
        /// <param name="fnwCode"></param>
        /// <returns></returns>
        private static string ConvDilutionCode(string fnwCode)
        {
            switch (fnwCode)
            {
                //前希釈
                case "1":
                    return "A";
                //後希釈
                case "0":
                    return "B";
            }

            //上記以外
            return string.Empty;
        }

        /// <summary>
        /// １セッションあたりの置換液量(L)取得
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="dialysisNo">透析時間を取得する透析番号</param>
        /// <returns>１セッションあたりの置換液量(L)</returns>
        public static async Task<string> GetFluidReplacementAsync(long dialysisNo)
        {
            //2013年版修正(FNWデータ取得化)
            //指示データを使用する設定の場合
            if (CustomizeSettings.Instance.IsDispIndHemodiafiltrationInfo)
            {
                //指示データ取得(023:補液量)
                DataTable dtInd = await StaticFunctions.GetIndDialysisCondAsync(dialysisNo, "20");

                if (null == dtInd)
                {
                    return null;
                }

                if (0 != dtInd.Rows.Count)
                {
                    //データが抽出できていれば値を返す
                    if (dtInd.Rows[0]["VALUE"] is string)
                    {
                        string str = dtInd.Rows[0]["VALUE"] as string;
                        str = str.Trim();
                        double dbl = double.Parse(str);
                        return dbl.ToString();
                        //return dtInd.Rows[0]["VALUE"] as string;
                    }
                }
            }

            //実績値データ取得(023:補液量)
            DataTable dtRst = await StaticFunctions.GetRstDialysisCondAsync(dialysisNo, "20");

            if (null == dtRst)
            {
                return null;
            }
            if (0 == dtRst.Rows.Count)
            {
                return string.Empty;
            }
            if (dtRst.Rows[0]["VALUE"] is string)
            {
                string str = dtRst.Rows[0]["VALUE"] as string;
                str = str.Trim();
                double dbl = double.Parse(str);
                return dbl.ToString();
            }

            return string.Empty;
        }

        /// <summary>
        /// 身長の取得
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="patID">患者番号</param>
        /// <returns>身長データ</returns>
        public static async Task<string> GetHeightAsync(long  patID)
        {
            //実績データの透析時間取得
            HeightResponse heightResult = await StatisticsLib.GetHeight(
                new SysDataSetRequest(
                    sqlCd: -1000015,
                    patId: patID,
                    fromDate: Settings.Default.PeriodStart.ToString("yyyy/MM/dd"),
                    toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd")
                )
            );
            List<HeightDataType> heightList = heightResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(heightList, null);
            if (null == dt)
            {
                return "false";
            }
            if (0 != dt.Rows.Count)
            {
                return dt.Rows[0][0].ToString();
            }
            else
            {
                return "false";
            }
        }

        /// <summary>
        /// 体重情報格納(BUN,クレアチニンの情報とセットで格納)
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="patID">患者ID</param>
        /// <param name="row">結果格納先DataRowインスタンス</param>
        /// <param name="dtFirstDialysisDay">第１透析日データ</param>
        /// <param name="weightBefore">前体重格納先列番号</param>
        /// <param name="weightAfter">後体重格納先列番号</param>
        /// <param name="bunBefore">透析前BUN格納先列番号</param>
        /// <param name="bunAfter">透析前BUN格納先列番号</param>
        /// <param name="creBefore">透析前CREATININE格納先列番号</param>
        /// <param name="creAfter">透析前CREATININE格納先列番号</param>
        /// <param name="usingOrderClass">検査結果前後使用区分</param>
        /// <param name="dialysisNo">処理が成功した時の透析番号</param>
        /// <param name="examDate">処理が成功した時の検査日</param>
        /// <returns>true：成功 false：失敗</returns>
        public static async Task<(bool success, DataRow row, string dialysisNo, DateTime examDate)> SetWeightAsync(
            long patID,
            DataRow row,
            DataTable dtFirstDialysisDay,
            int weightBefore,
            int weightAfter,
            int bunBefore,
            int bunAfter,
            int creBefore,
            int creAfter,
            string usingOrderClass,
            string dialysisNo,
            DateTime examDate)
        {
            //実績データの透析時間取得
            // BUNの検査結果はFNWコードに変換した上でバインド
            // 2020年版対応（血圧の取得変更対応）
            //2013年版修正(クレアチニン濃度も体重とセットで格納するように変更)
            //2013年版修正(ECUMについてはDBバージョンに関わらず除外する)
            //2013年版修正(特殊血液浄化については新DBバージョンのみ除外する)
            //2013年版修正(同日内で複数の検査データおよび実績データが存在する場合、その日の最も過去のデータのみを取得するように変更)
            ExamFindingsResponse examFindingsResult = await StatisticsLib.GetExamFindings(
                new SysDataSetRequest(
                    sqlCd: -1000022,
                    patId: patID,
                    fromDate: Settings.Default.PeriodStart.ToString("yyyy/MM/dd"),
                    toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd"),
                    orderClass: usingOrderClass,
                    examCdBun: FrmStatistics.ConvExamItem(StatisticsConst.EXAM_BUN),
                    examCdCre: FrmStatistics.ConvExamItem(StatisticsConst.EXAM_CREATININE),
                    examCdBunAfter: FrmStatistics.ConvExamItem(StatisticsConst.EXAM_BUN_AFTER),
                    examCdCreAfter: FrmStatistics.ConvExamItem(StatisticsConst.EXAM_CREATININE_AFTER)
                )
            );

            List<ExamFindingsDataType> examFindingsList = examFindingsResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(examFindingsList, null);
            if (null == dt)
            {
                return (false, row, dialysisNo, examDate);
            }

            if (0 == dt.Rows.Count)
            {
                return (true, row, dialysisNo, examDate);
            }

            //2013年版修正(検査結果の第１透析日判定機能を追加)
            int index = 0;
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                // 対象レコードの検査日が第１透析日かどうか
                DataRow[] work = dtFirstDialysisDay.Select("DIALYSIS_DATE = '" + dt.Rows[i]["EXAM_DAY"] as string + "'");

                if (1 == work.Length)
                {
                    index = i;
                    break;
                }
            }

            if (dt.Rows[index]["WEIGHT_BEFORE"] is decimal)
            {
                row[weightBefore] = ((decimal)dt.Rows[index]["WEIGHT_BEFORE"]).ToString();
            }
            if (dt.Rows[index]["WEIGHT_AFTER"] is decimal)
            {
                row[weightAfter] = ((decimal)dt.Rows[index]["WEIGHT_AFTER"]).ToString();
            }

            row[bunBefore] = dt.Rows[index]["RST_BUN_BEFORE"] as string;
            row[bunAfter] = dt.Rows[index]["RST_BUN_AFTER"] as string;
            //2013年版修正(クレアチニン濃度も体重とセットで格納するように変更)
            row[creBefore] = dt.Rows[index]["RST_CRE_BEFORE"] as string;
            row[creAfter] = dt.Rows[index]["RST_CRE_AFTER"] as string;
            // 2020年版対応（血圧の取得変更対応）
            if (dt.Rows[index]["DIALYSIS_NO"] is int)
            {
                dialysisNo = ((int)dt.Rows[index]["DIALYSIS_NO"]).ToString();
            }
            //【2022年度版対応】2021年度までの未対応分の改修
            if (dt.Rows[index]["EXAM_DATE"] is DateTime)
            {
                examDate = (DateTime)dt.Rows[index]["EXAM_DATE"];
            }
            return (true, row, dialysisNo, examDate);
        }

        /// <summary>
        /// その他の検査結果格納処理
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="patID">対象患者ID</param>
        /// <param name="row">結果格納先DataRowインスタンス</param>
        /// <param name="dtFirstDialysisDay">第１透析日データ</param>
        /// <param name="calcium">カルシウム検査結果格納先列番号</param>
        /// <param name="phosphorus">リン検査結果格納先列番号</param>
        /// <param name="albumin">アルブミン検査結果格納先列番号</param>
        /// <param name="crp">CRP検査結果格納先列番号</param>
        /// <param name="hemoglobin">ヘモグロビン検査結果格納先列番号</param>
        /// <param name="pth">PTH検査結果格納先列番号</param>
        /// <param name="totalCholesterol">総コレステロール検査結果格納先列番号</param>
        /// <param name="hdlCholesterol">HDL-C検査結果格納先列番号</param>
        ///// <param name="ldlCholesterol">LDL-C検査結果格納先列番号</param>
        ///// <param name="triglyceride">中性脂肪検査結果格納先列番号</param>
        /// <param name="usingOrderClass">検査結果前後使用区分</param>
        /// <param name="examDate">検査日</param>
        /// <returns>true：成功 false：失敗</returns>
        public static async Task<(bool sccess, DataRow row)> SetOtherExamAsync(
                                        long patID,
                                        DataRow row,
                                        DataTable dtFirstDialysisDay,   //2013年版修正(検査結果の第１透析日判定機能を追加)
            //int creatinineBefore,                                     //2013年版修正(クレアチニン濃度も体重とセットで格納するように変更)
            //int creatinineAfter,                                      //2013年版修正(クレアチニン濃度も体重とセットで格納するように変更)
                                        int calcium,
                                        int phosphorus,
                                        int albumin,
                                        int crp,
                                        int hemoglobin,
                                        int pth,
            //int uricAcid,
                                        int totalCholesterol,
                                        int hdlCholesterol,
                                        //int ldlCholesterol,         //2025年度対象外項目、2024年度新設項目：LDL
                                        //int triglyceride,           //2025年度対象外項目、2024年度新設項目：中性脂肪
                                        //int alt,                //2019年度除外項目：ALT
                                        //int ga,                 //2019年度除外項目：グリコアルブミン
                                        //int hba1c,              //2019年度除外項目：ヘモグロビンA1c
                                        //int b2mgBefore,
                                        //int b2mgAfter,
                                        string usingOrderClass,  //2015年版：検査結果前後対応
                                        DateTime examDate       //【2022年度版対応】2021年度までの未対応分の改修
            // 2020年度修正(調査対象外となった項目の対応)
            // 2023年度 調査対象外
                                        //int Fer,              //2019年度復活項目、2022年度復活項目：血清フェリチン
                                        //int Fe,               //2019年度復活項目、2022年度復活項目：血清鉄濃度
                                        //int TIBC              //2019年度復活項目、2022年度復活項目：総鉄結合能
            // END
                                        //int ALP,            //2019年度追加項目：ALP値
                                        //int Mg              //2019年度追加項目：マグネシウム濃度
                                       )
        {
            if (usingOrderClass == "0")
            {
                if (examDate == DateTime.MinValue)
                {
                    //検査項目設定画面のチェックボックスにチェックされている
                    var (successCalcium, updatedRowCalcium) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_CALCIUM, ExamOrderClass.ANY, calcium);
                    if (!successCalcium) { return (false, row); }
                    row = updatedRowCalcium; // updatedRow を row に設定

                    var (successPhosphorus, updatedRowPhosphorus) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_PHOSPHORUS, ExamOrderClass.ANY, phosphorus);
                    if (!successPhosphorus) { return (false, row); }
                    row = updatedRowPhosphorus; // updatedRow を row に設定

                    var (successAlbumin, updatedRowAlbumin) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_ALBUMIN, ExamOrderClass.ANY, albumin);
                    if (!successAlbumin) { return (false, row); }
                    row = updatedRowAlbumin; // updatedRow を row に設定

                    var (successCpr, updatedRowCpr) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_CRP, ExamOrderClass.ANY, crp);
                    if (!successCpr) { return (false, row); }
                    row = updatedRowCpr; // updatedRow を row に設定

                    var (successHemoglobin, updatedRowHemoglobin) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_HEMOGLOBIN, ExamOrderClass.ANY, hemoglobin);
                    if (!successHemoglobin) { return (false, row); }
                    row = updatedRowHemoglobin; // updatedRow を row に設定
                }
                else
                {
                    //検査項目設定画面のチェックボックスにチェックされている
                    var (successCalcium, updatedRowCalcium) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_CALCIUM, ExamOrderClass.ANY, calcium);
                    if (!successCalcium)
                    {
                        var (successCalciumAsync, updatedRowCalciumAsync) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_CALCIUM, ExamOrderClass.ANY, calcium);
                        if (!successCalciumAsync) { return (false, row); }
                        row = updatedRowCalciumAsync; // updatedRow を row に設定
                    }
                    else
                    {
                        row = updatedRowCalcium;
                    }

                    var (successPhosphorus, updatedRowPhosphorus) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_PHOSPHORUS, ExamOrderClass.ANY, phosphorus);
                    if (!successPhosphorus)
                    {
                        var (successPhosphorusAsync, updatedRowPhosphorusAsync) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_PHOSPHORUS, ExamOrderClass.ANY, phosphorus);
                        if (!successPhosphorusAsync) { return (false, row); }
                        row = updatedRowPhosphorusAsync; // updatedRow を row に設定
                    }
                    else
                    {
                        row = updatedRowPhosphorus;
                    }

                    var (successAlbumin, updatedRowAlbumin) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_ALBUMIN, ExamOrderClass.ANY, albumin);
                    if (!successAlbumin)
                    {
                        var (successAlbuminAsync, updatedRowAlbuminAsync) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_ALBUMIN, ExamOrderClass.ANY, albumin);
                        if (!successAlbuminAsync) { return (false, row); }
                        row = updatedRowAlbuminAsync; // updatedRow を row に設定
                    }
                    else
                    {
                        row = updatedRowAlbumin;
                    }

                    var (successCpr, updatedRowCpr) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_CRP, ExamOrderClass.ANY, crp);
                    if (!successCpr)
                    {
                        var (successCprAsync, updatedRowCprAsync) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_CRP, ExamOrderClass.ANY, crp);
                        if (!successCprAsync) { return (false, row); }
                        row = updatedRowCprAsync; // updatedRow を row に設定
                    }
                    else
                    {
                        row = updatedRowCpr;
                    }

                    var (successHemoglobin, updatedRowHemoglobin) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_HEMOGLOBIN, ExamOrderClass.ANY, hemoglobin);
                    if (!successHemoglobin)
                    {
                        var (successHemoglobinAsync, updatedRowHemoglobinAsync) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_HEMOGLOBIN, ExamOrderClass.ANY, hemoglobin);
                        if (!successHemoglobinAsync) { return (false, row); }
                        row = updatedRowHemoglobinAsync; // updatedRow を row に設定
                    }
                    else
                    {
                        row = updatedRowHemoglobin;
                    }

                }
            }
            else
            {
                if (examDate == DateTime.MinValue)
                {
                    var (successCalcium, updatedRowCalcium) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_CALCIUM, ExamOrderClass.BEFORE, calcium);
                    if (!successCalcium) { return (false, row); }
                    row = updatedRowCalcium;

                    var (successPhosphorus, updatedRowPhosphorus) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_PHOSPHORUS, ExamOrderClass.BEFORE, phosphorus);
                    if (!successPhosphorus) { return (false, row); }
                    row = updatedRowPhosphorus;

                    var (successAlbumin, updatedRowAlbumin) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_ALBUMIN, ExamOrderClass.BEFORE, albumin);
                    if (!successAlbumin) { return (false, row); }
                    row = updatedRowAlbumin;

                    var (successCpr, updatedRowCpr) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_CRP, ExamOrderClass.BEFORE, crp);
                    if (!successCpr) { return (false, row); }
                    row = updatedRowCpr;

                    var (successHemoglobin, updatedRowHemoglobin) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_HEMOGLOBIN, ExamOrderClass.BEFORE, hemoglobin);
                    if (!successHemoglobin) { return (false, row); }
                    row = updatedRowHemoglobin;
                }
                else
                {
                    var (successCalcium, updatedRowCalcium) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_CALCIUM, ExamOrderClass.BEFORE, calcium);
                    if (!successCalcium)
                    {
                        var (successCalciumFallback, updatedRowCalciumFallback) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_CALCIUM, ExamOrderClass.BEFORE, calcium);
                        if (!successCalciumFallback) { return (false, row); }
                        row = updatedRowCalciumFallback;
                    }
                    else
                    {
                        row = updatedRowCalcium;
                    }

                    var (successPhosphorus, updatedRowPhosphorus) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_PHOSPHORUS, ExamOrderClass.BEFORE, phosphorus);
                    if (!successPhosphorus)
                    {
                        var (successPhosphorusFallback, updatedRowPhosphorusFallback) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_PHOSPHORUS, ExamOrderClass.BEFORE, phosphorus);
                        if (!successPhosphorusFallback) { return (false, row); }
                        row = updatedRowPhosphorusFallback;
                    }
                    else
                    {
                        row = updatedRowPhosphorus;
                    }

                    var (successAlbumin, updatedRowAlbumin) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_ALBUMIN, ExamOrderClass.BEFORE, albumin);
                    if (!successAlbumin)
                    {
                        var (successAlbuminFallback, updatedRowAlbuminFallback) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_ALBUMIN, ExamOrderClass.BEFORE, albumin);
                        if (!successAlbuminFallback) { return (false, row); }
                        row = updatedRowAlbuminFallback;
                    }
                    else
                    {
                        row = updatedRowAlbumin;
                    }

                    var (successCpr, updatedRowCpr) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_CRP, ExamOrderClass.BEFORE, crp);
                    if (!successCpr)
                    {
                        var (successCprFallback, updatedRowCprFallback) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_CRP, ExamOrderClass.BEFORE, crp);
                        if (!successCprFallback) { return (false, row); }
                        row = updatedRowCprFallback;
                    }
                    else
                    {
                        row = updatedRowCpr;
                    }

                    var (successHemoglobin, updatedRowHemoglobin) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_HEMOGLOBIN, ExamOrderClass.BEFORE, hemoglobin);
                    if (!successHemoglobin)
                    {
                        var (successHemoglobinFallback, updatedRowHemoglobinFallback) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_HEMOGLOBIN, ExamOrderClass.BEFORE, hemoglobin);
                        if (!successHemoglobinFallback) { return (false, row); }
                        row = updatedRowHemoglobinFallback;
                    }
                    else
                    {
                        row = updatedRowHemoglobin;
                    }

                }
            }

            if (examDate == DateTime.MinValue)
            {
                var (successPth, updatedRowPth) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_PTH, ExamOrderClass.ANY, pth);
                if (!successPth) { return (false, row); }
                row = updatedRowPth;

                var (successTotalCholesterol, updatedRowTotalCholesterol) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_TOTAL_CHOLESTEROL, ExamOrderClass.ANY, totalCholesterol);
                if (!successTotalCholesterol) { return (false, row); }
                row = updatedRowTotalCholesterol;

                var (successHdlCholesterol, updatedRowHdlCholesterol) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_HDL_CHOLESTEROL, ExamOrderClass.ANY, hdlCholesterol);
                if (!successHdlCholesterol) { return (false, row); }
                row = updatedRowHdlCholesterol;

                //2025年度対象外項目
                //// 2024年度　新設項目
                //var (successldlCholesterol, updatedRowldlCholesterol) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_LDL_CHOLESTEROL, ExamOrderClass.ANY, ldlCholesterol);
                //if (!successldlCholesterol) { return (false, row); }
                //row = updatedRowldlCholesterol;

                //var (successtriglyceride, updatedRowtriglyceride) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_TRIGLYCERIDE, ExamOrderClass.ANY, triglyceride);
                //if (!successtriglyceride) { return (false, row); }
                //row = updatedRowtriglyceride;
                //// END
                //END
            }
            else
            {
                var (successPth, updatedRowPth) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_PTH, ExamOrderClass.ANY, pth);
                if (!successPth)
                {
                    var (successPthFallback, updatedRowPthFallback) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_PTH, ExamOrderClass.ANY, pth);
                    if (!successPthFallback) { return (false, row); }
                    row = updatedRowPthFallback;
                }
                else
                {
                    row = updatedRowPth;
                }

                var (successTotalCholesterol, updatedRowTotalCholesterol) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_TOTAL_CHOLESTEROL, ExamOrderClass.ANY, totalCholesterol);
                if (!successTotalCholesterol)
                {
                    var (successTotalCholesterolFallback, updatedRowTotalCholesterolFallback) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_TOTAL_CHOLESTEROL, ExamOrderClass.ANY, totalCholesterol);
                    if (!successTotalCholesterolFallback) { return (false, row); }
                    row = updatedRowTotalCholesterolFallback;
                }
                else
                {
                    row = updatedRowTotalCholesterol;
                }

                var (successHdlCholesterol, updatedRowHdlCholesterol) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_HDL_CHOLESTEROL, ExamOrderClass.ANY, hdlCholesterol);
                if (!successHdlCholesterol)
                {
                    var (successHdlCholesterolFallback, updatedRowHdlCholesterolFallback) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_HDL_CHOLESTEROL, ExamOrderClass.ANY, hdlCholesterol);
                    if (!successHdlCholesterolFallback) { return (false, row); }
                    row = updatedRowHdlCholesterolFallback;
                }
                else
                {
                    row = updatedRowHdlCholesterol;
                }

                //2025年度対象外項目
                //var (successLdlCholesterol, updatedRowLdlCholesterol) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_LDL_CHOLESTEROL, ExamOrderClass.ANY, ldlCholesterol);
                //if (!successLdlCholesterol)
                //{
                //    var (successLdlCholesterolFallback, updatedRowLdlCholesterolFallback) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_LDL_CHOLESTEROL, ExamOrderClass.ANY, ldlCholesterol);
                //    if (!successLdlCholesterolFallback) { return (false, row); }
                //    row = updatedRowLdlCholesterolFallback;
                //}
                //else
                //{
                //    row = updatedRowLdlCholesterol;
                //}

                //var (successTriglyceride, updatedRowTriglyceride) = await SetOneExamByExamDateAsync(patID, examDate, row, StatisticsConst.EXAM_TRIGLYCERIDE, ExamOrderClass.ANY, triglyceride);
                //if (!successTriglyceride)
                //{
                //    var (successTriglycerideFallback, updatedRowTriglycerideFallback) = await SetOneExamAsync(patID, row, dtFirstDialysisDay, StatisticsConst.EXAM_TRIGLYCERIDE, ExamOrderClass.ANY, triglyceride);
                //    if (!successTriglycerideFallback) { return (false, row); }
                //    row = updatedRowTriglycerideFallback;
                //}
                //else
                //{
                //    row = updatedRowTriglyceride;
                //}
                //END

            }

            //2013年版修正(「カルシウム濃度、ヘモグロビンA1c」検査値補正処理追加)
            //「カルシウム濃度」検査値補正処理
            if (CustomizeSettings.Instance.IsCorrectionCa)
            {
                decimal decValue;
                if (decimal.TryParse(row[calcium] as string, out decValue))
                {
                    row[calcium] = (decValue * 2).ToString();
                }
            }

            return (true, row);
        }

        /// <summary>
        /// 検査1件分の結果を格納
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="patID">患者ID</param>
        /// <param name="row">結果格納先DataRowインスタンス</param>
        /// <param name="dtFirstDialysisDay">第１透析日データ</param>
        /// <param name="examKey">検査項目キー名</param>
        /// <param name="orderClass">検査区分</param>
        /// <param name="column">結果格納先列番号</param>
        /// <returns>true：成功 false：失敗</returns>
        private static async Task<(bool sccess, DataRow row)> SetOneExamAsync(long patID, DataRow row, DataTable dtFirstDialysisDay, string examKey, ExamOrderClass orderClass, int column)
        {
            string usingOrderClass;
            switch (orderClass)
            {
                case ExamOrderClass.BEFORE:
                    // 透析前
                    usingOrderClass = "1";
                    break;
                case ExamOrderClass.AFTER:
                    // 透析後
                    usingOrderClass = "2";
                    break;
                default:
                    // 絞込みしない
                    usingOrderClass = "9";
                    break;
            }

            ExamOneSetResponse examOneSetResult = await StatisticsLib.GetExamOneSet(
                new SysDataSetRequest(
                    sqlCd: -1000023,
                    patId: patID,
                    fromDate: Settings.Default.PeriodStart.ToString("yyyy/MM/dd"),
                    toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd"),
                    orderClass: usingOrderClass,
                    examCd: FrmStatistics.ConvExamItem(examKey)
                )
            );
            List<ExamOneSetDataType> examOneSetList = examOneSetResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(examOneSetList, null);
            if (null == dt)
            {
                return (false, row);
            }

            if (0 == dt.Rows.Count)
            {
                return (true, row);
            }

            //2013年版修正(検査結果の第１透析日判定機能を追加)
            int index = 0;
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                // 対象レコードの検査日が第１透析日かどうか
                DataRow[] work = dtFirstDialysisDay.Select("DIALYSIS_DATE = '" + ((DateTime)dt.Rows[i]["EXAM_DATE"]).ToString("yyyyMMdd") + "'");

                if (1 == work.Length)
                {
                    index = i;
                    break;
                }
            }

            row[column] = dt.Rows[index]["EXAM_RST"].ToString();

            return (true, row);
        }

        /// <summary>
        /// 検査1件分の結果を検査日指定で格納
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="patID">患者ID</param>
        /// <param name="examDate">検査日</param>
        /// <param name="row">結果格納先DataRowインスタンス</param>
        /// <param name="examKey">検査項目キー名</param>
        /// <param name="orderClass">検査区分</param>
        /// <param name="column">結果格納先列番号</param>
        /// <returns>true：成功 false：失敗</returns>
        private static async Task<(bool sccess, DataRow row)> SetOneExamByExamDateAsync(long patID, DateTime examDate, DataRow row, string examKey, ExamOrderClass orderClass, int column)
        {
            string usingOrderClass;
            switch (orderClass)
            {
                case ExamOrderClass.BEFORE:
                    // 透析前
                    usingOrderClass = "1";
                    break;
                case ExamOrderClass.AFTER:
                    // 透析後
                    usingOrderClass = "2";
                    break;
                default:
                    // 絞込みしない
                    usingOrderClass = "9";
                    break;
            }

            ExamOneSetByDateResponse examOneSetByExamDateResult = await StatisticsLib.GetExamOneSetByDate(
                new SysDataSetRequest(
                    sqlCd: -1000024,
                    patId: patID,
                    fromDate: examDate.ToString("yyyy/MM/dd"),
                    orderClass: usingOrderClass,
                    examCd: FrmStatistics.ConvExamItem(examKey)
                )
            );
            List<ExamOneSetByDateDataType> examOneSetByDateList = examOneSetByExamDateResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(examOneSetByDateList, null);

            if (null == dt)
            {
                return (false, row);
            }

            if (0 == dt.Rows.Count)
            {
                return (false, row);
            }

            row[column] = dt.Rows[0]["EXAM_RST"].ToString();

            return (true, row);
        }

        /// <summary>
        /// 自動一致の候補取得
        /// </summary>
        /// <param name="name">マッチング対象文字列</param>
        /// <param name="target">一致対象リスト</param>
        /// <param name="colName">対象列名称</param>
        /// <returns>自動一致した候補(候補が無い場合はnull)</returns>
        public static DataRow GetAutoMatch(string name, DataTable target, string colName)
        {
            DataRow row = null;

            // 完全一致チェック
            for (int i = 0; i < target.Rows.Count; i++)
            {
                if (0 == StaticFunctions.AboutCompare(target.Rows[i][colName] as string, name))
                {
                    if (null == row)
                    {
                        // 見つけたのが一つ目だったらその情報を格納
                        row = target.Rows[i];
                    }
                    else
                    {
                        // 完全一致が2件以上の場合は自動割当なし
                        return null;
                    }
                }
            }

            if (null != row)
            {
                // 完全一致が1件だけだったら自動一致
                return row;
            }

            // 部分一致チェック
            for (int i = 0; i < target.Rows.Count; i++)
            {
                if (0 <= StaticFunctions.AboutIndexOf(target.Rows[i][colName] as string, name))
                {
                    if (null == row)
                    {
                        // 見つけたのが1件目
                        row = target.Rows[i];
                    }
                    else
                    {
                        // 部分一致の2件目を発見したら自動割当無し
                        return null;
                    }
                }
            }

            return row;
        }

        /// <summary>
        /// 自動一致の候補取得
        /// </summary>
        /// <param name="name">マッチング対象文字列</param>
        /// <param name="target">一致対象リスト</param>
        /// <returns>自動一致した候補(候補が無い場合はnull)</returns>
        public static DispCode GetAutoMatch(string name, List<DispCode> target)
        {
            // 完全一致チェック
            List<DispCode> work = target.FindAll(ele => 0 == StaticFunctions.AboutCompare(ele.Name, name));
            if (1 == work.Count)
            {
                // 完全一致が1件だけだったら自動一致
                return work[0];
            }
            else if (0 == work.Count)
            {
                // 完全一致0件の場合だけ部分一致チェック
                work = target.FindAll(ele => 0 <= StaticFunctions.AboutIndexOf(ele.Name, name));
                if (1 == work.Count)
                {
                    // 完全一致0件で部分一致1件だったら自動一致
                    return work[0];
                }
            }

            return null;
        }

        /// <summary>
        /// 指定した2つのSystem.Stringオブジェクトを『大文字小文字無視』『ひらがなカタカナ無視』『全角半角無視』で比較します
        /// </summary>
        /// <param name="strA">第1のSystem.String</param>
        /// <param name="strB">第2のSystem.String</param>
        /// <returns>2つの比較対照値の構文上の関係を示す32ビット符号付き整数。0より小：strAがstrBより小さい。0：strAとstrBは等しい。0より大：strAがstrBより大きい。</returns>
        public static int AboutCompare(string strA, string strB)
        {
            // 実行環境の文化情報取得
            CompareInfo ci = CultureInfo.CurrentCulture.CompareInfo;
            // あいまい一致チェック
            return ci.Compare(strA, strB, CompareOptions.IgnoreCase | CompareOptions.IgnoreKanaType | CompareOptions.IgnoreWidth);
        }

        /// <summary>
        /// 指定した部分文字列を『大文字小文字無視』『ひらがなカタカナ無視』『全角半角無視』で検索し、
        /// 検索対象文字列全体内でその部分文字列が最初に出現する位置の0から始まるインデックス番号を返します
        /// </summary>
        /// <param name="source">検索対象の文字列</param>
        /// <param name="value">source内で検索する文字列</param>
        /// <returns>source全体内でvalueが見つかった場合は、最初に見つかった位置の0から始まるインデックス番号。それ以外の場合は-1</returns>
        public static int AboutIndexOf(string source, string value)
        {
            // 実行環境の文化情報取得
            CompareInfo ci = CultureInfo.CurrentCulture.CompareInfo;

            try
            {
                // あいまい検索
                return ci.IndexOf(source, value, CompareOptions.IgnoreCase | CompareOptions.IgnoreKanaType | CompareOptions.IgnoreWidth);
            }
            catch (Exception ex)
            {
                //LogManager.WriteErrorLog(null, null, "文字列の部分一致チェックで例外発生", ex);
                // 例外発生(どっちかがnull)は一致無しとして処理
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(StatisticsConst), NKKLogging.LOGGING_CLASS.ERROR, String.Format("文字列の部分一致チェックで例外発生,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return -1;
            }
        }

        /// <summary>
        /// 指定された患者の最新のinout_cdが対象年に指定された物であれば取得する
        /// </summary>
        /// <param name="logInfo">db</param>
        /// <param name="patID">患者ID</param>
        /// <returns>対象患者対象年度内のinout_cd</returns>
        public static async Task<string> getInoutCdAsync(long patID)
        {
            string retINOUT_CD = string.Empty;
            //実績データの透析時間取得
            InOutResponse inOutResult = await StatisticsLib.GetInOut(
                new SysDataSetRequest(
                    sqlCd: -1000021,
                    patId: patID,
                    fromDate: Settings.Default.PeriodStart.ToString("yyyy/MM/dd"),
                    toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd")
                )
            );
            List<InOutDataType> inOutList = inOutResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(inOutList, null);
            if (null == dt)
            {
                // エラーもここでは無し扱い
                return "";
            }
            if (0 == dt.Rows.Count)
            {
                return "";
            }
            foreach (DataRow dr in dt.Rows)
            {
                if (dr["INOUT_CD"].ToString().Equals("2"))
                {
                    retINOUT_CD = "2";
                    return retINOUT_CD;
                }
                retINOUT_CD = "3";
            }          
            return retINOUT_CD;
        }

        /// <summary>
        /// 転入・転帰パターン
        /// </summary>
        /// <param name="logInfo">db</param>
        /// <param name="patID">患者ID</param>
        /// <returns>転入・転出パターン（1:転入患者【転入:記載あり, 転帰:記載なし】, 2:転入患者【転入:記載あり, 転帰:記載あり】,
        ///          3:【転入:記載あり, 転帰:記載あり】, 4:【転入:記載なし, 転帰:記載なし】, 5:出力しない）</returns>
        public static async Task<string> GetInoutCircumstanceAsync(long patID)
        {
            string retINOUT_CD = string.Empty;

            DataTable dt = await GetInoutPatternAsync(patID);

            if (null == dt)
            {
                // エラーもここでは無し扱い
                return "";
            }
            if (0 == dt.Rows.Count)
            {
                return "";
            }

            //最初の転帰が転入
            if (dt.Rows[0]["INOUT_CD"].Equals("2"))
            {
                if (dt.Rows.Count == 1)
                {
                    //転入（最初の日）
                    retINOUT_CD = "1";
                    //転出無記載
                }
                else
                {
                    //最終転帰が転入
                    if (dt.Rows[dt.Rows.Count - 1]["INOUT_CD"].Equals("2"))
                    {
                        //転入（最後の日）
                        retINOUT_CD = "1";
                        //転出無記載
                    }
                    //最終転帰が転出
                    else if (dt.Rows[dt.Rows.Count - 1]["INOUT_CD"].Equals("3"))
                    {
                        //転入元・転出先が 同施設or異施設 にかかわらず出力しない
                        retINOUT_CD = "5";
                    }
                    //最終転帰がそれ以外
                    else
                    {
                        //転入（最初の日）
                        retINOUT_CD = "2";
                        //転帰（死亡・離脱・移植）
                    }
                }
            }
            //最初の転帰が転出・死亡・離脱・移植
            else
            {
                if (dt.Rows.Count == 1)
                {
                    //転出（最初の日）
                    //転入無記載（自動）
                    retINOUT_CD = "3";
                }
                else
                {
                    //最終転帰が転入
                    if (dt.Rows[dt.Rows.Count - 1]["INOUT_CD"].Equals("2"))
                    {
                        //両方無記載
                        retINOUT_CD = "4";
                    }
                    //最終転帰が転出
                    else if (dt.Rows[dt.Rows.Count - 1]["INOUT_CD"].Equals("3"))
                    {
                        //転出（最後の日）
                        //転入無記載
                        retINOUT_CD = "3";
                    }
                    //最終転帰がそれ以外
                    else
                    {
                        //離脱・移植・転出・死亡（直近）
                        //転入無記載
                        retINOUT_CD = "3";
                    }
                }
            }

            return retINOUT_CD;

        }

        public static async Task<DataTable> GetInoutPatternAsync(long patID)
        {
            InOutPatternResponse inOutPatternResult = await StatisticsLib.GetInOutPattern(
                new SysDataSetRequest(
                    sqlCd: -1000020,
                    patId: patID,
                    fromDate: Settings.Default.PeriodStart.ToString("yyyy/MM/dd"),
                    toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd")
                )
            );
            List<InOutPatternDataType> inOutPatternList = inOutPatternResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(inOutPatternList, null);
            return dt;
        }

        /// <summary>
        /// 透析前収縮期血圧、透析前拡張期血圧、透析前脈拍の取得とセット
        /// </summary>
        /// <param name="logInfo">db</param>
        /// <param name="dNo">最新透析番号</param>
        /// <param name="row">行情報</param>
        /// <param name="BpAfter">行番：収縮期血圧</param>
        /// <param name="BpBefore">行番：拡張期血圧</param>
        /// <param name="PulseBefore">行番：脈拍</param>
        /// <returns>成功か失敗</returns>
        public static async Task<(bool sccess, DataRow row)> getBpAndPulseAsync(long dNo, DataRow row, int BpBefore, int BpAfter, int PulseBefore)
        {
            //2013年版コメント
            //  最終透析番号を取得した時点で特殊血液浄化は除いている為、SQL切り替え不要ではないかと思われるが念のためそのままにする。(結果は同じのはず)
            //　※ECUMを除く処理についても最終透析番号取得で行っている為、ここでは追記しない
            //特殊血液浄化も出力結果に含む
            BpAndPulseResponse bpAndPulseResult = await StatisticsLib.getBpAndPulse(
                new SysDataSetRequest(
                    sqlCd: -1000019,
                    ordNo: dNo
                )
            );
            List<BpAndPulseDataType> bpAndPulseList = bpAndPulseResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(bpAndPulseList, null);
            
            if (null == dt)
            {
                return (false, row);
            }

            if (0 != dt.Rows.Count)
            {
                if (dt.Rows[0]["BP_BEFORE"] is decimal || dt.Rows[0]["BP_AFTER"] is decimal || dt.Rows[0]["PULSE"] is decimal)
                {
                    row[BpBefore] = dt.Rows[0]["BP_BEFORE"].ToString();
                    row[BpAfter] = dt.Rows[0]["BP_AFTER"].ToString();
                    row[PulseBefore] = dt.Rows[0]["PULSE"].ToString();
                }
            }

            return (true, row);
        }


        /// <summary>
        /// 更新前と更新後の差分を出し備考に記述する文字列を生成する
        /// </summary>
        /// <param name="before">変更前データ</param>
        /// <param name="After">変更後データ</param>
        /// <param name="dr">行情報</param>
        /// <param name="bikou">備考欄の列番号</param>
        /// <param name="henkou">患者情報変更/訂正区分欄の列番号（2015年版対応（エクセルレイアウト対応））</param>
        /// <returns>成功：失敗</returns>
        public static bool ChangeUpdate(string[,] before, string[] After, ref DataRow dr, int bikou, int henkou)
        {
            string strBikou = string.Empty;
            try
            {

                for (int numLoop = 0; numLoop < (int)SheetSum.C39_備考; numLoop++)
                {
                    //if (numLoop == (int)SheetSum.C01_氏名)
                    //{
                    //    //氏名は変換が入るため除外
                    //    continue;
                    //}

                    //------------------------------------------
                    // 2015年版対応（エクセルレイアウト対応）START
                    //------------------------------------------
                    if (numLoop == (int)SheetSum.C15_氏名_姓_漢字 || numLoop == (int)SheetSum.C16_氏名_名_漢字 || numLoop == (int)SheetSum.C17_氏名_姓_カナ || numLoop == (int)SheetSum.C18_氏名_名_カナ)
                    {
                        //氏名はハッシュ変換が入るため除外
                        continue;
                    }

                    if (numLoop == (int)SheetSum.C14_診察券番号)
                    {
                        //診察券番号は2015年度未記入のため除外
                        continue;
                    }
                    //------------------------------------------
                    // 2015年版対応（エクセルレイアウト対応）END
                    //------------------------------------------

                    //並び替えも割当が行われている場合
                    //必ず変更ありになってしまう為除外
                    //但しQA提出中の為、警告を出しておく
                    if (numLoop == (int)SheetSum.C19_並び替え)
                    {
                        continue;
                    }

                    //2013年版修正(転入情報は一律「*」設定となるため比較から除外)
                    if ((numLoop == (int)SheetSum.C30_転入_西暦年)
                     || (numLoop == (int)SheetSum.C31_転入_月)
                     || (numLoop == (int)SheetSum.C32_転入_転入前の施設コード))
                    {
                        continue;
                    }

                    // 2020年版修正(透析医学会からの指摘事項)
                    // 転帰欄に関する変更は省略
                    if ((numLoop == (int)SheetSum.C33_転帰欄_転帰区分)
                        || (numLoop == (int)SheetSum.C34_転帰欄_西暦年)
                        || (numLoop == (int)SheetSum.C35_転帰欄_月)
                        || (numLoop == (int)SheetSum.C36_転帰欄_転出先の施設コード)
                        || (numLoop == (int)SheetSum.C37_転帰欄_死因コード))
                    {
                        continue;
                    }

                    // 2020年版修正(透析医学会からの指摘事項)
                    // 導入年月、転入年月の「月」について、01を1に変更したと言う内容を省略
                    if ((numLoop == (int)SheetSum.C26_導入年月_月)
                        || (numLoop == (int)SheetSum.C31_転入_月))
                    {
                        if (before[numLoop, 0] != null && After[numLoop] != null &&
                            before[numLoop, 0].PadLeft(2, '0').Equals(After[numLoop].PadLeft(2, '0')))
                        {
                            continue;
                        }
                    }

                    if (!before[numLoop, 0].Equals(After[numLoop]))
                    {
                        strBikou += before[numLoop, 1].ToString();
                        strBikou += "変更, ";

                        // 2015年版対応（エクセルレイアウト対応）
                        if (numLoop == (int)SheetSum.C21_生年月日_西暦 || numLoop == (int)SheetSum.C22_生年月日_月 || numLoop == (int)SheetSum.C23_生年月日_日)
                        {
                            dr[henkou] = "4";
                        }
                    }
                }
                if (strBikou.Length != 0)
                {
                    strBikou = strBikou.Remove(strBikou.Length - 2, 2);
                    dr[bikou] = strBikou;
                }
                return true;
            }
            catch (Exception ex)
            {
                //string logStr = "備考欄取得失敗";
                //LogManager.WriteErrorLog(null, null, logStr, e);
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(StaticFunctions), NKKLogging.LOGGING_CLASS.ERROR, String.Format("備考欄取得失敗,{0}",ex.ToString().Replace("\r\n", "{CRLF}")));
                return false;
            }

        }

        /// <summary>
        /// 変更箇所記録用配列
        /// </summary>
        /// <param name="UpdateBefore"></param>
        public static void SetBeforeName(ref string[,] UpdateBefore)
        {
            UpdateBefore[(int)SheetSum.C13_患者区分, 1] = "患者区分";
            //UpdateBefore[(int)SheetSum.C01_氏名, 1] = "氏名";
            UpdateBefore[(int)SheetSum.C19_並び替え, 1] = "並び替え";
            UpdateBefore[(int)SheetSum.C20_性別, 1] = "性別";
            UpdateBefore[(int)SheetSum.C21_生年月日_西暦, 1] = "生年月日_西暦";
            UpdateBefore[(int)SheetSum.C22_生年月日_月, 1] = "生年月日_月";
            UpdateBefore[(int)SheetSum.C23_生年月日_日, 1] = "生年月日_日";
            UpdateBefore[(int)SheetSum.C25_導入年月_西暦, 1] = "導入年月_西暦";
            UpdateBefore[(int)SheetSum.C26_導入年月_月, 1] = "導入年月_月";
            UpdateBefore[(int)SheetSum.C28_原疾患, 1] = "原疾患";
            UpdateBefore[(int)SheetSum.C29_在住県コード, 1] = "在住県コード";
            UpdateBefore[(int)SheetSum.C30_転入_西暦年, 1] = "転入_西暦年";
            UpdateBefore[(int)SheetSum.C31_転入_月, 1] = "転入_月";
            UpdateBefore[(int)SheetSum.C32_転入_転入前の施設コード, 1] = "転入_転入前の施設コード";
            UpdateBefore[(int)SheetSum.C33_転帰欄_転帰区分, 1] = "転帰欄_転帰区分";
            UpdateBefore[(int)SheetSum.C34_転帰欄_西暦年, 1] = "転帰欄_西暦年";
            UpdateBefore[(int)SheetSum.C35_転帰欄_月, 1] = "転帰欄_月";
            UpdateBefore[(int)SheetSum.C36_転帰欄_転出先の施設コード, 1] = "転帰欄_転出先の施設コード";
            UpdateBefore[(int)SheetSum.C37_転帰欄_死因コード, 1] = "転帰欄_死因コード";
        }

        /// <summary>
        /// 指定された患者IDの患者が転入患者であるか調べる
        /// 転入ならtrue それ以外false
        /// </summary>
        /// <param name="logInfo">db操作</param>
        /// <param name="patID">患者ID</param>
        /// <returns></returns>
        public static async Task<bool> getInoutAsync(long patID)
        {
            MovingInCountResponse movingInCountResult = await StatisticsLib.GetMovingInCount(
                new SysDataSetRequest(
                    sqlCd: -1000018,
                    patId: patID,
                    fromDate: Settings.Default.PeriodStart.ToString("yyyy/MM/dd"),
                    toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd")
                )
            );
            List<MovingInCountDataType> movingInCountList = movingInCountResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(movingInCountList, null);

            if (null == dt)
            {
                return false;
            }

            if (0 != dt.Rows.Count)
            {
                if (false == dt.Rows[0][0].ToString().Equals("0"))
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return false;
            }

        }


        /// <summary>
        /// 必須入力項目をチェックする
        /// 但し登録済み患者には使用しない予定
        /// </summary>
        /// <param name="logInfo">db操作</param>
        /// <param name="dr">行全体の情報</param>
        /// <param name="patId">患者Id</param>
        /// <param name="pat_inoutCd">転入・転帰区分</param>
        /// <returns></returns>
        public static async Task<(bool success, DataRow dr)> ChkRequiredItemAsync(DataRow dr, long patId, string pat_inoutCd)
        {
            try
            {
                //チェック項目
                //転入西暦 = 9999      ※転入しており、且つ不明の場合のみ不明値をセット
                //転入月 = 99          ※転入しており、且つ不明の場合のみ不明値をセット
                //転入前施設コード = 999999
                //                     ※転入しており、且つ不明の場合のみ不明値をセット
                //転帰欄_西暦 = 9999   ※転帰欄が1(転出)もしくは2(死亡)且つ西暦が不明の場合不明値をセット
                //転帰欄_月    = 99    ※転帰欄が1(転出)もしくは2(死亡)且つ月が不明の場合不明値をセット
                //転出先施設コード = 999999
                //                     ※転帰欄が1(転出)且つ不明の場合不明値をセット
                //転出先施設コード = ""
                //                     ※転帰欄が2(死亡)の場合は転出先施設コードに空文字をセットする

                //転入患者かチェック
                //2014年版修正（転入・転帰パターン対応）
                //getInout : 転入患者であればTrueを返す
                if (await getInoutAsync(patId))
                //if(dr[(int)SheetSum.C00_患者区分].Equals("2"))
                {
                    if (!pat_inoutCd.Equals("4"))
                    {
                        //転入年が未入力であれば"9999"を出力
                        if (!" ".Equals(dr[(int)SheetSum.C30_転入_西暦年] as string))
                        {
                            if (string.IsNullOrEmpty(dr[(int)SheetSum.C30_転入_西暦年] as string))
                            {
                                dr[(int)SheetSum.C30_転入_西暦年] = "9999";
                            }
                        }
                        else
                        {
                            dr[(int)SheetSum.C30_転入_西暦年] = "";
                        }
                        //転入月が未入力であれば"99"を出力
                        if (!" ".Equals(dr[(int)SheetSum.C31_転入_月] as string))
                        {
                            if (string.IsNullOrEmpty(dr[(int)SheetSum.C31_転入_月] as string))
                            {
                                dr[(int)SheetSum.C31_転入_月] = "99";
                            }
                        }
                        else
                        {
                            dr[(int)SheetSum.C31_転入_月] = "";
                        }
                        //転入前施設コードが未入力であれば、"999999"を出力
                        if (!" ".Equals(dr[(int)SheetSum.C32_転入_転入前の施設コード] as string))
                        {
                            if (string.IsNullOrEmpty(dr[(int)SheetSum.C32_転入_転入前の施設コード] as string))
                            {
                                dr[(int)SheetSum.C32_転入_転入前の施設コード] = "999999";
                            }
                        }
                        else
                        {
                            dr[(int)SheetSum.C32_転入_転入前の施設コード] = "";
                        }
                    }

                }

                //2014年版修正（離脱・移植の追加）
                //転帰区分が1(転出)もしくは2(死亡)であるかチェック
                //if (dr[(int)SheetSum.C14_転帰欄_転帰区分].Equals("1") ||
                //    dr[(int)SheetSum.C14_転帰欄_転帰区分].Equals("2"))
                //転帰区分が1(転出)、2(死亡)、3(離脱)、4(移植)であるかチェック
                if (dr[(int)SheetSum.C33_転帰欄_転帰区分].Equals("1") ||
                    dr[(int)SheetSum.C33_転帰欄_転帰区分].Equals("2") ||
                    dr[(int)SheetSum.C33_転帰欄_転帰区分].Equals("3") ||
                    dr[(int)SheetSum.C33_転帰欄_転帰区分].Equals("4"))
                {

                    if (string.IsNullOrEmpty(dr[(int)SheetSum.C34_転帰欄_西暦年] as string) ||
                        string.IsNullOrEmpty(dr[(int)SheetSum.C35_転帰欄_月] as string))
                    {
                        dr[(int)SheetSum.C34_転帰欄_西暦年] = "9999";
                        dr[(int)SheetSum.C35_転帰欄_月] = "99";
                    }

                    //2014年版修正（離脱・移植の追加）
                    //但し転帰区分が2(死亡)、3(離脱)、4(移植)以外の場合は転出先施設コードを空出力
                    //但し転帰区分が2(死亡)の場合は転出先施設コードを空出力
                    //if (false == dr[(int)SheetSum.C14_転帰欄_転帰区分].Equals("2"))
                    if (false == dr[(int)SheetSum.C33_転帰欄_転帰区分].Equals("2") &&
                        false == dr[(int)SheetSum.C33_転帰欄_転帰区分].Equals("3") &&
                        false == dr[(int)SheetSum.C33_転帰欄_転帰区分].Equals("4"))
                    {
                        if (string.IsNullOrEmpty(dr[(int)SheetSum.C36_転帰欄_転出先の施設コード] as string))
                        {
                            dr[(int)SheetSum.C36_転帰欄_転出先の施設コード] = "999999";
                        }
                    }
                }
            }
            catch
            {
                return (false, dr);
            }
            return (true, dr);
        }

        /// <summary>
        /// 患者病歴に糖尿病に該当する病名が存在するかどうか
        /// </summary>
        /// <param name="logInfo">db</param>
        /// <param name="patID">患者ID</param>
        /// <returns>true:糖尿病既往あり、false:糖尿病既往なし</returns>
        public static async Task<bool> IsDiabetesAsync(long patID)
        {
            HasDiabetesResponse hasDiabeteResult = await StatisticsLib.GetHasDiabetes(
                new SysDataSetRequest(
                    sqlCd: -1000017,
                    patId: patID,
                    fromDate: Settings.Default.PeriodStart.ToString("yyyy/MM/dd"),
                    toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd")
                )
            );
            List<HasDiabetesDataType> hasDiabeteList = hasDiabeteResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(hasDiabeteList, null);
            if (null == dt)
            {
                // エラーもここでは無し扱い
                return false;
            }
            if (0 == dt.Rows.Count)
            {
                return false;
            }

            //糖尿病選択設定データを取得
            DataTable csv = FnwCsv.ReadSelectMstDiseaseDiabetesCsv();

            foreach (DataRow dr in dt.Rows)
            {
                // 空白文字を無視するため後方に文字列を追加して完全一致させる
                DataRow[] work = csv.Select(FnwCsv.C_M_DIS_DIA1 + " + '$$' = '" + dr["DISEASE_CD"] as string + "$$'");

                // 選択設定済みデータがある事を確認
                if ((1 == work.Length) && ("1" == work[0][FnwCsv.C_M_DIS_DIA2] as string))
                {
                    // 設定済
                    return true;
                }
            }
            
            return false;
        }

        /// <summary>
        /// 指定期間内の実績から第１透析日のみを取得する
        /// (抽出範囲：指定開始日以降の直近の月曜日から指定終了日まで)
        /// </summary>
        /// <param name="logInfo">db</param>
        /// <param name="patID">患者ID</param>
        /// <returns>第１透析日データ取得</returns>
        public static async Task<DataTable> GetFirstDialysisDayAsync(long patID)
        {
            //抽出開始日および第１透析日検索開始日の中で新しい日付を開始日として設定する
            //ECUMについてはDBバージョンに関わらず除外する
            //特殊血液浄化については新DBバージョンのみ除外する
            DateTime sDate;
            if (Settings.Default.PeriodStart > Settings.Default.SearchExamStart)
            {
                sDate = Settings.Default.PeriodStart;
            }
            else
            {
                sDate = Settings.Default.SearchExamStart;
            }
            DialysisFirstDayDataResponse dialysisFirstDayResult = await StatisticsLib.GetDialysisFirstDay(
                new SysDataSetRequest(
                    sqlCd: -1000016,
                    patId: patID,
                    mstName: string.Empty,
                    fromDate: sDate.ToString("yyyy/MM/dd"),
                    toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd")
                )
            );
            List<DialysisFirstDayDataType> dialysisFirstDayList = dialysisFirstDayResult.Data;
            // DataTableに変換
            return StatisticsUtility.ConvertToDataTable(dialysisFirstDayList, null);
        }



        /// <summary>
        /// 患者感染症情報格納処理
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="patID">対象患者ID</param>
        /// <param name="row">結果格納先DataRowインスタンス</param>
        /// <param name="hbs">HBs抗原 格納先列番号</param>
        /// <param name="hbsAb">HBｓ抗体 格納先列番号</param>
        /// <param name="hbc">HBｃ抗体 格納先列番号</param>
        /// <param name="hbvDna">HBＶ ＤＮＡ検査 格納先列番号</param>
        /// <param name="hcv">HCV抗体 格納先列番号</param>
        /// <param name="hcvRna">HCV-RNA 格納先列番号</param>
        /// <returns></returns>
        public static async Task<(bool sccess, DataRow row)> SetInfectAsync(long patID,
                                     DataRow row,
                                     int hbs,
                                     int hbsAb,
                                     int hbc,
                                     int hbvDna,
                                     int hcv,
                                     int hcvRna
                                     )
        {
            // HBs抗原
            var (successHbs, updatedRowHbs) = await SetOneInfectAsync(patID, row, StatisticsConst.INFECT_HBS, hbs);
            if (!successHbs) { return (false, row); }
            row = updatedRowHbs;
            // HBs抗体
            var (successHbsAb, updatedRowHbsAb) = await SetOneInfectAsync(patID, row, StatisticsConst.INFECT_HBSAB, hbsAb);
            if (!successHbsAb) { return (false, row); }
            row = updatedRowHbsAb;
            // HBc抗体
            var (successHbc, updatedRowHbc) = await SetOneInfectAsync(patID, row, StatisticsConst.INFECT_HBC, hbc);
            if (!successHbc) { return (false, row); }
            row = updatedRowHbc;
            // HBV-DNA
            var (successHbvDna, updatedRowHbvDna) = await SetOneInfectAsync(patID, row, StatisticsConst.INFECT_HBV_DNA, hbvDna);
            if (!successHbvDna) { return (false, row); }
            row = updatedRowHbvDna;
            // HCV抗体
            var (successHcv, updatedRowHcv) = await SetOneInfectAsync(patID, row, StatisticsConst.INFECT_HCV, hcv);
            if (!successHcv) { return (false, row); }
            row = updatedRowHcv;
            // HCV-RNA
            var (successHcvRna, updatedRowHcvRna) = await SetOneInfectAsync(patID, row, StatisticsConst.INFECT_HCV_RNA, hcvRna);
            if (!successHcvRna) { return (false, row); }
            row = updatedRowHcvRna;

            return (true, row);
        }

        /// <summary>
        /// 感染症コードを指定して結果を格納
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="patId">患者ID</param>
        /// <param name="row">結果格納先DataRowインスタンス</param>
        /// <param name="infectKey">感染症名</param>
        /// <param name="column">結果格納先列番号</param>
        /// <returns></returns>
        public static async Task<(bool sccess, DataRow row)> SetOneInfectAsync(long patId, DataRow row, string infectKey, int column)
        {
            string value = FrmStatistics.ConvInfect(infectKey);
            bool isConvertible = int.TryParse(value, out int number);
            if (isConvertible)
            {
                InfectOneSetResponse infectOneSetResult = await StatisticsLib.GetInfectOneSet(
                    new SysDataSetRequest(
                        sqlCd: -1000027,
                        patId: patId,
                        examCd: number
                    )
                );
                List<InfectOneSetDataType> inOutPatternList = infectOneSetResult.Data;
                // DataTableに変換
                DataTable dt = StatisticsUtility.ConvertToDataTable(inOutPatternList, null);
                if (null == dt)
                {
                    return (false, row);
                }
                if (0 == dt.Rows.Count)
                {
                    row[column] = "Z";
                }
                else if (dt.Rows[0]["INFECT"].ToString() == "1")
                {
                    // 陰性
                    row[column] = "A";
                }
                else if (dt.Rows[0]["INFECT"].ToString() == "2")
                {
                    // 陽性
                    row[column] = "B";
                }
                else
                {
                    // 不明
                    row[column] = "Z";
                }
            }
            else
            {
                row[column] = string.Empty;
            }
            return (true, row);
        }

        // 2025年対象項目
        /// <summary>
        /// バスキュラーアクセス取得(学会コードへの変換済み)
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="dialysisNo">取得する実績の透析番号</param>
        /// <returns>取得したコード(null：エラー)</returns>
        public static async Task<string> GetVaAsync(long dialysisNo)
        {
            RstDialysisCondResponse rstDialysisCondResult = await StatisticsLib.GetRstDialysisCond(
                new SysDataSetRequest(
                    sqlCd: -1000014,
                    ordNo: dialysisNo,
                    ctlNo: "2"
                )
            );
            List<RstDialysisCondDataType> rstDialysisCondList = rstDialysisCondResult.Data;

            DataTable dt = StatisticsUtility.ConvertToDataTable(rstDialysisCondList, null);

            // バスキュラーアクセスのレコードなしの場合、nullを返却
            if (null == dt)
            {
                return null;
            }

            // 以下の条件に合致する場合、学会コード"Z:不明"を返却
            //  1.バスキュラーアクセスのレコードが1レコードではない場合
            //  2.バスキュラーアクセスが未登録(FNSI未入力)
            if (1 != dt.Rows.Count || DBNull.Value.Equals(dt.Rows[0]["VALUE"]))
            {
                return "Z";
            }

            return FrmStatistics.ConvVa(dt.Rows[0]["VALUE"] as string);
        }
        //END
    }
}
