package jp.co.nikkiso.ntss.core.constant;

/**
 * NTSS共通定数クラス.
 */
public class CoreConstant {

  /**
   * パッケージ定義.
   */
  public static class NtssPackage {

    /**
     * ntss-core.
     */
    public static final String CORE = "jp.co.nikkiso.ntss.core";

    /**
     * ntss-admin-web.
     */
    public static final String ADMIN_WEB = "jp.co.nikkiso.ntss.admin_web";

    /**
     * ntss-m-notice.
     */
    public static final String M_NOTICE = "jp.co.nikkiso.ntss.m_notice";

    /**
     * ntss-client-comm.
     */
    public static final String CLIENT_COMM = "jp.co.nikkiso.ntss.client_comm";

    /**
     * ntss-monitoring.
     */
    public static final String MONITORING = "jp.co.nikkiso.ntss.monitoring";

    /**
     * ntss-monitoring-config.
     */
    public static final String MONITORING_CONFIG = "jp.co.nikkiso.ntss.monitoring_config";

    /**
     * ntss-device-edge.
     */
    public static final String DEVICE_EDGE = "jp.co.nikkiso.ntss.device_edge";

    /**
     * ntss-device-edge-updater.
     */
    public static final String DEVICE_EDGE_UPDATER = "jp.co.nikkiso.ntss.device_edge_updater";

    /**
     * ntss-device-edge-updater_front.
     * TODO:ntss-admin-webにマージ完了後に削除@TDC
     */
    public static final String DEVICE_EDGE_UPDATER_F = "jp.co.nikkiso.ntss.device_edge_updater_front";

    /**
     * ntss-work-assist.
     */
    public static final String WORK_ASSIST = "jp.co.nikkiso.ntss.work_assist";

    /**
     * ntss-web-api.
     */
    public static final String WEB_API = "jp.co.nikkiso.ntss.web_api";

    /**
     * ntss-alive-moni
     */
    public static final String ALIVE_MONI = "jp.co.nikkiso.ntss.alive_moni";

    /**
     * ntss-alive-moni-auto
     */
    public static final String ALIVE_MONI_AUTO = "jp.co.nikkiso.ntss.alive_moni_auto";

    /**
     * ntss-data-gathering
     */
    public static final String DATA_GATHERING = "jp.co.nikkiso.ntss.data_gathering";

    /**
     * ntss-data-gathering-auto
     */
    public static final String DATA_GATHERING_AUTO = "jp.co.nikkiso.ntss.data_gathering_auto";

    /**
     * ntss-develop-tdc
     * TODO:ntss-admin-webにマージ完了後に削除@TDC
     */
    public static final String TDC_DEV = "jp.co.nikkiso.ntss.dec_dev";
    /**
     * ntss-api.
     */
    public static final String API = "jp.co.nikkiso.ntss.api";

    /**
     * ntss-coop-api.
     */
    public static final String COOP_API = "jp.co.nikkiso.ntss.coop_api";

  }

  /**
   * 日時フォーマット
   */
  public static final class DateTimeFormat {
    /**
     * ISO8601
     */
    public static final String ZONED_DATE_TIME_ISO8601 = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX";

    /**
     * タイムゾーン Asia/Tokyo
     */
    public static final String TIME_ZONE_ASIA_TOKYO = "Asia/Tokyo";
  }

  /**
   * 通信種別.
   */
  public static final class ComType {
    /**
     * 0：通信なし(オフライン運用)
     */
    public static final Integer OFFLINE = 0;
    /**
     * 1：新通信
     */
    public static final Integer NKK_COMM = 1;
    /**
     * 2：NX通信
     */
    public static final Integer NX = 2;
    /**
     * 3：医器工V4
     */
    public static final Integer COMMON_V4 = 3;
  }

  /**
   * 通信フォーマット.
   */
  public static final class ComFormat {

    /**
     * DAB = A.
     */
    public static final String DAB = "A";

    /**
     * DAB = D.
     */
    public static final String DAD = "D";

    /**
     * オフライン = F.
     */
    public static final String OFFLINE = "F";

    /**
     * DCS3 = I.
     */
    public static final String DCS3 = "I";

    /**
     * DRY-50A = I.
     */
    public static final String DRY50A = "I";

    /**
     * DBB3 = J.
     */
    public static final String DBB3 = "J";

    /**
     * DRY-50B = J.
     */
    public static final String DRY50B = "J";

    /**
     * DCG2 = M.
     */
    public static final String DCG2 = "M";

    /**
     * DBG2 = N.
     */
    public static final String DBG2 = "N";

    /**
     * DCS100NX2018 = P.
     */
    public static final String DCS100NX2018 = "P";

    /**
     * DBB100NX2018 = Q;
     */
    public static final String DBB100NX2018 = "Q";

    /**
     * DRO = R.
     */
    public static final String DRO = "R";
    /**
     * 医器工(Ver4.0)（仮)
     */
    public static final String COMMON4 = "V";
    /**
     * 医器工(Ver3.0) (条件送信が一部可能な装置)
     */
    public static final String COMMON3 = "W";
    /**
     * 医器工(Ver2.0) (透析開始終了が拾える装置)
     */
    public static final String COMMON2 = "Y";
    /**
     * 医器工(Ver1.0) (モニタの読み込み可能な装置)
     */
    public static final String COMMON1 = "Z";
    /**
     * V4 通信
     */
    public static final String V4COMMON = "V";
  }

  /**
   * 装置動作記録のデータ種別.
   */
  public static final class MotionRecordDataType {

    /**
     * 装置記録.
     */
    public static final int MACHINE = 1;

    /**
     * 緊急発報記録.
     */
    public static final int M_NOTICE = 2;

