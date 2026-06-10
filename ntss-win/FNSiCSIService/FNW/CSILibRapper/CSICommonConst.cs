using System;
using System.Collections.Generic;
using System.Text;

namespace jp.co.nikkiso.fn3.Cooperation.CSICoop
{
    /// <summary>
    /// シーエスアイ連携共通の定数定義を行います。
    /// </summary>
    public class CSICommonConst
    {
        #region 共通定義
        //--------------------------------------------------
        // 共通定義
        //--------------------------------------------------

        #region 処理区分
        /// <summary>
        /// 「0:false」設定値でのOFFとする
        /// </summary>
        public const string FALSE_CODE = "0";
        /// <summary>
        /// 「1:true」 設定値でのONとする
        /// </summary>
        public const string TRUE_CODE = "1";
        /// <summary>
        /// CSI側処理区分「新規」
        /// </summary>
        public const string PROCDIV_INSERT = "1";
        /// <summary>
        /// CSI側処理区分「修正」
        /// </summary>
        public const string PROCDIV_MODIFY = "2";
        /// <summary>
        /// CSI側処理区分「削除」
        /// </summary>
        public const string PROCDIV_DELETE = "3";
        /// <summary>
        /// CSI側処理区分「進捗変更」
        /// </summary>
        public const string PROCDIV_MODSTATUS = "6";
        /// <summary>
        /// CSI側処理区分「情報更新」
        /// </summary>
        public const string PROCDIV_RENEWINFO = "9";
        #endregion

        #region MIRAIs・エラーコード
        /// <summary>
        /// 対象患者情報未登録
        /// </summary>
        public const string ERRCODE_NOTEXISTSPATIENT = "IOT0004";
        /// <summary>
        /// この患者は別の端末にて処理中の為、新規登録処理以外は行えません。
        /// </summary>
        public const string ERRCODE_RETRYERR1 = "E0049";
        /// <summary>
        /// 患者ロック中です。
        /// </summary>
        public const string ERRCODE_RETRYERR2 = "F0001";
        /// <summary>
        /// データベース接続エラー
        /// </summary>
        public const string ERRCODE_RETRYERR3 = "D0001";
        /// <summary>
        /// 予約時間重複：処理継続（ワーニング）
        /// <value>WOT0000</value>
        /// </summary>
        public const string ERRCODE_RESERV_DUPLICATE = "WOT0000";
        #endregion
        #endregion


        #region レングス関連
        //--------------------------------------------------
        // レングス関連
        //--------------------------------------------------

        #region 患者情報
        /// <summary>
        /// 表示用患者ID
        /// </summary>
        public const int LEN_DISP_PATID = 12;
        /// <summary>
        /// 患者ID
        /// </summary>
        public const int LEN_PATID = 12;
        /// <summary>
        /// 氏名
        /// </summary>
        public const int LEN_NAME = 40;
        /// <summary>
        /// 氏名フリガナ
        /// </summary>
        public const int LEN_NAME_KANA = 40;
        #endregion
        #endregion


        #region 連携初期設定情報関連
        //--------------------------------------------------
        // 連携初期設定情報関連
        //--------------------------------------------------

        #region 設定区分
        /// <summary>
        /// 設定区分(共通:"0"/個別:"1")
        /// </summary>
        public const string SYS_DIV_UNIQUE = "1";
        #endregion

        #region セクション名(全て)
        /// <summary>
        /// 共通設定
        /// </summary>
        public const string SYS_SECT_COMMON = "CSI_COMMON";
        /// <summary>
        /// 透析予約送信
        /// </summary>
        public const string SYS_SECT_DIALYSISSCHESND = "CSI_DIALYSISSCHESND";
        /// <summary>
        /// 患者情報連携
        /// </summary>
        public const string SYS_SECT_PATIENTRCV = "CSI_PATIENTRCV";
        /// <summary>
        /// 透析実績送信
        /// </summary>
        public const string SYS_SECT_DIALYSISSND = "CSI_DIALYSISSND";
        /// <summary>
        /// 検査結果受信
        /// </summary>
        public const string SYS_SECT_EXAMINRCV = "CSI_EXAMINRCV";
        /// <summary>
        /// 検査予定送信
        /// </summary>
        public const string SYS_SECT_EXAMINSCHESEND = "CSI_EXAMINSCHESEND";
        // 2013/04/23 中村 科コード設定対応 Add Start
        /// <summary>
        /// 科コード設定
        /// </summary>
        public const string SYS_SECT_GROUPCD = "CSI_GROUPCD";
        // 2013/04/23 中村 科コード設定対応 Add End

