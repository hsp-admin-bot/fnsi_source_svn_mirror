package jp.co.nikkiso.ntss.device_edge_updater.constant;

/**
 * 定数クラス
 * @author y.kataguchi
 *
 */
public class Constant {

  /**
   * REST URI定義
   *
   */
  public static class Uri {
    public static final  String DEVICE_EDGE_UPDATER_RESPONSE = "/api/update";
    /* バージョン情報更新 */
    public static final String VERSION = "/api/device_edge_version";
    /* 予定情報更新 */
    public static final String PLAN = "/api/plan";
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
   * WebSocket通知識別用トピック情報
   *
   */
  public static class WebSocketTopic {

    /**
     * 通知メッセージ
     */
    public static final String NOTIFICATION_MESSAGE = "NOTIFICATION/MESSAGE";
  }

}
