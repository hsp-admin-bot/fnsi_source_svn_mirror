//////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：検査予定送信連携
// ファイル名：CSICoopExaminScheSendStd.cs
// 説明      ：検査予定の新規・変更・削除イベントに応じて、MIRAIsへ各検査オーダ
//             を送信する。
//
//	Copyright(C) 2011 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2011/01/19	飛田隆太			新規作成
//  2015/07/30  石川俊介            ログ強化
//  2016/04/12  中村圭之介          ポップアップ通知対応
//
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections;
using System.Collections.Generic;
using System.Xml;
using System.Text;
using System.Reflection;
using jp.co.nikkiso.fn3.Cooperation;
using jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn;
using jp.co.nikkiso.fn3.Cooperation.CSICoop;

namespace CSICoopExaminScheSendStd
{
    public class CSICoopExaminScheSendStd : Fn3ComPlugIn
    {
        #region 定数定義

        /// <summary>
        /// 連携イベントの処理区分：新規
        /// </summary>
        private const string EVENT_TYPE_ADD = "0";
        /// <summary>
        /// 連携イベントの処理区分：変更
        /// </summary>
        private const string EVENT_TYPE_MOD = "1";
        /// <summary>
        /// 連携イベントの処理区分：削除
        /// </summary>
        private const string EVENT_TYPE_DEL = "2";

        /// <summary>
        /// FNWの検査区分：透析前
        /// </summary>
        private const string EXAM_DIVISION_BEFORE = "0";

        /// <summary>
        /// FNWの検査区分：透析後
        /// </summary>
        private const string EXAM_DIVISION_AFTER = "1";

        /// <summary>
        /// FNWの検査区分：その他
        /// </summary>
        private const string EXAM_DIVISION_OTHER = "2";

        /// <summary>
        /// 個別クエリID定義（透析前・透析後）
        /// 検査予定削除時の更新者取得
        /// </summary>
        private const string ORG_QUERY_ID_GET_DELETE_UPDATE_CODE = "00001";

        /// <summary>
        /// 個別クエリID定義（透析前・透析後）
        /// 検査予定削除時の更新者取得
        /// </summary>
        private const string ORG_QUERY_ID_GET_DELETE_UPDATE_CODE_OTHER = "00002";

        /// <summary>
        /// 個別クエリID定義
        /// スタッフ権限の取得
        /// </summary>
        private const string ORG_QUERY_ID_GET_ACL = "00003";


        /// <summary>
        /// 連携による予定削除時のスタッフコード
        /// <value>**********</value>
        /// </summary>
        private const string UNKNOWN_STAFF_CODE = "**********";

        // 2011/05/23 中村 指示医対応
        /// <summary>
        /// 指示医フラグ
        /// </summary>
        private string IndicatorFlg = "";

        #endregion

        #region メンバ定義

        /// <summary>
        /// 外部I/F部品フラグ（JMS or PARTS）
        /// </summary>
        private string LibraryType = string.Empty;

        /// <summary>
        /// 患者ID桁数
        /// </summary>
        private int PatIDLength = 0;

        /// <summary>
        /// デフォルトスタッフコード
        /// </summary>
        private string DefaltStaffCode = string.Empty;

        /// <summary>
        /// 検査オーダ依頼科コード
        /// </summary>
        private string DapertmentCode = string.Empty;

        /// <summary>
        /// 検査オーダ依頼病棟コード
        /// </summary>
        private string WardCode = string.Empty;

        /// <summary>
        /// 検査オーダ入力端末
        /// </summary>
        private string UpdateTerminal = string.Empty;

        /// <summary>
        /// 予定削除スタッフコード
        /// </summary>
        private string DeleteStaffCode = string.Empty;

        /// <summary>
        /// 透析前コメント名称
        /// </summary>
        private string CommentNameDialBefore = string.Empty;

        /// <summary>
        /// 透析後コメント名称
        /// </summary>
        private string CommentNameDialAfter = string.Empty;

        /// <summary>
        /// その他コメント名称
        /// </summary>
        private string CommentNameOther = string.Empty;

        /// <summary>
        /// シーエスアイ外部I/F部品 共通オブジェクト
        /// </summary>
        private object objCSICOMMON = null;

        /// <summary>
        /// シーエスアイ外部I/F部品 検査オーダ
        /// </summary>
        private object objCSIORDER = null;

        /// <summary>
        /// MIRAIs-DBオブジェクト
        /// </summary>
        private object objMIRAIsDB = null;

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

        // 2016/04/13 中村 ポップアップ通知対応 Add Start
        /// <summary>ポップアップ通知設定</summary>
        private string m_strPopupNotice = "0";
        // 2016/04/13 中村 ポップアップ通知対応 Add End
        
        #endregion

        #region メソッド

        /// <summary>
        /// 初期化処理
        /// 初期設定、外部I/F部品インスタンスの取得
        /// </summary>
        /// <returns>成功/失敗</returns>
        protected override Fn3ReturnCode Initialize()
        {
            // メソッド開始ログ
            base.MethodStartLogOut(MethodBase.GetCurrentMethod());

            try
            {
                // 初期設定値取得
                Fn3ReturnCode retCodeGetIniSetting = this.GetIniSetting();
                if (retCodeGetIniSetting.IsError)
                {
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_INITIALIZE);
                    return CSIReturnCode.ERR_EXAMINSCHE_SEND_INITIALIZE;
                }

                // シーエスアイ外部I/F部品インスタンス生成
                Fn3ReturnCode retCodeGetInstance = this.CreateInterfaceInstance();
                if (retCodeGetInstance.IsError)
                {
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_INITIALIZE);
                    return CSIReturnCode.ERR_EXAMINSCHE_SEND_INITIALIZE;
                }

