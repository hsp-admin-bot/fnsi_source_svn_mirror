package jp.co.nikkiso.ntss.admin_web.response.scheduleAssignment;

import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;

/**
 * ユーザ設定のResponse.
 */
@NoArgsConstructor
public class ScheduleAssignmentUpdateResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public ScheduleAssignmentUpdateResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   * 通信サーバへの通知情報
   */
  public DeviceEdgeOrderRequest machinedata;

  //add FNSI redmine 6706 劉祥霖  追加再修正：？？？？患者予定部分に投薬がないと通知しない start
  /**
   * 装置への投薬変更通知発送フラッグ
   */
  public boolean sendMediNoticeFlag;
  //add FNSI redmine 6706 劉祥霖 追加再修正：？？？？患者予定部分に投薬がないと通知しない end
}
