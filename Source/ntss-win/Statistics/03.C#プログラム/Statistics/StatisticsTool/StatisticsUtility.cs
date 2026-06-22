using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Drawing.Text;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Fnw.StatisticsTool.Properties;
using NKKLoggingLib;
using TdcVersionInfoLib;

namespace Fnw.StatisticsTool
{
    /// <summary>
    /// 帳票レイアウトデザイナー用ユーティリティクラス
    /// </summary>
    public class StatisticsUtility
    {
        #region メンバ定数定義

        /// <summary>
        /// 製品名
        /// </summary>
        public const String PRODUCT_NAME = "GUIアプリ共通ライブラリ";

        /// <summary>
        /// アプリケーション共通設定ファイル内共通設定セクション識別子
        /// </summary>
        private const String CONFIG_COMMON_SECTION = @"Settings\CommonSection";
        /// <summary>
        /// アプリケーション共通設定ファイル内ログ設定セクション識別子
        /// </summary>
        private const String CONFIG_LOG_SECTION = @"Settings\LogSection";

        #endregion

        #region メンバ変数定義
        #endregion

        #region メンバプロパティ定義

        ///// <summary>
        ///// アプリケーションスタートアップディレクトリへのフルパスの取得を行います。
        ///// 終端に<code>System.IO.Path.DirectorySeparatorChar</code>は付加されません。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static String AppDirPath => System.Windows.Forms.Application.StartupPath;

        ///// <summary>
        ///// アプリケーションの設定ファイルの格納先ディレクトリへのフルパスの取得を行います。
        ///// 終端に<code>System.IO.Path.DirectorySeparatorChar</code>は付加されません。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static String ConfigDirPath => String.Format("{0}{1}{2}", AppDirPath, System.IO.Path.DirectorySeparatorChar, LayoutDesignerConstant.DIR_NAME_CONFIG_FILE);

        ///// <summary>
        ///// アプリケーションのサンプルレイアウトファイルの格納先ディレクトリへのフルパスの取得を行います。
        ///// 終端に<code>System.IO.Path.DirectorySeparatorChar</code>は付加されません。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static String ModelDirPath => String.Format("{0}{1}{2}", AppDirPath, System.IO.Path.DirectorySeparatorChar, LayoutDesignerConstant.DIR_NAME_MODEL_FILES);

        ///// <summary>
        ///// アプリケーションの最新ファイルの格納先ディレクトリへのフルパスの取得を行います。
        ///// 終端に<code>System.IO.Path.DirectorySeparatorChar</code>は付加されません。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static String UpdateContentsDirPath => String.Format("{0}{1}{2}", AppDirPath, System.IO.Path.DirectorySeparatorChar, LayoutDesignerConstant.DIR_NAME_UPDATE_FILES);

        ///// <summary>
        ///// アプリケーションのログ出力ディレクトリへのフルパスの取得を行います。
        ///// 終端に<code>System.IO.Path.DirectorySeparatorChar</code>は付加されません。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static String LogDirPath => String.Format("{0}{1}{2}", AppDirPath, System.IO.Path.DirectorySeparatorChar, LayoutDesignerConstant.DIR_NAME_LOG_FILE);

        ///// <summary>
        ///// アプリケーションの一時ファイル保存先ディレクトリへのフルパスの取得を行います。
        ///// 終端に<code>System.IO.Path.DirectorySeparatorChar</code>は付加されません。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static String TempDirPath => String.Format("{0}{1}{2}", AppDirPath, System.IO.Path.DirectorySeparatorChar, LayoutDesignerConstant.DIR_NAME_TEMP_FILE);

        ///// <summary>
        ///// アプリケーションのバックパップファイルの保存先ディレクトリへのフルパスの取得を行います。
        ///// 終端に<code>System.IO.Path.DirectorySeparatorChar</code>は付加されません。
        ///// </summary>
        //public static String BackupDirPath => String.Format("{0}{1}{2}", AppDirPath, System.IO.Path.DirectorySeparatorChar, LayoutDesignerConstant.DIR_NAME_BUCKUP_FILE);

