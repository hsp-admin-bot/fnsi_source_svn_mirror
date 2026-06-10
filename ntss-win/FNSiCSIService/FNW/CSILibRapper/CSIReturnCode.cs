using System;
using System.Collections.Generic;
using System.Text;
using jp.co.nikkiso.fn3.Cooperation;

namespace jp.co.nikkiso.fn3.Cooperation.CSICoop
{
    /// <summary>
    /// リターンコード定義クラス
    /// </summary>
    public sealed class CSIReturnCode : Fn3ReturnCode
    {
        #region 定数定義
        /// <summary>
        /// 処理区分ID
        /// </summary>
        private const string CPID_DIALYSISSCHESND = "410";      // 透析予約送信
        private const string CPID_DIALYSISSND = "420";          // 透析実績送信
        private const string CPID_PATIENTRCV = "500";           // 患者情報受信
        private const string CPID_EXAMINRCV = "540";            // 検体検査結果受信
        private const string CPID_EXAMINSCHESND = "460";        // 検体検査予定送信
        /// <summary>
        /// ログコードオフセット値
        /// </summary>
        private const int CODEOFFSET_PATIENTRCV = 1000;         // 患者情報連携
        private const int CODEOFFSET_DIALYSISSCHESND = 2000;    // 透析予約送信
        private const int CODEOFFSET_DIALYSISSND = 3000;        // 透析実績送信
        private const int CODEOFFSET_EXAMINRCV = 4000;          // 検体検査結果受信
        private const int CODEOFFSET_EXAMINSCHESND = 5000;      // 検体検査予定送信
        #endregion


        #region [1000～] 患者情報連携用エラーコード(1000～1499：患者情報受信／患者情報受信定期イベント発行：1500～1999)
        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_GETINITIALVALUE =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 001, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "初期設定情報に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_CREATEOBJECT =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 002, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクトの取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_CREATECOMMON =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 003, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（共通）の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_CREATEPATSCH =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 004, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（患者属性検索）の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_CREATEBLOODTYPE =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 005, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（患者血液型検索）の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_CREATEINFECTION =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 006, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（患者感染症検索）の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_CREATEADMSCH =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 007, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（患者在院情報検索）の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_CREATEDIALYSIS =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 008, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（患者識別情報出力）の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_DBOPEN =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 009, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBの接続に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_DBCLOSE =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 010, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBの切断に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_DBTRANSACTION =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 011, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBのトランザクション開始に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_DBCOMMIT =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 012, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBのコミットに失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_DBROLLBACK =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 013, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBのロールバックに失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_INITIALIZE =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 014, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "患者情報連携プラグインの初期化に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_NEWPATIENT =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 015, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "新規患者のチェックに失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_PATSCH =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 016, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "患者属性の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_BLOODTYPE =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 017, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "患者血液型の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_INFECTION =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 018, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "患者感染症の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_ADMSCH =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 019, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "患者在院情報の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_DIALYSIS =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 020, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "患者識別情報の登録に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_IMPORTPATIENT =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 021, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "患者の取込みに失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_NOTEXISTSPATIENT =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 022, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "対象患者は電子カルテに登録されていません。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_CONVERT =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 023, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "項目変換でエラーが発生しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_SET_PAT_INFO =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 024, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "患者情報登録に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_DEL_DIALYSIS_SCHEDUL =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 025, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "透析スケジュール削除に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_TRANSACTION =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 031, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "トランザクション開始に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_UPDATE =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 032, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "検査結果情報の更新に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_COMMIT =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 033, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "コミットに失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_ROLLBACK =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 034, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_ERR + "ロールバックに失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode FTL_PATIENT_RCV_CREATEOBJ =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 100, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_FTL + "CreateObject()でエラーが発生しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode FTL_PATIENT_RCV_INITIALIZE =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 101, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_FTL + "患者情報連携プラグインの初期化に失敗しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode FTL_PATIENT_RCV_IMPORTPATIENT =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 102, CSICommonConst.MODULE_MNAME_PR + CSICommonConst.LOGTYPE_FTL + "患者の取込みに失敗しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode MSG_PATIENT_RCV_NOTEXISTSPATIENT =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 200, "対象患者は電子カルテに登録されていません。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode MSG_PATIENT_RCV_IMPORTPATIENT =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 201, "患者の取込みに失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_SCHEDULER_INITIALIZE =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 500, CSICommonConst.MODULE_MNAME_PRS + CSICommonConst.LOGTYPE_ERR + "患者情報連携定期イベント発行プラグインの初期化に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_SCHEDULER_GET_SETTINGS =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 501, CSICommonConst.MODULE_MNAME_PRS + CSICommonConst.LOGTYPE_ERR + "患者情報連携定期イベント発行用初期設定の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_SCHEDULER_PATIENT_LIST =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 502, CSICommonConst.MODULE_MNAME_PRS + CSICommonConst.LOGTYPE_ERR + "定期更新対象患者のリスト取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_SCHEDULER_REGIST_EVENT =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 503, CSICommonConst.MODULE_MNAME_PRS + CSICommonConst.LOGTYPE_ERR + "患者更新イベント発行に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PATIENT_RCV_SCHEDULER_PATIENT_UPDATE =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 504, CSICommonConst.MODULE_MNAME_PRS + CSICommonConst.LOGTYPE_ERR + "患者情報の定期更新に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode FTL_PATIENT_RCV_SCHEDULER_PATIENT_LIST =
            new Fn3ReturnCode(CPID_PATIENTRCV, CODEOFFSET_PATIENTRCV + 600, CSICommonConst.MODULE_MNAME_PRS + CSICommonConst.LOGTYPE_FTL + "定期更新対象患者のリスト取得に失敗しました。", ReturnCodeType.Exception);
        #endregion