    /**
     * 予防保全/故障予知記録.
     */
    public static final int PREVENTIVE = 3;

    /**
     * 自己診断結果.
     */
    public static final int TEST_RESULT = 4;

    /**
     * 溶解記録.
     */
    public static final int DISSOLUTION = 5;

    /**
     * データ収集記録.
     */
    public static final int GATHERINNG = 6;

  }

  /**
   * データ収集ステータス.
   */
  public static final class GatheringStatus {

    /**
     * 一部異常 = -2.
     */
    public static final int SOME_FAULT = -2;

    /**
     * 異常 = -1.
     */
    public static final int FAULT = -1;

    /**
     * 依頼中 = 0.
     */
    public static final int REQUESTING = 0;

    /**
     * 処理中 = 1.
     */
    public static final int IN_PROGRESS = 1;

    /**
     * 転送完了.
     */
    public static final int COMPLETE = 2;

  }

  /**
   * 自己診断種別.
   */
  public static final class TestType {

    /**
     * 配管(UFRC)自己診断 = 1.
     */
    public static final int UFRC = 1;

    /**
     * 漏血自己診断 = 2.
     */
    public static final int BLOOD_LEAKAGE = 2;

    /**
     * 透析液流量自己診断 = 3.
     */
    public static final int DIALYSATE_FLOW_RATE = 3;

    /**
     * 濃度自己診断 = 4.
     */
    public static final int CONCENTRAITION = 4;

    /**
     * 配管テスト = 5.
     */
    public static final int PIPING_TEST = 5;

    /**
     * 希釈テスト = 6.
     */
    public static final int HEMODILUTION_TEST = 6;

  }

  /**
   * 治療状況実績
   */
  public static final class rstDialysisState {
    /**
     * 条件送信前
     */
    public static final String BEFORE_SEND_CONDITIOM = "0";
    /**
     * 条件送信済
     */
    public static final String AFTER_SEND_CONDITIOM = "1";
    /**
     * 条件送信確認済み
     */

    public static final String CHECKED_SEND_CONDITION = "2";
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
    public static final String AFTER_PAST_RECORD = "6";
  }

  /**
   * 死活監視ステータス.
   * @author TDC　H.Yonezawa
   */
  public static final class AliveMoniStatus {

    /**
     * 起動中.
     */
    public static final String RUNNING = "01";

    /**
     * 停止中.
     */
    public static final String STOP = "F0";

    /**
     * 通信異常.
     */
    public static final String CONNECTION_ERROR ="F1";

    /**
     * デバイス異常.
     */
    public static final String DEVICE_ERROR = "F2";

  }

  /**
   * 死活監視メール送信ステータス.
   */
  public static final class AliveMoniSendMailStatus {

    /**
     * 送信済み／送信不要.
     */
    public static final Short NO_SEND = 0;

    /**
     * 異常メール送信必要.
     */
    public static final Short SEND_FAIL_CONNECT = 1;

    /**
     * 復旧メール送信必要.
     */
    public static final Short SEND_RECONNECT = 2;
  }

  /**
   * デバイスエッジ死活監視メール送信対象コード.
   */
  public static final class AliveMoniDeviceEdgeAlarmCode {

    /**
     * デバイスエッジ通信異常.
     */
    public static final String CONNECT_ERROR = "G000";

    /**
     * デバイスエッジ異常.
     */
    public static final String DEVICE_ERROR = "G001";

    /**
     * デバイスエッジファイル数過多.
     */
    public static final String FILES_OVER = "G002";

    /**
     * デバイスエッジ接続USBメモリー故障.
     */
    public static final String FAILED_USB_MEMORY = "G003";

    /**
     * デバイスエッジ接続SDカード故障.
     */
    public static final String FAILED_SD_CARD = "G004";

    /**
     * デバイスエッジ接続復旧.
     */
    public static final String RECONNECT = "G005";
  }

  /**
   *  デバイスエッジ指示内容カテゴリ
   */
  public static final class DeviceEdgeManageConstant {
    public static final class OrderClass {
      /**
       *  ソフト更新指示
       */
      public static final short UPDATE = 0;
      /**
       * レストア
       */
      public static final short RESTORE = 1;
      /**
       * ログ収集命令
       */
      public static final short LOG_GATHER = 2;
      /**
       * NTSSサービス再起動
       */
      public static final short APP_REBOOT = 3;
      /**
       * NTSSサービス停止
       */
      public static final short APP_STOP = 4;
      /**
       * NTSSサービス開始
       */
      public static final short APP_START = 5;
      /**
       * デバイス再起動
       */
      public static final short DEVICE_REBOOT = 6;
      /**
       * 設定収集
       */
      public static final short CONF_GATHER = 7;
      /**
       * 設定適用
       */
      public static final short CONF_UPDATE = 8;
      /**
       * 予定キャンセル
       */
      public static final short PLAN_CANCEL = 9;

      public static final short MAX_CODE_VALUE = 9;
    }

    public static final class orderTarget {
      public static final short APP = 0;
      public static final short UPDATER = 1;
    }

    public static final class ResponseStatus {
      /**
       * -2：異常
       */
      public static final short ERROR = -2;
      /**
      * -1：拒否
      */
      public static final short REJECT = 1;
      /**
       * 0：依頼中（応答なし含む）
       */
      public static final short SEND = 0;
      /**
       * 1：処理中
       */
      public static final short RUN = 1;
      /**
       * 2：完了
       */
      public static final short FINISH = 2;
      /**
       * 3：予約
       */
      public static final short PLAN = 3;
    }
  }