                // 初期化成功
                return CSIReturnCode.Success;
            }
            catch (Exception ex)
            {
                base.ErrorTraceOut(CSIReturnCode.FTL_EXAMIN_RCV_INITIALIZE, ex);
                return CSIReturnCode.FTL_EXAMIN_RCV_INITIALIZE;
            }
            finally
            {
                // メソッド終了ログ
                base.MethodEndLogOut(MethodBase.GetCurrentMethod());
            }
        }

        /// <summary>
        /// 開始処理
        /// </summary>
        /// <returns>成功/失敗</returns>
        protected override Fn3ReturnCode Start()
        {
            // メソッド開始ログ
            base.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // メソッド終了ログ
            base.MethodEndLogOut(MethodBase.GetCurrentMethod());

            return CSIReturnCode.Success;
        }

        /// <summary>
        /// 停止処理
        /// </summary>
        protected override void Stop()
        {
            // メソッド開始ログ
            base.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // メソッド終了ログ
            base.MethodEndLogOut(MethodBase.GetCurrentMethod());
        }

        /// <summary>
        /// 検査予定書送信処理
        /// 検査予定情報をMIRAIsへ送信する
        /// </summary>
        /// <param name="exeInfo">各種処理データ</param>
        /// <returns>成功/失敗</returns>
        protected override Fn3ReturnCode Execute(Fn3ExecuteInfo exeInfo)
        {
            // メソッド開始ログ
            base.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // 入力、出力パラメタ全クリア
            CSICommon.ClearAllParameter();

            ExamInfo eiExamInfo = new ExamInfo();
            bool IsSuccess = true;

            // ロールバックフラグOFF
            bool isRollback = false;
            try
            {
                //--------------------------------------------------------------------------------------------------
                // 検査予定情報取得
                //--------------------------------------------------------------------------------------------------
                // ExamInfo eiExamInfo = new ExamInfo();
                Fn3ReturnCode retCodeGetExamInfo = this.GetExaminInfoFromExeInfo(exeInfo, eiExamInfo);
                if (retCodeGetExamInfo.IsError)
                {
                    // [エラー]検査予定送信失敗
                    // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                    //base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_SEND);
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_SEND, string.Format("患者ID=\"{0}\"", eiExamInfo.DispPatID));
                    // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                    IsSuccess = false;
                    return CSIReturnCode.ERR_EXAMINSCHE_SEND_SEND;
                }
                else
                {
                    base.DebugTraceOut(this.CreateDebugMessage("検査予定の送信処理を開始します。", eiExamInfo.GetLogInfoText()));
                }

                //--------------------------------------------------------------------------------------------------
                // MIRAIsDB接続
                //--------------------------------------------------------------------------------------------------
                Fn3ReturnCode retCodeDBOpen = this.OpenMIRAIsDB(eiExamInfo);
                if (retCodeDBOpen.IsError)
                {
                    // [エラー]検査予定送信失敗
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_SEND);
                    IsSuccess = false;
                    return CSIReturnCode.ERR_EXAMINSCHE_SEND_SEND;
                }

                //--------------------------------------------------------------------------------------------------
                // トランザクション開始
                //--------------------------------------------------------------------------------------------------
                Fn3ReturnCode retCodeStartTran = this.StartTransaction(eiExamInfo);
                if (retCodeStartTran.IsError)
                {
                    // [エラー]検査予定送信失敗
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_SEND);
                    IsSuccess = false;
                    return CSIReturnCode.ERR_EXAMINSCHE_SEND_SEND;
                }

                //--------------------------------------------------------------------------------------------------
                // 検査予定送信
                //--------------------------------------------------------------------------------------------------
                // ロールバックフラグON
                isRollback = true;
                Fn3ReturnCode retCodeSendExaminOrder = this.SendExaminOrder(eiExamInfo, exeInfo);
                if (retCodeSendExaminOrder.IsError)
                {
                    // [エラー]検査予定送信失敗
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_SEND);
                    IsSuccess = false;
                    return CSIReturnCode.ERR_EXAMINSCHE_SEND_SEND;
                }
                else
                {
                    // ロールバックフラグOFF
                    isRollback = false;
                }

                //--------------------------------------------------------------------------------------------------
                // コミット
                //--------------------------------------------------------------------------------------------------
                // ロールバックフラグON
                isRollback = true;
                Fn3ReturnCode retCodeCommit = this.CommitTransaction(eiExamInfo);
                if (retCodeCommit.IsError)
                {
                    // [エラー]検査予定送信失敗
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_SEND);
                    IsSuccess = false;
                    return CSIReturnCode.ERR_EXAMINSCHE_SEND_SEND;
                }
                else
                {
                    // ロールバックフラグOFF
                    isRollback = false;
                }

                //--------------------------------------------------------------------------------------------------
                // 送信成功
                //--------------------------------------------------------------------------------------------------
                base.DebugTraceOut(this.CreateDebugMessage("検査予定の送信処理に成功しました。", eiExamInfo.GetLogInfoText()));
                IsSuccess = true;
                return new Fn3ReturnCode(Fn3ReturnCode.Success.ProcKind, Fn3ReturnCode.Success.Code, base.SendHistMemo, ReturnCodeType.Success);
            }
            catch (Exception ex)
            {
                // [エラー]検査予定送信失敗
                base.ErrorTraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_SEND, ex);
                IsSuccess = false;
                return CSIReturnCode.ERR_EXAMINSCHE_SEND_SEND;
            }
            finally
            {
                // ロールバックが必要な場合
                if (isRollback)
                {
                    //--------------------------------------------------------------------------------------------------
                    // ロールバック
                    //--------------------------------------------------------------------------------------------------
                    this.RollbackTransaction();
                }

                //--------------------------------------------------------------------------------------------------
                // MIRAIsDB切断
                //--------------------------------------------------------------------------------------------------
                this.CloseMIRAIsDB();

                // ポップアップ通知対応
                this.RegistPopupNotice(exeInfo, eiExamInfo, IsSuccess);

                // メソッド終了ログ
                base.MethodEndLogOut(MethodBase.GetCurrentMethod());
            }
        }

        /// <summary>
        /// 解放処理
        /// </summary>
        protected override void Release()
        {
            // メソッド開始ログ
            base.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // メソッド終了ログ
            base.MethodEndLogOut(MethodBase.GetCurrentMethod());
        }

        /// <summary>
        /// 設定値取得＆チェック
        /// 外部I/F部品設定、患者ID桁数を取得
        /// </summary>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode GetIniSetting()
        {
            hstGroupCd.Clear();
            //--------------------------------------------------------------------------------------------------
            // 外部I/F部品設定の取得
            //--------------------------------------------------------------------------------------------------
            Fn3ReturnCode retCodePartsSelecter = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                      CSICommonConst.SYS_SECT_COMMON,
                                                                      CSICommonConst.SYS_KEY_LIBRARY_TYPE,
                                                                      ref this.LibraryType);
            if (retCodePartsSelecter.IsError || retCodePartsSelecter.IsException || this.LibraryType.Equals(string.Empty))
            {
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_GETINITIALVALUE,
                              string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_LIBRARY_TYPE, this.LibraryType));

                return CSIReturnCode.Error;
            }

            //--------------------------------------------------------------------------------------------------
            // 患者ID桁数の取得
            //--------------------------------------------------------------------------------------------------
            string strPatIDLength = string.Empty;
            Fn3ReturnCode retCodePatIDLength = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                    CSICommonConst.SYS_SECT_COMMON,
                                                                    CSICommonConst.SYS_KEY_SEND_PATID_FIGURES,
                                                                    ref strPatIDLength);
            if (retCodePatIDLength.IsError || retCodePatIDLength.IsException || strPatIDLength.Equals(string.Empty))
            {
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_GETINITIALVALUE,
                              string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_SEND_PATID_FIGURES, strPatIDLength));

                return CSIReturnCode.Error;
            }
            // 取得値を保持
            this.PatIDLength = System.Convert.ToInt32(strPatIDLength);

            //--------------------------------------------------------------------------------------------------
            // デフォルトスタッフコードの取得
            //--------------------------------------------------------------------------------------------------
            Fn3ReturnCode retCodeDefaltStaff = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                    CSICommonConst.SYS_SECT_COMMON,
                                                                    CSICommonConst.SYS_KEY_DEFAULT_STAFF_CODE,
                                                                    ref this.DefaltStaffCode);
            if (retCodeDefaltStaff.IsError || retCodeDefaltStaff.IsException || this.DefaltStaffCode.Equals(string.Empty))
            {
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_GETINITIALVALUE,
                              string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_DEFAULT_STAFF_CODE, this.DefaltStaffCode));

                return CSIReturnCode.Error;
            }

            //--------------------------------------------------------------------------------------------------
            // 検査オーダ依頼科コードの取得
            //--------------------------------------------------------------------------------------------------
            Fn3ReturnCode retCodeDaprtment = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                  CSICommonConst.SYS_SECT_EXAMINSCHESEND,
                                                                  CSICommonConst.SYS_KEY_EXAM_DAPARTMENT,
                                                                  ref this.DapertmentCode);
            if (retCodeDaprtment.IsError || retCodeDaprtment.IsException || this.DapertmentCode.Equals(string.Empty))
            {
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_GETINITIALVALUE,
                              string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_EXAMINSCHESEND, CSICommonConst.SYS_KEY_EXAM_DAPARTMENT, this.DapertmentCode));

                return CSIReturnCode.Error;
            }

            //--------------------------------------------------------------------------------------------------
            // 検査オーダ依頼病棟コードの取得
            //--------------------------------------------------------------------------------------------------
            Fn3ReturnCode retCodeWard = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                             CSICommonConst.SYS_SECT_EXAMINSCHESEND,
                                                             CSICommonConst.SYS_KEY_EXAM_WARD,
                                                             ref this.WardCode);
            if (retCodeWard.IsError || retCodeWard.IsException || this.WardCode.Equals(string.Empty))
            {
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_GETINITIALVALUE,
                              string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_EXAMINSCHESEND, CSICommonConst.SYS_KEY_EXAM_WARD, this.WardCode));

                return CSIReturnCode.Error;
            }

            //--------------------------------------------------------------------------------------------------
            // 検査オーダ入力端末の取得
            //--------------------------------------------------------------------------------------------------
            Fn3ReturnCode retCodeUpdateTerminal = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                       CSICommonConst.SYS_SECT_EXAMINSCHESEND,
                                                                       CSICommonConst.SYS_KEY_EXAM_UPDATE_TERMINAL,
                                                                       ref this.UpdateTerminal);
            if (retCodeUpdateTerminal.IsError || retCodeUpdateTerminal.IsException || this.UpdateTerminal.Equals(string.Empty))
            {
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_GETINITIALVALUE,
                              string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_EXAMINSCHESEND, CSICommonConst.SYS_KEY_EXAM_UPDATE_TERMINAL, this.UpdateTerminal));

                return CSIReturnCode.Error;
            }

            //--------------------------------------------------------------------------------------------------
            // 予定削除スタッフコードの取得
            //--------------------------------------------------------------------------------------------------
            Fn3ReturnCode retCodeDeleteStaff = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                       CSICommonConst.SYS_SECT_EXAMINSCHESEND,
                                                                       CSICommonConst.SYS_KEY_EXAM_DELETE_SCHEDULE_STAFF,
                                                                       ref this.DeleteStaffCode);
            if (retCodeDeleteStaff.IsError || retCodeDeleteStaff.IsException || this.UpdateTerminal.Equals(string.Empty))
            {
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_GETINITIALVALUE,
                              string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_EXAMINSCHESEND, CSICommonConst.SYS_KEY_EXAM_DELETE_SCHEDULE_STAFF, this.DeleteStaffCode));

                return CSIReturnCode.Error;
            }

            //--------------------------------------------------------------------------------------------------
            // 透析前コメント名称の取得
            //--------------------------------------------------------------------------------------------------
            Fn3ReturnCode retCodeCommentDialBefore = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                          CSICommonConst.SYS_SECT_EXAMINSCHESEND,
                                                                          CSICommonConst.SYS_KEY_EXAM_COMMENT_DIAL_BEFORE,
                                                                          ref this.CommentNameDialBefore);
            if (retCodeCommentDialBefore.IsError || retCodeCommentDialBefore.IsException || this.CommentNameDialBefore.Equals(string.Empty))
            {
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_GETINITIALVALUE,
                              string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_EXAMINSCHESEND, CSICommonConst.SYS_KEY_EXAM_COMMENT_DIAL_BEFORE, this.CommentNameDialBefore));

                return CSIReturnCode.Error;
            }

            //--------------------------------------------------------------------------------------------------
            // 透析後コメント名称の取得
            //--------------------------------------------------------------------------------------------------
            Fn3ReturnCode retCodeCommentDialAfter = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                         CSICommonConst.SYS_SECT_EXAMINSCHESEND,
                                                                         CSICommonConst.SYS_KEY_EXAM_COMMENT_DIAL_AFTER,
                                                                         ref this.CommentNameDialAfter);
            if (retCodeCommentDialAfter.IsError || retCodeCommentDialAfter.IsException || this.CommentNameDialAfter.Equals(string.Empty))
            {
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_GETINITIALVALUE,
                              string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_EXAMINSCHESEND, CSICommonConst.SYS_KEY_EXAM_COMMENT_DIAL_AFTER, this.CommentNameDialAfter));

                return CSIReturnCode.Error;
            }

            //--------------------------------------------------------------------------------------------------
            // その他コメント名称の取得（値の有無はチェックしない）
            //--------------------------------------------------------------------------------------------------
            Fn3ReturnCode retCodeCommentOther = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                     CSICommonConst.SYS_SECT_EXAMINSCHESEND,
                                                                     CSICommonConst.SYS_KEY_EXAM_COMMENT_OTHER,
                                                                     ref this.CommentNameOther);
            if (retCodeCommentOther.IsError || retCodeCommentOther.IsException)
            {
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_GETINITIALVALUE,
                              string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_EXAMINSCHESEND, CSICommonConst.SYS_KEY_EXAM_COMMENT_OTHER, this.CommentNameOther));

                return CSIReturnCode.Error;
            }


            // 2011/05/23 中村 指示医対応
            //--------------------------------------------------------------------------------------------------
            // 指示医切り替えフラグ
            //--------------------------------------------------------------------------------------------------
            string strIndicatorFlg = string.Empty;
            Fn3ReturnCode retCodeIndicatorFlg = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                    CSICommonConst.SYS_SECT_COMMON,
                                                                    CSICommonConst.SYS_KEY_INDICATOR_FLG,
                                                                    ref strIndicatorFlg);
            if (retCodeIndicatorFlg.IsError || retCodeIndicatorFlg.IsException || strIndicatorFlg.Equals(""))
            {
                this.TraceOut(CSIReturnCode.ERR_DIALYSISSCHE_SND_INITIALVALUEFAILED,
                              string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                            CSICommonConst.SYS_SECT_COMMON,
                                            CSICommonConst.SYS_KEY_INDICATOR_FLG,
                                            ""));
            }
            else
            {
                // 取得値を保持
                this.IndicatorFlg = strIndicatorFlg;
            }

            // 2013/04/23 中村 科コード設定対応 Add Start
            // 個別設定値を読み込む
            Fn3ReturnCode retCode = Fn3ReturnCode.Success;
            string strGroupFlg = string.Empty;
            Fn3ReturnCode retCodeGroupFlg = this.GetInitialValue("1", CSICommonConst.SYS_SECT_GROUPCD, CSICommonConst.SYS_KEY_PAT_GROUP_FLG, ref strGroupFlg);
            if (retCodeGroupFlg.IsError || retCodeGroupFlg.IsException || string.IsNullOrEmpty(strGroupFlg))
            {
                retCode = CSIReturnCode.ERR_EXAMINSCHE_SEND_GROUPCD_FAILED;

                this.TraceOut(retCode,
                              string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                            CSICommonConst.SYS_SECT_GROUPCD,
                                            CSICommonConst.SYS_KEY_PAT_GROUP_FLG,
                                            ""));
                return retCode;
            }
            else
            {
                m_PatGroupFlg = strGroupFlg;
            }

            if (m_PatGroupFlg.Equals("0"))
            {
                Fn3ReturnCode retCodeGroupCd = this.GetInitialValue("1", CSICommonConst.SYS_SECT_GROUPCD, ref hstGroupCd);
                if (retCodeGroupCd.IsError || retCodeGroupCd.IsException)
                {
                    retCode = CSIReturnCode.ERR_EXAMINSCHE_SEND_GROUPCD_FAILED;

                    this.TraceOut(retCode,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_GROUPCD,
                                                "",
                                                ""));
                    return retCode;
                }

                // 所属グループコードの利用設定をハッシュから取り除く
                if (hstGroupCd.ContainsKey(CSICommonConst.SYS_KEY_PAT_GROUP_FLG))
                {
                    hstGroupCd.Remove(CSICommonConst.SYS_KEY_PAT_GROUP_FLG);
                }

                // ベッド番号・科コード対応
                string strOutXml = string.Empty;
                Fn3ReturnCode retExecQuery = base.DBExecQuery("00004", "<rootNode />", ref strOutXml);
                if (retExecQuery.IsError || retExecQuery.IsException)
                {
                    retCode = CSIReturnCode.ERR_EXAMINSCHE_SEND_MSTBED_FAILED;
                    this.TraceOut(retCode);
                    return retCode;
                }
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(strOutXml);
                if (xmlDoc.SelectNodes("//rootNode/MST_BED/BED_NO").Count == 0)
                {
                    retCode = CSIReturnCode.ERR_EXAMINSCHE_SEND_MSTBED_FAILED;
                    this.TraceOut(retCode);
                    return retCode;
                }
                string strNgBedNo = string.Empty;
                foreach (XmlNode nodeBed in xmlDoc.SelectNodes("//rootNode/MST_BED/BED_NO"))
                {
                    if (hstGroupCd.ContainsKey(nodeBed.InnerText) == false ||
                        hstGroupCd[nodeBed.InnerText].ToString().Length != 5)
                    {
                        retCode = CSIReturnCode.ERR_EXAMINSCHE_SEND_MSTPATGROUP_FAILED;
                        if (!string.IsNullOrEmpty(strNgBedNo)) strNgBedNo += ",";
                        strNgBedNo += nodeBed.InnerText;
                    }
                }
                if (retCode == CSIReturnCode.ERR_EXAMINSCHE_SEND_MSTPATGROUP_FAILED)
                {
                    this.TraceOut(retCode,
                                  string.Format("登録されていないベッド番号：{0}", strNgBedNo));
                    return retCode;
                }
            }
            // 2013/04/23 中村 科コード設定対応 Add End

            // 2016/04/12 中村 ポップアップ通知対応 Add Start
            //--------------------------------------------------------------------------------------------------
            // ポップアップ通知設定
            //--------------------------------------------------------------------------------------------------
            string strPopupNotice = string.Empty;
            Fn3ReturnCode retCodePopupNotice = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                    CSICommonConst.SYS_SECT_COMMON,
                                                                    CSICommonConst.SYS_KEY_POPUP_NOTICE,
                                                                    ref strPopupNotice);
            if (retCodePopupNotice.IsError || retCodePopupNotice.IsException || strPopupNotice.Equals(""))
            {
                this.TraceOut(CSIReturnCode.WNG_EXAMINSCHE_POPUP_NOTICE,
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
            // 2016/04/12 中村 ポップアップ通知対応 Add End

            // 設定値取得成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// 検査予定送信に必要な、各I/F部品のインスタンスを生成
        /// </summary>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode CreateInterfaceInstance()
        {
            // シーエスアイ外部I/F部品のオブジェクト作成
            //-- 共通
            this.objCSICOMMON = CSICommonMethod.CreateObject(CSICommonMethod.GetLibName(CSICommonConst.CSIPROGRAMID_COMMON, this.LibraryType));
            if (this.objCSICOMMON == null)
            {
                // [アラーム通知]
                base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, string.Empty, string.Empty, string.Empty, CSIReturnCode.ERR_EXAMINSCHE_SEND_CREATECOMMON.Message);

                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                //base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_CREATECOMMON);
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_CREATECOMMON, string.Format("LibName=\"{0}\"", CSICommonConst.CSIPROGRAMID_COMMON));
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                return CSIReturnCode.Error;
            }

            //-- 検査オーダ
            this.objCSIORDER = CSICommonMethod.CreateObject(CSICommonMethod.GetLibName(CSICommonConst.CSIPROGRAMID_ORDER, this.LibraryType));
            if (this.objCSIORDER == null)
            {
                // [アラーム通知]
                base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, string.Empty, string.Empty, string.Empty, CSIReturnCode.ERR_EXAMINSCHE_SEND_CREATEOBJECT_ORDER.Message);

                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                //base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_CREATEOBJECT_ORDER);
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_CREATEOBJECT_ORDER, string.Format("LibName=\"{0}\"", CSICommonConst.CSIPROGRAMID_ORDER));
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                return CSIReturnCode.Error;
            }

            // シーエスアイ外部I/F部品 インスタンス生成成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// 検査予定情報取得
        /// 連携情報からMIRAIsへ送信する検査情報を取得します
        /// </summary>
        /// <param name="exeInfo">連携情報</param>
        /// <param name="eiExamInfo">検査予定情報</param>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode GetExaminInfoFromExeInfo(Fn3ExecuteInfo exeInfo, ExamInfo eiExamInfo)
        {
            //--------------------------------------------------------------------------------------------------
            // キー情報の読み込み
            //--------------------------------------------------------------------------------------------------
            XmlDocument xmlKeyInfo = new XmlDocument();
            try
            {
                xmlKeyInfo.LoadXml(exeInfo.KeyInfo);
            }
            catch (Exception ex)
            {
                // [エラー]キー情報読み込み失敗
                base.ErrorTraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, ex, "キー情報の読み込みに失敗");
                return CSIReturnCode.Error;
            }

            //--------------------------------------------------------------------------------------------------
            // 過去日のチェック
            //--------------------------------------------------------------------------------------------------
            // 削除時は検査予定が取れいないため、必ず取れるキー情報から検査日取得
            DateTime dtmExamDate = DateTime.Parse(xmlKeyInfo.SelectSingleNode("//血液検査送信/EXAM_DATE").InnerText.Insert(6, "/").Insert(4, "/"));
            // 検査日が今日より過去の場合
            if (dtmExamDate.Date < DateTime.Now.Date)
            { 
                // [エラー]過去のオーダ
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                //base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_PAST_DATE);
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_PAST_DATE, string.Format("検査日=\"{0}\"", dtmExamDate.Date.ToString()));
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                return CSIReturnCode.Error;
            }

            //--------------------------------------------------------------------------------------------------
            // イベント区分の取得
            //--------------------------------------------------------------------------------------------------
            eiExamInfo.EventType = exeInfo.EventType;

            //--------------------------------------------------------------------------------------------------
            // MIRAIsの処理区分取得
            //--------------------------------------------------------------------------------------------------
            switch (eiExamInfo.EventType)
            {
                // 新規
                case EVENT_TYPE_ADD:
                    eiExamInfo.MIRAIsProcType = CSICommonConst.PROCDIV_INSERT;
                    break;
                // 変更
                case EVENT_TYPE_MOD:
                    eiExamInfo.MIRAIsProcType = CSICommonConst.PROCDIV_MODIFY;
                    break;
                // 削除
                case EVENT_TYPE_DEL:
                    eiExamInfo.MIRAIsProcType = CSICommonConst.PROCDIV_DELETE;
                    break;
                default:
                    // [エラー]イベント区分不正
                    base.TraceOut(string.Format("イベント区分が不正です。 ({0})", eiExamInfo.GetLogInfoText()));
                    return CSIReturnCode.Error;
            }

            //--------------------------------------------------------------------------------------------------
            // 表示用患者IDの取得
            //--------------------------------------------------------------------------------------------------
            XmlNode nodeDispPatID = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DISP_PATID");
            eiExamInfo.DispPatID = nodeDispPatID.InnerText;

            //--------------------------------------------------------------------------------------------------
            // MIRAIsの患者番号取得
            //--------------------------------------------------------------------------------------------------
            // 取得した患者IDが設定桁数以下の場合に対応する為、設定桁数で0詰めする
            string miraisPatID = eiExamInfo.DispPatID.PadLeft(this.PatIDLength, '0');
            // 下桁から設定桁数だけ取得する
            miraisPatID = miraisPatID.Substring(miraisPatID.Length - this.PatIDLength, this.PatIDLength);
            eiExamInfo.MIRAIsPatID = miraisPatID;
            if (eiExamInfo.MIRAIsPatID.Equals(string.Empty))
            { 
                // [エラー]MIRAIs患者番号なし
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, "MIRAIs患者番号");
                return CSIReturnCode.Error;
            }

            //--------------------------------------------------------------------------------------------------
            // 患者IDの取得
            //--------------------------------------------------------------------------------------------------
            XmlNode nodePatID = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/PATID");
            eiExamInfo.PatID = nodePatID.InnerText;

            //--------------------------------------------------------------------------------------------------
            // 患者名の取得
            //--------------------------------------------------------------------------------------------------
            XmlNode nodePatName = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/NAME");
            eiExamInfo.PatName = nodePatName.InnerText;

            //--------------------------------------------------------------------------------------------------
            // 指示医の取得
            //--------------------------------------------------------------------------------------------------
            // 2011/05/23 中村 指示医対応
            string strIndStaffCd = "";
            if (this.IndicatorFlg.Equals("1"))
            {
                // 検査予定.指示者
                strIndStaffCd = getDeciderCd(exeInfo.CoopInfoXML);
                if (!strIndStaffCd.Equals(string.Empty))
                {
                    eiExamInfo.OrderDoctor = strIndStaffCd;
                }
            }

            if (eiExamInfo.OrderDoctor.Equals(string.Empty))
            {
                // 担当医1の取得
                XmlNode nodeDoctor1 = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DOCTOR_CD1");

                // 担当医1が設定されている場合
                if (!nodeDoctor1.InnerText.Equals(string.Empty))
                {
                    // 指示医は担当医1とする
                    eiExamInfo.OrderDoctor = nodeDoctor1.InnerText.Trim();
                }
                // 担当医1が未設定の場合
                else
                {
                    // 担当医2の取得
                    XmlNode nodeDoctor2 = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DOCTOR_CD2");

                    // 担当医2が設定されている場合
                    if (!nodeDoctor2.InnerText.Equals(string.Empty))
                    {
                        // 指示医は担当医2とする
                        eiExamInfo.OrderDoctor = nodeDoctor2.InnerText.Trim();
                    }
                    // 担当医2が未設定の場合
                    else
                    {
                        // デフォルトスタッフとする
                        eiExamInfo.OrderDoctor = this.DefaltStaffCode;
                    }
                }
            }
            if (eiExamInfo.OrderDoctor.Equals(string.Empty))
            {
                // [エラー]指示医なし
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, "指示医");
                return CSIReturnCode.Error;
            }

            //--------------------------------------------------------------------------------------------------
            // 科の取得
            //--------------------------------------------------------------------------------------------------
            // 2013/04/23 中村 科コード設定対応 Chg Start
