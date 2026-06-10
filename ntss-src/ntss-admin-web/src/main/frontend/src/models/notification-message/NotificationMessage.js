/**
 * 通知メッセージ情報を表現するクラス.
 */
import { dateFormat } from "@/functions/common/DateTimeUtils.js";
import { getRouterName } from "@/router/routing-helper";

export class NotificationMessage {
  constructor(notification) {
    // 通知メッセージ番号
    this.no = notification.notification_message_no;
    // 通知登録日時
    this.regDate = new Date(notification.reg_date);
    this.displayRegDate = dateFormat.format(
      this.regDate,
      "yyyy/MM/dd hh:mm:ss"
    );
    // メッセージ本文
    this.content = notification.content;
    // 付加情報
    this.additionalInfo = notification.additional_info
      ? JSON.parse(notification.additional_info)
      : null;
    // 既読フラグ
    this.isRead = notification.is_read === "1";

    // 画面遷移先のルーター名をあらかじめ取得する
    // NotificationMessageMixinで`getRouterName`をimportすると初期表示でこけるため
    if (this.additionalInfo && this.additionalInfo.FUNC) {
      this.additionalInfo.routerName = getRouterName(this.additionalInfo.FUNC);
    }
    // add FNSI-重要通知設定の追加 江 start
    // 重要フラグ
    this.isImportant = notification.is_important === "1";
    // add FNSI-重要通知設定の追加 江 end
    // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 start
    // 同姓同名フラグ
    this.isSame = notification.is_same === "1";
    // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 end
  }
}
