package jp.co.nikkiso.ntss.device_edge_updater_front.aspect;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import jp.co.nikkiso.ntss.device_edge_updater_front.service.LogService;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Aspect
@Component("LogAspectorDeviceEdgeUpdaterFront")
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

// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
//  @Around("execution (* jp.co.nikkiso.ntss.admin_web.web.rest..*.*(..))")
  public Object  cutControllerLog(ProceedingJoinPoint joinPoint){
    ObjectMapper mapper = new ObjectMapper();
    MethodSignature signature = (MethodSignature) joinPoint.getSignature();
    Method method = signature.getMethod();
    String httpType = resolveHttpType(method);
    String methodName = signature.getDeclaringTypeName() + "." + signature.getName();
    String className = getClassName(joinPoint);
    HttpServletRequest request = getRequest();
    Object result = null;
    long start = System.currentTimeMillis();
    try {
      result = joinPoint.proceed();
    } catch (Throwable e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    String fullUrl = request != null ? request.getRequestURL().toString() : null;
    Parameter[] parameters = signature.getMethod().getParameters();
    Object[] args = joinPoint.getArgs();
    Map<String,Object> paramMap = new  HashMap<>();
    for (int i = 0; i < parameters.length; i++) {
      try {
        paramMap.put(parameters[i].getName(),mapper.writeValueAsString(args[i]));
      } catch (JsonProcessingException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }

    long cost = System.currentTimeMillis() - start;
    Map<String, Object> map = new HashMap<>();
    map.put("LogAspectorDeviceEdgeUpdaterFront","CONTROLLER-LOG");
    if(result!=null){
      map.put("result", summarize(result.getClass().getSimpleName()));
    }else{
      map.put("result", null);
    }

    map.put("parameters", paramMap);
    map.put("className", className);
    map.put("methodName", methodName);
    map.put("httpType", httpType);
    map.put("url",fullUrl);
    map.put("cost",cost);
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(toJson(map));
    logService.log(LogLevel.INFO,eventLogMessage , "", LoggingConstant.SERVICE_NAME.FNSI, null);

    return result;
  }
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
  @Pointcut(value = "execution (* jp.co.nikkiso.ntss.device_edge_updater_front.service..*.*(..))")
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
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(throwable));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
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
      if (!StringUtils.isEmpty(className) && className.indexOf("LogServiceImpl") >= 0) {
        return;
      }
      String methodName = getMethodName(joinPoint);
      outputLog(className, methodName, joinPoint, OUTPUT_KBN.AFTER, "");
    } catch (Throwable throwable) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(throwable));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
  }

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

// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
  @Around("execution(* jp.co.nikkiso.ntss.core.dao..*(..))")
  public Object cutDaoPoint(ProceedingJoinPoint pjp) {
    Object object = null;
    MethodSignature sig = (MethodSignature) pjp.getSignature();
    Method implMethod = sig.getMethod();
    try {

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

      Map<String, Object> map = new HashMap<>();
      map.put("LogAspectorDeviceEdgeUpdaterFront","SQL-LOG");
      map.put("result", resultSummary);
      map.put("parameters", paramMap);
      map.put("className", className);
      map.put("methodName", methodName);
      map.put("sqlType", method);
      map.put("cost",cost);
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO,eventLogMessage , "", LoggingConstant.SERVICE_NAME.FNSI, null);
    } catch (Throwable throwable) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(throwable);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    return object;
  }
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
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

    logService.log(level, eventLogMessage, "", LoggingConstant.SERVICE_NAME.REMS, null);
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
