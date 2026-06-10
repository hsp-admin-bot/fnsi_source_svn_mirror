using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Fnw.StatisticsTool;
using Fnw.StatisticsTool.Data;
using Fnw.StatisticsTool.Helper;
using Fnw.StatisticsTool.FrmLogin;
using NKKWebAccessLib;
using Fnw.StatisticsTool.Models;
using NKKLoggingLib;

namespace Fnw.StatisticsTool
{
    /// <summary>
    /// 
    /// </summary>
    public class StatisticsLib
    {
        #region メンバ変数定義
        private static RestResultData<List<MstFacilityData>> m_MstFacilityData = null;

        #endregion

        #region メンバ関数定義(アプリケーション開始/終了処理)

        /// <summary>
        /// アプリケーション開始前処理を実行します。
        /// </summary>
        /// <returns></returns>
        public static bool PreAppStartUp()
        {
            bool wRet = false;

            try
            {
                // アプリケーション共通開始前処理を実行
                if (!StatisticsUtility.PreAppStartUp())
                {
                    return false;
                }

                // 読み込み済みの情報でサインイン情報を生成
                Login.LoginInfo = new LoginInfo()
                {
                    LoginID = StatisticsUtility.LoginID,
                    Password = StatisticsUtility.Password,
                    FacilityHashText = StatisticsUtility.FacilityHash,
                };

                wRet = true;
            }
            catch (Exception ex)
            {
                StatisticsUtility.RecordException(ex);
            }

            return wRet;
        }

        /// <summary>
        /// アプリケーション開始処理を実行します。
        /// </summary>
        /// <returns></returns>
        public static bool AppStartUp()
        {
            bool wRet = false;

            try
            {
                // アプリケーション共通開始処理を実行
                if (!StatisticsUtility.AppStartUp())
                {
                    return false;
                }

                wRet = true;
            }
            catch (Exception ex)
            {
                StatisticsUtility.RecordException(ex);
            }

            return wRet;
        }