  /**
   * 条件送信系定数
   *
   */
  public static class SendCondition {
    /**
     * 条件送信状況
     *
     */
    public static class WeightScaleClass {
      /**
       * 重量測定済み
       */
      public static final Short MEASURED = 0;
      /**
       * 条件送信指示中
       */
      public static final Short ORDER = 1;
      /**
       * 待機
       */
      public static final Short WAIT = 2;
      /**
       * 送信成功
       */
      public static final Short SEND_OK = 3;
      /**
       * 送信失敗
       */
      public static final Short SEND_NG = 4;

    }
  }

  /**
   * 仮登録クラス.
   */
  public static final class ProvisionalStatus {

    /**
     * 本登録 = 0.
     */
    public static final int NOT_PROVISIONAL = 0;

    /**
     * 仮登録 = 1.
     */
    public static final int PROVISIONAL = 1;
  }

  /**
   * 個人情報取扱い承認クラス
   */
  public static final class ConsentStatus {

    /**
     * 未承認 = 0.
     */
    public static final int NOT_CONSENT = 0;

    /**
     * 承認済 = 1.
     */
    public static final int CONSENT = 1;
  }

  /**
   * マスタ分類クラス.
   */
  public static final class MasterType {

    /**
     * 標準.
     */
    public static final String STANDARD = "1";

    /**
     * モーダル.
     */
    public static final String MODAL = "2";

    /**
     * 個別.
     */
    public static final String SPECIAL = "3";

    /**
     * 日機装.
     */
    public static final String NIKKISO = "4";
  }

  /**
   * 表示区分クラス.
   */
  public static final class DispClass {

    /**
     * 日機装社員のみ表示.
     */
    public static final String NIKKISO_ONLY = "1";

    /**
     * 制限なし（上記以外）.
     */
    public static final String NORMAL = "2";
  }

  /**
   * 表示管理レベルクラス.
   */
  public static final class EditLevel {

    /**
     * 全ユーザ
     */
    public static final String NORMAL = "1";

    /**
     * 管理者のみ表示.
     */
    public static final String ADMIN_ONLY = "2";

    /**
     * 日機装社員のみ表示.
     */
    public static final String NIKKISO_ONLY = "3";

    /**
     * 日機装社員の管理者のみ表示.
     */
    public static final String NIKKISO_ADMIN_ONLY = "4";

  }

  /**
   * ユーザータイプ.
   */
  public static final class UserType {

    /**
     * 日機装社員ユーザー.
     */
    public static final String NIKKISO = "1";

    /**
     * 一般ユーザー.
     */
    public static final String GENERAL = "0";
  }

  /**
   * 管理者フラグ.
   */
  public static final class Administrator {

    /**
     * 管理者ユーザー.
     */
    public static final String ADMIN_USER = "1";

    /**
     * 一般ユーザー.
     */
    public static final String GENERAL_USER = "0";

    // #11205 -ペンテスト2－4認可制御の不備  add 20260325 shiyw start
    /**
     * nkknkk施設CD.
     */
    public static final String NKK_FACILITY_CD = "nkknkk";
    // #11205 -ペンテスト2－4認可制御の不備  add 20260325 shiyw end
  }

  /**
   * 職種・ユーザ追加時に設定する使用機能の初期設定
   */
  public static final String DEFAULT_FUNCTION = "005";

  /**
   * 採択患者ユーザ追加時に設定する使用機能の初期設定
   */
  public static final String DEFAULT_PAT_FUNCTION = "026";

  /**
   * Datasource名.
   */
  public static final class DataSourceName {
    /**
     * 認証DB.
     */
    public static final String AUTH = "authDataSource";
    /**
     * デフォルトDB.
     */
    public static final String DEFAULT = "defaultDataSource";
    /**
     * 個人情報DB.
     */
    public static final String PERSONAL = "personalDataSource";
  }

  /**
   * TransactionManager名.
   */
  public static final class TransactionManagerName {
    /**
     * 認証DB.
     */
    public static final String AUTH = "authTransactionManager";
    /**
     * デフォルトDB.
     */
    public static final String DEFAULT = "defaultTransactionManager";
    /**
     * 個人情報DB.
     */
    public static final String PERSONAL = "personalTransactionManager";
    /**
     * 全DB.
     */
    public static final String ALL = "allTransactionManager";
  }

  /**
   * 施設設定番号.
   */
  public static class FacilitySettingNo {
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
    /**
     * 利用者マスタ-権限変更時サインアウト
     */
    public static final String AUTHORITY_CHANGE_SIGN_OUT = "1064";
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
    /**
     * タイムアウト時間(分)
     */
    public static final String TIME_OUT_MINUTES = "1003";

    /**
     * 透析困難リセット機能
     */
    public static final String DIALYSIS_DIFFICULTY_RESET = "1004";

    /**
     * カード作成機能
     */
    public static final String DISP_CREATE_CARD = "1005";

    /**
     * 検査予定変更機能
     */
    public static final String EXAM_SCHEDULE_CHANGE = "1007";

    /**
     * 放射線検査予定変更機能
     */
    public static final String RAD_SCHEDULE_CHANGE = "1008";

    /**
     * 検査結果取込 項目コード出力先設定
     */
    public static final String SELECT_INHOSPITAL_CD = "1009";

    /**
     * 検査依頼変更締切り日数
     */
    public static final String EXAM_SCHEDULE_CHANGE_LIMIT_DAY = "1011";

    /**
     * 検査依頼変更締切り時間
     */
    public static final String EXAM_SCHEDULE_CHANGE_LIMIT_TIME = "1012";

    /**
     * 放射線検査依頼変更締切り日数
     */
    public static final String RAD_SCHEDULE_CHANGE_LIMIT_DAY = "1013";

    /**
     * 放射線検査依頼変更締切り時間
     */
    public static final String RAD_SCHEDULE_CHANGE_LIMIT_TIME = "1014";

