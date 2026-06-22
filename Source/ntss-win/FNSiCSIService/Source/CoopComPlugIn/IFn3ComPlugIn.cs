///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：プラグイン機能
// ファイル名：IFn3ComPlugIn.cs
// 説明      ：連携本体とプラグインのインターフェース
//
//	Copyright(C) 2009 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2009/08/10	根津知則			新規作成
//  2011/06/23  青木雅文            表示用患者ID指定による患者情報取得メソッド追加
//  2011/08/26  青木雅文            透析スケジュール受信機能の追加
//  2012/11/13  大星憲士            系列施設対応
//	2013/05/07	大星憲士            系列施設複数連携対応
//  2014/11/06  阿部浩幸            指示変更情報取得対応
//  2015/04/21  中村圭之介          Redmine#4251対応
//  2015/06/24  中村圭之介          オーダ番号サイクリック対応
//  2016/06/10  中村圭之介          サイクリック仕様変更
//  2017/05/29  中村圭之介          指示簿受信対応
//
///////////////////////////////////////////////////////////////////////////////

using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using jp.co.nikkiso.fn3.Cooperation;
using jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopCommonInterface;
using jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopCommonDefine;

namespace jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn
{
	/// <summary>
	/// データベースアクセスタイプ
	/// </summary>
	public enum DBAccessType
	{
		/// <summary>
		/// 書き込み
		/// </summary>
		Update,

		/// <summary>
		/// 読み込み
		/// </summary>
		Select,

		/// <summary>
		/// 送信履歴テーブルの取得
		/// </summary>
		GetSendHist,

		/// <summary>
		/// 送信履歴テーブルの更新
		/// </summary>
		UpdateSendHist,

		/// <summary>
		/// 連携情報取得
		/// </summary>
		SelectCoopInfo,

		/// <summary>
		/// 連携情報更新
		/// </summary>
		UpdateCoopInfo,

		/// <summary>
		/// クエリ実行
		/// </summary>
		ExecQuery,

		/// <summary>
		/// DBトランザクション開始
		/// </summary>
		Transaction,

		/// <summary>
		/// DBコミット
		/// </summary>
		Commit,

		/// <summary>
		/// DBロールバック
		/// </summary>
		Rollback,

		/// <summary>
		/// 接続確認
		/// </summary>
		CheckConnect,

		/// <summary>
		/// 透析スケジュールのオーダ情報を取得する。
		/// </summary>
		GetSchOrderInfo,

        /// <summary>
        /// 患者IDと日付に該当する患者情報を取得する。
        /// </summary>
        GetPatInfo,

        /// <summary>
        /// 実績透析番号に該当する予約情報を取得する。
        /// </summary>
        GetDialysisScheduleInfo,

        /// <summary>
        /// 検査コメントマスタの取得をする。
        /// </summary>
        GetMstExaminComment,

		// <5.0.0.101> 患者死亡時に指示系データを終了状態に更新する 2010.01.14 M.Aoki Add Start
		/// <summary>
		/// 患者死亡時に指示系データを終了状態に更新する。
		/// </summary>
		DeleteIndDate,
		// <5.0.0.101> 患者死亡時に指示系データを終了状態に更新する 2010.01.14 M.Aoki Add End

        // FNW全患者リストを取得する 2010.05.05 K.Nakamura Add Start
        /// <summary>
        /// FNW全患者リストを取得する。
        /// </summary>
        GetAllPatId,
        // FNW全患者リストを取得する 2010.05.05 K.Nakamura Add End

        // 本日透析を予定している患者を取得する 2010.05.05 K.Nakamura Add Start
        /// <summary>
        /// 本日透析を予定している患者を取得する。
        /// </summary>
        GetSchPlanPatId,
        // 本日透析を予定している患者を取得する 2010.05.05 K.Nakamura Add End

		/// <summary>
		/// 最新のイベント情報（イベント管理テーブル、送信履歴テーブル）の内容を取得する。
		/// </summary>
		GetLatestEventInfo,

