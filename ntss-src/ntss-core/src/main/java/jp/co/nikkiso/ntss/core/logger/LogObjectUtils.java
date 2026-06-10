package jp.co.nikkiso.ntss.core.logger;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import org.springframework.core.io.ClassPathResource;
import org.springframework.util.FileCopyUtils;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.io.InputStream;
import java.net.InetAddress;
import java.nio.charset.StandardCharsets;
import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.StringJoiner;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryPoolMXBean;
import java.lang.management.MemoryUsage;
import java.lang.management.OperatingSystemMXBean;

/**
 * ログ出力のユーティリティクラス.
 */
public class LogObjectUtils {

  //FNSI-修正 ログ対応 xiebzh add start
  /**
   * 出力するログレベル(情報)
   */
  private static final String LogLevel_INFO = "info";

  /**
   * 出力するログレベル(警告)
   */
  private static final String LogLevel_WARN = "warn";

  /**
   * 出力するログレベル(エラー)
   */
  private static final String LogLevel_ERROR = "error";

  /**
   * 出力するログレベル(デバッグ)
   */
  private static final String LogLevel_DEBUG = "debug";

  /**
   * ログレベルのマッピング表
   *  key : restAPIのPathパラメータで送られてくるログレベル文字列
   *  value : ログレベル文字列に該当する{@link LogLevel}
   */
  private static final Map<String, LogLevel> logLevelMap = new HashMap<String, LogLevel>(){
    {
      // 情報
      put(LogLevel_INFO, LogLevel.INFO);
      // 警告
      put(LogLevel_WARN, LogLevel.WARN);
      // エラー
      put(LogLevel_ERROR, LogLevel.ERROR);
      // デバッグ
      put(LogLevel_DEBUG, LogLevel.DEBUG);
    }
  };
  //FNSI-修正 ログ対応 xiebzh add end

  /**
   * SQLファイルのベースディレクトリパス
   */
  private static final String BASE_SQL_DIR = "META-INF/jp/co/nikkiso/ntss/core/dao/";

  /**
   * SQLファイルに記述されているSQL文を取得する.
   *
   * @param filePath SQLパス(Dao名/SQLファイル名)
   *                 ※指定するSQLファイル名には拡張子は不要
   * @return SQL文
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public static String readSqlFile(String filePath) throws IOException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    InputStream is = null;
    try {
      is = new ClassPathResource(BASE_SQL_DIR + filePath + ".sql").getInputStream();
      String data = new String(FileCopyUtils.copyToByteArray(is), StandardCharsets.UTF_8);
      data = data.replaceAll("\\s+", " ");
      return data.trim();
    } catch (Exception e) {
      return "";
    } finally {
      if (is != null) {
        try {
          is.close();
        } catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
          throw new IOException("SQLファイルのクローズに失敗しました。", e);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
        }
      }
    }
  }

  /**
   * Javaアプリケーションを実行しているマシンのIPアドレスを取得する.
   * 例外が発生した場合、{@link NtssException} をスローする.
   *
   * @return IPアドレス
   * @throws NtssException IPアドレス取得に失敗した場合
   */
  public static String getHostAddress() throws NtssException{
    try {
      return InetAddress.getLocalHost().getHostAddress();
    } catch (Exception e) {
       // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      throw new NtssException("アプリケーションを実行しているマシンのIPアドレスの取得に失敗しました.", e.getCause());
    }
  }

  //FNSI-修正 ログ対応 xiebzh add start
  /**
   * Javaアプリケーションを実行しているマシンのホスト名を取得する.
   * 例外が発生した場合、{@link NtssException} をスローする.
   *
   * @return IPアドレス
   * @throws NtssException IPアドレス取得に失敗した場合
   */
  public static String getHostName() throws NtssException{
    try {
      String hostName = InetAddress.getLocalHost().getHostName();
      if (!StringUtils.isEmpty(hostName)) {
        return hostName;
      }

      return getHostAddress();
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      throw new NtssException("アプリケーションを実行しているマシンのホスト名の取得に失敗しました.", e.getCause());
    }
  }
  /**
   * 与えられた文字列のログレベルから該当する列挙型を取得する.
   * 与えられた文字列がnullもしくは空文字の場合はnullを返却する.
   * また、{@link LogLevel} にない場合もnullを返却する.
   *
   * @param strLogLevel 文字列のログレベル
   * @return 文字列のログレベルに該当する {@link LogLevel}
   */
  public static LogLevel getLogLevel(String strLogLevel) {
    // ログレベルがnulｌもしくは空文字の場合
    //　ログレベルのマッピング表にない場合
    if (StringUtils.isEmpty(strLogLevel) ||
      !logLevelMap.containsKey(strLogLevel)) {
      return null;
    }
    return logLevelMap.get(strLogLevel);
  }