        // 2014/03/17 阿部 クール別科目コード設定対応 Add Start
        /// <summary>
        /// クール別科目コード設定
        /// </summary>
        public const string SYS_SECT_DIALYSISSCHESND_KURAPPCD = "CSI_DIALYSISSCHESND_KURAPPCD";
        // 2014/03/17 阿部 クール別科目コード設定対応 Add End
        #endregion

        #region キー名(共通)
        /// <summary>
        /// データベース接続識別子
        /// </summary>
        public const string SYS_KEY_DB_NETSERVICE = "DB_NETSERVICE";
        /// <summary>
        /// データベース接続ユーザー名
        /// </summary>
        public const string SYS_KEY_DB_USER = "DB_USER";
        /// <summary>
        /// データベース接続パスワード
        /// </summary>
        public const string SYS_KEY_DB_PASSWORD = "DB_PASSWORD";
        /// <summary>
        /// 送信患者IDの桁数
        /// </summary>
        public const string SYS_KEY_SEND_PATID_FIGURES = "SEND_PATID_FIGURES";
        /// <summary>
        /// I/F部品使用モード（0：PARTS 1：JMS）
        /// </summary>
        public const string SYS_KEY_LIBRARY_TYPE = "LIBRARY_TYPE";        
        /// <summary>
        /// 連携対象動作モード（0：電子カルテ　1：オーダリング）
        /// </summary>
        public const string SYS_KEY_CONNECT_TYPE = "CONNECT_TYPE";
        // 2011/01/07 中村 指示医に患者基本情報.担当医を設定するよう変更
        /// <summary>
        /// デフォルト医師
        /// <value>DEFAULT_STAFF_CODE</value>
        /// </summary>
        public const string SYS_KEY_DEFAULT_STAFF_CODE = "DEFAULT_STAFF_CODE";

        // 2011/05/13 中村　指示医対応
        /// <summary>
        /// 指示医フラグ
        /// <value>INDICATOR_FLG</value>
        /// </summary>
        public const string SYS_KEY_INDICATOR_FLG = "INDICATOR_FLG";

        // 2016/04/11 中村 ポップアップ通知対応
        /// <summary>
        /// ポップアップ通知設定
        /// <value>POPUP_NOTICE</value>
        /// </summary>
        public const string SYS_KEY_POPUP_NOTICE = "POPUP_NOTICE";

        #endregion

        #region キー名(患者情報連携)
        /// <summary>
        /// 定期更新時刻
        /// </summary>
        public const string SYS_KEY_UPDATE_TIME = "PATIENTRCV_UPDATE_TIME";
        /// <summary>
        /// イベント通知DLL名
        /// </summary>
        public const string SYS_KEY_SEND_TO_DLL_NAME = "PATIENTRCV_DLL_NAME";
        /// <summary>
        /// 科コード
        /// </summary>
        public const string SYS_KEY_DEPTCODE = "DEPTCODE";
        /// <summary>
        /// 予約科目コード
        /// </summary>
        public const string SYS_KEY_APPCODE = "APPCODE";
        /// <summary>
        /// 予約行為コード
        /// </summary>
        public const string SYS_KEY_APPACTIONCODE = "APPACTIONCODE";
        /// <summary>
        /// 入力端末名
        /// </summary>
        public const string SYS_KEY_TERMINALNAME = "TERMINALNAME";