        /// <summary>
        /// アプリケーション終了処理を実行します。
        /// </summary>
        public static void AppEnd()
        {
            try
            {

            }
            finally
            {

            }
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// URIのパラメータ設定
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<NKKWebAccessResponse> GetSysDataSet(SysDataSetRequest request)
        {
            try
            {
                var parameters = new List<string>();

                if (request.SqlCd.HasValue)
                {
                    parameters.Add($"cd={System.Uri.EscapeDataString(request.SqlCd.Value.ToString())}");
                }

                if (request.PatId.HasValue)
                {
                    parameters.Add($"pat={System.Uri.EscapeDataString(request.PatId.Value.ToString())}");
                }

                if (request.OrdNo.HasValue)
                {
                    parameters.Add($"ord={System.Uri.EscapeDataString(request.OrdNo.Value.ToString())}");
                }

                if (!string.IsNullOrEmpty(request.FromDate))
                {
                    parameters.Add($"from={System.Uri.EscapeDataString(request.FromDate)}");
                }

                if (!string.IsNullOrEmpty(request.ToDate))
                {
                    parameters.Add($"to={System.Uri.EscapeDataString(request.ToDate)}");
                }

                if (request.Days.HasValue)
                {
                    parameters.Add($"days={System.Uri.EscapeDataString(request.Days.Value.ToString())}");
                }

                if (!string.IsNullOrEmpty(request.CtlNo))
                {
                    parameters.Add($"ctl={System.Uri.EscapeDataString(request.CtlNo)}");
                }

                if (!string.IsNullOrEmpty(request.OrderClass))
                {
                    parameters.Add($"orderClass={System.Uri.EscapeDataString(request.OrderClass)}");
                }

                if (request.ExamCd.HasValue)
                {
                    parameters.Add($"examCd={System.Uri.EscapeDataString(request.ExamCd.Value.ToString())}");
                }

                if (request.ExamCdBun.HasValue)
                {
                    parameters.Add($"examCdBun={System.Uri.EscapeDataString(request.ExamCdBun.Value.ToString())}");
                }

                if (request.ExamCdCre.HasValue)
                {
                    parameters.Add($"examCdCre={System.Uri.EscapeDataString(request.ExamCdCre.Value.ToString())}");
                }

                if (request.ExamCdBunAfter.HasValue)
                {
                    parameters.Add($"examCdBunAfter={System.Uri.EscapeDataString(request.ExamCdBunAfter.Value.ToString())}");
                }

                if (request.ExamCdCreAfter.HasValue)
                {
                    parameters.Add($"examCdCreAfter={System.Uri.EscapeDataString(request.ExamCdCreAfter.Value.ToString())}");
                }

                //// 処理開始時のタイムスタンプを取得
                //DateTime startTime = DateTime.Now;

                string wUri = $"{NKKWebAccess.BaseUri}{Uri.WEB_APP}{Uri.GET_SYS_DATA_SET}?{string.Join("&", parameters)}";
                var wRestRet = await NKKWebAccess.Get("データの取得", wUri, NKKWebAccess.SKIP_OTP);

                //// 処理終了時のタイムスタンプを取得
                //DateTime endTime = DateTime.Now;

                //// 処理時間を計算
                //TimeSpan elapsed = endTime - startTime;

                //// 処理時間を表示
                //Console.WriteLine($"処理時間: {elapsed.TotalMilliseconds} ミリ秒");

                return wRestRet;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetSysDataSet), NKKLogging.LOGGING_CLASS.ERROR, String.Format("URIのパラメータ設定エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 病名情報の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<DiseaseDataResponse> GetDiseaseData(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetDiseaseData");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new DiseaseDataResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<DiseaseDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetDiseaseData), NKKLogging.LOGGING_CLASS.ERROR, String.Format("病名情報の取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 主病名の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<PrimaryDiseaseDataResponse> GetPrimaryDiseaseData(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetPrimaryDiseaseData");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new PrimaryDiseaseDataResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<PrimaryDiseaseDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetPrimaryDiseaseData), NKKLogging.LOGGING_CLASS.ERROR, String.Format("主病名の取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 治療項目の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<TreatmentDataResponse> GetTreatmentData(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetTreatmentData");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new TreatmentDataResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<TreatmentDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetTreatmentData), NKKLogging.LOGGING_CLASS.ERROR, String.Format("治療項目の取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 死因情報の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<PatDieDataResponse> GetPatDieData(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetPatDieData");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new PatDieDataResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<PatDieDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetPatDieData), NKKLogging.LOGGING_CLASS.ERROR, String.Format("死因情報の取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 施設情報の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<FacilityDataResponse> GetFacilityData(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetFacilityData");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new FacilityDataResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<FacilityDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetFacilityData), NKKLogging.LOGGING_CLASS.ERROR, String.Format("施設情報の取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// バスキュラーアクセス情報の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<VaDataResponse> GetVaData(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetVaData");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new VaDataResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<VaDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetFacilityData), NKKLogging.LOGGING_CLASS.ERROR, String.Format("バスキュラーアクセス情報の取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 検査項目の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<ExamItemDataResponse> GetExamItemData(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetExamItemData");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new ExamItemDataResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<ExamItemDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetExamItemData), NKKLogging.LOGGING_CLASS.ERROR, String.Format("検査項目の取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 患者情報の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<PatPersonalDataResponse> GetPatPersonalData(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetPatPersonalData");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new PatPersonalDataResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<PatPersonalDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetPatPersonalData), NKKLogging.LOGGING_CLASS.ERROR, String.Format("患者情報の取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 指定期間内に実績が1件でも有る患者
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<OrdMainOtherPatDataResponse> GetOrdMainOtherPatData(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetOrdMainOtherPatData");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new OrdMainOtherPatDataResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<OrdMainOtherPatDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetOrdMainOtherPatData), NKKLogging.LOGGING_CLASS.ERROR, String.Format("指定期間内に実績が1件でも有る患者取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 指定期間内の実績から第１透析日のみを取得する
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<DialysisFirstDayDataResponse> GetDialysisFirstDay(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetDialysisFirstDay");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new DialysisFirstDayDataResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<DialysisFirstDayDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetDialysisFirstDay), NKKLogging.LOGGING_CLASS.ERROR, String.Format("指定期間内の実績から第１透析日のみを取得するエラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 患者病歴に糖尿病に該当する病名が存在するかどうか
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<HasDiabetesResponse> GetHasDiabetes(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetHasDiabetes");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new HasDiabetesResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<HasDiabetesDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetHasDiabetes), NKKLogging.LOGGING_CLASS.ERROR, String.Format("患者病歴に糖尿病に該当する病名が存在するかどうかエラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 指定された患者IDの透析導入日
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<PatUniqueInitDateResponse> GetPatUniqueInitDate(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetPatUniqueInitDate");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new PatUniqueInitDateResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<PatUniqueInitDateDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetPatUniqueInitDate), NKKLogging.LOGGING_CLASS.ERROR, String.Format("指定された患者IDの患者が透析導入日エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 指定された患者IDの患者が転入患者であるか調べる
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<MovingInCountResponse> GetMovingInCount(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetMovingInCount");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new MovingInCountResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<MovingInCountDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetMovingInCount), NKKLogging.LOGGING_CLASS.ERROR, String.Format("指定された患者IDの患者が転入患者であるか調べるエラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 指定された患者IDの転入日
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<MovingInDateResponse> GetMovingInDate(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetMovingInDate");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new MovingInDateResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<MovingInDateDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetMovingInDate), NKKLogging.LOGGING_CLASS.ERROR, String.Format("指定された患者IDの転入日エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 透析前収縮期血圧、透析前拡張期血圧、透析前脈拍の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<BpAndPulseResponse> getBpAndPulse(SysDataSetRequest request)
        {
            //Console.WriteLine($"getBpAndPulse");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new BpAndPulseResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<BpAndPulseDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(getBpAndPulse), NKKLogging.LOGGING_CLASS.ERROR, String.Format("透析前収縮期血圧、透析前拡張期血圧、透析前脈拍の取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 住所コード取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<ZipCodeResponse> GetZipCode(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetZipCode");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new ZipCodeResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<ZipCodeDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetZipCode), NKKLogging.LOGGING_CLASS.ERROR, String.Format("住所コード取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }


        /// <summary>
        /// 患者情報の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<PatInfoResponse> GetPatInfo(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetPatInfo");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new PatInfoResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<PatInfoDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetPatInfo), NKKLogging.LOGGING_CLASS.ERROR, String.Format("患者情報の取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 患者情報の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<PatMainInfoResponse> GetPatMainInfo(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetPatMainInfo");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new PatMainInfoResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<PatMainInfoDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetPatMainInfo), NKKLogging.LOGGING_CLASS.ERROR, String.Format("患者情報の取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// オーダ番号の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<LastOrdNoResponse> GetLastOrdNo(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetLastOrdNo");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new LastOrdNoResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<LastOrdNoDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetLastOrdNo), NKKLogging.LOGGING_CLASS.ERROR, String.Format("オーダ番号の取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 転入転出情報の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<MovingOutInfoResponse> GetMovingOutInfo(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetMovingOutInfo");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new MovingOutInfoResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<MovingOutInfoDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetMovingOutInfo), NKKLogging.LOGGING_CLASS.ERROR, String.Format("転入転出情報の取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 透析時間の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<DialysisTimeResponse> GetDialysisTime(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetDialysisTime");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new DialysisTimeResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<DialysisTimeDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetDialysisTime), NKKLogging.LOGGING_CLASS.ERROR, String.Format("透析時間の取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 患者情報の身長取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<HeightResponse> GetHeight(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetHeight");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new HeightResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<HeightDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetHeight), NKKLogging.LOGGING_CLASS.ERROR, String.Format("患者情報の身長取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 転入転出の情報を取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<InOutResponse> GetInOut(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetInOut");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new InOutResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<InOutDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetInOut), NKKLogging.LOGGING_CLASS.ERROR, String.Format("転入転出の情報を取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 転入転出の情報を取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<InOutPatternResponse> GetInOutPattern(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetInOutPattern");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new InOutPatternResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<InOutPatternDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetInOutPattern), NKKLogging.LOGGING_CLASS.ERROR, String.Format("転入転出の情報を取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 治療方法の情報を取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<TreatmentCdResponse> GetTreatmentCd(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetTreatmentCd");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new TreatmentCdResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<TreatmentCdDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetTreatmentCd), NKKLogging.LOGGING_CLASS.ERROR, String.Format("治療方法の情報を取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 指定期間内の透析回数
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<DialysisCountInRangeResponse> GetDialysisCountInRange(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetDialysisCountInRange");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new DialysisCountInRangeResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<DialysisCountInRangeDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetDialysisCountInRange), NKKLogging.LOGGING_CLASS.ERROR, String.Format("指定期間内の透析回数エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 実績データの透析時間取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<IndDialysisCondResponse> GetIndDialysisCond(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetIndDialysisCond");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new IndDialysisCondResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<IndDialysisCondDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetIndDialysisCond), NKKLogging.LOGGING_CLASS.ERROR, String.Format("実績データの透析時間取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 透析実績透析条件データ取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<RstDialysisCondResponse> GetRstDialysisCond(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetRstDialysisCond");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new RstDialysisCondResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<RstDialysisCondDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetRstDialysisCond), NKKLogging.LOGGING_CLASS.ERROR, String.Format("透析実績透析条件データ取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 指定患者の期間内で検査結果を取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<ExamFindingsResponse> GetExamFindings(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetExamFindings");
            try
            {
                var response = await GetSysDataSet(request);

            // 取得結果を格納するオブジェクトを作成
            var itemData = new ExamFindingsResponse
            {
                Success = response.isLogin && response.response.IsSuccessStatusCode,
                Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
            };

            // 取得データを戻り値にセット
            if (itemData.Success)
            {
                itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<ExamFindingsDataType>>.Deserialize(response.strContent);
            }

            return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetExamFindings), NKKLogging.LOGGING_CLASS.ERROR, String.Format("指定患者の期間内で検査結果を取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 指定検査項目の結果を取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<ExamOneSetResponse> GetExamOneSet(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetExamOneSet");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new ExamOneSetResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<ExamOneSetDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetExamOneSet), NKKLogging.LOGGING_CLASS.ERROR, String.Format("指定検査項目の結果を取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 指定検査の結果を検査日指定で取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<ExamOneSetByDateResponse> GetExamOneSetByDate(SysDataSetRequest request)
        {
            //Console.WriteLine($"GetExamOneSetByDate");
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new ExamOneSetByDateResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<ExamOneSetByDateDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(GetExamOneSetByDate), NKKLogging.LOGGING_CLASS.ERROR, String.Format("指定検査の結果を検査日指定で取得エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }
        }

        /// <summary>
        /// 感染症情報の取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<InfectionDataResponse> GetInfectionData(SysDataSetRequest request)
        {
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new InfectionDataResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<InfectionDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                StatisticsUtility.RecordException(ex, true);
                return null;
            }
        }

        /// <summary>
        /// 患者指定の感染症を取得
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public static async Task<InfectOneSetResponse> GetInfectOneSet(SysDataSetRequest request)
        {
            try
            {
                var response = await GetSysDataSet(request);

                // 取得結果を格納するオブジェクトを作成
                var itemData = new InfectOneSetResponse
                {
                    Success = response.isLogin && response.response.IsSuccessStatusCode,
                    Message = response.response.IsSuccessStatusCode ? string.Empty : "データ取得に失敗しました。"
                };

                // 取得データを戻り値にセット
                if (itemData.Success)
                {
                    itemData.Data = JsonDataSerializeHelperForNewtonsoft<List<InfectOneSetDataType>>.Deserialize(response.strContent);
                }

                return itemData;
            }
            catch (Exception ex)
            {
                StatisticsUtility.RecordException(ex, true);
                return null;
            }
        }

        /// <summary>
        /// 施設マスタデータの一覧を取得します。
        /// </summary>
        /// <param name="aIsReload"></param>
        /// <returns></returns>
        public static async Task<RestResultData<List<MstFacilityData>>> GetMstFactilityList(bool aIsReload)
        {
            try
            {
                if (m_MstFacilityData != null && m_MstFacilityData.IsSuccess && !aIsReload)
                {
                    return m_MstFacilityData;
                }

                m_MstFacilityData = new RestResultData<List<MstFacilityData>>();

                string wUri = $"{NKKWebAccess.BaseUri}{Uri.WEB_APP}";

                var wRestRet = await NKKWebAccess.Get("施設マスタ一覧取得", wUri + Uri.GET_MST_FACILITY_DATA, NKKWebAccess.SKIP_OTP);

                // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
                m_MstFacilityData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
                // エラーメッセージを更新
                m_MstFacilityData.ErrorText = MakeRestResultErrorText(wRestRet);

                // 取得データを戻り値にセット
                if (m_MstFacilityData.IsSuccess)
                {
                    m_MstFacilityData.Data = JsonDataSerializeHelper<List<MstFacilityData>>.Deserialize(wRestRet.strContent);
                }

                return m_MstFacilityData;
            }
            catch (Exception ex)
            {
                StatisticsUtility.RecordException(ex, true);
                return null;
            }
        }

        /// <summary>
        /// 指定された数字文字列を数値に変換します。
        /// </summary>
        /// <param name="aValue">変換する文字列</param>
        /// <param name="aIsAllowMinus">負値を許容する場合は True 、それ以外は False</param>
        /// <param name="aInvalidValue">変換できなかった場合に取得する数値(既定値は0)</param>
        /// <returns></returns>
        public static int ConvertStrToInt32(string aValue, bool aIsAllowMinus, int aInvalidValue = 0)
        {
            int wRet = aInvalidValue;
            if (string.IsNullOrWhiteSpace(aValue))
            {
                return wRet;
            }

            try
            {
                // 数値変換を試行
                wRet = Convert.ToInt32(aValue);
                // 負値を許容しない場合は追加でチェック
                if (!aIsAllowMinus && wRet < 0)
                {
                    wRet = aInvalidValue;
                }
            }
            catch
            {
                wRet = aInvalidValue;
            }

            return wRet;
        }

        /// <summary>
        /// 指定された数字文字列を数値に変換します。
        /// </summary>
        /// <param name="aValue"></param>
        /// <param name="aIsAllowMinus"></param>
        /// <param name="aInvalidValue"></param>
        /// <returns></returns>
        public static decimal ConvertStrToDecimal(string aValue, bool aIsAllowMinus, decimal aInvalidValue = 0m)
        {
            decimal wRet = aInvalidValue;
            if (string.IsNullOrWhiteSpace(aValue))
            {
                return wRet;
            }

            try
            {
                // 数値変換を試行
                wRet = Convert.ToDecimal(aValue);
                // 負値を許容しない場合は追加でチェック
                if (!aIsAllowMinus && wRet < 0)
                {
                    wRet = aInvalidValue;
                }
            }
            catch
            {
                wRet = aInvalidValue;
            }

            return wRet;
        }

        /// <summary>
        /// NKKWebAccessResponse の内容からエラーメッセージを作成します。
        /// </summary>
        /// <param name="aRestResult"></param>
        /// <returns></returns>
        public static string MakeRestResultErrorText(NKKWebAccessResponse aRestResult)
        {
            string wRet = string.Empty;

            if (!aRestResult.isLogin)
            {
                wRet = "サーバへの接続に失敗しました。";
            }
            else
            {
                wRet = aRestResult.response.StatusCode.ToString();
            }

            return wRet;
        }
        #endregion
    }
}