#if false
            XmlNode nodeDepartment = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/MST_PAT_GROUP/IN_HOSPITAL_CD");
            if (nodeDepartment == null || nodeDepartment.InnerText.Trim().Length != 5)
            {
                eiExamInfo.Department = this.DapertmentCode;
            }
            else
            {
                eiExamInfo.Department = nodeDepartment.InnerText.Trim().Substring(0, 2);
            }
#else
            if (m_PatGroupFlg.Equals("0"))
            {
                XmlNode nodeBedNo = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/SCH_DIALYSIS_PLAN/BED_NO");
                if (nodeBedNo != null)
                {
                    if (hstGroupCd.ContainsKey(nodeBedNo.InnerText))
                    {
                        eiExamInfo.Department = hstGroupCd[nodeBedNo.InnerText].ToString().Substring(0, 2);
                    }
                }
            }

            if (string.IsNullOrEmpty(eiExamInfo.Department))
            {
                XmlNode nodeDepartment = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/MST_PAT_GROUP/IN_HOSPITAL_CD");
                if (nodeDepartment == null || nodeDepartment.InnerText.Trim().Length != 5)
                {
                    eiExamInfo.Department = this.DapertmentCode;
                }
                else
                {
                    eiExamInfo.Department = nodeDepartment.InnerText.Trim().Substring(0, 2);
                }
            }
