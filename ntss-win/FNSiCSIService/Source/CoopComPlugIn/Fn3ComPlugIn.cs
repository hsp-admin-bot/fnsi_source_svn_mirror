///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：プラグイン機能
// ファイル名：Fn3ComPlugIn.cs
// 説明      ：プラグイン機能を提供する。
//
//  Copyright(C) 2009 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴c
//  日付        担当                理由
//  2009/08/10  根津知則            新規作成
//  2011/06/23  青木雅文            表示用患者ID指定による患者情報取得メソッド追加
//  2011/08/26  青木雅文            透析スケジュール受信機能の追加
//  2012/11/13  大星憲士            系列施設対応
//  2014/11/06  阿部浩幸            指示変更情報取得対応
//  2015/04/21  中村圭之介          Redmine#4251対応
//  2015/05/18  中村圭之介          Redmine#4625対応
//  2015/05/21  宮崎公伯            Redmine#4625対応
//  2015/06/24  中村圭之介          オーダ番号サイクリック対応
//  2016/06/10  中村圭之介          サイクリック仕様変更
//  2016/07/29  中村圭之介          サイクリック受入指摘(Redmine#6015)
//  2021/03/09  王楠                CSI製電子カルテ（MIRAIS)についての対応
//
///////////////////////////////////////////////////////////////////////////////

using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Xml;
using System.Threading;
using jp.co.nikkiso.fn3.Cooperation;
using jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopCommonInterface;
using jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopCommonDefine;
using System.Reflection;
using System.IO;
using System.Runtime.Remoting.Lifetime;
using System.Globalization;
using System.Data;
using jp.co.nikkiso.fn3.Cooperation.CoopComSocket;

namespace jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn
{
    /// <summary>
    /// 連携プラグイン生成用基底クラス<br />
    /// 連携プラグインを生成する場合はこのクラスを継承します。トレース出力、ダンプ出力など、連携処理に必要な機能を実装する。
    /// </summary>
    /// <example>
    /// 基本的な継承方法を以下に示す。
    /// <code>
    /// public class TestCooperation : Fn3ComPlugIn
    /// {
    ///     //  コンストラクタでは連携ID、処理区分を設定します。
    ///     public TestCooperation()
    ///         : base("0001", "001")
    ///     {
    ///         //  基本的に何も処理を行いません。
    ///     }
    ///
    ///     //  連携初期化処理
    ///     protected override Fn3ReturnCode Initialize(XmlNode xmlCoopSetting)
    ///     {
    ///         //  ソケットの初期化など連携で使用されるオブジェクトの初期化を行います。
    ///         return Fn3ReturnCode.Success;
    ///     }
    ///
    ///     //  連携処理開始処理
    ///     protected override Fn3ReturnCode Start()
    ///     {
    ///         //  サーバーソケットの待ち受け開始など、連携の開始処理を行います。
    ///         return Fn3ReturnCode.Success;
    ///     }
    ///
    ///     //  連携処理実行
    ///     protected virtual Fn3ReturnCode Execute(XmlNode xmlCoopInfo, XmlNode xmlEventMng)
    ///     {
    ///         //  送信系モジュールの連携処理を行います。
    ///         return Fn3ReturnCode.Success;
    ///     }
    ///
    ///     //  連携一時停止処理
    ///     protected override void Stop()
    ///     {
    ///         //  ソケットのクローズなど、連携の一時停止を行います。
    ///     }
    ///
    ///     //  連携解放処理
    ///     protected override void Release()
    ///     {
    ///         //  インスタンスの破棄など、連携の解放を行います。
    ///     }
    /// }
    /// </code>
    /// </example>
    public abstract class Fn3ComPlugIn : MarshalByRefObject, IFn3ComPlugIn
    {
        #region "列挙体"

        /// <summary>
        /// ログ種別
        /// </summary>
        private enum LogKind
        {
            /// <summary>
            /// 情報
            /// </summary>
            Information = 1,

            /// <summary>
            /// 警告
            /// </summary>
            Warning = 2,

            /// <summary>
            /// エラー
            /// </summary>
            Error = 3
        }

        /// <summary>
        /// 変換項目
        /// </summary>
        public enum ConvertItem
        {
            /// <summary>
            /// 血液型ABO（FNWから電子カルテ変換）
            /// </summary>
            BloodTypeABOToKarte,

            /// <summary>
            /// 血液型ABO（電子カルテからFNW変換）
            /// </summary>
            BloodTypeABOToFNW,

            /// <summary>
            /// 血液型RH（FNWから電子カルテ変換）
            /// </summary>
            BloodTypeRHToKarte,

            /// <summary>
            /// 血液型RH（電子カルテからFNW変換）
            /// </summary>
            BloodTypeRHToFNW,

            /// <summary>
            /// 性別（FNWから電子カルテ変換）
            /// </summary>
            SexToKarte,

            /// <summary>
            /// 性別（電子カルテからFNW変換）
            /// </summary>
            SexToFNW,

            /// <summary>
            /// 国籍（FNWから電子カルテ変換）
            /// </summary>
            NationalityToKarte,

            /// <summary>
            /// 国籍（電子カルテからFNW変換）
            /// </summary>
            NationalityToFNW,

            /// <summary>
            /// 感染症（FNWから電子カルテ変換）
            /// </summary>
            InfectionToKarte,

            /// <summary>
            /// 感染症（電子カルテからFNW変換）
            /// </summary>
            InfectionToFNW,

            /// <summary>
            /// 入外区分（FNWから電子カルテ変換）
            /// </summary>
            InOutFlgToKarte,

            /// <summary>
            /// 入外区分（電子カルテからFNW変換）
            /// </summary>
            InOutFlgToFNW,

            /// <summary>
            /// 検査区分（前後区分・FNWから電子カルテ変換）
            /// </summary>
            ExaminOrderClassToKarte,

            /// <summary>
            /// 検査区分（前後区分・電子カルテからFNW）
            /// </summary>
            ExaminOrderClassToFNW
        }

        /// <summary>
        /// 通知種別を設定する 
        /// (ここを更新する場合は、DBアプリのMultiCastConnect.csも更新する)
        /// </summary>
        private enum NOTIFYTYPE
        {
            /// <summary>血圧未測定</summary>
            UN_BLOOD_MESURE = 0,
            /// <summary>ケア報知</summary>
            UN_CARE,
            /// <summary>ベッド未登録</summary>
            UN_BED_ENTRY,
            /// <summary>未割付患者</summary>
            UN_ALLOCATION,
            /// <summary>未送信患者</summary>
            UN_SENT,
            /// <summary>指示変更</summary>
            REVISE,
            /// <summary>新規装置接続</summary>
            NEW_DEVICE_CONNECT,
            /// <summary>装置接続情報</summary>
            DEVICE_CONNECT_INFO,
            /// <summary>オプション読み込み</summary>
            DEVICE_OPTION_READ,
            /// <summary>警報/報知(全体)</summary>
            DEVICE_ALARM_ALL,
            /// <summary>警報(個別)</summary>
            DEVICE_ALARM_PERSONAL,
            /// <summary>報知(個別)</summary>
            DEVICE_ALARM_NOTIFY_PERSONAL,
        }

        /// <summary>
        /// アラーム通知種別
        /// </summary>
        public enum AlarmKind
        {
            /// <summary>警報/報知(全体)</summary>
            DEVICE_ALARM_ALL,
            /// <summary>警報(個別)</summary>
            DEVICE_ALARM_PERSONAL,
            /// <summary>報知(個別)</summary>
            DEVICE_ALARM_NOTIFY_PERSONAL,
        }
        #endregion

        #region "メンバ変数"

        private StatusCode m_statusCode;
        private bool m_bolAbortFlag = false;
        private bool m_bolEventRetry = false;
        private DBAccessDelegate m_dgtDBAccess = null;
        private SelfStopDelegate m_dgtSelfStop = null;
        private SendAlarmDelegate m_dgtSendAlarm = null;
        private RegistEventDelegate m_dgtRegistEvent = null;
        private StatusInformationDelegate m_dgtStatusInformation = null;
        private GetInitialValueDelegate m_dgtGetInitialValue = null;
        private SetInitialValueDelegate m_dgtSetInitialValue = null;
        private GetCooperationIDDelegate m_dgtGetCooperationIDDelegate = null;
        private Fn3CoopLog m_log = null;
        private XmlNode m_xmlMstCoopId = null;
        private string m_strSendHistMemo = null;
        // 系列施設対応 ここから 大星憲士 2012/11/13
        /// <summary>系列施設運用モード</summary>
        private SeriesPracticeModeType m_SeriesPracticeMode;

        /// <summary>系列施設コード</summary>
        private string m_LocalSeriesCode;
        // 系列施設対応 ここまで 大星憲士 2012/11/13

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        /// <summary>通信先系列施設コード</summary>
        private string m_ConnectSeriesCode;

        // 2015/04/21 中村 Redmine#4251対応
        /// <summary>処理対象の系列施設コード</summary>
        private string m_TargetSeriesCode = string.Empty;

        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

        // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 START
        // IFエッジサービスのIP
        private string m_IFEdgeIPAddress = string.Empty;

        // IFエッジサービスのポートNo
        private int m_IFEdgePortNo = 0;

        // LOCAL_INI_DATA
        private XmlNodeList m_xmlLOCAL_INI_DATA = null;

        // SYS_INI_DATA
        private XmlNodeList m_xmlSYS_INI_DATA = null;

        // EXEC_DATA
        private XmlNode m_xmlEXEC_DATA = null;
        // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 END

        #endregion

        #region "プロパティ"

        /// <summary>
        /// 連携ＩＤを取得します。
        /// </summary>  
        public virtual string CooperationID
        {
            get
            {
                if (this.m_xmlMstCoopId != null)
                {
                    return this.m_xmlMstCoopId["COOP_ID"].InnerText;
                }
                else
                {
                    return "";
                }
            }
        }

        /// <summary>
        /// この連携の処理区分を取得します。
        /// </summary>
        public virtual string ProcKind
        {
            get
            {
                if (this.m_xmlMstCoopId != null)
                {
                    return this.m_xmlMstCoopId["SEND_RACEIVE_CLASS"].InnerText;
                }
                else
                {
                    return "";
                }
            }
        }

        /// <summary>
        /// この連携の連携名称を取得します。
        /// </summary>
        public virtual string CooperationName
        {
            get
            {
                if (this.m_xmlMstCoopId != null)
                {
                    return this.m_xmlMstCoopId["COOP_NAME"].InnerText;
                }
                else
                {
                    return "";
                }
            }
        }

        /// <summary>
        /// この連携の連携機能名称を取得します。
        /// </summary>
        public virtual string FunctionName
        {
            get
            {
                if (this.m_xmlMstCoopId != null)
                {
                    return this.m_xmlMstCoopId["COOP_FUNCTION_NAME"].InnerText;
                }
                else
                {
                    return "";
                }
            }
        }

        /// <summary>
        /// この連携のキー情報定義を取得します。
        /// </summary>
        public virtual string KeyInfoDefine
        {
            get
            {
                if (this.m_xmlMstCoopId != null)
                {
                    return this.m_xmlMstCoopId["KEY_INFO_DEFINE"].InnerText;
                }
                else
                {
                    return "";
                }
            }
        }

        /// <summary>
        /// この連携の周期間隔（秒）を取得します。
        /// </summary>
        public virtual int Interval
        {
            get
            {
                if (this.m_xmlMstCoopId != null)
                {
                    return int.Parse(this.m_xmlMstCoopId["INTERVAL"].InnerText);
                }
                else
                {
                    return -1;
                }
            }
        }

        // 2015/06/24 中村 オーダ番号サイクリック対応 Add Start
        /// <summary>
        /// オーダ番号管理ＩＤを取得します。
        /// </summary>  
        public virtual string OrderNumberManageId
        {
            get
            {
                if (this.m_xmlMstCoopId != null)
                {
                    return this.m_xmlMstCoopId["ORDER_NUMBER_MANAGE_ID"].InnerText;
                }
                else
                {
                    return "";
                }
            }
        }
        // 2015/06/24 中村 オーダ番号サイクリック対応 Add End

        /// <summary>
        /// DBアクセスデリゲートを取得または設定します。
        /// </summary>
        public virtual DBAccessDelegate DBAccessDelegate
        {
            get { return this.m_dgtDBAccess; }
            set { this.m_dgtDBAccess = value; }
        }

        /// <summary>
        /// 自己停止用デリゲートを取得または設定します。
        /// </summary>
        public virtual SelfStopDelegate SelfStopDelegate
        {
            get { return this.m_dgtSelfStop; }
            set { this.m_dgtSelfStop = value; }
        }

        /// <summary>
        /// ログ出力デリゲートを取得または設定します。
        /// </summary>
        public OutLogDelegate OutLogDelegate
        {
            get { return this.m_log.OutLogDelegate; }
            set { this.m_log.OutLogDelegate = value; }
        }

        /// <summary>
        /// アラーム送信通知デリゲートを取得または設定します。
        /// </summary>
        public SendAlarmDelegate SendAlarmDelegate
        {
            get { return this.m_dgtSendAlarm; }
            set { this.m_dgtSendAlarm = value; }
        }

        /// <summary>
        /// メッセージ送信デリゲートを取得または設定します。
        /// </summary>
        public virtual RegistEventDelegate RegistEventDelegate
        {
            get { return this.m_dgtRegistEvent; }
            set { this.m_dgtRegistEvent = value; }
        }

        /// <summary>
        /// 状態変更通知デリゲートを取得または設定します。
        /// </summary>
        public virtual StatusInformationDelegate StatusInformationDelegate
        {
            get { return this.m_dgtStatusInformation; }
            set { this.m_dgtStatusInformation = value; }
        }

        /// <summary>
        /// 初期情報取得デリゲートを取得または設定します。
        /// </summary>
        public virtual GetInitialValueDelegate GetInitialValueDelegate
        {
            get { return this.m_dgtGetInitialValue; }
            set { this.m_dgtGetInitialValue = value; }
        }

        /// <summary>
        /// 初期情報設定デリゲートを取得または設定します。
        /// </summary>
        public virtual SetInitialValueDelegate SetInitialValueDelegate
        {
            get { return this.m_dgtSetInitialValue; }
            set { this.m_dgtSetInitialValue = value; }
        }

        /// <summary>
        /// 連携ID取得デリゲートを取得または設定します。
        /// </summary>
        public virtual GetCooperationIDDelegate GetCooperationIDDelegate
        {
            get { return this.m_dgtGetCooperationIDDelegate; }
            set { this.m_dgtGetCooperationIDDelegate = value; }
        }

        /// <summary>
        /// プラグインの状態を取得します。
        /// </summary>
        public virtual StatusCode Status
        {
            get { return this.m_statusCode; }
        }

        /// <summary>
        /// そのイベントを再度発行するかを取得または設定します。
        /// </summary>
        protected virtual bool EventRetry
        {
            get { return this.m_bolEventRetry; }
            set { this.m_bolEventRetry = value; }
        }

        /// <summary>
        /// 送信履歴テーブルのメモに書き込む文字列を取得または設定します。
        /// </summary>
        /// <remarks>
        /// 空の文字列が設定された場合は、空文字列で更新します。nullが設定された場合は、更新を行いません。<br />
        /// デフォルトはnullに設定されています。
        /// </remarks>
        protected virtual string SendHistMemo
        {
            get { return this.m_strSendHistMemo; }
            set { this.m_strSendHistMemo = value; }
        }

        // 系列施設対応 ここから 大星憲士 2012/11/13
        /// <summary>系列施設運用モード</summary>
        public SeriesPracticeModeType SeriesPracticeMode
        {
            set { m_SeriesPracticeMode = value; }
        }

        /// <summary>系列施設コード</summary>
        public string LocalSeriesCode
        {
            set { m_LocalSeriesCode = value; }
        }

        /// <summary>系列施設対応フラグ</summary>
        public bool IsSeriesSupported
        {
            get
            {
                if (m_SeriesPracticeMode == SeriesPracticeModeType.NOTSUPPORTED)
                {
                    return false;
                }
                else
                {
                    return true;
                }
            }
        }
        // 系列施設対応 ここまで 大星憲士 2012/11/13

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        /// <summary>通信先系列施設コード</summary>
        public string ConnectSeriesCode
        {
            set { m_ConnectSeriesCode = value; }
            get { return m_ConnectSeriesCode; }
        }
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

        // 2016/06/07 中村 サイクリック仕様変更 Add Start
        private string m_strOrderNoId = string.Empty;
        /// <summary>
        /// オーダ番号管理ID
        /// </summary>
        public string OrderNoId
        {
            set { m_strOrderNoId = value; }
        }

        private string m_strOrderNoMin = string.Empty;
        /// <summary>
        /// オーダ番号最小値
        /// </summary>
        public string OrderNoMin
        {
            set { m_strOrderNoMin = value; }
        }

        private string m_strOrderNoMax = string.Empty;
        /// <summary>
        /// オーダ番号最大値
        /// </summary>
        public string OrderNoMax
        {
            set { m_strOrderNoMax = value; }
        }
        // 2016/06/07 中村 サイクリック仕様変更 Add End 

        #endregion

        #region "コンストラクタ"

        /// <summary>
        /// Fn3ComPlugIn クラスの新しいインスタンスを初期化します。
        /// </summary>
        public Fn3ComPlugIn()
        {
            this.m_statusCode = StatusCode.Stopped;
            this.m_log = new Fn3CoopLog();
        }

        #endregion

        #region "メソッド"

        /// <summary>
        /// この連携を開始する。
        /// </summary>
        /// <returns>リターンコード</returns>
        public virtual Fn3ReturnCode StartCooperation()
        {
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            Fn3ReturnCode retCode = Fn3ReturnCode.Success;

            try
            {
                while (this.Status == StatusCode.Initialize || this.Status == StatusCode.Ready ||
                      this.Status == StatusCode.Execute || this.Status == StatusCode.TemporaryStop ||
                      this.Status == StatusCode.Stop)
                {
                    //  初期化中、起動準備中、実行中、中断中、終了中の場合は、各処理が終わるまで待機する。
                    System.Threading.Thread.Sleep(10);
                }

                //  状態を開始準備中にする。
                this.SetStatus(StatusCode.Ready);

                //  連携を開始する。
                retCode = this.Start();
            }
            catch (Exception ex)
            {
                retCode = Fn3ComPlugInReturnCode.StartCooperationException;
                this.ErrorTraceOut(retCode, ex, string.Format("CooperationID={0}", this.CooperationID));
                this.SetStatus(StatusCode.ErrorStop);
            }
            finally
            {
                if (retCode.IsError || retCode.IsException)
                {
                    //  ステータスを異常停止にする
                    this.SetStatus(StatusCode.ErrorStop);
                }
                else
                {
                    //  ステータスを待機中（起動中）にする
                    this.SetStatus(StatusCode.Standby);
                }

                this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            }

            return retCode;
        }

