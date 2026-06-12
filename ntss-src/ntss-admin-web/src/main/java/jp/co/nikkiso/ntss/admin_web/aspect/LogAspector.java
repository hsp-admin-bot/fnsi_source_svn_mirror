package jp.co.nikkiso.ntss.admin_web.aspect;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import tools.jackson.databind.ObjectMapper;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
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
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import java.lang.reflect.Method;
import java.lang.reflect.Parameter;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end

import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.convertString;
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.aspectorLogEventLogMessage;
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.getClassName;
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.getMethodName;
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.getParameterName;
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.isFacilitycd;
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.stackTraceToString;
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.summarize;
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end


@Aspect
@Component
public class LogAspector {

  private final List facilityCdList = Arrays.asList(
    "facilitycd",
    "facility_cd",
    "argFacilityCd"
  );

  private enum OUTPUT_KBN { BEFORE, AFTER, EXCEPTION };

  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // private Map<String, Object> paramNameValueMap = new HashMap<String, Object>();
  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  @Autowired
  private LogService logService;
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
  @Pointcut(value = "within(@org.springframework.web.bind.annotation.RestController *) && within(jp.co.nikkiso.ntss.admin_web.web.rest..*) ")
  public void cutWebLog(){}
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
  @Pointcut(value = "execution (* jp.co.nikkiso.ntss.admin_web.service..*.*(..))")
  public void cutLogPoint() {
  }
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang start
//  @Pointcut(value = "execution (* org.seasar.doma.jdbc..*.*(..))")
//  public void cutSqlLogPoint() {
//  }
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang end

// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
  @Around(value = "cutWebLog()")
  public Object  cutControllerLog(ProceedingJoinPoint joinPoint) throws Throwable {
    long beginTime = System.currentTimeMillis();
    Object result = null;
    Exception exception = null;
    try {
      result = joinPoint.proceed();
    } catch (Exception e) {
      exception = e;
      throw e;
    } finally {
      long costTime = System.currentTimeMillis() - beginTime;
      saveLog(joinPoint, result, costTime, exception);
    }
    return result;
  }

  private void saveLog(ProceedingJoinPoint joinPoint, Object result, long costTime, Exception exception) {
    EventLogMessage eventLogMessage = aspectorLogEventLogMessage(joinPoint,result,costTime,exception,"ntss-admin-web");
    LogLevel level;
    if(exception!=null){
      level = LogLevel.ERROR;
    }else{
      level = LogLevel.INFO;
    }
    logService.log(level,eventLogMessage , "", LoggingConstant.SERVICE_NAME.FNSI, null);
  }
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end

