package jp.co.nikkiso.ntss.core.logger;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy;
import ch.qos.logback.core.util.FileSize;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.encoder.PatternLayoutEncoder;
import ch.qos.logback.classic.joran.JoranConfigurator;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.joran.spi.JoranException;
import ch.qos.logback.core.rolling.RollingFileAppender;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import lombok.extern.slf4j.Slf4j;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * ロガー生成コンポーネント
 */
@Component
@Slf4j
public class EventLoggerFactory {

  /**
   * ログファイルを１つにまとめる際のロガー名.
   */
  private static final String DEFAULT_LOGGER_NAME = "system";
  /**
   * システム設定マスタのDaoインタフェース
   */
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  /**
   * アプリケーションログのプロパティクラス
   */
  @Autowired
  private ApplicationLoggingProperties applicationLoggingProperties;

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogServiceCore logServiceCore;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

  private static Map<String, String> projectMap = new HashMap<String, String>();

  static {
    projectMap.put("admin_web", "ntss-admin-web");
    projectMap.put("alive_moni", "alive_moni");
    projectMap.put("alive_moni_auto", "alive_moni_auto");
    projectMap.put("client_comm", "ntss-client-comm");
    projectMap.put("coop_api", "ntss-coop-api");
    projectMap.put("data_gathering", "data_gathering");
    projectMap.put("data_gathering_auto", "data_gathering_auto");
    projectMap.put("device_edge", "device_edge");
    projectMap.put("device_edge_updater", "device_edge_updater");
    projectMap.put("m_notice", "ntss-m-notice");
    projectMap.put("web_api", "ntss-web-api");
  }

  // 設定済みのロガー名を保持する
  /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
  // private static List<String> loggerNameList = new ArrayList<>();
  private static Set<String> loggerNameList = ConcurrentHashMap.newKeySet();
  /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
  //　ロガーリセットフラグ用の定数
  final static String LOGGER_RESET_FLG = "LoggerResetFlg";

  /**
   * ロガーを取得する.
   * ※イベントロガーを取得する.
   * <p>
   *  施設別にログファイルを分割出力する際に使用します。
   * </p>
   * @param facilityCd 施設コード
   * @return ロガー
   */
  public EventLogger getLogger(String facilityCd) {
    // FNSI-修正 Eventログ削除対応 xiebzh add start
    //return getLogger(facilityCd, LogClass.EVENT);
    return getLogger(facilityCd, LogClass.APP);
    // FNSI-修正 Eventログ削除対応 xiebzh add end
  }