        // 2011/06/23 中村 ADD START 放射線結果受信連携対応
        /// <summary>
        /// 体重情報を取得する。
        /// </summary>
        GetWeightInfo,
        // 2011/06/23 中村 ADD START 放射線結果受信連携対応
        // 注射オーダ受信対応 2011.06.23 Start M.Aoki
        /// <summary>
        /// 表示用患者IDと日付に該当する患者情報を取得する。
        /// </summary>
        GetPatInfoDispid,
        // 注射オーダ受信対応 2011.06.23 End M.Aoki
        // <5.2.2.0> 2011.08.26 Add Start M.Aoki 透析スケジュール受信機能追加
        /// <summary>
        /// 透析工程チェックを行う
        /// </summary>
        GetDialysisState,
        /// <summary>
        /// 指定分類コードを取得する
        /// </summary>
        GetMstClassCode,
        /// <summary>
        /// 指定した透析スケジュール情報の変更されているかチェックする
        /// </summary>
        GetChangeStatus,
        /// <summary>
        /// 指定した透析予定情報を削除する
        /// </summary>
        DeleteDialysisSchedule,
        /// <summary>
        /// 掲示板へ書き込みを行う
        /// </summary>
        AddBbsInfo,
        /// <summary>
        /// 指定開始日時の透析情報を取得する
        /// </summary>
        GetDialysisResult,
        /// <summary>
        /// 透析スケジュール情報を登録又は更新する
        /// </summary>
        UpdateDialysisOrderRecive,
        /// <summary>
        /// 次患者情報を更新する
        /// </summary>
        UpdateNextPatirntInfo,
        // <5.2.2.0> 2011.08.26 Add End M.Aoki 透析スケジュール受信機能追加
        // <5.2.2.0> 2011.11.02 Add Start 中村 マスタ情報受信機能追加
        /// <summary>
        /// マスタ情報を更新する
        /// </summary>
        UpdateMasterInfoReceive,
        /// <summary>
        /// 指定した項目を使用している患者一覧を取得する
        /// </summary>
        GetItemUsedPatInfo,
        // <5.2.2.0> 2011.11.02 Add End 中村 マスタ情報受信機能追加
        // 2012.02.07 Add Start 中村
        /// <summary>
        /// 体重情報を取得する
        /// </summary>
        GetDialysisWeightInfo,
        /// <summary>
        /// 血圧情報を取得する
        /// </summary>
        GetDialysisBldPresInfo,
        /// <summary>
        /// 最終チェック日時を更新する
        /// </summary>
        UpdateLastCheckDate,
        // 2012.02.07 Add End 中村
// >>>>> 2012.05.08 M.Miyazaki
        /// <summary>
        /// 掲示板へ書き込みを行う
        /// </summary>
        RegisterBbsInfo,
// <<<<< 2012.05.08 M.Miyazaki

        // 2013/01/30 中村 バイタル登録対応 Add Start
        /// <summary>
        /// 血圧情報を登録する
        /// </summary>
        SetBloodPressureInfo,
        // 2013/01/30 中村 バイタル登録対応 Add End

        // 2014/08/25 中村 旭中央病院対応 Add Start
        /// <summary>
        /// 患者治療方法情報を登録する
        /// </summary>
        SetPatTreatInfo,

        /// <summary>
        /// 患者CTR情報を登録する
        /// </summary>
        SetPatCtrInfo,
        // 2014/08/25 中村 旭中央病院対応 Add End

        // 2014/11/06 阿部 指示変更情報取得対応 Add Start
        /// <summary>
        /// 指示変更情報を取得する
        /// </summary>
        GetIndChangeLog,
        // 2014/11/06 阿部 指示変更情報取得対応 Add End

