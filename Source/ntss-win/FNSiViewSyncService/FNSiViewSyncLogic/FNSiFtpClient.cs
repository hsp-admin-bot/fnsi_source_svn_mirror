using NKKLoggingLib;
using System;
using System.Collections.Generic;
using System.IO;
using System.Globalization;
using System.Net;
using System.Text;

namespace FNSiViewSyncLogicLib
{
    /// <summary>
    /// FNSiFtpClientクラス
    /// </summary>
    class FNSiFtpClient
    {
        #region プライベート定義

        /// <summary>
        /// サービス名称
        /// </summary>
        private readonly String SERVICE_NAME = String.Format("{0,-20}", System.Reflection.Assembly.GetExecutingAssembly().GetName().Name);

        /// <summary>
        /// IPAddress
        /// </summary>
        private String m_strIPAddress = "";

        /// <summary>
        /// ポートNo
        /// </summary>
        private int m_nPortNo = 0;

        /// <summary>
        /// UserId
        /// </summary>
        private String m_strUserId = "";

        /// <summary>
        /// パスワード
        /// </summary>
        private String m_strPW = "";

        /// <summary>
        /// FTPファイルパス
        /// </summary>
        private String m_strFtpPath = "";

        /// <summary>
        /// FTPファイル名
        /// </summary>
        private String m_strFtpFileName = "";

        /// <summary>
        /// Localファイルパス
        /// </summary>
        private String m_strLocalPath = "";

        /// <summary>
        /// Localファイル名
        /// </summary>
        private String m_strLocalFileName = "";

        #endregion


        #region パブリックメソッド

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FNSiFtpClient(string IPAddress, int PortNo, String UserId, String PW)
        {
            // 構築処理
            m_strIPAddress = IPAddress;
            m_nPortNo = PortNo;
            m_strUserId = UserId;
            m_strPW = PW;
            m_strFtpPath = "";
            m_strFtpFileName = "";
            m_strLocalPath = "";
            m_strLocalFileName = "";
        }

        /// <summary>
        /// デストラクタ
        /// </summary>
        ~FNSiFtpClient()
        {

        }

        /// <summary>
        /// データを取得する
        /// </summary>
        /// <returns></returns>
        public Boolean GetData()
        {
            // Para Check
            if (String.IsNullOrEmpty(m_strIPAddress) || 0 == m_nPortNo)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP IP/Port error.[IP:" + m_strIPAddress + " Port:" + m_nPortNo.ToString() + "]");

                return false;
            }

            if (String.IsNullOrEmpty(m_strFtpPath) || String.IsNullOrEmpty(m_strFtpFileName))
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP Path/FileName is Empty.[Path:" + m_strFtpPath + " FileName:" + m_strFtpFileName + "]");

                return false;
            }

