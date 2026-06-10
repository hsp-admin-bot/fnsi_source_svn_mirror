///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：シーエスアイ標準連携　透析予約送信機能
// ファイル名：Fn3CSICoopDialysisScheSendStd.cs
// 説明      ：透析予約送信機能を提供する
//
//	Copyright(C) 2008 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2009/11/10	堀内英史			新規作成
//  2011/01/07  中村圭之介          依頼医師を予約指示.更新者⇒患者基本情報.担当医
//                                  に変更。
//  2011/01/11  中村圭之介          スタッフコード先頭0詰めなし対応
//  2011/05/13  中村圭之介          指示医対応（新里ﾒﾃﾞｨｹｱ版よりマージ）
//  2011/06/13  中村圭之介          予約時間重複時の処理継続対応
//  2014/03/18  阿部浩幸            クール別科目コード対応
//  2015/07/30  石川俊介            特殊浄化対応,ログ強化
//  2016/04/11  中村圭之介          ポップアップ通知対応
//  2016/05/19  中村圭之介          ポップアップ通知対応の受入指摘対応
//
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using System.Windows.Forms;
using System.Xml;
using jp.co.nikkiso.fn3.Cooperation;
using jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn;

namespace jp.co.nikkiso.fn3.Cooperation.CSICoop
{
    public class Fn3CSICoopDialysisScheSendStd : Fn3ComPlugIn
    {
        /// <summary>
        /// シーエスアイ外部I/F部品 共通オブジェクト
        /// </summary>
        object objCSICOMMON = null;

        /// <summary>
        /// シーエスアイ外部I/F部品 患者予約情報登録／変更オブジェクト
        /// </summary>
        object objCSIAPPPATIENT = null;

        /// <summary>
        /// MIRAIs-DBオブジェクト
        /// </summary>
        object objMiraisDB = null;

        /// <summary>
        /// 個別設定値
        /// </summary>
        Hashtable hstOrgSettings = new Hashtable();

        /// <summary>
        /// ログ出力用表示用患者ID保持変数
        /// </summary>
        private string m_strForMsgDispPatId = "";

        /// <summary>
        /// ログ出力用患者ID保持変数
        /// </summary>
        private string m_strForMsgPatId = "";

        /// <summary>
        /// ログ出力用患者ID保持変数
        /// </summary>
        private string m_strForMsgPatName = "";

        /// <summary>
        /// ログ出力用透析日保持変数
        /// </summary>
        private string m_strForMsgDialysisDate = "";

        /// <summary>
        /// ログ出力用クール保持変数
        /// </summary>
        private string m_strForMsgKur = "";

        /// <summary>
        /// ログ出力用ベッド保持変数
        /// </summary>
        private string m_strForMsgBedName = "";

        /// <summary>
        /// 患者ID桁数設定
        /// </summary>
        private Int32 PatIdLength = 12;

        /// <summary>
        /// 連携側指示削除時のスタッフコード
        /// <value>**********</value>
        /// </summary>
        private const string UNKNOWN_STAFF_CODE = "**********";

        // 2011/01/07 中村 依頼医師に患者基本情報.担当医を設定するよう変更
        /// <summary>
        /// デフォルト医師
        /// </summary>
        private string DefaultStaffCd = "";

        // 2011/05/13 中村 指示医対応
        /// <summary>
        /// 指示医フラグ
        /// </summary>
        private string IndicatorFlg = "";

        // 2013/04/23 中村 科コード設定対応 Add Start
        /// <summary>
        /// 科コード設定
        /// </summary>
        Hashtable hstGroupCd = new Hashtable();
        /// <summary>
        /// 所属グループコードの利用有無
        /// </summary>
        private string m_PatGroupFlg = "1";
        // 2013/04/23 中村 科コード設定対応 Add Start

        // 2014/03/17 阿部 クール別科目コード設定対応 Add Start
        /// <summary>
        /// クール別科目コード設定
        /// </summary>
        Hashtable hstKurAppCd = new Hashtable();
        // 2014/03/17 阿部 クール別科目コード設定対応 Add End

        // 2016/04/11 中村 ポップアップ通知対応 Add Start
        /// <summary>ポップアップ通知設定</summary>
        private string m_strPopupNotice = "0";

        private string m_strForSendMemoDialDate = string.Empty;
        // 2016/04/11 中村 ポップアップ通知対応 Add End

        /// <summary>
        /// プラグイン初期化処理
        /// </summary>
        /// <returns>リターンコード</returns>
        protected override Fn3ReturnCode Initialize()
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            hstGroupCd.Clear();
            Fn3ReturnCode fn3Ret = Fn3ReturnCode.Success;

            try
            {
                // 共通変数初期化
                CSICommon.ClearAllParameter();

                // 個別設定値を読み込む
                this.GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSCHESND, ref hstOrgSettings);

                //--------------------------------------------------------------------
                // 設定値の存在チェック
                //--------------------------------------------------------------------
                bool blnInitValueDone = true;

                // 科コード
                if (!this.hstOrgSettings.ContainsKey(CSICommonConst.SYS_KEY_DEPTCODE))
                {
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_INITIALVALUEFAILED;

                    this.TraceOut(fn3Ret,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_DIALYSISSCHESND,
                                                CSICommonConst.SYS_KEY_DEPTCODE,
                                                ""));
                    blnInitValueDone = false;
                }

