using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text;
using System.Threading.Tasks;
using FNSICloudConvertClient.Models;

namespace FNSICloudConvertClient.Logic
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// 施設一覧取得ロジック
    ///   オンプレ→クラウド (Export): オンプレ PostgreSQL (ntss.mst_facility) から取得
    ///   クラウド→オンプレ (Import): コンバーターサーバー API から取得 (JWT 認証)
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public static class FacilityLoader
    {
        private const string API_FACILITY_PATH = "/api/v1/facilities?size=1000";

        private static readonly HttpClient _http = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(30)
        };

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 操作モードに応じて施設一覧を取得する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static async Task<List<FacilityInfo>> LoadAsync(AppState state)
        {
            if (state.CurrentMode == OperationMode.Export)
                return await LoadFromDatabaseAsync(state.Settings);  // オンプレDB から取得
            else
                return await LoadFromServerAsync();                   // コンバーターサーバーAPI から取得
        }

        // --------------------------------------------------
        // Import: コンバーターサーバー API から取得 (JWT)
        // --------------------------------------------------
        private static async Task<List<FacilityInfo>> LoadFromServerAsync()
        {
            string url   = AppConfigLoader.ConverterBaseUri.TrimEnd('/') + API_FACILITY_PATH;
            string token = AppState.Instance.ConverterJwtToken;

            var request = new HttpRequestMessage(HttpMethod.Get, url);
            AppConfigLoader.ApplyConverterRequestHeaders(request.Headers);
            if (!string.IsNullOrEmpty(token))
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

            var resp = await _http.SendAsync(request);

            if (!resp.IsSuccessStatusCode)
                throw new Exception(string.Format("サーバーから施設一覧を取得できませんでした。[{0}]", (int)resp.StatusCode));

            string body = await resp.Content.ReadAsStringAsync();
            if (string.IsNullOrEmpty(body))
                throw new Exception("サーバーから施設一覧を取得できませんでした。");

            return ParseFacilityJson(body);
        }

        // --------------------------------------------------
        // Export: PostgreSQL ntss.mst_facility から取得
        // --------------------------------------------------
        private static async Task<List<FacilityInfo>> LoadFromDatabaseAsync(AppSettings settings)
        {
            var runner = new SqlRunner(settings);
            var table  = await runner.QueryAsync(
                "Common/get_facilities.sql",
                null);

            var list = new List<FacilityInfo>();
            foreach (System.Data.DataRow row in table.Rows)
            {
                list.Add(new FacilityInfo
                {
                    FacilityCd   = row["facility_cd"]   as string ?? string.Empty,
                    FacilityName = row["facility_name"] as string ?? string.Empty,
                });
            }
            return list;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// API レスポンス JSON を FacilityInfo リストへデシリアライズする
        /// JSON 形式: {"total":5,"page":0,"size":1000,"facilities":[{"facilityCd":"...","facilityName":"..."},...]}
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static List<FacilityInfo> ParseFacilityJson(string json)
        {
            var result = new List<FacilityInfo>();
            try
            {
                var ser = new DataContractJsonSerializer(typeof(FacilityListApiDto));
                using (var ms = new MemoryStream(Encoding.UTF8.GetBytes(json)))
                {
                    var dto = (FacilityListApiDto)ser.ReadObject(ms);
                    if (dto?.Facilities != null)
                    {
                        foreach (var f in dto.Facilities)
                        {
                            result.Add(new FacilityInfo
                            {
                                FacilityCd   = f.FacilityCd   ?? string.Empty,
                                FacilityName = f.FacilityName ?? string.Empty,
                            });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("施設一覧JSONの解析に失敗しました: " + ex.Message);
            }
            return result;
        }

        // --------------------------------------------------
        // API レスポンス用 DTO
        // --------------------------------------------------
        [DataContract]
        private class FacilityListApiDto
        {
            [DataMember(Name = "total")]
            public long Total { get; set; }

            [DataMember(Name = "facilities")]
            public List<FacilityItemDto> Facilities { get; set; }
        }

        [DataContract]
        private class FacilityItemDto
        {
            [DataMember(Name = "facilityCd")]
            public string FacilityCd { get; set; }

            [DataMember(Name = "facilityName")]
            public string FacilityName { get; set; }
        }
    }
}
