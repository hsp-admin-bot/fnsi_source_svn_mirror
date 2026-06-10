using FNSiViewSyncLogicLib.Common.Utilities;
using FNSiViewSyncLogicLib.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NKKLoggingLib;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading;
using TdcLib;
using TdcSocketLib;
using System.Linq;


namespace FNSiViewSyncLogicLib
{
    /// <summary>
    /// FNSiSocketServiceクラス
    /// </summary>
    class FNSiSocketService
    {
        #region プライベート定義

        // サービス
        private readonly UpdateDataService updateDataService;

        /// <summary>
        /// サービス名称
        /// </summary>
        private readonly String SERVICE_NAME = String.Format("{0,-20}", System.Reflection.Assembly.GetExecutingAssembly().GetName().Name);

        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        private Exception m_Exception = null;

        /// <summary>
        /// スレッドオブジェクト
        /// </summary>
        private readonly Thread m_Thread = null;

        /// <summary>
        /// SocketサービスのポートNo
        /// </summary>
        private int m_nPortNo = 0;

        /// <summary>
        /// TdcBaseSocketServerオブジェクト
        /// </summary>
        private readonly TdcBaseSocketServer m_socketService = new TdcBaseSocketServer();

		#endregion

        #region パブリックメソッド

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FNSiSocketService()
        {
            // 構築処理

            // クライアント接続時
            this.m_socketService.ServiceName = this.SERVICE_NAME;
            this.m_socketService.ClientConnectedHandler = this.ClientConnected;
            this.m_socketService.ClientReceivedHandler = this.ClientReceived;

            // Socket Server用スレッド構築
            this.m_Thread = new Thread(this.DoWork)
            {
                Name = "FNSiSocketService処理スレッド",
                IsBackground = false
            };
        }

        /// <summary>
        /// デストラクタ
        /// </summary>
        ~FNSiSocketService()
        {
            // 処理終了
            this.Stop();
        }

        /// <summary>
        /// 処理開始
        /// </summary>
        /// <returns></returns>
        public Boolean Start()
        {
            Boolean bret = true;

            DateTime dtnow = DateTime.Now;

            try
            {
                // 処理開始成功時
                if (bret == true && this.m_Thread != null)
                {
                    // Socket Server用スレッド開始
                    this.m_Thread.Start();
                }

                // ログ記録
                LogService.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, "処理開始");
            }
            catch (Exception ex)
            {
                this.Error = ex;
            }

            return (bret);
        }