  /**
   * 実行前処理
   * @param joinPoint
   */
  @Before("cutLogPoint()")
  public void doBeforeService(JoinPoint joinPoint) {
    try {
      String className = getClassName(joinPoint);
      if (className.equals("jp.co.nikkiso.ntss.admin_web.service.log.LogServiceImpl")) {
        return;
      }
      String methodName = getMethodName(joinPoint);
      outputLog(className, methodName, joinPoint, OUTPUT_KBN.BEFORE, "");
    } catch (Throwable throwable) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      if (throwable instanceof Exception) {
        eventLogMessage.setLogMessage(ExcetionStackTraceToString((Exception) throwable));
      } else {
        eventLogMessage.setLogMessage(
          throwable.toString()
        );
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
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
      if (className.equals("jp.co.nikkiso.ntss.admin_web.service.log.LogServiceImpl")) {
        return;
      }
      String methodName = getMethodName(joinPoint);
      outputLog(className, methodName, joinPoint, OUTPUT_KBN.AFTER, "");
    } catch (Throwable throwable) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      if (throwable instanceof Exception) {
        eventLogMessage.setLogMessage(ExcetionStackTraceToString((Exception) throwable));
      } else {
        eventLogMessage.setLogMessage(
          throwable.toString()
        );
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
  }

  @AfterThrowing(throwing="ex", pointcut="cutLogPoint()")
  public void doAfterThrowing(JoinPoint joinPoint, Throwable ex) {
    try {
      String className = getClassName(joinPoint);
      if (className.equals("jp.co.nikkiso.ntss.admin_web.service.log.LogServiceImpl")) {
        return;
      }
      String methodName = getMethodName(joinPoint);
      String errMessage = stackTraceToString(ex.getClass().getName(), ex.getMessage(), ex.getStackTrace());
      outputLog(className, methodName, joinPoint, OUTPUT_KBN.EXCEPTION, errMessage);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
  }

// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang start
  @Around("execution(* jp.co.nikkiso.ntss.core.dao..*(..))")
  public Object cutDaoPoint(ProceedingJoinPoint pjp) throws Throwable {
    Object object;
    EventLogMessage eventLogMessage = new EventLogMessage();
    Map<String, Object> map = new HashMap<>();
    try {
      MethodSignature sig = (MethodSignature) pjp.getSignature();
      Method implMethod = sig.getMethod();
      String className = getClassName(pjp);
      String methodName = getMethodName(pjp);

      if ("jp.co.nikkiso.ntss.core.dao.SysSystemDefineDaoImpl".equals(className)
        && "selectByCtlNo".equals(methodName)) {
        return pjp.proceed();
      }

      Map<String, Object> paramMap = new LinkedHashMap<>();
      Parameter[] params = implMethod.getParameters();
      Object[] args = pjp.getArgs();
      ObjectMapper mapper = new ObjectMapper();
      if(params!=null&&params.length>0&&args!=null&&args.length>0){
        for (int i = 0; i < params.length; i++) {
          paramMap.put(params[i].getName(),mapper.writeValueAsString(args[i]));
        }
      }
      long start = System.currentTimeMillis();
      if (args == null || args.length == 0) {
        object = pjp.proceed();
      } else {
        object = pjp.proceed(args);
      }
      long cost = System.currentTimeMillis() - start;

      String method = "UNKNOWN";
      if(implMethod!=null&&implMethod.getDeclaringClass().getInterfaces().length>0){
        Method interfaceMethod =
          implMethod.getDeclaringClass()
            .getInterfaces()[0]
            .getMethod(
              implMethod.getName(),
              implMethod.getParameterTypes()
            );
        if (interfaceMethod.isAnnotationPresent(Select.class)) {
          method = "SELECT";
        } else if (interfaceMethod.isAnnotationPresent(Update.class)) {
          method = "UPDATE";
        } else if (interfaceMethod.isAnnotationPresent(Insert.class)) {
          method = "INSERT";
        } else if (interfaceMethod.isAnnotationPresent(Delete.class)) {
          method = "DELETE";
        }
      }
      Map<String,Object> resultSummary = summarize(object);
      map.put("ntss-admin-web","SQL-LOG");
      map.put("result", resultSummary);
      map.put("parameters", paramMap);
      map.put("className", className);
      map.put("methodName", methodName);
      map.put("sqlType", method);
      map.put("cost",cost);
      eventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO,eventLogMessage , "", LoggingConstant.SERVICE_NAME.FNSI, null);
    } catch (Throwable throwable) {
      map.put("throwable",throwable.getMessage());
      eventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      throw throwable;
    }
    return object;
  }

  /**
   * メソッドがgetJdbcLogger場合、戻り値をNtssUtilLoggingJdbcLoggerに変更する
   * @param pjp
   */
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
//    } catch (Throwable throwable) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(throwable.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
//    }
//
//    return object;
//  }
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang end

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
    if (SecurityContextHolder.getContext().getAuthentication() != null) {
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
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
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang start
    }else{
      eventLogMessage.setUserId("");
      // 施設コード
      eventLogMessage.setFacilityCd("");
      // 接続先IPアドレス
      eventLogMessage.setClientIp("");
      // セッションID
      eventLogMessage.setSessionId("");
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang end
    }
    if (StringUtils.isEmpty(eventLogMessage.getFacilityCd()) && isFacilitycd(facilitycd)) {
      eventLogMessage.setFacilityCd(facilitycd);
    }

    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
    eventLogMessage.setLogMessage(message);

    logService.log(level, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
  }

}
