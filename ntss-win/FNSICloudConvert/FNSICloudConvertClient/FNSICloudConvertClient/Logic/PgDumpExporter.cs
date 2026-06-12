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
    /// PostgreSQL データをテーブル単位で導出する（データのみ・スキーマ不含）
    ///
    /// 対象テーブル・DB・フィルター条件は pg_dump_config.yaml から取得する。
    /// ダンプ方向 off2on（または both）のテーブルのみが対象となる。
    ///
    /// フィルタなし (whereTemplate=null) →
    ///     psql \COPY {table} TO file (FORMAT binary)
    /// フィルタあり (whereTemplate!=null) →
    ///     psql \COPY (SELECT * WHERE {whereTemplate}) TO file (FORMAT binary)
    ///
    /// 出力先: {OnpreTempFolder}\pg_export\{dbName}\
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    internal class PgDumpExporter
    {
        // --------------------------------------------------
        // 定数
        // --------------------------------------------------
        private static string PSQL_EXE        => AppConfigLoader.PsqlExe;
        private const  string PG_SCHEMA       = "ntss";
        private const  int    PG_DEFAULT_PORT = 5432;
        private const  int    MAX_PARALLEL    = 4;

        // DB名 → (ユーザー名, パスワード) — AppConfigLoader から動的に構築
        private Dictionary<string, (string User, string Password)> PG_DATABASES =>
            new Dictionary<string, (string, string)>
            {
                { AppConfigLoader.PgDb4Name, (AppConfigLoader.PgDb4User, AppConfigLoader.PgDb4Password) },
                { AppConfigLoader.PgDb5Name, (AppConfigLoader.PgDb5User, AppConfigLoader.PgDb5Password) },
                { AppConfigLoader.PgDb6Name, (AppConfigLoader.PgDb6User, AppConfigLoader.PgDb6Password) },
            };

        private readonly AppSettings _settings;
        private readonly AppLogger   _log;

        public PgDumpExporter(AppSettings settings)
        {
            _settings = settings;
            _log      = AppLogger.GetInstance();
        }

        private string BuildConnUri(string dbName)
        {
            var (user, pass) = PG_DATABASES[dbName];
            var (host, port) = AppSettings.ParseHostPort(_settings.OnpreRdbIpAddress, PG_DEFAULT_PORT);
            return string.Format("postgresql://{0}:{1}@{2}:{3}/{4}",
                user, pass, host, port, dbName);
        }

        private string GetPassword(string dbName) => PG_DATABASES[dbName].Password;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 導出前に yaml 設定からテーブル数を取得して件数ラベルを初期化する
        /// （DB への問い合わせは行わない）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task ReportTableCountsAsync(
            IProgress<ProgressInfo> progress,
            CancellationToken       ct)
        {
            await Task.Run(() =>
            {
                var targets = LoadExportTargets();

                foreach (var group in targets.GroupBy(t => t.Db))
                {
                    ct.ThrowIfCancellationRequested();
                    string key = DbNameToKey(group.Key);
                    progress.Report(new ProgressInfo
                    {
                        DbKind        = DbKind.PostgreSql,
                        IsCountUpdate = true,
                        CountKey      = key,
                        CountTotal    = group.Count(),
                        CountDone     = 0
                    });
                }
            }, ct);
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 全 DB・全テーブルをエクスポートする
        /// yaml の dump=true かつ direction が off2on または both のテーブルのみ対象
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
                    DbKind  = DbKind.PostgreSql,
                    IsError = true,
                    Message = string.Format(
                        "[PostgreSQL] ダンプ対象テーブルが0件です。pg_dump_config.yaml を確認してください: {0}",
                        AppConfigLoader.PgDumpConfigPath)
                });
                return;
            }

            int totalTables = targets.Count;
            int completed   = 0;

            progress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 0,
                Message    = string.Format("[PostgreSQL] ダンプ対象: {0} テーブル", totalTables)
            });

            // 前回の残留ファイルが混入しないよう毎回クリアする
            string pgExportRoot = Path.Combine(_settings.OnpreTempFolder, "pg_export");
            if (Directory.Exists(pgExportRoot))
                Directory.Delete(pgExportRoot, recursive: true);

            // DB ごとにグループ化して処理
            var byDb = targets
                .GroupBy(t => t.Db)
                .ToDictionary(g => g.Key, g => g.ToList());

            foreach (var kv in byDb)
            {
                ct.ThrowIfCancellationRequested();

                string dbName      = kv.Key;
                var    tableConfs  = kv.Value;

                if (!PG_DATABASES.ContainsKey(dbName))
                {
                    progress.Report(new ProgressInfo
                    {
                        DbKind  = DbKind.PostgreSql,
                        IsError = true,
                        Message = string.Format("[PostgreSQL] 未定義の DB: {0} — スキップ", dbName)
                    });
                    continue;
                }

                string outDir    = Path.Combine(_settings.OnpreTempFolder, "pg_export", dbName);
                Directory.CreateDirectory(outDir);

                string countKey  = DbNameToKey(dbName);
                string countKey2 = countKey;

                // 件数確定通知
                progress.Report(new ProgressInfo
                {
                    DbKind        = DbKind.PostgreSql,
                    IsCountUpdate = true,
                    CountKey      = countKey,
                    CountTotal    = tableConfs.Count,
                    CountDone     = 0
                });
                progress.Report(new ProgressInfo
                {
                    DbKind  = DbKind.PostgreSql,
                    Message = string.Format("[PostgreSQL] 導出開始: {0}", dbName)
                });

                var dbCounter    = new int[1];
                int dbTableCount = tableConfs.Count;

                var sem   = new SemaphoreSlim(MAX_PARALLEL, MAX_PARALLEL);
                var tasks = new List<Task>();

                foreach (var cfg in tableConfs)
                {
                    ct.ThrowIfCancellationRequested();

                    string db      = dbName;
                    var    tblCfg  = cfg;
                    string outDir2 = outDir;

                    await sem.WaitAsync(ct);

                    tasks.Add(Task.Run(() =>
                    {
                        try
                        {
                            ct.ThrowIfCancellationRequested();

                            progress.Report(new ProgressInfo
                            {
                                DbKind  = DbKind.PostgreSql,
                                Message = string.Format("[{0}] 導出開始: {1}", db, tblCfg.Name)
                            });

                            string dataFile = Path.Combine(outDir2, tblCfg.Name + ".data");

                            if (!string.IsNullOrWhiteSpace(tblCfg.WhereTemplate))
                                RunPsqlCopy(db, tblCfg.Name, tblCfg.WhereTemplate, facilityCds, dataFile, ct);
                            else
                                RunPsqlCopyAll(db, tblCfg.Name, dataFile, ct);

                            int dbDone = Interlocked.Increment(ref dbCounter[0]);
                            progress.Report(new ProgressInfo
                            {
                                DbKind        = DbKind.PostgreSql,
                                IsCountUpdate = true,
                                CountKey      = countKey2,
                                CountTotal    = dbTableCount,
                                CountDone     = dbDone
                            });
                            int pct = (int)((double)Interlocked.Increment(ref completed) / totalTables * 100);
                            progress.Report(new ProgressInfo
                            {
                                DbKind     = DbKind.PostgreSql,
                                Percentage = pct,
                                Message    = string.Format("[{0}] 導出完了: {1} ({2}/{3})",
                                    db, tblCfg.Name, completed, totalTables)
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
                                string.Format("導出エラー [{0}.{1}]: {2}", db, tblCfg.Name, ex.Message));
                            progress.Report(new ProgressInfo
                            {
                                DbKind  = DbKind.PostgreSql,
                                IsError = true,
                                Message = string.Format("[{0}] 導出エラー: {1} — {2}",
                                    db, tblCfg.Name, ex.Message)
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
                    DbKind  = DbKind.PostgreSql,
                    Message = string.Format("[PostgreSQL] 導出完了: {0}", dbName)
                });
            }
        }

        // --------------------------------------------------
        // Private ヘルパー
        // --------------------------------------------------

        /// <summary>
        /// yaml を読み込み、off2on エクスポート対象テーブル（dump=true かつ direction が off2on / both）を返す
        /// </summary>
        private List<PgTableConfig> LoadExportTargets()
        {
            var all = PgDumpConfigLoader.Load(AppConfigLoader.PgDumpConfigPath);
            return all
                .Where(t => t.Dump && IsDirectionMatch(t.Direction, "off2on"))
                .ToList();
        }

        /// <summary>
        /// direction が指定した operationMode に合致するか判定する
        /// direction="both" は常に true
        /// </summary>
        private static bool IsDirectionMatch(string direction, string operationMode)
        {
            if (string.IsNullOrEmpty(direction)) return true;
            string d = direction.ToLowerInvariant();
            return d == "both" || d == operationMode;
        }

        /// <summary>DB 名から進捗カウンター用キーへ変換する</summary>
        private string DbNameToKey(string dbName)
        {
            if (dbName == AppConfigLoader.PgDb4Name) return "db4";
            if (dbName == AppConfigLoader.PgDb6Name) return "db6";
            return "db5";
        }

        //----------------------------------------------------------------------------------------------------
        // psql \COPY {table} TO file (FORMAT binary) — 全データ出力（whereTemplate=null のテーブル用）
        //----------------------------------------------------------------------------------------------------
        private void RunPsqlCopyAll(
            string            dbName,
            string            table,
            string            outFile,
            CancellationToken ct)
        {
            string psqlFilePath = outFile.Replace('\\', '/');
            string copyCmd = string.Format(
                @"\COPY {0}.{1} TO '{2}' (FORMAT binary)",
                PG_SCHEMA, table, psqlFilePath);

            var psi = new ProcessStartInfo
            {
                FileName               = PSQL_EXE,
                Arguments              = string.Format("-d \"{0}\" --no-psqlrc --quiet",
                    BuildConnUri(dbName)),
                UseShellExecute        = false,
                RedirectStandardInput  = true,
                RedirectStandardOutput = true,
                RedirectStandardError  = true,
                CreateNoWindow         = true
            };
            psi.EnvironmentVariables["PGPASSWORD"] = GetPassword(dbName);

            if (!File.Exists(PSQL_EXE))
                throw new FileNotFoundException(
                    string.Format(
                        "実行ファイルが見つかりません。PostgreSQL Client Tools (psql) がインストールされているか確認してください。\nパス: {0}",
                        PSQL_EXE), PSQL_EXE);

            using (var proc = new Process { StartInfo = psi })
            {
                if (!proc.Start())
                    throw new InvalidOperationException(
                        string.Format("psql を起動できませんでした: {0}", PSQL_EXE));

                proc.StandardInput.WriteLine(copyCmd);
                proc.StandardInput.Close();

                var stderrTask = Task.Run(() => proc.StandardError.ReadToEnd());
                var stdoutTask = Task.Run(() => proc.StandardOutput.ReadToEnd());

                using (ct.Register(() => { try { if (!proc.HasExited) proc.Kill(); } catch { } }))
                {
                    proc.WaitForExit();
                    ct.ThrowIfCancellationRequested();

                    Task.WaitAll(stderrTask, stdoutTask);
                    string stderr = stderrTask.Result;
                    if (proc.ExitCode != 0)
                        throw new InvalidOperationException(
                            string.Format("psql COPY 終了コード {0}: {1}",
                                proc.ExitCode, stderr.Trim()));
                }
            }
        }

        //----------------------------------------------------------------------------------------------------
        // psql \COPY ... (FORMAT binary) — whereTemplate によるフィルタ付きデータ出力
        //----------------------------------------------------------------------------------------------------
        private void RunPsqlCopy(
            string            dbName,
            string            table,
            string            whereTemplate,
            List<string>      facilityCds,
            string            outFile,
            CancellationToken ct)
        {
            string whereClause = BuildWhereClause(whereTemplate, facilityCds);

            string psqlFilePath = outFile.Replace('\\', '/');
            string copyCmd = string.Format(
                @"\COPY (SELECT * FROM {0}.{1} WHERE {2}) TO '{3}' (FORMAT binary)",
                PG_SCHEMA, table, whereClause, psqlFilePath);

            var psi = new ProcessStartInfo
            {
                FileName               = PSQL_EXE,
                Arguments              = string.Format("-d \"{0}\" --no-psqlrc --quiet",
                    BuildConnUri(dbName)),
                UseShellExecute        = false,
                RedirectStandardInput  = true,
                RedirectStandardOutput = true,
                RedirectStandardError  = true,
                CreateNoWindow         = true
            };
            psi.EnvironmentVariables["PGPASSWORD"] = GetPassword(dbName);

            if (!File.Exists(PSQL_EXE))
                throw new FileNotFoundException(
                    string.Format(
                        "実行ファイルが見つかりません。PostgreSQL Client Tools (psql) がインストールされているか確認してください。\nパス: {0}",
                        PSQL_EXE), PSQL_EXE);

            using (var proc = new Process { StartInfo = psi })
            {
                if (!proc.Start())
                    throw new InvalidOperationException(
                        string.Format("psql を起動できませんでした: {0}", PSQL_EXE));

                proc.StandardInput.WriteLine(copyCmd);
                proc.StandardInput.Close();

                var stderrTask = Task.Run(() => proc.StandardError.ReadToEnd());
                var stdoutTask = Task.Run(() => proc.StandardOutput.ReadToEnd());

                using (ct.Register(() => { try { if (!proc.HasExited) proc.Kill(); } catch { } }))
                {
                    proc.WaitForExit();
                    ct.ThrowIfCancellationRequested();

                    Task.WaitAll(stderrTask, stdoutTask);
                    string stderr = stderrTask.Result;
                    if (proc.ExitCode != 0)
                        throw new InvalidOperationException(
                            string.Format("psql COPY 終了コード {0}: {1}",
                                proc.ExitCode, stderr.Trim()));
                }
            }
        }

        private static string BuildWhereClause(string whereTemplate, List<string> facilityCds)
        {
            if (string.IsNullOrWhiteSpace(whereTemplate))
                throw new ArgumentException("whereTemplate が未設定です。", nameof(whereTemplate));

            if (facilityCds == null || facilityCds.Count == 0)
                throw new InvalidOperationException("施設コードが空のため、フィルタ付きエクスポートを実行できません。");

            var inList = new StringBuilder();
            for (int i = 0; i < facilityCds.Count; i++)
            {
                if (i > 0) inList.Append(',');
                inList.AppendFormat("'{0}'", facilityCds[i].Replace("'", "''"));
            }

            return whereTemplate.Replace(":facilityList", inList.ToString());
        }
    }
}
