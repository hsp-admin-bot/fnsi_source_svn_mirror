using FNSiViewSyncLogicLib.Common.Utilities;
using NKKLoggingLib;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Data;

namespace FNSiViewSyncLogicLib.Services
{
    class UpdateDataService
    {
        #region プライベート定義

        /// <summary>
        /// 下線(-)
        /// </summary>
        private readonly String UNDER_LINE = "_";

        /// <summary>
        /// 削除データのファイル名
        /// </summary>
        //private readonly String DELETE_FILE_NAME = "DeleteByDialysisNo";

        /// <summary>
        /// 削除ファイル名
        /// </summary>
        //private string StrDelFileName = string.Empty;

        /// <summary>
        /// 出力先テーブル情報配列
        /// </summary>
        private readonly List<String> DeldetTableNameList = new List<String>  { "V_RST_DIALYSIS",
                                                                                "V_RST_DIALYSIS_COND",
                                                                                "V_RST_DIALYSIS_EQUIP",
                                                                                "V_RST_DIALYSIS_MEDI",
                                                                                "V_RST_DIALYSIS_ADD",
                                                                                "V_RST_RECEIPT_MEMO"};
        #endregion

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public UpdateDataService()
        {
        }

        private void Cleanup(string JobKeyName)
        {
            FNSiViewSyncSetting.JobStatusList[JobKeyName].FilePathList.Clear();
            FNSiViewSyncSetting.JobStatusList[JobKeyName].OkMessageList.Clear();
            FNSiViewSyncSetting.JobStatusList[JobKeyName].NgMessageList.Clear();
            FNSiViewSyncSetting.JobStatusList[JobKeyName].OkFileCount = 0;
            FNSiViewSyncSetting.JobStatusList[JobKeyName].NgFileCount = 0;
            FNSiViewSyncSetting.JobStatusList[JobKeyName].TableData.Clear();
            FNSiViewSyncSetting.JobStatusList[JobKeyName].StrFileNameList.Clear();
        }

        /// <summary>
        /// すべてのファイルが揃っているかを判定し揃っていれば処理を実行
        /// </summary>
        public bool AllReceivedUpdateData(string Path, string Status, string JobKeyName)
        {
            try
            {
                FNSiViewSyncSetting.JobStatusList[JobKeyName].Bret = true;
                FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewSyncList = FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewSyncList;
                if (FNSiViewSyncSetting.JobStatusList[JobKeyName].ErrorFlag)
                {
                    // クリーンアップ
                    Cleanup(JobKeyName);
                    FNSiViewSyncSetting.JobStatusList[JobKeyName].ErrorFlag = false;
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, $"AllReceivedUpdateData:Interrupted==true");
                    return false;
                }

                FNSiViewSyncSetting.JobStatusList[JobKeyName].FilePathList.Add(Path);
                if (SyncCntStatus.LAST_BEGIN == FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewSyncCntStatus)
                {
                    TimeSpan timeDifference = DateTime.Now - FNSiViewSyncSetting.JobStatusList[JobKeyName].RequestTimeStart;
                    double milliseconds = timeDifference.TotalMilliseconds;
                    string formattedMilliseconds = String.Format("{0:N0}", milliseconds);
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"要求部処理時間計測:{{ JobKeyName: {JobKeyName}, time: {formattedMilliseconds}ms }}");

                    // 有効データファイル取得
                    List<String> datFileList = GetValidDataFile(JobKeyName);
                    if (datFileList == null || datFileList.Count == 0)
                    {
                        // クリーンアップ
                        Cleanup(JobKeyName);
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, $"AllReceivedUpdateData:有効データファイル取得==false");
                        return false;
                    }

                    // データ整合性チェック
                    bool check = DataIntegrityCheck(datFileList, JobKeyName);
                    if (!check)
                    {
                        // クリーンアップ

                        Cleanup(JobKeyName);
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, $"AllReceivedUpdateData:データ整合性チェック==false");
                        return false;
                    }

                    // 更新処理
                    UpdateData(datFileList, JobKeyName);

                    // ファイル削除
                    DataFileDelete(JobKeyName);

