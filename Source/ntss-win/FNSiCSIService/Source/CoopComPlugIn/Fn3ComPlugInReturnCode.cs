///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：プラグイン機能
// ファイル名：Fn3ComPlugIn.cs
// 説明      ：プラグイン機能の戻り値を表す。
//
//	Copyright(C) 2009 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2009/08/10	根津知則			新規作成
//
///////////////////////////////////////////////////////////////////////////////

using System;
using System.Collections.Generic;
using System.Text;

namespace jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn
{
	enum ComPlugInErrorCode
	{
		ExecuteStatusError = 1,
		SendMessageError = 2,
		InitializeCooperationException = 3,
		StartCooperationException = 4,
		ExecuteCooperationException = 5,
		StopCooperationException = 6,
		ReleaseCooperationException = 7,
		ReportSendModuleNotFound = 8,
		UseReportStoreValueNotFound = 9,
		ReportSendValueNotFound = 10,
		GetInitialValueError = 11,
		SetInitialValueError = 12,
		InitialKeyNotFound = 13,
		WrongEventManagerXml = 14,
		WrongCoopInfoXml = 15,
		WrongSendHistXml = 16,
		ConvertError = 17,
		ReportStoreNameNotFound = 18,
		CreatePDFNameError = 19,
		CreateBackupFoderError = 20,
		CreateBackupFileError = 21,
		BackupFileEncodingError = 22,
		BackupFileNotFound = 23,
		ReadBackupFileError = 24,
		GetExamScheDateTimeError = 25,
        UsedOrderNoWarning = 26,
        NotNumberingWarning = 27,
        OrderNumberingError = 28,
	}

	/// <summary>
	/// プラグインリターンコード管理クラス
	/// </summary>
	public class Fn3ComPlugInReturnCode : Fn3ReturnCode
	{
		/// <summary>
		/// 処理が実行できない状態です。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：1<br />
		/// メッセージ：処理が実行できない状態です。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode ExecuteStatusError = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.ExecuteStatusError, "処理が実行できない状態です。", ReturnCodeType.Error);

		/// <summary>
		/// イベント管理テーブルへのレコード追加に失敗しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：2<br />
		/// メッセージ：イベント管理テーブルへのレコード追加に失敗しました。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode SendMessageError = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.SendMessageError, "イベント管理テーブルへのレコード追加に失敗しました。", ReturnCodeType.Error);

		/// <summary>
		/// 連携初期化時に例外が発生しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：3<br />
		/// メッセージ：連携初期化時に例外が発生しました。<br />
		/// 種別：Exception
		/// </remarks>
		public static readonly Fn3ReturnCode InitializeCooperationException = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.InitializeCooperationException, "連携初期化時に例外が発生しました。", ReturnCodeType.Exception);

