package jp.co.nikkiso.ntss.monitoring.service.logger;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.util.List;


/**
 * wangzuo アプリケーションログの適正化
 */
@Component
public class LogEventUtils {

  @Autowired
  private LogService logService;

  /**
   * Resourceログ出力
   */
  public <T> void resourceLogOutput(String className, String methodName, String functionCode, String flg, String mappingUrl, String facilityCd, T params) {
    StringBuffer logStr = new StringBuffer("");
    logStr.append(className);
    logStr.append(LOG_MESSAGE_SPACE);
    logStr.append(methodName);
    if (BEFORE_LOG_FLG_INFO.equals(flg)) {
      // 前処理の場合
      logStr.append(BEFORE_LOG_MESSAGE);
    } else if (AFTER_LOG_FLG_INFO.equals(flg)) {
      // 後処理かつ正常終了の場合
      logStr.append(AFTER_LOG_MESSAGE_INFO);
    } else if (AFTER_LOG_FLG_ERROR.equals(flg)) {
      // 後処理かつ異常終了の場合
      logStr.append(AFTER_LOG_MESSAGE_ERROR);
    }

    try {
      // 後処理かつ異常終了以外の場合
      if (!AFTER_LOG_FLG_ERROR.equals(flg)) {
        if (!StringUtils.isEmpty(mappingUrl)) {
          // mappingUrlありの場合
          logStr.append(mappingUrl);
        }
        if (!StringUtils.isEmpty(facilityCd)) {
          // 施設コードありの場合
          logStr.append(LOG_MESSAGE_SLASH);
          logStr.append(facilityCd);
        }

        if (params != null) {
          if (params instanceof List) {
            if (!CollectionUtils.isEmpty((List) params)) {
              // 他の多数パラメータありの場合
              for (Object obj : (List) params) {
                String str = DataUpdateLogInfoUtil.convertString(obj);
                if (str == null || str.isEmpty()){
                  continue;
                }
                logStr.append(LOG_MESSAGE_SLASH);
                logStr.append(str);
              }
            }
          }
        }
        String str = DataUpdateLogInfoUtil.convertString(params);
        logStr.append(LOG_MESSAGE_SLASH);
        logStr.append(str);
      } else {
        // 後処理かつ異常終了の場合
        logStr.append((String)params);
      }

    }catch (Exception e){
      logStr.append("error : " + e.getMessage());
    }

    EventLogMessage eventLogMessage = new EventLogMessage();

    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.NTSS_M_NOTICE + "," + LoggingConstant.SERVICE_NAME.FNSI);

    if (!StringUtils.isEmpty(facilityCd)) {
      eventLogMessage.setFacilityCd(facilityCd);
    }
    eventLogMessage.setLogMessage(logStr.toString());

    if (BEFORE_LOG_FLG_INFO.equals(flg) || AFTER_LOG_FLG_INFO.equals(flg)) {
      // 正常の前後処理の場合
      logService.log(LogLevel.INFO, eventLogMessage, functionCode, LoggingConstant.SERVICE_NAME.FNSI, null);
    } else if (AFTER_LOG_FLG_ERROR.equals(flg)) {
      // 異常の後処理の場合
      logService.log(LogLevel.ERROR, eventLogMessage, functionCode, LoggingConstant.SERVICE_NAME.FNSI, null);
    }
  }
}
