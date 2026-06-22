package jp.co.nikkiso.ntss.device_edge_updater.service;

public class LogMessage {
  public static final String WARN_NO_STREAM = "入力ストリームがありません。";
  public static final String ERROR_CLOSE_STREAM = "ストリームのクローズ処理でエラーが発生しました";
  public static final String ERROR_DB_PUSH_API = "受信ファイルのDB書き込みで想定外のエラーが発生しました";
  public static final String ERROR_TELEGRAM_STREAM = "ストリームからの電文取得に失敗しました。";
  public static final String ERROR_DECODE_TELEGRAM = "電文の文字列化に失敗しました。";
  public static final String WARN_KIND_UNDEFINED = "未定義のデータ種別です。";
  public static final String ERROR_UPDATE_ALIVEMONI = "デバイスエッジ死活状態更新に失敗しました。";
  public static final String WARN_UPDATE_ALIVEMONI = "デバイスエッジ死活状態更新対象がありませんでした。";
  public static final String ERROR_INSERT_MONITOR = "モニタデータ記録に失敗しました。";
  public static final String WARN_INSERT_MONITOR = "モニタデータが正常に記録できませんでした。";
  public static final String ERROR_INSERT_MOTION_LOG = "装置記録の保存に失敗しました。";
  public static final String WARN_INSERT_MOTION_LOG = "装置記録が正常に記録できませんでした。";
  public static final String ERROR_INSERT_MOTION_MNT = "メンテナンスデータの保存に失敗しました。";
  public static final String WARN_INSERT_MOTION_MNT = "メンテナンスデータが正常に記録できませんでした。";
  public static final String ERROR_INSERT_MOTION_DAR = "溶解記録の保存に失敗しました。";
  public static final String WARN_INSERT_MOTION_DAR = "溶解記録が正常に記録できませんでした。";
  public static final String ERROR_INSERT_MOTION_USE_TIME = "稼働時間の保存に失敗しました。";
  public static final String WARN_INSERT_MOTION_USE_TIME = "稼働時間が正常に記録できませんでした。";
  public static final String ERROR_DATE_FORMAT = "日付文字列の変換に失敗しました。";
}
