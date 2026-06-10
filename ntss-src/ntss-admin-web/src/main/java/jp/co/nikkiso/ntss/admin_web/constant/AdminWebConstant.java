package jp.co.nikkiso.ntss.admin_web.constant;

import lombok.Data;

import java.util.HashMap;
import java.util.Map;

/**
 * ntss-admin-webの定数クラス.
 */
public class AdminWebConstant {

  /**
   * URI定義.
   */
  public static class Uri {

    /**
     * ログイン.
     */
    public static final String LOGIN = "/api/login";

    /**
     * ログアウト.
     */
    public static final String LOGOUT = "/api/logout";

    /**
     * ユーザ系.
     */
    public static final String USER = "/api/user";


    public static final String AUTHENTICATION = "/api/authentication";

    /**
     * 施設系.
     */
    public static final String FACILITIES = "/api/facilities";

    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
    /**
     * サインアウト
     */
    public static final String SIGN_OUT = "/api/user-authority/sign-out";
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
    // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou start
    /**
     * 自身以外サインアウト
     */
    public static final String SIGN_OUT_ANOTHER = "/api/user-authority/sign-out-another";
    // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou end

    /**
     * システム利用設定情報
     */
    public static final String USE_SYS_HASH = "/api/facilities/MstFacilityHash/UseSys/hash";

    /**
     * 2要素認証失敗許容回数情報
     */
    public static final String OTP_FAILURE_CNT_HASH = "/api/facilities/MstFacilityHash/OtpFailureCnt/hash";

    /**
     * URLサインイン設定取得
     */
    public static final String URL_SIGNIN = "/api/facilities/MstFacilityHash/getUrlSignin";
    
    /**
     * サインインIF表示設定取得
     */
    public static final String IS_SIGNIN_DISP = "/api/facilities/MstFacilityHash/getIsSigninDisp";

    /**
     * 他タブ接続状態確認
     */
    public static final String WEBSOCKET_CONNECT_STATUS = "/api/websocketcertification/websocket_connect_status";

    /**
     * 装置系.
     */
    public static final String MACHINES = "/api/machines";

    /**
     * データ収集ファイルダウンロード.
     */
    public static final String GATHERING_DOWNLOAD = "/api/motion_record/detail/gathering/download";

    /**
     * 印刷ファイルダウンロード.
     */
    public static final String PRINT_DATA_DOWNLOAD = "/api/report_designer/forPrintServer/download";
    // add 9601 印刷サーバにて帳票の印刷が行われない　吉 start
    /**
     * サーバーのIPに通じて印刷フィアルを取得する
     */
    public static final String PRINT_DATA_DOWNLOAD_OTHER = "/api/report_designer/forPrintServer/getFileByServeIp";
    // add 9601 印刷サーバにて帳票の印刷が行われない　吉 end

    /**
     * 装置動作記録系.
     */
    public static final String MOTION_RECORD = "/api/motion_record";

    /**
     * デバイスエッジ系.
     */
    public static final String DEVICE_EDGE = "/api/device_edge";

    /**
     * ユーザ設定系.
     */
    public static final String USER_SETTINGS = "/api/user_settings";

    /**
     * マスタメンテナンス系.
     */
    public static final String MASTER_MAINTENANCE = "/api/master_maintenance";

    /**
     * マスタ同期系.
     */
    public static final String MST_SYNCHRO = "/api/mst_synchro";

    /**
     * 観察記録系.
     */
    public static final String PAT_OBS_REC = "/api/pat_obs_rec";

    /**
     * 患者イベント系.
     */
    public static final String PAT_EVENT = "/api/pat_event";

    /**
     * 体重計測定記録系.
     */
    public static final String MESURE_HISTORY = "/api/measure_history";

    /**
     * ブラウザWebSocket接続系.
     */
    public static final String WEBSOCKET_CERT = "/api/websocketcertification";

    /**
     * 患者グループ.
     */
    public static final String PAT_GROUP = "/api/pat_group";

    /**

     /**
     * 体重計系.
     */
    public static final String WEIGHT = "/api/weight";

    /**
     * 体重計状態系.
     */
    public static final String WEIGHT_STATE = "/api/weight_state";
    /**
     * 体重計マスタ編集.
     */
    public static final String WEIGHT_SETTING = "/api/weight_setting";

    // #11987 2026.01.23 add スケールベッド対応 TDC伊東 start
    /**
     * スケールベッド状態系.
     */
    public static final String SCALE_BED_STATE = "/api/scale_bed_state";
    // #11987 2026.01.23 add スケールベッド対応 TDC伊東 end
    // #11987 2026.02.11 add スケールベッド対応 TDC片口 start
    /**
     * スケールベッド参照系.
     */
    public static final String SCALE_BED = "/api/scale_bed";
    // #11987 2026.02.11 add スケールベッド対応 TDC片口 end

    /**
     * デバイスエッジ指示
     */
    public static final String DEVICE_EDGE_ORDER = "/api/device_edge_order";
    /**
     * デバイスエッジ遠隔指示
     */
    public static final String DEVICE_EDGE_MANAGE = "/api/device_edge_manage";
    /**
     * 警報注意履歴
     */
    public static final String ALARM_RECORD = "/api/alarm_record";
    /**
     * 治療状況用指示
     */
    public static final String TREAT_STATUS_LIST = "/api/status_list";
    /**
     * 治療状況大画面用指示
     */
    public static final String TREAT_STATUS_LIST_LARGE = "/api/status_list_large";
    /**
     * 治療状況用指示
     */
    public static final String TREAT_STATUS_MAP = "/api/status_map";
    /**
     * トレンドグラフ
     */
    public static final String TREND_GRAPH = "/api/trend_graph";

    /**
     * 治療状況マップベッドレイアウト
     */
    public static final String BED_LAYOUT = "/api/bed_layout";

    /**
     * 装置設定系
     */
    public static final String DEVICE_SET_INFO = "/api/deviceSetInfo";

    /**
     * 指示履歴系
     */
    public static final String IND_HISTORY = "/api/indHistory";

    /**
     * オーダーメイン系
     */
    public static final String MAIN_DATA = "/api/mainData";
    /**
     * オーダーメイン系(NEW)
     */
    public static final String PATIENTS = "/api/patients";

    /**
     * マスタ系
     */
    public static final String MST_INFO = "/api/mstInfo";

    /**
     * 患者情報系
     */
    public static final String PAT_INFO = "/api/patInfo";

    /**
     * リンケージ定義の作成
     */
    public static final String LINKAGE_DEFINITION = "/api/linkage_definition";
    /**
     * スケジュール表系
     */
    public static final String SCHEDULE_LIST = "/api/scheduleList";

    /**
     * 利用者系
     */
    public static final String PERSONAL_USER = "/api/personal_user";

    /**
     * 装置記録系
     */
    public static final String MACHINE_RECORD = "/api/machine_record";

    /**
     * 送信先グループ系
     */
    public static final String DESTINATION_GROUP = "/api/destination_group";

    /**
     * コンボボックス.
     */
    public static final String COMBO = "/api/combo";

    /**
     * 治療記録系
     */
    public static final String TREATMENT_RECORD = "/api/treatment-record";
	//add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
    /**
     * 治療方法マスタ
     */
    public static final String MST_TREATMENT = "/api/mst_treatment";
    /**
    /**
	//add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s end
     * チェックリストマスタ編集.
     */
    public static final String CHECKLIST_SETTING = "/api/checklist_setting";
    /**
     * チェックリストマスタ.
     */
    public static final String CHECK_LIST = "/api/check-list";
    /**
     * ファイルアップロード中継（デバイスサーバーコール）
     */
    public static final String FILE_UPLOAD = "/api/s3/upload";
    /**
     * スケジュール割り当て
     */
    public static final String SCHEDULE_ASSIGNMENT = "/api/schedule-assignment";

    /**
     * 帳票作成.
     */
    public static final String CREATING_REPORT = "/api/report";

    /**
     * 薬剤
     */
    public static final String MEDICINE = "/api/medicine";

    /**
     * 処方箋
     */
    public static final String PRESCRIPTION = "/api/pat-prescription";

    /**
     * 帳票レイアウトデザイナー
     */
    public static final String REPORT_DESIGNER = "/api/report_designer";

    /**
     * 帳票マスタ.
     */
    public static final String MASTER_REPORT = "/api/master_report";

    /**
     * 機能帳票設定
     */
    public static final String SYS_REPORT_SETTING = "/api/sys_report_setting";

    // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 王 start
    /**
     * 帳票種別定義
     */
    public static final String SYS_REPORT_CLASS = "/api/sys_report_class";
    // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 王 end

    /**
     * 掲示板登録情報系
     */
    public static final String BBS_INFO = "/api/bbsInfo";

    /**
     * プリンターマスターURI
     */
    public static final String PRINTERS = "/api/printers";

