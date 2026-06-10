package jp.co.nikkiso.ntss.admin_web.service.statusList;

import jp.co.nikkiso.ntss.admin_web.request.statusList.CheckAfterWeightRequest;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeOrder.DeviceEdgeOrderResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusList.AllConfirmResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.autoPrint.AutoPrintService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

/**
 * 実績確定処理用スレッド
 * @author ntss
 */
public class DialysisConfirmThread extends Thread {

  List<CheckAfterWeightRequest> request;
  NtssUser user;

  @Autowired
  DialysisConfirmService dialysisConfirmService;

  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  @Autowired
  LogService logService;

  // add 11613 by shiyw 20250303 start
  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;
  // add 11613 by shiyw 20250303 end

  public DialysisConfirmThread(List<CheckAfterWeightRequest> request, NtssUser user){
    this.request = request;
    this.user = user;
  }

  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage(NtssUser user) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  public void run() {
    String facilityCd = this.user.getFacilityCd();
    Long userId = this.user.getUserId();
    String userName = this.user.getUsername();

    EventLogMessage eventLogMessage = getEventLogMessage(this.user);
    eventLogMessage.setLogMessage("dialysisConfirm: " + request.size() + "件の実績確定処理開始");
    writeTextLog(LogLevel.INFO, eventLogMessage);

    for (CheckAfterWeightRequest ordInfo : request) {
      //実績確定処理
      updateCheckAfterWeight(ordInfo, userId, eventLogMessage);
      //NOTE: 実績確定で例外発生しても以下の処理は継続する

      // 自動印刷
      autoPrint(ordInfo, facilityCd, userId, userName, eventLogMessage);
      // 外部連携
      callJournal(ordInfo, facilityCd, eventLogMessage);
      // #10518 2024.05.23 del 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 start
//      // オフライン治療終了日更新
//      doSendEndDateUpdateInfo(ordInfo, facilityCd, eventLogMessage);
      // #10518 2024.05.23 del 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 end
      // 加算
      doAutoCalculation(ordInfo, eventLogMessage);
    }
    // #10518 2024.05.23 add 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 start
    List<Long> patIdList = request.stream().map(CheckAfterWeightRequest::getPatId).distinct().toList();
    for (Long patId : patIdList) {
      if (patId == null) {
        continue;
      }
      doSendOrderAllReportUpdateByPatId(patId, facilityCd, eventLogMessage);
    }
    // #10518 2024.05.23 add 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 end
    eventLogMessage.setLogMessage("dialysisConfirm: 終了");
    writeTextLog(LogLevel.INFO, eventLogMessage);

  }

  /**
   * 実績確定処理
   * 例外発生してもログに残すが処理継続
   * @param ordInfo CheckAfterWeightRequest
   * @param userId ユーザーID
   * @param eventLogMessage EventLogMessage
   */
  private void updateCheckAfterWeight(CheckAfterWeightRequest ordInfo, Long userId, EventLogMessage eventLogMessage) {

    String logTargetOrdInfo = "dialysisConfirm.autoPrint: ord_no(" + ordInfo.getOrdNo() + ")の実績確定処理";
    eventLogMessage.setLogMessage(logTargetOrdInfo + "開始");
    writeTextLog(LogLevel.INFO, eventLogMessage);

    // 実績確定
    try {
      this.dialysisConfirmService.updateCheckAfterWeight(ordInfo, userId, eventLogMessage);
      // add 11613 by shiyw 20250303 start
      this.ordMaterialSaveService.updateIsConfirm(ordInfo.getOrdNo(), ordInfo.getPatId());
      // add 11613 by shiyw 20250303 end
      eventLogMessage.setLogMessage(logTargetOrdInfo + "終了");
      writeTextLog(LogLevel.INFO, eventLogMessage);
    } catch (Exception ex) {
      eventLogMessage.setLogMessage(logTargetOrdInfo + "失敗\n" + ex.getMessage());
      writeTextLog(LogLevel.ERROR, eventLogMessage);
    }
  }

  /**
   * 自動印刷処理
   * 例外発生してもログに残すが処理継続
   * @param ordInfo CheckAfterWeightRequest
   * @param facilityCd 施設コード
   * @param userId ユーザーID
   * @param userName ユーザー名
   * @param eventLogMessage EventLogMessage
   */
  private void autoPrint(CheckAfterWeightRequest ordInfo, String facilityCd, Long userId, String userName, EventLogMessage eventLogMessage) {

    String logTargetOrdInfo = "dialysisConfirm.autoPrint: ord_no(" + ordInfo.getOrdNo() + ")の自動印刷処理";
    eventLogMessage.setLogMessage(logTargetOrdInfo + "開始");
    writeTextLog(LogLevel.INFO, eventLogMessage);

    // 自動印刷
    try {
      AllConfirmResponse r = this.dialysisConfirmService.autoPrint(ordInfo, facilityCd, userId, userName);
      if (r.isSuccess) {
        if (r.autoPrintResults != null) {
          for (AutoPrintService.AutoPrintResult pr : r.autoPrintResults) {
            if (pr.isAutoPrint && !pr.isSuccessAutoPrint) {
              eventLogMessage.setLogMessage(logTargetOrdInfo + ", 失敗項目：" + pr.autoPrintErrorMessage);
              writeTextLog(LogLevel.ERROR, eventLogMessage);
            }
          }
        }
        eventLogMessage.setLogMessage(logTargetOrdInfo + "終了");
        writeTextLog(LogLevel.INFO, eventLogMessage);
      } else {
        eventLogMessage.setLogMessage(logTargetOrdInfo + "失敗\n" + r.errorMessage + "\n" + r.errDetail);
        writeTextLog(LogLevel.ERROR, eventLogMessage);
      }
    } catch (Exception ex) {
      eventLogMessage.setLogMessage(logTargetOrdInfo + "失敗\n" + ex.getMessage());
      writeTextLog(LogLevel.ERROR, eventLogMessage);
    }
  }
  /**
   * 外部連携処理
   * 例外発生してもログに残すが処理継続
   * @param ordInfo CheckAfterWeightRequest
   * @param facilityCd 施設コード
   * @param eventLogMessage EventLogMessage
   */
  private void callJournal(CheckAfterWeightRequest ordInfo, String facilityCd, EventLogMessage eventLogMessage) {

    String logTargetOrdInfo = "dialysisConfirm.callJournal: ord_no(" + ordInfo.getOrdNo() + ")の外部連携処理";
    eventLogMessage.setLogMessage(logTargetOrdInfo + "開始");
    writeTextLog(LogLevel.INFO, eventLogMessage);

    try {
      // 外部連携
      this.dialysisConfirmService.callJournal(ordInfo, facilityCd);
      eventLogMessage.setLogMessage(logTargetOrdInfo + "終了");
      writeTextLog(LogLevel.INFO, eventLogMessage);
    } catch (Exception ex) {
      eventLogMessage.setLogMessage(logTargetOrdInfo + "失敗\n" + ex.getMessage());
      writeTextLog(LogLevel.ERROR, eventLogMessage);
    }
  }

