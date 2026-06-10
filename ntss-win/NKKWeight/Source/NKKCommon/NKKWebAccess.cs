//----------------------------------------------------------------------------------------------------
//  NKKWebAccessクラス定義
//  ※singleton
//----------------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Text;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;

//----------------------------------------------------------------------------------------------------
//  名前空間:NKKLoggingLib
//----------------------------------------------------------------------------------------------------
using NKKLoggingLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWebClientLib
//----------------------------------------------------------------------------------------------------
using NKKWebClientLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:ToGUILib
//----------------------------------------------------------------------------------------------------
using ToGUILib;
using System.ComponentModel;
using System.Threading;
//----------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWebAccessLib
//----------------------------------------------------------------------------------------------------
namespace NKKWebAccessLib
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// NKKWebAccessクラスのGet/Put/Post戻り値
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class NKKWebAccessResponse
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログインフラグ false：未ログイン(REST通知不可)/true：ログイン
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public Boolean isLogin = false;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// レスポンスオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public HttpResponseMessage response = new HttpResponseMessage();
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンテンツオブジェクト
        /// ※処理成功時にコンテンツを格納
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String strContent = String.Empty;
        //----------------------------------------------------------------------------------------------------
    }
    //----------------------------------------------------------------------------------------------------

    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// NKKWebAccessクラス
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class NKKWebAccess : ToGUI
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String SERVICE_NAME = "Server";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログインURI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static readonly String POST_LOGIN_URI = "/ntss-admin-web/api/login";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ユーザー情報取得URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        //private static readonly String GET_USER_URI = "/ntss-admin-web/api/user";
        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
        private static readonly String GET_USER_URI = "/ntss-admin-web/api/user";
        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバーへのアクセス処理の最大リトライ回数
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static readonly int SERVER_MAX_RETRY_COUNT = 3;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ServerLoginメソッドで引数に渡すと「サインインREST側でOTP確認をOK扱い」にしてくれる
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static readonly string SKIP_OTP = "\tskipotp\t";
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 内部保持クラスオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static volatile NKKWebAccess m_Instance = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ロックオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly static object m_syncRoot = new Object();
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// テキストエンコード
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static readonly System.Text.Encoding TEXT_ENCODE = System.Text.Encoding.UTF8;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// クライアント証明書の検索キー1値
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_strClientCertificateSearchValue1 = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// クライアント証明書の検索キー2値
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_strClientCertificateSearchValue2 = String.Empty;
        //----------------------------------------------------------------------------------------------------


        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ベースURI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_strBaseUri = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ユーザーID
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_strUserId = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// パスワード
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_strPW = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// URLエンコード済み施設のハッシュ値
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_strUrlEncodeFacilityHash = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 施設のハッシュ値
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_strFacilityHash = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ユーザー番号
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_strUserNo = String.Empty;
        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 利用者名_姓
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_strUserLastName = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 利用者名_名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_strUserFirstName = String.Empty;
        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 施設コード
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_strFacilityCd = String.Empty;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログイン時のWebRequestHandlerオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static WebRequestHandler m_webRequestHandler = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログイン時のHttpClientオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static HttpClient m_httpClient = null;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// HttpClientのロック
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static Semaphore smpClient = new Semaphore(1, 1);

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログイン状態フラグ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static Boolean m_Login = false;
        //----------------------------------------------------------------------------------------------------

        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        /// <summary>
        /// 利用者種別
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_strUserType = String.Empty;
        //----------------------------------------------------------------------------------------------------
        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end

        private static BackgroundWorker _checlConnectWorker = new BackgroundWorker();

        private static bool _isStopCheckingConnect = false;

        private static bool _isOnline = false;

        private static string stopSetStr = "2";


        #region パブリックプロパティ

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// テキストエンコーディング参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static Encoding Encoding
        {
            get { return (TEXT_ENCODE); }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// クライアント証明書の検索キー1値参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String ClientCertificateSearchValue1
        {
            get { return m_strClientCertificateSearchValue1; }
            set { m_strClientCertificateSearchValue1 = value; }

        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// クライアント証明書の検索キー2値参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String ClientCertificateSearchValue2
        {
            get { return m_strClientCertificateSearchValue2; }
            set { m_strClientCertificateSearchValue2 = value; }

        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ベースURI参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String BaseUri
        {
            get { return (m_strBaseUri); }
            set { m_strBaseUri = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ユーザーID参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String UserId
        {
            get { return (m_strUserId); }
            set { m_strUserId = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// パスワード参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String Password
        {
            get { return (m_strPW); }
            set { m_strPW = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// URLエンコード済みの施設のハッシュ値参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String UrlEncodeFacilityHash
        {
            get { return (m_strUrlEncodeFacilityHash); }
            set
            {
                m_strUrlEncodeFacilityHash = value;
                m_strFacilityHash = System.Web.HttpUtility.UrlDecode(m_strUrlEncodeFacilityHash);
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 施設のハッシュ値参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String FacilityHash
        {
            get { return (m_strFacilityHash); }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ユーザー番号参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String UserNo
        {
            get { return (m_strUserNo); }
            set { m_strUserNo = value; }
        }
        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 利用者名_姓参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String UserLastName
        {
            get { return (m_strUserLastName); }
            set { m_strUserLastName = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 利用者名_名参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String UserFirstName
        {
            get { return (m_strUserFirstName); }
            set { m_strUserFirstName = value; }
        }
        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 施設コード参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String FacilityCd
        {
            get { return (m_strFacilityCd); }
            set { m_strFacilityCd = value; }
        }
        //----------------------------------------------------------------------------------------------------

        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 利用者種別
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String UserType
        {
            get { return (m_strUserType); }
            set { m_strUserType = value; }
        }
        //----------------------------------------------------------------------------------------------------
        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end


        #endregion

        #region プライベートメソッド(コンストラクタ/デストラクタ)

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private NKKWebAccess()
        {
            // セキュリティ設定
            System.Net.ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            // サーバー側が自己証明書の場合は以下コメントを解除
            //System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// デストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void Dispose()
        {
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログ記録
        /// </summary>
        /// <param name="dtNow">発生日時</param>
        /// <param name="LoggingClass">ログ区分</param>
        /// <param name="strMesssage">記録メッセージ</param>
        //----------------------------------------------------------------------------------------------------
        private static void AddLogInfo(DateTime dtNow, NKKLogging.LOGGING_CLASS LoggingClass, String strMesssage)
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // ログ記録
            log.AddLogInfo(dtNow, SERVICE_NAME, LoggingClass, strMesssage);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GUI通知
        /// </summary>
        /// <param name="strStatus">状態</param>
        /// <param name="dtOccurDate">発生日時</param>
        /// <param name="strMessage">内容</param>
        //----------------------------------------------------------------------------------------------------
        private void SendMessageToGUI(String strStatus, DateTime dtOccurDate, String strMessage)
        {
            // GUIへ通知
            base.SendMessageToGUI(NKKWebAccess.SERVICE_NAME, strStatus, dtOccurDate, strMessage);
        }
        //----------------------------------------------------------------------------------------------------


#endregion


        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 処理オブジェクト取得
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static NKKWebAccess GetInstance()
        {
            if (m_Instance == null)
            {
                lock (m_syncRoot)
                {
                    if (m_Instance == null)
                        m_Instance = new NKKWebAccess();
                }
            }

            return (m_Instance);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 処理オブジェクト破棄
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static void DeleteInstance()
        {
            if (m_Instance != null)
            {
                lock (m_syncRoot)
                {
                    if (m_Instance != null)
                        m_Instance.Dispose();

                    m_Instance = null;
                }
            }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログイン状態参照/設定用プロパティ(true：ログイン中/false：未ログイン)
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static Boolean Login
        {
            get { return (m_Login); }
            set
            {
                if (false == value)
                {
                    NKKLogging.GetInstance().AccountId = "";
                }

                string message = string.Empty;
                if(m_Login != value)
                {
                    if (value)
                    {
                        message = "Connected";
                    }
                    else
                    {
                        message = "Disconnected";
                    }

                    m_Login = value;
                    NKKWebAccess.GetInstance().SendMessageToGUI(message, DateTime.Now, "");
                }
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GUI通知参照/設定用イベントハンドラー
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static dgtSendMessageToGUI SendMessageHandler
        {
            get { return (NKKWebAccess.GetInstance().SendMessageToGUIHandler); }
            set { NKKWebAccess.GetInstance().SendMessageToGUIHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログイン時のクッキーコンテナ参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static CookieContainer CookieContainer
        {
            get { return (m_webRequestHandler.CookieContainer); }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログイン時のWebRequestHandlerオブジェクト参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static WebRequestHandler WebRequestHandler
        {
            get { return m_webRequestHandler; }
            set
            {
                //
                if (m_webRequestHandler != null)
                {
                    m_webRequestHandler.Dispose();
                }

                //
                m_webRequestHandler = value;

                // クッキー設定
                m_webRequestHandler.UseCookies = true;

                // クライアント証明書の使用有無
                if (!String.IsNullOrEmpty(ClientCertificateSearchValue1) || !String.IsNullOrEmpty(ClientCertificateSearchValue2))
                {
                    // 使用する場合

                    // クライアント証明書を登録
                    m_webRequestHandler.ClientCertificates.Add(GetX509Certificate(ClientCertificateSearchValue1, ClientCertificateSearchValue2));
                }
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログイン時のHttpClientオブジェクト参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static HttpClient HttpClient
        {
            get
            {
                return m_httpClient;
            }
            set
            {
                //
                if (m_httpClient != null)
                {
                    m_httpClient.Dispose();
                }

                m_httpClient = value;

                // タイムアウト時間設定(30秒)
                m_httpClient.Timeout = TimeSpan.FromMilliseconds(30 * 1000);
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定したキーでクライアント証明書を取得する
        /// </summary>
        /// <param name="strValue1">検索用のキー値1</param>
        /// <param name="strValue2">検索用のキー値2</param>
        /// <returns>null：合致なし/else：取得したX509証明書</returns>
        //----------------------------------------------------------------------------------------------------
        public static X509Certificate2 GetX509Certificate(String strValue1, String strValue2)
        {
            X509Certificate2 ret = null;

            // ログ記録：
            AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "クライアント証明書取得開始, 検索キー:" + strValue1 + " / " + strValue2);


            // 証明書ストアの情報取得
            StoreLocation[] stores = (StoreLocation[])Enum.GetValues(typeof(StoreLocation));
            StoreName[] storeNames = (StoreName[])Enum.GetValues(typeof(StoreName));

            // 証明書ストアの場所分
            for (int intlop1 = 0; ret == null && intlop1 < stores.Length; intlop1++)
            {
                StoreLocation storeLocation = stores[intlop1];

                //　証明書ストアの名前分
                for (int intlop2 = 0; ret == null && intlop2 < storeNames.Length; intlop2++)
                {
                    // 場所と名前を指定して証明書ストアを作成
                    X509Store store = new X509Store(storeNames[intlop2], storeLocation);

                    try
                    {
                        // 証明書ストアを開く
                        store.Open(OpenFlags.OpenExistingOnly | OpenFlags.ReadOnly);

                        // 証明書の一覧を取得
                        X509Certificate2Collection findResult = store.Certificates;

                        // 現時点の日付で有効な証明書に絞り込む
                        findResult = findResult.Find(X509FindType.FindByTimeValid, DateTime.Now, false);
                        // サブジェクト名から検索キー値1で証明書を絞り込む
                        findResult = findResult.Find(X509FindType.FindBySubjectName, strValue1, false);
                        // サブジェクト名から検索キー値2で証明書を絞り込む
                        findResult = findResult.Find(X509FindType.FindBySubjectName, strValue2, false);
                        if (0 < findResult.Count)
                        {
                            ret = findResult[0];
                            AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "クライアント証明書取得, 表示名:" + ret.FriendlyName + "/サブジェクト名：" + ret.SubjectName.Name);
                        }

                        //for ( int intlop = 0; ret == null && intlop < findResult.Count; intlop++ )
                        //{
                        //    // TODO:表示名による検索(暫定)
                        //    X509Certificate2 value = findResult[intlop];
                        //    if (value.FriendlyName.ToUpper().Contains(strValue.ToUpper()))
                        //    {
                        //        // ログ記録：
                        //        AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "クライアント証明書取得, 表示名:" + value.FriendlyName);
                        //        ret = value;
                        //    }
                        //}
                    }
                    catch (Exception ex)
                    {
                        // ログ記録
                        AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("クライアント証明書取得失敗,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                    }
                    finally
                    {
                        store.Close();
                    }
                }
            }

            // ログ記録：
            if (ret != null)
            {
                AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "クライアント証明書取得終了");
            }
            else
            {
                AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "クライアント証明書取得終了, 合致なし");
            }
            return ret;
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// JSON分解
        /// </summary>
        /// <param name="strData"></param>
        /// <returns></returns>
        //----------------------------------------------------------------------------------------------------
        public static Dictionary<String, String> GetJsonData(String strData)
        {
            return TdcLib.JSONLib.JSONtoData(strData);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// CSRF用トークン取得
        /// </summary>
        /// <param name="strUri">URI</param>
        /// <returns>トークン文字列</returns>
        //----------------------------------------------------------------------------------------------------
        public static String GetCSRFToken(String strUri)
        {
            String strtoken = String.Empty;

            // CSRF用トークンを取得
            foreach (Cookie cookie in NKKWebAccess.CookieContainer.GetCookies(new Uri(strUri)))
            {
                if (cookie.Name.Equals("XSRF-TOKEN"))
                {
                    strtoken = cookie.Value;
                    break;
                }
            }

            return (strtoken);
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続監視開始する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static void StartCheckConnection()
        {
            _checlConnectWorker = new BackgroundWorker();
            // del #5964 プロンプトボックスの内容を変更する 王永吉 strat
            //_checlConnectWorker.DoWork += new DoWorkEventHandler(DoCheckConnect);
            //_checlConnectWorker.RunWorkerAsync();
            // del #5964 プロンプトボックスの内容を変更する 王永吉 end
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続監視終了する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static void StopCheckConnection()
        {
            _isStopCheckingConnect = true;
            _checlConnectWorker.Dispose();
            _checlConnectWorker = null;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続チェック
        /// </summary>
        /// <param name="o"></param>
        /// <param name="args"></param>
        //----------------------------------------------------------------------------------------------------
        private static void DoCheckConnect(object o, DoWorkEventArgs args)
        {
            while(!_isStopCheckingConnect)
            {
                if (CheckConnect())
                {
                    Login = true;
                }
                else
                {
                    Login = false;
                }
                Thread.Sleep(3000);
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続チェック
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------------------------------------------
        private static bool CheckConnect()
        {
            bool ret = false;

            if (HttpClient != null)
            {
                String struri = String.Format("{0}{1}?_={2}", BaseUri, GET_USER_URI, DateTime.Now.Ticks);

                smpClient.WaitOne();
                try
                {
                    // ユーザー情報取得

                    var res = Task.Run(() => HttpClient.GetAsync(struri)).Result;

                    // 結果判定
                    if (res.IsSuccessStatusCode == true)
                    {
                        ret = true;
                    }
                }
                catch 
                { 
                }
                finally
                {
                    smpClient.Release();
                }
            }

            return ret;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログイン処理(※互換用)
        /// </summary>
        /// <returns>ログイン結果(-1:サーバー未到達/0：失敗/1：成功)</returns>
        //----------------------------------------------------------------------------------------------------
        public static async Task<int> ServerLogin()
        {
            int ret = -1;
            Boolean bret = false;

            NKKWebAccess.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"サインイン 施設ハッシュ[{FacilityHash}]");

            // Uri作成
            String struri = String.Format("{0}{1}?_={2}", NKKWebAccess.BaseUri, POST_LOGIN_URI, DateTime.Now.Ticks);

            smpClient.WaitOne();
            try
            {
                String strdata = String.Empty;

                // WebRequestHandler構築
                NKKWebAccess.WebRequestHandler = new WebRequestHandler();

                // HttpClient構築
                NKKWebAccess.HttpClient = new HttpClient(NKKWebAccess.WebRequestHandler);

                // ログイン処理
                HttpContent content = new FormUrlEncodedContent(new Dictionary<String, String>
                    {{ "userId", NKKWebAccess.UserId }
                    ,{ "password", NKKWebAccess.Password }
                    ,{ "facilityCd", NKKWebAccess.FacilityHash }
                });
                HttpResponseMessage res = Task.Run(() => NKKWebAccess.HttpClient.PostAsync(struri, content)).Result;

                // 結果判定
                if (res.IsSuccessStatusCode == true)
                {
                    // ログイン成功
                    ret = 1;
                    bret = true;

                    // 応答取得
                    strdata = Task.Run(() => res.Content.ReadAsStringAsync()).Result;

                    // JSON分解
                    Dictionary<String, String> tbl = GetJsonData(strdata);

                    // ユーザー番号取得
                    if (tbl.ContainsKey("userId") == true)
                    {
                        NKKWebAccess.UserNo = tbl["userId"];
                        NKKLogging.GetInstance().AccountId = tbl["userId"];
                    }
                    // 施設コード取得
                    if (tbl.ContainsKey("facilityCd") == true)
                    {
                        NKKWebAccess.FacilityCd = tbl["facilityCd"];
                        NKKLogging.GetInstance().FacilityCd = tbl["facilityCd"];
                    }

                    //// クッキー保持
                    ////m_cookieContainer = clienthandler.CookieContainer;

                    // 
                    NKKWebAccess.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("ログイン成功,{0}", struri));

                    //// DEBUG
                    //NKKWebAccess.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO
                    //    , String.Format("FacilityCd:{0},UserNo:{1}", NKKWebAccess.FacilityCd, NKKWebAccess.UserNo));

                    // GUIへ通知
                    NKKWebAccess.GetInstance().SendMessageToGUI("接続中", DateTime.Now, "ログイン成功");


                    //// Uri作成
                    //struri = String.Format("{0}{1}?_={2}", NKKWeightInformation.BaseUri, GET_USER_URI, DateTime.Now.Ticks);

                    //// ユーザー情報取得
                    //res = await client.GetAsync(struri);
                    //// 結果判定
                    //if (res.IsSuccessStatusCode == true)
                    //{
                    //    // 応答取得
                    //    strdata = await res.Content.ReadAsStringAsync();

                    //    // DEBUG
                    //    NKKWebAccess.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("User:{0}", strdata));
                    //}
                }
                else if (res.StatusCode == HttpStatusCode.ServiceUnavailable)
                {
                    // 503 サーバーが一時的に利用できない
                    // EC2が起動していない場合
                    ret = -1;

                    //
                    AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, string.Format("ログイン失敗,{0},{1}", struri, res.ReasonPhrase));

                    // GUIへ通知
                    // "Service Unavailable: Back-end server is at capacity" と通知される
                    GetInstance().SendMessageToGUI("未接続", DateTime.Now, res.ReasonPhrase);

                }
                else
                {
                    // 200以外

                    // ログイン失敗
                    ret = 0;

                    // 
                    NKKWebAccess.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("ログイン失敗,{0}", struri));

                    // GUIへ通知
                    NKKWebAccess.GetInstance().SendMessageToGUI("未接続", DateTime.Now, "ログイン失敗");
                }
            }
            catch (Exception ex)
            {
                // エラー(サーバー未到達含む)

                //
                NKKWebAccess.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("ログイン失敗,{0},{1}", struri, ex.ToString().Replace("\r\n", "{CRLF}")));

                // GUIへ通知
                NKKWebAccess.GetInstance().SendMessageToGUI("未接続", DateTime.Now, "ログイン失敗");
            }
            finally
            {
                smpClient.Release();
            }

            Login = bret;

            return (ret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログイン処理(RESTが400系エラーの場合にエラーメッセージも取得する版)
        /// </summary>
        /// <param name="argOtpCd">{"サインイン":"空","2要素認証のためのOTPサインイン":"OTP文字列","OTP免除のサインイン":SKIP_OTP変数で定義された文字列}</param>
        /// <returns>
        /// サインインRESTのレスポンス＋response.ReasonPhraseに「エラーメッセージ」
        /// ＋strContentに「ログイン結果(-1:サーバー未到達や失敗[503]/0：失敗[200系でも503でもない]/1：成功[200系])」</returns>
        //----------------------------------------------------------------------------------------------------
        public static async Task<NKKWebAccessResponse> ServerLogin(string argOtpCd)
        {
            NKKWebAccessResponse nwar = new NKKWebAccessResponse();

            NKKWebAccess.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"サインイン 施設ハッシュ[{FacilityHash}]");

            // Uri作成
            String struri = String.Format("{0}{1}?_={2}", BaseUri, POST_LOGIN_URI, DateTime.Now.Ticks);
            smpClient.WaitOne();
            try
            {
                // WebRequestHandler構築
                WebRequestHandler = new WebRequestHandler();

                // HttpClient構築
                HttpClient = new HttpClient(WebRequestHandler);

                // ログイン処理
                HttpContent content;
                if (string.IsNullOrWhiteSpace(argOtpCd))
                {
                    content = new FormUrlEncodedContent(new Dictionary<String, String> { { "userId", UserId }, { "password", Password }, { "facilityCd", FacilityHash } });
                }
                else if (SKIP_OTP == argOtpCd)
                {
                    content = new FormUrlEncodedContent(new Dictionary<String, String> { { "userId", UserId }, { "password", "_" }, { "facilityCd", FacilityHash }, { "funcCd", "_" } });
                }
                else
                {
                    content = new FormUrlEncodedContent(new Dictionary<String, String> { { "userId", UserId }, { "password", Password }, { "facilityCd", FacilityHash }, { "otpCd", argOtpCd } });
                }
                nwar.response = Task.Run(() => HttpClient.PostAsync(struri, content)).Result;

                // 結果判定
                if (nwar.response.IsSuccessStatusCode)
                {
                    // 応答取得 と JSON分解
                    string strdata = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;
                    Dictionary<String, String> tbl = GetJsonData(strdata);

                    // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
                    // ユーザー番号取得
                    if (tbl.ContainsKey("userId") == true)
                    {
                        NKKWebAccess.UserNo = tbl["userId"];
                    }
                    // 施設コード取得
                    if (tbl.ContainsKey("facilityCd") == true)
                    {
                        NKKWebAccess.FacilityCd = tbl["facilityCd"];
                    }

                    // DEBUG
                    NKKWebAccess.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, String.Format("FacilityCd:{0},UserNo:{1}", NKKWebAccess.FacilityCd, NKKWebAccess.UserNo));

                    // Uri作成
                    struri = String.Format("{0}{1}?_={2}", BaseUri, GET_USER_URI, DateTime.Now.Ticks);

                    NKKWebAccessResponse res = new NKKWebAccessResponse();

                    // ユーザー情報取得
                    res.response = Task.Run(() => HttpClient.GetAsync(struri)).Result;

                    // 結果判定
                    if (res.response.IsSuccessStatusCode == true)
                    {
                        // 応答取得
                        string strdatalRes = await res.response.Content.ReadAsStringAsync();

                        // DEBUG
                        NKKWebAccess.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, String.Format("User:{0}", strdatalRes));

                        Dictionary<String, String> tblRes = GetJsonData(strdatalRes);
                        if (tblRes.ContainsKey("userAccountInfo") == true)
                        {
                            Dictionary<String, String> tblResUser = GetJsonData(tblRes["userAccountInfo"]);
                            // 利用者名_姓取得
                            if (tblResUser.ContainsKey("userLastName") == true)
                            {
                                NKKWebAccess.UserLastName = tblResUser["userLastName"];
                            }
                            // 利用者名_名取得
                            if (tblResUser.ContainsKey("userFirstName") == true)
                            {
                                NKKWebAccess.UserFirstName = tblResUser["userFirstName"];
                            }
                            // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
                            // 利用者種別
                            if (tblResUser.ContainsKey("userType") == true)
                            {
                                NKKWebAccess.UserType = tblResUser["userType"];
                            }
                            // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
                        }
                    }
                    // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end

                    if (tbl.ContainsKey("code"))
                    {
                        // ログイン途中まで成功(サインイン完了ではない)
                        nwar.strContent = "1";

                        // [OK:200]で code が取れるのは2要素認証モードへの遷移
                        AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("2要素認証におけるID/PWログインの成功,{0}", struri));
                        GetInstance().SendMessageToGUI("接続中", DateTime.Now, "2要素認証におけるID/PWログインの成功");
                    }
                    else
                    {
                        // ログイン成功(サインイン完了)
                        nwar.strContent = "1";
                        nwar.isLogin = true;
                        Login = true;

                        if (tbl.ContainsKey("userId"))
                        {
                            UserNo = tbl["userId"];
                            NKKLogging.GetInstance().AccountId = tbl["userId"];
                        }
                        if (tbl.ContainsKey("facilityCd"))
                        {
                            FacilityCd = tbl["facilityCd"];
                            NKKLogging.GetInstance().FacilityCd = tbl["facilityCd"];
                        }

                        AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("ログイン成功,{0}", struri));
                        GetInstance().SendMessageToGUI("接続中", DateTime.Now, "ログイン成功");
                    }
                }
                else if (HttpStatusCode.Forbidden == nwar.response.StatusCode)
                {
                    // 403系
                    // ログイン失敗
                    nwar.isLogin = false;
                    Login = false;

                    // 応答取得 と JSON分解
                    string strdata = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;
                    Dictionary<String, String> tbl = GetJsonData(strdata);

                    AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, string.Format("ログイン失敗,{0},{1}", struri, strdata));
                    if (tbl.ContainsKey("message"))
                    {
                        nwar.response.ReasonPhrase = tbl["message"];
                    }
                    GetInstance().SendMessageToGUI("未接続", DateTime.Now, "ログイン失敗:" + nwar.response.ReasonPhrase);

                    if (nwar.response.ReasonPhrase.CompareTo("認証に失敗しました。認証情報を確認して下さい。") == 0
                        || nwar.response.ReasonPhrase.CompareTo("Bad credentials") == 0
                        || nwar.response.ReasonPhrase.CompareTo("ワンタイムパスワードが正しくありません") == 0)
                    {
                        // 認証失敗
                        nwar.strContent = "0";
                    }
                    else
                    {
                        // 認証失敗ではない時、接続失敗と判断します。
                        nwar.strContent = "-1";
                    }
                }
                else 
                {
                    // 403以外
                    // EC2が起動していない場合
                    nwar.strContent = "-1";
                    nwar.isLogin = false;
                    Login = false;


                    // 応答取得 と JSON分解
                    string strdata = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;
                    Dictionary<String, String> tbl = GetJsonData(strdata);

                    AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, string.Format("ログイン失敗,{0},{1}", struri, strdata));
                    if (tbl.ContainsKey("message"))
                    {
                        nwar.response.ReasonPhrase = tbl["message"];
                    }
                    else
                    {
                        nwar.response.ReasonPhrase = "サーバに接続できませんでした。";
                    }
                    GetInstance().SendMessageToGUI("未接続", DateTime.Now, "ログイン失敗:" + nwar.response.ReasonPhrase);
                }
            }
            catch (Exception ex)
            {
                // エラー(サーバー未到達含む)
                nwar.strContent = "-1";
                nwar.isLogin = false;
                Login = false;

                nwar.response.StatusCode = (HttpStatusCode)999; // 勝手な定義
                nwar.response.ReasonPhrase = "サーバに接続できませんでした。";

                AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("ログイン失敗,{0},{1}", struri, ex.ToString().Replace("\r\n", "{CRLF}")));
                GetInstance().SendMessageToGUI("未接続", DateTime.Now, "ログイン失敗");
            }
            finally
            {
                smpClient.Release();
            }

            return nwar;
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GET処理
        /// </summary>
        /// <param name="strFuncName">処理名称</param>
        /// <param name="strUri">Uri</param>
        /// <returns>NKKWebAccessレスポンスオブジェクト</returns>
        //----------------------------------------------------------------------------------------------------
        public static async Task<NKKWebAccessResponse> Get(String strFuncName, String strUri)
        {
            return await Get(strFuncName, strUri, "");
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GET処理
        /// </summary>
        /// <param name="strFuncName">処理名称</param>
        /// <param name="strUri">Uri</param>
        /// <param name="strServerLoginArg">ServerLoginメソッドに渡る引数</param>
        /// <returns>NKKWebAccessレスポンスオブジェクト</returns>
        //----------------------------------------------------------------------------------------------------
        public static async Task<NKKWebAccessResponse> Get(String strFuncName, String strUri, String strServerLoginArg)
        {
            NKKWebAccessResponse nwar = new NKKWebAccessResponse();
            bool isLastRest401or403 = false;

            // #10833 2024.08.08 del 不要な処理削除 TDC米沢 start
            //// add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
            //bool doCFalg = true;
            //// 特定印刷ステータス非印刷処理の場合
            //if (strFuncName.Contains("+&&#false"))
            //{
            //    String[] strlines = strFuncName.Split(new char[] { '+' }, StringSplitOptions.None);
            //    strFuncName = strlines[0];
            //    doCFalg = false;
            //}
            //// add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
            // #10833 2024.08.08 del 不要な処理削除 TDC米沢 end

            // リトライ処理
            for (int intlop = 0; intlop < SERVER_MAX_RETRY_COUNT; intlop++)
            {
                // 「2回目以降 かつ 直前のRESTが401/403でない」はリトライにウェイトをいれる
                if (1 <= intlop && false == isLastRest401or403)
                {
                    System.Threading.Thread.Sleep(10 * 1000);
                }

                // 未サインイン状態だったら事前入力情報でサインインを試行
                if (false == Login)
                {
                    isLastRest401or403 = false; // REST直前で一旦リセット
                    nwar = await ServerLogin(strServerLoginArg);

                    if (HttpStatusCode.Unauthorized == nwar.response.StatusCode || HttpStatusCode.Forbidden == nwar.response.StatusCode)
                    {
                        isLastRest401or403 = true;
                    }
                }

                if (true == Login)
                {
                    smpClient.WaitOne();
                    try
                    {
                        isLastRest401or403 = false; // REST直前で一旦リセット
                        nwar.response = Task.Run(() => HttpClient.GetAsync(strUri)).Result;

                        if (nwar.response.IsSuccessStatusCode)
                        {
                            nwar.strContent = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;
                            nwar.isLogin = true;
                            Login = true;

                            GetInstance().SendMessageToGUI("接続中", DateTime.Now, String.Format("{0}処理成功", strFuncName));

                            break;
                        }
                        else
                        {
                            nwar.strContent = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;
                            nwar.isLogin = false;
                            Login = false;

                            if (HttpStatusCode.Unauthorized == nwar.response.StatusCode || HttpStatusCode.Forbidden == nwar.response.StatusCode)
                            {
                                isLastRest401or403 = true;
                            }

                            AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("{0}処理失敗,{1},{2}", strFuncName, strUri, nwar.response.StatusCode));
                            GetInstance().SendMessageToGUI("未接続", DateTime.Now, String.Format("{0}処理失敗:{1}", strFuncName, nwar.response.StatusCode));
                        }
                    }
                    catch (Exception ex)
                    {
                        nwar.strContent = "";
                        nwar.isLogin = false;
                        Login = false;

                        nwar.response.StatusCode = (HttpStatusCode)999; // 勝手な定義
                        nwar.response.ReasonPhrase = "サーバ接続不可などの例外発生";

                        AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("{0}処理失敗,{1},{2}", strFuncName, strUri, ex.ToString().Replace("\r\n", "{CRLF}")));
                        GetInstance().SendMessageToGUI("未接続", DateTime.Now, String.Format("{0}処理失敗:{1}", strFuncName, ex.Message));
                    }
                    finally
                    {
                        smpClient.Release();
                    }
                }
            }
            // #10833 2024.08.08 del 不要な処理削除 TDC米沢 start
            //// mod #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
            ////// 20210908 #6437 成功追加log  鄭  start
            ////AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strFuncName + "処理成功");
            ////// 20210908 #6437 成功追加log  鄭  end
            //if (doCFalg)
            //{
            //    // 20210908 #6437 成功追加log  鄭  start
            //    AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strFuncName + "処理成功");
            //    // 20210908 #6437 成功追加log  鄭  end
            //}
            //// mod #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
            // #10833 2024.08.08 del 不要な処理削除 TDC米沢 end
            return nwar;
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// PUT処理
        /// </summary>
        /// <param name="strFuncName">処理名称</param>
        /// <param name="strUri">Uri</param>
        /// <param name="strdata">送信データ(json)</param>
        /// <returns>NKKWebAccessレスポンスオブジェクト</returns>
        //----------------------------------------------------------------------------------------------------
        public static async Task<NKKWebAccessResponse> Put(String strFuncName, String strUri, String strdata)
        {
            return await Put(strFuncName, strUri, strdata, "");
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// PUT処理
        /// </summary>
        /// <param name="strFuncName">処理名称</param>
        /// <param name="strUri">Uri</param>
        /// <param name="strdata">送信データ(json)</param>
        /// <param name="strServerLoginArg">ServerLoginメソッドに渡る引数</param>
        /// <returns>NKKWebAccessレスポンスオブジェクト</returns>
        //----------------------------------------------------------------------------------------------------
        public static async Task<NKKWebAccessResponse> Put(String strFuncName, String strUri, String strdata, String strServerLoginArg)
        {
            NKKWebAccessResponse nwar = new NKKWebAccessResponse();
            bool isLastRest401or403 = false;

            // リトライ処理
            for (int intlop = 0; intlop < SERVER_MAX_RETRY_COUNT; intlop++)
            {
                // 「2回目以降 かつ 直前のRESTが401/403でない」はリトライにウェイトをいれる
                if (1 <= intlop && false == isLastRest401or403)
                {
                    System.Threading.Thread.Sleep(10 * 1000);
                }

                // 未サインイン状態だったら事前入力情報でサインインを試行
                if (false == Login)
                {
                    isLastRest401or403 = false; // REST直前で一旦リセット
                    nwar = await ServerLogin(strServerLoginArg);

                    if (HttpStatusCode.Unauthorized == nwar.response.StatusCode || HttpStatusCode.Forbidden == nwar.response.StatusCode)
                    {
                        isLastRest401or403 = true;
                    }
                }

                if (true == Login)
                {
                    smpClient.WaitOne();
                    try
                    {
                        HttpContent content = new StringContent(strdata, NKKWebAccess.Encoding, "application/json");

                        // CSRF用トークンをヘッダに追加
                        content.Headers.Add("X-XSRF-TOKEN", NKKWebAccess.GetCSRFToken(strUri));

                        isLastRest401or403 = false; // REST直前で一旦リセット
                        nwar.response = Task.Run(() => HttpClient.PutAsync(strUri, content)).Result;

                        if (nwar.response.IsSuccessStatusCode)
                        {
                            nwar.strContent = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;
                            nwar.isLogin = true;
                            Login = true;

                            GetInstance().SendMessageToGUI("接続中", DateTime.Now, String.Format("{0}処理成功", strFuncName));

                            break;
                        }
                        else
                        {
                            nwar.strContent = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;
                            nwar.isLogin = false;
                            Login = false;

                            if (HttpStatusCode.Unauthorized == nwar.response.StatusCode || HttpStatusCode.Forbidden == nwar.response.StatusCode)
                            {
                                isLastRest401or403 = true;
                            }

                            AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("{0}処理失敗,{1},{2}", strFuncName, strUri, nwar.response.StatusCode));
                            GetInstance().SendMessageToGUI("未接続", DateTime.Now, String.Format("{0}処理失敗:{1}", strFuncName, nwar.response.StatusCode));
                        }
                    }
                    catch (Exception ex)
                    {
                        nwar.strContent = "";
                        nwar.isLogin = false;
                        Login = false;

                        nwar.response.StatusCode = (HttpStatusCode)999; // 勝手な定義
                        nwar.response.ReasonPhrase = "サーバ接続不可などの例外発生";

                        AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("{0}処理失敗,{1},{2}", strFuncName, strUri, ex.ToString().Replace("\r\n", "{CRLF}")));
                        GetInstance().SendMessageToGUI("未接続", DateTime.Now, String.Format("{0}処理失敗:{1}", strFuncName, ex.Message));
                    }
                    finally
                    {
                        smpClient.Release();
                    }
                }
            }

            return nwar;
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// POST処理
        /// </summary>
        /// <param name="strFuncName">処理名称</param>
        /// <param name="strUri">Uri</param>
        /// <param name="strdata">送信データ(json)</param>
        /// <returns>NKKWebAccessレスポンスオブジェクト</returns>
        //----------------------------------------------------------------------------------------------------
        public static async Task<NKKWebAccessResponse> Post(String strFuncName, String strUri, String strdata)
        {
            return await Post(strFuncName, strUri, strdata, "");
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// POST処理
        /// </summary>
        /// <param name="strFuncName">処理名称</param>
        /// <param name="strUri">Uri</param>
        /// <param name="strdata">送信データ(json)</param>
        /// <param name="strServerLoginArg">ServerLoginメソッドに渡る引数</param>
        /// <returns>NKKWebAccessレスポンスオブジェクト</returns>
        //----------------------------------------------------------------------------------------------------
        public static async Task<NKKWebAccessResponse> Post(String strFuncName, String strUri, String strdata, String strServerLoginArg)
        {
            NKKWebAccessResponse nwar = new NKKWebAccessResponse();
            bool isLastRest401or403 = false;

            // リトライ処理
            for (int intlop = 0; intlop < SERVER_MAX_RETRY_COUNT; intlop++)
            {
                // 「2回目以降 かつ 直前のRESTが401/403でない」はリトライにウェイトをいれる
                if (1 <= intlop && false == isLastRest401or403)
                {
                    System.Threading.Thread.Sleep(10 * 1000);
                }

                // 未サインイン状態だったら事前入力情報でサインインを試行
                if (false == Login)
                {
                    isLastRest401or403 = false; // REST直前で一旦リセット
                    nwar = await ServerLogin(strServerLoginArg);

                    if (HttpStatusCode.Unauthorized == nwar.response.StatusCode || HttpStatusCode.Forbidden == nwar.response.StatusCode)
                    {
                        isLastRest401or403 = true;
                    }
                }

                if (true == Login)
                {
                    smpClient.WaitOne();
                    try
                    {
                        HttpContent content = new StringContent(strdata, NKKWebAccess.Encoding, "application/json");

                        // CSRF用トークンをヘッダに追加
                        content.Headers.Add("X-XSRF-TOKEN", NKKWebAccess.GetCSRFToken(strUri));

                        isLastRest401or403 = false; // REST直前で一旦リセット
                        nwar.response = Task.Run(() => HttpClient.PostAsync(strUri, content)).Result;

                        if (nwar.response.IsSuccessStatusCode)
                        {
                            nwar.strContent = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;
                            nwar.isLogin = true;
                            Login = true;

                            GetInstance().SendMessageToGUI("接続中", DateTime.Now, String.Format("{0}処理成功", strFuncName));

                            break;
                        }
                        else
                        {
                            nwar.strContent = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;
                            nwar.isLogin = false;
                            Login = false;

                            if (HttpStatusCode.Unauthorized == nwar.response.StatusCode || HttpStatusCode.Forbidden == nwar.response.StatusCode)
                            {
                                isLastRest401or403 = true;
                            }

                            AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("{0}処理失敗,{1},{2}", strFuncName, strUri, nwar.response.StatusCode));
                            GetInstance().SendMessageToGUI("未接続", DateTime.Now, String.Format("{0}処理失敗:{1}", strFuncName, nwar.response.StatusCode));
                        }
                    }
                    catch (Exception ex)
                    {
                        nwar.strContent = "";
                        nwar.isLogin = false;
                        Login = false;

                        nwar.response.StatusCode = (HttpStatusCode)999; // 勝手な定義
                        nwar.response.ReasonPhrase = "サーバ接続不可などの例外発生";

                        AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("{0}処理失敗,{1},{2}", strFuncName, strUri, ex.ToString().Replace("\r\n", "{CRLF}")));
                        GetInstance().SendMessageToGUI("未接続", DateTime.Now, String.Format("{0}処理失敗:{1}", strFuncName, ex.Message));
                    }
                    finally
                    {
                        smpClient.Release();
                    }
                }
            }

            return nwar;
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GET処理(※サインインなし)
        /// </summary>
        /// <param name="strFuncName">処理名称</param>
        /// <param name="strUri">Uri</param>
        /// <returns>NKKWebAccessレスポンスオブジェクト</returns>
        //----------------------------------------------------------------------------------------------------
        public static async Task<NKKWebAccessResponse> GetNoSignIn(String strFuncName, String strUri)
        {
            NKKWebAccessResponse nwar = new NKKWebAccessResponse();
            bool isLastRest401or403 = false;

            HttpClient httpCli = new HttpClient(new WebRequestHandler());
            nwar.isLogin = false; // サインイン無しで実行するので[false]としておく

            // リトライ処理
            for (int intlop = 0; intlop < SERVER_MAX_RETRY_COUNT; intlop++)
            {
                // 「2回目以降 かつ 直前のRESTが401/403でない」はリトライにウェイトをいれる
                if (1 <= intlop && false == isLastRest401or403)
                {
                    System.Threading.Thread.Sleep(10 * 1000);
                }

                try
                {
                    isLastRest401or403 = false; // REST直前で一旦リセット
                    nwar.response = Task.Run(() => httpCli.GetAsync(strUri)).Result;

                    if (nwar.response.IsSuccessStatusCode)
                    {
                        nwar.strContent = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;

                        GetInstance().SendMessageToGUI("接続中", DateTime.Now, String.Format("{0}処理成功", strFuncName));

                        break;
                    }
                    else
                    {
                        nwar.strContent = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;

                        if (HttpStatusCode.Unauthorized == nwar.response.StatusCode || HttpStatusCode.Forbidden == nwar.response.StatusCode)
                        {
                            isLastRest401or403 = true;
                        }

                        AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("{0}処理失敗,{1},{2}", strFuncName, strUri, nwar.response.StatusCode));
                        GetInstance().SendMessageToGUI("未接続", DateTime.Now, String.Format("{0}処理失敗:{1}", strFuncName, nwar.response.StatusCode));
                    }
                }
                catch (Exception ex)
                {
                    nwar.strContent = "";

                    nwar.response.StatusCode = (HttpStatusCode)999; // 勝手な定義
                    nwar.response.ReasonPhrase = "サーバ接続不可などの例外発生";

                    AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("{0}処理失敗,{1},{2}", strFuncName, strUri, ex.ToString().Replace("\r\n", "{CRLF}")));
                    GetInstance().SendMessageToGUI("未接続", DateTime.Now, String.Format("{0}処理失敗:{1}", strFuncName, ex.Message));
                }
            }

            return nwar;
        }
        //----------------------------------------------------------------------------------------------------
    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------