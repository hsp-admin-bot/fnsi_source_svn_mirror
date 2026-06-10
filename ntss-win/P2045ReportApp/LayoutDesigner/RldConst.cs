using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票レイアウトデザイナ定数定義
    /// </summary>
    public static class RldConst
    {
        public const string FILE_NAME_WORK_XLSX_TEMP = @"workTemp.xlsx";
        /// <summary>
        /// 作業用エクセルファイル名
        /// </summary>
        public const string FILE_NAME_WORK_XLSX = @"work.xlsx";
        /// <summary>
        /// プレビュー表示用 html ファイル名
        /// </summary>
        public const string FILE_NAME_PREV_HTML = @"work.html";
        /// <summary>
        /// プレビュー表示用 html ファイル関連ディレクトリ名
        /// </summary>
        public const string DIR_NAME_PREV_FILES = @"work.files";

        /// <summary>
        /// パスの先頭につける文字列
        /// </summary>
        public const string PATH_HEADER = "##";
        /// <summary>
        /// 計算項目の先頭に付ける文字列
        /// </summary>
        public const string CALC_HEADER = PATH_HEADER + "=";
        /// <summary>
        /// フリー計算の項目先頭
        /// </summary>
        public const string CALC_ITEM_START = "[";
        /// <summary>
        /// フリー計算の項目末端
        /// </summary>
        public const string CALC_ITEM_END = "]";
        /// <summary>
        /// パスの区切り文字
        /// </summary>
        public const string PATH_SPLIT = ".";

        // add #12516 項目の設定されていない帳票出力時にシステムエラーが発生する 高 start
        public const string DATA_EMPTY_CAPTION = "帳票内データ項目なし";
        public const string DATA_EMPTY_MESSAGE = "帳票内にデータ項目が存在しないため、保存できません。\r\n保存するにはデータ項目を一件以上配置する必要があります。";
        // add #12516 項目の設定されていない帳票出力時にシステムエラーが発生する 高 start

        /// <summary>
        /// 内部使用定数値定数定義
        /// </summary>
        private static class InnerValueData
        {
            /// <summary>
            /// 帳票種別[透析レポート]
            /// </summary>
            public const string VAL_REPORTTYPE_DIALYSIS = "Dialysis";
            /// <summary>
            /// 帳票種別[単患者帳票]
            /// </summary>
            public const string VAL_REPORTTYPE_ONE_PATIENT = "OnePatient";
            /// <summary>
            /// 帳票種別[複数患者帳票]
            /// </summary>
            public const string VAL_REPORTTYPE_MULTI_PATIENT = "MultiPatient";
            /// <summary>
            /// 帳票種別[準備リスト]
            /// </summary>
            public const string VAL_REPORTTYPE_EQUIPMENT_LIST = "EquipmentList";
            /// <summary>
            /// 帳票種別[配布リスト(ベッド)]
            /// </summary>
            public const string VAL_REPORTTYPE_DISTRIBUTE_LIST_BED = "DistributeListBed";
            /// <summary>
            /// 帳票種別[配布リスト(物品)]
            /// </summary>
            public const string VAL_REPORTTYPE_DISTRIBUTE_LIST_EQUIPMENT = "DistributeListEquipment";
            /// <summary>
            /// 帳票種別[装置帳票]
            /// </summary>
            public const string VAL_REPORTTYPE_DEVICE = "Device";
            /// <summary>
            /// 帳票種別[ラベル]
            /// </summary>
            public const string VAL_REPORTTYPE_LABEL = "Label";
            /// <summary>
            /// 帳票種別[紹介状]
            /// </summary>
            public const string VAL_REPORTTYPE_REFERRAL_LETTER = "ReferralLetter";
            // add FNSI-523 2次元帳票対応 夏 start
            /// <summary>
            /// 帳票種別[単一集計]
            /// </summary>
            public const string VAL_REPORTTYPE_ONE_TOTAL = "OneTotal";
            /// <summary>
            /// 帳票種別[複数集計]
            /// </summary>
            public const string VAL_REPORTTYPE_MULTI_TOTAL = "MultiTotal";
            // add FNSI-523 2次元帳票対応 夏 end
            /// <summary>
            /// データ種別[数値]
            /// </summary>
            public const string VAL_DATATYPE_DECIMAL = "decimal";
            /// <summary>
            /// データ種別[文字列]
            /// </summary>
            public const string VAL_DATATYPE_STRING = "string";
            /// <summary>
            /// データ種別[日付]
            /// </summary>
            public const string VAL_DATATYPE_DATETIME = "DateTime";
            /// <summary>
            /// データ種別[画像]
            /// </summary>
            public const string VAL_DATATYPE_IMAGE = "byte[]";

            /// <summary>
            /// 改ページ有無値 - 無し
            /// </summary>
            public const string VAL_ISNEWPAGE_FALSE = "";
            /// <summary>
            /// 改ページ有無値 - 有り
            /// </summary>
            public const string VAL_ISNEWPAGE_TRUE = "1";

            /// <summary>
            /// 縮小して全体表示 - 無し
            /// </summary>
            public const string VAL_ISSHRINK_NONE = "";
            /// <summary>
            /// 縮小して全体表示 - 有り
            /// </summary>
            public const string VAL_ISSHRINK_DONE = "1";

            /// <summary>
            /// フィルタ選択状態 - 全て
            /// </summary>
            public const string VAL_FILTER_STATE_ALL = "全部";
            /// <summary>
            /// フィルタ選択状態 - 一部
            /// </summary>
            public const string VAL_FILTER_STATE_PART = "一部";

            /// <summary>
            /// テンプレート繰返し有無値 - 無し
            /// </summary>
            public const string VAL_HAS_TEMPLETE_NO = "0";
            /// <summary>
            /// テンプレート繰返し有無値 - 有り
            /// </summary>
            public const string VAL_HAS_TEMPLETE_YES = "1";

            /// <summary>
            /// テンプレート内外[無]
            /// </summary>
            public const string VAL_IS_IN_TEMPLETE_NONE = "";
            /// <summary>
            /// テンプレート内外[内]
            /// </summary>
            public const string VAL_IS_IN_TEMPLETE_IN = "内";
            /// <summary>
            /// テンプレート内外[外]
            /// </summary>
            public const string VAL_IS_IN_TEMPLETE_OUT = "外";

            /// <summary>
            /// テンプレート繰返し抽出条件 - 設定なし
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_MODE_NONE = "";
            /// <summary>
            /// テンプレート繰返し抽出条件 - 透析日モード
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_MODE_DIALYSIS = "Dialysis";
            /// <summary>
            /// テンプレート繰返し抽出条件 - 検査日モード
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_MODE_EXAMIN = "Examin";
            //add #8763-3 zhu start
            /// <summary>
            /// 抽出条件 - 処方箋交付日
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_MODE_PRESCRIPTIONNO = "issue_date";
            /// <summary>
            /// 抽出条件 - 放射線検査日
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_MODE_RESULTCD = "reg_rad_date";
            /// <summary>
            /// 抽出条件 - 点検日
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_MODE_MAINTENO = "mainte_date";
            //add #8763-3 zhu end
            // add #10605 観察記録がテンプレート繰返しされない 高 start
            /// <summary>
            /// テンプレート繰返し抽出条件 - イベント開始日
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_MODE_EVENTSTARTDATE = "event_start_date";
            // add #10605 観察記録がテンプレート繰返しされない 高 end
            //add #8763 zhu start
            /// <summary>
            /// 繰り返しキー - 設定なし
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_NO_NONE = "";
            /// <summary>
            /// 繰り返しキー - 透析日モード-key
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_NO_ORDNO = "ord_no";
            /// <summary>
            /// 繰り返しキー - 処方箋交付日-key
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_NO_PRESCRIPTIONNO = "ord_prescription_no";
            /// <summary>
            /// 繰り返しキー - 検査日モード-key
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_NO_MAINCD = "exam_main_cd";
            /// <summary>
            /// 繰り返しキー - 放射線検査日-key
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_NO_RESULTCD = "rad_result_cd";
            /// <summary>
            /// 繰り返しキー - 点検日-key
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_NO_MAINTENO = "mainte_no";
            //add #8763 zhu end 
        }

        /// <summary>
        /// URI 用定数定義
        /// </summary>
        public static class Uri
        {
            /// <summary>
            /// アプリケーションURI
            /// </summary>
            public const string WEB_APP = @"/ntss-admin-web";

            /// <summary>
            /// 観察記録種別一覧取得用URI
            /// </summary>
            public const string GET_MST_OBSKIND_ALL = @"/api/pat_obs_rec/mst/kind-all";

            /// <summary>
            /// 薬剤フィルタ表示用データ取得用URI
            /// </summary>
            // mod #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 高 start
            //public const string GET_ABS_MEDICINE = @"/api/medicine";
            public const string GET_ABS_MEDICINE = @"/api/report_designer/medicine";
            // mod #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 高 end

            /// <summary>
            /// 医材フィルタ表示用データ取得URI
            /// </summary>
            public const string GET_ABS_EQUIP = @"/api/report_designer/equipment";
            //add #8489 zhu start
            /// <summary>
            /// ダイアライザフィルタ表示用データ取得URI
            /// </summary>
            // mod #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
            //public const string GET_ABS_Distribution = @"/api/report_designer/dialyzer";
            public const string GET_ABS_Distribution = @"/api/report_designer/master/dialyzer";
            // mod #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
            //add #8489 zhu start

            /// <summary>
            /// 透析困難フィルタ表示用データ取得URI
            /// </summary>
            public const string GET_ABS_DIAL_DIFF = @"/api/report_designer/dialysis_difficulties";

            /// <summary>
            /// 検査項目フィルタ表示用データ取得URI
            /// </summary>
            public const string GET_MST_EXAM_ITEM = @"/api/report_designer/master/exam_item";

            /// <summary>
            /// 検査セットフィルタ表示用データ取得URI
            /// </summary>
            public const string GET_MST_EXAM_SET = @"/api/report_designer/master/exam_set";

            /// <summary>
            /// イベントフィルタ表示用データ取得URI
            /// </summary>
            public const string GET_ABS_PAT_EVENT = @"/api/report_designer/pat_event";

            /// <summary>
            /// 
            /// </summary>
            public const string GET_MST_PAT_EVENT_SUB_CATEGORY = @"/api/report_designer/master/pat_event_sub_category";

            /// <summary>
            /// 加算フィルタ表示用データ取得URI
            /// </summary>
            public const String GET_ABS_ADDITION = @"/api/report_designer/master/addition";

            /// <summary>
            /// 水質調査箇所フィルタ表示用データ取得URI
            /// </summary>
            public const String GET_MST_WATER_SURVEY_POINT = @"/api/report_designer/master/water_survey_point";

            // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
            /// <summary>
            /// 日常・定期点検レイアウトマスタ表示用データ取得URI
            /// </summary>
            // mod #12055 日常点検仕様変更(#9451)のレイアウトデザイナー対応 高 start
            //public const String GET_MST_MAINTE_LAYOUT = @"/api/mente-layout/layout";
            //public const String GET_MST_MAINTE_DETAIL = @"/api/mente-layout/mainte_detail";
            public const String GET_MST_MAINTE_LAYOUT = @"/api/mente-layout";
			// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
            public const String GET_MST_MACHINE_TYPE = @"/api/report_designer/machine_type";
			// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
            // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
            //public const String GET_MST_MAINTE_DETAIL = @"/api/mente-layout/details";
            public const String GET_MST_MAINTE_DETAIL = @"/api/report_designer/Inspection";
            // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
            // mod #12055 日常点検仕様変更(#9451)のレイアウトデザイナー対応 高 end
            // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end

            // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  start
            /// <summary>
            /// 日常・定期点検レイアウトマスタ表示用データ取得URI
            /// </summary>
            public const String GET_SYS_REPORT_CLASS = @"/api/sys_report_class/getSysReportClassAll";
            // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  end

            // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
            /// <summary>
            /// レセプトフィルタ表示用データ取得用URI
            /// </summary>
            public const string GET_ABS_RECEIPT = @"/api/report_designer/Receipt";
            // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
            // add #12006 感染症がフィルタできない 高 start
            /// <summary>
            /// 感染症フィルタ表示用データ取得用URI
            /// </summary>
            public const string GET_ABS_INFECTION = @"/api/report_designer/master/infection";
            // add #12006 感染症がフィルタできない 高 end
            // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
            /// <summary>
            /// 水質検査種別フィルタ表示用データ取得用URI
            /// </summary>
            // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
            public const string GET_ABS_WQTESTTYPE = @"/api/report_designer/master/water_survey_type";
            /// <summary>
            /// 水質検査個所フィルタ表示用データ取得用URI
            /// </summary>
            public const string GET_ABS_WQTESTPOINT = @"/api/report_designer/water_survey_point";
            // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
            // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end

            /// <summary>
            /// 帳票マスタ用APIルートURI
            /// </summary>
            private const string API_MST_REPORT_ROOT = @"/api/master_report";
            /// <summary>
            /// 帳票マスタ一覧取得用URI "/api/master_report"
            /// </summary>
            public const string GET_MST_REPORT = API_MST_REPORT_ROOT;
            /// <summary>
            /// 帳票マスタ更新用URI "/api/master_report"
            /// </summary>
            public const string POST_MST_REPORT = API_MST_REPORT_ROOT;
            /// <summary>
            /// 帳票マスタ:帳票名変更用URI
            /// </summary>
            [Obsolete(PUT_MST_REPORT_USER_DATA +"を使用してください")]
            public const string PUT_MST_REPORT_REPORTNAME = API_MST_REPORT_ROOT + @"/report_name";
            /// <summary>
            /// 帳票マスタ:帳票ファイルへのパス変更用URI
            /// </summary>
            [Obsolete(PUT_MST_REPORT_USER_DATA +"を使用してください")]
            public const string PUT_MST_REPORT_REPORTPATH = API_MST_REPORT_ROOT + @"/report_path";
            /// <summary>
            /// 帳票マスタ:表示/非表示変更用URI
            /// </summary>
            [Obsolete(PUT_MST_REPORT_USER_DATA +"を使用してください")]
            public const string PUT_MST_REPORT_ISDISP = API_MST_REPORT_ROOT + @"/is_disp";
            /// <summary>
            /// 帳票マスタ:帳票名,表示フラグ,削除フラグ変更用URI "/api/master_report/list_data"
            /// </summary>
            public const string PUT_MST_REPORT_USER_DATA = API_MST_REPORT_ROOT + @"/list_data";
            // add 6589 帳票ツールの版数を適用するためのインターフェースの抽出　dongzl start
            /// <summary>
            /// 帳票マスタ:帳票履歴変更用URI "/api/master_report/edit_report_no"
            /// </summary>
            public const string PUT_MST_REPORT_NO = API_MST_REPORT_ROOT + @"/edit_report_no";
            // add 6589 帳票ツールの版数を適用するためのインターフェースの抽出　dongzl end
            //// end
            //add 6854 点検帳票：１つのレイアウトに複数の帳票が紐づけできてしまう 吉 start
            public const string PUT_MST_REPORT_CHECK_REPEAT = API_MST_REPORT_ROOT + @"/check_repeat";
            //add 6854 点検帳票：１つのレイアウトに複数の帳票が紐づけできてしまう 吉 end
            /// <summary>
            /// ファイルダウンロード用API
            /// </summary>
            public const string POST_S3_DOWNLOAD = @"/api/report_designer/download";
            /// <summary>
            /// ファイルアップロード用API
            /// </summary>
            public const string POST_S3_UPLOAD = @"/api/s3/upload";

            // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
            /// <summary>
            /// 施設マスタ用APIルートURI
            /// </summary>
            private const string API_MST_FACILITY_ROOT = @"/api/master_maintenance";
            /// <summary>
            /// 施設マスタ:表示用URI "/api/master_maintenance/mst_facility_setting/mst_facility"
            /// </summary>
            public const string GET_MST_FACILITY_DATA = API_MST_FACILITY_ROOT + @"/mst_facility_setting/mst_facility";
            // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
        }

        /// <summary>
        /// 帳票種別用定数定義
        /// </summary>
        public static class ReportTypeData
        {
            /// <summary>
            /// 帳票種別[透析レポート]
            /// </summary>
            public const string VAL_TYPE_DIALYSIS = InnerValueData.VAL_REPORTTYPE_DIALYSIS;
            /// <summary>
            /// 帳票種別[単患者帳票]
            /// </summary>
            public const string VAL_TYPE_ONE_PATIENT = InnerValueData.VAL_REPORTTYPE_ONE_PATIENT;
            /// <summary>
            /// 帳票種別[複数患者帳票]
            /// </summary>
            public const string VAL_TYPE_MULTI_PATIENT = InnerValueData.VAL_REPORTTYPE_MULTI_PATIENT;
            /// <summary>
            /// 帳票種別[準備リスト]
            /// </summary>
            public const string VAL_TYPE_EQUIPMENT_LIST = InnerValueData.VAL_REPORTTYPE_EQUIPMENT_LIST;
            /// <summary>
            /// 帳票種別[配布リスト(ベッド)]
            /// </summary>
            public const string VAL_TYPE_DISTRIBUTE_LIST_BED = InnerValueData.VAL_REPORTTYPE_DISTRIBUTE_LIST_BED;
            /// <summary>
            /// 帳票種別[配布リスト(物品)]
            /// </summary>
            public const string VAL_TYPE_DISTRIBUTE_LIST_EQUIPMENT = InnerValueData.VAL_REPORTTYPE_DISTRIBUTE_LIST_EQUIPMENT;
            /// <summary>
            /// 帳票種別[装置帳票]
            /// </summary>
            public const string VAL_TYPE_DEVICE = InnerValueData.VAL_REPORTTYPE_DEVICE;
            /// <summary>
            /// 帳票種別[ラベル]
            /// </summary>
            public const string VAL_TYPE_LABEL = InnerValueData.VAL_REPORTTYPE_LABEL;
            /// <summary>
            /// "ReferralLetter" 帳票種別[紹介状]
            /// </summary>
            public const string VAL_TYPE_REFERRAL_LETTER = InnerValueData.VAL_REPORTTYPE_REFERRAL_LETTER;
            // add FNSI-523 2次元帳票対応 夏 start
            /// <summary>
            /// 帳票種別[単一集計]
            /// </summary>
            public const string VAL_TYPE_ONE_TOTAL = InnerValueData.VAL_REPORTTYPE_ONE_TOTAL;
            /// <summary>
            /// 帳票種別[複数集計]
            /// </summary>
            public const string VAL_TYPE_MULTI_TOTAL = InnerValueData.VAL_REPORTTYPE_MULTI_TOTAL;
            // add FNSI-523 2次元帳票対応 夏 end
        }

        /// <summary>
        /// マスタデータ用定数定義
        /// </summary>
        public static class MasterData
        {
            /// <summary>
            /// 帳票マスタ用定数定義
            /// </summary>
            public static class Report
            {
                /// <summary>
                /// 帳票種別[透析レポート]
                /// </summary>
                public const int VAL_TYPE_DIALYSIS = 1;

                /// <summary>
                /// 帳票種別[単患者帳票]
                /// </summary>
                public const int VAL_TYPE_ONE_PATIENT = 2;

                /// <summary>
                /// 帳票種別[複数患者帳票]
                /// </summary>
                public const int VAL_TYPE_MULTI_PATIENT = 3;

                /// <summary>
                /// 帳票種別[準備リスト]
                /// </summary>
                public const int VAL_TYPE_EQUIPMENT_LIST = 4;

                /// <summary>
                /// 帳票種別[配布リスト(ベッド)]
                /// </summary>
                public const int VAL_TYPE_DISTRIBUTE_LIST_BED = 5;

                /// <summary>
                /// 帳票種別[配布リスト(物品)]
                /// </summary>
                public const int VAL_TYPE_DISTRIBUTE_LIST_EQUIPMENT = 6;

                /// <summary>
                /// 帳票種別[装置帳票]
                /// </summary>
                public const int VAL_TYPE_DEVICE = 7;

                /// <summary>
                /// 帳票種別[ラベル]
                /// </summary>
                public const int VAL_TYPE_LABEL = 8;

                /// <summary>
                /// 帳票種別[紹介状]
                /// </summary>
                public const int VAL_TYPE_REFERRAL_LETTER = 9;

                // add FNSI-523 2次元帳票対応 夏 start
                /// <summary>
                /// 帳票種別[単一集計]
                /// </summary>
                public const int VAL_TYPE_ONE_TOTAL = 10;

                /// <summary>
                /// 帳票種別[複数集計]
                /// </summary>
                public const int VAL_TYPE_MULTI_TOTAL = 11;
                // add FNSI-523 2次元帳票対応 夏 end

            }
        }

        /// <summary>
        /// フィルタ種別用定数定義
        /// </summary>
        public static class FilterType
        {
            /// <summary>
            /// パラメータデータ用フィルタ種別定義定数
            /// </summary>
            public static class Parameter
            {
                /// <summary>
                /// 
                /// </summary>
                public const string CATEGORY = "Category";

                /// <summary>
                /// フィルタ種別 - 検査項目
                /// </summary>
                public const string EXAMINE = "Examin";
                /// <summary>
                /// フィルタ種別 - 検査セット
                /// </summary>
                public const string EXAM_SET = "ExamSet";
                /// <summary>
                /// フィルタ種別 - 空検査
                /// </summary>
                [Obsolete("使用用途要確認")]
                public const string EXAM_NULL = "ExamNull";
                /// <summary>
                /// フィルタ種別 - 水質調査箇所
                /// </summary>
                public const string WATER_SURVEY = "WaterSurvey";
                /// <summary>
                /// フィルタ種別 - 空水質調査箇所
                /// </summary>
                [Obsolete("使用用途要確認")]
                public const string WATER_NULL = "WaterNull";
                /// <summary>
                /// フィルタ種別 - 空値拒否
                /// </summary>
                [Obsolete("使用用途要確認")]
                public const string IS_NOT_NULL = "IsNotNull";
                // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
                /// <summary>
                /// フィルタ種別 - 点検
                /// </summary>
                public const string INSPECTION = "Inspection";
                // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end

                // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                /// <summary>
                /// フィルタ種別 - 薬剤
                /// </summary>
                public const string MEDICINE = "Medicine";
                /// <summary>
                /// フィルタ種別 - 医材
                /// </summary>
                public const string EQUIP = "Equip";
                /// <summary>
                /// フィルタ種別 - 観察記録種別
                /// </summary>
                public const string OBSKIND = "Llt";
                /// <summary>
                /// フィルタ種別 - 患者イベントカテゴリ
                /// </summary>
                public const string PATEVENT = "Event";
                /// <summary>
                /// フィルタ種別 - 加算
                /// </summary>
                public const string ADDITION = "ReceMemo";  
                /// <summary>
                /// フィルタ種別 - 透析困難コメント
                /// </summary>
                public const string DIALDIFF = "DialDiff";
                /// <summary>
                /// フィルタ種別 - 医材
                /// </summary>
                public const string EQUIPMENT = "Equipment";
                // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                //add #8489 zhu start
                /// <summary>
                /// フィルタ種別 - 配布リスト(ベッド)
                /// </summary>
                public const string DISTRIBUTION = "Distribution";
                //add #8489 zhu end
                // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                /// <summary>
                /// フィルタ種別 - 水質検査種別
                /// </summary>
                public const string WQTESTTYPE = "WQTestType";
                /// <summary>
                /// フィルタ種別 - 水質検査個所
                /// </summary>
                public const string WQTESTPOINT = "WQTestPoint";
                // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
            }

            /// <summary>
            /// グループデータ用フィルタ種別定数定義
            /// </summary>
            public static class Group
            {
                /// <summary>
                /// フィルタ種別 - 薬剤
                /// </summary>
                public const string MEDICINE = "Medicine";
                /// <summary>
                /// フィルタ種別 - 医材
                /// </summary>
                public const string EQUIP = "Equip";
                /// <summary>
                /// フィルタ種別 - 観察記録種別
                /// </summary>
                public const string OBSKIND = "Llt";
                /// <summary>
                /// フィルタ種別 - 患者イベントカテゴリ
                /// </summary>
                public const string PATEVENT = "Event";
                /// <summary>
                /// フィルタ種別 - 加算
                /// </summary>
                public const string ADDITION = "ReceMemo";  // TODO: 本来は適切なキーワードに変更するべき
                /// <summary>
                /// フィルタ種別 - 透析困難コメント
                /// </summary>
                public const string DIALDIFF = "DialDiff";

                //and #5601 2021-09-23 医材 鄭 start
                /// <summary>
                /// フィルタ種別 - 医材
                /// </summary>
                public const string EQUIPMENT = "Equipment";
                //and  #5601 2021-09-23 医材 鄭 start

 				//add #8615 zhu start
                /// <summary>
                /// 
                /// </summary>
                public const string CATEGORY = "Category";

                /// <summary>
                /// フィルタ種別 - 検査項目
                /// </summary>
                public const string EXAMINE = "Examin";
                /// <summary>
                /// フィルタ種別 - 検査セット
                /// </summary>
                public const string EXAM_SET = "ExamSet";

                /// <summary>
                /// フィルタ種別 - 水質調査箇所
                /// </summary>
                public const string WATER_SURVEY = "WaterSurvey";
   
                // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
                /// <summary>
                /// フィルタ種別 - 点検
                /// </summary>
                public const string INSPECTION = "Inspection";
                // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end


                //add #8615 zhu end
                //add #8489 zhu start
                /// <summary>
                /// フィルタ種別 - 配布リスト(ベッド)
                /// </summary>
                public const string DISTRIBUTION = "Distribution";
                //add #8489 zhu end

                // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
                /// <summary>
                /// フィルタ種別 - レセプト
                /// </summary>
                public const string PECEIPT = "Receipt";
                // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end

                // add #11625 クラス「指示履歴」の仕様変更② 高 start
                /// <summary>
                /// フィルタ種別 - 指示履歴
                /// </summary>
                public const string LOGTARGET = "logTarget";
                // add #11625 クラス「指示履歴」の仕様変更② 高 end

                // add #12006 感染症がフィルタできない 高 start
                /// <summary>
                /// フィルタ種別 - 感染症
                /// </summary>
                public const string INFECTION = "Infection";
                // add #12006 感染症がフィルタできない 高 end

                // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
                /// <summary>
                /// フィルタ種別 - 器材
                /// </summary>
                public const string EQUIP_DIA = "EquipDia";
                // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
                // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
                /// <summary>
                /// フィルタ種別 - 水質検査種別
                /// </summary>
                public const string WQTESTTYPE = "WQTestType";
                // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                /// <summary>
                /// フィルタ種別 - 水質検査個所
                /// </summary>
                public const string WQTESTPOINT = "WQTestPoint";
                // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
            }
        }

        /// <summary>
        /// フィルタデータ用定数定義
        /// </summary>
        public static class FilterData
        {
            /// <summary>
            /// [ルート]
            /// </summary>
            public const string TAG_ROOT = @"SelectSetting";

            /// <summary>
            /// [/アイテム]
            /// </summary>
            public const string TAG_ITEM = @"Item";

            /// <summary>
            /// [/アイテム/@コード]
            /// </summary>
            public const string ATT_ITEM_CODE = @"code";
            // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 start
            // <summary>
            /// [/アイテム/@Name]
            /// </summary>
            public const string ATT_ITEM_NAME = @"name";
            // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 end
            /// <summary>
            /// [/アイテム/@透析前]
            /// </summary>
            public const string ATT_ITEM_EXAMCLASS_BEFORE = @"before";
            /// <summary>
            /// [/アイテム/@透析後]
            /// </summary>
            public const string ATT_ITEM_EXAMCLASS_AFTER = @"after";
            /// <summary>
            /// [/アイテム/@その他]
            /// </summary>
            public const string ATT_ITEM_EXAMCLASS_OTHER = @"other";

            /// <summary>
            /// [/アイテム/@タグデータ]
            /// </summary>
            public const string ATT_ITEM_TAG = @"tag";
            /// <summary>
            /// [/アイテム/@チェック状態]
            /// </summary>
            public const string ATT_ITEM_CHECKSTATE = @"checkState";

            /// <summary>
            /// フィルタ区切り文字
            /// </summary>
            public const string SPLITSTR_FILTER = ".";

            /// <summary>
            /// [/アイテム/@透析前] or [/アイテム/@透析後] or [/アイテム/@その他] = '選択'
            /// </summary>
            public const string VAL_ATT_ITEM_EXAMCLASS_ON = "1";
            /// <summary>
            /// [/アイテム/@透析前] or [/アイテム/@透析後] or [/アイテム/@その他] = '未選択'
            /// </summary>
            public const string VAL_ATT_ITEM_EXAMCLASS_OFF = "0";
        }

        /// <summary>
        /// 設定データ用定数定義
        /// </summary>
        public static class SettingData
        {
            /// <summary>
            /// 帳票種別保存先アドレス
            /// </summary>
            public const string CELLADDR_REPORT_TYPE = @"A1";

            /// <summary>
            /// レポートCD
            /// </summary>
            public const string CELLADDR_REPORT_CODE = @"A2";

            /// <summary>
            /// テンプレート繰返し有無保存先アドレス
            /// </summary>
            public const string CELLADDR_HAS_TEMPLETE = @"A3";

            /// <summary>
            /// テンプレート繰返し有無値 - 無し
            /// </summary>
            public const string VAL_HAS_TEMPLETE_NO = InnerValueData.VAL_HAS_TEMPLETE_NO;
            /// <summary>
            /// テンプレート繰返し有無値 - 有り
            /// </summary>
            public const string VAL_HAS_TEMPLETE_YES = InnerValueData.VAL_HAS_TEMPLETE_YES;
        }

        /// <summary>
        /// パラメータ編集データ用定数定義
        /// </summary>
        public static class ParamData
        {
            /// <summary>
            /// 繰返し範囲区切り文字
            /// </summary>
            public const string SPLITSTR_REPEATADDRESS = ",";

            /// <summary>
            /// データ種別[数値]
            /// </summary>
            public const string VAL_DATATYPE_DECIMAL = InnerValueData.VAL_DATATYPE_DECIMAL;
            /// <summary>
            /// データ種別[文字列]
            /// </summary>
            public const string VAL_DATATYPE_STRING = InnerValueData.VAL_DATATYPE_STRING;
            /// <summary>
            /// データ種別[日付]
            /// </summary>
            public const string VAL_DATATYPE_DATETIME = InnerValueData.VAL_DATATYPE_DATETIME;
            /// <summary>
            /// データ種別[画像]
            /// </summary>
            public const string VAL_DATATYPE_IMAGE = InnerValueData.VAL_DATATYPE_IMAGE;

            /// <summary>
            /// 改ページ有無値 - 無し
            /// </summary>
            public const string VAL_ISNEWPAGE_FALSE = InnerValueData.VAL_ISNEWPAGE_FALSE;
            /// <summary>
            /// 改ページ有無値 - 有り
            /// </summary>
            public const string VAL_ISNEWPAGE_TRUE = InnerValueData.VAL_ISNEWPAGE_TRUE;

            /// <summary>
            /// 縮小して全体を表示するかどうか - 縮小しない
            /// </summary>
            public const string VAL_ISSHRINK_NONE = InnerValueData.VAL_ISSHRINK_NONE;
            /// <summary>
            /// 縮小して全体を表示するかどうか - 縮小する
            /// </summary>
            public const string VAL_ISSHRINK_DONE = InnerValueData.VAL_ISSHRINK_DONE;

            /// <summary>
            /// フィルタ選択状態 - 未設定
            /// </summary>
            public const string VAL_FILTER_STATE_NO = @"未設定";
            /// <summary>
            /// フィルタ選択状態 - 設定済
            /// </summary>
            public const string VAL_FILTER_STATE_YES = @"設定済";
            // add #12050 FNW帳票コンバートで維持されない設定がある 高 start
            /// <summary>
            /// フィルタ選択状態 - 設定済
            /// </summary>
            public const string VAL_FILTER_STATE_RESET = @"※要再設定";
            // add #12050 FNW帳票コンバートで維持されない設定がある 高 end

            /// <summary>
            /// テンプレート内外[無]
            /// </summary>
            public const string VAL_IS_IN_TEMPLETE_NONE = InnerValueData.VAL_IS_IN_TEMPLETE_NONE;
            /// <summary>
            /// テンプレート内外[内]
            /// </summary>
            public const string VAL_IS_IN_TEMPLETE_IN = InnerValueData.VAL_IS_IN_TEMPLETE_IN;
            /// <summary>
            /// テンプレート内外[外]
            /// </summary>
            public const string VAL_IS_IN_TEMPLETE_OUT = InnerValueData.VAL_IS_IN_TEMPLETE_OUT;
        }

        /// <summary>
        /// グループ編集データ用定数定義
        /// </summary>
        public static class GroupData
        {
            /// <summary>
            /// フィルタ選択状態 - 全て選択
            /// </summary>
            public const string VAL_FILTER_STATE_ALL = InnerValueData.VAL_FILTER_STATE_ALL;
            /// <summary>
            /// フィルタ選択状態 - 一部選択
            /// </summary>
            public const string VAL_FILTER_STATE_PART = InnerValueData.VAL_FILTER_STATE_PART;

            /// <summary>
            /// 改ページ有無値 - 無し
            /// </summary>
            public const string VAL_ISNEWPAGE_FALSE = InnerValueData.VAL_ISNEWPAGE_FALSE;
            /// <summary>
            /// 改ページ有無値 - 有り
            /// </summary>
            public const string VAL_ISNEWPAGE_TRUE = InnerValueData.VAL_ISNEWPAGE_TRUE;

            /// <summary>
            /// テンプレート内外[無]
            /// </summary>
            public const string VAL_IS_IN_TEMPLETE_NONE = InnerValueData.VAL_IS_IN_TEMPLETE_NONE;
            /// <summary>
            /// テンプレート内外[内]
            /// </summary>
            public const string VAL_IS_IN_TEMPLETE_IN = InnerValueData.VAL_IS_IN_TEMPLETE_IN;
            /// <summary>
            /// テンプレート内外[外]
            /// </summary>
            public const string VAL_IS_IN_TEMPLETE_OUT = InnerValueData.VAL_IS_IN_TEMPLETE_OUT;
        }

        /// <summary>
        /// テンプレート繰返し用定数定義
        /// </summary>
        public static class TempleteData
        {
            // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
            /// <summary>
            /// (FNW帳票)テンプレート範囲保存先アドレス
            /// </summary>
            public const string FNW_CELLADDR_RANGE = @"A4";

            /// <summary>
            /// (FNW帳票)テンプレートの下移動幅保存先アドレス
            /// </summary>
            public const string FNW_CELLADDR_ROWCOUNT = @"A7";

            /// <summary>
            /// (FNW帳票)テンプレートの右移動幅保存先アドレス
            /// </summary>
            public const string FNW_CELLADDR_COLUMNCOUNT = @"A5";

            /// <summary>
            /// (FNW帳票)テンプレートの下移動回数保存先アドレス
            /// </summary>
            public const string FNW_CELLADDR_REPEAT_V = @"A8";

            /// <summary>
            /// (FNW帳票)テンプレートの右移動回数保存先アドレス
            /// </summary>
            public const string FNW_CELLADDR_REPEAT_H = @"A6";

            /// <summary>
            /// (FNW帳票)テンプレートの改ページフラグ保存先アドレス
            /// </summary>
            public const string FNW_CELLADDR_ISNEWPAGE = @"A9";

            /// <summary>
            /// (FNW帳票)テンプレートの繰り返し方向保存先アドレス
            /// </summary>
            public const string FNW_CELLADDR_DIRECTION = @"A10";
            // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

            /// <summary>
            /// テンプレート繰返し範囲保存先アドレス
            /// </summary>
            public const string CELLADDR_RANGE = @"A11";

            /// <summary>
            /// 行数保存先アドレス
            /// </summary>
            public const string CELLADDR_ROWCOUNT = @"A12";

            /// <summary>
            /// 列数保存先アドレス
            /// </summary>
            public const string CELLADDR_COLUMNCOUNT = @"A13";

            /// <summary>
            /// 繰返し回数(縦)保存先アドレス
            /// </summary>
            public const string CELLADDR_REPEAT_V = @"A14";

            /// <summary>
            /// 繰返し回数(横)保存先アドレス
            /// </summary>
            public const string CELLADDR_REPEAT_H = @"A15";

            /// <summary>
            /// 余白(縦)保存先アドレス
            /// </summary>
            public const string CELLADDR_MARGIN_V = @"A16";

            /// <summary>
            /// 余白(横)保存先アドレス
            /// </summary>
            public const string CELLADDR_MARGIN_H = @"A17";

            /// <summary>
            /// 改ページ有無保存先アドレス
            /// </summary>
            public const string CELLADDR_ISNEWPAGE = @"A18";

            /// <summary>
            /// 繰返し方向保存先アドレス
            /// </summary>
            public const string CELLADDR_DIRECTION = @"A19";

            /// <summary>
            /// テンプレート繰返しの抽出モード保存先アドレス
            /// </summary>
            public const string CELLADDR_REPEATMODE = @"A20";
            //add #8763 zhu start
            /// <summary>
            /// テンプレート繰返しの抽出モード保存先アドレス
            /// </summary>
            public const string CELLADDR_REPEATNO = @"A21";
            //add #8763 zhu start
            /// <summary>
            /// 改ページ有無値 - 無し
            /// </summary>
            public const string VAL_ISNEWPAGE_FALSE = InnerValueData.VAL_ISNEWPAGE_FALSE;
            /// <summary>
            /// 改ページ有無値 - 有り
            /// </summary>
            public const string VAL_ISNEWPAGE_TRUE = InnerValueData.VAL_ISNEWPAGE_TRUE;

            /// <summary>
            /// 繰返し方向値 - N型
            /// </summary>
            public const string VAL_DIRECTION_N = "N";
            /// <summary>
            /// 繰返し方向値 - Z型
            /// </summary>
            public const string VAL_DIRECTION_Z = "Z";

            /// <summary>
            /// 抽出条件 - 設定なし
            /// </summary>
            public const string VAL_REPEAT_MODE_NONE = InnerValueData.VAL_TEMPLETE_REPEAT_MODE_NONE;
            /// <summary>
            /// 抽出条件 - 透析日モード
            /// </summary>
            public const string VAL_REPEAT_MODE_DIALYSIS = InnerValueData.VAL_TEMPLETE_REPEAT_MODE_DIALYSIS;
            /// <summary>
            /// 抽出条件 - 検査日モード
            /// </summary>
            public const string VAL_REPEAT_MODE_EXAMIN = InnerValueData.VAL_TEMPLETE_REPEAT_MODE_EXAMIN;
            //add #8763-3 zhu start
            /// <summary>
            /// 抽出条件 - 処方箋交付日
            /// </summary>
            public const string VAL_REPEAT_MODE_PRESCRIPTIONNO = InnerValueData.VAL_TEMPLETE_REPEAT_MODE_PRESCRIPTIONNO;
            /// <summary>
            /// 抽出条件 - 放射線検査日
            /// </summary>
            public const string VAL_REPEAT_MODE_RESULTCD = InnerValueData.VAL_TEMPLETE_REPEAT_MODE_RESULTCD;
            /// <summary>
            /// 抽出条件 - 点検日
            /// </summary>
            public const string VAL_REPEAT_MODE_MAINTENO = InnerValueData.VAL_TEMPLETE_REPEAT_MODE_MAINTENO;
            //add #8763-3 zhu end
            // add #10605 観察記録がテンプレート繰返しされない 高 start
            /// <summary>
            /// 抽出条件 - イベント開始日
            /// </summary>
            public const string VAL_REPEAT_MODE_EVENTSTARTDATE = InnerValueData.VAL_TEMPLETE_REPEAT_MODE_EVENTSTARTDATE;
            // add #10605 観察記録がテンプレート繰返しされない 高 end
            //add #8763 zhu start
            /// <summary>
            /// 繰り返しキー - 設定なし
            /// </summary>
            public const string VAL_REPEAT_NO_NONE = InnerValueData.VAL_TEMPLETE_REPEAT_NO_NONE;
            /// <summary>
            /// 繰り返しキー - 治療番号
            /// </summary>
            public const string VAL_REPEAT_NO_ORDNO = InnerValueData.VAL_TEMPLETE_REPEAT_NO_ORDNO;
            /// <summary>
            /// 繰り返しキー - 処方番号
            /// </summary>
            public const string VAL_REPEAT_NO_PRESCRIPTIONNO = InnerValueData.VAL_TEMPLETE_REPEAT_NO_PRESCRIPTIONNO;
            /// <summary>
            /// 繰り返しキー - 検査番号
            /// </summary>
            public const string VAL_REPEAT_NO_MAINCD = InnerValueData.VAL_TEMPLETE_REPEAT_NO_MAINCD;
            /// <summary>
            /// 繰り返しキー - 放射線検査番号
            /// </summary>
            public const string VAL_REPEAT_NO_RESULTCD = InnerValueData.VAL_TEMPLETE_REPEAT_NO_RESULTCD;
            /// <summary>
            /// 繰り返しキー - 点検番号
            /// </summary>
            public const string VAL_REPEAT_NO_MAINTENO = InnerValueData.VAL_TEMPLETE_REPEAT_NO_MAINTENO;
            //add #8763 zhu end
        }

        // add FNSI-523 2次元帳票対応 夏 start
        /// <summary>
        /// 集計用定数定義
        /// </summary>
        public static class TotalData
        {
            /// <summary>
            /// 横の集計単位保存先アドレス
            /// </summary>
            public const string CELLADDR_UNITV = @"A31";

            /// <summary>
            /// 縦の集計単位保存先アドレス
            /// </summary>
            public const string CELLADDR_UNITH = @"A32";

            /// <summary>
            /// 集計単位日付保存先アドレス
            /// </summary>
            public const string CELLADDR_UNITDATE = @"A33";

            /// <summary>
            /// 表示内容保存先アドレス
            /// </summary>
            public const string CELLADDR_CONTENTS = @"A34";

            /// <summary>
            /// 表示変換保存先アドレス
            /// </summary>
            public const string CELLADDR_CONVERSION = @"A35";

            /// <summary>
            /// 縦の合計保存先アドレス
            /// </summary>
            public const string CELLADDR_COUNT_H = @"A36";

            /// <summary>
            /// 横の合計保存先アドレス
            /// </summary>
            public const string CELLADDR_COUNT_V = @"A37";

            /// <summary>
            /// 起点セル保存先アドレス
            /// </summary>
            public const string CELLADDR_ORIGINRANGE = @"A38";

            // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
            /// <summary>
            /// 終点セル保存先アドレス
            /// </summary>
            public const string CELLADDR_ENDPOIRANGE = @"C38";
            // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end

            // add #11973 日常点検一覧帳票が正常に出せない 高 start
            /// <summary>
            /// 表示内容種類保存先アドレス
            /// </summary>
            public const string CELLADDR_CONTENTS_TYPE = @"A39";
            // add #11973 日常点検一覧帳票が正常に出せない 高 end

            // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
            /// <summary>
            ///出力値のない列は省略する保存先アドレス
            /// </summary>
            public const string CELLADDR_EFFECT_DATA_V = @"C31";
            // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end

            // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
            /// <summary>
            ///出力値のない行は省略する保存先アドレス
            /// </summary>
            public const string CELLADDR_EFFECT_DATA_H = @"C32";
            // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end

            // add #6035 2021-12-28 紹介状で曜日単位の投与マトリクスが表示できない　孟堅 start
            /// <summary>
            /// 帳票区分保存先アドレス
            /// </summary>
            public const string CELLADDR_REPORTTYPE = @"A51";
            // add #6035　2021-12-28 紹介状で曜日単位の投与マトリクスが表示できない 孟堅　end
            // add #11011 集計内訳タブ仕様変更 高 start
            /// <summary>
            /// 横の集計単位保存先アドレス
            /// </summary>
            public const string CELLADDR_UNITV_ADDRESS = @"B31";

            /// <summary>
            /// 縦の集計単位保存先アドレス
            /// </summary>
            public const string CELLADDR_UNITH_ADDRESS = @"B32";
            // add #11011 集計内訳タブ仕様変更 高 end
        }
        // add FNSI-523 2次元帳票対応 夏 end

        // add UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 start
        /// <summary>
        /// 定期日常点検・交換部品記録簿用定数定義
        /// </summary>
        public static class InspectionLayoutData
        {
            /// <summary>
            /// 帳票区分保存先アドレス
            /// </summary>
            public const string CELLADDR_REPORTTYPE = @"A51";

            /// <summary>
            /// 用途CD保存先アドレス
            /// </summary>
            public const string CELLADDR_USECD = @"A52";

			// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
            ///// <summary>
            ///// 記録簿CD保存先アドレス
            ///// </summary>
            //public const string CELLADDR_RECORDCD = @"A53";

            ///// <summary>
            ///// 点検レイアウトCD保存先アドレス
            ///// </summary>
            //public const string CELLADDR_LAYOUTCD = @"A54";

            /// <summary>
            /// 型式CD保存先アドレス
            /// </summary>
            public const string CELLADDR_MACHINETYPECD = @"A53";
			// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
        }
        // add UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 end

        /// <summary>
        /// データ項目リストファイル用定数定義
        /// </summary>
        public static class ItemList
        {
            /// <summary>
            /// データ項目リスト[/帳票テーブル]
            /// </summary>
            public const string TAG_REPORTTABLE = @"reportTable";

            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票タグ]
            /// </summary>
            public const string TAG_REPORT = @"report";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/@帳票種別]
            /// </summary>
            public const string ATT_REPORT_TYPE = @"type";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/@帳票種別名]
            /// </summary>
            public const string ATT_REPORT_DISPNAME = @"dispName";

            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/項目テーブル]
            /// </summary>
            public const string TAG_DATATABLE = @"dataTable";

            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/項目テーブル/項目]
            /// </summary>
            public const string TAG_DATA = @"data";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@データ項目コード]
            /// </summary>
            public const string ATT_DATA_DATACODE = @"dataCode";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@データ項目名]
            /// </summary>
            public const string ATT_DATA_DATANAME = @"dataName";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@カテゴリ]
            /// </summary>
            public const string ATT_DATA_DATACATEGORY = @"dataCategory";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@クラス]
            /// </summary>
            public const string ATT_DATA_DATACLASS = @"dataClass";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@SQLコード]
            /// </summary>
            public const string ATT_DATA_SQLCODE = @"sqlCode";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@データ種別]
            /// </summary>
            public const string ATT_DATA_DATATYPE = @"dataType";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@繰返可否]
            /// </summary>
            public const string ATT_DATA_CANREPEAT = @"canRepeat";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@フィルタ種別]
            /// </summary>
            public const string ATT_DATA_FILTERTYPE = @"filterType";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@表示書式]
            /// </summary>
            public const string ATT_DATA_DISPFORMAT = @"dispFormat";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@計算式内使用可否]
            /// </summary>
            public const string ATT_DATA_CANCALC = @"canCalc";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@プレビューデータ]
            /// </summary>
            public const string ATT_DATA_PREVIEW = @"preview";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@使用可否施設フィルタ種別]
            /// </summary>
            public const string ATT_DATA_FACILITYFILTERTYPE = @"facilityFilterType";

            // add 2020-09-27 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 start
            /// <summary>
            /// データ整列化
            /// </summary>
            public const string DATA_SORT = "dataSort";
            // add 2020-09-27 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 end

            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@繰返可否='(既定値)']
            /// </summary>
            public const string VAL_DATA_CANREPEAT_DEFAULT = VAL_DATA_CANREPEAT_NO;
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@繰返可否='不可']
            /// </summary>
            public const string VAL_DATA_CANREPEAT_NO = "0";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@繰返可否='可']
            /// </summary>
            public const string VAL_DATA_CANREPEAT_YES = "1";

            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@計算式内使用可否='(既定値)']
            /// </summary>
            public const string VAL_DATA_CANCALC_DEFAULT = VAL_DATA_CANCALC_NO;
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@計算式内使用可否='使用不可']
            /// </summary>
            public const string VAL_DATA_CANCALC_NO = "0";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@計算式内使用可否='使用可']
            /// </summary>
            public const string VAL_DATA_CANCALC_YES = "1";

            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/変換テーブル]
            /// </summary>
            public const string TAG_CONVTABLE = @"convTable";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/変換テーブル/@クラス]
            /// </summary>
            public const string ATT_CONVTABLE_CLS = @"cls";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/変換テーブル/変換項目]
            /// </summary>
            public const string TAG_CONV = @"conv";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/変換テーブル/変換項目/@コード]
            /// </summary>
            public const string ATT_CONV_CODE = @"code";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/変換テーブル/変換項目/@データ]
            /// </summary>
            public const string ATT_CONV_ITEM = @"item";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/変換テーブル/変換項目/@表示名]
            /// </summary>
            public const string ATT_CONV_DISP = @"disp";

            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/施設テーブル]
            /// </summary>
            public const string TAG_FACILITYTABLE = @"facilityTable";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/施設テーブル/施設]
            /// </summary>
            public const string TAG_FACILITY = @"facility";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/施設テーブル/施設/@施設ハッシュ値]
            /// </summary>
            public const string ATT_FACILITY_CODE = @"code";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@使用可否施設フィルタ種別='(既定値)']
            /// </summary>
            public const string VAL_DATA_FACILITYFILTERTYPE_DEFAULT = VAL_DATA_FACILITYFILTERTYPE_USE;
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@使用可否施設フィルタ種別='使用不可']
            /// </summary>
            public const string VAL_DATA_FACILITYFILTERTYPE_DISUSE = "0";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@使用可否施設フィルタ種別='使用可']
            /// </summary>
            public const string VAL_DATA_FACILITYFILTERTYPE_USE = "1";
        }

        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
        /// <summary>
        /// コンバート用データ項目リストファイル用定数定義
        /// </summary>
        public static class ItemConvertList
        {
            /// <summary>
            /// 変換用データ項目リスト[/帳票テーブル]
            /// </summary>
            public const string TAG_REPORTTABLE = @"reportTable";

            /// <summary>
            /// 変換用データ項目リスト[/帳票テーブル/帳票/項目テーブル]
            /// </summary>
            public const string TAG_DATATABLE = @"dataTable";

            /// <summary>
            /// 変換用データ項目リスト[/帳票テーブル/帳票/項目テーブル/項目]
            /// </summary>
            public const string TAG_DATA = @"data";
            /// <summary>
            /// 変換用データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@データ項目名]
            /// </summary>
            public const string ATT_DATA_DATANAME = @"dataName";
            /// <summary>
            /// 変換用データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@新データ項目名]
            /// </summary>
            public const string ATT_DATA_NEW_DATANAME = @"newDataName";
        }
        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

        // add #9651 帳票表示項目の並び順を変更する 高 start
        /// <summary>
        /// 帳票表示項目の並び順項目リストファイル用定数定義
        /// </summary>
        public static class ItemOrderList
        {
            /// <summary>
            /// 並び順項目リスト[/帳票テーブル]
            /// </summary>
            public const string TAG_REPORTTABLE = @"reportTable";

            /// <summary>
            /// 並び順項目リスト[/帳票テーブル/帳票/項目テーブル]
            /// </summary>
            public const string TAG_DATATABLE = @"dataTable";

            /// <summary>
            /// 並び順項目リスト[/帳票テーブル/帳票/項目テーブル/項目]
            /// </summary>
            public const string TAG_DATA = @"data";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@カテゴリ]
            /// </summary>
            public const string ATT_DATA_DATACATEGORY = @"dataCategory";
            /// <summary>
            /// データ項目リスト[/帳票テーブル/帳票/データ項目テーブル/データ項目/@クラス]
            /// </summary>
            public const string ATT_DATA_DATACLASS = @"dataClass";
        }
        // add #9651 帳票表示項目の並び順を変更する 高 end

        /// <summary>
        /// 帳票定義ファイル用定数定義
        /// </summary>
        public static class ReportDefine
        {
            /// <summary>
            /// 帳票定義[ルート]
            /// </summary>
            public const string TAG_ROOT = @"ReportDefinition";

            /// <summary>
            /// 帳票定義[/帳票]
            /// </summary>
            public const string TAG_REPORT = @"report";
            /// <summary>
            /// 帳票定義[/帳票/@帳票種別]
            /// </summary>
            public const string ATT_REPORT_TYPE = @"type";
            /// <summary>
            /// 帳票定義[/帳票/@テンプレート繰返有無]
            /// </summary>
            public const string ATT_REPORT_HAS_TEMPLETE = @"hasTmpl";

            /// <summary>
            /// 帳票定義[/パラメータテーブル]
            /// </summary>
            public const string TAG_PARAMTABLE = @"paramTable";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ]
            /// </summary>
            public const string TAG_PARAM = @"param";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@ID]
            /// </summary>
            public const string ATT_PARAM_ID = @"id";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@表示種別]
            /// </summary>
            public const string ATT_PARAM_DISPTYPE = @"dispType";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@データ項目コード]
            /// </summary>
            public const string ATT_PARAM_DATACODE = @"dataCode";
            // add #11276 キー日付に対するデータ引き当て仕様対応 高 start
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@データ Path]
            /// </summary>
            public const string ATT_PARAM_DATAPATH = @"dataPath";
            // add #11276 キー日付に対するデータ引き当て仕様対応 高 end
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@SQLコード]
            /// </summary>
            public const string ATT_PARAM_SQLCODE = @"sqlCode";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@データ種別]
            /// </summary>
            public const string ATT_PARAM_DATATYPE = @"dataType";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@表示文字数]
            /// </summary>
            public const string ATT_PARAM_DISPLENGTH = @"dispLength";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@フィルタ種別]
            /// </summary>
            public const string ATT_PARAM_FILTERTYPE = @"filterType";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@表示書式]
            /// </summary>
            public const string ATT_PARAM_DISPFORMAT = @"dispFormat";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@縮小して全体を表示]
            /// </summary>
            public const string ATT_PARAM_ISSHRINK = @"isShrink";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@グループID]
            /// </summary>
            public const string ATT_PARAM_GROUPID = @"groupID";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@テンプレート繰返し範囲に含まれているかどうか]
            /// </summary>
            public const string ATT_PARAM_ISINTEMPLETE = @"isInTmpl";

            /// <summary>
            /// 画像
            /// </summary>
            public const string ATT_PARAM_ISIMAGE = @"isImage";

            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@数式]
            /// </summary>
            public const string ATT_PARAM_FORMULA = @"formula";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@改ページするかどうか]
            /// </summary>
            public const string ATT_PARAM_ISNEWPAGE = @"isNewPage";

            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/変換リストテーブル]
            /// </summary>
            public const string TAG_CONVTABLE = @"convTable";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/変換リストテーブル/@クラス]
            /// </summary>
            public const string ATT_CONVTABLE_CLS = @"cls";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/変換リストテーブル/変換データ]
            /// </summary>
            public const string TAG_CONV = @"conv";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/変換リストテーブル/変換データ/@コード]
            /// </summary>
            public const string ATT_CONV_CODE = @"code";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/変換リストテーブル/変換データ/@アイテム]
            /// </summary>
            public const string ATT_CONV_ITEM = @"item";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/変換リストテーブル/変換データ/@表示内容]
            /// </summary>
            public const string ATT_CONV_DISP = @"disp";

            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/フィルタテーブル]
            /// </summary>
            public const string TAG_PARAM_FILTERTABLE = @"filterTable";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/フィルタテーブル/フィルタ]
            /// </summary>
            public const string TAG_PARAM_FILTER = @"filter";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/フィルタテーブル/フィルタ/@コード]
            /// </summary>
            public const string ATT_PARAM_FILTER_CODE = @"code";
            // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 start
            // <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/フィルタテーブル/フィルタ/@Name]
            /// </summary>
            public const string ATT_PARAM_FILTER_NAME = @"name";
            // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 end
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/フィルタテーブル/フィルタ/@透析前]
            /// </summary>
            public const string ATT_PARAM_FILTER_EXAM_BEFORE = @"before";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/フィルタテーブル/フィルタ/@透析後]
            /// </summary>
            public const string ATT_PARAM_FILTER_EXAM_AFTER = @"after";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/フィルタテーブル/フィルタ/@その他]
            /// </summary>
            public const string ATT_PARAM_FILTER_EXAM_OTHER = @"other";
            //add #8524 董 START
            /// 帳票定義[繰返し範囲]
            /// </summary>
            public const string ATT_PARAM_REPEATADDRESS = @"repeatAddress";
            //add #8524 董 START
            /////// <summary>
            /////// 帳票定義[/パラメータテーブル/パラメータ/変換リストテーブル/変換データ/数式項目テーブル]
            /////// </summary>
            ////public const String TAG_TERMTABLE = @"termTable";
            /////// <summary>
            /////// 帳票定義[/パラメータテーブル/パラメータ/変換リストテーブル/変換データ/数式項目テーブル/数式項目]
            /////// </summary>
            ////public const String TAG_TERM = @"term";
            /////// <summary>
            /////// 帳票定義[/パラメータテーブル/パラメータ/変換リストテーブル/変換データ/数式項目テーブル/数式項目/@ID]
            /////// </summary>
            ////public const String ATT_TERM_ID = @"id";
            /////// <summary>
            /////// 帳票定義[/パラメータテーブル/パラメータ/変換リストテーブル/変換データ/数式項目テーブル/数式項目/@データ項目コード]
            /////// </summary>
            ////public const String ATT_TERM_DATACODE = @"dataCode";
            /////// <summary>
            /////// 帳票定義[/パラメータテーブル/パラメータ/変換リストテーブル/変換データ/数式項目テーブル/数式項目/@SQLコード]
            /////// </summary>
            ////public const String ATT_TERM_SQLCODE = @"sqlCode";
            /////#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong start
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@表示文字数]
            /// </summary>
            public const string ATT_PARAM_ROWCOUNT = @"rowCount";
            //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong end

            /// <summary>
            /// 帳票定義[/グループテーブル]
            /// </summary>
            public const string TAG_GROUPTABLE = @"groupTable";
            /// <summary>
            /// 帳票定義[/グループテーブル/グループ]
            /// </summary>
            public const string TAG_GROUP = @"group";
            /// <summary>
            /// 帳票定義[/グループテーブル/グループ/@グループID]
            /// </summary>
            public const string ATT_GROUP_ID = @"id";
            /// <summary>
            /// 帳票定義[/グループテーブル/グループ/@１頁内での最大繰返回数]
            /// </summary>
            public const string ATT_GROUP_REPEATMAX = @"repeatMax";
            /// <summary>
            /// 帳票定義[/グループテーブル/グループ/@改ページするかどうか]
            /// </summary>
            public const string ATT_GROUP_ISNEWPAGE = @"isNewPage";
            /// <summary>
            /// 帳票定義[/グループテーブル/グループ/@フィルタ種別]
            /// </summary>
            public const string ATT_GROUP_FILTERTYPE = @"filterType";

            /// <summary>
            /// 帳票定義[/グループテーブル/グループ/フィルタテーブル]
            /// </summary>
            public const string TAG_GROUP_FILTERTABLE = @"filterTable";
            /// <summary>
            /// 帳票定義[/グループテーブル/グループ/フィルタテーブル/フィルタ]
            /// </summary>
            public const string TAG_GROUP_FILTER = @"filter";
            /// <summary>
            /// 帳票定義[/グループテーブル/グループ/フィルタテーブル/フィルタ/@アイテム]
            /// </summary>
            public const string ATT_GROUP_FILTER_ITEM = @"item";

            // add FNSI-523 2次元帳票対応 夏 start
            /// <summary>
            /// 帳票定義[/集計テーブル]
            /// </summary>
            public const string TAG_TOTALTABLE = @"totalTable";
            /// <summary>
            /// 帳票定義[/集計テーブル/@横の集計単位]
            /// </summary>
            public const string ATT_TOTALUNITV = @"unitV";
            /// <summary>
            /// 帳票定義[/集計テーブル/@縦の集計単位]
            /// </summary>
            public const string ATT_TOTALUNITH = @"unitH";
            /// <summary>
            /// 帳票定義[/集計テーブル/@集計単位日付]
            /// </summary>
            public const string ATT_TOTALUNITDATE = @"unitDate";
            // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
            /// <summary>
            /// 帳票定義[/集計テーブル/@出力値のない列は省略する]
            /// </summary>
            public const string ATT_TOTAL_EFFECT_DATA_V = @"effectDataV";
            // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
            // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
            /// <summary>
            /// 帳票定義[/集計テーブル/@出力値のない行は省略する]
            /// </summary>
            public const string ATT_TOTAL_EFFECT_DATA_H = @"effectDataH";
            // add #12218 集計の縦単位でも値のない行が出力できない設定を追加 limingzhe end
            /// <summary>
            /// 帳票定義[/集計テーブル/@表示内容]
            /// </summary>
            public const string ATT_TOTALCONTENTS = @"contents";
            /// <summary>
            // add #11973 日常点検一覧帳票が正常に出せない 高 start
            /// /// 帳票定義[/集計テーブル/@表示内容種類]
            /// </summary>
            public const string ATT_TOTALCONTENTSTYPE = @"contentsType";
            /// <summary>
            // add #11973 日常点検一覧帳票が正常に出せない 高 end
            /// 帳票定義[/集計テーブル/@表示変換]
            /// </summary>
            public const string ATT_TOTALCONVERSION = @"conversion";
            /// <summary>
            /// 帳票定義[/集計テーブル/@縦の合計]
            /// </summary>
            public const string ATT_TOTALCOUNTH = @"countH";
            /// <summary>
            /// 帳票定義[/集計テーブル/@横の合計]
            /// </summary>
            public const string ATT_TOTALCOUNTV = @"countV";
            /// <summary>
            /// 帳票定義[/集計テーブル/@起点セル]
            /// </summary>
            public const string ATT_TOTALORIGINRANGE = @"originRange";
            // add FNSI-523 2次元帳票対応 夏 end
            // add #11011 集計内訳タブ仕様変更 高 start
            /// <summary>
            /// 帳票定義[/集計テーブル/@横の集計単位Address]
            /// </summary>
            public const string ATT_TOTALUNITVADDRESS = @"unitVAddress";
            /// <summary>
            /// 帳票定義[/集計テーブル/@縦の集計単位Address]
            /// </summary>
            public const string ATT_TOTALUNITHADDRESS = @"unitHAddress";
            // add #11011 集計内訳タブ仕様変更 高 end

            /// <summary>
            /// 帳票定義[/テンプレート繰返し]
            /// </summary>
            public const string TAG_TEMPLETE = @"tmplRepeat";
            /// <summary>
            /// 帳票定義[/テンプレート繰返し/@テンプレートID]
            /// </summary>
            public const string ATT_TEMPLETE_ID = @"id";
            // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 start
            /// <summary>
            /// 帳票定義[/テンプレート繰返し/@繰返回数(縦)]
            /// </summary>
            public const string ATT_TEMPLETE_REPEAT_COUNTH = @"repeatCountH";
            /// <summary>
            /// 帳票定義[/テンプレート繰返し/@繰返回数(横)]
            /// </summary>
            public const string ATT_TEMPLETE_REPEAT_COUNTV = @"repeatCountV";
            /// <summary>
            /// 帳票定義[/テンプレート繰返し/@余白(縦)]
            /// </summary>
            public const string ATT_TEMPLETE_MARGINV = @"marginV";
            /// <summary>
            /// 帳票定義[/テンプレート繰返し/@余白(横)]
            /// </summary>
            public const string ATT_TEMPLETE_MARGINH = @"marginH";
            // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 end
            /// <summary>
            /// 帳票定義[/テンプレート繰返し/@１頁内での最大繰返回数]
            /// </summary>
            public const string ATT_TEMPLETE_REPEATMAX = @"repeatMax";
            /// <summary>
            /// 帳票定義[/テンプレート繰返し/@改ページするかどうか]
            /// </summary>
            public const string ATT_TEMPLETE_ISNEWPAGE = @"isNewPage";
            /// <summary>
            /// 帳票定義[/テンプレート繰返し/@繰返しモード]
            /// </summary>
            public const string ATT_TEMPLETE_REPEATMODE = @"repeatMode";
            //add #8763 zhu start
            /// <summary>
            /// 帳票定義[/テンプレート繰返し/@繰り返しキー]
            /// </summary>
            public const string ATT_TEMPLETE_REPEATNO = @"key";
            //add #8763 zhu end
            /// <summary>
            /// 帳票定義[/帳票/@テンプレート繰返し有無='無し']
            /// </summary>
            public const string VAL_REPORT_HAS_TEMPLETE_NO = InnerValueData.VAL_HAS_TEMPLETE_NO;
            /// <summary>
            /// 帳票定義[/帳票/@テンプレート繰返し有無='有り']
            /// </summary>
            public const string VAL_REPORT_HAS_TEMPLETE_YES = InnerValueData.VAL_HAS_TEMPLETE_YES;
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@表示種別='データ']
            /// </summary>
            public const string VAL_PARAM_DISPTYPE_DATA = "0";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@表示種別='計算結果']
            /// </summary>
            public const string VAL_PARAM_DISPTYPE_CALC = "1";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@縮小して全体を表示='行わない']
            /// </summary>
            public const string VAL_PARAM_ISSHRINK_NONE = "0";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@縮小して全体を表示='行う']
            /// </summary>
            public const string VAL_PARAM_ISSHRINK_DONE = "1";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@テンプレート繰返し範囲に含まれているか='無効']
            /// </summary>
            public const string VAL_PARAM_ISINTEMPLETE_NONE = InnerValueData.VAL_IS_IN_TEMPLETE_NONE;
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@テンプレート繰返し範囲に含まれているか='含まれていない']
            /// </summary>
            public const string VAL_PARAM_ISINTEMPLETE_NO = "0";
            /// <summary>
            /// 帳票定義[/パラメータテーブル/パラメータ/@テンプレート繰返し範囲に含まれているか='含まれている']
            /// </summary>
            public const string VAL_PARAM_ISINTEMPLETE_YES = "1";

            /// <summary>
            /// 帳票定義[/グループテーブル/グループ/@改ページを行うかどうか='行わない']
            /// </summary>
            public const string VAL_GROUP_ISNEWPAGE_FALSE = "0";
            /// <summary>
            /// 帳票定義[/グループテーブル/グループ/@改ページを行うかどうか='行う']
            /// </summary>
            public const string VAL_GROUP_ISNEWPAGE_TRUE = "1";

            /// <summary>
            /// 帳票定義[/テンプレート/@改ページを行うかどうか='行わない']
            /// </summary>
            public const string VAL_TEMPLETE_ISNEWPAGE_FALSE = "0";
            /// <summary>
            /// 帳票定義[/テンプレート/@改ページを行うかどうか='行う']
            /// </summary>
            public const string VAL_TEMPLETE_ISNEWPAGE_TRUE = "1";

            /// <summary>
            /// 帳票定義[/テンプレート繰返し/@繰返しモード='設定なし']
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_MODE_NONE = InnerValueData.VAL_TEMPLETE_REPEAT_MODE_NONE;
            /// <summary>
            /// 帳票定義[/テンプレート繰返し/@繰返しモード='透析日モード']
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_MODE_DIALYSIS = InnerValueData.VAL_TEMPLETE_REPEAT_MODE_DIALYSIS;
            /// <summary>
            /// 帳票定義[/テンプレート繰返し/@繰返しモード='検査日モード']
            /// </summary>
            public const string VAL_TEMPLETE_REPEAT_MODE_EXAMIN = InnerValueData.VAL_TEMPLETE_REPEAT_MODE_EXAMIN;

        }
    }
}