        #region [2000～] 透析予約送信用エラーコード
        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_CREATECOMMON =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 001, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（共通）の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_DBOPEN =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 002, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBの接続に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_DBCLOSE =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 003, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBの切断に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_DBTRANSACTION =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 004, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBのトランザクション開始に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_DBCOMMIT =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 005, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBのコミットに失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_DBROLLBACK =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 006, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBのロールバックに失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_INITIALVALUEFAILED =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 101, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "透析予約送信プラグインの初期設定値の取得に失敗しました。", ReturnCodeType.Error);

        // 2013/04/23 中村 科コード設定対応 Add Start
        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_GROUPCD_FAILED =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 102, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "科コード設定の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_MSTBED_FAILED =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 103, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "ベッドマスタの参照に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_MSTPATGROUP_FAILED =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 104, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "ベッド番号・科コード対応情報が設定されていません。", ReturnCodeType.Error);
        // 2013/04/23 中村 科コード設定対応 Add End

        // 2014/03/17 阿部 クール別科目コード設定対応 Add Start
        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_KURAPPCD_FAILED =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 105, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "クール別科目コード設定の取得に失敗しました。", ReturnCodeType.Error);
        // 2014/03/17 阿部 クール別科目コード設定対応 Add End

        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_CREATEAPPPATIENT =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 201, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（患者予約情報登録／変更）の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_INPUT =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 202, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "外部I/Fメソッド（患者予約情報登録／変更）のエラーです。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_INVARIDDIV =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 203, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "不正な処理区分です。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_GETVALUE =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 204, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "送信情報の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_INVALIDVALUE =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 205, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "送信情報の値が不正です。", ReturnCodeType.Error);

        // 2016/04/11 中村 ポップアップ通知 Add Start
        public static readonly Fn3ReturnCode ERR_REGIST_POPUP =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 206, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "ポップアップ通知に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_NOT_EXIST_IF_EVENT_LOG =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 207, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "連携イベントログテーブルが存在しないため、ポップアップ通知をスキップします。", ReturnCodeType.Error);
        // 2016/04/11 中村 ポップアップ通知 Add End

        public static readonly Fn3ReturnCode ERR_DIALYSISSCHE_SND_EXCLUSION =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 301, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "指定患者IDが排他エラーのためリトライします", ReturnCodeType.Error);

        // 2011/05/13 中村 指示医対応
        public static readonly Fn3ReturnCode WNG_DIALYSISSCHE_SND_INDICATOR =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 401, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_ERR + "指示医情報の取得に失敗しました。", ReturnCodeType.Warning);

        // 2016/04/11 中村 ポップアップ通知
        public static readonly Fn3ReturnCode WNG_DIALYSISSCHE_POPUP_NOTICE =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 402, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_WNG + "ポップアップ通知設定の取得に失敗しました。", ReturnCodeType.Warning);

        public static readonly Fn3ReturnCode FTL_DIALYSISSCHE_SND_CREATEOBJ =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 501, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_FTL + "CreateObject()でエラーが発生しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode FTL_DIALYSISSCHE_SND_INITFAILED =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 502, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_FTL + "透析予約送信プラグインの初期化に失敗しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode FTL_DIALYSISSCHE_SND_INPUT_EX =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 503, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_FTL + "外部I/Fオブジェクト（患者予約情報登録／変更）で例外が発生しました。", ReturnCodeType.Exception);

        // 2011/05/13 中村 指示医対応
        public static readonly Fn3ReturnCode FTL_DIALYSISSCHE_SND_STAFFAUTH_EX =
            new Fn3ReturnCode(CPID_DIALYSISSCHESND, CODEOFFSET_DIALYSISSCHESND + 504, CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_FTL + "スタッフ権限取得で例外が発生しました。", ReturnCodeType.Exception);

        
        #endregion

        #region [3000～] 透析実績送信用エラーコード
        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_GETINITIALVALUE =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 001, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "初期設定情報に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_DBOPEN =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 002, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBの接続に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYLSIS_SND_DBCLOSE =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 003, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBの切断に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_DBTRANSACTION =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 004, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBのトランザクション開始に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_DBCOMMIT =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 005, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBのコミットに失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_DBROLLBACK =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 006, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBのロールバックに失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_SCHEDULE_INFO =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 007, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "予約情報の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_CREATEOBJECT_COMMON =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 010, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（共通）の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_CREATEOBJECT_ORDER =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 011, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（汎用オーダ登録／変更）の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_CREATEOBJECT_ORDERINJECTION =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 012, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（注射オーダ登録／変更）の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_CREATEOBJECT_EXAMFREE =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 013, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（患者診療フリー登録／変更）の取得に失敗しました。", ReturnCodeType.Error);

        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        //public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_ORDER =
        //    new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 020, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "汎用オーダ・送信処理でエラーが発生しました。", ReturnCodeType.Error);
        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_ORDER =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 020, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "汎用オーダ（人工腎臓）・送信処理でエラーが発生しました。", ReturnCodeType.Error);
        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_ORDERINJECTION =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 021, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "注射オーダ・送信処理でエラーが発生しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_EXAMRREE =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 022, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "患者診療フリー・送信処理でエラーが発生しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_MAKEDATA_ORDER =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 023, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "汎用オーダ・送信データが取得出来ません。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 024, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "注射オーダ・送信データが取得出来ません。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 025, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "患者診療フリー・送信データが取得出来ません。", ReturnCodeType.Error);
        
        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_SEND_ORDER =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 026, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "汎用オーダ・データの送信でエラーが発生しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_SEND_ORDERINJECTION =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 027, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "注射オーダ・データの送信でエラーが発生しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_SEND_EXAMRREE =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 028, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "患者診療フリー・データの送信でエラーが発生しました。", ReturnCodeType.Error);

        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_OXYGEN_ORDER =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 029, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "汎用オーダ（酸素吸入）・送信処理でエラーが発生しました。", ReturnCodeType.Error);
        
        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_TREATMENT_ORDER =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 030, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "汎用オーダ（その他の処置）・送信処理でエラーが発生しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_OXYGEN_ORVER =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 031, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "汎用オーダ（酸素吸入）・最大送信数10件を超えました。11件目以降の送信処理は行われません。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_TREAT_ORVER =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 032, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "汎用オーダ（その他の処置）・最大送信数20件を超えました。21件目以降の送信処理は行われません。", ReturnCodeType.Error);
        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

        // 2013/04/23 中村 科コード設定対応 Add Start
        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_GROUPCD_FAILED =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 033, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "科コード設定の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_MSTBED_FAILED =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 034, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "ベッドマスタの参照に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_MSTPATGROUP_FAILED =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 035, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "ベッド番号・科コード対応情報が設定されていません。", ReturnCodeType.Error);
        // 2013/04/23 中村 科コード設定対応 Add End

        // 2013/10/31 阿部(浩) 同手技送信方法対応 Add Start
        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_SAME_PROCEDURE_FAILED =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 036, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "注射オーダ同手技まとめフラグの取得に失敗しました。", ReturnCodeType.Error);
        // 2013/10/31 阿部(浩) 同手技送信方法対応 Add End

        // 2016/04/11 中村 ポップアップ通知 Add Start
        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_REGIST_POPUP =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 037, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "ポップアップ通知に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_NOT_EXIST_IF_EVENT_LOG =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 038, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "連携イベントログテーブルが存在しないため、ポップアップ通知をスキップします。", ReturnCodeType.Error);
        // 2016/04/11 中村 ポップアップ通知 Add End

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_ECG_ORVER =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 039, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "汎用オーダ（心電図）・最大送信数10件を超えました。11件目以降の送信処理は行われません。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_ECG_ORDER =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 040, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "汎用オーダ（心電図）・送信処理でエラーが発生しました。", ReturnCodeType.Error);


        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_MAKEDATA_ORDER =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 050, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "汎用オーダ・送信データが取得出来ません。＜処理続行＞", ReturnCodeType.Warning);

        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 051, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "注射オーダ・送信データが取得出来ません。＜処理続行＞", ReturnCodeType.Warning);

        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_MAKEDATA_EXAMRREE =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 052, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "患者診療フリー・送信データが取得出来ません。＜処理続行＞", ReturnCodeType.Warning);

        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_SCHEDULE_INFO =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 053, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "予約情報の取得に失敗しました。＜処理続行＞", ReturnCodeType.Warning);

        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION_NODATE =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 054, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "注射オーダ・注射オーダデータが存在しない為、送信処理は行われませんでした。＜処理続行＞", ReturnCodeType.Warning);

        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_MAKEDATA_ORDER_NODATE =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 055, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "汎用オーダ・データが存在しない汎用オーダの為、送信処理は行われませんでした。＜処理続行＞", ReturnCodeType.Warning);

        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_OXYGENORDER_FLAGOFF =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 056, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "汎用オーダ（酸素吸入）・送信フラグOFF。＜処理続行＞", ReturnCodeType.Warning);

        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_TREATMENTORDER_FLAGOFF =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 057, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "汎用オーダ（その他の処置）・送信フラグOFF。＜処理続行＞", ReturnCodeType.Warning);

        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

        // >>>>>【Ver.5.0.2.100】2015.07.30 石川 特殊浄化対応
        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 058, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "数量がNULLのため、送信データの出力対象から除外します。＜処理続行＞", ReturnCodeType.Warning);

        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 059, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "数量が0のため、送信データの出力対象から除外します。＜処理続行＞", ReturnCodeType.Warning);
        // <<<<<【Ver.5.0.2.100】2015.07.30 石川 特殊浄化対応


        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_SEND_ORDER_SUCCESS_ERR =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 060, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "汎用オーダ・データの送信は成功していますがエラーが発生しています。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_DIALYSIS_SND_SEND_ORDERINJECTION_SUCCESS_ERR =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 061, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "注射オーダ・データの送信は成功していますがエラーが発生しています。", ReturnCodeType.Error);

        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_INIT =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 070, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "Initialize()で警告が発生しています。＜処理続行＞", ReturnCodeType.Warning);
        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

        // 2011/05/13 中村 指示医対応
        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_DECIDER =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 071, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_ERR + "版確定者の取得に失敗しました。＜処理続行＞", ReturnCodeType.Warning);

        // >>>>>【Ver.5.0.2.100】2015.08.04 石川 特殊浄化対応
        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_OXYGEN_NOT_DATA =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 080, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "汎用オーダ（酸素吸入）・送信データが存在しない為 、処理をスキップします。＜処理続行＞", ReturnCodeType.Warning);

        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_INJECTION_NOT_DATA =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 081, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "注射オーダ・送信データが存在しない為 、処理をスキップします。＜処理続行＞", ReturnCodeType.Warning);
        // <<<<<【Ver.5.0.2.100】2015.08.04 石川 特殊浄化対応

        // 2016/04/13 中村 その他処置行為送信仕様追加
        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_TREATACTION_SEND_TYPE =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 082, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "処置行為送信方法の切り替え設定の取得に失敗しました。", ReturnCodeType.Warning);

        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_EQUIP_CLASS_CODES =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 083, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "処置材料として扱う分類設定の取得に失敗しました。", ReturnCodeType.Warning);

        // 2016/04/13 中村 ポップアップ通知
        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_POPUP_NOTICE =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 084, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "ポップアップ通知設定の取得に失敗しました。", ReturnCodeType.Warning);

        // >>>>>【Ver.5.0.8.100】2025.05.12 Thach 心電図送信対応

        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_ECGACTION_FLAG =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 085, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "心電図送信フラグ設定の取得に失敗しました。", ReturnCodeType.Warning);

        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_CLINICAL_FREE_MODE =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 086, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "診療フリーモード設定の取得に失敗しました。", ReturnCodeType.Warning);

        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_ECGORDER_FLAGOFF =
           new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 087, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "汎用オーダ（心電図）・送信フラグOFF。＜処理続行＞", ReturnCodeType.Warning);
        
        public static readonly Fn3ReturnCode WNG_DIALYSIS_SND_ECG_NOT_DATA =
           new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 088, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_WNG + "汎用オーダ（心電図）・送信データが存在しない為 、処理をスキップします。＜処理続行＞", ReturnCodeType.Warning);

        // <<<<<【Ver.5.0.8.100】2025.05.12 Thach 心電図送信対応

        public static readonly Fn3ReturnCode FTL_DIALYSIS_SND_EX_INIT =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 100, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_FTL + "Initialize()でエラーが発生しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode FTL_DIALYSIS_SND_EX_EXECUTE =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 101, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_FTL + "Execute()でエラーが発生しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode FTL_DIALYSIS_SND_EX_CREATEOBJ =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 102, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_FTL + "CreateObject()でエラーが発生しました。", ReturnCodeType.Exception);

        // 2011/05/13 中村 指示医対応
        public static readonly Fn3ReturnCode FTL_DIALYSIS_SND_DECIDER =
            new Fn3ReturnCode(CPID_DIALYSISSND, CODEOFFSET_DIALYSISSND + 103, CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_FTL + "スタッフ権限取得でエラーが発生しました。", ReturnCodeType.Exception);

       
        #endregion

        #region [4000～] 検体検査結果受信用エラーコード
        public static readonly Fn3ReturnCode ERR_EXAMIN_RCV_GETINITIALVALUE =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 001, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_ERR + "初期設定情報に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMIN_RCV_BADEXECUTETIME =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 002, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_ERR + "定期取込実施時刻が不正です。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode WNG_EXAMIN_RCV_NOTREMOVED =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 010, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_WNG + "MIRAIs-DBから検査結果情報の削除が行われませんでした。", ReturnCodeType.Warning);

        public static readonly Fn3ReturnCode ERR_EXAMIN_RCV_NOTUPDATE =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 011, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_ERR + "FN-DBへの検査結果情報登録が行われませんでした。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMIN_RCV_GETPATIENTINFO =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 012, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_ERR + "患者情報の取得に失敗しました。", ReturnCodeType.Error);
        
        public static readonly Fn3ReturnCode ERR_EXAMIN_RCV_TRANSACTION =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 021, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_ERR + "トランザクション開始に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMIN_RCV_UPDATE =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 022, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_ERR + "検査結果情報の更新に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMIN_RCV_COMMIT =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 023, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_ERR + "コミットに失敗しました。", ReturnCodeType.Error);
        
        public static readonly Fn3ReturnCode FTL_EXAMIN_RCV_INITIALIZE =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 101, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_FTL + "検査結果情報受信プラグインの初期化に失敗しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode FTL_EXAMIN_RCV_DBOPEN =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 102, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_FTL + "MIRAIs-DBの接続に失敗しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode FTL_EXAMIN_RCV_DBQUERY =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 103, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_FTL + "MIRAIs-DBのSQLクエリ実行に失敗しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode FTL_EXAMIN_RCV_DBTRANSACTION =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 104, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_FTL + "MIRAIs-DBのトランザクション開始に失敗しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode FTL_EXAMIN_RCV_DBEXECUTE =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 105, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_FTL + "MIRAIs-DBのSQLステートメント実行に失敗しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode FTL_EXAMIN_RCV_DBCOMMIT =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 106, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_FTL + "MIRAIs-DBのコミットに失敗しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode FTL_EXAMIN_RCV_DBROLLBACK =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 107, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_FTL + "MIRAIs-DBのロールバックに失敗しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode FTL_EXAMIN_RCV_ELAPSED =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 108, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_FTL + "検査結果情報受信連携処理中に例外エラーが発生しました。", ReturnCodeType.Exception);

        // 2013/04/23 中村 採取日・採取時間のNULL考慮 Add Start
        public static readonly Fn3ReturnCode WNG_EXAMIN_RCV_GETEXAMDATE =
            new Fn3ReturnCode(CPID_EXAMINRCV, CODEOFFSET_EXAMINRCV + 109, CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_WNG + "採取日・採取時刻が空白または不正な値です。検査日時が算出出来ない為、スキップします。", ReturnCodeType.Warning);
        // 2013/04/23 中村 採取日・採取時間のNULL考慮 Add End
        #endregion

        #region [5000～] 検体検査予定送信用エラーコード
        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_GETINITIALVALUE = 
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 001, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "初期設定情報の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_INITIALIZE =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 002, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "検査予定送信プラグインの初期化に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_CREATECOMMON =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 003, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（共通）の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_CREATEOBJECT_ORDER =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 004, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（検査オーダ登録／変更）の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_DBOPEN =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 005, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBの接続に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_DBCLOSE =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 006, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBの切断に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_DBTRANSACTION =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 007, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBのトランザクション開始に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_DBCOMMIT =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 008, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBのコミットに失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_DBROLLBACK =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 009, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "MIRAIs-DBのロールバックに失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_USEOBJECT_ORDER =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 010, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "外部I/Fオブジェクト（検査オーダ登録／変更）の利用に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 011, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "必須項目の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_SEND =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 012, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "検査予定の送信に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_PAST_DATE =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 013, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "過去オーダは送信しません。", ReturnCodeType.Error);

        // 2013/04/23 中村 科コード設定対応 Add Start
        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_GROUPCD_FAILED =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 014, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "科コード設定の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_MSTBED_FAILED =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 015, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "ベッドマスタの参照に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_SEND_MSTPATGROUP_FAILED =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 016, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "ベッド番号・科コード対応情報が設定されていません。", ReturnCodeType.Error);
        // 2013/04/23 中村 科コード設定対応 Add End

        // 2016/04/11 中村 ポップアップ通知 Add Start
        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_REGIST_POPUP =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 017, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "ポップアップ通知に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_EXAMINSCHE_NOT_EXIST_IF_EVENT_LOG =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 018, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_ERR + "連携イベントログテーブルが存在しないため、ポップアップ通知をスキップします。", ReturnCodeType.Error);
        // 2016/04/11 中村 ポップアップ通知 Add End


        public static readonly Fn3ReturnCode FTL_EXAMINSCHE_SEND_CREATEOBJ =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 101, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_FTL + "CreateObject()でエラーが発生しました。", ReturnCodeType.Exception);

        // 2011/05/23 中村 指示医対応
        public static readonly Fn3ReturnCode FTL_EXAMINSCHE_SND_INDICATOR =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 102, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_FTL + "スタッフ権限取得でエラーが発生しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode WNG_EXAMINSCHE_SND_INDICATOR =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 201, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_WNG + "指示医情報の取得に失敗しました。", ReturnCodeType.Warning);

        // 2016/04/11 中村 ポップアップ通知
        public static readonly Fn3ReturnCode WNG_EXAMINSCHE_POPUP_NOTICE =
            new Fn3ReturnCode(CPID_EXAMINSCHESND, CODEOFFSET_EXAMINSCHESND + 202, CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_WNG + "ポップアップ通知設定の取得に失敗しました。", ReturnCodeType.Warning);

        #endregion
    }
}