#endif
            // 2013/04/23 中村 科コード設定対応 Chg End

            //--------------------------------------------------------------------------------------------------
            // 新規・変更時の検査情報を取得
            //--------------------------------------------------------------------------------------------------
            if (eiExamInfo.EventType.Equals(EVENT_TYPE_ADD) || eiExamInfo.EventType.Equals(EVENT_TYPE_MOD))
            {
                //--------------------------------------------------------------------------------------------------
                // 検査予定日時の取得
                //--------------------------------------------------------------------------------------------------
                DateTime examDate;
                Fn3ReturnCode retCodeExamDate = base.GetExamScheDateTime(exeInfo, out examDate);
                if (retCodeExamDate.IsError)
                {
                    // [エラー]検査予定日時取得失敗
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, "検査予定日時");
                    return CSIReturnCode.Error;
                }
                eiExamInfo.ExamDate = examDate;

                //--------------------------------------------------------------------------------------------------
                // 検査区分の取得
                //--------------------------------------------------------------------------------------------------
                XmlNode nodeExamDivision = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_EXAMIN_SCHEDULE/EXAM_DIVISION");
                eiExamInfo.ExamDivision = nodeExamDivision.InnerText;

                //--------------------------------------------------------------------------------------------------
                // MIRAIsの検査区分コメントコード取得
                //--------------------------------------------------------------------------------------------------
                string miraisExamDivisionCode = string.Empty;
                Fn3ReturnCode retCodeConvExamDiv = base.Convert(ConvertItem.ExaminOrderClassToKarte, eiExamInfo.ExamDivision, ref miraisExamDivisionCode);
                // 変換できなかった場合
                if (retCodeConvExamDiv.IsError)
                {
                    // 透析前の場合
                    if (eiExamInfo.ExamDivision.Equals(EXAM_DIVISION_BEFORE))
                    {
                        // [エラー]透析前コード取得失敗
                        base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, "透析前検査コメントコード");
                        return CSIReturnCode.Error;                    
                    }
                    // 透析後の場合
                    else if (eiExamInfo.ExamDivision.Equals(EXAM_DIVISION_AFTER))
                    {
                        // [エラー]透析後コード取得失敗
                        base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, "透析後検査コメントコード");
                        return CSIReturnCode.Error;
                    }
                    // その他の場合
                    else
                    {
                        // コードが無ければ検査区分を送らないためnullとする
                        eiExamInfo.MIRAIsExamDivisionCommentCode = null;
                    }
                }
                else
                {
                    // MIRAIs側の当該コードを設定
                    eiExamInfo.MIRAIsExamDivisionCommentCode = miraisExamDivisionCode;
                }

                //--------------------------------------------------------------------------------------------------
                // MIRAIsの検査区分コメント名称取得
                //--------------------------------------------------------------------------------------------------
                switch (eiExamInfo.ExamDivision)
                { 
                    case EXAM_DIVISION_BEFORE:
                        eiExamInfo.MIRAIsExamDivisionName = this.CommentNameDialBefore;
                        break;
                    case EXAM_DIVISION_AFTER:
                        eiExamInfo.MIRAIsExamDivisionName = this.CommentNameDialAfter;
                        break;
                    default:
                        eiExamInfo.MIRAIsExamDivisionName = this.CommentNameOther;
                        break;
                }

                //--------------------------------------------------------------------------------------------------
                // オーダ日時の取得
                //--------------------------------------------------------------------------------------------------
                XmlNode nodeUpdate = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_EXAMIN_SCHEDULE/UP_DATE");
                DateTime update;
                if (!DateTime.TryParse(nodeUpdate.InnerText, out update))
                {
                    // [エラー]オーダ日なし
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, "オーダ日");
                    return CSIReturnCode.Error;
                }
                eiExamInfo.OrderDate = update;

                //--------------------------------------------------------------------------------------------------
                // オーダ入力者の取得
                //--------------------------------------------------------------------------------------------------
                XmlNode nodeOrderStaff = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_EXAMIN_SCHEDULE/ORDER_STAFF");
                eiExamInfo.OrderStaff = nodeOrderStaff.InnerText.Trim();
                if (eiExamInfo.OrderStaff.Equals(string.Empty))
                {
                    // [エラー]オーダ入力者なし
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, "オーダ入力者");
                    return CSIReturnCode.Error;
                }

                //--------------------------------------------------------------------------------------------------
                // 検査セットの取得（全ての検査セットを展開し、検査項目の院内コードリストを生成）
                //--------------------------------------------------------------------------------------------------
                // 検査セット数分処理
                foreach (XmlNode nodeExamSet in exeInfo.CoopInfoXML.SelectNodes("//rootNode/PAT_EXAMIN_SCHEDULE/MST_EXAM_SET"))
                {
                    // 検査項目数分処理
// 2011/07/17 中村 【緊急対応】予約は院内コード２を参照するよう変更。
#if false
                    // foreach (XmlNode nodeExamInhospitalCode in nodeExamSet.SelectNodes("MST_EXAM_SET_DETAIL/MST_EXAM_ITEM/IN_HOSPITAL_CD"))
#endif
                    foreach (XmlNode nodeExamInhospitalCode in nodeExamSet.SelectNodes("MST_EXAM_SET_DETAIL/MST_EXAM_ITEM/IN_HOSPITAL_CD2"))
                    {
                        // 院内コードが設定されている場合（院内コードの無いものは送信しない）
                        if (!nodeExamInhospitalCode.InnerText.Equals(string.Empty))
                        {
                            // 既にリストに登録されている院内コードは追加しない（重複は不許可）
                            if (!eiExamInfo.ExamItemList.Contains(nodeExamInhospitalCode.InnerText.Trim()))
                            {
                                // 検査項目リストに検査項目の院内コードを追加
                                eiExamInfo.ExamItemList.Add(nodeExamInhospitalCode.InnerText.Trim());
                            }
                        }
                    }
                }
                if (eiExamInfo.ExamItemList.Count.Equals(0))
                {
                    // [エラー]検査項目1つもなし
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, "検査項目");
                    return CSIReturnCode.Error;
                }

                //--------------------------------------------------------------------------------------------------
                // 更新者の取得
                //--------------------------------------------------------------------------------------------------
                XmlNode nodeUpdateStaff = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_EXAMIN_SCHEDULE/UPDATE_CODE");
                eiExamInfo.UpdateStaff = nodeUpdateStaff.InnerText.Trim();
                if (eiExamInfo.UpdateStaff.Equals(string.Empty))
                {
                    // [エラー]更新者なし
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, "更新者");
                    return CSIReturnCode.Error;
                }
            }
            //--------------------------------------------------------------------------------------------------
            // 削除時の検査情報を取得
            //--------------------------------------------------------------------------------------------------
            else
            {
                //--------------------------------------------------------------------------------------------------
                // 検査予定日の取得（キー情報より取得）
                // ※時間は取れない
                //--------------------------------------------------------------------------------------------------
                eiExamInfo.ExamDate = DateTime.Parse(xmlKeyInfo.SelectSingleNode("//血液検査送信/EXAM_DATE").InnerText.Insert(6, "/").Insert(4, "/"));

                //--------------------------------------------------------------------------------------------------
                // 検査区分の取得（キー情報より取得）
                //--------------------------------------------------------------------------------------------------
                eiExamInfo.ExamDivision = xmlKeyInfo.SelectSingleNode("//血液検査送信/EXAM_DIVISION").InnerText;

                //--------------------------------------------------------------------------------------------------
                // 更新者の取得
                //--------------------------------------------------------------------------------------------------
                XmlNode nodeUpdateStaff = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_EXAMIN_SCHEDULE/UPDATE_CODE");
                // 更新者ノードが存在する場合
                // ※透析予定による削除時
                if (nodeUpdateStaff != null)
                {
                    // 更新者取得
                    eiExamInfo.UpdateStaff = nodeUpdateStaff.InnerText.Trim();
                    if (eiExamInfo.UpdateStaff.Equals(string.Empty))
                    {
                        // [エラー]更新者なし
                        base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, "更新者");
                        return CSIReturnCode.Error;
                    }
                }
                // 更新者ノードが無い場合
                // ※検査予定レコードの論理削除時
                else
                {
                    //--------------------------------------------------------------------------------------------------
                    // 連携情報が取れないため、個別クエリにより主キーの一致する「実施予定なし」検査予定を抽出し、
                    // そこから更新者を取得する
                    //--------------------------------------------------------------------------------------------------
                    string strQueryResultXml = string.Empty;

                    //--------------------------------------------------------------------------------------------------
                    // 透析前・透析後の場合
                    //--------------------------------------------------------------------------------------------------
                    if (eiExamInfo.ExamDivision.Equals(EXAM_DIVISION_AFTER) || eiExamInfo.ExamDivision.Equals(EXAM_DIVISION_BEFORE))
                    {
                        // 患者ID、キー情報からクエリ用パラメータ生成
                        string inXml = this.CreateInXml(eiExamInfo.PatID, eiExamInfo.ExamDate.ToString("yyyyMMdd"), eiExamInfo.ExamDivision);

                        // 透析前・透析後用更新者取得個別クエリ実施
                        Fn3ReturnCode retCodeGetUpdateCode = base.DBExecQuery(ORG_QUERY_ID_GET_DELETE_UPDATE_CODE, inXml, ref strQueryResultXml);
                        if (retCodeGetUpdateCode.IsError || retCodeGetUpdateCode.IsException)
                        {
                            // [エラー]個別クエリ失敗
                            base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, "透析前・透析後用更新者取得クエリ失敗");
                            return CSIReturnCode.Error;
                        }
                    }
                    //--------------------------------------------------------------------------------------------------
                    // その他の場合
                    //--------------------------------------------------------------------------------------------------
                    else
                    {
                        // 削除時は検査予定が取れいないため、キー情報から検査セットコード取得
                        string keyExamSetCD = xmlKeyInfo.SelectSingleNode("//血液検査送信/EXAM_SET_CD").InnerText;

                        // 患者ID、キー情報からクエリ用パラメータ生成（検査セットコードまで指定）
                        string inXml = this.CreateInXml(eiExamInfo.PatID, eiExamInfo.ExamDate.ToString("yyyyMMdd"), eiExamInfo.ExamDivision, keyExamSetCD);

                        // その他用更新者取得個別クエリ実施
                        Fn3ReturnCode retCodeGetUpdateCode = base.DBExecQuery(ORG_QUERY_ID_GET_DELETE_UPDATE_CODE_OTHER, inXml, ref strQueryResultXml);
                        if (retCodeGetUpdateCode.IsError || retCodeGetUpdateCode.IsException)
                        {
                            // [エラー]個別クエリ失敗
                            base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, "その他用更新者取得クエリ失敗");
                            return CSIReturnCode.Error;
                        }
                    }

                    //--------------------------------------------------------------------------------------------------
                    // 削除時更新者の取り出し
                    //--------------------------------------------------------------------------------------------------
                    XmlDocument xmlDoc = new XmlDocument();
                    try
                    {
                        xmlDoc.LoadXml(strQueryResultXml);
                        XmlNode nodeDeleteUpdateStaff = xmlDoc.SelectSingleNode("//rootNode/PAT_EXAMIN_SCHEDULE/UPDATE_CODE");

                        //--------------------------------------------------------------------------------------------------
                        // 更新者取得
                        //--------------------------------------------------------------------------------------------------
                        eiExamInfo.UpdateStaff = nodeDeleteUpdateStaff.InnerText.Trim();
                        if (eiExamInfo.UpdateStaff.Equals(string.Empty))
                        {
                            // [エラー]削除時更新者なし
                            base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, "削除時更新者");
                            return CSIReturnCode.Error;
                        }
                    }
                    catch (Exception ex)
                    {
                        // [エラー]削除時更新者取り出し失敗
                        base.ErrorTraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_ESSENTIALVALUE_NOT_FOUND, ex);
                        return CSIReturnCode.Error;
                    }
                }

                //--------------------------------------------------------------------------------------------------
                // システム削除スタッフの場合（死亡患者取り込みなどプログラムが検査予定を削除した場合）
                // ※2011/02/03 患者死亡による削除の場合、検査予定の論理削除は行われないため現状は予定削除スタッフが送られることはないが、
                //   ひとまず残しておく
                //--------------------------------------------------------------------------------------------------
                if (eiExamInfo.UpdateStaff.Equals(UNKNOWN_STAFF_CODE))
                {
                    // 予定削除スタッフを設定
                    eiExamInfo.UpdateStaff = this.DeleteStaffCode;
                }
            }

            // 収集成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// 入力XMLを生成します
        /// </summary>
        /// <param name="values">バインド値</param>
        /// <returns>入力XML</returns>
        private string CreateInXml(params string[] values)
        {
            StringBuilder sb = new StringBuilder();
            XmlWriterSettings settings = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            XmlWriter inXmlWriter = XmlWriter.Create(sb, settings);

            inXmlWriter.WriteStartElement("rootNode");
            for (int i = 0; i < values.Length; i++)
            {
                inXmlWriter.WriteElementString(string.Format("VALUE{0}", i.ToString()), values[i]);
            }
            inXmlWriter.WriteEndElement();
            inXmlWriter.Flush();

            return sb.ToString();
        }

        /// <summary>
        /// 検査オーダ送信処理
        /// </summary>
        /// <param name="eiExamInfo">検査予定情報</param>
        /// <param name="exeInfo">連携情報</param>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode SendExaminOrder(ExamInfo eiExamInfo, Fn3ExecuteInfo exeInfo)
        {
            //--------------------------------------------------------------------------------------------------
            // 検査オーダ設定
            // データ構造は以下の通り
            //
            // オーダコレクション
            //   ↓
            //   オーダヘッダコレクション（削除の場合はグループ以下を設定しない）
            //     ↓
            //     オーダグループコレクション
            //       ↓
            //       オーダディテールコレクション（N件）
            //       ↓
            //       検査コメントコレクション（ディテールと同件数）
            //--------------------------------------------------------------------------------------------------
            if (eiExamInfo.EventType.Equals(EVENT_TYPE_ADD))
            {
                // 新規の場合はオーダ番号無し
                eiExamInfo.MIRAIsOrderNo = null;
                eiExamInfo.MIRAIsOrderSubNo = null;
            }
            else
            {
                // 暫定対策　
                // base.SendHistMemoに値が入らない
                // フレームワークのバグと思われるがバグ対応を待つ時間はないのでexeInfo.SendHistMemoで上書する。
                if (base.SendHistMemo != exeInfo.SendHistMemo)
                {
                    base.DebugTraceOut(string.Format("SendHistMemoの障害 Fn3ComPlugIn.SendHistMemo={0} Fn3ExecuteInfo.SendHistMemo={1}", base.SendHistMemo, exeInfo.SendHistMemo));
                }
                base.SendHistMemo = exeInfo.SendHistMemo;

                // 変更・削除の場合は送信履歴メモより新規時に保持した値を取得（形式：オーダ番号,オーダサブ番号）
                eiExamInfo.MIRAIsOrderNo = base.SendHistMemo.Split(',')[0];
                eiExamInfo.MIRAIsOrderSubNo = base.SendHistMemo.Split(',')[1];
            }
            // 検査オーダ設定開始
            this.SetOrderCollection(eiExamInfo);

            //--------------------------------------------------------------------------------------------------
            // 検査オーダ送信
            //--------------------------------------------------------------------------------------------------
            // 出力パラメタ格納領域確保
            CSICommon.varOUTPARAM = new object[7];
            // 送信処理実施
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            base.TraceOut("【検査予定送信】他部門I/F：CSICommonMethod.pOrder() Start");
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            bool isSendSuccess = CSICommonMethod.pOrder(this.objCSIORDER, CSICommon.colORDER, ref CSICommon.varOUTPARAM, ref CSICommon.colERR, this.objMIRAIsDB);
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            base.TraceOut("【検査予定送信】他部門I/F：CSICommonMethod.pOrder() End");
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            // DUMP出力
            DumpParameter dumpParam = new DumpParameter("検査オーダ", new object[] { CSICommon.colORDER }, CSICommon.varOUTPARAM, CSICommon.colERR, isSendSuccess);
            base.DumpOut(exeInfo.SpecificKey, CSICommonMethod.CreateDumpData(eiExamInfo.PatID, new DumpParameter[] { dumpParam }));
            //>>>>> 2011/12/16 CHG T.Kurita 検査オーダ重複対応
            //if (!isSendSuccess)
            //{
            //    // [アラーム通知]
            //    base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, eiExamInfo.DispPatID, eiExamInfo.PatName, string.Empty,
            //                   string.Format("{0}（{1}）", CSIReturnCode.ERR_EXAMINSCHE_SEND_USEOBJECT_ORDER.Message, CSICommonMethod.GetLastErrorString()));

            //    // MIRAIs側の接続エラー、排他エラー（電子カルテで対象患者参照中など）の場合
            //    if (CSICommonMethod.IsErrorCode(CSICommonConst.ERRCODE_RETRYERR1) ||
            //        CSICommonMethod.IsErrorCode(CSICommonConst.ERRCODE_RETRYERR2) ||
            //        CSICommonMethod.IsErrorCode(CSICommonConst.ERRCODE_RETRYERR3))
            //    {
            //        //--------------------------------------------------------------------------------------------------
            //        // リトライ実施
            //        //--------------------------------------------------------------------------------------------------
            //        base.EventRetry = true;
            //    }

            //    // [エラー]検査予定送信失敗
            //    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_USEOBJECT_ORDER);
            //    return CSIReturnCode.Error;
            //}
            if ((!isSendSuccess) || (CSICommon.pGetERRCollectionCount() != 0))
            {
                string strLastError = "";
                string strErrLevel = string.Empty;
                string strErrCd = string.Empty;
                string strErrMsg = string.Empty;

                strLastError = CSICommonMethod.GetLastErrorString(ref strErrLevel, ref strErrCd, ref strErrMsg);

                if (!strErrLevel.Equals("W"))
                {

                    // [アラーム通知]
                    base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, eiExamInfo.DispPatID, eiExamInfo.PatName, string.Empty,
                                   string.Format("{0}（{1}）", CSIReturnCode.ERR_EXAMINSCHE_SEND_USEOBJECT_ORDER.Message, CSICommonMethod.GetLastErrorString()));

                    // MIRAIs側の接続エラー、排他エラー（電子カルテで対象患者参照中など）の場合
                    if (CSICommonMethod.IsErrorCode(CSICommonConst.ERRCODE_RETRYERR1) ||
                        CSICommonMethod.IsErrorCode(CSICommonConst.ERRCODE_RETRYERR2) ||
                        CSICommonMethod.IsErrorCode(CSICommonConst.ERRCODE_RETRYERR3))
                    {
                        //--------------------------------------------------------------------------------------------------
                        // リトライ実施
                        //--------------------------------------------------------------------------------------------------
                        base.EventRetry = true;
                    }

                    // [エラー]検査予定送信失敗
                    // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                    //base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_USEOBJECT_ORDER);
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_USEOBJECT_ORDER, string.Format("患者ID=\"{0}\"", eiExamInfo.DispPatID));
                    // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                    return CSIReturnCode.Error;
                }
            }
            //<<<<< 2011/12/16 CHG T.Kurita 検査オーダ重複対応

            //--------------------------------------------------------------------------------------------------
            // オーダ番号、オーダサブ番号保持
            //--------------------------------------------------------------------------------------------------
            if (eiExamInfo.EventType.Equals(EVENT_TYPE_ADD))
            {
                //>>>>> 2011/12/20 CHG T.Kurita
                //// 新規の場合はMIRAIsの戻り値からオーダ番号、オーダサブ番号を取得
                //string orderNo = CSICommon.pGetOUTPARAMData(CSICommon.CON_ORDERNO).ToString();
                //string orderSubNo = CSICommon.pGetOUTPARAMData(CSICommon.CON_ORDERSUBNO).ToString();
                object objNo = CSICommon.pGetOUTPARAMData(CSICommon.CON_ORDERNO);
                if (objNo == null)
                {
                    // [エラー]検査予定送信失敗
                    base.TraceOut(string.Format("MIRAIsからオーダ番号が返されませんでした。<オーダ番号:NULL> ({0})", eiExamInfo.GetLogInfoText()));
                    return CSIReturnCode.Error;
                }
                string orderNo = objNo.ToString();

                object objSubNo = CSICommon.pGetOUTPARAMData(CSICommon.CON_ORDERSUBNO);
                if (objSubNo == null)
                {
                    // [エラー]検査予定送信失敗
                    base.TraceOut(string.Format("MIRAIsからオーダ番号が返されませんでした。<オーダサブ番号:NULL> ({0})", eiExamInfo.GetLogInfoText()));
                    return CSIReturnCode.Error;
                }
                string orderSubNo = objSubNo.ToString();
                //<<<<< 2011/12/20 CHG T.Kurita

                // 番号が取れていない場合
                if (orderNo.Equals(string.Empty) || orderSubNo.Equals(string.Empty))
                { 
                    // [エラー]検査予定送信失敗
                    base.TraceOut(string.Format("MIRAIsからオーダ番号が返されませんでした。 ({0})", eiExamInfo.GetLogInfoText()));
                    return CSIReturnCode.Error;
                }

                // 2016/04/13 中村 ポップアップ通知対応 Chg Start
                // 検査日
                string examDate = eiExamInfo.ExamDate.ToString("yyyyMMddHHmm");

                // 送信履歴メモに格納（カンマ区切り）
                // base.SendHistMemo = orderNo + "," + orderSubNo;
                base.SendHistMemo = orderNo + "," + orderSubNo + "," + examDate;
                // 2016/04/13 中村 ポップアップ通知対応 Chg End
            }

            // 送信成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// 検査オーダ．オーダヘッダコレクションを設定します
        /// </summary>
        /// <param name="eiExamInfo">検査予定情報</param>
        private void SetOrderCollection(ExamInfo eiExamInfo)
        {
            //--------------------------------------------------------------------------------------------------
            // オーダコレクションの領域確保
            //--------------------------------------------------------------------------------------------------
            CSICommon.varORDER = new object[14];

            //--------------------------------------------------------------------------------------------------
            // オーダコレクションの各値設定
            //--------------------------------------------------------------------------------------------------
            // 処理区分
            CSICommon.pSetORDERData(CSICommon.CON_O_TRANSACTION, eiExamInfo.MIRAIsProcType);
            // 動作区分（2：正常登録）
            CSICommon.pSetORDERData(CSICommon.CON_O_ACTION, "2");
            // 進捗変更区分
            CSICommon.pSetORDERData(CSICommon.CON_O_MODSTATUS, null);
            // 帳票区分
            CSICommon.pSetORDERData(CSICommon.CON_O_ISSUE, null);

            // オーダヘッダコレクション作成
            this.SetOrderHeaderCollection(eiExamInfo);
            CSICommon.pSetCollection(2, CSICommon.varHEADER);
            CSICommon.pSetORDERData(CSICommon.CON_O_HEADERCOLLECTION, (VBA.Collection)CSICommon.colHEADER);

            // 進捗マスタ参照フラグ（1：進捗マスタを参照する）
            CSICommon.pSetORDERData(CSICommon.CON_O_COMSTATUS, "1");
            // 新オーダ日
            CSICommon.pSetORDERData(CSICommon.CON_O_ORDERDATE, null);
            // 新オーダ進捗
            CSICommon.pSetORDERData(CSICommon.CON_O_ORDERSTATUS, null);
            // 新会計進捗
            CSICommon.pSetORDERData(CSICommon.CON_O_ACCOUNTSTATUS, null);
            // 帳票発行
            CSICommon.pSetORDERData(CSICommon.CON_O_PRINTOBJECT, null);
            // 薬袋I/F
            CSICommon.pSetORDERData(CSICommon.CON_O_DRUG, null);
            // 検査I/F
            CSICommon.pSetORDERData(CSICommon.CON_O_LACS, null);
            // 医事I/F
            CSICommon.pSetORDERData(CSICommon.CON_O_IBARS, null);
            // RIS I/F
            CSICommon.pSetORDERData(CSICommon.CON_O_RIS, null);

            // オーダコレクション追加
            CSICommon.pSetCollection(1, CSICommon.varORDER);
        }

        /// <summary>
        /// 検査オーダ．オーダヘッダコレクションを設定します
        /// </summary>
        /// <param name="eiExamInfo">検査予定情報</param>
        private void SetOrderHeaderCollection(ExamInfo eiExamInfo)
        {
            //--------------------------------------------------------------------------------------------------
            // オーダヘッダコレクションの領域確保
            //--------------------------------------------------------------------------------------------------
            CSICommon.varHEADER = new object[28];

            //--------------------------------------------------------------------------------------------------
            // オーダヘッダコレクションの各値設定
            //--------------------------------------------------------------------------------------------------
            // オーダ番号（新規時はnullになる）
            CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERNO, eiExamInfo.MIRAIsOrderNo);
            // オーダサブ番号（新規時はnullになる）
            CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERSUBNO, eiExamInfo.MIRAIsOrderSubNo);

            // 患者番号～オーダ入力者
            if (eiExamInfo.EventType.Equals(EVENT_TYPE_ADD) || eiExamInfo.EventType.Equals(EVENT_TYPE_MOD))
            {
                // 新規・変更時

                // 患者番号
                CSICommon.pSetHEADERData(CSICommon.CON_H_PATIENTNO, eiExamInfo.MIRAIsPatID);
                // オーダ種
                CSICommon.pSetHEADERData(CSICommon.CON_H_KINDOFORDER, "60");
                // オーダ詳細
                CSICommon.pSetHEADERData(CSICommon.CON_H_DETAILOFORDER, null);
                // オーダ開始日
                CSICommon.pSetHEADERData(CSICommon.CON_H_STARTDATE, eiExamInfo.ExamDate.ToString("yyyy/MM/dd"));
                // オーダ開始時刻
                CSICommon.pSetHEADERData(CSICommon.CON_H_STARTTIME, eiExamInfo.ExamDate.ToString("HH:mm:ss"));
                // オーダ終了日
                CSICommon.pSetHEADERData(CSICommon.CON_H_ENDDATE, eiExamInfo.ExamDate.ToString("yyyy/MM/dd"));
                // オーダ終了時刻
                CSICommon.pSetHEADERData(CSICommon.CON_H_ENDTIME, eiExamInfo.ExamDate.ToString("HH:mm:ss"));
                // 実施進捗
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERSTATUS1, null);
                // 科 
                // CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERDEPARTMENT, this.DapertmentCode);
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERDEPARTMENT, eiExamInfo.Department);
                // 病棟
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERWARD, this.WardCode);
                // 指示医
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERDOCTOR, eiExamInfo.OrderDoctor);
                // オーダ日 
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERDATE, eiExamInfo.OrderDate.ToString("yyyy/MM/dd"));
                // オーダ時刻
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERTIME, eiExamInfo.OrderDate.ToString("HH:mm:ss"));
                // オーダ入力端末
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERTERMINAL, this.UpdateTerminal);
                // オーダ入力者
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDEROPERATOR, eiExamInfo.OrderStaff);
            }
            else
            {
                // 削除時

                // 患者番号
                CSICommon.pSetHEADERData(CSICommon.CON_H_PATIENTNO, null);
                // オーダ種
                CSICommon.pSetHEADERData(CSICommon.CON_H_KINDOFORDER, null);
                // オーダ詳細
                CSICommon.pSetHEADERData(CSICommon.CON_H_DETAILOFORDER, null);
                // オーダ開始日
                CSICommon.pSetHEADERData(CSICommon.CON_H_STARTDATE, null);
                // オーダ開始時刻
                CSICommon.pSetHEADERData(CSICommon.CON_H_STARTTIME, null);
                // オーダ終了日
                CSICommon.pSetHEADERData(CSICommon.CON_H_ENDDATE, null);
                // オーダ終了時刻
                CSICommon.pSetHEADERData(CSICommon.CON_H_ENDTIME, null);
                // 実施進捗
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERSTATUS1, null);
                // 科 
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERDEPARTMENT, null);
                // 病棟
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERWARD, null);
                // 指示医
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERDOCTOR, null);
                // オーダ日 
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERDATE, null);
                // オーダ時刻
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERTIME, null);
                // オーダ入力端末
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDERTERMINAL, null);
                // オーダ入力者
                CSICommon.pSetHEADERData(CSICommon.CON_H_ORDEROPERATOR, null);
            }

            // 実施病棟
            CSICommon.pSetHEADERData(CSICommon.CON_H_EXECUTEWARD, null);
            // 実施病室
            CSICommon.pSetHEADERData(CSICommon.CON_H_EXECUTEROOM, null);
            // 実施日
            CSICommon.pSetHEADERData(CSICommon.CON_H_EXECUTEDATE, null);
            // 実施時刻
            CSICommon.pSetHEADERData(CSICommon.CON_H_EXECUTETIME, null);
            // 実施者
            CSICommon.pSetHEADERData(CSICommon.CON_H_EXECUTEOPERATOR, null);
            // 実施番号
            CSICommon.pSetHEADERData(CSICommon.CON_H_EXECUTENO, null);
            // 発効日
            CSICommon.pSetHEADERData(CSICommon.CON_H_ISSUEDATE, null);
            // 発行者
            CSICommon.pSetHEADERData(CSICommon.CON_H_ISSUEOPERATOR, null);
            // 更新端末 
            CSICommon.pSetHEADERData(CSICommon.CON_H_UPDATETERMINAL, this.UpdateTerminal);
            // 更新者
            CSICommon.pSetHEADERData(CSICommon.CON_H_UPDATEOPERATOR, eiExamInfo.UpdateStaff);

            //--------------------------------------------------------------------------------------------------
            // 検査オーダ．オーダグループコレクション設定
            //--------------------------------------------------------------------------------------------------
            // ※削除時は値無しコレクションを設定
            this.SetOrderGroupCollection(eiExamInfo);
            CSICommon.pSetCollection(3, CSICommon.varGROUP);
            CSICommon.pSetHEADERData(CSICommon.CON_H_TESTGROUPCOLLECTION, (VBA.Collection)CSICommon.colGROUP);
        }

        /// <summary>
        /// 検査オーダ．オーダグループコレクションを設定します
        /// </summary>
        /// <param name="eiExamInfo">検査予定情報</param>
        private void SetOrderGroupCollection(ExamInfo eiExamInfo)
        {
            //--------------------------------------------------------------------------------------------------
            // オーダグループコレクションの領域確保
            //--------------------------------------------------------------------------------------------------
            CSICommon.varGROUP = new object[15];

            //--------------------------------------------------------------------------------------------------
            // オーダヘッダコレクションの各値設定
            //--------------------------------------------------------------------------------------------------
            // 開始日付
            CSICommon.pSetGROUPData(CSICommon.CON_G_STARTDATE, null);
            // 開始時刻
            CSICommon.pSetGROUPData(CSICommon.CON_G_STARTTIME, null);
            // 実施進捗
            CSICommon.pSetGROUPData(CSICommon.CON_G_GROUPSTATUS1, null);
            // 実施病棟
            CSICommon.pSetGROUPData(CSICommon.CON_G_EXECUTEWARD, null);
            // 実施病室
            CSICommon.pSetGROUPData(CSICommon.CON_G_EXECUTEROOM, null);
            // 実施日
            CSICommon.pSetGROUPData(CSICommon.CON_G_EXECUTEDATE, null);
            // 実施時刻
            CSICommon.pSetGROUPData(CSICommon.CON_G_EXECUTETIME, null);
            // 実施者
            CSICommon.pSetGROUPData(CSICommon.CON_G_EXECUTEOPERATOR, null);
            // 実施番号
            CSICommon.pSetGROUPData(CSICommon.CON_G_EXECUTENO, null);
            // 期間
            CSICommon.pSetGROUPData(CSICommon.CON_G_PERIOD, null);
            // グループ種
            CSICommon.pSetGROUPData(CSICommon.CON_G_GROUPCATEGORY, null);
            // 身長
            CSICommon.pSetGROUPData(CSICommon.CON_G_TESTHEIGHT, null);
            // 体重
            CSICommon.pSetGROUPData(CSICommon.CON_G_TESTWEIGHT, null);
            // 妊娠集数
            CSICommon.pSetGROUPData(CSICommon.CON_G_TESTNOOFPREGNANCYMONTH, null);

            // 新規・変更時
            if (eiExamInfo.EventType.Equals(EVENT_TYPE_ADD) || eiExamInfo.EventType.Equals(EVENT_TYPE_MOD))
            {
                // 検査項目数分処理
                for (int i = 0; i < eiExamInfo.ExamItemList.Count; i++)
                {
                    //--------------------------------------------------------------------------------------------------
                    // 検査オーダ．オーダディテールコレクション設定
                    //--------------------------------------------------------------------------------------------------
                    this.SetOrderDetailCollection(eiExamInfo, i);
                    CSICommon.pSetCollection(4, CSICommon.varDETAIL);
                }
            }
            // ※削除時は検査項目が無いため、空のコレクションを設定
            CSICommon.pSetGROUPData(CSICommon.CON_G_TESTDETAILCOLLECTION, (VBA.Collection)CSICommon.colDETAIL);
        }

        /// <summary>
        /// 検査オーダ．オーダディテールコレクションを設定します
        /// </summary>
        /// <param name="eiExamInfo">検査予定情報</param>
        /// <param name="examItemIndex">検査項目インデックス</param>
        private void SetOrderDetailCollection(ExamInfo eiExamInfo, int examItemIndex)
        {
            //--------------------------------------------------------------------------------------------------
            // オーダディテールコレクションの領域確保
            //--------------------------------------------------------------------------------------------------
            CSICommon.varDETAIL = new object[5];

            //--------------------------------------------------------------------------------------------------
            // オーダディテールコレクションの各値設定
            //--------------------------------------------------------------------------------------------------
            // 検査項目コード
            CSICommon.pSetDETAILData(CSICommon.CON_D_TESTITEMCODE, eiExamInfo.ExamItemList[examItemIndex]);
            // 2012/09/20 中村 緊急区分値の不具合対応（Redmine#1292） Chg Start
            // // 緊急区分（1：通常）
            // CSICommon.pSetDETAILData(CSICommon.CON_D_EMARGENCYLEVEL, "1");
            // 緊急区分（0：通常）
            CSICommon.pSetDETAILData(CSICommon.CON_D_EMARGENCYLEVEL, "0");
            // 2012/09/20 中村 緊急区分値の不具合対応（Redmine#1292） Chg End
            // 検査薬剤コレクション
            CSICommon.pSetDETAILData(CSICommon.CON_D_TESTMEDICINECOLLECTION, null);
            // 負荷/日内時間コレクション
            CSICommon.pSetDETAILData(CSICommon.CON_D_TESTTIMECOLLECTION, null);

            // 検査区分が透析前、透析後、またはその他で検査コメントを設定する場合
            if (eiExamInfo.IsSetExamComment)
            {
                // 検査コメントコレクション作成（検査のコメントとして検査区分を送る）
                this.SetExaminCommentCollection(eiExamInfo);
                CSICommon.colDETAILINFO = CSICommon.objVBACollection.CreateVBACollection();
                CSICommon.pSetCollection(5, CSICommon.varDETAILINFO);
                CSICommon.pSetDETAILData(CSICommon.CON_D_TESTCOMMENTCOLLECTION, (VBA.Collection)CSICommon.colDETAILINFO);
            }
            else
            {
                // 検査コメントコレクションなし
                CSICommon.pSetDETAILData(CSICommon.CON_D_TESTCOMMENTCOLLECTION, null);
            }
        }

        /// <summary>
        /// 検査オーダ．検査コメントコレクションを設定します
        /// </summary>
        /// <param name="eiExamInfo">検査予定情報</param>
        private void SetExaminCommentCollection(ExamInfo eiExamInfo)
        {
            //--------------------------------------------------------------------------------------------------
            // 検査コメントコレクションの領域確保
            //--------------------------------------------------------------------------------------------------
            CSICommon.varDETAILINFO = new object[4];

            //--------------------------------------------------------------------------------------------------
            // 検査コメントコレクションの各値設定
            //--------------------------------------------------------------------------------------------------
            // コメント種（1：汎用コメント）
            CSICommon.pSetDETAILINFOData(CSICommon.CON_D_TESTCOMMENTTYPE, "1");
            // 入力区分（A：マスタから設定）
            CSICommon.pSetDETAILINFOData(CSICommon.CON_D_TESTCOMMENTINPUTMETHOD, "A");
            // コメント項目コード
            CSICommon.pSetDETAILINFOData(CSICommon.CON_D_TESTCOMMENTCODE, eiExamInfo.MIRAIsExamDivisionCommentCode);
            // コメント名称
            CSICommon.pSetDETAILINFOData(CSICommon.CON_D_TESTCOMMENTNAME, eiExamInfo.MIRAIsExamDivisionName);
        }

        /// <summary>
        /// MIRAIsデータベース接続
        /// </summary>
        /// <param name="eiExamInfo">ログ出力に利用する検査予定情報</param>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode OpenMIRAIsDB(ExamInfo eiExamInfo)
        {
            // MIRAIsDB接続
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            //if (!CSICommonMethod.pDbOpen(this.objCSICOMMON, ref this.objMIRAIsDB, ref CSICommon.colERR))
            base.TraceOut("【検査予定送信】他部門I/F：CSICommonMethod.pDbOpen() Start");
            bool bResult = CSICommonMethod.pDbOpen(this.objCSICOMMON, ref this.objMIRAIsDB, ref CSICommon.colERR);
            base.TraceOut("【検査予定送信】他部門I/F：CSICommonMethod.pDbOpen() End");
            if (bResult == false)
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            {
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                //base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_DBOPEN, CSICommonMethod.GetLastErrorString());
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_DBOPEN,
                    string.Format("患者ID=\"{0}\", エラー内容=\"{1}\"", eiExamInfo.DispPatID, CSICommonMethod.GetLastErrorString()));
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

                // [アラーム通知]
                base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, eiExamInfo.DispPatID, eiExamInfo.PatName, string.Empty,
                               string.Format("{0}（{1}）", CSIReturnCode.ERR_EXAMINSCHE_SEND_DBOPEN.Message, CSICommonMethod.GetLastErrorString()));

                // [エラー]DB接続失敗
                return CSIReturnCode.Error;
            }
            else
            {
                base.DebugTraceOut(this.CreateDebugMessage("MIRAIs-DBに接続しました。"));

                // MIRAIsDB Open成功
                return CSIReturnCode.Success;
            }
        }

        /// <summary>
        /// MIRAIsデータベース切断
        /// </summary>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode CloseMIRAIsDB()
        {
            // MIRAIsDB切断
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            //if (!CSICommonMethod.pDbClose(this.objCSICOMMON, this.objMIRAIsDB, ref CSICommon.colERR))
            base.TraceOut("【検査予定送信】他部門I/F：CSICommonMethod.pDbClose() Start");
            bool bResult = CSICommonMethod.pDbClose(this.objCSICOMMON, this.objMIRAIsDB, ref CSICommon.colERR);
            base.TraceOut("【検査予定送信】他部門I/F：CSICommonMethod.pDbClose() End");
            if (bResult == false)
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            {
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_DBCLOSE, CSICommonMethod.GetLastErrorString());

                // [エラー]DB切断失敗
                return CSIReturnCode.Error;
            }
            else
            {
                base.DebugTraceOut(this.CreateDebugMessage("MIRAIs-DBを切断しました。"));

                // MIRAIsDB Close成功
                return CSIReturnCode.Success;
            }
        }

        /// <summary>
        /// トランザクション開始
        /// </summary>
        /// <param name="eiExamInfo">ログ出力に利用する検査予定情報</param>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode StartTransaction(ExamInfo eiExamInfo)
        { 
            // トランザクション開始
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            //if (!CSICommonMethod.pDbBeginTrn(this.objCSICOMMON, this.objMIRAIsDB, ref CSICommon.colERR))
            base.TraceOut("【検査予定送信】他部門I/F：CSICommonMethod.pDbBeginTrn() Start");
            bool bResult = CSICommonMethod.pDbBeginTrn(this.objCSICOMMON, this.objMIRAIsDB, ref CSICommon.colERR);
            base.TraceOut("【検査予定送信】他部門I/F：CSICommonMethod.pDbBeginTrn() End");
            if (bResult == false)
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            {
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                //base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_DBTRANSACTION, CSICommonMethod.GetLastErrorString());
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_DBTRANSACTION,
                    string.Format("患者ID=\"{0}\", エラー内容=\"{1}\"", eiExamInfo.DispPatID, CSICommonMethod.GetLastErrorString()));
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

                // [アラーム通知]
                base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, eiExamInfo.DispPatID, eiExamInfo.PatName, string.Empty,
                               string.Format("{0}（{1}）", CSIReturnCode.ERR_EXAMINSCHE_SEND_DBTRANSACTION.Message, CSICommonMethod.GetLastErrorString()));

                // [エラー]トランザクション開始失敗
                return CSIReturnCode.Error;
            }
            else
            {
                base.DebugTraceOut(this.CreateDebugMessage("MIRAIs-DBのトランザクションを開始しました。"));

                // トランザクション開始成功
                return CSIReturnCode.Success;
            }
        }

        /// <summary>
        /// コミット
        /// </summary>
        /// <param name="eiExamInfo">ログ出力に利用する検査予定情報</param>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode CommitTransaction(ExamInfo eiExamInfo)
        { 
            // コミット
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            //if (!CSICommonMethod.pDbCommitTrn(this.objCSICOMMON, this.objMIRAIsDB, ref CSICommon.colERR))
            base.TraceOut("【検査予定送信】他部門I/F：CSICommonMethod.pDbCommitTrn() Start");
            bool bResult = CSICommonMethod.pDbCommitTrn(this.objCSICOMMON, this.objMIRAIsDB, ref CSICommon.colERR);
            base.TraceOut("【検査予定送信】他部門I/F：CSICommonMethod.pDbCommitTrn() End");
            if (bResult == false)
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            {
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                //base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_DBCOMMIT, CSICommonMethod.GetLastErrorString());
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_DBCOMMIT,
                    string.Format("患者ID=\"{0}\", エラー内容=\"{1}\"", eiExamInfo.DispPatID, CSICommonMethod.GetLastErrorString()));
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

                // [アラーム通知]
                base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, eiExamInfo.DispPatID, eiExamInfo.PatName, string.Empty,
                               string.Format("{0}（{1}）", CSIReturnCode.ERR_EXAMINSCHE_SEND_DBCOMMIT.Message, CSICommonMethod.GetLastErrorString()));

                // [エラー]コミット失敗
                return CSIReturnCode.Error;
            }
            else
            {
                base.DebugTraceOut(this.CreateDebugMessage("MIRAIs-DBのトランザクションをコミットしました。"));

                // コミット成功
                return CSIReturnCode.Success;
            }
        }

        /// <summary>
        /// ロールバック
        /// </summary>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode RollbackTransaction()
        { 
            // ロールバック
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            //if (!CSICommonMethod.pDbRollBack(this.objCSICOMMON, this.objMIRAIsDB, ref CSICommon.colERR))
            base.TraceOut("【検査予定送信】他部門I/F：CSICommonMethod.pDbRollBack() Start");
            bool bResult = CSICommonMethod.pDbRollBack(this.objCSICOMMON, this.objMIRAIsDB, ref CSICommon.colERR);
            base.TraceOut("【検査予定送信】他部門I/F：CSICommonMethod.pDbRollBack() End");
            if (bResult == false)
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            {
                base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_SEND_DBROLLBACK, CSICommonMethod.GetLastErrorString());

                // [エラー]ロールバック失敗
                return CSIReturnCode.Error;
            }
            else
            {
                base.DebugTraceOut(this.CreateDebugMessage("MIRAIs-DBのトランザクションをロールバックしました。"));

                // ロールバック成功
                return CSIReturnCode.Success;
            }
        }

        /// <summary>
        /// デバックメッセージ生成
        /// <para>【検査予定送信】【デバック】：メインメッセージ の形式でメッセージ生成</para>
        /// </summary>
        /// <param name="strMainMessage">～しました。などの主文</param>
        /// <returns>デバックメッセージ</returns>
        private string CreateDebugMessage(string strMainMessage)
        {
            return CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_DBG + strMainMessage;
        }

        /// <summary>
        /// デバックメッセージ生成
        /// <para>【検査予定送信】【デバック】：メインメッセージ (補足情報) の形式でメッセージ生成</para>
        /// </summary>
        /// <param name="strMainMessage">～しました。などの主文</param>
        /// <param name="strSubInfo">主文に対する補足情報(不正な設定値、値など)</param>
        /// <returns>デバックメッセージ</returns>
        private string CreateDebugMessage(string strMainMessage, string strSubInfo)
        {
            return CSICommonConst.MODULE_MNAME_ESS + CSICommonConst.LOGTYPE_DBG + strMainMessage + "(" + strSubInfo + ")";
        }

        // 2011/05/23 中村 指示医対応
        /// <summary>
        /// 検査予約.指示者取得処理
        /// </summary>
        /// <param name="xmlCoopInfo">連携情報</param>
        /// <returns>版確定者コード</returns>
        private string getDeciderCd(XmlNode xmlCoopInfo)
        {
            string strStaffCd = string.Empty;
            string strLabel = string.Empty;

            // 指示者取得
            XmlNode xmlIndicator = xmlCoopInfo.SelectSingleNode("//rootNode/PAT_EXAMIN_SCHEDULE/DOCTOR_CODE");
            if (xmlIndicator == null || string.IsNullOrEmpty(xmlIndicator.InnerText))
            {
                //	取得失敗
                this.TraceOut(CSIReturnCode.WNG_EXAMINSCHE_SND_INDICATOR, "透析予定.指示者");

                return strStaffCd;
            }

            // 職種コード取得
            string strIndicator = xmlIndicator.InnerText.Trim();
            XmlNode xmlJobClass = xmlCoopInfo.SelectSingleNode(string.Format("//rootNode/PAT_EXAMIN_SCHEDULE/MST_STAFF[STAFF_CD='{0}']/JOB_CLASS_CD", strIndicator));
            if (xmlJobClass == null || string.IsNullOrEmpty(xmlJobClass.InnerText))
            {
                //	取得失敗
                this.TraceOut(CSIReturnCode.WNG_EXAMINSCHE_SND_INDICATOR, "スタッフマスタ.職種コード");

                return strStaffCd;
            }
            if (!xmlJobClass.InnerText.Equals("1"))
            {
                return strStaffCd;
            }

            string strOutXml = "";
            Fn3ReturnCode fn3Ret = this.DBExecQuery(ORG_QUERY_ID_GET_ACL, string.Format("<rootNode><VALUE>{0}</VALUE></rootNode>", strIndicator), ref strOutXml);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                //	取得失敗
                this.TraceOut(fn3Ret, "スタッフ権限取得用個別クエリが失敗しました。");

                return strStaffCd;
            }

            XmlDocument doc = new XmlDocument();
            try
            {
                doc.LoadXml(strOutXml);
            }
            catch (Exception ex)
            {
                base.ErrorTraceOut(CSIReturnCode.FTL_EXAMINSCHE_SND_INDICATOR, ex);
                return strStaffCd;
            }

            XmlNode xmlAcl = doc.SelectSingleNode("//rootNode/SYS_STAFF_AUTH/ACL");
            if (xmlAcl == null || string.IsNullOrEmpty(xmlAcl.InnerText))
            {
                //	取得失敗
                this.TraceOut(CSIReturnCode.WNG_EXAMINSCHE_SND_INDICATOR, "スタッフ権限.ACL区分");

                return strStaffCd;
            }

            int intAcl;
            if (!int.TryParse(xmlAcl.InnerText, out intAcl))
            {
                //	取得失敗
                this.TraceOut(CSIReturnCode.WNG_EXAMINSCHE_SND_INDICATOR, "スタッフ権限.ACL区分");

                return strStaffCd;
            }
            if (intAcl >= 3)
            {
                strStaffCd = strIndicator;
            }

            return strStaffCd;
        }


        // 2016/04/13 中村 ポップアップ通知対応 Add Start
        #region
        /// <summary>
        /// ポップアップ通知情報登録
        /// </summary>
        private void RegistPopupNotice(Fn3ExecuteInfo exeInfo, ExamInfo eiExamInfo, bool IsSuccess)
        {
            try
            {
                if ("0" == m_strPopupNotice)
                {
                    // 通知しない設定の場合は何もせずに終了
                    return;
                }

                // 表示用患者ID
                string strDispPatId = string.Empty;
                if (string.IsNullOrEmpty(eiExamInfo.DispPatID))
                {
                    // 患者未指定の場合は何もせずに終了
                    return;
                }
                strDispPatId = eiExamInfo.DispPatID.PadLeft(12, '0');

                // 患者名チェック
                string strPatName = "-";
                if (!string.IsNullOrEmpty(eiExamInfo.PatName))
                {
                    strPatName = eiExamInfo.PatName;
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
                string strExamDate = string.Empty;
                DateTime dtExamDate;
                string[] strBuf = exeInfo.SendHistMemo.Split(',');
                if (strBuf.Length >= 3 && !string.IsNullOrEmpty(strBuf[2]))
                {
                    // 送信メモ.透析日時より取得
                    if (DateTime.TryParseExact(strBuf[2], "yyyyMMddHHmm", null, 0, out dtExamDate))
                    {
                        strExamDate = dtExamDate.ToString("yyyy/MM/dd HH:mm");
                    }
                }
                else if (exeInfo.SendClass.Equals("0"))
                {
                    // 検査予定より取得
                    Fn3ReturnCode retCodeExamDate = base.GetExamScheDateTime(exeInfo, out dtExamDate);
                    if (retCodeExamDate.IsSuccess)
                    {
                        strExamDate = dtExamDate.ToString("yyyy/MM/dd HH:mm");
                    }
                }

                // 検査日が取得できていない場合
                if (string.IsNullOrEmpty(strExamDate) && exeInfo.SpecificKey.Length >= 20)
                {
                    // 特定キーより検査日のみ取得(時間なし)
                    if (DateTime.TryParseExact(exeInfo.SpecificKey.Substring(12, 8), "yyyyMMdd", null, 0, out dtExamDate))
                    {
                        strExamDate = dtExamDate.ToString("yyyy/MM/dd");
                    }
                }

                // メッセージ作成
                string strPopUpMsg = string.Empty;
                string strEventCd = string.Empty;
                if (IsSuccess)
                {
                    // 成功メッセージ作成
                    strPopUpMsg = string.Format("検査オーダ({0})の送信に成功しました。\n　患者ID：[{1}]\n　患者名：[{2}]\n　検査日：[{3}]",
                                  strSendClass, strDispPatId, strPatName, strExamDate);
                    strEventCd = "4600000001";
                }
                else
                {
                    // 失敗メッセージ作成
                    strPopUpMsg = string.Format("検査オーダ({0})の送信に失敗しました。\n　患者ID：[{1}]\n　患者名：[{2}]\n　検査日：[{3}]",
                                  strSendClass, strDispPatId, strPatName, strExamDate);
                    strEventCd = "4600000002";
                }

                // 連携イベントログテーブル存在チェック
                string strSQL = @"<rootNode></rootNode>";
                string strOutXml = string.Empty;
                Fn3ReturnCode retCode = base.DBExecQuery("10002", strSQL, ref strOutXml);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_REGIST_POPUP);
                    return;
                }
                XmlDocument doc = new XmlDocument();
                doc.LoadXml(strOutXml);
                XmlNode xmlNode = doc.SelectSingleNode("//rootNode/USER_TABLES/TABLE_NAME");
                if (null == xmlNode || !xmlNode.InnerText.Equals("IF_EVENT_LOG"))
                {
                    // テーブルがないので処理終了
                    TraceOut(CSIReturnCode.ERR_EXAMINSCHE_NOT_EXIST_IF_EVENT_LOG);
                    return;
                }

                // 連携イベントログテーブル登録SQL
                strSQL = string.Format(@"<rootNode><EVENT_CLASS>{0}</EVENT_CLASS><DISP_PATID>{1}</DISP_PATID><NAME>{2}</NAME><EVENT_CD>{3}</EVENT_CD><EVENT_DETAIL>{4}</EVENT_DETAIL></rootNode>",
                                                    "検査オーダ送信", strDispPatId, strPatName, strEventCd, strPopUpMsg);
                // SQL実行
                strOutXml = string.Empty;
                retCode = base.DBExecQuery("10001", strSQL, ref strOutXml);
                if (retCode.IsError || retCode.IsException)
                {
                    // トレースログのみ出力
                    base.TraceOut(CSIReturnCode.ERR_EXAMINSCHE_REGIST_POPUP);
                }
            }
            catch (Exception ex)
            {
                base.ErrorTraceOut(CSIReturnCode.ERR_EXAMINSCHE_REGIST_POPUP, ex);
            }
        }
        #endregion
        // 2016/04/13 中村 ポップアップ通知対応 Add End

        #endregion
    }
}