        // >>>>>【Ver.5.0.2.100】2015.07.30 石川 特殊浄化対応
        /// <summary>
        /// 特殊浄化予約科目コード
        /// </summary>
        public const string SYS_KEY_SPEC_APPCODE = "SPEC_APPCODE";
        /// <summary>
        /// 特殊浄化予約行為コード
        /// </summary>
        public const string SYS_KEY_SPEC_APPACTIONCODE = "SPEC_APPACTIONCODE";
        // <<<<<【Ver.5.0.2.100】2015.07.30 石川 特殊浄化対応

        // 2010/12/09 中村
        /// <summary>
        /// 予約削除スタッフコード
        /// <value>SCHE_DEL_STAFF_CODE</value>
        /// </summary>
        public const string SYS_KEY_SCHE_DEL_STAFF_CODE = "SCHE_DEL_STAFF_CODE";

        #endregion

        #region キー名(検査結果受信)
        /// <summary>
        /// 定期取込実施時刻
        /// </summary>
        public const string SYS_KEY_EXECUTE_TIME = "EXECUTE_TIME";
        /// <summary>
        /// MIRAIS「透析前」対応コード
        /// </summary>
        public const string SYS_KEY_DIALYSIS_CODE_BEFORE = "DIALYSIS_CODE_BEFORE";
        /// <summary>
        /// MIRAIS「透析後」対応コード
        /// </summary>
        public const string SYS_KEY_DIALYSIS_CODE_AFTER = "DIALYSIS_CODE_AFTER";
        /// <summary>
        /// コメント区切り文字
        /// </summary>
        public const string SYS_KEY_COMMENT_SEPARATE = "COMMENT_SEPARATE";
        #endregion

        #region キー名(透析実績送信)
        /// <summary>
        /// 透析実績依頼科
        /// </summary>
        public const string SYS_KEY_DAPARTMENT = "DAPARTMENT";
        /// <summary>
        /// 透析実績操作部署
        /// </summary>
        public const string SYS_KEY_ORDER_WARD = "ORDER_WARD";
        /// <summary>
        /// 透析実績入力端末
        /// </summary>
        public const string SYS_KEY_UPDATE_TERMINAL = "UPDATE_TERMINAL";
        /// <summary>
        /// 注射オーダ薬袋Ｉ／Ｆ使用フラグ
        /// </summary>
        public const string SYS_KEY_DRUGBAG_FLG = "DRUGBAG_FLG";
        /// <summary>
        /// 酸素吸入量コード
        /// </summary>
        public const string SYS_KEY_OXYGEN_INHALATION = "OXYGEN_INHALATION";        
        /// <summary>
        /// 抗凝固剤・手技
        /// </summary>
        public const string SYS_KEY_STRANTICOAGULANT_PROCEDURE_CODE = "STRANTICOAGULANT_PROCEDURE_CODE";
        /// <summary>
        /// 抗凝固剤・ルート項目コード
        /// </summary>
        public const string SYS_KEY_STRANTICOAGULANT_ROUTE_CODE = "STRANTICOAGULANT_ROUTE_CODE";
        /// <summary>
        /// 抗凝固剤・投与方法項目コード
        /// </summary>
        public const string SYS_KEY_STRANTICOAGULANT_METHOD_CODE = "STRANTICOAGULANT_METHOD_CODE";
        /// <summary>
        /// 透析液・手技
        /// </summary>
        public const string SYS_KEY_STRHEMODIALYSIS_PROCEDURE_CODE = "STRHEMODIALYSIS_PROCEDURE_CODE";
        /// <summary>
        /// 透析液・ルート項目
        /// </summary>
        public const string SYS_KEY_STRHEMODIALYSIS_ROUTE_CODE = "STRHEMODIALYSIS_ROUTE_CODE";
        /// <summary>
        /// 透析液・投与方法項目コード
        /// </summary>
        public const string SYS_KEY_STRHEMODIALYSIS_METHOD_CODE = "STRHEMODIALYSIS_METHOD_CODE";

        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        /// <summary>
        /// 酸素吸入行為送信フラグ
        /// </summary>
        public const string SYS_KEY_OXYGENACTION_SEND_FLAG = "OXYGENACTION_SEND_FLAG";
        /// <summary>
        /// 酸素吸入行為コード
        /// </summary>
        public const string SYS_KEY_OXYGENACTION_CODE = "OXYGENACTION_CODE";
        /// <summary>
        /// 処置行為送信フラグ
        /// </summary>
        public const string SYS_KEY_TREATMENTACTION_SEND_FLAG = "TREATMENTACTION_SEND_FLAG";
        /// <summary>
        /// 処置行為薬剤コード
        /// </summary>
        //public const string SYS_KEY_TREATMENTACTION_MEDICINE_CODES1 = "TREATMENTACTION_MEDICINE_CODES1";
        //public const string SYS_KEY_TREATMENTACTION_MEDICINE_CODES2 = "TREATMENTACTION_MEDICINE_CODES2";
        public const string SYS_KEY_TREATMENTACTION_MEDICINE_CODES = "TREATMENTACTION_MEDICINE_CODES";
        /// <summary>
        /// 処置行為まとめフラグ
        /// </summary>
        public const string SYS_KEY_TREATMENTACTION_UNITE_FLAG = "TREATMENTACTION_UNITE_FLAG";
        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

