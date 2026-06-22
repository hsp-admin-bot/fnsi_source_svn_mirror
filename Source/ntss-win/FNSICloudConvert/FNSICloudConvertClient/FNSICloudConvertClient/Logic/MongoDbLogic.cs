using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using FNSICloudConvertClient.Models;

namespace FNSICloudConvertClient.Logic
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// MongoDB データ導出 / 導入ロジック
    ///
    /// 導出 (off2on): mongodump.exe を使用して BSON 形式で出力
    ///   対象コレクション・フィルター条件は mongo_dump_config.yaml から取得する。
    ///   filterField != null → --queryFile でフィルタリング
    ///   filterField == null → 全件導出
    ///   最大 MAX_PARALLEL 並列でコレクションを同時処理
    ///
    /// 出力先: {OnpreTempFolder}\mongo_export\ntss\{collection}.bson
    ///
    /// 導入 (on2off): mongorestore.exe を使用してサーバー生成 BSON ZIP をインポート
    ///   ZIP 構造: ntss\{collection}.bson（mongodump と同じ形式）
    ///
    /// 接続: OnpreMongoIpAddress:27017 / 認証: nkk/nkk (authSource=ntss)
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class MongoDbLogic
    {
        private static string MONGO_DUMP_EXE    => AppConfigLoader.MongoDumpExe;
        private static string MONGO_RESTORE_EXE => AppConfigLoader.MongoRestoreExe;
        private const int    DB_DEFAULT_PORT  = 27017;
        private const int    MAX_PARALLEL     = 4;

        // AppConfigLoader から取得するプロパティ
        private static string DB_NAME => AppConfigLoader.MongoDbName;
        private static string DB_USER => AppConfigLoader.MongoUser;
        private static string DB_PASS => AppConfigLoader.MongoPassword;

        private readonly AppLogger   _log;
        private readonly AppSettings _settings;

        public MongoDbLogic(AppSettings settings)
        {
            _settings = settings;
            _log      = AppLogger.GetInstance();
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 導出前に yaml 設定からコレクション数を取得して件数ラベルを初期化する
        /// （MongoDB への問い合わせは行わない）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task ReportCollectionCountAsync(
            IProgress<ProgressInfo> progress,
            CancellationToken       ct)
        {
            await Task.Run(() =>
            {
                var targets = LoadExportTargets();

                progress.Report(new ProgressInfo
                {
                    DbKind        = DbKind.MongoDb,
                    IsCountUpdate = true,
                    CountKey      = "mongo",
                    CountTotal    = targets.Count,
                    CountDone     = 0
                });
            }, ct);
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定施設コードのデータを mongodump で導出する
        ///
        /// 対象コレクション・フィルター条件は mongo_dump_config.yaml から取得する。
        /// dump=true のコレクションのみ処理。
        /// filterField != null → 施設フィルタ付きでエクスポート
        /// filterField == null → 全件エクスポート
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task ExportAsync(
            List<string>            facilityCds,
            IProgress<ProgressInfo> progress,
            CancellationToken       ct)
        {
            // yaml 設定を読み込む
            var targets = LoadExportTargets();

            if (targets.Count == 0)
            {
                progress.Report(new ProgressInfo
                {
                    DbKind  = DbKind.MongoDb,
                    IsError = true,
                    Message = string.Format(
                        "[MongoDB] ダンプ対象コレクションが0件です。mongo_dump_config.yaml を確認してください: {0}",
                        AppConfigLoader.MongoDumpConfigPath)
                });
                return;
            }

            int total     = targets.Count;
            int completed = 0;

            progress.Report(new ProgressInfo
            {
                DbKind     = DbKind.MongoDb,
                Percentage = 0,
                Message    = string.Format("[MongoDB] 導出開始: DB={0} 施設={1} 対象={2}コレクション",
                    DB_NAME, string.Join(",", facilityCds), total)
            });

            progress.Report(new ProgressInfo
            {
                DbKind        = DbKind.MongoDb,
                IsCountUpdate = true,
                CountKey      = "mongo",
                CountTotal    = total,
                CountDone     = 0
            });

            // mongodump の --out に渡すルートディレクトリ
            // → mongodump が自動で {outputRoot}\ntss\{collection}.bson を生成する
            // 前回の残留ファイルが混入しないよう毎回クリアする
            string outputRoot = Path.Combine(_settings.OnpreTempFolder, "mongo_export");
            if (Directory.Exists(outputRoot))
                Directory.Delete(outputRoot, recursive: true);
            Directory.CreateDirectory(outputRoot);

            var sem   = new SemaphoreSlim(MAX_PARALLEL, MAX_PARALLEL);
            var tasks = new List<Task>();

            foreach (var cfg in targets)
            {
                ct.ThrowIfCancellationRequested();

                var  colCfg      = cfg;
                bool hasFilter   = colCfg.FilterField != null;

                await sem.WaitAsync(ct);

                tasks.Add(Task.Run(() =>
                {
                    try
                    {
                        ct.ThrowIfCancellationRequested();

                        progress.Report(new ProgressInfo
                        {
                            DbKind  = DbKind.MongoDb,
                            Message = string.Format("[{0}] 導出開始: {1}", DB_NAME, colCfg.Name)
                        });

                        RunMongoDump(
                            colCfg.Name,
                            hasFilter ? facilityCds : null,
                            colCfg.FilterField,
                            outputRoot,
                            ct);

                        int done = Interlocked.Increment(ref completed);
                        progress.Report(new ProgressInfo
                        {
                            DbKind        = DbKind.MongoDb,
                            IsCountUpdate = true,
                            CountKey      = "mongo",
                            CountTotal    = total,
                            CountDone     = done
                        });
                        progress.Report(new ProgressInfo
                        {
                            DbKind     = DbKind.MongoDb,
                            Percentage = (int)((double)done / total * 100),
                            Message    = string.Format("[{0}] 導出完了: {1} ({2}/{3})",
                                DB_NAME, colCfg.Name, done, total)
                        });
                    }
                    catch (OperationCanceledException)
                    {
                        throw;
                    }
                    catch (Exception ex)
                    {
                        _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient",
                            AppLogger.LOGGING_CLASS.ERROR,
                            string.Format("[{0}] 導出エラー [{1}]: {2}", DB_NAME, colCfg.Name, ex.Message));
                        progress.Report(new ProgressInfo
                        {
                            DbKind  = DbKind.MongoDb,
                            IsError = true,
                            Message = string.Format("[{0}] 導出エラー: {1} — {2}",
                                DB_NAME, colCfg.Name, ex.Message)
                        });
                        throw;
                    }
                    finally
                    {
                        sem.Release();
                    }
                }, ct));
            }

            await Task.WhenAll(tasks);

            progress.Report(new ProgressInfo
            {
                DbKind     = DbKind.MongoDb,
                Percentage = 100,
                Message    = string.Format("[MongoDB] 導出完了: {0} コレクション処理", total)
            });
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// on2off 用: サーバーからダウンロードした Mongo ダンプ ZIP を mongorestore でインポートする
        ///
        /// ZIP 内の構造: ntss\{collectionName}.bson（サーバーが mongodump で出力した BSON）
        /// 各 BSON ファイルを mongorestore --drop でインポートする。
        /// </summary>
        /// <param name="mongoZipPath">mongo_dump.zip のパス</param>
        /// <param name="progress">進捗コールバック</param>
        /// <param name="ct">キャンセルトークン</param>
        //----------------------------------------------------------------------------------------------------
        public async Task ImportFromZipAsync(
            string                  mongoZipPath,
            IProgress<ProgressInfo> progress,
            CancellationToken       ct)
        {
            progress.Report(new ProgressInfo
            {
                DbKind     = DbKind.MongoDb,
                Percentage = 0,
                Message    = "[MongoDB] インポート開始..."
            });

            // ZIP 展開先
            string restoreDir = Path.Combine(
                Path.GetDirectoryName(mongoZipPath), "mongo_restore_work");
            if (Directory.Exists(restoreDir))
                Directory.Delete(restoreDir, recursive: true);
            Directory.CreateDirectory(restoreDir);

            await Task.Run(() => ZipArchiver.ExtractToDirectory(mongoZipPath, restoreDir), ct);

            // yaml からインポート対象コレクション名セットを構築
            var importTargets = new HashSet<string>(
                MongoDumpConfigLoader.Load(AppConfigLoader.MongoDumpConfigPath)
                    .Where(c => c.Dump)
                    .Select(c => c.Name),
                StringComparer.OrdinalIgnoreCase);

            progress.Report(new ProgressInfo
            {
                DbKind  = DbKind.MongoDb,
                Message = string.Format("[MongoDB] mongo_dump_config.yaml: {0} コレクションがインポート対象", importTargets.Count)
            });

            // ntss サブフォルダ内の .bson ファイルを収集し yaml 対象のみに絞る
            // ZIP 構造: ntss\{collection}.bson（mongodump 形式）
            string ntssDir = Path.Combine(restoreDir, DB_NAME);
            string[] allBsonFiles = Directory.Exists(ntssDir)
                ? Directory.GetFiles(ntssDir, "*.bson", SearchOption.TopDirectoryOnly)
                : new string[0];

            var bsonFiles = allBsonFiles
                .Where(f =>
                {
                    string col = Path.GetFileNameWithoutExtension(f);
                    if (!importTargets.Contains(col))
                    {
                        _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient",
                            AppLogger.LOGGING_CLASS.INFO,
                            string.Format("[MongoDB] {0}: yaml 対象外 — スキップ", col));
                        return false;
                    }
                    return true;
                })
                .ToArray();

            if (bsonFiles.Length == 0)
            {
                progress.Report(new ProgressInfo
                {
                    DbKind     = DbKind.MongoDb,
                    Percentage = 100,
                    Message    = "[MongoDB] ZIP 内にインポート対象 BSON ファイルがありません（スキップ）"
                });
                return;
            }

            progress.Report(new ProgressInfo
            {
                DbKind        = DbKind.MongoDb,
                IsCountUpdate = true,
                CountKey      = "mongo",
                CountTotal    = bsonFiles.Length,
                CountDone     = 0
            });

            int done = 0;
            foreach (string bsonFile in bsonFiles)
            {
                ct.ThrowIfCancellationRequested();

                string collectionName = Path.GetFileNameWithoutExtension(bsonFile);

                progress.Report(new ProgressInfo
                {
                    DbKind  = DbKind.MongoDb,
                    Message = string.Format("[MongoDB] インポート中: {0}", collectionName)
                });

                await Task.Run(() =>
                    RunMongoRestore(collectionName, bsonFile, ct), ct);

                done++;
                progress.Report(new ProgressInfo
                {
                    DbKind        = DbKind.MongoDb,
                    IsCountUpdate = true,
                    CountKey      = "mongo",
                    CountTotal    = bsonFiles.Length,
                    CountDone     = done
                });
                progress.Report(new ProgressInfo
                {
                    DbKind     = DbKind.MongoDb,
                    Percentage = (int)((double)done / bsonFiles.Length * 100),
                    Message    = string.Format("[MongoDB] インポート完了: {0} ({1}/{2})",
                        collectionName, done, bsonFiles.Length)
                });
            }

            progress.Report(new ProgressInfo
            {
                DbKind     = DbKind.MongoDb,
                Percentage = 100,
                Message    = string.Format("[MongoDB] インポート完了: {0} コレクション", done)
            });
        }

        // ------------------------------------------------------------------
        // Private ヘルパー
        // ------------------------------------------------------------------

        /// <summary>
        /// yaml を読み込み、dump=true のコレクション一覧を返す
        /// </summary>
        private List<MongoCollectionConfig> LoadExportTargets()
        {
            var all = MongoDumpConfigLoader.Load(AppConfigLoader.MongoDumpConfigPath);
            return all.Where(c => c.Dump).ToList();
        }

        private string BuildUri()
        {
            var (mongoHost, mongoPort) = AppSettings.ParseHostPort(_settings.OnpreMongoIpAddress, DB_DEFAULT_PORT);
            return string.Format("mongodb://{0}:{1}@{2}:{3}/{4}?authSource={4}",
                DB_USER, DB_PASS, mongoHost, mongoPort, DB_NAME);
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// mongodump.exe を呼び出して 1 コレクションを BSON 形式でエクスポートする
        ///
        /// 出力: {outputRoot}\ntss\{collectionName}.bson（mongodump が自動生成）
        ///       {outputRoot}\ntss\{collectionName}.metadata.json
        ///
        /// facilityCds が null の場合は全件エクスポート。
        /// それ以外は --queryFile（一時ファイル）で filterField IN (...) フィルタを適用。
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void RunMongoDump(
            string            collectionName,
            List<string>      facilityCds,   // null → 全件
            string            filterField,   // フィルター対象フィールド名（例: "facility_cd"）
            string            outputRoot,
            CancellationToken ct)
        {
            string queryFile = null;
            try
            {
                var args = new StringBuilder();
                args.AppendFormat("--uri \"{0}\" ", BuildUri());
                args.AppendFormat("--db \"{0}\" ", DB_NAME);
                args.AppendFormat("--collection \"{0}\" ", collectionName);
                args.AppendFormat("--out \"{0}\" ", outputRoot);

                if (facilityCds != null && facilityCds.Count > 0 && filterField != null)
                {
                    // クエリ JSON を一時ファイルに書いて --queryFile で渡す
                    // （Windowsコマンドラインでのダブルクォートのエスケープ問題を回避）
                    var codes = new StringBuilder();
                    for (int i = 0; i < facilityCds.Count; i++)
                    {
                        if (i > 0) codes.Append(',');
                        codes.AppendFormat("\"{0}\"",
                            facilityCds[i].Replace("\\", "\\\\").Replace("\"", "\\\""));
                    }
                    string queryJson = string.Format(
                        "{{\"{0}\":{{\"$in\":[{1}]}}}}", filterField, codes);

                    queryFile = Path.GetTempFileName();
                    // BOMなしUTF-8で書き出す（Encoding.UTF8はBOM付きのためmongodumpのJSONパーサーが失敗する）
                    File.WriteAllText(queryFile, queryJson, new UTF8Encoding(false));
                    args.AppendFormat("--queryFile \"{0}\"", queryFile);
                }

                var psi = new ProcessStartInfo
                {
                    FileName               = MONGO_DUMP_EXE,
                    Arguments              = args.ToString().TrimEnd(),
                    UseShellExecute        = false,
                    RedirectStandardOutput = false,
                    RedirectStandardError  = true,
                    CreateNoWindow         = true
                };

                if (!File.Exists(MONGO_DUMP_EXE))
                    throw new FileNotFoundException(
                        string.Format(
                            "実行ファイルが見つかりません。MongoDB Database Tools (mongodump) がインストールされているか確認してください。\nパス: {0}",
                            MONGO_DUMP_EXE), MONGO_DUMP_EXE);

                using (var proc = Process.Start(psi))
                {
                    var stderrTask = Task.Run(() => proc.StandardError.ReadToEnd());

                    using (ct.Register(() =>
                    {
                        try { if (!proc.HasExited) proc.Kill(); } catch { }
                    }))
                    {
                        // 出力 BSON ファイルのサイズを監視して「進捗なし」でハング検知する。
                        const int POLL_MS          = 10_000;
                        const int NO_PROGRESS_MS   = 5 * 60_000;
                        string    bsonFile         = Path.Combine(outputRoot, DB_NAME, collectionName + ".bson");
                        long      lastSize         = 0;
                        DateTime  lastProgressTime = DateTime.Now;

                        while (!proc.WaitForExit(POLL_MS))
                        {
                            ct.ThrowIfCancellationRequested();

                            long currentSize = File.Exists(bsonFile)
                                ? new FileInfo(bsonFile).Length
                                : 0;

                            if (currentSize != lastSize)
                            {
                                lastSize         = currentSize;
                                lastProgressTime = DateTime.Now;
                            }
                            else if ((DateTime.Now - lastProgressTime).TotalMilliseconds > NO_PROGRESS_MS)
                            {
                                try { proc.Kill(); } catch { }
                                throw new TimeoutException(
                                    string.Format("[{0}] mongodump 応答なし (5分間進捗なし): {1}",
                                        DB_NAME, collectionName));
                            }
                        }

                        ct.ThrowIfCancellationRequested();

                        string stderr = stderrTask.GetAwaiter().GetResult();
                        if (proc.ExitCode != 0)
                        {
                            throw new InvalidOperationException(
                                string.Format("mongodump 終了コード {0}: {1}",
                                    proc.ExitCode, stderr.Trim()));
                        }
                    }
                }
            }
            finally
            {
                if (queryFile != null)
                    try { File.Delete(queryFile); } catch { }
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// mongorestore.exe を呼び出して 1 コレクションを BSON ファイルからインポートする（on2off 用）
        ///
        /// --drop: インポート前に既存コレクションを削除
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void RunMongoRestore(
            string            collectionName,
            string            bsonFilePath,
            CancellationToken ct)
        {
            var args = new StringBuilder();
            args.AppendFormat("--uri \"{0}\" ", BuildUri());
            args.AppendFormat("--db \"{0}\" ", DB_NAME);
            args.AppendFormat("--collection \"{0}\" ", collectionName);
            args.Append("--drop ");
            args.AppendFormat("\"{0}\"", bsonFilePath);

            var psi = new ProcessStartInfo
            {
                FileName               = MONGO_RESTORE_EXE,
                Arguments              = args.ToString().TrimEnd(),
                UseShellExecute        = false,
                RedirectStandardOutput = false,
                RedirectStandardError  = true,
                CreateNoWindow         = true
            };

            if (!File.Exists(MONGO_RESTORE_EXE))
                throw new FileNotFoundException(
                    string.Format(
                        "実行ファイルが見つかりません。MongoDB Database Tools (mongorestore) がインストールされているか確認してください。\nパス: {0}",
                        MONGO_RESTORE_EXE), MONGO_RESTORE_EXE);

            using (var proc = Process.Start(psi))
            {
                var stderrTask = Task.Run(() => proc.StandardError.ReadToEnd());

                using (ct.Register(() =>
                {
                    try { if (!proc.HasExited) proc.Kill(); } catch { }
                }))
                {
                    proc.WaitForExit();
                    ct.ThrowIfCancellationRequested();

                    string stderr = stderrTask.GetAwaiter().GetResult();
                    if (proc.ExitCode != 0)
                        throw new InvalidOperationException(
                            string.Format("mongorestore 終了コード {0}: {1}",
                                proc.ExitCode, stderr.Trim()));
                }
            }
        }

    }
}