                // 予約科目コード
                if (!this.hstOrgSettings.ContainsKey(CSICommonConst.SYS_KEY_APPCODE))
                {
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_INITIALVALUEFAILED;

                    this.TraceOut(fn3Ret,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_DIALYSISSCHESND,
                                                CSICommonConst.SYS_KEY_APPCODE,
                                                ""));
                    blnInitValueDone = false;
                }

                // 予約行為コード
                if (!this.hstOrgSettings.ContainsKey(CSICommonConst.SYS_KEY_APPACTIONCODE))
                {
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_INITIALVALUEFAILED;

                    this.TraceOut(fn3Ret,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_DIALYSISSCHESND,
                                                CSICommonConst.SYS_KEY_APPACTIONCODE,
                                                ""));
                    blnInitValueDone = false;
                }

                // 入力端末名
                if (!this.hstOrgSettings.ContainsKey(CSICommonConst.SYS_KEY_TERMINALNAME))
                {
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_INITIALVALUEFAILED;

                    this.TraceOut(fn3Ret,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_DIALYSISSCHESND,
                                                CSICommonConst.SYS_KEY_TERMINALNAME,
                                                ""));
                    blnInitValueDone = false;
                }

                // 2010/12/09 中村
                // 予約削除スタッフコード
                if (!this.hstOrgSettings.ContainsKey(CSICommonConst.SYS_KEY_SCHE_DEL_STAFF_CODE))
                {
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_INITIALVALUEFAILED;

                    this.TraceOut(fn3Ret,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_DIALYSISSCHESND,
                                                CSICommonConst.SYS_KEY_SCHE_DEL_STAFF_CODE,
                                                ""));
                    blnInitValueDone = false;
                }

                // 2011/01/07 中村 依頼医師に患者基本情報.担当医を設定するよう変更
                // デフォルト医師
                String strDefaultStaffCd = "";
                Fn3ReturnCode retCodeDefaultStaffCd = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                        CSICommonConst.SYS_SECT_COMMON,
                                                                        CSICommonConst.SYS_KEY_DEFAULT_STAFF_CODE,
                                                                        ref strDefaultStaffCd);
                if (retCodeDefaultStaffCd.IsError || retCodeDefaultStaffCd.IsException || strDefaultStaffCd.Equals(""))
                {
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_INITIALVALUEFAILED;

                    this.TraceOut(fn3Ret,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_COMMON,
                                                CSICommonConst.SYS_KEY_DEFAULT_STAFF_CODE,
                                                ""));
                    blnInitValueDone = false;
                }
                else
                {
                    this.DefaultStaffCd = strDefaultStaffCd;
                }

                // 外部I/F部品使用設定
                string strUseJMSFlag = "";
                Fn3ReturnCode retCodeUseJMSFlag = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                       CSICommonConst.SYS_SECT_COMMON,
                                                                       CSICommonConst.SYS_KEY_LIBRARY_TYPE,
                                                                       ref strUseJMSFlag);
                if (retCodeUseJMSFlag.IsError || retCodeUseJMSFlag.IsException || strUseJMSFlag.Equals(""))
                {
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_INITIALVALUEFAILED;

                    this.TraceOut(fn3Ret,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_COMMON,
                                                CSICommonConst.SYS_KEY_LIBRARY_TYPE,
                                                ""));
                    blnInitValueDone = false;
                }

                // 患者ID桁数
                String strPatIDLength = "";
                Fn3ReturnCode retCodePatIDLength = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                        CSICommonConst.SYS_SECT_COMMON,
                                                                        CSICommonConst.SYS_KEY_SEND_PATID_FIGURES,
                                                                        ref strPatIDLength);
                if (retCodePatIDLength.IsError || retCodePatIDLength.IsException || strPatIDLength.Equals(""))
                {
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_INITIALVALUEFAILED;

                    this.TraceOut(fn3Ret,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_COMMON,
                                                CSICommonConst.SYS_KEY_SEND_PATID_FIGURES,
                                                ""));
                    blnInitValueDone = false;
                }
                else
                {
                    // 取得値を保持
                    this.PatIdLength = System.Convert.ToInt32(strPatIDLength);
                }
                
                // 2011/05/13 中村 指示医対応
                // 指示医切り替えフラグ
                string strIndicatorFlg = string.Empty;
                Fn3ReturnCode retCodeIndicatorFlg = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                        CSICommonConst.SYS_SECT_COMMON,
                                                                        CSICommonConst.SYS_KEY_INDICATOR_FLG,
                                                                        ref strIndicatorFlg);
                if (retCodeIndicatorFlg.IsError || retCodeIndicatorFlg.IsException || strIndicatorFlg.Equals(""))
                {
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_INITIALVALUEFAILED;

                    this.TraceOut(fn3Ret,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_COMMON,
                                                CSICommonConst.SYS_KEY_INDICATOR_FLG,
                                                ""));
                    blnInitValueDone = false;
                }
                else
                {
                    // 取得値を保持
                    this.IndicatorFlg = strIndicatorFlg;
                }

                // 2013/04/23 中村 科コード設定対応 Add Start
                // 個別設定値を読み込む
                string strGroupFlg = string.Empty;
                Fn3ReturnCode retCodeGroupFlg = this.GetInitialValue("1", CSICommonConst.SYS_SECT_GROUPCD, CSICommonConst.SYS_KEY_PAT_GROUP_FLG, ref strGroupFlg);
                if (retCodeGroupFlg.IsError || retCodeGroupFlg.IsException || string.IsNullOrEmpty(strGroupFlg))
                {
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_GROUPCD_FAILED;

                    this.TraceOut(fn3Ret,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_GROUPCD,
                                                CSICommonConst.SYS_KEY_PAT_GROUP_FLG,
                                                ""));
                    return fn3Ret;
                }
                else
                {
                    m_PatGroupFlg = strGroupFlg;
                }

                if (m_PatGroupFlg.Equals("0"))
                {
                    // 所属グループコードの利用が「0：利用しない」の場合
                    // ベッド番号・科コード対応設定を取得
                    Fn3ReturnCode retCodeGroupCd = this.GetInitialValue("1", CSICommonConst.SYS_SECT_GROUPCD, ref hstGroupCd);
                    if (retCodeGroupCd.IsError || retCodeGroupCd.IsException)
                    {
                        fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_GROUPCD_FAILED;

                        this.TraceOut(fn3Ret,
                                      string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                    CSICommonConst.SYS_SECT_GROUPCD,
                                                    "",
                                                    ""));
                        return fn3Ret;
                    }

                    // 所属グループコードの利用設定をハッシュから取り除く
                    if (hstGroupCd.ContainsKey(CSICommonConst.SYS_KEY_PAT_GROUP_FLG))
                    {
                        hstGroupCd.Remove(CSICommonConst.SYS_KEY_PAT_GROUP_FLG);
                    }

                    // ベッド番号・科コード対応
                    string strOutXml = string.Empty;
                    Fn3ReturnCode retExecQuery = base.DBExecQuery("00002", "<rootNode />", ref strOutXml);
                    if (retExecQuery.IsError || retExecQuery.IsException)
                    {
                        fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_MSTBED_FAILED;
                        this.TraceOut(fn3Ret);
                        return fn3Ret;
                    }
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.LoadXml(strOutXml);

                    if (xmlDoc.SelectNodes("//rootNode/MST_BED/BED_NO").Count == 0)
                    {
                        fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_MSTPATGROUP_FAILED;
                        this.TraceOut(fn3Ret);
                        return fn3Ret;
                    }
                    string strNgBedNo = string.Empty;
                    foreach (XmlNode nodeBed in xmlDoc.SelectNodes("//rootNode/MST_BED/BED_NO"))
                    {
                        if (hstGroupCd.ContainsKey(nodeBed.InnerText) == false ||
                            hstGroupCd[nodeBed.InnerText].ToString().Length != 5)
                        {
                            fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_MSTPATGROUP_FAILED;
                            if (!string.IsNullOrEmpty(strNgBedNo)) strNgBedNo += ",";
                            strNgBedNo += nodeBed.InnerText;
                        }
                    }
                    if (fn3Ret == CSIReturnCode.ERR_DIALYSISSCHE_SND_MSTPATGROUP_FAILED)
                    {
                        this.TraceOut(fn3Ret,
                                      string.Format("登録されていないベッド番号：{0}", strNgBedNo));
                        return fn3Ret;
                    }
                }
                // 2013/04/23 中村 科コード設定対応 Add End
                // 2014/03/18 阿部 クール別科目コード設定対応 Add Start
                else
                {
                    // 所属グループコードの利用が「1：利用する」の場合
                    // クール別科目コード設定を取得
                    Fn3ReturnCode retCodeKurAppCd = this.GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSCHESND_KURAPPCD, ref hstKurAppCd);
                    if (retCodeKurAppCd.IsError || retCodeKurAppCd.IsException)
                    {
                        // 取得失敗時はトレースログを出力して正常処理継続
                        this.TraceOut(CSIReturnCode.ERR_DIALYSISSCHE_SND_KURAPPCD_FAILED,
                                      string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                    CSICommonConst.SYS_SECT_DIALYSISSCHESND_KURAPPCD,
                                                    "",
                                                    ""));
                    }
                    
                }
                // 2014/03/18 阿部 クール別科目コード設定対応 Add End

                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 特殊浄化対応
                // 特殊浄化予約科目コード
                if (!this.hstOrgSettings.ContainsKey(CSICommonConst.SYS_KEY_SPEC_APPCODE))
                {
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_INITIALVALUEFAILED;

                    this.TraceOut(fn3Ret,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_DIALYSISSCHESND,
                                                CSICommonConst.SYS_KEY_SPEC_APPCODE,
                                                ""));
                    blnInitValueDone = false;
                }

                // 特殊浄化予約行為コード
                if (!this.hstOrgSettings.ContainsKey(CSICommonConst.SYS_KEY_SPEC_APPACTIONCODE))
                {
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_INITIALVALUEFAILED;

                    this.TraceOut(fn3Ret,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_DIALYSISSCHESND,
                                                CSICommonConst.SYS_KEY_APPACTIONCODE,
                                                ""));
                    blnInitValueDone = false;
                }
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 特殊浄化対応

                // 2016/04/11 中村 ポップアップ通知対応 Add Start
                string strPopupNotice = string.Empty;
                Fn3ReturnCode retCodePopupNotice = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                        CSICommonConst.SYS_SECT_COMMON,
                                                                        CSICommonConst.SYS_KEY_POPUP_NOTICE,
                                                                        ref strPopupNotice);
                if (retCodePopupNotice.IsError || retCodePopupNotice.IsException || string.IsNullOrEmpty(strPopupNotice))
                {
                    retCodePopupNotice = CSIReturnCode.WNG_DIALYSISSCHE_POPUP_NOTICE;

                    this.TraceOut(retCodePopupNotice,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_COMMON,
                                                CSICommonConst.SYS_KEY_POPUP_NOTICE,
                                                ""));
                }
                else
                {
                    // 取得値を保持
                    this.m_strPopupNotice = strPopupNotice;
                }
                // 2016/04/11 中村 ポップアップ通知対応 Add End

                //--------------------------------------------------------------------
                // 電子カルテDB接続確立
                //--------------------------------------------------------------------

                // 設定値が全てあるときのみ
                if (blnInitValueDone)
                {
                    // シーエスアイ外部I/F部品のオブジェクト作成
                    //-- 共通
                    objCSICOMMON = this.CreateObjectRap(CSICommonMethod.GetLibName(CSICommonConst.CSIPROGRAMID_COMMON, strUseJMSFlag));
                    if (objCSICOMMON == null)
                    {
                        // エラー
                        fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_CREATECOMMON;

                        // トレースログ出力
                        // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                        //this.TraceOut(fn3Ret);
                        this.TraceOut(fn3Ret, string.Format("LibName=\"{0}\"", CSICommonConst.CSIPROGRAMID_COMMON));
                        // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                    }
                    else
                    {
                        //-- 患者予約情報登録／更新
                        objCSIAPPPATIENT = this.CreateObjectRap(CSICommonMethod.GetLibName(CSICommonConst.CSIPROGRAMID_APPPATIENT, strUseJMSFlag));
                        if (objCSIAPPPATIENT == null)
                        {
                            // エラー
                            fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_CREATEAPPPATIENT;

                            // トレースログ出力
                            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                            //this.TraceOut(fn3Ret);
                            base.TraceOut(fn3Ret, string.Format("LibName=\"{0}\"", CSICommonConst.CSIPROGRAMID_APPPATIENT));
                            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // 初期化失敗
                fn3Ret = CSIReturnCode.FTL_DIALYSISSCHE_SND_INITFAILED;

                this.ErrorTraceOut(fn3Ret, ex);
            }
            finally
            {
                // リターンコードがエラーのとき
                if (fn3Ret.IsError || fn3Ret.IsException)
                {
                    // アラーム出力を行う（１度だけ）
                    this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, "", null, "", fn3Ret.Message);
                }

                // メソッド終了ログ
                this.MethodEndLogOut(MethodBase.GetCurrentMethod());

            }
            return fn3Ret;

        }

        /// <summary>
        /// プラグイン開始処理
        /// </summary>
        /// <returns>リターンコード</returns>
        protected override Fn3ReturnCode Start()
        {
            // ※特に処理はなし

            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// プラグイン送信実行処理
        /// </summary>
        /// <param name="exeInfo">連携情報</param>
        /// <returns>リターンコード</returns>
        protected override Fn3ReturnCode Execute(Fn3ExecuteInfo exeInfo)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            Fn3ReturnCode fn3Ret = Fn3ReturnCode.Success;

            try
            {
                // 2011/02/05 中村 送信履歴.MEMO初期化
                this.SendHistMemo = null;

                // 2016/04/11 中村 ポップアップ通知設定　初期化処理を追加
                m_strForMsgDialysisDate = string.Empty;
                m_strForMsgKur = string.Empty;
                m_strForSendMemoDialDate = string.Empty;

                // 処理区分判断
                string strProcDiv = "";
                switch (exeInfo.SendClass)
                {
                    case "0": strProcDiv = CSICommonConst.PROCDIV_INSERT; break;	//	新規
                    case "1": strProcDiv = CSICommonConst.PROCDIV_MODIFY; break;	//	修正
                    case "2": strProcDiv = CSICommonConst.PROCDIV_DELETE; break;	//	削除
                    default:
                        // 2016/05/19 中村 戻り値用変数へのセット漏れ Chg Start
                        //this.TraceOut(CSIReturnCode.ERR_DIALYSISSCHE_SND_INVARIDDIV);
                        //return CSIReturnCode.ERR_DIALYSISSCHE_SND_INVARIDDIV;
                        fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_INVARIDDIV;
                        this.TraceOut(fn3Ret);
                        return fn3Ret;
                        // 2016/05/19 中村 戻り値用変数へのセット漏れ Chg End
                }

                // 患者情報取得(患者ID、表示用患者ID、患者名)
                this.GetPatientInfoFromExeInfo(exeInfo);

                // 共通変数初期化
                CSICommon.ClearAllParameter();

                // MIRAIs-DBへの接続確立
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                base.TraceOut("【透析予約送信】他部門I/F：CSICommonMethod.pDbOpen() Start");
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                bool blnConnect = CSICommonMethod.pDbOpen(objCSICOMMON, ref objMiraisDB, ref CSICommon.colERR);
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                base.TraceOut("【透析予約送信】他部門I/F：CSICommonMethod.pDbOpen() End");
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                if ((!blnConnect) || (CSICommon.pGetERRCollectionCount() != 0))
                {
                    // エラーリターン

                    // 2016/05/19 中村 戻り値用変数へのセット漏れ Chg Start
                    //// >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    ////this.TraceOut(CSIReturnCode.ERR_DIALYSISSCHE_SND_DBOPEN, CSICommonMethod.GetLastErrorString());
                    //base.TraceOut(CSIReturnCode.ERR_DIALYSISSCHE_SND_DBOPEN,
                    //    string.Format("患者ID=\"{0}\", エラー内容=\"{1}\"", m_strForMsgDispPatId, CSICommonMethod.GetLastErrorString()));
                    //// <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    //this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "", 
                    //               string.Format("{0}（{1}）", CSIReturnCode.ERR_DIALYSISSCHE_SND_DBOPEN.Message, CSICommonMethod.GetLastErrorString()));
                    //return CSIReturnCode.ERR_DIALYSISSCHE_SND_DBOPEN;
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_DBOPEN;
                    base.TraceOut(fn3Ret,
                        string.Format("患者ID=\"{0}\", エラー内容=\"{1}\"", m_strForMsgDispPatId, CSICommonMethod.GetLastErrorString()));
                    this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                                   string.Format("{0}（{1}）", fn3Ret.Message, CSICommonMethod.GetLastErrorString()));
                    return fn3Ret;
                    // 2016/05/19 中村 戻り値用変数へのセット漏れ Chg End
                }

                // 登録情報の準備
                fn3Ret = setInputValue(strProcDiv, exeInfo);

                if ((!fn3Ret.IsError) && (!fn3Ret.IsException))
                {

                    //---------------------------------------------------------------------------
                    // I/Fメソッドにより電子カルテへ登録
                    //---------------------------------------------------------------------------
                    bool blnExec;
                    string strLastError = "";

                    // トランザクション開始
                    // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                    base.TraceOut("【透析予約送信】他部門I/F：CSICommonMethod.pDbBeginTrn() Start");
                    // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                    blnExec = CSICommonMethod.pDbBeginTrn(objCSICOMMON, objMiraisDB, ref CSICommon.colERR);
                    // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                    base.TraceOut("【透析予約送信】他部門I/F：CSICommonMethod.pDbBeginTrn() End");
                    // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

                    // 失敗
                    if ((!blnExec) || (CSICommon.pGetERRCollectionCount() != 0))
                    {
                        strLastError = CSICommonMethod.GetLastErrorString();

                        // 異常終了
                        fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_DBTRANSACTION;

                        ////	イベントリトライ
                        //this.EventRetry = true;

                        // アラーム出力し、リトライしない
                        this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                                       string.Format("{0}（{1}）", fn3Ret.Message, CSICommonMethod.GetLastErrorString()));

                        // トレースログ出力
                        this.TraceOut(fn3Ret, strLastError);
                    }
                    else
                    {
                        // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                        base.TraceOut("【透析予約送信】他部門I/F：CSICommonMethod.pAppPatient() Start");
                        // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                        // 予約情報登録
                        blnExec = CSICommonMethod.pAppPatient(objCSIAPPPATIENT,
                                                               CSICommon.varINPARAM,
                                                               ref CSICommon.varOUTPARAM,
                                                               ref CSICommon.colERR,
                                                               objMiraisDB);
                        // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                        base.TraceOut("【透析予約送信】他部門I/F：CSICommonMethod.pAppPatient() End");
                        // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

                        // DUMP出力
                        DumpParameter dpAppPatient = new DumpParameter("患者予約情報登録/更新",
                                                                       CSICommon.varINPARAM,
                                                                       CSICommon.varOUTPARAM,
                                                                       CSICommon.colERR,
                                                                       blnExec);
                        this.DumpOut(exeInfo.SpecificKey, CSICommonMethod.CreateDumpData(m_strForMsgPatId, new DumpParameter[] { dpAppPatient }));

                        // メソッド実行に失敗
                        if ((!blnExec) || (CSICommon.pGetERRCollectionCount() != 0))
                        {
                            string strErrLevel = string.Empty;
                            string strErrCd = string.Empty;
                            string strErrMsg = string.Empty;

                            strLastError = CSICommonMethod.GetLastErrorString(ref strErrLevel, ref strErrCd, ref strErrMsg);

                            // 2011/06/13 中村 予約時間重複時の処理継続対応
                            // 予約時間重複エラー時は、コミット処理を行うよう修正
                            if (strErrLevel.Equals("W"))
                            {
                                // コミット
                                fn3Ret = procCommit();
                                if ((!fn3Ret.IsError) && (!fn3Ret.IsException))
                                {
                                    // 送信履歴.メモに予約番号を登録
                                    // 2013/04/23 中村 科コード設定対応 Chg Start
                                    // this.SendHistMemo = CSICommon.pGetOUTPARAMData(CSICommon.CON_APPP_APPOINTMENTNO1).ToString();
                                    // 2016/04/12 中村 ポップアップ通知対応 Chg Start
                                    //this.SendHistMemo = string.Format("{0},{1}",
                                    //                                  CSICommon.pGetOUTPARAMData(CSICommon.CON_APPP_APPOINTMENTNO1).ToString(),
                                    //                                  CSICommon.pGetINPARAMData(CSICommon.CON_APPP_APPCODE).ToString());
                                    this.SendHistMemo = string.Format("{0},{1},{2}",
                                                                      CSICommon.pGetOUTPARAMData(CSICommon.CON_APPP_APPOINTMENTNO1).ToString(),
                                                                      CSICommon.pGetINPARAMData(CSICommon.CON_APPP_APPCODE).ToString(),
                                                                      this.m_strForSendMemoDialDate);
                                    // 2016/04/12 中村 ポップアップ通知対応 Chg End
                                    // 2013/04/23 中村 科コード設定対応 Chg End

                                    // トレース出力
                                    this.DebugTraceOut(CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_DBG + CSICommonConst.DEBUGTRACE_PRE_SUCCESS_MSG +
                                                       String.Format("透析予約の送信に成功しました。({0})",
                                                       String.Format("患者ID：{0} 表示用患者ID：{1} 透析日：{2} クール：{3} ベッド：{4}",
                                                                     this.m_strForMsgPatId,
                                                                     this.m_strForMsgDispPatId,
                                                                     this.m_strForMsgDialysisDate,
                                                                     this.m_strForMsgKur,
                                                                     this.m_strForMsgBedName)));

                                    // 正常
                                    fn3Ret = new Fn3ReturnCode(Fn3ReturnCode.Success.ProcKind, Fn3ReturnCode.Success.Code, base.SendHistMemo, ReturnCodeType.Success);
                                }
                            }
                            else
                            {
                                // ロールバック
                                fn3Ret = procRollback();

                                if ((!fn3Ret.IsError) && (!fn3Ret.IsException))
                                {
                                    // 異常終了
                                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_INPUT;

                                    ////	イベントリトライ
                                    //this.EventRetry = true;

                                    // アラーム出力し、リトライしない
                                    this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                                        string.Format("{0}（{1}）処理区分:{2}", fn3Ret.Message, strLastError, strProcDiv));

                                    // トレースログ出力
                                    // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                                    //this.TraceOut(fn3Ret, strLastError);
                                    this.TraceOut(fn3Ret,
                                        string.Format("患者ID=\"{0}\", エラー内容=\"{1}\"", m_strForMsgDispPatId, strLastError));
                                    // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                                }
                            }
                        }
                        // その他を成功とみなす
                        else
                        {
                            // コミット
                            fn3Ret = procCommit();
                            if ((!fn3Ret.IsError) && (!fn3Ret.IsException))
                            {
                                // 送信履歴.メモに予約番号を登録
                                // 2013/04/23 中村 科コード設定対応 Chg Start
                                // this.SendHistMemo = CSICommon.pGetOUTPARAMData(CSICommon.CON_APPP_APPOINTMENTNO1).ToString();
                                // 2016/04/12 中村 ポップアップ通知対応 Chg Start
                                //this.SendHistMemo = string.Format("{0},{1}",
                                //                                  CSICommon.pGetOUTPARAMData(CSICommon.CON_APPP_APPOINTMENTNO1).ToString() ,
                                //                                  CSICommon.pGetINPARAMData(CSICommon.CON_APPP_APPCODE).ToString());
                                this.SendHistMemo = string.Format("{0},{1},{2}",
                                                                  CSICommon.pGetOUTPARAMData(CSICommon.CON_APPP_APPOINTMENTNO1).ToString(),
                                                                  CSICommon.pGetINPARAMData(CSICommon.CON_APPP_APPCODE).ToString(),
                                                                  this.m_strForSendMemoDialDate);
                                // 2016/04/12 中村 ポップアップ通知対応 Chg End
                                // 2013/04/23 中村 科コード設定対応 Chg End

                                // トレース出力
                                this.DebugTraceOut(CSICommonConst.MODULE_MNAME_DSS + CSICommonConst.LOGTYPE_DBG + CSICommonConst.DEBUGTRACE_PRE_SUCCESS_MSG +
                                                   String.Format("透析予約の送信に成功しました。({0})",
                                                   String.Format("患者ID：{0} 表示用患者ID：{1} 透析日：{2} クール：{3} ベッド：{4}",
                                                                 this.m_strForMsgPatId,
                                                                 this.m_strForMsgDispPatId,
                                                                 this.m_strForMsgDialysisDate,
                                                                 this.m_strForMsgKur,
                                                                 this.m_strForMsgBedName)));

                                // 正常
                                fn3Ret = new Fn3ReturnCode(Fn3ReturnCode.Success.ProcKind, Fn3ReturnCode.Success.Code, base.SendHistMemo, ReturnCodeType.Success);
                            }
                        }
                    }
                }
            }
            // 異常終了
            catch (Exception ex)
            {
                fn3Ret = CSIReturnCode.FTL_DIALYSISSCHE_SND_INPUT_EX;

                this.ErrorTraceOut(fn3Ret, ex);
            }
            finally
            {
                // MIRAIs-DB切断処理
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                base.TraceOut("【透析予約送信】他部門I/F：CSICommonMethod.pDbClose() Start");
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                bool blnDisConnect = CSICommonMethod.pDbClose(objCSICOMMON, objMiraisDB, ref CSICommon.colERR);
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                base.TraceOut("【透析予約送信】他部門I/F：CSICommonMethod.pDbClose() End");
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                if ((!blnDisConnect) || (CSICommon.pGetERRCollectionCount() != 0))
                {
                    this.TraceOut(CSIReturnCode.ERR_DIALYSISSCHE_SND_DBCLOSE, CSICommonMethod.GetLastErrorString());
                }

                // 2016/05/25 中村 ポップアップ通知設定の受入指摘対応 Chg Start
                // （変更 かつ 送信情報の取得失敗）の場合、ポップアップ通知しない
                if (!exeInfo.SendClass.Equals("1") ||
                    fn3Ret != CSIReturnCode.ERR_DIALYSISSCHE_SND_GETVALUE)
                {
                    // 2016/04/11 中村 ポップアップ通知設定
                    this.RegistPopupNotice(exeInfo, fn3Ret.IsSuccess);
                }
                // 2016/05/25 中村 ポップアップ通知設定の受入指摘対応 Chg End

                // メソッド終了ログ
                this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            }
            return fn3Ret;
        }

        /// <summary>
        /// プラグイン停止処理
        /// </summary>
        protected override void Stop()
        {
            // ※特に処理はなし
        }

        /// <summary>
        /// プラグイン解放処理
        /// </summary>
        protected override void Release()
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
        }

        /// <summary>
        /// 患者情報取得
        /// 連携情報から患者の表示用ID、内部用ID、名称を取得
        /// </summary>
        /// <param name="exeInfo">連携情報</param>
        private void GetPatientInfoFromExeInfo(Fn3ExecuteInfo exeInfo)
        {
            // 表示用患者ID取得(連携情報から取得)
            this.m_strForMsgDispPatId = "";
            this.m_strForMsgDispPatId = CSICommonMethod.formatString("{0:D12}", exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DISP_PATID").InnerText);

            // 患者ID取得(連携情報から取得)
            this.m_strForMsgPatId = "";
            this.m_strForMsgPatId = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/PATID").InnerText;

            // 患者名取得(連携情報から取得)
            this.m_strForMsgPatName = "";
            this.m_strForMsgPatName = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/NAME").InnerText;
        }

        /// <summary>
        /// インスタンスを生成する
        /// </summary>
        /// <param name="strLibName">インスタンス名</param>
        /// <param name="retCodeError">対象部品エラーコード</param>
        /// <returns>成功/失敗</returns>
        private object CreateObjectRap(string strLibName)
        {
            try
            {
                // インスタンス生成
                return CSICommonMethod.CreateObject(strLibName);
            }
            catch (Exception ex)
            {
                // エラー
                base.ErrorTraceOut(CSIReturnCode.FTL_DIALYSISSCHE_SND_CREATEOBJ, ex);
                return null;
            }
        }

        /// <summary>
        /// 登録情報生成処理
        /// </summary>
        /// <param name="strSendDiv"></param>
        /// <param name="exeInfo"></param>
        /// <returns></returns>
        private Fn3ReturnCode setInputValue(string strSendDiv, Fn3ExecuteInfo exeInfo)
        {
            Fn3ReturnCode fn3Ret = Fn3ReturnCode.Success;
            string strLabel = "";

            // 配列の領域確保
            CSICommon.varINPARAM = new object[17];

            // DBから情報の取得
            XmlNode xmlNode;

            // >>>>>【Ver.5.0.2.100】2015.07.29 石川 特殊浄化対応
            // 装置モードを取得
            string strDeviceMode = string.Empty;
            XmlNode xmlMstTreatItem = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/IND_DIALYSIS_COND[DIALYSIS_ITEM_CD=006]/MST_TREAT_ITEM");
            if (null != xmlMstTreatItem && string.IsNullOrEmpty(xmlMstTreatItem["DEVICE_MODE"].InnerText.Trim()) == false)
            {
                strDeviceMode = xmlMstTreatItem["DEVICE_MODE"].InnerText.Trim();
            }
            // <<<<<【Ver.5.0.2.100】2015.07.29 石川 特殊浄化対応

            // 2011/01/07 中村 依頼医師に患者基本情報.担当医を設定するよう変更。
            string strIndStaffCd = "";
            #region //-- 患者基本情報.担当医
            // 2011/05/13 指示医対応
            if (IndicatorFlg.Equals("1"))
            {
                // "予定指示.指示者"取得
                // 医師 かつ 指示編集権限がある場合、指示者を取得
                fn3Ret = getIndicatorCd(exeInfo.CoopInfoXML, ref strIndStaffCd);
                if (fn3Ret.IsError || fn3Ret.IsException)
                {
                    return fn3Ret;
                }
            }

            if (string.IsNullOrEmpty(strIndStaffCd))
            {
                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DOCTOR_CD1");
                if (xmlNode != null)
                {
                    strIndStaffCd = xmlNode.InnerText.Trim();
                }

                if (string.IsNullOrEmpty(strIndStaffCd))
                {
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DOCTOR_CD2");
                    if (xmlNode != null)
                    {
                        strIndStaffCd = xmlNode.InnerText.Trim();
                    }
                }
                if (string.IsNullOrEmpty(strIndStaffCd))
                {
                    strIndStaffCd = this.DefaultStaffCd;
                }
            }
            #endregion

            string strUpdateStaffCd = "";
            #region //-- 予定指示.更新者
            // 2011/05/23 中村 受入試験結果反映
#if true
            fn3Ret = getUpdaterCd(exeInfo.CoopInfoXML, ref strUpdateStaffCd);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            if (strUpdateStaffCd.Equals(UNKNOWN_STAFF_CODE))
            {
                // 連携側指示削除時のスタッフコードの場合、初期値テーブルより取得した
                // 固定のスタッフコードを設定。
                strUpdateStaffCd = this.hstOrgSettings[CSICommonConst.SYS_KEY_SCHE_DEL_STAFF_CODE].ToString();
            }
#else
            xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/IND_DIALYSIS_PLAN/UPDATE_STAFF_CD");
            if (xmlNode == null)
            {
                // 取得できない場合エラー
                fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_GETVALUE;
                strLabel = "予定指示.更新者";

                // アラーム出力し、リトライしない
                this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                    string.Format("{0}（{1}）", fn3Ret.Message, strLabel));

                //	取得失敗
                this.TraceOut(fn3Ret, strLabel);

                return fn3Ret;
            }
            else
            {
                strUpdateStaffCd = xmlNode.InnerText.Trim();

                // 2011/01/11 中村 スタッフコード0詰めなし対応
                // // 5桁ゼロパディング
                // strUpdateStaffCd = CSICommonMethod.formatString("{0:D5}", strUpdateStaffCd);

                // 2010/12/09 中村
                if (strUpdateStaffCd.Equals(UNKNOWN_STAFF_CODE))
                {
                    // 連携側指示削除時のスタッフコードの場合、初期値テーブルより取得した
                    // 固定のスタッフコードを設定。
                    strUpdateStaffCd = this.hstOrgSettings[CSICommonConst.SYS_KEY_SCHE_DEL_STAFF_CODE].ToString();
                }
            }
#endif
            #endregion


            // 2013/04/23 中村 科コード設定対応 Chg Start
#if false
            string strDeptCode = "";
            string strPatGroupCd = "";

            xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/MST_PAT_GROUP/IN_HOSPITAL_CD");
            if ((xmlNode == null) || (xmlNode.InnerText.Trim().Length != 5))
            {
                //-- 設定値：科コード
                strDeptCode = this.hstOrgSettings[CSICommonConst.SYS_KEY_DEPTCODE].ToString();
                // 2桁ゼロパディング
                strDeptCode = CSICommonMethod.formatString("{0:D2}", strDeptCode);

                //-- 設定値：予約科目コード
                strPatGroupCd = hstOrgSettings[CSICommonConst.SYS_KEY_APPCODE].ToString();
                // 5桁ゼロパディング
                strPatGroupCd = CSICommonMethod.formatString("{0:D5}", strPatGroupCd);
            }
            else
            {
                //-- 科コード
                strDeptCode = xmlNode.InnerText.Trim().Substring(0, 2);
                //-- 予約科目コード
                strPatGroupCd = xmlNode.InnerText.Trim();
            }
#endif
            string strReserveNumber = "";
            string strDeptCode = "";
            string strPatGroupCd = "";
            
            // 新規でないときのみ
            if (strSendDiv != CSICommonConst.PROCDIV_INSERT)
            {
                // 予約番号は新規以外は送信メモの値を使用
                // 科コード、予約科目コードは削除時のみ送信メモの値を使用
                #region //-- 送信履歴.メモ（予約番号,科コード,予約科目コード）
                if ((exeInfo.SendHistMemo == null) || (exeInfo.SendHistMemo == string.Empty))
                {
                    // 値が取れなければエラー
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_GETVALUE;
                    strLabel = "予約番号";

                    // アラーム出力し、リトライしない
                    this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                        string.Format("{0}（{1}）", fn3Ret.Message, strLabel));

                    //	取得失敗
                    this.TraceOut(fn3Ret, strLabel);

                    return fn3Ret;
                }
                else
                {
                    string[] splitMemo = exeInfo.SendHistMemo.Split(',');
                    // 2016/04/12 中村 ポップアップ通知対応
                    // if (splitMemo.Length == 2)
                    if (splitMemo.Length >= 2)
                    {
                        //-- 予約番号
                        strReserveNumber = splitMemo[0];
                        if (strSendDiv == CSICommonConst.PROCDIV_DELETE)
                        {
                            //-- 科コード
                            strDeptCode = splitMemo[1].Substring(0, 2);
                            //-- 予約項目コード
                            strPatGroupCd = splitMemo[1];
                        }

                        // 2016/04/12 中村 ポップアップ通知対応
                        if (splitMemo.Length >= 3)
                        {
                            //-- 送信メモ.透析日時
                            this.m_strForSendMemoDialDate = splitMemo[2];
                        }
                    }
                    else
                    {
                        strReserveNumber = exeInfo.SendHistMemo;
                    }
                }
                #endregion
            }

            if (string.IsNullOrEmpty(strDeptCode) || string.IsNullOrEmpty(strPatGroupCd))
            {
                if (m_PatGroupFlg == "0")
                {
                    // 所属グループコードの利用が「0：利用しない」の場合
                    #region //-- 透析スケジュール.ベッド番号（科コード,予約科目コード）
                    // ベッド番号より科コード・予約項目コードを取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/SCH_DIALYSIS_PLAN/BED_NO");
                    if (xmlNode != null)
                    {
                        if (hstGroupCd.ContainsKey(xmlNode.InnerText))
                        {
                            //-- 科コード
                            strDeptCode = hstGroupCd[xmlNode.InnerText].ToString().Substring(0, 2);
                            //-- 予約項目コード
                            strPatGroupCd = hstGroupCd[xmlNode.InnerText].ToString();
                        }
                    }
                    #endregion
                    
                }
                // 2014/03/18 阿部 クール別科目コード設定対応 CHG Start
                else
                {
                    // 所属グループコードの利用が「1：利用する」の場合
                    #region //-- 透析スケジュール.クールコード（予約科目コード）
                    // クールコードより予約科目コードを取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/SCH_DIALYSIS_PLAN/KUR_CD");
                    if (xmlNode != null)
                    {
                        strPatGroupCd = "";

                        if (hstKurAppCd.ContainsKey(xmlNode.InnerText))
                        {
                            string strGetCd = hstKurAppCd[xmlNode.InnerText].ToString();
                            if (!string.IsNullOrEmpty(strGetCd) && 5 == strGetCd.Length)
                            {
                                // 設定されていて5桁であればOK
                                //-- 予約項目コード
                                strPatGroupCd = strGetCd;

                                //-- 科コード
                                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/MST_PAT_GROUP/IN_HOSPITAL_CD");
                                if ((xmlNode == null) || (xmlNode.InnerText.Trim().Length != 5))
                                {
                                    //-- 所属部グループコード
                                    strDeptCode = this.hstOrgSettings[CSICommonConst.SYS_KEY_DEPTCODE].ToString();
                                    // 2桁ゼロパディング
                                    strDeptCode = CSICommonMethod.formatString("{0:D2}", strDeptCode);
                                }
                                else
                                {
                                    //-- 連携設定「科コード」
                                    strDeptCode = xmlNode.InnerText.Trim().Substring(0, 2);
                                }
                            }
                        }
                    }
                    #endregion
                }
                // 2014/03/18 阿部 クール別科目コード設定対応 CHG End

                if (string.IsNullOrEmpty(strDeptCode) || string.IsNullOrEmpty(strPatGroupCd))
                {
                    #region //-- 患者基本情報.所属グループ（科コード,予約科目コード）
                    //// ベッド番号が取得できなかった場合
                    // 所属コード「0：利用しない」でベッド番号が取得できなかった場合(ベッド未登録の場合)、
                    // もしくは「1：利用する」でクール別科目コードが取得出来なかった場合(設定なしか、5桁未満)
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/MST_PAT_GROUP/IN_HOSPITAL_CD");
                    if ((xmlNode == null) || (xmlNode.InnerText.Trim().Length != 5))
                    {
                        //-- 設定値：科コード
                        strDeptCode = this.hstOrgSettings[CSICommonConst.SYS_KEY_DEPTCODE].ToString();
                        // 2桁ゼロパディング
                        strDeptCode = CSICommonMethod.formatString("{0:D2}", strDeptCode);

                        // >>>>>【Ver.5.0.2.100】2015.07.29 石川 特殊浄化対応
                        if (strDeviceMode.CompareTo("9") == 0 &&
                            string.IsNullOrEmpty(hstOrgSettings[CSICommonConst.SYS_KEY_SPEC_APPCODE].ToString()) == false)
                        {
                            //-- 設定値：特殊浄化予約科目コード
                            strPatGroupCd = hstOrgSettings[CSICommonConst.SYS_KEY_SPEC_APPCODE].ToString();
                        }
                        else
                        {
                        // <<<<<【Ver.5.0.2.100】2015.07.29 石川 特殊浄化対応
                            //-- 設定値：予約科目コード
                            strPatGroupCd = hstOrgSettings[CSICommonConst.SYS_KEY_APPCODE].ToString();
                        // >>>>>【Ver.5.0.2.100】2015.07.29 石川 特殊浄化対応
                        }
                        // <<<<<【Ver.5.0.2.100】2015.07.29 石川 特殊浄化対応

                        // 5桁ゼロパディング
                        strPatGroupCd = CSICommonMethod.formatString("{0:D5}", strPatGroupCd);
                    }
                    else
                    {
                        //-- 科コード
                        strDeptCode = xmlNode.InnerText.Trim().Substring(0, 2);
                        //-- 予約科目コード
                        strPatGroupCd = xmlNode.InnerText.Trim();
                    }
                    #endregion
                }
            }
            // 2013/04/23 中村 科コード設定対応 Chg End

            string strTerminalName = "";
            #region //-- 設定値：登録端末名
            strTerminalName = this.hstOrgSettings[CSICommonConst.SYS_KEY_TERMINALNAME].ToString();
            //※パディング不要
            #endregion

            // 2013/04/23 中村 科コード設定対応 Chg Start　移動
