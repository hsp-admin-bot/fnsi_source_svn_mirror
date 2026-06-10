package web.constant;

/**
 * NTSS共通定数クラス.
 */
public class CoreConstant {

  /**
   * システム設定クラス.
   */
  public static class SysSystemDefine {
    /**
     * オンプレミス
     */
    public static final Integer CTL_NO_ON_PREMISE = 14;
    /**
     * アプリケーション
     */
    public static final Integer APPLICATION_LOGGING = 27;
    /**
     * コンバータ
     */
    public static final Integer CONVERT_LOGGING = 28;
    /**
     * イベントログ
     */
    public static final Integer EVENT_LOGGING = 28;
    /**
     * 帳票レイアウトデザイナーアプリケーションログ出力先
     */
    public static final Integer LAYOUTDESIGNER_LOG_OUTPUT_PATH = 1001;
    /**
     * 体重計アプリケーションログ出力先
     */
    public static final Integer NKKWEIGHT_LOG_OUTPUT_PATH = 1002;
    /**
     * 印刷サーバーアプリケーションログ出力先
     */
    public static final Integer NKKPRINT_LOG_OUTPUT_PATH = 1003;
    /**
     * 浄化装置通信アプリケーションログ出力先
     */
    public static final Integer BLOODPURIFY_LOG_OUTPUT_PATH = 1004;
    /**
     * 不明アプリケーションログ出力先
     */
    public static final Integer UNKNOWNAPP_LOG_OUTPUT_PATH = 1005;
    /**
     * デバイスエッジログ出力先
     */
    public static final Integer DEVICEEDGE_LOG_OUTPUT_PATH = 1006;
    // add 2021-05-31 連携エッジのログをAWSにupする 孫 start
    /**
     * IFエンジログ出力先
     */
    public static final Integer IFEDGE_LOG_OUTPUT_PATH = 1007;
    // add 2021-05-31 連携エッジのログをAWSにupする 孫 end
    /**
     * coop-api配信ファイル保持フォルダ
     */
    public static final Integer COOPAPI_DIST_FOLDER_PATH = 1008;

    //FNSI-修正 vpn url対応 xiebzh add start
    /**
     * vpnキー
     */
    public static final Integer VPN_KEY = 1009;
    //FNSI-修正 vpn url対応 xiebzh add end
    // add 5967 カードアプリのログアップロード名とアップロード先が正しくないため、ログの一部が消えてしまう  吉 start
    public static final Integer NKKACCESSCARD_LOG_OUTPUT_PATH = 1010;
    // add 5967 カードアプリのログアップロード名とアップロード先が正しくないため、ログの一部が消えてしまう  吉 end

    /**
     * ロガー設定更新対象モジュールリスト
     */
    public static final Integer LOGGER_UPDATE_TARGET_LIST = 1011;

    // add 2023-11-21  limingyang start
    /**
     * コンバートエンジログ出力先
     */
    public static final Integer CONVERT_LOG_OUTPUT_PATH = 1012;
    // add 2023-11-21  limingyang end
  }


  /**
   * MONGODB
   */
  public static class MongoDbConfig {
    /**
     * mongodb接続タイムアウト
     */
    public static final Integer CONNECT_TIME_OUT = 3000;
  }

}