        /// <summary>
        /// 処理終了
        /// </summary>
        public void Stop()
        {
            DateTime dtnow = DateTime.Now;

            try
            {
                // Socketサーバー処理停止
                if (this.m_socketService.IsListen)
                {
                    this.m_socketService.StopListner();

                    // ログ記録
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, this.m_socketService.ServiceName.Trim() + "処理終了");
                }

                // Socket Server用スレッド停止
                if (this.m_Thread != null)
                {
                    // カウンタ値初期化
                    uint dwtickcount = (uint)System.Environment.TickCount;

                    // スレッドが終了するか10秒間待つ
                    while (!TdcLib.TdcLib.CheckTickCount(10 * 1000, dwtickcount, (uint)System.Environment.TickCount))
                    {
                        // スレッドが終了した場合
                        if (this.m_Thread.IsAlive == false)
                        {
                            // 処理を抜ける
                            break;
                        }
                        Thread.Sleep(100);
                    };
                }

                // ログ記録
                LogService.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, "処理終了");
            }
            catch (Exception ex)
            {
                this.Error = ex;
            }
        }

        /// <summary>
        /// SocketサービスのポートNo 参照/設定用プロパティ
        /// </summary>
        public int PortNo
        {
            get { return this.m_nPortNo; }
            set { this.m_nPortNo = value; }
        }

        #endregion

        #region プライベートメソッド

        /// <summary>
        /// Socket Server用スレッド実行処理
        /// </summary>
        private void DoWork()
        {
            try
            {
                // socketサービスを作成する
                m_socketService.ServiceName = this.SERVICE_NAME;
                if (m_socketService.StartListener(null, m_nPortNo, 2))
                {
                    // ログ記録
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, this.m_socketService.ServiceName.Trim() + "処理開始");
                }
                else
                {
                    throw (new Exception(this.m_socketService.ServiceName + "待ち受け失敗"));
                }
            }
            catch (Exception ex)
            {
                this.Error = ex;
            }
        }

        private readonly List<TdcBaseSocketServerClient> clientList = new List<TdcBaseSocketServerClient>();
        /// <summary>
        /// クライアントソケット接続/切断時
        /// </summary>
        /// <param name="Sender">ベースオブジェクト</param>
        /// <param name="Status">接続状態</param>
        private void ClientConnected(Object Sender, TdcBaseSocket.ConnectionStatus Status)
        {
            // 接続状態判定
            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "ClientConnected START");
            if (Status == TdcBaseSocket.ConnectionStatus.CONNECT)
            {
                // 接続完了時
                if (Sender is TdcBaseSocketServerClient cl)
                {
                    lock (clientList)
                    {
                        if (!clientList.Contains(cl))
                        {
                            clientList.Add(cl);
                        }
                    }
                    // ログ記録
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Client Socket Connected.[" + cl.GetConnectionString() + "]");
                }
            }
            // 切断時にはリストから削除
            else if (Status == TdcBaseSocket.ConnectionStatus.CLOSE)
            {
                if (Sender is TdcBaseSocketServerClient cl)
                {
                    lock (clientList)
                    {
                        clientList.Remove(cl);
                    }
                }
            }
        }
        public void StopAllClients()
        {
            // スナップショット
            List<TdcBaseSocketServerClient> clients;
            lock (clientList)
                clients = clientList.ToList();
           
            foreach (var client in clients)
            {
                try
                {

                    (client as IDisposable)?.Dispose();
                }
                catch (Exception ex)
                {

                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, ex.Message);
                }
            }

            lock (clientList)
                foreach (var c in clients) clientList.Remove(c);
        }


        /// <summary>
        /// クライアントソケット受信時
        /// </summary>
        /// <param name="Sender">ベースオブジェクト</param>
        /// <param name="cData">受信バッファ</param>
        /// <param name="nRecieveSize">受信byte数</param>
        private void ClientReceived(Object Sender, Byte[] cData, int nRecieveSize)
        {
            string currentJobKeyName = "";
            try
            {
                Dictionary<String, String> tbl = new Dictionary<string, string>();
                String errorCode = "";
                String errorMessage = "";
                String status = "";
                String zipFilePath = "";
                String zipFileName = "";
                String regDate = "";
                String paramList1 = "";
                int syncMode = -1;

                // 受信データ
                string strdata = Encoding.UTF8.GetString(cData, 0, nRecieveSize);

                // 受信データがJSONか
                if (JSONLib.IsJSONData(strdata))
                {
                    // JSON分解
                    tbl = JsonConvert.DeserializeObject<Dictionary<string, string>>(strdata);

                    // エラーコード取得
                    if (tbl.ContainsKey("ErrorCode") == true)
                    {
                        errorCode = tbl["ErrorCode"];
                    }

                    // エラーメッセージ取得
                    if (tbl.ContainsKey("ErrorMessage") == true)
                    {
                        errorMessage = tbl["ErrorMessage"];
                    }

                    // エラーメッセージ取得
                    if (tbl.ContainsKey("ErrorMessage") == true)
                    {
                        errorMessage = tbl["ErrorMessage"];
                    }

                    // ステータス取得
                    if (tbl.ContainsKey("status") == true)
                    {
                        status = tbl["status"];
                    }

                    // 一回同期データ取得
                    if (tbl.ContainsKey("tables") == true)
                    {
                        try
                        {
                            String tablesJson = "{\"tables\":" + tbl["tables"] + "}";
                            // JOSN->Dictionary
                            Dictionary<String, object> tablesDict = JsonConvert.DeserializeObject<Dictionary<String, object>>(tablesJson);
                            var tables = tablesDict["tables"] as JArray;
                            if (tables != null)
                            {
                                for (int i = 0; i < tables.Count; i++)
                                {
                                    ViewTableInfo tblInfo = new ViewTableInfo();

                                    String dataTmp = tables[i].ToString();
                                    dataTmp = dataTmp.Replace("\r\n", " ").Replace("\r", " ").Replace("\n", " ");
                                    var tableLine = JsonConvert.DeserializeObject<Dictionary<String, object>>(dataTmp);

                                    tblInfo.TableName = (String)tableLine["tblName"];
                                    tblInfo.KeyName = (String)tableLine["keyName"];
                                    tblInfo.JobKeyName = (String)tableLine["jobKeyName"];
                                    currentJobKeyName = tblInfo.JobKeyName;

                                    String dataKeyTmp = tableLine["dataKey"].ToString();
                                    dataKeyTmp = dataKeyTmp.Replace("\r\n", " ").Replace("\r", " ").Replace("\n", " ");
                                    Dictionary<String, object> dataKeyDict = JsonConvert.DeserializeObject<Dictionary<String, object>>(dataKeyTmp);

                                    tblInfo.FromDate = dataKeyDict.ContainsKey("fromDate") && dataKeyDict["fromDate"] != null ? (string)dataKeyDict["fromDate"] : "";
                                    tblInfo.ToDate = dataKeyDict.ContainsKey("toDate") && dataKeyDict["toDate"] != null ? (string)dataKeyDict["toDate"] : "";
                                    paramList1 = dataKeyDict.ContainsKey("paramList1") ? (string)dataKeyDict["paramList1"] : "";

                                    String sqlCdsTmp = (String)tableLine["sqlCds"].ToString();
                                    sqlCdsTmp = sqlCdsTmp.Replace("\r\n", " ").Replace("\r", " ").Replace("\n", " ");
                                    tblInfo.SqlCd = sqlCdsTmp;

                                    if (i == 0)
                                    {
                                        ClearViewSyncList(currentJobKeyName);
                                    }
                                    AddToViewSyncList(tblInfo, currentJobKeyName);
                                }

                            }
                        }
                        catch (Exception ex)
                        {
                            errorCode = "9999";
                            errorMessage = "Incorrect data->tables format. Message:" + ex.Message;
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, ex.StackTrace);
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "データ同期処理中にエラーが発生しました: " + ex.Message);
                        }
                    }


                    // 同期モード(1:起動、2:固定同期頻度1、3:固定同期頻度2、4:間隔同期)
                    if (tbl.ContainsKey("SyncMode") == true)
                    {
                        syncMode = Convert.ToInt32(tbl["SyncMode"]);
                    }
                    if (SyncMode.START != syncMode && SyncMode.MODE1 != syncMode && SyncMode.MODE2 != syncMode && SyncMode.TIME_SPAN != syncMode && SyncMode.Manual != syncMode)
                    {
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "データ同期:実行モードに取得に失敗しました.StartMode:" + syncMode + "]");
                    }

                    // 実行結果:登録日時(yyyyMMddhhmmss)
                    if (tbl.ContainsKey("RegDate") == true)
                    {
                        regDate = tbl["RegDate"];
                    }
                }
                else
                {
                    errorCode = "9999";
                    errorMessage = "Incorrect data format.";
                }

                // 正常場合
                if ("0000".Equals(errorCode))
                {
                    // ログ記録
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "データ同期:データ生成に成功しました.");

                    // ZIPファイルパス取得
                    if (tbl.ContainsKey("ZipFilePath") == true)
                    {
                        zipFilePath = tbl["ZipFilePath"];
                    }

                    // ZIPファイル名取得
                    if (tbl.ContainsKey("ZipFileName") == true)
                    {
                        zipFileName = tbl["ZipFileName"];
                    }

                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, "fileName_zip" + tbl["ZipFileName"] + "_____ threadID" + Thread.CurrentThread.ManagedThreadId);

                    if (String.IsNullOrEmpty(zipFilePath) || String.IsNullOrEmpty(zipFileName))
                    {
                        errorMessage = string.Format("データ同期:ZIPのファイルパス／ファイル名に取得に失敗しました. ZipFilePath:[{0}] ZipFileName:[{1}]", zipFilePath, zipFileName);
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, errorMessage);
                        return;
                    }

                    // ①ZIPファイルを取得する
                    string zipSaveDir;
                    if (GeZiptFileByFtp(FNSiViewSyncSetting.DataFolder, zipFilePath, zipFileName, out zipSaveDir) == false)
                    {
                        errorMessage = string.Format("データ同期:ZIPファイルの取得に失敗しました. ZipFilePath:[{0}] ZipFileName:[{1}]", zipFilePath, zipFileName);
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, errorMessage);
                        FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ErrorFlag = true;
                        FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncCntStatus = SyncCntStatus.LAST_END;
                        return;
                    }
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "データ同期:ZIPファイルの取得に成功しました.");
                    string path = Path.Combine(zipSaveDir, Path.GetFileNameWithoutExtension(zipFileName)) + "\\";
                    // ②ZIPファイルを解凍する
                    if (UnCompressZipFile(FNSiViewSyncSetting.DataFolder, path, zipFileName, zipSaveDir) == false)
                    {
                        errorMessage = string.Format("データ同期:ZIPファイルの解凍に失敗しました. ZipFilePath:[{0}] ZipFileName:[{1}]", FNSiViewSyncSetting.DataFolder, zipFileName);
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, errorMessage);
                        FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ErrorFlag = true;
                        FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncCntStatus = SyncCntStatus.LAST_END;
                        return;
                    }
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "データ同期:ZIPファイルの解凍に成功しました.");

                    // ③DBにデータを更新する
                    UpdateDataService updateDataService = new UpdateDataService();
                    if (updateDataService.AllReceivedUpdateData(path, errorCode, currentJobKeyName) == false)
                    {
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "データ同期:DBデータ更新に失敗しました.[" + strdata + "]");

                        // NGにZipファイルを変更する
                        FileRename(zipSaveDir, zipFileName, "NG_" + zipFileName);
                        FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ErrorFlag = true;  // 中断フラグを設定
                    }
                    else
                    {
                        // OKにZipファイルを変更する
                        FileRename(zipSaveDir, zipFileName, "OK_" + zipFileName);
                        if (SyncCntStatus.BEGIN == FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncCntStatus)
                        {
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "データ同期:ファイル受信に成功しました");
                        }
                        else if (SyncCntStatus.LAST_BEGIN == FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncCntStatus)
                        {
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "データ同期:データ更新に成功しました");
                        }
                    }

                    // FTP上のZIPファイルを削除
                    FNSiFtpClient fNSiFtpClient = new FNSiFtpClient(FNSiViewSyncSetting.FtpIPAddress, FNSiViewSyncSetting.FtpPortNo,
                        FNSiViewSyncSetting.FtpUserId, FNSiViewSyncSetting.FtpPW);
                    fNSiFtpClient.deleteFileByFullPath(zipFilePath, zipFileName);
                    
                }
                else
                {
                    // ログ記録
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "データ同期:受信に失敗しました.[" + strdata + "]");
                    FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ErrorFlag = true;
                }

                // 一回同期状態(END/LAST_END)を設定する
                try
                {
                    if (FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ErrorFlag)
                    {
                        FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncCntStatus = SyncCntStatus.LAST_END;
                        if(FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncList == null || FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncList.Count == 0)
                        {
                            throw new Exception($"ViewSyncListが取得できていません:{strdata}");
                        }
                        ViewTableInfo viewTableInfo = (ViewTableInfo)FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncList[0];

                        string currentStatus = status == "200" ? "500" : status;
                        string logMessage = "VIEWアプリ要求部エラー";
                        if (status != "200") logMessage = errorMessage;

                        string resultMessage;
                        if (viewTableInfo.Mode == "1")
                        {
                            resultMessage = $"{viewTableInfo.TableName}:{viewTableInfo.FromDate}~{viewTableInfo.ToDate}";
                        }
                        else if (paramList1 == "")
                        {
                            resultMessage = $"{viewTableInfo.TableName}";
                        }
                        else
                        {
                            resultMessage = $"{viewTableInfo.TableName}:{paramList1}";
                        }
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, $"errorMessage:{errorMessage}");
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=\"{currentStatus}\", message=\"{logMessage}\", result=\"{resultMessage}\"");
                    }
                    else if (SyncCntStatus.BEGIN == FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncCntStatus)
                    {
                        FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncCntStatus = SyncCntStatus.END;
                    }
                    else if (SyncCntStatus.LAST_BEGIN == FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncCntStatus)
                    {
                        FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncCntStatus = SyncCntStatus.LAST_END;
                    }
                }
                catch (Exception ex)
                {
                    FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncCntStatus = SyncCntStatus.LAST_END;
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, ex.StackTrace);
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=\"500\", message=\"VIEWアプリ要求部エラー:{ex.Message}\", result=\"\"");
                }
            }
            catch(Exception ex)
            {
                if (currentJobKeyName == "")
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"Jobの特定に失敗しました、サービスを再起動してください。");
                }
                else
                {
                    FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncCntStatus = SyncCntStatus.LAST_END;
                }
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, ex.StackTrace);
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=\"500\", message=\"VIEWアプリ要求部エラー:{ex.Message}\", result=\"\"");
            }
        }


        /// <summary>
        /// ファイル名を変更する
        /// </summary>
        /// <param name="path">ファイルパス</param>
        /// <param name="srcFile">変更前ファイル名</param>
        /// <param name="desFile">変更後ファイル名</param>
        private void FileRename(String path, String srcFile, String desFile)
        {
            try
            {
                String srcFileName = System.IO.Path.Combine(path, srcFile);
                String desFileName = System.IO.Path.Combine(path, desFile);
                File.Move(srcFileName, desFileName);

                srcFileName = System.IO.Path.Combine(path, desFile);
                desFileName = System.IO.Path.Combine(path, desFile);
                File.Move(srcFileName, desFileName);
            }
            catch (Exception ex)
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, ex.StackTrace);
            }
        }


        /// <summary>
        /// ZIPファイルを取得する
        /// </summary>
        /// <param name="localPath">Localパス</param>
        /// <param name="zipFilePath">ZIPファイルパス</param>
        /// <param name="zipFileName">ZIPファイル名</param>
        /// <returns></returns>
        private Boolean GeZiptFileByFtp(String localPath, String zipFilePath, String zipFileName, out string actualLocalPath)
        {
            // 現在日付フォルダを作成
            String dateFolder = DateTime.Now.ToString("yyyyMMdd");
            String targetPath = System.IO.Path.Combine(localPath, dateFolder);
            actualLocalPath = targetPath;
            // フォルダが存在しない場合は作成
            if (!System.IO.Directory.Exists(targetPath))
            {
                System.IO.Directory.CreateDirectory(targetPath);
            }

            int retryCount = 3;
            for (int attempt = 0; attempt < retryCount; attempt++)
            {
                try
                {
                    FNSiFtpClient ftpClient = new FNSiFtpClient(FNSiViewSyncSetting.FtpIPAddress, FNSiViewSyncSetting.FtpPortNo,
                        FNSiViewSyncSetting.FtpUserId, FNSiViewSyncSetting.FtpPW);

                    ftpClient.FtpPath = zipFilePath;
                    ftpClient.FtpFileName = zipFileName;
                    ftpClient.LocalPath = targetPath;
                    ftpClient.LocalFileName = zipFileName;

                    if (ftpClient.GetData() == false)
                    {
                        if (attempt == retryCount - 1)
                        {
                            return false;
                        }
                        else
                        {
                            // 一定時間待機してから再試行
                            System.Threading.Thread.Sleep(200);
                            continue;
                        }
                    }
                    return true;
                }
                catch (Exception ex)
                {
                    this.Error = ex;
                    if (attempt == retryCount - 1)
                    {
                        return false;
                    }
                    else
                    {
                        // 一定時間待機してから再試行
                        System.Threading.Thread.Sleep(200);
                        continue;
                    }
                }
            }
            return false;
        }

        /// <summary>
        /// ZIPファイルを解凍する
        /// </summary>
        /// <param name="localPath">Localパス</param>
        /// <param name="zipFileName">ZIPファイル名</param>
        /// <returns></returns>
        private Boolean UnCompressZipFile(string localPath, String localafterPath, String zipFileName,String zipSaveDir)
        {
            int retryCount = 3;
            for (int attempt = 0; attempt < retryCount; attempt++)
            {
                try
                {
                    // ローカルZIPファイル名
                    string localFile = Path.Combine(zipSaveDir, zipFileName);
                    // ファイルが存在しない場合、エラーログを記録して終了
                    if (File.Exists(localFile) == false)
                    {
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "ZIPファイルは存在しません。[" + localFile + "]");
                        return false;
                    }

                    var afterName = Path.GetFileName(localafterPath.TrimEnd('\\', '/'));
                    var extractDir = Path.Combine(zipSaveDir, afterName);
                    Directory.CreateDirectory(extractDir);
                    if (TdcLib.TdcLib.UnCompressZipFile(Encoding.Default, localFile, extractDir) == false)
                    {
                        this.Error = TdcLib.TdcLib.Error;
                        if (attempt == retryCount - 1)
                        {
                            return false;
                        }
                        else
                        {
                            // 一定時間待機してから再試行
                            System.Threading.Thread.Sleep(100);
                            continue;
                        }
                    }
                    return true;
                }
                catch (Exception ex)
                {
                    this.Error = ex;
                    if (attempt == retryCount - 1)
                    {
                        return false;
                    }
                    else
                    {
                        // 一定時間待機してから再試行
                        System.Threading.Thread.Sleep(100);
                        continue;
                    }
                }
            }
            return false;
        }

        /// <summary>
        /// 直前に発生したエラーオブジェクト取得/設定用プロパティ
        /// </summary>
        private Exception Error
        {
            get { return (this.m_Exception); }
            set
            {
                m_Exception = value;

                if (value != null)
                {
                    // 履歴作成
                    DateTime dtlog = DateTime.Now;
                    String strlogdata = String.Format("{0}, {1}", this.GetType().Name, value.ToString().Replace("\r\n", "{CRLF}"));

                    // 履歴に追記
                    LogService.AddLogInfo(dtlog, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
                }
            }
        }

        private void AddToViewSyncList(ViewTableInfo item, string currentJobKeyName)
        {
            lock (FNSiViewSyncSetting.lockFile)
            {
                if (item != null)
                {
                    FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncList.Add(item);
                }
            }
        }

        private void ClearViewSyncList(string currentJobKeyName)
        {
            lock (FNSiViewSyncSetting.lockFile)
            {
                FNSiViewSyncSetting.JobStatusList[currentJobKeyName].ViewSyncList.Clear();
            }
        }
        #endregion
    }
}
