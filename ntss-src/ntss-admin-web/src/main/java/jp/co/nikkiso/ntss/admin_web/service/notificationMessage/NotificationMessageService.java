package jp.co.nikkiso.ntss.admin_web.service.notificationMessage;

import jp.co.nikkiso.ntss.admin_web.request.notificationMessage.ReadStatusRequest;
import jp.co.nikkiso.ntss.admin_web.response.notificationMessage.NotificationListResponse;
import jp.co.nikkiso.ntss.admin_web.response.notificationMessage.UnreadCountResponse;

import java.util.List;

/**
 * 通知一覧のServiceインタフェース.
 */
public interface NotificationMessageService {

  /**
   * 通知メッセージを登録します.
   *
   * @param content        メッセージ本文
   * @param recipients     利用者IDのリスト
   * @param additionalInfo 付加情報
   * @param facilityCd     施設コード
   */
  Long registerNotificationMessage(String content, List<Long> recipients, String additionalInfo, String facilityCd);

  /**
   * 通知メッセージ登録をクライアントに通知します.
   *
   * @param recipients 利用者IDのリスト
   */
  void notifyNotificationMessage(Long notificationMessageNo, List<Long> recipients);

  /**
   * 通知メッセージ(未通知)を取得します.
   *
   * @param userId ユーザーID
   * @return 通知メッセージ情報
   */
  // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 Start
  // NotificationListResponse getNotificationMessage(Long userId);
  NotificationListResponse getNotificationMessage(Long userId, String facilityCd);
  // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 end

  // add FNSI-当施設の操作通知は別施設に表示を修正 江 start
  NotificationListResponse getNotificationMessageList(Long userId, String facilityCd);
  // add FNSI-当施設の操作通知は別施設に表示を修正 江 end

  /**
   * 通知メッセージ(全件)を取得します.
   *
   * @param userId ユーザーID
   * @return 通知メッセージ情報
   */
  NotificationListResponse getNotificationMessageAll(Long userId);

  //add FNSI-通知表示が遅いを修正 江 start
  NotificationListResponse getNotificationMessageAll(Long userId, String facilityCd, Integer offset);
  //add FNSI-通知表示が遅いを修正 江 end

  // del #10110 通知一覧から既読にした通知以外も消える dengshen start
  // //add FNSI redmine 4893 修正 鄧シン start
  // NotificationListResponse getNotificationMessageAllAfterChange(Long userId, String facilityCd, Integer offset);
  // //add FNSI redmine 4893 修正 鄧シン end
  // del #10110 通知一覧から既読にした通知以外も消える dengshen start

  // add FNSI-通知既読更新を修正 江 start
  /**
   * 既読フラグを更新します.
   *
   * @param userId ユーザーID
   * @return 未読件数
   */
  void updateIsReadStatus(Long userId);
  // add FNSI-通知既読更新を修正 江 end

  /**
   * 既読フラグを更新します.
   *
   * @param request リクエスト
   * @param userId ユーザーID
   * @return 未読件数
   */
  // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 Start
  void updateReadStatus(ReadStatusRequest request, Long userId, String facilityCd);
  // void updateReadStatus(ReadStatusRequest request, Long userId);
  // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 end

  /**
   * 未読件数を取得します.
   *
   * @param userId ユーザーID
   * @return
   */
  UnreadCountResponse getUnreadCount(Long userId);

  //add FNSI-【redmine #4440 別の施設に対する通知が表示される】を修正 江 start
  /**
   * 未読件数を取得します.
   *
   * @param userId ユーザーID
   * @return
   */
  UnreadCountResponse getUnreadCountByFacilityCd(Long userId, String facilityCd);
  //add FNSI-【redmine #4440 別の施設に対する通知が表示される】を修正 江 end
}