    // add FNSI 1006 No.425 start -- Sanjingye Sun 20210115
    /**
     * 検査依頼変更締切り有無
     */
    public static final String EXAM_CHANGE_ON_OFF_WITH_ORDER = "1015";

    /**
     * 一般撮影検査依頼変更締切り有無
     */
    public static final String RAD_CHANGE_ON_OFF_WITH_ORDER = "1016";
    // add FNSI 1006 No.425 end -- Sanjingye Sun 20210115

    /**
     * 性別未設定時検査項目上下限取得設定
     */
    public static final String PAT_SEX_NON = "1017";
    // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
    /**
     * デフォルトプリンターコード
     */
    public static final String DEFAULT_PRINTER = "1018";
    // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
    /**
     * 感染症検査結果反映時 陽性結果値群
     */
    public static final String INFECT_POSITIVE_RESULT_VALUE_GROUP = "1019";

    /**
     * 感染症検査結果反映時 陰性結果値群
     */
    public static final String INFECT_NEGATIVE_RESULT_VALUE_GROUP = "1020";

    /**
     * 在宅透析患者指示変更のお知らせカテゴリID
     */
    public static final String CHANGE_IND_CATEGORY_ID = "1021";

    /**
     * デフォルト選択医師設定値
     */
    public static final String DEFAULT_SEL_DOCTOR = "1025";

    /**
     * 前体重時車いす測定順序
     */
    public static final String WHEEL_CHAIR_MEASURE_ORDER_MODE_BEFORE = "1026";
    /**
     * 後体重時車いす測定順序
     */
    public static final String WHEEL_CHAIR_MEASURE_ORDER_MODE_AFTER = "1027";

    /**
     * デフォルト手技コード値
     */
    public static final String DEFAULT_PROCEDURE = "1028";

    /**
     * デフォルト投与タイミング値
     */
    public static final String DEFAULT_MEDICATE_TIMING = "1029";

    /**
     * 延長処理開始時刻
     */
    public static final String SCH_EXT_START_TIME = "1031";

    /**
     * 延長処理終了時刻
     */
    public static final String SCH_EXT_END_TIME = "1032";

    /**
     * ログイン方式設定値
     */
    public static final String LOGIN_METHOD_SETTING_NO = "1030";

    /**
     * チェックリスト自動更新間隔 （分）
     */
    public static final String CHECK_LIST_RELOAD_INTERVAL = "1033";

    /**
     * 体重計選択有効化設定
     */
    public static final String ENABLE_WEIGHT_SELECT = "1034";

    /**
     * 空きベッド検索除外予定数
     */
    public static final String MAX_BED_TREAT_COUNT = "1035";

    /**
     * パスワードポリシー適用レベル
     */
    public static final String PASSWORD_POLICY = "1036";

    /**
     * パスワード文字数
     */
    public static final String NUM_OF_PASSWORD = "1037";

   /**
    * ２要素認証
    */
   public static final String TWO_FACTOR_AUTHENTICATION = "1038";

    /**
     * 空きベッド候補切替指示期間(日)
     */
    public static final String BED_SEARCH_RESULT_CHANGE_PERIOD = "1039";

    /**
     * 簡易検索対象条件
     */
    public static final String SIMPLE_SEARCH_CONDITIONS  = "1046";

    /**
     * シェーマ機能スタンプ定型文字
     */
    public static final String IMAGE_EDITOR_STAMP_TEXT_COLLECTION = "1047";

    /**
     * 追加料金
     */
    public static final String ADDITIONAL_FEE  = "1049";

    /**
     * 外部警報1 ON時 メッセージ変更
     */
    public static final String EXTERNAL_ALARM1_ON_MESSAGE_CHANGE  = "1051";

    /**
     * 外部警報2 ON時 メッセージ変更
     */
    public static final String EXTERNAL_ALARM2_ON_MESSAGE_CHANGE  = "1052";

    /**
     * 外部警報3 ON時 メッセージ変更
     */
    public static final String EXTERNAL_ALARM3_ON_MESSAGE_CHANGE  = "1053";

    /**
     * 外部警報4 ON時 メッセージ変更
     */
    public static final String EXTERNAL_ALARM4_ON_MESSAGE_CHANGE  = "1054";

    /**
     * 外部警報1 OFF時 メッセージ変更
     */
    public static final String EXTERNAL_ALARM1_OFF_MESSAGE_CHANGE = "1055";

    /**
     * 外部警報2 OFF時 メッセージ変更
     */
    public static final String EXTERNAL_ALARM2_OFF_MESSAGE_CHANGE = "1056";

    /**
     * 外部警報3 OFF時 メッセージ変更
     */
    public static final String EXTERNAL_ALARM3_OFF_MESSAGE_CHANGE = "1057";

    /**
     * 外部警報4 OFF時 メッセージ変更
     */
    public static final String EXTERNAL_ALARM4_OFF_MESSAGE_CHANGE = "1058";

    /**
     * パスワード有効期間
     */
    public static final String PASSWORD_VALIDITY_PERIOD = "1059";

    /**
     * 過去パスワード再利用禁止
     */
    public static final String PASSWORD_REUSE_PROHIBITED = "1060";

    /**
     * サインイン失敗時のアカウントロック設定
     */
    public static final String ACCOUNT_LOCK_SETTING = "1061";

    /**
     * サインイン失敗許容回数
     */
    public static final String FAILURE_CNT = "1062";

    /**
     * 2要素認証失敗許容回数
     */
    public static final String OTP_FAILURE_CNT = "1063";

    /**
     * 大画面表示のお知らせ内容
     */
    public static final String LARGE_DISP_INFO_KIND = "1065";