  // #10518 2024.05.23 mod 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 start
//  /**
//   * オフライン終了日時更新デバイスエッジ通知処理
//   * 例外発生してもログに残すが処理継続
//   * @param ordInfo CheckAfterWeightRequest
//   * @param facilityCd 施設コード
//   * @param eventLogMessage EventLogMessage
//   */
//  private void doSendEndDateUpdateInfo(CheckAfterWeightRequest ordInfo, String facilityCd, EventLogMessage eventLogMessage) {
//
//    String logTargetOrdInfo = "dialysisConfirm.doSendEndDateUpdateInfo: ord_no(" + ordInfo.getOrdNo() + ")のオフライン終了日時更新デバイスエッジ通知処理";
//    eventLogMessage.setLogMessage(logTargetOrdInfo + "開始");
//    writeTextLog(LogLevel.INFO, eventLogMessage);
//
//    try {
//      // オフライン治療終了日更新
//      DeviceEdgeOrderResponse r = this.dialysisConfirmService.sendEndDateUpdateInfo(ordInfo, facilityCd);
//      if (r.isSuccess) {
//        eventLogMessage.setLogMessage(logTargetOrdInfo + "終了");
//        writeTextLog(LogLevel.INFO, eventLogMessage);
//      } else {
//        eventLogMessage.setLogMessage(logTargetOrdInfo + "失敗\n" + r.errorMessage);
//        writeTextLog(LogLevel.ERROR, eventLogMessage);
//      }
//    } catch (Exception ex) {
//      eventLogMessage.setLogMessage(logTargetOrdInfo + "失敗\n" + ex.getMessage());
//      writeTextLog(LogLevel.ERROR, eventLogMessage);
//    }
//  }

  /**
   * 実績確定・削除時装置レポート画像更新処理
   * 例外発生してもログに残すが処理継続
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param eventLogMessage EventLogMessage
   */
  private void doSendOrderAllReportUpdateByPatId(Long patId, String facilityCd, EventLogMessage eventLogMessage) {

    String logTargetOrdInfo = "dialysisConfirm.doSendOrderAllReportUpdateByPatId: pat_id(" + patId + ")の装置レポート画像更新通知処理";
    eventLogMessage.setLogMessage(logTargetOrdInfo + "開始");
    writeTextLog(LogLevel.INFO, eventLogMessage);

    try {
      // 装置レポート画像更新
      DeviceEdgeOrderResponse r = this.dialysisConfirmService.sendOrderAllReportUpdateByPatId(patId, facilityCd);
      if (r.isSuccess) {
        eventLogMessage.setLogMessage(logTargetOrdInfo + "終了");
        writeTextLog(LogLevel.INFO, eventLogMessage);
      } else {
        eventLogMessage.setLogMessage(logTargetOrdInfo + "失敗\n" + r.errorMessage);
        writeTextLog(LogLevel.ERROR, eventLogMessage);
      }
    } catch (Exception ex) {
      eventLogMessage.setLogMessage(logTargetOrdInfo + "失敗\n" + ex.getMessage());
      writeTextLog(LogLevel.ERROR, eventLogMessage);
    }
  }
  // #10518 2024.05.23 mod 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 end

  /**
   * 加算処理
   * 例外発生してもログに残すが処理継続
   * @param ordInfo ordInfo
   * @param eventLogMessage EventLogMessage
   */
  private void doAutoCalculation(CheckAfterWeightRequest ordInfo, EventLogMessage eventLogMessage) {

    String logTargetOrdInfo = "dialysisConfirm.doAutoCalculation: ord_no(" + ordInfo.getOrdNo() + ")の加算処理";
    eventLogMessage.setLogMessage(logTargetOrdInfo + "開始");
    writeTextLog(LogLevel.INFO, eventLogMessage);
    try {
      // 加算
      webApiCallCommonUtil.doAutoCalculation(ordInfo.getOrdNo());
      eventLogMessage.setLogMessage(logTargetOrdInfo + "終了");
      writeTextLog(LogLevel.INFO, eventLogMessage);
    } catch (Exception ex) {
      eventLogMessage.setLogMessage(logTargetOrdInfo + "失敗\n" + ex.getMessage());
      writeTextLog(LogLevel.ERROR, eventLogMessage);
    }
  }

  private void writeTextLog(LogLevel logLevel, EventLogMessage eventLogMessage) {
    logService.log(logLevel, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, LoggingConstant.SERVICE_NAME.FNSI, null);
  }
}

