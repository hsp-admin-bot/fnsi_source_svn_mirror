using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text;
using System.Threading;

namespace MockServer
{
    // -----------------------------------------------------------------------
    // MockServer: FNSICloudConvertClient 開発用モックサーバー
    //
    // 対応エンドポイント:
    //   POST /ntss-admin-web/api/login              ログイン（OTP対応）
    //   GET  /ntss-admin-web/api/user               ユーザー情報取得
    //   PUT  /ntss-admin-web/api/logging/mongo/info ログ送信（受け取るだけ）
    //   POST /ntss-admin-web/api/log/uploader/*     ログアップロード（受け取るだけ）
    //   GET  /ntss-admin-web/api/mstInfo/mstFacility 施設一覧
    //
    //   POST /api/v1/upload                              ZIPアップロード → uploadId 返却
    //   POST /api/v1/jobs                                移行JOB起動 → jobId 返却
    //   GET  /api/v1/jobs/{jobId}                        JOB状態ポーリング
    //   GET  /api/v1/jobs/{jobId}/logs                   実行ログ取得
    //   GET  /api/v1/facilities/count                    テーブル件数（on2off 用）
    //   GET  /api/v1/download/{jobId}/{fileType}         ZIPダウンロード（on2off 用）
    //
    // 設定: MockConfig.json（EXEと同ディレクトリ）
    //   user1/pass1 → OTP不要 → 直接ログイン完了
    //   user2/pass2 → OTP必要 → "111111"で通過、他は失敗
    // -----------------------------------------------------------------------
    class Program
    {
        private const string BASE_URL = "http://localhost:8080/";

        // ログイン成功後のセッションを保持（UserId → UserConfig）
        private static readonly Dictionary<string, UserConfig> _sessions
            = new Dictionary<string, UserConfig>(StringComparer.OrdinalIgnoreCase);

        // OTP待ちセッション（UserId → UserConfig）
        private static readonly Dictionary<string, UserConfig> _otpPending
            = new Dictionary<string, UserConfig>(StringComparer.OrdinalIgnoreCase);

        // Converter JOB 管理
        private static readonly Dictionary<long, MockJob> _jobs = new Dictionary<long, MockJob>();
        private static long _nextJobId = 1;

        private static MockConfigRoot _config;
        private static readonly object _lock = new object();

        static void Main(string[] args)
        {
            _config = LoadConfig();
            if (_config == null)
            {
                Console.WriteLine("[ERROR] MockConfig.json の読み込みに失敗しました。");
                Console.ReadKey();
                return;
            }

            Console.WriteLine("==============================================");
            Console.WriteLine("  FNSICloudConvertClient 開発用モックサーバー");
            Console.WriteLine("  URL: " + BASE_URL);
            Console.WriteLine("==============================================");
            Console.WriteLine("登録ユーザー:");
            foreach (var u in _config.Users)
            {
                string otpInfo = u.RequireOtp ? string.Format("OTP必要 (正解: {0})", u.OtpCode) : "OTP不要";
                Console.WriteLine(string.Format("  {0} / {1}  [{2}]  {3}", u.UserId, u.Password, otpInfo, u.DisplayName));
            }
            Console.WriteLine("----------------------------------------------");
            Console.WriteLine("Ctrl+C で停止");
            Console.WriteLine();

            var listener = new HttpListener();
            listener.Prefixes.Add(BASE_URL);

            try
            {
                listener.Start();
                Console.WriteLine("[INFO] リスニング開始");

                while (true)
                {
                    try
                    {
                        var context = listener.GetContext();
                        ThreadPool.QueueUserWorkItem(_ => HandleRequest(context));
                    }
                    catch (HttpListenerException)
                    {
                        break;
                    }
                }
            }
            catch (HttpListenerException ex)
            {
                Console.WriteLine("[ERROR] リスナー起動失敗: " + ex.Message);
                Console.WriteLine("  ポート 8080 が使用中か、管理者権限が必要な可能性があります。");
                Console.ReadKey();
            }
            finally
            {
                listener.Close();
            }
        }