        ///// <summary>
        ///// アプリケーションの一時帳票保存先ディレクトリへのフルパスの取得を行います。
        ///// 終端に<code>System.IO.Path.DirectorySeparatorChar</code>は付加されません。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static String WorkDirPath => String.Format("{0}{1}{2}", AppDirPath, System.IO.Path.DirectorySeparatorChar, LayoutDesignerConstant.DIR_NAME_WORK_FILE);

        ///// <summary>
        ///// マニュアルファイルの格納先ディレクトリへのフルパスの取得を行います。
        ///// 終端に<code>System.IO.Path.DirectorySeparatorChar</code>は付加されません。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static String ManualDirPath => String.Format("{0}{1}{2}", AppDirPath, System.IO.Path.DirectorySeparatorChar, LayoutDesignerConstant.DIR_NAME_MANUAL_FILE);

        ///// <summary>
        ///// 画像ファイルの格納先ディレクトリへのフルパスの取得を行います。
        ///// 終端に<code>System.IO.Path.DirectorySeparatorChar</code>は付加されません。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static String ImageDirPath => String.Format("{0}{1}{2}", AppDirPath, System.IO.Path.DirectorySeparatorChar, LayoutDesignerConstant.DIR_NAME_IMAGE_FILE);

        ///// <summary>
        ///// アプリケーション共通設定ファイルへのフルパスの取得を行います。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static String ConfigFilePath => String.Format("{0}{1}{2}", AppDirPath, System.IO.Path.DirectorySeparatorChar, LayoutDesignerConstant.FILE_NAME_CONFIG_FILE);

        ///// <summary>
        ///// データ項目リストファイルへのフルパスの取得を行います。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static String DataListFilePath => String.Format("{0}{1}{2}", ConfigDirPath, System.IO.Path.DirectorySeparatorChar, LayoutDesignerConstant.FILE_NAME_DATALIST_FILE);

        //// add 2023-03-13 NO5616 帳票表示項目の並び順を変更する 鵬 start
        ///// <summary>
        ///// データ項目ソートファイルへのフルパスの取得を行います。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static String DataOrderFilePath => String.Format("{0}{1}{2}", ConfigDirPath, System.IO.Path.DirectorySeparatorChar, LayoutDesignerConstant.FILE_NAME_DATAORDER_FILE);

        //// add 2023-03-13 NO5616 鵬 end

        //// add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
        ///// <summary>
        ///// 変換用データ項目リストファイルへのフルパスの取得を行います。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static String ConvertDataListFilePath => String.Format("{0}{1}{2}", ConfigDirPath, System.IO.Path.DirectorySeparatorChar, LayoutDesignerConstant.FILE_NAME_CONVERT_DATALIST_FILE);
        //// add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

        ///// <summary>
        ///// データ項目リストベースファイルへのフルパスの取得を行います。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static string DataListBaseFilePath => System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, LayoutDesignerConstant.FILE_NAME_DATALIST_BASE_FILE);

        ///// <summary>
        ///// マスターデータファイルへのフルパスの取得をおこないます。
        ///// 値の取得のみ可能です。
        ///// </summary>
        //public static String MasterFilePath => String.Format("{0}{1}{2}", ConfigDirPath, System.IO.Path.DirectorySeparatorChar, LayoutDesignerConstant.FILE_NAME_MASTER_FILE);

        /// <summary>
        /// 接続用ユーザIDの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public static String LoginID { get; private set; } = String.Empty;

        /// <summary>
        /// 接続用ユーザIDのパスワード取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public static String Password { get; private set; } = String.Empty;

        /// <summary>
        /// 接続用施設ハッシュ値の取得及び設定を行います。
        /// </summary>
        public static String FacilityHash { get; private set; } = String.Empty;

        /// <summary>
        /// 接続先サーバアドレスの取得及び設定を行います。
        /// </summary>
        public static String BaseUri { get; set; } = String.Empty;


        // add  20210827 #6137 BaseName -- 鄭 start
        // プログラム名
        public static String BaseName { get; set; } = String.Empty;
        // add  20210827 #6137 BaseName-- 鄭 end

        /// <summary>
        /// Amazon S3 バケットを使用するかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public static Boolean UseS3Bucket { get; private set; } = true;

