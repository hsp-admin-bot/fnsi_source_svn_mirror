package jp.co.nikkiso.ntss.device_edge.web.rest;

import jp.co.nikkiso.ntss.device_edge.service.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.constant.Constant.Uri;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.sms.SmsService;

import java.util.Arrays;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

@RestController
@RequestMapping(Uri.SMS)
public class SmsResource {

  @Autowired
  private LogService logService;
  @Autowired
  private SmsService smsService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End
  /**
   * 緊急発報マスタ設定の施設登録項目一覧取得
   */
  @GetMapping({ "/cd_list/{facility_cd}" })
  public ResponseEntity<?> getMstAlarmNotificationList(
      @PathVariable(name = "facility_cd") String facilityCd) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API GET CALLED api/sms/cd_list/" + facilityCd + "");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    String ret = smsService.buildNotificationCdList(facilityCd, "\n");
    return new ResponseEntity<>(ret, HttpStatus.OK);
  }

  /**
   * 緊急発報マスタ設定のSMS設定取得
   */
  @GetMapping({ "/conf/{notification_cd}" })
  public ResponseEntity<?> getMstAlarmNotificationConf(
      @PathVariable(name = "notification_cd") Long notificationCd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SMS + "/conf";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      notificationCd);
    // wp アプリケーションログの適正化 Add End

//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("API GET CALLED api/sms/conf/" + notificationCd + "");
//    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    String ret = smsService.buildNotificationConfig(notificationCd);
    if (ret == null) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(notificationCd, ret));
      // wp アプリケーションログの適正化 Add End
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(notificationCd, ret));
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(ret, HttpStatus.OK);
  }

  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }
}