    /**
     * 治療状況リスト・治療状況マップ 日付フォーマット
     */
    public static final String STATUS_LIST_MAP_DATE_FORMAT = "1069";

    /**
     * URLサインイン設定
     */
    public static final String URL_SIGNIN = "2001";

    /**
     * URLサインイン秘密鍵
     */
    public static final String URL_SIGNIN_SECRETKEY = "2002";

    /**
     * 治療時間判定時間
     */
    public static final String TREAT_JUDGE_TIME = "2003";

    // add FNSI-終了およびその結果を通知機能で教える 江 start
    /**
     * 検査結果項目
     */
    public static final String CHECK_RESULT_FOR_FACILITY = "3003";
    // add FNSI-終了およびその結果を通知機能で教える 江 end
    // add redmain #4822 鄧シン start
    /**
     * 帳票未指定時のデフォルト帳票
     */
    public static final String DEFAULT_REPORT_TEMPLATE = "3004";
    // add redmain #4822 鄧シン end
    /**
     * add FNSI 1006 No.425 --孙灏 20201215
     * 患者イベント期間の範囲変更機能
     */
    public static final String PAT_EVENT_CHANGE = "3005";

    // #11339 2024.12.04 add 次患者情報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口 start
    /** 医療材料表示順 */
    public static final String EQUIP_DISPLAY_ORDER = "3006";
    /** 投与薬剤表示順 */
    public static final String MEDICINE_DISPLAY_ORDER = "3007";
    // #11339 2024.12.04 add 次患者情報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口 end

    // del #11944 施設設定41(水質管理帳票表示)の用途が違う limingzhe start
//    // add 9210 施設設定マスタのNo41が動作しない。　吉 start
//    public static final String WATER_SURVEY = "1041";
//    // add 9210 施設設定マスタのNo41が動作しない。　吉 end
    // del #11944 施設設定41(水質管理帳票表示)の用途が違う limingzhe end

    // add #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない 20240229 ztc start
    // 抗凝固剤設定のデフォルト指定
    public static final String ANTICOAGULANT_DEFAULT_SETTING = "3115";
    // 抗凝固剤設定の自動計算指定
    public static final String ANTICOAGULANT_AUTO_SETTING = "3116";
    // add #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない 20240229 ztc end
    public static final String REPLENISHER_FILTRATION_SETTING = "3114";

    // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
    // データ種別順ソート設定
    public static final String DATA_KIND_SORT_SETTING = "3131";
    // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end

    /**
     * 体重計モード時強制サインアウトON/OFF
     */
    public static final String FORCE_SIGN_OUT_IN_WEIGHT_MODE = "3133";

    /**
     * Aspose.cellsプラグインを使用するかどうかを指定する
     */
    // del 9316 施設設定マスタ125番の削除について　吉 start
//    public static final String PREVIEW_MODE = "3121";
    // del 9316 施設設定マスタ125番の削除について　吉 end

    // #11827 2025.05.14 add 仮想端末姓名結合設定 TDC米沢 start
    // 仮想端末姓名結合設定
    public static final String VIRTUAL_TERMINAL_NAME_CONCAT_SETTING = "3134";
    // #11827 2025.05.14 add 仮想端末姓名結合設定 TDC米沢 end

    // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
    // 固定項目 -> 治療経過表
    public static final String FIXED_DIALYSIS_REPORT_SETTING = "3135";
    // 固定項目 -> 治療経過表（手書き）
    public static final String FIXED_DIALYSIS_REPORT_HANDWRITTEN_SETTING = "3136";
    // 固定項目 -> 日常点検記録簿
    public static final String FIXED_DAILY_INSPECT_RECORD_BOOK_SETTING = "3137";
    // 固定項目 -> 定期点検（記録簿・交換部品記録簿）
    public static final String FIXED_PERIODIC_INSPECT_RECORD_BOOK_SETTING = "3138";
    // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

    // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
    // 固定項目 -> 水質管理記録簿
    public static final String FIXED_WATER_SURVEY_RECORD_BOOK_SETTING = "3141";
    // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end

    /**
     * 体重計モード測定記録ボタン表示/非表示を設定
     */
    public static final String WEIGHT_MODE_MEASURE_HISTORY_BUTTON_DISPLAY = "3139";

    /**
     * サインインIF表示設定
     */
    public static final String IS_SIGNIN_DISP = "3144";

    /**
     * 系列施設対応
     */
    public static final String AFFILIATED_FACILITIES="4001";

    /* #11987 2026.03.22 add スケールベッド対応 ケールベッド患者切り替えタイミング設定値 TDC渡辺 start */
    /**
     * スケールベッド患者切り替えタイミング
     */
    public static final String SCALE_BED_PAT_CHANGE_TIMING = "3146";
    /* #11987 2026.03.22 add スケールベッド対応 ケールベッド患者切り替えタイミング設定値 TDC渡辺 end */
  }

  /**
   * 装置モニタデータのデータ種別.
   */
  public static class MniMonitorDataType {

    /**
     * モニタデータ種別（不明）.
     */
    public static final Short MONITOR_DATA_TYPE_UNKNOWN = 0;

    /**
     * モニタデータ種別（モニタ）.
     */
    public static final Short MONITOR_DATA_TYPE_MONITOR = 1;

    /**
     * モニタデータ種別（透析中血圧）.
     */
    public static final Short MONITOR_DATA_TYPE_DIALYSIS_BP = 2;

    /**
     * モニタデータ種別（再循環率）.
     */
    public static final Short MONITOR_DATA_TYPE_RECIRCULATION_RATE = 3;

    /**
     * モニタデータ種別（体重測定）
     */
    public static final Short MONITOR_DATA_TYPE_TEMPERATURE = 4;