        // -------------------------------------------------------------------
        // リクエストルーティング
        // -------------------------------------------------------------------
        private static void HandleRequest(HttpListenerContext ctx)
        {
            var req  = ctx.Request;
            var resp = ctx.Response;

            string method = req.HttpMethod.ToUpper();
            string path   = req.Url.AbsolutePath.TrimEnd('/');

            Console.WriteLine(string.Format("[{0}] {1} {2}", DateTime.Now.ToString("HH:mm:ss"), method, path));

            try
            {
                if (method == "POST" && path == "/ntss-admin-web/api/login")
                {
                    HandleLogin(req, resp);
                }
                else if (method == "GET" && path == "/ntss-admin-web/api/user")
                {
                    HandleGetUser(req, resp);
                }
                else if (method == "PUT" && path == "/ntss-admin-web/api/logging/mongo/info")
                {
                    HandleMongoLog(req, resp);
                }
                else if (method == "POST" && path.StartsWith("/ntss-admin-web/api/log/uploader"))
                {
                    HandleLogUpload(req, resp);
                }
                else if (method == "GET" && path == "/ntss-admin-web/api/mstInfo/mstFacility")
                {
                    HandleGetFacilities(req, resp);
                }
                // ---- Converter 認証 ----
                else if (method == "POST" && path == "/auth/login")
                {
                    HandleConverterLogin(req, resp);
                }
                else if (method == "GET" && path == "/actuator/health")
                {
                    HandleActuatorHealth(resp);
                }
                // ---- Converter API ----
                else if (method == "POST" && path == "/api/v1/upload")
                {
                    HandleConverterUpload(req, resp);
                }
                else if (method == "POST" && path == "/api/v1/jobs")
                {
                    HandleConverterJobCreate(req, resp);
                }
                else if (method == "GET" && path.StartsWith("/api/v1/jobs/"))
                {
                    // /api/v1/jobs/{jobId}  or  /api/v1/jobs/{jobId}/logs
                    string rest = path.Substring("/api/v1/jobs/".Length); // "123" or "123/logs"
                    if (rest.EndsWith("/logs"))
                    {
                        string jobIdStr = rest.Substring(0, rest.Length - "/logs".Length);
                        HandleConverterJobLogs(req, resp, jobIdStr);
                    }
                    else
                    {
                        HandleConverterJobStatus(req, resp, rest);
                    }
                }
                else if (method == "GET" && path.StartsWith("/api/v1/facilities") && !path.StartsWith("/api/v1/facilities/count"))
                {
                    HandleGetFacilitiesV1(req, resp);
                }
                else if (method == "GET" && path == "/api/v1/facilities/count")
                {
                    HandleFacilityCount(req, resp);
                }
                else if (method == "GET" && path == "/api/v1/system/info")
                {
                    HandleSystemInfo(resp);
                }
                else if (method == "GET" && path.StartsWith("/api/v1/download/"))
                {
                    string rest = path.Substring("/api/v1/download/".Length);
                    HandleDownload(req, resp, rest);
                }
                else
                {
                    Console.WriteLine("  → 404 Not Found");
                    resp.StatusCode = 404;
                    WriteJson(resp, "{\"error\":\"not found\"}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("  [ERROR] " + ex.Message);
                resp.StatusCode = 500;
                WriteJson(resp, "{\"error\":\"internal server error\"}");
            }
            finally
            {
                resp.Close();
            }
        }

        // -------------------------------------------------------------------
        // POST /ntss-admin-web/api/login
        //
        // NKKWebAccess の動作:
        //   ステップ1 (argOtpCd=""):
        //     200 + JSON に "code" キーあり → 2FA必要 (strContent="1", isLogin=false)
        //     200 + JSON に "code" キーなし → ログイン完了 (strContent="1", isLogin=true)
        //     403                           → 認証失敗 (strContent="0")
        //   ステップ2 (argOtpCd=OTPコード):
        //     200 + JSON に "code" キーなし → ログイン完了 (strContent="1", isLogin=true)
        //     403                           → OTP失敗 (strContent="0")
        // -------------------------------------------------------------------
        private static void HandleLogin(HttpListenerRequest req, HttpListenerResponse resp)
        {
            string body = ReadBody(req);
            Console.WriteLine("  Body: " + body);

            var fields = ParseFormOrJson(body);
            string userId   = GetField(fields, "userId", "user_id", "UserId");
            string password = GetField(fields, "password", "Password");
            string otpCd    = GetField(fields, "otpCd", "otp", "OtpCd");

            bool isOtpStep = !string.IsNullOrEmpty(otpCd);

            if (isOtpStep)
            {
                // ステップ2: OTP検証
                UserConfig pending;
                lock (_lock)
                {
                    // OTP待ちセッションをuserId単位で管理
                    // userId が body に入っていない場合、セッションから推測
                    pending = FindOtpPending(userId, otpCd);
                }

                if (pending == null)
                {
                    // OTP不一致 or セッションなし
                    Console.WriteLine("  → 403 OTP失敗");
                    resp.StatusCode = 403;
                    WriteJson(resp, "{\"result\":\"0\",\"message\":\"ワンタイムパスワードが正しくありません。\"}");
                    return;
                }

                // OTP成功
                lock (_lock)
                {
                    _otpPending.Remove(pending.UserId);
                    _sessions[pending.UserId] = pending;
                }
                Console.WriteLine(string.Format("  → 200 OTP認証成功 ({0})", pending.UserId));
                // "code" キーなし → isLogin=true
                WriteJson(resp, string.Format(
                    "{{\"result\":\"1\",\"userId\":\"{0}\",\"facilityCd\":\"{1}\"}}",
                    pending.UserId, pending.FacilityCd));
                return;
            }

            // ステップ1: ID/PW認証
            UserConfig user = FindUser(userId, password);
            if (user == null)
            {
                Console.WriteLine(string.Format("  → 403 認証失敗 (userId={0})", userId));
                resp.StatusCode = 403;
                WriteJson(resp, "{\"result\":\"0\",\"message\":\"ユーザーIDまたはパスワードが正しくありません。\"}");
                return;
            }

            if (!user.RequireOtp)
            {
                // OTP不要 → 直接ログイン完了 ("code" キーなし)
                lock (_lock) { _sessions[user.UserId] = user; }
                Console.WriteLine(string.Format("  → 200 ログイン成功（OTP不要）({0})", user.UserId));
                WriteJson(resp, string.Format(
                    "{{\"result\":\"1\",\"userId\":\"{0}\",\"facilityCd\":\"{1}\"}}",
                    user.UserId, user.FacilityCd));
            }
            else
            {
                // OTP必要 → "code" キーあり → isLogin=false
                lock (_lock) { _otpPending[user.UserId] = user; }
                Console.WriteLine(string.Format("  → 200 OTP要求 ({0})", user.UserId));
                WriteJson(resp, string.Format(
                    "{{\"result\":\"1\",\"code\":\"sent\",\"userId\":\"{0}\"}}",
                    user.UserId));
            }
        }

        // -------------------------------------------------------------------
        // GET /ntss-admin-web/api/user
        // -------------------------------------------------------------------
        private static void HandleGetUser(HttpListenerRequest req, HttpListenerResponse resp)
        {
            // NKKWebAccess はログイン後にユーザー情報を取得することがある
            // 簡易的に最初のセッションユーザーを返す
            UserConfig user = null;
            lock (_lock)
            {
                foreach (var kv in _sessions) { user = kv.Value; break; }
            }

            if (user == null)
            {
                Console.WriteLine("  → 403 未ログイン");
                resp.StatusCode = 403;
                WriteJson(resp, "{\"error\":\"not logged in\"}");
                return;
            }

            Console.WriteLine(string.Format("  → 200 ユーザー情報返却 ({0})", user.UserId));
            WriteJson(resp, string.Format(
                "{{\"userId\":\"{0}\",\"facilityCd\":\"{1}\",\"displayName\":\"{2}\"}}",
                user.UserId, user.FacilityCd, user.DisplayName));
        }

        // -------------------------------------------------------------------
        // PUT /ntss-admin-web/api/logging/mongo/info
        // -------------------------------------------------------------------
        private static void HandleMongoLog(HttpListenerRequest req, HttpListenerResponse resp)
        {
            string body = ReadBody(req);
            Console.WriteLine("  MongoLog受信: " + (body.Length > 100 ? body.Substring(0, 100) + "..." : body));
            Console.WriteLine("  → 200 OK");
            WriteJson(resp, "{\"result\":\"ok\"}");
        }

        // -------------------------------------------------------------------
        // GET /api/v1/facilities   (新形式 — FacilityLoader が使用)
        // {"total":5,"page":0,"size":1000,"facilities":[...]}
        // -------------------------------------------------------------------
        private static void HandleGetFacilitiesV1(HttpListenerRequest req, HttpListenerResponse resp)
        {
            Console.WriteLine("  → 200 施設一覧返却 [/api/v1/facilities] 5件");
            WriteJson(resp,
                "{\"total\":5,\"page\":0,\"size\":1000," +
                "\"facilities\":[" +
                "{\"facilityCd\":\"C001\",\"facilityName\":\"[API]\u6771\u4eac\u4e2d\u592e\u75c5\u9662\"}," +
                "{\"facilityCd\":\"C002\",\"facilityName\":\"[API]\u5927\u962a\u5317\u6d77\u30af\u30ea\u30cb\u30c3\u30af\"}," +
                "{\"facilityCd\":\"C003\",\"facilityName\":\"[API]\u540d\u53e4\u5c4b\u5357\u90e8\u75c5\u9662\"}," +
                "{\"facilityCd\":\"11166\",\"facilityName\":\"\u4f5566\u30c6\u30b9\u30c8\"}," +
                "{\"facilityCd\":\"NKKSBR\",\"facilityName\":\"\u65e5\u6a5f\u88c5\u9759\u5ca1\u7b2c\u56db\u901a\u4fe1\u8a66\u9a13\u5ba4test1\"}" +
                "]}");
        }

        // -------------------------------------------------------------------
        // GET /ntss-admin-web/api/mstInfo/mstFacility
        // 施設マスタ一覧を返す（モックデータ）
        // -------------------------------------------------------------------
        private static void HandleGetFacilities(HttpListenerRequest req, HttpListenerResponse resp)
        {
            Console.WriteLine("  \u2192 200 \u65bd\u8a2d\u4e00\u89a7\u8fd4\u5374 [API\u30e2\u30c3\u30af] 5\u4ef6");
            // ※ MockServer から返す本番相当データ（実際は FutureNet サーバーが返す）
            WriteJson(resp,
                "[" +
                "{\"facilityCd\":\"C001\",\"facilityName\":\"[API]\u6771\u4eac\u4e2d\u592e\u75c5\u9662\"}," +
                "{\"facilityCd\":\"C002\",\"facilityName\":\"[API]\u5927\u962a\u5317\u6d77\u30af\u30ea\u30cb\u30c3\u30af\"}," +
                "{\"facilityCd\":\"C003\",\"facilityName\":\"[API]\u540d\u53e4\u5c4b\u5357\u90e8\u75c5\u9662\"}," +
                "{\"facilityCd\":\"11166\",\"facilityName\":\"\u4f5566\u30c6\u30b9\u30c8\"}," +
                "{\"facilityCd\":\"NKKSBR\",\"facilityName\":\"\u65e5\u6a5f\u88c5\u9759\u5ca1\u7b2c\u56db\u901a\u4fe1\u8a66\u9a13\u5ba4test1\"}" +
                "]");
        }

        // -------------------------------------------------------------------
        // POST /ntss-admin-web/api/log/uploader/*
        // -------------------------------------------------------------------
        private static void HandleLogUpload(HttpListenerRequest req, HttpListenerResponse resp)
        {
            Console.WriteLine(string.Format("  ログアップロード受信 (ContentLength={0})", req.ContentLength64));
            // 受け取るだけで捨てる
            ReadBody(req);
            Console.WriteLine("  → 200 OK");
            WriteJson(resp, "{\"result\":\"ok\"}");
        }

        // -------------------------------------------------------------------
        // POST /auth/login
        // コンバーターサーバー JWT 認証モック
        // user3 の場合は認証失敗（401）を返す
        // -------------------------------------------------------------------
        private static void HandleConverterLogin(HttpListenerRequest req, HttpListenerResponse resp)
        {
            string body = ReadBody(req);
            Console.WriteLine("  Converter 認証: " + body);

            var fields = ParseFormOrJson(body);
            string dispUserId = GetField(fields, "dispUserId", "userId", "user_id");

            if (string.Equals(dispUserId, "user3", StringComparison.OrdinalIgnoreCase))
            {
                Console.WriteLine("  -> 401 Converter 認証失敗 (user3)");
                resp.StatusCode = 401;
                WriteJson(resp, "{\"error\":\"unauthorized\",\"message\":\"コンバーター認証に失敗しました。\"}");
                return;
            }

            Console.WriteLine("  -> 200 JWT 返却");
            WriteJson(resp,
                "{\"accessToken\":\"mock_jwt_token\"," +
                "\"refreshToken\":\"mock_refresh_token\"," +
                "\"expiresIn\":3600," +
                "\"tokenType\":\"Bearer\"}");
        }

        // -------------------------------------------------------------------
        // POST /api/v1/upload
        // マルチパートファイルを受け取り uploadId を返す（ファイルは捨てる）
        // -------------------------------------------------------------------
        private static void HandleConverterUpload(HttpListenerRequest req, HttpListenerResponse resp)
        {
            // multipart/form-data のボディは大きい場合があるので生バイトで読み捨てる
            DrainInputStream(req);

            string uploadId = "mock_" + Guid.NewGuid().ToString("N").Substring(0, 8);
            Console.WriteLine(string.Format("  → 200 Upload 受付: {0}", uploadId));
            WriteJson(resp, string.Format("{{\"uploadId\":\"{0}\"}}", uploadId));
        }

        // -------------------------------------------------------------------
        // POST /api/v1/jobs
        // JOB を作成してバックグラウンドでシミュレーションを開始する
        // -------------------------------------------------------------------
        private static void HandleConverterJobCreate(HttpListenerRequest req, HttpListenerResponse resp)
        {
            string body = ReadBody(req);
            var fields  = ParseFormOrJson(body);
            string direction = GetField(fields, "direction");

            MockJob job;
            lock (_lock)
            {
                job = new MockJob { JobId = _nextJobId++ };
                _jobs[job.JobId] = job;
            }

            Console.WriteLine(string.Format("  → 200 JOB 作成: JobId={0} direction={1}", job.JobId, direction));
            WriteJson(resp, string.Format("{{\"jobId\":{0}}}", job.JobId));

            // バックグラウンドで 10 タスクを 1.5 秒間隔でシミュレート
            long jobId = job.JobId;
            ThreadPool.QueueUserWorkItem(_ => SimulateJob(jobId));
        }

        // -------------------------------------------------------------------
        // GET /api/v1/jobs/{jobId}
        // -------------------------------------------------------------------
        private static void HandleConverterJobStatus(HttpListenerRequest req, HttpListenerResponse resp, string jobIdStr)
        {
            if (!long.TryParse(jobIdStr, out long jobId))
            {
                resp.StatusCode = 400;
                WriteJson(resp, "{\"error\":\"invalid jobId\"}");
                return;
            }

            MockJob job;
            lock (_lock) { _jobs.TryGetValue(jobId, out job); }

            if (job == null)
            {
                resp.StatusCode = 404;
                WriteJson(resp, "{\"error\":\"job not found\"}");
                return;
            }

            int pct, total, done;
            string status;
            lock (job)
            {
                status = job.Status;
                total  = job.TotalTasks;
                done   = job.DoneTasks;
                pct    = total == 0 ? 0 : (int)((double)done / total * 100);
            }

            WriteJson(resp, string.Format(
                "{{\"jobId\":{0},\"status\":\"{1}\",\"progress\":{{\"totalTasks\":{2},\"doneTasks\":{3},\"percentComplete\":{4}}}}}",
                jobId, status, total, done, pct));
        }

        // -------------------------------------------------------------------
        // GET /api/v1/jobs/{jobId}/logs?offset=X&limit=Y
        // -------------------------------------------------------------------
        private static void HandleConverterJobLogs(HttpListenerRequest req, HttpListenerResponse resp, string jobIdStr)
        {
            if (!long.TryParse(jobIdStr, out long jobId))
            {
                resp.StatusCode = 400;
                WriteJson(resp, "{\"error\":\"invalid jobId\"}");
                return;
            }

            long offset = 0;
            int  limit  = 100;
            if (req.Url.Query != null)
            {
                foreach (var part in req.Url.Query.TrimStart('?').Split('&'))
                {
                    var kv = part.Split(new char[]{'='}, 2);
                    if (kv.Length == 2)
                    {
                        if (kv[0] == "offset") long.TryParse(kv[1], out offset);
                        if (kv[0] == "limit")  int.TryParse(kv[1], out limit);
                    }
                }
            }

            MockJob job;
            lock (_lock) { _jobs.TryGetValue(jobId, out job); }

            if (job == null)
            {
                resp.StatusCode = 404;
                WriteJson(resp, "{\"error\":\"job not found\"}");
                return;
            }

            var sb = new StringBuilder();
            sb.Append("{\"logs\":[");
            long nextOffset = offset;

            lock (job)
            {
                bool first = true;
                for (long i = offset; i < job.Logs.Count && i < offset + limit; i++)
                {
                    var entry = job.Logs[(int)i];
                    if (!first) sb.Append(',');
                    first = false;
                    sb.AppendFormat(
                        "{{\"logId\":{0},\"taskId\":{1},\"taskName\":\"{2}\",\"level\":\"{3}\",\"message\":\"{4}\"}}",
                        i + 1, entry.TaskId, Esc(entry.TaskName), entry.Level, Esc(entry.Message));
                    nextOffset = i + 1;
                }
            }

            sb.AppendFormat("],\"nextOffset\":{0}}}", nextOffset);
            WriteJson(resp, sb.ToString());
        }

        // -------------------------------------------------------------------
        // GET /api/v1/facilities/count
        // on2off 用: クライアントが seqStartMap を構築するためのテーブル件数を返す
        // -------------------------------------------------------------------
        private static void HandleFacilityCount(HttpListenerRequest req, HttpListenerResponse resp)
        {
            Console.WriteLine("  → 200 施設テーブル件数返却 (on2off用)");
            WriteJson(resp,
                "{\"facilityCodes\":[\"NKKSBR\"]," +
                "\"tableCounts\":{\"pat_personal_main\":12,\"ord_main\":34,\"pat_exam_main\":5,\"pat_exam_pattern\":3}," +
                "\"totalRows\":54," +
                "\"calculatedAt\":\"2026-04-05T00:00:00Z\"}");
        }

        private static void HandleSystemInfo(HttpListenerResponse resp)
        {
            WriteJson(resp, "{\"converterDbHost\":\"localhost\",\"converterDbPort\":5433}");
        }

        private static void HandleActuatorHealth(HttpListenerResponse resp)
        {
            WriteJson(resp, "{\"status\":\"UP\"}");
        }

        // -------------------------------------------------------------------
        // GET /api/v1/download/{jobId}/{fileType}
        // on2off 用: 最小限の有効な空 ZIP を返す（モック）
        // -------------------------------------------------------------------
        private static void HandleDownload(HttpListenerRequest req, HttpListenerResponse resp, string rest)
        {
            // rest = "{jobId}/{fileType}"  例: "1/pg_dump"
            string[] parts    = rest.Split(new char[]{'/'}, 2);
            string   jobIdStr = parts.Length > 0 ? parts[0] : "?";
            string   fileType = parts.Length > 1 ? parts[1] : "?";

            Console.WriteLine(string.Format("  → 200 ダウンロード: jobId={0} fileType={1}", jobIdStr, fileType));

            byte[] zipBytes = CreateEmptyZipBytes();
            resp.ContentType     = "application/zip";
            resp.ContentLength64 = zipBytes.Length;
            resp.OutputStream.Write(zipBytes, 0, zipBytes.Length);
        }

        // -------------------------------------------------------------------
        // 最小限の有効な空 ZIP バイト列を生成する（メモリ上で ZipArchive を作成）
        // -------------------------------------------------------------------
        private static byte[] CreateEmptyZipBytes()
        {
            using (var ms = new MemoryStream())
            {
                using (var archive = new ZipArchive(ms, ZipArchiveMode.Create, leaveOpen: true))
                {
                    // エントリなし → 空 ZIP
                }
                return ms.ToArray();
            }
        }

        // -------------------------------------------------------------------
        // JOB シミュレーション: 10 タスク × 1.5 秒
        // -------------------------------------------------------------------
        private static readonly string[] TASK_NAMES = {
            "PG Import", "PK Mapping", "PK Refresh", "FK Refresh",
            "Mongo Import", "Mongo FK Refresh", "PG Export", "PG Restore",
            "Mongo Export+Import", "File Copy"
        };

        private static void SimulateJob(long jobId)
        {
            MockJob job;
            lock (_lock) { _jobs.TryGetValue(jobId, out job); }
            if (job == null) return;

            lock (job) { job.TotalTasks = TASK_NAMES.Length; }

            for (int i = 0; i < TASK_NAMES.Length; i++)
            {
                Thread.Sleep(1500);

                lock (job)
                {
                    job.DoneTasks = i + 1;
                    job.Logs.Add(new MockLogEntry
                    {
                        TaskId   = i + 1,
                        TaskName = TASK_NAMES[i],
                        Level    = "INFO",
                        Message  = string.Format("タスク完了: {0}", TASK_NAMES[i])
                    });
                }

                Console.WriteLine(string.Format("  [JOB {0}] タスク完了: {1} ({2}/{3})",
                    jobId, TASK_NAMES[i], i + 1, TASK_NAMES.Length));
            }

            lock (job) { job.Status = "DONE"; }
            Console.WriteLine(string.Format("  [JOB {0}] DONE", jobId));
        }

        // -------------------------------------------------------------------
        // ヘルパー: InputStream を読み捨てる（バイナリ対応）
        // -------------------------------------------------------------------
        private static void DrainInputStream(HttpListenerRequest req)
        {
            if (!req.HasEntityBody) return;
            var buf = new byte[65536];
            while (req.InputStream.Read(buf, 0, buf.Length) > 0) { }
        }

        private static string Esc(string s) =>
            (s ?? string.Empty).Replace("\\", "\\\\").Replace("\"", "\\\"");

        // -------------------------------------------------------------------
        // ヘルパー: OTP待ちセッション検索
        // -------------------------------------------------------------------
        private static UserConfig FindOtpPending(string userId, string otpCd)
        {
            if (!string.IsNullOrEmpty(userId) && _otpPending.ContainsKey(userId))
            {
                var u = _otpPending[userId];
                if (u.OtpCode == otpCd) return u;
                return null;
            }
            // userId が空の場合は全OTP待ちを検索
            foreach (var kv in _otpPending)
            {
                if (kv.Value.OtpCode == otpCd) return kv.Value;
            }
            return null;
        }

        private static UserConfig FindUser(string userId, string password)
        {
            foreach (var u in _config.Users)
            {
                if (string.Equals(u.UserId, userId, StringComparison.OrdinalIgnoreCase)
                    && u.Password == password)
                    return u;
            }
            return null;
        }

        // -------------------------------------------------------------------
        // ヘルパー: リクエストボディ読み込み
        // -------------------------------------------------------------------
        private static string ReadBody(HttpListenerRequest req)
        {
            if (!req.HasEntityBody) return string.Empty;
            using (var sr = new StreamReader(req.InputStream, req.ContentEncoding ?? Encoding.UTF8))
                return sr.ReadToEnd();
        }

        // -------------------------------------------------------------------
        // ヘルパー: フォームまたはJSON本文をキー/値辞書に変換
        //   application/x-www-form-urlencoded → "&" split
        //   application/json                  → 簡易JSON parse
        // -------------------------------------------------------------------
        private static Dictionary<string, string> ParseFormOrJson(string body)
        {
            var dict = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            if (string.IsNullOrWhiteSpace(body)) return dict;

            string trimmed = body.Trim();
            if (trimmed.StartsWith("{"))
            {
                // 簡易JSONパース: "key":"value" のペアを抽出
                // DataContractJsonSerializer は型が固定なので正規表現で代替
                int i = 0;
                while (i < trimmed.Length)
                {
                    int ks = trimmed.IndexOf('"', i); if (ks < 0) break;
                    int ke = trimmed.IndexOf('"', ks + 1); if (ke < 0) break;
                    string key = trimmed.Substring(ks + 1, ke - ks - 1);
                    int colon = trimmed.IndexOf(':', ke + 1); if (colon < 0) break;
                    // 値の開始
                    int vi = colon + 1;
                    while (vi < trimmed.Length && (trimmed[vi] == ' ' || trimmed[vi] == '\t')) vi++;
                    string val;
                    if (vi < trimmed.Length && trimmed[vi] == '"')
                    {
                        int ve = trimmed.IndexOf('"', vi + 1); if (ve < 0) break;
                        val = trimmed.Substring(vi + 1, ve - vi - 1);
                        i = ve + 1;
                    }
                    else
                    {
                        int ve = vi;
                        while (ve < trimmed.Length && trimmed[ve] != ',' && trimmed[ve] != '}') ve++;
                        val = trimmed.Substring(vi, ve - vi).Trim();
                        i = ve + 1;
                    }
                    if (!string.IsNullOrEmpty(key)) dict[key] = val;
                }
            }
            else
            {
                // application/x-www-form-urlencoded
                foreach (var pair in body.Split('&'))
                {
                    var kv = pair.Split(new char[]{'='}, 2);
                    if (kv.Length == 2)
                        dict[Uri.UnescapeDataString(kv[0])] = Uri.UnescapeDataString(kv[1]);
                }
            }
            return dict;
        }

        private static string GetField(Dictionary<string, string> dict, params string[] keys)
        {
            foreach (var k in keys)
                if (dict.ContainsKey(k)) return dict[k];
            return string.Empty;
        }

        // -------------------------------------------------------------------
        // ヘルパー: JSON レスポンス書き込み
        // -------------------------------------------------------------------
        private static void WriteJson(HttpListenerResponse resp, string json)
        {
            resp.ContentType     = "application/json; charset=utf-8";
            resp.ContentEncoding = Encoding.UTF8;
            byte[] buf = Encoding.UTF8.GetBytes(json);
            resp.ContentLength64 = buf.Length;
            resp.OutputStream.Write(buf, 0, buf.Length);
        }

        // -------------------------------------------------------------------
        // MockConfig.json 読み込み
        // -------------------------------------------------------------------
        private static MockConfigRoot LoadConfig()
        {
            string path = Path.Combine(
                Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location),
                "MockConfig.json");

            if (!File.Exists(path))
            {
                Console.WriteLine("[ERROR] 設定ファイルが見つかりません: " + path);
                return null;
            }

            try
            {
                string json = File.ReadAllText(path, Encoding.UTF8);
                using (var ms = new MemoryStream(Encoding.UTF8.GetBytes(json)))
                {
                    var ser = new DataContractJsonSerializer(typeof(MockConfigRoot));
                    return (MockConfigRoot)ser.ReadObject(ms);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("[ERROR] 設定ファイル読み込み失敗: " + ex.Message);
                return null;
            }
        }
    }

    // -----------------------------------------------------------------------
    // 設定モデル（DataContractJsonSerializer 用）
    // -----------------------------------------------------------------------
    [DataContract]
    public class MockConfigRoot
    {
        [DataMember(Name = "Users")]
        public List<UserConfig> Users { get; set; } = new List<UserConfig>();
    }

    // -----------------------------------------------------------------------
    // Converter JOB モデル
    // -----------------------------------------------------------------------
    public class MockJob
    {
        public long              JobId      { get; set; }
        public string            Status     { get; set; } = "RUNNING";
        public int               TotalTasks { get; set; } = 0;
        public int               DoneTasks  { get; set; } = 0;
        public List<MockLogEntry> Logs      { get; set; } = new List<MockLogEntry>();
    }

    public class MockLogEntry
    {
        public int    TaskId   { get; set; }
        public string TaskName { get; set; }
        public string Level    { get; set; }
        public string Message  { get; set; }
    }

    [DataContract]
    public class UserConfig
    {
        [DataMember(Name = "UserId")]
        public string UserId { get; set; }

        [DataMember(Name = "Password")]
        public string Password { get; set; }

        [DataMember(Name = "RequireOtp")]
        public bool RequireOtp { get; set; }

        [DataMember(Name = "OtpCode")]
        public string OtpCode { get; set; }

        [DataMember(Name = "FacilityCd")]
        public string FacilityCd { get; set; }

        [DataMember(Name = "DisplayName")]
        public string DisplayName { get; set; }
    }
}
