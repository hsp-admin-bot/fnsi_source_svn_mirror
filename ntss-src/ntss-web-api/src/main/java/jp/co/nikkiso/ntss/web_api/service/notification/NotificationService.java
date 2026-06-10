package jp.co.nikkiso.ntss.web_api.service.notification;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.MntNotificationMessage;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.web_api.request.RecipientsRequest;
import lombok.Data;

/**
 * 通知系のServiceインタフェース.
 */
public interface NotificationService {

  /**
   * 指定のユーザの、指定の共通設定タブの個人設定値を取得します.
   * 移植元: jp.co.nikkiso.ntss.admin_web.service.userSettings.UserSettingsService.getPersonalSettings
   * @param userId ユーザーID
   * @param tabDefineCd 共通設定タブ定義コード
   * @return 設定項目と設定値情報
   * @throws NotExistException ユーザーIDに該当するレコードが存在しない場合
   */
  List<MstUser.SettingValue> getPersonalSettings(Long userId, Integer tabDefineCd) throws NotExistException;

  // Add By HandsomeLin At 2023/02/16 Start
  // #6174
  Map<Long, List<MstUser.SettingValue>> getPersonalSettingsByUserIds(List<Long> userIds, Integer tabDefineCd) throws NotExistException;

  Map<Long, List<MstUser.SettingValue>> getPersonalSettingsByFacilityCdList(List<String> facilityCdList, Integer tabDefineCd) throws NotExistException;

  Map<Long, List<MstUser.SettingValue>> getAllPersonalSettings(Integer tabDefineCd) throws NotExistException;
  // Add By HandsomeLin At 2023/02/16 End

  /**
   * 通知メッセージを登録します.
   * 移植元: jp.co.nikkiso.ntss.admin_web.service.notificationMessage.notificationMessageService
   *
   * @param content        メッセージ本文
   * @param recipients ユーザIDと施設コードの組み合わせ情報
   * @param additionalInfo 付加情報
   * @param facilityCd 施設コード
   * @return 登録した通知メッセージ番号
   */
  //mod FNSI-重要通知設定の追加 江 start
  //Long registerNotificationMessage(String content, List<RecipientsRequest> recipients, String additionalInfo, String facilityCd);
  Long registerNotificationMessage(String content, List<RecipientsRequest> recipients, String additionalInfo, String facilityCd, Long notificationNo);
  //mod FNSI-重要通知設定の追加 江 end

  // Add By HandsomeLin At 2023/02/16 Start
  // #6174
  List<Long> registerNotificationMessages(List<NotificationMessage> messages);
  // Add By HandsomeLin At 2023/02/16 End

  // Add By HandsomeLin At 2023/02/16 Start
  // #6174
  @Data
  class NotificationMessage {
    private String content;
    private List<RecipientsRequest> recipients;
    private String additionalInfo;
    private String facilityCd;
    private Long notificationNo;
  }

  @Data
  class NotificationStatus {
    private Long notificationMessageNo;
    private List<RecipientsRequest> recipients;
  }
  // Add By HandsomeLin At 2023/02/16 End

  // add bug 6522 修正 chen start
  /**
   * 通知メッセージを取得します.
   * 移植元: jp.co.nikkiso.ntss.admin_web.service.notificationMessage.notificationMessageService
   *
   * @param content        メッセージ本文
   * @param userId ユーザID
   * @param additionalInfo 付加情報
   * @param facilityCd 施設コード
   * @return 登録した通知メッセージ番号
   */
  // List<MntNotificationMessage> hasNotificationMessage(String content, Long userId, String additionalInfo, String facilityCd, Long notificationNo);
  // add bug 6522 修正 chen end

  //add FNSi6531通知が重複して行われる 周 start
  /**
   * 通知メッセージを取得します.
   *
   * @param facilityCd 施設コード
   * @param notificationNo 通知番号
   * @return 登録した通知メッセージ数
   */
  List<MntNotificationMessage> getNotificationMessage(String facilityCd, Long notificationNo);
  //add FNSi6531通知が重複して行われる 周 end

  /**
   * 通知メッセージ登録をクライアントに通知します.
   * 移植元: jp.co.nikkiso.ntss.admin_web.service.notificationMessage.notificationMessageService
   * @param notificationMessageNo 通知対象の通知メッセージ番号
   * @param recipients 利用者IDのリスト
   */
  void notifyNotificationMessage(Long notificationMessageNo, List<Long> recipients);

  /**
   * 施設コード、利用者ID、に該当する送信先にPush通知を実施する .
   * @param RecipientsReqList 施設コードとユーザIDの組み合わせ
   * @param message メッセージ
   * @return 送信件数
   */
  int sendPushMessage(List<RecipientsRequest> recipientsReqList, String message);

}