    /**
     * モニタデータ種別（透析前血圧）
     */
    public static final Short MONITOR_DATA_TYPE_BEFORE_BP = 5;

    /**
     * モニタデータ種別（透析後血圧）
     */
    public static final Short MONITOR_DATA_TYPE_AFTER_BP = 6;

  }

  /**
   * バッチ稼働状況管理番号.
   */
  public static class MntBatchManagerCtlNo {
    /**
     * 入外区分更新
     */
    public static final Integer CTL_NO_IN_OUT_STATE_UPDATE = 1;

    /**
     * スケジュール自動延長
     */
    public static final Integer CTL_NO_SCHEDULE_EXTEND = 2;

    /**
     * ログイン無効化
     */
    public static final Integer CTL_NO_STOP_LOGIN = 3;

    /**
     * 期間外削除実行
     */
    public static final Integer CTL_NO_DELETE_FACILITY = 4;

    /**
     * 検査結果再計算
     */
    public static final Integer CTL_NO_RECALCULATION = 5;

  }

  /**
   * 通知定義コード.
   */
  public static class NotificationDefinition {

    // add FNSI-重要通知設定の追加 江 start
    public static final Long Maker_Notice = 0L;
    // add FNSI-重要通知設定の追加 江 end

    /**
     * 新規患者登録通知
     */
    public static final Long CREATE_PAT = 1L;

    /**
     * ジャーナルAPI通知
     */
    // modify 9583 by kangjie 20240410 start
//    public static final Long CREATE_JOURNAL = 2L;
    // modify 9583 by kangjie 20240410 start

    /**
     * 感染症患者ON通知
     */
    public static final Long REGISTER_INFECT_PAT = 3L;

    /**
     * 感染症(＋)に変更通知
     */
    public static final Long CHANGE_INFECT_POSITIVE = 4L;

    /**
     * 禁忌・ｱﾚﾙｷﾞｰ追加・更新・削除通知
     */
    public static final Long UPDATE_TABOO_ALLERGY = 5L;

    /**
     * 転入通知
     */
    public static final Long MOVE_IN = 6L;

    /**
     * 転出通知
     */
    public static final Long MOVING_OUT = 7L;

    /**
     * 一時転出通知
     */
    public static final Long TEMPORARILY_MOVING_OUT = 8L;

    /**
     * 離脱通知
     */
    public static final Long WITHDRAWAL = 9L;

    /**
     * 移植通知
     */
    public static final Long IMPLANTATION = 10L;

    /**
     * 死亡通知
     */
    public static final Long DEATH = 11L;

    /**
     * DW追加通知
     */
    public static final Long ADD_DW = 12L;

    /**
     * 在宅患者ON通知
     */
    public static final Long REGISTER_HOME_DIALYSIS_PAT = 13L;

    /**
     * 患者グループ通知
     */
    public static final Long ADD_PAT_GROUP = 14L;

    /**
     * 患者情報共有受理側通知
     */
    public static final Long PAT_INFO_SHARE_ACCEPT = 15L;

    /**
     * 担当者に設定通知
     */
    public static final Long SET_CHARGE_STAFF = 16L;

    /**
     * ホスト報知
     */
    public static final Long HOST_NOTIFY = 17L;

    /**
     * 条件送信失敗通知
     */
    public static final Long SEND_COND_NG = 18L;

    /**
     * 投薬タイミング通知
     */
    public static final Long MEDICINE_TYMING = 19L;

    /**
     * ？？？？患者発生通知
     */
    public static final Long UNREGISTERED_PAT = 20L;

    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
    /**
     * 連携受信通知
     */
    // modify 9583 by kangjie 20240410 start
//    public static final Long COOP_JOURNAL_RECEIVE = 21L;
    // modify 9583 by kangjie 20240410 end

    /**
     * 初回指示・浄化申込連携通知
     */
    public static final Long COOP_JOURNAL_INI_DIAL = 22L;

    /**
     * 患者情報連携通知
     */
    public static final Long COOP_JOURNAL_PROFILE = 23L;

    /**
     * 定時連携送信通知notification_no:20→24
     */
    // modify 9583 by kangjie 20240410 start
//    public static final Long COOP_JOURNAL_SEND_TIME = 24L;
    // modify 9583 by kangjie 20240410 end
    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

    // add FNSI-検査結果通知 関 start
    /**
     * 検査結果notification_no:18→25
     */
    public static final Long EXAM_RECORD = 25L;
    // add FNSI-検査結果通知 関 end

    // add FNSI-終了およびその結果を通知機能で教える 江 start
    /**
     * 検査結果notification_no:19→26
     */
    public static final Long EXAM_RECORD_ReadFile = 26L;
    // add FNSI-終了およびその結果を通知機能で教える 江 end

    // add FNSI-終了およびその結果を通知機能で教える 江 start
    /**
     * 画面遷移時通知既読
     */
    public static final Long SETTING_IDENTIFIER_READ_ON_JUMP = 27L;
    // add FNSI-終了およびその結果を通知機能で教える 江 end

    // add 9583 by kangjie 20240401 start 通知一覧の連携エラー通知の遷移不正
    // 連携エラー通知
    public static final Long COOP_JOURNAL_ERROR = 28L;
    // add 9583 by kangjie 20240401 end 通知一覧の連携エラー通知の遷移不正

    /**
     * サインイン時クール未登録チェック通知
     */
    public static final Long NOTIFY_KUR_NOT_SET = 29L;

    /**
     * サインイン時ベッド未登録チェック通知
     */
    public static final Long NOTIFY_BED_NOT_SET = 30L;

    /**
     * 回診記録通知
     */
    public static final Long ADD_ROUNDS_INFO = 31L;