#if false
            string strReserveNumber = "";
            // 新規でないときのみ
            if (strSendDiv != CSICommonConst.PROCDIV_INSERT)
            {
                #region //-- 送信履歴.メモ（予約番号）
                if ((exeInfo.SendHistMemo == null) || (exeInfo.SendHistMemo == string.Empty))
                {
                    // 値が取れなければエラー
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_GETVALUE;
                    strLabel = "予約番号";

                    // アラーム出力し、リトライしない
                    this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                        string.Format("{0}（{1}）", fn3Ret.Message, strLabel));

                    //	取得失敗
                    this.TraceOut(fn3Ret, strLabel);

                    return fn3Ret;
                }
                else
                {
                    strReserveNumber = exeInfo.SendHistMemo;
                }
                #endregion
            }
#endif
            // 2013/04/23 中村 科コード設定対応 Chg End 移動

            string strPatId = "";
            string strDialysisDate = "";
            string strStartTime = "";
            string strDialysisTime = "";
            string strActionCode = "";
            string strBedName = "";

            // 削除でないときのみ
            if (strSendDiv != CSICommonConst.PROCDIV_DELETE)
            {
                #region //-- 患者基本情報.患者番号
                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DISP_PATID");
                if (xmlNode == null)
                {
                    // 取得できない場合エラー
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_GETVALUE;
                    strLabel = "患者基本情報.患者番号";

                    // アラーム出力し、リトライしない
                    this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                        string.Format("{0}（{1}）", fn3Ret.Message, strLabel));

                    //	取得失敗
                    this.TraceOut(fn3Ret, strLabel);

                    return fn3Ret;
                }
                else
                {
                    strPatId = xmlNode.InnerText.Trim();

                    // 取得した患者IDが設定桁数以下の場合に対応する為、設定桁数で0詰めする
                    strPatId = strPatId.PadLeft(this.PatIdLength, '0');
                    // 下桁から設定桁数だけ取得する
                    strPatId = strPatId.Substring(strPatId.Length - this.PatIdLength, this.PatIdLength);

                    // strPatId += "  "; ←I/F資料によると不要

                }
                #endregion

                #region //-- 透析スケジュール.透析日
                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/SCH_DIALYSIS_PLAN/DIALYSIS_DATE");
                if (xmlNode == null)
                {
                    // 取得できない場合エラー
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_GETVALUE;
                    strLabel = "透析スケジュール.透析日";

                    // 2012/07/30 中村 お知らせアプリに通知しない(Redmine#1230) Del Start
                    //// アラーム出力し、リトライしない
                    //this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                    //    string.Format("{0}（{1}）", fn3Ret.Message, strLabel));
                    // 2012/07/30 中村 お知らせアプリに通知しない(Redmine#1230) Del End

                    //	取得失敗
                    this.TraceOut(fn3Ret, strLabel);

                    return fn3Ret;
                }
                else
                {
                    strDialysisDate = xmlNode.InnerText.Trim();
                    string strYear = strDialysisDate.Substring(0, 4);
                    string strMonth = strDialysisDate.Substring(4, 2);
                    string strDay = strDialysisDate.Substring(6, 2);
                    // 「YYYY/MM/DD」に書式化
                    strDialysisDate = string.Format("{0}/{1}/{2}", strYear, strMonth, strDay);
                }
                #endregion

                #region //-- 条件指示.開始時間
                fn3Ret = getStartTime(exeInfo.CoopInfoXML, ref strStartTime);
                //※メソッド内で「HH:MM」に書式化済み
                if (fn3Ret.IsError || fn3Ret.IsException)
                {
                    return fn3Ret;
                }
                #endregion

                // 2016/04/12 中村 ポップアップ通知対応 Add Start
                DateTime dtBuf;
                if (DateTime.TryParseExact((strDialysisDate + strStartTime), "yyyy/MM/ddHH:mm", null, 0, out dtBuf))
                {
                    //-- 送信メモ.透析日時
                    this.m_strForSendMemoDialDate = dtBuf.ToString("yyyyMMddHHmm");
                }

                // 2016/04/12 中村 ポップアップ通知対応 Add End

                #region //-- 条件指示.透析時間
                fn3Ret = getDialysisTime(exeInfo.CoopInfoXML, ref strDialysisTime);
                //※分で取得
                if (fn3Ret.IsError || fn3Ret.IsException)
                {
                    return fn3Ret;
                }
                #endregion

                #region //-- ベッド名称
                fn3Ret = getBedName(exeInfo.CoopInfoXML, ref strBedName);
                if (fn3Ret.IsError || fn3Ret.IsException)
                {
                    return fn3Ret;
                }
                #endregion

                #region //-- 設定値：予約行為コード
                // >>>>>【Ver.5.0.2.100】2015.07.29 石川 特殊浄化対応
                if (strDeviceMode.CompareTo("9") == 0 &&
                    string.IsNullOrEmpty(hstOrgSettings[CSICommonConst.SYS_KEY_SPEC_APPACTIONCODE].ToString()) == false)
                {
                    strActionCode = this.hstOrgSettings[CSICommonConst.SYS_KEY_SPEC_APPACTIONCODE].ToString();
                }
                else
                {
                // <<<<<【Ver.5.0.2.100】2015.07.29 石川 特殊浄化対応

                    strActionCode = this.hstOrgSettings[CSICommonConst.SYS_KEY_APPACTIONCODE].ToString();
                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                    //// 6桁ゼロパディング
                    //strActionCode = CSICommonMethod.formatString("{0:D6}", strActionCode);
                    //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更

                // >>>>>【Ver.5.0.2.100】2015.07.29 石川 特殊浄化対応
                }
                // <<<<<【Ver.5.0.2.100】2015.07.29 石川 特殊浄化対応
                #endregion
            }
            //-- ログ出力用に透析日、クール、ベッド名を保持
            this.m_strForMsgDialysisDate = strDialysisDate;
            this.m_strForMsgKur = strStartTime;
            this.m_strForMsgBedName = strBedName;

            //-- 準備品コレクション
            VBA.Collection colINPARAM15 = CSICommon.objVBACollection.CreateVBACollection();

            //-- コメントコレクション
            VBA.Collection colINPARAM16 = CSICommon.objVBACollection.CreateVBACollection();

            // 登録情報を配列にセット
            switch (strSendDiv)
            {
                case CSICommonConst.PROCDIV_INSERT: // 新規
                case CSICommonConst.PROCDIV_MODIFY: // 変更
                    //-- 処理区分
                    if (strSendDiv == CSICommonConst.PROCDIV_INSERT)
                    {
                        CSICommon.pSetINPARAMData(CSICommon.CON_APPP_MODE, CSICommonConst.PROCDIV_INSERT);
                    }
                    else
                    {
                        CSICommon.pSetINPARAMData(CSICommon.CON_APPP_MODE, CSICommonConst.PROCDIV_MODIFY);
                    }
                    //-- 患者番号
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_PATIENTNO, strPatId);
                    //-- 依頼科
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_REQUESTDEPT, strDeptCode);
                    //-- 依頼医師
                    // 2011/01/07 中村 依頼医師に患者基本情報.担当医を設定するよう変更。
                    // CSICommon.pSetINPARAMData(CSICommon.CON_APPP_REQUESTDR, strUpdateStaffCd);
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_REQUESTDR, strIndStaffCd);
                    //-- 予約番号
                    if (strSendDiv == CSICommonConst.PROCDIV_INSERT)
                    {
                        // セットしない
                    }
                    else
                    {
                        CSICommon.pSetINPARAMData(CSICommon.CON_APPP_APPOINTMENTNO, strReserveNumber);
                    }
                    //-- 予約日
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_APPDATE, strDialysisDate);
                    //-- 予約時間
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_APPTIME, strStartTime);
                    //-- 分数
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_APPSLOTTIME, strDialysisTime);
                    //-- 予約科
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_DEPARTMENT, strDeptCode);
                    //-- 予約科目コード
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_APPCODE, strPatGroupCd);
                    //-- 予約行為コード
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_APPACTIONCODE, strActionCode);
                    //-- 予約コメント
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_FREECOMMENT, strBedName);
                    //-- 来院区分
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_VISITSTATUS, "0");
                    //-- 更新端末
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_UPDATETERMINAL, strTerminalName);
                    //-- 更新者
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_UPDATEOPERATOR, strUpdateStaffCd);
                    //-- 準備品コレクション
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_PREPARATIONCOLLECTION, colINPARAM15);
                    //-- コメントコレクション
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_COMMENTCOLLECTION, colINPARAM16);
                    return Fn3ReturnCode.Success;

                case CSICommonConst.PROCDIV_DELETE: // 削除
                    //-- 処理区分
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_MODE, CSICommonConst.PROCDIV_DELETE);
                    //-- 患者番号
                    // セットしない
                    //-- 依頼科
                    // セットしない
                    //-- 依頼医師
                    // セットしない
                    //-- 予約番号
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_APPOINTMENTNO, strReserveNumber);
                    //-- 予約日
                    // セットしない
                    //-- 予約時間
                    // セットしない
                    //-- 分数
                    // セットしない
                    //-- 予約科
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_DEPARTMENT, strDeptCode);
                    //-- 予約科目コード
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_APPCODE, strPatGroupCd);
                    //-- 予約行為コード
                    // セットしない
                    //-- 予約コメント
                    // セットしない
                    //-- 来院区分
                    // セットしない
                    //-- 更新端末
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_UPDATETERMINAL, strTerminalName);
                    //-- 更新者
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_UPDATEOPERATOR, strUpdateStaffCd);
                    //-- 準備品コレクション
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_PREPARATIONCOLLECTION, colINPARAM15);
                    //-- コメントコレクション
                    CSICommon.pSetINPARAMData(CSICommon.CON_APPP_COMMENTCOLLECTION, colINPARAM16);
                    return Fn3ReturnCode.Success;

                default:
                    // エラー／不正な処理区分
                    return CSIReturnCode.ERR_DIALYSISSCHE_SND_INVARIDDIV;
            }
        }

        /// <summary>
        /// 開始時刻取得処理
        /// </summary>
        /// <param name="xmlCoopInfo">連携情報</param>
        /// <param name="strValue">取得結果</param>
        /// <returns>リターンコード</returns>
        private Fn3ReturnCode getStartTime(XmlNode xmlCoopInfo, ref string strValue)
        {
            string strItemName = "";
            Fn3ReturnCode fn3Ret = Fn3ReturnCode.Success;
            string strLabel = "";

            //	クールマスタ取得
            XmlNode xmlMstKur = xmlCoopInfo.SelectSingleNode("//rootNode/SCH_DIALYSIS_PLAN/MST_KUR");
            if (xmlMstKur == null || xmlMstKur.ChildNodes.Count == 0)
            {
                //	取得失敗
                fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_GETVALUE;
                strLabel = "クールマスタ";

                // アラーム出力し、リトライしない
                this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                    string.Format("{0}（{1}）", fn3Ret.Message, strLabel));

                this.TraceOut(fn3Ret, strLabel);

                return fn3Ret;
            }

            //	項目名称取得
            strItemName = xmlMstKur["STANDARD_START_TIME"].InnerText.Trim();
            if (strItemName.Length < 6)
            {
                //	取得失敗
                fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_GETVALUE;
                strLabel = "クールマスタ.クール内標準開始時間";

                // アラーム出力し、リトライしない
                this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                    string.Format("{0}（{1}）", fn3Ret.Message, strLabel));

                this.TraceOut(fn3Ret, strLabel);

                return fn3Ret;
            }

            int intKurStartTimeHour;
            int intKurStartTimeMin;
            int intKurStartTimeSec;
            if (int.TryParse(strItemName.Substring(0, 2), out intKurStartTimeHour) == false ||
                int.TryParse(strItemName.Substring(2, 2), out intKurStartTimeMin) == false ||
                int.TryParse(strItemName.Substring(4, 2), out intKurStartTimeSec) == false)
            {
                //	日時の書式が不正
                fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_INVALIDVALUE;
                strLabel = "クールマスタ.クール内標準開始時間";

                // アラーム出力し、リトライしない
                this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                    string.Format("{0}（{1}）", fn3Ret.Message, strLabel));

                this.TraceOut(fn3Ret, strLabel);

                return fn3Ret;
            }
            strItemName = string.Format("{0:D2}:{1:D2}", intKurStartTimeHour, intKurStartTimeMin);

            // 値を渡す
            strValue = strItemName;

            return fn3Ret;
        }

        /// <summary>
        /// 透析時間取得処理
        /// </summary>
        /// <param name="xmlCoopInfo">連携情報</param>
        /// <param name="strValue">取得結果</param>
        /// <returns>リターンコード</returns>
        private Fn3ReturnCode getDialysisTime(XmlNode xmlCoopInfo, ref string strValue)
        {
            int intDialysisTime = 0;
            Fn3ReturnCode fn3Ret = Fn3ReturnCode.Success;
            string strLabel = "";

            //	条件指示取得
            XmlNode xmlDialysisTime = xmlCoopInfo.SelectSingleNode("//rootNode/IND_DIALYSIS_COND[DIALYSIS_ITEM_CD=002]");
            if (xmlDialysisTime == null || xmlDialysisTime.ChildNodes.Count == 0)
            {
                //	取得失敗
                fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_GETVALUE;
                strLabel = "条件指示";

                // アラーム出力し、リトライしない
                this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                    string.Format("{0}（{1}）", fn3Ret.Message, strLabel));

                this.TraceOut(fn3Ret, strLabel);

                return fn3Ret;
            }

            //	透析時間取得
            string strDialysisTime = xmlDialysisTime["VALUE"].InnerText.Trim();
            if (strDialysisTime == null || int.TryParse(strDialysisTime, out intDialysisTime) == false)
            {
                fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_GETVALUE;
                strLabel = "条件指示.透析時間";

                // アラーム出力し、リトライしない
                this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                    string.Format("{0}（{1}）", fn3Ret.Message, strLabel));

                this.TraceOut(fn3Ret, strLabel);

                return fn3Ret;
            }

            //	項目情報部へ追加
            strValue = strDialysisTime;

            return fn3Ret;
        }

        /// <summary>
        /// ベッド名称取得処理
        /// ※ベッド未登録の場合、ベッド名称を「ベッド未登録」とする
        /// </summary>
        /// <param name="xmlCoopInfo">連携情報</param>
        /// <param name="strValue">取得結果</param>
        /// <returns>リターンコード</returns>
        private Fn3ReturnCode getBedName(XmlNode xmlCoopInfo, ref string strValue)
        {
            string strItemName = "";
            Fn3ReturnCode fn3Ret = Fn3ReturnCode.Success;
            string strLabel = "";

            //	ベッドマスタ取得
            XmlNode node = xmlCoopInfo.SelectSingleNode("//rootNode/SCH_DIALYSIS_PLAN/MST_BED");
            if (node == null)
            {
                fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_GETVALUE;
                strLabel = "ベッドマスタ";

                // アラーム出力し、リトライしない
                this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                    string.Format("{0}（{1}）", fn3Ret.Message, strLabel));

                //	取得失敗
                this.TraceOut(fn3Ret, strLabel);

                return fn3Ret;
            }

            // ベッド未登録の場合
            if (node.ChildNodes.Count.Equals(0))
            {
                // ベッド未登録とする
                strItemName = "ベッド未登録";
            }
            else
            {
                //	項目名称取得
                strItemName = node["BED_NAME"].InnerText.Trim();
                if (strItemName.Equals(""))
                {
                    //	連携項目取得失敗
                    fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_GETVALUE;
                    strLabel = "ベッドマスタ.ベッド名";

                    // アラーム出力し、リトライしない
                    this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                        string.Format("{0}（{1}）", fn3Ret.Message, strLabel));

                    //	取得失敗
                    this.TraceOut(fn3Ret, strLabel);

                    return fn3Ret;
                }
            }

            //	項目情報部へ追加
            strValue = strItemName;

            return fn3Ret;
        }

        // 2011/05/13 中村 指示医対応
        /// <summary>
        /// 予定指示.指示者取得処理
        /// </summary>
        /// <param name="xmlCoopInfo">連携情報</param>
        /// <param name="strStaffCd">指示者コード</param>
        /// <returns>リターンコード</returns>
        private Fn3ReturnCode getIndicatorCd(XmlNode xmlCoopInfo, ref string strStaffCd)
        {
            strStaffCd = string.Empty;
            Fn3ReturnCode fn3Ret = Fn3ReturnCode.Success;
            string strLabel = string.Empty;


            XmlNode xmlIndNode = null;                  // 指示者取得ノード
            DateTime dtBaseUpdate = DateTime.MinValue;  // 

            //===================
            // 予約指示
            //===================
            XmlNodeList xmlIndDialysisPlanList = xmlCoopInfo.SelectNodes("//IND_DIALYSIS_PLAN");
            foreach (XmlNode childNode in xmlIndDialysisPlanList)
            {
                DateTime dtUpdate;
                XmlNode xmlUpdate = childNode.SelectSingleNode("UP_DATE");
                if (xmlUpdate == null || string.IsNullOrEmpty(xmlUpdate.InnerText))
                {
                    continue;
                }
                if (DateTime.TryParse(xmlUpdate.InnerText, out dtUpdate) == false)
                {
                    dtUpdate = DateTime.MinValue;
                }
                if (dtUpdate > dtBaseUpdate)
                {
                    strLabel = "予定指示";
                    dtBaseUpdate = dtUpdate;
                    xmlIndNode = childNode;
                }
            }

            //===================
            // 条件指示
            //===================
            XmlNodeList xmlIndDialysisCondList = xmlCoopInfo.SelectNodes("//IND_DIALYSIS_COND");
            foreach (XmlNode childNode in xmlIndDialysisCondList)
            {
                DateTime dtUpdate;
                XmlNode xmlUpdate = childNode.SelectSingleNode("UP_DATE");
                if (xmlUpdate == null || string.IsNullOrEmpty(xmlUpdate.InnerText))
                {
                    continue;
                }
                if (DateTime.TryParse(xmlUpdate.InnerText, out dtUpdate) == false)
                {
                    dtUpdate = DateTime.MinValue;
                }

                if (dtUpdate > dtBaseUpdate)
                {
                    strLabel = "条件指示";
                    dtBaseUpdate = dtUpdate;
                    xmlIndNode = childNode;
                }
            }

            //===================
            // 投薬指示
            //===================
            XmlNodeList xmlIndDialysisMediList = xmlCoopInfo.SelectNodes("//IND_DIALYSIS_MEDI");
            foreach (XmlNode childNode in xmlIndDialysisMediList)
            {
                DateTime dtUpdate;
                XmlNode xmlUpdate = childNode.SelectSingleNode("UP_DATE");
                if (xmlUpdate == null || string.IsNullOrEmpty(xmlUpdate.InnerText))
                {
                    continue;
                }
                if (DateTime.TryParse(xmlUpdate.InnerText, out dtUpdate) == false)
                {
                    dtUpdate = DateTime.MinValue;
                }

                if (dtUpdate > dtBaseUpdate)
                {
                    strLabel = "投薬指示";
                    dtBaseUpdate = dtUpdate;
                    xmlIndNode = childNode;
                }
            }

            //===================
            // 材料指示
            //===================
            XmlNodeList xmlIndDialysisEquipList = xmlCoopInfo.SelectNodes("//IND_DIALYSIS_EQUIP");
            foreach (XmlNode childNode in xmlIndDialysisEquipList)
            {
                DateTime dtUpdate;
                XmlNode xmlUpdate = childNode.SelectSingleNode("UP_DATE");
                if (xmlUpdate == null || string.IsNullOrEmpty(xmlUpdate.InnerText))
                {
                    continue;
                }
                if (DateTime.TryParse(xmlUpdate.InnerText, out dtUpdate) == false)
                {
                    dtUpdate = DateTime.MinValue;
                }

                if (dtUpdate > dtBaseUpdate)
                {
                    strLabel = "材料指示";
                    dtBaseUpdate = dtUpdate;
                    xmlIndNode = childNode;
                }
            }

            //===================
            // 指示簿指示
            //===================
            XmlNodeList xmlIndDialysisAddList = xmlCoopInfo.SelectNodes("//IND_DIALYSIS_ADD");
            foreach (XmlNode childNode in xmlIndDialysisAddList)
            {
                DateTime dtUpdate;
                XmlNode xmlUpdate = childNode.SelectSingleNode("UP_DATE");
                if (xmlUpdate == null || string.IsNullOrEmpty(xmlUpdate.InnerText))
                {
                    continue;
                }
                if (DateTime.TryParse(xmlUpdate.InnerText, out dtUpdate) == false)
                {
                    dtUpdate = DateTime.MinValue;
                }

                if (dtUpdate > dtBaseUpdate)
                {
                    strLabel = "指示簿指示";
                    dtBaseUpdate = dtUpdate;
                    xmlIndNode = childNode;
                }
            }

            // 指示者取得
            XmlNode xmlIndicator = xmlIndNode.SelectSingleNode("INDICATOR_CD");
            if (xmlIndicator == null || string.IsNullOrEmpty(xmlIndicator.InnerText))
            {
                // 取得できない場合エラー
                fn3Ret = CSIReturnCode.WNG_DIALYSISSCHE_SND_INDICATOR;
                strLabel = strLabel + "指示者";

                //	取得失敗
                this.TraceOut(fn3Ret, strLabel);

                return fn3Ret;
            }

            // 職種コード取得
            string strIndicator = xmlIndicator.InnerText;
            XmlNode xmlJobClass = xmlIndNode.SelectSingleNode(string.Format("MST_STAFF[STAFF_CD='{0}']/JOB_CLASS_CD", strIndicator));
            if (xmlJobClass == null || string.IsNullOrEmpty(xmlJobClass.InnerText))
            {
                // 取得できない場合エラー
                fn3Ret = CSIReturnCode.WNG_DIALYSISSCHE_SND_INDICATOR;
                strLabel = "スタッフマスタ.職種コード";

                //	取得失敗
                this.TraceOut(fn3Ret, strLabel);

                return fn3Ret;
            }
            if (!xmlJobClass.InnerText.Equals("1"))
            {
                return fn3Ret;
            }

            string strOutXml = "";
            fn3Ret = this.DBExecQuery("00001", string.Format("<rootNode><VALUE>{0}</VALUE></rootNode>", strIndicator), ref strOutXml);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                // 取得できない場合エラー
                fn3Ret = CSIReturnCode.WNG_DIALYSISSCHE_SND_INDICATOR;
                //	取得失敗
                this.TraceOut(fn3Ret, "スタッフ権限取得用個別クエリが失敗しました。");

                return fn3Ret;
            }

            XmlDocument doc = new XmlDocument();
            try
            {
                doc.LoadXml(strOutXml);
            }
            catch (Exception ex)
            {
                fn3Ret = CSIReturnCode.FTL_DIALYSISSCHE_SND_STAFFAUTH_EX;
                base.ErrorTraceOut(fn3Ret, ex);
                return fn3Ret;
            }

            XmlNode xmlAcl = doc.SelectSingleNode("//rootNode/SYS_STAFF_AUTH/ACL");
            if (xmlAcl == null || string.IsNullOrEmpty(xmlAcl.InnerText))
            {
                // 取得できない場合エラー
                fn3Ret = CSIReturnCode.WNG_DIALYSISSCHE_SND_INDICATOR;
                strLabel = "スタッフ権限.ACL区分";

                //	取得失敗
                this.TraceOut(fn3Ret, strLabel);

                return fn3Ret;
            }

            int intAcl;
            if (!int.TryParse(xmlAcl.InnerText, out intAcl))
            {
                // 取得できない場合エラー
                fn3Ret = CSIReturnCode.WNG_DIALYSISSCHE_SND_INDICATOR;
                strLabel = "スタッフ権限.ACL区分";

                //	取得失敗
                this.TraceOut(fn3Ret, strLabel);

                return fn3Ret;
            }
            if (intAcl >= 3)
            {
                strStaffCd = strIndicator;
            }

            return fn3Ret;
        }

        // 2011/05/16 中村 指示医対応
        /// <summary>
        /// 更新者取得処理
        /// </summary>
        /// <param name="xmlCoopInfo">連携情報</param>
        /// <param name="strStaffCd">更新者コード</param>
        /// <returns>リターンコード</returns>
        private Fn3ReturnCode getUpdaterCd(XmlNode xmlCoopInfo, ref string strStaffCd)
        {
            strStaffCd = string.Empty;
            Fn3ReturnCode fn3Ret = Fn3ReturnCode.Success;
            string strLabel = string.Empty;


            XmlNode xmlIndNode = null;                  // 指示者取得ノード
            DateTime dtBaseUpdate = DateTime.MinValue;  // 

            //===================
            // 予約指示
            //===================
            XmlNodeList xmlIndDialysisPlanList = xmlCoopInfo.SelectNodes("//IND_DIALYSIS_PLAN");
            foreach (XmlNode childNode in xmlIndDialysisPlanList)
            {
                DateTime dtUpdate;
                XmlNode xmlUpdate = childNode.SelectSingleNode("UP_DATE");
                if (xmlUpdate == null || string.IsNullOrEmpty(xmlUpdate.InnerText))
                {
                    continue;
                }
                if (DateTime.TryParse(xmlUpdate.InnerText, out dtUpdate) == false)
                {
                    dtUpdate = DateTime.MinValue;
                }
                if (dtUpdate > dtBaseUpdate)
                {
                    strLabel = "予定指示";
                    dtBaseUpdate = dtUpdate;
                    xmlIndNode = childNode;
                }
            }

            //===================
            // 条件指示
            //===================
            XmlNodeList xmlIndDialysisCondList = xmlCoopInfo.SelectNodes("//IND_DIALYSIS_COND");
            foreach (XmlNode childNode in xmlIndDialysisCondList)
            {
                DateTime dtUpdate;
                XmlNode xmlUpdate = childNode.SelectSingleNode("UP_DATE");
                if (xmlUpdate == null || string.IsNullOrEmpty(xmlUpdate.InnerText))
                {
                    continue;
                }
                if (DateTime.TryParse(xmlUpdate.InnerText, out dtUpdate) == false)
                {
                    dtUpdate = DateTime.MinValue;
                }

                if (dtUpdate > dtBaseUpdate)
                {
                    strLabel = "条件指示";
                    dtBaseUpdate = dtUpdate;
                    xmlIndNode = childNode;
                }
            }

            //===================
            // 投薬指示
            //===================
            XmlNodeList xmlIndDialysisMediList = xmlCoopInfo.SelectNodes("//IND_DIALYSIS_MEDI");
            foreach (XmlNode childNode in xmlIndDialysisMediList)
            {
                DateTime dtUpdate;
                XmlNode xmlUpdate = childNode.SelectSingleNode("UP_DATE");
                if (xmlUpdate == null || string.IsNullOrEmpty(xmlUpdate.InnerText))
                {
                    continue;
                }
                if (DateTime.TryParse(xmlUpdate.InnerText, out dtUpdate) == false)
                {
                    dtUpdate = DateTime.MinValue;
                }

                if (dtUpdate > dtBaseUpdate)
                {
                    strLabel = "投薬指示";
                    dtBaseUpdate = dtUpdate;
                    xmlIndNode = childNode;
                }
            }

            //===================
            // 材料指示
            //===================
            XmlNodeList xmlIndDialysisEquipList = xmlCoopInfo.SelectNodes("//IND_DIALYSIS_EQUIP");
            foreach (XmlNode childNode in xmlIndDialysisEquipList)
            {
                DateTime dtUpdate;
                XmlNode xmlUpdate = childNode.SelectSingleNode("UP_DATE");
                if (xmlUpdate == null || string.IsNullOrEmpty(xmlUpdate.InnerText))
                {
                    continue;
                }
                if (DateTime.TryParse(xmlUpdate.InnerText, out dtUpdate) == false)
                {
                    dtUpdate = DateTime.MinValue;
                }

                if (dtUpdate > dtBaseUpdate)
                {
                    strLabel = "材料指示";
                    dtBaseUpdate = dtUpdate;
                    xmlIndNode = childNode;
                }
            }

            //===================
            // 指示簿指示
            //===================
            XmlNodeList xmlIndDialysisAddList = xmlCoopInfo.SelectNodes("//IND_DIALYSIS_ADD");
            foreach (XmlNode childNode in xmlIndDialysisAddList)
            {
                DateTime dtUpdate;
                XmlNode xmlUpdate = childNode.SelectSingleNode("UP_DATE");
                if (xmlUpdate == null || string.IsNullOrEmpty(xmlUpdate.InnerText))
                {
                    continue;
                }
                if (DateTime.TryParse(xmlUpdate.InnerText, out dtUpdate) == false)
                {
                    dtUpdate = DateTime.MinValue;
                }

                if (dtUpdate > dtBaseUpdate)
                {
                    strLabel = "指示簿指示";
                    dtBaseUpdate = dtUpdate;
                    xmlIndNode = childNode;
                }
            }

            // 指示者取得
            XmlNode xmlUpdater = xmlIndNode.SelectSingleNode("UPDATE_STAFF_CD");
            if (xmlUpdater == null || string.IsNullOrEmpty(xmlUpdater.InnerText))
            {
                // 取得できない場合エラー
                fn3Ret = CSIReturnCode.WNG_DIALYSISSCHE_SND_INDICATOR;
                strLabel = strLabel + "更新者";

                //	取得失敗
                this.TraceOut(fn3Ret, strLabel);

                return fn3Ret;
            }
            strStaffCd = xmlUpdater.InnerText.Trim();

            return fn3Ret;
        }

        /// <summary>
        /// コミット
        /// </summary>
        /// <returns></returns>
        private Fn3ReturnCode procCommit()
        {
            bool blnExec;
            Fn3ReturnCode fn3Ret = Fn3ReturnCode.Success;

            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            base.TraceOut("【透析予約送信】他部門I/F：CSICommonMethod.pDbCommitTrn() Start");
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            blnExec = CSICommonMethod.pDbCommitTrn(objCSICOMMON, objMiraisDB, ref CSICommon.colERR);
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            base.TraceOut("【透析予約送信】他部門I/F：CSICommonMethod.pDbCommitTrn() End");
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

            if ((!blnExec) || (CSICommon.pGetERRCollectionCount() != 0))
            {
                // 異常終了
                fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_DBCOMMIT;

                ////	イベントリトライ
                //this.EventRetry = true;

                // アラーム出力し、リトライしない
                this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                               string.Format("{0}（{1}）", fn3Ret.Message, CSICommonMethod.GetLastErrorString()));

                // トレースログ出力
                if (CSICommon.pGetERRCollectionCount() != 0)
                {
                    this.TraceOut(fn3Ret, CSICommonMethod.GetLastErrorString());
                }
                else
                {
                    this.TraceOut(fn3Ret);
                }
            }
            return fn3Ret;
        }

        /// <summary>
        /// ロールバック
        /// </summary>
        /// <returns></returns>
        private Fn3ReturnCode procRollback()
        {
            bool blnExec;
            Fn3ReturnCode fn3Ret = Fn3ReturnCode.Success;

            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            base.TraceOut("【透析予約送信】他部門I/F：CSICommonMethod.pDbRollBack() Start");
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            blnExec = CSICommonMethod.pDbRollBack(objCSICOMMON, objMiraisDB, ref CSICommon.colERR);
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            base.TraceOut("【透析予約送信】他部門I/F：CSICommonMethod.pDbRollBack() End");
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            if ((!blnExec) || (CSICommon.pGetERRCollectionCount() != 0))
            {
                // 異常終了
                fn3Ret = CSIReturnCode.ERR_DIALYSISSCHE_SND_DBROLLBACK;

                ////	イベントリトライ
                //this.EventRetry = true;

                // アラーム出力し、リトライしない
                this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, m_strForMsgDispPatId, m_strForMsgPatName, "",
                               string.Format("{0}（{1}）", fn3Ret.Message, CSICommonMethod.GetLastErrorString()));

                // トレースログ出力
                if (CSICommon.pGetERRCollectionCount() != 0)
                {
                    this.TraceOut(fn3Ret, CSICommonMethod.GetLastErrorString());
                }
                else
                {
                    this.TraceOut(fn3Ret);
                }
            }
            return fn3Ret;
        }

        // 2016/04/11 中村 ポップアップ通知対応 Add Start
        #region
        /// <summary>
        /// ポップアップ通知情報登録
        /// </summary>
        private void RegistPopupNotice(Fn3ExecuteInfo exeInfo, bool IsSuccess)
        {
            if ("0" == m_strPopupNotice)
            {
                // 通知しない設定の場合は何もせずに終了
                return;
            }

            // 表示用患者ID
            if (string.IsNullOrEmpty(this.m_strForMsgDispPatId))
            {
                // 患者未指定の場合は何もせずに終了
                return;
            }

            // 患者名チェック
            if (string.IsNullOrEmpty(this.m_strForMsgPatName))
            {
                // 空値の場合、"-"を設定
                this.m_strForMsgPatName = "-";
            }

            string strSendClass = string.Empty;
            switch (exeInfo.SendClass)
            {
                case "0": strSendClass = "新規"; break;	//	新規
                case "1": strSendClass = "修正"; break;	//	修正
                case "2": strSendClass = "削除"; break;	//	削除
                default: return;
            }

            // 透析日
            string strDialysisDate = string.Empty;
            DateTime dtDialysisDate;
            if (!string.IsNullOrEmpty(m_strForSendMemoDialDate))
            {
                // 送信メモ.透析日時より取得
                if (DateTime.TryParseExact(m_strForSendMemoDialDate, "yyyyMMddHHmm", null, 0, out dtDialysisDate))
                {
                    strDialysisDate = dtDialysisDate.ToString("yyyy/MM/dd HH:mm");
                }
            }
            else if (exeInfo.SendClass.Equals("0"))
            {

                // 透析スケジュール.透析日
                string strBuf = string.Empty;
                XmlNode xmlBuf = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/SCH_DIALYSIS_PLAN/DIALYSIS_DATE");
                if (xmlBuf == null)
                {
                    base.TraceOut(CSIReturnCode.ERR_REGIST_POPUP);
                    return;
                }
                else
                {
                    strBuf = xmlBuf.InnerText.Trim();
                }

                // 条件指示.開始時間
                xmlBuf = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/SCH_DIALYSIS_PLAN/MST_KUR/STANDARD_START_TIME");
                if (xmlBuf == null || string.IsNullOrEmpty(xmlBuf.InnerText))
                {
                    base.TraceOut(CSIReturnCode.ERR_REGIST_POPUP);
                    return;
                }
                else
                {
                    strBuf += xmlBuf.InnerText.Trim();
                }

                if (DateTime.TryParseExact(strBuf, "yyyyMMddHHmmss", null, 0, out dtDialysisDate))
                {
                    strDialysisDate = dtDialysisDate.ToString("yyyy/MM/dd HH:mm");
                }
            }
            else
            {
                // 送信メモ.透析日時より取得
                string[] strBuf = exeInfo.SendHistMemo.Split(',');
                if (strBuf.Length > 3 && !string.IsNullOrEmpty(strBuf[2]))
                {
                    if (DateTime.TryParseExact(strBuf[2], "yyyyMMddHHmm", null, 0, out dtDialysisDate))
                    {
                        strDialysisDate = dtDialysisDate.ToString("yyyy/MM/dd HH:mm");
                    }
                }
            }

            // 透析日が取得できていない場合
            if (string.IsNullOrEmpty(strDialysisDate) && exeInfo.SpecificKey.Length > 8)
            {
                // 特定キーより透析日のみ取得(時間なし)
                if (DateTime.TryParseExact(exeInfo.SpecificKey.Substring(0, 8), "yyyyMMdd", null, 0, out dtDialysisDate))
                {
                    strDialysisDate = dtDialysisDate.ToString("yyyy/MM/dd");
                }
            }


            // メッセージ作成
            string strPopUpMsg = string.Empty;
            string strEventCd = string.Empty;
            if (IsSuccess)
            {
                // 成功メッセージ作成
                strPopUpMsg = string.Format("透析予約({0})の送信に成功しました。\n　患者ID：[{1}]\n　患者名：[{2}]\n　透析日：[{3}]",
                              strSendClass, m_strForMsgDispPatId, m_strForMsgPatName, strDialysisDate);
                strEventCd = "4100000001";
            }
            else
            {
                // 失敗メッセージ作成
                strPopUpMsg = string.Format("透析予約({0})の送信に失敗しました。\n　患者ID：[{1}]\n　患者名：[{2}]\n　透析日：[{3}]",
                              strSendClass, m_strForMsgDispPatId, m_strForMsgPatName, strDialysisDate);
                strEventCd = "4100000002";
            }

            // 連携イベントログテーブル存在チェック
            string strSQL = @"<rootNode></rootNode>";
            string strOutXml = string.Empty;
            Fn3ReturnCode retCode = base.DBExecQuery("10002", strSQL, ref strOutXml);
            if (retCode.IsError || retCode.IsException)
            {
                // エラー
                base.TraceOut(CSIReturnCode.ERR_REGIST_POPUP);
                return;
            }
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(strOutXml);
            XmlNode xmlNode = doc.SelectSingleNode("//rootNode/USER_TABLES/TABLE_NAME");
            if (null == xmlNode || !xmlNode.InnerText.Equals("IF_EVENT_LOG"))
            {
                // テーブルがないので処理終了
                TraceOut(CSIReturnCode.ERR_NOT_EXIST_IF_EVENT_LOG);
                return;
            }

            // 連携イベントログテーブル登録SQL
            strSQL = string.Format(@"<rootNode><EVENT_CLASS>{0}</EVENT_CLASS><DISP_PATID>{1}</DISP_PATID><NAME>{2}</NAME><EVENT_CD>{3}</EVENT_CD><EVENT_DETAIL>{4}</EVENT_DETAIL></rootNode>",
                                                "透析予約送信", m_strForMsgDispPatId, m_strForMsgPatName, strEventCd, strPopUpMsg);
            // SQL実行
            strOutXml = string.Empty;
            retCode = base.DBExecQuery("10001", strSQL, ref strOutXml);
            if (retCode.IsError || retCode.IsException)
            {
                // トレースログのみ出力
                base.TraceOut(CSIReturnCode.ERR_REGIST_POPUP);
            }
        }
        #endregion
        // 2016/04/11 中村 ポップアップ通知対応 Add End

    }
}
