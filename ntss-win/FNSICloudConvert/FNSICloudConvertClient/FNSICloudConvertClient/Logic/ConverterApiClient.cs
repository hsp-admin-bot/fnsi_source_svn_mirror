using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using FNSICloudConvertClient.Models;
using Newtonsoft.Json.Linq;

namespace FNSICloudConvertClient.Logic
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// FNSi Cloud Converter REST API クライアント
    ///
    /// エンドポイント:
    ///   POST /auth/login                  — JWT 認証
    ///   POST /api/v1/upload               — ダンプファイルのアップロード
    ///   POST /api/v1/jobs                 — 移行 JOB の起動
    ///   GET  /api/v1/jobs/{jobId}         — JOB 状態ポーリング
    ///   GET  /api/v1/jobs/{jobId}/logs    — 実行ログ取得（オフセットポーリング）
    ///   POST /ntss-admin-web/api/log/uploader/{appName} — ログファイルアップロード
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    internal class ConverterApiClient
    {
        private const string API_BASE        = "/api/v1";
        private const int    POLL_INTERVAL_MS = 1000;
        private const int    MAX_LOG_UPLOAD_MB_SIZE = 8;
        private const string LEGACY_LOG_UPLOADER_NAME = "NKKLogUploader";
        private static readonly Regex ServerLogTimeRegex =
            new Regex(@"^(?:\d{4}-\d{2}-\d{2}\s+)?(?<time>\d{2}:\d{2}:\d{2})(?:\.\d{3})?",
                RegexOptions.Compiled);
        private static readonly Regex BracketTokenRegex =
            new Regex(@"\[(?<token>[A-Z0-9_]+)\]", RegexOptions.Compiled);
        private static readonly Regex TaskUnitProgressRegex =
            new Regex(@"^(?<unitType>.+?)(?:開始|完了|スキップ)\s+\((?<current>\d+)/(?<total>\d+)\):",
                RegexOptions.Compiled);

        private readonly string    _baseUrl;
        private readonly AppLogger _log;
        private readonly Dictionary<string, Dictionary<string, TaskUnitProgress>> _taskUnitProgressMap =
            new Dictionary<string, Dictionary<string, TaskUnitProgress>>(StringComparer.OrdinalIgnoreCase);
        private static readonly SemaphoreSlim _reloginLock = new SemaphoreSlim(1, 1);

        // HttpClient はアプリ起動中は共有して使い回す（大ファイル転送のため長いタイムアウト）
        private static readonly HttpClient _http = new HttpClient
        {
            Timeout = TimeSpan.FromHours(2)
        };

        public ConverterApiClient(string baseUrl)
        {
            _baseUrl = baseUrl.TrimEnd('/');
            _log     = AppLogger.GetInstance();
        }

        // ------------------------------------------------------------------
        // 認証ヘルパー: JWT トークンを Authorization ヘッダーに付与する
        // ------------------------------------------------------------------

        private HttpRequestMessage CreateRequest(HttpMethod method, string url)
        {
            var req = new HttpRequestMessage(method, url);
            AppConfigLoader.ApplyConverterRequestHeaders(req.Headers);
            string token = AppState.Instance.ConverterJwtToken;
            if (!string.IsNullOrEmpty(token))
                req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            return req;
        }

        private async Task<HttpResponseMessage> SendAuthorizedAsync(
            Func<HttpRequestMessage> requestFactory,
            CancellationToken ct,
            bool allowRetryOnUnauthorized = true)
        {
            HttpResponseMessage response = await SendOnceAsync(requestFactory, ct);

            if (allowRetryOnUnauthorized && IsUnauthorized(response))
            {
                response.Dispose();

                bool reloginSucceeded = await TryReloginAsync(ct);
                if (!reloginSucceeded)
                {
                    var failedRetryResponse = new HttpResponseMessage(HttpStatusCode.Unauthorized);
                    failedRetryResponse.Content = new StringContent(
                        "{\"message\":\"Converter 再認証に失敗しました\"}",
                        Encoding.UTF8,
                        "application/json");
                    return failedRetryResponse;
                }

                response = await SendOnceAsync(requestFactory, ct);
            }

            return response;
        }

        private async Task<HttpResponseMessage> SendOnceAsync(
            Func<HttpRequestMessage> requestFactory,
            CancellationToken ct)
        {
            using (var req = requestFactory())
            {
                HttpResponseMessage response = await _http.SendAsync(req, ct);
                UpdateTokenFromResponse(response);
                return response;
            }
        }

        private static bool IsUnauthorized(HttpResponseMessage response)
        {
            return response.StatusCode == HttpStatusCode.Unauthorized
                || response.StatusCode == HttpStatusCode.Forbidden;
        }

        private static void UpdateTokenFromResponse(HttpResponseMessage response)
        {
            if (response.Headers.TryGetValues("X-Renewed-Token", out IEnumerable<string> values))
            {
                foreach (string token in values)
                {
                    if (!string.IsNullOrWhiteSpace(token))
                    {
                        AppState.Instance.ConverterJwtToken = token.Trim();
                        AppState.Instance.IsConverterAuthenticated = true;
                        return;
                    }
                }
            }
        }

        private async Task<bool> TryReloginAsync(CancellationToken ct)
        {
            var state = AppState.Instance;

            await _reloginLock.WaitAsync(ct);
            try
            {
                if (!string.IsNullOrWhiteSpace(state.ConverterRefreshToken))
                {
                    string refreshedToken = await RefreshAccessTokenAsync(state.ConverterRefreshToken, ct);
                    if (!string.IsNullOrWhiteSpace(refreshedToken))
                    {
                        state.ConverterJwtToken = refreshedToken;
                        state.IsConverterAuthenticated = true;
                        return true;
                    }
                }

                string facilityCd;
                string dispUserId;
                string password;
                string credentialSource;
                if (!TryResolveConverterCredentials(out facilityCd, out dispUserId, out password, out credentialSource))
                {
                    state.IsConverterAuthenticated = false;
                    state.ConverterJwtToken = string.Empty;
                    _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.WARNING,
                        string.Format("Converter 再認証スキップ: 資格情報不足 ({0})", credentialSource));
                    return false;
                }

                string token = await LoginAsync(
                    facilityCd,
                    dispUserId,
                    password,
                    ct);

                state.ConverterFacilityCd = facilityCd;
                state.ConverterDispUserId = dispUserId;
                state.ConverterPassword = password;
                state.ConverterJwtToken = token ?? string.Empty;
                state.IsConverterAuthenticated = !string.IsNullOrEmpty(token);
                return state.IsConverterAuthenticated;
            }
            finally
            {
                _reloginLock.Release();
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// POST /auth/login — コンバーターサーバーへ JWT 認証を行う
        /// </summary>
        /// <returns>アクセストークン文字列。失敗時は null。</returns>
        //----------------------------------------------------------------------------------------------------
        public async Task<string> LoginAsync(string facilityCd, string dispUserId, string password,
            CancellationToken ct = default, bool detachedLog = false)
        {
            string url = _baseUrl + "/auth/login";

            var sb = new StringBuilder();
            sb.Append('{');
            sb.AppendFormat("\"facilityCd\":\"{0}\",",  Esc(facilityCd));
            sb.AppendFormat("\"dispUserId\":\"{0}\",",  Esc(dispUserId));
            sb.AppendFormat("\"password\":\"{0}\"",     Esc(password));
            sb.Append('}');

            var content = new StringContent(sb.ToString(), Encoding.UTF8, "application/json");

            WriteConverterAuthLog(AppLogger.LOGGING_CLASS.INFO,
                string.Format("Converter 認証開始: {0}", url), detachedLog);

            try
            {
                HttpResponseMessage resp;
                using (var req = CreateRequest(HttpMethod.Post, url))
                {
                    req.Content = content;
                    resp = await _http.SendAsync(req, ct);
                }
                string body = await resp.Content.ReadAsStringAsync();

                if (!resp.IsSuccessStatusCode)
                {
                    WriteConverterAuthLog(AppLogger.LOGGING_CLASS.WARNING,
                        string.Format("Converter 認証失敗 [{0}]: {1}", (int)resp.StatusCode, body), detachedLog);
                    return null;
                }

                var dto = Deserialize<ConverterLoginDto>(body);
                if (string.IsNullOrEmpty(dto?.AccessToken))
                {
                    WriteConverterAuthLog(AppLogger.LOGGING_CLASS.WARNING,
                        "Converter 認証: accessToken が取得できませんでした", detachedLog);
                    return null;
                }

                AppState.Instance.ConverterRefreshToken = dto.RefreshToken ?? string.Empty;
                WriteConverterAuthLog(AppLogger.LOGGING_CLASS.INFO,
                    "Converter 認証成功", detachedLog);
                return dto.AccessToken;
            }
            catch (Exception ex)
            {
                WriteConverterAuthLog(AppLogger.LOGGING_CLASS.WARNING,
                    string.Format("Converter 認証例外: {0}", ex.Message), detachedLog);
                return null;
            }
        }

        private async Task<string> RefreshAccessTokenAsync(string refreshToken, CancellationToken ct)
        {
            if (string.IsNullOrWhiteSpace(refreshToken))
                return null;

            string url = _baseUrl + "/auth/refresh";

            var sb = new StringBuilder();
            sb.Append('{');
            sb.AppendFormat("\"refreshToken\":\"{0}\"", Esc(refreshToken));
            sb.Append('}');

            var content = new StringContent(sb.ToString(), Encoding.UTF8, "application/json");
            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("Converter トークン更新開始: {0}", url));

            try
            {
                HttpResponseMessage resp;
                using (var req = CreateRequest(HttpMethod.Post, url))
                {
                    req.Content = content;
                    resp = await _http.SendAsync(req, ct);
                }
                string body = await resp.Content.ReadAsStringAsync();

                if (!resp.IsSuccessStatusCode)
                {
                    _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.WARNING,
                        string.Format("Converter トークン更新失敗 [{0}]: {1}", (int)resp.StatusCode, body));
                    return null;
                }

                var dto = Deserialize<ConverterRefreshDto>(body);
                if (string.IsNullOrWhiteSpace(dto?.AccessToken))
                {
                    _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.WARNING,
                        "Converter トークン更新: accessToken が取得できませんでした");
                    return null;
                }

                _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                    "Converter トークン更新成功");
                return dto.AccessToken;
            }
            catch (Exception ex)
            {
                _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.WARNING,
                    string.Format("Converter トークン更新例外: {0}", ex.Message));
                return null;
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// POST /api/v1/upload — ZIP ファイルをマルチパートでアップロードする
        /// </summary>
        /// <param name="zipFilePath">アップロードする ZIP ファイルパス</param>
        /// <param name="uploadType">種別: "PG_DUMP" / "MONGO_DUMP" / "FILES"</param>
        /// <param name="facilityCodes">施設コード（カンマ区切り）</param>
        /// <returns>サーバーから返された uploadId</returns>
        //----------------------------------------------------------------------------------------------------
        public async Task<string> UploadAsync(
            string            zipFilePath,
            string            uploadType,
            string            facilityCodes,
            CancellationToken ct)
        {
            string url = _baseUrl + API_BASE + "/upload";

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("Upload 開始: {0} ({1}) → {2}",
                    Path.GetFileName(zipFilePath), uploadType, url));

            Func<HttpRequestMessage> requestFactory = () =>
            {
                var requestContent = new MultipartFormDataContent();
                requestContent.Add(new StringContent(uploadType), "uploadType");
                requestContent.Add(new StringContent(facilityCodes), "facilityCode");

                var retryFileStream = File.OpenRead(zipFilePath);
                var retryFileContent = new StreamContent(retryFileStream);
                retryFileContent.Headers.ContentType = new MediaTypeHeaderValue("application/zip");
                requestContent.Add(retryFileContent, "file", Path.GetFileName(zipFilePath));

                var req = CreateRequest(HttpMethod.Post, url);
                req.Content = requestContent;
                return req;
            };

            var resp = await SendAuthorizedAsync(requestFactory, ct);
            string body = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
                throw new InvalidOperationException(
                    string.Format("Upload 失敗 [{0}] {1}: {2}",
                        (int)resp.StatusCode, uploadType, body));

            var dto = Deserialize<UploadResponseDto>(body);
            if (string.IsNullOrEmpty(dto?.UploadId))
                throw new InvalidOperationException(
                    string.Format("uploadId が取得できませんでした ({0})", uploadType));

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("Upload 完了: {0} → {1}", uploadType, dto.UploadId));

            return dto.UploadId;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// POST /api/v1/jobs — 移行 JOB を起動する
        /// </summary>
        /// <param name="direction">"off2on" または "on2off"</param>
        /// <param name="facilityCodes">対象施設コードリスト</param>
        /// <param name="uploadIds">アップロード ID マップ (pgDump / mongoDump / files)</param>
        /// <returns>サーバーから返された jobId</returns>
        //----------------------------------------------------------------------------------------------------
        public async Task<long> StartJobAsync(
            string                     direction,
            List<string>               facilityCodes,
            Dictionary<string, string> uploadIds,
            CancellationToken          ct)
        {
            string url = _baseUrl + API_BASE + "/jobs";

            var sb = new StringBuilder();
            sb.Append('{');
            sb.AppendFormat("\"direction\":\"{0}\",", Esc(direction));
            sb.Append("\"facilityCodes\":[");
            for (int i = 0; i < facilityCodes.Count; i++)
            {
                if (i > 0) sb.Append(',');
                sb.AppendFormat("\"{0}\"", Esc(facilityCodes[i]));
            }
            sb.Append("],");
            sb.Append("\"uploadIds\":{");
            sb.AppendFormat("\"pgDump\":\"{0}\",",    Esc(GetOrEmpty(uploadIds, "pgDump")));
            sb.AppendFormat("\"mongoDump\":\"{0}\",", Esc(GetOrEmpty(uploadIds, "mongoDump")));
            sb.AppendFormat("\"files\":\"{0}\"",      Esc(GetOrEmpty(uploadIds, "files")));
            sb.Append('}');
            sb.Append('}');

            var requestBody = sb.ToString();
            var resp = await SendAuthorizedAsync(() =>
            {
                var req = CreateRequest(HttpMethod.Post, url);
                req.Content = new StringContent(requestBody, Encoding.UTF8, "application/json");
                return req;
            }, ct);
            string body = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
                throw new InvalidOperationException(
                    string.Format("JOB 起動失敗 [{0}]: {1}", (int)resp.StatusCode, body));

            var dto = Deserialize<JobCreatedDto>(body);
            if (dto == null || dto.JobId == 0)
                throw new InvalidOperationException("jobId が取得できませんでした");

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("JOB 起動完了: JobId={0}", dto.JobId));

            return dto.JobId;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GET /api/v1/facilities/count — on2off 用のクラウド側テーブル件数を取得する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task<Dictionary<string, long>> GetFacilityCountsAsync(
            List<string>      facilityCodes,
            CancellationToken ct)
        {
            if (facilityCodes == null || facilityCodes.Count == 0)
                throw new ArgumentException("facilityCodes が空です", "facilityCodes");

            string facilityParam = Uri.EscapeDataString(string.Join(",", facilityCodes));
            string url = _baseUrl + API_BASE + "/facilities/count?facility_cd=" + facilityParam;

            var resp = await SendAuthorizedAsync(() => CreateRequest(HttpMethod.Get, url), ct);
            string body = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
                throw new InvalidOperationException(
                    string.Format("施設テーブル件数取得失敗 [{0}]: {1}", (int)resp.StatusCode, body));

            try
            {
                var result = new Dictionary<string, long>(StringComparer.Ordinal);
                var root = JObject.Parse(body);
                var tableCounts = root["tableCounts"] as JObject;
                if (tableCounts == null)
                    return result;

                foreach (var prop in tableCounts.Properties())
                    result[prop.Name] = prop.Value.Value<long>();

                return result;
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException(
                    string.Format("施設テーブル件数レスポンス解析失敗: {0}", ex.Message), ex);
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GET /api/v1/facilities/seq-plan — on2off 用の sequence 事前予約プランを取得する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task<ConverterSeqReservePlan> GetSeqReservePlanAsync(
            List<string>      facilityCodes,
            CancellationToken ct)
        {
            if (facilityCodes == null || facilityCodes.Count == 0)
                throw new ArgumentException("facilityCodes が空です", "facilityCodes");

            string facilityParam = Uri.EscapeDataString(string.Join(",", facilityCodes));
            string url = _baseUrl + API_BASE + "/facilities/seq-plan?facility_cd=" + facilityParam;

            var resp = await SendAuthorizedAsync(() => CreateRequest(HttpMethod.Get, url), ct);
            string body = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
                throw new InvalidOperationException(
                    string.Format("sequence 予約プラン取得失敗 [{0}]: {1}", (int)resp.StatusCode, body));

            try
            {
                var root = JObject.Parse(body);
                var result = new ConverterSeqReservePlan
                {
                    TotalReserveCount = root["totalReserveCount"] != null
                        ? root["totalReserveCount"].Value<long>()
                        : 0L,
                    CalculatedAt = root["calculatedAt"] != null
                        ? root["calculatedAt"].Value<string>() ?? string.Empty
                        : string.Empty
                };

                var facilityArray = root["facilityCodes"] as JArray;
                if (facilityArray != null)
                {
                    foreach (var facilityToken in facilityArray)
                        result.FacilityCodes.Add(facilityToken.Value<string>() ?? string.Empty);
                }

                var tablePlans = root["tablePlans"] as JArray;
                if (tablePlans != null)
                {
                    foreach (JToken rawToken in tablePlans)
                    {
                        var token = rawToken as JObject;
                        if (token == null)
                            continue;

                        result.TablePlans.Add(new ConverterSeqReservePlanItem
                        {
                            TableName = token["tableName"] != null ? token["tableName"].Value<string>() ?? string.Empty : string.Empty,
                            DbName = token["dbName"] != null ? token["dbName"].Value<string>() ?? string.Empty : string.Empty,
                            IdColumn = token["idColumn"] != null ? token["idColumn"].Value<string>() ?? string.Empty : string.Empty,
                            SeqName = token["seqName"] != null ? token["seqName"].Value<string>() ?? string.Empty : string.Empty,
                            ReserveCount = token["reserveCount"] != null ? token["reserveCount"].Value<long>() : 0L
                        });
                    }
                }

                return result;
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException(
                    string.Format("sequence 予約プランレスポンス解析失敗: {0}", ex.Message), ex);
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// POST /api/v1/jobs — on2off 移行 JOB を起動する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task<long> StartJobOnToOffAsync(
            List<string>             facilityCodes,
            Dictionary<string, long> seqStartMap,
            CancellationToken        ct)
        {
            string url = _baseUrl + API_BASE + "/jobs";

            var sb = new StringBuilder();
            sb.Append('{');
            sb.Append("\"direction\":\"on2off\",");
            sb.Append("\"facilityCodes\":[");
            for (int i = 0; i < facilityCodes.Count; i++)
            {
                if (i > 0) sb.Append(',');
                sb.AppendFormat("\"{0}\"", Esc(facilityCodes[i]));
            }
            sb.Append("],");
            sb.Append("\"seqStartMap\":{");
            bool first = true;
            foreach (var kv in seqStartMap)
            {
                if (!first) sb.Append(',');
                first = false;
                sb.AppendFormat("\"{0}\":{1}", Esc(kv.Key), kv.Value);
            }
            sb.Append('}');
            sb.Append('}');

            var requestBody = sb.ToString();
            var resp = await SendAuthorizedAsync(() =>
            {
                var req = CreateRequest(HttpMethod.Post, url);
                req.Content = new StringContent(requestBody, Encoding.UTF8, "application/json");
                return req;
            }, ct);
            string body = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
                throw new InvalidOperationException(
                    string.Format("on2off JOB 起動失敗 [{0}]: {1}", (int)resp.StatusCode, body));

            var dto = Deserialize<JobCreatedDto>(body);
            if (dto == null || dto.JobId == 0)
                throw new InvalidOperationException("jobId が取得できませんでした");

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("on2off JOB 起動完了: JobId={0}", dto.JobId));

            return dto.JobId;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GET /api/v1/download/{jobId}/{fileType} — サーバーから ZIP をダウンロードする（on2off 用）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task DownloadAsync(
            long              jobId,
            string            fileType,
            string            destPath,
            CancellationToken ct)
        {
            string url = string.Format("{0}{1}/download/{2}/{3}", _baseUrl, API_BASE, jobId, fileType);

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("Download 開始: {0} → {1}", fileType, destPath));

            var resp = await SendAuthorizedAsync(() => CreateRequest(HttpMethod.Get, url), ct);

            if (!resp.IsSuccessStatusCode)
            {
                string err = await resp.Content.ReadAsStringAsync();
                throw new InvalidOperationException(
                    string.Format("Download 失敗 [{0}] {1}: {2}",
                        (int)resp.StatusCode, fileType, err));
            }

            using (var fs = File.Create(destPath))
                await resp.Content.CopyToAsync(fs);

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("Download 完了: {0} ({1} bytes)",
                    fileType, new FileInfo(destPath).Length));
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// JOB が DONE または FAILED になるまで 1 秒間隔でポーリングする
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task PollUntilDoneAsync(
            long                    jobId,
            IProgress<ProgressInfo> pgProgress,
            IProgress<ProgressInfo> mongoProgress,
            CancellationToken       ct)
        {
            long logOffset = 0;
            string lastTaskCountText = null;
            int lastTaskTotal = -1;
            int lastTaskDone = -1;
            _taskUnitProgressMap.Clear();

            while (true)
            {
                ct.ThrowIfCancellationRequested();

                // ---- JOB 状態取得 ----
                string statusUrl = string.Format("{0}{1}/jobs/{2}", _baseUrl, API_BASE, jobId);
                var statusResp   = await SendAuthorizedAsync(() => CreateRequest(HttpMethod.Get, statusUrl), ct);
                string statusBody = await statusResp.Content.ReadAsStringAsync();

                if (!statusResp.IsSuccessStatusCode)
                    throw new InvalidOperationException(
                        string.Format("JOB 状態取得失敗 [{0}]: {1}",
                            (int)statusResp.StatusCode, statusBody));

                var job = Deserialize<JobStatusDto>(statusBody);
                if (job == null)
                    throw new InvalidOperationException("JOB ステータスの解析に失敗しました");

                int pct   = job.Progress?.PercentComplete ?? 0;
                int total = job.Progress?.TotalTasks      ?? 0;
                int done  = job.Progress?.DoneTasks       ?? 0;

                mongoProgress.Report(new ProgressInfo
                {
                    DbKind     = DbKind.MongoDb,
                    Percentage = pct
                });

                logOffset = await FetchAndReportJobLogsAsync(jobId, logOffset, mongoProgress, ct);

                string taskCountText = BuildCloudTaskCountText(job.Tasks);
                if (!string.IsNullOrWhiteSpace(taskCountText))
                {
                    if (!string.Equals(lastTaskCountText, taskCountText, StringComparison.Ordinal))
                    {
                        mongoProgress.Report(new ProgressInfo
                        {
                            DbKind        = DbKind.MongoDb,
                            IsCountUpdate = true,
                            CountKey      = "cloud_task_detail",
                            CountText     = taskCountText
                        });
                        lastTaskCountText = taskCountText;
                    }
                }
                else if ((lastTaskTotal != total || lastTaskDone != done)
                    && string.IsNullOrEmpty(lastTaskCountText))
                {
                    mongoProgress.Report(new ProgressInfo
                    {
                        DbKind        = DbKind.MongoDb,
                        IsCountUpdate = true,
                        CountKey      = "cloud_task",
                        CountTotal    = total,
                        CountDone     = done
                    });
                    lastTaskCountText = null;
                }
                lastTaskTotal = total;
                lastTaskDone = done;

                if (job.Status == "DONE")
                {
                    logOffset = await FlushPendingJobLogsAsync(jobId, logOffset, mongoProgress, ct);
                    lastTaskCountText = RefreshCloudTaskCountAfterLogFlush(job.Tasks, mongoProgress, lastTaskCountText);
                    break;
                }

                if (job.Status == "FAILED")
                {
                    logOffset = await FlushPendingJobLogsAsync(jobId, logOffset, mongoProgress, ct);
                    lastTaskCountText = RefreshCloudTaskCountAfterLogFlush(job.Tasks, mongoProgress, lastTaskCountText);
                    throw new InvalidOperationException(
                        string.Format("サーバー JOB が失敗しました: JobId={0}", jobId));
                }

                await Task.Delay(POLL_INTERVAL_MS, ct);
            }
        }

        private async Task<long> FetchAndReportJobLogsAsync(
            long jobId,
            long logOffset,
            IProgress<ProgressInfo> mongoProgress,
            CancellationToken ct)
        {
            string logsUrl = string.Format(
                "{0}{1}/jobs/{2}/logs?offset={3}&limit=100",
                _baseUrl, API_BASE, jobId, logOffset);
            var logsResp = await SendAuthorizedAsync(() => CreateRequest(HttpMethod.Get, logsUrl), ct);
            if (!logsResp.IsSuccessStatusCode)
                return logOffset;

            string logsBody = await logsResp.Content.ReadAsStringAsync();
            var logsDto = Deserialize<JobLogsDto>(logsBody);
            if (logsDto?.Logs == null)
                return logOffset;

            foreach (var entry in logsDto.Logs)
            {
                string rawLine = string.IsNullOrWhiteSpace(entry.FormattedMessage)
                    ? string.Format("[{0}] {1}", entry.Level, entry.Message)
                    : entry.FormattedMessage;
                UpdateTaskUnitProgress(entry, rawLine);
                string displayLine = BuildCompactServerLogLine(entry, rawLine);
                if (string.IsNullOrWhiteSpace(displayLine))
                    continue;

                mongoProgress.Report(new ProgressInfo
                {
                    DbKind = DbKind.MongoDb,
                    Message = displayLine,
                    RawMessage = rawLine,
                    IsError = entry.Level == "ERROR",
                    IsPreformattedLogLine = !string.IsNullOrWhiteSpace(entry.FormattedMessage)
                });
            }

            return logsDto.NextOffset > logOffset ? logsDto.NextOffset : logOffset;
        }

        private string RefreshCloudTaskCountAfterLogFlush(
            List<TaskStatusDto> tasks,
            IProgress<ProgressInfo> mongoProgress,
            string lastTaskCountText)
        {
            string taskCountText = BuildCloudTaskCountText(tasks);
            if (!string.IsNullOrWhiteSpace(taskCountText)
                && !string.Equals(lastTaskCountText, taskCountText, StringComparison.Ordinal))
            {
                mongoProgress.Report(new ProgressInfo
                {
                    DbKind        = DbKind.MongoDb,
                    IsCountUpdate = true,
                    CountKey      = "cloud_task_detail",
                    CountText     = taskCountText
                });
                return taskCountText;
            }

            return lastTaskCountText;
        }

        private async Task<long> FlushPendingJobLogsAsync(
            long jobId,
            long logOffset,
            IProgress<ProgressInfo> mongoProgress,
            CancellationToken ct)
        {
            const int settlePollMs = 250;
            const int maxRounds = 8;

            int stableRounds = 0;
            for (int round = 0; round < maxRounds; round++)
            {
                ct.ThrowIfCancellationRequested();

                long nextOffset = await FetchAndReportJobLogsAsync(jobId, logOffset, mongoProgress, ct);
                if (nextOffset > logOffset)
                {
                    logOffset = nextOffset;
                    stableRounds = 0;
                    continue;
                }

                stableRounds++;
                if (stableRounds >= 2)
                    break;

                await Task.Delay(settlePollMs, ct);
            }

            return logOffset;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// POST /ntss-admin-web/api/log/uploader/{appName} — ログファイルをアップロードする
        /// アプリ終了時にバックグラウンドで呼び出す。失敗しても例外を投げない。
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task UploadLogAsync(string appName)
        {
            try
            {
                string logFolder = AppLogger.GetInstance().LogFolder;
                if (string.IsNullOrEmpty(logFolder))
                    logFolder = Path.Combine(Application.StartupPath, "LOG");

                if (!Directory.Exists(logFolder))
                    return;

                WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.INFO, "ログアップロード処理開始");

                if (!await EnsureFreshLoginForLogUploadAsync())
                {
                    WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.WARNING,
                        "Converter 再認証失敗のためログアップロードをスキップ");
                    return;
                }

                List<string> zipFiles = CreateUploadZipFiles(logFolder, appName);
                string uploadedAppName = Path.GetFileNameWithoutExtension(appName);
                string facilityCd = ResolveFacilityCode();

                foreach (string zipFile in zipFiles)
                {
                    bool uploadSucceeded = false;
                    List<string> uploadFiles = new List<string> { zipFile };

                    try
                    {
                        long maxFileSize = (long)MAX_LOG_UPLOAD_MB_SIZE * 1024L * 1024L;
                        long fileLength = new FileInfo(zipFile).Length;
                        if (maxFileSize < fileLength)
                        {
                            uploadFiles = SplitFile(zipFile, maxFileSize);
                            WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.INFO,
                                string.Format("ログを分割:{0} → {1}分割({2}MB制限)",
                                    zipFile, uploadFiles.Count, MAX_LOG_UPLOAD_MB_SIZE));
                        }

                        string uploadedFileName = BuildUploadedFileName(Path.GetFileName(zipFile), facilityCd);
                        for (int i = 0; i < uploadFiles.Count; i++)
                        {
                            string uploadFile = uploadFiles[i];
                            int mode = DetermineLegacyUploadMode(uploadFiles.Count, i);

                            WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.INFO,
                                string.Format("ログアップロード開始:{0}/[{1}]/mode:{2}", uploadFile, i + 1, mode));

                            try
                            {
                                await UploadLegacyLogPartAsync(mode, uploadedAppName, uploadedFileName, uploadFile);
                                uploadSucceeded = true;
                                WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.INFO,
                                    string.Format("ログアップロード成功:{0}/[{1}]/mode:{2}", uploadFile, i + 1, mode));
                            }
                            catch (Exception ex)
                            {
                                uploadSucceeded = false;
                                WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.INFO,
                                    string.Format("ログアップロード失敗:{0}/[{1}]/mode:{2},error:{3}",
                                        uploadFile, i + 1, mode, ex.Message));
                                break;
                            }
                        }
                    }
                    finally
                    {
                        if (uploadFiles.Count > 1)
                        {
                            foreach (string splitFile in uploadFiles)
                                DeleteUploadWorkFile(splitFile);
                        }

                        if (uploadSucceeded)
                            DeleteUploadWorkFile(zipFile);
                    }
                }

                WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.INFO, "ログアップロード処理終了");
            }
            catch (Exception ex)
            {
                WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.ERROR,
                    string.Format("{0}.UploadLogAsync,error:{1}", LEGACY_LOG_UPLOADER_NAME, ex.ToString()));
            }
        }

        private List<string> CreateUploadZipFiles(string logFolder, string appName)
        {
            var zipFiles = new List<string>();
            string searchPattern = string.Format("{0}_*.log", appName);

            foreach (string logFile in Directory.GetFiles(logFolder, searchPattern, SearchOption.TopDirectoryOnly))
            {
                try
                {
                    string zipFile = Path.ChangeExtension(logFile, ".ZIP");
                    ZipArchiver.CreateFromFiles(new[] { logFile }, zipFile);
                    WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.INFO,
                        string.Format("ログ圧縮成功,{0} → {1}", logFile, zipFile));

                    if (File.GetLastWriteTime(logFile).Date < DateTime.Now.Date)
                    {
                        File.Delete(logFile);
                        WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.INFO,
                            string.Format("ログ削除,{0}", logFile));
                    }

                    zipFiles.Add(zipFile);
                }
                catch (Exception ex)
                {
                    WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.ERROR,
                        string.Format("{0}.CreateUploadZipFiles,file:{1},error:{2}",
                            LEGACY_LOG_UPLOADER_NAME, logFile, ex.ToString()));
                }
            }

            return zipFiles;
        }

        private static int DetermineLegacyUploadMode(int totalParts, int index)
        {
            if (totalParts <= 1)
                return 0;
            if (index == 0)
                return 1;
            if (index == totalParts - 1)
                return 3;
            return 2;
        }

        private static string BuildUploadedFileName(string fileName, string facilityCd)
        {
            if (string.IsNullOrWhiteSpace(facilityCd))
                return fileName;
            return fileName.IndexOf(facilityCd, StringComparison.OrdinalIgnoreCase) >= 0
                ? fileName
                : facilityCd + "_" + fileName;
        }

        private string ResolveFacilityCode()
        {
            if (!string.IsNullOrWhiteSpace(BusinessApiClient.FacilityCd))
                return BusinessApiClient.FacilityCd.Trim();
            if (!string.IsNullOrWhiteSpace(AppState.Instance.ConverterFacilityCd))
                return AppState.Instance.ConverterFacilityCd.Trim();
            return string.Empty;
        }

        private List<string> SplitFile(string sourceFile, long maxBytes)
        {
            var result = new List<string>();
            byte[] buffer = new byte[81920];
            int index = 0;

            using (var input = File.OpenRead(sourceFile))
            {
                while (input.Position < input.Length)
                {
                    index++;
                    string partFile = string.Format("{0}.part{1:D3}", sourceFile, index);
                    long remaining = maxBytes;

                    using (var output = new FileStream(partFile, FileMode.Create, FileAccess.Write, FileShare.None))
                    {
                        while (remaining > 0 && input.Position < input.Length)
                        {
                            int readSize = (int)Math.Min(buffer.Length, remaining);
                            int bytesRead = input.Read(buffer, 0, readSize);
                            if (bytesRead <= 0)
                                break;

                            output.Write(buffer, 0, bytesRead);
                            remaining -= bytesRead;
                        }
                    }

                    result.Add(partFile);
                }
            }

            return result;
        }

        private async Task UploadLegacyLogPartAsync(int mode, string appName, string uploadedFileName, string uploadFilePath)
        {
            string url = string.Format("{0}/ntss-admin-web/api/log/uploader/{1}?_={2}",
                _baseUrl,
                mode,
                DateTime.Now.Ticks);

            var resp = await SendAuthorizedAsync(() =>
            {
                var requestContent = new MultipartFormDataContent();
                requestContent.Add(new StringContent(appName, Encoding.UTF8), "appName");
                requestContent.Add(new StringContent(uploadedFileName, Encoding.UTF8), "fileName");

                var fileStream = File.OpenRead(uploadFilePath);
                var fileContent = new StreamContent(fileStream);
                fileContent.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
                requestContent.Add(fileContent, "upFile", Path.GetFileName(uploadFilePath));

                var req = CreateRequest(HttpMethod.Post, url);
                req.Content = requestContent;
                return req;
            }, CancellationToken.None, allowRetryOnUnauthorized: true);

            string body = await resp.Content.ReadAsStringAsync();
            if (!resp.IsSuccessStatusCode)
                throw new InvalidOperationException(
                    string.Format("ログアップロード失敗 [{0}]: {1}", (int)resp.StatusCode, body));
        }

        private void DeleteUploadWorkFile(string filePath)
        {
            try
            {
                if (File.Exists(filePath))
                {
                    File.Delete(filePath);
                    WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.INFO,
                        string.Format("ファイル削除:{0}", filePath));
                }
            }
            catch (Exception ex)
            {
                WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.ERROR,
                    string.Format("{0}.DeleteUploadWorkFile,file:{1},error:{2}",
                        LEGACY_LOG_UPLOADER_NAME, filePath, ex.ToString()));
            }
        }

        private void WriteLegacyUploadLog(AppLogger.LOGGING_CLASS cls, string message)
        {
            _log.AddDetachedLogInfo(DateTime.Now, LEGACY_LOG_UPLOADER_NAME, cls, message);
        }

        private async Task<bool> EnsureFreshLoginForLogUploadAsync()
        {
            var state = AppState.Instance;
            string facilityCd;
            string dispUserId;
            string password;
            string credentialSource;
            if (!TryResolveConverterCredentials(out facilityCd, out dispUserId, out password, out credentialSource))
            {
                bool hasExistingToken = !string.IsNullOrWhiteSpace(state.ConverterJwtToken);
                if (hasExistingToken)
                {
                    WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.WARNING,
                        string.Format("Converter 再認証情報不足 ({0}) のため既存トークンでログアップロードを継続", credentialSource));
                    return true;
                }

                state.IsConverterAuthenticated = false;
                state.ConverterJwtToken = string.Empty;
                WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.WARNING,
                    string.Format("Converter 再認証情報不足 ({0}) のためログアップロードをスキップ", credentialSource));
                return false;
            }

            string existingToken = state.ConverterJwtToken;
            WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.INFO,
                string.Format("Converter 再認証開始({0})", credentialSource));

            string token = await LoginAsync(
                facilityCd,
                dispUserId,
                password,
                CancellationToken.None,
                detachedLog: true);

            if (string.IsNullOrWhiteSpace(token))
            {
                if (!string.IsNullOrWhiteSpace(existingToken))
                {
                    state.IsConverterAuthenticated = true;
                    state.ConverterJwtToken = existingToken;
                    WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.WARNING,
                        "Converter 再認証失敗のため既存トークンでログアップロードを継続");
                    return true;
                }

                state.IsConverterAuthenticated = false;
                state.ConverterJwtToken = string.Empty;
                WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.WARNING, "Converter 再認証失敗");
                return false;
            }

            state.ConverterFacilityCd = facilityCd;
            state.ConverterDispUserId = dispUserId;
            state.ConverterPassword = password;
            state.ConverterJwtToken = token ?? string.Empty;
            state.IsConverterAuthenticated = !string.IsNullOrEmpty(token);
            WriteLegacyUploadLog(AppLogger.LOGGING_CLASS.INFO, "Converter 再認証成功");
            return state.IsConverterAuthenticated;
        }

        private bool TryResolveConverterCredentials(
            out string facilityCd,
            out string dispUserId,
            out string password,
            out string credentialSource)
        {
            var state = AppState.Instance;

            facilityCd = ChooseCredential(state.ConverterFacilityCd, BusinessApiClient.FacilityCd);
            dispUserId = ChooseCredential(state.ConverterDispUserId, BusinessApiClient.UserId);
            password = ChooseCredential(state.ConverterPassword, BusinessApiClient.Password);

            credentialSource = string.Format(
                "facility={0}, user={1}, password={2}",
                DescribeCredentialSource(state.ConverterFacilityCd, BusinessApiClient.FacilityCd),
                DescribeCredentialSource(state.ConverterDispUserId, BusinessApiClient.UserId),
                DescribeCredentialSource(state.ConverterPassword, BusinessApiClient.Password));

            return !string.IsNullOrWhiteSpace(facilityCd)
                && !string.IsNullOrWhiteSpace(dispUserId)
                && !string.IsNullOrWhiteSpace(password);
        }

        private static string ChooseCredential(string primaryValue, string fallbackValue)
        {
            if (!string.IsNullOrWhiteSpace(primaryValue))
                return primaryValue.Trim();
            if (!string.IsNullOrWhiteSpace(fallbackValue))
                return fallbackValue.Trim();
            return string.Empty;
        }

        private static string DescribeCredentialSource(string primaryValue, string fallbackValue)
        {
            if (!string.IsNullOrWhiteSpace(primaryValue))
                return "AppState";
            if (!string.IsNullOrWhiteSpace(fallbackValue))
                return "BusinessApiClient";
            return "missing";
        }

        private void WriteConverterAuthLog(AppLogger.LOGGING_CLASS cls, string message, bool detachedLog)
        {
            if (detachedLog)
            {
                _log.AddDetachedLogInfo(DateTime.Now, "FNSICloudConvertClient", cls, message);
                return;
            }

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", cls, message);
        }

        private string BuildCloudTaskCountText(List<TaskStatusDto> tasks)
        {
            if (tasks == null || tasks.Count == 0)
                return string.Empty;

            var lines = new List<string>(tasks.Count);
            for (int i = 0; i < tasks.Count; i++)
            {
                TaskStatusDto task = tasks[i];
                string countText = BuildTaskCountText(task);
                string taskName = task.TaskName ?? "---";
                string shortStatus = ToShortStatus(task.Status);
                if (string.Equals(shortStatus, "DONE", StringComparison.Ordinal))
                {
                    lines.Add(string.Format("{0,-22} {1}", taskName, countText));
                }
                else
                {
                    lines.Add(string.Format("{0,-22} {1} {2}", taskName, shortStatus, countText));
                }
            }

            return string.Join("\n", lines);
        }

        private string BuildTaskCountText(TaskStatusDto task)
        {
            long estimated = task.EstimatedRows ?? 0;
            long affected = task.AffectedRows ?? 0;
            Dictionary<string, TaskUnitProgress> scopeProgressMap;

            if (!string.IsNullOrWhiteSpace(task.TaskName)
                && _taskUnitProgressMap.TryGetValue(task.TaskName, out scopeProgressMap)
                && scopeProgressMap != null
                && scopeProgressMap.Count > 0)
            {
                long totalUnits = 0;
                long doneUnits = 0;
                foreach (TaskUnitProgress progress in scopeProgressMap.Values)
                {
                    if (progress == null || progress.TotalUnits <= 0)
                        continue;

                    totalUnits += progress.TotalUnits;
                    doneUnits += Math.Max(0, Math.Min(progress.CurrentUnit, progress.TotalUnits));
                }

                if (totalUnits > 0)
                {
                    if (string.Equals(task.Status, "DONE", StringComparison.OrdinalIgnoreCase))
                    {
                        long finalTotal = estimated > 0 ? estimated : totalUnits;
                        return string.Format("{0}/{0}", finalTotal);
                    }

                    doneUnits = Math.Max(0, Math.Min(doneUnits, totalUnits));
                    return string.Format("{0}/{1}", doneUnits, totalUnits);
                }
            }

            if (estimated > 0)
            {
                if (string.Equals(task.Status, "DONE", StringComparison.OrdinalIgnoreCase))
                    return string.Format("{0}/{0}", estimated);

                if (affected > 0)
                    return string.Format("{0}/{1}", Math.Min(affected, estimated), estimated);
            }

            if (affected > 0)
                return affected.ToString();

            return "---";
        }

        private static string ToShortStatus(string status)
        {
            if (string.IsNullOrWhiteSpace(status))
                return "---";

            string upper = status.ToUpperInvariant();
            switch (upper)
            {
                case "DONE":
                    return "DONE";
                case "RUNNING":
                    return "RUN ";
                case "FAILED":
                    return "FAIL";
                case "PENDING":
                    return "WAIT";
                default:
                    return upper.Length >= 4 ? upper.Substring(0, 4) : upper;
            }
        }

        private static string BuildCompactServerLogLine(LogEntryDto entry, string rawLine)
        {
            string source = string.IsNullOrWhiteSpace(rawLine)
                ? (entry != null ? entry.Message ?? string.Empty : string.Empty)
                : rawLine.Trim();
            if (string.IsNullOrWhiteSpace(source))
                return string.Empty;

            string timeText = ExtractServerLogTime(source);
            string taskName = !string.IsNullOrWhiteSpace(entry != null ? entry.TaskName : null)
                ? entry.TaskName.Trim()
                : ExtractTaskName(source);
            string messageText = ExtractServerLogMessage(entry, source, taskName);

            if (string.IsNullOrWhiteSpace(messageText))
                return string.Empty;

            if (!string.IsNullOrWhiteSpace(timeText) && !string.IsNullOrWhiteSpace(taskName))
                return string.Format("[{0}][{1}] {2}", timeText, taskName, messageText);
            if (!string.IsNullOrWhiteSpace(timeText))
                return string.Format("[{0}] {1}", timeText, messageText);
            if (!string.IsNullOrWhiteSpace(taskName))
                return string.Format("[{0}] {1}", taskName, messageText);
            return messageText;
        }

        private static string ExtractServerLogTime(string source)
        {
            if (string.IsNullOrWhiteSpace(source))
                return string.Empty;

            Match match = ServerLogTimeRegex.Match(source);
            return match.Success ? match.Groups["time"].Value : string.Empty;
        }

        private static string ExtractTaskName(string source)
        {
            if (string.IsNullOrWhiteSpace(source))
                return string.Empty;

            foreach (Match match in BracketTokenRegex.Matches(source))
            {
                string token = match.Groups["token"].Value;
                if (token.StartsWith("TASK", StringComparison.OrdinalIgnoreCase))
                    return token;
            }

            return string.Empty;
        }

        private static string ExtractServerLogMessage(LogEntryDto entry, string source, string taskName)
        {
            string message = null;
            int dashIndex = source.IndexOf(" - ", StringComparison.Ordinal);
            if (dashIndex >= 0)
            {
                message = dashIndex >= 0 ? source.Substring(dashIndex + 3) : source;
            }
            else if (entry != null && !string.IsNullOrWhiteSpace(entry.Message)
                && !string.Equals(entry.Message.Trim(), source, StringComparison.Ordinal))
            {
                message = entry.Message;
            }
            else
            {
                message = source;
            }

            message = message == null ? string.Empty : message.Trim();
            if (string.IsNullOrWhiteSpace(message))
                return string.Empty;

            if (!string.IsNullOrWhiteSpace(taskName))
            {
                string prefix = "[" + taskName + "]";
                if (message.StartsWith(prefix, StringComparison.Ordinal))
                    message = message.Substring(prefix.Length).TrimStart();
            }

            return message;
        }

        private void UpdateTaskUnitProgress(LogEntryDto entry, string rawLine)
        {
            string source = string.IsNullOrWhiteSpace(rawLine)
                ? (entry != null ? entry.Message ?? string.Empty : string.Empty)
                : rawLine.Trim();
            if (string.IsNullOrWhiteSpace(source))
                return;

            string taskName = !string.IsNullOrWhiteSpace(entry != null ? entry.TaskName : null)
                ? entry.TaskName.Trim()
                : ExtractTaskName(source);
            if (string.IsNullOrWhiteSpace(taskName))
                return;

            string messageText = ExtractServerLogMessage(entry, source, taskName);
            if (string.IsNullOrWhiteSpace(messageText))
                return;

            string progressText = messageText;
            string scopeName = string.Empty;
            if (progressText.StartsWith("[", StringComparison.Ordinal))
            {
                int closingIndex = progressText.IndexOf(']');
                if (closingIndex > 1)
                {
                    scopeName = progressText.Substring(1, closingIndex - 1).Trim();
                    progressText = progressText.Substring(closingIndex + 1).TrimStart();
                }
            }

            Match match = TaskUnitProgressRegex.Match(progressText);
            if (!match.Success)
                return;

            int current;
            int total;
            if (!int.TryParse(match.Groups["current"].Value, out current)
                || !int.TryParse(match.Groups["total"].Value, out total)
                || total <= 0)
            {
                return;
            }

            Dictionary<string, TaskUnitProgress> scopeProgressMap;
            if (!_taskUnitProgressMap.TryGetValue(taskName, out scopeProgressMap))
            {
                scopeProgressMap = new Dictionary<string, TaskUnitProgress>(StringComparer.OrdinalIgnoreCase);
                _taskUnitProgressMap[taskName] = scopeProgressMap;
            }

            string scopeKey = string.IsNullOrWhiteSpace(scopeName) ? "__default__" : scopeName;
            scopeProgressMap[scopeKey] = new TaskUnitProgress(current, total);
        }

        public async Task<ConverterSystemInfo> GetSystemInfoAsync(CancellationToken ct)
        {
            string url = _baseUrl + API_BASE + "/system/info";
            var resp = await SendAuthorizedAsync(() => CreateRequest(HttpMethod.Get, url), ct);
            string body = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
                throw new InvalidOperationException(
                    string.Format("システム情報取得失敗 [{0}]: {1}", (int)resp.StatusCode, body));

            var dto = Deserialize<ConverterSystemInfoDto>(body);
            if (dto == null || string.IsNullOrWhiteSpace(dto.ConverterDbHost) || dto.ConverterDbPort <= 0)
                throw new InvalidOperationException("convert_db 情報が取得できませんでした");

            return new ConverterSystemInfo(dto.ConverterDbHost, dto.ConverterDbPort);
        }

        public async Task<ConverterServerHealth> GetServerHealthAsync(CancellationToken ct)
        {
            string url = _baseUrl + "/actuator/health";

            try
            {
                using (var req = CreateRequest(HttpMethod.Get, url))
                {
                    var resp = await _http.SendAsync(req, ct);
                    string body = await resp.Content.ReadAsStringAsync();

                    string status = string.Empty;
                    try
                    {
                        var root = JObject.Parse(body);
                        status = root.Value<string>("status") ?? string.Empty;
                    }
                    catch
                    {
                        status = string.Empty;
                    }

                    return new ConverterServerHealth(true, string.IsNullOrWhiteSpace(status) ? "UNKNOWN" : status);
                }
            }
            catch
            {
                return new ConverterServerHealth(false, string.Empty);
            }
        }

        // ------------------------------------------------------------------
        // JSON ユーティリティ
        // ------------------------------------------------------------------

        private static T Deserialize<T>(string json) where T : class
        {
            if (string.IsNullOrWhiteSpace(json)) return null;
            try
            {
                var ser = new DataContractJsonSerializer(typeof(T));
                using (var ms = new MemoryStream(Encoding.UTF8.GetBytes(json)))
                    return (T)ser.ReadObject(ms);
            }
            catch
            {
                return null;
            }
        }

        private static string Esc(string s) =>
            (s ?? string.Empty).Replace("\\", "\\\\").Replace("\"", "\\\"");

        private static string GetOrEmpty(Dictionary<string, string> d, string key) =>
            (d != null && d.ContainsKey(key)) ? d[key] : string.Empty;

        // ------------------------------------------------------------------
        // レスポンス DTO（DataContractJsonSerializer 用）
        // ------------------------------------------------------------------

        [DataContract]
        private class ConverterLoginDto
        {
            [DataMember(Name = "accessToken")]
            public string AccessToken { get; set; }

            [DataMember(Name = "refreshToken")]
            public string RefreshToken { get; set; }

            [DataMember(Name = "expiresIn")]
            public int ExpiresIn { get; set; }

            [DataMember(Name = "tokenType")]
            public string TokenType { get; set; }
        }

        [DataContract]
        private class ConverterRefreshDto
        {
            [DataMember(Name = "accessToken")]
            public string AccessToken { get; set; }

            [DataMember(Name = "expiresIn")]
            public int ExpiresIn { get; set; }

            [DataMember(Name = "tokenType")]
            public string TokenType { get; set; }
        }

        [DataContract]
        private class UploadResponseDto
        {
            [DataMember(Name = "uploadId")]
            public string UploadId { get; set; }
        }

        [DataContract]
        private class ConverterSystemInfoDto
        {
            [DataMember(Name = "converterDbHost")]
            public string ConverterDbHost { get; set; }

            [DataMember(Name = "converterDbPort")]
            public int ConverterDbPort { get; set; }
        }

        [DataContract]
        private class JobCreatedDto
        {
            [DataMember(Name = "jobId")]
            public long JobId { get; set; }
        }

        [DataContract]
        private class JobStatusDto
        {
            [DataMember(Name = "jobId")]
            public long JobId { get; set; }

            [DataMember(Name = "status")]
            public string Status { get; set; }

            [DataMember(Name = "progress")]
            public JobProgressDto Progress { get; set; }

            [DataMember(Name = "tasks")]
            public List<TaskStatusDto> Tasks { get; set; }
        }

        [DataContract]
        private class JobProgressDto
        {
            [DataMember(Name = "totalTasks")]
            public int TotalTasks { get; set; }

            [DataMember(Name = "doneTasks")]
            public int DoneTasks { get; set; }

            [DataMember(Name = "percentComplete")]
            public int PercentComplete { get; set; }
        }

        [DataContract]
        private class TaskStatusDto
        {
            [DataMember(Name = "taskName")]
            public string TaskName { get; set; }

            [DataMember(Name = "status")]
            public string Status { get; set; }

            [DataMember(Name = "estimatedRows")]
            public long? EstimatedRows { get; set; }

            [DataMember(Name = "affectedRows")]
            public long? AffectedRows { get; set; }
        }

        [DataContract]
        private class JobLogsDto
        {
            [DataMember(Name = "logs")]
            public List<LogEntryDto> Logs { get; set; }

            [DataMember(Name = "nextOffset")]
            public long NextOffset { get; set; }
        }

        [DataContract]
        private class LogEntryDto
        {
            [DataMember(Name = "logId")]
            public long LogId { get; set; }

            [DataMember(Name = "taskId")]
            public long TaskId { get; set; }

            [DataMember(Name = "taskName")]
            public string TaskName { get; set; }

            [DataMember(Name = "level")]
            public string Level { get; set; }

            [DataMember(Name = "message")]
            public string Message { get; set; }

            [DataMember(Name = "formattedMessage")]
            public string FormattedMessage { get; set; }
        }

        private sealed class TaskUnitProgress
        {
            public TaskUnitProgress(int currentUnit, int totalUnits)
            {
                CurrentUnit = currentUnit;
                TotalUnits = totalUnits;
            }

            public int CurrentUnit { get; private set; }
            public int TotalUnits { get; private set; }
        }


    }

    internal sealed class ConverterSystemInfo
    {
        public ConverterSystemInfo(string converterDbHost, int converterDbPort)
        {
            ConverterDbHost = converterDbHost;
            ConverterDbPort = converterDbPort;
        }

        public string ConverterDbHost { get; private set; }
        public int ConverterDbPort { get; private set; }
    }

    internal sealed class ConverterServerHealth
    {
        public ConverterServerHealth(bool isReachable, string status)
        {
            IsReachable = isReachable;
            Status = status ?? string.Empty;
        }

        public bool IsReachable { get; private set; }
        public string Status { get; private set; }
    }

    internal sealed class ConverterSeqReservePlan
    {
        public ConverterSeqReservePlan()
        {
            FacilityCodes = new List<string>();
            TablePlans = new List<ConverterSeqReservePlanItem>();
            CalculatedAt = string.Empty;
        }

        public List<string> FacilityCodes { get; private set; }
        public List<ConverterSeqReservePlanItem> TablePlans { get; private set; }
        public long TotalReserveCount { get; set; }
        public string CalculatedAt { get; set; }
    }

    internal sealed class ConverterSeqReservePlanItem
    {
        public string TableName { get; set; }
        public string DbName { get; set; }
        public string IdColumn { get; set; }
        public string SeqName { get; set; }
        public long ReserveCount { get; set; }
    }
}