  /**
   * サビース名取得
   * @param eventLogMessage
   * @return
   */
  public static String getServiceName(EventLogMessage eventLogMessage) {
    if (eventLogMessage == null) {
      return LoggingConstant.SERVICE_NAME.FNSI;
    }

    String serviceName = "";
    if (!StringUtils.isEmpty(eventLogMessage.getServiceName())) {
      serviceName = eventLogMessage.getServiceName();
    } else {
      serviceName = LoggingConstant.SERVICE_NAME.FNSI;
    }

    return serviceName;
  }
  //FNSI-修正 ログ対応 xiebzh add end

  // #8732 2023.06.26 add ログ強化 TDC片口 start
  /**
   * システム情報の取得
   * @return
   */
  public static String getSystemInfo() {

    String cpuInfo = getCpuInfo();
    String memoryInfo = getMemoryInfo();

    return "SYSTEM_INFO [" + cpuInfo + " / " + memoryInfo + "]";
  }

  /**
   * CPU利用情報取得
   * @return
   */
  private static String getCpuInfo() {
    DecimalFormat fmt = new DecimalFormat("###.####");
    DecimalFormat f2 = new DecimalFormat("##.#");

    OperatingSystemMXBean osMx = (OperatingSystemMXBean)
        ManagementFactory.getOperatingSystemMXBean();
    double loadAverage = osMx.getSystemLoadAverage();
    int processors = osMx.getAvailableProcessors();
    double average = 0.0;
    if (processors > 0) {
      average = (loadAverage * 100 / (double)processors);
    }
    return "CPU: " + f2.format(average) + "% (LoadAverage=" + fmt.format(loadAverage) + " Processors=" + processors + ")";
  }

  /**
   * メモリ利用情報取得
   * @return
   */
  private static String getMemoryInfo() {
    DecimalFormat f1 = new DecimalFormat("#,###MB");
    DecimalFormat f2 = new DecimalFormat("##.#");

    List<MemoryPoolMXBean> memoryPoolMxs  = ManagementFactory.getMemoryPoolMXBeans();
    StringJoiner poolStr = new StringJoiner(" / ");
    for (MemoryPoolMXBean memoryPoolMx : memoryPoolMxs) {
      MemoryUsage usage = memoryPoolMx.getUsage();
      long used = usage.getUsed() / (1024 * 1024);
      long committed = usage.getCommitted() / (1024 * 1024);
      long max = usage.getMax() / (1024 * 1024);
      double ratio = 0.0;
      if (max > 0) {
        ratio = (used * 100 / (double)max);
      }
      String info = memoryPoolMx.getName() +": Commit=" + f1.format(committed) + " Use=" + f1.format(used);
      if (max > 0) {
        info += " Max=" + f1.format(max) + " (" + f2.format(ratio) + "%)";
      }
      poolStr.add(info);
    }
    return poolStr.toString();
  }
  // #8732 2023.06.26 add ログ強化 TDC片口 end

  // #11810 2025.05.29 add ログ強化 TDC片口 start
  /**
   * スレッドグループ情報の取得
   * @return
   */
  public static String getThreadGroupInfo() {
    ThreadGroup currentThreadGroup = Thread.currentThread().getThreadGroup();

    String threadGroupInfo = "GroupName=" + currentThreadGroup.getName() + " ActiveCount=" + currentThreadGroup.activeCount();

    return "THREAD_INFO [" + threadGroupInfo + "]";
  }
  // #11810 2025.05.29 add ログ強化 TDC片口 end
}