        // 2015/06/24 中村 オーダ番号サイクリック対応 Add Start
        /// <summary>
        /// 使用済オーダ番号を削除・更新する。
        /// </summary>
        UpdateUsedOrderNo,
        // 2015/06/24 中村 オーダ番号サイクリック対応 Add End

        // 2016/06/08 中村 サイクリック仕様変更 Add Start
        /// <summary>
        /// 使用済オーダ番号を取得する。
        /// </summary>
        GetOrderNumberWithPatid,

        /// <summary>
        /// 使用済オーダ番号を取得する。
        /// </summary>
        GetOrderNumberWithNumDate,

        /// <summary>
        /// オーダ番号管理よりオーダ番号を取得する。
        /// </summary>
        GetOrderNumberManage,

        /// <summary>
        /// オーダ番号取得ファンクションを実行する。
        /// </summary>
        ExecFnGetOrderNumber,

        /// <summary>
        /// イベント管理のオーダ番号を更新する。
        /// </summary>
        UpdateEventOrderNo,

        /// <summary>
        /// 使用済みオーダ番号を登録する。
        /// </summary>
        InsertUsedOrderNo,

        /// <summary>
        /// オーダ番号管理のオーダ番号を更新する。
        /// </summary>
        UpdateOrderNumberManage,
        
        /// <summary>
        /// イベント管理のオーダ番号を取得する。
        /// </summary>
        GetEventOrderNo,

        /// <summary>
        /// イベント管理情報より患者IDを取得する。
        /// </summary>
        GetPatidFromEventInfo,
        // 2016/06/08 中村 サイクリック仕様変更 Add End

        // 2016/10/18 中村 加算IF
        /// <summary>
        /// レセプトメモ情報を更新する。
        /// </summary>
        UpdateReceiptMemo,

        // 2017/05/29 中村 指示簿受信対応
        /// <summary>
        /// 指示簿指示情報を更新する。
        /// </summary>
        UpdateIndDialysisAdd,

    }

	/// <summary>
	/// DBアクセスデリゲート
	/// </summary>
	/// <param name="type">アクセスタイプ</param>
	/// <param name="strInXml">XML文字列（入力）</param>
	/// <param name="strOutXml">Xml文字列（出力）</param>
	/// <param name="objExInParam">拡張パラメータ（入力）</param>
	/// <param name="objExOutParam">拡張パラメータ（出力）</param>
	/// <returns>リターンコード</returns>
	public delegate Fn3ReturnCode DBAccessDelegate(DBAccessType type, string strInXml, ref string strOutXml, object objExInParam, ref object objExOutParam);

