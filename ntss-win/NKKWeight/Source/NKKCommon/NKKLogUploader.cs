//----------------------------------------------------------------------------------------------------
// ログアップロード処理
//----------------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.RegularExpressions;
using System.Reflection;
using System.Net;


//----------------------------------------------------------------------------------------------------
//  NKKWebAccessLib名前空間
//----------------------------------------------------------------------------------------------------
using NKKWebAccessLib;

//----------------------------------------------------------------------------------------------------
//  NKKCommon名前空間
//----------------------------------------------------------------------------------------------------
namespace NKKCommon
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// ログアップロード処理用クラス
    ///   ログ格納先フォルダのログファイルをアップロードする
    ///   ログファイル名([strLogExt]_YYYYMMDD.LOG：YYYYMMDDファイル作成日)
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class NKKLogUploader
    {

#region パブリックプロパティ
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アップロードする最大ファイルサイズ(MB単位)
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public int MAX_UPLOAE_MB_SIZE { get; set; } = 8;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アップロードリトライ回数
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public int MAX_RETRY_COUNT { get; set; } = 3;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アプリケーションURI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private String WEB_APP_URI { get; set; } = "/ntss-admin-web";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// sys_system_defineのctl_no
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public int SystemDefineVersionNo { get; set; }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// システム設定取得URI /api/mstInfo/sysSystemDefine
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String GET_SYSTEM_DEFINE_URI { get; set; } = "/api/mstInfo/sysSystemDefine";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログファイルのアップロードURI /api/log/uploader/{処理モード}
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String POST_LOGFILE_UPLOADER_URI { get; set; } = "/api/log/uploader/";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アプリケーション名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String APP_NAME { get; set; } = String.Empty;
        //----------------------------------------------------------------------------------------------------
#endregion

        #region プライベートメソッド

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// sys_system_defineのvalueフィールドを読み込む
        /// </summary>
        /// <param name="systemDefineVersionNo">検索するctr_no</param>
        /// <returns>sys_system_defineのvalueフィールド</returns>
        //----------------------------------------------------------------------------------------------------
        private string GetSystemDefineValue(int systemDefineVersionNo)
        {
            string value = string.Empty;
            string strUri = $"{NKKWebAccessLib.NKKWebAccess.BaseUri}{this.WEB_APP_URI}{this.GET_SYSTEM_DEFINE_URI}/{systemDefineVersionNo}?_={DateTime.Now.Ticks}";
            NKKWebAccessLib.NKKWebAccessResponse res = NKKWebAccessLib.NKKWebAccess.Get("最新バージョン設定取得", strUri).Result;
            if (res.response.IsSuccessStatusCode == true)
            {

                // JSON文字列をデシリアライズする
                var deserializedData = new List<SysSystemDefine>();
                using (var ms = new System.IO.MemoryStream(Encoding.UTF8.GetBytes(res.strContent)))
                {
                    var ser = new System.Runtime.Serialization.Json.DataContractJsonSerializer(deserializedData.GetType());
                    deserializedData = ser.ReadObject(ms) as List<SysSystemDefine>;
                    ms.Close();
                }
                if (deserializedData.Count > 0)
                {
                    // valueをデシリアライズする
                    value = deserializedData[0].Value;

                }

            }

            return value;
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定ファイルを削除する
        /// </summary>
        /// <param name="strFileName">削除するファイル名</param>
        //----------------------------------------------------------------------------------------------------
        private void DeleteFile( String strFileName )
        {
            NKKLoggingLib.NKKLogging log = NKKLoggingLib.NKKLogging.GetInstance();
            try
            {
                // 指定ファイルを削除
                System.IO.File.Delete(strFileName);

                // ログ記録
                log.AddLogInfo(DateTime.Now, this.GetType().Name, NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO,
                    String.Format("ファイル削除:{0}",  strFileName));
            }
            catch (Exception ex)
            {
                // ログ記録
                log.AddLogInfo(DateTime.Now, this.GetType().Name, NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR,
                    String.Format("{0}.{1},ファイル削除失敗:{2},error:{3}", this.GetType().Name, MethodBase.GetCurrentMethod().Name, strFileName, ex.ToString()));
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// POST処理(ログファイルアップロード用REST[/api/log/uploader]専用)
        /// </summary>
        /// <param name="strFuncName">処理名称</param>
        /// <param name="strUri">Uri</param>
        /// <param name="strAppName">アップロードを行うアプリケーション名</param>
        /// <param name="strFileName">送信ファイル名</param>
        /// <param name="strServerLoginArg">ServerLoginメソッドに渡る引数</param>
        /// <returns>NKKWebAccessレスポンスオブジェクト</returns>
        //----------------------------------------------------------------------------------------------------
        private async Task<NKKWebAccessResponse> Post(String strFuncName, String strUri, String strUploadedFileName, String strFileName, String strServerLoginArg)
        {
            NKKLoggingLib.NKKLogging log = NKKLoggingLib.NKKLogging.GetInstance();

            NKKWebAccessResponse nwar = new NKKWebAccessResponse();
            bool isLastRest401or403 = false;

            // リトライ処理
            for (int intlop = 0; intlop < this.MAX_RETRY_COUNT; intlop++)
            {
                // 「2回目以降 かつ 直前のRESTが401/403でない」はリトライにウェイトをいれる
                if (1 <= intlop && false == isLastRest401or403)
                {
                    System.Threading.Thread.Sleep(10 * 1000);
                }

                // 未サインイン状態だったら事前入力情報でサインインを試行
                if (false == NKKWebAccess.Login)
                {
                    isLastRest401or403 = false; // REST直前で一旦リセット
                    nwar = await NKKWebAccess.ServerLogin(strServerLoginArg);

                    if (HttpStatusCode.Unauthorized == nwar.response.StatusCode || HttpStatusCode.Forbidden == nwar.response.StatusCode)
                    {
                        isLastRest401or403 = true;
                    }
                }

                if (true == NKKWebAccess.Login)
                {
                    try
                    {
                        using (var wContent = new System.Net.Http.MultipartFormDataContent())
                        {
                            // アップロードするアプリケーション名
                            wContent.Add(new System.Net.Http.StringContent(this.APP_NAME), "appName");
                            // アップロード先のファイル名
                            wContent.Add(new System.Net.Http.StringContent(strUploadedFileName), "fileName");

                            //　アップロードするファイル
                            var wFileContent = new System.Net.Http.StreamContent(System.IO.File.OpenRead(strFileName));
                            wFileContent.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("form-data")
                            {
                                Name = "upFile",
                                FileName = System.IO.Path.GetFileName(strFileName)
                            };
                            wContent.Add(wFileContent);

                            // CSRF用トークンをヘッダに追加
                            wContent.Headers.Add("X-XSRF-TOKEN", NKKWebAccess.GetCSRFToken(strUri));

                            isLastRest401or403 = false; // REST直前で一旦リセット
                            nwar.response = Task.Run(() => NKKWebAccess.HttpClient.PostAsync(strUri, wContent)).Result;

                            if (nwar.response.IsSuccessStatusCode)
                            {
                                nwar.strContent = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;
                                nwar.isLogin = true;
                                NKKWebAccess.Login = true;

                                break;
                            }
                            else
                            {
                                nwar.strContent = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;
                                nwar.isLogin = false;
                                NKKWebAccess.Login = false;

                                if (HttpStatusCode.Unauthorized == nwar.response.StatusCode || HttpStatusCode.Forbidden == nwar.response.StatusCode)
                                {
                                    isLastRest401or403 = true;
                                }

                                log.AddLogInfo(DateTime.Now, this.GetType().Name, NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, String.Format("{0}処理失敗,{1},{2}", strFuncName, strUri, nwar.response.StatusCode));
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        nwar.strContent = "";
                        nwar.isLogin = false;
                        NKKWebAccess.Login = false;

                        nwar.response.StatusCode = (HttpStatusCode)999; // 勝手な定義
                        nwar.response.ReasonPhrase = "サーバ接続不可などの例外発生";

                        log.AddLogInfo(DateTime.Now, this.GetType().Name, NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, String.Format("{0}処理失敗,{1},{2}", strFuncName, strUri, ex.ToString().Replace("\r\n", "{CRLF}")));
                    }
                }
            }

            return nwar;
        }
        //----------------------------------------------------------------------------------------------------

        #endregion

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログファイルをアップロードする
        /// </summary>
        /// <param name="strAppName">アップロードを行うアプリケーション名</param>
        //----------------------------------------------------------------------------------------------------
        public void UploadLog(String strAppName)
        {
            const String strSearchPattern = "\\d{4}[0-1]\\d[0-3]\\d\\.ZIP";
            NKKLoggingLib.NKKLogging log = NKKLoggingLib.NKKLogging.GetInstance();

            try
            {
                // アプリケーション名設定
                this.APP_NAME = strAppName;

                // ログ記録：処理開始
                log.AddLogInfo(DateTime.Now, this.GetType().Name, NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, "ログアップロード処理開始");

                // 正規表現によるファイル名マッチングパターン登録
                Regex reg = new Regex(strSearchPattern, RegexOptions.IgnoreCase);

                // ログファイルを圧縮する
                log.ZipLogFiles(this.GetType().Name, true);

                List<String> uploadFiles = new List<String>();
                Boolean isSuccess = false;

                // ログファイル格納先に格納されている圧縮ファイルを全て取得する
                String[] logfiles = System.IO.Directory.GetFiles(log.LogFolder, "*.ZIP", System.IO.SearchOption.TopDirectoryOnly);
                foreach (String strfile in logfiles)
                {
                    isSuccess = false;
                    uploadFiles.Clear();
                    uploadFiles.Add(strfile);

                    // ファイル名(+拡張子)のみ取得
                    String strfilename = System.IO.Path.GetFileName(strfile);

                    // ファイル名チェック
                    if (reg.Match(strfilename).Success == true)
                    {
                        // 有効なファイル名の場合

                        Boolean bSeparated = false;

                        // ファイルサイズを取得
                        System.IO.FileInfo file = new System.IO.FileInfo(strfile);
                        // 指定ファイルサイズをMB→byte単位に変換
                        long maxfilesize = (long)MAX_UPLOAE_MB_SIZE * 1024 * 1024;

                        // 指定ファイルサイズを超えているかどうか
                        if (maxfilesize < file.Length)
                        {
                            bSeparated = true;

                            // 指定サイズに分割する
                            uploadFiles.Clear();
                            uploadFiles = TdcLib.TdcLib.SeparateFile(strfile, maxfilesize);

                            // ログ記録：分割結果
                            log.AddLogInfo(DateTime.Now, this.GetType().Name, NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO,
                                String.Format("ログを分割:{0} → {1}分割({2}MB制限)", strfile, uploadFiles.Count, MAX_UPLOAE_MB_SIZE));
                        }

                        for (int intlop = 0; intlop < uploadFiles.Count; intlop++)
                        {
                            String uploadfile = uploadFiles[intlop];

                            // REST-APIの仕様
                            //  処理モードにより「/tmp/{施設コード}/」に作成するファイルの生成方法が変わる
                            //      0：分割なし(新規作成してからファイル移動)
                            //      1：分割あり先頭(分割前ファイル名で新規作成)
                            //      2：分割あり途中(分割前ファイルの末尾に追記)
                            //      3：分割あり最後(分割前ファイルの末尾に追記してからファイル移動)
                            int mode = 0
                                // 分割あり
                                + (bSeparated ? 1 : 0);
                            // 分割あり
                            if (bSeparated)
                            {
                                // 分割あり：途中
                                mode += (0 < intlop ? 1 : 0);
                                mode += (intlop == (uploadFiles.Count - 1) ? 1 : 0);
                            }

                            // ファイルをアップロードする(/{srv}/ntss-admin-web/api/log/uploader/{mode})
                            String strUri = String.Format("{0}{1}{2}{3}?_={4}"
                                , NKKWebAccess.BaseUri
                                , this.WEB_APP_URI
                                , this.POST_LOGFILE_UPLOADER_URI
                                , mode
                                , DateTime.Now.Ticks);

                            // ログ記録：ファイルアップロード
                            log.AddLogInfo(DateTime.Now, this.GetType().Name, NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO,
                                String.Format("ログアップロード開始:{0}/[{1}]/mode:{2}", uploadfile, intlop + 1, mode));

                            // add #9696 アプリケーションログのパスとファイル名の修正。 donghao start
                            //if (SignInLib.SignIn.SignInInfo !=null)
                            //{
                            //    if (!String.IsNullOrEmpty(SignInLib.SignIn.SignInInfo.FacilityCode))
                            //    {
                            //        strfilename = SignInLib.SignIn.SignInInfo.FacilityCode + "_" + strfilename;
                            //    }
                            //    else
                            //    {
                            //        strfilename = NKKWebAccess.FacilityCd + "_" + strfilename;

                            //    }


                            //}
                            //else
                            {
                                if (!String.IsNullOrEmpty(NKKWebAccess.FacilityCd))
                                {
                                    if (!strfilename.Contains(NKKWebAccess.FacilityCd))
                                    {
                                        strfilename = NKKWebAccess.FacilityCd + "_" + strfilename;
                                    }
                                }
                            }
                            // add #9696 アプリケーションログのパスとファイル名の修正。 donghao end

                            // POST処理
                            NKKWebAccessResponse res = this.Post("ログファイルアップロード", strUri, strfilename, uploadfile, "").Result;
                            if (res.response.IsSuccessStatusCode == true)
                            {
                                // 成功
                                isSuccess = true;

                                // ログ記録：ファイルアップロード成功
                                log.AddLogInfo(DateTime.Now, this.GetType().Name, NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO,
                                    String.Format("ログアップロード成功:{0}/[{1}]/mode:{2}", uploadfile, intlop + 1, mode));
                            }
                            else
                            {
                                // 失敗
                                isSuccess = false;

                                // ログ記録：ファイルアップロード失敗
                                String resContent = res.strContent;
                                log.AddLogInfo(DateTime.Now, this.GetType().Name, NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO,
                                    String.Format("ログアップロード失敗:{0}/[{1}]/mode:{2},error:{3}", uploadfile, intlop + 1, mode, resContent));

                                break;
                            }
                        }

                        // 分割判定
                        if (bSeparated)
                        {
                            // 分割した場合

                            // 分割ファイルを削除
                            foreach (String strdelfile in uploadFiles)
                            {
                                this.DeleteFile(strdelfile);
                            }
                        }

                        // アップロード結果判定
                        if( isSuccess )
                        {
                            // 成功

                            // アップロード対象のログファイルを削除
                            this.DeleteFile(strfile);
                        }
                        else
                        {
                            // 失敗
                        }
                    }
                }

                // ログ記録：処理終了
                log.AddLogInfo(DateTime.Now, this.GetType().Name, NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, "ログアップロード処理終了");
            }
            catch( Exception ex )
            {
                log.AddLogInfo(DateTime.Now, this.GetType().Name, NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR,
                    String.Format("{0}.{1},error:{2}", this.GetType().Name, MethodBase.GetCurrentMethod().Name, ex.ToString()));
            }
        }
        //----------------------------------------------------------------------------------------------------
    }
    //----------------------------------------------------------------------------------------------------
}