        /// <summary>
        /// Amazon S3 バケットの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public static String S3Bucket { get; private set; } = String.Empty;
        public static string DownloadSourceFolder { get; private set; }

        // add サンプルレイアウトをサーバからダウンロードして、編集できる機能。 陳 start
        /// <summary>
        /// 最新ファイル取得先ファイル名の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public static string DownloadFileName { get; private set; } = String.Empty;

        /// <summary>
        /// Sサンプルレイアウト取得先フォルダの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public static string ModelFolder { get; private set; } = String.Empty;

        /// <summary>
        /// サンプルレイアウト取得先ファイル名の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public static string ModelFileName { get; private set; } = String.Empty;
        // add サンプルレイアウトをサーバからダウンロードして、編集できる機能。 陳 end

        // add 2020-08-10 FNSI-仕様追加 ページ追加 李 start
        /// <summary>
        /// システム支援ドキュメント
        /// </summary>
        public static string HelpDocument { get; set; }
        /// <summary>
        /// システム・データ版
        /// </summary>
        public static string DataVersion { get; set; }
        // add 2020-08-10 FNSI-仕様追加 ページ追加 李 end

        // add FNSI-仕様追加 帳票モデルのバージョン判定 夏 start
        /// <summary>
        /// 帳票モデル版
        /// </summary>
        public static string ModelVersion { get; set; }
        // add FNSI-仕様追加 帳票モデルのバージョン判定 夏 end

        /// add #7297 初回リリース対象外の機能とその関連機能を隠す xiaosonglei start
        /// <summary>
        /// 新規登録タブのドロップダウンリスト設定
        /// </summary>
        public static String CreateDropCodeList { get; private set; } = String.Empty;
        // add #7297 初回リリース対象外の機能とその関連機能を隠す xiaosonglei end

        /// <summary>
        /// ログファイル保持日数の取得及び設定を行います。
        /// 既定値は 20 日です。
        /// </summary>
        private static Int32 LogFileKeepNumberOfDays { get; set; } = 20;

        /// <summary>
        /// ログファイル保持数の取得及び設定を行います。
        /// 既定値は 20 ファイルです。
        /// </summary>
        private static Int32 LogFileKeepNumberOfCount { get; set; } = 20;

        #endregion

        #region メンバ関数定義(アプリケーション開始/終了)

        /// <summary>
        /// アプリケーション共通開始前処理を実行します。
        /// </summary>
        /// <returns></returns>
        public static Boolean PreAppStartUp()
        {
            Boolean wRet = false;

            try
            {
                // 呼び出し元チェック
                if (System.Windows.Forms.Application.MessageLoop)
                {
                    throw new System.ApplicationException("アプリケーション開始前処理の呼び出しが不正です。");
                }

                // ログ出力設定
                NKKLogging wLogging = NKKLogging.GetInstance();
                // ログ識別子
                wLogging.LogExt = $"{"Statistics"}_{System.Net.Dns.GetHostName()}";
                // バージョン情報記録用処理登録(ログが変わった場合にログの先頭に記録するため)
                wLogging.FirstWriteEvent = VersionInfos.GetVersionInfo;

                wRet = true;
            }
            catch (Exception ex)
            {
                StatisticsUtility.RecordException(ex);
            }

            return wRet;
        }

        /// <summary>
        /// アプリケーション共通開始処理を実行します。
        /// </summary>
        /// <returns></returns>
        public static Boolean AppStartUp()
        {
            Boolean wRet = false;

            try
            {

                wRet = true;
            }
            catch (Exception ex)
            {
                StatisticsUtility.RecordException(ex);
            }
            return wRet;
        }

