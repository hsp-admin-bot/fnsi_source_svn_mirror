package jp.co.nikkiso.ntss.core.utils;

import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.encoder.PatternLayoutEncoder;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.rolling.RollingFileAppender;
import ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy;
import ch.qos.logback.core.util.FileSize;
import com.sun.management.OperatingSystemMXBean;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import org.slf4j.LoggerFactory;
import org.springframework.util.Assert;

import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.MemoryUsage;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class InvestigateLogUtils {

    /**
     * #11205 ペンテスト2-4 認可制御の不備 調査モードフラグ
     * true  = 調査モード：認可違反を検出してもログに記録するのみで処理を続行する（本番影響を回避）
     * false = 本番モード：認可違反を検出した場合は HTTP 403 FORBIDDEN を返す
     */
    public static boolean enable_log_for_11205 = true;

    private static Map<String,String> projectMap = new HashMap<>();
    static {
        projectMap.put("admin_web","ntss-admin-web");
        projectMap.put("alive_moni","alive_moni");
        projectMap.put("alive_moni_auto","alive_moni_auto");
        //projectMap.put("api","skip");
        projectMap.put("client_comm","ntss-client-comm");
        projectMap.put("coop_api","ntss-coop-api");
        //projectMap.put("core","skip");
        projectMap.put("data_gathering","data_gathering");
        projectMap.put("data_gathering_auto","data_gathering_auto");
        projectMap.put("device_edge","device_edge");
        projectMap.put("device_edge_updater","device_edge_updater");
        projectMap.put("m_notice","ntss-m-notice");
        projectMap.put("web_api","ntss-web-api");
    }

    private static String projectName = "other";

    public static void getProjectName() {
        if(!projectName.equals("other")) {
            return;
        }
        boolean startFlag = false;
        StackTraceElement[] stackTraceElements = Thread.currentThread().getStackTrace();
        for (StackTraceElement stackTraceElement : stackTraceElements) {
            String className = stackTraceElement.getClassName();
            if("jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils".equals(className)) {
                startFlag = true;
            }
            if(startFlag) {
                if(className.startsWith("jp.co.nikkiso.ntss.")) {
                    className = className.replace("jp.co.nikkiso.ntss.", "");
                    String words[] = className.split("\\.");
                    String appNamePackage = words[0];
                    if("api".equals(appNamePackage) || "core".equals(appNamePackage) ) {
                        continue;
                    }
                    if(projectMap.containsKey(appNamePackage)) {
                        projectName = projectMap.get(appNamePackage);
                        break;
                    }
                }
            }
        }
    }

    public static void info(String subPath,String msg){
        Logger logger = getLoggerCustom("log",subPath);
        if(logger == null) {
            return;
        }
        logger.info(msg);
    }


    public static void info(String loggerName,String msg,String subPath){
        Logger logger = getLoggerCustom(loggerName,subPath);
        if(logger == null) {
            return;
        }
        // 获取调用者信息（包含行号）
        String callerInfo = getCallerInfoWithLineNumber();
        String fullMsg = "[" + callerInfo + "] " + msg;
        logger.info(fullMsg);
    }

    public static void info(String loggerName, String msg, String subPath, int callerLevel){
        Logger logger = getLoggerCustom(loggerName,subPath);
        if(logger == null) {
            return;
        }
        // callerLevel=1: InvestigateLogUtils.info()の呼び出し元、callerLevel=2: その一つ上の呼び出し元
        String callerInfo = getCallerInfoWithLineNumber(callerLevel);
        String fullMsg = "[" + callerInfo + "] " + msg;
        logger.info(fullMsg);
    }

    private static ThreadLocal<HashMap<String, Long>> infoKeyTL = ThreadLocal.withInitial(() -> new HashMap<>());
    public static void startTask(String subPath,String infoKey) {
      HashMap<String, Long> map = infoKeyTL.get();
      map.put(subPath + "-" + infoKey, System.currentTimeMillis());
    }

    public static void endTask(String subPath,String infoKey) {
      HashMap<String, Long> map = infoKeyTL.get();
      boolean isContains = map.containsKey(subPath + "-" + infoKey);
      Assert.isTrue(isContains, "can not find startTask("+infoKey+")");
      Long startTime = map.get(subPath + "-" + infoKey);
      Long duration = System.currentTimeMillis() - startTime;
      info("log", infoKey + " cost：" + duration + " ms", subPath);
      map.remove(subPath + "-" + infoKey);
    }

    public static Logger getLoggerCustom(String loggerName,String subPath){
        getProjectName();
        subPath = subPath == null ? "" : subPath + "/";
        String serverName = LogObjectUtils.getHostName();
        Logger logger = (Logger) LoggerFactory.getLogger(loggerName);
        if(logger.getAppender("custom") != null) {
            return logger;
        }
        // 上下文取得
        final LoggerContext lc = (LoggerContext) LoggerFactory.getILoggerFactory();

        // 日志归档
        final RollingFileAppender<ILoggingEvent> fileAppender = new RollingFileAppender<>();
        fileAppender.setName("custom");
        fileAppender.setFile("/efs/PerformanceLog/" + subPath + projectName + "__" + serverName + "__" + loggerName + ".log");
        fileAppender.setAppend(true);
        fileAppender.setContext(lc);

        // 基于时间的轮换设置
        final SizeAndTimeBasedRollingPolicy<ILoggingEvent> rollingPolicy = new SizeAndTimeBasedRollingPolicy<>();
        rollingPolicy.setFileNamePattern("/efs/PerformanceLog/" + subPath  + projectName + "__" + serverName + "__" + loggerName + "__%d{yyyyMMdd}_%i.log.gz");
        rollingPolicy.setMaxHistory(10);
        rollingPolicy.setParent(fileAppender);
        rollingPolicy.setContext(lc);
        rollingPolicy.setMaxFileSize(FileSize.valueOf("200MB"));
        rollingPolicy.start();

        // 日志输出编码取得
        final PatternLayoutEncoder ple = new PatternLayoutEncoder();
        ple.setPattern("%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n");
        ple.setContext(lc);
        ple.setCharset(StandardCharsets.UTF_8);
        ple.start();

        fileAppender.setRollingPolicy(rollingPolicy);
        fileAppender.setEncoder(ple);
        fileAppender.start();

        logger.addAppender(fileAppender);
        logger.setAdditive(false);
        return logger;
    }

    private static MemoryMXBean memoryMXBean = null;
    private static MemoryUsage heapMemoryUsage = null;
    public static String outputJvmMemoryUsage() {
        // 获取ManagementFactory中的MemoryMXBean
        if(memoryMXBean == null){
          memoryMXBean = ManagementFactory.getMemoryMXBean();
        }
        // 获取JVM的堆内存使用情况
        if(heapMemoryUsage == null ) {
          heapMemoryUsage = memoryMXBean.getHeapMemoryUsage();
        }
        // 获取JVM的非堆内存使用情况
        //    MemoryUsage nonHeapMemoryUsage = memoryMXBean.getNonHeapMemoryUsage();
        // 获取当前CPU使用率
        OperatingSystemMXBean osBean = (OperatingSystemMXBean) ManagementFactory.getOperatingSystemMXBean();
        double cpuUsage = osBean.getProcessCpuLoad();
        String memoryInfo =  "  【Heap Memory =》 " +
                "Init:" + heapMemoryUsage.getInit() / 1024 / 1024 + "MB" +
                ",Used:" + heapMemoryUsage.getUsed() / 1024 / 1024 + "MB" +
                ",Committed:" + heapMemoryUsage.getCommitted() / 1024 / 1024 + "MB" +
                ",Max: " + heapMemoryUsage.getMax() / 1024 / 1024 + "MB】" +
                //      "   【Non-Heap Memory =》 " +
                //      "Init: " + nonHeapMemoryUsage.getInit() / 1024 / 1024 + "MB" +
                //      "，Used: " + nonHeapMemoryUsage.getUsed() / 1024 / 1024 + "MB" +
                //      "，Committed: " + nonHeapMemoryUsage.getCommitted() / 1024 / 1024 + "MB" +
                //      "，Max: " + nonHeapMemoryUsage.getMax() / 1024 / 1024 + "MB】" +
                "【Current CPU usage:" + cpuUsage * 100 + "%】";
         return memoryInfo;
    }

    /**
     * 获取调用者的类名、方法名和行号（处理代理类）
     * @return 调用者信息，格式：类名。方法名：行号
     */
    public static String getCallerInfoWithLineNumber() {
        return getCallerInfoWithLineNumber(1);
    }

    public static String getCallerInfoWithLineNumber(int callerLevel) {
        try {
            StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
            int targetCallerLevel = Math.max(1, callerLevel);

            // 跳过前面的栈帧：getStackTrace, getCallerInfoWithLineNumber, info
            int startIndex = 0;
            for (int i = 0; i < stackTrace.length; i++) {
                if (stackTrace[i].getClassName().equals(InvestigateLogUtils.class.getName())
                        && stackTrace[i].getMethodName().equals("info")) {
                    startIndex = i + 1;
                    break;
                }
            }

            // 从 info 方法的下一个栈帧开始查找实际的调用者
            int callerCount = 0;
            for (int i = startIndex; i < stackTrace.length; i++) {
                StackTraceElement element = stackTrace[i];
                String className = element.getClassName();

                // 跳过 InvestigateLogUtils 自身和 Spring 代理相关的类
                if (className.equals(InvestigateLogUtils.class.getName())) {
                    continue;
                }

                callerCount++;
                if (callerCount < targetCallerLevel) {
                    continue;
                }

                // 如果是 CGLIB 或 JDK 动态代理，尝试获取目标类
                Class<?> clazz = loadClass(className);
                if (clazz != null) {
                    String methodName = element.getMethodName();
                    int lineNumber = element.getLineNumber();

                    // 处理 CGLIB 代理
                    if (className.contains("$$EnhancerByCGLIB$$") || className.contains("$$FastClassBySpringCGLIB$$")) {
                        Class<?> targetClass = clazz.getSuperclass();
                        if (targetClass != null && !targetClass.equals(Object.class)) {
                            return targetClass.getSimpleName()+ ":" + lineNumber + "." + methodName + "()";
                        }
                    }

                    // 处理 JDK 动态代理实现的接口
                    if (clazz.isSynthetic() && className.contains("$Proxy")) {
                        // 对于 JDK 代理，尝试从方法签名中获取实际类信息
                        return extractRealClassName(element) + ":" + lineNumber + "." + methodName + "()";
                    }

                    // 普通类直接返回
                    return clazz.getSimpleName() + ":" + lineNumber + "." + methodName + "()";
                }

                // 如果类加载失败，使用类名
                return getSimpleClassName(className) + ":" + element.getLineNumber() + "." + element.getMethodName() + "()";
            }

            return "Unknown";
        } catch (Exception e) {
            return "Unknown";
        }
    }

    /**
     * 加载类（处理代理情况）
     */
    private static Class<?> loadClass(String className) {
        try {
            return Thread.currentThread().getContextClassLoader().loadClass(className);
        } catch (ClassNotFoundException e) {
            try {
                return Class.forName(className);
            } catch (Exception ex) {
                return null;
            }
        }
    }

    /**
     * 从代理类中提取真实类名
     */
    private static String extractRealClassName(StackTraceElement element) {
        String className = element.getClassName();

        // 移除 CGLIB 代理后缀
        if (className.contains("$$EnhancerByCGLIB$$")) {
            return getSimpleClassName(className.substring(0, className.indexOf("$$EnhancerByCGLIB$$")));
        }
        if (className.contains("$$FastClassBySpringCGLIB$$")) {
            return getSimpleClassName(className.substring(0, className.indexOf("$$FastClassBySpringCGLIB$$")));
        }

        // JDK 动态代理返回接口名或去掉 $Proxy 后缀
        if (className.contains("$Proxy")) {
            return "Proxy";
        }

        return getSimpleClassName(className);
    }

    /**
     * 获取简单的类名（去掉包名）
     */
    private static String getSimpleClassName(String fullClassName) {
        if (fullClassName == null || fullClassName.isEmpty()) {
            return "Unknown";
        }

        int lastDot = fullClassName.lastIndexOf('.');
        if (lastDot > 0 && lastDot < fullClassName.length() - 1) {
            return fullClassName.substring(lastDot + 1);
        }
        return fullClassName;
    }
}
