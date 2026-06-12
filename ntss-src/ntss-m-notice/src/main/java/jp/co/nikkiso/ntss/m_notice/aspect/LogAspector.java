package jp.co.nikkiso.ntss.m_notice.aspect;


// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import tools.jackson.databind.ObjectMapper;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import jp.co.nikkiso.ntss.m_notice.service.LogService;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.Signature;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import java.lang.reflect.Method;
import java.lang.reflect.Parameter;

import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.aspectorLogEventLogMessage;
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.summarize;
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end


@Aspect
@Component("LogAspectorMnotice")
public class LogAspector {

  private enum OUTPUT_KBN { BEFORE, AFTER, EXCEPTION };

  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // private Map<String, Object> paramNameValueMap = new HashMap<String, Object>();
  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  @Autowired
  private LogService logService;

  private final List facilityCdList = Arrays.asList(
    "facilitycd"
  );

  @Pointcut(value = "execution (* jp.co.nikkiso.ntss.m_notice.service..*.*(..))")
  public void cutLogPoint() {
  }

// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang start
//  @Pointcut(value = "execution (* org.seasar.doma.jdbc..*.*(..))")
//  public void cutSqlLogPoint() {
//  }
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang end

  /**
   * 実行前処理
   * @param joinPoint
   */
  @Before("cutLogPoint()")
  public void doBeforeService(JoinPoint joinPoint) {
    try {
      String className = getClassName(joinPoint);
      if (!StringUtils.isEmpty(className) && className.indexOf("LogServiceImpl") >= 0) {
        return;
      }
      String methodName = getMethodName(joinPoint);
      outputLog(className, methodName, joinPoint, OUTPUT_KBN.BEFORE, "");
    } catch (Throwable throwable) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      throwable.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      if (throwable instanceof Exception) {
        eventLogMessage.setLogMessage(
          ExcetionStackTraceToString((Exception) throwable)
        );
      } else {
        eventLogMessage.setLogMessage(
          throwable.toString()
        );
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
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
      if (!StringUtils.isEmpty(className) && className.indexOf("LogServiceImpl") >= 0) {
        return;
      }
      String methodName = getMethodName(joinPoint);
      outputLog(className, methodName, joinPoint, OUTPUT_KBN.AFTER, "");
    } catch (Throwable throwable) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      throwable.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      if (throwable instanceof Exception) {
        eventLogMessage.setLogMessage(
          ExcetionStackTraceToString((Exception) throwable)
        );
      } else {
        eventLogMessage.setLogMessage(
          throwable.toString()
        );
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
    }
  }
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end

  @AfterThrowing(throwing="ex", pointcut="cutLogPoint()")
  public void doAfterThrowing(JoinPoint joinPoint, Throwable ex) {
    String className = getClassName(joinPoint);
    if (!StringUtils.isEmpty(className) && className.indexOf("LogServiceImpl") >= 0) {
      return;
    }
    String methodName = getMethodName(joinPoint);
    String errMessage = stackTraceToString(ex.getClass().getName(), ex.getMessage(), ex.getStackTrace());
    outputLog(className, methodName, joinPoint, OUTPUT_KBN.EXCEPTION, errMessage);
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
   * メソッドがgetJdbcLogger場合、戻り値をNtssUtilLoggingJdbcLoggerに変更する
   * @param pjp
   */
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang start
//  @Around("cutSqlLogPoint()")
//  public Object doAround(ProceedingJoinPoint pjp) {
//    Object object = null;
//    try {
//      //JdbcLogger
//      String className = getClassName(pjp);
//      String methodName = getMethodName(pjp);
//      Object[] args = pjp.getArgs();
//      if (args == null || args.length == 0) {
//        object = pjp.proceed();
//      } else {
//        object = pjp.proceed(args);
//      }
//
//      if ("org.seasar.doma.boot.autoconfigure.DomaConfig".equals(className) &&
//        "getJdbcLogger".equals(methodName)) {
//        object = new NtssUtilLoggingJdbcLogger(logService);
//        return object;
//      }
//    } catch (Throwable throwable) {}
//
//    return object;
//  }
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang end

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
   * ログ出力
   * @param className クラス名
   * @param methodName メソッド名
   * @param joinPoint カットポイント
   * @param outputKbn 出力区分
   */
  private void outputLog(String className, String methodName, JoinPoint joinPoint, OUTPUT_KBN outputKbn, String errMessage) {
    String message = "";
    String facilitycd = "";
    String paramMessage = "";
    String[] paramNames = getParameterName(joinPoint);
    Object[] paramValues = joinPoint.getArgs();
    if (paramNames != null && paramNames.length > 0) {
      for (int i = 0; i < paramNames.length; i++) {
        if (paramValues != null && paramValues.length >= i) {
          paramMessage = paramMessage + " " + paramNames[i] + ":" + convertString(paramValues[i]);
          if (facilityCdList.contains(paramNames[i].toLowerCase())
            && "java.lang.String".equals(paramNames[i].getClass().getTypeName())) {
            facilitycd = DataUpdateLogInfoUtil.convertString(paramValues[i]);
            break;
          }
        }
      }
    }

    LogLevel level = LogLevel.INFO;
    if (outputKbn == OUTPUT_KBN.BEFORE) {
      message = String.format(LoggingConstant.MONGO_LOG.BEFORE_MESSAGE, className, methodName, paramMessage);
    } else if (outputKbn == OUTPUT_KBN.AFTER) {
      message = String.format(LoggingConstant.MONGO_LOG.AFTER_MESSAGE, className, methodName);
    } else {
      level = LogLevel.ERROR;
      message = String.format(LoggingConstant.MONGO_LOG.EXCEPTION_MESSAGE, className, methodName, errMessage);
    }

    EventLogMessage eventLogMessage = new EventLogMessage();
    if (isFacilitycd(facilitycd)) {
      eventLogMessage.setFacilityCd(facilitycd);
    }
    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
    eventLogMessage.setLogMessage(message);

    logService.log(level, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
  }

  /**
   * 施設コードチェック
   * @param facilitycd
   * @return
   */
  private boolean isFacilitycd(String facilitycd) {
    if (StringUtils.isEmpty(facilitycd)) {
      return false;
    }

    if (facilitycd.indexOf(",") >= 0 || facilitycd.indexOf("[") >= 0 || facilitycd.indexOf("]") >= 0 || facilitycd.indexOf(" ") >= 0) {
      return false;
    }

    if (facilitycd.length() > 6) {
      return false;
    }

    return true;
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

}
