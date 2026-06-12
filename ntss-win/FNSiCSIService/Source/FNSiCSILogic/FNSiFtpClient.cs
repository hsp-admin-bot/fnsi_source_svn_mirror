using NKKLoggingLib;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace FNSiCSILogicLib
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
            catch(Exception ex)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "Ftp error. Message:" + ex.Message);

                return false;
            }

            return true;
        }

        /// <summary>
        /// ログを送信する
        /// </summary>
        /// <param name="fileInf">ファイル情報</param>
        /// <returns></returns>
        public bool SendLogToDevice(FileInfo fileInf)
        {
            string ftpPath = FNSiCSISetting.SendLogToBoxPath + "csilog/";
            return this.SendFileToDevice(fileInf, ftpPath);
        }

        /// <summary>
        /// ダンプを送信する
        /// </summary>
        /// <param name="fileInf">ファイル情報</param>
        /// <returns></returns>
        public bool SendDumpToDevice(FileInfo fileInf)
        {
            string ftpPath = FNSiCSISetting.SendLogToBoxPath + "csidump/";
            return this.SendFileToDevice(fileInf, ftpPath);
        }

        /// <summary>
        /// データを送信する
        /// </summary>
        /// <param name="fileInf">ファイル情報</param>
        /// <returns></returns>
        public bool SendDataToDevice(FileInfo fileInf)
        {
            string ftpPath = FNSiCSISetting.SendLogToBoxPath + "csidata/";
            return this.SendFileToDevice(fileInf, ftpPath);
        }

        /// <summary>
        /// ファイルを送信する
        /// </summary>
        /// <param name="fileInf">ファイル情報</param>
        /// <param name="ftpPath">FTPパス</param>
        /// <returns></returns>
        public bool SendFileToDevice(FileInfo fileInf, string ftpPath)
        {
            // Para Check
            if (String.IsNullOrEmpty(m_strIPAddress) || 0 == m_nPortNo)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP IP/Port error.[IP:" + m_strIPAddress + " Port:" + m_nPortNo.ToString() + "]");

                return false;
            }

            // ログ送信パス存在チェック
            if (String.IsNullOrEmpty(ftpPath))
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP Log Path error.[Path:" + ftpPath + "]");

                return false;
            }

            string ftpUrl = @"ftp://" + m_strIPAddress + "/" + ftpPath + fileInf.Name;

            FtpWebRequest reqFtp = null;
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

                if (fileInf.Name.Contains("zip"))
                {
                    fileInf.Delete();
                }
            }
            catch (Exception ex)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "Ftp File Upload error. Message:" + ex.Message);

                return false;
            }
            return true;
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
            if (String.IsNullOrEmpty(FNSiCSISetting.SendLogToBoxPath))
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP Log Path error.[Path:" + FNSiCSISetting.SendLogToBoxPath + "]");
            }

            string ftpUrl = @"ftp://" + m_strIPAddress + "/" + FNSiCSISetting.SendLogToBoxPath;

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

                for (int i = 0; i < tmpFiles.Length; i++)
                {
                    if (tmpFiles[i].Contains("ViewSync_") && tmpFiles[i].Contains(".log"))
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

        /// <summary>
        /// FTP上の指定ファイルを削除する
        /// </summary>
        /// <param name="ftpPath">FTPファイルパス</param>
        /// <param name="ftpFileName">FTPファイル名</param>
        /// <returns></returns>
        public Boolean DeleteFtpFile(String ftpPath, String ftpFileName)
        {
            // Para Check
            if (String.IsNullOrEmpty(m_strIPAddress) || 0 == m_nPortNo)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP IP/Port error.[IP:" + m_strIPAddress + " Port:" + m_nPortNo.ToString() + "]");
                return false;
            }

            if (String.IsNullOrEmpty(ftpPath) || String.IsNullOrEmpty(ftpFileName))
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "FTP Path/FileName is Empty.[Path:" + ftpPath + " FileName:" + ftpFileName + "]");
                return false;
            }

            if (ftpPath.EndsWith("/") == false)
            {
                ftpPath += "/";
            }

            String ftpUrl = "ftp://" + m_strIPAddress + "/" + ftpPath + ftpFileName;

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
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "Ftp File Delete error. Message:" + ex.Message);

                return false;
            }

            return true;
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
