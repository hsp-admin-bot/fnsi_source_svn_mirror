package jp.co.nikkiso.ntss.admin_web.service.log;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.BaseBlankEntity;
import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_MESSAGE_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_MESSAGE_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_MESSAGE;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.LOG_MESSAGE_SLASH;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.LOG_MESSAGE_SPACE;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

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
          if (params instanceof Map){
            Map<Object, Object> dic = (Map)params;
            for(Map.Entry<Object, Object> entry : dic.entrySet()){
              String mapKey = DataUpdateLogInfoUtil.convertString(entry.getKey());
              String mapValue = DataUpdateLogInfoUtil.convertString(entry.getValue());
              logStr.append(mapKey+" / "+mapValue);
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

    EventLogMessage eventLogMessage = new EventLogMessage();
    SecurityContext sc = SecurityContextHolder.getContext();
    if (sc != null){
      Authentication au = sc.getAuthentication();
      if (au != null) {
        Object user = au.getPrincipal();
        if (user != null) {
          if (user instanceof NtssUser) {
            NtssUser nu = (NtssUser)user;
            // 利用者ID
            eventLogMessage.setUserId(nu.getUserId().toString());
            // 施設コード
            eventLogMessage.setFacilityCd(nu.getFacilityCd());
            // 接続先IPアドレス
            eventLogMessage.setClientIp(nu.getClientIpAddress());
            // セッションID
            eventLogMessage.setSessionId(nu.getSessionId());
          }
        }
      }
    }


    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);

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

  /**
   * 操作者を設定する
   * @param entity
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
  public static void setOperatorId(Object entity, LogService logService) {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    try {
      if (SecurityContextHolder.getContext() == null) {
        return;
      }
      Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
      if (authentication == null) {
        return;
      }
      NtssUser ntssUser = (NtssUser) authentication.getPrincipal();
      if (ntssUser == null) {
        return;
      }

      if (entity instanceof BaseEntity) {
        ((BaseEntity) entity).setOperatorId(ntssUser.getUserId());
        ((BaseEntity) entity).setClientIp(ntssUser.getClientIpAddress());
      }

      if (entity instanceof BaseBlankEntity) {
        ((BaseBlankEntity) entity).setOperatorId(ntssUser.getUserId());
        ((BaseBlankEntity) entity).setClientIp(ntssUser.getClientIpAddress());
      }

    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      if (logService != null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "",
          LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
    }
  }

//upd by ztc 2023-03-20 Treatment method change branch 2, 3 optimization --start /
  /**
   * 操作者を設定する
   * @param entitys
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
  public static void batchSetOperatorId(List<?> entitys, LogService logService) {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    try {
      if (SecurityContextHolder.getContext() == null) {
        return;
      }

      Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
      if (authentication == null) {
        return;
      }

      NtssUser ntssUser = (NtssUser) authentication.getPrincipal();
      if (ntssUser == null) {
        return;
      }

      entitys.stream().filter(obj -> obj instanceof BaseEntity || obj instanceof BaseBlankEntity)
        .forEach(obj -> {
          if (obj instanceof BaseEntity) {
            ((BaseEntity) obj).setOperatorId(ntssUser.getUserId());
            ((BaseEntity) obj).setClientIp(ntssUser.getClientIpAddress());
          } else {
            ((BaseBlankEntity) obj).setOperatorId(ntssUser.getUserId());
            ((BaseBlankEntity) obj).setClientIp(ntssUser.getClientIpAddress());
          }
        });

    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      if (logService != null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "",
          LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
    }
  }
//upd by ztc 2023-03-20 Treatment method change branch 2, 3 optimization --end /
}