  /**
   * アプリンケーションロガー又はイベントロガーを取得する.
   * <code>logClass</code>が未指定の場合、イベントログのロガーを返却する.
   * <p>
   *  施設別にログファイルを分割出力する際に使用します。
   * </p>
   * @param facilityCd 施設コード
   * @param logClass ログ区分
   * @return ロガー
   */
  public EventLogger getLogger(String facilityCd, LogClass logClass) {
    // 施設コードが未指定の場合
    if (!StringUtils.hasLength(facilityCd)) {
      throw new IllegalArgumentException("facilityCd is Null or Empty");
    }



    // ログ区分が未指定の場合はイベントログとする.
    if (logClass == null) {
      // FNSI-修正 Eventログ削除対応 xiebzh add start
      //logClass = LogClass.EVENT;
      logClass = LogClass.APP;
      // FNSI-修正 Eventログ削除対応 xiebzh add start
    }
    // ロガー名
    final String loggerName = getLoggerName(facilityCd, logClass);
    // ロガー取得
    final Logger logger = (Logger) LoggerFactory.getLogger(loggerName);
    synchronized (logger) {
      // 対応するロガーが未設定の場合
      /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
      // if (loggerNameList.indexOf(loggerName) == -1) {
      if (!loggerNameList.contains(loggerName)) {
      /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
        String projectName = defaultTag();
        String serverName = LogObjectUtils.getHostName();
        //FNSI-修正 #8295、デバイスサーバの連携サービスのログが出力されないの修正、xugj del start
//        // 設定済みロガーリストに含める
//        loggerNameList.add(loggerName);
        //FNSI-修正 #8295、デバイスサーバの連携サービスのログが出力されないの修正、xugj del end
        // ログプロパティクラス取得
        final LoggingProperties loggingProperties = getLoggingProperties(logClass);
        // del 2023-03-09 bug #8295 デバイスサーバの連携サービスのログが出力されない 孫 start
//        //FNSI-修正 #8295、デバイスサーバの連携サービスのログが出力されないの修正、xugj add start
//        // 設定済みロガーリストに含める
//        loggerNameList.add(loggerName);
//        //FNSI-修正 #8295、デバイスサーバの連携サービスのログが出力されないの修正、xugj add end
        // del 2023-03-09 bug #8295 デバイスサーバの連携サービスのログが出力されない 孫 end
        boolean isOutputFlg = getOutFlg(projectName, loggingProperties.getOutFlg());
        // アプリケーションログを出力しない設定の場合
        if (!isOutputFlg){
          return new EventLogger(null);
        }
        // コンテキスト取得
        final LoggerContext lc = (LoggerContext) LoggerFactory.getILoggerFactory();
        /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
        // if (loggerNameList.indexOf(LOGGER_RESET_FLG) > -1) {
        if (loggerNameList.contains(LOGGER_RESET_FLG)) {
        /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
          // ロガーの初期化フラグが立ったので初期化する ( 設定のリセット　→ 初期設定ファイルの再読み込みを実施 )
          lc.reset();
          JoranConfigurator config = new JoranConfigurator();
          config.setContext(lc);
          // ntss-admin-web モジュールのみ、そのままではコンソールログ出力に影響があるので、モジュール内のファイルを指定して読み込みを実施
          if (projectMap.get(projectName) != null && projectMap.get(projectName).equals("ntss-admin-web")) {
            try {
              String testPath = "src/main/resources/logback-spring.xml";
              config.doConfigure(testPath);
            } catch (JoranException e) {
              // 読み込みに失敗していても、影響はコンソールログ出力が止まるのみです。それ以外の処理、アプリケーションログの出力に影響はありません。
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              if (!StringUtils.isEmpty(facilityCd)) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
              logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
            }
          }
          // 初期化が終わったら初期化フラグを除去する
          /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
          // loggerNameList.remove(loggerNameList.indexOf(LOGGER_RESET_FLG));
          loggerNameList.remove(LOGGER_RESET_FLG);
          /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
        }


        // ログ出力エンコード取得
        final PatternLayoutEncoder ple = new PatternLayoutEncoder();
        ple.setPattern("\"%d{yyyy/MM/dd HH:mm:ss}\",%msg%n"); // ログメッセージはCSV形式で出力
        ple.setContext(lc);
        ple.setCharset(StandardCharsets.UTF_8);
        ple.start();
        // ローテーションの設定取得
        final RollingFileAppender<ILoggingEvent> fileAppender = new RollingFileAppender<>();
        fileAppender.setName(loggerName);
        fileAppender.setFile(loggingProperties.getFileName(facilityCd, projectMap.get(projectName), serverName));

        fileAppender.setAppend(true);
        fileAppender.setContext(lc);
        // 時刻ベースのローテーションの設定取得
        final SizeAndTimeBasedRollingPolicy<ILoggingEvent> rollingPolicy = new SizeAndTimeBasedRollingPolicy<>();
        rollingPolicy.setFileNamePattern(loggingProperties.getFileNamePattern(facilityCd, serverName, projectMap.get(projectName)));
        rollingPolicy.setMaxHistory(loggingProperties.getMaxHistory());
        rollingPolicy.setParent(fileAppender);
        rollingPolicy.setContext(lc);
        // ログ出力ロジック xie start
        long fileSize = loggingProperties.getMaxFileSize();
        FileSize fs = FileSize.valueOf(fileSize + "MB");
        rollingPolicy.setMaxFileSize(fs);
        // ログ出力ロジック xie end
        rollingPolicy.start();

        fileAppender.setRollingPolicy(rollingPolicy);
        fileAppender.setEncoder(ple);
        fileAppender.start();

        logger.addAppender(fileAppender);
        logger.setAdditive(false);

        // add 2023-03-09 bug #8295 デバイスサーバの連携サービスのログが出力されない 孫 start
        // ※位置が移動しただけ
        // 設定済みロガーリストに含める
        loggerNameList.add(loggerName);
        // add 2023-03-09 bug #8295 デバイスサーバの連携サービスのログが出力されない 孫 end
      }
    }
    return new EventLogger(logger);
  }

  /**
   * ロガー設定を再読み込みさせる為に、フラグをリセットする.
   */
  public void resetFlg() throws Exception {
    loggerNameList.clear();
    loggerNameList.add(LOGGER_RESET_FLG);
  }

  private static Map<String, String> getOutFlgMap(String outFlg) {
    // ntss-admin-web=1,ntss-client-comm=1,ntss-web-api=1,ntss-coop-api=1,device_edge=1,ntss-m-notice=1,device_edge_updater=1,data_gathering=1,data_gathering_auto=1,alive_moni=1,alive_moni_auto=1
    Map<String, String> outFlgMap = new HashMap<String, String>();
    String[] outFlgs = outFlg.split(",");
    if (outFlgs != null) {
      for (int i = 0; i < outFlgs.length; i++) {
        String project = outFlgs[i].trim();;
        String[] projectSet = project.split("=");
        if (projectSet != null && projectSet.length == 2) {
          outFlgMap.put(projectSet[0].trim(), projectSet[1].trim());
        }
      }
    }
    return outFlgMap;
  }