            if (String.IsNullOrEmpty(m_strLocalPath) || String.IsNullOrEmpty(m_strLocalFileName))
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "Local Path/FileName is Empty.[Path:" + m_strLocalPath + " FileName:" + m_strLocalFileName + "]");

                return false;
            }

            FtpWebRequest reqFtp = null;

            try
            {
                // ローカルファイル名
                string localFile = m_strLocalPath + m_strLocalFileName;

                // ファイルが存在場合、バックアップファイル
                if (File.Exists(localFile) == true)
                {
                    string backupFile = m_strLocalPath + DateTime.Now.ToString("yyyyMMddHHmm") + "_" + m_strLocalFileName;
                    File.Move(localFile, backupFile);

                    // ログ記録
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "File[" + m_strLocalFileName + "] exists. BackedUp File[" + backupFile + "]");
                }

                FileStream outputStream = new FileStream(localFile, FileMode.Create);

                String ftpUrl = "ftp://" + m_strIPAddress + "/" + m_strFtpPath;

                reqFtp = (FtpWebRequest)FtpWebRequest.Create(new Uri(ftpUrl + m_strFtpFileName));
                reqFtp.Method = WebRequestMethods.Ftp.DownloadFile;
                reqFtp.UseBinary = true;
                reqFtp.UsePassive = true;
                if (!String.IsNullOrEmpty(m_strUserId))
                {
                    reqFtp.Credentials = new NetworkCredential(m_strUserId, m_strPW);
                }
                FtpWebResponse response = (FtpWebResponse)reqFtp.GetResponse();

                Stream ftpStream = response.GetResponseStream();
                long cl = response.ContentLength;

                int bufferSize = 2048;
                int readCount;
                byte[] buffer = new byte[bufferSize];

                readCount = ftpStream.Read(buffer, 0, bufferSize);
                while (readCount > 0)
                {
                    outputStream.Write(buffer, 0, readCount);
                    readCount = ftpStream.Read(buffer, 0, bufferSize);
                }

                ftpStream.Close();
                outputStream.Close();
                response.Close();
            }
            catch (Exception ex)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "Ftp error. Message:" + ex.Message);

                return false;
            }

            return true;
        }

        // #6843 ログアップロード LL start
        /// <summary>
        /// データを送信する
        /// </summary>
        /// <param name="fileInf">ファイル情報</param>
        /// <returns></returns>
        public bool SendLogToDevice(FileInfo fileInf)
        {
            // Para Check
            if (String.IsNullOrEmpty(m_strIPAddress) || 0 == m_nPortNo)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP IP/Port error.[IP:" + m_strIPAddress + " Port:" + m_nPortNo.ToString() + "]");

                return false;
            }

            // ログ送信パス存在チェック
            if (String.IsNullOrEmpty(FNSiViewSyncSetting.SendLogToBoxPath)) {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP Log Path error.[Path:" + FNSiViewSyncSetting.SendLogToBoxPath + "]");

                return false;
            }

            string ftpUrl = @"ftp://" + m_strIPAddress + "/" + FNSiViewSyncSetting.SendLogToBoxPath + fileInf.Name;

            FtpWebRequest reqFtp;
            try
            {
                reqFtp = (FtpWebRequest)WebRequest.Create(new Uri(ftpUrl));
                reqFtp.Credentials = new NetworkCredential(m_strUserId, m_strPW);
                reqFtp.UseBinary = true;
                reqFtp.Method = WebRequestMethods.Ftp.UploadFile;
                reqFtp.UsePassive = true;
                reqFtp.ContentLength = fileInf.Length;
                int buffLength = 2048;
                byte[] buff = new byte[buffLength];
                int contentLen;
                Stream strm = reqFtp.GetRequestStream();
                FileStream fs = fileInf.OpenRead();
                contentLen = fs.Read(buff, 0, buffLength);
                while (contentLen != 0)
                {
                    strm.Write(buff, 0, contentLen);
                    contentLen = fs.Read(buff, 0, buffLength);
                }
                strm.Close();
                fs.Close();
            }
            catch (Exception ex)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "Ftp File Upload error. Message:" + ex.Message);

                return false;
            }
            finally
            {
                if (fileInf.Name.Contains("zip"))
                {
                    fileInf.Delete();
                }
            }
            return true;
        }

        public void deleteFile(string fileName)
        {
            // Para Check
            if (String.IsNullOrEmpty(m_strIPAddress) || 0 == m_nPortNo)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP IP/Port error.[IP:" + m_strIPAddress + " Port:" + m_nPortNo.ToString() + "]");
            }

            // ログ送信パス存在チェック
            if (String.IsNullOrEmpty(FNSiViewSyncSetting.SendLogToBoxPath))
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP Log Path error.[Path:" + FNSiViewSyncSetting.SendLogToBoxPath + "]");
            }

            string ftpUrl = @"ftp://" + m_strIPAddress + "/" + FNSiViewSyncSetting.SendLogToBoxPath + fileName;
            // #8510 FNSiViewSyncServiceのログが翌日の日付になる　start
            //bool checkFile = FTPFileCheck(ftpUrl);
            // #8510 FNSiViewSyncServiceのログが翌日の日付になる　end

            FtpWebRequest reqFtp = null;
            try
            {
                reqFtp = (FtpWebRequest)WebRequest.Create(new Uri(ftpUrl));
                reqFtp.Credentials = new NetworkCredential(m_strUserId, m_strPW);
                reqFtp.UseBinary = true;
                reqFtp.Method = WebRequestMethods.Ftp.DeleteFile;
                reqFtp.UsePassive = true;
                string result = String.Empty;
                FtpWebResponse response = (FtpWebResponse)reqFtp.GetResponse();
                long size = response.ContentLength;
                Stream datastream = response.GetResponseStream();
                StreamReader sr = new StreamReader(datastream);
                result = sr.ReadToEnd();
                sr.Close();
                datastream.Close();
                response.Close();
            }
            catch (Exception ex)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "Ftp File Upload error. Message:" + ex.Message);
            }
            finally
            {
            }
        }

        public void deleteFileByFullPath(string path, string fileName = null)
        {
            // Para Check
            if (String.IsNullOrEmpty(m_strIPAddress) || 0 == m_nPortNo)
            {
                // ログ記録
                AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP IP/Port error.[IP:" + m_strIPAddress + " Port:" + m_nPortNo.ToString() + "]");
                return;
            }

            // 送信パス存在チェック
            if (String.IsNullOrEmpty(path))
            {
                // ログ記録
                AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP Log Path error.[Path:" + path + "]");
                return;
            }

            string ftpUrl;
            if (string.IsNullOrEmpty(fileName))
            {
                ftpUrl = @"ftp://" + m_strIPAddress + "/" + path + "/";
                List<string> fileList =  getFileListByFullPath(path);
                foreach(string name in fileList)
                {
                    string[] names =  name.Split('/');
                    deleteFileByFullPath(path, names[names.Length - 1]);
                }
            }
            else
            {
                ftpUrl = @"ftp://" + m_strIPAddress + "/" + path + "/" + fileName;
            }

            FtpWebRequest reqFtp;
            try
            {
                reqFtp = (FtpWebRequest)WebRequest.Create(new Uri(ftpUrl));
                reqFtp.Credentials = new NetworkCredential(m_strUserId, m_strPW);
                reqFtp.UseBinary = true;
                reqFtp.UsePassive = true;

                if (string.IsNullOrEmpty(fileName))
                {
                    reqFtp.Method = WebRequestMethods.Ftp.RemoveDirectory;
                }
                else
                {
                    reqFtp.Method = WebRequestMethods.Ftp.DeleteFile;
                }

                FtpWebResponse response = (FtpWebResponse)reqFtp.GetResponse();
                response.Close();
            }
            catch (WebException ex)
            {
                if (ex.Response != null)
                {
                    FtpWebResponse response = (FtpWebResponse)ex.Response;
                    if (response.StatusCode == FtpStatusCode.ActionNotTakenFileUnavailable ||
                        response.StatusCode == FtpStatusCode.ActionNotTakenFileUnavailableOrBusy)
                    {
                        // ファイルまたはディレクトリが存在しない場合のエラーを無視
                    }
                    else
                    {
                        // その他のエラーはログ記録
                        AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP operation error. Message: " + ex.Message);
                    }
                }
                else
                {
                    // その他のエラーはログ記録
                    AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP operation error. Message: " + ex.Message);
                }
            }
        }

        public List<string> getFileList()
        {
            // Para Check
            if (String.IsNullOrEmpty(m_strIPAddress) || 0 == m_nPortNo)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP IP/Port error.[IP:" + m_strIPAddress + " Port:" + m_nPortNo.ToString() + "]");
            }

            // ログ送信パス存在チェック
            if (String.IsNullOrEmpty(FNSiViewSyncSetting.SendLogToBoxPath))
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP Log Path error.[Path:" + FNSiViewSyncSetting.SendLogToBoxPath + "]");
            }

            string ftpUrl = @"ftp://" + m_strIPAddress + "/" + FNSiViewSyncSetting.SendLogToBoxPath;

            FtpWebRequest reqFtp = null;
            StringBuilder result = new StringBuilder();
            List<string> files = new List<string>();
            try
            {
                reqFtp = (FtpWebRequest)WebRequest.Create(new Uri(ftpUrl));
                reqFtp.UseBinary = true;
                reqFtp.Credentials = new NetworkCredential(m_strUserId, m_strPW);
                reqFtp.Method = WebRequestMethods.Ftp.ListDirectory;
                WebResponse response = reqFtp.GetResponse();
                StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.Default);
                string line = reader.ReadLine();
                while (line != null)
                {
                    result.Append(line);
                    result.Append("\n");

                    line = reader.ReadLine();
                }
                // to remove the trailing '\n'
                if (result != null && result.Length > 0)
                {
                    result.Remove(result.ToString().LastIndexOf('\n'), 1);
                }
                reader.Close();
                response.Close();
                string[] tmpFiles = result.ToString().Split('\n');
                
                for (int i =0; i< tmpFiles.Length; i++)
                {
                    if(tmpFiles[i].Contains("ViewSync_") && tmpFiles[i].Contains(".log"))
                    {
                        files.Add(tmpFiles[i]);
                    }

                }
                return files;
            }
            catch (Exception ex)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "Ftp File Upload error. Message:" + ex.Message);
            }
            finally
            {
            }
            return files;
        }

        public List<string> getFileListByFullPath(string path, int? days = null)
        {
            // Para Check
            if (String.IsNullOrEmpty(m_strIPAddress) || 0 == m_nPortNo)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP IP/Port error.[IP:" + m_strIPAddress + " Port:" + m_nPortNo.ToString() + "]");
            }

            string ftpUrl = @"ftp://" + m_strIPAddress + "/" + path;

            FtpWebRequest reqFtp = null;
            List<string> files = new List<string>();
            try
            {
                reqFtp = (FtpWebRequest)WebRequest.Create(new Uri(ftpUrl));
                reqFtp.UseBinary = true;
                reqFtp.Credentials = new NetworkCredential(m_strUserId, m_strPW);
                reqFtp.Method = WebRequestMethods.Ftp.ListDirectory;
                WebResponse response = reqFtp.GetResponse();
                StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.Default);
                string line = reader.ReadLine();
                List<string> fileNames = new List<string>();
                while (line != null)
                {
                    fileNames.Add(line);
                    line = reader.ReadLine();
                }
                reader.Close();
                response.Close();

                DateTime? thresholdDate = null;
                if (days.HasValue)
                {
                    thresholdDate = DateTime.Now.AddDays(-days.Value);
                }

                foreach (string fileName in fileNames)
                {
                    if(days.HasValue)
                    {
                        DateTime fileDate;
                        if (fileName.Length == 8)
                        {
                            fileDate = GetFileDateFromDirectoryName(fileName);
                        }
                        else
                        {
                            fileDate = GetFileDateFromFileName(fileName);
                        }
                        if (!thresholdDate.HasValue || fileDate < thresholdDate)
                        {
                            files.Add(fileName);
                        }
                    }
                    else
                    {
                        files.Add(fileName);
                    }

                }
                return files;
            }
            catch (Exception ex)
            {
                AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "Ftp File Upload error. Message:" + ex.Message);
                return files;
            }
        }

        /// <summary>
        /// FTPファイルパス 参照/設定用プロパティ
        /// </summary>
        public String FtpPath
        {
            get { return this.m_strFtpPath; }
            set
            {
                this.m_strFtpPath = value;
                if (this.m_strFtpPath.EndsWith("/") == false)
                {
                    this.m_strFtpPath += "/";
                }
            }
        }

        /// <summary>
        /// FTPファイル名 参照/設定用プロパティ
        /// </summary>
        public String FtpFileName
        {
            get { return this.m_strFtpFileName; }
            set { this.m_strFtpFileName = value; }
        }

        /// <summary>
        /// Localファイルパス 参照/設定用プロパティ
        /// </summary>
        public String LocalPath
        {
            get { return this.m_strLocalPath; }
            set
            {
                this.m_strLocalPath = value;
                if (this.m_strLocalPath.EndsWith("\\") == false)
                {
                    this.m_strLocalPath += "\\";
                }
            }
        }

        /// <summary>
        /// Localファイル名 参照/設定用プロパティ
        /// </summary>
        public String LocalFileName
        {
            get { return this.m_strLocalFileName; }
            set { this.m_strLocalFileName = value; }
        }

        #endregion


        #region プライベートメソッド

        public DateTime GetFileDateFromFileName(string fileName)
        {
            try
            {
                // ファイル名から日付部分を抽出
                string datePart = fileName.Substring(fileName.LastIndexOf('_') + 1, 8);
                return DateTime.ParseExact(datePart, "yyyyMMdd", CultureInfo.InvariantCulture);
            }
            catch (Exception ex)
            {
                AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "GetFileDateFromFileName error. Message: " + ex.Message);
                return DateTime.MinValue;
            }
        }

        public DateTime GetFileDateFromDirectoryName(string directoryName)
        {
            try
            {
                // ディレクトリ名から日付部分を抽出
                return DateTime.ParseExact(directoryName, "yyyyMMdd", CultureInfo.InvariantCulture);
            }
            catch (Exception ex)
            {
                AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "GetFileDateFromDirectoryName error. Message: " + ex.Message);
                return DateTime.MinValue;
            }
        }

        /// <summary>
        /// ログ記録
        /// </summary>
        /// <param name="dtNow">発生日時</param>
        /// <param name="LoggingClass">ログ区分</param>
        /// <param name="strMesssage">記録メッセージ</param>
        private void AddLogInfo(DateTime dtNow, NKKLogging.LOGGING_CLASS LoggingClass, String strMesssage)
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // ログ記録
            log.AddLogInfo(dtNow, SERVICE_NAME, LoggingClass, strMesssage);
        }

        #endregion
    }
}
