package jp.co.nikkiso.ntss.device_edge.service.sms;

/**
 * SMS通知機能設定取得サービス
 */
public interface SmsService {

  /**
   * 送信先施設内の警報通知マスタ主キーのリストを文字列連結して返す
   * @param destinationFacilityCd 送信先施設コード
   * @param separator 文字列連結で使用するセパレータ
   */
  String buildNotificationCdList(String destinationFacilityCd, String separator);
  /**
   * 特定の主キーから取得した警報通知マスタの情報を整形して返す
   * @param notificationCd
   * @return
   */
  String buildNotificationConfig(Long alarmNotificationCd);
}