    /**
     * 掲示板施設カレンダー(施設イベント)
     */
    public static final Long ADD_FACILTY_EVENT = 32L;

    /**
     * 患者イベント
     */
    public static final Long ADD_PAT_EVENT = 33L;

    /**
     * ナースコール
     */
    public static final Long NURSE_CALL = 34L;

    /**
     * 申込完了
     */
    public static final Long APPLICATION_COMPLETED = 35L;

    /**
     * 治療中指示変更通知
     */
    public static final Long INDICATION_CHANGE_IN_TREATMENT = 36L;

    // add FNSI-redmine#4081「帳票印刷失敗通知の動作不正」対応 江 start
    /**
     * 帳票印刷失敗通知
     */
    public static final Long PRINT_FAIL = 37L;
    // add FNSI-redmine#4081「帳票印刷失敗通知の動作不正」対応 江 end

    /**
     * 日次処理時指示内容変更通知
     */
    public static final Long INDICATION_CHANGE_IN_DAILY_PROC = 38L;
  }

  /**
   * 外部警報の装置記録コード.
   */
  public static class ExternalAlarmCode {
    /**
     * 外部警報1ON.
     */
    public static final String EXTERNAL_ALARM_1_ON  = "AF90";
    /**
     * 外部警報2ON.
     */
    public static final String EXTERNAL_ALARM_2_ON  = "AF91";
    /**
     * 外部警報3ON.
     */
    public static final String EXTERNAL_ALARM_3_ON  = "AF92";
    /**
     * 外部警報4ON.
     */
    public static final String EXTERNAL_ALARM_4_ON  = "AF93";
    /**
     * 外部警報1OFF.
     */
    public static final String EXTERNAL_ALARM_1_OFF = "AF94";
    /**
     * 外部警報2OFF.
     */
    public static final String EXTERNAL_ALARM_2_OFF = "AF95";
    /**
     * 外部警報3OFF.
     */
    public static final String EXTERNAL_ALARM_3_OFF = "AF96";
    /**
     * 外部警報4OFF.
     */
    public static final String EXTERNAL_ALARM_4_OFF = "AF97";
  }

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
     * イベントログ
     */
    public static final Integer EVENT_LOGGING = 28;
    /**
     * 施設追加時に登録するデフォルト帳票配置パス
     */
    public static final Integer DEFAULT_REPORT_PATH = 38;
    /**
     * 帳票配置パス
     */
    public static final Integer REPORT_PATH = 39;
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

