package jp.co.nikkiso.ntss.web_api.constant;

public class WebApiConstant {
  /**
   * WebSocket通知識別用トピック情報
   *
   */
  public static class WebSocketTopic{
    public static class CardAccess {
      public static final String CARD_WRITE_STAFF = "CARD/WRITE_STAFF";
      public static final String CARD_WRITE_PAT = "CARD/WRITE_PAT";
    }
    /**
     * 体重計装置を操作する指示用
     *
     */
    public static class WeightState {
      /**
       * 患者カード読み取り
       */
      public static final String CARD_READ = "WEIGHT/CARD_READ";
      /**
       * 体重計入力取得
       */
      public static final String SCALE = "WEIGHT/SCALE_VALUE";
      /**
       * カード書き込み指示
       */
      public static final String CARD_WRITE = "WEIGHT/CARD_WRITE";
      /**
       * カード書き込み結果参照指示
       */
      public static final String CARD_WRITE_RESULT = "WEIGHT/CARD_WRITE_RESULT";
      /**
       * 体重計接続状態更新
       */
      public static final String WEIGHT_CONNECT = "WEIGHT/CONNECT";
      /**
       * 体重計レシート印刷
       */
      public static final String PRINT = "WEIGHT/PRINT";
    }
    /**
     * 通信サーバー用
     */
    public static class ComSv {
      /**
       * 条件送信指示
       */
      public static final String SEND_CONDITION = "COMSV/1";
      /**
       * 装置オプション読出し指示
       */
      public static final String READ_OPTION = "COMSV/2";
      /**
       * 設定値読出し指示
       */
      public static final String READ_SETTING_VALUE = "COMSV/3";
      /**
       * 次患者情報転送指示
       */
      public static final String SEND_NEXT_PAT = "COMSV/4";
      /**
       * 通信サーバー設定更新指示
       */
      public static final String RELOAD_COMSV_SETTING  = "COMSV/5";
      /**
       * 愁訴処置マスタ更新指示
       */
      public static final String RELOAD_TREAT_MASTER  = "COMSV/6";
      /**
       * スタッフマスタ更新指示
       */
      public static final String RELOAD_STAFF_MASTER  = "COMSV/7";
      /**
       * 未登録患者割付指示
       */
      public static final String SET_UNKNOWN_PAT  = "COMSV/8";
      /**
       * 条件送信キャンセル指示
       */
      public static final String CANCEL_CONDITION  = "COMSV/9";
      /**
       * 投薬指示変更指示
       */
      public static final String CHANGE_IND_MEDI  = "COMSV/10";
      /**
       * 後体重測定指示
       */
      public static final String AFTER_WEIGHT  = "COMSV/11";
      /**
       * 治療状況確認指示
       */
      public static final String CHECK_STATUS  = "COMSV/12";
      /**
       * チェックリストマスタ更新指示
       */
      public static final String RELOAD_CHECKLIST_MASTER  = "COMSV/13";
      /**
       * 仮想端末キャッシュ更新指示
       */
      public static final String CHACE_CLEAR  = "COMSV/14";
      /**
       * 検査項目マスタ更新指示
       */
      public static final String RELOAD_EXAM_MASTER  = "COMSV/15";
      /**
       * オフライン運転開始指示
       */
      public static final String START_TREAT_OFFLINE  = "COMSV/16";
      /**
       * オフライン運転終了指示
       */
      public static final String END_TREAT_OFFLINE  = "COMSV/17";
    }
    /**
     * デバイスエッジ指示用
     *
     */
    public static class DeviceEdgeManage {
      /**
       *  ソフト更新指示用トピック
       */
      public static final String UPDATE = "NTSS/UPDATE";
      /**
       * レストア用トピック
       */
      public static final String RESTORE = "NTSS/RESTORE";
      /**
       * ログ収集命令トピック
       */
      public static final String LOG_GATHER = "NTSS/LOG_GATHER";
      /**
       * NTSSサービス再起動トピック
       */
      public static final String APP_REBOOT = "NTSS/NTSS_REBOOT";
      /**
       * NTSSサービス停止トピック
       */
      public static final String APP_STOP = "NTSS/NTSS_STOP";
      /**
       * NTSSサービス開始トピック
       */
      public static final String APP_START = "NTSS/NTSS_START";
      /**
       * デバイス再起動トピック
       */
      public static final String DEVICE_REBOOT = "NTSS/DE_REBOOT";
      /**
       * 設定収集トピック
       */
      public static final String CONF_GATHER = "NTSS/CONF_GATHER";
      /**
       * 設定適用トピック
       */
      public static final String CONF_UPDATE = "NTSS/CONF_UPDATE";
      /**
       * 管理番号
       */
      public static class OrderClass {
        /**
         *  ソフト更新指示用トピック
         */
        public static final short UPDATE = 0;
        /**
         * レストア用トピック
         */
        public static final short RESTORE = 1;
        /**
         * ログ収集命令トピック
         */
        public static final short LOG_GATHER = 2;
        /**
         * NTSSサービス再起動トピック
         */
        public static final short APP_REBOOT = 3;
        /**
         * NTSSサービス停止トピック
         */
        public static final short APP_STOP = 4;
        /**
         * NTSSサービス開始トピック
         */
        public static final short APP_START = 5;
        /**
         * デバイス再起動トピック
         */
        public static final short DEVICE_REBOOT = 6;
        /**
         * 設定収集トピック
         */
        public static final short CONF_GATHER = 7;
        /**
         * 設定適用トピック
         */
        public static final short CONF_UPDATE = 8;
      }
    }