        // 2016/04/14 中村 その他処置行為送信仕様追加 Add Start
        /// <summary>
        /// 処置行為送信方法の切り替え設定
        /// </summary>
        public const string SYS_KEY_TREATMENTACTION_SEND_TYPE = "TREATMENTACTION_SEND_TYPE";

        /// <summary>
        /// 処置材料として扱う分類
        /// </summary>
        public const string SYS_KEY_EQUIP_CLASS_CODES = "EQUIP_CLASS_CODES";
        // 2016/04/14 中村 その他処置行為送信仕様追加 Add End

        // 2011/06/15 中村 補液送信対応
        /// <summary>
        /// 補液送信フラグ
        /// </summary>
        public const string SYS_KEY_REPLENISH_SEND_FLAG = "REPLENISH_SEND_FLAG";
        /// <summary>
        /// 補液・手技
        /// </summary>
        public const string SYS_KEY_STRREPLENISH_PROCEDURE_CODE = "STRREPLENISH_PROCEDURE_CODE";
        /// <summary>
        /// 補液・ルート項目コード
        /// </summary>
        public const string SYS_KEY_STRREPLENISH_ROUTE_CODE = "STRREPLENISH_ROUTE_CODE";
        /// <summary>
        /// 補液・投与方法項目コード
        /// </summary>
        public const string SYS_KEY_STRREPLENISH_METHOD_CODE = "STRREPLENISH_METHOD_CODE";

        // 2013/10/31 阿部(浩) 同手技送信方法対応 Add Start
        /// <summary>
        /// 注射オーダ同手技まとめフラグ
        /// </summary>
        public const string SYS_KEY_SAME_PROCEDURE_FLG = "SAME_PROCEDURE_FLG";
        // 2013/10/31 阿部(浩) 同手技送信方法対応 Add End

        // >>>>>【Ver.5.0.8.100】2025.05.12 Thach 心電図送信対応
        /// <summary>
        /// 心電図行為送信フラグ
        /// </summary>
        public const string SYS_KEY_ECGACTION_SEND_FLAG = "ECGACTION_SEND_FLAG";
        /// <summary>
        /// 心電図行為コード
        /// </summary>
        public const string SYS_KEY_ECGACTION_CODE = "ECGACTION_CODE";
        // <<<<<【Ver.5.0.8.100】2025.05.12 Thach 心電図送信対応

        /// <summary>
        /// 診療フリーモード
        /// </summary>
        public const string SYS_KEY_CLINICAL_FREE_MODE = "CLINICAL_FREE_MODE";

        #endregion

