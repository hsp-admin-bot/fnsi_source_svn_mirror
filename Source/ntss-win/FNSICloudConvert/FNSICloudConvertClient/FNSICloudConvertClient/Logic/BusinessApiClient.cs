using System;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace FNSICloudConvertClient.Logic
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// 業務アプリ（NTSS Admin Web）へのログイン認証クライアント（NKKWebAccess の代替）
    ///
    /// エンドポイント:
    ///   POST {BaseUri}/ntss-admin-web/api/login
    ///
    /// レスポンス仕様（MockServer準拠）:
    ///   ID/PW 認証成功（OTP不要）: {"result":"1","userId":"...","facilityCd":"..."}
    ///   ID/PW 認証成功（OTP必要）: {"result":"1","code":"sent","userId":"..."}
    ///   認証失敗 / 403           : {"result":"0","message":"..."}
    ///
    /// ServerLoginAsync が返す BusinessLoginResponse:
    ///   strContent = "-1" → サーバー接続失敗 / HTTP エラー
    ///   strContent = "0"  → 認証失敗
    ///   strContent = "1" + isLogin = false → OTP 送信済み（二段階認証必要）
    ///   strContent = "1" + isLogin = true  → ログイン完了
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public static class BusinessApiClient
    {
        public static string BaseUri                       { get; set; } = "http://localhost:8080";
        public static string UserId                        { get; set; } = string.Empty;
        public static string Password                      { get; set; } = string.Empty;
        public static string FacilityCd                    { get; set; } = string.Empty;
        public static string UrlEncodeFacilityHash         { get; set; } = string.Empty;
        public static string ClientCertificateSearchValue1 { get; set; } = string.Empty;
        public static string ClientCertificateSearchValue2 { get; set; } = string.Empty;

        /// <summary>ログイン済みフラグ（NKKWebAccess.Login の代替）</summary>
        public static bool IsLoggedIn { get; private set; }

        private static readonly HttpClient _http = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(30)
        };

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログイン認証を実行する
        /// </summary>
        /// <param name="otpCode">
        ///   ステップ1（ID/PW認証）: 空文字 ""
        ///   ステップ2（OTP認証）  : ワンタイムパスワード
        /// </param>
        //----------------------------------------------------------------------------------------------------
        public static async Task<BusinessLoginResponse> ServerLoginAsync(string otpCode)
        {
            string url = BaseUri.TrimEnd('/') + "/ntss-admin-web/api/login";

            // application/x-www-form-urlencoded 形式で送信
            // UrlEncodeFacilityHash はすでに URL エンコード済みのため二重エンコードしない
            var sb = new StringBuilder();
            sb.AppendFormat("userId={0}",   Uri.EscapeDataString(UserId));
            sb.AppendFormat("&password={0}", Uri.EscapeDataString(Password));

            if (!string.IsNullOrEmpty(otpCode))
            {
                // ステップ2: OTP 認証
                sb.AppendFormat("&otpCd={0}", Uri.EscapeDataString(otpCode));
            }
            else
            {
                // ステップ1: ID/PW 認証 — facilityCd はすでにエンコード済みをそのまま使用
                sb.AppendFormat("&facilityCd={0}", UrlEncodeFacilityHash);
            }

            var httpContent = new StringContent(sb.ToString(), Encoding.UTF8, "application/x-www-form-urlencoded");

            try
            {
                HttpResponseMessage resp = await _http.PostAsync(url, httpContent);
                string body = await resp.Content.ReadAsStringAsync();

                // 403 → 認証失敗（ID/PW 不一致 or OTP 不一致）
                if (resp.StatusCode == HttpStatusCode.Forbidden)
                    return new BusinessLoginResponse { strContent = "0", isLogin = false, response = resp };

                // その他 4xx/5xx → 接続失敗
                if (!resp.IsSuccessStatusCode)
                    return new BusinessLoginResponse { strContent = "-1", isLogin = false, response = resp };

                // "code" キーがあれば OTP 必要（原版 NKKWebAccess と同じ判定）
                bool hasCodeKey = body.IndexOf("\"code\"", StringComparison.Ordinal) >= 0;

                if (hasCodeKey)
                    return new BusinessLoginResponse { strContent = "1", isLogin = false, response = resp };

                // "code" キーなし → ログイン完了
                // facilityCd をレスポンスから取得・保存
                FacilityCd = ExtractJsonString(body, "facilityCd");
                IsLoggedIn = true;
                return new BusinessLoginResponse { strContent = "1", isLogin = true, response = resp };
            }
            catch
            {
                return new BusinessLoginResponse { strContent = "-1", isLogin = false, response = null };
            }
        }

        private static string Esc(string s) =>
            (s ?? string.Empty).Replace("\\", "\\\\").Replace("\"", "\\\"");

        /// <summary>JSON 文字列から指定キーの値を簡易抽出する</summary>
        private static string ExtractJsonString(string json, string key)
        {
            string search = "\"" + key + "\":\"";
            int start = json.IndexOf(search, StringComparison.Ordinal);
            if (start < 0) return string.Empty;
            start += search.Length;
            int end = json.IndexOf('"', start);
            return end < 0 ? string.Empty : json.Substring(start, end - start);
        }
    }

    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// ServerLoginAsync のレスポンス（NKKWebAccessResponse の代替）
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class BusinessLoginResponse
    {
        /// <summary>"-1"=接続失敗, "0"=認証失敗, "1"=成功（isLogin で状態確認）</summary>
        public string strContent { get; set; } = string.Empty;

        /// <summary>true=ログイン完了 / false=OTP待ち（strContent="1" のとき有効）</summary>
        public bool isLogin { get; set; }

        /// <summary>エラー詳細抽出用の HTTP レスポンス</summary>
        public HttpResponseMessage response { get; set; }
    }
}
