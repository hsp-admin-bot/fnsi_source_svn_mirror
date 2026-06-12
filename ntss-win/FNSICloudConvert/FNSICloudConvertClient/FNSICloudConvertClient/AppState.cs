using System.Collections.Generic;
using FNSICloudConvertClient.Logic;
using FNSICloudConvertClient.Models;

namespace FNSICloudConvertClient
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// アプリケーション全体の状態を保持するシングルトン
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public sealed class AppState
    {
        private static AppState _instance;
        private static readonly object _lock = new object();

        private AppState() { }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// シングルトンインスタンスを取得する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static AppState Instance
        {
            get
            {
                if (_instance == null)
                {
                    lock (_lock)
                    {
                        if (_instance == null)
                            _instance = new AppState();
                    }
                }
                return _instance;
            }
        }

        /// <summary>ログイン中のユーザーID</summary>
        public string UserId { get; set; } = string.Empty;

        /// <summary>ログイン中のユーザー名</summary>
        public string UserName { get; set; } = string.Empty;

        /// <summary>操作モード（データ導出 / データ導入）</summary>
        public OperationMode CurrentMode { get; set; } = OperationMode.None;

        /// <summary>選択済み施設リスト</summary>
        public List<FacilityInfo> SelectedFacilities { get; set; } = new List<FacilityInfo>();

        /// <summary>接続設定</summary>
        public AppSettings Settings { get; set; } = new AppSettings();

        /// <summary>コンバーターサーバーへの認証成功フラグ</summary>
        public bool IsConverterAuthenticated { get; set; } = false;

        /// <summary>コンバーターサーバーから取得した JWT アクセストークン</summary>
        public string ConverterJwtToken { get; set; } = string.Empty;

        /// <summary>コンバーターサーバーから取得した JWT リフレッシュトークン</summary>
        public string ConverterRefreshToken { get; set; } = string.Empty;

        /// <summary>コンバーターサーバー再認証用の施設コード</summary>
        public string ConverterFacilityCd { get; set; } = string.Empty;

        /// <summary>コンバーターサーバー再認証用の表示ユーザーID</summary>
        public string ConverterDispUserId { get; set; } = string.Empty;

        /// <summary>コンバーターサーバー再認証用のパスワード</summary>
        public string ConverterPassword { get; set; } = string.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アプリ状態をリセットする（ログアウト時に使用）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public void Reset()
        {
            UserId                   = string.Empty;
            UserName                 = string.Empty;
            CurrentMode              = OperationMode.None;
            SelectedFacilities       = new List<FacilityInfo>();
            Settings                 = new AppSettings();
            IsConverterAuthenticated = false;
            ConverterJwtToken        = string.Empty;
            ConverterRefreshToken    = string.Empty;
            ConverterFacilityCd      = string.Empty;
            ConverterDispUserId      = string.Empty;
            ConverterPassword        = string.Empty;

            // ログアウト後も接続設定を保持する
            var saved = Logic.UserSettingsStore.Load();
            if (saved != null)
                saved.ApplyTo(Settings);
        }
    }
}