        /// <summary>
        /// イベント管理テーブル取得の1ポーリング単位の処理開始時に呼び出されます。
        /// イベント管理テーブルにイベントが存在しない場合は呼び出されません。
        /// </summary>
        /// <returns>リターンコード</returns>
        public virtual Fn3ReturnCode StartProcessCooperation()
        {
            Fn3ReturnCode retCode;

            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            try
            {
                retCode = this.StartProcess();
            }
            catch (Exception ex)
            {
                retCode = Fn3ComPlugInReturnCode.StartCooperationException;
                this.ErrorTraceOut(retCode, ex, string.Format("CooperationID={0}", this.CooperationID));
            }
            finally
            {
                this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            }

            return retCode;
        }

        /// <summary>
        /// 連携の開始処理を行い場合は、このメソッドをオーバーライドします。
        /// </summary>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode Start()
        {
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// イベント管理テーブル取得の1ポーリング単位の処理終了時に呼び出されます。
        /// イベント管理テーブルにイベントが存在しない場合は呼び出されません。
        /// </summary>
        public virtual void EndProcessCooperation()
        {
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            try
            {
                this.EndProcess();
            }
            catch (Exception ex)
            {
                Fn3ReturnCode retCode = Fn3ComPlugInReturnCode.StartCooperationException;
                this.ErrorTraceOut(retCode, ex, string.Format("CooperationID={0}", this.CooperationID));
            }
            finally
            {
                this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            }
        }

        /// <summary>
        /// この連携を停止する。
        /// </summary>
        public virtual void StopCooperation()
        {
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            try
            {
                this.m_bolAbortFlag = true;

                while (this.Status == StatusCode.Initialize || this.Status == StatusCode.Ready ||
                      this.Status == StatusCode.Execute || this.Status == StatusCode.TemporaryStop ||
                      this.Status == StatusCode.Stop)
                {
                    //  初期化中、起動準備中、実行中、中断中、終了中の場合は、各処理が終わるまで待機する。
                    System.Threading.Thread.Sleep(10);
                }

                //  状態を停止処理中にする
                this.SetStatus(StatusCode.TemporaryStop);

                //  連携を中断する。
                this.Stop();
            }
            catch (Exception ex)
            {
                this.ErrorTraceOut(Fn3ComPlugInReturnCode.StopCooperationException, ex, string.Format("CooperationID={0}", this.CooperationID));
            }
            finally
            {
                //  停止
                this.SetStatus(StatusCode.TemporaryStopped);

                //  フラグをおろす。
                this.m_bolAbortFlag = false;

                this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            }
        }

        private Fn3ReturnCode CanExecute()
        {
            if (this.Status != StatusCode.Standby || this.m_bolAbortFlag == true)
            {
                //  待機中ではない、または中断処理が行われている。
                return Fn3ComPlugInReturnCode.ExecuteStatusError;
            }
            else
            {
                //  待機中
                return Fn3ReturnCode.Success;
            }
        }

        /// <summary>
        /// DBの接続状態をチェックし、切断状態の場合は再接続を行う。
        /// </summary>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBCheckConnect()
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strXml = null;
            //object obj = null;
            //return this.m_dgtDBAccess(DBAccessType.CheckConnect, null, ref strXml, null, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// DBコミットを行う。
        /// </summary>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBCommit()
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strXml = null;
            //object obj = null;
            //return this.m_dgtDBAccess(DBAccessType.Commit, null, ref strXml, null, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// DBのクエリ実行を行う。
        /// </summary>
        /// <param name="strQueryId">クエリID</param>
        /// <param name="strInXml">入力パラメータ</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBExecQuery(string strQueryId, string strInXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strOutXml = null;
            //object obj = null;
            //return this.m_dgtDBAccess(DBAccessType.ExecQuery, strInXml, ref strOutXml, null, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// DBのクエリ実行を行う
        /// </summary>
        /// <param name="strQueryId">クエリID</param>
        /// <param name="strInXml">入力パラメータ</param>
        /// <param name="strOutXml">出力パラメータ</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBExecQuery(string strQueryId, string strInXml, ref string strOutXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 START
            try
            {
                strOutXml = System.Web.HttpUtility.HtmlDecode("<rootNode>" + m_xmlEXEC_DATA["A" + strQueryId].InnerXml + "</rootNode>");
            }
            catch
            {
                //  取得に失敗
                return Fn3ComPlugInReturnCode.GetInitialValueError;
            }

            return Fn3ComPlugInReturnCode.Success;
            // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 END

            // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 START
            //object obj = null;
            //// 2015/04/21 中村 Redmine#4251対応 Start
            //// return this.m_dgtDBAccess(DBAccessType.ExecQuery, strInXml, ref strOutXml, strQueryId, ref obj);
            //string[] strVal = new string[2];
            //strVal[0] = strQueryId;
            //strVal[1] = this.m_TargetSeriesCode;

            //return this.m_dgtDBAccess(DBAccessType.ExecQuery, strInXml, ref strOutXml, strVal, ref obj);
            //// 2015/04/21 中村 Redmine#4251対応 End
            // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 END
        }

        /// <summary>
        /// DBよりデータ読み込みを行う。
        /// </summary>
        /// <param name="strInXml">DB入力パラメータ</param>
        /// <param name="strOutXml">DB出力パラメータ</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBSelect(string strInXml, ref string strOutXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //return this.m_dgtDBAccess(DBAccessType.Select, strInXml, ref strOutXml, null, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 透析番号より透析スケジュールのオーダ情報を取得する。
        /// </summary>
        /// <param name="strDialysisNo">透析番号</param>
        /// <param name="strOutXml">出力XML</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBGetSchOrderInfo(string strDialysisNo, ref string strOutXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //return this.m_dgtDBAccess(DBAccessType.GetSchOrderInfo, null, ref strOutXml, strDialysisNo, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 患者IDと日付に該当する患者情報を取得する。
        /// </summary>
        /// <param name="strPatId">患者ID</param>
        /// <param name="strUpdate">更新日時　※NULLの場合は最新日時で検索</param>
        /// <param name="strOutXml">出力XML</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBGetPatInfo(string strPatId, string strUpdate, ref string strOutXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //// 2015/05/21 宮崎 Redmine#4625対応 Upd Start
            ////string[] strVal = new string[2];
            //string[] strVal = new string[3];
            //// 2015/05/21 宮崎 Redmine#4625対応 Upd End

            //strVal[0] = strPatId;
            //strVal[1] = strUpdate;
            //// 2015/05/18 中村 Redmine#4625対応 Add Start
            //if (!string.IsNullOrEmpty(this.m_TargetSeriesCode))
            //{
            //    // 対象系列施設コードが設定されている場合、対象系列施設コードを指定
            //    strVal[2] = this.m_TargetSeriesCode;
            //}
            //else
            //{
            //    // 対象系列施設コードが設定されていない場合、通信先系列施設コードを指定
            //    strVal[2] = this.m_ConnectSeriesCode;
            //}
            //// 2015/05/18 中村 Redmine#4625対応 Add End
            //return this.m_dgtDBAccess(DBAccessType.GetPatInfo, null, ref strOutXml, strVal, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 実績透析番号に該当する予約情報を取得する。
        /// </summary>
        /// <param name="strDialysisNo">透析番号</param>
        /// <param name="strOutXml">出力XML</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBGetDialysisScheduleInfo(string strDialysisNo, ref string strOutXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //// 2015/05/18 中村 Redmine#4625対応 Chg Start
            //// return this.m_dgtDBAccess(DBAccessType.GetDialysisScheduleInfo, null, ref strOutXml, strDialysisNo, ref obj);
            //string[] strVal = new string[2];
            //strVal[0] = strDialysisNo;
            //if (!string.IsNullOrEmpty(this.m_TargetSeriesCode))
            //{
            //    // 対象系列施設コードが設定されている場合、対象系列施設コードを指定
            //    strVal[1] = this.m_TargetSeriesCode;
            //}
            //else
            //{
            //    // 対象系列施設コードが設定されていない場合、通信先系列施設コードを指定
            //    strVal[1] = this.m_ConnectSeriesCode;
            //}
            //return this.m_dgtDBAccess(DBAccessType.GetDialysisScheduleInfo, null, ref strOutXml, strVal, ref obj);
            //// 2015/05/18 中村 Redmine#4625対応 Chg End
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 検査形式コードとコメントコードに紐づく検査コメントマスタレコードを取得する。
        /// </summary>
        /// <param name="strMethodCd">検査形式コード。</param>
        /// <param name="strCommentsCd">コメントコード。<br />
        /// nullの場合は、検査形式コードに紐づく検査コメントコードを全て取得
        /// </param>
        /// <param name="strOutXml">出力XMLデータ。</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBGetMstExaminComment(string strMethodCd, string strCommentsCd, ref string strOutXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //string[] strVal = new string[2];
            //strVal[0] = strMethodCd;
            //strVal[1] = strCommentsCd;
            //return this.m_dgtDBAccess(DBAccessType.GetMstExaminComment, null, ref strOutXml, strVal, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        // <5.0.0.101> 患者死亡時に指示系データを終了状態に更新する 2010.01.14 M.Aoki Add Start
        /// <summary>
        /// 患者死亡時に指示系データを終了状態に更新する。
        /// </summary>
        /// <param name="strDispPatid">表示用患者ＩＤ</param>
        /// <param name="strDate">開始日時（YYYYMMDD）<br />
        /// nullの場合は、現在の日付
        /// </param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBDeleteIndDate(string strDispPatid, string strDate)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strOutXml = null;
            //object obj = null;
            //string[] strVal = new string[2];
            //strVal[0] = strDispPatid;
            //strVal[1] = strDate;
            //return this.m_dgtDBAccess(DBAccessType.DeleteIndDate, null, ref strOutXml, strVal, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }
        // <5.0.0.101> 患者死亡時に指示系データを終了状態に更新する 2010.01.14 M.Aoki Add End

        /// <summary>
        /// 連携情報取得
        /// </summary>
        /// <param name="strFunctionName">連携機能名称</param>
        /// <param name="strKeyInfoXml">キー情報</param>
        /// <param name="strOutXml">DB出力パラメータ</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBSelectCoopInfo(string strFunctionName, string strKeyInfoXml, ref string strOutXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //// 2015/04/21 中村 Redmine#4251対応 Start
            //// return this.m_dgtDBAccess(DBAccessType.SelectCoopInfo, strKeyInfoXml, ref strOutXml, strFunctionName, ref obj);
            //string[] strVal = new string[2];
            //strVal[0] = strFunctionName;
            //strVal[1] = m_ConnectSeriesCode;
            //return this.m_dgtDBAccess(DBAccessType.SelectCoopInfo, strKeyInfoXml, ref strOutXml, strVal, ref obj);
            //// 2015/04/21 中村 Redmine#4251対応 End
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        // 2015/04/21 中村 Redmine#4251対応 Start
        /// <summary>
        /// 連携情報取得
        /// </summary>
        /// <param name="strFunctionName">連携機能名称</param>
        /// <param name="strKeyInfoXml">キー情報</param>
        /// <param name="strSeriesCode">系列施設コード</param>
        /// <param name="strOutXml">DB出力パラメータ</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBSelectCoopInfo(string strFunctionName, string strKeyInfoXml, string strSeriesCode, ref string strOutXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //string[] strVal = new string[2];
            //strVal[0] = strFunctionName;
            //strVal[1] = strSeriesCode;
            //return this.m_dgtDBAccess(DBAccessType.SelectCoopInfo, strKeyInfoXml, ref strOutXml, strVal, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }
        // 2015/04/21 中村 Redmine#4251対応 End

        // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 START
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// データ文字列をJSON形式文字列のエスケープシーケンス変換を行う
        /// </summary>
        /// <param name="strOrgText">変換前文字列</param>
        /// <returns>変換後文字列</returns>
        //----------------------------------------------------------------------------------------------------
        public static String ConvertJSONString(String strOrgText)
        {
            String strret = strOrgText;

            // エスケープシーケンス変換
            strret = strret.Replace(@"\", "{\\\\}");    // 最初に値を変えておく
            strret = strret.Replace(@"/", "\\/");
            strret = strret.Replace("\r", "\\r");
            strret = strret.Replace("\n", "\\n");
            //strret = strret.Replace("'", "\\'");
            strret = strret.Replace(@"""", @"\""");
            strret = strret.Replace("\t", "\\t");
            strret = strret.Replace("\b", "\\b");
            strret = strret.Replace("\f", "\\f");
            strret = strret.Replace("{\\\\}", "\\\\");  // 最後に正しい値をセット

            return (strret);
        }
        // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 END

        /// <summary>
        /// 連携情報更新
        /// </summary>
        /// <param name="strFunctionName">連携機能名称</param>
        /// <param name="strInXml">入力XML</param>
        /// <param name="intUpdateNum">更新レコード数</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBUpdateCoopInfo(string strFunctionName, string strInXml, ref int intUpdateNum)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 START
            //string strXml = null;
            //object obj = null;
            //// 2015/05/18 中村 Redmine#4625対応 Chg Start
            //// Fn3ReturnCode retCode = this.m_dgtDBAccessm_dgtDBAccess(DBAccessType.UpdateCoopInfo, strInXml, ref strXml, strFunctionName, ref obj);
            //string[] strVal = new string[2];
            //strVal[0] = strFunctionName;
            //if (!string.IsNullOrEmpty(this.m_TargetSeriesCode))
            //{
            //    // 対象系列施設コードが設定されている場合、対象系列施設コードを指定
            //    strVal[1] = this.m_TargetSeriesCode;
            //}
            //else
            //{
            //    // 対象系列施設コードが設定されていない場合、通信先系列施設コードを指定
            //    strVal[1] = this.m_ConnectSeriesCode;
            //}

            //Fn3ReturnCode retCode = this.m_dgtDBAccess(DBAccessType.UpdateCoopInfo, strInXml, ref strXml, strVal, ref obj);
            // 2015/05/18 中村 Redmine#4625対応 Chg End

            // intUpdateNum = (int)obj;
            //int[] iVal = (int[])obj;
            //intUpdateNum = iVal[0];

            // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 END

            // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 START
            // データの取得処理
            //ソケットサーバー
            Fn3SocketClient webDataGetAll = null;
            Fn3ReturnCode retCode = Fn3ReturnCode.Success;

            try
            {
                // 入力XMLに「処理区分（CRUD:）」を追加する
                if (!strInXml.Contains("<CRUD>") && !strInXml.Contains("</CRUD>"))
                {
                    int start = strInXml.IndexOf("<rootNode>") + "<rootNode>".Length;
                    string strInXmlNew = strInXml.Substring(0, start);
                    strInXmlNew = strInXmlNew + "<CRUD>1</CRUD>";
                    strInXmlNew = strInXmlNew + strInXml.Substring(start, strInXml.Length - start);
                    strInXml = strInXmlNew;
                }

                // ソケット接続
                webDataGetAll = new Fn3SocketClient(m_IFEdgeIPAddress, m_IFEdgePortNo);

                // ソケット接続
                retCode = webDataGetAll.Connect();
                if (!Fn3ReturnCode.Success.Equals(retCode))
                {
                    TraceOut(retCode, "Fn3SocketClient Connect ng.");
                    return retCode;
                }

                // 電文生成
                StringBuilder sendData = new StringBuilder();
                sendData.Append("{");
                String updateXml = String.Format("\"Dump\":\"{0}\"}}", ConvertJSONString(strInXml));
                sendData.Append(updateXml);

                String body = sendData.ToString();
                String head = String.Format("{0:D6}OKFN3:05000190001", Encoding.Default.GetBytes(body).Length + 23);

                // 文字列をバイト シーケンスにエンコードする
                byte[] bdata = Encoding.Default.GetBytes(head + body);

                // 電文送信
                retCode = webDataGetAll.Send(bdata, 0, bdata.Length);
                if (!Fn3ReturnCode.Success.Equals(retCode))
                {
                    TraceOut(retCode, "Fn3SocketClient Send ng.");
                    return retCode;
                }

                // ソケット切断
                webDataGetAll.Disconnect();
                webDataGetAll = null;
            }
            catch (Exception ex)
            {
                if (webDataGetAll != null && webDataGetAll.Connected)
                {
                    webDataGetAll.Disconnect();
                }
                webDataGetAll = null;

                retCode = Fn3ReturnCode.Exception;
                TraceOut(retCode, ex.StackTrace);

                return retCode;
            }
            finally
            {
                // ソケットが生成されている場合は、切断して終了
                if (webDataGetAll != null)
                {
                    // ソケット切断
                    webDataGetAll.Disconnect();
                }
                webDataGetAll = null;
            }

            String messageDump = String.Format("OutputData:[{0}]", strInXml);

            TraceOut(messageDump);

            //// データを取得する
            //Thread trdAll = new Thread(webDataGetAll.DoWork)
            //{
            //    Name = "データ更新スレッド"
            //};
            //trdAll.Start();

            retCode = Fn3ReturnCode.Success;
            // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 END

            return retCode;
        }

        // >>>>> 2012.02.27 M.Miyazaki API仕様変更対応
        /// <summary>
        /// 連携情報更新
        /// </summary>
        /// <param name="strFunctionName">連携機能名称</param>
        /// <param name="strInXml">入力XML</param>
        /// <param name="intUpdateNum">更新レコード数</param>
        /// <param name="intBedNumber">変更前ベッド番号</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBUpdateCoopInfo(string strFunctionName, string strInXml, ref int intUpdateNum, ref int intBedNumber)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strXml = null;
            //object obj = null;
            //// 2015/05/18 中村 Redmine#4625対応 Chg Start
            //// Fn3ReturnCode retCode = this.m_dgtDBAccess(DBAccessType.UpdateCoopInfo, strInXml, ref strXml, strFunctionName, ref obj);
            //string[] strVal = new string[2];
            //strVal[0] = strFunctionName;
            //if (!string.IsNullOrEmpty(this.m_TargetSeriesCode))
            //{
            //    // 対象系列施設コードが設定されている場合、対象系列施設コードを指定
            //    strVal[1] = this.m_TargetSeriesCode;
            //}
            //else
            //{
            //    // 対象系列施設コードが設定されていない場合、通信先系列施設コードを指定
            //    strVal[1] = this.m_ConnectSeriesCode;
            //}
            //Fn3ReturnCode retCode = this.m_dgtDBAccess(DBAccessType.UpdateCoopInfo, strInXml, ref strXml, strVal, ref obj);
            //// 2015/05/18 中村 Redmine#4625対応 Chg End

            //int[] iVal = (int[])obj;
            //intUpdateNum = iVal[0];
            //intBedNumber = iVal[1];

            //return retCode;
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }
        // <<<<< 2012.02.27 M.Miyazaki API仕様変更対応

        /// <summary>
        /// 送信履歴情報の取得
        /// </summary>
        /// <param name="strEventGroupNo">イベントグループ番号</param>
        /// <param name="strSendHistXml">DB出力パラメータ</param>
        /// <returns></returns>
        protected virtual Fn3ReturnCode DBGetSendHist(string strEventGroupNo, ref string strSendHistXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //return this.m_dgtDBAccess(DBAccessType.GetSendHist, null, ref strSendHistXml, strEventGroupNo, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// DBロールバックを行う。
        /// </summary>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBRollback()
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strXml = null;
            //object obj = null;
            //return this.m_dgtDBAccess(DBAccessType.Rollback, null, ref strXml, null, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// DBトランザクションを行う。
        /// </summary>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBTransaction()
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strXml = null;
            //object obj = null;
            //return this.m_dgtDBAccess(DBAccessType.Transaction, null, ref strXml, null, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// DB書き込みを行う。
        /// </summary>
        /// <param name="strInXml">XmlNode（入力）</param>
        /// <param name="intUpdateNum">更新レコード数を受け取るオブジェクト</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBUpdate(string strInXml, ref int intUpdateNum)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strXml = null;
            //object obj = null;

            //Fn3ReturnCode retCode = this.m_dgtDBAccess(DBAccessType.Update, strInXml, ref strXml, null, ref obj);

            //intUpdateNum = (int)obj;

            //return retCode;
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 送信履歴情報の更新を行う。
        /// </summary>
        /// <param name="strInXml">XmlNode（入力）</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBUpdateSendHist(string strInXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strXml = null;
            //object obj = null;

            //return this.m_dgtDBAccess(DBAccessType.UpdateSendHist, strInXml, ref strXml, null, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 最新のイベント情報を取得
        /// </summary>
        /// <param name="strDllName">DLL名</param>
        /// <param name="strSpecificKey">特定キー</param>
        /// <param name="strEventInfo">イベント情報</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBGetLatestEventInfo(string strDllName, string strSpecificKey, ref string strEventInfo)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string[] strIn = new string[2];
            //strIn[0] = strDllName;
            //strIn[1] = strSpecificKey;
            //object obj = null;

            //return this.m_dgtDBAccess(DBAccessType.GetLatestEventInfo, null, ref strEventInfo, strIn, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 最新のイベントが処理済であるかをチェック
        /// </summary>
        /// <param name="strDllName">DLL名</param>
        /// <param name="strSpecificKey">特定キー</param>
        /// <param name="bolIsProc">true：処理済　false：未処理（リトライ含む）　イベントが未登録（=新規）の場合はtrue。</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBCheckLatestEventProc(string strDllName, string strSpecificKey, out bool bolIsProc)
        {
            bolIsProc = false;

            try
            {
                Fn3ReturnCode retCode;
                string strEventInfo = "";

                retCode = this.DBGetLatestEventInfo(strDllName, strSpecificKey, ref strEventInfo);
                if (retCode.IsError || retCode.IsException)
                {
                    //  取得失敗
                    return retCode;
                }

                //  取得XMLよりイベント管理の処理フラグと、送信履歴の送信ステータスを取得
                XmlDocument doc = new XmlDocument();
                doc.LoadXml(strEventInfo);
                string strProcFlg = Fn3ComTool.GetXmlValue(doc, "//rootNode/COP_EVENT_MANAGE/PROC_FLG");
                string strSendStatus = Fn3ComTool.GetXmlValue(doc, "//rootNode/COP_COOP_SEND_HST/SEND_STATE");

                if (string.IsNullOrEmpty(strProcFlg))
                {
                    //  イベントなし（新規）
                    bolIsProc = true;
                }
                else if (strProcFlg.Equals("1") && strSendStatus.Equals("1"))
                {
                    //  処理済、送信済み
                    bolIsProc = true;
                }
                else
                {
                    //  上記以外
                    bolIsProc = false;
                }

                return Fn3ReturnCode.Success;
            }
            catch (Exception ex)
            {
                Fn3ReturnCode retCode = Fn3ComPlugInReturnCode.StartCooperationException;
                this.ErrorTraceOut(retCode, ex, string.Format("CooperationID={0}", this.CooperationID));
                return retCode;
            }
        }

        /// <summary>
        /// 体重情報を取得
        /// </summary>
        /// <param name="strDispPatid">表示用患者ID</param>
        /// <param name="strExamDate">検査日(YYYY/MM/DD)</param>
        /// <param name="strWeightInfo">出力XMLデータ</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBGetWeightInfo(string strDispPatid, string strExamDate, ref string strWeightInfo)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //string[] strVal = new string[2];
            //strVal[0] = strDispPatid;
            //strVal[1] = strExamDate;

            //return this.m_dgtDBAccess(DBAccessType.GetWeightInfo, null, ref strWeightInfo, strVal, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// この連携の処理を行う。
        /// </summary>
        /// <param name="strEventMngXml">イベントマネージャー情報を保持しているstring</param>
        /// <returns>リターンコード</returns>
        public virtual Fn3ReturnCode ExecuteCooperation(string strEventMngXml)
        {
            // 2015/04/21 中村 Redmine#4251対応
            return this.ExecuteCooperation(strEventMngXml, m_ConnectSeriesCode);
        }

        // 2015/04/21 中村 Redmine#4251対応 Start
        /// <summary>
        /// この連携の処理を行う。
        /// </summary>
        /// <param name="strEventMngXml">イベントマネージャー情報を保持しているstring</param>
        /// <param name="strSeriesCode">系列施設コード</param>
        /// <returns>リターンコード</returns>
        public virtual Fn3ReturnCode ExecuteCooperation(string strEventMngXml, string strSeriesCode)
        {
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            Fn3ReturnCode retCode = Fn3ReturnCode.Success;
            Fn3ReturnCode retExecute;

            Fn3ExecuteInfo exeInfo;

            XmlDocument xmlEventMngRoot = null;
            XmlNode xmlEventMng = null;

            string strKeyInfo;
            string strFunctionName;
            string strSpecificKey;
            string strEventGroupNo;

            this.EventRetry = false;

            // 2011/10/17 中村 障害対応（#196） NULL初期化するよう修正。
            this.SendHistMemo = null;

            // 2015/04/21 中村 Redmine#4251対応
            this.m_TargetSeriesCode = strSeriesCode;

            try
            {
                xmlEventMngRoot = new XmlDocument();
                xmlEventMngRoot.LoadXml(strEventMngXml);
                xmlEventMng = xmlEventMngRoot.SelectSingleNode("COP_EVENT_MANAGE");

                strKeyInfo = xmlEventMng["KEY_INFO"].InnerText;                     //  キー情報
                strFunctionName = xmlEventMng["COOP_FUNCTION_NAME"].InnerText;      //  連携機能名称
                strSpecificKey = xmlEventMng["SPECIFIC_KEY"].InnerText;             //  特定キー
                strEventGroupNo = xmlEventMng["EVENT_GROUP_NO"].InnerText;          //  イベントグループ番号

                // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 START
                // IFエッジサービスのIP
                m_IFEdgeIPAddress = xmlEventMng["IFEdgeIPAddress"].InnerText;

                // IFエッジサービスのポートNo
                m_IFEdgePortNo = int.Parse(xmlEventMng["IFEdgePortNo"].InnerText);
                // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 END

                retCode = this.CanExecute();
                if (retCode.IsError || retCode.IsException)
                {
                    //  実行不可
                    TraceOut(retCode, string.Format("COOP_ID={0}, EVENT_GROUP_NO={1}, SPECIFIC_KEY={2}", this.CooperationID, strEventGroupNo, strSpecificKey));
                    return retCode;
                }

                try
                {
                    //  状態を処理中にする。
                    this.SetStatus(StatusCode.Execute);

                    // 2016/06/07 中村 サイクリック仕様変更 Add Start
                    if (!string.IsNullOrEmpty(m_strOrderNoId) &&
                        string.IsNullOrEmpty(xmlEventMng["ORDER_NUMBER"].InnerText))
                    {
                        // オーダ番号取得
                        string strOrderNo;
                        retCode = GetOrderNumber(xmlEventMng, out strOrderNo);
                        if (!retCode.IsSuccess)
                        {
                            return retCode;
                        }

                        // 採番した番号で、イベント管理情報XMLを更新
                        xmlEventMng["ORDER_NUMBER"].InnerText = strOrderNo;
                        strEventMngXml = xmlEventMngRoot.DocumentElement.OuterXml;
                    }
                    // 2016/06/07 中村 サイクリック仕様変更 Add End

                    exeInfo = new Fn3ExecuteInfo();

                    //  実行情報にイベント管理情報を追加
                    retCode = exeInfo.SetEventManagerXml(strEventMngXml);
                    if (retCode.IsError || retCode.IsException)
                    {
                        //  イベント管理XMLの読み込み失敗
                        TraceOut(retCode);
                        return retCode;
                    }


                    //  送信履歴テーブルを取得する。
                    string strSendHistXml = null;

                    // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 START
                    strSendHistXml = xmlEventMng["EVENT_COOP_SEND_HST"].InnerXml;
                    // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 END

                    // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 START
                    //retCode = this.DBGetSendHist(strEventGroupNo, ref strSendHistXml);
                    //if (retCode.IsError || retCode.IsException)
                    //{
                    //    TraceOut(retCode, string.Format("COOP_ID={0}, EVENT_GROUP_NO={1}, SPECIFIC_KEY={2}", this.CooperationID, strEventGroupNo, strSpecificKey));
                    //    return retCode;
                    //}
                    // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 END

                    //  実行情報に送信履歴情報を追加
                    retCode = exeInfo.SetSendHistXml(strSendHistXml);
                    if (retCode.IsError || retCode.IsException)
                    {
                        //  送信履歴XMLの読み込み失敗
                        TraceOut(retCode, string.Format("COOP_ID={0}, EVENT_GROUP_NO={1}, SPECIFIC_KEY={2}", this.CooperationID, strEventGroupNo, strSpecificKey));
                        return retCode;
                    }

                    // 連携関連情報を取得する
                    string strCoopInfo = null;
                    // 2015/04/21 中村 Redmine#4251対応 Start
                    // retCode = this.DBSelectCoopInfo(strFunctionName, strKeyInfo, ref strCoopInfo);
                    // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 START
                    //retCode = this.DBSelectCoopInfo(strFunctionName, strKeyInfo, strSeriesCode, ref strCoopInfo);
                    // 2015/04/21 中村 Redmine#4251対応 End
                    //if (retCode.IsError || retCode.IsException)
                    //{
                    //    //  連携関連情報の取得失敗
                    //    TraceOut(retCode, string.Format("COOP_ID={0}, COOP_FUNCTION_NAME={1}, KEY_INFO={2}", this.CooperationID, strFunctionName, strKeyInfo));

                    //    //  送信履歴テーブルの更新
                    //    this.UpdateSendHist(exeInfo, retCode);

                    //    return retCode;
                    //}
                    // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 END

                    //  実行情報に連携情報を追加
                    // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 START
                    strCoopInfo = xmlEventMng["EVENT_COOP_INFO"].InnerXml;
                    // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 END

                    retCode = exeInfo.SetCoopInfoXml(strCoopInfo);
                    if (retCode.IsError || retCode.IsException)
                    {
                        //  連携関連情報XMLの読み込み失敗
                        TraceOut(retCode, string.Format("COOP_ID={0}, COOP_FUNCTION_NAME={1}, KEY_INFO={2}", this.CooperationID, strFunctionName, strKeyInfo));

                        //  送信履歴テーブルの更新
                        // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 START
                        //this.UpdateSendHist(exeInfo, retCode);
                        // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 END

                        return retCode;
                    }

                    // 送信履歴メモをセットする
                    this.SendHistMemo = exeInfo.SendHistMemo;

                    //  連携の処理を行う。
                    retExecute = this.Execute(exeInfo);

                    //  送信履歴の更新
                    // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 START
                    // retCode = this.UpdateSendHist(exeInfo, retExecute);
                    // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 END

                    //  連携機能名称が「透析実績」で送信成功している場合（送信履歴の更新に失敗してもレポート送信は行う）
                    if (strFunctionName.Equals("透析実績") && (retExecute.IsSuccess || retExecute.IsWarning))
                    {
                        var rpRetCode = this.ReportProcess(exeInfo);
                        
                        if(!rpRetCode.IsSuccess)
                        {
                            retExecute = rpRetCode;
                        }
                    }

                    //  連携処理が失敗していた場合はリターンコードはその情報を戻す。
                    retCode = retExecute;
                }
                catch (Exception ex)
                {
                    retCode = Fn3ComPlugInReturnCode.ExecuteCooperationException;
                    this.ErrorTraceOut(retCode, ex, string.Format("CooperationID={0}", this.CooperationID));
                }
                finally
                {
                    this.EventRetry = false;

                    if (this.Status == StatusCode.Execute)
                    {
                        //  処理終了（状態を待機にする）
                        this.SetStatus(StatusCode.Standby);
                    }
                }
            }
            catch (Exception ex)
            {
                retCode = Fn3ComPlugInReturnCode.ExecuteCooperationException;
                this.ErrorTraceOut(retCode, ex, string.Format("CooperationID={0}", this.CooperationID));
            }
            finally
            {
                // 2015/04/21 中村 Redmine#4251対応
                this.m_TargetSeriesCode = string.Empty;

                this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            }

            return retCode;
        }
        // 2015/04/21 中村 Redmine#4251対応 End

        /// <summary>
        /// レポート処理を行う。
        /// </summary>
        /// <param name="exeInfo">実行情報</param>
        /// <returns></returns>
        private Fn3ReturnCode ReportProcess(Fn3ExecuteInfo exeInfo)
        {
            Fn3ReturnCode retCode;

            bool bolUseRepStore = false;

            string strUseReportStore = "";

            //  初期設定マスタよりPDF作成設定を取得する。
            retCode = this.GetInitialValue("0", "REPORT_INFO", "USE_REPORT_STORE", ref strUseReportStore);
            if (retCode.IsError || retCode.IsException)
            {
                retCode = Fn3ComPlugInReturnCode.UseReportStoreValueNotFound;
                TraceOut(retCode, string.Format("COOP_ID={0} SPECIFIC_KEY={1}", this.CooperationID, exeInfo.SpecificKey));
                return retCode;
            }

            bolUseRepStore = (strUseReportStore.Equals("1") ? true : false);

            if (bolUseRepStore == false)
            {
                //  レポートストアを使用しない場合は処理終了
                return Fn3ReturnCode.Success;
            }

            string strSendPDF = null;
            retCode = this.GetInitialValue("0", "REPORT_INFO", "SEND", ref strSendPDF);
            if (retCode.IsError || retCode.IsException)
            {
                retCode = Fn3ComPlugInReturnCode.ReportSendValueNotFound;
                TraceOut(retCode, string.Format("COOP_ID={0} SPECIFIC_KEY={1}", this.CooperationID, exeInfo.SpecificKey));
                return retCode;
            }

            //  ReportStoreのDll名を取得
            string strReportStoreDllName = "";
            retCode = this.GetInitialValue("0", "REPORT_INFO", "REPORT_STORE_DLL_NAME", ref strReportStoreDllName);
            if (retCode.IsError || retCode.IsException || strReportStoreDllName.Equals(""))
            {
                retCode = Fn3ComPlugInReturnCode.ReportStoreNameNotFound;
                TraceOut(retCode, string.Format("COOP_ID={0} SPECIFIC_KEY={1}", this.CooperationID, exeInfo.SpecificKey));
                return retCode;
            }

            string strEventType = exeInfo.SendClass;        //  イベント区分に送信履歴の送信区分を設定する。

            Hashtable hashKeyInfo = new Hashtable();

            //  キー情報を解析し、ハッシュテーブルに登録する。
            XmlDocument xmlKeyInfo = new XmlDocument();
            xmlKeyInfo.LoadXml(exeInfo.KeyInfo);

            foreach (XmlNode node in xmlKeyInfo.SelectSingleNode(this.FunctionName).ChildNodes)
            {
                string strName = node.Name;
                string strValue = node.InnerText;
                hashKeyInfo.Add(strName, strValue);
            }

            //  実績の連携情報よりPDFファイル名を生成する。
            string strPDFFileName = this.CreatePDFName(exeInfo);
            if (strPDFFileName == null)
            {
                return Fn3ComPlugInReturnCode.CreatePDFNameError;
            }

            //  透析レポートのイベント追加を行う。
            return this.RegistEvent(strReportStoreDllName, strEventType, hashKeyInfo, exeInfo.SpecificKey, strPDFFileName, false);
        }

        /// <summary>
        /// PDF名を生成する
        /// </summary>
        /// <param name="exeInfo">実行情報</param>
        /// <returns>PDF名。生成失敗時はnull。</returns>
        private string CreatePDFName(Fn3ExecuteInfo exeInfo)
        {
            XmlNode xmlTempNode;

            //  患者ID取得
            // 2010/09/01 YSK中村 PDFのファイル名変更（表示用患者ID+透析番号+版番号）。
#if false
            xmlTempNode = exeInfo.CoopInfoXML.SelectSingleNode("rootNode/PAT_BASIC_INFO/PATID");
            if(xmlTempNode == null || xmlTempNode.InnerText == "")
            {
                this.TraceOut("連携情報より患者IDの取得に失敗したため、レポートストアのイベント登録に失敗しました。");
                return null;
            }

            string strPatID = xmlTempNode.InnerText;
            strPatID = strPatID.PadLeft(12, '0');
            strPatID = strPatID.Substring(strPatID.Length - 12);
#endif
            xmlTempNode = exeInfo.CoopInfoXML.SelectSingleNode("rootNode/PAT_BASIC_INFO/DISP_PATID");
            if (xmlTempNode == null || xmlTempNode.InnerText == "")
            {
                this.TraceOut("連携情報より表示用患者IDの取得に失敗したため、レポートストアのイベント登録に失敗しました。");
                return null;
            }

            string strPatID = xmlTempNode.InnerText;
            strPatID = strPatID.Trim();
            strPatID = strPatID.TrimStart('0');

            //  透析番号取得
            xmlTempNode = exeInfo.CoopInfoXML.SelectSingleNode("rootNode/RST_DIALYSIS_HST/DIALYSIS_NO");
            if (xmlTempNode == null || xmlTempNode.InnerText == "")
            {
                this.TraceOut("連携情報より透析番号の取得に失敗したため、レポートストアのイベント登録に失敗しました。");
                return null;
            }
            string strDialysisNo = xmlTempNode.InnerText;
            strDialysisNo = strDialysisNo.PadLeft(12, '0');
            strDialysisNo = strDialysisNo.Substring(strDialysisNo.Length - 12);

            //  版番取得
            xmlTempNode = exeInfo.CoopInfoXML.SelectSingleNode("rootNode/RST_DIALYSIS_HST/EDITION");
            if (xmlTempNode == null || xmlTempNode.InnerText == "")
            {
                this.TraceOut("連携情報より版番号の取得に失敗したため、レポートストアのイベント登録に失敗しました。");
                return null;
            }
            string strEdition = xmlTempNode.InnerText;
            strEdition = strEdition.PadLeft(4, '0');
            strEdition = strEdition.Substring(strEdition.Length - 4);

            return string.Format("{0}{1}{2}.pdf", strPatID, strDialysisNo, strEdition);

        }

        /// <summary>
        /// 自己停止の要求を行います。
        /// </summary>
        protected virtual void SelfStop()
        {
            this.SetStatus(StatusCode.ErrorStop);
            this.m_dgtSelfStop();
        }

        /// <summary>
        /// イベント管理テーブルにレコード追加を依頼します。
        /// </summary>
        /// <param name="strPlugInDllFileName">プラグインDLLファイル名</param>
        /// <param name="strEventType">イベント区分　"0"：登録 "1"：変更 "2"：削除 "3"：その他 "4"：依頼要求</param>
        /// <param name="hashKeyInfo">キー情報</param>
        /// <param name="strSpecificKey">特定キー</param>
        /// <param name="strMemo">フリーコメント</param>
        /// <param name="waitFlag">他DLL処理待機フラグ</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode RegistEvent(string strPlugInDllFileName, string strEventType, Hashtable hashKeyInfo, string strSpecificKey, string strMemo, bool waitFlag)
        {
            // 2015/04/21 中村 Redmine#4251対応 Start
            // if (this.m_dgtRegistEvent(strPlugInDllFileName, MessageType.EventEntry, strEventType, hashKeyInfo, strSpecificKey, strMemo, waitFlag, m_ConnectSeriesCode, DateTime.Now) == true)
            string strSeriesCode = m_ConnectSeriesCode;
            if (!string.IsNullOrEmpty(this.m_TargetSeriesCode))
            {
                strSeriesCode = this.m_TargetSeriesCode;
            }
            if (this.m_dgtRegistEvent(strPlugInDllFileName, MessageType.EventEntry, strEventType, hashKeyInfo, strSpecificKey, strMemo, waitFlag, strSeriesCode, DateTime.Now) == true)
            // 2015/04/21 中村 Redmine#4251対応 End
            {
                return Fn3ReturnCode.Success;
            }
            else
            {
                return Fn3ComPlugInReturnCode.SendMessageError;
            }
        }

        // 2015/04/21 中村 Redmine#4251対応 Start
        /// <summary>
        /// イベント管理テーブルにレコード追加を依頼します。
        /// </summary>
        /// <param name="strPlugInDllFileName">プラグインDLLファイル名</param>
        /// <param name="strEventType">イベント区分　"0"：登録 "1"：変更 "2"：削除 "3"：その他 "4"：依頼要求</param>
        /// <param name="hashKeyInfo">キー情報</param>
        /// <param name="strSpecificKey">特定キー</param>
        /// <param name="strMemo">フリーコメント</param>
        /// <param name="waitFlag">他DLL処理待機フラグ</param>
        /// <param name="strSeriesCode">系列施設コード</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode RegistEvent(string strPlugInDllFileName, string strEventType, Hashtable hashKeyInfo, string strSpecificKey, string strMemo, bool waitFlag, string strSeriesCode)
        {
            if (this.m_dgtRegistEvent(strPlugInDllFileName, MessageType.EventEntry, strEventType, hashKeyInfo, strSpecificKey, strMemo, waitFlag, strSeriesCode, DateTime.Now) == true)
            {
                return Fn3ReturnCode.Success;
            }
            else
            {
                return Fn3ComPlugInReturnCode.SendMessageError;
            }
        }
        // 2015/04/21 中村 Redmine#4251対応 End

        // 2014/09/12 Add Start 阿部 イベント管理テーブルの対象日指定対応
        /// <summary>
        /// イベント管理テーブルにレコード追加を依頼します。
        /// </summary>
        /// <param name="strPlugInDllFileName">プラグインDLLファイル名</param>
        /// <param name="strEventType">イベント区分　"0"：登録 "1"：変更 "2"：削除 "3"：その他 "4"：依頼要求</param>
        /// <param name="hashKeyInfo">キー情報</param>
        /// <param name="strSpecificKey">特定キー</param>
        /// <param name="strMemo">フリーコメント</param>
        /// <param name="waitFlag">他DLL処理待機フラグ</param>
        /// <param name="dtTargetDate">対象日(イベント管理テーブルのTARGET_DATEとして指定する)</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode RegistEvent(string strPlugInDllFileName, string strEventType, Hashtable hashKeyInfo, string strSpecificKey, string strMemo, bool waitFlag, DateTime dtTargetDate)
        {
            // 2015/04/21 中村 Redmine#4251対応 Start
            // if (this.m_dgtRegistEvent(strPlugInDllFileName, MessageType.EventEntry, strEventType, hashKeyInfo, strSpecificKey, strMemo, waitFlag, m_ConnectSeriesCode, dtTargetDate) == true)
            string strSeriesCode = m_ConnectSeriesCode;
            if (!string.IsNullOrEmpty(this.m_TargetSeriesCode))
            {
                strSeriesCode = this.m_TargetSeriesCode;
            }
            if (this.m_dgtRegistEvent(strPlugInDllFileName, MessageType.EventEntry, strEventType, hashKeyInfo, strSpecificKey, strMemo, waitFlag, strSeriesCode, dtTargetDate) == true)
            // 2015/04/21 中村 Redmine#4251対応 End
            {
                return Fn3ReturnCode.Success;
            }
            else
            {
                return Fn3ComPlugInReturnCode.SendMessageError;
            }
        }
        // 2014/09/12 Add End 阿部 イベント管理テーブルの対象日指定対応

        // 2015/04/21 中村 Redmine#4251対応 Start
        /// <summary>
        /// イベント管理テーブルにレコード追加を依頼します。
        /// </summary>
        /// <param name="strPlugInDllFileName">プラグインDLLファイル名</param>
        /// <param name="strEventType">イベント区分　"0"：登録 "1"：変更 "2"：削除 "3"：その他 "4"：依頼要求</param>
        /// <param name="hashKeyInfo">キー情報</param>
        /// <param name="strSpecificKey">特定キー</param>
        /// <param name="strMemo">フリーコメント</param>
        /// <param name="waitFlag">他DLL処理待機フラグ</param>
        /// <param name="strSeriesCode">系列施設コード</param>
        /// <param name="dtTargetDate">対象日(イベント管理テーブルのTARGET_DATEとして指定する)</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode RegistEvent(string strPlugInDllFileName, string strEventType, Hashtable hashKeyInfo, string strSpecificKey, string strMemo, bool waitFlag, string strSeriesCode, DateTime dtTargetDate)
        {
            if (this.m_dgtRegistEvent(strPlugInDllFileName, MessageType.EventEntry, strEventType, hashKeyInfo, strSpecificKey, strMemo, waitFlag, strSeriesCode, dtTargetDate) == true)
            {
                return Fn3ReturnCode.Success;
            }
            else
            {
                return Fn3ComPlugInReturnCode.SendMessageError;
            }
        }
        // 2015/04/21 中村 Redmine#4251対応 End

        /// <summary>
        /// 送信履歴情報を更新する
        /// </summary>
        /// <param name="exeInfo">連携実行情報</param>
        /// <param name="retExecute">連携処理実行時のリターンコード</param>
        /// <returns>リターンコード</returns>
        private Fn3ReturnCode UpdateSendHist(Fn3ExecuteInfo exeInfo, Fn3ReturnCode retExecute)
        {
            Fn3ReturnCode retCode = Fn3ReturnCode.Success;
            string strSendHistXml;
            string strSendStatus = "";

            //  送信履歴更新
            string strNow = Fn3ComTool.DateTimeToString(DateTime.Now);

            using (StringWriter sw = new StringWriter())
            {
                XmlTextWriter writer = new XmlTextWriter(sw);

                writer.WriteStartElement("rootNode");
                writer.WriteStartElement("COP_COOP_SEND_HST_DETAIL");
                writer.WriteElementString("COOP_ID", this.CooperationID);
                writer.WriteElementString("EVENT_GROUP_NO", exeInfo.EventGroupNo);
                writer.WriteElementString("PROC_DATE", strNow);
                writer.WriteElementString("SEND_CLASS", exeInfo.SendClass);
                if (this.EventRetry == false)
                {
                    if (retExecute.IsError || retExecute.IsException)
                    {
                        //  送信失敗の場合はSendStatusを2に更新
                        strSendStatus = "2";
                    }
                    else
                    {
                        //  送信成功の場合はSendStatusを1に更新
                        strSendStatus = "1";
                    }
                }
                else
                {
                    //  イベントをリトライする場合は設定の場合は、未送信を設定
                    strSendStatus = "0";
                }
                writer.WriteElementString("SEND_STATE", strSendStatus);
                writer.WriteElementString("EVENT_OCCUR_DATE", Fn3ComTool.DateTimeToString(exeInfo.OccurDate));
                writer.WriteElementString("EVENT_SEQ_NUMBER", exeInfo.SeqNumber.ToString());
                writer.WriteElementString("MEMO", retExecute.Message);
                writer.WriteElementString("RESERVE", exeInfo.SendHistReserve);

                // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
                if (IsSeriesSupported)
                {
                    writer.WriteElementString("SERIES_CD", exeInfo.SeriesCD);
                }
                // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

                writer.WriteEndElement();

                // 送信履歴テーブルの情報を更新
                writer.WriteStartElement("COP_COOP_SEND_HST");
                // 特定キー
                writer.WriteElementString("SPECIFIC_KEY", exeInfo.SpecificKey);
                // メモ情報の追加
                if (this.SendHistMemo != null)
                {
                    writer.WriteElementString("MEMO", this.SendHistMemo);
                }

                // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
                if (IsSeriesSupported)
                {
                    writer.WriteElementString("SERIES_CD", exeInfo.SeriesCD);
                }
                // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

                writer.WriteEndElement();

                writer.WriteEndElement();

                writer.Close();

                strSendHistXml = sw.ToString();
            }

            bool bolTransaction = false;

            retCode = this.DBTransaction();
            if (retCode.IsError || retCode.IsException)
            {
                this.TraceOut(retCode, string.Format("COOP_ID={0} SPECIFIC_KEY={1} PROC_DATE={2}", this.CooperationID, exeInfo.SpecificKey, strNow));
                return retCode;
            }

            bolTransaction = true;

            try
            {
                retCode = this.DBUpdateSendHist(strSendHistXml);
                if (retCode.IsError || retCode.IsException)
                {
                    //  更新失敗
                    this.TraceOut(retCode, string.Format("COOP_ID={0} SPECIFIC_KEY={1} PROC_DATE={2}", this.CooperationID, exeInfo.SpecificKey, strNow));
                }
                else
                {
                    //  更新成功
                    retCode = DBCommit();
                    if (retCode.IsError || retCode.IsException)
                    {
                        //  コミット失敗
                        this.TraceOut(retCode, string.Format("COOP_ID={0} SPECIFIC_KEY={1} PROC_DATE={2}", this.CooperationID, exeInfo.SpecificKey, strNow));
                    }
                    else
                    {
                        //  コミット成功
                        bolTransaction = false;

                        //  変更履歴追加
                        StringBuilder strChgLog = new StringBuilder();
                        strChgLog.Append("IF;");
                        strChgLog.AppendFormat("KEY;COP_COOP_SEND_HST_DETAIL.COOP_ID;{0};COP_COOP_SEND_HST_DETAIL.SPECIFIC_KEY;{1};COP_COOP_SEND_HST_DETAIL.PROC_DATE;{2};", this.CooperationID, exeInfo.SpecificKey, strNow);
                        strChgLog.AppendFormat("VALUE;COP_COOP_SEND_HST_DETAIL.SEND_STATUS;{0};COP_COOP_SEND_HST_DETAIL.MEMO;{1}", strSendStatus, retExecute.Message);
                        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
                        #region 系列施設複数連携対応
                        //this.m_log.ChangeLogOut(ChangeLogType1.Etc, ChangeLogType2.None, "", "", strChgLog.ToString());
                        #endregion //系列施設複数連携対応

                        LogParameter logParameter = new LogParameter();
                        logParameter.SetProcessID(ConnectSeriesCode, CooperationID, "3");
                        this.m_log.ChangeLogOut(logParameter, ChangeLogType1.Etc, ChangeLogType2.None, "", "", strChgLog.ToString());
                        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

                        if (this.SendHistMemo != null)
                        {
                            strChgLog.Remove(0, strChgLog.Length);
                            strChgLog.Append("IF;");
                            strChgLog.AppendFormat("KEY;COP_COOP_SEND_HST.COOP_ID;{0};COP_COOP_SEND_HST.SPECIFIC_KEY;{1};", this.CooperationID, exeInfo.SpecificKey);
                            strChgLog.AppendFormat("VALUE;COP_COOP_SEND_HST.MEMO;{0}", this.SendHistMemo);
                            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
                            #region 系列施設複数連携対応
                            //this.m_log.ChangeLogOut(ChangeLogType1.Etc, ChangeLogType2.None, "", "", strChgLog.ToString());
                            #endregion //系列施設複数連携対応

                            logParameter = new LogParameter();
                            logParameter.SetProcessID(ConnectSeriesCode, CooperationID, "3");
                            this.m_log.ChangeLogOut(logParameter, ChangeLogType1.Etc, ChangeLogType2.None, "", "", strChgLog.ToString());
                            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                retCode = Fn3ComPlugInReturnCode.ExecuteCooperationException;
                this.ErrorTraceOut(retCode, ex, string.Format("トランザクション中だったためロールバックを行います。 COOP_ID={0} SPECIFIC_KEY={1} PROC_DATE={2}", this.CooperationID, exeInfo.SpecificKey, strNow));
            }
            finally
            {
                if (bolTransaction == true)
                {
                    //  トランザクション中であった場合ロールバックを行う。
                    retCode = this.DBRollback();
                    if (retCode.IsError || retCode.IsException)
                    {
                        //  ロールバック失敗失敗
                        this.TraceOut(retCode, string.Format("COOP_ID={0} SPECIFIC_KEY={1} PROC_DATE={2}", this.CooperationID, exeInfo.SpecificKey, strNow));
                    }
                }
            }

            return retCode;
        }

        /// <summary>
        /// この連携を初期化する。
        /// </summary>
        /// <param name="strMstCoopId">連携IDマスタ情報</param>
        /// <returns>処理成功時は0</returns>
        public virtual Fn3ReturnCode InitializeCooperation(string strMstCoopId)
        {
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            Fn3ReturnCode retCode = Fn3ReturnCode.Success;
            XmlDocument xmlMstCoopIdRoot;

            try
            {
                while (this.Status == StatusCode.Initialize || this.Status == StatusCode.Ready ||
                      this.Status == StatusCode.Execute || this.Status == StatusCode.TemporaryStop ||
                      this.Status == StatusCode.Stop)
                {
                    //  初期化中、起動準備中、実行中、中断中、終了中の場合は、各処理が終わるまで待機する。
                    System.Threading.Thread.Sleep(10);
                }

                //  文字列で受け取ったxmlをXmlNodeに変換
                xmlMstCoopIdRoot = new XmlDocument();
                xmlMstCoopIdRoot.LoadXml(strMstCoopId);
                this.m_xmlMstCoopId = xmlMstCoopIdRoot.SelectSingleNode("MST_COOP_ID");

                // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 START
                // IFエッジサービスのIP
                m_IFEdgeIPAddress = m_xmlMstCoopId["IFEdgeIPAddress"].InnerText;

                // IFエッジサービスのポートNo
                m_IFEdgePortNo = int.Parse(m_xmlMstCoopId["IFEdgePortNo"].InnerText);

                // EXEC_DATA
                m_xmlEXEC_DATA = m_xmlMstCoopId["SYS_COOP_EXEC_DATA"];

                // INI_DATA
                XmlNode iniNode = m_xmlMstCoopId.SelectSingleNode("SYS_COOP_INI_DATA");
                if (iniNode != null)
                {
                    m_xmlSYS_INI_DATA = iniNode.SelectNodes("row");
                }

                String sysCoopIniFilePath = m_xmlMstCoopId["SYS_COOP_INI_FILE_PATH"].InnerText;

                XmlDocument xmlInitDoc = new XmlDocument();
                xmlInitDoc.Load(sysCoopIniFilePath);

                m_xmlLOCAL_INI_DATA = xmlInitDoc.SelectNodes("//root/row");
                
                // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 END

                //  状態を初期化中にする。
                this.SetStatus(StatusCode.Initialize);

                //  連携自身の初期化を行う。
                retCode = this.Initialize();

                if (retCode.IsError || retCode.IsException)
                {
                    //  初期化に失敗（状態を初期化失敗にする）
                    this.SetStatus(StatusCode.ErrorStop);
                }
                else
                {
                    //  初期化に成功（状態を初期化完了）
                    this.SetStatus(StatusCode.Initialized);
                }
            }
            catch (Exception ex)
            {
                retCode = Fn3ComPlugInReturnCode.InitializeCooperationException;
                this.ErrorTraceOut(retCode, ex, string.Format("CooperationID={0}", this.CooperationID));
                this.SetStatus(StatusCode.ErrorStop);
            }
            finally
            {
                this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            }

            return retCode;
        }

        /// <summary>
        /// この連携を解放する
        /// </summary>
        public virtual void ReleaseCooperation()
        {
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            try
            {
                //  状態を終了処理中にする。
                this.SetStatus(StatusCode.Stop);

                //  連携の解放を行う。
                this.Release();
            }
            catch (Exception ex)
            {
                this.ErrorTraceOut(Fn3ComPlugInReturnCode.ReleaseCooperationException, ex, string.Format("CooperationID={0}", this.CooperationID));
            }
            finally
            {
                //  状態を終了にする。
                this.SetStatus(StatusCode.Stopped);

                this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            }
        }

        /// <summary>
        /// このオブジェクトの状態を設定します。
        /// </summary>
        /// <param name="statusCode">状態</param>
        private void SetStatus(StatusCode statusCode)
        {
            this.m_statusCode = statusCode;

            //  状態変更通知デリゲートをコール
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_dgtStatusInformation(this.CooperationID, statusCode);
            #endregion //系列施設複数連携対応

            // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 START
            if (this.m_dgtStatusInformation == null) return;
            // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 END

            this.m_dgtStatusInformation(m_ConnectSeriesCode + this.CooperationID, statusCode);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// 受信処理を開始します。
        /// </summary>
        /// <returns>処理開始可能の場合はFn3ReturnCode.Succdess。またはIsSuccessがTrueかIsWarningがTrue。</returns>
        /// <remarks>
        /// StartReceiveProcessメソッドはFn3ComPlugInが内部的に管理している状態を元に、処理の開始が可能かどうかを判断する。
        /// また、正常に受信処理が開始された場合は、状態を「実行中」へ遷移させます。
        /// 状態が「実行中」の時に、一時停止が行われた場合は、処理の終了まで一時停止の待機が行われるなど、他スレッドとの同期にも使用されます。
        /// </remarks>
        /// <example>
        /// 受信系のモジュールの処理時は以下のように作成します。<br />
        /// サンプルは非同期ソケット受信時の処理。
        /// <code>
        /// void server_AsyncReceive(object source, Fn3ManagedAsyncReceiveEventArgs e)
        /// {
        ///     //  受信処理開始
        ///     Fn3ReturnCode ret = this.StartReceiveProcess();
        ///     
        ///     if(ret.IsError || ret.IsException)
        ///     {
        ///         //  処理開始が出来ない状態
        ///     }
        /// 
        ///     //  連携処理
        ///     ・・・
        /// 
        ///     //  受信処理終了
        ///     this.EndReceiveProcess();
        /// }
        /// </code>
        /// </example>
        protected virtual Fn3ReturnCode StartReceiveProcess()
        {
            Fn3ReturnCode retCode;

            //  DB接続チェック
            retCode = this.DBCheckConnect();
            if (retCode.IsError || retCode.IsException)
            {
                //  DB接続失敗
                return retCode;
            }

            //  実行可能チェック
            retCode = this.CanExecute();
            if (retCode.IsError || retCode.IsException)
            {
                //  実行不可
                return retCode;
            }

            //  状態を実行中に変更
            this.SetStatus(StatusCode.Execute);

            return retCode;
        }

        /// <summary>
        /// 受信処理を終了します。
        /// </summary>
        /// <remarks>
        /// EndReceiveProcessメソッドは、受信処理を終了時には必ず呼び出してください。内部的に保持している状態を「待機中」に遷移させる。<br />
        /// 処理実行中に一時停止が行われる場合は、処理の終了まで一時停止処理がブロックされるため、このメソッドを呼び出さない場合、デッドロックになる可能性があります。
        /// </remarks>
        /// <example>
        /// 受信系のモジュールの処理時は以下のように作成します。<br />
        /// サンプルは非同期ソケット受信時の処理。
        /// <code>
        /// void server_AsyncReceive(object source, Fn3ManagedAsyncReceiveEventArgs e)
        /// {
        ///     //  受信処理開始
        ///     Fn3ReturnCode ret = this.StartReceiveProcess();
        ///     
        ///     if(ret.IsError || ret.IsException)
        ///     {
        ///         //  処理開始が出来ない状態
        ///     }
        /// 
        ///     //  連携処理
        ///     ・・・
        /// 
        ///     //  受信処理終了
        ///     this.EndReceiveProcess();
        /// }
        /// </code>
        /// </example>
        protected virtual void EndReceiveProcess()
        {
            if (this.Status == StatusCode.Execute)
            {
                //  状態を待機中に変更する。
                this.SetStatus(StatusCode.Standby);
            }
        }

        /// <summary>
        /// ダンプ出力を行う。
        /// </summary>
        /// <param name="strSpecificKey">特定キー</param>
        /// <param name="bytes">出力データ</param>
        protected virtual void DumpOut(string strSpecificKey, byte[] bytes)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_log.DumpOut(this.CooperationID, strSpecificKey, bytes);
            #endregion //系列施設複数連携対応

            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID(ConnectSeriesCode, CooperationID, "3");
            this.m_log.DumpOut(logParameter, this.CooperationID, strSpecificKey, bytes);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// メソッド開始ログを出力する。
        /// </summary>
        /// <param name="methodBase">メソッド情報</param>
        /// <example>
        /// メソッド開始ログの出力方法を以下に示す。
        /// <code>
        /// public void Func(string str, int index)
        /// {
        ///     //  メソッド開始ログ出力
        ///     MethodStartLog(System.Reflection.MethodBase.GetCurrentMethod());
        ///     
        ///     ・・・
        ///     
        ///     //  メソッド終了ログ出力
        ///     MethodEndLog(System.Reflection.MethodBase.GetCurrentMethod());
        /// }
        /// </code>
        /// </example>
        protected virtual void MethodStartLogOut(MethodBase methodBase)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_log.MethodLog(MethodFlag.Start, methodBase);
            #endregion //系列施設複数連携対応

            LogParameter logParameter = new LogParameter();
            string coopID = "00000";
            if (!string.IsNullOrEmpty(CooperationID))
            {
                coopID = CooperationID;
            }
            logParameter.SetProcessID(ConnectSeriesCode, coopID, "3");
            this.m_log.MethodLog(logParameter, MethodFlag.Start, methodBase);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// メソッド終了ログを出力する。
        /// </summary>
        /// <param name="methodBase">メソッド情報</param>
        /// <example>
        /// メソッド終了ログの出力方法を以下に示す。
        /// <code>
        /// public void Func(string str, int index)
        /// {
        ///     //  メソッド開始ログ出力
        ///     MethodStartLog(System.Reflection.MethodBase.GetCurrentMethod());
        ///     
        ///     ・・・
        ///     
        ///     //  メソッド終了ログ出力
        ///     MethodEndLog(System.Reflection.MethodBase.GetCurrentMethod());
        /// }
        /// </code>
        /// </example>
        protected virtual void MethodEndLogOut(MethodBase methodBase)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_log.MethodLog(MethodFlag.End, methodBase);
            #endregion //系列施設複数連携対応

            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID(ConnectSeriesCode, CooperationID, "3");
            this.m_log.MethodLog(logParameter, MethodFlag.End, methodBase);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// メソッド詳細ログを出力する。
        /// </summary>
        /// <param name="mb">メソッドベース</param>
        /// <param name="strMessage">出力メッセージ</param>
        protected virtual void MethodDetailLogOut(MethodBase mb, string strMessage)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_log.MethodDetailLog(mb, strMessage);
            #endregion //系列施設複数連携対応

            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID(m_ConnectSeriesCode, CooperationID, "3");

            this.m_log.MethodDetailLog(logParameter, mb, strMessage);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// デバッグログを出力する。
        /// </summary>
        /// <param name="strMessage">出力メッセージ</param>
        protected virtual void DebugTraceOut(string strMessage)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_log.DebugLog(strMessage);
            #endregion //系列施設複数連携対応

            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID(ConnectSeriesCode, CooperationID, "3");
            this.m_log.DebugLog(logParameter, strMessage);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// トレースログを出力する。
        /// </summary>
        /// <param name="strMessage">出力メッセージ</param>
        protected virtual void TraceOut(string strMessage)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_log.TraceLog(strMessage);
            #endregion //系列施設複数連携対応

            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID(ConnectSeriesCode, CooperationID, "3");
            this.m_log.TraceLog(logParameter, strMessage);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// トレースログを出力する。
        /// </summary>
        /// <param name="intErrorCode">0～9999のエラーコード</param>
        /// <param name="strMessage">出力メッセージ</param>
        protected virtual void TraceOut(int intErrorCode, string strMessage)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_log.TraceLog(this.CreateErrorCode(LogKind.Error, intErrorCode), strMessage);
            #endregion //系列施設複数連携対応

            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID(ConnectSeriesCode, CooperationID, "3");
            this.m_log.TraceLog(logParameter, this.CreateErrorCode(LogKind.Error, intErrorCode), strMessage);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// トレースログを出力する。
        /// </summary>
        /// <param name="returnCode"></param>
        protected virtual void TraceOut(Fn3ReturnCode returnCode)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_log.TraceLog(returnCode);
            #endregion //系列施設複数連携対応

            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID(ConnectSeriesCode, CooperationID, "3");
            this.m_log.TraceLog(logParameter, returnCode);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// トレースログを出力する。
        /// </summary>
        /// <param name="returnCode">エラーコード</param>
        /// <param name="strExMessage">拡張メッセージ</param>
        protected virtual void TraceOut(Fn3ReturnCode returnCode, string strExMessage)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_log.TraceLog(returnCode, strExMessage);
            #endregion //系列施設複数連携対応

            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID(ConnectSeriesCode, CooperationID, "3");
            this.m_log.TraceLog(logParameter, returnCode, strExMessage);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// エラーログを出力する。
        /// </summary>
        /// <param name="returnCode">リターンコード</param>
        /// <param name="ex">例外クラス</param>
        protected virtual void ErrorTraceOut(Fn3ReturnCode returnCode, Exception ex)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_log.ErrorLog(returnCode, ex);
            #endregion //系列施設複数連携対応

            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID(ConnectSeriesCode, CooperationID, "3");
            this.m_log.ErrorLog(logParameter, returnCode, ex);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// エラーログを出力する。
        /// </summary>
        /// <param name="returnCode">エラーコード</param>
        /// <param name="ex">例外クラス</param>
        /// <param name="strExtensionMessage">拡張メッセージ</param>
        protected virtual void ErrorTraceOut(Fn3ReturnCode returnCode, Exception ex, string strExtensionMessage)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_log.ErrorLog(returnCode, ex, strExtensionMessage);
            #endregion //系列施設複数連携対応

            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID(ConnectSeriesCode, CooperationID, "3");
            this.m_log.ErrorLog(logParameter, returnCode, ex, strExtensionMessage);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// エラー出力
        /// </summary>
        /// <param name="intErrorCode">0～9999のエラーコード</param>
        /// <param name="strMessage">メッセージ</param>
        /// <param name="ex">発生した例外</param>
        protected virtual void ErrorTraceOut(int intErrorCode, string strMessage, Exception ex)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_log.ErrorLog(this.CreateErrorCode(LogKind.Error, intErrorCode), strMessage, ex);
            #endregion //系列施設複数連携対応

            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID(ConnectSeriesCode, CooperationID, "3");
            this.m_log.ErrorLog(logParameter, this.CreateErrorCode(LogKind.Error, intErrorCode), strMessage, ex);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// エラー出力
        /// </summary>
        /// <param name="intErrorCode">0～9999のエラーコード</param>
        /// <param name="strMessage">メッセージ</param>
        /// <param name="ex">発生した例外</param>
        /// <param name="strExtensionMessage">追加情報</param>
        protected virtual void ErrorTraceOut(int intErrorCode, string strMessage, Exception ex, string strExtensionMessage)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_log.ErrorLog(this.CreateErrorCode(LogKind.Error, intErrorCode), strMessage, ex, strExtensionMessage);
            #endregion //系列施設複数連携対応

            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID(ConnectSeriesCode, CooperationID, "3");
            this.m_log.ErrorLog(logParameter, this.CreateErrorCode(LogKind.Error, intErrorCode), strMessage, ex, strExtensionMessage);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// 10桁のエラーコードを生成する
        /// </summary>
        /// <param name="logKind">ログ種別</param>
        /// <param name="intErrorCode">4桁のエラーコード</param>
        /// <returns>10桁のエラーコード</returns>
        private string CreateErrorCode(LogKind logKind, int intErrorCode)
        {
            return string.Format("05{0}{1:-3}{2:D4}", (int)logKind, this.ProcKind, intErrorCode);
        }

        /// <summary>
        /// 変更ログを出力する。
        /// </summary>
        /// <param name="type1">変更内容区分１</param>
        /// <param name="type2">変更内容区分２</param>
        /// <param name="strPatID">患者ID</param>
        /// <param name="strDialysisNo">透析番号</param>
        /// <param name="strChangeLog">変更内容</param>
        protected virtual void ChangeLogOut(ChangeLogType1 type1, ChangeLogType2 type2, string strPatID, string strDialysisNo, string strChangeLog)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //this.m_log.ChangeLogOut(type1, type2, strPatID, strDialysisNo, strChangeLog);
            #endregion //系列施設複数連携対応

            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID(ConnectSeriesCode, CooperationID, "3");
            this.m_log.ChangeLogOut(logParameter, type1, type2, strPatID, strDialysisNo, strChangeLog);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// 初期設定情報を取得します。
        /// </summary>
        /// <param name="strDevision">区分</param>
        /// <param name="strSection">セクション名</param>
        /// <param name="strKey">キー名</param>
        /// <param name="strValue">取得した値を保持するstring</param>
        /// <returns>取得に成功した場合はtrue。それ以外はfalse。</returns>
        protected virtual Fn3ReturnCode GetInitialValue(string strDevision, string strSection, string strKey, ref string strValue)
        {
            ResultCode result;
            Hashtable hash = new Hashtable();
            // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 START
            Fn3ReturnCode ret = Fn3ComPlugInReturnCode.InitialKeyNotFound;
            String m_Section = "";
            String m_Key = "";

            try
            {
                if(this.m_xmlSYS_INI_DATA != null)
                {
                    foreach (XmlNode xn in m_xmlSYS_INI_DATA)
                    {
                        m_Section = xn["INI_SECTION"].InnerText.Trim();
                        m_Key = xn["INI_KEY"].InnerText.Trim();
                        if (strSection.Equals(m_Section) && strKey.Equals(m_Key))
                        {
                            strValue = xn["INI_VALUE"].InnerText.Trim();
                            ret = Fn3ComPlugInReturnCode.Success;
                        }
                    }
                }

                if (!ret.IsSuccess)
                {
                    foreach (XmlNode xn in m_xmlLOCAL_INI_DATA)
                    {
                        m_Section = xn["INI_SECTION"].InnerText.Trim();
                        m_Key = xn["INI_KEY"].InnerText.Trim();
                        if (strSection.Equals(m_Section) && strKey.Equals(m_Key))
                        {
                            strValue = xn["INI_VALUE"].InnerText.Trim();
                            ret = Fn3ComPlugInReturnCode.Success;
                        }
                    }
                }
            }
            catch
            {
                //  取得に失敗
                ret = Fn3ComPlugInReturnCode.InitialKeyNotFound;
            }

            return ret;
            // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 END

            // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 START
            //while ((result = this.m_dgtGetInitialValue(strDevision, strSection, strKey, ref hash)) == ResultCode.Retry)
            //{
            //    Thread.Sleep(10);
            //}

            //if (result == ResultCode.Ng)
            //{
            //    return Fn3ComPlugInReturnCode.GetInitialValueError;
            //}

            //try
            //{
            //    //  ハッシュテーブルより値を取得
            //    strValue = (string)hash[strKey];
            //    if (strValue == null) return Fn3ComPlugInReturnCode.InitialKeyNotFound;

            //    return Fn3ComPlugInReturnCode.Success;
            //}
            //catch
            //{
            //    //  取得に失敗
            //    return Fn3ComPlugInReturnCode.InitialKeyNotFound;
            //}
            // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 END
        }

        /// <summary>
        /// 初期設定情報を取得します。
        /// </summary>
        /// <param name="strDevision">区分</param>
        /// <param name="strSection">セクション名</param>
        /// <param name="hash">取得値を保持するハッシュテーブルオブジェクト</param>
        /// <returns>成功時はtrue。それ以外はfalse。</returns>
        protected virtual Fn3ReturnCode GetInitialValue(string strDevision, string strSection, ref Hashtable hash)
        {
            ResultCode result;
            // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 START
            Fn3ReturnCode ret = Fn3ComPlugInReturnCode.GetInitialValueError;
            String m_Section = "";

            try
            {
                if (this.m_xmlSYS_INI_DATA != null)
                {
                    foreach (XmlNode xn in m_xmlSYS_INI_DATA)
                    {
                        m_Section = xn["INI_SECTION"].InnerText.Trim();
                        if (strSection.Equals(m_Section))
                        {
                            hash.Add(xn["INI_KEY"].InnerText.Trim(), xn["INI_VALUE"].InnerText.Trim());
                            ret = Fn3ComPlugInReturnCode.Success;
                        }
                    }
                }

                if (!ret.IsSuccess)
                {
                    foreach (XmlNode xn in m_xmlLOCAL_INI_DATA)
                    {
                        m_Section = xn["INI_SECTION"].InnerText.Trim();
                        if (strSection.Equals(m_Section))
                        {
                            hash.Add(xn["INI_KEY"].InnerText.Trim(), xn["INI_VALUE"].InnerText.Trim());
                            ret = Fn3ComPlugInReturnCode.Success;
                        }
                    }
                }
            }
            catch
            {
                //  取得に失敗
                ret = Fn3ComPlugInReturnCode.GetInitialValueError;
            }

            return ret;
            // CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 END

            // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 START
            //while ((result = this.m_dgtGetInitialValue(strDevision, strSection, "", ref hash)) == ResultCode.Retry)
            //{
            //    Thread.Sleep(10);
            //}

            //if (result == ResultCode.Ok)
            //{
            //    return Fn3ComPlugInReturnCode.Success;
            //}
            //else
            //{
            //    return Fn3ComPlugInReturnCode.GetInitialValueError;
            //}
            // CSI製電子カルテ（MIRAIS)についての対応 DEL 2021.03.09 END
        }

        /// <summary>
        /// 初期設定情報を設定します。
        /// </summary>
        /// <param name="strDevision">区分</param>
        /// <param name="strSection">セクション名</param>
        /// <param name="strKey">キー名</param>
        /// <param name="strValue">設定値</param>
        /// <returns>成功時はtrue。それ以外はfalse。</returns>
        protected virtual Fn3ReturnCode SetInitialValue(string strDevision, string strSection, string strKey, string strValue)
        {
            ResultCode result;

            while ((result = this.m_dgtSetInitialValue(strDevision, strSection, strKey, strValue)) == ResultCode.Retry)
            {
                Thread.Sleep(10);
            }

            if (result == ResultCode.Ok)
            {
                return Fn3ComPlugInReturnCode.Success;
            }
            else
            {
                return Fn3ComPlugInReturnCode.SetInitialValueError;
            }
        }

        /// <summary>
        /// 項目変換
        /// </summary>
        /// <param name="item">変換項目</param>
        /// <param name="strConvertKey">変換もとの値</param>
        /// <param name="strValue">変換後の値</param>
        /// <returns></returns>
        protected virtual Fn3ReturnCode Convert(ConvertItem item, string strConvertKey, ref string strValue)
        {
            string strSectionName = "";

            switch (item)
            {
                case ConvertItem.BloodTypeABOToFNW: strSectionName = "CONV_BLOOD_ABO_TO_FNW"; break;
                case ConvertItem.BloodTypeABOToKarte: strSectionName = "CONV_BLOOD_ABO_TO_KARTE"; break;
                case ConvertItem.BloodTypeRHToFNW: strSectionName = "CONV_BLOOD_RH_TO_FNW"; break;
                case ConvertItem.BloodTypeRHToKarte: strSectionName = "CONV_BLOOD_RH_TO_KARTE"; break;
                case ConvertItem.SexToFNW: strSectionName = "CONV_SEX_TO_FNW"; break;
                case ConvertItem.SexToKarte: strSectionName = "CONV_SEX_TO_KARTE"; break;
                case ConvertItem.NationalityToFNW: strSectionName = "CONV_NATIONALITY_TO_FNW"; break;
                case ConvertItem.NationalityToKarte: strSectionName = "CONV_NATIONALITY_TO_KARTE"; break;
                case ConvertItem.InfectionToFNW: strSectionName = "CONV_INFECTION_TO_FNW"; break;
                case ConvertItem.InfectionToKarte: strSectionName = "CONV_INFECTION_TO_KARTE"; break;
                case ConvertItem.InOutFlgToFNW: strSectionName = "CONV_INOUT_TO_FNW"; break;
                case ConvertItem.InOutFlgToKarte: strSectionName = "CONV_INOUT_TO_KARTE"; break;
                case ConvertItem.ExaminOrderClassToFNW: strSectionName = "CONV_EXAMIN_ORDER_CLASS_TO_FNW"; break;
                case ConvertItem.ExaminOrderClassToKarte: strSectionName = "CONV_EXAMIN_ORDER_CLASS_TO_KARTE"; break;
                default: return Fn3ComPlugInReturnCode.ConvertError;
            }

            return this.GetInitialValue("0", strSectionName, strConvertKey, ref strValue);
        }

        /// <summary>
        /// アラーム送信を行う
        /// </summary>
        /// <param name="kind">アラーム種別</param>
        /// <param name="patid">患者ID</param>
        /// <param name="pat_name">患者氏名</param>
        /// <param name="strErrorCode">エラーコード（4桁）</param>
        /// <param name="strErrorMessage">エラーメッセージ</param>
        protected void SendAlarm(AlarmKind kind, string patid, string pat_name, string strErrorCode, string strErrorMessage)
        {
            string msg;

            // 2014/04/14 中村 お知らせアプリへ通知する患者IDを先頭0詰め12桁にフォーマット Add Start
            if (!string.IsNullOrEmpty(patid))
            {
                patid = patid.PadLeft(12, '0');
            }
            // 2014/04/14 中村 お知らせアプリへ通知する患者IDを先頭0詰め12桁にフォーマット Add End

            msg = string.Format("{0},{1},,,,,,{2},{3}", strErrorCode, strErrorMessage, patid, pat_name);

            this.m_dgtSendAlarm(GetAlarmNotifyType(kind), msg);
        }

        /// <summary>
        /// アラーム送信を行う。
        /// </summary>
        /// <param name="kind">アラーム種別</param>
        /// <param name="patid">患者ID</param>
        /// <param name="pat_name">患者氏名</param>
        /// <param name="retCode">リターンコード</param>
        protected void SendAlarm(AlarmKind kind, string patid, string pat_name, Fn3ReturnCode retCode)
        {
            string msg;

            // 2014/04/14 中村 お知らせアプリへ通知する患者IDを先頭0詰め12桁にフォーマット Add Start
            if (!string.IsNullOrEmpty(patid))
            {
                patid = patid.PadLeft(12, '0');
            }
            // 2014/04/14 中村 お知らせアプリへ通知する患者IDを先頭0詰め12桁にフォーマット Add End

            // RPCシーケンス番号,メッセージ内容,ホスト名,ポート番号,チャネル名,ベッド番号,ベッド名称,患者ID,患者名称の形式
            msg = string.Format("{0},{1},,,,,,{2},{3}", retCode.Code, retCode.Message, patid, pat_name);

            this.m_dgtSendAlarm(GetAlarmNotifyType(kind), msg);
        }

        /// <summary>
        /// 連携の一時停止処理を行うには、このメソッドをオーバーライドします。
        /// </summary>
        protected virtual void Stop()
        {
        }

        /// <summary>
        /// 連携の初期化を行うには、このメソッドをオーバーライドします。
        /// </summary>
        /// <returns>初期化が成功した場合はFn3ReturnCode.Successを返す。</returns>
        protected virtual Fn3ReturnCode Initialize()
        {
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// イベント管理テーブル取得の1ポーリング単位の開始処理を行うにはこのメソッドをオーバーライドします。
        /// イベント管理テーブルにイベントが存在しない場合は呼び出されません。
        /// </summary>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode StartProcess()
        {
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 連携の処理を行うには、このメソッドをオーバーライドします。
        /// </summary>
        /// <param name="exeInfo">実行情報</param>
        /// <returns>処理が成功した場合はFn3ReturnCode.Successを返す。</returns>
        protected virtual Fn3ReturnCode Execute(Fn3ExecuteInfo exeInfo)
        {
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// イベント管理テーブル取得の1ポーリング単位の終了処理を行うにはこのメソッドをオーバーライドします。
        /// イベント管理テーブルにイベントが存在しない場合は呼び出されません。
        /// </summary>
        protected virtual void EndProcess()
        {
        }

        /// <summary>
        /// 連携の解放を行うにはこのメソッドをオーバーライドします。
        /// </summary>
        protected virtual void Release()
        {
        }

        /// <summary>
        /// アラーム種別の変換
        /// </summary>
        /// <param name="kind">変換元の種別</param>
        /// <returns>変換後の種別</returns>
        private string GetAlarmNotifyType(AlarmKind kind)
        {
            string type;

            switch (kind)
            {
                case AlarmKind.DEVICE_ALARM_ALL:        // 警報・報知（全体）
                    type = NOTIFYTYPE.DEVICE_ALARM_ALL.GetHashCode().ToString();
                    break;
                case AlarmKind.DEVICE_ALARM_PERSONAL:   // 警報（個別）
                    type = NOTIFYTYPE.DEVICE_ALARM_PERSONAL.GetHashCode().ToString();
                    break;
                case AlarmKind.DEVICE_ALARM_NOTIFY_PERSONAL:    // 報知（個別）
                    type = NOTIFYTYPE.DEVICE_ALARM_NOTIFY_PERSONAL.GetHashCode().ToString();
                    break;
                default:    // デフォルトは警報・報知（全体）
                    type = NOTIFYTYPE.DEVICE_ALARM_ALL.GetHashCode().ToString();
                    break;
            }

            return type;
        }

        /// <summary>
        /// バックアップファイルを保存する。
        /// </summary>
        /// <param name="strBackupFolderPath">バックアップフォルダパス</param>
        /// <param name="dtmTargetDate">対象日</param>
        /// <param name="strFileName">ファイル名</param>
        /// <param name="strContents">内容</param>
        /// <param name="strFilePath">保存ファイルパス</param>
        /// <returns>リターンコード</returns>
        /// <remarks>
        /// 対象日を指定した場合、以下のパスにバックアップファイルが作成されます。<br />
        /// [strBackupFolderPath]\[対象日(YYYYMMDD)]\[strFileName]<br />
        /// このメソッドで作成されたバックアップファイルは、DeleteBackupFileBeforeDateメソッドで対象日を指定して削除することが出来ます。
        /// </remarks>
        protected virtual Fn3ReturnCode SaveBackupFile(string strBackupFolderPath, DateTime dtmTargetDate, string strFileName, string strContents, out string strFilePath)
        {
            return this.SaveBackupFile(strBackupFolderPath, dtmTargetDate.ToString("yyyyMMdd"), strFileName, Encoding.UTF8.GetBytes(strContents), out strFilePath);
        }

        /// <summary>
        /// バックアップファイルを保存する
        /// </summary>
        /// <param name="strBackupFolderPath">バックアップフォルダパス</param>
        /// <param name="dtmTargetDate">対象日</param>
        /// <param name="strFileName">ファイル名</param>
        /// <param name="bytContents">内容</param>
        /// <param name="strFilePath">保存ファイルパス</param>
        /// <returns>リターンコード</returns>
        /// <remarks>
        /// 対象日を指定した場合、以下のパスにバックアップファイルが作成されます。<br />
        /// [strBackupFolderPath]\[対象日(YYYYMMDD)]\[strFileName]<br />
        /// このメソッドで作成されたバックアップファイルは、DeleteBackupFileBeforeDateメソッドで対象日を指定して削除することが出来ます。
        /// </remarks>
        protected virtual Fn3ReturnCode SaveBackupFile(string strBackupFolderPath, DateTime dtmTargetDate, string strFileName, byte[] bytContents, out string strFilePath)
        {
            return this.SaveBackupFile(strBackupFolderPath, dtmTargetDate.ToString("yyyyMMdd"), strFileName, bytContents, out strFilePath);
        }

        /// <summary>
        /// バックアップファイルを保存する
        /// </summary>
        /// <param name="strBackupFilePath">バックアップフォルダパス</param>
        /// <param name="strFileName">ファイル名</param>
        /// <param name="strContents">内容</param>
        /// <param name="strFilePath">保存ファイルパス</param>
        /// <returns>リターンコード</returns>
        protected Fn3ReturnCode SaveBackupFile(string strBackupFilePath, string strFileName, string strContents, out string strFilePath)
        {
            return this.SaveBackupFile(strBackupFilePath, "", strFileName, Encoding.UTF8.GetBytes(strContents), out strFilePath);
        }

        /// <summary>
        /// バックアップファイルを保存する
        /// </summary>
        /// <param name="strBackupFilePath">バックアップフォルダパス</param>
        /// <param name="strFileName">ファイル名</param>
        /// <param name="bytContents">内容</param>
        /// <param name="strFilePath">保存ファイルパス</param>
        /// <returns>リターンコード</returns>
        protected Fn3ReturnCode SaveBackupFile(string strBackupFilePath, string strFileName, byte[] bytContents, out string strFilePath)
        {
            return this.SaveBackupFile(strBackupFilePath, "", strFileName, bytContents, out strFilePath);
        }

        /// <summary>
        /// バックアップファイルを保存する
        /// </summary>
        /// <param name="strBackupFolderPath">バックアップフォルダパス</param>
        /// <param name="strSubFolderName">サブフォルダ名</param>
        /// <param name="strFileName">ファイル名</param>
        /// <param name="strContents">内容</param>
        /// <param name="strFilePath">保存ファイルパス</param>
        /// <returns>リターンコード</returns>
        /// <remarks>
        /// サブフォルダ名を指定した場合、以下のパスにバックアップファイルが作成されます。<br />
        /// [strBackupFolderPath]\[strSubFolderName]\[strFileName]
        /// </remarks>
        protected Fn3ReturnCode SaveBackupFile(string strBackupFolderPath, string strSubFolderName, string strFileName, string strContents, out string strFilePath)
        {
            return this.SaveBackupFile(strBackupFolderPath, strSubFolderName, strFileName, Encoding.UTF8.GetBytes(strContents), out strFilePath);
        }

        /// <summary>
        /// バックアップファイルを保存する
        /// </summary>
        /// <param name="strBackupFolderPath">バックアップフォルダパス</param>
        /// <param name="strSubFolderName">サブフォルダ名</param>
        /// <param name="strFileName">ファイル名</param>
        /// <param name="bytContents">内容</param>
        /// <param name="strFilePath">保存ファイルパス</param>
        /// <returns>リターンコード</returns>
        /// <remarks>
        /// サブフォルダ名を指定した場合、以下のパスにバックアップファイルが作成されます。<br />
        /// [strBackupFolderPath]\[strSubFolderName]\[strFileName]
        /// </remarks>
        protected Fn3ReturnCode SaveBackupFile(string strBackupFolderPath, string strSubFolderName, string strFileName, byte[] bytContents, out string strFilePath)
        {
            strFilePath = "";

            if (string.IsNullOrEmpty(strBackupFolderPath) == false)
            {
                //  サブフォルダが指定されている場合は、パスを結合。
                strBackupFolderPath = Path.Combine(strBackupFolderPath, strSubFolderName);
            }

            //  バックアップフォルダの存在チェック
            if (Directory.Exists(strBackupFolderPath) == false)
            {
                try
                {
                    //  バックアップフォルダが存在ないしない為、作成
                    Directory.CreateDirectory(strBackupFolderPath);
                }
                catch
                {
                    //  作成失敗
                    return Fn3ComPlugInReturnCode.CreateBackupFolderError;
                }
            }

            //  バックアップファイルパス作成
            strFilePath = Path.Combine(strBackupFolderPath, strFileName);
            strFilePath = Path.GetFullPath(strFilePath);

            try
            {
                //  バックアップファイル作成
                using (FileStream fs = new FileStream(strFilePath, FileMode.Create, FileAccess.Write, FileShare.None))
                {
                    fs.Write(bytContents, 0, bytContents.Length);
                }
            }
            catch
            {
                //  作成失敗
                return Fn3ComPlugInReturnCode.CreateBackupFileError;
            }

            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// バックアップファイルを読み込む
        /// </summary>
        /// <param name="strBackupFilePath">バックアップファイルパス</param>
        /// <param name="strContents">内容</param>
        /// <returns>リターンコード</returns>
        protected Fn3ReturnCode LoadBackupFile(string strBackupFilePath, out string strContents)
        {
            strContents = "";

            Fn3ReturnCode retCode;
            byte[] bytContents;

            retCode = this.LoadBackupFile(strBackupFilePath, out bytContents);
            if (retCode.IsError || retCode.IsException) return retCode;

            try
            {
                //  文字列変換
                strContents = Encoding.UTF8.GetString(bytContents);
            }
            catch
            {
                //  Unicode変換に失敗
                return Fn3ComPlugInReturnCode.BackupFileEncodingError;
            }

            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// バックアップファイルを読み込む
        /// </summary>
        /// <param name="strBackupFilePath">バックアップファイルパス</param>
        /// <param name="bytContents">内容</param>
        /// <returns>リターンコード</returns>
        protected Fn3ReturnCode LoadBackupFile(string strBackupFilePath, out byte[] bytContents)
        {
            bytContents = null;

            if (File.Exists(strBackupFilePath) == false)
            {
                //  ファイルが存在しない
                return Fn3ComPlugInReturnCode.BackupFileNotFound;
            }

            try
            {
                //  読み込み
                using (FileStream fs = new FileStream(strBackupFilePath, FileMode.Open, FileAccess.Read))
                {
                    bytContents = new byte[fs.Length];
                    fs.Read(bytContents, 0, bytContents.Length);
                }
            }
            catch
            {
                //  例外発生
                return Fn3ComPlugInReturnCode.ReadBackupFileError;
            }

            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 対象日以前のバックアップファイルを削除する。
        /// </summary>
        /// <param name="strBackupFolderPath">バックアップフォルダパス</param>
        /// <param name="dtmDelDate">削除指定日</param>
        /// <remarks>
        /// このメソッドはバックアップファイルをSaveBackupFileで対象日を設定した場合、削除指定日以前が対象日のバックアップファイルを全て削除します。
        /// </remarks>
        protected void DeleteBackupFileBeforeDate(string strBackupFolderPath, DateTime dtmDelDate)
        {
            if (Directory.Exists(strBackupFolderPath) == false) return;

            //  バックアップフォルダ内のフォルダを列挙
            DirectoryInfo di = new DirectoryInfo(strBackupFolderPath);
            DirectoryInfo[] subDir = di.GetDirectories();

            foreach (DirectoryInfo dir in subDir)
            {
                try
                {
                    //  フォルダ名を日時に変換
                    DateTime dtmDir;
                    if (DateTime.TryParseExact(dir.Name, "yyyyMMdd", null, DateTimeStyles.None, out dtmDir) == false) continue;

                    //  フォルダ名が対象日以前の場合は、フォルダを削除
                    if (dtmDir <= dtmDelDate) dir.Delete(true);
                }
                catch
                {
                    //  例外は権限が問題なので、何も処理を行わない。
                }
            }
        }

        /// <summary>
        /// 検査予定日時を取得する（検査予定連携限定機能）
        /// </summary>
        /// <param name="exeInfo">連携情報</param>
        /// <param name="dtmExamScheDateTime">検査予定開始日時</param>
        /// <returns>リターンコード</returns>
        protected Fn3ReturnCode GetExamScheDateTime(Fn3ExecuteInfo exeInfo, out DateTime dtmExamScheDateTime)
        {
            dtmExamScheDateTime = new DateTime(0);
            //  透析前後区分を取得
            string strExamDivision = Fn3ComTool.GetXmlValue(exeInfo.CoopInfoXML, "//rootNode/PAT_EXAMIN_SCHEDULE/EXAM_DIVISION");
            if (string.IsNullOrEmpty(strExamDivision))
            {
                //  取得失敗
                return Fn3ComPlugInReturnCode.GetExamScheDateTimeError;
            }

            //  検査日付の取得
            string strExamDate = Fn3ComTool.GetXmlValue(exeInfo.CoopInfoXML, "//rootNode/PAT_EXAMIN_SCHEDULE/EXAM_DATE");

            switch (strExamDivision)
            {
                case "0":   //  透析前
                    {
                        //  クール標準開始時間を取得
                        string strDialScheStartTime = Fn3ComTool.GetXmlValue(exeInfo.CoopInfoXML, "//rootNode/SCH_DIALYSIS_PLAN/MST_KUR/STANDARD_START_TIME");
                        if (string.IsNullOrEmpty(strDialScheStartTime))
                        {
                            //  取得失敗
                            return Fn3ComPlugInReturnCode.GetExamScheDateTimeError;
                        }

                        //  検査日付とクール標準開始時間で検査日時を作成
                        if (DateTime.TryParseExact(strExamDate + strDialScheStartTime, "yyyyMMddHHmmss", null, DateTimeStyles.None, out dtmExamScheDateTime) == false)
                        {
                            //  作成失敗
                            return Fn3ComPlugInReturnCode.GetExamScheDateTimeError;
                        }

                        //  透析前マージン時間を取得
                        string strMarginTime = "";
                        int intMarginTime;
                        this.GetInitialValue("0", "EXAM_MARGIN_TIME", "DIAL_BEFORE", ref strMarginTime);
                        if (int.TryParse(strMarginTime, out intMarginTime) == true)
                        {
                            //  マージン時間が取得できた場合は、開始時間から減算する。
                            dtmExamScheDateTime = dtmExamScheDateTime.AddMinutes(-intMarginTime);
                        }
                        return Fn3ReturnCode.Success;
                    }
                case "1":   //  透析後
                    {
                        //  クール標準開始時間を取得
                        string strDialScheStartTime = Fn3ComTool.GetXmlValue(exeInfo.CoopInfoXML, "//rootNode/SCH_DIALYSIS_PLAN/MST_KUR/STANDARD_START_TIME");
                        if (string.IsNullOrEmpty(strDialScheStartTime))
                        {
                            //  取得失敗
                            return Fn3ComPlugInReturnCode.GetExamScheDateTimeError;
                        }

                        //  検査日付とクール標準開始時間で検査日時を作成
                        if (DateTime.TryParseExact(strExamDate + strDialScheStartTime, "yyyyMMddHHmmss", null, DateTimeStyles.None, out dtmExamScheDateTime) == false)
                        {
                            //  作成失敗
                            return Fn3ComPlugInReturnCode.GetExamScheDateTimeError;
                        }

                        //  予定透析時間を取得
                        string strDialysisTime = Fn3ComTool.GetXmlValue(exeInfo.CoopInfoXML, "//rootNode/IND_DIALYSIS_COND[CTL_NO='002']/VALUE");
                        int intDialysisTime;
                        if (int.TryParse(strDialysisTime, out intDialysisTime) == false)
                        {
                            //  予定透析時間取得失敗
                            return Fn3ComPlugInReturnCode.GetExamScheDateTimeError;
                        }

                        //  開始時間に透析時間を加算して透析終了時刻を取得
                        dtmExamScheDateTime = dtmExamScheDateTime.AddMinutes(intDialysisTime);

                        //  透析後マージン時間を取得
                        string strMarginTime = "";
                        int intMarginTime;
                        this.GetInitialValue("0", "EXAM_MARGIN_TIME", "DIAL_AFTER", ref strMarginTime);
                        if (int.TryParse(strMarginTime, out intMarginTime) == true)
                        {
                            //  マージン時間が取得できた場合は、開始時間から減算する。
                            dtmExamScheDateTime = dtmExamScheDateTime.AddMinutes(intMarginTime);
                        }
                        return Fn3ReturnCode.Success;
                    }
                case "2":   //  その他
                    {
                        //  その他開始時刻を取得
                        string strOtherExamTime = Fn3ComTool.GetXmlValue(exeInfo.CoopInfoXML, "//rootNode/PAT_EXAMIN_SCHEDULE/MST_EXAM_SET/OTHER_EXAM_TIME");
                        if (string.IsNullOrEmpty(strOtherExamTime))
                        {
                            //  取得失敗
                            return Fn3ComPlugInReturnCode.GetExamScheDateTimeError;
                        }

                        //  検査日付とその他開始時刻で検査日時を作成
                        if (DateTime.TryParseExact(strExamDate + strOtherExamTime, "yyyyMMddHHmm", null, DateTimeStyles.None, out dtmExamScheDateTime) == false)
                        {
                            //  作成失敗
                            return Fn3ComPlugInReturnCode.GetExamScheDateTimeError;
                        }
                        return Fn3ReturnCode.Success;
                    }
                default:
                    {
                        //  不明な前後区分
                        return Fn3ComPlugInReturnCode.GetExamScheDateTimeError;
                    }
            }
        }

        /// <summary>
        /// リース期間延長メソッド
        /// </summary>
        /// <returns>ILeaseオブジェクト</returns>
        /// <remarks>使用しないでください。</remarks>
        public override object InitializeLifetimeService()
        {
            ILease lease = (ILease)base.InitializeLifetimeService();
            if (lease.CurrentState == LeaseState.Initial)
            {
                lease.Register(new BarSponsor());
            }
            return lease;
        }

        // 注射オーダ受信対応 2011.06.23 Start M.Aoki
        /// <summary>
        /// 表示用患者IDと日付に該当する患者情報を取得する。
        /// </summary>
        /// <param name="strPatId">患者ID</param>
        /// <param name="strUpdate">更新日時　※NULLの場合は最新日時で検索</param>
        /// <param name="strOutXml">出力XML</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBGetPatInfoDispid(string strPatId, string strUpdate, ref string strOutXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //// 2015/05/21 宮崎 Redmine#4625対応 Upd Start
            ////string[] strVal = new string[2];
            //string[] strVal = new string[3];
            //// 2015/05/21 宮崎 Redmine#4625対応 Upd End
            //strVal[0] = strPatId;
            //strVal[1] = strUpdate;
            //// 2015/05/18 中村 Redmine#4625対応 Add Start
            //if (!string.IsNullOrEmpty(this.m_TargetSeriesCode))
            //{
            //    // 対象系列施設コードが設定されている場合、対象系列施設コードを指定
            //    strVal[2] = this.m_TargetSeriesCode;
            //}
            //else
            //{
            //    // 対象系列施設コードが設定されていない場合、通信先系列施設コードを指定
            //    strVal[2] = this.m_ConnectSeriesCode;
            //}
            //// 2015/05/18 中村 Redmine#4625対応 Add End
            //return this.m_dgtDBAccess(DBAccessType.GetPatInfoDispid, null, ref strOutXml, strVal, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }
        // 注射オーダ受信対応 2011.06.23 End M.Aoki

        // <5.2.2.0> 2011.08.26 Add Start M.Aoki 透析スケジュール受信機能追加
        /// <summary>
        /// 指定患者の開始日時に該当する透析予定の工程チェックを行う
        /// </summary>
        /// <param name="strPatId">患者ID（内部ID）</param>
        /// <param name="strStartDate">透析開始日</param>
        /// <param name="strStartTime">透析開始時間</param>
        /// <returns></returns>
        protected virtual int DBGetDialysisState(string strPatId, string strStartDate, string strStartTime, string strPlural)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strOutXml = null;
            //object obj = null;
            //string[] strVal = new string[4];
            //strVal[0] = strPatId;
            //strVal[1] = strStartDate;
            //strVal[2] = strStartTime;
            //strVal[3] = strPlural;

            //Fn3ReturnCode retCode = this.m_dgtDBAccess(DBAccessType.GetDialysisState, null, ref strOutXml, strVal, ref obj);

            //return (int)obj;
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return 1;
        }

        /// <summary>
        /// 指定患者の開始日時に該当する透析予定の工程チェックを行う
        /// </summary>
        /// <param name="iClassKind">分類区分</param>
        /// <param name="strClassName">分類名称</param>
        /// <returns></returns>
        protected virtual string DBGetMstClassCode(int iClassKind, string strClassName)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strOutXml = null;
            //object obj = null;
            //string[] strVal = new string[2];
            //strVal[0] = iClassKind.ToString();
            //strVal[1] = strClassName;

            //Fn3ReturnCode retCode = this.m_dgtDBAccess(DBAccessType.GetMstClassCode, null, ref strOutXml, strVal, ref obj);

            //return (string)obj;
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return "";

        }

        /// <summary>
        /// 指定患者の開始日時に該当する透析スケジュール情報の変更有無チェックを行う
        /// </summary>
        /// <param name="strPatId">患者ID（内部ID）</param>
        /// <param name="strStartDate">透析開始日</param>
        /// <param name="strStartTime">透析開始時間</param>
        /// <returns></returns>
        protected virtual int DBGetChangeStatus(string strPatId, string strStartDate, string strStartTime)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strOutXml = null;
            //object obj = null;
            //string[] strVal = new string[3];
            //strVal[0] = strPatId;
            //strVal[1] = strStartDate;
            //strVal[2] = strStartTime;

            //Fn3ReturnCode retCode = this.m_dgtDBAccess(DBAccessType.GetChangeStatus, null, ref strOutXml, strVal, ref obj);

            //return (int)obj;
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return 1;
        }

        /// <summary>
        ///  指定患者の開始日時の透析予定情報を削除します
        /// </summary>
        /// <param name="strPatId">患者ID（内部ID）</param>
        /// <param name="strStaffCd">スタッフコード(担当医)</param>
        /// <param name="strStartDate">透析開始日</param>
        /// <param name="strStartTime">透析開始時間</param>
        /// <param name="iBedNo">ベッド番号</param>
        /// <returns></returns>
        protected virtual Fn3ReturnCode DBDeleteDialysisSchedule(string strPatId, string strStaffCd, string strStartDate, string strStartTime, int iPlural, out int iBedNo)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strOutXml = null;
            //object obj = null;
            //// >>>>> 2012.04.04 M.Miyazaki 不具合修正
            ////            string[] strVal = new string[3];
            //string[] strVal = new string[5];
            //// <<<<< 2012.04.04 M.Miyazaki 不具合修正
            //strVal[0] = strPatId;
            //strVal[1] = strStaffCd;
            //strVal[2] = strStartDate;
            //strVal[3] = strStartTime;
            //strVal[4] = iPlural.ToString();
            //Fn3ReturnCode retCode = this.m_dgtDBAccess(DBAccessType.DeleteDialysisSchedule, null, ref strOutXml, strVal, ref obj);

            iBedNo = 0;
            //if (obj != null)
            //    iBedNo = (int)obj;

            //return retCode;
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 掲示板へ書き込みをする
        /// </summary>
        /// <param name="strPatId">患者ID（内部ID）</param>
        /// <param name="strNote">掲示する内容</param>
        /// <param name="dtStartDate">掲示開始日</param>
        /// <param name="dtEndDate">掲示終了日</param>
        /// <returns></returns>
        protected virtual Fn3ReturnCode DBAddBbsInfo(string strPatId, string strNote, DateTime? dtStartDate, DateTime? dtEndDate)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strOutXml = null;
            //object obj = null;
            //string[] strVal = new string[4];
            //strVal[0] = strPatId;
            //strVal[1] = strNote;

            //if (null == dtStartDate)
            //    strVal[2] = null;
            //else
            //    strVal[2] = ((DateTime)dtStartDate).ToString("yyyyMMdd");

            //if (null == dtEndDate)
            //    strVal[3] = null;
            //else
            //    strVal[3] = ((DateTime)dtEndDate).ToString("yyyyMMdd");

            //return this.m_dgtDBAccess(DBAccessType.AddBbsInfo, null, ref strOutXml, strVal, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        // >>>>> 2012.05.08 M.Miyazaki
        /// <summary>
        /// 掲示板へ書き込みをする(拡張版)
        /// ⇒今後、このAPIに統一していきたい！
        /// </summary>
        /// <param name="strNote">掲示する内容</param>
        /// <param name="IsAllPat">全患者対象 True:全患者／False:選択患者</param>
        /// <param name="strPatId">患者IDリスト（内部ID）</param>
        /// <param name="IsAllStaff">全スタッフ対象 True:全スタッフ／False:選択スタッフ</param>
        /// <param name="strStaffCd">スタッフCDリスト リストがない場合は、強制的に全スタッフにします。</param>
        /// <param name="dtStartDate">掲示開始日</param>
        /// <param name="dtEndDate">掲示終了日</param>
        /// <returns></returns>
        protected virtual Fn3ReturnCode DBRegisterBbsInfo(string strNote, bool IsAllPat, List<string> strPatId, bool IsAllStaff, List<string> strStaffCd, DateTime? dtStartDate, DateTime? dtEndDate)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strOutXml = null;
            //object obj = null;
            //int PatCnt = 0;
            //int StaffCnt = 0;
            //int ParamCnt = 0;
            //int i = 0;
            //int cnt = 0;
            //if (strPatId != null)
            //{
            //    PatCnt = strPatId.Count;
            //}
            //if (strStaffCd != null)
            //{
            //    StaffCnt = strStaffCd.Count;
            //}
            //if (StaffCnt == 0)
            //{
            //    IsAllStaff = true;
            //}
            //ParamCnt = PatCnt + StaffCnt + 7;
            //string[] strVal = new string[ParamCnt];

            //// パラメータリスト作成
            //// ①掲載内容
            //strVal[cnt++] = strNote;
            //// ②全患者対象設定
            //strVal[cnt++] = IsAllPat.ToString();
            //// ③患者リスト数
            //strVal[cnt++] = PatCnt.ToString();
            //// ④患者リスト
            //for (i = 0; i < PatCnt; i++)
            //{
            //    strVal[cnt++] = strPatId[i];
            //}
            //// ⑤全スタッフ対象設定
            //strVal[cnt++] = IsAllStaff.ToString();
            //// ⑥スタッフリスト数
            //strVal[cnt++] = StaffCnt.ToString();
            //// ⑧スタッフリスト
            //for (i = 0; i < StaffCnt; i++)
            //{
            //    strVal[cnt++] = strStaffCd[i];
            //}
            //// ⑨掲示開始日
            //if (null == dtStartDate)
            //{
            //    strVal[cnt++] = null;
            //}
            //else
            //{
            //    strVal[cnt++] = ((DateTime)dtStartDate).ToString("yyyyMMdd");
            //}
            //// ⑩掲示終了日
            //if (null == dtEndDate)
            //{
            //    strVal[cnt++] = null;
            //}
            //else
            //{
            //    strVal[cnt++] = ((DateTime)dtEndDate).ToString("yyyyMMdd");
            //}

            //return this.m_dgtDBAccess(DBAccessType.RegisterBbsInfo, null, ref strOutXml, strVal, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }
        // <<<<< 2012.05.08 M.Miyazaki

        /// <summary>
        /// 透析実績情報を取得します
        /// </summary>
        /// <param name="strPatId">患者ID（内部ID）</param>
        /// <param name="strStartDate">透析開始日</param>
        /// <param name="strStartTime">透析開始時間</param>
        /// <param name="iDialysisState">透析工程状態</param>
        /// <param name="strDialysisXml">透析実績情報</param>
        /// <returns></returns>
        protected virtual int DBGetDialysisResult(string strPatId, string strStartDate, string strStartTime, out int iDialysisState, out string strDialysisXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //strDialysisXml = null;
            //// 2015/05/21 宮崎 Redmine#4625対応 Upd Start
            ////string[] strVal = new string[3];
            //string[] strVal = new string[4];
            //// 2015/05/21 宮崎 Redmine#4625対応 Upd End
            //strVal[0] = strPatId;
            //strVal[1] = strStartDate;
            //strVal[2] = strStartTime;
            //// 2015/05/18 中村 Redmine#4625対応 Add Start
            //if (!string.IsNullOrEmpty(this.m_TargetSeriesCode))
            //{
            //    // 対象系列施設コードが設定されている場合、対象系列施設コードを指定
            //    strVal[3] = this.m_TargetSeriesCode;
            //}
            //else
            //{
            //    // 対象系列施設コードが設定されていない場合、通信先系列施設コードを指定
            //    strVal[3] = this.m_ConnectSeriesCode;
            //}
            //// 2015/05/18 中村 Redmine#4625対応 Add End

            //Fn3ReturnCode ret = this.m_dgtDBAccess(DBAccessType.GetDialysisResult, null, ref strDialysisXml, strVal, ref obj);

            //int[] iVal = (int[])obj;

            //// >>>>> 2013.07.23 阿部(浩) Redmine#2232
            //iDialysisState = iVal[1];

            //return iVal[0];

            ////iDialysisState = iVal[0];

            ////return iVal[1];
            //// <<<<< 2013.07.23 阿部(浩) Redmine#2232
            // CSI製電子カルテ（MIRAIS)についての対応 END
            iDialysisState = 0;
            strDialysisXml = "";
            return 1;
        }

        /// <summary>
        /// 透析オーダ受信機能の更新処理
        /// </summary>
        /// <param name="strInXml">入力XML</param>
        /// <returns></returns>
        protected virtual Fn3ReturnCode DBUpdateDialysisOrderRecive(string strInXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strOutXml = null;
            //object obj = null;

            //// 2015/05/18 中村 Redmine#4625対応 Start
            //// return this.m_dgtDBAccess(DBAccessType.UpdateDialysisOrderRecive, strInXml, ref strOutXml, null, ref obj);
            //string strSeriesCode = this.m_ConnectSeriesCode;
            //if (!string.IsNullOrEmpty(this.m_TargetSeriesCode))
            //{
            //    strSeriesCode = this.m_TargetSeriesCode;
            //}
            //return this.m_dgtDBAccess(DBAccessType.UpdateDialysisOrderRecive, strInXml, ref strOutXml, strSeriesCode, ref obj);
            //// 2015/05/18 中村 Redmine#4625対応 End
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 次患者情報更新処理を行う
        /// </summary>
        /// <param name="iBedNo"></param>
        /// <returns></returns>
        protected virtual Fn3ReturnCode DBUpdateNextPatientInfo(int iBedNo)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strOutXml = null;
            //object obj = null;

            //return this.m_dgtDBAccess(DBAccessType.UpdateNextPatirntInfo, null, ref strOutXml, iBedNo, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        // <5.2.2.0> 2011.08.26 Add End M.Aoki 透析スケジュール受信機能追加

        // <5.2.2.0> 2011.11.02 Add Start 中村 マスタ情報受信機能追加
        /// <summary>
        /// マスタ情報の登録を行う
        /// </summary>
        /// <param name="strInXml"></param>
        /// <returns></returns>
        protected virtual Fn3ReturnCode DBUpdateMasterInfoReceive(string strInXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strOutXml = null;
            //object obj = null;

            //return this.m_dgtDBAccess(DBAccessType.UpdateMasterInfoReceive, strInXml, ref strOutXml, null, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }
        /// <summary>
        /// 指定した項目を使用している患者一覧を取得する
        /// </summary>
        /// <param name="strInXml"></param>
        /// <param name="strOutXml"></param>
        /// <returns></returns>
        protected virtual Fn3ReturnCode DBGetItemUsedPatInfo(string strInXml, ref string strOutXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //return this.m_dgtDBAccess(DBAccessType.GetItemUsedPatInfo, strInXml, ref strOutXml, null, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }
        // <5.2.2.0> 2011.11.02 Add End 中村 マスタ情報受信機能追加

        // 2012.02.07 Add Start 中村
        /// <summary>
        /// 体重情報を取得
        /// </summary>
        /// <param name="strExamDate">検査日(YYYY/MM/DD HH24:MI:SS)</param>
        /// <param name="strWeightInfo">出力XMLデータ</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBGetDialysisWeightInfo(string strExamDate, ref string strWeightInfo)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //string[] strVal = new string[2];
            //strVal[0] = this.CooperationID;
            //strVal[1] = strExamDate;

            //return this.m_dgtDBAccess(DBAccessType.GetDialysisWeightInfo, null, ref strWeightInfo, strVal, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }
        /// <summary>
        /// 血圧情報を取得
        /// </summary>
        /// <param name="strExamDate">検査日(YYYY/MM/DD HH24:MI:SS)</param>
        /// <param name="strWeightInfo">出力XMLデータ</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBGetDialysisBldPresInfo(string strExamDate, ref string strWeightInfo)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //string[] strVal = new string[2];
            //strVal[0] = this.CooperationID;
            //strVal[1] = strExamDate;

            //return this.m_dgtDBAccess(DBAccessType.GetDialysisBldPresInfo, null, ref strWeightInfo, strVal, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        #region 系列施設複数連携対応
        ///// <summary>
        ///// 最終チェック日時を更新
        ///// </summary>
        ///// <param name="strExamDate">最終チェック日時(YYYY/MM/DD HH24:MI:SS)</param>
        ///// <returns>リターンコード</returns>
        //protected virtual Fn3ReturnCode DBUpdateLastCheckDate(string strExamDate)
        #endregion //系列施設複数連携対応

        /// <summary>
        /// 最終チェック日時を更新
        /// </summary>
        /// <param name="strExamDate"></param>
        /// <param name="strSeriesCode"></param>
        /// <returns></returns>
        protected virtual Fn3ReturnCode DBUpdateLastCheckDate(string strExamDate, string strSeriesCode)
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strOutXml = null;
            //object obj = null;
            //// 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            //#region 系列施設複数連携対応
            ////string[] strVal = new string[2];
            ////strVal[0] = this.CooperationID;
            ////strVal[1] = strExamDate;
            //#endregion //系列施設複数連携対応

            //string[] strVal = new string[3];
            //strVal[0] = this.CooperationID;
            //strVal[1] = strExamDate;
            //strVal[2] = strSeriesCode;
            //// 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

            //return this.m_dgtDBAccess(DBAccessType.UpdateLastCheckDate, null, ref strOutXml, strVal, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }
        // 2012.02.07 Add End 中村

        // 2013/01/30 中村 バイタル登録対応 Add Start
        /// <summary>
        /// バイタル情報更新
        /// </summary>
        /// <param name="strInXml">入力XML</param>
        /// <param name="intUpdateNum">更新レコード数</param>
        /// <param name="intDialysisNo">透析番号</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBSetBloodPressureInfo(string strInXml, ref int intUpdateNum, ref int intDialysisNo)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strXml = null;
            //object obj = null;

            //Fn3ReturnCode retCode = this.m_dgtDBAccess(DBAccessType.SetBloodPressureInfo, strInXml, ref strXml, null, ref obj);

            //int[] iVal = (int[])obj;
            //intUpdateNum = iVal[0];
            //intDialysisNo = iVal[1];

            //return retCode;
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }
        // 2013/01/30 中村 バイタル登録対応 Add End


        // 2014/08/25 中村 旭中央病院対応 Add Start
        /// <summary>
        /// 患者治療方法情報を登録
        /// </summary>
        /// <param name="strInXml">入力XML</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBSetPatTreatInfo(string strInXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strXml = null;
            //object obj = null;

            //Fn3ReturnCode retCode = this.m_dgtDBAccess(DBAccessType.SetPatTreatInfo, strInXml, ref strXml, null, ref obj);

            //return retCode;
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 患者CTR情報を登録
        /// </summary>
        /// <param name="strInXml">入力XML</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBSetPatCtrInfo(string strInXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strXml = null;
            //object obj = null;

            //Fn3ReturnCode retCode = this.m_dgtDBAccess(DBAccessType.SetPatCtrInfo, strInXml, ref strXml, null, ref obj);

            //return retCode;
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }
        // 2014/08/25 中村 旭中央病院対応 Add End

        // 2014/11/06 阿部 指示変更情報取得対応 Add Start
        /// <summary>
        /// 指示変更情報を取得します
        /// </summary>
        /// <param name="strEventCd">イベントコード(汎用イベント.イベントコード[002001／002002：予定、002005：条件、002006：投薬、002007：医材、002008：指示簿])</param>
        /// <param name="dtBaseDate">取得基準日時(汎用イベント.発生日時[指示の更新日時が指定可能な場合は指定すること])</param>
        /// <param name="strPatId">内部患者ID</param>
        /// <param name="strPlural">同日複数回(指示1：1、指示2：2)</param>
        /// <param name="strStartDate">取得開始日(汎用イベント.開始日(YYYYMMDD))</param>
        /// <param name="strEndDate">取得終了日(汎用イベント.終了日(YYYYMMDD))</param>
        /// <param name="strCtlNo">項目番号(予定以外は必須とする)</param>
        /// <param name="strIndNo">指示番号(予定以外は必須とする)</param>
        /// <param name="strSeriesCd">系列施設コード</param>
        /// <param name="strOutXml">出力XML</param>
        /// <returns>リターンコード</returns>
        //protected virtual Fn3ReturnCode DBGetIndChangeLog(string strEventCd, DateTime dtBaseDate, string strPatId, string strPlural, string strStartDate, string strCtlNo, string strIndNo, string strSeriesCd, ref string strOutXml)
        protected virtual Fn3ReturnCode DBGetIndChangeLog(string strEventCd, DateTime dtBaseDate, string strPatId, string strPlural, string strStartDate, string strEndDate, string strCtlNo, string strIndNo, string strSeriesCd, ref string strOutXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //object obj = null;
            //string[] strVal = new string[9];
            //strVal[0] = strEventCd;
            //strVal[1] = dtBaseDate.ToString("yyyy/MM/dd HH:mm:ss");
            //strVal[2] = strPatId;
            //strVal[3] = strPlural;
            //strVal[4] = strStartDate;
            //strVal[5] = strEndDate;
            //strVal[6] = strCtlNo;
            //strVal[7] = strIndNo;
            //strVal[8] = strSeriesCd;

            //return this.m_dgtDBAccess(DBAccessType.GetIndChangeLog, null, ref strOutXml, strVal, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }
        // 2014/11/06 阿部 指示変更情報取得対応 Add End

        // 2015/06/24 中村 オーダ番号サイクリック対応 Add Start
        /// <summary>
        /// 使用済みオーダ番号を未使用に変更します。
        /// </summary>
        /// <param name="strPatid">患者ID</param>
        /// <param name="strDelOrderNo">未使用に変更するオーダ番号</param>
        /// <param name="strUsedOrderNo">実際に使用したオーダ番号</param>
        /// <param name="strSeqNo">イベント管理．シーケンス番号</param>
        /// <param name="dtOccurDate">イベント管理．発生日</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBUpdateUsedOrderNo(string strPatid, string strDelOrderNo, string strUsedOrderNo, string strSeqNo, DateTime dtOccurDate)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strOutXml = null;
            //object obj = null;

            //string[] strVal = new string[7];
            //strVal[0] = this.OrderNumberManageId;
            //strVal[1] = this.m_TargetSeriesCode;
            //strVal[2] = strPatid;
            //strVal[3] = strDelOrderNo;
            //strVal[4] = strUsedOrderNo;
            //strVal[5] = strSeqNo;
            //strVal[6] = dtOccurDate.ToString("yyyy/MM/dd HH:mm:ss");

            //return this.m_dgtDBAccess(DBAccessType.UpdateUsedOrderNo, null, ref strOutXml, strVal, ref obj);
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }
        // 2015/06/24 中村 オーダ番号サイクリック対応 Add End

        /// <summary>
        /// レセプトメモ情報の更新
        /// </summary>
        /// <param name="strInXml">入力XML</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBUpdateReceiptMemo(string strInXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strXml = null;
            //object obj = null;

            //Fn3ReturnCode retCode = this.m_dgtDBAccess(DBAccessType.UpdateReceiptMemo, strInXml, ref strXml, null, ref obj);

            //return retCode;

            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 指示簿指示情報の更新
        /// </summary>
        /// <param name="strInXml">入力XML</param>
        /// <returns>リターンコード</returns>
        protected virtual Fn3ReturnCode DBUpdateIndDialysisAdd(string strInXml)
        {
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //string strXml = null;
            //object obj = null;

            //Fn3ReturnCode retCode = this.m_dgtDBAccess(DBAccessType.UpdateIndDialysisAdd, strInXml, ref strXml, null, ref obj);

            //return retCode;
            // CSI製電子カルテ（MIRAIS)についての対応 END
            return Fn3ReturnCode.Success;
        }


        // 2016/06/08 中村 サイクリック仕様変更 Add Start
        /// <summary>
        /// オーダ番号の取得
        /// </summary>
        /// <param name="xmlEventMng">イベント管理情報</param>
        /// <param name="OrderNo">オーダ番号</param>
        /// <returns>リターンコード</returns>
        private Fn3ReturnCode GetOrderNumber(XmlNode xmlEventMng, out string OrderNo)
        {
            Fn3ReturnCode RetCode = Fn3ReturnCode.Success;
            OrderNo = string.Empty;
            // CSI製電子カルテ（MIRAIS)についての対応 START
            //// 2016/07/25 中村 サイクリック受入指摘(Redmine#6015)
            ////string eventType = xmlEventMng["EVENT_CLASS"].InnerText;
            //string eventType = xmlEventMng["BASE_EVENT_CLASS"].InnerText;

            //if (!eventType.Equals("0"))
            //{
            //    // 変更もしくは削除区分

            //    // ------------------------------------
            //    // オーダ番号取得 from イベント管理
            //    // ------------------------------------
            //    string strOutXml = null;
            //    object obj = null;
            //    string[] strVal = new string[2];
            //    strVal[0] = this.CooperationID;
            //    strVal[1] = xmlEventMng["SPECIFIC_KEY"].InnerText;
            //    RetCode = this.m_dgtDBAccess(DBAccessType.GetEventOrderNo, null, ref strOutXml, strVal, ref obj);
            //    if (RetCode.IsError || RetCode.IsException)
            //    {
            //        return RetCode;
            //    }
            //    OrderNo = (string)obj;

            //    if (!String.IsNullOrEmpty(OrderNo))
            //    {
            //        RetCode = DBTransaction();
            //        if (OrderNo == "未使用番号無し")
            //        {
            //            // ------------------------------------
            //            // イベント管理の更新
            //            // ------------------------------------
            //            obj = null;
            //            strVal = new string[4];
            //            strVal[0] = xmlEventMng["EVENT_SEQ_NUMBER"].InnerText;
            //            strVal[1] = xmlEventMng["EVENT_OCCUR_DATE"].InnerText;
            //            strVal[2] = OrderNo;
            //            strVal[3] = "2";
            //            RetCode = this.m_dgtDBAccess(DBAccessType.UpdateEventOrderNo, null, ref strOutXml, strVal, ref obj);
            //            if (RetCode.IsError || RetCode.IsException)
            //            {
            //                DBRollback();
            //                return RetCode;
            //            }
            //            RetCode = DBCommit();
            //            if (RetCode.IsError || RetCode.IsException)
            //            {
            //                DBRollback();
            //                return RetCode;
            //            }
            //            RetCode = Fn3ComPlugInReturnCode.NotNumberingWarning;
            //            this.TraceOut(RetCode, string.Format("COOP_ID={0} SPECIFIC_KEY={1}", this.CooperationID, xmlEventMng["SPECIFIC_KEY"].InnerText));
            //            return RetCode;
            //        }
            //        else
            //        {
            //            // ------------------------------------
            //            // イベント管理の更新
            //            // ------------------------------------
            //            obj = null;
            //            strVal = new string[4];
            //            strVal[0] = xmlEventMng["EVENT_SEQ_NUMBER"].InnerText;
            //            strVal[1] = xmlEventMng["EVENT_OCCUR_DATE"].InnerText;
            //            strVal[2] = OrderNo;
            //            strVal[3] = null;
            //            RetCode = this.m_dgtDBAccess(DBAccessType.UpdateEventOrderNo, null, ref strOutXml, strVal, ref obj);
            //            if (RetCode.IsError || RetCode.IsException)
            //            {
            //                DBRollback();
            //                return RetCode;
            //            }
            //            RetCode = DBCommit();
            //            if (RetCode.IsError || RetCode.IsException)
            //            {
            //                DBRollback();
            //                return RetCode;
            //            }
            //        }
            //    }
            //    else
            //    {
            //        eventType = "0";
            //    }
            //}
            //// 新規区分
            //if (eventType.Equals("0"))
            //{
            //    string strOutXml = null;
            //    string strIn = xmlEventMng["SPECIFIC_KEY"].InnerText;
            //    object objOut = null;
            //    this.m_dgtDBAccess(DBAccessType.GetPatidFromEventInfo, null, ref strOutXml, strIn, ref objOut);
            //    string strPatid = (string)objOut;

            //    // 新規
            //    Mutex mutex = new Mutex(false, string.Format("NKKCooperationServer_{0}", this.m_strOrderNoId));

            //    try
            //    {
            //        // ロック開始
            //        mutex.WaitOne();

            //        TraceOut(string.Format("#オーダ番号の発番開始（管理ID:{0}）#", this.m_strOrderNoId));

            //        // ------------------------------------
            //        // オーダ番号取得
            //        // ------------------------------------
            //        strOutXml = null;
            //        object obj = null;
            //        string[] strVal = new string[2];
            //        strVal[0] = this.m_strOrderNoId;
            //        strVal[1] = this.m_TargetSeriesCode;
            //        RetCode = this.m_dgtDBAccess(DBAccessType.GetOrderNumberManage, null, ref strOutXml, strVal, ref obj);
            //        if (RetCode.IsError || RetCode.IsException)
            //        {
            //            return RetCode;
            //        }
            //        string strBaseOrderNo = (string)obj;

            //        // ------------------------------------
            //        // オーダ番号発番
            //        // ------------------------------------
            //        RetCode = OrderNumbering(strPatid, strBaseOrderNo, out OrderNo);
            //        if (RetCode.IsSuccess)
            //        {
            //            RetCode = DBTransaction();

            //            // ------------------------------------
            //            // イベント管理の更新(発番した番号)
            //            // ------------------------------------
            //            obj = null;
            //            strVal = new string[4];
            //            strVal[0] = xmlEventMng["EVENT_SEQ_NUMBER"].InnerText;
            //            strVal[1] = xmlEventMng["EVENT_OCCUR_DATE"].InnerText;
            //            strVal[2] = OrderNo;
            //            strVal[3] = null;
            //            RetCode = this.m_dgtDBAccess(DBAccessType.UpdateEventOrderNo, null, ref strOutXml, strVal, ref obj);
            //            if (RetCode.IsError || RetCode.IsException)
            //            {
            //                DBRollback();
            //                return RetCode;
            //            }

            //            // ------------------------------------
            //            // 使用済みオーダ番号の登録
            //            // ------------------------------------
            //            obj = null;
            //            strVal = new string[4];
            //            strVal[0] = this.m_strOrderNoId;
            //            strVal[1] = this.m_TargetSeriesCode;
            //            strVal[2] = strPatid;
            //            strVal[3] = OrderNo;
            //            RetCode = this.m_dgtDBAccess(DBAccessType.InsertUsedOrderNo, null, ref strOutXml, strVal, ref obj);
            //            if (RetCode.IsError || RetCode.IsException)
            //            {
            //                DBRollback();
            //                return RetCode;
            //            }

            //            // ------------------------------------
            //            // 次に使用するオーダ番号設定
            //            // ------------------------------------
            //            string NextOrderNo = string.Empty;
            //            decimal decOrderNo;
            //            decimal decOrderNoMax;
            //            if (decimal.TryParse(OrderNo, out decOrderNo) &&
            //                decimal.TryParse(this.m_strOrderNoMax, out decOrderNoMax))
            //            {
            //                if ((decOrderNo + 1) > decOrderNoMax)
            //                {
            //                    // [オーダ番号 + 1]が[オーダ番号最大値]を超えている場合
            //                    // [オーダ番号最小値]を設定
            //                    NextOrderNo = this.m_strOrderNoMin;
            //                }
            //                else
            //                {
            //                    // [オーダ番号 + 1]を設定
            //                    NextOrderNo = (decOrderNo + 1m).ToString("0");
            //                }
            //            }

            //            // ------------------------------------
            //            // オーダ番号管理のオーダ番号の更新
            //            // ------------------------------------
            //            if (!string.IsNullOrEmpty(NextOrderNo))
            //            {
            //                obj = null;
            //                strVal = new string[3];
            //                strVal[0] = this.m_strOrderNoId;
            //                strVal[1] = this.m_TargetSeriesCode;
            //                strVal[2] = NextOrderNo;
            //                RetCode = this.m_dgtDBAccess(DBAccessType.UpdateOrderNumberManage, null, ref strOutXml, strVal, ref obj);
            //                if (RetCode.IsError || RetCode.IsException)
            //                {
            //                    DBRollback();
            //                    return RetCode;
            //                }
            //            }

            //            RetCode = DBCommit();
            //            if (RetCode.IsError || RetCode.IsException)
            //            {
            //                DBRollback();
            //                return RetCode;
            //            }
            //        }
            //        else if (RetCode.IsWarning)
            //        {
            //            // ------------------------------------
            //            // イベント管理の更新(未使用番号無し)
            //            // ------------------------------------
            //            obj = null;
            //            strVal = new string[4];
            //            strVal[0] = xmlEventMng["EVENT_SEQ_NUMBER"].InnerText;
            //            strVal[1] = xmlEventMng["EVENT_OCCUR_DATE"].InnerText;
            //            strVal[2] = OrderNo;
            //            strVal[3] = "2";
            //            RetCode = this.m_dgtDBAccess(DBAccessType.UpdateEventOrderNo, null, ref strOutXml, strVal, ref obj);
            //            if (RetCode.IsError || RetCode.IsException)
            //            {
            //                DBRollback();
            //                return RetCode;
            //            }

            //            RetCode = DBCommit();
            //            if (RetCode.IsError || RetCode.IsException)
            //            {
            //                DBRollback();
            //                return RetCode;
            //            }

            //            RetCode = Fn3ComPlugInReturnCode.NotNumberingWarning;
            //            this.TraceOut(RetCode, string.Format("COOP_ID={0} SPECIFIC_KEY={1}", this.CooperationID, xmlEventMng["SPECIFIC_KEY"].InnerText));
            //            return RetCode;

            //        }
            //        else
            //        {
            //            this.TraceOut(RetCode, string.Format("COOP_ID={0} PATID={1} NUMBERING_DATE={2}", this.CooperationID, strPatid, DateTime.Today.ToString("yyyy/MM/dd HH:mm:ss")));
            //            return RetCode;
            //        }
            //    }
            //    finally
            //    {
            //        TraceOut(string.Format("#オーダ番号の発番終了（管理ID:{0}）#", this.m_strOrderNoId));

            //        // ロック解放
            //        mutex.ReleaseMutex();
            //    }

            //}
            // CSI製電子カルテ（MIRAIS)についての対応 END

            return RetCode;
        }

        /// <summary>
        /// 使用済みオーダ番号テーブルのマージ
        /// </summary>
        /// <param name="table1">テーブル１</param>
        /// <param name="table2">テーブル２</param>
        /// <returns>マージされたテーブル</returns>
        /// <remarks>
        /// 使用済みオーダ番号の昇順にソートしたテーブルデータを返す
        /// </remarks>
        private DataTable OrderNoMerge(DataTable table1, DataTable table2)
        {
            DataTable table = table1.Clone();
            table.Merge(table1);
            table.Merge(table2);

            DataView view = new DataView(table);
            view.Sort = "USED_ORDER_NUMBER";

            return view.ToTable(true, new string[] { "USED_ORDER_NUMBER" });
        }

        /// <summary>
        /// オーダ番号発番
        /// </summary>
        /// <param name="strPatid">患者ID</param>
        /// <param name="strBaseOrderNo">検索起点となるオーダ番号</param>
        /// <param name="OrderNo">発番したオーダ番号</param>
        /// <returns>リターンコード</returns>
        private Fn3ReturnCode OrderNumbering(string strPatid, string strBaseOrderNo, out string OrderNo)
        {
            Fn3ReturnCode RetCode = Fn3ReturnCode.Success;
            OrderNo = null;

            //string strOutXml = null;
            //object obj = null;
            //string[] strVal = new string[6];
            //strVal[0] = this.m_strOrderNoId;
            //strVal[1] = this.m_strOrderNoMin;
            //strVal[2] = this.m_strOrderNoMax;
            //strVal[3] = strPatid;
            //strVal[4] = strBaseOrderNo;
            //strVal[5] = this.m_TargetSeriesCode;
            //// オーダ番号取得ファンクション実行
            //RetCode = this.m_dgtDBAccess(DBAccessType.ExecFnGetOrderNumber, null, ref strOutXml, strVal, ref obj);
            //if (RetCode.IsError || RetCode.IsException)
            //{
            //    return RetCode;
            //}

            //string strBuf = (string)obj;
            //if (string.IsNullOrEmpty(strBuf))
            //{
            //    // 取得失敗
            //    RetCode = Fn3ComPlugInReturnCode.OrderNumberingError;
            //    OrderNo = null;
            //}
            //else if ("NONE" == strBuf)
            //{
            //    // 未使用番号無し
            //    RetCode = Fn3ComPlugInReturnCode.NotNumberingWarning;
            //    OrderNo = "未使用番号無し";
            //}
            //else
            //{
            //    // 取得成功
            //    OrderNo = strBuf;
            //}

            return RetCode;
        }
        // 2016/06/08 中村 サイクリック仕様変更 Add End

        #endregion
    }

    /// <summary>
    /// リース期間延長クラス
    /// </summary>
    internal class BarSponsor : MarshalByRefObject, ISponsor
    {
        public TimeSpan Renewal(ILease lease)
        {
            return lease.InitialLeaseTime;
        }
    }
}
