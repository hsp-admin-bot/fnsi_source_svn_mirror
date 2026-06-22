using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using FNSICloudConvertClient.Models;
using System.Linq;
using System.Windows.Forms;

namespace FNSICloudConvertClient.Logic
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// データ移行ロジック（PostgreSQL + MongoDB を統合制御）
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class DataMigrationLogic
    {
        private readonly AppLogger _log;
        private readonly object _jobStateLock = new object();
        private CancellationTokenSource _cts;
        private long _currentJobId;

        public DataMigrationLogic()
        {
            _log = AppLogger.GetInstance();
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// データ導出（off2on）を実行する
        ///
        /// Step 1: PG 導出           pgProgress   0% ～  30%
        /// Step 2: Mongo 導出        pgProgress  30% ～  50%
        /// Step 3: ZIP 作成          pgProgress  50% ～  60%
        /// Step 4: アップロード × 3  pgProgress  60% ～  85%
        /// Step 5: JOB 起動          pgProgress  85% ～  90%
        /// Step 6: JOB ポーリング    pgProgress  90% 固定 / mongoProgress 0% ～ 100%
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task RunExportAsync(
            List<FacilityInfo>      facilities,
            AppSettings             settings,
            IProgress<ProgressInfo> pgProgress,
            IProgress<ProgressInfo> mongoProgress)
        {
            _cts = new CancellationTokenSource();
            var ct = _cts.Token;

            var facilityCds = facilities.Select(f => f.FacilityCd).ToList();

            var pgLogic    = new PostgreSqlLogic(settings);
            var mongoLogic = new MongoDbLogic(settings);

            // ----------------------------------------------------------------
            // Step 0: 事前件数取得（DB4/5/6 テーブル数 + Mongo コレクション数）
            // ----------------------------------------------------------------
            var pgExporter = new PgDumpExporter(settings);
            await Task.WhenAll(
                pgExporter.ReportTableCountsAsync(pgProgress, ct),
                mongoLogic.ReportCollectionCountAsync(pgProgress, ct)
            );

            // ----------------------------------------------------------------
            // Step 1: PostgreSQL 導出 (pgProgress 0-30%)
            // ----------------------------------------------------------------
            await pgLogic.ExportAsync(facilityCds, NormalizeProgress(pgProgress, 0, 30), ct);

            // ----------------------------------------------------------------
            // Step 2: MongoDB 導出（全施設を一括処理 / pgProgress 30-50%）
            // ----------------------------------------------------------------
            await mongoLogic.ExportAsync(
                facilityCds,
                NormalizeProgress(pgProgress, 30, 20),
                ct);

            // ----------------------------------------------------------------
            // Step 3: ZIP アーカイブ作成 (pgProgress 50-60%)
            // ----------------------------------------------------------------
            string uploadDir    = Path.Combine(settings.OnpreTempFolder, "uploads");
            string pgZipPath    = Path.Combine(uploadDir, "pg_dump.zip");
            string mongoZipPath = Path.Combine(uploadDir, "mongo_dump.zip");
            string filesZipPath = Path.Combine(uploadDir, "files.zip");

            await Task.Run(() =>
            {
                ct.ThrowIfCancellationRequested();
                Directory.CreateDirectory(uploadDir);

                // PG dump ZIP
                pgProgress.Report(new ProgressInfo
                {
                    DbKind = DbKind.PostgreSql, Percentage = 51,
                    Message = "[ZIP] PG ダンプ圧縮中..."
                });
                string zipPwd = AppConfigLoader.ZipPassword;

                string pgExportDir = Path.Combine(settings.OnpreTempFolder, "pg_export");
                if (Directory.Exists(pgExportDir))
                    ZipArchiver.CreateFromDirectory(pgExportDir, pgZipPath, zipPwd);
                else
                    ZipArchiver.CreateEmpty(pgZipPath);

                // Mongo dump ZIP
                ct.ThrowIfCancellationRequested();
                pgProgress.Report(new ProgressInfo
                {
                    DbKind = DbKind.PostgreSql, Percentage = 54,
                    Message = "[ZIP] Mongo ダンプ圧縮中..."
                });
                string mongoExportDir = Path.Combine(settings.OnpreTempFolder, "mongo_export");
                if (Directory.Exists(mongoExportDir))
                    ZipArchiver.CreateFromDirectory(mongoExportDir, mongoZipPath, zipPwd);
                else
                {
                    pgProgress.Report(new ProgressInfo
                    {
                        DbKind = DbKind.PostgreSql, IsError = true,
                        Message = string.Format("[ZIP] Mongo 導出ディレクトリが見つかりません: {0}", mongoExportDir)
                    });
                    ZipArchiver.CreateEmpty(mongoZipPath);
                }

                // Files ZIP（施設コードと同名のサブディレクトリのみ対象）
                ct.ThrowIfCancellationRequested();
                pgProgress.Report(new ProgressInfo
                {
                    DbKind = DbKind.PostgreSql, Percentage = 57,
                    Message = "[ZIP] FNSi ファイル圧縮中..."
                });
                if (!string.IsNullOrEmpty(settings.OnpreFnsiRootFolder)
                    && Directory.Exists(settings.OnpreFnsiRootFolder))
                    ZipArchiver.CreateFromSubDirectories(
                        settings.OnpreFnsiRootFolder, facilityCds, filesZipPath, zipPwd);
                else
                    ZipArchiver.CreateEmpty(filesZipPath);

                pgProgress.Report(new ProgressInfo
                {
                    DbKind = DbKind.PostgreSql, Percentage = 60,
                    Message = "[ZIP] 圧縮完了"
                });
            }, ct);

            // ----------------------------------------------------------------
            // Step 4: アップロード × 3 (pgProgress 60-85%)
            // ----------------------------------------------------------------
            string facilityCdsCsv = string.Join(",", facilityCds);
            var apiClient = new ConverterApiClient(AppConfigLoader.ConverterBaseUri);

            pgProgress.Report(new ProgressInfo
            {
                DbKind = DbKind.PostgreSql, Percentage = 61,
                Message = "[Upload] PG ダンプをアップロード中..."
            });
            string pgUploadId = await apiClient.UploadAsync(pgZipPath, "PG_DUMP", facilityCdsCsv, ct);
            pgProgress.Report(new ProgressInfo
            {
                DbKind = DbKind.PostgreSql, Percentage = 69,
                Message = string.Format("[Upload] PG ダンプ完了: {0}", pgUploadId)
            });

            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo
            {
                DbKind = DbKind.PostgreSql, Percentage = 70,
                Message = "[Upload] Mongo ダンプをアップロード中..."
            });
            string mongoUploadId = await apiClient.UploadAsync(mongoZipPath, "MONGO_DUMP", facilityCdsCsv, ct);
            pgProgress.Report(new ProgressInfo
            {
                DbKind = DbKind.PostgreSql, Percentage = 78,
                Message = string.Format("[Upload] Mongo ダンプ完了: {0}", mongoUploadId)
            });

            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo
            {
                DbKind = DbKind.PostgreSql, Percentage = 79,
                Message = "[Upload] FNSi ファイルをアップロード中..."
            });
            string filesUploadId = await apiClient.UploadAsync(filesZipPath, "FILES", facilityCdsCsv, ct);
            pgProgress.Report(new ProgressInfo
            {
                DbKind = DbKind.PostgreSql, Percentage = 85,
                Message = string.Format("[Upload] FNSi ファイル完了: {0}", filesUploadId)
            });

            // ----------------------------------------------------------------
            // Step 5: JOB 起動 (pgProgress 85-90%)
            // ----------------------------------------------------------------
            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo
            {
                DbKind = DbKind.PostgreSql, Percentage = 86,
                Message = "[JOB] 移行 JOB を起動中..."
            });
            var uploadIds = new Dictionary<string, string>
            {
                { "pgDump",    pgUploadId    },
                { "mongoDump", mongoUploadId },
                { "files",     filesUploadId },
            };
            long jobId = await apiClient.StartJobAsync("off2on", facilityCds, uploadIds, ct);
            SetCurrentJobId(jobId);

            // JOB 起動成功 → オンプレ側は完了（100%）
            pgProgress.Report(new ProgressInfo
            {
                DbKind = DbKind.PostgreSql, Percentage = 100,
                Message = string.Format("[JOB] 移行 JOB 起動完了: JobId={0}　サーバー処理を待機中...", jobId)
            });

            // ----------------------------------------------------------------
            // Step 6: JOB ポーリング（mongoProgress 0-100%）
            // ----------------------------------------------------------------
            try
            {
                await apiClient.PollUntilDoneAsync(jobId, pgProgress, mongoProgress, ct);
            }
            finally
            {
                ClearCurrentJobId(jobId);
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// データ導入（on2off）を実行する
        ///
        /// Step 1: seqStartMap 構築       pgProgress   0% ～  20%
        /// Step 2: JOB 起動               pgProgress  20% ～  25%
        /// Step 3: JOB ポーリング         pgProgress  25% 固定 / mongoProgress 0% ～ 100%
        /// Step 4: ダウンロード × 3       pgProgress  25% ～  55%
        /// Step 5: PG リストア            pgProgress  55% ～  80%
        /// Step 6: Mongo インポート        pgProgress  80% ～  95%
        /// Step 7: ファイル展開           pgProgress  95% ～ 100%
        /// </summary>
        /// <param name="facilities">対象施設リスト</param>
        /// <param name="settings">接続設定</param>
        /// <param name="pgProgress">全体進捗コールバック（左パネル）</param>
        /// <param name="mongoProgress">クラウド JOB / Mongo 進捗コールバック（右パネル）</param>
        //----------------------------------------------------------------------------------------------------
        public async Task RunImportAsync(
            List<FacilityInfo>      facilities,
            AppSettings             settings,
            IProgress<ProgressInfo> pgProgress,
            IProgress<ProgressInfo> mongoProgress)
        {
            _cts = new CancellationTokenSource();
            var ct = _cts.Token;

            var facilityCds = facilities.Select(f => f.FacilityCd).ToList();

            var pgLogic    = new PostgreSqlLogic(settings);
            var mongoLogic = new MongoDbLogic(settings);
            var apiClient  = new ConverterApiClient(AppConfigLoader.ConverterBaseUri);

            // ----------------------------------------------------------------
            // Step 1: seqStartMap 構築 (pgProgress 0-20%)
            // ----------------------------------------------------------------
            pgProgress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 1,
                Message    = "[Import] オンプレ DB のシーケンス情報を収集中..."
            });

            var seqStartMap = await pgLogic.GetSeqStartMapAsync(
                facilityCds,
                NormalizeProgress(pgProgress, 0, 20), ct);

            // ----------------------------------------------------------------
            // Step 2: JOB 起動 (pgProgress 20-25%)
            // ----------------------------------------------------------------
            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 21,
                Message    = "[Import] 移行 JOB を起動中..."
            });

            long jobId = await apiClient.StartJobOnToOffAsync(facilityCds, seqStartMap, ct);
            SetCurrentJobId(jobId);

            pgProgress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 25,
                Message    = string.Format("[Import] JOB 起動完了: JobId={0}　サーバー処理を待機中...", jobId)
            });

            // ----------------------------------------------------------------
            // Step 3: JOB ポーリング（mongoProgress 0-100%、pgProgress は 25% 固定）
            // ----------------------------------------------------------------
            try
            {
                await apiClient.PollUntilDoneAsync(jobId, pgProgress, mongoProgress, ct);
            }
            finally
            {
                ClearCurrentJobId(jobId);
            }

            // ----------------------------------------------------------------
            // Step 4: ダウンロード × 3 (pgProgress 25-55%)
            // ----------------------------------------------------------------
            string downloadDir  = Path.Combine(settings.OnpreTempFolder, "downloads");
            string pgZipPath    = Path.Combine(downloadDir, "pg_dump.zip");
            string mongoZipPath = Path.Combine(downloadDir, "mongo_dump.zip");
            string filesZipPath = Path.Combine(downloadDir, "files.zip");

            Directory.CreateDirectory(downloadDir);

            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 26,
                Message    = "[Download] PG ダンプをダウンロード中..."
            });
            await apiClient.DownloadAsync(jobId, "pg_dump", pgZipPath, ct);
            pgProgress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 35,
                Message    = "[Download] PG ダンプ完了"
            });

            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 36,
                Message    = "[Download] Mongo ダンプをダウンロード中..."
            });
            await apiClient.DownloadAsync(jobId, "mongo_dump", mongoZipPath, ct);
            pgProgress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 45,
                Message    = "[Download] Mongo ダンプ完了"
            });

            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 46,
                Message    = "[Download] FNSi ファイルをダウンロード中..."
            });
            await apiClient.DownloadAsync(jobId, "files", filesZipPath, ct);
            pgProgress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 55,
                Message    = "[Download] FNSi ファイル完了"
            });

            // ----------------------------------------------------------------
            // Step 5: PG リストア (pgProgress 55-80%)
            // ----------------------------------------------------------------
            await pgLogic.RestoreAsync(pgZipPath, facilityCds, NormalizeProgress(pgProgress, 55, 25), ct);

            // ----------------------------------------------------------------
            // Step 6: Mongo インポート (pgProgress 80-95%)
            // ----------------------------------------------------------------
            await mongoLogic.ImportFromZipAsync(mongoZipPath, NormalizeProgress(pgProgress, 80, 15), ct);

            // ----------------------------------------------------------------
            // Step 7: ファイル展開 (pgProgress 95-100%)
            // ----------------------------------------------------------------
            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 96,
                Message    = "[Import] FNSi ファイルを展開中..."
            });

            if (!string.IsNullOrEmpty(settings.OnpreFnsiRootFolder))
            {
                await Task.Run(() =>
                {
                    ct.ThrowIfCancellationRequested();
                    ZipArchiver.ExtractToDirectory(filesZipPath, settings.OnpreFnsiRootFolder, AppConfigLoader.ZipPassword);
                }, ct);
            }

            pgProgress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 100,
                Message    = "[Import] データ導入完了"
            });
        }

        // ====================================================================
        // LAN モード分割メソッド
        // ====================================================================

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// [LAN モード / off2on] オンプレ側エクスポート
        /// Step 0: 事前件数取得
        /// Step 1: PG 導出       pgProgress  0% ～  50%
        /// Step 2: Mongo 導出    pgProgress 50% ～  75%
        /// Step 3: ZIP 作成      pgProgress 75% ～ 100%
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task RunExportOnpreAsync(
            List<FacilityInfo>      facilities,
            AppSettings             settings,
            IProgress<ProgressInfo> pgProgress,
            IProgress<ProgressInfo> mongoProgress)
        {
            _cts = new CancellationTokenSource();
            var ct = _cts.Token;

            var facilityCds = facilities.Select(f => f.FacilityCd).ToList();
            var pgLogic    = new PostgreSqlLogic(settings);
            var mongoLogic = new MongoDbLogic(settings);

            // Step 0: 事前件数取得
            var pgExporter = new PgDumpExporter(settings);
            await Task.WhenAll(
                pgExporter.ReportTableCountsAsync(pgProgress, ct),
                mongoLogic.ReportCollectionCountAsync(pgProgress, ct));

            // Step 1: PG 導出 (0-50%)
            await pgLogic.ExportAsync(facilityCds, NormalizeProgress(pgProgress, 0, 50), ct);

            // Step 2: Mongo 導出 (50-75%)
            await mongoLogic.ExportAsync(facilityCds, NormalizeProgress(pgProgress, 50, 25), ct);

            // Step 3: ZIP 作成 (75-100%)
            string uploadDir    = Path.Combine(settings.OnpreTempFolder, "uploads");
            string pgZipPath    = Path.Combine(uploadDir, "pg_dump.zip");
            string mongoZipPath = Path.Combine(uploadDir, "mongo_dump.zip");
            string filesZipPath = Path.Combine(uploadDir, "files.zip");
            string zipPwd       = AppConfigLoader.ZipPassword;
            string facilityCdsCsv = string.Join(",", facilityCds);

            await Task.Run(() =>
            {
                ct.ThrowIfCancellationRequested();
                Directory.CreateDirectory(uploadDir);

                pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 76, Message = "[ZIP] PG ダンプ圧縮中..." });
                string pgExportDir = Path.Combine(settings.OnpreTempFolder, "pg_export");
                if (Directory.Exists(pgExportDir)) ZipArchiver.CreateFromDirectory(pgExportDir, pgZipPath, zipPwd);
                else ZipArchiver.CreateEmpty(pgZipPath);

                ct.ThrowIfCancellationRequested();
                pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 86, Message = "[ZIP] Mongo ダンプ圧縮中..." });
                string mongoExportDir = Path.Combine(settings.OnpreTempFolder, "mongo_export");
                if (Directory.Exists(mongoExportDir)) ZipArchiver.CreateFromDirectory(mongoExportDir, mongoZipPath, zipPwd);
                else ZipArchiver.CreateEmpty(mongoZipPath);

                ct.ThrowIfCancellationRequested();
                pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 93, Message = "[ZIP] FNSi ファイル圧縮中..." });
                if (!string.IsNullOrEmpty(settings.OnpreFnsiRootFolder) && Directory.Exists(settings.OnpreFnsiRootFolder))
                    ZipArchiver.CreateFromSubDirectories(settings.OnpreFnsiRootFolder, facilityCds, filesZipPath, zipPwd);
                else ZipArchiver.CreateEmpty(filesZipPath);

                pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 100, Message = "[ZIP] 圧縮完了 — ネットワークを WAN に切り替えてからクラウドImportを実行してください" });
            }, ct);
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// [LAN モード / off2on] クラウド側インポート
        /// Step 4: アップロード × 3  pgProgress  0% ～  70%
        /// Step 5: JOB 起動          pgProgress 70% ～  85%
        /// Step 6: JOB ポーリング    pgProgress 85% 固定 / mongoProgress 0% ～ 100%
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task RunExportCloudAsync(
            List<FacilityInfo>      facilities,
            AppSettings             settings,
            IProgress<ProgressInfo> pgProgress,
            IProgress<ProgressInfo> mongoProgress)
        {
            _cts = new CancellationTokenSource();
            var ct = _cts.Token;

            var facilityCds   = facilities.Select(f => f.FacilityCd).ToList();
            var facilityCdsCsv = string.Join(",", facilityCds);
            var apiClient      = new ConverterApiClient(AppConfigLoader.ConverterBaseUri);

            string uploadDir    = Path.Combine(settings.OnpreTempFolder, "uploads");
            string pgZipPath    = Path.Combine(uploadDir, "pg_dump.zip");
            string mongoZipPath = Path.Combine(uploadDir, "mongo_dump.zip");
            string filesZipPath = Path.Combine(uploadDir, "files.zip");

            // Step 4: アップロード × 3 (0-70%)
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 1, Message = "[Upload] PG ダンプをアップロード中..." });
            string pgUploadId = await apiClient.UploadAsync(pgZipPath, "PG_DUMP", facilityCdsCsv, ct);
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 23, Message = string.Format("[Upload] PG ダンプ完了: {0}", pgUploadId) });

            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 24, Message = "[Upload] Mongo ダンプをアップロード中..." });
            string mongoUploadId = await apiClient.UploadAsync(mongoZipPath, "MONGO_DUMP", facilityCdsCsv, ct);
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 46, Message = string.Format("[Upload] Mongo ダンプ完了: {0}", mongoUploadId) });

            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 47, Message = "[Upload] FNSi ファイルをアップロード中..." });
            string filesUploadId = await apiClient.UploadAsync(filesZipPath, "FILES", facilityCdsCsv, ct);
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 70, Message = string.Format("[Upload] FNSi ファイル完了: {0}", filesUploadId) });

            // Step 5: JOB 起動 (70-85%)
            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 71, Message = "[JOB] 移行 JOB を起動中..." });
            var uploadIds = new Dictionary<string, string>
            {
                { "pgDump",    pgUploadId    },
                { "mongoDump", mongoUploadId },
                { "files",     filesUploadId },
            };
            long jobId = await apiClient.StartJobAsync("off2on", facilityCds, uploadIds, ct);
            SetCurrentJobId(jobId);

            // JOB 起動成功 → クライアント側処理完了（100%）
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 100, Message = string.Format("[JOB] 起動完了: JobId={0}　サーバー処理を待機中...", jobId) });

            // Step 6: JOB ポーリング（pgProgress は 100% 維持のままログ追記）
            try
            {
                await apiClient.PollUntilDoneAsync(jobId, pgProgress, mongoProgress, ct);
            }
            finally
            {
                ClearCurrentJobId(jobId);
            }

            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 100, Message = "[クラウド Import] 完了" });
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// [LAN モード / on2off] クラウド側エクスポート
        /// Step 1: seqStartMap 用スクリプト生成 + JSON 読込  pgProgress  0% ～  20%
        /// Step 2: JOB 起動               pgProgress 20% ～  30%
        /// Step 3: JOB ポーリング         pgProgress 30% 固定 / mongoProgress 0% ～ 100%
        /// Step 4: ダウンロード × 3       pgProgress 30% ～ 100%
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task RunImportCloudAsync(
            List<FacilityInfo>      facilities,
            AppSettings             settings,
            IProgress<ProgressInfo> pgProgress,
            IProgress<ProgressInfo> mongoProgress)
        {
            _cts = new CancellationTokenSource();
            var ct = _cts.Token;

            var facilityCds = facilities.Select(f => f.FacilityCd).ToList();
            var pgLogic     = new PostgreSqlLogic(settings);
            var apiClient   = new ConverterApiClient(AppConfigLoader.ConverterBaseUri);

            // Step 1: seqStartMap 用スクリプト生成 + JSON 読込 (0-20%)
            var seqProgress = NormalizeProgress(pgProgress, 0, 20);
            var seqArtifacts = await pgLogic.PrepareManualSeqReserveAsync(facilityCds, seqProgress, ct);
            var seqStartMap = AcquireManualSeqStartMap(seqArtifacts, pgLogic, seqProgress, ct);

            // Step 2: JOB 起動 (20-30%)
            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 21, Message = "[Import] 移行 JOB を起動中..." });
            long jobId = await apiClient.StartJobOnToOffAsync(facilityCds, seqStartMap, ct);
            SetCurrentJobId(jobId);
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 30, Message = string.Format("[Import] JOB 起動完了: JobId={0}　サーバー処理を待機中...", jobId) });

            // Step 3: JOB ポーリング (mongoProgress 0-100%)
            try
            {
                await apiClient.PollUntilDoneAsync(jobId, pgProgress, mongoProgress, ct);
            }
            finally
            {
                ClearCurrentJobId(jobId);
            }

            // Step 4: ダウンロード × 3 (30-100%)
            string downloadDir  = Path.Combine(settings.OnpreTempFolder, "downloads");
            string pgZipPath    = Path.Combine(downloadDir, "pg_dump.zip");
            string mongoZipPath = Path.Combine(downloadDir, "mongo_dump.zip");
            string filesZipPath = Path.Combine(downloadDir, "files.zip");
            Directory.CreateDirectory(downloadDir);

            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 31, Message = "[Download] PG ダンプをダウンロード中..." });
            await apiClient.DownloadAsync(jobId, "pg_dump", pgZipPath, ct);
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 53, Message = "[Download] PG ダンプ完了" });

            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 54, Message = "[Download] Mongo ダンプをダウンロード中..." });
            await apiClient.DownloadAsync(jobId, "mongo_dump", mongoZipPath, ct);
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 76, Message = "[Download] Mongo ダンプ完了" });

            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 77, Message = "[Download] FNSi ファイルをダウンロード中..." });
            await apiClient.DownloadAsync(jobId, "files", filesZipPath, ct);
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 100, Message = "[クラウド Export] 完了 — ネットワークを LAN に切り替えてからオンプレImportを実行してください" });
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// [LAN モード / on2off] オンプレ側インポート
        /// Step 5: PG リストア     pgProgress  0% ～  55%
        /// Step 6: Mongo インポート pgProgress 55% ～  85%
        /// Step 7: ファイル展開    pgProgress 85% ～ 100%
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task RunImportOnpreAsync(
            List<FacilityInfo>      facilities,
            AppSettings             settings,
            IProgress<ProgressInfo> pgProgress,
            IProgress<ProgressInfo> mongoProgress)
        {
            _cts = new CancellationTokenSource();
            var ct = _cts.Token;

            var facilityCds = facilities.Select(f => f.FacilityCd).ToList();
            var pgLogic     = new PostgreSqlLogic(settings);
            var mongoLogic  = new MongoDbLogic(settings);

            string downloadDir  = Path.Combine(settings.OnpreTempFolder, "downloads");
            string pgZipPath    = Path.Combine(downloadDir, "pg_dump.zip");
            string mongoZipPath = Path.Combine(downloadDir, "mongo_dump.zip");
            string filesZipPath = Path.Combine(downloadDir, "files.zip");

            // Step 5: PG リストア (0-55%)
            await pgLogic.RestoreAsync(pgZipPath, facilityCds, NormalizeProgress(pgProgress, 0, 55), ct);

            // Step 6: Mongo インポート (55-85%)
            await mongoLogic.ImportFromZipAsync(mongoZipPath, NormalizeProgress(pgProgress, 55, 30), ct);

            // Step 7: ファイル展開 (85-100%)
            ct.ThrowIfCancellationRequested();
            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 86, Message = "[Import] FNSi ファイルを展開中..." });
            if (!string.IsNullOrEmpty(settings.OnpreFnsiRootFolder))
            {
                await Task.Run(() =>
                {
                    ct.ThrowIfCancellationRequested();
                    ZipArchiver.ExtractToDirectory(filesZipPath, settings.OnpreFnsiRootFolder, AppConfigLoader.ZipPassword);
                }, ct);
            }

            pgProgress.Report(new ProgressInfo { DbKind = DbKind.PostgreSql, Percentage = 100, Message = "[オンプレ Import] データ導入完了" });
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 実行中の処理をキャンセルする
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public void Cancel()
        {
            if (_cts != null)
                _cts.Cancel();

            long jobId = CurrentJobId();
            if (jobId > 0)
                RequestServerInterrupt(jobId);
        }

        private void SetCurrentJobId(long jobId)
        {
            lock (_jobStateLock)
            {
                _currentJobId = jobId;
            }
        }

        private void ClearCurrentJobId(long jobId)
        {
            lock (_jobStateLock)
            {
                if (_currentJobId == jobId)
                    _currentJobId = 0;
            }
        }

        private long CurrentJobId()
        {
            lock (_jobStateLock)
            {
                return _currentJobId;
            }
        }

        private void RequestServerInterrupt(long jobId)
        {
            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("[Cancel] サーバー JOB 中断要求を送信します: JobId={0}", jobId));

            Task.Run(async () =>
            {
                try
                {
                    var apiClient = new ConverterApiClient(AppConfigLoader.ConverterBaseUri);
                    await apiClient.InterruptJobAsync(jobId, "client cancel", CancellationToken.None);
                }
                catch (Exception ex)
                {
                    _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient",
                        AppLogger.LOGGING_CLASS.WARNING,
                        string.Format("[Cancel] サーバー JOB 中断要求に失敗: JobId={0}, error={1}", jobId, ex.Message));
                }
            });
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 進捗コールバックのパーセンテージを正規化するラッパーを返す
        /// </summary>
        /// <param name="inner">出力先 IProgress</param>
        /// <param name="basePercent">全体における開始 %（0-100）</param>
        /// <param name="rangePercent">このステップに割り当てる幅（%）</param>
        //----------------------------------------------------------------------------------------------------
        private static IProgress<ProgressInfo> NormalizeProgress(
            IProgress<ProgressInfo> inner, int basePercent, int rangePercent)
        {
            return new Progress<ProgressInfo>(info =>
            {
                if (info.Percentage >= 0)
                {
                    var normalized = new ProgressInfo
                    {
                        DbKind        = info.DbKind,
                        Percentage    = basePercent + (int)(info.Percentage * rangePercent / 100.0),
                        Message       = info.Message,
                        IsError       = info.IsError,
                        IsPreformattedLogLine = info.IsPreformattedLogLine,
                        IsCountUpdate = info.IsCountUpdate,
                        CountKey      = info.CountKey,
                        CountTotal    = info.CountTotal,
                        CountDone     = info.CountDone,
                        CountText     = info.CountText,
                    };
                    inner.Report(normalized);
                }
                else
                {
                    inner.Report(info);
                }
            });
        }

        private static Dictionary<string, long> AcquireManualSeqStartMap(
            SeqReserveScriptArtifacts artifacts,
            PostgreSqlLogic           pgLogic,
            IProgress<ProgressInfo>   progress,
            CancellationToken         ct)
        {
            if (artifacts == null)
                throw new ArgumentNullException("artifacts");
            if (pgLogic == null)
                throw new ArgumentNullException("pgLogic");

            ct.ThrowIfCancellationRequested();

            progress.Report(new ProgressInfo
            {
                DbKind  = DbKind.PostgreSql,
                Message = string.Format(
                    "[SeqReserve] run_reserve_seq.cmd を実行して結果 JSON を作成してください: {0}",
                    artifacts.CommandPath)
            });

            DialogResult dialogResult = MessageBox.Show(
                string.Format(
                    "オンプレ DB の sequence 事前確保スクリプトを生成しました。\n\n" +
                    "1. 次のファイルを実行してください。\n{0}\n\n" +
                    "2. 実行後、次の JSON が自動生成されます。\n{1}\n\n" +
                    "準備ができたら [OK] を押してください。\n" +
                    "中止する場合は [キャンセル] を押してください。",
                    artifacts.CommandPath,
                    artifacts.ResultJsonPath),
                "sequence 事前確保",
                MessageBoxButtons.OKCancel,
                MessageBoxIcon.Information);

            if (dialogResult != DialogResult.OK)
                throw new OperationCanceledException("sequence 事前確保がキャンセルされました");

            ct.ThrowIfCancellationRequested();

            string resultJsonPath = ResolveSeqReserveResultPath(artifacts.ResultJsonPath);
            Dictionary<string, long> seqStartMap = pgLogic.LoadManualSeqStartMap(artifacts.Plan, resultJsonPath);

            progress.Report(new ProgressInfo
            {
                DbKind     = DbKind.PostgreSql,
                Percentage = 100,
                Message    = string.Format("[SeqReserve] 結果 JSON 読込完了: {0}", resultJsonPath)
            });

            return seqStartMap;
        }

        private static string ResolveSeqReserveResultPath(string expectedPath)
        {
            if (!string.IsNullOrWhiteSpace(expectedPath) && File.Exists(expectedPath))
                return expectedPath;

            MessageBox.Show(
                "想定の sequence 結果 JSON が見つかりませんでした。生成された JSON ファイルを選択してください。",
                "sequence 事前確保",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning);

            using (var dialog = new OpenFileDialog())
            {
                dialog.Title = "sequence 事前確保結果 JSON を選択";
                dialog.Filter = "JSON ファイル (*.json)|*.json|すべてのファイル (*.*)|*.*";
                dialog.CheckFileExists = true;
                dialog.CheckPathExists = true;

                if (!string.IsNullOrWhiteSpace(expectedPath))
                {
                    string initialDirectory = Path.GetDirectoryName(expectedPath);
                    if (!string.IsNullOrWhiteSpace(initialDirectory) && Directory.Exists(initialDirectory))
                        dialog.InitialDirectory = initialDirectory;

                    dialog.FileName = Path.GetFileName(expectedPath);
                }

                if (dialog.ShowDialog() != DialogResult.OK)
                    throw new OperationCanceledException("sequence 事前確保結果 JSON の選択がキャンセルされました");

                return dialog.FileName;
            }
        }
    }
}