        /// <summary>
        /// アプリケーション共通終了処理を実行します。
        /// </summary>
        public static void AppEnd()
        {
            try
            {

            }
            finally
            {
            }
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 例外情報を記録し、画面にメッセージボックスを表示します。
        /// </summary>
        /// <param name="aEx">発生した例外情報</param>
        public static void RecordException(Exception aEx) => StatisticsUtility.RecordException(aEx, true);

        /// <summary>
        /// 例外情報を記録します。
        /// </summary>
        /// <param name="aEx">発生した例外情報</param>
        /// <param name="aIsShowMsg">画面にメッセージを表示する場合は True 、それ以外は Fasle 。</param>
        public static void RecordException(Exception aEx, bool aIsShowMsg) => StatisticsUtility.RecordException(null, aEx, aIsShowMsg);

        /// <summary>
        /// 例外情報を記録し、画面にメッセージボックスを表示します。
        /// </summary>
        /// <param name="aOwner">メッセージボックスを表示する場合の親フォーム</param>
        /// <param name="aEx">発生した例外情報</param>
        public static void RecordException(System.Windows.Forms.Form aOwner, Exception aEx) => StatisticsUtility.RecordException(aOwner, aEx, true);

        /// <summary>
        /// 例外情報を記録します。
        /// </summary>
        /// <param name="aOwner">メッセージボックスを表示する場合の親フォーム</param>
        /// <param name="aEx">発生した例外情報</param>
        /// <param name="aIsShowMsg">画面にメッセージを表示する場合は True 、それ以外は Fasle 。</param>
        public static void RecordException(System.Windows.Forms.Form aOwner, Exception aEx, bool aIsShowMsg)
        {
            RecordException(aOwner, aEx, aIsShowMsg, "致命的なエラーが発生しました");
        }

        /// <summary>
        /// 例外情報を記録します。
        /// </summary>
        /// <param name="aOwner">メッセージボックスを表示する場合の親フォーム</param>
        /// <param name="aEx">発生した例外情報</param>
        /// <param name="aIsShowMsg">画面にメッセージを表示する場合は True 、それ以外は Fasle 。</param>
        /// <param name="MSG_TITLE">メッセージボックスのタイトル</param>
        public static void RecordException(System.Windows.Forms.Form aOwner, Exception aEx, bool aIsShowMsg, string MSG_TITLE)
        {
            try
            {
                DateTime wNow = DateTime.Now;

                // 書き込みメッセージを作成
                var wLines = StatisticsUtility.MakeWriteMessageString(aEx).Split(new string[] { System.Environment.NewLine }, StringSplitOptions.None);

                // ファイルへ書き込み(要求)
                for (int i = 0; i < wLines.Length; i++)
                {
                    WriteLog(wNow, NKKLogging.LOGGING_CLASS.ERROR, wLines[i]);
                }

                // 画面にメッセージボックスを表示する場合
                if (aIsShowMsg)
                {
                    // 別スレッドからの呼び出しの場合は失敗するので表示しない
                    if (aOwner != null && aOwner.InvokeRequired) return;

                    MessageBox.Show(
                        aOwner,
                        StatisticsUtility.MakeShowMessageString(aEx),
                        MSG_TITLE,
                        System.Windows.Forms.MessageBoxButtons.OK,
                        System.Windows.Forms.MessageBoxIcon.Error);
                }
            }
            finally
            {
            }
        }

        /// <summary>
        /// ログを出力します。
        /// </summary>
        /// <param name="aLoggingClass"></param>
        /// <param name="aMessage"></param>
        public static void WriteLog(NKKLogging.LOGGING_CLASS aLoggingClass, string aMessage) => StatisticsUtility.WriteLog(DateTime.Now, aLoggingClass, aMessage);

        /// <summary>
        /// ログを出力します。
        /// </summary>
        /// <param name="aDatetime"></param>
        /// <param name="aLoggingClass"></param>
        /// <param name="aMessage"></param>
        public static void WriteLog(DateTime aDatetime, NKKLogging.LOGGING_CLASS aLoggingClass, string aMessage)
        {
            NKKLogging.GetInstance().AddLogInfo(aDatetime, StatisticsUtility.PRODUCT_NAME, aLoggingClass, aMessage);
        }

        #endregion

        #region メンバ関数定義(非公開)

        /// <summary>
        /// ログファイルへ書き込むメッセージを作成します。
        /// </summary>
        /// <param name="aEx"></param>
        /// <returns></returns>
        private static String MakeWriteMessageString(Exception aEx)
        {
            var wRet = new System.Text.StringBuilder();
            wRet = StatisticsUtility.MakeWriteMessageStringFromOneException(wRet, aEx, 1);
            return wRet.ToString();
        }

        /// <summary>
        /// １つの例外情報からイベントログ及びログファイルへ書込む文字列を作成して、既存の書込み文字列の末尾に追加します。
        /// </summary>
        /// <param name="aAppendedText"></param>
        /// <param name="aEx"></param>
        /// <param name="aIndent"></param>
        /// <returns></returns>
        private static System.Text.StringBuilder MakeWriteMessageStringFromOneException(System.Text.StringBuilder aAppendedText, System.Exception aEx, Int32 aIndent)
        {
            var wRet = aAppendedText;

            if (aEx != null)
            {
                String wSpace1 = new String(' ', aIndent);
                String wSpace2 = new String(' ', aIndent - 1);

                wRet.AppendFormat("|{0}【モジュール】 {1}{2}", wSpace1, aEx.Source, System.Environment.NewLine)
                    .AppendFormat("|{0}【例外クラス】 {1}{2}", wSpace1, aEx.GetType().ToString(), System.Environment.NewLine)
                    // mod  #7844 帳票（複数集計）：結合したセルに集計項目を設定すると、アップロードできない 2022-08-09 孟堅 start
                    // .AppendFormat("|{0}【エラー内容】 {1}{2}", aEx.Message , System.Environment.NewLine)
                    .AppendFormat("|{0}【エラー内容】 {1}{2}", wSpace1, ErrInfoConv(aEx.Message) , System.Environment.NewLine)
                    // mod  #7844 帳票（複数集計）：結合したセルに集計項目を設定すると、アップロードできない 2022-08-09 孟堅 end
                    .AppendFormat("|{0}【スタックトレース】----------------------------------------{1}", wSpace1, System.Environment.NewLine)
                    .AppendFormat("|{0}【モジュール】 {1}{2}", wSpace2, aEx.StackTrace, System.Environment.NewLine)
                    .AppendFormat("|{0}【スタックトレース】----------------------------------------{1}", wSpace1, System.Environment.NewLine);
            }

            // さらに潜る
            if (aEx.InnerException != null)
            {
                wRet = MakeWriteMessageStringFromOneException(wRet, aEx.InnerException, aIndent + 1);
            }

            return wRet;
        }
        // add  #7844 帳票（複数集計）：結合したセルに集計項目を設定すると、アップロードできない 2022-08-09 孟堅 start
        /// <summary>
        ///  エラーメッセージ変換　
        /// </summary>
        /// <param name="exInfo">本来のエラーあたまっ情報</param>
        /// <returns>変換した情報</returns>
        private static string ErrInfoConv(string exInfo) {
            string conStr=String.Empty;
            switch (exInfo)
            {
                case "この操作は結合したセルには行えません。":
                    conStr= "集計範囲内に結合セルの数が統一していない";
                    break;
                default:
                    conStr = exInfo;
                    break;
            }
            return conStr;
        }
        // add #7844 帳票（複数集計）：結合したセルに集計項目を設定すると、アップロードできない 2022-08-09 孟堅 end
        /// <summary>
        /// 画面に表示するためのメッセージを作成します。n
        /// </summary>
        /// <param name="aEx"></param>
        /// <returns></returns>
        private static String MakeShowMessageString(Exception aEx)
        {
            var wRet = new System.Text.StringBuilder();

            wRet.Length = 0;
            wRet.AppendLine(aEx.Message);

            if (aEx.InnerException != null)
            {
                // 1階層分のみ画面に表示する
                String wMessage = "このエラーに関する詳細メッセージはありません。";
                if (!String.IsNullOrEmpty(aEx.InnerException.Message))
                {
                    wMessage = aEx.InnerException.Message;
                }
                wRet.AppendLine(wMessage);
            }

            return wRet.ToString();
        }

        //private static PrivateFontCollection pfcYu = new PrivateFontCollection();
        //private static PrivateFontCollection pfcSegmdl2 = new PrivateFontCollection();
        //private static bool initilizedForFont = false;

        //public enum ResourceFont
        //{
        //    YU = 0,
        //    SEGMDL2
        //}

        //[System.Runtime.InteropServices.DllImport("gdi32.dll", ExactSpelling = true)]
        //private static extern IntPtr AddFontMemResourceEx(byte[] pbFont, int cbFont, IntPtr pdv, out uint pcFonts);

        ///// <summary>
        ///// リソース埋め込みのフォントを準備
        ///// </summary>
        ///// <param name="argResourceFontBytes">リソース埋め込みのフォント</param>
        ///// <param name="argPfc">格納先となるPrivateFontCollection</param>
        //private static void ReadyResourceFont(byte[] argResourceFontBytes, PrivateFontCollection argPfc)
        //{
        //    IntPtr fontBytesPtr = System.Runtime.InteropServices.Marshal.AllocCoTaskMem(argResourceFontBytes.Length);
        //    System.Runtime.InteropServices.Marshal.Copy(argResourceFontBytes, 0, fontBytesPtr, argResourceFontBytes.Length);
        //    uint cFonts;
        //    AddFontMemResourceEx(argResourceFontBytes, argResourceFontBytes.Length, IntPtr.Zero, out cFonts);
        //    argPfc.AddMemoryFont(fontBytesPtr, argResourceFontBytes.Length);
        //    System.Runtime.InteropServices.Marshal.FreeCoTaskMem(fontBytesPtr);
        //}

        ///// <summary>
        ///// 本クラスのフォント機能を使用する前に呼び出す必要があるメソッド(※コンストラクタ的)
        ///// </summary>
        //public static void InitForFont()
        //{
            // リソース埋め込みフォント「Yu Gothic UI」を pfcの添え字[0] で準備
            //ReadyResourceFont(Resources.YuGothicUI, pfcYu);
            // リソース埋め込みフォント「Segoe MDL2 Assets」 pfcの添え字[1] で準備
            //ReadyResourceFont(Resources.segmdl2, pfcSegmdl2);
        //}

        ///// <summary>
        ///// リソース埋め込みのフォントファミリを取得
        ///// </summary>
        ///// <param name="argRf">0から順に定義したフォント番号</param>
        ////public static FontFamily GetResourceFontFamily(ResourceFont argRf)
        ////{
        ////    if (false == initilizedForFont)
        ////    {
        ////        //InitForFont();
        ////        initilizedForFont = true;
        ////    }

        ////    switch (argRf)
        ////    {
        ////        case ResourceFont.YU: return pfcYu.Families[0];
        ////        case ResourceFont.SEGMDL2: return pfcSegmdl2.Families[0];
        ////        default: return pfcYu.Families[0]; // 念のための範囲外対応
        ////    }
        ////}

        //// add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        ///// <summary>
        ///// 施設コード
        ///// </summary>
        //public static string CurrentFacilityCd { get; set; } = String.Empty;

        ///// <summary>
        ///// 施設名
        ///// </summary>
        //public static string CurrentFacilityName { get; set; } = String.Empty;
        //// add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
        #endregion


        /// <summary>
        /// リストを DataTable 
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="data"></param>
        /// <param name="columnNames"></param>
        /// <returns></returns>
        public static DataTable ConvertToDataTable<T>(List<T> data, Dictionary<string, string> columnNames = null)
        {
            // data が null の場合に空の DataTable を返す
            if (data == null)
            {
                return null;
            }

            DataTable dataTable = new DataTable(typeof(T).Name);

            // Tのプロパティを取得
            PropertyInfo[] properties = typeof(T).GetProperties(BindingFlags.Public | BindingFlags.Instance);

            // DataTableにカスタム列名でカラムを追加
            foreach (PropertyInfo prop in properties)
            {
                // columnNames が null の場合は空の辞書として扱う
                string columnName = columnNames != null && columnNames.ContainsKey(prop.Name)
                    ? columnNames[prop.Name]
                    : prop.Name;
                dataTable.Columns.Add(columnName, Nullable.GetUnderlyingType(prop.PropertyType) ?? prop.PropertyType);
            }

            // 各オブジェクトをDataRowに変換してDataTableに追加
            foreach (T item in data)
            {
                var values = new object[properties.Length];
                for (int i = 0; i < properties.Length; i++)
                {
                    values[i] = properties[i].GetValue(item, null);
                }
                dataTable.Rows.Add(values);
            }

            return dataTable;
        }
    }
}