        #region キー名(検査予定送信)
        /// <summary>
        /// 検査オーダ依頼科コード
        /// </summary>
        public const string SYS_KEY_EXAM_DAPARTMENT = "DAPARTMENT";
        /// <summary>
        /// 検査オーダ依頼病棟コード
        /// </summary>
        public const string SYS_KEY_EXAM_WARD = "WARD";
        /// <summary>
        /// 検査オーダ入力端末コード
        /// </summary>
        public const string SYS_KEY_EXAM_UPDATE_TERMINAL = "UPDATE_TERMINAL";

        /// <summary>
        /// 予定削除スタッフコード
        /// </summary>
        public const string SYS_KEY_EXAM_DELETE_SCHEDULE_STAFF = "SCHE_DEL_STAFF_CODE";

        /// <summary>
        /// 透析前コメント名称
        /// </summary>
        public const string SYS_KEY_EXAM_COMMENT_DIAL_BEFORE = "COMMENT_NAME_DIAL_BEFORE";

        /// <summary>
        /// 透析後コメント名称
        /// </summary>
        public const string SYS_KEY_EXAM_COMMENT_DIAL_AFTER = "COMMENT_NAME_DIAL_AFTER";

        /// <summary>
        /// その他コメント名称
        /// </summary>
        public const string SYS_KEY_EXAM_COMMENT_OTHER = "COMMENT_NAME_OTHER";
        #endregion

        #region キー名(科コード設定)
        /// <summary>
        /// 所属グループコードの利用
        /// <value>PAT_GROUP_FLG</value>
        /// </summary>
        public const string SYS_KEY_PAT_GROUP_FLG = "PAT_GROUP_FLG";
        #endregion

        #endregion

        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        #region その他定数
        // 汎用オーダ番号管理用キー（人工腎臓）
        public const string ORDERNO_KEY_DIALYSIS = "GENERAL";
        // 汎用オーダ番号管理用キー（酸素吸入）
        public const string ORDERNO_KEY_OXYGEN = "O";
        // 汎用オーダ番号管理用キー（心電図）
        public const string ORDERNO_KEY_ECG = "E";
        // 汎用オーダ番号管理用セパレータ
        public const string ORDERNO_KEY_SEPARATER = ":";
        // 汎用オーダ番号管理用セパレータ
        public const string ORDERNO_PAIR_SEPARATER = "#";
        #endregion
        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

        #region ログ関連
        //--------------------------------------------------
        // ログ関連
        //--------------------------------------------------

        #region ログフォーマット
        /// <summary>
        /// 連携初期設定情報関連のログ出力用フォーマット文字列
        /// </summary>
        /// <remarks>
        /// 以下、使用例。
        /// Fn3ReturnCode retCode = this.GetInitialValue((設定区分), (セクション名), (キー名), ref (値));
        /// if (retCode.IsError || retCode.IsException || strValue.Trim().Equals(""))
        /// {
        ///     this.TraceOut(retCode, string.Format(CSICommonConst.SYS_LOG_FORMAT, (セクション名), (キー名), (値)) )
        /// }
        /// </remarks>
        public const string SYS_LOG_FORMAT = "Section=\"{0}\", Key=\"{1}\", Value=\"{2}\"";
        /// <summary>
        /// ログヘッダーフォーマット
        /// </summary>
        public const string SYS_LOG_HEADERFORMAT = "【{0}】【{1}】{2}";
        #endregion

