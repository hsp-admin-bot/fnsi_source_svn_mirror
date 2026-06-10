package jp.co.nikkiso.ntss.core.utils;

// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import org.apache.commons.lang3.StringUtils;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.Signature;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.http.HttpMethod;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.lang.reflect.Method;
import java.lang.reflect.Parameter;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;

public class LogAspectorToolsUtils {

  public static String resolveHttpType(Method method) {
    if (method.isAnnotationPresent(GetMapping.class)) return HttpMethod.GET.name();
    if (method.isAnnotationPresent(PostMapping.class)) return HttpMethod.POST.name();
    if (method.isAnnotationPresent(PutMapping.class)) return HttpMethod.PUT.name();
    if (method.isAnnotationPresent(DeleteMapping.class)) return HttpMethod.DELETE.name();
    if (method.isAnnotationPresent(PatchMapping.class)) return HttpMethod.PATCH.name();
    if (method.isAnnotationPresent(RequestMapping.class)) {
      RequestMapping rm = method.getAnnotation(RequestMapping.class);
      if (rm.method().length > 0) return rm.method()[0].name();
    }
    return "UNKNOWN";
  }

  public static HttpServletRequest getRequest() {
    ServletRequestAttributes attrs =
      (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
    return attrs != null ? attrs.getRequest() : null;
  }

  public static String toJson(Map<String, Object> map) {
    StringBuilder sb = new StringBuilder("{");
    map.forEach((k, v) -> sb.append("\"").append(k).append("\":\"").append(v).append("\","));
    if (sb.charAt(sb.length() - 1) == ',') sb.setLength(sb.length() - 1);
    sb.append("}");
    return sb.toString();
  }

  public static Map<String, Object> summarize(Object result) {
    Map<String, Object> json = new LinkedHashMap<>();
    if (result == null) {
      json.put("kind", "null");
      return json;
    }else if (result instanceof Optional<?>) {
      json.put("kind", "optional");
      json.put("present", ((Optional<?>) result).isPresent());
      return json;
    }else if (result instanceof Collection<?>) {
      json.put("kind", "list");
      json.put("size", ((Collection<?>) result).size());
      return json;
    }else if (result instanceof Map<?, ?>) {
      json.put("kind", "map");
      json.put("size", ((Map<?, ?>) result).size());
      return json;
    }else if (result instanceof Integer) {
      json.put("kind", "affected");
      json.put("count", result);
      return json;
    }else if (result instanceof int[] arr) {
      json.put("kind", "batch");
      json.put("size", arr.length);
      json.put("affected", Arrays.stream(arr).sum());
      return json;
    }else if (result instanceof Boolean) {
      json.put("kind", "boolean");
      json.put("value", result);
      return json;
    }
    ObjectMapper mapper = new ObjectMapper();
    try {
      String jsonResult = mapper.writeValueAsString(result);
      json.put("value", jsonResult);
    } catch (JsonProcessingException e) {
      e.getMessage();
    }

    json.put("kind", "entity");
    json.put("type", result.getClass().getSimpleName());

    return json;
  }

  public static String getIpAddr(HttpServletRequest request) {
    String ip = request.getHeader("X-Forwarded-For");
    if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
      ip = request.getHeader("Proxy-Client-IP");
    }
    if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
      ip = request.getRemoteAddr();
    }
    if (ip != null && ip.contains(",")) {
      ip = ip.split(",")[0];
    }
    return ip;
  }

  /**
   * クラス名取得
   * @param joinPoint
   * @return
   */
  public static String getClassName(JoinPoint joinPoint) {
    String className = joinPoint.getTarget().getClass().getName();
    if (className.contains("$")) {
      className = className.substring(0, className.indexOf("$"));
    }
    return className;
  }

  /**
   * メソッド名取得
   * @param joinPoint
   * @return
   */
  public static String getMethodName(JoinPoint joinPoint) {
    return joinPoint.getSignature().getName();
  }

  /**
   * パラメータ名称を取得する
   * @param joinPoint
   */
  public static String[] getParameterName(JoinPoint joinPoint) {
    Signature signature = joinPoint.getSignature();
    MethodSignature methodSignature = (MethodSignature) signature;
    return methodSignature.getParameterNames();
  }

  /**
   * 施設コードチェック
   * @param facilitycd
   * @return
   */
  public static boolean isFacilitycd(String facilitycd) {
    if (StringUtils.isEmpty(facilitycd)) {
      return false;
    }else if (facilitycd.contains(",") || facilitycd.contains("[") || facilitycd.contains("]") || facilitycd.contains(" ")) {
      return false;
    }
    return facilitycd.length() <= 6;
  }

  public static String stackTraceToString(String exceptionName, String exceptionMessage, StackTraceElement[] elements) {
    StringBuilder stringBuilder = new StringBuilder();
    for (StackTraceElement stet : elements) {
      stringBuilder.append(stet).append("\n");
    }
    return exceptionName + ":" + exceptionMessage + "\n\t" + stringBuilder;
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

  public static EventLogMessage aspectorLogEventLogMessage(ProceedingJoinPoint joinPoint, Object result, long costTime, Exception exception,String module){
    EventLogMessage eventLogMessage = new EventLogMessage();
    Map<String, Object> map = new HashMap<>();
    ServletRequestAttributes attrs = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes());
    String ipAddr;
    String fullUrl;
    if( attrs != null){
      HttpServletRequest request = attrs.getRequest();
      ipAddr = getIpAddr(request);
      fullUrl = request.getRequestURL().toString();
    }else{
      ipAddr = null;
      fullUrl = null;
    }
    MethodSignature signature = (MethodSignature) joinPoint.getSignature();
    Method method = signature.getMethod();
    String httpType = resolveHttpType(method);
    String methodName = signature.getDeclaringTypeName() + "." + signature.getName();
    String className = getClassName(joinPoint);
    Parameter[] parameters = signature.getMethod().getParameters();
    Object[] args = joinPoint.getArgs();
    map.put(module,"CONTROLLER-LOG");
    map.put("ipAddr",ipAddr);
    map.put("url",fullUrl);
    map.put("className", className);
    map.put("methodName", methodName);
    map.put("httpType", httpType);
    map.put("cost",costTime);
    if(exception!=null){
      map.put("Exception",exception.getMessage());
    }
    if(result!=null){
      map.put("result",  result.getClass().getName());
    }else{
      map.put("result", null);
    }
    map.put("parameters", filterParam(args,parameters));
    eventLogMessage.setLogMessage(toJson(map));
    return eventLogMessage;
  }

  private static String filterParam(Object[] args,Parameter[] parameters) {
    Map<String, Object> paramMap = new HashMap<>();
    for (int i = 0; i < parameters.length; i++) {
      Class<?> type = parameters[i].getType();
      if (!(MultipartFile.class.isAssignableFrom(type))
        &&!(HttpServletRequest.class.isAssignableFrom(type))
        &&!(HttpServletResponse.class.isAssignableFrom(type))
        &&!(BindingResult.class.isAssignableFrom(type))
        &&!(type.isArray() && MultipartFile.class.isAssignableFrom(type.getComponentType()))) {
        paramMap.put(parameters[i].getName(), args[i]);
      }
    }
    return toJson(paramMap);
  }

}
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