  private static boolean getOutFlg(String projectName, String outFlg) {
    if (StringUtils.isEmpty(projectName) || StringUtils.isEmpty(outFlg)) {
      return false;
    }

    Map<String, String> map = getOutFlgMap(outFlg);
    String convertProjectMap=  projectMap.get(projectName);
    if (StringUtils.isEmpty(convertProjectMap)) {
      return false;
    }

    if (map != null) {
      String value = map.get(convertProjectMap);
      if (StringUtils.isEmpty(value)) {
        return false;
      }
      if ("1".equals(value.trim())) {
        return true;
      } else {
        return false;
      }
    }

    return false;
  }



  private static String getProjectName(String className) {
    String[] backendNames = className.split("\\.");
    if (backendNames != null && backendNames.length >= 5) {
      return backendNames[4];
    }

    return "other";
  }

  private static String defaultTag() {
    try {
      StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
      StackTraceElement log = stackTrace[1];
      String tag = null;
      for (int i = 1; i < stackTrace.length; i++) {
        StackTraceElement e = stackTrace[i];
        if (!e.getClassName().equals(log.getClassName())) {
          tag = e.getClassName();
          break;
        }
      }
      if (tag == null) {
        tag = log.getClassName();

      }
      return getProjectName(tag);
    } catch (Exception e) {
      return "other";
    }
  }


  /**
   * ロガーを取得する.
   * <p>
   * ログファイルを１つにまとめて出力する際に使用します。
   * </p>
   * @return ロガー
   */
  public EventLogger getLogger() {
    // FNSI-修正 eventログ削除 xiebzh add start
    //return getLogger(DEFAULT_LOGGER_NAME);
    return getLogger(DEFAULT_LOGGER_NAME, LogClass.APP);
    // FNSI-修正 eventログ削除 xiebzh add end
  }

  /**
   * ログ区分に該当するロガー取得文字列を取得する.
   *
   * @param facilityCd 施設コード
   * @param logClass ログ区分
   * @return ロガー取得文字列
   */
  private String getLoggerName(String facilityCd, LogClass logClass) {
    StringBuffer buf = new StringBuffer();
    buf.append(logClass.name()).append("-").append(facilityCd);
    return buf.toString();
  }

  /**
   * ログ区分におけるログプロパティクラスを取得する.
   * ※<code>logClass</code>が{@link LogClass#APP}以外の場合は、{@link EventLoggingProperties}を返す.
   *
   * @param logClass ログ区分
   * @return ログ区分に該当するログプロパティクラス
   */
  private LoggingProperties getLoggingProperties(LogClass logClass) {
    // FNSI-修正 Eventログ削除対応 xiebzh add start
    //if (LogClass.APP.equals(logClass)) {
    //  return factory(applicationLoggingProperties, CoreConstant.SysSystemDefine.APPLICATION_LOGGING);
    //}
    //return factory(eventLoggingProperties, CoreConstant.SysSystemDefine.EVENT_LOGGING);
    // FNSI-修正 Eventログ削除対応 xiebzh add start
    return factory(applicationLoggingProperties, CoreConstant.SysSystemDefine.APPLICATION_LOGGING);
  }

  /**
	 * 指定されたタイプに該当するデータベースからLoggingPropertiesを返す。
	 * @param log ログプロパティの抽象クラス
	 * @param type ログタイプ
	 * @return LoggingProperties
	 */
  private LoggingProperties factory(LoggingProperties log, int type) {
    List<SysSystemDefine> systemDefine = sysSystemDefineDao.selectByCtlNo(type);
    ObjectMapper objectMapper = new ObjectMapper();
    try {
      Map<String, String> infoLogger = objectMapper.readValue(systemDefine.get(0).getValue(), new TypeReference<Map<String, String>>() {});
      log.setFileName(infoLogger.get("path_output"));
      log.setFileNamePattern(infoLogger.get("file_pattern"));
      // ログ出力ロジック xie start
      String fileSize = infoLogger.get("max_file_size");
      if (StringUtils.isEmpty(fileSize)) {
        log.setMaxFileSize(100);
      } else {
        log.setMaxFileSize(Long.valueOf(fileSize));
      }

      log.setOutFlg(infoLogger.get("out_flg"));
      // ログ出力ロジック xie end
    } catch (Exception e) {
      log.setMaxFileSize(100);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    return log;
  }
}