    /**
     * 予実リスト.
     */
    public static final String INDICATION_RESULT = "/api/indication-result";

    /**
     * 種別.
     */
    public static final String ROUND_TYPE = "/api/round-type";

    /**
     * 愁訴処置マスタ
     */
    public static final String COMPLAINT = "/api/complaint";

    /**
     * 利用者権限.
     */
    public static final String USER_AUTHORITY = "/api/user-authority";

    /**
     * プッシュ通知(仮).
     */
    public static final String SEND_PUSH = "/api/send-push";

    /**
     * モニタ.
     */
    public static final String MONITOR = "/api/monitor";

    /**
     * 個人設定の共通設定タブ定義
     */
    public static final String SYS_PERSONAL_SETTINGS_DEFINE = "/api/personal_setting_define";

    /**
     * 施設設定マスタ
     */
    public static final String FACILITY_SETTING = "/api/facilitySetting";

    /**
     * 通知メッセージ.
     */
    public static final String NOTIFICATION_MESSAGE = "/api/notification-message";

    /**
     * 検査系
     */
    public static final String EXAM = "/api/exam";

    /**
     * 放射線検査系
     */
    public static final String RAD = "/api/rad";

    /**
     * 帳票出力
     */
    public static final String REPORT_MENU = "/api/report_menu";

    /**
     * 保険情報
     */
    public static final String PAT_INSURANCE = "/api/pat_insurance";

    /**
     * 紹介状
     */
    public static final String PAT_INTRODUCTION_LETTER = "/api/pat-introduction-letter";

    /**
     * 指示受け・承認
     */
    public static final String PAT_IND_APPROVE = "/api/patIndApprove";
    public static final String PAT_IND_APPROVE_HISTORY = "/api/patIndApproveHistory";
    public static final String PAT_PERSONAL_MAIN = "/api/patPersonalMain";

    /**
     * 在宅透析
     */
    public static final String PAT_HOME_DIALYSIS = "/api/pat_home_dialysis";

    /**
     * 施設カレンダー
     */
    public static final String FACILITY_CALENDAR = "/api/facilityCalendar";

    /**
     * 水質管理
     */
    public static final String WATER_SURVEY = "/api/waterSurvey";

    /**
     * BVMS
     */
    public static final String BVMS = "/api/bvms";

    public static final String RE_LOOP_RATE_MAIN_COMMENTS = "/api/re-loop-rate-main-comments";

    /**
     * 連携施設
     */
    public static final String COOP_FACILITY = "/api/coopFacility";

    /**
     * マスターユーザー
     */
    public static final String MST_USER = "/api/mstUser";
    public static final String CARD_STATE = "/api/card_state";
    public static final String FACILITY_LOGIN_METHOD = "/api/facilitySetting/methodLogin";
    public static final String FACILITY_GET_USER_ID = "/api/facilitySetting/getUserId";
    public static final String CARD_STATE_DEVICE_CARD = "/api/card_state/getDeviceCard";
    public static final String CARD_STATE_DEVICE_STATUS = "/api/card_state/getDeviceStatus";

    /**
     * 患者名の識別
     */
    public static final String PAT_NAME_IDENTIFICATION = "api/pat_name_identification";

    /**
     * データリストカテゴリ詳細
     */
    public static final String SYS_DATA_LIST_DETAIL = "/api/sysDataListDetail";

    /**
     * 患者情報共有管理
     */
    public static final String SHR_PAT_INFO = "/api/shrPatInfo";

    /**
     * 検査結果
     */
    public static final String MENTE_MAIN = "/api/mente-main";

    /**
     * レイアウト検査
     */
    public static final String MENTE_LAYOUT = "/api/mente-layout";

    /**
     * レイアウトグループ検査
     */
    public static final String MENTE_LAYOUT_GROUP = "/api/mente-layout-group";

    /**
     * レイアウトカテゴリ検査
     */
    public static final String MENTE_CATEGORY = "/api/mente-category";

    /**
     * 詳細項目検査
     */
    public static final String MENTE_DETAIL = "/api/mente-detail";
    /**
     * 外部連携稼働ビューア
     */
    public static final String EXTERNAL_COOP_OPER_VIEWER = "/api/external_coop_oper_viewer";

    /**
     * 患者加算実績情報
     */
    public static final String ADDITION_INFO = "/api/addition_info";

    /**
     * 通知定義
     */
    public static final String SYS_NOTIFICATION = "/api/sys_notification";

    /**
     * システム設定
     */
    public static final String SYS_SYSTEM_DEFINE = "/api/sys_system_define";

    /**
     * ログ参照
     */
    public static final String LOGS = "/api/logs";

    /**
     * 浄化装置通信ソフト.
     */
    public static final String BLOOD_PURIFY = "/api/blood_purify";

    /**
     * オプション申込テーブル.
     */
    public static final String SAL_SUBSCRIPTION_MANAGE = "/api/salSubscriptionManage";

    /**
     * 詳細患者検索マスタ
     */
    public static final String PAT_SEARCH_DETAIL = "/api/pat_search_detail";

    /**
     * 標準医薬品マスタ
     */
    public static final String SYS_MEDICINE = "/api/sys_medicine";

    /**
     * リリース情報
     */
    public static final String SYS_RELEASE_INFO = "/api/release_info";

    /**
     * ログ出力
     */
    public static final String LOGGING = "/api/logging";

    /**
     * サインイン管理
     */
    public static final String SIGN_IN_MANAGER = "/api/sign-in";

    /**
     * サインイン管理
     */
    public static final String CLIENT_CERTIFICATE = "/api/client-cer";

    /**
     * サインイン管理取得（認証不要URL)
     */
    public static final String SIGN_IN_MANAGER_NO_AUTH_SELECT = SIGN_IN_MANAGER + "/select/**";

    /**
     * サインイン状態確認（認証不要URL)
     */
    public static final String SIGN_IN_MANAGER_CHECK_SESSIONTIMEOUT = SIGN_IN_MANAGER + "/check/sessiontimeout";

    /**
     * サインイン管理削除（認証不要URL)
     */
    public static final String SIGN_IN_MANAGER_NO_AUTH_DELETE = SIGN_IN_MANAGER + "/delete/**";

    /**
     * 背景色のカラーコード取得（認証不要URL)
     */
    public static final String SIGN_IN_MANAGER_COLOR_CODE = SIGN_IN_MANAGER + "/color_code";

    /**
     *  P-Ca9分割グラフ
     */
    public static final String CA9_GRAPH = "/api/ca9_graph";

    /**
     * 2要素認証 サインイン時にワンタイムパスワード初回登録.
     */
    public static final String REGISTER_OTP_AT_SIGN_IN = "/api/register_otp";

    /**
     * 2要素認証 サインイン時にワンタイムパスワード初回登録（認証不要URL).
     */
    public static final String REGISTER_OTP_AT_SIGN_IN_NO_AUTH = REGISTER_OTP_AT_SIGN_IN + "/**";


    /**
     * ログアップローダー
     */
    public static final String LOG_UPLOADER = "/api/log/uploader";

    //add FNSI-改修内容 バイタルグラフ追加 房　start
    /**
     * バイタル.
     */
    public static final String VITAL = "/api/vital";
    //add FNSI-改修内容 バイタルグラフ追加 房　end
    // FNSI-add 除外期間の追加 徐 start
    /**
     * 除外期間
     */
    public static final String EXCEPTION_PERIOD = "/api/exceptionPeriod";
    // FNSI-add 除外期間の追加 徐 end

    /**
     * ログアップローダー
     */
    public static final String SYS_COOP_NO = "/api/sysCoopNo";

    /* add by chamaojia 2025-05-21 [11871] --start */
    // iPhone側のメモリが大きいためにシステムが登録されている問題を処理する、新しいインタフェース
    public static final String SYS_FACILITY = "/api/sysFacility";
    /* add by chamaojia 2025-05-21 [11871] --end */
  }

  /**
   * 文字サイズ定義.
   */
  public static class FontSize {

    /**
     * 小.
     */
    public static final int SMALL = 0;

    /**
     * 中.
     */
    public static final int MEDIUM = 1;

    /**
     * 大.
     */
    public static final int LARGE = 2;

    /**
     * 特大.
     */
    public static final int EXTRA_LARGE = 3;

  }

  /**
   * テーマ定義.
   */
  public static class Theme {

    /**
     * 白.
     */
    public static final int WHITE = 0;

    /**
     * 黒.
     */
    public static final int BLACK = 1;

  }

  /**
   * メニューバー表示フラグ定義.
   */
  public static class IsDispMenu {

    /**
     * 非表示.
     */
    public static final int HIDDEN = 0;

    /**
     * 表示.
     */
    public static final int VISIBLE = 1;
  }

  /**
   * 画面フレーム分割フラグ定義.
   */
  public static class IsSplitFrame {

    /**
     * なし.
     */
    public static final int OFF = 0;

