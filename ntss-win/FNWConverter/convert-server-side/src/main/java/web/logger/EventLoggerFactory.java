package web.logger;

import batch.ApplicationConst;
import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.encoder.PatternLayoutEncoder;
import ch.qos.logback.classic.joran.JoranConfigurator;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.rolling.RollingFileAppender;
import ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy;
import ch.qos.logback.core.util.FileSize;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;
import web.config.EventLoggerUtil;
import web.constant.CoreConstant;
import web.entity.SysSystemDefine;

import javax.sql.DataSource;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
/**
 * ロガー生成コンポーネント
 */
@Component
@Slf4j
public class EventLoggerFactory {

  @Autowired
  ApplicationContext appContext;

  /**
   * アプリケーションログのプロパティクラス
   */
  @Autowired
  private ApplicationLoggingProperties applicationLoggingProperties;

  /**
   * ロギング ツール クラスの導入
   */
  @Autowired
  private EventLoggerUtil eventLoggerUtil;

  private static Map<String, String> projectMap = new HashMap<String, String>();

  static {
    projectMap.put("convert", "convert-server-side");
  }

  // 設定済みのロガー名を保持する
  private static List<String> loggerNameList = new ArrayList<>();
  //　ロガーリセットフラグ用の定数
  final static String LOGGER_RESET_FLG = "LoggerResetFlg";

  @Autowired
  private Environment environment;


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
    String projectName = defaultTag();
    if ("other".equals(projectName)) {
      projectName = "convert";
    }
    String serverName = LogObjectUtils.getHostName();
    // ログ区分が未指定の場合はイベントログとする.
    if (logClass == null) {
      logClass = LogClass.APP;
    }
    // ロガー名
    final String loggerName = getLoggerName(facilityCd, logClass);
    // ロガー取得
    final Logger logger = (Logger) LoggerFactory.getLogger(loggerName);
    synchronized (logger) {
      // 対応するロガーが未設定の場合
      if (!loggerNameList.contains(loggerName)) {
        // 設定済みロガーリストに含める
        loggerNameList.add(loggerName);
        // ログプロパティクラス取得
        final LoggingProperties loggingProperties = getLoggingProperties(facilityCd);
        // コンテキスト取得
        final LoggerContext lc = (LoggerContext) LoggerFactory.getILoggerFactory();
        if (loggerNameList.contains(LOGGER_RESET_FLG)) {
          // ロガーの初期化フラグが立ったので初期化する ( 設定のリセット　→ 初期設定ファイルの再読み込みを実施 )
          lc.reset();
          JoranConfigurator config = new JoranConfigurator();
          config.setContext(lc);
          // 初期化が終わったら初期化フラグを除去する
          loggerNameList.remove(loggerNameList.indexOf(LOGGER_RESET_FLG));
        }
        // アプリケーションログを出力しない設定の場合

        // ログ出力エンコード取得
        final PatternLayoutEncoder ple = new PatternLayoutEncoder();
        ple.setPattern("%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %file:%line %logger{50}.%M - %msg%n");
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

        long fileSize = loggingProperties.getMaxFileSize();
        FileSize fs = FileSize.valueOf(fileSize + "MB");
        rollingPolicy.setMaxFileSize(fs);
        rollingPolicy.start();

        fileAppender.setRollingPolicy(rollingPolicy);
        fileAppender.setEncoder(ple);
        fileAppender.start();


        logger.addAppender(fileAppender);
        logger.setAdditive(false);
      }
    }
    return new EventLogger(logger);
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
   * ログ区分に該当するロガー取得文字列を取得する.
   *
   * @param facilityCd 施設コード
   * @param logClass ログ区分
   * @return ロガー取得文字列
   */
  private String getLoggerName(String facilityCd, LogClass logClass) {
    StringBuilder buf = new StringBuilder();
    buf.append(logClass.name()).append("-").append(facilityCd);
    return buf.toString();
  }

  /**
   * ログ区分におけるログプロパティクラスを取得する.
   * ※<code>logClass</code>が{@link LogClass#APP}以外の場合は、{@link EventLoggingProperties}を返す.
   *
   * @return ログ区分に該当するログプロパティクラス
   */
  private LoggingProperties getLoggingProperties(String facilityCd) {
    return factory(applicationLoggingProperties, CoreConstant.SysSystemDefine.CONVERT_LOGGING, facilityCd);
  }




  /**
	 * 指定されたタイプに該当するデータベースからLoggingPropertiesを返す。
	 * @param log ログプロパティの抽象クラス
	 * @param type ログタイプ
	 * @return LoggingProperties
	 */
  private LoggingProperties factory(LoggingProperties log, int type, String facilityCd) {
    //nkk 5のパターンを指定する
    String table_prefix =  environment.getProperty("datasource.nkk5.table_prefix");
    //DBロギング構成の取得
    String sql = "select ctl_no as ctlNo, service_cd as serviceCd, name, value, description, " +
            "is_enable as isEnable, up_date as upDate  from " + table_prefix + "sys_system_define where ctl_no = ?";
    DataSource dataSource = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    SysSystemDefine systemDefine = new SysSystemDefine();
    List<SysSystemDefine> userList = jdbcTemplate.query(sql, new Object[]{type}, new BeanPropertyRowMapper<>(SysSystemDefine.class));
    if(!userList.isEmpty()){
       systemDefine = userList.get(0);
    }

    ObjectMapper objectMapper = new ObjectMapper();
    try {
      Map<String, String> infoLogger = objectMapper.readValue(systemDefine.getValue(), new TypeReference<Map<String, String>>() {});
      log.setFileName(infoLogger.get("path_output"));
      log.setFileNamePattern(infoLogger.get("file_pattern"));
      String fileSize = infoLogger.get("max_file_size");
      if (ObjectUtils.isEmpty(fileSize)) {
        log.setMaxFileSize(100);
      } else {
        log.setMaxFileSize(Long.valueOf(fileSize));
      }
      log.setOutFlg(infoLogger.get("out_flg"));
    } catch (Exception e) {
      log.setMaxFileSize(100);
      eventLoggerUtil.recordLog(
          facilityCd,
          eventLoggerUtil.getEventLogMessage(
                  "processCmdSql(String[] cmd, boolean status) Java呼び出しProcess実行CMDコマンド共通メソッド ：" + EventLoggerUtil.excetionStackTraceToString(e),
                   facilityCd,
                  e.getClass().getName() + ".processCmdSql()"),
          LogLevel.ERROR);
    }
    return log;
  }
}