    /**
     * 通知メッセージ
     */
    public static final String NOTIFICATION_MESSAGE = "NOTIFICATION/MESSAGE";
  }

  /**
   * WebSocket通知用定数
   */
  public static class NotifyTarget {
    /* upd by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    /**
     * デバイスエッジメインアプリケーション対象通知トピック用文字列
     */
    public static final String DEVICE_EDGE_MAIN_LABEL = "EDGE";

    /**
     * デバイスエッジアップデータアプリケーション対象通知トピック用文字列
     */
    public static final String DEVICE_EDGE_UPDATER_LABEL = "UPDEDGE";

    /**
     * ブラウザ対象通知トピック用文字列
     */
    public static final String WEB_BROWSER_LABEL = "BROWSER";

    /**
     * 体重計接続サービスアプリ対象通知トピック用文字列
     */
    public static final String WEB_WEIGHT_APP_LABEL = "WSCALE";

    /**
     * デバイスアクセスカード用文字列
     */
    public static final String DEVICE_ACCESS_CARD_LABEL = "ACSCARD";

    /**
     * デバイスエッジ対象接続サーバータイプ
     */
    public static final Integer DEVICE_EDGE_SERVER_TYPE = 0;

    /**
     * ブラウザ対象接続サーバータイプ
     */
    public static final Integer WEB_BROWSER_SERVER_TYPE = 1;
    /* upd by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
  }

  /**
   * WebPush用オプション（タイトル等）
   */
  public static class WebPushOptions {

    /**
     * 通知タイトル(ReMSのみ)
     */
    public static final String TITLE_1 = "日機装 ReMS";

    /**
     * 通知タイトル(次世代FNのみ)
     */
    public static final String TITLE_2 = "日機装 FutureNetWeb⁺Si";

    /**
     * 通知タイトル(ReMS+次世代FNのみ)
     */
    public static final String TITLE_3 = "日機装 FutureNetWeb⁺Si×ReMS";

    /**
     * 通知タイトル(ReMSのみ)
     */
    public static final String ICON_1 = "/ntss-admin-web/img/notification/icon_01.png";

    /**
     * 通知タイトル(次世代FNのみ)
     */
    public static final String ICON_2 = "/ntss-admin-web/img/notification/icon_02.png";

    /**
     * 通知タイトル(ReMS+次世代FNのみ)
     */
    public static final String ICON_3 = "/ntss-admin-web/img/notification/icon_03.png";
    
  }
}
