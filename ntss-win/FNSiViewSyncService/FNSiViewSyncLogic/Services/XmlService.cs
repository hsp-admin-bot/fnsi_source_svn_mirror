namespace FNSiViewSyncLogicLib.Services
{
    using NKKLoggingLib;
    using System;
    using System.IO;
    using System.Threading;
    using System.Xml;
    using FNSiViewSyncLogicLib.Common.Utilities;

    public static class XmlService
    {
        private static readonly string XMLG_FILE_NAME = "FNSiViewSync.xml";
        private static readonly int MaxRetryCount = FNSiViewSyncSetting.XMLRetryCount; // 最大リトライ回数
        private static readonly TimeSpan RetryDelay = TimeSpan.FromMilliseconds(FNSiViewSyncSetting.XMLRetryInterval); // リトライ間のディレイ

        private static void LogRetryAttempt(string message, string filePath, int attempt, TimeSpan delay)
        {
            string retryMessage = $"{message} リトライ回数: {attempt}, リトライ間隔: {delay.TotalSeconds}秒 [{filePath}]";
            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, retryMessage);
        }

        private static void LogError(string message, string filePath, Exception ex)
        {
            string errorMessage = $"{message} [{filePath}] {ex?.Message}";
            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, errorMessage);
        }

        /// <summary>
        /// 指定されたテーブル名に基づいて、最後の開始日時を更新します。
        /// </summary>
        /// <param name="name">更新するテーブルの名前。</param>
        /// <returns>処理が成功したかどうかを表すブール値。</returns>
        public static void UpdateViewXmlTableLastStartDateByName(string name)
        {
            UpdateViewXmlTableDateAttributeByName(name, "last_start_date", DateTime.Now.ToString("yyyyMMddHHmmss"));
        }

        /// <summary>
        /// 指定されたテーブル名に基づいて、最後の終了日時を更新します。
        /// </summary>
        /// <param name="name">更新するテーブルの名前。</param>
        /// <returns>処理が成功したかどうかを表すブール値。</returns>
        public static void UpdateViewXmlTableLastEndDateByName(string name)
        {
            UpdateViewXmlTableDateAttributeByName(name, "last_end_date", DateTime.Now.ToString("yyyyMMddHHmmss"));
        }

        /// <summary>
        /// 指定された属性に基づいて、指定されたテーブル名の日時属性を更新します。
        /// </summary>
        /// <param name="name">テーブル名</param>
        /// <param name="attributeName">更新する属性名</param>
        /// <returns>成功した場合はtrue、そうでない場合はfalse</returns>
        private static bool UpdateViewXmlTableDateAttributeByName(string name, string attributeName, string value)
        {
            string xmlfile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, XMLG_FILE_NAME);

            for (int attempt = 0; attempt <= MaxRetryCount; attempt++)
            {
                try
                {
                    lock (FNSiViewSyncSetting.lockFile)
                    {
                        if (!File.Exists(xmlfile))
                        {
                            if (attempt >= MaxRetryCount)
                            {
                                LogError("XMLファイルが存在しないため、最終的に更新に失敗しました。", xmlfile, null);
                            }
                            Thread.Sleep(RetryDelay);
                            continue;
                        }

                        XmlDocument xdoc = CommonUtil.LoadDecryptedXml(xmlfile);
                        XmlNodeList xmlView = xdoc.SelectNodes("//viewList/view");

                        bool nodeFound = false;
                        foreach (XmlNode xm in xmlView)
                        {
                            XmlElement xe = (XmlElement)xm;
                            if (xe.GetAttribute("key_name").Trim() == name)
                            {
                                xe.SetAttribute(attributeName, value);
                                nodeFound = true;
                                break;
                            }
                        }

                        if (nodeFound)
                        {
                            CommonUtil.SaveEncrypted(xdoc,xmlfile);
                            return true;
                        }
                        else
                        {
                            LogRetryAttempt($"更新対象のテーブルが見つかりません。再試行します: {name}", xmlfile, attempt + 1, RetryDelay);
                            Thread.Sleep(RetryDelay);
                        }
                    }
                }
                catch (XmlException ex)
                {
                    LogError("XMLファイルの読み込み中にエラーが発生しました。", xmlfile, ex);
                    return false;
                }
                catch (IOException ex)
                {
                    if (attempt < MaxRetryCount)
                    {
                        LogRetryAttempt($"ファイル操作中にIO例外が発生しました。再試行します: {name}", xmlfile, attempt + 1, RetryDelay);
                        Thread.Sleep(RetryDelay);
                    }
                    else
                    {
                        LogError($"XMLファイルの更新に最終的に失敗しました: {name} リトライ回数: {attempt}", xmlfile, ex);
                        return false;
                    }
                }
                catch (Exception ex)
                {
                    LogError("予期しないエラーが発生しました。", xmlfile, ex);
                    return false;
                }
            }
            return false; // すべてのリトライが失敗した場合
        }

        /// <summary>
        /// Xmlファイルの更新処理
        /// </summary>
        public static void UpdateViewXmlFile(ViewTableInfo viewTableInfo)
        {
            lock (FNSiViewSyncSetting.lockFile)
            {
                // XMLファイル名作成
                String xmlfile = AppDomain.CurrentDomain.BaseDirectory;
                if (!xmlfile.EndsWith("\\"))
                {
                    xmlfile += "\\";
                }
                xmlfile += XMLG_FILE_NAME;

                // XMLドキュメントのロードと更新をリトライ
                int retries = MaxRetryCount;
                int delay = RetryDelay.Milliseconds; // 1秒待機

                while (true)
                {
                    try
                    {
                        // テーブル情報取得(XMLより)
                        // 出力先テーブル情報配列
                        XmlDocument xdoc = CommonUtil.LoadDecryptedXml(xmlfile);
                        XmlNodeList xmlView = xdoc.SelectNodes("//viewList/view");

                        foreach (XmlNode xm in xmlView)
                        {
                            XmlElement xe = (XmlElement)xm;

                            string TableName = xe.GetAttribute("name").Trim();
                            string KeyName = xe.GetAttribute("key_name").Trim();
                            string Description = xe.GetAttribute("desc").Trim();
                            string SqlCd = xe.GetAttribute("sqlcd").Trim();
                            string Mode = xe.GetAttribute("Mode").Trim();
                            string FromDate = xe.GetAttribute("FromDate").Trim();
                            string ToDate = xe.GetAttribute("ToDate").Trim();

                            if (viewTableInfo.TableName.Equals(TableName) &&
                                viewTableInfo.KeyName.Equals(KeyName) &&
                                viewTableInfo.Desc.Equals(Description) &&
                                viewTableInfo.SqlCd.Equals(SqlCd) &&
                                viewTableInfo.Mode.Equals(Mode))
                            {
                                UpdateViewXmlTableDateAttributeByName(KeyName, "is_init", "1");
                                UpdateViewXmlTableDateAttributeByName(KeyName, "once_flg", "0");
                                break;
                            }
                        }
                        break; // 成功したらループを抜ける
                    }
                    catch (IOException ex)
                    {
                        if (--retries == 0)
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"XMLの更新に失敗しました: {viewTableInfo.KeyName}:{ex.Message}");

                        Console.WriteLine($"File is locked, retrying in {delay / 1000} seconds...");
                        Thread.Sleep(delay);
                    }
                }
            }
        }
    }
}