    /**
     * あり.
     */
    public static final int ON = 1;
  }

  /**
   * 装置動作記録の定数定義.
   */
  public static class MotionRecordsConstants {

    /**
     * 指定期間の日数 = 7日分.
     */
    public static final int PERIOD = 7;

    /**
     * 指定期間開始日に指定する日付のインデックス番号.
     * デフォルト = 6
     */
    public static final int INDEX_FROM_DATE = 6;

    /**
     * 指定レコード行数.
     */
    public static final int RECORD_CNT = 30;
  }

  /**
   * マスタ編集画面での操作タイプ定義.
   */
  public static class MasterOperationType {

    /**
     * 追加.
     */
    public static final int INSERT = 1;

    /**
     * 変更.
     */
    public static final int UPDATE = 2;
  }

  /**
   * ON/OFFフラグ
   */
  public static class FlagType {

    /**
     * OFF.
     */
    public static final String FLAG_OFF = "0";

    /**
     * ON.
     */
    public static final String FLAG_ON = "1";
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
   * WebSocket通知識別用トピック情報
   *
   */
  public static class WebSocketTopic {
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
      // add FNSI-田中衡機の追加 徐 start
      /**
       * 受信開始OK
       */
      public static final String SENDOK = "WEIGHT/SCALE_CLEAR";
      // add FNSI-田中衡機の追加 徐 end
      // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 start
      /**
       * マスタ変更
       */
      public static final String MST_CHANGED = "WEIGHT_SCALE/MST_CHANGED";
      // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 end
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
      public static final String RELOAD_COMSV_SETTING = "COMSV/5";
      /**
       * 愁訴処置マスタ更新指示
       */
      public static final String RELOAD_TREAT_MASTER = "COMSV/6";
      /**
       * スタッフマスタ更新指示
       */
      public static final String RELOAD_STAFF_MASTER = "COMSV/7";
      /**
       * 未登録患者割付指示
       */
      public static final String SET_UNKNOWN_PAT = "COMSV/8";
      /**
       * 条件送信キャンセル指示
       */
      public static final String CANCEL_CONDITION = "COMSV/9";
      /**
       * 投薬指示変更指示
       */
      public static final String CHANGE_IND_MEDI = "COMSV/10";
      /**
       * 後体重測定指示
       */
      public static final String AFTER_WEIGHT = "COMSV/11";
      /**
       * 治療状況確認指示
       */
      public static final String CHECK_STATUS = "COMSV/12";
      /**
       * チェックリストマスタ更新指示
       */
      public static final String RELOAD_CHECKLIST_MASTER = "COMSV/13";
      /**
       * 仮想端末キャッシュ更新指示
       */
      public static final String CHACE_CLEAR = "COMSV/14";
      /**
       * 検査項目マスタ更新指示
       */
      public static final String RELOAD_EXAM_MASTER = "COMSV/15";
      /**
       * オフライン運転開始指示
       */
      public static final String START_TREAT_OFFLINE = "COMSV/16";
      /**
       * オフライン運転終了指示
       */
      public static final String END_TREAT_OFFLINE = "COMSV/17";
      // add 通信サーバー通信追加 房 start
      //
      // #10518 2024.04.18 mod コメントが処理内容と違っているので修正 TDC米沢 start
      // /**
      //  * オフラインレポート更新
      //  */
      /**
       * 実績版確定時装置レポート画像更新
       */
      // #10518 2024.04.18 mod コメントが処理内容と違っているので修正 TDC米沢 end
      public static final String SEND_REPORT_WHEN_CONFIRM  = "COMSV/19";

      // #10518 2024.04.18 mod コメントが処理内容と違っているので修正 TDC米沢 start
      // /**
      //  * オフライン治療終了日更新
      //  */
      /**
       * 実績確定・削除時装置レポート画像更新
       */
      // #10518 2024.04.18 mod コメントが処理内容と違っているので修正 TDC米沢 end
      public static final String SEND_END_DATE_UPDATE_CONFIRM  = "COMSV/18";
      // add 通信サーバー通信追加 房 end

      // #10518 2024.04.18 mod コメントが処理内容と違っているので修正 TDC米沢 start
      // /**
      //  * 治療時間変更指示
      //  */
      /**
       * オフライン運転タイマー更新
       */
      // #10518 2024.04.18 mod コメントが処理内容と違っているので修正 TDC米沢 end
      public static final String SEND_TREAT_TIME  = "COMSV/20";

      //    add 7074 2022-12-02 設定していないホスト報知が通知される 張 start
      /**
       * ホスト報知定義更新指示
       */
      public static final String HOST_NOTIFICATION_DEFINITION  = "COMSV/21";
      //    add 7074 2022-12-02 設定していないホスト報知が通知される 張 end
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
       * 予約キャンセルトピック
       */
      public static final String PLAN_CANCEL = "NTSS/PLAN_CANCEL";

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
        /**
         * 予約キャンセルトピック
         */
        public static final short PLAN_CANCEL = 9;
      }
    }

    /**
     * 通知メッセージ
     */
    public static final String NOTIFICATION_MESSAGE = "NOTIFICATION/MESSAGE";