    // 2014/09/12 Mod Start 阿部 イベント管理テーブルの対象日指定対応
    /// <summary>
    /// イベント登録デリゲート
    /// </summary>
    /// <param name="strPlugInDllFileName">プラグインDLLファイル名</param>
    /// <param name="type">メッセージ区分</param>
    /// <param name="strEventType">イベント区分　"0"：登録 "1"：変更 "2"：削除 "3"：その他 "4"：依頼要求</param>
    /// <param name="hashKeyInfo">キー情報</param>
    /// <param name="strSpecificKey">特定キー</param>
    /// <param name="strMemo">フリーコメント</param>
    /// <param name="waitFlag">他DLL処理待機フラグ</param>
    /// <param name="strSeriesCode">通知先の系列施設コード</param>
    /// <param name="dtTargetDate">対象日(イベント管理テーブルのTARGET_DATEとして指定する)</param>
    /// <returns></returns>
    public delegate bool RegistEventDelegate(string strPlugInDllFileName, MessageType type, string strEventType, Hashtable hashKeyInfo, string strSpecificKey, string strMemo, bool waitFlag, string strSeriesCode, DateTime dtTargetDate);
    //
    //// 系列施設複数連携対応 ここから 大星憲士 2013/05/07
    //#region 系列施設複数連携対応
    /////// <summary>
    /////// イベント登録デリゲート
    /////// </summary>
    /////// <param name="strPlugInDllFileName">プラグインDLLファイル名</param>
    /////// <param name="type">メッセージ区分</param>
    /////// <param name="strEventType">イベント区分　"0"：登録 "1"：変更 "2"：削除 "3"：その他 "4"：依頼要求</param>
    /////// <param name="hashKeyInfo">キー情報</param>
    /////// <param name="strSpecificKey">特定キー</param>
    /////// <param name="waitFlag">他DLL処理待機フラグ</param>
    /////// <param name="strMemo">フリーコメント</param>
    /////// <returns>成功時はtrue。それ以外がfalse。</returns>
    ////public delegate bool RegistEventDelegate(string strPlugInDllFileName, MessageType type, string strEventType, Hashtable hashKeyInfo, string strSpecificKey, string strMemo, bool waitFlag);
    //#endregion //系列施設複数連携対応
    //
    ///// <summary>
    ///// イベント登録デリゲート
    ///// </summary>
    ///// <param name="strPlugInDllFileName">プラグインDLLファイル名</param>
    ///// <param name="type">メッセージ区分</param>
    ///// <param name="strEventType">イベント区分　"0"：登録 "1"：変更 "2"：削除 "3"：その他 "4"：依頼要求</param>
    ///// <param name="hashKeyInfo">キー情報</param>
    ///// <param name="strSpecificKey">特定キー</param>
    ///// <param name="strMemo">フリーコメント</param>
    ///// <param name="waitFlag">他DLL処理待機フラグ</param>
    ///// <param name="strSeriesCode">通知先の系列施設コード</param>
    ///// <returns></returns>
    //public delegate bool RegistEventDelegate(string strPlugInDllFileName, MessageType type, string strEventType, Hashtable hashKeyInfo, string strSpecificKey, string strMemo, bool waitFlag, string strSeriesCode);
    //// 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
    // 2014/09/12 Mod End 阿部 イベント管理テーブルの対象日指定対応

	/// <summary>
	/// 連携ID取得デリゲート。他のプラグインの連携IDを連携機能名称をキーに取得します。
	/// </summary>
	/// <param name="strFunctionName">連携機能名称</param>
	/// <returns>連携IDを保持している文字列配列。</returns>
    public delegate string[] GetCooperationIDDelegate(string strFunctionName);

	/// <summary>
	/// 連携プラグイン生成用インターフェース<br />
	/// 連携プラグインを生成する場合はComPlugInクラスを継承してください。
	/// </summary>
    public interface IFn3ComPlugIn
	{
		#region "プロパティ"

		/// <summary>
        /// 連携ＩＤを取得する。
        /// </summary>
        string CooperationID
        {
            get;
        }

		/// <summary>
		/// DBアクセスデリゲートを設定します。
		/// </summary>
		DBAccessDelegate DBAccessDelegate
		{
			set;
		}

		/// <summary>
		/// 自己停止デリゲートを設定します。
		/// </summary>
		SelfStopDelegate SelfStopDelegate
		{
			set;
		}

		/// <summary>
		/// イベント登録デリゲートを設定します。
		/// </summary>
		RegistEventDelegate RegistEventDelegate
		{
			set;
		}

		/// <summary>
		/// 状態変更通知デリゲートを設定します。
		/// </summary>
		StatusInformationDelegate StatusInformationDelegate
		{
			set;
		}

		/// <summary>
		/// ログ出力デリゲートを設定します。
		/// </summary>
		OutLogDelegate OutLogDelegate
		{
			set;
		}

		/// <summary>
		/// アラーム送信通知デリゲートを設定します。
		/// </summary>
		SendAlarmDelegate SendAlarmDelegate
		{
			set;
		}

		/// <summary>
		/// 初期情報取得デリゲートを設定します。
		/// </summary>
		GetInitialValueDelegate GetInitialValueDelegate
		{
			set;
		}

		/// <summary>
		///	初期情報設定デリゲートを設定します。
		/// </summary>
		SetInitialValueDelegate SetInitialValueDelegate
		{
			set;
		}

