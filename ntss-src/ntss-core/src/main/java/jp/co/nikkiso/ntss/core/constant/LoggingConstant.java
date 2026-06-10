package jp.co.nikkiso.ntss.core.constant;

/**
 *
 */
public class LoggingConstant {

  /**
   * .
   */
  public static class FUNCTION_CODE {

    /**
     * 稼働ビューア
     */
    public static final String FUNC_OPERATION_VIEWER = "001";
    /**
     * 生体モニタ
     */
    public static final String FUNC_MONITORING = "002";
    /**
     * デバイスエッジ稼働監視
     */
    public static final String FUNC_DEVICE_EDGE_OPERATION = "003";
    /**
     * 患者統合経過ビューア
     */
    public static final String FUNC_PAT_VIEWER = "004";
    /**
     * マスタメンテナンス
     */
    public static final String FUNC_MASTER_MAINTENANCE = "005";
    /**
     * 治療記録
     */
    public static final String FUNC_TREATMENT_RECORD = "006";
    /**
     * 患者情報
     */
    public static final String FUNC_PAT_INFO = "007";
    /**
     * マルチ患者一覧
     */
    public static final String FUNC_MULTI_PAT_LIST = "008";
    /**
     * スケジュール表
     */
    public static final String FUNC_SCHEDULE_LIST = "009";
    /**
     * 装置設定(患者情報)
     */
    public static final String FUNC_PAT_DEVICE_SET = "010";
    /**
     * 治療状況リスト
     */
    public static final String FUNC_STATUS_LIST_MAIN = "011";
    /**
     * 治療状況マップ
     */
    public static final String FUNC_STATUS_MAP = "012";
    /**
     * 体重計・条件送信
     */
    public static final String FUNC_SEND_CONDITION = "013";
    /**
     * 体重計測定記録
     */
    public static final String FUNC_MEASURE_HISTORY = "014";
    /**
     * チェックリスト
     */
    public static final String FUNC_CHECK_LIST = "015";
    /**
     * 観察記録
     */
    public static final String FUNC_OBSERVE_RECORD = "016";
    /**
     * 患者新規登録
     */
    public static final String FUNC_PAT_INFO_CREATE = "017";
    /**
     * 検査結果
     */
    public static final String FUNC_EXAM_RECORD = "018";
    /**
     * 帳票
     */
    public static final String FUNC_REPORT_MENU = "019";
    /**
     * 掲示板一覧情報
     */
    public static final String FUNC_BBS_INFO = "020";
    /**
     * 検査依頼
     */
    public static final String FUNC_EXAM_REQUEST = "021";
    /**
     * 放射線検査依頼
     */
    public static final String FUNC_RAD_REQUEST = "022";
    /**
     * 患者グループ
     */
    public static final String FUNC_PAT_GROUP = "023";
    /**
     * 患者カレンダ
     */
    public static final String FUNC_PAT_CALENDAR = "024";
    /**
     * 在宅透析施設用
     */
    public static final String FUNC_FACILITY_HOME_DIALYSIS = "025";
    /**
     * 在宅透析患者用
     */
    public static final String FUNC_PAT_HOME_DIALYSIS = "026";
    /**
     * 患者イベント
     */
    public static final String FUNC_PAT_EVENT = "027";

    /**
     * 指示受け・指示承認
     */
    public static final String FUNC_INDICATION = "028";
    /**
     * 患者イベント - Clone
     */
    public static final String FUNC_PAT_INTRO_LETTER = "030";

    /**
     * 外部連携稼働ビューア
     */
    public static final String FUNC_EXTERNAL_COOP = "031";

    /**
    * 水質調査
    */
    public static final String FUNC_WATER_QUALITY_SURVEY = "032";

    /**
     * 定期点検
     */
    public static final String FUNC_PERIODIC_INSPECTION = "033";

    /**
     * 日常点検
     */
    public static final String FUNC_DAILY_CHECK = "034";

    /**
     * 患者情報共有
     */
    public static final String FUNC_SHARING_PATIENT_INFORMATION = "036";