    // #11987 2026.03.24 add スケールベッドアプリのTRACEログアップロード TDC伊東 start
    /**
     * スケールベッドアプリケーションログ出力先
     */
    public static final Integer NKKSCALEBED_LOG_OUTPUT_PATH = 1014;
    // #11987 2026.03.24 add スケールベッドアプリのTRACEログアップロード TDC伊東 end
  }

  /**
   * システム利用設定クラス.
   */
  public static class SystemUseSettings {
    /**
     * ReMSのみ
     */
    public static final String REMS_ONLY = "1";
    /**
     * FNSiのみ
     */
    public static final String FNSI_ONLY = "2";
    /**
     * FNSi+ReMS
     */
    public static final String FNSI_REMS = "3";
  }

  /**
   * 日機装フラグクラス.
   */
  public static class IsNkkFlg {
    /**
     * 全施設向け
     */
    public static final String ALL_FACILITIES = "0";
    /**
     * 日機装施設のみ
     */
    public static final String NKK_ONLY = "1";
  }

  /**
   * システム利用設定区分.
   */
  public static class SystemUseDisp {
    /**
     * 全施設向け
     */
    public static final String FNSI_REMS = "0";
    /**
     * ReMSが含まれる施設
     */
    public static final String INCLUDE_REMS = "1";
    /**
     * FNSiが含まれる施設
     */
    public static final String INCLUDE_FNSI = "2";
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
   * MONGODB
   */
  public static class MongoDbConfig {
    /**
     * mongodb接続タイムアウト
     */
    public static final Integer CONNECT_TIME_OUT = 3000;
  }
  // add #7880 帳票：ラベルが正しく表示されない 姜 start
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
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String PATIENT_COOL = "クール順";
    public static final String PATIENT_COOL = "クール表示順";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    /**
     * フリガナ
     */
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String READING = "フリガナ";
    public static final String READING = "患者名";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    /**
     * 患者グループ名
     */
    public static final String PATIENT_GROUP_NAME = "患者グループ名";
    /**
     * ベッドグループ名
     */
    public static final String BED_GROUP_NAME = "ベッドグループ";
    /**
     * ベッド名
     */
    public static final String BED_NAME = "ベッド表示順";
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
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 start
//    public static final String MEDICINE_EQUIPMENT_CODE = "医材/薬剤";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String MEDICINE_EQUIPMENT_CODE = "データ種別順";
    public static final String MEDICINE_EQUIPMENT_CODE = "データ種別表示順";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 end
    // add #12032 配布リスト（物品）の並び順に「データ分類」がない 高　start
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String MEDICINE_EQUIPMENT_DATA_GROUP = "治療条件順";
    public static final String MEDICINE_EQUIPMENT_DATA_GROUP = "治療条件";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    // add #12032 配布リスト（物品）の並び順に「データ分類」がない 高　end
    /**
     * 分類名称
     */
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 start
//    public static final String MEDICINE_EQUIPMENT_CLASS = "分類順";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String MEDICINE_EQUIPMENT_CLASS = "分類名称順";
    public static final String MEDICINE_EQUIPMENT_CLASS = "分類名称表示順";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 end
    /**
     * 名称
     */
    // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//    public static final String MEDICINE_EQUIPMENT_NAME = "名称表示順";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String MEDICINE_EQUIPMENT_NAME = "名称順";
    public static final String MEDICINE_EQUIPMENT_NAME = "名称";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

    // add #9323 donghao start
    /**
     * 名称
     */
    public static final String EQUIPMENT_MEDICINE_NAME = "名称";
    /**
     * 分類名称
     */
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 start
//    public static final String EQUIPMENT_MEDICINE_CLASS = "分類名称";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String EQUIPMENT_MEDICINE_CLASS = "分類名称順";
    public static final String EQUIPMENT_MEDICINE_CLASS = "分類名称表示順";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 end
    // add #9323 donghao start

    /**
     * 透析日
     */
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//    public static final String DIALYSIS_DAY = "透析日";
    public static final String DIALYSIS_DAY = "治療日";
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end

    // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
    public static final String TREATMENT_DATE = "治療日";
    // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    /**
     * 透析室グループ
     */
    // mod #7880 帳票：ラベルが正しく表示されない 姜 start
    // public static final String DIALYSIS_ROOM_GROUP = "透析室グループ表示順";
    public static final String DIALYSIS_ROOM_GROUP = "透析室表示順";
    // mod #7880 帳票：ラベルが正しく表示されない 姜 end
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String DIALYSIS_ROOM_GROUP1 = "透析室";
    public static final String DIALYSIS_ROOM_GROUP1 = "透析室表示順";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    /**
     * ベッドグループ
     */
    public static final String ROOM_BED_GROUP = "ベッドグループ表示順";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String ROOM_BED_GROUP1 = "ベッドグループ";
    public static final String ROOM_BED_GROUP1 = "ベッドグループ表示順";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    /**
     * 患者グループ名
     */
    public static final String PATIENT_GROUP = "患者グループ表示順";
    /**
     * 装置名称
     */
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//    public static final String MACHINE_NAME = "装置名称";
    public static final String MACHINE_NAME = "装置表示順";
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    /**
     * 装置番号
     */
    public static final String MACHINE_NO = "装置番号";
    /**
     * 製造番号
     */
    public static final String MACHINE_SERIAL = "製造番号";
    /**
     * 型式名
     */
    public static final String MACHINE_TYPE = "型式名";
    // add 8565 複数患者帳票に並び替えキーに不足あり 姜 start
    /**
     * 終了予定
     */
    public static final String IND_END_DATE = "終了予定";
    /**
     * 終了予測
     */
    public static final String IND_END_DATE_TIME = "終了予測";
    /**
     * 透析開始
     */
    public static final String RST_START_DATE = "透析開始";
    /**
     * 透析終了
     */
    public static final String RST_END_DATE = "透析終了";
    // add 8565 複数患者帳票に並び替えキーに不足あり 姜 end
  }
  // add #7880 帳票：ラベルが正しく表示されない 姜 end

  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
  /**
   * 固定帳票ID
   */
  public static class FixedReportCd {
    /**
     * 治療経過表
     */
    public static final Long DIALYSIS_REPORT = -3l;

    /**
     * 治療経過表（手書き）
     */
    public static final Long DIALYSIS_REPORT_HANDWRITTEN = -4l;

    /**
     * 日常点検記録簿
     */
    public static final Long DAILY_INSPECT_RECORD_BOOK = -5l;

    /**
     * 定期点検（記録簿・交換部品記録簿）
     */
    public static final Long PERIODIC_INSPECT_RECORD_BOOK = -6l;

    // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
    /**
     * 水質管理記録簿
     */
    public static final Long WATER_SURVEY_RECORD_BOOK = -7l;
    // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
  }
  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

  /**
   * 検査再計算依頼ステータス
   */
  public static class ExamRecalcStatus {
    /**
     * 未処理 = 0.
     */
    public static final String UNPROGRESS = "0";

    /**
     * 処理完了 = 2.
     */
    public static final String PROGRESS_COMPLETE = "2";

    /**
     * 処理中断 = 4.
     */
    public static final String PROGRESS_PAUSE = "4";

    /**
     * 中止 = 9
     */
    public static final String PROGRESS_STOPED = "9";
  }

  /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --start */
  /**
   * Japanese prefix for name
   */
  public static class NamePrefixJapan {

    /**
     * 禁忌
     */
    public static final String TABOO = "【禁忌】";

    /**
     * ｱﾚﾙｷﾞｰ
     */
    public static final String ALLERGY = "【ｱﾚﾙｷﾞｰ】";

    /**
     * 禁忌 and ｱﾚﾙｷﾞｰ
     */
    public static final String TABOO_AND_ALLERGY = "【禁忌・ｱﾚﾙｷﾞｰ】";

    /**
     * 分類不一致
     */
    public static final String INCONSISTENT_CLASSIFICATION = "【分類不一致】";

    /**
     * 期限切れ
     */
    public static final String EXPIRED = "【期限切れ】";

    /**
     * 削除済み
     */
    public static final String DELETED = "【削除済み】";

    /**
     * 削除済み含む
     */
    public static final String INCLUDE_DELETED = "【削除済み含む】";

  }
  /* add by chamaojia 2024-06-07 [10754] 接頭文字対応 --end */

  /* add by chamaojia 2024-10-11 [11140] healthmon_facility_conn Add constant definitions in JSON --start */
  /**
   * mnt_if_edge_healthmon  -> healthmon_facility_conn
   */
  public static class HealthmonFctJson {
    /**
     * 業務用
     */
    public static final String BUSINESS_HEADER = "edge_b";

    /**
     * 管理用
     */
    public static final String MANAGER_HEADER = "edge_m";
  }
  /* add by chamaojia 2024-10-11 [11140] healthmon_facility_conn Add constant definitions in JSON --end */
}