    /**
     * 強制サインアウト
     */
    public static final String FORCE_SIGNOUT = "SYSTEM/FORCE_SIGNOUT";
  }

  /**
   * ord_mainの定数
   */
  public static class OrdMainConst {
    /**
     * 治療状況
     */
    public static class DialysisState {
      /**
       * 条件送信前
       */
      public static final String BEFORE_SEND = "0";
      /**
       * 条件送信済
       */
      public static final String AFTER_SEND = "1";
      /**
       * 条件送信確認済み
       */
      public static final String CHECKED_SEND = "2";
      /**
       * 治療中
       */
      public static final String DIALYSIS = "3";
      /**
       * 排液済
       */
      public static final String AFTER_DIALYSIS = "4";
      /**
       * 後体重測定済み(実績未確定)
       */
      public static final String AFTER_WEIGHT = "5";
      /**
       * 後体重確認済み(過去実績)
       */
      public static final String PAST_RECORD = "6";
    }
  }

  /**
   * 治療方法マスタの定数
   */
  public static class Treatment {
    /**
     * 装置モード
     */
    public static class DeviceMode {
      /**
       * 不明
       */
      public static final Integer UNKNOWN = -1;
      /**
       * HD
       */
      public static final Integer HD = 0;
      /**
       * ECUM
       */
      public static final Integer ECUM = 1;
      /**
       * HDF
       */
      public static final Integer HDF = 2;
      /**
       * HF
       */
      public static final Integer HF = 3;
      /**
       * HD+補液
       */
      public static final Integer HD_AND_REPLACEMENT = 4;
      /**
       * ECUM+補液
       */
      public static final Integer ECUM_AND_REPLACEMENT = 5;
      /**
       * AFBF
       */
      public static final Integer AFBF = 6;
      /**
       * OHDF
       */
      public static final Integer OHDF = 7;
      /**
       * OHF
       */
      public static final Integer OHF = 8;
      /**
       * 特殊浄化
       */
      public static final Integer PURIFICATION = 9;
      /**
       * I-HDF
       */
      public static final Integer I_HDF = 10;
    }
  }

  /**
   * 装置型式定数
   */
  public static class MachineType {
    public static class Model {
      /**
       * RO
       */
      public static final String DRO = "001";
      /**
       * 供給装置
       */
      public static final String DAB = "002";
      /**
       * 溶解装置
       */
      public static final String DAD = "003";
      /**
       * 個人用透析装置
       */
      public static final String PERSONAL = "004";
      /**
       * 透析装置
       */
      public static final String DCS = "005";
      // add FNSI-251 付 start
      /**
       * 溶解装置（A粉対応）
       */
      public static final String DRYA = "006";
      /**
       * 溶解装置（B粉対応）
       */
      public static final String DRYB = "007";
      // add FNSI-251 付 end
    }
  }

  /**
   * 警報注意履歴定義
   *
   */
  public static class AlarmRecord {

    /**
     * 発生種類
     *
     */
    public static class AlarmClass {
      /**
       * 注意下限
       */
      public static final String CATEGORY_1 = "注意下限";
      /**
       * 注意上限
       */
      public static final String CATEGORY_2 = "注意上限";
      /**
       * 警報下限
       */
      public static final String CATEGORY_3 = "警報下限";
      /**
       * 警報上限
       */
      public static final String CATEGORY_4 = "警報上限";
      /**
       * 変化率注意下限
       */
      public static final String CATEGORY_5 = "変化率注意下限";
      /**
       * 変化率注意上限
       */
      public static final String CATEGORY_6 = "変化率注意上限";
      /**
       * 変化率警報下限
       */
      public static final String CATEGORY_7 = "変化率警報下限";
      /**
       * 変化率警報上限
       */
      public static final String CATEGORY_8 = "変化率警報上限";

      /**
       * 区分番号からメッセージを取得
       * @param classNo
       * @return
       */
      public static String getValue(int classNo) {
        switch (classNo) {
        case 1:
          return CATEGORY_1;
        case 2:
          return CATEGORY_2;
        case 3:
          return CATEGORY_3;
        case 4:
          return CATEGORY_4;
        case 5:
          return CATEGORY_5;
        case 6:
          return CATEGORY_6;
        case 7:
          return CATEGORY_7;
        case 8:
          return CATEGORY_8;
        default:
          return "";
        }

      }
    }

    /**
     * 発生区分
     *
     */
    public static class OccurClass {
      /**
       * 消滅
       */
      public static final String EXT = "消滅";
      /**
       * 発生
       */
      public static final String OCCUR = "発生";

      /**
       * 区分番号からメッセージを取得
       * @param classNo
       * @return
       */
      public static String getValue(int classNo) {
        switch (classNo) {
        case 0:
          return EXT;
        case 1:
          return OCCUR;
        default:
          return "";
        }
      }
    }
  }

  /**
   * 帳票出力のConstant
   */
  public static class ReportMenu {
    /**
     * 患者ID
     */
    public static final String PATIENT_ID = "患者ID";
    /**
     * 患者名
     */
    public static final String PATIENT_NAME = "患者名";
    /**
     * ベッドCD
     */
    public static final String PATIENT_BED = "ベッド表示順";
    /**
     * クール
     */
    public static final String PATIENT_COOL = "クール";
    /**
     * フリガナ
     */
    public static final String READING = "フリガナ";
    /**
     * 患者グループ名
     */
    public static final String PATIENT_GROUP_NAME = "患者グループ名";
    /**
     * ベッドグループ名
     */
    public static final String BED_GROUP_NAME = "ベッドグループ名";
    /**
     * ベッド名
     */
    public static final String BED_NAME = "ベッド名";
    /**
     * 入外区分
     */
    public static final String ENTRANCE_EXIT_CLASSIFICATION = "入外区分";
    /**
     * 性別
     */
    public static final String SEX = "性別";
    /**
     * 感染症患者
     */
    public static final String INFECTIOUS_ISEASE_PATIENTS = "感染症患者";
    /**
     * 血液型
     */
    public static final String BLOOD_TYPE = "血液型";
    /**
     * 薬剤/医材
     */
    public static final String MEDICINE_EQUIPMENT_CODE = "薬剤/医材";
    // add #9323 donghao start
    /**
     * 医材/薬剤
     */
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 start
//    public static final String EQUIPMENT_MEDICINE_CODE = "医材/薬剤";
      // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String EQUIPMENT_MEDICINE_CODE = "データ種別順";
    public static final String EQUIPMENT_MEDICINE_CODE = "データ種別表示順";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 end
    // add #12032 配布リスト（物品）の並び順に「データ分類」がない 高　start
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String EQUIPMENT_MEDICINE_DATA_GROUP = "治療条件順";
    public static final String EQUIPMENT_MEDICINE_DATA_GROUP = "治療条件";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    // add #12032 配布リスト（物品）の並び順に「データ分類」がない 高　end
    // add #9323 donghao end
    /**
     * 分類名称
     */
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 start
//    public static final String MEDICINE_EQUIPMENT_CLASS = "分類名称";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String MEDICINE_EQUIPMENT_CLASS = "分類名称順";
    public static final String MEDICINE_EQUIPMENT_CLASS = "分類名称表示順";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 end
    /**
     * 名称
     */
    public static final String MEDICINE_EQUIPMENT_NAME = "名称";
    /*add 2020-12-09 FNSI-添加内容 各帳票の並び順調整。 吉 start*/
    /**
     * 透析日
     */
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//    public static final String DIALYSIS_DAY = "透析日";
    public static final String DIALYSIS_DAY = "治療日";
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    /**
     * 透析室グループ
     */
    // mod #7880 帳票：ラベルが正しく表示されない 姜 start
    // public static final String DIALYSIS_ROOM_GROUP = "透析室グループ";
    public static final String DIALYSIS_ROOM_GROUP = "透析室表示順";
    // mod #7880 帳票：ラベルが正しく表示されない 姜 end
    /**
     * ベッドグループ
     */
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String ROOM_BED_GROUP = "ベッドグループ";
    public static final String ROOM_BED_GROUP = "ベッドグループ表示順";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    /*add 2020-12-09 FNSI-添加内容 各帳票の並び順調整。 吉 end*/
    /*add FNSI-改修内容装置帳票の対応 任 start*/
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String MACHINE_NAME = "装置名称";
    public static final String MACHINE_NAME = "装置表示順";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    public static final String MACHINE_NO = "装置番号";
    public static final String MACHINE_SERIAL = "製造番号";
    public static final String MACHINE_TYPE = "型式名";
    /*add FNSI-改修内容装置帳票の対応 任 end*/
    // add 9036 【IES起票】帳票画面_並び替え表示不正　吉 start
    public static final String BED_CD = "ベッド表示順";
    // add 9036 【IES起票】帳票画面_並び替え表示不正　吉 end
  }


  /**
   * 権限定義.
   */
  public static class Authority {

    /**
     * 施設 - 閲覧.
     */
    public static final String FCL_VIEW = "011";

    /**
     * 施設 - 代理編集.
     */
    public static final String FCL_PEDIT = "012";

    /**
     * 施設 - 編集.
     */
    public static final String FCL_EDIT = "013";

    /**
     * 患者情報 - 閲覧.
     */
    public static final String PAT_VIEW = "021";

    /**
     * 患者情報 - 代理編集.
     */
    public static final String PAT_PEDIT = "022";

    /**
     * 患者情報 - 編集.
     */
    public static final String PAT_EDIT = "023";

    /**
     * 患者イベント - 閲覧.
     */
    public static final String PAT_EVENT_VIEW = "031";

    /**
     * 患者イベント - 代理編集.
     */
    public static final String PAT_EVENT_PEDIT = "032";

    /**
     * 患者イベント - 編集.
     */
    public static final String PAT_EVENT_EDIT = "033";

    /**
     * 患者別装置設定 - 閲覧.
     */
    public static final String PAT_DEVSET_VIEW = "041";

    /**
     * 患者別装置設定 - 代行編集.
     */
    public static final String PAT_DEVSET_PEDI = "042";

    /**
     * 患者別装置設定 - 編集.
     */
    public static final String PAT_DEVSET_EDI = "043";

    /**
     * 治療指示 - 閲覧.
     */
    public static final String IND_VIEW = "051";

    /**
     * 治療指示 - 代理編集.
     */
    public static final String IND_PEDIT = "052";

    /**
     * 治療指示 - 編集.
     */
    public static final String IND_EDIT = "053";

    /**
     * 治療指示受け・承認 - 閲覧.
     */
    public static final String IND_RECEIVE_VIEW = "061";

    /**
     * 治療指示受け・承認 - 代理編集.
     */
    public static final String IND_RECEIVE_PEDIT = "062";

    /**
     * 治療指示受け・承認 - 編集.
     */
    public static final String IND_RECEIVE_EDIT = "063";

    /**
     * 検査・放射線指示 - 閲覧.
     */
    public static final String IND_EXAM_VIEW = "071";

    /**
     * 検査・放射線指示 - 代行編集.
     */
    public static final String IND_EXAM_PEDIT = "072";

    /**
     * 検査・放射線指示 - 編集.
     */
    public static final String IND_EXAM_EDIT = "073";

    /**
     * 処方 - 閲覧.
     */
    public static final String PRESCRIPTION_VIEW = "081";

    /**
     * 処方 - 代理編集.
     */
    public static final String PRESCRIPTION_PEDIT = "082";

    /**
     * 処方 - 編集.
     */
    public static final String PRESCRIPTION_EDIT = "083";

    /**
     * 治療記録 - 閲覧.
     */
    public static final String RST_VIEW = "091";

    /**
     * 治療記録 - 代理編集.
     */
    public static final String RST_PEDIT = "092";

    /**
     * 治療記録 - 編集.
     */
    public static final String RST_EDIT = "093";

    /**
     * 検査結果 - 閲覧.
     */
    public static final String RST_EXAM_VIEW = "101";

    /**
     * 検査結果 - 代行編集.
     */
    public static final String RST_EXAM_PEDIT = "102";

    /**
     * 検査結果 - 編集.
     */
    public static final String RST_EXAM_EDIT = "103";

    /**
     * 機器保守 - 閲覧.
     */
    public static final String DEV_VIEW = "111";

    /**
     * 機器保守 - 代行編集.
     */
    public static final String DEV_PEDIT = "112";

    /**
     * 機器保守 - 編集.
     */
    public static final String DEV_EDIT = "113";

    /**
     * 患者削除.
     */
    public static final String DEL_PAT = "991";

    /**
     * 患者イベント削除.
     */
    public static final String DEL_PAT_EVENT = "992";

    /**
     * 治療実績削除.
     */
    public static final String DEL_RST = "993";

    /**
     * 検査結果削除.
     */
    public static final String DEL_EXAM = "994";

    /**
     * 処方削除.
     */
    public static final String DEL_PRESCRIPTION = "995";

  }

  /**
   * 指示履歴
   */
  public static class IndHistory {
    /**
     * すべて
     */
    public static final int ALL = 1;

    /**
     * 未
     */
    public static final int NOTYET = 2;

    /**
     * 済
     */
    public static final int ALREADY = 3;

    /**
     * 指示タイプ 受け
     */
    public static final int RECEIVER_1 = 1;

    /**
     * 指示タイプ 受け
     */
    public static final int RECEIVER_2 = 2;

    /**
     * 指示タイプ 承認
     */
    public static final int APPROVER_1 = 3;

    /**
     * 指示タイプ 承認
     */
    public static final int APPROVER_2 = 4;
  }

  /**
   * 患者情報-入外・転入出カード-区分値(画面入力値)
   */
  public static class InOutVisitHistoryInfoMoveInOut {
    /**
     * 導入
     */
    public static final String MOVE_IN_OUT_CLASS_INTRODUCTION = "1";

    /**
     * 転入
     */
    public static final String MOVE_IN_OUT_CLASS_MOVE_IN = "2";

    /**
     * 転出
     */
    public static final String MOVE_IN_OUT_CLASS_MOVING_OUT = "3";

    /**
     * 入院
     */
    public static final String MOVE_IN_OUT_CLASS_HOSPITALIZATION = "4";

    /**
     * 退院
     */
    public static final String MOVE_IN_OUT_CLASS_DISCHARGE = "5";

    /**
     * 外来
     */
    public static final String MOVE_IN_OUT_CLASS_OUTPATIENT = "6";

    /**
     * 離脱
     */
    public static final String MOVE_IN_OUT_CLASS_WITHDRAWAL = "7";

    /**
     * 移植
     */
    public static final String MOVE_IN_OUT_CLASS_IMPLANTATION = "8";

    /**
     * 一時転出
     */
    public static final String MOVE_IN_OUT_CLASS_TEMPORARILY_MOVING_OUT = "9";

    /**
     * 通院拒否・不明
     */
    public static final String MOVE_IN_OUT_CLASS_REJECTION_UNKNOWN = "10";

    /**
     * 死亡
     */
    public static final String MOVE_IN_OUT_CLASS_DEATH = "11";

  }

  /**
   * 転入出状態(DB保存値)
   */
  public static class PatInfoMoveInOut {
    /**
     * 在院
     */
    public static final String MOVE_IN_OUT_HOSPITALIZATION = "0";

    /**
     * 導入予定
     */
    public static final String MOVE_IN_OUT_INTRODUCTION_PLAN = "1";

    /**
     * 転入予定
     */
    public static final String MOVE_IN_OUT_MOVE_IN_PLAN = "2";

    /**
     * 転出
     */
    public static final String MOVE_IN_OUT_MOVING_OUT = "3";

    /**
     * 離脱
     */
    public static final String MOVE_IN_OUT_WITHDRAWAL = "7";

    /**
     * 移植
     */
    public static final String MOVE_IN_OUT_IMPLANTATION = "8";

    /**
     * 一時転出
     */
    public static final String MOVE_IN_OUT_TEMPORARILY_MOVING_OUT = "9";

    /**
     * 不明
     */
    public static final String MOVE_IN_OUT_UNKNOWN = "10";

    /**
     * 死亡
     */
    public static final String MOVE_IN_OUT_DEATH = "11";

  }

  /**
   * 入外区分値(画面入力値/DB保存値 共通)
   */
  public static class PatInfoInOutClass {
    /**
     * 外来
     */
    public static final Integer IN_OUT_CLASS_OUTPATIENT = 0;

    /**
     * 入院
     */
    public static final Integer IN_OUT_CLASS_HOSPITALIZATION = 1;

    /**
     * 死亡
     */
    public static final Integer IN_OUT_CLASS_DEATH = 2;

    /**
     * － (不在)
     */
    public static final Integer IN_OUT_CLASS_ABSRENCE = 3;

  }

  public static class SalSubscriptionManageStatus {
    /**
     * 受け入れない
     */
    public static final String NOT_ACCEPTED = "0";
    /**
     * 受け入れた
     */
    public static final String ACCEPTED = "1";
    /**
     * 完了
     */
    public static final String COMPLETION = "2";
    /**
     * キャンセル
     */
    public static final String CANCEL = "9";
  }

  /**
   * 患者保険の分類値（画面入力値/ DBセーブ値に共通）
   */
  public static class PatInsuranceClass {
    /**
     * 保険
     */
    public static final Integer INSURANCE_CLASS = 0;

    /**
     * 公費
     */
    public static final Integer PUBLIC_EXPENDITURE_CLASS = 1;

    /**
     * セット
     */
    public static final Integer SET_CLASS = 2;

    /**
     * 自費
     */
    public static final Integer OWN_EXPENSE_CLASS = 3;

  }

  /**
   *
   */
  public static class FacilityCalendarItem {

    /**
     * 全治療件数.
     */
    public static final String TOTAL_TREATMENTS = "total_treatments";

    /**
     * 透析治療件数.
     */
    public static final String DIALYSIS_TREATMENTS = "dialysis_treatments";

    /**
     * HD治療件数.
     */
    public static final String HD_TREATMENTS = "hd_treatments";

    /**
     * ECUM治療件数.
     */
    public static final String ECUM_TREATMENTS = "ecum_treatments";

    /**
     * HDF治療件数.
     */
    public static final String HDF_TREATMENTS = "hdf_treatments";

    /**
     * HF治療件数.
     */
    public static final String HF_TREATMENTS = "hf_treatments";

    /**
     * AFBF治療件数.
     */
    public static final String AFBF_TREATMENTS = "afbf_treatments";

    /**
     * OHDF治療件数.
     */
    public static final String OHDF_TREATMENTS = "ohdf_treatments";

    /**
     * OHF治療件数.
     */
    public static final String OHF_TREATMENTS = "ohf_treatments";

    /**
     * I-HDF治療件数.
     */
    public static final String I_HDF_TREATMENTS_NUMBER = "i_hdf_treatments_number";

    /**
     * 特殊浄化治療件数.
     */
    public static final String SPECIAL_PURIFICATION_TREATMENTS_NUMBER = "special_purification_treatments_number";

    /**
     * 外来患者治療件数.
     */
    public static final String OUTPATIENT_TREATMENTS = "outpatient_treatments";

    /**
     * 入院患者治療件数.
     */
    public static final String INPATIENT_TREATMENTS_NUMBER = "inpatient_treatments_number";

    /**
     * クール別治療件数.
     */
    public static final String TREATMENTS_BY_COURSE_NUMBER = "treatments_by_course_number";

    /**
     * 導入件数.
     */
    public static final String INTRODUCTIONS_NUMBER = "introductions_number";

    /**
     * 転入件数.
     */
// mod FNSI-改修内容 転入件数と転出件数、死亡件数が施設カレンダー画面で表示できない dou start
//    public static final String MOVE_IN = "move_in";
    public static final String MOVE_IN_NUMBER = "move_in_number";
// mod FNSI-改修内容 転入件数と転出件数、死亡件数が施設カレンダー画面で表示できない dou end
    /**
     * 転出件数.
     */
// mod FNSI-改修内容 転入件数と転出件数、死亡件数が施設カレンダー画面で表示できない dou start
//    public static final String MOVING_OUT = "moving_out";
    public static final String MOVING_OUT_NUMBER = "moving_out_number";
// mod FNSI-改修内容 転入件数と転出件数、死亡件数が施設カレンダー画面で表示できない dou end
    /**
     * 入院件数.
     */
    public static final String HOSPITALIZATIONS_NUMBER = "hospitalizations_number";

    /**
     * 退院件数.
     */
    public static final String DISCHARGES_NUMBER = "discharges_number";

    /**
     * 外来件数.
     */
    public static final String OUTPATIENTS = "outpatients";

    /**
     * 離脱件数.
     */
    public static final String WITHDRAWALS = "withdrawals";

    /**
     * 移植件数.
     */
    public static final String TRANSPLANTS_NUMBER = "transplants_number";

    /**
     * 一時転出(出)件数.
     */
    public static final String TEMPORARY_TRANSFERS_OUTS_NUMBER = "temporary_transfers_outs_number";

    /**
     * 一時転出(入)件数.
     */
    public static final String TEMPORARY_TRANSFERS_IN_NUMBER = "temporary_transfers_in_number";

    /**
     * 拒否・不明件数.
     */
    public static final String REJECTED_UNKNOWN_NUMBER = "rejected_unknown_number";

    /**
     * 死亡件数.
     */
    public static final String DEATHS = "deaths";

    /**
     * 検査予定件数.
     */
    public static final String SCHEDULED_NUMBER_INSPECTIONS = "scheduled_number_inspections";

    /**
     * 放射線予定件数.
     */
    public static final String EXPECTED_NUMBER_RADIATION = "expected_number_radiation";

    /**
     * 患者イベントカテゴリマスタ分繰り返す.
     */
    public static final String REPEAT_PAT_EVENT_CATEGORY = "repeat_pat_event_category";

    /**
     * 患者イベントサブカテゴリマスタ分繰り返す.
     */
    public static final String REPEAT_PAT_EVENT_SUBCATEGORY = "repeat_pat_event_subcategory";

    /**
     * 自己診断結果.
     */
    public static final String SELF_DIAGNOSIS_RESULT = "self_diagnosis_result";

    /**
     * 日常点検列名分繰り返す.
     */
    public static final String REPEAT_DAILY_INSPECTION = "repeat_daily_inspection";

    // add #9552 日常点検の個別選択ができない 商 start
    /**
     * 日常点検レイアウト.
     */
    public static final String REPEAT_MAINTE_LAYOUT = "repeat_mainte_layout";
    // add #9552 日常点検の個別選択ができない 商 end

    /**
     * 定期点検.
     */
    public static final String PERIODIC_INSPECTION = "periodic_inspection";

    /**
     * 水質管理.
     */
    public static final String WATER_QUALITY_MANAGEMENT = "water_quality_management";

    /**
     * 施設イベントカテゴリ分繰り返す.
     */
    public static final String REPEAT_FACILITY_EVENT_CATEGORIES = "repeat_facility_event_categories";

  }

  /**
   * インアウト項目区分定義
   */
  public static class NumberOfInOut {
    @Data
    public static class NumberOfInOutItem {
      private String id;
      private String descr;

      private NumberOfInOutItem(String id, String descr) {
        this.id = id;
        this.descr = descr;
      }
    }

    public static NumberOfInOutItem[] listItemInOut = {

        // 導入 区分値
        new NumberOfInOutItem("1", "導入"),

        // 転入
        new NumberOfInOutItem("2", "転入"),

        // 転出
        new NumberOfInOutItem("3", "転出"),

        // 入院
        new NumberOfInOutItem("4", "入院"),

        // 退院
        new NumberOfInOutItem("5", "退院"),

        // 外来
        new NumberOfInOutItem("6", "外来"),

        // 離脱
        new NumberOfInOutItem("7", "離脱"),

        // 移植
        new NumberOfInOutItem("8", "移植"),

        // 一時転出
        new NumberOfInOutItem("9", "一時転出"),

        // 通院拒否・不明
        new NumberOfInOutItem("10", "通院拒否・不明"),

        // 死亡
        new NumberOfInOutItem("11", "死亡"),
    };
  }

  /**
   *
   */
  public static class Router {
    // スケジュール表
    public static final String SCHEDULE_LIST = "schedule-list";

    // 患者情報
    public static final String PAT_INFO = "pat-info";

    //検査依頼
    public static final String EXAM_REQUEST = "exam-request";

    //放射線依頼
    public static final String RADIATION_REQUEST = "rad-request";

    //日常点検
    public static final String DAILY_CHECK = "daily-check";

    //掲示板登録情報クラス
    public static final String BBS_INFO = "bbs-info";

    //水質管理
    public static final String WATER_QUALITY_SURVEY = "water-quality-survey";

    //定期点検
    public static final String PERIODIC_INSPECTION = "periodic-inspection";

    //遠隔監視
    // mod FNSI-改修内容 自己診断結果：合格xx台、不合格xx台、未実施xx台 dou start
//    public static final String OPERATION_VIEWER = "operation-viewer";
    public static final String OPERATION_VIEWER = "operation-viewer-general-machines";
    // mod FNSI-改修内容 自己診断結果：合格xx台、不合格xx台、未実施xx台 dou end

    // #9531_Q&A Added by Zhou.tao 患者イベントカテゴリマスタ分繰り返す Start
    public static final String PAT_EVENT = "pat-event";
    // #9531_Q&A Added by Zhou.tao 患者イベントカテゴリマスタ分繰り返す End
  }

  /**
   *
   */
  public static class Unit {
    // 件
    public static final String ITEM = "item";

    // 人
    public static final String PERSON = "person";

    //タイトル
    public static final String TITLE = "title";

    //台
    public static final String TABLE = "table";

  }

  /**
   * 点検用途クラス定義
   */
  public static class MainteClass {
    /**
     * 日常点検
     */
    public static final String DAILY = "1";
    /**
     * 定期点検
     */
    public static final String PERIODIC = "2";
  }

  /**
   * 点検結果クラス定義
   */
  public static class MainteAnswer {
    /**
     * 日常点検用
     */
    public static class Daily {
      /**
       * 未実施（旧仕様）
       */
      public static final String NONE_OLD = "";
      /**
       * 未実施
       */
      public static final String NONE = null;
      /**
       * 合格
       */
      public static final String PASS = "1";
      /**
       * 不合格
       */
      public static final String FAIL = "2";
      /**
       * 点検途中
       */
      public static final String PROGRESS = "3";
    }
  }

  /**
   *
   */
  public static class InspectionResult {
    @Data
    public static class InspectionResultItem {
      private String id;
      private String descr;

      private InspectionResultItem(String id, String descr) {
        this.id = id;
        this.descr = descr;
      }
    }

    public static InspectionResultItem[] listInspectionResultDailyCheck = {
// del FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou start
      // ブランク
//      new InspectionResultItem(null, "blank"),
// del FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou end
      // 合格
      new InspectionResultItem("1", "pass"),
// mod FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou start
      // 点検途中
//      new InspectionResultItem("2", "during inspection")

      // 不合格
      new InspectionResultItem("3", "ng"),

      // 未実施
      new InspectionResultItem("4", "blank"),
// mod FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou end
    };

    public static InspectionResultItem[] listInspectionResultPeriodic = {

        // 要確認
        new InspectionResultItem(null, "confirmation required"),

        // 合格
        new InspectionResultItem("1", "pass"),

    };
  }

  /**
   * 事前設定
   */
  public static class AdvancedSettings {

    // 加算機能
    public static final String ADDITION_INFO = "A08";
  }

  /**
   * システム利用設定
   */
  public static class SystemUseSetting {
    // 日機装 ReMS
    public static final String REMS = "日機装 ReMS";

    // 日機装 FutureNetWeb⁺Si
    public static final String FUTURENETWEB_SI = "日機装 FutureNetWeb⁺Si";

    // 日機装 FutureNetWeb⁺Si×ReMS
    public static final String FUTURENETWEB_SI_REMS = "日機装 FutureNetWeb⁺Si×ReMS";

    //日機装
    public static final String NKK = "日機装";

    /* add by chamaojia 2023-03-08 [6118] 最大長制限定数の一括挿入  --start */
    // バルクinsertデータの最大制限
    public static final int BATCH_INSERT_MAX_LIMIT_NUM = 1000;
    /* add by chamaojia 2023-03-08 [6118] 最大長制限定数の一括挿入  --end */
    /* add by ztc 2023-05-19 [8605] 一括挿入データの修正ioストリームの超長異常問題が発生しました  --start */
    public static final int BATCH_INSERT_MAX_LIMIT_NUM_ORD_CHECK_LIST = 2500;
    /* add by ztc 2023-05-19 [8605] 一括挿入データの修正ioストリームの超長異常問題が発生しました  --end */
  }

  /**
   * P-Ca9分割グラフ設定
   */
  public static class GraphSetting {

    //検査結果取得の検査区分No
    public static final String EXAM_CATEGORY_NO = "1";
    //検査結果取得の検査区分Txt
    public static final String EXAM_CATEGORY_TXT = "examCategory";
    //X軸検査マスタ指定No
    public static final String EXAM_ITEM_CD_X_NO = "2";
    //X軸検査マスタ指定Txt
    public static final String EXAM_ITEM_CD_X_TXT = "examItemCdX";
    //Y軸検査マスタ指定No
    public static final String EXAM_ITEM_CD_Y_NO = "3";
    //Y軸検査マスタ指定Txt
    public static final String EXAM_ITEM_CD_Y_TXT = "examItemCdY";
    //X軸グラフ上限値No
    public static final String LIMIT_UPPER_X_NO = "4";
    //X軸グラフ上限値Txt
    public static final String LIMIT_UPPER_X_TXT = "limitUpperX";
    //X軸グラフ閾値上限No
    public static final String LIMIT_UPPER_THRESHOLD_X_NO = "5";
    //X軸グラフ閾値上限Txt
    public static final String LIMIT_UPPER_THRESHOLD_X_TXT = "limitUpperThresholdX";
    //X軸グラフ閾値下限No
    public static final String LIMIT_LOWER_THRESHOLD_X_NO = "6";
    //X軸グラフ閾値下限Txt
    public static final String LIMIT_LOWER_THRESHOLD_X_TXT = "limitLowerThresholdX";
    //X軸グラフ下限値No
    public static final String LIMIT_LOWER_X_NO = "7";
    //X軸グラフ下限値Txt
    public static final String LIMIT_LOWER_X_TXT = "limitLowerX";
    //Y軸グラフ上限値No
    public static final String LIMIT_UPPOER_Y_NO = "8";
    //Y軸グラフ上限値Txt
    public static final String LIMIT_UPPOER_Y_TXT = "limitUpperY";
    //Y軸グラフ閾値上限No
    public static final String LIMIT_UPPER_THRESHOLD_Y_NO = "9";
    //Y軸グラフ閾値上限Txt
    public static final String LIMIT_UPPER_THRESHOLD_Y_TXT = "limitUpperThresholdY";
    //Y軸グラフ閾値下限No
    public static final String LIMIT_LOWER_THRESHOLD_Y_NO = "10";
    //Y軸グラフ閾値下限Txt
    public static final String LIMIT_LOWER_THRESHOLD_Y_TXT = "limitLowerThresholdY";
    //Y軸グラフ下限値No
    public static final String LIMIT_LOWER_Y_NO = "11";
    //Y軸グラフ下限値Txt
    public static final String LIMIT_LOWER_Y_TXT = "limitLowerY";
    //グラフプロットのサイズNo
    public static final String PLOT_SIZE_NO = "12";
    //グラフプロットのサイズTxt
    public static final String PLOT_SIZE_TXT = "plotSize";
    //プロットの色No
    public static final String PLOT_COLOR_NO = "13";
    //プロットの色Txt
    public static final String PLOT_COLOR_TXT = "plotColor";
    //プロットの色（選択患者）No
    public static final String PLOT_SELECTED_COLOR_NO = "14";
    //プロットの色（選択患者）Txt
    public static final String PLOT_SELECTED_COLOR_TXT = "plotSelectedColor";
    //プロットの色（範囲外）No
    public static final String PLOT_OUTSIZE_COLOR_NO = "15";
    //プロットの色（範囲外）Txt
    public static final String PLOT_OUTSIZE_COLOR_TXT = "plotOutsideColor";
    //プロットの色（経過表示期間①）No
    public static final String PLOT_PROGRESS1_COLOR_NO = "16";
    //プロットの色（経過表示期間①）Txt
    public static final String PLOT_PROGRESS1_COLOR_TXT = "plotProgress1Color";
    //プロットの色（経過表示期間②）No
    public static final String PLOT_PROGRESS2_COLOR_NO = "17";
    //プロットの色（経過表示期間②）Txt
    public static final String PLOT_PROGRESS2_COLOR_TXT = "plotProgress2Color";
    //プロットの色（経過表示期間③）No
    public static final String PLOT_PROGRESS3_COLOR_NO = "18";
    //プロットの色（経過表示期間③）Txt
    public static final String PLOT_PROGRESS3_COLOR_TXT = "plotProgress3Color";
    //プロットの色（経過表示期間④）No
    public static final String PLOT_PROGRESS4_COLOR_NO = "19";
    //プロットの色（経過表示期間④）Txt
    public static final String PLOT_PROGRESS4_COLOR_TXT = "plotProgress4Color";
    //線の色（経過表示期間①）No
    public static final String LINE_PROGRESS1_COLOR_NO = "20";
    //線の色（経過表示期間①）Txt
    public static final String LINE_PROGRESS1_COLOR_TXT = "lineProgress1Color";
    //線の色（経過表示期間②）No
    public static final String LINE_PROGRESS2_COLOR_NO = "21";
    //線の色（経過表示期間②）Txt
    public static final String LINE_PROGRESS2_COLOR_TXT = "lineProgress2Color";
    //線の色（経過表示期間③）No
    public static final String LINE_PROGRESS3_COLOR_NO = "22";
    //線の色（経過表示期間③）Txt
    public static final String LINE_PROGRESS3_COLOR_TXT = "lineProgress3Color";
    //線の色（経過表示期間④）No
    public static final String LINE_PROGRESS4_COLOR_NO = "23";
    //線の色（経過表示期間④）Txt
    public static final String LINE_PROGRESS4_COLOR_TXT = "lineProgress4Color";
    //グラフ線の太さNo
    public static final String SERIES_LINE_WIDTH_NO = "24";
    //グラフ線の太さTxt
    public static final String SERIES_LINE_WIDTH_TXT = "seriesLineWidth";
    //集計情報エリア1説明文No
    public static final String DISTRIBUTION_GRAPH_TOOLTIP1_NO = "25";
    //集計情報エリア1説明文Txt
    public static final String DISTRIBUTION_GRAPH_TOOLTIP1_TXT = "distributionGraphTooltip1";
    //集計情報エリア2説明文No
    public static final String DISTRIBUTION_GRAPH_TOOLTIP2_NO = "26";
    //集計情報エリア2説明文Txt
    public static final String DISTRIBUTION_GRAPH_TOOLTIP2_TXT = "distributionGraphTooltip2";
    //集計情報エリア3説明文No
    public static final String DISTRIBUTION_GRAPH_TOOLTIP3_NO = "27";
    //集計情報エリア3説明文Txt
    public static final String DISTRIBUTION_GRAPH_TOOLTIP3_TXT = "distributionGraphTooltip3";
    //集計情報エリア4説明文No
    public static final String DISTRIBUTION_GRAPH_TOOLTIP4_NO = "28";
    //集計情報エリア4説明文Txt
    public static final String DISTRIBUTION_GRAPH_TOOLTIP4_TXT = "distributionGraphTooltip4";
    //集計情報エリア5説明文No
    public static final String DISTRIBUTION_GRAPH_TOOLTIP5_NO = "29";
    //集計情報エリア5説明文Txt
    public static final String DISTRIBUTION_GRAPH_TOOLTIP5_TXT = "distributionGraphTooltip5";
    //集計情報エリア6説明文No
    public static final String DISTRIBUTION_GRAPH_TOOLTIP6_NO = "30";
    //集計情報エリア6説明文Txt
    public static final String DISTRIBUTION_GRAPH_TOOLTIP6_TXT = "distributionGraphTooltip6";
    //集計情報エリア7説明文No
    public static final String DISTRIBUTION_GRAPH_TOOLTIP7_NO = "31";
    //集計情報エリア7説明文Txt
    public static final String DISTRIBUTION_GRAPH_TOOLTIP7_TXT = "distributionGraphTooltip7";
    //集計情報エリア8説明文No
    public static final String DISTRIBUTION_GRAPH_TOOLTIP8_NO = "32";
    //集計情報エリア8説明文Txt
    public static final String DISTRIBUTION_GRAPH_TOOLTIP8_TXT = "distributionGraphTooltip8";
    //集計情報エリア9説明文No
    public static final String DISTRIBUTION_GRAPH_TOOLTIP9_NO = "33";
    //集計情報エリア9説明文Txt
    public static final String DISTRIBUTION_GRAPH_TOOLTIP9_TXT = "distributionGraphTooltip9";
    //グラフエリア1患者グループNo
    public static final String PATIENT_GROUP_AREA1_NO = "34";
    //グラフエリア1患者グループTxt
    public static final String PATIENT_GROUP_AREA1_TXT = "patientGroupArea1";
    //グラフエリア2患者グループNo
    public static final String PATIENT_GROUP_AREA2_NO = "35";
    //グラフエリア2患者グループTxt
    public static final String PATIENT_GROUP_AREA2_TXT = "patientGroupArea2";
    //グラフエリア3患者グループNo
    public static final String PATIENT_GROUP_AREA3_NO = "36";
    //グラフエリア3患者グループTxt
    public static final String PATIENT_GROUP_AREA3_TXT = "patientGroupArea3";
    //グラフエリア4患者グループNo
    public static final String PATIENT_GROUP_AREA4_NO = "37";
    //グラフエリア4患者グループTxt
    public static final String PATIENT_GROUP_AREA4_TXT = "patientGroupArea4";
    //グラフエリア5患者グループNo
    public static final String PATIENT_GROUP_AREA5_NO = "38";
    //グラフエリア5患者グループTxt
    public static final String PATIENT_GROUP_AREA5_TXT = "patientGroupArea5";
    //グラフエリア6患者グループNo
    public static final String PATIENT_GROUP_AREA6_NO = "39";
    //グラフエリア6患者グループTxt
    public static final String PATIENT_GROUP_AREA6_TXT = "patientGroupArea6";
    //グラフエリア7患者グループNo
    public static final String PATIENT_GROUP_AREA7_NO = "40";
    //グラフエリア7患者グループTxt
    public static final String PATIENT_GROUP_AREA7_TXT = "patientGroupArea7";
    //グラフエリア8患者グループNo
    public static final String PATIENT_GROUP_AREA8_NO = "41";
    //グラフエリア8患者グループTxt
    public static final String PATIENT_GROUP_AREA8_TXT = "patientGroupArea8";
    //グラフエリア9患者グループNo
    public static final String PATIENT_GROUP_AREA9_NO = "42";
    //グラフエリア9患者グループTxt
    public static final String PATIENT_GROUP_AREA9_TXT = "patientGroupArea9";
    //X軸の項目コード
    public static final String UNIT_X_TXT = "unitX";
    //Y軸の項目コード
    public static final String UNIT_Y_TXT = "unitY";
    //X軸の項目名
    public static final String UNIT_NAME_X_TXT = "unitNameX";
    //Y軸の項目名
    public static final String UNIT_NAME_Y_TXT = "unitNameY";
    //患者グループ名エリア1
    public static final String PATIENT_GROUP_NAME_AREA1_TXT = "patientGroupNameArea1";
    //患者グループ名エリア2
    public static final String PATIENT_GROUP_NAME_AREA2_TXT = "patientGroupNameArea2";
    //患者グループ名エリア3
    public static final String PATIENT_GROUP_NAME_AREA3_TXT = "patientGroupNameArea3";
    //患者グループ名エリア4
    public static final String PATIENT_GROUP_NAME_AREA4_TXT = "patientGroupNameArea4";
    //患者グループ名エリア5
    public static final String PATIENT_GROUP_NAME_AREA5_TXT = "patientGroupNameArea5";
    //患者グループ名エリア6
    public static final String PATIENT_GROUP_NAME_AREA6_TXT = "patientGroupNameArea6";
    //患者グループ名エリア7
    public static final String PATIENT_GROUP_NAME_AREA7_TXT = "patientGroupNameArea7";
    //患者グループ名エリア8
    public static final String PATIENT_GROUP_NAME_AREA8_TXT = "patientGroupNameArea8";
    //患者グループ名エリア9
    public static final String PATIENT_GROUP_NAME_AREA9_TXT = "patientGroupNameArea9";

    /**
     * 定数設定一覧を取得する
     * @return
     */
    public static Map<String, String> getSettingHashList() {
      return new HashMap<String, String>() {
        {
          put(EXAM_CATEGORY_NO, EXAM_CATEGORY_TXT);
          put(EXAM_ITEM_CD_X_NO, EXAM_ITEM_CD_X_TXT);
          put(EXAM_ITEM_CD_Y_NO, EXAM_ITEM_CD_Y_TXT);
          put(LIMIT_UPPER_X_NO, LIMIT_UPPER_X_TXT);
          put(LIMIT_UPPER_THRESHOLD_X_NO, LIMIT_UPPER_THRESHOLD_X_TXT);
          put(LIMIT_LOWER_THRESHOLD_X_NO, LIMIT_LOWER_THRESHOLD_X_TXT);
          put(LIMIT_LOWER_X_NO, LIMIT_LOWER_X_TXT);
          put(LIMIT_UPPOER_Y_NO, LIMIT_UPPOER_Y_TXT);
          put(LIMIT_UPPER_THRESHOLD_Y_NO, LIMIT_UPPER_THRESHOLD_Y_TXT);
          put(LIMIT_LOWER_THRESHOLD_Y_NO, LIMIT_LOWER_THRESHOLD_Y_TXT);
          put(LIMIT_LOWER_Y_NO, LIMIT_LOWER_Y_TXT);
          put(PLOT_SIZE_NO, PLOT_SIZE_TXT);
          put(PLOT_COLOR_NO, PLOT_COLOR_TXT);
          put(PLOT_SELECTED_COLOR_NO, PLOT_SELECTED_COLOR_TXT);
          put(PLOT_OUTSIZE_COLOR_NO, PLOT_OUTSIZE_COLOR_TXT);
          put(PLOT_PROGRESS1_COLOR_NO, PLOT_PROGRESS1_COLOR_TXT);
          put(PLOT_PROGRESS2_COLOR_NO, PLOT_PROGRESS2_COLOR_TXT);
          put(PLOT_PROGRESS3_COLOR_NO, PLOT_PROGRESS3_COLOR_TXT);
          put(PLOT_PROGRESS4_COLOR_NO, PLOT_PROGRESS4_COLOR_TXT);
          put(LINE_PROGRESS1_COLOR_NO, LINE_PROGRESS1_COLOR_TXT);
          put(LINE_PROGRESS2_COLOR_NO, LINE_PROGRESS2_COLOR_TXT);
          put(LINE_PROGRESS3_COLOR_NO, LINE_PROGRESS3_COLOR_TXT);
          put(LINE_PROGRESS4_COLOR_NO, LINE_PROGRESS4_COLOR_TXT);
          put(SERIES_LINE_WIDTH_NO, SERIES_LINE_WIDTH_TXT);
          put(DISTRIBUTION_GRAPH_TOOLTIP1_NO, DISTRIBUTION_GRAPH_TOOLTIP1_TXT);
          put(DISTRIBUTION_GRAPH_TOOLTIP2_NO, DISTRIBUTION_GRAPH_TOOLTIP2_TXT);
          put(DISTRIBUTION_GRAPH_TOOLTIP3_NO, DISTRIBUTION_GRAPH_TOOLTIP3_TXT);
          put(DISTRIBUTION_GRAPH_TOOLTIP4_NO, DISTRIBUTION_GRAPH_TOOLTIP4_TXT);
          put(DISTRIBUTION_GRAPH_TOOLTIP5_NO, DISTRIBUTION_GRAPH_TOOLTIP5_TXT);
          put(DISTRIBUTION_GRAPH_TOOLTIP6_NO, DISTRIBUTION_GRAPH_TOOLTIP6_TXT);
          put(DISTRIBUTION_GRAPH_TOOLTIP7_NO, DISTRIBUTION_GRAPH_TOOLTIP7_TXT);
          put(DISTRIBUTION_GRAPH_TOOLTIP8_NO, DISTRIBUTION_GRAPH_TOOLTIP8_TXT);
          put(DISTRIBUTION_GRAPH_TOOLTIP9_NO, DISTRIBUTION_GRAPH_TOOLTIP9_TXT);
          put(PATIENT_GROUP_AREA1_NO, PATIENT_GROUP_AREA1_TXT);
          put(PATIENT_GROUP_AREA2_NO, PATIENT_GROUP_AREA2_TXT);
          put(PATIENT_GROUP_AREA3_NO, PATIENT_GROUP_AREA3_TXT);
          put(PATIENT_GROUP_AREA4_NO, PATIENT_GROUP_AREA4_TXT);
          put(PATIENT_GROUP_AREA5_NO, PATIENT_GROUP_AREA5_TXT);
          put(PATIENT_GROUP_AREA6_NO, PATIENT_GROUP_AREA6_TXT);
          put(PATIENT_GROUP_AREA7_NO, PATIENT_GROUP_AREA7_TXT);
          put(PATIENT_GROUP_AREA8_NO, PATIENT_GROUP_AREA8_TXT);
          put(PATIENT_GROUP_AREA9_NO, PATIENT_GROUP_AREA9_TXT);
        }
      };
    }
	// add 9200 by kangjie 20230912 start
    public static class FacilitySettingClass{
	  //施設設定番号 3008
      public final static String SETTING_NO_3008 = "3008";
	  //上限はありません
      public final static String VALUE_MINUS_1 = "-1";
    }
    public static class DateClass{
      public final static String END_MAX_DATE = "29991231";
    }
    public static class OrdMainClass {
      public final static String IS_DEL_0 = "0";
      public final static int LEN_8 = 8;
    }
	// add 9200 by kangjie 20230912 end
  }

  /**
  * @Author kangjie
  * @Description 10150_9664[治疗条件KEY]
  * @Date 2024/08/30 15:33
  * @Param
  * @return
  **/
  public static class IndCondKey {
    /**
     * 透析液
     */
    public static final String DIALYZATE_FIVETEEN = "15";
    /**
     * 補液
     */
    public static final String  FLUID_NINETEEN = "19";

    /**
     * 补液使用数
     */
    public static final String FLUID_TWENTY_TWO = "22";
  }

  /**
  * @Author kangjie
  * @Description 10150_9664[编辑TYPE]
  * @Date 2024/08/30 15:34
  * @Param
  * @return
  **/
  public static class EditType {
    /**
     * 已编辑
     */
    public static final String EDITED_ONE = "1";
  }

  /**
   * API返却種別
   */
  public static class ResponseKind {
    /**
     * 競合
     * NOTE : 一意制約違反で、DuplicateKeyExceptionをキャッチした際、フロント側で重複エラーを表示させるために使用する.
     * [AxiosHelper.js]で、Response Code 409は「排他エラー」を表示するため、本フラグが設定されている場合、表示させずに
     * 呼び出し元の画面で独自のメッセージを表示させるために使用するため。
     */
    public static final String CONFLICT_CUSTOM = "CONFLICT_CUSTOM";
  }
}
