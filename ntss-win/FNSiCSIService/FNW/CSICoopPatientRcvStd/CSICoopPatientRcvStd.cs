//////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：患者情報連携
// ファイル名：CSICoopPatientRcvStd.cs
// 説明      ：患者取込依頼イベントを受けて、MIRAIsより対象患者の情報を取得して
//             FNWDBへ登録、更新を行う。
//             また、登録、更新に関わらず、MIRAIsへ患者識別情報の登録を行う。
//
//	Copyright(C) 2009 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2009/11/18	飛田隆太			新規作成
//  2015/07/30  石川俊介            ログ強化
//
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Xml;
using System.Text;
using System.Threading;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using jp.co.nikkiso.fn3.Cooperation;
using jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn;
using jp.co.nikkiso.fn3.Cooperation.CSICoop;

namespace CSICoopPatientRcvStd
{
    public class CSICoopPatientRcvStd : Fn3ComPlugIn
    {
        #region メンバ定義
        /// <summary>
        /// 実行中フラグ
        /// </summary>
        private bool isExecuting = false;

        /// <summary>
        /// 患者ID桁数
        /// </summary>
        private Int32 PatIDLength = 0;

        /// <summary>
        /// 外部I/F部品JMS版使用フラグ
        /// </summary>
        private String UseJMSFlag = "";

        /// <summary>
        /// シーエスアイ外部I/F部品 共通オブジェクト
        /// </summary>
        private object objCSICOMMON = null;

        /// <summary>
        /// シーエスアイ外部I/F部品 患者属性検索オブジェクト
        /// </summary>
        private object objCSIPATSCH = null;

        /// <summary>
        /// シーエスアイ外部I/F部品 血液型検索オブジェクト
        /// </summary>
        private object objCSIBLOODTYPE = null;

        /// <summary>
        /// シーエスアイ外部I/F部品 感染症検索オブジェクト
        /// </summary>
        private object objCSIINFECTION = null;

        /// <summary>
        /// シーエスアイ外部I/F部品 患者在院情報検索オブジェクト
        /// </summary>
        private object objCSIADMSCH = null;

        /// <summary>
        /// シーエスアイ外部I/F部品 患者識別情報出力オブジェクト
        /// </summary>
        private object objCSIDIALYSIS = null;

        /// <summary>
        /// MIRAIs-DBオブジェクト
        /// </summary>
        private object objMIRAIsDB = null;

        /// <summary>
        /// 患者連絡先コレクション用キー定義
        /// 有効フラグ
        /// 続柄
        /// 住所
        /// 郵便番号
        /// 電話番号
        /// </summary>
        private const String KEY_ENABLED = "ENABLED";
        private const String KEY_CTL_NO = "CTL_NO";
        private const String KEY_DISP_NO = "DISP_NO";
        private const String KEY_RELATION = "RELATION";
        private const String KEY_PAT_ADDRESS = "ADDRESS";
        private const String KEY_PAT_ZIPCODE = "ZIPCODE";
        private const String KEY_PAT_TELNO = "TELNO";

        /// <summary>
        /// FNWコード
        /// 不明
        /// 外来
        /// </summary>
        private const String FNW_CODE_UNKNOWN = "-";
        private const String FNW_CODE_OUT = "0";

        /// <summary>
        /// ダンプデータタイトル
        /// </summary>
        private const String DUMP_PATSCH = "患者属性検索";
        private const String DUMP_BLOODTYPE = "患者血液型検索";
        private const String DUMP_INFECTION = "患者感染症検索";
        private const String DUMP_ADMSCH = "患者在院情報検索";
        private const String DUMP_DIALYSIS = "患者識別情報出力";
        #endregion

        #region プロパティ
        private String _DispPatID = "";
        /// <summary>
        /// 表示用患者ID
        /// </summary>
        private String DispPatID
        {
            get { return this._DispPatID; }
            set { this._DispPatID = value; }
        }

        private String _PatID = "";
        /// <summary>
        /// 患者ID
        /// </summary>
        private String PatID
        {
            get { return this._PatID; }
            set { this._PatID = value; }
        }

        private String _PatName = "";
        /// <summary>
        /// 患者名
        /// </summary>
        private String PatName
        {
            get { return this._PatName; }
            set { this._PatName = value; }
        }
        #endregion

        #region メソッド
        /// <summary>
        /// 初期化処理
        /// </summary>
        /// <returns>成功/失敗</returns>
        protected override Fn3ReturnCode Initialize()
        {
            // メソッド開始ログ
            base.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // 設定値取得(外部I/F部品使用設定、患者ID桁数)
            Fn3ReturnCode retCode = this.GetIniSetting();
            if (retCode.IsError)
            {
                // [トレースログ]設定値取得失敗
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_INITIALIZE);

                // [エラー]初期化失敗
                return CSIReturnCode.ERR_PATIENT_RCV_INITIALIZE;
            }

            // メソッド終了ログ
            base.MethodEndLogOut(MethodBase.GetCurrentMethod());

            // 初期化成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// 開始処理
        /// 初期設定取得、MIRAIs提供部品の取得等を実施
        /// </summary>
        /// <returns>成功/失敗</returns>
        protected override Fn3ReturnCode Start()
        {
            // メソッド開始ログ
            base.MethodStartLogOut(MethodBase.GetCurrentMethod());

            try
            {
                // シーエスアイ外部I/F部品インスタンス生成
                Fn3ReturnCode retCodeGetInstance = this.CreateInterfaceInstance();
                if (retCodeGetInstance.IsError)
                {
                    // [トレースログ]初期化失敗
                    base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_INITIALIZE);

                    // [エラー]初期化失敗
                    return CSIReturnCode.ERR_PATIENT_RCV_INITIALIZE;
                }
                else
                {
                    // [トレースログ]
                    base.DebugTraceOut(this.CreateTraceMessage("開始処理に成功しました。"));

                    // 初期化成功
                    return CSIReturnCode.Success;
                }
            }
            catch (Exception ex)
            {
                // [トレースログ]初期化失敗
                base.ErrorTraceOut(CSIReturnCode.FTL_PATIENT_RCV_INITIALIZE, ex);

                // [エラー]初期化失敗
                return CSIReturnCode.ERR_PATIENT_RCV_INITIALIZE;
            }
            finally
            {
                // メソッド終了ログ
                base.MethodEndLogOut(MethodBase.GetCurrentMethod());
            }
        }

        /// <summary>
        /// 停止処理
        /// 取込実行中の場合、処理終了まで待つ
        /// </summary>
        protected override void Stop()
        {
            // メソッド開始ログ
            base.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // 実行中フラグにて判定
            while (this.isExecuting)
            {
                // 500msecスリープして定期更新処理停止を待つ
                Thread.Sleep(500);

                // [トレースログ]停止待ち
                base.DebugTraceOut(this.CreateTraceMessage("患者情報取り込み処理を停止中です。"));
            }

            // [トレースログ]定期更新イベント発行停止完了
            base.DebugTraceOut(this.CreateTraceMessage("患者情報取り込み処理を停止しました。"));

            // メソッド終了ログ
            base.MethodEndLogOut(MethodBase.GetCurrentMethod());
        }