		/// <summary>
		/// 連携開始時に例外が発生しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：4<br />
		/// メッセージ：連携開始時に例外が発生しました。<br />
		/// 種別：Exception
		/// </remarks>
		public static readonly Fn3ReturnCode StartCooperationException = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.StartCooperationException, "連携開始時に例外が発生しました。", ReturnCodeType.Exception);

		/// <summary>
		/// 連携処理時に例外が発生しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：5<br />
		/// メッセージ：連携処理時に例外が発生しました。<br />
		/// 種別：Exception
		/// </remarks>
		public static readonly Fn3ReturnCode ExecuteCooperationException = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.ExecuteCooperationException, "連携処理時に例外が発生しました。", ReturnCodeType.Exception);

		/// <summary>
		/// 連携停止時に例外が発生しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：6<br />
		/// メッセージ：連携停止時に例外が発生しました。<br />
		/// 種別：Exception
		/// </remarks>
		public static readonly Fn3ReturnCode StopCooperationException = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.StopCooperationException, "連携停止時に例外が発生しました。", ReturnCodeType.Exception);

		/// <summary>
		/// 連携解放時に例外が発生しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：7<br />
		/// メッセージ：連携解放時に例外が発生しました。<br />
		/// 種別：Exception
		/// </remarks>
		public static readonly Fn3ReturnCode ReleaseCooperationException = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.ReleaseCooperationException, "連携解放時に例外が発生しました。", ReturnCodeType.Exception);

		/// <summary>
		/// 透析レポート送信モジュールが存在しないため、透析レポート送信イベントの追加に失敗しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：8<br />
		/// メッセージ：透析レポート送信モジュールが存在しないため、透析レポート送信イベントの追加に失敗しました。<br />
		/// 種別：Exception
		/// </remarks>
		public static readonly Fn3ReturnCode ReportSendModuleNotFound = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.ReportSendModuleNotFound, "透析レポート送信モジュールが存在しないため、透析レポート送信イベントの追加に失敗しました。", ReturnCodeType.Exception);

		/// <summary>
		/// 透初期設定マスタよりレポートストア使用設定が取得できなかったため、レポート処理を行いませんでした。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：9<br />
		/// 透初期設定マスタよりレポートストア使用設定が取得できなかったため、レポート処理を行いませんでした。<br />
		/// 種別：Warning
		/// </remarks>
		public static readonly Fn3ReturnCode UseReportStoreValueNotFound = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.UseReportStoreValueNotFound, "透初期設定マスタよりレポートストア使用設定が取得できなかったため、レポート処理を行いませんでした。", ReturnCodeType.Warning);

		/// <summary>
		/// 初期設定マスタより透析レポート送信設定が取得できなかったため、レポート送信を行いませんでした。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：10<br />
		/// メッセージ：初期設定マスタより透析レポート送信設定が取得できなかったため、レポート送信を行いませんでした。<br />
		/// 種別：Warning
		/// </remarks>
		public static readonly Fn3ReturnCode ReportSendValueNotFound = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.ReportSendValueNotFound, "初期設定マスタより透析レポート送信設定が取得できなかったため、レポート送信を行いませんでした。", ReturnCodeType.Warning);

		/// <summary>
		/// 初期設定情報の取得に失敗しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：11<br />
		/// メッセージ：初期設定情報の取得に失敗しました。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode GetInitialValueError = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.GetInitialValueError, "初期設定情報の取得に失敗しました。", ReturnCodeType.Error);

		/// <summary>
		/// 初期設定情報の更新に失敗しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：12<br />
		/// メッセージ：初期設定情報の更新に失敗しました。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode SetInitialValueError = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.SetInitialValueError, "初期設定情報の更新に失敗しました。", ReturnCodeType.Error);

		/// <summary>
		/// 初期設定情報取得時にキー名が存在しないため、取得に失敗しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：13<br />
		/// メッセージ：初期設定情報取得時にキー名が存在しないため、取得に失敗しました。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode InitialKeyNotFound = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.InitialKeyNotFound, "初期設定情報取得時にキー名が存在しないため、取得に失敗しました。", ReturnCodeType.Error);

		/// <summary>
		/// 不正なイベント管理情報XMLです。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：14<br />
		/// メッセージ：不正なイベント管理情報XMLです。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode WrongEventManagerXml = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.WrongEventManagerXml, "不正なイベント管理情報XMLです。", ReturnCodeType.Error);

		/// <summary>
		/// 不正な連携情報XMLです。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：15<br />
		/// メッセージ：不正な連携情報XMLです。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode WrongCoopInfoXml = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.WrongCoopInfoXml, "不正な連携情報XMLです。", ReturnCodeType.Error);

		/// <summary>
		/// 不正な送信履歴XMLです。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：16<br />
		/// メッセージ：不正な送信履歴XMLです。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode WrongSendHistXml = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.WrongSendHistXml, "不正な送信履歴XMLです。", ReturnCodeType.Error);

		/// <summary>
		/// 項目の変換に失敗しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：17<br />
		/// メッセージ：項目の変換に失敗しました。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode ConvertError = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.ConvertError, "項目の変換に失敗しました。", ReturnCodeType.Error);

		/// <summary>
		/// レポートストアのDLL名の取得に失敗したため、レポート処理を行いませんでした。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：18<br />
		/// メッセージ：レポートストアのDLL名の取得に失敗したため、レポート処理を行いませんでした。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode ReportStoreNameNotFound = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.ReportStoreNameNotFound, "レポートストアのDLL名の取得に失敗したため、レポート処理を行いませんでした。", ReturnCodeType.Error);

		/// <summary>
		/// PDFファイル名の生成に失敗したため、レポートストアへのイベント登録を行いませんでした。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：19<br />
		/// メッセージ：PDFファイル名の生成に失敗したため、レポートストアへのイベント登録を行いませんでした。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode CreatePDFNameError = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.CreatePDFNameError, "PDFファイル名の生成に失敗したため、レポートストアへのイベント登録を行いませんでした。", ReturnCodeType.Error);

		/// <summary>
		/// バックアップフォルダの作成に失敗しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：20<br />
		/// メッセージ：バックアップフォルダの作成に失敗しました。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode CreateBackupFolderError = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.CreateBackupFoderError, "バックアップフォルダの作成に失敗しました。", ReturnCodeType.Error);

		/// <summary>
		/// バックアップファイルの作成に失敗しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：21<br />
		/// メッセージ：バックアップファイルの作成に失敗しました。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode CreateBackupFileError = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.CreateBackupFileError, "バックアップファイルの作成に失敗しました。", ReturnCodeType.Error);

		/// <summary>
		/// バックアップファイルがUnicodeではないため、読み込みに失敗しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：22<br />
		/// メッセージ：バックアップファイルがUnicodeではないため、読み込みに失敗しました。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode BackupFileEncodingError = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.BackupFileEncodingError, "バックアップファイルがUnicodeではないため、読み込みに失敗しました。", ReturnCodeType.Error);

		/// <summary>
		/// バックアップファイルが存在しません。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：23<br />
		/// メッセージ：バックアップファイルが存在しません。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode BackupFileNotFound = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.BackupFileNotFound, "バックアップファイルが存在しません。", ReturnCodeType.Error);

		/// <summary>
		/// バックアップファイルの読み込みに失敗しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：24<br />
		/// メッセージ：バックアップファイルの読み込みに失敗しました。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode ReadBackupFileError = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.ReadBackupFileError, "バックアップファイルの読み込みに失敗しました。", ReturnCodeType.Error);

		/// <summary>
		/// 検査予定時刻の取得に失敗しました。
		/// </summary>
		/// <remarks>
		/// 処理区分：010<br />
		/// コード：25<br />
		/// メッセージ：検査予定時刻の取得に失敗しました。<br />
		/// 種別：Error
		/// </remarks>
		public static readonly Fn3ReturnCode GetExamScheDateTimeError = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.GetExamScheDateTimeError, "検査予定時刻の取得に失敗しました。", ReturnCodeType.Error);

        // 2016/06/13 中村 サイクリック仕様変更 Add Start
        /// <summary>
        /// 本日使用可能なオーダ番号をすべて使用してしまっている為、リトライします。
        /// </summary>
        /// <remarks>
        /// 処理区分：010<br />
        /// コード：26<br />
        /// 種別：Warning
        /// </remarks>
        public static readonly Fn3ReturnCode UsedOrderNoWarning = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.UsedOrderNoWarning, "本日使用可能なオーダ番号をすべて使用してしまっている為、リトライします。", ReturnCodeType.Warning);

        /// <summary>
        /// 最小値～最大値のオーダ番号をすべて使用してしまっている為、スキップします。
        /// </summary>
        /// <remarks>
        /// 処理区分：010<br />
        /// コード：27<br />
        /// 種別：Warning
        /// </remarks>
        public static readonly Fn3ReturnCode NotNumberingWarning = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.NotNumberingWarning, "最小値～最大値のオーダ番号をすべて使用してしまっている為、スキップします。", ReturnCodeType.Warning);
        // 2016/06/13 中村 サイクリック仕様変更 Add End

        /// <summary>
        /// オーダ番号の発番に失敗しました。
        /// </summary>
        /// <remarks>
        /// 処理区分：010<br />
        /// コード：28<br />
        /// メッセージ：オーダ番号の発番に失敗しました。<br />
        /// 種別：Error
        /// </remarks>
        public static readonly Fn3ReturnCode OrderNumberingError = new Fn3ReturnCode("010", (int)ComPlugInErrorCode.OrderNumberingError, "オーダ番号の発番に失敗しました。", ReturnCodeType.Error);

	}
}
