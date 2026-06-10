package jp.co.nikkiso.ntss.coop_api.utils;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;

@Component
public class JournalConvertLogUtil {

  @Autowired
  private LogService logServiceTemp;
  private static LogService logService;

  @PostConstruct
  public void init() {
    logService = logServiceTemp;

  }

  public static void eventMessageError(String message, String facilityCd, String className) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(message);
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setInvokeClass(className);
    logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//      JournalConvertLogUtil.eventMessageError(error,request.getFacilityCd(),this.getClass().getName());
  }

  public static void eventMessageError(String message, String facilityCd, String patId, String userId, String className) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setUserId(userId);
    eventLogMessage.setPatId(patId);
    eventLogMessage.setLogMessage(message);
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setInvokeClass(className);
    logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//    String error="ジャナル変換API：IFエッジ(サーバへの電文リクエスト)に通知失敗。";
//    JournalConvertLogUtil.eventMessageError(error,request.getFacilityCd(),
//      (request.getPatId() == null ? "" : request.getPatId().toString()),
//      (request.getUserId() == null ? "" : request.getUserId().toString()),
//      this.getClass().getName());
  }

  public static void eventMessageDebug(String message, String facilityCd, String className) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(message);
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setInvokeClass(className);
    logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//      JournalConvertLogUtil.eventMessageDebug(error,request.getFacilityCd(),this.getClass().getName());
  }

  public static void eventMessageWarn(String message, String facilityCd, String className) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(message);
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setInvokeClass(className);
    logService.log(LogLevel.WARN, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//    String warnMessage=String.format(error+" ctl_no:[%s], facility_cd:[%s], coop_cd:[%s], coop_version:[%s]",
//      journal.getCtlNo(),facilityCd,journal.getCoopCd(),coopVersion);
  }
}
