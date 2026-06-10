using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NKKCommon
{
    public class Updater
    {

        /// <summary>
        /// アプリケーションURI
        /// </summary>
        private static string WEB_APP_URI { get; set; } = "/ntss-admin-web";

        /// <summary>
        /// 最新ファイル群zipファイルのダウンロード先フォルダ
        /// </summary>
        private static string DownloadDestFolder => System.IO.Path.GetFullPath(BaseFolder + "\\..\\SelfUpdate\\" + System.Reflection.Assembly.GetEntryAssembly().GetName().Name + "\\dl");

        /// <summary>
        /// 実行ファイルの起動先フォルダ
        /// </summary>
        private static string BaseFolder { get; set; } = AppDomain.CurrentDomain.BaseDirectory.TrimEnd('\\');

        /// <summary>
        /// アップデート時のバックアップ先フォルダ
        /// </summary>
        private static string BackupFolder { get; set; } = System.IO.Path.GetFullPath(BaseFolder + "\\..\\SelfUpdate\\" + System.Reflection.Assembly.GetEntryAssembly().GetName().Name + "\\backup");

        // add サンプルレイアウトをサーバからダウンロードして、編集できる機能。 陳 start
        /// <summary>
        ///  初期化時のバックアップフォルダ
        /// </summary>
        private static string InitialBackupFolder { get; set; } = System.IO.Path.GetFullPath(BaseFolder + "\\Model");

        /// <summary>
        /// テキストエンコーディング参照用プロパティ(.NET 実装の既定のエンコード)
        /// </summary>
        private static Encoding EntryNameEncodingDefault { get; } = Encoding.Default;
        // add サンプルレイアウトをサーバからダウンロードして、編集できる機能。 陳 end

        /// <summary>
        /// テキストエンコーディング参照用プロパティ(UTF-8 形式のエンコーディング)
        /// </summary>
        private static Encoding EntryNameEncoding { get; } = Encoding.UTF8;

        /// <summary>
        /// 最新zipファイルの解凍パスワード
        /// </summary>
        public string DownloadFilePassword { get; set; } = "";

        /// <summary>
        /// sys_system_defineのctl_no
        /// </summary>
        public int SystemDefineVersionNo { get; set; }

        /// <summary>
        /// 実行ファイルの種類 0：サービス/else：実行ファイル
        /// </summary>
        public int ProcType { get; set; }

        /// <summary>
        /// ダウンロードするファイル名
        /// </summary>
        public string DownloadFileName { get; set; }

        // add サンプルレイアウトをサーバからダウンロードして、編集できる機能。 陳 start
        /// <summary>
        /// 更新するサンプルレイアウトファイル名
        /// </summary>
        public string ModelFileName { get; set; }

        /// <summary>
        /// バケット名
        /// </summary>
        public string BucketModel { get; set; }
        // add サンプルレイアウトをサーバからダウンロードして、編集できる機能。 陳 end

        /// <summary>
        /// バケット名
        /// </summary>
        public string Bucket { get; set; }

        /// <summary>
        /// システム設定取得URI /api/mstInfo/sysSystemDefine
        /// </summary>
        public static string GET_SYSTEM_DEFINE_URI { get; set; } = "/api/mstInfo/sysSystemDefine";

        /// <summary>
        /// S3からのファイルダウンロートURI /api/motion_record/detail/gathering/download
        /// </summary>
        public static string GET_FILE_DOWNLOAD_URI { get; set; } = "/api/motion_record/detail/gathering/download";


        /// <summary>
        /// ログ記録メソッド
        /// </summary>
        public Action<NKKLoggingLib.NKKLogging.LOGGING_CLASS, string> LoggingMethod;

        /// <summary>
        /// 新しいバージョンが公開されているか確認する
        /// </summary>
        /// <param name="targetAsm">バージョン確認を行うアセンブリオブジェクト</param>
        /// <returns>新しいバージョンが公開されている場合 True。新しいバージョンの公開が確認できない場合 False</returns>
        public bool IsPublishedNewVersion(System.Reflection.Assembly targetAsm)
        {
            Version lastver = null;

            // sys_system_defineのValueフィールドを読み込む
            string defineValue = GetSystemDefineValue(this.SystemDefineVersionNo);

            if (string.IsNullOrEmpty(defineValue) == false)
            {
                // valueをデシリアライズする
                using (var ms = new System.IO.MemoryStream(Encoding.UTF8.GetBytes(defineValue)))
                {
                    // valueをデシリアライズする
                    var value = new VersionValue();

                    var ser = new System.Runtime.Serialization.Json.DataContractJsonSerializer(value.GetType());
                    value = ser.ReadObject(ms) as VersionValue;
                    ms.Close();

                    // sys_system_defineに格納された最新バージョン番号
                    lastver = new Version(value.version);

                }

            }

            bool isReleasedNewVersion;
            //lastver = new Version("1.0.0.1");
            if (lastver != null)
            {
                // 設定取得

                // 更新対象のアセンブリ情報からバージョン取得
                Version runver = targetAsm.GetName().Version;

                // ログ記録：設定値
                LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, string.Format("取得した{0}の最新バージョン:{1}", targetAsm.ManifestModule.Name, lastver.ToString()));

                // 最新バージョンが動作バージョンより新しいか判定
                if (lastver.Equals(runver))
                {
                    // ログ記録：バージョン同一
                    LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, $"既に最新バージョンなのでアップデートを中止, 稼働バージョン:{runver.ToString()}, 最新バージョン:{lastver.ToString()}");

                    isReleasedNewVersion = false;

                }
                else
                {

                    // ログ記録：バージョン違い
                    string latestVersion = lastver.ToString();
                    LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, $"{targetAsm.ManifestModule.Name}のバージョン違いを検出したのでアップデートを実施, 稼働バージョン:{runver.ToString()}, 最新バージョン:{latestVersion}");

                    isReleasedNewVersion = true;

                }

            }
            else
            {
                // ログ記録：バージョン未設定
                LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, "最新バージョンが不明のためアップデートを中止");

                isReleasedNewVersion = false;

            }

            return isReleasedNewVersion;
        }

        /// <summary>
        /// sys_system_defineのvalueフィールドを読み込む
        /// </summary>
        /// <param name="systemDefineVersionNo">検索するctr_no</param>
        /// <returns>sys_system_defineのvalueフィールド</returns>
        public static string GetSystemDefineValue(int systemDefineVersionNo)
        {
            string value = string.Empty;
            string strUri = $"{NKKWebAccessLib.NKKWebAccess.BaseUri}{WEB_APP_URI}{GET_SYSTEM_DEFINE_URI}/{systemDefineVersionNo}?_={DateTime.Now.Ticks}";
            NKKWebAccessLib.NKKWebAccessResponse res = NKKWebAccessLib.NKKWebAccess.Get("最新バージョン設定取得", strUri).Result;
            if (res.response.IsSuccessStatusCode == true)
            {

                // JSON文字列をデシリアライズする
                var deserializedData = new List<SysSystemDefine>();
                using (var ms = new System.IO.MemoryStream(Encoding.UTF8.GetBytes(res.strContent)))
                {
                    var ser = new System.Runtime.Serialization.Json.DataContractJsonSerializer(deserializedData.GetType());
                    deserializedData = ser.ReadObject(ms) as List<SysSystemDefine>;
                    ms.Close();
                }
                if (deserializedData.Count > 0)
                {
                    // valueをデシリアライズする
                    value = deserializedData[0].Value;

                }

            }

            return value;
        }

        /// <summary>
        /// 自己アップデートする（MSI方式）
        /// ダウンロード先フォルダ内の *.msi を msiexec /quiet でサイレントインストールする。
        /// サービス停止・ファイル更新・サービス再起動はすべて MSI の CA が担当する。
        /// </summary>
        public void AppUpdate()
        {
            // 自プロセス情報を取得
            var pro = System.Diagnostics.Process.GetCurrentProcess();

            //　稼働時間：現在日時 - 処理開始日時
            LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, $"自プロセス情報, プロセス名：{pro.ProcessName}, プロセスID：{pro.Id}, ファイル名:{pro.MainModule.FileName}, 稼働時間：{DateTime.Now - pro.StartTime}");

            // ログ記録：アップデート開始
            LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, "最新ファイルにアップデート開始（MSI方式）");

            // DownloadDestFolder 内の MSI ファイルを検索
            string[] msiFiles = System.IO.Directory.GetFiles(DownloadDestFolder, "*.msi");
            if (msiFiles.Length == 0)
            {
                LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, $"MSIファイルが見つからないためアップデートを中止, 検索フォルダ:{DownloadDestFolder}");
                return;
            }

            string msiPath = msiFiles[0];
            string msiLogPath = System.IO.Path.GetFullPath(System.IO.Path.Combine(DownloadDestFolder, "..", "update.log"));

            LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, $"MSIファイル: {msiPath}");
            LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, $"MSIログ: {msiLogPath}");

            // Zone.Identifier（Mark of the Web）を削除してセキュリティ警告を抑制
            UnblockFile(msiPath);

            // MsiSystemRebootPending=1 を解消する。
            // PendingFileRenameOperations が存在すると Windows Installer が
            // RemoveExistingProducts の子プロセスで Error 1730 を返しアップグレードが失敗する。
            // このサービスは SYSTEM 権限で動作しているため HKLM への書き込みが可能。
            try
            {
                using (var key = Microsoft.Win32.Registry.LocalMachine.OpenSubKey(
                    @"SYSTEM\CurrentControlSet\Control\Session Manager", writable: true))
                {
                    if (key?.GetValue("PendingFileRenameOperations") != null)
                    {
                        key.DeleteValue("PendingFileRenameOperations");
                        LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, "PendingFileRenameOperations を削除しました（MsiSystemRebootPending 解消）");
                    }
                }
            }
            catch (Exception ex)
            {
                LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, $"PendingFileRenameOperations 削除失敗: {ex.Message}");
            }

            // msiexec でサイレントインストール実行
            // /quiet     : UILevel=2（設定ダイアログをスキップ）
            // /norestart : インストール後の自動再起動を抑制
            // /l*v       : 詳細ログを出力
            var app = new System.Diagnostics.ProcessStartInfo
            {
                Verb = "RunAs",
                FileName = "msiexec.exe",
                Arguments = $"/i \"{msiPath}\" /quiet /norestart /l*v \"{msiLogPath}\"",
                CreateNoWindow = false,
                UseShellExecute = true
            };

            // ログ記録：msiexec 起動前
            LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO,
                $"msiexec 起動開始, MSIパス:{msiPath}, ログパス:{msiLogPath}");
            try
            {
                System.Diagnostics.Process.Start(app);
                // ログ記録：msiexec 起動成功
                LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, "msiexec 起動成功");
            }
            catch (Exception ex)
            {
                // ログ記録：msiexec 起動失敗
                LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR,
                    $"msiexec 起動失敗, エラー:{ex.Message}");
            }

            // 自プロセスを終了（先に Exit することでファイルロックを解放する）
            Environment.Exit(0);
        }

        /// <summary>
        /// Zone.Identifier 代替データストリーム（Mark of the Web）を削除する。
        /// インターネット経由でダウンロードした MSI に付与されるセキュリティ属性を解除し、
        /// msiexec のサイレント実行をブロックされないようにする。
        /// </summary>
        /// <param name="filePath">対象ファイルのフルパス</param>
        private void UnblockFile(string filePath)
        {
            try
            {
                System.IO.File.Delete(filePath + ":Zone.Identifier");
                LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, $"Zone.Identifierを削除: {filePath}");
            }
            catch
            {
                // Zone.Identifier が存在しない場合は正常（例外は無視）
            }
        }

        /// <summary>
        /// Amazon S3 から最新プログラムファイルを取得する
        /// </summary>
        /// <returns>取得に成功した場合 True。取得できなかった場合 False。</returns>
        public bool GetLatestProgramFile()
        {
            bool isSuccess = false;

            // ダウンロードフォルダ作成
            System.IO.Directory.CreateDirectory(DownloadDestFolder);

            // ダウンロード先フォルダ内のファイル、フォルダをすべて削除
            try
            {
                var target = new System.IO.DirectoryInfo(DownloadDestFolder);
                foreach (System.IO.FileInfo file in target.GetFiles())
                {
                    file.Delete();
                }
                foreach (System.IO.DirectoryInfo dir in target.GetDirectories())
                {
                    dir.Delete(true);
                }
            }
            catch
            {

            }

            // 最新zipファイルをダウンロード
            string strdldata = string.Empty;
            string strUri = $"{NKKWebAccessLib.NKKWebAccess.BaseUri}{WEB_APP_URI}{GET_FILE_DOWNLOAD_URI}?_={DateTime.Now.Ticks}";
            var sbPostData = new StringBuilder();
            sbPostData.Append("{")
                     .AppendFormat("\"filename\": \"{0}\",", DownloadFileName)
                     .AppendFormat("\"bucket\": \"{0}\"", Bucket)
                     .Append("}");
            NKKWebAccessLib.NKKWebAccessResponse res = NKKWebAccessLib.NKKWebAccess.Post("最新バージョンダウンロード", strUri, sbPostData.ToString()).Result;
            if (res.response.IsSuccessStatusCode == true)
            {
                strdldata = res.strContent;
            }

            if (string.IsNullOrEmpty(strdldata) == false)
            {
                // ダウンロード先ファイル名取得
                string strdlfile = DownloadDestFolder + "\\" + DownloadFileName;

                try
                {
                    // ダウンロードしたファイルを保存
                    using (var wstream = System.IO.File.Create(strdlfile))
                    {
                        for (int i = 0; i < strdldata.Length / 2; i++)
                        {
                            wstream.WriteByte(Convert.ToByte(strdldata.Substring(i * 2, 2), 16));
                        }
                    }

                }
                catch (Exception)
                {
                    // ログ記録：ダウンロードファイルの保存失敗
                    LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, "最新バージョンのダウンロードの保存に失敗したためアップデートを中止");

                }

                // ファイルの存在確認
                if (System.IO.File.Exists(strdlfile) == true)
                {
                    // 該当ファイルあり

                    // ログ記録：ダウンロードファイルの保存成功
                    LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, $"最新バージョンのダウンロード成功, 対象ファイル名:{strdlfile}");

                    // 最新zipファイルを解凍
                    if (TdcLib.TdcLib.UnCompressZipFile(EntryNameEncoding, strdlfile, DownloadDestFolder, string.Empty,
                                                        DownloadFilePassword))
                    {

                        // ログ記録：解凍成功
                        LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, $"ダウンロードファイルの解凍成功, 対象ファイル名:{strdlfile}");


                        // ダウンロードファイルを削除
                        System.IO.File.Delete(strdlfile);

                        // ログ記録：ダウンロードファイルを削除
                        LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, String.Format("ダウンロードファイルを削除, 対象ファイル名:{0}", strdlfile));

                        // 解凍した MSI の Zone.Identifier を削除（AppUpdate での msiexec 実行に備える）
                        foreach (string msi in System.IO.Directory.GetFiles(DownloadDestFolder, "*.msi"))
                        {
                            UnblockFile(msi);
                        }

                        isSuccess = true;

                    }
                    else
                    {
                        // ログ記録：解凍失敗
                        LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR,
                            $"ダウンロードファイルの解凍失敗, 対象ファイル名:{strdlfile}, エラー:{TdcLib.TdcLib.Error?.Message}");
                    }


                }
            }
            else
            {
                // ログ記録：ダウンロード失敗
                LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, $"最新バージョンのダウンロードに失敗したためアップデートを中止, URI:{strUri}, Code:{res.response.StatusCode}");

            }

            return isSuccess;
        }

        // add サンプルレイアウトをサーバからダウンロードして、編集できる機能。 陳 start
        /// <summary>
        /// Amazon S3 から最新プサンプルレイアウトファイルを取得する
        /// </summary>
        /// <returns>取得に成功した場合 True。取得できなかった場合 False。</returns>
        public bool GetS3ModelFile()
        {
            bool isSuccess = false;

            // ダウンロードフォルダ作成
            System.IO.Directory.CreateDirectory(DownloadDestFolder);

            // ダウンロード先フォルダ内のファイル、フォルダをすべて削除
            try
            {
                var target = new System.IO.DirectoryInfo(DownloadDestFolder);
                foreach (System.IO.FileInfo file in target.GetFiles())
                {
                    file.Delete();
                }
                foreach (System.IO.DirectoryInfo dir in target.GetDirectories())
                {
                    dir.Delete(true);
                }
            }
            catch
            {
                // ログ記録：ダウンロード先フォルダ内のファイル、フォルダをすべて削除失敗
                LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, "削除失敗");
            }
            // 最新zipファイルをダウンロード
            string strdldata = string.Empty;
            string strUri = $"{NKKWebAccessLib.NKKWebAccess.BaseUri}{WEB_APP_URI}{GET_FILE_DOWNLOAD_URI}?_={DateTime.Now.Ticks}";
            var sbPostData = new StringBuilder();
            sbPostData.Append("{")
                     .AppendFormat("\"filename\": \"{0}\",", ModelFileName)
                     .AppendFormat("\"bucket\": \"{0}\"", BucketModel)
                     .Append("}");
            NKKWebAccessLib.NKKWebAccessResponse res = NKKWebAccessLib.NKKWebAccess.Post("最新サンプルレイアウトダウンロード", strUri, sbPostData.ToString()).Result;
            if (res.response.IsSuccessStatusCode == true)
            {
                strdldata = res.strContent;
            }

            if (string.IsNullOrEmpty(strdldata) == false)
            {
                // ダウンロード先ファイル名取得
                string strdlfile = DownloadDestFolder + "\\" + ModelFileName;

                try
                {
                    // ダウンロードしたファイルを保存
                    using (var wstream = System.IO.File.Create(strdlfile))
                    {
                        for (int i = 0; i < strdldata.Length / 2; i++)
                        {
                            wstream.WriteByte(Convert.ToByte(strdldata.Substring(i * 2, 2), 16));
                        }
                    }

                }
                catch (Exception)
                {
                    // ログ記録：ダウンロードファイルの保存失敗
                    LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, "最新サンプルレイアウトのダウンロードの保存に失敗したため更新を中止");
                }

                // ファイルの存在確認
                if (System.IO.File.Exists(strdlfile) == true)
                {
                    // 該当ファイルあり

                    // ログ記録：ダウンロードファイルの保存成功
                    LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, $"最新サンプルレイアウトのダウンロード成功, 対象ファイル名:{strdlfile}");

                    // 最新zipファイルを解凍
                    if (TdcLib.TdcLib.UnCompressZipFile(EntryNameEncodingDefault, strdlfile, DownloadDestFolder, string.Empty,
                                                        DownloadFilePassword))
                    {

                        // ログ記録：解凍成功
                        LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, $"ダウンロードファイルの解凍成功, 対象ファイル名:{strdlfile}");

                        // ダウンロードファイルを削除
                        System.IO.File.Delete(strdlfile);

                        // ログ記録：ダウンロードファイルを削除
                        LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, String.Format("ダウンロードファイルを削除, 対象ファイル名:{0}", strdlfile));

                        isSuccess = true;

                    }


                }
            }
            else
            {
                // ログ記録：ダウンロード失敗
                LoggingMethod(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, $"最新サンプルレイアウトのダウンロードの保存に失敗したため更新を中止, URI:{strUri}, Code:{res.response.StatusCode}");
            }
            return isSuccess;
        }

        /// <summary>
        /// サンプルレイアウトの自己アップデートする
        /// </summary>
        public void ModelFileUpdate(String filePafh = "")
        {

            try
            {

                if (String.Empty.Equals(filePafh))
                {
                    filePafh = DownloadDestFolder;
                }

                // ダウンロード先フォルダ内のファイル、フォルダをすべてコピー
                var target = new System.IO.DirectoryInfo(filePafh);

                foreach (var file in target.GetFileSystemInfos())
                {
                    //フォルダを取得
                    if (file is System.IO.DirectoryInfo)
                    {
                        ModelFileUpdate(((System.IO.DirectoryInfo)file).FullName);
                    }
                    else
                    {
                        //ファイルをコピー
                        string path = InitialBackupFolder + "\\" + ((System.IO.FileInfo)file).Directory.Name;

                        //パスが存在しますか
                        if (!System.IO.Directory.Exists(path))
                        {
                            System.IO.Directory.CreateDirectory(path);
                        }
                        ((System.IO.FileInfo)file).CopyTo(path + "\\" + file.Name, true);

                    }
                }
            }
            catch (Exception)
            {
                throw;
            }

        }
        // add サンプルレイアウトをサーバからダウンロードして、編集できる機能。 陳 end
    }
}
