using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;
using LayoutDesigner.Data;
using LayoutDesignerUtilityLib;
using Newtonsoft.Json;
using NKKWebAccessLib;
using RldMsgBox = LayoutDesignerUtilityLib.RldMessageBox;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票レイアウトデザイナ共通パラメータクラス
    /// </summary>
    public class RldLib
    {
        #region メンバ定数定義

        /// <summary>
        /// スーパーユーザ用ID
        /// </summary>
        private const string SUPER_USER_LOGIN_ID = "";
        /// <summary>
        /// スーパーユーザ用パスワード
        /// </summary>
        private const string SUPER_USER_PASSOWRD = "";

        #endregion

        #region メンバ列挙体定義

        /// <summary>
        /// 帳票種別
        /// </summary>
        public enum EnumReportType
        {
            /// <summary>
            /// 未定義
            /// </summary>
            None,
            /// <summary>
            /// 透析レポート
            /// </summary>
            Dialysis,
            /// <summary>
            /// 単患者帳票
            /// </summary>
            OnePatient,
            /// <summary>
            /// 複数患者帳票
            /// </summary>
            MultiPatient,
            /// <summary>
            /// 準備リスト
            /// </summary>
            EquipmentList,
            /// <summary>
            /// 配布リスト(ベッド)
            /// </summary>
            DistributeListBed,
            /// <summary>
            /// 配布リスト(機材)
            /// </summary>
            DistributeListEquipment,
            /// <summary>
            /// 装置帳票
            /// </summary>
            Device,
            /// <summary>
            /// ラベル
            /// </summary>
            Label,
            // add FNSI-523 2次元帳票対応 夏 start
            /// <summary>
            /// 単一集計
            /// </summary>
            OneTotal,
            /// <summary>
            /// 複数集計
            /// </summary>
            MultiTotal
            // add FNSI-523 2次元帳票対応 夏 end
        }

        #endregion

        #region メンバ変数定義

        /// <summary>
        /// Excel 制御ヘルパークラス
        /// </summary>
        private static RldExcelHelper m_XlHelper = null;

        /// <summary>
        /// 帳票マスタデータ
        /// </summary>
        private static RldRestResultData<List<MstReportData>> m_MstReportData = null;

        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        /// <summary>
        /// 施設マスタデータ
        /// </summary>
        private static RldRestResultData<List<MstFacilityData>> m_MstFacilityData = null;
        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end

        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
        /// <summary>
        /// 日常・定期点検レイアウトマスタデータ
        /// </summary>
        private static RldRestResultData<List<MstMainteLayoutData>> m_MstMainteLayoutData = null;
        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end

		// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
        /// <summary>
        /// 装置型式マスタデータ
        /// </summary>
        private static RldRestResultData<List<MstMachineTypeData>> m_MstMachineTypeData = null;
		// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

        #endregion

        #region メンバプロパティ定義
        public static string WorkTempXlsxFilePath => string.Format("{0}{1}{2}", RldUtility.WorkDirPath, System.IO.Path.DirectorySeparatorChar, RldConst.FILE_NAME_WORK_XLSX_TEMP);
        /// <summary>
        /// 作業用 Excel ファイルへのフルパスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public static string WorkXlsxFilePath => string.Format("{0}{1}{2}", RldUtility.WorkDirPath, System.IO.Path.DirectorySeparatorChar, RldConst.FILE_NAME_WORK_XLSX);

        /// <summary>
        /// プレビュー表示用 html ファイルへのフルパスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public static string PreviewHtmlFilePath => string.Format("{0}{1}{2}", RldUtility.WorkDirPath, System.IO.Path.DirectorySeparatorChar, RldConst.FILE_NAME_PREV_HTML);

        /// <summary>
        /// プレビュー表示用 html ファイルの関連ディレクトリへのフルパスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public static string PreviewHtmlRelationDirPath => string.Format("{0}{1}{2}", RldUtility.WorkDirPath, System.IO.Path.DirectorySeparatorChar, RldConst.DIR_NAME_PREV_FILES);

        /// <summary>
        /// Excel 制御ヘルパークラスへの参照の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public static RldExcelHelper XlHelper
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                if (m_XlHelper == null)
                {
                    m_XlHelper = new RldExcelHelper();
                }

                return m_XlHelper;
            }
        }

        /// <summary>
        /// 帳票種別リストの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public static List<ReportTypeData> ReportClassList { get; } = new List<ReportTypeData>();

        /// <summary>
        /// 現在編集中の帳票の取得及び設定を行います。
        /// </summary>
        public static MstReportData CurrentReport { get; set; } = null;

        /// <summary>
        /// 現在編集中のレイアウトデータの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public static LayoutDataSet CurrentLayoutData { get; } = new LayoutDataSet();

        /// <summary>
        /// 現在使用中のフィルタデータの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public static FilterDataSet FilterDataSet { get; } = new FilterDataSet();

        /// <summary>
        /// ドラッグアンドドロップ中かどうかの取得及び設定を行います。
        /// </summary>
        public static bool IsRunningDragDrop { get; set; } = false;

        /// <summary>
        /// デザインウィンドウが閉じられようとしているかどうかの取得及び設定を行います。
        /// </summary>
        public static bool IsStartDesignWindowClosing { get; set; } = false;

        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
        /// <summary>
        /// 帳票区分の取得及び設定を行います。
        /// </summary>
        public static InspectionLayoutData inspectionLayoutData = new InspectionLayoutData();
        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end

        // add FNSI-523 2次元帳票対応 夏 start
        /// <summary>
        /// 2次元帳票データの取得及び設定を行います。
        /// </summary>
        public static TotalLayoutData totalLayoutData = new TotalLayoutData();
        // add FNSI-523 2次元帳票対応 夏 end

        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
        /// <summary>
        ///  旧帳票のテンプレート繰返しモードデータの取得及び設定を行います。
        /// </summary>
        public static string StrRepeatMode { get; set; } = string.Empty;
        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end


        // add #8335 FNW帳票取込みの動作に問題あり 夏 start
        /// <summary>
        /// 旧帳票の取得及び設定を行います。
        /// </summary>
        public static String StrOldFileName { get; set; } = String.Empty;
        /// <summary>
        /// 旧帳票の取得及び設定を行います。
        /// </summary>
        // add #8335 FNW帳票取込みの動作に問題あり 夏 end

        // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 start
        /// <summary>
        /// レイアウトシートで保存するのを行います。
        /// </summary>
        public static Boolean IsSaveLayoutSheet { get; set; } = false;
        // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 end

        // add #11535 帳票の汎用バーコード出力対応 高 start
        public static System.Collections.Generic.Dictionary<string, string> barCodeDic = new System.Collections.Generic.Dictionary<string, string>
        {
             { "", "" }
            ,{ "NW-7(Codabar)", "CODABAR" }
            ,{ "Code 39", "CODE_39" }
            ,{ "Code 128", "CODE_128" }
            ,{ "二次元バーコード", "QR_CODE" }
        };
        // add #11535 帳票の汎用バーコード出力対応 高 end

        // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 start
        public static Boolean IsWorkXlsx { get; set; } = false;
        // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 end

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
                if (!RldUtility.PreAppStartUp())
                {
                    return false;
                }

                // 読み込み済みの情報でサインイン情報を生成
                SignInLib.SignIn.SignInInfo = new SignInLib.SignInInfo()
                {
                    LoginID = RldUtility.LoginID,
                    Password = RldUtility.Password,
                    FacilityHashText = RldUtility.FacilityHash,
                };

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex);
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
                if (!RldUtility.AppStartUp())
                {
                    return false;
                }

                // データ項目リストファイルから帳票種別と帳票種別名を読み込み
                LoadReportTypeList();

                // バックアップファイル保存先ディレクトリの存在を確認し無ければ作成
                foreach (ReportTypeData wData in ReportClassList)
                {
                    if (!string.IsNullOrEmpty(wData.ReportClassName))
                    {
                        RldUtility.CheckAndCreateDirectory(GetBackupDirPath(wData.ReportClass));
                    }
                }

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex);
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

        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
        /// <summary>
        /// 日常・定期点検レイアウトマスタの点検レイアウトコードとレイアウト名を取得します。
        /// </summary>
        /// <returns></returns>
        public static async Task<RldRestResultData<List<MstMainteLayoutData>>> GetMstMainteLayoutList()
        {
            try
            {
                m_MstMainteLayoutData = new RldRestResultData<List<MstMainteLayoutData>>();

                // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
                //string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}{RldConst.Uri.GET_MST_MAINTE_LAYOUT}/{RldLib.inspectionLayoutData.UseCD}";
                String wUri = String.Format("{0}{1}{2}/{3}/{4}",
                    NKKWebAccess.BaseUri,
                    RldConst.Uri.WEB_APP,
                    RldConst.Uri.GET_MST_MAINTE_LAYOUT,
                    LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd,
                    RldLib.inspectionLayoutData.UseCD
                    );
                // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end

                var wRestRet = await NKKWebAccess.Get("日常・定期点検レイアウトマスタの点検レイアウトコードとレイアウト名取得", wUri, NKKWebAccess.SKIP_OTP);

                // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
                m_MstMainteLayoutData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
                // エラーメッセージを更新
                m_MstMainteLayoutData.ErrorText = MakeRestResultErrorText(wRestRet);

                // 取得データを戻り値にセット
                if (m_MstMainteLayoutData.IsSuccess)
                {
                    m_MstMainteLayoutData.Data = RldJsonDataSerializeHelper<List<MstMainteLayoutData>>.Deserialize(wRestRet.strContent);
                }

                return m_MstMainteLayoutData;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, true);
                return null;
            }
        }
        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end

		// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
        /// <summary>
        /// 装置型式マスタの型式コードと型式名を取得します。
        /// </summary>
        /// <returns></returns>
        public static async Task<RldRestResultData<List<MstMachineTypeData>>> GetMstMachineTypeList()
        {
            try
            {
                m_MstMachineTypeData = new RldRestResultData<List<MstMachineTypeData>>();

                String wUri = String.Format("{0}{1}{2}/{3}/{4}",
                    NKKWebAccess.BaseUri,
                    RldConst.Uri.WEB_APP,
                    RldConst.Uri.GET_MST_MACHINE_TYPE,
                    LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd,
                    RldLib.inspectionLayoutData.UseCD
                    );

                var wRestRet = await NKKWebAccess.Get("装置型式マスタの型式コードと型式名取得", wUri, NKKWebAccess.SKIP_OTP);

                // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
                m_MstMachineTypeData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
                // エラーメッセージを更新
                m_MstMachineTypeData.ErrorText = MakeRestResultErrorText(wRestRet);

                // 取得データを戻り値にセット
                if (m_MstMachineTypeData.IsSuccess)
                {
                    m_MstMachineTypeData.Data = RldJsonDataSerializeHelper<List<MstMachineTypeData>>.Deserialize(wRestRet.strContent);
                }

                return m_MstMachineTypeData;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, true);
                return null;
            }
        }
		// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

        /// <summary>
        /// 帳票マスタデータの一覧を取得します。
        /// </summary>
        /// <param name="aIsReload"></param>
        /// <returns></returns>
        public static async Task<RldRestResultData<List<MstReportData>>> GetMstReportList(bool aIsReload)
        {
            try
            {
                if (m_MstReportData != null && m_MstReportData.IsSuccess && !aIsReload)
                {
                    return m_MstReportData;
                }

                m_MstReportData = new RldRestResultData<List<MstReportData>>();

                string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}{RldConst.Uri.GET_MST_REPORT}";

                var wRestRet = await NKKWebAccess.Get("帳票マスタ一覧取得", wUri, NKKWebAccess.SKIP_OTP);

                // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
                m_MstReportData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
                // エラーメッセージを更新
                m_MstReportData.ErrorText = MakeRestResultErrorText(wRestRet);

                // 取得データを戻り値にセット
                if (m_MstReportData.IsSuccess)
                {
                    m_MstReportData.Data = RldJsonDataSerializeHelper<List<MstReportData>>.Deserialize(wRestRet.strContent);
                }

                return m_MstReportData;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, true);
                return null;
            }
        }

        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        /// <summary>
        /// 帳票マスタデータの一覧を取得します。
        /// </summary>
        /// <param name="aIsReload"></param
        /// <param name="facilityCd"></param>
        /// <returns></returns>
        public static async Task<RldRestResultData<List<MstReportData>>> GetMstReportListOtherFacilityCd(bool aIsReload, string facilityCd)
        {
            try
            {
                if (m_MstReportData != null && m_MstReportData.IsSuccess && !aIsReload)
                {
                    return m_MstReportData;
                }

                m_MstReportData = new RldRestResultData<List<MstReportData>>();

                string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}{RldConst.Uri.GET_MST_REPORT}/{facilityCd}/facilityCd";

                var wRestRet = await NKKWebAccess.Get("帳票マスタ一覧取得", wUri, NKKWebAccess.SKIP_OTP);

                // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
                m_MstReportData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
                // エラーメッセージを更新
                m_MstReportData.ErrorText = MakeRestResultErrorText(wRestRet);

                // 取得データを戻り値にセット
                if (m_MstReportData.IsSuccess)
                {
                    m_MstReportData.Data = RldJsonDataSerializeHelper<List<MstReportData>>.Deserialize(wRestRet.strContent);
                }

                return m_MstReportData;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, true);
                return null;
            }
        }

        /// <summary>
        /// 施設マスタデータの一覧を取得します。
        /// </summary>
        /// <param name="aIsReload"></param>
        /// <returns></returns>
        public static async Task<RldRestResultData<List<MstFacilityData>>> GetMstFactilityList(bool aIsReload)
        {
            try
            {
                if (m_MstFacilityData != null && m_MstFacilityData.IsSuccess && !aIsReload)
                {
                    return m_MstFacilityData;
                }

                m_MstFacilityData = new RldRestResultData<List<MstFacilityData>>();

                string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}";

                var wRestRet = await NKKWebAccess.Get("施設マスタ一覧取得", wUri + RldConst.Uri.GET_MST_FACILITY_DATA, NKKWebAccess.SKIP_OTP);

                // ログイン状態を維持していて成功応答の場合は戻り値を成功にセット
                m_MstFacilityData.IsSuccess = wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode;
                // エラーメッセージを更新
                m_MstFacilityData.ErrorText = MakeRestResultErrorText(wRestRet);

                // 取得データを戻り値にセット
                if (m_MstFacilityData.IsSuccess)
                {
                    m_MstFacilityData.Data = RldJsonDataSerializeHelper<List<MstFacilityData>>.Deserialize(wRestRet.strContent);
                }

                return m_MstFacilityData;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, true);
                return null;
            }
        }
        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end

        /// <summary>
        /// 帳票マスタデータを更新します。
        /// </summary>
        /// <param name="aList">更新する帳票マスタデータ</param>
        /// <param name="aIsAddNew">追加する場合 True。更新する場合 False。</param>
        /// <returns></returns>
        public static async Task<KeyValuePair<bool, string>> PutMstReportList(List<MstReportData> aList)
        {
            var wRet = new KeyValuePair<bool, string>(false, string.Empty);
            NKKWebAccessResponse wRestRet = null;

            try
            {
                string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}{RldConst.Uri.POST_MST_REPORT}/{LayoutDesignerUtility.CurrentFacilityCd}/list_data";

                // JSON データ生成
                var wJsonData = RldJsonDataSerializeHelper<List<MstReportData>>.Serialize(aList);
                // 編集の場合は PUT 処理
                wRestRet = await NKKWebAccess.Put("帳票マスタデータ更新", wUri, wJsonData, NKKWebAccess.SKIP_OTP);

                wRet = new KeyValuePair<bool, string>(
                    wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode,
                    string.Format("{0}:{1}", wRestRet.response.StatusCode, wRestRet.response.ReasonPhrase));
            }
            catch (Exception ex)
            {
                // 例外情報を生成
                var wEx = new System.ApplicationException("データ更新に失敗しました。", ex);
                // 例外情報を記録(画面にメッセージボックスを表示)
                RldUtility.RecordException(wEx, false);
            }

            return wRet;
        }

        /// <summary>
        /// 帳票の選択された履歴の変更
        /// </summary>
        /// <param name="reportCd"></param>
        /// <param name="selectedHistory"></param>
        /// <returns></returns>
        public static async Task<KeyValuePair<bool, string>> ChangeSelectedHistoryInfo(string reportCd, string selectedHistory)
        {
            var wRet = new KeyValuePair<bool, string>(false, string.Empty);
            NKKWebAccessResponse wRestRet = null;

            try
            {
                
                string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}";

                // JSON データ生成
                Dictionary<string, string> request = new Dictionary<string, string>
                {
                    { "reportCd", reportCd },
                    { "selectedHistory", selectedHistory }
                };

                var wJsonData = JsonConvert.SerializeObject(request, Formatting.Indented);
                wRestRet = await NKKWebAccess.Put("帳票マスタデータ更新", wUri + RldConst.Uri.PUT_MST_REPORT_NO, wJsonData, NKKWebAccess.SKIP_OTP);

                if (wRestRet.strContent.Equals("noExist"))
                {
                    MessageBox.Show("選択された版のファイルは存在しませんでした。他の版を選択してください。", "ファイルがみつかりません");
                    return new KeyValuePair<bool, string>(false, string.Empty);
                }

                // 結果取得
                wRet = new KeyValuePair<bool, string>(
                    wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode,
                    string.Format("{0}:{1}", wRestRet.response.StatusCode, wRestRet.response.ReasonPhrase));
            }
            catch (Exception ex)
            {
                // 例外情報を生成
                var wEx = new System.ApplicationException("データ更新に失敗しました。", ex);
                // 例外情報を記録(画面にメッセージボックスを表示)
                RldUtility.RecordException(wEx, false);
            }

            return wRet;
        }

        //add 6854 装置帳票：定期・日常が分離されていない 吉  start
        public static async Task<MstReportData> checkRepeat(MstReportData wData)
        {
            var wRet = new KeyValuePair<bool, string>(false, string.Empty);
            NKKWebAccessResponse wRestRet = null;

            try
            {
                string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}";

                // JSON データ生成()
                var wJsonData = RldJsonDataSerializeHelper<MstReportData>.Serialize(wData);
                wRestRet = await NKKWebAccess.Put("帳票マスタデータ更新", wUri + RldConst.Uri.PUT_MST_REPORT_CHECK_REPEAT, wJsonData, NKKWebAccess.SKIP_OTP);
                if (wRestRet.response.IsSuccessStatusCode)
                {
                    MstReportData reportInfo = RldJsonDataSerializeHelper<MstReportData>.Deserialize(wRestRet.strContent);
                    return reportInfo;
                }
                else
                {
                    return null;
                }
            }
            catch (Exception ex)
            {
                // 例外情報を生成
                var wEx = new System.ApplicationException("データ更新に失敗しました。", ex);
                // 例外情報を記録(画面にメッセージボックスを表示)
                RldUtility.RecordException(wEx, false);
                return null;
            }
        }
        //add 6854  装置帳票：定期・日常が分離されていない 吉  end

        // add #12589 どこかで使用している帳票も削除出来てしまう 高 start
        public static async Task<KeyValuePair<bool, string>> checkDelRepeat(List<MstReportData> aList)
        {
            var wRet = new KeyValuePair<bool, string>(true, string.Empty);
            NKKWebAccessResponse wRestRet = null;

            if (aList == null || aList.Count <= 0)
                return wRet;

            try
            {
                string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}{RldConst.Uri.POST_MST_REPORT}/{LayoutDesignerUtility.CurrentFacilityCd}/checkIsCanDelete";

                // JSON データ生成
                var wJsonData = RldJsonDataSerializeHelper<List<MstReportData>>.Serialize(aList);
                // 編集の場合は PUT 処理
                wRestRet = await NKKWebAccess.Put("帳票マスタデータ削除", wUri, wJsonData, NKKWebAccess.SKIP_OTP);

                if (wRestRet.response.IsSuccessStatusCode)
                {
                    if (string.IsNullOrEmpty(wRestRet.strContent))
                        return wRet;

                    return new KeyValuePair<bool, string>(false, wRestRet.strContent);
                }

                return wRet;
            }
            catch (Exception ex)
            {}

            return wRet;
        }
        // add #12589 どこかで使用している帳票も削除出来てしまう 高 end

        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        /// <summary>
        /// 帳票マスタデータを更新します。
        /// </summary>
        /// <param name="aData">帳票マスタに書き込むデータ</param>
        /// <param name="aIsAddNew">帳票マスタに追加する場合 True。更新する場合 False。</param>
        /// <param name="newS3Path"></param>
        /// <returns></returns>
        public static async Task<KeyValuePair<bool, string>> PutMstReportDataOtherFacilityCd(MstReportData aData, bool aIsAddNew, String newS3Path) =>
            await PutMstReportListOtherFacilityCd(new List<MstReportData>() { aData }, aIsAddNew, newS3Path);

        /// <summary>
        /// 帳票マスタデータを更新します。
        /// </summary>
        /// <param name="aList">更新する帳票マスタデータ</param>
        /// <param name="aIsAddNew">追加する場合 True。更新する場合 False。</param>
        /// <param name="newS3Path"></param>
        /// <returns></returns>
        public static async Task<KeyValuePair<bool, string>> PutMstReportListOtherFacilityCd(List<MstReportData> aList, bool aIsAddNew, String newS3Path)
        {
            var wRet = new KeyValuePair<bool, string>(false, string.Empty);
            NKKWebAccessResponse wRestRet = null;

            try
            {
                if (aIsAddNew)
                {
                    foreach (var wData in aList)
                    {
                        String tempS3Bucket = String.Empty;
                        string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}{RldConst.Uri.POST_MST_REPORT}/{LayoutDesignerUtility.CurrentFacilityCd}/insert";
                        tempS3Bucket = wData.ReportPath.S3Bucket;
                        wData.ReportPath.S3Bucket = newS3Path;
                        wData.ReportHstInfo.ReportHstList.ForEach(i => i.S3Bucket = newS3Path);
                        // JSON データ生成()
                        var wJsonData = RldJsonDataSerializeHelper<MstReportData>.Serialize(wData);
                        // 新規追加の場合は POST 処理
                        wRestRet = await NKKWebAccess.Post("帳票マスタデータ追加", wUri, wJsonData, NKKWebAccess.SKIP_OTP);
                        wData.ReportPath.S3Bucket = tempS3Bucket;
                        wData.ReportHstInfo.ReportHstList.ForEach(i => i.S3Bucket = tempS3Bucket);
                        // エラーが発生した場合は抜ける
                        if (!wRestRet.isLogin || !wRestRet.response.IsSuccessStatusCode)
                        {
                            break;
                        }
                    }
                }
                else
                {
                    String tempS3Bucket = String.Empty;
                    foreach (var wData in aList)
                    {
                        tempS3Bucket = wData.ReportPath.S3Bucket;
                        wData.ReportPath.S3Bucket = newS3Path;
                        wData.ReportHstInfo.ReportHstList.ForEach(i =>
                        {
                            if (int.Parse(i.CtlNo) == wData.ReportHstInfo.ReportHstList.Count)
                            {
                                i.S3Bucket = newS3Path;
                            }
                        });
                    }
                    string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}{RldConst.Uri.POST_MST_REPORT}/{LayoutDesignerUtility.CurrentFacilityCd}/update";
                    // JSON データ生成
                    var wJsonData = RldJsonDataSerializeHelper<List<MstReportData>>.Serialize(aList);
                    foreach (var wData in aList)
                    {
                        wData.ReportPath.S3Bucket = tempS3Bucket;
                        wData.ReportHstInfo.ReportHstList.ForEach(i =>
                        {
                            if (int.Parse(i.CtlNo) == wData.ReportHstInfo.ReportHstList.Count)
                            {
                                i.S3Bucket = tempS3Bucket;
                            }
                        });
                    }
                    // 編集の場合は PUT 処理
                    wRestRet = await NKKWebAccess.Put("帳票マスタデータ更新", wUri, wJsonData, NKKWebAccess.SKIP_OTP);
                }

                if (wRestRet.strContent != "")
                {
                    Dictionary<String, String> json = NKKWebAccess.GetJsonData(wRestRet.strContent);
                    if (json["reportCd"] != "")
                    {
                        RldLib.CurrentReport.ReportCode = long.Parse(json["reportCd"]);
                    }
                }

                // 結果取得
                wRet = new KeyValuePair<bool, string>(
                    wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode,
                    string.Format("{0}:{1}", wRestRet.response.StatusCode, wRestRet.response.ReasonPhrase));
            }
            catch (Exception ex)
            {
                // 例外情報を生成
                var wEx = new System.ApplicationException("データ更新に失敗しました。", ex);
                // 例外情報を記録(画面にメッセージボックスを表示)
                RldUtility.RecordException(wEx, false);
            }

            return wRet;
        }

        /// <summary>
        /// 一時ファイル保存先ディレクトリへのフルパスの取得を行います。
        /// </summary>
        /// <returns></returns>
        public static string GetTempXlsDirPath() => RldUtility.TempDirPath;

        /// <summary>
        /// 帳票種別毎のサンプルレイアウトファイル保存先ディレクトリへのフルパスの取得を行います。
        /// </summary>
        /// <param name="aReportType"></param>
        /// <returns></returns>
        public static string GetModelDirPath(string aReportType) =>
            string.Format("{0}{1}{2}", RldUtility.ModelDirPath, System.IO.Path.DirectorySeparatorChar, aReportType);

        /// <summary>
        /// 帳票種別毎のバックアップファイル保存先ディレクトリへのフルパスの取得を行います。
        /// </summary>
        /// <param name="aReportType"></param>
        /// <returns></returns>
        public static string GetBackupDirPath(string aReportType) =>
            $"{RldUtility.BackupDirPath}{System.IO.Path.DirectorySeparatorChar}{aReportType}";

        /// <summary>
        /// 一時ファイル保存先ディレクトリをクリアします。
        /// </summary>
        public static void ClearTempXlsDirPath()
        {
            string wTarget = GetTempXlsDirPath();
            try
            {
                System.IO.Directory.GetDirectories(wTarget).ToList().ForEach(ele => RldUtility.DeleteDirectoryIfExists(ele));
                System.IO.Directory.GetFiles(wTarget).ToList().ForEach(ele => RldUtility.DeleteFileIfExists(ele));
            }
            finally
            {
            }
        }

        /// <summary>
        /// ２つの XML タグ名が等しいか確認します。
        /// </summary>
        /// <param name="aTagA"></param>
        /// <param name="aTagB"></param>
        /// <returns></returns>
        public static bool IsEqualXmlTagName(string aTagA, string aTagB) => aTagA == aTagB;

        /// <summary>
        /// ２つの XML 属性名が等しいか確認します。
        /// </summary>
        /// <param name="aAttributeA"></param>
        /// <param name="aAttributeB"></param>
        /// <returns></returns>
        public static bool IsEqualXmlAttName(string aAttributeA, string aAttributeB) => aAttributeA == aAttributeB;

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
        /// 全てのパラメータ編集データに対してテンプレート内外状態を更新します。
        /// </summary>
        /// <returns></returns>
        /// //edit #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong start
        public static bool UpdateDesignParamDataIsInTemplete(string total = "")
        //edit #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong end
        {
            bool wRet = false;
            // add #8314 グループタブの表示不正 王占宇 start
            DesignParamDatasList designParamDatasList = new DesignParamDatasList();
            // add #8314 グループタブの表示不正 王占宇 end
            try
            {
                using (var wXlRangeTemplete = new ExcelRangeEx(XlHelper.XlSheetLayout, CurrentLayoutData.DesignTempleteData.Range))
                {

                    // テンプレート領域を取得
                    var wTempleteArea = wXlRangeTemplete.GetRectangle();

                    for (int i = 0; i < CurrentLayoutData.DesignParamList.Count; i++)
                    {

                        var wData = CurrentLayoutData.DesignParamList[i];

                        // テンプレート内外状態を更新
                        using (var wXlRange = new ExcelRangeEx(XlHelper.XlSheetLayout, wData.CellAddress))
                        {
                            // mod #11556 「##=」型の計算式で関数が使用できなくなっている 高 start
                            //wData.IsInTemplete = GetIsInTemplete(wTempleteArea, wXlRange.GetRectangle());
                            wData.IsInTemplete = GetIsInTemplete(wXlRange.Range.Address[false, false], wXlRangeTemplete.Range.Address[false, false]);
                            // mod #11556 「##=」型の計算式で関数が使用できなくなっている 高 end
                            // add #8314 グループタブの表示不正 王占宇 start
                            designParamDatasList.Add(wData);
                            // add #8314 グループタブの表示不正 王占宇 end
                        }
                        // del #8314 グループタブの表示不正 王占宇 start
                        // if (wRet = CurrentLayoutData.SetDesignParamData(wData, i) == false)
                        // {
                        //     return false;
                        // }
                        // del #8314 グループタブの表示不正 王占宇 end

                    }
                    // add #8314 グループタブの表示不正 王占宇 start
                    FilterDesignGroupData(designParamDatasList);

                    for (int j = 0; j < designParamDatasList.Count; j++)
                    {
                        var wData = designParamDatasList[j];
                        if (wRet = CurrentLayoutData.SetDesignParamData(wData, j) == false)
                        {
                            return false;
                        }
                    }
                    //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong start
                    if (total != "")
                    {
                        List<string> totalTotalList = new List<string>(total.Trim().Split(','));
                        List<string> readOnly = new List<string>();
                        List<DesignGroupData> groupList = RldLib.CurrentLayoutData.DesignGroupList.ToList();
                        foreach (var wList in totalTotalList)
                        {
                            foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                            {
                                if (!readOnly.Contains(wData.GroupName))
                                {
                                    RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, true);
                                }

                                if (wData.DataPath.Equals(wList))
                                {
                                    foreach (var groupData in groupList)
                                    {
                                        if (readOnly.Count == 0)
                                        {
                                            if (groupData.GroupName == wData.GroupName && groupData.IsInTemplete == wData.IsInTemplete)
                                            {
                                                groupData.IsNewPage = "";
                                                RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, false);
                                                readOnly.Add(groupData.GroupName);
                                                break;
                                            }
                                        }
                                        else
                                        {
                                            if (!readOnly.Contains(groupData.GroupName))
                                            {
                                                if (groupData.GroupName == wData.GroupName && groupData.IsInTemplete == wData.IsInTemplete)
                                                {
                                                    groupData.IsNewPage = "";
                                                    RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, false);
                                                    readOnly.Add(groupData.GroupName);
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong end
                    // add #8314 グループタブの表示不正 王占宇 end
                }

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        // add #8314 グループタブの表示不正 王占宇 start
        private static void FilterDesignGroupData(DesignParamDatasList designParamDatasList)
        {
            List<DesignGroupData> tempList = RldLib.XlHelper.GetSheetGroupDataList().ToList();
            List<DesignGroupData> addTempList = new List<DesignGroupData>();
            // mod #8314 グループタブの表示不正 王占宇 start
            // RldLib.CurrentLayoutData.DesignGroupList.Clear();
            List<DesignGroupData> itemList = new List<DesignGroupData>();
            itemList = RldLib.CurrentLayoutData.DesignGroupList.ToList();
            itemList.ForEach(p => RldLib.CurrentLayoutData.DesignGroupList.Remove(p));
            // mod #8314 グループタブの表示不正 王占宇 end
            if (RldLib.CurrentLayoutData.DesignTempleteData == null)
            {
                return;
            }
            if (string.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignTempleteData.Range))
            {
                return;
            }
            try
            {
                using (var wXlRangeTemplete = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, RldLib.CurrentLayoutData.DesignTempleteData.Range))
                {
                    // テンプレート領域を取得
                    var wTempleteArea = wXlRangeTemplete.GetRectangle();

                    for (int i = 0; i < designParamDatasList.Count; i++)
                    {
                        var wData = designParamDatasList[i];

                        // テンプレート内外状態を更新
                        using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, wData.CellAddress))
                        {
                            if (RldLib.CurrentLayoutData.DesignSettingData.IsSupportTempleteRepeat)
                            {
                                // 帳票種別としてテンプレート繰返しをサポートしている場合は "外"

                                if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
                                {
                                    // テンプレート繰返しの設定を行っている場合は範囲に入っているか確認
                                    if (wTempleteArea.Contains(wXlRange.GetRectangle()))
                                    {
                                        if (tempList.Where(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                         == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_IN).ToList().Count > 0)
                                        {
                                            addTempList.Add(tempList.FirstOrDefault(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                            == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_IN));
                                        }
                                    }
                                    else
                                    {
                                        if (tempList.Where(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                         == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_OUT).ToList().Count > 0)
                                        {
                                            addTempList.Add(tempList.FirstOrDefault(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                            == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_OUT));
                                        }

                                    }
                                }
                                else
                                {
                                    if (tempList.Where(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                         == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE).ToList().Count > 0)
                                    {
                                        addTempList.Add(tempList.FirstOrDefault(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                        == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE));
                                    }
                                }
                            }
                        }
                    }
                }
                var newList = addTempList.GroupBy(p => new { p.GroupName, p.IsInTemplete });
                List<DesignGroupData> newAddTempList = new List<DesignGroupData>();
                foreach (var item in newList)
                {
                    newAddTempList.Add(item.ToList()[0]);
                }
                // グループシート読み込み
                // RldLib.CurrentLayoutData.DesignGroupList.Clear();
                newAddTempList.ForEach(ele => RldLib.CurrentLayoutData.DesignGroupList.Add(ele));
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }
        }
        // add #8314 グループタブの表示不正 王占宇 end

        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
        /// <summary>
        /// 旧帳票のグループシート読み込む処理により、グループリストを更新して保存する。
        /// </summary>
        /// <returns></returns>
        public static bool UpdateDesignGroupDataFromOldReport()
        {
            bool wRet = false;

            try
            {
                for (int i = 0; i < CurrentLayoutData.DesignGroupList.Count; i++)
                {
                    DesignGroupData wData = CurrentLayoutData.DesignGroupList[i];

                    foreach (var wDataforConvert in CurrentLayoutData.DataGroupFromOldReportList)
                    {
                        // mod #12050 FNW帳票コンバートで維持されない設定がある 高 start
                        //if (wDataforConvert.GroupPath == wData.GroupPath)
                        if (wDataforConvert.GroupName == wData.GroupName && wDataforConvert.IsInTemplete == wData.IsInTemplete)
                        // mod #12050 FNW帳票コンバートで維持されない設定がある 高 end
                        {
                            wData.IsNewPage = wDataforConvert.IsNewPage;
                            continue;
                        }
                    }

                    // 該当インデックスのデータを更新
                    CurrentLayoutData.DesignGroupList[i] = wData;
                }

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }
        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

        /// <summary>
        /// 新規作成したパラメータ編集データに不足情報を付加します。
        /// </summary>
        /// <param name="aTarget"></param>
        /// <returns></returns>
        public static DesignParamData ApplyAdditionalInfoToParamData(DesignParamData aTarget)
        {
            // add 2020-08-05 FNSI-仕様修正 修正パラメータを空にするバグ問題 李 start
            if (aTarget == null)
                return null;
            // add 2020-08-05 FNSI-仕様修正 修正パラメータを空にするバグ問題 李 end

            DesignParamData wRet = aTarget;

            // パラメータ編集データの配置セルを生成
            using (var wXlRange = new ExcelRangeEx(XlHelper.XlSheetLayout, wRet.CellAddress))
            {

                string wIsInTemplete = RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE;
                //edit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong start
                if (CurrentLayoutData.DesignSettingData.IsSupportTempleteRepeat && CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES && !string.IsNullOrEmpty(CurrentLayoutData.DesignTempleteData.Range))
                //edit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong end
                {
                    // テンプレート繰返し範囲に入っているか取得
                    using (var wXlRangeTemplete = new ExcelRangeEx(XlHelper.XlSheetLayout, CurrentLayoutData.DesignTempleteData.Range))
                    {
                        // mod #11556 「##=」型の計算式で関数が使用できなくなっている 高 start
                        //wIsInTemplete = GetIsInTemplete(wXlRangeTemplete.GetRectangle(), wXlRange.GetRectangle());
                        wIsInTemplete = GetIsInTemplete(wXlRange.Range.Address[false, false], wXlRangeTemplete.Range.Address[false, false]);
                        // mod #11556 「##=」型の計算式で関数が使用できなくなっている 高 end
                    }
                }
                wRet.IsInTemplete = wIsInTemplete;

                // 縮小して全体を表示の設定状態を取得
                if (wRet.CanEditShrink)
                {
                    object wValue = wXlRange.Range.ShrinkToFit;
                    bool wIsShrink = wValue == DBNull.Value || (bool)wValue;

                    wRet.IsShrink = wIsShrink ? RldConst.ParamData.VAL_ISSHRINK_DONE : RldConst.ParamData.VAL_ISSHRINK_NONE;
                }

                // 書式を取得
                if (wRet.CanEditDisplayFormat)
                {
                    object wValue = wXlRange.Range.NumberFormat;
                    string wNumberFormat = wValue == DBNull.Value ? string.Empty : (string)wValue;

                    if ((!string.IsNullOrEmpty(wNumberFormat) && wNumberFormat != "General") || string.IsNullOrEmpty(wRet.DisplayFormat))
                    {
                        wRet.DisplayFormat = wNumberFormat;
                    }
                }

                // データ種別が string の場合
                if (wRet.DataType.ToLower() == RldConst.ParamData.VAL_DATATYPE_STRING.ToLower() && wRet.CanEditLength)
                {
                    wRet.Length = Convert.ToString(wXlRange.GetStringLength());
                }
            }

            return wRet;
        }

        /// <summary>
        /// データ項目リストファイルから帳票種別リストを読み込みます。
        /// </summary>
        private static void LoadReportTypeList()
        {
            try
            {
                if (!System.IO.File.Exists(RldUtility.DataListBaseFilePath))
                {
                    throw new System.IO.FileNotFoundException(@"データ項目リストのベースファイルが見つかりません。", RldUtility.DataListBaseFilePath);
                }

                // データ項目リストファイル読込
                var wXmlLastDoc = new TdcLib.TdcXml();
                if (!System.IO.File.Exists(RldUtility.DataListFilePath) || !wXmlLastDoc.Load(RldUtility.DataListFilePath))
                {
                    // NOTE: 前回出力した状態のファイルはないケースもある
                    //throw new System.ApplicationException(@"データ項目リストファイルの読み込みに失敗しました。", wXmlDoc.Error);
                    wXmlLastDoc = null;
                }

                // データ項目リストベースファイル読込
                var wXmlDoc = new TdcLib.TdcXml();
                if (!wXmlDoc.Load(RldUtility.DataListBaseFilePath))
                {
                    throw new System.ApplicationException(@"データ項目リストのベースファイルの読み込みに失敗しました。", wXmlDoc.Error);
                }

                // 帳票種別リストを取得
                // [reportTable/report]
                // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
                //var wXmlReports = wXmlDoc.Document.SelectNodes(string.Format("{0}/{1}", RldConst.ItemList.TAG_REPORTTABLE, RldConst.ItemList.TAG_REPORT));

                //// [report]ノード
                //foreach (System.Xml.XmlNode wNode in wXmlReports)
                //{

                //    string wReportType = string.Empty, wReportTypeName = string.Empty;

                //    // 帳票種別と帳票種別名を取得
                //    // wNode.Attributesにはtype属性とdispName属性の2つが含まれている
                //    foreach (System.Xml.XmlAttribute wAttribute in wNode.Attributes)
                //    {
                //        if (IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_REPORT_TYPE))
                //        {
                //            // type属性
                //            wReportType = wAttribute.Value;
                //        }
                //        else if (IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_REPORT_DISPNAME))
                //        {
                //            // dispName属性
                //            wReportTypeName = wAttribute.Value;
                //        }
                //    }

                //    // テンプレート繰返しを設定できるかどうかを取得
                //    bool wCanSettingTempleteRepeat = true;

                //    // 透析レポートと準備リストはテンプレート繰り返しの設定をできなくする
                //    switch (wReportType)
                //    {
                //        case RldConst.ReportTypeData.VAL_TYPE_DIALYSIS:
                //        case RldConst.ReportTypeData.VAL_TYPE_EQUIPMENT_LIST:
                //            wCanSettingTempleteRepeat = false;
                //            break;
                //    }


                //    // リストへ追加 
                //    if (!string.IsNullOrEmpty(wReportType) && !string.IsNullOrEmpty(wReportTypeName))
                //    {
                //        ReportClassList.Add(
                //            new ReportTypeData()
                //            {
                //                ReportClass = wReportType,
                //                ReportClassName = wReportTypeName,
                //                IsSupportTempleteRepeat = wCanSettingTempleteRepeat
                //            });
                //    }

                //}
                // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
                // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
                ReportClassList.Clear();
                ReportClassList.Add(new ReportTypeData() { ReportClass = RldConst.ReportTypeData.VAL_TYPE_DIALYSIS, ReportClassName = "治療経過表", IsSupportTempleteRepeat = false });
                ReportClassList.Add(new ReportTypeData() { ReportClass = RldConst.ReportTypeData.VAL_TYPE_ONE_PATIENT, ReportClassName = "単患者帳票", IsSupportTempleteRepeat = true });
                ReportClassList.Add(new ReportTypeData() { ReportClass = RldConst.ReportTypeData.VAL_TYPE_MULTI_PATIENT, ReportClassName = "複数患者帳票", IsSupportTempleteRepeat = true });
                ReportClassList.Add(new ReportTypeData() { ReportClass = RldConst.ReportTypeData.VAL_TYPE_EQUIPMENT_LIST, ReportClassName = "準備リスト", IsSupportTempleteRepeat = false });
                ReportClassList.Add(new ReportTypeData() { ReportClass = RldConst.ReportTypeData.VAL_TYPE_DISTRIBUTE_LIST_BED, ReportClassName = "配布リスト(ベッド)", IsSupportTempleteRepeat = true });
                ReportClassList.Add(new ReportTypeData() { ReportClass = RldConst.ReportTypeData.VAL_TYPE_DISTRIBUTE_LIST_EQUIPMENT, ReportClassName = "配布リスト(物品)", IsSupportTempleteRepeat = true });
                ReportClassList.Add(new ReportTypeData() { ReportClass = RldConst.ReportTypeData.VAL_TYPE_DEVICE, ReportClassName = "装置帳票", IsSupportTempleteRepeat = true });
                ReportClassList.Add(new ReportTypeData() { ReportClass = RldConst.ReportTypeData.VAL_TYPE_LABEL, ReportClassName = "ラベル", IsSupportTempleteRepeat = true });
                ReportClassList.Add(new ReportTypeData() { ReportClass = RldConst.ReportTypeData.VAL_TYPE_REFERRAL_LETTER, ReportClassName = "紹介状", IsSupportTempleteRepeat = true });
                ReportClassList.Add(new ReportTypeData() { ReportClass = RldConst.ReportTypeData.VAL_TYPE_ONE_TOTAL, ReportClassName = "単集計", IsSupportTempleteRepeat = true });
                ReportClassList.Add(new ReportTypeData() { ReportClass = RldConst.ReportTypeData.VAL_TYPE_MULTI_TOTAL, ReportClassName = "複数集計", IsSupportTempleteRepeat = true });
                // add #11009 カテゴリ「印刷情報」の仕様調整 高 end

                if (SignInLib.SignIn.SignInInfo.IsOnline)
                {
                    // WEBサービスにサインインできている場合のみ処理する

                    // 帳票種別マスターを読み込む
                    string defineValue = NKKCommon.Updater.GetSystemDefineValue(24);

                    // ReportClassListに追加する
                    if (string.IsNullOrEmpty(defineValue) == false)
                    {
                        // valueをデシリアライズする
                        using (var ms = new System.IO.MemoryStream(Encoding.UTF8.GetBytes(defineValue)))
                        {
                            // valueをデシリアライズする
                            var value = new List<MstReportType>();

                            var ser = new System.Runtime.Serialization.Json.DataContractJsonSerializer(value.GetType());
                            value = ser.ReadObject(ms) as List<MstReportType>;
                            ms.Close();

                            // ReportClassListに追加する処理を実装する
                            foreach (var item in value)
                            {
                                System.Diagnostics.Debug.Print(DateTime.Now.ToString() + item.ReportName);
                                if (item.ReportClass > 9)
                                {
                                    ReportClassList.Add(
                                        new ReportTypeData()
                                        {
                                            ReportClass = item.ReportType,
                                            ReportClassName = item.ReportName,
                                            IsSupportTempleteRepeat = item.IsSupportTempleteRepeat
                                        });
                                    ReportClassIntDictionary.Add(item.ReportType, item.ReportClass);
                                    ReportClassStringDictionary.Add(item.ReportClass, item.ReportType);

                                }

                            }

                        }

                    }

                    // add 2020-08-13 FNSI-仕様追加 データのバージョン判定を増やす 李 start
                    // データベースからデータのバージョンを取得する
                    string dataVersion = NKKCommon.Updater.GetSystemDefineValue(35);
                    if (!string.IsNullOrEmpty(dataVersion))
                    {
                        var dVer = new NKKCommon.VersionValue();
                        using (var ms = new System.IO.MemoryStream(Encoding.UTF8.GetBytes(dataVersion)))
                        {
                            var ser = new System.Runtime.Serialization.Json.DataContractJsonSerializer(dVer.GetType());
                            dVer = ser.ReadObject(ms) as NKKCommon.VersionValue;
                            ms.Close();
                        }
                        // データのバージョン
                        if (!string.IsNullOrEmpty(LayoutDesignerUtilityLib.LayoutDesignerUtility.DataVersion) && new Version(dVer.version).Equals(new Version(LayoutDesignerUtilityLib.LayoutDesignerUtility.DataVersion)))
                            return;
                        // データのバージョンをプロファイルに保存する
                        LayoutDesignerUtilityLib.LayoutDesignerUtility.SaveConfigInfo("DataVersion", dVer.version);
                        LayoutDesignerUtilityLib.LayoutDesignerUtility.DataVersion = dVer.version;
                    }
                    // add 2020-08-13 FNSI-仕様追加 データのバージョン判定を増やす 李 end

                    // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
                    var wXmlDoc_tmp = new TdcLib.TdcXml();
                    System.Xml.XmlDocument document = wXmlDoc_tmp.Document;
                    System.Xml.XmlDeclaration xmlDeclaration = document.CreateXmlDeclaration("1.0", "utf-8", "yes");
                    document.AppendChild(xmlDeclaration);
                    // create root node
                    System.Xml.XmlElement rootNode = document.CreateElement(RldConst.ItemList.TAG_REPORTTABLE);
                    document.AppendChild(rootNode);

                    Dictionary<string, System.Xml.XmlNode> reportImportNode = new Dictionary<string, System.Xml.XmlNode>();
                    System.Xml.XmlNode importNode, importNodeTmp;
                    System.Xml.XmlNode importNodeCommon = null;

                    var wXmlReports = wXmlDoc.Document.SelectNodes(string.Format("{0}/{1}", RldConst.ItemList.TAG_REPORTTABLE, RldConst.ItemList.TAG_REPORT));
                    // [report]ノード
                    foreach (System.Xml.XmlNode wNode in wXmlReports)
                    {

                        string wReportType = string.Empty;

                        // 帳票種別を取得
                        // wNode.Attributesにはtype属性が含まれている
                        foreach (System.Xml.XmlAttribute wAttribute in wNode.Attributes)
                        {
                            if (IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_REPORT_TYPE))
                            {
                                // type属性
                                wReportType = wAttribute.Value;
                                break;
                            }
                        }
                        if(string.IsNullOrEmpty(wReportType) == false)
                        {
                            if("Common".Equals(wReportType))
                            {
                                importNodeCommon = wNode.SelectSingleNode(RldConst.ItemList.TAG_DATATABLE);
                            }
                            else
                            {
                                importNodeTmp = wNode.SelectSingleNode(RldConst.ItemList.TAG_DATATABLE);
                                if(importNodeTmp != null)
                                    reportImportNode.Add(wReportType, importNodeTmp);
                            }

                        }
                    }

                    foreach (var item in ReportClassList)
                    {
                        System.Xml.XmlElement xmlElement = document.CreateElement(RldConst.ItemList.TAG_REPORT);
                        xmlElement.Attributes.Append(document.CreateAttribute(RldConst.ItemList.ATT_REPORT_TYPE)).Value = item.ReportClass;
                        xmlElement.Attributes.Append(document.CreateAttribute(RldConst.ItemList.ATT_REPORT_DISPNAME)).Value = item.ReportClassName;
                        var reportNode = document.SelectSingleNode(RldConst.ItemList.TAG_REPORTTABLE).InsertAfter(xmlElement, document.SelectSingleNode(RldConst.ItemList.TAG_REPORTTABLE).LastChild);
                        // process Common
                        if (importNodeCommon != null)
                        {
                            System.Xml.XmlNode importNode1 = document.ImportNode(importNodeCommon, true);
                            reportNode = reportNode.InsertAfter(importNode1, null);
                        }

                        // process Special
                        if (reportImportNode.ContainsKey(item.ReportClass))
                        {
                            if (importNodeCommon == null)
                            {
                                System.Xml.XmlNode importNode1 = document.ImportNode(reportImportNode[item.ReportClass], true);
                                reportNode = reportNode.InsertAfter(importNode1, null);
                            }
                            else
                            {
                                var reportNodeDataList = reportImportNode[item.ReportClass].SelectNodes(RldConst.ItemList.TAG_DATA);
                                foreach (System.Xml.XmlNode reportNodeData in reportNodeDataList)
                                {
                                    importNode = document.ImportNode(reportNodeData, true);
                                    var nodeDataChild = reportNode.LastChild;
                                    System.Xml.XmlNode node = reportNode.InsertAfter(importNode, nodeDataChild);
                                }
                            }
                        }
                        else
                        {
                            if (importNodeCommon == null)
                            {
                                System.Xml.XmlNode importNode1 = document.CreateElement(RldConst.ItemList.TAG_DATATABLE);
                                reportNode = reportNode.InsertAfter(importNode1, null);
                            }
                        }
                    }
                    // add #11009 カテゴリ「印刷情報」の仕様調整 高 end

                    // SQLコードとデータコードをデータ項目一覧にセットする
                    Task.Run(() =>
                    {
                        try
                        {
                            // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
                            // SetDataCodesAsync(wXmlDoc, wXmlLastDoc);
                            SetDataCodesAsync(wXmlDoc_tmp, wXmlLastDoc);
                            // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
                        }
                        catch (Exception ex)
                        {
                            RldUtility.RecordException(ex, false);
                        }
                    });

                }

            }
            catch (Exception ex)
            {
                throw new System.Exception(@"データ項目リストファイルの読込中にエラーが発生しました。", ex);
            }
        }

        // add 2020-10-12 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 start
        /// <summary>
        /// DataListデータリストにソート機能を追加
        /// </summary>
        /// <param name="dataSort"></param>
        /// <returns></returns>
        private static string DataSortFormat(string dataSort)
        {
            if (string.IsNullOrEmpty(dataSort))
                return "99.9999.999999";
            string ret = "";
            string[] ds = dataSort.Split('.');
            if (ds.Length == 1)
                ret = ds[0].PadLeft(2, '0') + ".9999.999999";
            else if (ds.Length == 2)
                ret = ds[0] == "" ? "99" : ds[0].PadLeft(2, '0') + "." + ds[1] == "" ? "9999" : ds[1].PadLeft(4, '0') + ".999999";
            else
                ret = (ds[0] == "" ? "99" : ds[0].PadLeft(2, '0')) + "." + (ds[1] == "" ? "9999" : ds[1].PadLeft(4, '0')) + "." + (ds[2] == "" ? "999999" : ds[2].PadLeft(6, '0'));
            return ret;
        }
        // add 2020-09-28 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 end

        /// <summary>
        /// sys_data_setテーブルのSQLコードとデータコードをデータ項目一覧に反映させる
        /// </summary>
        /// <param name="wXmlDoc">データ項目一覧XML</param>
        private static async void SetDataCodesAsync(TdcLib.TdcXml wXmlDoc, TdcLib.TdcXml wXmlLastDoc)
        {

            try
            {
                // sys_data_setの全レコードを読み込む
                //NKKWebAccessResponse wRestRet = await NKKWebAccess.Get("sys_data_set取得", $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}/api/report_designer/sys_data_sets/", NKKWebAccess.SKIP_OTP);
                NKKWebAccessResponse wRestRet = await NKKWebAccess.Get("sys_data_set取得", $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}/api/report_designer/sys_data_sets", NKKWebAccess.SKIP_OTP);

                // 属性値が異なっていればセットするローカル関数
                void setIfNotEqual(System.Xml.XmlAttribute attribute, string value)
                {
                    //　属性値が異なっていればセットする
                    if (!attribute.Value.Equals(value) && !string.IsNullOrWhiteSpace(value))
                    {
                        attribute.Value = value;

                    }
                }

                // 取得データを戻り値にセット
                List<Data.SysDataSetData> sysDataSets = null;
                if (wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode)
                {
                    // sys_data_setテーブルの全レコード
                    sysDataSets = RldJsonDataSerializeHelper<List<Data.SysDataSetData>>.Deserialize(wRestRet.strContent);

                    System.Diagnostics.Debug.Print(wXmlDoc.Document.InnerXml);

                    // 帳票種別リストを取得
                    // [reportTable/report]
                    string reportTableReport = $"{RldConst.ItemList.TAG_REPORTTABLE}/{RldConst.ItemList.TAG_REPORT}";
                    var wXmlLastReports = wXmlLastDoc?.Document.SelectNodes(reportTableReport);
                    var wXmlReports = wXmlDoc.Document.SelectNodes(reportTableReport);

                    //bool isUpdateDataList = false;
                    //void setIfNotEqual(System.Xml.XmlAttribute attribute, string value)
                    //{
                    //    if (!attribute.Value.Equals(value) && !string.IsNullOrWhiteSpace(value))
                    //    {
                    //        attribute.Value = value;
                    //        isUpdateDataList = true;
                    //    }
                    //}

                    // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
                    //// sys_system_defineの帳票種別マスタのDictionaryをクローンする
                    //var checkList = new List<ReportTypeData>(ReportClassList);

                    //// 帳票種別マスターにあってDataListにないものを判断するためにDataListに既にある帳票種別を除去する
                    //foreach (System.Xml.XmlNode wNode in wXmlReports)
                    //{
                    //    // XML内のtype属性に指定された帳票の種類を示す文字列を取得
                    //    // DataListに含まれている帳票種別をチェック用コレクションから削除する
                    //    checkList.RemoveAll(n => n.ReportClass.Equals(wNode.Attributes["type"].Value));
                    //}

                    //// sys_system_defineの帳票種別マスタにはあるが、DataListにない帳票種別を追加する
                    //foreach (var item in checkList)
                    //{
                    //    // DataListに帳票種別を追加する
                    //    // <report type = "TreatmentStatusList" dispName = "治療状況リスト">
                    //    //     <dataTable>
                    //    //         <data dataCode="date" dataName="個別点検日" dataCategory="機器保守" dataClass="日常点検詳細" sqlCode="107" dataType="DateTime" ...>
                    //    //         </data>
                    //    //     </dataTable>
                    //    // </report>
                    //    System.Xml.XmlDocument document = wXmlDoc.Document;
                    //    System.Xml.XmlElement xmlElement = document.CreateElement(RldConst.ItemList.TAG_REPORT);
                    //    xmlElement.Attributes.Append(document.CreateAttribute(RldConst.ItemList.ATT_REPORT_TYPE)).Value = item.ReportClass;
                    //    xmlElement.Attributes.Append(document.CreateAttribute(RldConst.ItemList.ATT_REPORT_DISPNAME)).Value = item.ReportClassName;
                    //    var reportNode = document.SelectSingleNode(RldConst.ItemList.TAG_REPORTTABLE).InsertAfter(xmlElement, document.SelectSingleNode(RldConst.ItemList.TAG_REPORTTABLE).LastChild);
                    //    reportNode.InsertAfter(document.CreateElement(RldConst.ItemList.TAG_DATATABLE), null);
                    //}

                    //// 帳票種別が追加されている場合は中身が増えているのでwXmlReportsを再設定する
                    //if (checkList.Count > 0)
                    //{
                    //    wXmlReports = wXmlDoc.Document.SelectNodes(reportTableReport);
                    //}
                    // del #11009 カテゴリ「印刷情報」の仕様調整 高 end

                    // [report]ノード. 帳票種別のループ.
                    foreach (System.Xml.XmlNode wNode in wXmlReports)
                    {

                        // XML内のtype属性に指定された帳票の種類を示す文字列を取得し、帳票種別コードに変換する
                        var reportClass = ConvertReportClassStringToInt32(wNode.Attributes["type"].Value);

                        // 変更前のInnerXmlを保持する
                        string xml = wNode.InnerXml;

                        System.Xml.XmlNodeList xmlNodeList = wNode.SelectNodes("dataTable/data");

                        // sys_data_setのdetailからDataName, カテゴリ, クラスに有効値が入っている項目をループで参照する
                        // かつそのsys_data_setのレコードの帳票種別に求めている帳票種別が含まれている
                        // sys_data_setのdetailの中身でループする
                        foreach ((Data.SysDataSetData sysDataSet, Data.SysDataSetDetailData detail) in
                        from Data.SysDataSetData sysDataSet in sysDataSets
                        where sysDataSet.ReportClass.Classes.Contains(reportClass)
                        from Data.SysDataSetDetailData detail in sysDataSet.DetailInfo.Details
                        where !string.IsNullOrWhiteSpace(detail.DataName)
                                && !string.IsNullOrWhiteSpace(detail.DataCategory)
                                && !string.IsNullOrWhiteSpace(detail.DataClass)
                        select (sysDataSet, detail))
                        {

                            bool isExist = false;

                            // DataList.xmlのdataTable/dataノードの中からdataName, dataCategory, dataClassが一致する要素を抽出する
                            foreach (System.Xml.XmlElement item in from System.Xml.XmlElement item in xmlNodeList
                                                                   where item.Attributes["dataName"].Value.Equals(detail.DataName)
                                                                      && item.Attributes["dataCategory"].Value.Equals(detail.DataCategory)
                                                                      && item.Attributes["dataClass"].Value.Equals(detail.DataClass)
                                                                   select item)
                            {
                                // SQLコード, DATAコード他をセットする
                                setIfNotEqual(item.Attributes["dataCode"], detail.DataCode);
                                setIfNotEqual(item.Attributes["sqlCode"], sysDataSet.SqlCd);
                                setIfNotEqual(item.Attributes["dataType"], detail.DataType);
                                setIfNotEqual(item.Attributes["canRepeat"], sysDataSet.CanRepeat);
                                setIfNotEqual(item.Attributes["dispFormat"], detail.DispFormat);
                                setIfNotEqual(item.Attributes["canCalc"], detail.CanCalc);
                                setIfNotEqual(item.Attributes["preview"], detail.Preview);
                                setIfNotEqual(item.Attributes["facilityFilterType"], detail.FacilityFilterType);
                                setIfNotEqual(item.Attributes[RldConst.ItemList.ATT_DATA_FILTERTYPE], detail.FilterType);
                                settingConvTable(wXmlDoc, detail, item);

                                isExist = true;
                            }

                            if (!isExist)
                            {
                                // なければ追加する
                                // 追加する

                                System.Xml.XmlElement elem = wXmlDoc.Document.CreateElement("data");

                                // この順番を変更してはいけない
                                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("dataCode")).Value = detail.DataCode;
                                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("dataName")).Value = detail.DataName;
                                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("dataCategory")).Value = detail.DataCategory;
                                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("dataClass")).Value = detail.DataClass;
                                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("sqlCode")).Value = sysDataSet.SqlCd;
                                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("dataType")).Value = detail.DataType;
                                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("canRepeat")).Value = sysDataSet.CanRepeat;
                                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute(RldConst.ItemList.ATT_DATA_FILTERTYPE)).Value = detail.FilterType;
                                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("dispFormat")).Value = detail.DispFormat;
                                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("canCalc")).Value = detail.CanCalc;
                                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("preview")).Value = detail.Preview;
                                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("facilityFilterType")).Value = detail.FacilityFilterType;
                                // add 2020-09-28 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 start
                                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("dataSort")).Value = DataSortFormat(detail.DataSort);
                                // add 2020-09-28 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 end
                                // add 2021-08-30 6009画像 李 start
                                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("isImage")).Value = detail.IsImage;
                                // add 2021-08-30 6009画像 李 end

                                // dataTableノードの最後の子ノードの次にdata要素を追加する

                                // <dataTable>
                                //   <data dataCode="pat_id" dataName="患者ID" dataCategory="患者情報" dataClass="基本情報">
                                //     <facilityTable />
                                //   </data>
                                //   <data dataCode="" dataName="氏名フリガナ" dataCategory="患者情報" dataClass="基本情報">
                                //     <facilityTable />
                                //   </data>
                                //
                                //   …
                                //
                                //   これを追加
                                //   <data dataCode="" dataName="" dataCategory="" dataClass="">
                                //     <facilityTable />
                                //   </data>

                                settingConvTable(wXmlDoc, detail, elem);

                                // dataTableノードの最後の子ノードの次にdata要素を追加する
                                System.Xml.XmlNode node = wNode.SelectSingleNode("dataTable").InsertAfter(elem, wNode.SelectSingleNode("dataTable").LastChild);

                                // facilityTable要素を追加
                                _ = node.InsertAfter(wXmlDoc.Document.CreateElement("facilityTable"), node.LastChild);

                            }

                        }

                        if (reportClass == RldConst.MasterData.Report.VAL_TYPE_LABEL)
                        {
                            // ラベルの場合のみ
                            // カテゴリ:ラベル クラス:物品情報 項目名:分類別情報
                            // 分類別情報のSQLコードにラベル印刷データを取得するSQLコードを指定する

                            // DataListの[分類別情報]項目を返す列挙子
                            IEnumerable<(Data.SysDataSetData sysDataSet, System.Xml.XmlElement item)> enumerable()
                            {
                                // 「帳票種別にラベルが指定されたsys_data_setレコード」と「DataList.xmlの分類別情報タグ」のセットを返す
                                return from Data.SysDataSetData sysDataSet in
                                           from Data.SysDataSetData sysDataSet in sysDataSets
                                           where sysDataSet.ReportClass.Classes.Contains(RldConst.MasterData.Report.VAL_TYPE_LABEL)
                                           select sysDataSet
                                       from System.Xml.XmlElement item in
                                           from System.Xml.XmlElement item in xmlNodeList
                                           where item.Attributes["dataName"].Value.Equals(DesignItemListData.dcClassificationInfo)
                                              && item.Attributes["dataCategory"].Value.Equals(DesignItemListData.dcLabel)
                                              && item.Attributes["dataClass"].Value.Equals(DesignItemListData.dcMaterialInfo)
                                           select item
                                       select (sysDataSet, item);
                            }

                            // DataListの[分類別情報]項目のSQLコードにラベルのSQLコードをセットする
                            // mod #10980 ラベル項目設定が機能していない 高 start
                            IEnumerable<(Data.SysDataSetData sysDataSet, System.Xml.XmlElement item)> dcMaterialInfoSet = enumerable();
                            if (dcMaterialInfoSet.Count() > 0)
                            {
                                dcMaterialInfoSet = dcMaterialInfoSet.OrderBy(p => int.Parse(p.sysDataSet.SqlCd));
                                foreach ((Data.SysDataSetData sysDataSet, System.Xml.XmlElement item) in dcMaterialInfoSet)
                                {
                                    // SQLコードをセットする
                                    setIfNotEqual(item.Attributes["sqlCode"], sysDataSet.SqlCd);
                                    break;
                                }
                            }
                            //foreach ((Data.SysDataSetData sysDataSet, System.Xml.XmlElement item) in enumerable())
                            //{
                            //    // SQLコードをセットする
                            //    setIfNotEqual(item.Attributes["sqlCode"], sysDataSet.SqlCd);
                            //}
                            // mod #10980 ラベル項目設定が機能していない 高 end

                        }

                        // カテゴリ/クラスでソート
                        var nodeList = wNode.SelectNodes("dataTable/data");
                        var sortedList = GroupingNodeList(nodeList);

                        // dataTableノードのすべての子ノードと属性の両方を削除
                        wNode.SelectSingleNode("dataTable").RemoveAll();

                        // dataTableノードの子ノードのリストに、ソートしたノードを追加
                        foreach (var node in sortedList)
                        {
                            wNode.SelectSingleNode("dataTable").AppendChild(node);
                        }
                    }
                    if (wXmlLastReports == null)
                    {
                        // データ項目一覧を新規登録する
                        // 保存
                        string dataListFilePath = RldUtility.DataListFilePath;
                        _ = wXmlDoc.Save(dataListFilePath);
                    }
                    else
                    {
                        bool isUpdateDataList = false;
                        // 前回作成ファイルとの変更チェック
                        if (wXmlLastReports.Count != wXmlReports.Count)
                        {
                            // 帳票項目数変更

                            isUpdateDataList = true;
                        }
                        else
                        {
                            for (int cnt = 0; cnt < wXmlReports.Count; cnt++)
                            {
                                var lastXml = wXmlLastReports[cnt].InnerXml;
                                var newXml = wXmlReports[cnt].InnerXml;
                                if (!newXml.Equals(lastXml))
                                {
                                    // 変更有り
                                    isUpdateDataList = true;
                                    break;
                                }
                            }
                        }

                        // データ項目一覧をアップデートする
                        if (isUpdateDataList)
                        {

                            string dataListFilePath = RldUtility.DataListFilePath;

                            // 現状のファイルを名前を変えて退避する
                            string destFileName = System.IO.Path.GetDirectoryName(dataListFilePath)
                                                  + "\\"
                                                  + System.IO.Path.GetFileNameWithoutExtension(dataListFilePath)
                                                  + "_"
                                                  + DateTime.Now.ToString("yyyyMMddHHmmss")
                                                  + System.IO.Path.GetExtension(dataListFilePath);
                            System.IO.File.Move(dataListFilePath, destFileName);

                            // 保存
                            _ = wXmlDoc.Save(dataListFilePath);

                        }
                    }

                }

            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

        }

        private static List<System.Xml.XmlNode> GroupingNodeList(System.Xml.XmlNodeList nodeList)
        {
            var dataCategories = new List<string>();
            var dataClasses = new List<string>();
            var sortedList = new List<System.Xml.XmlNode>();

            foreach (System.Xml.XmlElement node in nodeList)
            {
                var dataCategory = node.Attributes["dataCategory"].Value;
                if (!dataCategories.Contains(dataCategory))
                {
                    // 同じカテゴリは1回のみ実行
                    dataCategories.Add(dataCategory);
                    var catList = GroupingNodeListCategory(nodeList, dataCategory);
                    sortedList.AddRange(catList);
                }
            }
            return sortedList;
        }
        /// <summary>
        /// カテゴリが同じデータセットを纏めて返す
        /// </summary>
        /// <param name="sysDataSets"></param>
        /// <param name="dataCategory"></param>
        /// <returns></returns>
        private static List<System.Xml.XmlNode> GroupingNodeListCategory(System.Xml.XmlNodeList nodeList, String dataCategory)
        {
            var dataClasses = new List<string>();
            var sortedList = new List<System.Xml.XmlNode>();

            foreach (System.Xml.XmlElement node in nodeList)
            {
                if (dataCategory == node.Attributes["dataCategory"].Value)
                {
                    var dataClass = node.Attributes["dataClass"].Value;
                    if (!dataClasses.Contains(dataClass))
                    {
                        // 同じクラスは1回のみ実行
                        dataClasses.Add(dataClass);
                        var classList = GroupingNodeListClass(nodeList, dataCategory, dataClass);
                        sortedList.AddRange(classList);
                    }
                }

            }
            return sortedList;
        }
        /// <summary>
        /// カテゴリとクラスが同じデータセットを纏めて返す
        /// </summary>
        /// <param name="sysDataSets"></param>
        /// <param name="dataCategory"></param>
        /// <param name="dataClass"></param>
        /// <returns></returns>
        private static List<System.Xml.XmlNode> GroupingNodeListClass(System.Xml.XmlNodeList nodeList, String dataCategory, String dataClass)
        {
            var sortedList = new List<System.Xml.XmlNode>();

            foreach (System.Xml.XmlElement node in nodeList)
            {
                if (dataCategory == node.Attributes["dataCategory"].Value && dataClass == node.Attributes["dataClass"].Value)
                {
                    // カテゴリとクラスが同じデータセットを纏めて返す
                    sortedList.Add(node);
                }
            }
            return sortedList;
        }

        /// <summary>
        /// convTableを取得した内容で変更する
        /// </summary>
        /// <param name="wXmlDoc"></param>
        /// <param name="detail"></param>
        /// <param name="item"></param>
        private static void settingConvTable(TdcLib.TdcXml wXmlDoc, Data.SysDataSetDetailData detail, System.Xml.XmlElement item)
        {
            foreach (System.Xml.XmlNode child in item.ChildNodes)
            {
                if (!child.Name.Equals("convTable"))
                {
                    continue;
                }
                // 既に<convTable>があった場合は削除
                item.RemoveChild(child);
            }
            // <convTable>作成
            var cTbl = wXmlDoc.Document.CreateElement("convTable");
            cTbl.Attributes.Append(wXmlDoc.Document.CreateAttribute("cls")).Value = detail.DataName;
            foreach (var convTable in detail.ConvTable)
            {
                var elem = wXmlDoc.Document.CreateElement("conv");
                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("code")).Value = convTable.Code;
                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("item")).Value = convTable.Item;
                elem.Attributes.Append(wXmlDoc.Document.CreateAttribute("disp")).Value = convTable.Disp;

                cTbl.AppendChild(elem);
            }
            if (cTbl.ChildNodes.Count > 0)
            {
                item.PrependChild(cTbl);
            }
        }

        // mod #11556 「##=」型の計算式で関数が使用できなくなっている 高 start
        /// <summary>
        /// 指定されたパラメータ編集データの配置場所からテンプレート内外状態を取得します。
        /// </summary>
        /// <param name="strParamAddr"></param>
        /// <param name="strTempleteAddr"></param>
        /// <returns></returns>
        //private static string GetIsInTemplete(System.Drawing.RectangleF aTempleteArea, System.Drawing.RectangleF aParamArea)
        private static string GetIsInTemplete(String strParamAddr, String strTempleteAddr)
        // mod #11556 「##=」型の計算式で関数が使用できなくなっている 高 end
        {
            var wRet = RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE;

            try
            {
                if (CurrentLayoutData.DesignSettingData.IsSupportTempleteRepeat)
                {
                    // 帳票種別としてテンプレート繰返しをサポートしている場合は "外"
                    wRet = RldConst.ParamData.VAL_IS_IN_TEMPLETE_OUT;

                    if (CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
                    {
                        // テンプレート繰返しの設定を行っている場合は範囲に入っているか確認
                        // mod #11556 「##=」型の計算式で関数が使用できなくなっている 高 start
                        //if (aTempleteArea.Contains(aParamArea))
                        if (XlHelper.XlApp.IsInTemplete(strParamAddr, strTempleteAddr))
                        // mod #11556 「##=」型の計算式で関数が使用できなくなっている 高 end
                        {
                            wRet = RldConst.ParamData.VAL_IS_IN_TEMPLETE_IN;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        /// <summary>
        /// 指定されたユーザがスーパーユーザかどうか確認します。
        /// </summary>
        /// <param name="aLoginID"></param>
        /// <param name="aPassword"></param>
        /// <returns></returns>
        public static bool IsSuperUser(string aLoginID, string aPassword)
        {
            string wLoginID = aLoginID.Trim();
            string wPassword = aPassword.Trim();

            // ユーザID確認
            if (string.CompareOrdinal(wLoginID, SUPER_USER_LOGIN_ID) != 0)
            {
                return false;
            }
            // パスワード確認
            if (string.CompareOrdinal(wPassword, SUPER_USER_PASSOWRD) != 0)
            {
                return false;
            }

            return true;
        }

        /// <summary>
        /// 作業用ファイルの編集を継続するかどうかの確認を行います。
        /// </summary>
        /// <returns></returns>
        public static bool CheckContinueEditWorkFile()
        {
            bool wRet = false;

            // 作業中ファイルがある場合
            if (System.IO.File.Exists(WorkXlsxFilePath))
            {
                // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
                string[] name = Directory.GetFiles(@WorkXlsxFilePath.Replace("work.xlsx", ""), "*.temp");
                if (name.Length > 0)
                {
                    for (int i = 0; i < name.Length; i++)
                    {
                        if (!String.IsNullOrEmpty(name[i]))
                        {
                            string[] fileName = System.IO.Path.GetFileNameWithoutExtension(name[i]).Split('_');
                            LayoutDesignerUtility.CurrentFacilityCd = fileName[0];
                            LayoutDesignerUtility.CurrentFacilityName = fileName[1];
                            // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
                            RldLib.FilterDataSet.ClearFilterData();
                            // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end
                            break;
                        }
                    }
                }
                // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
                // add #12477 管理者モード起動時に一時ファイルを検知すると日機装施設で開いてしまう 高 start
                if ("1".Equals(SignInLib.SignIn.SignInInfo.UserType))
                {
                    MessageBox.Show("前回作業時の帳票レイアウトファイルが残っています。\r\n管理者モードのため、前回作業を継続する場合は先に登録先施設を選択してから「一時ファイル読込」機能を使用して「work」フォルダ内のファイルを読み込んでください。", "確認してください");
                    wRet = false;
                    return wRet;
                }
                // add #12477 管理者モード起動時に一時ファイルを検知すると日機装施設で開いてしまう 高 end

                var wMsg = new System.Text.StringBuilder() { Length = 0 };
                wMsg.AppendLine(@"前回作業時の帳票レイアウトファイルが残っています。")
                    .AppendLine(@"前回作業を継続しますか？")
                    .Append("(「いいえ」を選択すると、前回作業時の帳票レイアウトファイルは\r\n削除されます)");

                if (RldMsgBox.Show(wMsg.ToString(), @"確認してください", System.Windows.Forms.MessageBoxButtons.YesNo, System.Windows.Forms.MessageBoxIcon.Question) == System.Windows.Forms.DialogResult.Yes)
                {
                    wRet = true;
                }

                // 念のため再度確認
                if (!wRet)
                {
                    if (RldMsgBox.Show("前回作業時の帳票レイアウトファイルは削除されます。\r\n本当によろしいですか？", @"再度確認してください", System.Windows.Forms.MessageBoxButtons.YesNo, System.Windows.Forms.MessageBoxIcon.Question, System.Windows.Forms.MessageBoxDefaultButton.Button2) == System.Windows.Forms.DialogResult.No)
                    {
                        wRet = true;
                    }
                }
            }

            return wRet;
        }

        /// <summary>
        /// 有効な帳票種別のリストを取得します。
        /// </summary>
        /// <returns></returns>
        public static IEnumerable<EnumReportType> GetDefinedReportTypeList()
        {
            foreach (EnumReportType wReportType in Enum.GetValues(typeof(EnumReportType)).Cast<EnumReportType>().Where(wElement => wElement != EnumReportType.None).ToList())
            {
                yield return wReportType;
            }
        }

        /// <summary>
        /// 文字列形式の帳票種別を取得するためのDictionary
        /// </summary>
        private static readonly Dictionary<int, string> ReportClassStringDictionary = new Dictionary<int, string>();

        /// <summary>
        /// 数値形式の帳票種別を取得するためのDictionary
        /// </summary>
        private static readonly Dictionary<string, int> ReportClassIntDictionary = new Dictionary<string, int>();

        /// <summary>
        /// 数値形式の帳票種別を文字列形式の帳票種別に変換します。
        /// </summary>
        /// <param name="aReportClass"></param>
        /// <returns></returns>
        public static string ConvertReportClassInt32ToString(int aReportClass)
        {
            string wRet = string.Empty;

            switch (aReportClass)
            {
                case RldConst.MasterData.Report.VAL_TYPE_DIALYSIS:
                    // 帳票種別[透析レポート]
                    wRet = RldConst.ReportTypeData.VAL_TYPE_DIALYSIS;
                    break;

                case RldConst.MasterData.Report.VAL_TYPE_ONE_PATIENT:
                    // 帳票種別[単患者帳票]
                    wRet = RldConst.ReportTypeData.VAL_TYPE_ONE_PATIENT;
                    break;

                case RldConst.MasterData.Report.VAL_TYPE_MULTI_PATIENT:
                    // 帳票種別[複数患者帳票]
                    wRet = RldConst.ReportTypeData.VAL_TYPE_MULTI_PATIENT;
                    break;

                case RldConst.MasterData.Report.VAL_TYPE_EQUIPMENT_LIST:
                    // 帳票種別[準備リスト]
                    wRet = RldConst.ReportTypeData.VAL_TYPE_EQUIPMENT_LIST;
                    break;

                case RldConst.MasterData.Report.VAL_TYPE_DISTRIBUTE_LIST_BED:
                    // 帳票種別[配布リスト(ベッド)]
                    wRet = RldConst.ReportTypeData.VAL_TYPE_DISTRIBUTE_LIST_BED;
                    break;

                case RldConst.MasterData.Report.VAL_TYPE_DISTRIBUTE_LIST_EQUIPMENT:
                    // 帳票種別[配布リスト(物品)]
                    wRet = RldConst.ReportTypeData.VAL_TYPE_DISTRIBUTE_LIST_EQUIPMENT;
                    break;

                case RldConst.MasterData.Report.VAL_TYPE_DEVICE:
                    // 帳票種別[装置帳票]
                    wRet = RldConst.ReportTypeData.VAL_TYPE_DEVICE;
                    break;

                case RldConst.MasterData.Report.VAL_TYPE_LABEL:
                    // 帳票種別[ラベル]
                    wRet = RldConst.ReportTypeData.VAL_TYPE_LABEL;
                    break;

                case RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER:
                    // 帳票種別[紹介状]
                    wRet = RldConst.ReportTypeData.VAL_TYPE_REFERRAL_LETTER;
                    break;

                // add FNSI-523 2次元帳票対応 夏 start
                case RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL:
                    // 帳票種別[単一集計]
                    wRet = RldConst.ReportTypeData.VAL_TYPE_ONE_TOTAL;
                    break;

                case RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL:
                    // 帳票種別[複数集計]
                    wRet = RldConst.ReportTypeData.VAL_TYPE_MULTI_TOTAL;
                    break;
                // add FNSI-523 2次元帳票対応 夏 end

                default:
                    // 10以上はsys_system_defineの設定に依る
                    if (ReportClassStringDictionary.ContainsKey(aReportClass))
                    {
                        wRet = ReportClassStringDictionary[aReportClass];
                    }
                    break;
            }

            return wRet;
        }

        /// <summary>
        /// 文字列形式の帳票種別を数値形式の帳票種別に変換します。
        /// </summary>
        /// <param name="aReportClass"></param>
        /// <returns></returns>
        public static int ConvertReportClassStringToInt32(string aReportClass)
        {
            int wRet = 0;

            switch (aReportClass)
            {
                case RldConst.ReportTypeData.VAL_TYPE_DIALYSIS:
                    // 透析レポート
                    wRet = RldConst.MasterData.Report.VAL_TYPE_DIALYSIS;
                    break;

                case RldConst.ReportTypeData.VAL_TYPE_ONE_PATIENT:
                    // 単患者帳票
                    wRet = RldConst.MasterData.Report.VAL_TYPE_ONE_PATIENT;
                    break;

                case RldConst.ReportTypeData.VAL_TYPE_MULTI_PATIENT:
                    // 複数患者帳票
                    wRet = RldConst.MasterData.Report.VAL_TYPE_MULTI_PATIENT;
                    break;

                case RldConst.ReportTypeData.VAL_TYPE_EQUIPMENT_LIST:
                    // 準備リスト
                    wRet = RldConst.MasterData.Report.VAL_TYPE_EQUIPMENT_LIST;
                    break;

                case RldConst.ReportTypeData.VAL_TYPE_DISTRIBUTE_LIST_BED:
                    // 配布リスト(ベッド)
                    wRet = RldConst.MasterData.Report.VAL_TYPE_DISTRIBUTE_LIST_BED;
                    break;

                case RldConst.ReportTypeData.VAL_TYPE_DISTRIBUTE_LIST_EQUIPMENT:
                    // 配布リスト(物品)
                    wRet = RldConst.MasterData.Report.VAL_TYPE_DISTRIBUTE_LIST_EQUIPMENT;
                    break;

                case RldConst.ReportTypeData.VAL_TYPE_DEVICE:
                    // 装置帳票
                    wRet = RldConst.MasterData.Report.VAL_TYPE_DEVICE;
                    break;

                case RldConst.ReportTypeData.VAL_TYPE_LABEL:
                    // ラベル
                    wRet = RldConst.MasterData.Report.VAL_TYPE_LABEL;
                    break;

                case RldConst.ReportTypeData.VAL_TYPE_REFERRAL_LETTER:
                    // 紹介状
                    wRet = RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER;
                    break;
                // add FNSI-523 2次元帳票対応 夏 start
                case RldConst.ReportTypeData.VAL_TYPE_ONE_TOTAL:
                    // 単一集計
                    wRet = RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL;
                    break;
                case RldConst.ReportTypeData.VAL_TYPE_MULTI_TOTAL:
                    // 複数集計
                    wRet = RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL;
                    break;
                // add FNSI-523 2次元帳票対応 夏 end
                default:
                    // 10以上はsys_system_defineの設定に依る
                    if (ReportClassIntDictionary.ContainsKey(aReportClass))
                    {
                        wRet = ReportClassIntDictionary[aReportClass];
                    }
                    break;
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

        // add #11758 セルを編集中のまま、保存作業を行うと致命的なエラーが発生する 高 start
        [DllImport("user32.dll")]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

        [DllImport("user32.dll")]
        public static extern bool PostMessage(IntPtr hWnd, uint Msg, int wParam, int lParam);

        const uint WM_KEYDOWN = 0x0100;
        const int VK_ESCAPE = 0x1B;
        const int VK_TAB = 0x9;

        /// <summary>
        /// send command : TAB to execl
        /// </summary>
        /// <returns></returns>
        public static void SendExeclTAB()
        {
            // add #11959 オンラインで保存して戻るで致命的なエラー 高 start
            RldLib.XlHelper.IsHandleLayoutSheetEvent = false;
            string aBeforeAddress = string.Empty;
            string aBeforeValue = string.Empty;

            aBeforeAddress = GetActiveAddress();
            // add #11959 オンラインで保存して戻るで致命的なエラー 高 end
            IntPtr excelHwnd = FindWindow("XLMAIN", null);
            if (excelHwnd != IntPtr.Zero)
            {
                PostMessage(excelHwnd, WM_KEYDOWN, VK_TAB, 0);
                System.Threading.Thread.Sleep(400);
            }
            // add #11959 オンラインで保存して戻るで致命的なエラー 高 start
            if (!string.IsNullOrEmpty(aBeforeAddress))
            {
                // get modify value of cell with address
                aBeforeValue = GetValue2FromAddress(aBeforeAddress);
                UpdateParamDataListItem(aBeforeAddress, aBeforeValue);
            }
            RldLib.XlHelper.IsHandleLayoutSheetEvent = true;
            // add #11959 オンラインで保存して戻るで致命的なエラー 高 end
        }
        // add #11758 セルを編集中のまま、保存作業を行うと致命的なエラーが発生する 高 end

        // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
        /// <summary>
        /// check execl dialog.
        /// </summary>
        /// input: 
        ///     chkFlag == 1: when cell is editting, OK
        ///     chkFlag == 2: when cell is editting, NG
        ///     chkFlag == 3: when cell is editting, NG and not output message
        /// <returns>exception: false, else true </returns>
        public static bool chkExeclDialog(int chkFlag)
        {
            bool bRet = true;

            try
            {
                if (chkFlag == 1)
                {
                    bool original = RldLib.XlHelper.XlApp.Application.ScreenUpdating;
                    RldLib.XlHelper.XlApp.Application.ScreenUpdating = original;
                }
                else
                {
                    RldLib.XlHelper.XlApp.Application.DisplayAlerts = false;
                    RldLib.XlHelper.XlApp.Application.DisplayAlerts = true;
                }
            }
            catch (Exception)
            {
                if(chkFlag != 3)
                    RldMsgBox.Show("操作を継続できません。\r\nExcelの機能を使用中の場合はそちらを完了させてから操作を行ってください。", "確認してください");
                bRet = false;
            }
            return bRet;
        }
        // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

        // add #11959 オンラインで保存して戻るで致命的なエラー 高 start
        // add or update param datelist item with address and DataPath
        public static void UpdateParamDataListItem(string wCellAddress, string wDataPath)
        {
            Int32 wNewIndex = -1;
            DesignParamData wData = null;
            DesignParamData newData = null;
            string curPath = string.Empty;
            string aCellAddress = string.Empty;

            // find item of param data list wich address
            wNewIndex = RldLib.CurrentLayoutData.FindDesignParamDataIndex(wCellAddress);
            // not find
            if(wNewIndex == -1)
            {
                // DataPath is not valid name, not process
                if (!isValidDataPath(wDataPath))
                {
                    return;
                }

                // create new item
                newData = CreateParamData(wCellAddress, wDataPath);
                if (newData == null)
                    return;

                // add new item to param data list
                RldLib.CurrentLayoutData.DesignParamList.Add(newData);
                // add new group
                RldLib.CurrentLayoutData.CreateAndAddDesignGroupData(newData);

                // RldLib.CurrentLayoutData.DesignParamListを並べ替える
                RldLib.CurrentLayoutData.DesignParamList.Sort();
                return;
            }

            wData = RldLib.CurrentLayoutData.DesignParamList[wNewIndex];
            // DataPath not change, not process
            if (wData.DataPath.Equals(wDataPath))
            {
                return;
            }

            if (!isValidDataPath(wDataPath))
            {
                // remove old cell and group
                RldLib.CurrentLayoutData.RemoveDesignParamData(wData);
                return;
            }

            // create new item
            newData = CreateParamData(wCellAddress, wDataPath);
            if (newData == null)
                return;

            // 別の項目が配置されていたセルの場合
            RldLib.CurrentLayoutData.SetDesignParamData(newData, wNewIndex);

            return;
        }

        // Active Cellのアドレス and valueを取得
        public static string GetActiveAddress()
        {
            string wAddress = string.Empty;

            using (var wXlRange = RldLib.XlHelper.XlApp.GetActiveCell)
            {
                // 先のアドレスを取得
                wAddress = wXlRange.Range.Address[false, false];

                // 結合セルへのドロップの場合は正しい範囲を取得
                if (wXlRange.Range.MergeCells)
                {
                    using (var wXlMerge = new ExcelRangeEx(wXlRange.Range.MergeArea))
                        wAddress = wXlMerge.Range.Address[false, false];
                }
            }

            return wAddress;
        }

        // Cellのvalueを取得
        public static string GetValue2FromAddress(string wAddress)
        {
            string wValue = string.Empty;

            using (var wXlRange = new ExcelRangeEx(XlHelper.XlSheetLayout, wAddress))
            {
                wValue = Convert.ToString(wXlRange.GetValue2());
            }

            return wValue;
        }

        // is valid DataPath
        public static bool isValidDataPath(string wDataPath)
        {
            // is empty
            if (string.IsNullOrEmpty(wDataPath))
                return false;

            // is ##
            if (wDataPath.Equals(RldConst.PATH_HEADER))
                return false;

            // start content is not ##
            if(!wDataPath.StartsWith(RldConst.PATH_HEADER))
                return false;

            return true;
        }

        // create param data with address and DataPath
        public static DesignParamData CreateParamData(string wCellAddress, string wDataPath)
        {
            if (string.IsNullOrEmpty(wCellAddress))
                return null;

            if (string.IsNullOrEmpty(wDataPath))
                return null;


            DesignParamData wData = null;
            wData = RldLib.CurrentLayoutData.CreateDesignParamData(wDataPath, wCellAddress);

            if (!string.IsNullOrEmpty(wData.DisplayFormat))
            {
                using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, wCellAddress))
                {
                    wXlRange.Range.NumberFormatLocal = wXlRange.Range.NumberFormat = wData.DisplayFormat;
                }
            }
            else
            {
                using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, wCellAddress))
                {
                    if (wData.DataType == "string" || wData.DataType == "byte[]")
                    {
                        wXlRange.Range.NumberFormat = "General";
                    }
                }

            }

            // 不足情報を付加
            wData = RldLib.ApplyAdditionalInfoToParamData(wData);

            return wData;
        }
        // add #11959 オンラインで保存して戻るで致命的なエラー 高 end

        // mod #12621 ##=の計算式が保存できないことがある、また、プレビュー値が異常 高 start
        // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
        //public static String GetSamplingFormula(String aFormula, DesignParamDatasList designParamList, 
        //    System.ComponentModel.BindingList<DesignItemListData> dataItemList)
        //{
        //    String wRet = aFormula.Replace(RldConst.CALC_HEADER, String.Empty);

        //    Int32 wStartPos = -1, wEndPos = -1;
        //    string wTemp = string.Empty;
        //    int commStrPos = -1, commEndPos = -1;
        //     string cal_start = RldConst.CALC_ITEM_START + RldConst.PATH_HEADER;

        //    while ((commStrPos = wRet.IndexOf("\"", commEndPos + 1)) >= 0)
        //    {
        //        {
        //            string wRetTemp1 = wRet.Substring(commEndPos + 1, commStrPos - commEndPos - 1);
        //            string wTmp1 = wRetTemp1;
        //            wStartPos = -1;
        //            wEndPos = -1;
        //            while ((wStartPos = wTmp1.IndexOf(cal_start, wEndPos + 1)) >= 0)
        //            {
        //                wEndPos = wTmp1.IndexOf(RldConst.CALC_ITEM_END, wStartPos + 1);
        //                if (wEndPos == -1)
        //                    break;

        //                // データ項目名を切り出し
        //                var wItemPath = wTmp1.Substring(wStartPos + 1, wEndPos - wStartPos - 1);
        //                if (designParamList.Count(ele => ele.DataPath == wItemPath) > 0)
        //                {
        //                    var wData = designParamList.Single(ele => ele.DataPath == wItemPath);
        //                    wRetTemp1 = wRetTemp1.Replace(
        //                        $"{RldConst.CALC_ITEM_START}{wItemPath}{RldConst.CALC_ITEM_END}",
        //                        RldLib.ConvertStrToDecimal(wData.PreviewData, true).ToString());
        //                }
        //                else
        //                {
        //                    if (dataItemList.Count(ele => ele.DataPath == wItemPath) > 0)
        //                    {
        //                        var wData = dataItemList.Single(ele => ele.DataPath == wItemPath);
        //                        wRetTemp1 = wRetTemp1.Replace(
        //                            $"{RldConst.CALC_ITEM_START}{wItemPath}{RldConst.CALC_ITEM_END}",
        //                            RldLib.ConvertStrToDecimal(wData.PreviewData, true).ToString());
        //                    }
        //                }
        //            }
        //            wTemp = wTemp + wRetTemp1;
        //            commEndPos = wRet.IndexOf("\"", commStrPos + 1);
        //            if (commEndPos == -1)
        //            {
        //                return string.Empty;
        //            }
        //            else
        //            {
        //                wTemp = wTemp + wRet.Substring(commStrPos, commEndPos - commStrPos + 1);
        //            }
        //        }
        //    }

        //    string wRetTemp = wRet.Substring(commEndPos + 1);
        //    string wTmp = wRetTemp;
        //    wStartPos = -1;
        //    wEndPos = -1;
        //    while ((wStartPos = wTmp.IndexOf(cal_start, wEndPos + 1)) >= 0)
        //    {
        //        wEndPos = wTmp.IndexOf(RldConst.CALC_ITEM_END, wStartPos + 1);
        //        if (wEndPos == -1)
        //            break;

        //        // データ項目名を切り出し
        //        var wItemPath = wTmp.Substring(wStartPos + 1, wEndPos - wStartPos - 1);
        //        if (designParamList.Count(ele => ele.DataPath == wItemPath) > 0)
        //        {
        //            var wData = designParamList.Single(ele => ele.DataPath == wItemPath);
        //            wRetTemp = wRetTemp.Replace(
        //                $"{RldConst.CALC_ITEM_START}{wItemPath}{RldConst.CALC_ITEM_END}",
        //                RldLib.ConvertStrToDecimal(wData.PreviewData, true).ToString());
        //        }
        //        else
        //        {
        //            if (dataItemList.Count(ele => ele.DataPath == wItemPath) > 0)
        //            {
        //                var wData = dataItemList.Single(ele => ele.DataPath == wItemPath);
        //                wRetTemp = wRetTemp.Replace(
        //                    $"{RldConst.CALC_ITEM_START}{wItemPath}{RldConst.CALC_ITEM_END}",
        //                    RldLib.ConvertStrToDecimal(wData.PreviewData, true).ToString());
        //            }
        //        }
        //    }
        //    wTemp = wTemp + wRetTemp;

        //    return wTemp;
        //}
        private const int MAX_RECURSION_DEPTH = 10;
        private static readonly Regex CellReferenceRegex = new Regex(@"[A-Za-z]+[0-9]+", RegexOptions.Compiled);

        private static readonly string[] FunctionNames = {
    "SUM", "SUMIF", "SUMPRODUCT",
    "AVERAGE", "AVERAGEIF",
    "COUNT", "COUNTA", "COUNTIF",
    "MAX", "MIN",
    "ABS", "INT", "ROUND", "ROUNDUP", "ROUNDDOWN", "MOD",
    "IF", "IFERROR", "AND", "OR", "NOT",
    "LEFT", "RIGHT", "MID", "LEN", "TRIM", "CONCATENATE", "SUBSTITUTE",
    "VALUE", "TEXT",
    "VLOOKUP", "HLOOKUP", "MATCH", "INDEX",
    "DATE", "DAY", "MONTH", "YEAR", "TODAY", "NOW",
    "VBRColor"
};

        /// <summary>
        /// Checks if a string is an Excel function
        /// </summary>
        private static bool IsExcelFunction(string text)
        {
            if (string.IsNullOrEmpty(text))
                return false;

            // Trim whitespace
            string trimmedText = text.Trim();

            // Remove leading "=" if present
            if (trimmedText.StartsWith("="))
            {
                trimmedText = trimmedText.Substring(1);
            }

            // Check if the text starts with any function name followed by '('
            foreach (string functionName in FunctionNames)
            {
                // Check for exact function name followed by (
                if (trimmedText.StartsWith(functionName + "(", StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }

                // Also check with possible whitespace between function name and (
                int funcIndex = trimmedText.IndexOf(functionName, StringComparison.OrdinalIgnoreCase);
                if (funcIndex == 0)
                {
                    int afterFunc = functionName.Length;
                    if (afterFunc < trimmedText.Length)
                    {
                        while (afterFunc < trimmedText.Length && char.IsWhiteSpace(trimmedText[afterFunc]))
                        {
                            afterFunc++;
                        }
                        if (afterFunc < trimmedText.Length && trimmedText[afterFunc] == '(')
                        {
                            return true;
                        }
                    }
                }
            }

            // Check if the text matches pattern: FUNCTION_NAME( ... )
            string pattern = @"^[A-Za-z]+[\w]*\s*\(";
            if (System.Text.RegularExpressions.Regex.IsMatch(trimmedText, pattern))
            {
                var match = System.Text.RegularExpressions.Regex.Match(trimmedText, @"^([A-Za-z]+[\w]*)\s*\(");
                if (match.Success)
                {
                    string funcName = match.Groups[1].Value;
                    foreach (string functionName in FunctionNames)
                    {
                        if (funcName.Equals(functionName, StringComparison.OrdinalIgnoreCase))
                        {
                            return true;
                        }
                    }
                }
            }

            return false;
        }

        /// <summary>
        /// Helper method to check if a string is a valid mathematical expression
        /// </summary>
        private static bool IsValidMathExpression(string expression)
        {
            if (string.IsNullOrEmpty(expression))
                return false;

            // Remove all whitespace first
            string cleaned = expression.Replace(" ", "");

            if (string.IsNullOrEmpty(cleaned))
                return false;

            // Check if it's a pure number
            if (decimal.TryParse(cleaned, out _))
                return true;

            // Check if the expression contains any alphabetic characters
            if (System.Text.RegularExpressions.Regex.IsMatch(cleaned, @"[A-Za-z]"))
                return false;

            // Check if the expression contains invalid pattern like "100(72)"
            if (System.Text.RegularExpressions.Regex.IsMatch(cleaned, @"\d+\("))
                return false;

            // Check if the expression contains any characters that are not valid in math expressions
            string validPattern = @"^[0-9\.\+\-\*\/\(\)]+$";
            if (!System.Text.RegularExpressions.Regex.IsMatch(cleaned, validPattern))
                return false;

            // Check for parentheses balance
            int balance = 0;
            foreach (char c in cleaned)
            {
                if (c == '(') balance++;
                else if (c == ')') balance--;
                if (balance < 0) return false;
            }
            if (balance != 0) return false;

            // Check if the expression contains empty parentheses or invalid parenthesis patterns
            if (cleaned.Contains("()") || cleaned.Contains(")("))
                return false;

            // Check for double operators
            if (System.Text.RegularExpressions.Regex.IsMatch(cleaned, @"[\+\-\*\/]{2,}"))
                return false;

            // Check if the expression starts or ends with an operator
            if (System.Text.RegularExpressions.Regex.IsMatch(cleaned, @"^[\+\-\*\/]|[\+\-\*\/]$"))
                return false;

            // Check for invalid decimal point usage
            var numberMatches = System.Text.RegularExpressions.Regex.Matches(cleaned, @"\d+(?:\.\d+)?");
            foreach (System.Text.RegularExpressions.Match match in numberMatches)
            {
                string number = match.Value;
                int decimalCount = number.Count(c => c == '.');
                if (decimalCount > 1)
                    return false;
            }

            // Try to evaluate as a test
            try
            {
                var dt = new System.Data.DataTable();
                object testResult = dt.Compute(cleaned, "");
                if (testResult == null)
                    return false;
                string resultString = testResult.ToString();
                if (System.Text.RegularExpressions.Regex.IsMatch(resultString, @"[A-Za-z]"))
                    return false;
            }
            catch
            {
                return false;
            }

            return true;
        }

        /// <summary>
        /// Checks if a string is a single bracketed data path [##...] with no extra characters
        /// </summary>
        private static bool IsSingleBracketedItem(string text)
        {
            if (string.IsNullOrEmpty(text))
                return false;

            // Must start with [## and end with ]
            if (!text.StartsWith(RldConst.CALC_ITEM_START) || !text.EndsWith(RldConst.CALC_ITEM_END))
                return false;

            // Count brackets - should be exactly 2 (one [ and one ])
            int bracketCount = 0;
            foreach (char c in text)
            {
                if (c == '[') bracketCount++;
                else if (c == ']') bracketCount--;
                if (bracketCount < 0) return false;
            }

            if (bracketCount != 0) return false;

            // Check that there is only one '[' and one ']'
            int firstBracket = text.IndexOf('[');
            int lastBracket = text.LastIndexOf(']');

            // If there are any '[' or ']' in between, it's not a single bracketed item
            string inside = text.Substring(firstBracket + 1, lastBracket - firstBracket - 1);
            if (inside.Contains("[") || inside.Contains("]"))
                return false;

            return true;
        }

        /// <summary>
        /// Gets the sampling formula by recursively processing calculation headers and data items
        /// </summary>
        public static string GetSamplingFormula(string aFormula, DesignParamDatasList designParamList,
                    System.ComponentModel.BindingList<DesignItemListData> dataItemList,
                    int recursionDepth, HashSet<string> callStack)
        {
            // Initialize call stack on first call
            if (callStack == null)
            {
                callStack = new HashSet<string>();
            }

            // Guard against excessive recursion depth
            if (recursionDepth > MAX_RECURSION_DEPTH)
            {
                return "=0";
            }

            // Process formula that starts with ##= header (calculation header)
            if (aFormula.StartsWith(RldConst.CALC_HEADER))
            {
                // Extract the inner formula after the ##= header
                string innerFormula = aFormula.Substring(RldConst.CALC_HEADER.Length);

                // Check if innerFormula is a single bracketed data path
                if (IsSingleBracketedItem(innerFormula))
                {
                    // Single bracketed item - process it directly
                    string processedValue = ProcessBracketedDataItems(innerFormula, designParamList, dataItemList);

                    // Check if the value is a pure number
                    if (decimal.TryParse(processedValue, System.Globalization.NumberStyles.Any,
                        System.Globalization.CultureInfo.InvariantCulture, out decimal numValue))
                    {
                        return "=" + numValue.ToString(System.Globalization.CultureInfo.InvariantCulture);
                    }
                    else
                    {
                        // For non-numeric values (dates, phone numbers, text), return as quoted string
                        return "=\"" + processedValue.Replace("\"", "\"\"") + "\"";
                    }
                }

                // Handle pure cell reference (e.g., C8, D9, E10) - no operators
                if (CellReferenceRegex.IsMatch(innerFormula) &&
                    !innerFormula.Contains("+") && !innerFormula.Contains("-") &&
                    !innerFormula.Contains("*") && !innerFormula.Contains("/") &&
                    !innerFormula.Contains("&") && !innerFormula.Contains("("))
                {
                    // Check for circular reference
                    if (callStack.Contains(innerFormula))
                    {
                        return "=0";
                    }

                    var newCallStack = new HashSet<string>(callStack);
                    newCallStack.Add(innerFormula);

                    // Get the raw cell value from Excel
                    string cellValue = GetCellValue(innerFormula);

                    // If the cell contains a formula (##=...), recursively process it
                    if (cellValue.StartsWith(RldConst.CALC_HEADER))
                    {
                        string result = GetSamplingFormula(cellValue, designParamList, dataItemList, recursionDepth + 1, newCallStack);
                        if (result == "#CIRCULAR_REFERENCE?" || result.Contains("#CIRCULAR_REFERENCE?"))
                        {
                            return "=0";
                        }
                        return result;
                    }

                    // If the cell contains a data path (##... but not ##=), recursively process it
                    if (cellValue.StartsWith(RldConst.PATH_HEADER) && !cellValue.StartsWith(RldConst.CALC_HEADER))
                    {
                        string result = GetSamplingFormula(cellValue, designParamList, dataItemList, recursionDepth + 1, newCallStack);
                        if (result == "#CIRCULAR_REFERENCE?" || result.Contains("#CIRCULAR_REFERENCE?"))
                        {
                            return "=0";
                        }
                        return result;
                    }

                    // If the cell value is wrapped in [##...], process the bracketed items
                    if (cellValue.StartsWith(RldConst.CALC_ITEM_START) && cellValue.EndsWith(RldConst.CALC_ITEM_END))
                    {
                        string processedValue = ProcessBracketedDataItems(cellValue, designParamList, dataItemList);

                        if (decimal.TryParse(processedValue, System.Globalization.NumberStyles.Any,
                            System.Globalization.CultureInfo.InvariantCulture, out decimal numValue))
                        {
                            return "=" + numValue.ToString(System.Globalization.CultureInfo.InvariantCulture);
                        }
                        else
                        {
                            return "=\"" + processedValue.Replace("\"", "\"\"") + "\"";
                        }
                    }

                    // Return the raw cell value - check if it's a number
                    if (decimal.TryParse(cellValue, System.Globalization.NumberStyles.Any,
                        System.Globalization.CultureInfo.InvariantCulture, out decimal rawNumValue))
                    {
                        return "=" + rawNumValue.ToString(System.Globalization.CultureInfo.InvariantCulture);
                    }
                    return cellValue;
                }

                // Handle arithmetic expressions containing cell references
                if (CellReferenceRegex.IsMatch(innerFormula) ||
                    innerFormula.Contains("+") || innerFormula.Contains("-") ||
                    innerFormula.Contains("*") || innerFormula.Contains("/") ||
                    innerFormula.Contains("&") || innerFormula.Contains("(") || innerFormula.Contains(")"))
                {
                    // Check for direct circular reference
                    if (callStack.Count > 0)
                    {
                        string currentCell = callStack.Last();
                        var circularCheckMatches = CellReferenceRegex.Matches(innerFormula);
                        foreach (Match match in circularCheckMatches)
                        {
                            if (match.Value == currentCell)
                            {
                                return "=0";
                            }
                        }
                    }

                    // Process all bracketed [##...] items in the expression
                    string resolvedExpression = innerFormula;

                    int maxIterations = 10;
                    int iteration = 0;
                    while ((resolvedExpression.Contains(RldConst.CALC_ITEM_START) || resolvedExpression.Contains(RldConst.PATH_HEADER)) && iteration < maxIterations)
                    {
                        iteration++;

                        if (resolvedExpression.Contains(RldConst.CALC_ITEM_START))
                        {
                            resolvedExpression = ProcessBracketedDataItems(resolvedExpression, designParamList, dataItemList);
                        }

                        if (resolvedExpression.Contains(RldConst.PATH_HEADER) && !resolvedExpression.Contains(RldConst.CALC_HEADER))
                        {
                            resolvedExpression = ProcessUnbracketedDataPathsInString(resolvedExpression, designParamList, dataItemList);
                        }
                    }

                    // Resolve cell references
                    var cellMatches = CellReferenceRegex.Matches(resolvedExpression);

                    for (int i = cellMatches.Count - 1; i >= 0; i--)
                    {
                        Match match = cellMatches[i];
                        string cellRef = match.Value;

                        if (decimal.TryParse(cellRef, out _))
                        {
                            continue;
                        }

                        var newCallStack = new HashSet<string>(callStack);
                        newCallStack.Add(cellRef);

                        string cellValue = GetCellValue(cellRef);

                        if (cellValue.StartsWith(RldConst.CALC_HEADER))
                        {
                            string result = GetSamplingFormula(cellValue, designParamList, dataItemList, recursionDepth + 1, newCallStack);
                            if (result == "#CIRCULAR_REFERENCE?" || result.Contains("#CIRCULAR_REFERENCE?") || result == "=0")
                            {
                                cellValue = "0";
                            }
                            else
                            {
                                if (result.StartsWith("="))
                                {
                                    result = result.Substring(1);
                                }
                                cellValue = result;
                            }
                        }
                        else if (cellValue.StartsWith(RldConst.PATH_HEADER) && !cellValue.StartsWith(RldConst.CALC_HEADER))
                        {
                            string result = GetSamplingFormula(cellValue, designParamList, dataItemList, recursionDepth + 1, newCallStack);
                            if (result == "#CIRCULAR_REFERENCE?" || result.Contains("#CIRCULAR_REFERENCE?") || result == "=0")
                            {
                                cellValue = "0";
                            }
                            else
                            {
                                if (result.StartsWith("="))
                                {
                                    result = result.Substring(1);
                                }
                                cellValue = result;
                            }
                        }
                        else if (cellValue.StartsWith(RldConst.CALC_ITEM_START) && cellValue.EndsWith(RldConst.CALC_ITEM_END))
                        {
                            cellValue = ProcessBracketedDataItems(cellValue, designParamList, dataItemList);
                        }

                        if (cellValue.StartsWith("\"") && cellValue.EndsWith("\""))
                        {
                            string unquoted = cellValue.Substring(1, cellValue.Length - 2);
                            if (decimal.TryParse(unquoted, out _))
                            {
                                cellValue = unquoted;
                            }
                            else
                            {
                                cellValue = unquoted;
                            }
                        }

                        resolvedExpression = resolvedExpression.Substring(0, match.Index) +
                                             cellValue +
                                             resolvedExpression.Substring(match.Index + match.Length);
                    }

                    // Handle string concatenation with & operator
                    if (resolvedExpression.Contains("&"))
                    {
                        string concatenatedResult = EvaluateStringConcatenation(resolvedExpression);
                        return "=\"" + concatenatedResult.Replace("\"", "\"\"") + "\"";
                    }

                    // Check if resolved expression is a pure value
                    bool hasOperatorsAfterResolution = resolvedExpression.Contains("+") || resolvedExpression.Contains("-") ||
                                                       resolvedExpression.Contains("*") || resolvedExpression.Contains("/") ||
                                                       resolvedExpression.Contains("&");
                    bool hasParenthesesAfterResolution = resolvedExpression.Contains("(") || resolvedExpression.Contains(")");

                    if (!hasOperatorsAfterResolution && !hasParenthesesAfterResolution)
                    {
                        if (decimal.TryParse(resolvedExpression, System.Globalization.NumberStyles.Any,
                            System.Globalization.CultureInfo.InvariantCulture, out decimal pureNumValue))
                        {
                            return "=" + pureNumValue.ToString(System.Globalization.CultureInfo.InvariantCulture);
                        }
                        else
                        {
                            return "=\"" + resolvedExpression.Replace("\"", "\"\"") + "\"";
                        }
                    }

                    // Check if expression is an Excel function
                    bool isExcelFunction = IsExcelFunction(resolvedExpression);

                    if (isExcelFunction)
                    {
                        if (!resolvedExpression.StartsWith("="))
                        {
                            return "=" + resolvedExpression;
                        }
                        return resolvedExpression;
                    }

                    // Clean up the expression
                    string cleanedExpression = System.Text.RegularExpressions.Regex.Replace(resolvedExpression, @"\s+", " ").Trim();

                    bool isValidMathExpr = IsValidMathExpression(cleanedExpression);

                    if (!isValidMathExpr)
                    {
                        if (decimal.TryParse(cleanedExpression, System.Globalization.NumberStyles.Any,
                            System.Globalization.CultureInfo.InvariantCulture, out decimal numValue))
                        {
                            return "=" + numValue.ToString(System.Globalization.CultureInfo.InvariantCulture);
                        }
                        else if (System.Text.RegularExpressions.Regex.IsMatch(cleanedExpression, @"^[A-Z]+[\w]*\("))
                        {
                            return "=" + cleanedExpression;
                        }
                        else
                        {
                            return "=\"" + cleanedExpression.Replace("\"", "\"\"") + "\"";
                        }
                    }

                    // Try DataTable.Compute
                    try
                    {
                        var dt = new System.Data.DataTable();
                        object computeResult = dt.Compute(cleanedExpression, "");
                        if (computeResult != null)
                        {
                            string evaluatedResult = computeResult.ToString();
                            if (decimal.TryParse(evaluatedResult, System.Globalization.NumberStyles.Any,
                                System.Globalization.CultureInfo.InvariantCulture, out decimal numValue))
                            {
                                return "=" + numValue.ToString(System.Globalization.CultureInfo.InvariantCulture);
                            }
                            else
                            {
                                return "=\"" + evaluatedResult.Replace("\"", "\"\"") + "\"";
                            }
                        }
                    }
                    catch
                    {
                        // Fall through to Excel evaluation
                    }

                    // Try Excel evaluation as fallback
                    if (RldLib.XlHelper.XlApp.Application != null)
                    {
                        try
                        {
                            object excelResult = RldLib.XlHelper.XlApp.Application.Evaluate(cleanedExpression);
                            if (excelResult != null && excelResult != DBNull.Value)
                            {
                                string result = excelResult.ToString();
                                if (decimal.TryParse(result, System.Globalization.NumberStyles.Any,
                                    System.Globalization.CultureInfo.InvariantCulture, out decimal numValue))
                                {
                                    return "=" + numValue.ToString(System.Globalization.CultureInfo.InvariantCulture);
                                }
                                else
                                {
                                    return "=\"" + result.Replace("\"", "\"\"") + "\"";
                                }
                            }
                        }
                        catch
                        {
                            // Fall through
                        }
                    }

                    if (resolvedExpression.StartsWith("\"") && resolvedExpression.EndsWith("\""))
                    {
                        return "=" + resolvedExpression;
                    }
                    return "=\"" + resolvedExpression.Replace("\"", "\"\"") + "\"";
                }

                // Check for circular reference BEFORE processing
                if (CellReferenceRegex.IsMatch(innerFormula))
                {
                    var cellMatches = CellReferenceRegex.Matches(innerFormula);
                    foreach (Match match in cellMatches)
                    {
                        string cellRef = match.Value;
                        if (callStack.Contains(cellRef))
                        {
                            return "=0";
                        }
                    }
                }

                // Process all data items within the formula
                string processedFormula = ProcessDataItems(innerFormula, designParamList, dataItemList);

                if (processedFormula.StartsWith("="))
                {
                    return processedFormula;
                }

                if (decimal.TryParse(processedFormula, System.Globalization.NumberStyles.Any,
                    System.Globalization.CultureInfo.InvariantCulture, out decimal pureNumVal))
                {
                    return "=" + pureNumVal.ToString(System.Globalization.CultureInfo.InvariantCulture);
                }

                bool hasOperators = processedFormula.Contains("+") || processedFormula.Contains("-") ||
                                    processedFormula.Contains("*") || processedFormula.Contains("/") ||
                                    processedFormula.Contains("&");
                bool hasCellReferences = CellReferenceRegex.IsMatch(processedFormula);
                bool isExcelFunc = IsExcelFunction(processedFormula);

                if (!hasOperators && !hasCellReferences && !isExcelFunc)
                {
                    return "=\"" + processedFormula.Replace("\"", "\"\"") + "\"";
                }

                if (RldLib.XlHelper.XlApp.Application != null && (hasOperators || hasCellReferences || isExcelFunc))
                {
                    try
                    {
                        string resolvedValue = EvaluateFormulaWithCellValues(processedFormula, 0, null, null);

                        if (!string.IsNullOrEmpty(resolvedValue))
                        {
                            if (resolvedValue.Contains("#CIRCULAR_REFERENCE?"))
                            {
                                return "=0";
                            }

                            if (resolvedValue.Contains(RldConst.CALC_ITEM_START))
                            {
                                resolvedValue = ProcessBracketedDataItems(resolvedValue, designParamList, dataItemList);
                            }

                            resolvedValue = ProcessAllDataPaths(resolvedValue, designParamList, dataItemList);

                            if (resolvedValue.Contains(RldConst.PATH_HEADER) ||
                                resolvedValue.Contains(RldConst.CALC_HEADER) ||
                                resolvedValue.Contains(RldConst.CALC_ITEM_START))
                            {
                                string result = GetSamplingFormula(resolvedValue, designParamList, dataItemList, recursionDepth + 1, callStack);
                                if (result.Contains("#CIRCULAR_REFERENCE?"))
                                {
                                    return "=0";
                                }
                                if (result.StartsWith("\"") && result.EndsWith("\""))
                                {
                                    result = result.Substring(1, result.Length - 2);
                                }
                                return result;
                            }

                            bool isExcelFuncResult = IsExcelFunction(resolvedValue);
                            bool hasArithmeticOperators = resolvedValue.Contains("+") || resolvedValue.Contains("-") ||
                                                          resolvedValue.Contains("*") || resolvedValue.Contains("/") ||
                                                          resolvedValue.Contains("&");

                            if (isExcelFuncResult)
                            {
                                if (resolvedValue.Contains("#CIRCULAR_REFERENCE?"))
                                {
                                    return "=0";
                                }
                                return resolvedValue;
                            }

                            if (hasArithmeticOperators)
                            {
                                bool hasNonNumeric = false;
                                string[] evalTokens = resolvedValue.Split(new char[] { '+', '-', '*', '/', '&' }, StringSplitOptions.RemoveEmptyEntries);
                                foreach (string token in evalTokens)
                                {
                                    string trimmedToken = token.Trim();
                                    if (!decimal.TryParse(trimmedToken, out _) &&
                                        !trimmedToken.StartsWith("\"") && !trimmedToken.EndsWith("\""))
                                    {
                                        hasNonNumeric = true;
                                        break;
                                    }
                                }

                                if (hasNonNumeric)
                                {
                                    return "=\"" + resolvedValue.Replace("\"", "\"\"") + "\"";
                                }

                                string evaluatedResult = EvaluateExpression(resolvedValue);
                                if (evaluatedResult.Contains("#CIRCULAR_REFERENCE?"))
                                {
                                    return "=0";
                                }
                                if (decimal.TryParse(evaluatedResult, System.Globalization.NumberStyles.Any,
                                    System.Globalization.CultureInfo.InvariantCulture, out decimal numVal))
                                {
                                    return "=" + numVal.ToString(System.Globalization.CultureInfo.InvariantCulture);
                                }
                                else
                                {
                                    return "=\"" + evaluatedResult.Replace("\"", "\"\"") + "\"";
                                }
                            }

                            if (!decimal.TryParse(resolvedValue, out _))
                            {
                                if (resolvedValue.StartsWith("\"") && resolvedValue.EndsWith("\""))
                                {
                                    return "=" + resolvedValue;
                                }
                                return "=\"" + resolvedValue.Replace("\"", "\"\"") + "\"";
                            }
                            return "=" + resolvedValue;
                        }
                    }
                    catch (Exception ex)
                    {
                        return "=\"" + processedFormula.Replace("\"", "\"\"") + "\"";
                    }
                }

                return processedFormula;
            }

            // If no ##= header, process data items
            string processedResult = ProcessDataItems(aFormula, designParamList, dataItemList);

            if (!processedResult.StartsWith("=") && !string.IsNullOrEmpty(processedResult))
            {
                if (decimal.TryParse(processedResult, System.Globalization.NumberStyles.Any,
                    System.Globalization.CultureInfo.InvariantCulture, out decimal numVal))
                {
                    return "=" + numVal.ToString(System.Globalization.CultureInfo.InvariantCulture);
                }
                else
                {
                    return "=\"" + processedResult.Replace("\"", "\"\"") + "\"";
                }
            }

            return processedResult;
        }

        /// <summary>
        /// Evaluates string concatenation expressions with & operator
        /// </summary>
        private static string EvaluateStringConcatenation(string expression)
        {
            try
            {
                expression = expression.Trim();

                string result = "";
                int length = expression.Length;
                bool inQuote = false;
                string currentPart = "";

                for (int i = 0; i < length; i++)
                {
                    char c = expression[i];

                    if (c == '"')
                    {
                        inQuote = !inQuote;
                        currentPart += c;
                    }
                    else if (c == '&' && !inQuote)
                    {
                        string trimmedPart = currentPart.Trim();
                        if (trimmedPart.StartsWith("\"") && trimmedPart.EndsWith("\""))
                        {
                            result += trimmedPart.Substring(1, trimmedPart.Length - 2);
                        }
                        else
                        {
                            result += trimmedPart;
                        }
                        currentPart = "";
                    }
                    else
                    {
                        currentPart += c;
                    }
                }

                if (!string.IsNullOrEmpty(currentPart))
                {
                    string trimmedPart = currentPart.Trim();
                    if (trimmedPart.StartsWith("\"") && trimmedPart.EndsWith("\""))
                    {
                        result += trimmedPart.Substring(1, trimmedPart.Length - 2);
                    }
                    else
                    {
                        result += trimmedPart;
                    }
                }

                return result;
            }
            catch (Exception ex)
            {
                return expression;
            }
        }

        /// <summary>
        /// Overload for backward compatibility (with recursionDepth only)
        /// </summary>
        public static string GetSamplingFormula(string aFormula, DesignParamDatasList designParamList,
                    System.ComponentModel.BindingList<DesignItemListData> dataItemList, int recursionDepth)
        {
            return GetSamplingFormula(aFormula, designParamList, dataItemList, recursionDepth, null);
        }

        /// <summary>
        /// Overload for simplest call (no recursionDepth)
        /// </summary>
        public static string GetSamplingFormula(string aFormula, DesignParamDatasList designParamList,
                    System.ComponentModel.BindingList<DesignItemListData> dataItemList)
        {
            return GetSamplingFormula(aFormula, designParamList, dataItemList, 0, null);
        }

        private const int MAX_CELL_EVALUATION_DEPTH = 50;

        /// <summary>
        /// Evaluates a formula by replacing cell references with their actual values from Excel
        /// </summary>
        private static string EvaluateFormulaWithCellValues(string formula, int recursionDepth = 0,
            Stack<string> currentPath = null, Dictionary<string, string> evaluatedCache = null)
        {
            if (currentPath == null)
            {
                currentPath = new Stack<string>();
            }

            if (evaluatedCache == null)
            {
                evaluatedCache = new Dictionary<string, string>();
            }

            if (recursionDepth > MAX_CELL_EVALUATION_DEPTH)
            {
                return "#CIRCULAR_REFERENCE?";
            }

            if (string.IsNullOrEmpty(formula))
                return formula;

            try
            {
                var cellMatches = CellReferenceRegex.Matches(formula);
                string processedFormula = formula;

                for (int i = cellMatches.Count - 1; i >= 0; i--)
                {
                    Match match = cellMatches[i];
                    string cellRef = match.Value;

                    if (currentPath.Contains(cellRef, StringComparer.OrdinalIgnoreCase))
                    {
                        return "#CIRCULAR_REFERENCE?";
                    }

                    string cellValue;

                    if (evaluatedCache.TryGetValue(cellRef, out cellValue))
                    {
                        // Use cached value
                    }
                    else
                    {
                        currentPath.Push(cellRef);

                        try
                        {
                            cellValue = GetCellValue(cellRef);

                            bool isWrappedDataPath = cellValue.StartsWith(RldConst.CALC_ITEM_START) &&
                                                     cellValue.EndsWith(RldConst.CALC_ITEM_END);

                            if (!isWrappedDataPath && CellReferenceRegex.IsMatch(cellValue) &&
                                !cellValue.Equals(cellRef, StringComparison.OrdinalIgnoreCase))
                            {
                                cellValue = EvaluateFormulaWithCellValues(cellValue, recursionDepth + 1, currentPath, evaluatedCache);

                                if (cellValue == "#CIRCULAR_REFERENCE?")
                                {
                                    return "#CIRCULAR_REFERENCE?";
                                }
                            }

                            evaluatedCache[cellRef] = cellValue;
                        }
                        finally
                        {
                            currentPath.Pop();
                        }
                    }

                    processedFormula = processedFormula.Substring(0, match.Index) +
                                       cellValue +
                                       processedFormula.Substring(match.Index + match.Length);
                }

                return processedFormula;
            }
            catch (Exception ex)
            {
                return formula;
            }
        }

        /// <summary>
        /// Gets the value of a cell from the Excel application with safety checks
        /// </summary>
        private static string GetCellValue(string cellReference)
        {
            try
            {
                if (RldLib.XlHelper.XlApp.Application == null)
                    return cellReference;

                cellReference = cellReference.Trim();

                if (!CellReferenceRegex.IsMatch(cellReference))
                    return cellReference;

                dynamic range = null;
                try
                {
                    range = RldLib.XlHelper.XlApp.Application.Range[cellReference];
                }
                catch
                {
                    return cellReference;
                }

                if (range == null)
                    return cellReference;

                object value = range.Value2;

                if (value == null || value == DBNull.Value)
                    return "0";

                string cellValue = value.ToString().TrimEnd();

                if (string.IsNullOrEmpty(cellValue))
                    return "0";

                if (cellValue.StartsWith(RldConst.CALC_HEADER))
                {
                    string innerFormula = cellValue.Substring(RldConst.CALC_HEADER.Length);
                    if (innerFormula.Trim().Equals(cellReference, StringComparison.OrdinalIgnoreCase))
                    {
                        return "0";
                    }
                }

                if (cellValue.StartsWith(RldConst.PATH_HEADER) &&
                    !cellValue.StartsWith(RldConst.CALC_HEADER))
                {
                    return RldConst.CALC_ITEM_START + cellValue + RldConst.CALC_ITEM_END;
                }

                if (cellValue.StartsWith(RldConst.CALC_ITEM_START) &&
                    cellValue.EndsWith(RldConst.CALC_ITEM_END))
                {
                    return cellValue;
                }

                if (decimal.TryParse(cellValue, out decimal numValue))
                {
                    return numValue.ToString(System.Globalization.CultureInfo.InvariantCulture);
                }

                return cellValue;
            }
            catch (Exception ex)
            {
                return cellReference;
            }
        }

        /// <summary>
        /// Evaluates a mathematical expression
        /// </summary>
        private static string EvaluateExpression(string expression)
        {
            try
            {
                if (expression.Contains("#CIRCULAR_REFERENCE?"))
                {
                    return "#CIRCULAR_REFERENCE?";
                }

                expression = expression.Trim();

                if (expression.StartsWith("\"") && expression.EndsWith("\""))
                {
                    return expression.Substring(1, expression.Length - 2);
                }

                if (expression.Contains("&"))
                {
                    return EvaluateStringConcatenation(expression);
                }

                if (expression.Contains("+") || expression.Contains("-") ||
                    expression.Contains("*") || expression.Contains("/"))
                {
                    var dt = new System.Data.DataTable();
                    object result = dt.Compute(expression, "");
                    return result?.ToString() ?? expression;
                }

                return expression;
            }
            catch (Exception ex)
            {
                return expression;
            }
        }

        /// <summary>
        /// Determines whether the formula requires Excel evaluation (contains cell references)
        /// </summary>
        private static bool NeedsExcelEvaluation(string formula)
        {
            if (string.IsNullOrEmpty(formula))
                return false;

            if (decimal.TryParse(formula, out _))
                return false;

            return CellReferenceRegex.IsMatch(formula);
        }

        /// <summary>
        /// Processes all data paths in the formula
        /// </summary>
        private static string ProcessAllDataPaths(string formula, DesignParamDatasList designParamList,
                    System.ComponentModel.BindingList<DesignItemListData> dataItemList)
        {
            if (string.IsNullOrEmpty(formula))
                return formula;

            string result = formula;
            result = ProcessBracketedDataItems(result, designParamList, dataItemList);
            result = ProcessUnbracketedDataPathsInString(result, designParamList, dataItemList);
            result = ProcessCalcHeaderFormulas(result, designParamList, dataItemList);

            return result;
        }

        /// <summary>
        /// Processes embedded ##= formulas within a string
        /// </summary>
        private static string ProcessCalcHeaderFormulas(string formula, DesignParamDatasList designParamList,
                    System.ComponentModel.BindingList<DesignItemListData> dataItemList)
        {
            if (string.IsNullOrEmpty(formula) || !formula.Contains(RldConst.CALC_HEADER))
                return formula;

            string result = formula;
            int searchPos = 0;
            int maxIterations = 10;
            int iteration = 0;

            while (result.Contains(RldConst.CALC_HEADER) && iteration < maxIterations)
            {
                iteration++;
                int startPos = result.IndexOf(RldConst.CALC_HEADER, searchPos);
                if (startPos == -1)
                    break;

                int endPos = startPos + RldConst.CALC_HEADER.Length;
                while (endPos < result.Length)
                {
                    char c = result[endPos];
                    if (c == '+' || c == '-' || c == '*' || c == '/' || c == '&' || c == ' ' || c == ')')
                    {
                        break;
                    }
                    endPos++;
                }

                string subFormula = result.Substring(startPos, endPos - startPos);
                string evaluatedValue = GetSamplingFormula(subFormula, designParamList, dataItemList, 0);

                result = result.Substring(0, startPos) + evaluatedValue + result.Substring(endPos);
                searchPos = startPos + evaluatedValue.Length;
            }

            return result;
        }

        /// <summary>
        /// Processes all data items in the formula
        /// </summary>
        private static string ProcessDataItems(string formula, DesignParamDatasList designParamList,
                    System.ComponentModel.BindingList<DesignItemListData> dataItemList)
        {
            if (string.IsNullOrEmpty(formula))
                return formula;

            string result = ProcessBracketedDataItems(formula, designParamList, dataItemList);
            result = ProcessUnbracketedDataPathsInString(result, designParamList, dataItemList);

            return result;
        }

        /// <summary>
        /// Processes unbracketed data paths in any string
        /// </summary>
        private static string ProcessUnbracketedDataPathsInString(string text, DesignParamDatasList designParamList,
                    System.ComponentModel.BindingList<DesignItemListData> dataItemList)
        {
            if (string.IsNullOrEmpty(text) || !text.Contains(RldConst.PATH_HEADER))
                return text;

            string result = text;
            int maxIterations = 50;
            int iteration = 0;

            while (result.Contains(RldConst.PATH_HEADER) && iteration < maxIterations)
            {
                iteration++;

                var matches = System.Text.RegularExpressions.Regex.Matches(result, @"##[^\s\+\-\*\/\&\(\)\[\]\,""]+");

                if (matches.Count == 0)
                    break;

                for (int i = matches.Count - 1; i >= 0; i--)
                {
                    var match = matches[i];
                    string dataPath = match.Value;

                    if (dataPath.StartsWith(RldConst.CALC_HEADER))
                        continue;

                    string replacement = dataPath;

                    var designParamMatch = designParamList.FirstOrDefault(ele => ele.DataPath == dataPath);
                    if (designParamMatch != null)
                    {
                        replacement = GetPreviewDataValue(designParamMatch.PreviewData);
                    }
                    else
                    {
                        var dataItemMatch = dataItemList.FirstOrDefault(ele => ele.DataPath == dataPath);
                        if (dataItemMatch != null)
                        {
                            replacement = GetPreviewDataValue(dataItemMatch.PreviewData);
                        }
                    }

                    result = result.Substring(0, match.Index) + replacement + result.Substring(match.Index + match.Length);
                }
            }

            return result;
        }

        /// <summary>
        /// Processes only bracketed data items in the format [##...] within the formula
        /// </summary>
        private static string ProcessBracketedDataItems(string formula, DesignParamDatasList designParamList,
                    System.ComponentModel.BindingList<DesignItemListData> dataItemList)
        {
            String wRet = formula;
            Int32 wStartPos = -1, wEndPos = -1;
            string wTemp = string.Empty;
            int commStrPos = -1, commEndPos = -1;
            string cal_start = RldConst.CALC_ITEM_START + RldConst.PATH_HEADER;

            // Process content inside double quotes
            while ((commStrPos = wRet.IndexOf("\"", commEndPos + 1)) >= 0)
            {
                string wRetTemp1 = wRet.Substring(commEndPos + 1, commStrPos - commEndPos - 1);
                string wTmp1 = wRetTemp1;
                wStartPos = -1;
                wEndPos = -1;

                while ((wStartPos = wTmp1.IndexOf(cal_start, wEndPos + 1)) >= 0)
                {
                    wEndPos = wTmp1.IndexOf(RldConst.CALC_ITEM_END, wStartPos + 1);
                    if (wEndPos == -1)
                        break;

                    var wItemPath = wTmp1.Substring(wStartPos + 1, wEndPos - wStartPos - 1);
                    string replacement = wItemPath;

                    if (designParamList.Count(ele => ele.DataPath == wItemPath) > 0)
                    {
                        var wData = designParamList.First(ele => ele.DataPath == wItemPath);
                        replacement = wData.PreviewData;
                    }
                    else if (dataItemList.Count(ele => ele.DataPath == wItemPath) > 0)
                    {
                        var wData = dataItemList.First(ele => ele.DataPath == wItemPath);
                        replacement = wData.PreviewData;
                    }

                    wRetTemp1 = wRetTemp1.Replace(
                        $"{RldConst.CALC_ITEM_START}{wItemPath}{RldConst.CALC_ITEM_END}",
                        replacement);
                }

                wTemp = wTemp + wRetTemp1;
                commEndPos = wRet.IndexOf("\"", commStrPos + 1);
                if (commEndPos == -1)
                {
                    return string.Empty;
                }
                else
                {
                    wTemp = wTemp + wRet.Substring(commStrPos, commEndPos - commStrPos + 1);
                }
            }

            // Process data items that are not inside double quotes
            string wRetTemp = wRet.Substring(commEndPos + 1);
            string wTmp = wRetTemp;
            wStartPos = -1;
            wEndPos = -1;

            while ((wStartPos = wTmp.IndexOf(cal_start, wEndPos + 1)) >= 0)
            {
                wEndPos = wTmp.IndexOf(RldConst.CALC_ITEM_END, wStartPos + 1);
                if (wEndPos == -1)
                    break;

                var wItemPath = wTmp.Substring(wStartPos + 1, wEndPos - wStartPos - 1);
                string replacement = wItemPath;

                if (designParamList.Count(ele => ele.DataPath == wItemPath) > 0)
                {
                    var wData = designParamList.First(ele => ele.DataPath == wItemPath);
                    replacement = wData.PreviewData;
                }
                else if (dataItemList.Count(ele => ele.DataPath == wItemPath) > 0)
                {
                    var wData = dataItemList.First(ele => ele.DataPath == wItemPath);
                    replacement = wData.PreviewData;
                }

                wRetTemp = wRetTemp.Replace(
                    $"{RldConst.CALC_ITEM_START}{wItemPath}{RldConst.CALC_ITEM_END}",
                    replacement);
            }

            wTemp = wTemp + wRetTemp;

            return wTemp;
        }

        /// <summary>
        /// Gets the preview data value formatted as either a number or quoted string
        /// </summary>
        private static string GetPreviewDataValue(string previewData)
        {
            if (string.IsNullOrEmpty(previewData))
                return "\"\"";

            if (decimal.TryParse(previewData, out _))
            {
                return previewData;
            }

            return "\"" + previewData.Replace("\"", "\"\"") + "\"";
        }

        // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end
        // mod #12621 ##=の計算式が保存できないことがある、また、プレビュー値が異常 高 end

        #endregion
    }
}
