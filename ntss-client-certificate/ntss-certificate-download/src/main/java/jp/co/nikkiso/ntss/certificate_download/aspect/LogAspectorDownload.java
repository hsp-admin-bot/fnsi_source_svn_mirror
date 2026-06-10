package jp.co.nikkiso.ntss.certificate_download.aspect;

import jp.co.nikkiso.ntss.certificate_download.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.Signature;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Aspect
@Component
public class LogAspectorDownload {

  private enum OUTPUT_KBN { BEFORE, AFTER, EXCEPTION };

  private Map<String, Object> paramNameValueMap = new HashMap<String, Object>();

  @Autowired
  LogService logService;

  @Pointcut(value = "execution (* jp.co.nikkiso.ntss.certificate_download.service..*.*(..))")
  public void cutLogPoint() {
  }

  /**
   * 実行前処理
   * @param joinPoint
   */
  @Before("cutLogPoint()")
  public void doBeforeService(JoinPoint joinPoint) {
    try {
      String className = getClassName(joinPoint);
      if (className.indexOf("LogServiceImpl") >= 0) {
        return;
      }
      String methodName = getMethodName(joinPoint);
      outputLog(className, methodName, joinPoint, OUTPUT_KBN.BEFORE, "");
    } catch (Throwable throwable) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(throwable.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", "CERTIFICATE_DOWNLOAD", null);
    }
  }

  /**
   * 実行後処理
   * @param joinPoint
   */
  @AfterReturning("cutLogPoint()")
  public void doAfterService(JoinPoint joinPoint) {
    try {
      String className = getClassName(joinPoint);
      if (className.indexOf("LogServiceImpl") >= 0) {
        return;
      }
      String methodName = getMethodName(joinPoint);
      outputLog(className, methodName, joinPoint, OUTPUT_KBN.AFTER, "");
    } catch (Throwable throwable) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(throwable.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", "CERTIFICATE_DOWNLOAD", null);
    }
  }

  @AfterThrowing(throwing="ex", pointcut="cutLogPoint()")
  public void doAfterThrowing(JoinPoint joinPoint, Throwable ex) {
    try {
      String className = getClassName(joinPoint);
      if (className.indexOf("LogServiceImpl") >= 0) {
        return;
      }
      String methodName = getMethodName(joinPoint);
      String errMessage = stackTraceToString(ex.getClass().getName(), ex.getMessage(), ex.getStackTrace());
      outputLog(className, methodName, joinPoint, OUTPUT_KBN.EXCEPTION, errMessage);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ex.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", "CERTIFICATE_DOWNLOAD", null);
    }
  }

  public String stackTraceToString(String exceptionName, String exceptionMessage, StackTraceElement[] elements) {
    StringBuffer strbuff = new StringBuffer();
    for (StackTraceElement stet : elements) {
      strbuff.append(stet + "\n");
    }
    String message = exceptionName + ":" + exceptionMessage + "\n\t" + strbuff.toString();
    return message;
  }

  /**
   * クラス名取得
   * @param joinPoint
   * @return
   */
  private String getClassName(JoinPoint joinPoint) {
    String className = joinPoint.getTarget().getClass().getName();
    if (className.indexOf("$") >= 0) {
      className = className.substring(0, className.indexOf("$"));
    }
    return className;
  }

  /**
   * メソッド名取得
   * @param joinPoint
   * @return
   */
  private String getMethodName(JoinPoint joinPoint) {
    return joinPoint.getSignature().getName();
  }

  /**
   * パラメータ名称を取得する
   * @param joinPoint
   */
  private String[] getParameterName(JoinPoint joinPoint) {
    Signature signature = joinPoint.getSignature();
    MethodSignature methodSignature = (MethodSignature) signature;
    String[] strings = methodSignature.getParameterNames();
    return strings;
  }

  /**
   * ログ出力
   * @param className クラス名
   * @param methodName メソッド名
   * @param joinPoint カットポイント
   * @param outputKbn 出力区分
   */
  private void outputLog(String className, String methodName, JoinPoint joinPoint, OUTPUT_KBN outputKbn, String errMessage) {
    String message = "";
    String paramMessage = "";
    String[] paramNames = getParameterName(joinPoint);
    Object[] paramValues = joinPoint.getArgs();
    if (paramNames != null && paramNames.length > 0) {
      for (int i = 0; i < paramNames.length; i++) {
        if (paramValues != null && paramValues.length >= i) {
          paramMessage = paramMessage + " " + paramNames[i] + ":" + convertString(paramValues[i]);
        }
      }
    }

    LogLevel level = LogLevel.INFO;
    if (outputKbn == OUTPUT_KBN.BEFORE) {
      message = String.format("%s %s 実施開始。パラメータ：%s", className, methodName, paramMessage);
    } else if (outputKbn == OUTPUT_KBN.AFTER) {
      message = String.format("%s %s 実施終了。", className, methodName);
    } else {
      level = LogLevel.ERROR;
      message = String.format("%s %s 実施異常終了。エラー：%s", className, methodName, errMessage);
    }

    EventLogMessage eventLogMessage = new EventLogMessage();

    eventLogMessage.setLogMessage(message);

    logService.log(level, eventLogMessage, "", "CERTIFICATE_DOWNLOAD", null);
  }

  /**
   * String変換
   * @param obj 変換用オブジェクト
   * @return 変換したデータ
   */
  public static String convertString(Object obj) {
    if (obj == null) {
      return "";
    }

    return obj.toString();
  }

}