		/// <summary>
		/// 連携ID取得デリゲートを設定します。
		/// </summary>
		GetCooperationIDDelegate GetCooperationIDDelegate
		{
			set;
		}

		/// <summary>
		/// プラグインの状態を取得します。
		/// </summary>
		StatusCode Status
		{
			get;
		}

        // 系列施設対応 ここから 大星憲士 2012/11/13
        /// <summary>系列施設運用モード</summary>
        SeriesPracticeModeType SeriesPracticeMode
        {
            set;
        }

        /// <summary>系列施設コード</summary>
        string LocalSeriesCode
        {
            set;
        }

        /// <summary>系列施設対応フラグ</summary>
        bool IsSeriesSupported
        {
            get;
        }
        // 系列施設対応 ここまで 大星憲士 2012/11/13

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        /// <summary>
        /// 通信先系列施設コード
        /// </summary>
        string ConnectSeriesCode
        {
            set;
            get;
        }
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

        // 2016/06/07 中村 サイクリック仕様変更 Add Start
        /// <summary>
        /// オーダ番号管理ID
        /// </summary>
        string OrderNoId
        {
            set;
        }
        /// <summary>
        /// オーダ番号最小値
        /// </summary>
        string OrderNoMin
        {
            set;
        }
        /// <summary>
        /// オーダ番号最大値
        /// </summary>
        string OrderNoMax
        {
            set;
        }
        // 2016/06/07 中村 サイクリック仕様変更 Add End 

		#endregion

		#region "メソッド"

		/// <summary>
        /// 連携の初期化を行う。
        /// </summary>
		/// <param name="strxXmlCoopSetting">連携IDマスタ情報</param>
        /// <returns>
		/// 初期化に成功した場合はFn3ReturnCode.Successを返す。
		/// </returns>
        Fn3ReturnCode InitializeCooperation(string strxXmlCoopSetting);

		/// <summary>
		/// 連携の開始を行う。
		/// </summary>
		/// <returns>開始に成功した場合はFn3ReturnCode.Successを返す。</returns>
		Fn3ReturnCode StartCooperation();

		/// <summary>
		/// イベント管理テーブル取得の1ポーリング単位の処理開始時に呼び出されます。
		/// イベント管理テーブルにイベントが存在しない場合は呼び出されません。
		/// </summary>
		/// <returns>リターンコード</returns>
		Fn3ReturnCode StartProcessCooperation();

        /// <summary>
        /// 連携の処理を行う。
        /// </summary>
		/// <param name="strEventMngXml">イベントマネージャー情報を保持しているstring</param>
        /// <returns>
		/// 処理に成功した場合は0をFn3ReturnCode.Successを返す。
		/// </returns>
        Fn3ReturnCode ExecuteCooperation(string strEventMngXml);

        // 2015/04/21 中村 Redmine#4251対応 Start
        /// <summary>
        /// 連携の処理を行う。
        /// </summary>
        /// <param name="strEventMngXml">イベントマネージャー情報を保持しているstring</param>
        /// <param name="strSeriesCode">系列施設コード</param>
        /// <returns>
        /// 処理に成功した場合は0をFn3ReturnCode.Successを返す。
        /// </returns>
        Fn3ReturnCode ExecuteCooperation(string strEventMngXml, string strSeriesCode);
        // 2015/04/21 中村 Redmine#4251対応 End

		/// <summary>
		/// イベント管理テーブル取得の1ポーリング単位の処理終了時に呼び出されます。
		/// イベント管理テーブルにイベントが存在しない場合は呼び出されません。
		/// </summary>
		void EndProcessCooperation();

		/// <summary>
		/// 連携の停止を行う。
		/// </summary>
		void StopCooperation();

		/// <summary>
        ///	連携の解放を行う。
        /// </summary>
        void ReleaseCooperation();

		#endregion
	}
}