    /**
     * 施設一覧
     */
    public static final String FUNC_DETAIL_FACILITIES_LIST = FUNC_OPERATION_VIEWER + "01";
    /**
     * 装置一覧
     */
    public static final String FUNC_DETAIL_MACHINES_LIST = FUNC_OPERATION_VIEWER + "02";
    /**
     * 装置記録
     */
    public static final String FUNC_DETAIL_MOTION_RECORD_LIST = FUNC_OPERATION_VIEWER + "03";
    /**
     * 装置記録詳細
     */
    public static final String FUNC_DETAIL_MOTION_RECORD_DETAIL = FUNC_OPERATION_VIEWER + "04";
    /**
     * ログ参照画面
     */
    public static final String FUNC_VIEW_LOG = "035";
    /**
     * P-Ca9分割グラフ
     */
    public static final String FUNC_SPLIT_GRAPH = "039";
  }

  /**
   *
   */
  public static class SERVICE_NAME {
    /**
    *
    */
    public static final String REMS = "ReMS";
    /**
      *
      */
    public static final String FNSI = "FNSi";
    /**
     *
     */
    public static final String FNM = "FNM";
  }

  /**
   *
   */
  public static class MODULE_NAME {
    public static final String ADMIN_WEB = "ntss-admin-web";
    public static final String NTSS_ALIVE_MONI = "ntss-alive-moni";
    public static final String NTSS_ALIVE_MONI_AUTO = "ntss-alive-moni-auto";
    public static final String NTSS_API = "ntss-api";
    public static final String NTSS_CLIENT_COMM = "ntss-client-comm";
    public static final String NTSS_COOP_API = "ntss-coop-api";
    public static final String NTSS_DATA_GATHERING = "ntss-data-gathering";
    public static final String NTSS_DATA_GATHERING_AUTO = "ntss-data-gathering-auto";
    public static final String NTSS_DEVICE_EDGE = "ntss-device-edge";
    public static final String NTSS_DEVICE_DEDGE_UPDATER = "ntss-device-edge-updater";
    public static final String NTSS_DEVICE_EDGE_UPDATER_FRONT = "ntss-device-edge-updater-front";
    public static final String NTSS_M_NOTICE = "ntss-m-notice";
    public static final String NTSS_MONITORING = "ntss-monitoring";
    public static final String NTSS_WEB_API = "ntss-web-api";
    //FNSI-修正 ログ対応 xiebzh add start
    public static final String NTSS_CORE = "ntss-core";
    //FNSI-修正 ログ対応 xiebzh add end
  }

  //FNSI-修正 ログ対応 xiebzh add start
  public static class MONGO_LOG {
    public static final String ACCESS_URI = "/mongo/{logLevel}";
    public static final String ACCESS_URI_PARAM = "logLevel";
    public static final String REQUEST_MAPPING = "/api/logging";

    // wangzuo アプリケーションログの適正化 Add Start
    public static final String LOG_MESSAGE_SPACE = " ";
    public static final String LOG_MESSAGE_SLASH = "/";
    public static final String BEFORE_LOG_FLG_INFO = "BI";
    public static final String AFTER_LOG_FLG_INFO = "AI";
    public static final String AFTER_LOG_FLG_ERROR = "AE";
    public static final String BEFORE_LOG_MESSAGE = "実施開始：";
    public static final String AFTER_LOG_MESSAGE_INFO = "実施終了：";
    public static final String AFTER_LOG_MESSAGE_ERROR = "実施異常終了：";
    // wangzuo アプリケーションログの適正化 Add End
    // xie アプリケーションログの適正化 Add Start
    public static final String BEFORE_MESSAGE = "%s %s 実施開始。パラメータ：%s";
    public static final String AFTER_MESSAGE = "%s %s 実施終了。";
    public static final String EXCEPTION_MESSAGE = "%s %s 実施異常終了。エラー：%s";
    // xie アプリケーションログの適正化 Add End
  }
  //FNSI-修正 ログ対応 xiebzh add end

  //FNSI-修正 マスタ削除の対応 wangchen add start
  public static class MASTER_DELETE{
    public static final String DELETED= "【削除済み】";
    public static final String DELETED_INCLUDE = "【削除済み含む】";
  }
  //FNSI-修正 マスタ削除の対応 wangchen add end

  // ロガーリセットメソッド用
  public static class LOGGER_RESET {
    public static final String REQUEST_MAPPING = "/api/logger-reset";
    public static final String ACCESS_URI = "/flg-on";
  }
}