        #region ログ文言
        /// <summary>
        /// 処理成功時のログ出力用の共通文言
        /// </summary>
        public const string DEBUGTRACE_PRE_SUCCESS_MSG = "【処理成功】";
        /// <summary>
        /// ログ種別・致命的エラー（エラートレース用）
        /// </summary>
        public const string LOGTYPE_FTL = "【致命的エラー】";
        /// <summary>
        /// ログ種別・通常エラー
        /// </summary>
        public const string LOGTYPE_ERR = "【エラー】";
        /// <summary>
        /// ログ種別・警告
        /// </summary>
        public const string LOGTYPE_WNG = "【警告】";
        /// <summary>
        /// ログ種別・デバック（デバックトレース用）
        /// </summary>
        public const string LOGTYPE_DBG = "【デバック】";
        /// <summary>
        /// モジュール名・透析レポート送信
        /// </summary>
        public const string MODULE_MNAME_DRS = "【透析レポート送信】";
        /// <summary>
        /// モジュール名・透析予約送信
        /// </summary>
        public const string MODULE_MNAME_DSS = "【透析予約送信】";
        /// <summary>
        /// モジュール名・透析実施送信
        /// </summary>
        public const string MODULE_MNAME_DS = "【透析実施送信】";
        /// <summary>
        /// モジュール名・検査結果受信
        /// </summary>
        public const string MODULE_MNAME_ER = "【検査結果受信】";
        /// <summary>
        /// モジュール名・患者情報受信定期イベント発行
        /// </summary>
        public const string MODULE_MNAME_PRS = "【患者情報受信定期イベント発行】";
        /// <summary>
        /// モジュール名・患者情報受信
        /// </summary>
        public const string MODULE_MNAME_PR = "【患者情報受信】";
        /// <summary>
        /// モジュール名・検査予定送信
        /// </summary>
        public const string MODULE_MNAME_ESS = "【検査予定送信】";
        #endregion
        #endregion


        #region ActiveXプログラム関連
        //--------------------------------------------------
        // ActiveXプログラム関連
        //--------------------------------------------------

        #region ActiveXプログラムID定義
        /// <summary>
        /// 他部門システム連携I/F共通
        /// </summary>
        public const string CSIPROGRAMID_COMMON = "COMMON.clsProcessEvent";      // COMMON
        /// <summary>
        /// 患者属性検索
        /// </summary>
        public const string CSIPROGRAMID_PATSCH = "PATSCH.clsProcessEvent";      // PATSCH
        /// <summary>
        /// 患者血液型検索
        /// </summary>
        public const string CSIPROGRAMID_BLOODTYPE = "BLOODTYPE.clsProcessEvent";   // BLOODTYPE
        /// <summary>
        /// 患者感染症検索
        /// </summary>
        public const string CSIPROGRAMID_INFECTION = "INFECTION.clsProcessEvent";   // INFECTION
        /// <summary>
        /// 患者保険情報検索
        /// </summary>
        public const string CSIPROGRAMID_INSURANCE = "INSURANCE.clsProcessEvent";   // INSURANCE
        /// <summary>
        /// 患者在院情報検索
        /// </summary>
        public const string CSIPROGRAMID_ADMSCH = "ADMSCH.clsProcessEvent";      // ADMSCH
        /// <summary>
        /// 患者予約情報検索
        /// </summary>
        public const string CSIPROGRAMID_PATAPPSCH = "PATAPPSCH.clsProcessEvent";   // PATAPPSCH
        /// <summary>
        /// 患者受付情報検索
        /// </summary>
        public const string CSIPROGRAMID_APPSCH = "APPSCH.clsProcessEvent";      // APPSCH
        /// <summary>
        /// 患者識別情報出力
        /// </summary>
        public const string CSIPROGRAMID_DIALYSIS = "DIALYSIS.clsProcessEvent";    // DIALYSIS
        /// <summary>
        /// 患者オーダ登録／変更
        /// </summary>
        public const string CSIPROGRAMID_ORDER = "ORDER.clsProcessEvent";       // ORDER
        /// <summary>
        /// 患者診療フリー登録／変更
        /// </summary>
        public const string CSIPROGRAMID_EXAMFREE = "EXAMFREE.clsProcessEvent";    // EXAMFREE
        /// <summary>
        /// 患者予約情報登録／変更
        /// </summary>
        public const string CSIPROGRAMID_APPPATIENT = "APPPATIENT.clsProcessEvent";  // APPPATIENT
        /// <summary>
        /// 患者オーダ情報取得
        /// </summary>
        public const string CSIPROGRAMID_OEDERGET = "ORDERGET.clsProcessEvent";    // OEDERGET
        #endregion
        #endregion
    }
}
