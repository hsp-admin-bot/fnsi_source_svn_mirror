package jp.co.nikkiso.ntss.m_notice.constant;

/**
 * ntss-m-noticeのメッセージ定数クラス.
 */
public class MNoticeMessageConstant {

  /**
   * 備考欄出力エラーメッセージ定義.
   */
  public static final class Remarks {

    /**
     * 電文エラー.
     */
    public static final String TELEGRAM = "電文エラー:%1$s:[受信データ:%2$s]";

    /**
     * 電文長エラー.
     */
    public static final String TELEGRAM_LENGTH = "電文長エラー:[受信データ:%s]";

    /**
     * 通信種別エラー.
     */
    public static final String COM_TYPE = "通信種別エラー:[受信データ:%s]";

    /**
     * 緊急発報マスタ:レコードなし.
     */
    public static final String MST_M_NOTICE_RECORD = "取得できませんでした:緊急発報マスタにレコードなし:[facility_cd:%s]、[machine_record_cd:%s]";

    /**
     * 緊急発報マスタ:項目の値なし.
     */
    public static final String MST_M_NOTICE_VALUE = "取得できませんでした:緊急発報マスタに項目の値なし:[facility_cd:%s]、[machine_record_cd:%s]";

    /**
     * 施設マスタ:レコードなし
     */
    public static final String MST_FACILITY_RECORD = "取得できませんでした:施設マスタにレコードなし:[facility_cd:%s]";

    /**
     * 施設マスタ:項目の値なし
     */
    public static final String MST_FACILITY_VALUE = "取得できませんでした:施設マスタに項目の値なし:[facility_cd:%s]";

    /**
     * システム設定:レコードなし.
     */
    public static final String SYS_SYSTEM_DEFINE_RECORD = "取得できませんでした:システム設定にレコードなし:[ctl_no:1][facility_cd:all][service_cd:000]";

    /**
     * システム設定:項目の値なし.
     */
    public static final String SYS_SYSTEM_DEFINE_VALUE = "取得できませんでした:システム設定に項目の値なし:[ctl_no:1][facility_cd:all][service_cd:000]";

    /**
     * 型式マスタ:レコードなし.
     */
    public static final String MST_MACHINE_TYPE_RECORD = "取得できませんでした:型式マスタにレコードなし:[machine_type_cd:%s]";

    /**
     * 型式マスタ:項目の値なし.
     */
    public static final String MST_MACHINE_TYPE_VALUE = "取得できませんでした:型式マスタに項目の値なし:[machine_type_cd:%s]";

    /**
     * 装置マスタ:レコードなし.
     */
    public static final String MST_MACHINE_RECORD = "取得できませんでした:装置マスタにレコードなし:[machine_type:%s]、[machine_serial:%s]、[facility_cd:%s]";

    /**
     * 装置マスタ:項目の値なし.
     */
    public static final String MST_MACHINE_VALUE = "取得できませんでした:装置マスタに項目の値なし:[machine_type:%s]、[machine_serial:%s]、[facility_cd:%s]";

    /**
     * 宛先グループマスタ:レコードなし.
     */
    public static final String MST_ADDRESS_GROUP_RECORD = "取得できませんでした:宛先グループマスタにレコードなし:[address_group_cd:%s]";

    /**
     * 利用者マスタ:レコードなし.
     */
    public static final String MST_USER_RECORD = "取得できませんでした:利用者マスタにレコードなし:[user_cd:%s]";

    /**
     * デバイスエッジマスタ:レコードなし.
     */
    public static final String MST_DEVICE_EDGE_RECORD = "取得できませんでした:デバイスエッジマスタにレコードなし:[device_edge_no:%s]、[facility_cd:%s]";

    /**
     * 装置状態管理:レコードなし.
     */
    public static final String MNT_MACHINE_STATE_RECORD = "取得できませんでした:装置状態管理にレコードなし:[facility_cd:%s]、[machineTypeCd:%s]、[machineSerial:%s]";

  }

  /**
   * nullまたは空白時のログ出力メッセージ定義.
   */
  public static class NullEmptyMessage {

    /**
     * ベースメッセージ.
     */
    public static final String NULL_EMPTY_FORMAT = "%sがヌルまたは空白です。";

    /**
     * 型式コード.
     */
    public static final String MODEL_CODE = String.format(NULL_EMPTY_FORMAT, "型式コード");

    /**
     * 製造番号.
     */
    public static final String SERIAL_NUMBER = String.format(NULL_EMPTY_FORMAT, "製造番号");

    /**
     * 施設コード.
     */
    public static final String FACILITY_CODE = String.format(NULL_EMPTY_FORMAT, "施設コード");

    /**
     * 発生日付.
     */
    public static final String OCCURRENCE_DATE = String.format(NULL_EMPTY_FORMAT, "発生日付");

    /**
     * 発生時刻.
     */
    public static final String OCCURRENCE_TIME = String.format(NULL_EMPTY_FORMAT, "発生時刻");

    /**
     * 発生日時.
     */
    public static final String OCCURRENCE_DATETIME = String.format(NULL_EMPTY_FORMAT, "発生日時");

