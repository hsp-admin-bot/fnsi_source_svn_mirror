using NKKWebAccessLib;
using System;
using System.Net;
using System.Reflection;
using System.Threading.Tasks;

namespace NKK.BloodPurify
{
    static public class MyRest
    {
        static private readonly string STATIC_CLASS_NAME = "MyRest";
        static private readonly string MyRestBaseUri = MyConfig.BaseUri + "/ntss-admin-web/api/blood_purify/";

        /// <summary>
        /// 浄化装置の透析情報を取得する
        /// </summary>
        /// <param name="argStartYyyyMmDd">YYYYMMDD形式の治療開始日</param>
        /// <returns>浄化装置通信アプリ用の透析情報</returns>
        static public async Task<(bool isSuccess, string errorReasonPhrase, string getData)> GetBloodPurifyOrdInfoForBloodPurifyDevice(string argStartYyyyMmDd)
        {
            (bool isSuccess, string errorReasonPhrase, string getData) ret = (false, "", "");

            try
            {
                var restRes = await NKKWebAccess.Get(MethodBase.GetCurrentMethod().Name, MyRestBaseUri + $"ord_main/bp_device/{NKKWebAccess.FacilityCd}/{argStartYyyyMmDd}/", NKKWebAccess.SKIP_OTP);

                ret.isSuccess = restRes.response.IsSuccessStatusCode;
                ret.errorReasonPhrase
                    = string.IsNullOrWhiteSpace(restRes.response.ReasonPhrase) ? $"{(int)restRes.response.StatusCode}:{restRes.response.StatusCode}" : restRes.response.ReasonPhrase;
                if (ret.isSuccess)
                {
                    ret.getData = restRes.strContent;
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(STATIC_CLASS_NAME, "", ex);
            }

            return ret;
        }

        /// <summary>
        /// クールマスタの情報を取得する
        /// </summary>
        /// <returns>クールマスタの情報</returns>
        static public async Task<(bool isSuccess, string errorReasonPhrase, string getData)> GetMstKur()
        {
            (bool isSuccess, string errorReasonPhrase, string getData) ret = (false, "", "");

            try
            {
                var restRes = await NKKWebAccess.Get(MethodBase.GetCurrentMethod().Name, MyRestBaseUri + $"mst_kur/{NKKWebAccess.FacilityCd}/", NKKWebAccess.SKIP_OTP);

                ret.isSuccess = restRes.response.IsSuccessStatusCode;
                ret.errorReasonPhrase
                    = string.IsNullOrWhiteSpace(restRes.response.ReasonPhrase) ? $"{(int)restRes.response.StatusCode}:{restRes.response.StatusCode}" : restRes.response.ReasonPhrase;
                if (ret.isSuccess)
                {
                    ret.getData = restRes.strContent;
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(STATIC_CLASS_NAME, "", ex);
            }

            return ret;
        }

        /// <summary>
        /// 日機装透析装置の透析情報を取得する
        /// </summary>
        /// <param name="argStartYyyyMmDd">YYYYMMDD形式の治療開始日</param>
        /// <returns>浄化装置通信アプリ用の透析情報</returns>
        static public async Task<(bool isSuccess, string errorReasonPhrase, string getData)> GetBloodPurifyOrdInfoForNkkDevice(string argStartYyyyMmDd)
        {
            (bool isSuccess, string errorReasonPhrase, string getData) ret = (false, "", "");

            try
            {
                var restRes = await NKKWebAccess.Get(MethodBase.GetCurrentMethod().Name, MyRestBaseUri + $"ord_main/nkk_device/{NKKWebAccess.FacilityCd}/{argStartYyyyMmDd}/", NKKWebAccess.SKIP_OTP);

                ret.isSuccess = restRes.response.IsSuccessStatusCode;
                ret.errorReasonPhrase
                    = string.IsNullOrWhiteSpace(restRes.response.ReasonPhrase) ? $"{(int)restRes.response.StatusCode}:{restRes.response.StatusCode}" : restRes.response.ReasonPhrase;
                if (ret.isSuccess)
                {
                    ret.getData = restRes.strContent;
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(STATIC_CLASS_NAME, "", ex);
            }

            return ret;
        }

        /// <summary>
        /// 浄化治療のモニタデータを治療記録に登録
        /// </summary>
        /// <param name="argOrdNo">オーダー番号</param>
        /// <param name="argBptxtFilePath">bptxt(UTF-8N/LF、DEのファイル形式と同じ)ファイルのパス</param>
        /// <returns></returns>
        static public async Task<(bool isSuccess, string errorReasonPhrase, HttpStatusCode statusCode)> PostBptxtFile(long argOrdNo, string argBptxtFilePath)
        {
            (bool isSuccess, string errorReasonPhrase, HttpStatusCode statusCode) ret = (false, "", (HttpStatusCode)999); // (StatusCode[999]は)勝手な定義

            try
            {
                var restRes = await NKKWebAccess.Post(MethodBase.GetCurrentMethod().Name, MyRestBaseUri + $"post_data/{argOrdNo}/", AccessorBptxtFile.Read(argBptxtFilePath), NKKWebAccess.SKIP_OTP);

                ret.isSuccess = restRes.response.IsSuccessStatusCode;
                ret.errorReasonPhrase
                    = string.IsNullOrWhiteSpace(restRes.response.ReasonPhrase) ? $"{(int)restRes.response.StatusCode}:{restRes.response.StatusCode}" : restRes.response.ReasonPhrase;
                ret.statusCode = restRes.response.StatusCode;
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(STATIC_CLASS_NAME, "", ex);
            }

            return ret;
        }

        // add 2020-08-03 FNSI-仕様追加 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する 李 start
        /// <summary>
        /// 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する
        /// </summary>
        /// <returns></returns>
        static public async Task<(bool isSuccess, string status, string getData)> GetDialysisDevice()
        {
            (bool isSuccess, string status, string getData) ret = (false, "未サインイン", "");

            try
            {
                var restRes = await NKKWebAccess.Get(MethodBase.GetCurrentMethod().Name,
                    MyRestBaseUri + $"mst_getdialysisdevice/{NKKWebAccess.FacilityCd}/");
                ret.isSuccess = restRes.isLogin & restRes.response.IsSuccessStatusCode;
                ret.status = (true == restRes.isLogin ? $"{(int)restRes.response.StatusCode}:{restRes.response.StatusCode}" : "サーバに接続できませんでした");
                ret.getData = restRes.strContent;
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(STATIC_CLASS_NAME, "", ex);
            }

            return ret;
        }
        // add 2020-08-03 FNSI-仕様追加 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する 李 end
    }
}
