package jp.co.nikkiso.ntss.admin_web.service.statusList;

import jp.co.nikkiso.ntss.admin_web.request.statusList.CheckAfterWeightRequest;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeOrder.DeviceEdgeOrderResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusList.AllConfirmResponse;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

public interface DialysisConfirmService {

  /**
   * 確認ボタン押下時処理
   * ord_mainの初版確定、ステータス、版番号更新
   */
  int updateCheckAfterWeight(CheckAfterWeightRequest ordInfo, Long sessionUserId, EventLogMessage eventLogMessage);

  /**
   * 自動印刷処理
   * @param ordInfo リクエストパラメータ
   * @param facilityCd 施設コード
   * @param userId ユーザーID
   * @param userName ユーザー名
   * @return 応答
   */
  AllConfirmResponse autoPrint(CheckAfterWeightRequest ordInfo, String facilityCd, Long userId, String userName);

  /**
   * 外部連携
   *
   * @param request リクエストパラメータ
   * @param facilityCd 施設コード
   */
  void callJournal(CheckAfterWeightRequest request, String facilityCd);

  // #10518 2024.05.23 mod 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 start
//  /**
//   * オフライン終了日時更新
//   *
//   * @param request    リクエストパラメータ
//   * @param facilityCd 施設コード
//   * @return 通知応答
//   */
//  DeviceEdgeOrderResponse sendEndDateUpdateInfo(CheckAfterWeightRequest request, String facilityCd);
  /**
   * 実績確定・削除時装置レポート画像更新
   *
   * @param patId    患者ID
   * @param facilityCd 施設コード
   * @return 通知応答
   */
  DeviceEdgeOrderResponse sendOrderAllReportUpdateByPatId(Long patId, String facilityCd);
  // #10518 2024.05.23 mod 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 end
}
