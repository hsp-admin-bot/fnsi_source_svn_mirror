using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using FNSICloudConvertClient.Models;
using Newtonsoft.Json.Linq;
using Npgsql;

namespace FNSICloudConvertClient.Logic
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// PostgreSQL データ導出 / 導入ロジック
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class PostgreSqlLogic
    {
        private static string PG_RESTORE_EXE => AppConfigLoader.PgRestoreExe;
        private static string PSQL_EXE       => AppConfigLoader.PsqlExe;
        private const string PG_SCHEMA      = "ntss";
        private const int    PG_DEFAULT_PORT = 5432;
        private static readonly HashSet<string> ONTOOFF_MIGRATION_DBS = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "ntss_db5",
            "ntss_db6",
        };

        // リストア対象外のシステムテーブル（フレームワーク管理テーブルなど）
        private static readonly HashSet<string> SYSTEM_TABLES_SKIP = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "flyway_schema_history",
            "schema_version",
            "shedlock",
            "spring_session",
            "spring_session_attributes",
        };

        private readonly AppLogger  _log;
        private readonly AppSettings _settings;

        // DB名 → (ユーザー名, パスワード)
        private Dictionary<string, (string User, string Password)> PgDatabases =>
            new Dictionary<string, (string, string)>
            {
                { AppConfigLoader.PgDb4Name, (AppConfigLoader.PgDb4User, AppConfigLoader.PgDb4Password) },
                { AppConfigLoader.PgDb5Name, (AppConfigLoader.PgDb5User, AppConfigLoader.PgDb5Password) },
                { AppConfigLoader.PgDb6Name, (AppConfigLoader.PgDb6User, AppConfigLoader.PgDb6Password) },
            };

        public PostgreSqlLogic(AppSettings settings)
        {
            _settings = settings;
            _log      = AppLogger.GetInstance();
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 施設データを PostgreSQL から導出する（全施設まとめて処理）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task ExportAsync(
            List<string>            facilityCds,
            IProgress<ProgressInfo> progress,
            CancellationToken       ct)
        {
            try
            {
                progress.Report(new ProgressInfo
                {
                    DbKind     = DbKind.PostgreSql,
                    Percentage = 0,
                    Message    = string.Format("[PostgreSQL] データ導出開始: {0} 施設", facilityCds.Count)
                });

                var exporter = new PgDumpExporter(_settings);
                await exporter.ExportAsync(facilityCds, progress, ct);

                progress.Report(new ProgressInfo
                {
                    DbKind     = DbKind.PostgreSql,
                    Percentage = 100,
                    Message    = "[PostgreSQL] データ導出完了"
                });
            }
            catch (OperationCanceledException)
            {
                progress.Report(new ProgressInfo
                {
                    DbKind  = DbKind.PostgreSql,
                    Message = "[PostgreSQL] 処理をキャンセルしました",
                    IsError = true
                });
                throw;
            }
            catch (Exception ex)
            {
                _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.ERROR,
                    string.Format("PostgreSQL 導出エラー: {0}", ex.Message));
                progress.Report(new ProgressInfo
                {
                    DbKind  = DbKind.PostgreSql,
                    Message = string.Format("[PostgreSQL] 導出エラー: {0}", ex.Message),
                    IsError = true
                });
                throw;
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// on2off 用: クラウド件数に応じてローカル sequence を事前確保し、seqStartMap を構築する。
        /// seqStartMap を構築する。
        /// キー形式: "{tableName}"（サーバー側 cfg.getName() と一致）
        /// 値: オンプレ DB で予約確保したシーケンスの先頭値（サーバー件数取得失敗時は 1）
        /// sharedPkTable テーブルは親のマッピングに依存するためスキップ。
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task<Dictionary<string, long>> GetSeqStartMapAsync(
            List<string>            facilityCds,
            IProgress<ProgressInfo> progress,
            CancellationToken       ct)
        {
            var seqStartMap = new Dictionary<string, long>(StringComparer.Ordinal);

            var targets = PgDumpConfigLoader.Load(AppConfigLoader.PgDumpConfigPath)
                .Where(t => t.Dump
                         && t.HasIndependentPk
                         && IsOnToOffDirectionMatch(t.Direction)
                         && IsOnToOffMigrationDb(t.Db))
                .ToList();

            progress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 0,
                Message    = string.Format("[SeqMap] {0} テーブルのシーケンス開始値を収集中...", targets.Count)
            });

            Dictionary<string, long> cloudCounts;
            try
            {
                var apiClient = new ConverterApiClient(AppConfigLoader.ConverterBaseUri);
                cloudCounts = await apiClient.GetFacilityCountsAsync(facilityCds, ct);
            }
            catch (Exception ex)
            {
                _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient",
                    AppLogger.LOGGING_CLASS.WARNING,
                    string.Format("[SeqMap] クラウド件数取得失敗のため 1 開始にフォールバック: {0}", ex.Message));

                foreach (var cfg in targets)
                    seqStartMap[cfg.Name] = 1;

                progress.Report(new ProgressInfo
                {
                    DbKind     = DbKind.PostgreSql,
                    Percentage = 100,
                    Message    = "[SeqMap] サーバー件数取得に失敗したため、全テーブルを 1 開始で処理します"
                });

                return seqStartMap;
            }

            int done = 0;
            foreach (var grp in targets.GroupBy(t => t.Db ?? "ntss_db5"))
            {
                ct.ThrowIfCancellationRequested();

                string dbName = grp.Key;
                if (!PgDatabases.ContainsKey(dbName))
                    throw new InvalidOperationException(string.Format("[SeqMap] DB 設定が見つかりません: {0}", dbName));

                string user = PgDatabases[dbName].User;
                string pass = PgDatabases[dbName].Password;
                var (pgHost, pgPort) = AppSettings.ParseHostPort(_settings.OnpreRdbIpAddress, PG_DEFAULT_PORT);
                string connStr = string.Format(
                    "Host={0};Port={1};Database={2};Username={3};Password={4}",
                    pgHost, pgPort, dbName, user, pass);

                using (var conn = new NpgsqlConnection(connStr))
                {
                    await conn.OpenAsync(ct);

                    foreach (var cfg in grp)
                    {
                        ct.ThrowIfCancellationRequested();

                        long reserveCount = GetReserveCount(cloudCounts, cfg.Name);
                        long startSeq = await ReserveSequenceRangeAsync(conn, cfg, reserveCount, ct);
                        seqStartMap[cfg.Name] = startSeq;

                        done++;
                        progress.Report(new ProgressInfo
                        {
                            DbKind     = DbKind.PostgreSql,
                            Percentage = targets.Count == 0 ? 100 : (int)((double)done / targets.Count * 100),
                            Message    = string.Format("[SeqMap] {0}: reserveCount={1}, startSeq={2}, seq={3}",
                                cfg.Name, reserveCount, startSeq, cfg.ResolveSeqName())
                        });
                    }
                }
            }

            progress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 100,
                Message    = string.Format("[SeqMap] 完了: {0} テーブル分のシーケンスを確保", seqStartMap.Count)
            });

            return seqStartMap;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// [LAN / on2off] 手動 sequence 予約用の実行スクリプト一式を生成する。
        /// 生成物:
        ///   - seq_reserve_plan.json
        ///   - run_reserve_seq.ps1
        ///   - run_reserve_seq.cmd
        ///   - seq_start_map_result.json（スクリプト実行後に自動生成）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        internal async Task<SeqReserveScriptArtifacts> PrepareManualSeqReserveAsync(
            List<string>            facilityCds,
            IProgress<ProgressInfo> progress,
            CancellationToken       ct)
        {
            if (facilityCds == null || facilityCds.Count == 0)
                throw new ArgumentException("facilityCds が空です", "facilityCds");

            progress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 0,
                Message    = "[SeqReserve] サーバーから sequence 予約プランを取得中..."
            });

            var apiClient = new ConverterApiClient(AppConfigLoader.ConverterBaseUri);
            var plan = await apiClient.GetSeqReservePlanAsync(facilityCds, ct);
            if (plan == null || plan.TablePlans == null || plan.TablePlans.Count == 0)
                throw new InvalidOperationException("sequence 予約プランが空です");

            progress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 35,
                Message    = string.Format("[SeqReserve] 予約プラン取得完了: {0} テーブル / 件数={1}",
                    plan.TablePlans.Count, plan.TotalReserveCount)
            });

            string artifactDir = BuildSeqReserveArtifactDirectory();
            Directory.CreateDirectory(artifactDir);

            string planJsonPath = Path.Combine(artifactDir, "seq_reserve_plan.json");
            string scriptPath = Path.Combine(artifactDir, "run_reserve_seq.ps1");
            string commandPath = Path.Combine(artifactDir, "run_reserve_seq.cmd");
            string resultJsonPath = Path.Combine(artifactDir, "seq_start_map_result.json");

            WriteUtf8File(planJsonPath, BuildSeqReservePlanJson(plan));
            progress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 60,
                Message    = string.Format("[SeqReserve] プラン JSON を生成: {0}", planJsonPath)
            });

            WriteUtf8File(scriptPath, BuildSeqReservePowerShellScript());
            WriteAsciiFile(commandPath, BuildSeqReserveCommandScript());
            progress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 80,
                Message    = string.Format("[SeqReserve] 実行スクリプトを生成: {0}", commandPath)
            });

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("[SeqReserve] 生成完了: plan={0}, script={1}, cmd={2}, result={3}",
                    planJsonPath, scriptPath, commandPath, resultJsonPath));

            return new SeqReserveScriptArtifacts(
                artifactDir,
                planJsonPath,
                scriptPath,
                commandPath,
                resultJsonPath,
                plan);
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 手動 sequence 予約スクリプトが出力した JSON から seqStartMap を読み込む。
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        internal Dictionary<string, long> LoadManualSeqStartMap(
            ConverterSeqReservePlan plan,
            string                  resultJsonPath)
        {
            if (string.IsNullOrWhiteSpace(resultJsonPath))
                throw new ArgumentException("resultJsonPath が空です", "resultJsonPath");
            if (!File.Exists(resultJsonPath))
                throw new FileNotFoundException("sequence 予約結果 JSON が見つかりません", resultJsonPath);

            string json = File.ReadAllText(resultJsonPath, Encoding.UTF8);
            var root = JObject.Parse(json);
            var seqStartMapToken = root["seqStartMap"] as JObject;
            if (seqStartMapToken == null)
                throw new InvalidOperationException("sequence 予約結果 JSON に seqStartMap がありません");

            var seqStartMap = new Dictionary<string, long>(StringComparer.Ordinal);
            foreach (var prop in seqStartMapToken.Properties())
            {
                if (prop.Value == null || prop.Value.Type == JTokenType.Null)
                    continue;

                seqStartMap[prop.Name] = prop.Value.Value<long>();
            }

            if (seqStartMap.Count == 0)
                throw new InvalidOperationException("sequence 予約結果 JSON の seqStartMap が空です");

            var expectedTables = (plan != null && plan.TablePlans != null)
                ? plan.TablePlans
                    .Select(t => t.TableName)
                    .Where(t => !string.IsNullOrWhiteSpace(t))
                    .Distinct(StringComparer.Ordinal)
                    .ToList()
                : new List<string>();

            var missingTables = expectedTables
                .Where(tableName => !seqStartMap.ContainsKey(tableName))
                .ToList();
            if (missingTables.Count > 0)
            {
                throw new InvalidOperationException(
                    string.Format("sequence 予約結果 JSON に不足があります: {0}",
                        string.Join(", ", missingTables)));
            }

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("[SeqReserve] 結果 JSON 読込完了: {0} テーブル", seqStartMap.Count));

            return seqStartMap;
        }

        private static bool IsOnToOffDirectionMatch(string direction)
        {
            if (string.IsNullOrEmpty(direction)) return true;
            string d = direction.ToLowerInvariant();
            return d == "both" || d == "on2off";
        }

        private string BuildSeqReserveArtifactDirectory()
        {
            string baseDir = !string.IsNullOrWhiteSpace(_settings.OnpreTempFolder)
                ? _settings.OnpreTempFolder
                : Path.Combine(Path.GetTempPath(), "FNSICloudConvert");

            return Path.Combine(
                baseDir,
                "offline_seq_reserve",
                DateTime.Now.ToString("yyyyMMdd_HHmmss"));
        }

        private string BuildSeqReservePlanJson(ConverterSeqReservePlan plan)
        {
            var (pgHost, pgPort) = AppSettings.ParseHostPort(_settings.OnpreRdbIpAddress, PG_DEFAULT_PORT);

            var tablePlans = new JArray();
            foreach (var item in plan.TablePlans)
            {
                tablePlans.Add(new JObject
                {
                    ["tableName"] = item.TableName ?? string.Empty,
                    ["dbName"] = item.DbName ?? string.Empty,
                    ["idColumn"] = item.IdColumn ?? string.Empty,
                    ["seqName"] = item.SeqName ?? string.Empty,
                    ["reserveCount"] = item.ReserveCount
                });
            }

            var root = new JObject
            {
                ["generatedAt"] = DateTimeOffset.Now.ToString("o"),
                ["sourceCalculatedAt"] = plan.CalculatedAt ?? string.Empty,
                ["rdbHost"] = pgHost,
                ["rdbPort"] = pgPort,
                ["schemaName"] = PG_SCHEMA,
                ["facilityCodes"] = new JArray(plan.FacilityCodes ?? new List<string>()),
                ["totalReserveCount"] = plan.TotalReserveCount,
                ["tablePlans"] = tablePlans
            };

            return root.ToString();
        }

        private string BuildSeqReservePowerShellScript()
        {
            var script = new StringBuilder();

            script.AppendLine("$ErrorActionPreference = 'Stop'");
            script.AppendLine("$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path");
            script.AppendLine("$planPath = Join-Path $scriptRoot 'seq_reserve_plan.json'");
            script.AppendLine("$resultPath = Join-Path $scriptRoot 'seq_start_map_result.json'");
            script.AppendLine("$psqlExe = " + ToPowerShellSingleQuoted(PSQL_EXE));
            script.AppendLine("$dbConfigs = @{");
            foreach (var kv in PgDatabases)
            {
                script.AppendLine(string.Format(
                    "    {0} = @{{ user = {1}; password = {2} }}",
                    ToPowerShellSingleQuoted(kv.Key),
                    ToPowerShellSingleQuoted(kv.Value.User),
                    ToPowerShellSingleQuoted(kv.Value.Password)));
            }
            script.AppendLine("}");
            script.AppendLine();
            script.AppendLine("function Quote-Identifier([string]$value) {");
            script.AppendLine("    return '\"' + $value.Replace('\"', '\"\"') + '\"'");
            script.AppendLine("}");
            script.AppendLine();
            script.AppendLine("function Escape-SqlLiteral([string]$value) {");
            script.AppendLine("    return $value.Replace(\"'\", \"''\")");
            script.AppendLine("}");
            script.AppendLine();
            script.AppendLine("function Invoke-PsqlText([string]$dbName, [string]$userName, [string]$password, [string]$sql, [string]$separator = '|') {");
            script.AppendLine("    $env:PGPASSWORD = $password");
            script.AppendLine("    try {");
            script.AppendLine("        $output = & $psqlExe '-h' $dbHost '-p' $dbPort.ToString() '-U' $userName '-d' $dbName '--no-psqlrc' '--quiet' '-v' 'ON_ERROR_STOP=1' '-At' '-F' $separator '-c' $sql 2>&1");
            script.AppendLine("        $exitCode = $LASTEXITCODE");
            script.AppendLine("        if ($output -is [System.Array]) {");
            script.AppendLine("            $outputText = ($output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine");
            script.AppendLine("        } else {");
            script.AppendLine("            $outputText = [string]$output");
            script.AppendLine("        }");
            script.AppendLine("        if ($exitCode -ne 0) {");
            script.AppendLine("            throw ('psql exit code=' + $exitCode + [Environment]::NewLine + $outputText)");
            script.AppendLine("        }");
            script.AppendLine("        return $outputText.Trim()");
            script.AppendLine("    } finally {");
            script.AppendLine("        Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue");
            script.AppendLine("    }");
            script.AppendLine("}");
            script.AppendLine();
            script.AppendLine("try {");
            script.AppendLine("    if (-not (Test-Path -LiteralPath $psqlExe)) {");
            script.AppendLine("        throw ('psql.exe not found: ' + $psqlExe)");
            script.AppendLine("    }");
            script.AppendLine();
            script.AppendLine("    $plan = Get-Content -LiteralPath $planPath -Raw | ConvertFrom-Json");
            script.AppendLine("    $dbHost = [string]$plan.rdbHost");
            script.AppendLine("    $dbPort = [int]$plan.rdbPort");
            script.AppendLine("    $schemaName = [string]$plan.schemaName");
            script.AppendLine();
            script.AppendLine("    if (Test-Path -LiteralPath $resultPath) {");
            script.AppendLine("        Remove-Item -LiteralPath $resultPath -Force");
            script.AppendLine("    }");
            script.AppendLine();
            script.AppendLine("    $seqStartMap = [ordered]@{}");
            script.AppendLine("    $tableResults = New-Object System.Collections.Generic.List[object]");
            script.AppendLine();
            script.AppendLine("    foreach ($item in $plan.tablePlans) {");
            script.AppendLine("        $tableName = [string]$item.tableName");
            script.AppendLine("        $dbName = [string]$item.dbName");
            script.AppendLine("        $idColumn = [string]$item.idColumn");
            script.AppendLine("        $seqName = [string]$item.seqName");
            script.AppendLine("        $reserveCount = [int64]$item.reserveCount");
            script.AppendLine();
            script.AppendLine("        if (-not $dbConfigs.ContainsKey($dbName)) {");
            script.AppendLine("            throw ('DB credential not found: ' + $dbName)");
            script.AppendLine("        }");
            script.AppendLine();
            script.AppendLine("        $dbConfig = $dbConfigs[$dbName]");
            script.AppendLine("        $quotedTable = Quote-Identifier $tableName");
            script.AppendLine("        $quotedId = Quote-Identifier $idColumn");
            script.AppendLine("        $quotedSeq = Quote-Identifier $seqName");
            script.AppendLine();
            script.AppendLine("        $maxSql = 'SELECT COALESCE(MAX({0}), 0) FROM {1}.{2}' -f $quotedId, $schemaName, $quotedTable");
            script.AppendLine("        $maxIdText = Invoke-PsqlText -dbName $dbName -userName $dbConfig.user -password $dbConfig.password -sql $maxSql");
            script.AppendLine("        $maxId = [int64]$maxIdText");
            script.AppendLine();
            script.AppendLine("        $seqSql = 'SELECT last_value::text || ''|'' || CASE WHEN is_called THEN ''true'' ELSE ''false'' END FROM {0}.{1}' -f $schemaName, $quotedSeq");
            script.AppendLine("        $seqText = Invoke-PsqlText -dbName $dbName -userName $dbConfig.user -password $dbConfig.password -sql $seqSql");
            script.AppendLine("        if ([string]::IsNullOrWhiteSpace($seqText)) {");
            script.AppendLine("            throw ('sequence info is empty: ' + $seqName)");
            script.AppendLine("        }");
            script.AppendLine();
            script.AppendLine("        $parts = $seqText -split '\\|', 2");
            script.AppendLine("        $lastValue = [int64]$parts[0]");
            script.AppendLine("        $isCalled = $false");
            script.AppendLine("        if ($parts.Length -ge 2) {");
            script.AppendLine("            $isCalled = $parts[1].Trim().ToLowerInvariant() -eq 'true'");
            script.AppendLine("        }");
            script.AppendLine();
            script.AppendLine("        if ($isCalled) {");
            script.AppendLine("            $nextFromSeq = $lastValue + 1");
            script.AppendLine("        } else {");
            script.AppendLine("            $nextFromSeq = $lastValue");
            script.AppendLine("        }");
            script.AppendLine();
            script.AppendLine("        $firstAvailable = $nextFromSeq");
            script.AppendLine("        if (($maxId + 1) -gt $firstAvailable) {");
            script.AppendLine("            $firstAvailable = $maxId + 1");
            script.AppendLine("        }");
            script.AppendLine();
            script.AppendLine("        $setValue = $null");
            script.AppendLine("        if ($reserveCount -gt 0) {");
            script.AppendLine("            $setValue = $firstAvailable + $reserveCount - 1");
            script.AppendLine("        } elseif ($firstAvailable -gt $nextFromSeq) {");
            script.AppendLine("            $setValue = $firstAvailable - 1");
            script.AppendLine("        }");
            script.AppendLine();
            script.AppendLine("        if ($null -ne $setValue) {");
            script.AppendLine("            $qualifiedSeq = $schemaName + '.' + $quotedSeq");
            script.AppendLine("            $setvalSql = 'SELECT setval(''' + (Escape-SqlLiteral $qualifiedSeq) + ''', ' + $setValue + ', true)'");
            script.AppendLine("            Invoke-PsqlText -dbName $dbName -userName $dbConfig.user -password $dbConfig.password -sql $setvalSql | Out-Null");
            script.AppendLine("        }");
            script.AppendLine();
            script.AppendLine("        if ($null -eq $setValue) {");
            script.AppendLine("            $reservedLast = $lastValue");
            script.AppendLine("        } else {");
            script.AppendLine("            $reservedLast = [int64]$setValue");
            script.AppendLine("        }");
            script.AppendLine();
            script.AppendLine("        $seqStartMap[$tableName] = [int64]$firstAvailable");
            script.AppendLine("        $tableResults.Add([ordered]@{");
            script.AppendLine("            tableName = $tableName");
            script.AppendLine("            dbName = $dbName");
            script.AppendLine("            idColumn = $idColumn");
            script.AppendLine("            seqName = $seqName");
            script.AppendLine("            reserveCount = $reserveCount");
            script.AppendLine("            startSeq = [int64]$firstAvailable");
            script.AppendLine("            reservedLast = [int64]$reservedLast");
            script.AppendLine("            maxId = [int64]$maxId");
            script.AppendLine("            previousLastValue = [int64]$lastValue");
            script.AppendLine("            previousIsCalled = $isCalled");
            script.AppendLine("        }) | Out-Null");
            script.AppendLine();
            script.AppendLine("        Write-Host ('[SeqReserve] ' + $tableName + ': reserveCount=' + $reserveCount + ', startSeq=' + $firstAvailable + ', seq=' + $seqName)");
            script.AppendLine("    }");
            script.AppendLine();
            script.AppendLine("    $result = [ordered]@{");
            script.AppendLine("        generatedAt = (Get-Date).ToString('o')");
            script.AppendLine("        sourceCalculatedAt = [string]$plan.sourceCalculatedAt");
            script.AppendLine("        facilityCodes = @($plan.facilityCodes)");
            script.AppendLine("        seqStartMap = $seqStartMap");
            script.AppendLine("        tableResults = $tableResults");
            script.AppendLine("    }");
            script.AppendLine();
            script.AppendLine("    $result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $resultPath -Encoding UTF8");
            script.AppendLine("    Write-Host ('[SeqReserve] completed: ' + $resultPath)");
            script.AppendLine("    exit 0");
            script.AppendLine("} catch {");
            script.AppendLine("    Write-Error $_");
            script.AppendLine("    exit 1");
            script.AppendLine("}");

            return script.ToString();
        }

        private static string BuildSeqReserveCommandScript()
        {
            var script = new StringBuilder();
            script.AppendLine("@echo off");
            script.AppendLine("setlocal");
            script.AppendLine("set SCRIPT_DIR=%~dp0");
            script.AppendLine("powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%SCRIPT_DIR%run_reserve_seq.ps1\"");
            script.AppendLine("set EXIT_CODE=%ERRORLEVEL%");
            script.AppendLine("if not \"%EXIT_CODE%\"==\"0\" (");
            script.AppendLine("  echo.");
            script.AppendLine("  echo Sequence reserve script failed. ExitCode=%EXIT_CODE%");
            script.AppendLine("  pause");
            script.AppendLine(")");
            script.AppendLine("exit /b %EXIT_CODE%");
            return script.ToString();
        }

        private static void WriteUtf8File(string path, string content)
        {
            File.WriteAllText(path, content ?? string.Empty, new UTF8Encoding(true));
        }

        private static void WriteAsciiFile(string path, string content)
        {
            File.WriteAllText(path, content ?? string.Empty, Encoding.ASCII);
        }

        private static string ToPowerShellSingleQuoted(string value)
        {
            return "'" + (value ?? string.Empty).Replace("'", "''") + "'";
        }

        private static bool IsOnToOffMigrationDb(string dbName)
        {
            return !string.IsNullOrEmpty(dbName) && ONTOOFF_MIGRATION_DBS.Contains(dbName);
        }

        private static long GetReserveCount(Dictionary<string, long> cloudCounts, string tableName)
        {
            if (cloudCounts == null || string.IsNullOrEmpty(tableName))
                return 0;

            long count;
            if (!cloudCounts.TryGetValue(tableName, out count))
                return 0;

            return count < 0 ? 0 : count;
        }

        private async Task<long> ReserveSequenceRangeAsync(
            NpgsqlConnection   conn,
            PgTableConfig      cfg,
            long               reserveCount,
            CancellationToken  ct)
        {
            string quotedTable = QuoteIdentifier(cfg.Name);
            string quotedId    = QuoteIdentifier(cfg.IdColumn);
            string quotedSeq   = QuoteIdentifier(cfg.ResolveSeqName());

            long maxId;
            using (var maxCmd = new NpgsqlCommand(
                string.Format("SELECT COALESCE(MAX({0}), 0) FROM {1}.{2}", quotedId, PG_SCHEMA, quotedTable), conn))
            {
                object maxResult = await maxCmd.ExecuteScalarAsync(ct);
                maxId = Convert.ToInt64(maxResult);
            }

            long lastValue;
            bool isCalled;
            using (var seqCmd = new NpgsqlCommand(
                string.Format("SELECT last_value, is_called FROM {0}.{1}", PG_SCHEMA, quotedSeq), conn))
            using (var reader = await seqCmd.ExecuteReaderAsync(ct))
            {
                if (!await reader.ReadAsync(ct))
                    throw new InvalidOperationException(string.Format("シーケンス情報を取得できませんでした: {0}", cfg.ResolveSeqName()));

                lastValue = reader.GetInt64(0);
                isCalled  = reader.GetBoolean(1);
            }

            long nextFromSeq    = isCalled ? lastValue + 1 : lastValue;
            long firstAvailable = Math.Max(maxId + 1, nextFromSeq);

            if (reserveCount > 0)
            {
                long reservedLast = firstAvailable + reserveCount - 1;
                await SetSequenceValueAsync(conn, cfg.ResolveSeqName(), reservedLast, true, ct);
            }
            else if (firstAvailable > nextFromSeq)
            {
                await SetSequenceValueAsync(conn, cfg.ResolveSeqName(), firstAvailable - 1, true, ct);
            }

            return firstAvailable;
        }

        private async Task SetSequenceValueAsync(
            NpgsqlConnection   conn,
            string             seqName,
            long               value,
            bool               isCalled,
            CancellationToken  ct)
        {
            string qualifiedSeq = PG_SCHEMA + "." + QuoteIdentifier(seqName);
            string sql = string.Format(
                "SELECT setval('{0}', {1}, {2})",
                EscapeSqlLiteral(qualifiedSeq),
                value,
                isCalled ? "true" : "false");

            using (var cmd = new NpgsqlCommand(sql, conn))
                await cmd.ExecuteScalarAsync(ct);
        }

        private static string QuoteIdentifier(string value)
        {
            return string.Format("\"{0}\"", (value ?? string.Empty).Replace("\"", "\"\""));
        }

        private static string EscapeSqlLiteral(string value)
        {
            return (value ?? string.Empty).Replace("'", "''");
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// on2off 用: サーバーからダウンロードした PG ダンプ ZIP をリストアする
        ///
        /// ZIP 内のディレクトリ構造:
        ///   {dbName}/{table}.data   → psql \COPY ... FROM (FORMAT binary)（データのみ）
        ///   {dbName}/{table}.dump   → pg_restore -Fc（スキーマ + データ、旧形式互換）
        /// </summary>
        /// <param name="pgZipPath">pg_dump.zip のパス</param>
        /// <param name="progress">進捗コールバック</param>
        /// <param name="ct">キャンセルトークン</param>
        //----------------------------------------------------------------------------------------------------
        public async Task RestoreAsync(
            string                  pgZipPath,
            List<string>            facilityCds,
            IProgress<ProgressInfo> progress,
            CancellationToken       ct)
        {
            progress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 0,
                Message    = "[Restore] PG リストア開始..."
            });

            // ZIP 展開先
            string restoreDir = Path.Combine(
                Path.GetDirectoryName(pgZipPath), "pg_restore_work");
            if (Directory.Exists(restoreDir))
                Directory.Delete(restoreDir, recursive: true);
            Directory.CreateDirectory(restoreDir);

            await Task.Run(() => ZipArchiver.ExtractToDirectory(pgZipPath, restoreDir), ct);

            // restoreDir 配下のサブディレクトリ = DB 名ごとに処理
            var dbDirs = Directory.GetDirectories(restoreDir);
            if (dbDirs.Length == 0)
            {
                progress.Report(new ProgressInfo
                {
                    DbKind     = DbKind.PostgreSql,
                    Percentage = 100,
                    Message    = "[Restore] ZIP 内にリストア対象ファイルがありません（スキップ）"
                });
                return;
            }

            var dbs = PgDatabases;

            // yaml からリストア対象テーブル名セットを構築（on2off / both のみ）
            var restoreTargets = LoadRestoreTargetNames();
            progress.Report(new ProgressInfo
            {
                DbKind  = DbKind.PostgreSql,
                Message = string.Format("[Restore] pg_dump_config.yaml: {0} テーブルがリストア対象", restoreTargets.Count)
            });

            int totalFiles  = CountRestoreFiles(restoreDir, restoreTargets);
            int doneFiles   = 0;

            foreach (string dbDir in dbDirs)
            {
                ct.ThrowIfCancellationRequested();

                string dbName = Path.GetFileName(dbDir);
                if (!dbs.ContainsKey(dbName))
                {
                    progress.Report(new ProgressInfo
                    {
                        DbKind  = DbKind.PostgreSql,
                        IsError = true,
                        Message = string.Format("[Restore] 未知の DB: {0} — スキップ", dbName)
                    });
                    continue;
                }

                string user    = dbs[dbName].User;
                string pass    = dbs[dbName].Password;
                var (pgHost2, pgPort2) = AppSettings.ParseHostPort(_settings.OnpreRdbIpAddress, PG_DEFAULT_PORT);
                string connUri = string.Format(
                    "postgresql://{0}:{1}@{2}:{3}/{4}",
                    user, pass, pgHost2, pgPort2, dbName);

                progress.Report(new ProgressInfo
                {
                    DbKind  = DbKind.PostgreSql,
                    Message = string.Format("[Restore] {0}: リストア開始", dbName)
                });

                var dataFiles = Directory.GetFiles(dbDir, "*.data")
                    .Where(f =>
                    {
                        string tbl = Path.GetFileNameWithoutExtension(f);
                        if (SYSTEM_TABLES_SKIP.Contains(tbl)) return false;
                        if (!restoreTargets.Contains(tbl))
                        {
                            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient",
                                AppLogger.LOGGING_CLASS.INFO,
                                string.Format("[Restore] {0}.{1}: yaml 対象外 — スキップ", dbName, tbl));
                            return false;
                        }
                        return true;
                    })
                    .ToArray();
                var dumpFiles = Directory.GetFiles(dbDir, "*.dump")
                    .Where(f =>
                    {
                        string tbl = Path.GetFileNameWithoutExtension(f);
                        if (SYSTEM_TABLES_SKIP.Contains(tbl)) return false;
                        if (!restoreTargets.Contains(tbl))
                        {
                            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient",
                                AppLogger.LOGGING_CLASS.INFO,
                                string.Format("[Restore] {0}.{1}: yaml 対象外 — スキップ", dbName, tbl));
                            return false;
                        }
                        return true;
                    })
                    .ToArray();

                // フェーズ 1: 全 .data テーブルの既存施設データを先にまとめて削除する
                //             FK 制約違反が出たテーブルは子テーブル削除後に再試行する
                if (facilityCds != null && facilityCds.Count > 0)
                {
                    var pendingDeletes = dataFiles
                        .Select(f => Path.GetFileNameWithoutExtension(f))
                        .ToList();

                    int maxPasses = pendingDeletes.Count + 1;
                    for (int retryPass = 0; retryPass < maxPasses && pendingDeletes.Count > 0; retryPass++)
                    {
                        var retryList = new System.Collections.Generic.List<string>();
                        foreach (string table in pendingDeletes)
                        {
                            ct.ThrowIfCancellationRequested();
                            progress.Report(new ProgressInfo
                            {
                                DbKind  = DbKind.PostgreSql,
                                Message = string.Format("[Restore] {0}.{1}: 既存施設データを削除中...", dbName, table)
                            });
                            bool deleted = await DeleteFacilityDataAsync(dbName, table, facilityCds, ct);
                            if (!deleted)
                            {
                                progress.Report(new ProgressInfo
                                {
                                    DbKind  = DbKind.PostgreSql,
                                    Message = string.Format("[Restore] {0}.{1}: FK 制約のためリトライ待ち", dbName, table)
                                });
                                retryList.Add(table);
                            }
                        }
                        pendingDeletes = retryList;
                    }

                    foreach (string table in pendingDeletes)
                    {
                        progress.Report(new ProgressInfo
                        {
                            DbKind  = DbKind.PostgreSql,
                            IsError = true,
                            Message = string.Format("[Restore] {0}.{1}: 削除失敗（FK 制約が解消されませんでした）", dbName, table)
                        });
                    }
                }

                // フェーズ 2: .dump ファイル → pg_restore によるデータリストア
                foreach (string dumpFile in dumpFiles)
                {
                    ct.ThrowIfCancellationRequested();
                    string table = Path.GetFileNameWithoutExtension(dumpFile);
                    progress.Report(new ProgressInfo
                    {
                        DbKind  = DbKind.PostgreSql,
                        Message = string.Format("[Restore] {0}.{1}: データリストア中...", dbName, table)
                    });

                    await Task.Run(() =>
                        RunPgRestore(connUri, dumpFile, pass, ct), ct);

                    doneFiles++;
                    progress.Report(new ProgressInfo
                    {
                        DbKind     = DbKind.PostgreSql,
                        Percentage = totalFiles == 0 ? 0 : (int)((double)doneFiles / totalFiles * 100),
                        Message    = string.Format("[Restore] {0}.{1}: データリストア完了", dbName, table)
                    });
                }

                // フェーズ 3: .data ファイル → バイナリ COPY（削除済み）
                foreach (string dataFile in dataFiles)
                {
                    ct.ThrowIfCancellationRequested();
                    string table = Path.GetFileNameWithoutExtension(dataFile);

                    progress.Report(new ProgressInfo
                    {
                        DbKind  = DbKind.PostgreSql,
                        Message = string.Format("[Restore] {0}.{1}: データ COPY 中...", dbName, table)
                    });

                    string psqlFilePath = dataFile.Replace('\\', '/');
                    await Task.Run(() =>
                        RunPsqlCopyFrom(connUri, dbName, table, psqlFilePath, pass, ct), ct);

                    doneFiles++;
                    progress.Report(new ProgressInfo
                    {
                        DbKind     = DbKind.PostgreSql,
                        Percentage = totalFiles == 0 ? 0 : (int)((double)doneFiles / totalFiles * 100),
                        Message    = string.Format("[Restore] {0}.{1}: データ COPY 完了", dbName, table)
                    });
                }

                progress.Report(new ProgressInfo
                {
                    DbKind  = DbKind.PostgreSql,
                    Message = string.Format("[Restore] {0}: 完了", dbName)
                });
            }

            progress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 100,
                Message    = "[Restore] PG リストア完了"
            });
        }

        // ------------------------------------------------------------------
        // Private ヘルパー
        // ------------------------------------------------------------------

        /// <summary>
        /// on2off リストア用: 指定テーブルから対象施設のデータを削除する。
        /// 戻り値: true=削除成功（または facility_cd 列なしでスキップ）、false=FK 違反により削除失敗（リトライが必要）
        /// </summary>
        private async Task<bool> DeleteFacilityDataAsync(
            string            dbName,
            string            tableName,
            List<string>      facilityCds,
            CancellationToken ct)
        {
            var dbs = PgDatabases;
            if (!dbs.ContainsKey(dbName)) return true;

            string user    = dbs[dbName].User;
            string pass    = dbs[dbName].Password;
            var (pgHost3, pgPort3) = AppSettings.ParseHostPort(_settings.OnpreRdbIpAddress, PG_DEFAULT_PORT);
            string connStr = string.Format(
                "Host={0};Port={1};Database={2};Username={3};Password={4}",
                pgHost3, pgPort3, dbName, user, pass);

            var inList = new StringBuilder();
            for (int i = 0; i < facilityCds.Count; i++)
            {
                if (i > 0) inList.Append(',');
                inList.AppendFormat("'{0}'", facilityCds[i].Replace("'", "''"));
            }

            using (var conn = new NpgsqlConnection(connStr))
            {
                await conn.OpenAsync(ct);

                // facility_cd 列の存在確認（列がないテーブルはスキップ）
                bool hasFacilityCd = false;
                using (var chk = new NpgsqlCommand(
                    string.Format(
                        "SELECT COUNT(*) FROM information_schema.columns " +
                        "WHERE table_schema = '{0}' AND table_name = '{1}' AND column_name = 'facility_cd'",
                        PG_SCHEMA, tableName.Replace("'", "''")), conn))
                {
                    hasFacilityCd = Convert.ToInt64(await chk.ExecuteScalarAsync(ct)) > 0;
                }

                if (!hasFacilityCd) return true;

                string sql = string.Format(
                    "DELETE FROM {0}.{1} WHERE facility_cd IN ({2})",
                    PG_SCHEMA, tableName, inList);

                try
                {
                    using (var cmd = new NpgsqlCommand(sql, conn))
                        await cmd.ExecuteNonQueryAsync(ct);
                    return true;
                }
                catch (PostgresException pgEx) when (pgEx.SqlState == "23503")
                {
                    // FK 制約違反 → 子テーブルがまだ残っている。リトライが必要。
                    return false;
                }
            }
        }

        private static int CountRestoreFiles(string restoreDir, HashSet<string> restoreTargets)
        {
            int count = 0;
            foreach (string subDir in Directory.GetDirectories(restoreDir))
            {
                count += Directory.GetFiles(subDir, "*.dump")
                    .Count(f => restoreTargets.Contains(Path.GetFileNameWithoutExtension(f))
                             && !SYSTEM_TABLES_SKIP.Contains(Path.GetFileNameWithoutExtension(f)));
                count += Directory.GetFiles(subDir, "*.data")
                    .Count(f => restoreTargets.Contains(Path.GetFileNameWithoutExtension(f))
                             && !SYSTEM_TABLES_SKIP.Contains(Path.GetFileNameWithoutExtension(f)));
            }
            return count;
        }

        /// <summary>
        /// yaml からリストア対象テーブル名の HashSet を返す（on2off / both かつ dump=true）
        /// </summary>
        private static HashSet<string> LoadRestoreTargetNames()
        {
            var all = PgDumpConfigLoader.Load(AppConfigLoader.PgDumpConfigPath);
            var set = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var t in all)
            {
                if (t.Dump && IsRestoreDirectionMatch(t.Direction))
                    set.Add(t.Name);
            }
            return set;
        }

        private static bool IsRestoreDirectionMatch(string direction)
        {
            if (string.IsNullOrEmpty(direction)) return true;
            string d = direction.ToLowerInvariant();
            return d == "both" || d == "on2off";
        }

        private void RunPgRestore(
            string            connUri,
            string            dumpFile,
            string            pgPassword,
            CancellationToken ct)
        {
            var args = new StringBuilder();
            args.AppendFormat("-d \"{0}\" ", connUri);
            args.Append("-Fc --no-acl --no-owner --data-only ");
            args.AppendFormat("\"{0}\"", dumpFile);

            var psi = new ProcessStartInfo
            {
                FileName               = PG_RESTORE_EXE,
                Arguments              = args.ToString().TrimEnd(),
                UseShellExecute        = false,
                RedirectStandardError  = true,
                RedirectStandardOutput = false,
                CreateNoWindow         = true
            };
            psi.EnvironmentVariables["PGPASSWORD"] = pgPassword;

            if (!System.IO.File.Exists(PG_RESTORE_EXE))
                throw new FileNotFoundException(
                    string.Format("実行ファイルが見つかりません。PostgreSQL Client Tools (pg_restore) がインストールされているか確認してください。\nパス: {0}", PG_RESTORE_EXE), PG_RESTORE_EXE);

            using (var proc = Process.Start(psi))
            {
                using (ct.Register(() => { try { if (!proc.HasExited) proc.Kill(); } catch { } }))
                {
                    string stderr = proc.StandardError.ReadToEnd();
                    proc.WaitForExit();
                    ct.ThrowIfCancellationRequested();

                    if (proc.ExitCode != 0)
                        throw new InvalidOperationException(
                            string.Format("pg_restore 終了コード {0}: {1}",
                                proc.ExitCode, stderr.Trim()));
                }
            }
        }

        private void RunPsqlCopyFrom(
            string            connUri,
            string            dbName,
            string            tableName,
            string            psqlFilePath,   // フォワードスラッシュ区切り
            string            pgPassword,
            CancellationToken ct)
        {
            string copyCmd = string.Format(
                @"\COPY {0}.{1} FROM '{2}' (FORMAT binary)",
                PG_SCHEMA, tableName, psqlFilePath);

            var psi = new ProcessStartInfo
            {
                FileName               = PSQL_EXE,
                Arguments              = string.Format("-d \"{0}\" --no-psqlrc --quiet", connUri),
                UseShellExecute        = false,
                RedirectStandardInput  = true,
                RedirectStandardOutput = true,
                RedirectStandardError  = true,
                CreateNoWindow         = true
            };
            psi.EnvironmentVariables["PGPASSWORD"] = pgPassword;

            if (!System.IO.File.Exists(PSQL_EXE))
                throw new FileNotFoundException(
                    string.Format("実行ファイルが見つかりません。PostgreSQL Client Tools (psql) がインストールされているか確認してください。\nパス: {0}", PSQL_EXE), PSQL_EXE);

            using (var proc = Process.Start(psi))
            {
                proc.StandardInput.WriteLine(copyCmd);
                proc.StandardInput.Close();

                var stderrTask = Task.Run(() => proc.StandardError.ReadToEnd());
                var stdoutTask = Task.Run(() => proc.StandardOutput.ReadToEnd());

                using (ct.Register(() => { try { if (!proc.HasExited) proc.Kill(); } catch { } }))
                {
                    proc.WaitForExit();
                    ct.ThrowIfCancellationRequested();

                    string stderr = stderrTask.Result;
                    if (proc.ExitCode != 0)
                        throw new InvalidOperationException(
                            string.Format("psql COPY FROM 終了コード {0}: {1}",
                                proc.ExitCode, stderr.Trim()));
                }
            }
        }
    }

    internal sealed class SeqReserveScriptArtifacts
    {
        public SeqReserveScriptArtifacts(
            string                  artifactDirectory,
            string                  planJsonPath,
            string                  scriptPath,
            string                  commandPath,
            string                  resultJsonPath,
            ConverterSeqReservePlan plan)
        {
            ArtifactDirectory = artifactDirectory;
            PlanJsonPath = planJsonPath;
            ScriptPath = scriptPath;
            CommandPath = commandPath;
            ResultJsonPath = resultJsonPath;
            Plan = plan;
        }

        public string ArtifactDirectory { get; private set; }
        public string PlanJsonPath { get; private set; }
        public string ScriptPath { get; private set; }
        public string CommandPath { get; private set; }
        public string ResultJsonPath { get; private set; }
        public ConverterSeqReservePlan Plan { get; private set; }
    }
}