    /**
     * 装置記録コード.
     */
    public static final String RECORDING_CODE = String.format(NULL_EMPTY_FORMAT, "装置記録コード");

    /**
     * 装置記録メッセージ.
     */
    public static final String RECORDING_MESSAGE = String.format(NULL_EMPTY_FORMAT, "装置記録メッセージ");

    /**
     * 装置記録補助データ1.
     */
    public static final String RECORDING_DATA1 = String.format(NULL_EMPTY_FORMAT, "装置記録補助データ1");

    /**
     * 装置記録補助データ2.
     */
    public static final String RECORDING_DATA2 = String.format(NULL_EMPTY_FORMAT, "装置記録補助データ2");

    /**
     * 装置記録補助データ3.
     */
    public static final String RECORDING_DATA3 = String.format(NULL_EMPTY_FORMAT, "装置記録補助データ3");

    /**
     * 装置記録補助データ4.
     */
    public static final String RECORDING_DATA4 = String.format(NULL_EMPTY_FORMAT, "装置記録補助データ4");

    /**
     * チェックサム.
     */
    public static final String CHECK_SUM = String.format(NULL_EMPTY_FORMAT, "チェックサム");

    /**
     * デバイスエッジ番号.
     */
    public static final String DEVICE_EDGE_NUMBER = String.format(NULL_EMPTY_FORMAT, "デバイスエッジ番号");

    /**
     * 電文.
     */
    public static final String TELEGRAM = "電文が取得できていません。";

  }

  /**
   * エラー時のログ出力メッセージ定義.
   */
  public static class MNoticeError {

    /**
     * 電文-通信種別の整合性エラー.
     */
    public static final String COM_TYPE_NOT_MATCH_DATA = "電文データと通信種別の整合性が一致しません。";

    /**
     * チェックディジットエラー.
     */
    public static final String CHECK_DIGIT = "チェックディジットに誤りがあります。";

    /**
     * メール送信時エラー.
     */
    public static final String SEND_MAIL = "メール送信時にエラーが発生しました。";

    /**
     * 緊急発報マスタ取得エラー.
     */
    public static final String GET_MST_M_NOTICE = "該当する施設コードと装置記録コードのデータがなかったため、緊急発報マスタを取得できませんでした。";

    /**
     * 施設マスタ取得エラー.
     */
    public static final String GET_MST_FACILITY = "該当する施設コードのデータがなかったため、施設マスタを取得できませんでした。";

    /**
     * 型式マスタ取得エラー.
     */
    public static final String GET_MST_MACHINE_TYPE = "該当する型式コードのデータがなかったため、型式マスタを取得できませんでした。";

    /**
     * 装置マスタ取得エラー.
     */
    public static final String GET_MST_MACHINE = "該当する型式コード、製造番号、施設コードに該当するデータがなかったため、装置マスタを取得できませんでした。";

    /**
     * 装置名取得エラー.
     */
    public static final String GET_MACHINE_NAME = "装置名が取得できませんでした。";

    /**
     * 装置記録メッセージ取得エラー.
     */
    public static final String GET_MACHINE_RECORD_MESSAGE = "該当のレコードに装置記録メッセージのデータがなかったため、装置記録メッセージを取得できませんでした。";

    /**
     * 宛先グループマスタ取得エラー.
     */
    public static final String GET_MST_ADDRESS_GROUP = "宛先グループコードに該当するデータがなかったため、宛先グループマスタを取得できませんでした。";

    /**
     * 利用者マスタ取得エラー.
     */
    public static final String GET_MST_USER = "利用者コードに該当するデータがなかったため、利用者マスタを取得できませんでした。";

    /**
     * システム設定データ取得エラー.
     */
    public static final String GET_SYS_SYSTEM_DEFINE = "システム設定データを取得できませんでした。";

    /**
     * イベント発生日時取得エラー.
     */
    public static final String GET_EVENT_REG_DATE = "イベント発生日時を取得できませんでした。";

    /**
     * デフォルトメールテンプレート取得エラー.
     */
    public static final String GET_DEFAULT_MAIL_TEMPLATE = "システム設定マスタに該当のデータがなかったため、デフォルトメールテンプレートを取得できませんでした。";

    /**
     * デバイスエッジマスタ取得エラー.
     */
    public static final String GET_MST_DEVICE_EDGE = "該当する施設コード及びデバイスエッジ番号のデータがなかったため、デバイスエッジマスタを取得できませんでした。";

    /**
     * 装置状態管理取得エラー.
     */
    public static final String GET_MNT_MACHINE_STATE = "該当する施設コード及び型式コード及び製造番号のデータがなかったため、装置状態管理を取得できませんでした。";

  }

  /**
   * 緊急発報ステータス
   */
  public static final class MNoticeStatus {

    /**
     * 異常
     */
    public static final Integer FAULT = -1;

    /**
     * メール送信待ち
     */
    public static final Integer WAIT_SEND_MAIL = 0;

    /**
     * メール送信済
     */
    public static final Integer SEND_MAIL = 1;

    /**
     * メール送信対象なし
     */
    public static final Integer NO_MAIL = 2;

    /**
     * メール送信スキップ
     */
    public static final Integer SKIP = 9;
  }

}