                    // クリーンアップ
                    Cleanup(JobKeyName);
                    return FNSiViewSyncSetting.JobStatusList[JobKeyName].Bret;
                }
                else
                {
                    return true;
                }
            }
            catch(Exception e)
            {
                Cleanup(JobKeyName);
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, e.StackTrace);
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "AllReceivedUpdateData(),登録処理でエラーが発生しました。: " + e.Message) ;
                return false;
            }           
        }

        /// <summary>
        /// 有効データファイル取得
        /// </summary>
        private List<String> GetValidDataFile(string JobKeyName)
        {
            List<String> datFileList = new List<String>();
            foreach (string path in FNSiViewSyncSetting.JobStatusList[JobKeyName].FilePathList)
            {
                List<string> filesPaths = GetDatFiles(path);
                datFileList.AddRange(filesPaths);
            }
            if (datFileList.Count == 0)
            {
                // ログ記録
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "GetValidDataFile(),有効データファイル(.csv)を取得しません。");
                return null;
            }
            return datFileList;
        }

        /// <summary>
        /// データ整合性チェック
        /// </summary>
        private bool DataIntegrityCheck(List<String> datFileList, string JobKeyName)
        {
            string keyName = FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.KeyName;
            string currentKeyName;
            foreach (String strfile in datFileList)
            {
                currentKeyName = GetKeyNameByStrfile(strfile, JobKeyName);
                if (keyName != currentKeyName)
                {
                    return false;
                }

                string fileName = Path.GetFileName(strfile);
                FNSiViewSyncSetting.JobStatusList[JobKeyName].StrFileNameList.Add(fileName);

                // モードがNULLか？
                if (String.IsNullOrEmpty(FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.Mode))
                {
                    // 失敗ログ追加
                    FNSiViewSyncSetting.JobStatusList[JobKeyName].NgMessageList.Add(String.Format("ファイル[{0}]更新失敗：キー名[{1}]によってXMLからモードを取得していません。", fileName, FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.KeyName));
                    return false;
                }

            }
            return true;
        }

        private void UpdateData(List<String> datFileList, string JobKeyName)
        {
            // コネクション
            ODBCHelper connection = new ODBCHelper(FNSiViewSyncSetting.ConnectionString);

            // SQl文を取得
            var (insertSql, deleteSql) = TryGetSql(JobKeyName);

            string keyName = "";
            string currentKeyName;
            // 外部表フォルダを取得
            String externalDirPath = GetExternalDirPath();

            try
            {
                // トランザクションを開始
                connection.BeginTransaction();
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, String.Format("現在の状態は, jobKeyName:{0}, insertOrUpdate:{1}", FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.JobKeyName, FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.Mode));

                DateTime dtDeleteStart = DateTime.Now;

                // 削除処理
                if (FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.Mode == Mode.FULL_ITEM.ToString())
                {
                    connection.Delete(deleteSql);
                }
                else
                {
                    if (FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.IsInit)
                    {
                        // 初回でない場合は削除処理
                        DateTime now = DateTime.Now;
                        // 過去方向削除
                        string currentDeleteSql = deleteSql;
                        currentDeleteSql = currentDeleteSql.Replace("@fromDate", "18000101");//本当の最小値
                        DateTime currentDate = now;
                        currentDeleteSql = currentDeleteSql.Replace("@toDate", currentDate.AddDays(-FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.KeepOldLimit -1).ToString("yyyyMMdd"));
                        connection.Delete(currentDeleteSql);

                        // 未来方向削除
                        currentDeleteSql = deleteSql;
                        currentDate = now;
                        currentDeleteSql = currentDeleteSql.Replace("@fromDate", currentDate.AddDays(FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.KeepNewLimit + 1).ToString("yyyyMMdd"));
                        currentDeleteSql = currentDeleteSql.Replace("@toDate", "22000101");//本当の最大値
                        connection.Delete(currentDeleteSql);

                        // 範囲削除
                        currentDeleteSql = deleteSql;
                        currentDate = now;
                        currentDeleteSql = currentDeleteSql.Replace("@fromDate", currentDate.AddDays(-FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.PastRangeTotal).ToString("yyyyMMdd"));
                        currentDate = now;
                        currentDeleteSql = currentDeleteSql.Replace("@toDate", currentDate.AddDays(FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.FutureRangeTotal).ToString("yyyyMMdd"));
                        connection.Delete(currentDeleteSql);
                    }
                }

                // 登録処理
                int allRecordCnt = 0;
                int okRecordCnt = 0;
                int ngRecordCnt = 0;

                allRecordCnt++;

                DateTime dtInsertStart = DateTime.Now;


                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, "マージ処理開始" + DateTime.Now.ToString("HH:mm:ss.fff"));

                // 初回ファイルのみヘッダーを書き込む、外部表をクリアする
                bool isFirstFile = true;
                
                foreach (String strfile in datFileList)
                {
                    currentKeyName = GetKeyNameByStrfile(strfile, JobKeyName);
                    if (keyName == "")
                    {
                        keyName = currentKeyName;
                    }
                
                    if (isFirstFile)
                    {
                        // 外部表をクリア
                        ClearExTable(keyName, externalDirPath);
                    }

                    // 受信ファイルを外部表フォルダへコピー
                    mergeCSV(strfile, keyName, externalDirPath, isFirstFile);
                    // 以降はヘッダーを書かないと設定
                    isFirstFile = false;
                }

                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, "マージ処理終了" + DateTime.Now.ToString("HH:mm:ss.fff"));
                connection.Insert(insertSql.ToString());

                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "登録部　keyName:" + keyName + " Insert 実行時間:" + (DateTime.Now - dtInsertStart));
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "登録部　keyName:" + keyName + " Delete 実行時間:" + (dtInsertStart - dtDeleteStart));
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "登録部　keyName:" + keyName + " 登録部 実行時間:" + (DateTime.Now - dtDeleteStart));

                // 外部表をクリア
                ClearExTable(keyName, externalDirPath);

                connection.Commit();

                // 全部データを更新しません
                if (ngRecordCnt == allRecordCnt)
                {
                    // 失敗ログ追加
                    String errorMessage = String.Format("ファイル[{0}]更新失敗：：キー名[{1}]によって全部データを更新していません。", FNSiViewSyncSetting.JobStatusList[JobKeyName].StrFileNameList[0], FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.KeyName);
                    FNSiViewSyncSetting.JobStatusList[JobKeyName].NgMessageList.Add(errorMessage);
                    FNSiViewSyncSetting.JobStatusList[JobKeyName].NgFileCount++;
                }

                // 成功ログ追加
                FNSiViewSyncSetting.JobStatusList[JobKeyName].OkMessageList.Add(String.Format("ファイル[{0}]更新成功：キー名[{1}] モード:{2}", FNSiViewSyncSetting.JobStatusList[JobKeyName].StrFileNameList[0], FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.KeyName, FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.Mode));
                FNSiViewSyncSetting.JobStatusList[JobKeyName].OkFileCount++;
            }
            catch (Exception ex)
            {
                // ログ記録
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, ex.StackTrace);
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("UpdateData(),{0}", ex.ToString()));

                connection.Rollback();

                // 外部表をクリア
                ClearExTable(keyName, externalDirPath);
                FNSiViewSyncSetting.JobStatusList[JobKeyName].Bret = false;
            }


            // ログ記録
            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("DBデータ更新: {0}ファイル更新成功, {1}ファイル更新失敗.", FNSiViewSyncSetting.JobStatusList[JobKeyName].OkFileCount, FNSiViewSyncSetting.JobStatusList[JobKeyName].NgFileCount));

            // 成功ログ記録
            if (FNSiViewSyncSetting.JobStatusList[JobKeyName].OkMessageList.Count > 0)
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "以下のファイルの更新に成功しました。");
                foreach (String msg in FNSiViewSyncSetting.JobStatusList[JobKeyName].OkMessageList)
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, msg);
                }
            }
            else
            {
                FNSiViewSyncSetting.JobStatusList[JobKeyName].Bret = false;
            }

            // 失敗ログ記録
            if (FNSiViewSyncSetting.JobStatusList[JobKeyName].NgMessageList.Count > 0)
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "以下のファイルの更新に失敗しました。");
                foreach (String msg in FNSiViewSyncSetting.JobStatusList[JobKeyName].NgMessageList)
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, msg);
                }
            }

           //  bool delFlg = this.DeleteByDialysisNo();
            // if (!delFlg) Bret = delFlg;
        }


        /// <summary>
        /// 削除機能:下記テーブルは透析Noによる削除処理
        /// ①透析実績データ
        /// ②透析条件実績データ
        /// ③医療材料実績データ
        /// ④投与薬剤実績データ
        /// ⑤指示簿指示実績データ
        /// ⑥透析実績レセプトメモデータ
        /// </summary>
        /// <param name="strfile">ファイルパス</param>
        /// <param name="delTableNameList">削除テーブルリスト</param>
        /// <returns>戻るフラグ</returns>
        //private bool DeleteByDialysisNo()
        //{
        //    // 戻るフラグ
        //    Boolean bret = true;

        //    // 透析No削除についてファイルは見つかりません
        //    if (string.IsNullOrEmpty(StrDelFileName))
        //    {
        //        // 文件ログ追加
        //        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("==========削除処理⇒透析No削除についてファイルは見つかりません。{0}==========",
        //                                                                                    Thread.CurrentThread.ManagedThreadId));
        //        return bret;
        //    }

        //    // 削除のファイル名(+拡張子)のみ取得
        //    string strfilename = System.IO.Path.GetFileName(StrDelFileName);

        //    // 削除のテーブル名
        //    string tableName = string.Empty;

        //    // 削除SQL
        //    string deleteSql = "DELETE {0} WHERE DIALYSIS_NO IN ({1})";

        //    // 削除SQLのパラメータ透析No
        //    string dialysisnoValue = string.Empty;
        //    string dialysisno = string.Empty;

        //    // in削除最大件数
        //    int batchSize = 1000;

        //    // ファイルから、削除透析Noを取得する
        //    string[] dialysisnos = new string[] { };

        //    try
        //    {
        //        // ファイルを読みます
        //        string fileData = File.ReadAllText(StrDelFileName);
        //        fileData = fileData.Replace("\r\n", " ").Replace("\r", " ").Replace("\n", " ");
        //        fileData = "{\"results\":" + fileData + "}";

        //        // JOSN->Dictionary
        //        Dictionary<String, object> dictData = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<String, object>>(fileData);
        //        var results = dictData["results"] as Newtonsoft.Json.Linq.JArray;
        //        for (int i = 0; i < results.Count; i++)
        //        {
        //            var lineData = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<String, String>>(results[i].ToString());
        //            foreach (var info in lineData)
        //            {
        //                dialysisnoValue = info.Value;
        //            }
        //        }

        //        // ファイルに削除可能な透析Noはありません
        //        if (string.IsNullOrEmpty(dialysisnoValue) || results.Count == 0)
        //        {
        //            // 文件ログ追加
        //            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("==========削除処理⇒ファイルに削除可能な透析Noはありません。{0}==========",
        //                                                                                        Thread.CurrentThread.ManagedThreadId));

        //            // 同期結果ファイルの実行結果項目を設定する
        //            CommonUtil.SetViewSyncOKInfo(tableName, Status.OK, "データが無し.", 0, 0, ref ViewSyncList);

        //            return true;
        //        }

        //        // DB接続
        //        ODBCHelper conn = new ODBCHelper(FNSiViewSyncSetting.ConnectionString);

        //        // DB処理: トランザクションを開始
        //        conn.BeginTransaction();

        //        // SQLのパラメータ透析Noを取得
        //        dialysisnos = dialysisnoValue.Split(',');

        //        // 下記テーブルのリスト「DeldetTableNameListに①~⑥」は透析Noによる削除する
        //        // ①透析実績データ、②透析条件実績データ、③医療材料実績データ、
        //        // ④投与薬剤実績データ、⑤指示簿指示実績データ、⑥透析実績レセプトメモデータ
        //        if (DeldetTableNameList.Contains(ViewTableInfo.TableName))
        //        {
        //            // 開始ログ追加
        //            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("==========削除処理⇒開始{0}==========", Thread.CurrentThread.ManagedThreadId));

        //            // 削除処理件数
        //            int count = 0;

        //            // 1回につき最大1000件を削除
        //            for (int i = 0; i < dialysisnos.Length; i += batchSize)
        //            {
        //                // 削除する透析Noをフォーマット
        //                string[] batch = dialysisnos.Skip(i).Take(batchSize).ToArray();
        //                dialysisno = string.Join(",", batch.Select(value => $"'{value}'"));

        //                // 削除SQL
        //                string delSql = String.Format(deleteSql, ViewTableInfo.TableName, dialysisno.Replace(" ", ""));

        //                // 削除処理
        //                count += conn.DeleteByDialysisNo(delSql, batch.Length);
        //            }

        //            // ログ追加
        //            String okMessage = String.Format("※削除処理成功。テーブル名:[{0}]。SQL:{1}。透析No共{2}個、実際削除{3}件==========",
        //                                              ViewTableInfo.TableName,
        //                                              String.Format(deleteSql, ViewTableInfo.TableName, "[透析Noリスト]"),
        //                                              dialysisnos.Length,
        //                                              count);
        //            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, okMessage);

        //            // 終了ログ追加
        //            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("==========削除処理⇒終了{0}==========", Thread.CurrentThread.ManagedThreadId));
        //        }


        //        // ログ追加
        //        if (!string.IsNullOrEmpty(dialysisno))
        //        {
        //            // SQLのパラメータ透析No
        //            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("※ファイル名:{0} パラメータ[透析Noリスト]:{1}==========",
        //                                                                                        strfilename,
        //                                                                                        dialysisnoValue));
        //        }

        //        // DB処理: トランザクションコミット
        //        conn.Commit();

        //    }
        //    catch (Exception ex)
        //    {
        //        // 失敗ログ追加
        //        String errorMessage = String.Format("==========削除処理⇒ファイルに透析Noを削除失敗：ファイル名:[{0}]。テーブル名[{1}]によってデータを取得していません。____{2}",
        //                                            strfilename,
        //                                            tableName,
        //                                            ex.ToString());
        //        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, errorMessage);
        //    }

        //    return bret;
        //}

        /// <summary>
        /// SQL文取得
        /// </summary>
        public (string insertSql, string deleteSql) TryGetSql(string JobKeyName)
        {
            string insertSql;
            string deleteSql;

            try
            {
                insertSql = CommonUtil.GetSql(FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.KeyName, "insert");
                deleteSql = CommonUtil.GetSql(FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.KeyName, "delete");
            }
            catch (Exception ex)
            {
                string errorMessage = $"ファイル[{FNSiViewSyncSetting.JobStatusList[JobKeyName].StrFileNameList[0]}]更新失敗：キー名[{FNSiViewSyncSetting.JobStatusList[JobKeyName].ViewTableInfo.KeyName}]によってSQLを取得していません。";
                FNSiViewSyncSetting.JobStatusList[JobKeyName].NgMessageList.Add(errorMessage);
                FNSiViewSyncSetting.JobStatusList[JobKeyName].NgMessageList.Add(ex.Message);
                FNSiViewSyncSetting.JobStatusList[JobKeyName].NgFileCount++;

                throw new Exception(errorMessage);
            }

            return (insertSql, deleteSql);
        }

        /// <summary>
        /// 有効データファイルを取得する
        /// </summary>
        /// <param name="filePath">ファイルパス</param>
        /// <returns>有効データファイル</returns>
        private List<String> GetDatFiles(String filePath)
        {
            List<String> datFileList = new List<String>();

            // データファイル名のフォーマット(例えば：V_PAT_INFO_20210127.csv)
            const String strSearchPattern = ".*\\d{4}\\d{2}\\d{2}.*.(CSV|csv)$";

            try
            {
                String strfilename = "";

                // 正規表現によるファイル名マッチングパターン登録
                Regex reg = new Regex(strSearchPattern, RegexOptions.IgnoreCase);

                // データファイル格納先に格納されているファイルを全て取得する
                String[] datafiles = System.IO.Directory.GetFiles(filePath, "*.*", System.IO.SearchOption.TopDirectoryOnly);
                foreach (String strfile in datafiles)
                {
                    try
                    {
                        // ファイル名(+拡張子)のみ取得
                        strfilename = System.IO.Path.GetFileName(strfile);

                        // ファイル名チェック
                        if (reg.Match(strfilename).Success == true)
                        {
                            // 有効なファイル名の場合
                            datFileList.Add(strfile);
                        }
                    }
                    catch (Exception ex)
                    {
                        // ログ記録
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, ex.StackTrace);
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("GetDatFiles(),SearchPattern:{0},File:{1},{2}", strSearchPattern, strfile, ex.ToString()));
                    }
                }
            }
            catch (Exception ex)
            {
                // ログ記録
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, ex.StackTrace);
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("GetDatFiles(),SearchPattern:{0},{1}", strSearchPattern, ex.ToString()));
            }

            return datFileList;
        }

        /// <summary>
        /// キー名をファイルから取得
        /// </summary>
        private string GetKeyNameByStrfile(String strfile, string JobKeyName)
        {
            // ファイル名(+拡張子)のみ取得
            string strfilename = System.IO.Path.GetFileName(strfile);

            // ファイル名からキー名を取得する
            string keyName = "";
            int lastIndex = strfilename.LastIndexOf(UNDER_LINE);
            if (lastIndex > 0)
            {
                keyName = strfilename.Substring(0, lastIndex);
            }

            // キー名がNULLか？
            if (String.IsNullOrEmpty(keyName))
            {
                // 失敗ログ追加
                FNSiViewSyncSetting.JobStatusList[JobKeyName].NgMessageList.Add(String.Format("ファイル[{0}]更新失敗：ファイル名からキー名を取得していません。", strfilename));

                FNSiViewSyncSetting.JobStatusList[JobKeyName].NgFileCount++;
                return "";
            }
            return keyName;
        }

        /// <summary>
        /// 解凍ファイルを削除する
        /// </summary>
        private void DataFileDelete(string JobKeyName)
        {
            try
            {
                foreach (string path in FNSiViewSyncSetting.JobStatusList[JobKeyName].FilePathList)
                {
                    DirectoryInfo directoryInfo = new DirectoryInfo(path);
                    directoryInfo.Delete(true);
                }
            }
            catch (Exception ex)
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "ファイル削除失敗" + ex.StackTrace);
            }
        }

        private string GetCsvFilePath(String keyName, String directoriePath)
        {
            string csvFilePath = directoriePath + "\\" + keyName + "_TEMP.csv";
            return csvFilePath;
        }

        /// <summary>
        /// CSVファイルをマージする
        /// </summary>
        public void mergeCSV(String sourceFile, String keyName, String directoriePath, bool isFirstFile)
        {
            try
            {
                // ファイルのフルパスを構築
                string csvFilePath = GetCsvFilePath(keyName, directoriePath);

                // ファイルを追記する
                using (StreamReader reader = new StreamReader(sourceFile, Encoding.GetEncoding("shift_jis")))
                {

                    using (StreamWriter writer = new StreamWriter(csvFilePath, true, Encoding.GetEncoding("shift_jis")))
                    {
                        // 最初の1行をスキップするためのフラグ
                        bool isFirstLine = true; 
                        string line;
                        if (isFirstFile) {
                            writer.WriteLine(">゛j^q-(");
                        }

                        // datファイルを読み込み、外部表の末尾に追記する
                        while ((line = reader.ReadLine()) != null)
                        {
                            // 最初の1行かつヘッダーを書き込まない場合
                            if (isFirstLine)
                            {
                                // 以降は2行目として設定
                                isFirstLine = false;
                                continue;
                            }
                            writer.WriteLine(line);
                        }
                    }
                }
            }
            catch (IOException e)
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, e.StackTrace);
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, keyName + "の外部表マージ処理でエラーが発生しました。: " + e.Message);
                throw e;
            }
        }

        public String GetExternalDirPath()
        {

            String selectSql = GetSql("EXTERNAL_TABLES", "select");
            ODBCHelper conn = new ODBCHelper(FNSiViewSyncSetting.ConnectionString);
            DataTable data = conn.Select(selectSql);
            DataRow row = data.Rows[0];

            string directoriePath = "";

            foreach (var item in row.ItemArray)
            {
                directoriePath = item.ToString();
            }

            return directoriePath;
        }

        /// <summary>
        /// 外部表をクリアする
        /// </summary>
        public void ClearExTable(String keyName, String directoriePath) {

            if (string.IsNullOrEmpty(keyName) || string.IsNullOrEmpty(directoriePath))
            {
                return;
            }

            string filePath = GetCsvFilePath(keyName, directoriePath);
            try
            {
                if (File.Exists(filePath))
                {
                    File.WriteAllText(filePath, string.Empty);
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, keyName + "の外部表をクリアしました。");
                }
            }
            catch (Exception e)
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, e.StackTrace);
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, keyName + "の外部表クリア処理でエラーが発生しました。: " + e.Message);
            }

        }

        /// <summary>
        /// SQL文を取得する
        /// </summary>
        /// <param name="keyName">キー名</param>
        /// <param name="types">種類</param>
        private String GetSql(String keyName, String type)
        {
            String sql = "";

            String sqlFileName = String.Format("{0}\\sql\\{1}_{2}.sql", AppDomain.CurrentDomain.BaseDirectory, keyName, type);

            string tmpSql = File.ReadAllText(sqlFileName);
            sql = tmpSql.Replace("\r\n", " ").Replace("\r", " ").Replace("\n", " ");

            return sql;
        }
    }
}