        /// <summary>
        /// 患者情報取得処理
        /// MIRAIsより指定患者の情報を取得し、登録、更新する
        /// 新規登録、更新に関わらず、MIRAIsに対し患者識別情報を登録する
        /// </summary>
        /// <param name="exeInfo">各種処理データ</param>
        /// <returns>成功/失敗</returns>
        protected override Fn3ReturnCode Execute(Fn3ExecuteInfo exeInfo)
        {
            // メソッド開始ログ
            base.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // 実行中フラグON
            this.isExecuting = true;

            try
            {
                // 患者情報取得(患者ID、表示用患者ID、患者名)
                this.GetPatientInfoFromExeInfo(exeInfo);

                // 入力、出力パラメタ全クリア
                CSICommon.ClearAllParameter();

                // MIRAIsDB接続
                Fn3ReturnCode retCodeDBOpen = this.OpenMIRAIsDB();
                if (retCodeDBOpen.IsError)
                {
                    // [トレースログ]DB接続失敗
                    // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                    //base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_IMPORTPATIENT);
                    base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_IMPORTPATIENT, string.Format("患者ID=\"{0}\"", this.DispPatID));
                    // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

                    // [エラー]患者取り込み失敗
                    // ※FNWクライアント画面表示用メッセージをエラーとして返す
                    return CSIReturnCode.MSG_PATIENT_RCV_IMPORTPATIENT;
                }
                
                // 患者取込み処理実施(毎回識別情報登録)
                Fn3ReturnCode retCodeImportPatient = this.ImportPatientInfo(exeInfo, this.DispPatID, true);
                if (retCodeImportPatient.IsError)
                {
                    // [トレースログ]患者取込み失敗
                    base.TraceOut(retCodeImportPatient);

                    // 患者が電子カルテに存在しなかった場合
                    if (retCodeImportPatient.Equals(CSIReturnCode.ERR_PATIENT_RCV_NOTEXISTSPATIENT))
                    {
                        // [エラー]電子カルテに患者不在
                        // ※FNWクライアント画面表示用メッセージをエラーとして返す
                        return CSIReturnCode.MSG_PATIENT_RCV_NOTEXISTSPATIENT;
                    }
                    // それ以外のエラーの場合
                    else
                    {
                        // [エラー]患者取り込み失敗
                        // ※FNWクライアント画面表示用メッセージをエラーとして返す
                        return CSIReturnCode.MSG_PATIENT_RCV_IMPORTPATIENT;
                    }
                }
                else
                {
                    // [トレースログ]患者取込み成功
                    base.DebugTraceOut(this.CreateTraceMessage(CSICommonConst.DEBUGTRACE_PRE_SUCCESS_MSG + "患者取込みに成功しました。", String.Format("患者ID：{0} 表示用患者ID：{1}", this.PatID, this.DispPatID)));
                }

                // 受信処理成功
                return CSIReturnCode.Success;
            }
            catch (Exception ex)
            {
                // [トレースログ]例外発生
                base.ErrorTraceOut(CSIReturnCode.FTL_PATIENT_RCV_IMPORTPATIENT, ex);

                // [エラー]患者取り込み失敗
                // ※FNWクライアント画面表示用メッセージをエラーとして返す
                return CSIReturnCode.MSG_PATIENT_RCV_IMPORTPATIENT;
            }
            finally
            {
                try
                {
                    // MIRAIsDB切断
                    this.CloseMIRAIsDB();
                }
                catch (Exception ex)
                {
                    // [トレースログ]例外発生
                    base.ErrorTraceOut(CSIReturnCode.FTL_PATIENT_RCV_IMPORTPATIENT, ex);
                }

                // 実行中フラグOFF
                this.isExecuting = false;

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
            // 初期設定から外部I/F部品設定を取得
            Fn3ReturnCode retCodePartsSelecter = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                      CSICommonConst.SYS_SECT_COMMON,
                                                                      CSICommonConst.SYS_KEY_LIBRARY_TYPE,
                                                                      ref this.UseJMSFlag);
            if (retCodePartsSelecter.IsError || retCodePartsSelecter.IsException || this.UseJMSFlag.Equals(""))
            {
                // [トレースログ]外部I/F部品設定取得失敗
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_GETINITIALVALUE, 
                              string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_LIBRARY_TYPE, this.UseJMSFlag));

                // [エラー]外部I/F部品設定取得失敗
                return CSIReturnCode.Error;
            }

            // 初期設定から患者ID桁数を取得
            String strPatIDLength = "";
            Fn3ReturnCode retCodePatIDLength = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                                    CSICommonConst.SYS_SECT_COMMON,
                                                                    CSICommonConst.SYS_KEY_SEND_PATID_FIGURES,
                                                                    ref strPatIDLength);
            if (retCodePatIDLength.IsError || retCodePatIDLength.IsException || strPatIDLength.Equals(""))
            {
                // [トレースログ]患者ID桁数設定取得失敗
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_GETINITIALVALUE, 
                              string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_SEND_PATID_FIGURES, strPatIDLength));

                // [エラー]患者ID桁数設定取得失敗
                return CSIReturnCode.Error;
            }
            // 取得値を保持
            this.PatIDLength = System.Convert.ToInt32(strPatIDLength);
            
            // 設定値取得成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// シーエスアイ外部I/F部品 インスタンス生成
        /// 患者情報連携に必要な、各I/F部品のインスタンスを生成
        /// </summary>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode CreateInterfaceInstance()
        {
            // シーエスアイ外部I/F部品のオブジェクト作成
            //-- 共通
            this.objCSICOMMON = this.CreateObjectRap(CSICommonMethod.GetLibName(CSICommonConst.CSIPROGRAMID_COMMON, this.UseJMSFlag));
            if (this.objCSICOMMON == null)
            {
                // [トレースログ]共通部品生成失敗
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                //base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CREATECOMMON);
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CREATECOMMON, string.Format("LibName=\"{0}\"", CSICommonConst.CSIPROGRAMID_COMMON));
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

                // [エラー]共通部品生成失敗
                return CSIReturnCode.ERR_PATIENT_RCV_CREATECOMMON;
            }

            //-- 患者属性検索
            this.objCSIPATSCH = this.CreateObjectRap(CSICommonMethod.GetLibName(CSICommonConst.CSIPROGRAMID_PATSCH, this.UseJMSFlag));
            if (this.objCSIPATSCH == null)
            {
                // [トレースログ]患者属性検索生成失敗
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                //base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CREATEPATSCH);
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CREATEPATSCH, string.Format("LibName=\"{0}\"", CSICommonConst.CSIPROGRAMID_PATSCH));
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

                // [エラー]患者属性検索生成失敗
                return CSIReturnCode.ERR_PATIENT_RCV_CREATEPATSCH;
            }

            //-- 患者血液型検索
            this.objCSIBLOODTYPE = this.CreateObjectRap(CSICommonMethod.GetLibName(CSICommonConst.CSIPROGRAMID_BLOODTYPE, this.UseJMSFlag));
            if (this.objCSIBLOODTYPE == null)
            {
                // [トレースログ]患者血液型検索生成失敗
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                //base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CREATEBLOODTYPE);
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CREATEBLOODTYPE, string.Format("LibName=\"{0}\"", CSICommonConst.CSIPROGRAMID_BLOODTYPE));
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

                // [エラー]患者血液型検索生成失敗
                return CSIReturnCode.ERR_PATIENT_RCV_CREATEBLOODTYPE;
            }

            //-- 患者感染症検索
            this.objCSIINFECTION = this.CreateObjectRap(CSICommonMethod.GetLibName(CSICommonConst.CSIPROGRAMID_INFECTION, this.UseJMSFlag));
            if (this.objCSIINFECTION == null)
            {
                // [トレースログ]患者感染症検索生成失敗
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                //base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CREATEINFECTION);
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CREATEINFECTION, string.Format("LibName=\"{0}\"", CSICommonConst.CSIPROGRAMID_INFECTION));
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

                // [エラー]患者感染症検索生成失敗
                return CSIReturnCode.ERR_PATIENT_RCV_CREATEINFECTION;
            }

            //-- 患者在院情報検索
            this.objCSIADMSCH = this.CreateObjectRap(CSICommonMethod.GetLibName(CSICommonConst.CSIPROGRAMID_ADMSCH, this.UseJMSFlag));
            if (this.objCSIADMSCH == null)
            {
                // [トレースログ]患者在院情報検索生成失敗
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                //base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CREATEADMSCH);
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CREATEADMSCH, string.Format("LibName=\"{0}\"", CSICommonConst.CSIPROGRAMID_ADMSCH));
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

                // [エラー]患者在院情報検索生成失敗
                return CSIReturnCode.ERR_PATIENT_RCV_CREATEADMSCH;
            }

            //-- 患者識別情報出力
            this.objCSIDIALYSIS = this.CreateObjectRap(CSICommonMethod.GetLibName(CSICommonConst.CSIPROGRAMID_DIALYSIS, this.UseJMSFlag));
            if (this.objCSIDIALYSIS == null)
            {
                // [トレースログ]患者識別情報出力生成失敗
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                //base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CREATEDIALYSIS);
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CREATEDIALYSIS, string.Format("LibName=\"{0}\"", CSICommonConst.CSIPROGRAMID_DIALYSIS));
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

                // [エラー]患者識別情報出力生成失敗
                return CSIReturnCode.ERR_PATIENT_RCV_CREATEDIALYSIS;
            }

            // シーエスアイ外部I/F部品 インスタンス生成成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// インスタンスを生成する
        /// </summary>
        /// <param name="strLibName">インスタンス名</param>
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
                base.ErrorTraceOut(CSIReturnCode.FTL_PATIENT_RCV_CREATEOBJ, ex);
                return null;
            }
        }

        /// <summary>
        /// 患者情報取得
        /// 連携情報から患者の表示用ID、内部用ID、名称を取得
        /// </summary>
        /// <param name="exeInfo">連携情報</param>
        private void GetPatientInfoFromExeInfo(Fn3ExecuteInfo exeInfo)
        {
            // 表示用患者ID取得(キー情報から取得)
            XmlDocument xmlKeyInfo = new XmlDocument();
            xmlKeyInfo.LoadXml(exeInfo.KeyInfo);
            this.DispPatID = "";
            this.DispPatID = CSICommonMethod.formatString("{0:D12}", xmlKeyInfo.InnerText);

            // 患者ID取得(連携情報から取得)
            this.PatID = "";
            XmlNode nodePatID = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/PATID");
            if (nodePatID != null)
            {
                this.PatID = nodePatID.InnerText;
            }

            // 患者名取得(連携情報から取得)
            this.PatName = "";
            XmlNode nodePatName = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/NAME");
            if (nodePatName != null)
            {
                this.PatName = nodePatName.InnerText;
            }
        }

        /// <summary>
        /// MIRAIsデータベース接続
        /// </summary>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode OpenMIRAIsDB()
        {
            // MIRAIsDB接続
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            //if (!CSICommonMethod.pDbOpen(this.objCSICOMMON, ref this.objMIRAIsDB, ref CSICommon.colERR))
            base.TraceOut("【患者情報受信】他部門I/F：CSICommonMethod.pDbOpen() Start");
            bool bResult = CSICommonMethod.pDbOpen(this.objCSICOMMON, ref this.objMIRAIsDB, ref CSICommon.colERR);
            base.TraceOut("【患者情報受信】他部門I/F：CSICommonMethod.pDbOpen() End");
            if (bResult == false)
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            {
                // [トレースログ]DB接続エラー
                // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                //base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_DBOPEN, CSICommonMethod.GetLastErrorString());
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_DBOPEN, 
                    string.Format("患者ID=\"{0}\", エラー内容=\"{1}\"",this.DispPatID,CSICommonMethod.GetLastErrorString()));
                // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

                // [アラーム通知]
                base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, this.DispPatID, this.PatName, "",
                               string.Format("{0}（{1}）", CSIReturnCode.ERR_PATIENT_RCV_DBOPEN.Message, CSICommonMethod.GetLastErrorString()));

                // [エラー]DB接続失敗
                return CSIReturnCode.ERR_PATIENT_RCV_DBOPEN;
            }
            else
            {
                // [トレースログ]MIRAIsDB Open成功
                base.DebugTraceOut(this.CreateTraceMessage("MIRAIs-DBに接続しました。"));

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
            base.TraceOut("【患者情報受信】他部門I/F：CSICommonMethod.pDbClose() Start");
            bool bResult = CSICommonMethod.pDbClose(this.objCSICOMMON, this.objMIRAIsDB, ref CSICommon.colERR);
            base.TraceOut("【患者情報受信】他部門I/F：CSICommonMethod.pDbClose() End");
            if (bResult == false)
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            {
                // [トレースログ]DB切断エラー
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_DBCLOSE, CSICommonMethod.GetLastErrorString());                

                // [エラー]DB切断失敗
                return CSIReturnCode.ERR_PATIENT_RCV_DBCLOSE;
            }
            else
            {
                // [トレースログ]MIRAIsDB Close成功
                base.DebugTraceOut(this.CreateTraceMessage("MIRAIs-DBを切断しました。"));

                // MIRAIsDB Close成功
                return CSIReturnCode.Success;
            }
        }

        /// <summary>
        /// 新患チェック
        /// 患者基本情報に表示用患者IDが一致するレコードが有る/無いにて判定
        /// </summary>
        /// <param name="strDispPatID">表示用患者ID</param>
        /// <param name="isNewPatient">チェック結果 True:新規/False:既登録</param>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode CheckNewPatient(String strDispPatID, ref bool isNewPatient)
        {
            // 入力XML生成
            StringBuilder sbInXml = new StringBuilder();
            XmlWriterSettings xmwSetting = new XmlWriterSettings();
            xmwSetting.OmitXmlDeclaration = true;
            XmlWriter xwInXmlWriter = XmlWriter.Create(sbInXml, xmwSetting);
            xwInXmlWriter.WriteStartElement("rootNode");
            xwInXmlWriter.WriteStartElement("PAT_BASIC_INFO");
            xwInXmlWriter.WriteElementString("DISP_PATID", strDispPatID);
            xwInXmlWriter.WriteEndElement();
            xwInXmlWriter.WriteEndElement();
            xwInXmlWriter.Flush();
            xwInXmlWriter.Close();

            // 患者取得実施
            String strResultXml = "";
            Fn3ReturnCode retCodeGetPatient = base.DBSelect(sbInXml.ToString(), ref strResultXml);
            if (retCodeGetPatient.IsError || retCodeGetPatient.IsException)
            {
                // [トレースログ]患者取得失敗
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_NEWPATIENT, retCodeGetPatient.Message);

                // [エラー]新患チェック失敗
                return CSIReturnCode.ERR_PATIENT_RCV_NEWPATIENT;
            }

            // 患者情報の取得結果により判定
            XmlDocument xmlPatInfo = new XmlDocument();
            xmlPatInfo.LoadXml(strResultXml);
            isNewPatient = xmlPatInfo.InnerText.Equals("") ? true : false;

            // 新患チェック成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// 患者情報取込み処理
        /// 指定患者IDの情報をMIRAIsより取得し、FNWDBへ登録、更新を行う
        /// また、新規患者の場合は、MIRAIsに対し、患者識別情報を登録する
        /// </summary>
        /// <param name="exeInfo">各種処理データ</param>
        /// <param name="strDispPatID">表示用患者ID</param>
        /// <param name="isRegistDIAFLG">患者識別情報登録フラグ</param>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode ImportPatientInfo(Fn3ExecuteInfo exeInfo, String strDispPatID, bool isRegistDIAFLG)
        {
            // FNW側DBのトランザクション開始
            Fn3ReturnCode retCodeTran = base.DBTransaction();
            if (retCodeTran.IsError || retCodeTran.IsException)
            {
                // [トレースログ]トランザクション開始失敗
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_TRANSACTION);
                base.TraceOut(retCodeTran);

                // [エラー]トランザクション開始失敗
                return retCodeTran;
            }

            // ダンプ容器生成
            List<DumpParameter> lstDumpDatas = new List<DumpParameter>();
            lstDumpDatas.Add(new DumpParameter(DUMP_PATSCH, null, null, null, null));
            lstDumpDatas.Add(new DumpParameter(DUMP_BLOODTYPE, null, null, null, null));
            lstDumpDatas.Add(new DumpParameter(DUMP_INFECTION, null, null, null, null));
            lstDumpDatas.Add(new DumpParameter(DUMP_ADMSCH, null, null, null, null));

            bool isSuccess = false;
            Fn3ReturnCode retCodeGetPatientInfo;
            try
            {
                // MIRAIsより対象患者の各種情報取得
                retCodeGetPatientInfo = this.GetPatientInfoFromMIRAIs(strDispPatID, lstDumpDatas);
                if (retCodeGetPatientInfo.IsSuccess)
                {
                    // 取得した各種情報をFNWへ登録
                    Fn3ReturnCode retCodeSetPatientInfo = this.SetPatientInfoToFNW(exeInfo, strDispPatID);
                    if (retCodeSetPatientInfo.IsSuccess)
                    {
                        // 登録フラグがオンの場合
                        if (isRegistDIAFLG)
                        {
                            // MIRAIsへ患者識別情報を登録
                            lstDumpDatas.Add(new DumpParameter(DUMP_DIALYSIS, null, null, null, null));
                            Fn3ReturnCode retCodeSetDiscernmentInfo = this.SetDiscernmentInfoToMIRAIs(strDispPatID, lstDumpDatas);
                            if (retCodeSetDiscernmentInfo.IsSuccess)
                            {
                                // [正常]患者識別情報登録成功
                                isSuccess = true;
                            }
                        }
                        // オフの場合
                        else
                        {
                            // [正常]患者取込み成功
                            isSuccess = true;
                        }
                    }
                }
            }
            finally
            {
                // 処理が成功した場合
                if (isSuccess)
                {
                    // コミット実施
                    Fn3ReturnCode retCodeCommit = base.DBCommit();
                    if (retCodeCommit.IsError || retCodeCommit.IsException)
                    {
                        // [トレースログ]コミット失敗
                        base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_COMMIT);
                        base.TraceOut(retCodeCommit);
                    }
                }
                // 失敗した場合
                else
                {
                    // ロールバック実施
                    Fn3ReturnCode retCodeRollback = base.DBRollback();
                    if (retCodeRollback.IsError || retCodeRollback.IsException)
                    {
                        // [トレースログ]ロールバック失敗
                        base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_ROLLBACK);
                        base.TraceOut(retCodeRollback);
                    }
                }
            }

            // [ダンプ出力]
            base.DumpOut(exeInfo.SpecificKey, CSICommonMethod.CreateDumpData(this.PatID, lstDumpDatas.ToArray()));

            if (isSuccess)
            {
                // 患者取込み成功
                return CSIReturnCode.Success;
            }
            else
            {
                // MIRAIsに患者が登録されていなかった場合
                if (retCodeGetPatientInfo.Equals(CSIReturnCode.ERR_PATIENT_RCV_NOTEXISTSPATIENT))
                {
                    // [エラー]対象患者未登録(汎用結果のメッセージに表示される)
                    return retCodeGetPatientInfo;
                }
                // 他のエラーの場合
                else
                {
                    // [エラー]患者取込み失敗
                    return CSIReturnCode.ERR_PATIENT_RCV_IMPORTPATIENT;
                }
            }
        }

        /// <summary>
        /// 患者情報取得
        /// MIRAIsDBより患者属性、血液型、感染症、在院情報を取得する
        /// ※取得した値は、CSICommonクラスの各取得値配列に格納される
        /// </summary>
        /// <param name="strDispPatID">表示用患者ID</param>
        /// <param name="lstDumpDatas">ダンプデータリスト</param>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode GetPatientInfoFromMIRAIs(String strDispPatID, List<DumpParameter> lstDumpDatas)
        {
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            bool bResult = true;
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化

            // 患者IDを指定桁数へ短縮
            String strMIRAIsPatID;
            if (!this.GetMIRAIsPatID(strDispPatID, this.PatIDLength, out strMIRAIsPatID))
            {
                // [トレースログ]患者属性取得エラー
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_NOTEXISTSPATIENT, String.Format("患者ID：{0} ", strDispPatID));

                // [エラー]患者が電子カルテに存在しない(はず)
                return CSIReturnCode.ERR_PATIENT_RCV_NOTEXISTSPATIENT;
            }

            #region 患者属性取得
            // 入力パラメタ設定
            CSICommon.varINPARAM = new object[1];
            CSICommon.varINPARAM[CSICommon.CON_PAT_PATIENTNO] = strMIRAIsPatID;

            // ダンプ取得開始
            DumpParameter dpPatSCH = lstDumpDatas.Find(match => match.DataTitle.Equals(DUMP_PATSCH));
            dpPatSCH.SendData = CSICommon.varINPARAM;

            // 患者属性検索実施
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            //if (!CSICommonMethod.pPatSch(this.objCSIPATSCH, CSICommon.varINPARAM, ref CSICommon.varPATSCH, ref CSICommon.colERR, this.objMIRAIsDB) || !CSICommon.pGetERRCollectionCount().Equals(0))
            base.TraceOut("【患者情報受信】他部門I/F：CSICommonMethod.pPatSch() Start");
            bResult = CSICommonMethod.pPatSch(this.objCSIPATSCH, CSICommon.varINPARAM, ref CSICommon.varPATSCH, ref CSICommon.colERR, this.objMIRAIsDB);
            base.TraceOut("【患者情報受信】他部門I/F：CSICommonMethod.pPatSch() End");
            if (bResult == false || !CSICommon.pGetERRCollectionCount().Equals(0))
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            {
                // [エラー]患者属性取得失敗
                Fn3ReturnCode retCodePatSch = CSIReturnCode.ERR_PATIENT_RCV_PATSCH;

                // [トレースログ]患者属性取得エラー
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_PATSCH, String.Format("患者ID：{0} ", strDispPatID) + CSICommonMethod.GetLastErrorString());

                // 該当患者無しの場合、アラーム通知しない(IOT0004)
                if (!CSICommonMethod.IsErrorCode(CSICommonConst.ERRCODE_NOTEXISTSPATIENT))
                {
                    // [アラーム通知]
                    base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, strDispPatID, this.PatName, "",
                                   string.Format("{0}（{1}）", CSIReturnCode.ERR_PATIENT_RCV_PATSCH.Message, CSICommonMethod.GetLastErrorString()));
                }
                // 該当患者無しの場合
                else
                {
                    // [エラー]該当患者無しエラーを返す(汎用結果のメモに設定されるメッセージ用)
                    retCodePatSch = CSIReturnCode.ERR_PATIENT_RCV_NOTEXISTSPATIENT;
                }

                // エラー有り
                if (!CSICommon.pGetERRCollectionCount().Equals(0))
                {
                    // ダンプ取得終了
                    dpPatSCH.ErrorData = CSICommon.colERR;
                    dpPatSCH.Result = false;
                }

                // [エラー]患者属性取得失敗
                return retCodePatSch;
            }
            else
            {
                // ダンプ取得終了
                dpPatSCH.ReceiveData = CSICommon.varPATSCH;
                dpPatSCH.Result = true;
            }
            #endregion

            #region 患者血液型取得
            // 入力パラメタ設定
            CSICommon.varINPARAM = new object[1];
            CSICommon.varINPARAM[CSICommon.CON_BLD_PATIENTNO] = strMIRAIsPatID;

            // ダンプ取得開始
            DumpParameter dpBloodType = lstDumpDatas.Find(match => match.DataTitle.Equals(DUMP_BLOODTYPE));
            dpBloodType.SendData = CSICommon.varINPARAM;

            // 患者血液型検索実施
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            //if (!CSICommonMethod.pBloodType(this.objCSIBLOODTYPE, CSICommon.varINPARAM, ref CSICommon.varBLOODTYPE, ref CSICommon.colERR, this.objMIRAIsDB))
            base.TraceOut("【患者情報受信】他部門I/F：CSICommonMethod.pBloodType() Start");
            bResult = CSICommonMethod.pBloodType(this.objCSIBLOODTYPE, CSICommon.varINPARAM, ref CSICommon.varBLOODTYPE, ref CSICommon.colERR, this.objMIRAIsDB);
            base.TraceOut("【患者情報受信】他部門I/F：CSICommonMethod.pBloodType() End");
            if (bResult == false)
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            {
                // [トレースログ]患者血液型取得エラー
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_BLOODTYPE, String.Format("患者ID：{0} ", strDispPatID) + CSICommonMethod.GetLastErrorString());

                // [アラーム通知]
                base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, strDispPatID, this.PatName, "",
                               string.Format("{0}（{1}）", CSIReturnCode.ERR_PATIENT_RCV_BLOODTYPE.Message, CSICommonMethod.GetLastErrorString()));

                // エラー有り
                if (!CSICommon.pGetERRCollectionCount().Equals(0))
                {
                    // ダンプ取得終了
                    dpBloodType.ErrorData = CSICommon.colERR;
                    dpBloodType.Result = false;
                }

                // [エラー]患者血液型取得失敗
                return CSIReturnCode.ERR_PATIENT_RCV_BLOODTYPE;
            }
            else
            {
                // ダンプ取得終了
                dpBloodType.ReceiveData = CSICommon.varBLOODTYPE;
                dpBloodType.Result = true;
            }
            #endregion

            #region 患者感染症取得
            // 入力パラメタ設定
            CSICommon.varINPARAM = new object[2];
            CSICommon.varINPARAM[CSICommon.CON_INF_PATIENTNO] = strMIRAIsPatID;
            CSICommon.varINPARAM[CSICommon.CON_INF_MODE] = "1"; // 全て検索

            // ダンプ取得開始
            DumpParameter dpInfection = lstDumpDatas.Find(match => match.DataTitle.Equals(DUMP_INFECTION));
            dpInfection.SendData = CSICommon.varINPARAM;

            // 患者感染症検索実施
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            //if (!CSICommonMethod.pInfection(this.objCSIINFECTION, CSICommon.varINPARAM, ref CSICommon.colINFECTION, ref CSICommon.colERR, this.objMIRAIsDB))
            base.TraceOut("【患者情報受信】他部門I/F：CSICommonMethod.pInfection() Start");
            bResult = CSICommonMethod.pInfection(this.objCSIINFECTION, CSICommon.varINPARAM, ref CSICommon.colINFECTION, ref CSICommon.colERR, this.objMIRAIsDB);
            base.TraceOut("【患者情報受信】他部門I/F：CSICommonMethod.pInfection() End");
            if (bResult == false)
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            {
                // [トレースログ]患者感染症取得エラー
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_INFECTION, String.Format("患者ID：{0} ", strDispPatID) + CSICommonMethod.GetLastErrorString());

                // [アラーム通知]
                base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, strDispPatID, this.PatName, "",
                               string.Format("{0}（{1}）", CSIReturnCode.ERR_PATIENT_RCV_INFECTION.Message, CSICommonMethod.GetLastErrorString()));                

                // エラー有り
                if (!CSICommon.pGetERRCollectionCount().Equals(0))
                {
                    // ダンプ取得終了
                    dpInfection.ErrorData = CSICommon.colERR;
                    dpInfection.Result = false;
                }

                // [エラー]患者感染症取得失敗
                return CSIReturnCode.ERR_PATIENT_RCV_INFECTION;
            }
            else
            {
                // ダンプ取得終了
                dpInfection.ReceiveData = new Object[] { (Object)CSICommon.colINFECTION };
                dpInfection.Result = true;
            }
            #endregion

            #region 患者在院情報取得
            // 入力パラメタ設定
            CSICommon.varINPARAM = new object[3];
            CSICommon.varINPARAM[CSICommon.CON_ADM_PATIENTNO] = strMIRAIsPatID;

            // ダンプ取得開始
            DumpParameter dpAdmSCH = lstDumpDatas.Find(match => match.DataTitle.Equals(DUMP_ADMSCH));
            dpAdmSCH.SendData = CSICommon.varINPARAM;

            // 患者在院情報検索実施
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            //if (!CSICommonMethod.pAdmSch(this.objCSIADMSCH, CSICommon.varINPARAM, ref CSICommon.varADMSCH, ref CSICommon.colERR, this.objMIRAIsDB))
            base.TraceOut("【患者情報受信】他部門I/F：CSICommonMethod.pAdmSch() Start");
            bResult = CSICommonMethod.pAdmSch(this.objCSIADMSCH, CSICommon.varINPARAM, ref CSICommon.varADMSCH, ref CSICommon.colERR, this.objMIRAIsDB);
            base.TraceOut("【患者情報受信】他部門I/F：CSICommonMethod.pAdmSch() End");
            if (bResult == false)
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            {
                // [トレースログ]患者在院情報取得エラー
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_ADMSCH, String.Format("患者ID：{0} ", strDispPatID) + CSICommonMethod.GetLastErrorString());

                // [アラーム通知]
                base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, strDispPatID, this.PatName, "",
                               string.Format("{0}（{1}）", CSIReturnCode.ERR_PATIENT_RCV_ADMSCH.Message, CSICommonMethod.GetLastErrorString()));
                                
                // エラー有り
                if (!CSICommon.pGetERRCollectionCount().Equals(0))
                {
                    // ダンプ取得終了
                    dpAdmSCH.ErrorData = CSICommon.colERR;
                    dpAdmSCH.Result = false;
                }

                // [エラー]患者在院情報取得失敗
                return CSIReturnCode.ERR_PATIENT_RCV_ADMSCH;
            }
            else
            {
                // ダンプ取得終了
                dpAdmSCH.ReceiveData = CSICommon.varADMSCH;
                dpAdmSCH.Result = true;
            }
            #endregion

            // 患者情報取得成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// 患者情報登録、更新
        /// MIRAIsより取得した情報により、患者基本情報、患者連絡先情報、患者感染症情報を登録する
        /// なお、患者感染症情報は削除新規を行う
        /// ※MIRAIs取得した値は、CSICommonクラスの各取得値配列に格納されている
        /// </summary>
        /// <param name="exeInfo">各種処理データ</param>
        /// <param name="strDispPatID">表示用患者ID</param>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode SetPatientInfoToFNW(Fn3ExecuteInfo exeInfo, String strDispPatID)
        {
            #region MIRAIsDBよりの取得値をFNW形式へ変換
            bool isConvertSuccess = true;
            Fn3ReturnCode retCodeConvert;
            String strExceptionFormat = "Section={0} /key=\"{1}\"";
            String strUnConvertFormat = "対応する変換コードがないため、{0}を設定します。（Section={1} /key=\"{2}\"）";

            // 氏名(40バイト切り出し)
            String strName = CSICommonMethod.SubstringSafe(CSICommon.pGetPATSCHData(CSICommon.CON_PAT_PATIENTNM), CSICommonConst.LEN_NAME);

            // 氏名フリガナ(40バイト切り出し)
            String strNameKana = CSICommonMethod.SubstringSafe(CSICommon.pGetPATSCHData(CSICommon.CON_PAT_PATIENTNMKANA), CSICommonConst.LEN_NAME_KANA);

            // 生年月日 (YYYYMMDD形式 変換不要)
            String strBirthday = CSICommon.pGetPATSCHData(CSICommon.CON_PAT_BIRTHDAY);

            // 性別 (コード変換実施)
            String strSex = "";
            String strSexMIRAIs = CSICommon.pGetPATSCHData(CSICommon.CON_PAT_SEX);
            retCodeConvert = base.Convert(ConvertItem.SexToFNW, strSexMIRAIs, ref strSex);
            if (retCodeConvert.IsException)
            {
                // [トレースログ]性別変換失敗
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CONVERT);
                base.TraceOut(retCodeConvert, String.Format(strExceptionFormat, ConvertItem.SexToFNW.ToString(), strSexMIRAIs));

                // [エラー]性別変換失敗
                isConvertSuccess = false;
            }
            // 対応コードが無い場合
            else if (retCodeConvert.IsError)
            {
                // [トレースログ]不明に丸め
                base.DebugTraceOut(this.CreateTraceMessage(String.Format(strUnConvertFormat, "不明", ConvertItem.SexToFNW.ToString(), strSexMIRAIs)));

                // 不明を設定
                strSex = FNW_CODE_UNKNOWN;
            }

            // 血液型ABO (コード変換実施)
            String strBloodABO = "";
            String strBloodABOMIRAIs = CSICommon.pGetBLOODTYPEData(CSICommon.CON_BLD_ABO);
            retCodeConvert = base.Convert(ConvertItem.BloodTypeABOToFNW, strBloodABOMIRAIs, ref strBloodABO);
            if (retCodeConvert.IsException)
            {
                // [トレースログ]血液型ABO変換失敗
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CONVERT);
                base.TraceOut(retCodeConvert, String.Format(strExceptionFormat, ConvertItem.BloodTypeABOToFNW.ToString(), strBloodABOMIRAIs));

                // [エラー]血液型ABO変換失敗
                isConvertSuccess = false;
            }
            // 対応コードが無い場合
            else if (retCodeConvert.IsError)
            {
                // [トレースログ]不明に丸め
                base.DebugTraceOut(this.CreateTraceMessage(String.Format(strUnConvertFormat, "不明", ConvertItem.BloodTypeABOToFNW.ToString(), strBloodABOMIRAIs)));

                // 不明を設定
                strBloodABO = FNW_CODE_UNKNOWN;
            }

            // 血液型RH (コード変換実施)
            String strBloodRH = "";
            String strBloodRHMIRAIs = CSICommon.pGetBLOODTYPEData(CSICommon.CON_BLD_RH);
            retCodeConvert = base.Convert(ConvertItem.BloodTypeRHToFNW, strBloodRHMIRAIs, ref strBloodRH);
            if (retCodeConvert.IsException)
            {
                // [トレースログ]血液型ABO変換失敗
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CONVERT);
                base.TraceOut(retCodeConvert, String.Format(strExceptionFormat, ConvertItem.BloodTypeRHToFNW.ToString(), strBloodRHMIRAIs));

                // [エラー]血液型ABO変換失敗
                isConvertSuccess = false;
            }
            // 対応コードが無い場合
            else if (retCodeConvert.IsError)
            {
                // [トレースログ]不明に丸め
                base.DebugTraceOut(this.CreateTraceMessage(String.Format(strUnConvertFormat, "不明", ConvertItem.BloodTypeRHToFNW.ToString(), strBloodRHMIRAIs)));

                // 不明を設定
                strBloodRH = FNW_CODE_UNKNOWN;
            }
            
            // 入外区分 (コード変換実施)
            String strInOutFlg = "";
            String strInOutFlgMIRAIs = CSICommon.pGetADMSCHData(CSICommon.CON_ADM_PATIENTTYPE);
            retCodeConvert = base.Convert(ConvertItem.InOutFlgToFNW, strInOutFlgMIRAIs, ref strInOutFlg);
            if (retCodeConvert.IsException)
            {
                // [トレースログ]入外区分変換失敗
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CONVERT);
                base.TraceOut(retCodeConvert, String.Format(strExceptionFormat, ConvertItem.InOutFlgToFNW.ToString(), strInOutFlgMIRAIs));

                // [エラー]入外区分変換失敗
                isConvertSuccess = false;
            }
            // 対応コードが無い場合
            else if (retCodeConvert.IsError)
            {
                // [トレースログ]外来に丸め
                base.DebugTraceOut(this.CreateTraceMessage(String.Format(strUnConvertFormat, "外来", ConvertItem.InOutFlgToFNW.ToString(), strInOutFlgMIRAIs)));

                // 外来を設定
                strInOutFlg = FNW_CODE_OUT;
            }
            
            #region 感染症情報取得
            // MIRAIsより取得できた分を取得・変換
            Hashtable htbInfection = new Hashtable();
            for (int i = 1; i <= CSICommon.pGetINFECTIONCollectionCount(); i++)
            { 
                String strInfectionCode = "";
                String strInfectionName = "";
                String strResultMIRAIs = "";
                String strUpdate = "";

                // 値取り出し
                CSICommon.pGetINFECTIONCollectionItem(i.ToString(), ref strInfectionCode, ref strInfectionName, ref strResultMIRAIs, ref strUpdate);
                String strResultFNW = "";
                retCodeConvert = base.Convert(ConvertItem.InfectionToFNW, strResultMIRAIs, ref strResultFNW);
                if (retCodeConvert.IsException)
                {
                    // [トレースログ]感染症結果コード変換失敗
                    base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_CONVERT);
                    base.TraceOut(retCodeConvert, String.Format(strExceptionFormat, ConvertItem.InfectionToFNW.ToString(), strResultMIRAIs));

                    // [エラー]感染症結果コード変換失敗
                    isConvertSuccess = false;
                    break;
                }
                // 対応コードが無い場合
                else if (retCodeConvert.IsError)
                {
                    // [トレースログ]不明に丸め
                    base.DebugTraceOut(this.CreateTraceMessage(String.Format(strUnConvertFormat, "不明", ConvertItem.InfectionToFNW.ToString(), strResultMIRAIs)));

                    // 不明を設定
                    strResultFNW = FNW_CODE_UNKNOWN;
                }

                // 感染症コード、結果を取得 (感染症マスタの同期が前提)
                htbInfection.Add(strInfectionCode, strResultFNW);
            }

            //>>>>> 2011/12/15 CHG T.Kurita 感染症取り込み仕様変更
            //// 感染症有無 (取得した感染症に、全て「無し」であれば無、それ以外は有)
            //String strInfect = "0";
            //if (isConvertSuccess)
            //{
            //    // 感染症情報がMIRAIsに1件も登録されていない場合
            //    if (htbInfection.Count.Equals(0))
            //    {
            //        // 感染症有りとして扱う
            //        strInfect = "1";
            //    }
            //    // 感染症情報が取得できた場合
            //    else
            //    {
            //        // 取得件数分処理(必ず全件取れる)
            //        foreach (String strInfectionResult in htbInfection.Values)
            //        {
            //            // 感染症「無し」では無い場合
            //            if (!strInfectionResult.Equals("0"))
            //            {
            //                // 感染症有りを設定
            //                strInfect = "1";
            //            }
            //        }
            //    }
            //}
            // 感染症有無(連携情報から取得)
            String strInfect = "0";
            XmlNode nodeInfect = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/INFECT");
            if (nodeInfect != null)
            {
                strInfect = nodeInfect.InnerText;
            }
            // 感染症有無が「"0":なし」の場合
            if (strInfect.Equals("0"))
            {
                // 感染症有無 (取得した感染症に、1件以上「1:(+)」がある場合)
                if (isConvertSuccess)
                {
                    // 感染症情報がMIRAIsに1件以上登録されている場合
                    if (htbInfection.Count > 0)
                    {
                        // 取得件数分処理(必ず全件取れる)
                        foreach (String strInfectionResult in htbInfection.Values)
                        {
                            // 感染症「1:(+)」の場合
                            if (strInfectionResult.Equals("1"))
                            {
                                // 感染症有りを設定
                                strInfect = "1";
                            }
                        }
                    }
                }
            }
            //<<<<< 2011/12/15 CHG T.Kurita 感染症取り込み仕様変更
            #endregion

            #region 患者連絡先情報＝本人の取得
            List<Hashtable> lstAddressCollection = new List<Hashtable>();
            Hashtable htbAddressCollection1 = new Hashtable();
            htbAddressCollection1.Add(KEY_ENABLED, false);

            // 管理番号 (1固定)
            htbAddressCollection1.Add(KEY_CTL_NO, "1");

            // 表示順 (過去の値が無い場合は1固定)
            XmlNode nodeContact1 = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_CONTACT[CTL_NO=1]/DISP_NO");
            if (nodeContact1 == null)
            {
                htbAddressCollection1.Add(KEY_DISP_NO, "1");
            }
            else
            {
                htbAddressCollection1.Add(KEY_DISP_NO, nodeContact1.InnerText);
            }

            // 続柄 (本人)
            htbAddressCollection1.Add(KEY_RELATION, "0");

            // 住所1 (変換不要)
            htbAddressCollection1.Add(KEY_PAT_ADDRESS, CSICommon.pGetPATSCHData(CSICommon.CON_PAT_ADDRESS1));
            if (!htbAddressCollection1[KEY_PAT_ADDRESS].ToString().Equals(""))
            {
                htbAddressCollection1[KEY_ENABLED] = true;
            }

            // 郵便番号1 (変換不要)
            htbAddressCollection1.Add(KEY_PAT_ZIPCODE, CSICommon.pGetPATSCHData(CSICommon.CON_PAT_POSTALCODE1));
            if (!htbAddressCollection1[KEY_PAT_ZIPCODE].ToString().Equals(""))
            {
                htbAddressCollection1[KEY_ENABLED] = true;
            }

            // 電話番号1 (変換不要)
            htbAddressCollection1.Add(KEY_PAT_TELNO, CSICommon.pGetPATSCHData(CSICommon.CON_PAT_TEL1));
            if (!htbAddressCollection1[KEY_PAT_TELNO].ToString().Equals(""))
            {
                htbAddressCollection1[KEY_ENABLED] = true;
            }
            lstAddressCollection.Add(htbAddressCollection1);
            #endregion

            #region 患者連絡先情報＝勤務先の取得
            Hashtable htbAddressCollection2 = new Hashtable();
            htbAddressCollection2.Add(KEY_ENABLED, false);

            // 管理番号 (2固定)
            htbAddressCollection2.Add(KEY_CTL_NO, "2");

            // 表示順 (過去の値が無い場合は2固定)
            XmlNode nodeContact2 = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_CONTACT[CTL_NO=2]/DISP_NO");
            if (nodeContact2 == null)
            {
                htbAddressCollection2.Add(KEY_DISP_NO, "2");
            }
            else
            {
                htbAddressCollection2.Add(KEY_DISP_NO, nodeContact2.InnerText);
            }

            // 続柄 (本人)
            htbAddressCollection2.Add(KEY_RELATION, "0");

            // 住所2 (変換不要)
            htbAddressCollection2.Add(KEY_PAT_ADDRESS, CSICommon.pGetPATSCHData(CSICommon.CON_PAT_ADDRESS2));
            if (!htbAddressCollection2[KEY_PAT_ADDRESS].ToString().Equals(""))
            {
                htbAddressCollection2[KEY_ENABLED] = true;
            }

            // 郵便番号2 (変換不要)
            htbAddressCollection2.Add(KEY_PAT_ZIPCODE, CSICommon.pGetPATSCHData(CSICommon.CON_PAT_POSTALCODE2));
            if (!htbAddressCollection2[KEY_PAT_ZIPCODE].ToString().Equals(""))
            {
                htbAddressCollection2[KEY_ENABLED] = true;
            }

            // 電話番号2 (変換不要)
            htbAddressCollection2.Add(KEY_PAT_TELNO, CSICommon.pGetPATSCHData(CSICommon.CON_PAT_TEL2));
            if (!htbAddressCollection2[KEY_PAT_TELNO].ToString().Equals(""))
            {
                htbAddressCollection2[KEY_ENABLED] = true;
            }
            lstAddressCollection.Add(htbAddressCollection2);
            #endregion

            #region 患者連絡先情報＝その他
            Hashtable htbAddressCollection3 = new Hashtable();
            htbAddressCollection3.Add(KEY_ENABLED, false);

            // 管理番号 (3固定)
            htbAddressCollection3.Add(KEY_CTL_NO, "3");

            // 表示順 (過去の値が無い場合は3固定)
            XmlNode nodeContact3 = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_CONTACT[CTL_NO=3]/DISP_NO");
            if (nodeContact3 == null)
            {
                htbAddressCollection3.Add(KEY_DISP_NO, "3");
            }
            else
            {
                htbAddressCollection3.Add(KEY_DISP_NO, nodeContact3.InnerText);
            }

            // 続柄 (その他)
            htbAddressCollection3.Add(KEY_RELATION, "99");

            // 住所3 (変換不要)
            htbAddressCollection3.Add(KEY_PAT_ADDRESS, CSICommon.pGetPATSCHData(CSICommon.CON_PAT_ADDRESS3));
            if (!htbAddressCollection3[KEY_PAT_ADDRESS].ToString().Equals(""))
            {
                htbAddressCollection3[KEY_ENABLED] = true;
            }

            // 郵便番号3 (変換不要)
            htbAddressCollection3.Add(KEY_PAT_ZIPCODE, CSICommon.pGetPATSCHData(CSICommon.CON_PAT_POSTALCODE3));
            if (!htbAddressCollection3[KEY_PAT_ZIPCODE].ToString().Equals(""))
            {
                htbAddressCollection3[KEY_ENABLED] = true;
            }

            // 電話番号3 (変換不要)
            htbAddressCollection3.Add(KEY_PAT_TELNO, CSICommon.pGetPATSCHData(CSICommon.CON_PAT_TEL3));
            if (!htbAddressCollection3[KEY_PAT_TELNO].ToString().Equals(""))
            {
                htbAddressCollection3[KEY_ENABLED] = true;
            }
            lstAddressCollection.Add(htbAddressCollection3);
            #endregion

            // 科コード (診療科マスタの同期が前提)
            String strCourse = CSICommon.pGetADMSCHData(CSICommon.CON_ADM_CURRENTDEPT);

            // 病棟コード (病棟マスタの同期が前提)
            String strWard = CSICommon.pGetADMSCHData(CSICommon.CON_ADM_CURRENTWARD);

            // 死亡日 (YYYY/MM/DD形式 /を取り除く)
            String strDieDate = CSICommon.pGetADMSCHData(CSICommon.CON_ADM_DEATHDATE).Replace("/", "");

            // 死亡フラグ (死亡日が在る場合のみ設定)
            String strDieFlg = strDieDate.Equals("") ? "0" : "1";

            // 指示、透析スケジュール削除判定用の今回死亡フラグ設定
            bool isNowDie = false;
            XmlNode nodeDieFlg = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DIE_FLG");
            if (strDieFlg.Equals("1"))
            {
                // 初回取込みの場合
                if (nodeDieFlg == null)
                {
                    // 今回死亡フラグオン
                    isNowDie = true;
                }
                // 生存→死亡になった場合は
                else if (nodeDieFlg.InnerText.Equals("0"))
                {
                    // 今回死亡フラグオン
                    isNowDie = true;
                }
            }

            // 変換が全て成功していない場合
            if (!isConvertSuccess)
            { 
                // [エラー]患者情報変換失敗
                return Fn3ReturnCode.Error;
            }
            #endregion

            #region 登録、更新用入力XML生成
            StringBuilder sbInXml = new StringBuilder();
            XmlWriterSettings xmwSetting = new XmlWriterSettings();
            xmwSetting.OmitXmlDeclaration = true;
            XmlWriter xwInXmlWriter = XmlWriter.Create(sbInXml, xmwSetting);
            xwInXmlWriter.WriteStartElement("rootNode");

            #region 患者基本情報部
            xwInXmlWriter.WriteStartElement("PAT_BASIC_INFO");

            // 表示用患者ID
            xwInXmlWriter.WriteElementString("DISP_PATID", strDispPatID);
            // 氏名
            xwInXmlWriter.WriteElementString("NAME", strName);
            // 氏名フリガナ
            xwInXmlWriter.WriteElementString("NAME_KANA", strNameKana);
            // 生年月日
            xwInXmlWriter.WriteElementString("BIRTHDAY", strBirthday);
            // 性別
            xwInXmlWriter.WriteElementString("SEX_CD", strSex);
            // 血液型ABO
            xwInXmlWriter.WriteElementString("BLOOD_TYPE_ABO", strBloodABO);
            // 血液型RH
            xwInXmlWriter.WriteElementString("BLOOD_TYPE_RH", strBloodRH);
            // 感染症有無
            //>>>>> 2011/12/15 CHG T.Kurita 感染症取り込み仕様変更
            //xwInXmlWriter.WriteElementString("INFECT", strInfect);
            if (strInfect.Equals("1"))
            {
                xwInXmlWriter.WriteElementString("INFECT", strInfect);
            }
            //<<<<< 2011/12/15 CHG T.Kurita 感染症取り込み仕様変更
            // 入外区分
            xwInXmlWriter.WriteElementString("INOUT_FLG", strInOutFlg);
            // 診療科コード
            xwInXmlWriter.WriteElementString("COURSE_CD", strCourse);
            // 病棟コード
            xwInXmlWriter.WriteElementString("WARD_CD", strWard);
            // 死亡日
            xwInXmlWriter.WriteElementString("DIE_DATE", strDieDate);
            // 死亡フラグ
            xwInXmlWriter.WriteElementString("DIE_FLG", strDieFlg);

            xwInXmlWriter.WriteEndElement();
            #endregion

            #region 患者連絡先情報部
            Int32 intPatContactIndex = 1;
            foreach (Hashtable htbAddressCollection in lstAddressCollection)
            {
                // 取得値が無い場合
                if (htbAddressCollection[KEY_ENABLED].Equals(false))
                {
                    // 設定しない
                    continue;
                }

                xwInXmlWriter.WriteStartElement("PAT_CONTACT");
                xwInXmlWriter.WriteAttributeString("ID", intPatContactIndex++.ToString());

                // 表示用患者ID
                xwInXmlWriter.WriteElementString("DISP_PATID", strDispPatID);
                // 管理番号
                xwInXmlWriter.WriteElementString("CTL_NO", htbAddressCollection[KEY_CTL_NO].ToString());
                // 表示順
                xwInXmlWriter.WriteElementString("DISP_NO", htbAddressCollection[KEY_DISP_NO].ToString());
                // 続柄
                xwInXmlWriter.WriteElementString("RELATION", htbAddressCollection[KEY_RELATION].ToString());
                // 氏名(全て患者本人の氏名を設定)
                xwInXmlWriter.WriteElementString("NAME", strName);
                // 住所 (無い場合は書かない)
                String strAddress = htbAddressCollection[KEY_PAT_ADDRESS].ToString();
                if (!strAddress.Equals(""))
                {
                    xwInXmlWriter.WriteElementString("ADDRESS", strAddress);
                }
                // 郵便番号 (無い場合は書かない)
                String strZipCode = htbAddressCollection[KEY_PAT_ZIPCODE].ToString();
                if (!strZipCode.Equals(""))
                {
                    xwInXmlWriter.WriteElementString("ZIPCODE", strZipCode);
                }
                // 電話番号1 (無い場合は書かない)
                String strTELNO1 = htbAddressCollection[KEY_PAT_TELNO].ToString();
                if (!strTELNO1.Equals(""))
                {
                    xwInXmlWriter.WriteElementString("TELNO1", strTELNO1);
                }

                xwInXmlWriter.WriteEndElement();
            }
            #endregion

            #region 患者感染症情報部
            Int32 intInfectIndex = 1;
            foreach (String strInfectionCode in htbInfection.Keys)
            {
                xwInXmlWriter.WriteStartElement("PAT_INFECT");
                xwInXmlWriter.WriteAttributeString("ID", intInfectIndex++.ToString());

                // 表示用患者ID
                xwInXmlWriter.WriteElementString("DISP_PATID", strDispPatID);
                // 感染症コード
                xwInXmlWriter.WriteElementString("INFECTION_CD", strInfectionCode);
                // 結果コード
                xwInXmlWriter.WriteElementString("INFECT", htbInfection[strInfectionCode].ToString());

                xwInXmlWriter.WriteEndElement();
            }
            #endregion

            xwInXmlWriter.WriteEndElement();
            xwInXmlWriter.Flush();
            xwInXmlWriter.Close();
            #endregion

            // 患者取込み実施
            Int32 intUpdateNum = 0;
            Fn3ReturnCode retCodeSetPatient = base.DBUpdateCoopInfo(base.FunctionName, sbInXml.ToString(), ref intUpdateNum);
            if (retCodeSetPatient.IsError || retCodeSetPatient.IsException)
            {
                // [トレースログ]患者情報登録失敗
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_SET_PAT_INFO);                
                base.TraceOut(retCodeSetPatient);

                // [アラーム通知]
                base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, strDispPatID, this.PatName, "", CSIReturnCode.ERR_PATIENT_RCV_SET_PAT_INFO.Message);

                // [エラー]患者情報登録失敗
                return retCodeSetPatient;
            }
            else
            {
                // 患者が今回死亡になった場合
                if (isNowDie)
                {
                    // 対象患者の指示、透析スケジュールを死亡日から削除
                    Fn3ReturnCode retCodeDeleteInd = base.DBDeleteIndDate(strDispPatID, strDieDate);
                    if (retCodeDeleteInd.IsError || retCodeDeleteInd.IsException)
                    {
                        // [トレースログ]指示、透析スケジュール削除失敗
                        // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                        //base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_DEL_DIALYSIS_SCHEDUL);
                        base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_DEL_DIALYSIS_SCHEDUL, string.Format("患者ID=\"{0}\"", this.DispPatID));
                        // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
                        base.TraceOut(retCodeDeleteInd);

                        // [エラー]指示、透析スケジュール削除失敗
                        return retCodeDeleteInd;
                    }
                }

                // [トレースログ]患者取込み成功
                base.DebugTraceOut(this.CreateTraceMessage("患者取込み成功：" + strDispPatID));
            }

            // 患者情報登録、更新成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// 患者識別情報登録
        /// 指定患者の患者識別情報をMIRAIsへ登録する
        /// </summary>
        /// <param name="strDispPatID">表示用患者ID</param>
        /// <param name="lstDumpDatas">ダンプデータリスト</param>
        // <returns>成功/失敗</returns>
        private Fn3ReturnCode SetDiscernmentInfoToMIRAIs(String strDispPatID, List<DumpParameter> lstDumpDatas)
        {
            // 入力パラメタ設定
            String strMIRAIsPatID;
            this.GetMIRAIsPatID(strDispPatID, this.PatIDLength, out strMIRAIsPatID);
            CSICommon.varINPARAM = new object[2];
            CSICommon.varINPARAM[CSICommon.CON_DIA_PATIENTNO] = strMIRAIsPatID;
            CSICommon.varINPARAM[CSICommon.CON_DIA_MODE] = CSICommonConst.PROCDIV_INSERT;

            // ダンプ取得開始
            DumpParameter dpDialysis = lstDumpDatas.Find(match => match.DataTitle.Equals(DUMP_DIALYSIS));
            dpDialysis.SendData = CSICommon.varINPARAM;

            // 患者識別情報登録実施
            // >>>>>【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            //if (!CSICommonMethod.pDialysis(this.objCSIDIALYSIS, CSICommon.varINPARAM, ref CSICommon.colERR, this.objMIRAIsDB))
            base.TraceOut("【患者情報受信】他部門I/F：CSICommonMethod.pDialysis() Start");
            bool bResult = CSICommonMethod.pDialysis(this.objCSIDIALYSIS, CSICommon.varINPARAM, ref CSICommon.colERR, this.objMIRAIsDB);
            base.TraceOut("【患者情報受信】他部門I/F：CSICommonMethod.pDialysis() End");
            if (bResult == false)
            // <<<<<【Ver.5.0.2.100】2015.07.30 石川 ログ強化
            {
                // [トレースログ]患者識別情報登録エラー
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_DIALYSIS, String.Format("患者ID：{0} ", strDispPatID) + CSICommonMethod.GetLastErrorString());

                // [アラーム通知]
                base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, strDispPatID, this.PatName, "",
                               string.Format("{0}（{1}）", CSIReturnCode.ERR_PATIENT_RCV_DIALYSIS.Message, CSICommonMethod.GetLastErrorString()));

                // ダンプ取得終了
                dpDialysis.ErrorData = CSICommon.colERR;
                dpDialysis.Result = false;

                // [エラー]患者識別情報登録失敗
                return CSIReturnCode.ERR_PATIENT_RCV_DIALYSIS;
            }
            else
            {
                // [トレースログ]患者識別情報登録成功
                base.DebugTraceOut(this.CreateTraceMessage("患者識別情報登録成功：", String.Format("患者ID：{0}", strDispPatID)));

                // ダンプ取得終了
                dpDialysis.Result = true;
            }

            // 患者識別情報登録成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// MIRAIs用患者ID取得
        /// 患者IDの下N桁を取得(Nは設定値)
        /// </summary>
        /// <param name="strDispPatID">表示用患者ID(フル桁想定)</param>
        /// <param name="nPatIDLength">患者ID指定桁数</param>
        /// <param name="strMIRAIsPatID">取得した患者ID</param>
        /// <returns>成功/失敗</returns>
        private bool GetMIRAIsPatID(String strDispPatID, Int32 nPatIDLength, out String strMIRAIsPatID)
        {
            // 前ゼロを取り除いた状態で指定患者IDよりも長い場合
            if (strDispPatID.TrimStart('0').Length > nPatIDLength)
            {
                // 連携対象外の患者のため、エラーとする
                strMIRAIsPatID = "";
                return false;
            }
            // 正常な場合
            else
            {
                strMIRAIsPatID = strDispPatID.Substring(strDispPatID.Length - nPatIDLength, nPatIDLength);
                return true;
            }
        }

        /// <summary>
        /// トレースメッセージ生成
        /// <para>[～プラグイン]：メインメッセージ の形式でメッセージ生成</para>
        /// </summary>
        /// <param name="strMainMessage">～しました。などの主文</param>
        /// <returns>トレースメッセージ</returns>
        private String CreateTraceMessage(String strMainMessage)
        {
            return CSICommonConst.MODULE_MNAME_PRS + CSICommonConst.LOGTYPE_DBG + strMainMessage;
        }

        /// <summary>
        /// トレースメッセージ生成
        /// <para>[～プラグイン]：メインメッセージ (補足情報) の形式でメッセージ生成</para>
        /// </summary>
        /// <param name="strMainMessage">～しました。などの主文</param>
        /// <param name="strSubInfo">主文に対する補足情報(不正な設定値、値など)</param>
        /// <returns>トレースメッセージ</returns>
        private String CreateTraceMessage(String strMainMessage, String strSubInfo)
        {
            return CSICommonConst.MODULE_MNAME_PRS + CSICommonConst.LOGTYPE_DBG + strMainMessage + "(" + strSubInfo + ")";
        }
        #endregion
    }
}
