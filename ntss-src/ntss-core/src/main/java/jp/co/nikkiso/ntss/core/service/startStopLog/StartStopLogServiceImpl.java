package jp.co.nikkiso.ntss.core.service.startStopLog;


import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.utils.Ec2MetadataHelper;
import jp.co.nikkiso.ntss.core.logevent.LogEvent;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.lang.management.ManagementFactory;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 起動停止ログサービス実装クラス
 *
 * OS、Tomcat、アプリケーション（WAR/JAR）の起動・停止イベントを監視し、
 * MongoDBの「log_event」コレクションに記録する。
 *
 * 主な機能：
 * - OS起動/停止時刻の取得とログ記録
 * - Tomcat起動/停止イベントのログ記録
 * - WAR/JARアプリケーション起動/停止イベントのログ記録
 * - 重複レコード防止機能（主キー戦略）
 */
@Service
public class StartStopLogServiceImpl implements StartStopLogService {

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogServiceCore logServiceCore;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

  /** アプリケーション名（spring.application.nameプロパティから取得） */
  @Value("${spring.application.name:}")
  private String applicationName;

  /** ログ日時フォーマット（yyyyMMddHHmmssSSS形式） */
  private static final DateTimeFormatter targetFormatter =
    DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS");

  /** OS起動時刻を取得するためのLinuxコマンド（uptime -s は yyyy-MM-dd HH:mm:ss 形式で返す） */
  private static final String[] OS_BOOT_CMD = {
    "/bin/bash",
    "-c",
    "uptime -s"
  };
  /* 実行例:
     [root@ies-webapp-01 ~]# uptime -s
     2026-02-05 15:14:43
   */
  /** OS起動時刻の正規表現パターン（yyyy-MM-dd HH:mm:ss形式） */
  private static final Pattern OS_BOOT_TIME_PATTERN =
    Pattern.compile("(\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2})");

  /** MongoDBテンプレート（ログイベント保存に使用） */
  @Autowired(required = false)
  private MongoTemplate mongoTemplate;

  /**
   * OS最新起動時刻を取得する
   *
   * Linuxコマンド「uptime -s」を実行してシステム起動時刻を取得する。
   * コマンド出力（yyyy-MM-dd HH:mm:ss）から正規表現で日時文字列を抽出し、LocalDateTimeに変換する。
   *
   * @return OS起動時刻（取得失敗時はnull）
   */
  private LocalDateTime getOsLatestBootTime() {
    // MongoDBが利用できない場合は処理をスキップ
    if (mongoTemplate == null) {
      return null;
    }
    LocalDateTime osBootTime = null;
    try {
        // OS起動時刻取得コマンドを実行（uptime -s → 例: 2026-02-05 15:14:43）
        Process process = new ProcessBuilder(OS_BOOT_CMD)
                .redirectErrorStream(true)
                .start();
        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = br.readLine()) != null) {
              // 正規表現で日時部分を抽出（yyyy-MM-dd HH:mm:ss）
              Matcher matcher = OS_BOOT_TIME_PATTERN.matcher(line);
              if (!matcher.find()) {
                break;
              }
              String timeStr = matcher.group(1);
              DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
              // 文字列をLocalDateTimeに変換
              osBootTime = LocalDateTime.parse(timeStr, formatter);
            }
        }
        process.waitFor();
    } catch (Exception e) {
        // 例外発生時はnullを返す（ログ取得失敗）
        // log.warn("Failed to read OS boot logs", e);
    }
    return osBootTime;
  }

  /**
   * 最終シャットダウン時刻を取得する
   *
   * Linuxコマンド「last -F -x shutdown | head -1」を実行して
   * 最後のシステムシャットダウン時刻を取得する。
   * コマンド出力は英語形式の日時文字列（例：Mon Feb 05 15:14:00 2026）となるため、
   * 曜日部分を検索して日時文字列を組み立て、LocalDateTimeに変換する。
   *
   * @return 最終シャットダウン時刻（取得失敗時はnull）
   */
  public LocalDateTime getLastShutdownTime() {
    try {
      // シャットダウン履歴取得コマンドを実行
      ProcessBuilder pb = new ProcessBuilder(
        "bash",
        "-c",
        "LANG=C last -F -x shutdown | head -1"
      );

      Process process = pb.start();

      try (BufferedReader reader = new BufferedReader(
        new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {

        String line = reader.readLine();
        process.waitFor();

        // 出力が空の場合は処理終了
        if (line == null || line.isBlank()) {
          return null;
        }

        // 空白文字で分割
        String[] parts = line.split("\\s+");

        // 曜日部分（Mon, Tue, Wed等）のインデックスを検索
        int dayIndex = -1;
        for (int i = 0; i < parts.length; i++) {
          if (parts[i].matches("Mon|Tue|Wed|Thu|Fri|Sat|Sun")) {
            dayIndex = i;
            break;
          }
        }

        // 曜日が見つからない場合は処理終了
        if (dayIndex == -1) {
          return null;
        }

        // 曜日から始まる5要素を結合して日時文字列を作成
        // 形式：Mon Feb 05 15:14:00 2026
        String dateStr = String.join(" ",
          parts[dayIndex],
          parts[dayIndex + 1],
          parts[dayIndex + 2],
          parts[dayIndex + 3],
          parts[dayIndex + 4]
        );

        // 英語形式の日時フォーマッター
        DateTimeFormatter inputFormatter =
          DateTimeFormatter.ofPattern("EEE MMM d HH:mm:ss yyyy", Locale.ENGLISH);

        // 日時文字列をLocalDateTimeに変換
        LocalDateTime dateTime =
          LocalDateTime.parse(dateStr, inputFormatter);
        return dateTime;
      }

    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      return null;
    }
  }

  /**
   * OS起動ログを記録する
   *
   * OS起動時刻を取得し、「OS_BOOT」タイプのログイベントを作成してMongoDBに保存する。
   */
  @Override
  public void osBootLog() {
    // MongoDBが利用できない場合は処理をスキップ
    if (mongoTemplate == null) {
      return;
    }
    // OS起動時刻を取得
    LocalDateTime bootTime = getOsLatestBootTime();
    if(bootTime != null) {
      // 日時を指定フォーマットに変換
      String logDateStr = bootTime.format(targetFormatter);
      // ログイベントを作成
      LogEvent logEvent = makeLogEvent("OS_BOOT",logDateStr);
      // MongoDBに保存
      saveOsEventLog(logEvent);
    }
  }

  /**
   * OSシャットダウンログを記録する
   *
   * 最終シャットダウン時刻を取得し、「OS_DOWN」タイプのログイベントを作成してMongoDBに保存する。
   */
  @Override
  public void osDownLog() {
    // MongoDBが利用できない場合は処理をスキップ
    if (mongoTemplate == null) {
      return;
    }
    // 最終シャットダウン時刻を取得
    LocalDateTime bootTime = getLastShutdownTime();
    if(bootTime != null) {
      // 日時を指定フォーマットに変換
      String logDateStr = bootTime.format(targetFormatter);
      // ログイベントを作成
      LogEvent logEvent = makeLogEvent("OS_DOWN",logDateStr);
      // MongoDBに保存
      saveOsEventLog(logEvent);
    }
  }

  /**
   * Tomcat起動ログを記録する
   *
   * JVMランタイムから起動時刻を取得し、「TOMCAT_BOOT」タイプのログイベントを作成してMongoDBに保存する。
   * 主キー戦略により、同一EC2上の複数アプリケーションから重複してinsertされることを防止する。
   */
  @Override
  public void tomcatBootLog() {
    // MongoDBが利用できない場合は処理をスキップ
    if (mongoTemplate == null) {
      return;
    }
    // JVM起動時刻を取得（ミリ秒単位）
    long startTime = ManagementFactory.getRuntimeMXBean().getStartTime();
    // タイムゾーン付きフォーマッター作成
    DateTimeFormatter formatter =
      DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS").withZone(ZoneId.systemDefault());
    // エポックミリ秒をフォーマット済み文字列に変換
    String logDateStr = formatter.format(Instant.ofEpochMilli(startTime));
    // ログイベントを作成
    LogEvent logEvent = makeLogEvent("TOMCAT_BOOT",logDateStr);
    // 主キーを生成（ログタイプ_IP_日時）
    String id = logEvent.getLogType() + "_" + logEvent.getEc2Ip().replace(".","-") + "_" + logEvent.getLogDate();
    logEvent.set_id(id);
    try {
      // MongoDBに挿入
      mongoTemplate.insert(logEvent, "log_event");
    } catch (Exception e) {
      /*
        主キー重複例外は無視する。
        同一のEC2上に複数のwarまたはjarがデプロイされた場合、同じTOMCAT_BOOTレコードがinsertされることを防ぐため。
       */
    }
  }

  /**
   * Tomcat停止ログを記録する
   *
   * 「TOMCAT_DOWN」タイプのログイベントを作成してMongoDBに保存する。
   * 主キー戦略により、同一EC2上の複数アプリケーションから重複してinsertされることを防止する。
   */
  @Override
  public void tomcatDownLog() {
    // MongoDBが利用できない場合は処理をスキップ
    if (mongoTemplate == null) {
      return;
    }
    // JVM起動時刻を取得（停止時の時刻特定に使用）
    long startTime = ManagementFactory.getRuntimeMXBean().getStartTime();
    // タイムゾーン付きフォーマッター作成
    DateTimeFormatter formatter =
      DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS").withZone(ZoneId.systemDefault());
    // エポックミリ秒をフォーマット済み文字列に変換
    String logDateStr = formatter.format(Instant.ofEpochMilli(startTime));
    // ログイベントを作成
    LogEvent logEvent = makeLogEvent("TOMCAT_DOWN",logDateStr);
    // 主キーを生成（ログタイプ_IP_日時）
    String id = logEvent.getLogType() + "_" + logEvent.getEc2Ip().replace(".","-") + "_" + logEvent.getLogDate();
    logEvent.set_id(id);
    try {
      // MongoDBに挿入
      mongoTemplate.insert(logEvent, "log_event");
    } catch (Exception e) {
      /*
        主キー重複例外は無視する。
        同一のEC2上に複数のwarまたはjarがデプロイされた場合、同じTOMCAT_DOWNレコードがinsertされることを防ぐため。
       */
    }
  }

  /**
   * JARアプリケーション起動ログを記録する
   *
   * Spring Boot JARとして起動した場合のログイベントを作成してMongoDBに保存する。
   * 現在時刻を起動時刻として記録する。
   */
  @Override
  public void jarBootLog() {
    // MongoDBが利用できない場合は処理をスキップ
    if (mongoTemplate == null) {
      return;
    }
    // 現在時刻を取得
    LocalDateTime bootTime = LocalDateTime.now();;
    // 日時を指定フォーマットに変換
    String logDateStr = bootTime.format(targetFormatter);
    // ログイベントを作成
    LogEvent logEvent = makeLogEvent("JAR_BOOT",logDateStr);
    // MongoDBに保存
    mongoTemplate.insert(logEvent, "log_event");
  }

  /**
   * JARアプリケーション停止ログを記録する
   *
   * Spring Boot JARアプリケーションの停止ログイベントを作成してMongoDBに保存する。
   * 現在時刻を停止時刻として記録する。
   */
  @Override
  public void jarDownLog() {
    // MongoDBが利用できない場合は処理をスキップ
    if (mongoTemplate == null) {
      return;
    }
    // 現在時刻を取得
    LocalDateTime bootTime = LocalDateTime.now();;
    // 日時を指定フォーマットに変換
    String logDateStr = bootTime.format(targetFormatter);
    // ログイベントを作成
    LogEvent logEvent = makeLogEvent("JAR_DOWN",logDateStr);
    // MongoDBに保存
    mongoTemplate.insert(logEvent, "log_event");
  }

  /**
   * WARアプリケーション起動ログを記録する
   *
   * 外部Tomcatにデプロイされたアプリケーションの起動ログイベントを作成してMongoDBに保存する。
   * 現在時刻を起動時刻として記録する。
   */
  @Override
  public void warBootLog() {
    // MongoDBが利用できない場合は処理をスキップ
    if (mongoTemplate == null) {
      return;
    }
    // 現在時刻を取得
    LocalDateTime bootTime = LocalDateTime.now();;
    // 日時を指定フォーマットに変換
    String logDateStr = bootTime.format(targetFormatter);
    // ログイベントを作成
    LogEvent logEvent = makeLogEvent("WAR_BOOT",logDateStr);
    // MongoDBに保存
    mongoTemplate.insert(logEvent, "log_event");
  }

  /**
   * WARアプリケーション停止ログを記録する
   *
   * 外部Tomcatにデプロイされたアプリケーションの停止ログイベントを作成してMongoDBに保存する。
   * 現在時刻を停止時刻として記録する。
   */
  @Override
  public void warDownLog() {
    // MongoDBが利用できない場合は処理をスキップ
    if (mongoTemplate == null) {
      return;
    }
    // 現在時刻を取得
    LocalDateTime bootTime = LocalDateTime.now();;
    // 日時を指定フォーマットに変換
    String logDateStr = bootTime.format(targetFormatter);
    // ログイベントを作成
    LogEvent logEvent = makeLogEvent("WAR_DOWN",logDateStr);
    // MongoDBに保存
    mongoTemplate.insert(logEvent, "log_event");
  }

  /**
   * OSイベントログをMongoDBに保存する
   *
   * OS起動/停止イベントをMongoDBの「log_event」コレクションに保存する。
   * 主キー戦略により、同一EC2上の複数アプリケーションから重複してinsertされることを防止する。
   *
   * @param logEvent 保存するログイベント
   */
  @Override
  public void saveOsEventLog(LogEvent logEvent) {
      // 主キーを生成（ログタイプ_IP_日時）
      String id = logEvent.getLogType() + "_" + logEvent.getEc2Ip().replace(".","-") + "_" + logEvent.getLogDate();
      logEvent.set_id(id);
      try {
        // MongoDBに挿入
        mongoTemplate.insert(logEvent, "log_event");
      } catch (Exception e) {
        /*
          主キー重複例外は無視する。
          同一のEC2上に複数のwarまたはjarがデプロイされた場合、同じOS_BOOTレコードがinsertされることを防ぐため。
         */
      }
  }

  /**
   * サーバーのIPアドレスを取得する
   *
   * まずローカルホストのIPアドレス取得を試み、失敗した場合は
   * AWS EC2メタデータサービスからプライベートIPアドレスを取得する。
   *
   * @return サーバーのIPアドレス
   */
  @Override
  public String getServerIp(){
    String ip = "";
    try {
      // ローカルホストのIPアドレスを取得
      ip = InetAddress.getLocalHost().getHostAddress();
    } catch (UnknownHostException e) {
      // 失敗時はEC2メタデータからプライベートIPを取得
      ip = Ec2MetadataHelper.getPrivateIp();
    }
    return ip;
  }

  /**
   * サーバーのホスト名を取得する
   *
   * ローカルホストのホスト名を取得する。
   * 取得に失敗した場合は空文字列を返す。
   *
   * @return サーバーのホスト名（取得失敗時は空文字列）
   */
  @Override
  public String getServerHostName(){
    String hostName = "";
    try {
      // ローカルホストのホスト名を取得
      hostName = InetAddress.getLocalHost().getHostName();
    } catch (UnknownHostException e) {
      // 例外発生時は空文字列を返す
    }
    return hostName;
  }

  /**
   * ログイベントオブジェクトを生成する
   *
   * ログタイプと日時を元に、LogEventオブジェクトを作成する。
   * ログタイプに応じて適切なメッセージを生成し、
   * サーバー情報やその他の必須フィールドを設定する。
   *
   * @param logType ログタイプ（OS_BOOT, OS_DOWN, TOMCAT_BOOT, TOMCAT_DOWN, WAR_BOOT, WAR_DOWN, JAR_BOOT, JAR_DOWN）
   * @param logTime ログ日時（yyyyMMddHHmmssSSS形式）
   * @return 生成されたログイベントオブジェクト
   */
  private LogEvent makeLogEvent(String logType,String logTime) {
    // サーバー情報を取得
    String svcName = getServerHostName();
    String svcIp = getServerIp();
    String message = "";

    // ログタイプに応じてメッセージを生成
    if ("WAR_BOOT".equals(logType)) {
      // 「svcName(svcIp)」上の「applicationName war」サービスの起動が完了しました。
      message = String.format("%s(%s)」上の「%s war」サービスの起動が完了しました。", svcName,svcIp, applicationName);
    } else if ("WAR_DOWN".equals(logType)) {
      // 「svcName(svcIp)」上の「applicationName war」サービスが停止しました。
      message = String.format("%s(%s)」上の「%s war」サービスが停止しました。", svcName,svcIp, applicationName);
    } else if ("JAR_BOOT".equals(logType)) {
      // 「svcName(svcIp)」上の「applicationName jar」サービスの起動が完了しました。
      message = String.format("%s(%s)」上の「%s jar」サービスの起動が完了しました。", svcName,svcIp, applicationName);
    } else if ("JAR_DOWN".equals(logType)) {
      // 「svcName(svcIp)」上の「applicationName jar」サービスが停止しました。
      message = String.format("%s(%s)」上の「%s jar」サービスが停止しました。", svcName,svcIp, applicationName);
    } else if ("TOMCAT_BOOT".equals(logType)) {
      // 「svcName(svcIp)」上の「tomcat」サービスの起動が完了しました。
      message = String.format("%s(%s)」上の「tomcat」サービスの起動が完了しました。", svcName,svcIp);
    } else if ("TOMCAT_DOWN".equals(logType)) {
      // 「svcName(svcIp)」上の「tomcat」サービスが停止しました。
      message = String.format("%s(%s)」上の「tomcat」サービスが停止しました。", svcName,svcIp);
    } else if ("OS_BOOT".equals(logType)) {
      // 「svcName(svcIp)」OSが起動しました
      message = String.format("%s(%s)」OSが起動しました。", svcName,svcIp);
    } else if ("OS_DOWN".equals(logType)) {
      // 「svcName(svcIp)」OSが停止しました。
      message = String.format("%s(%s)」OSが停止しました。", svcName,svcIp);
    }

    // ログイベントオブジェクトを生成
    LogEvent logEvent = new LogEvent();
    // 施設コード
    logEvent.setFacilityCd("system");
      /*
       ログ種別
          OS_BOOT
          OS_SHUTDOWN
          TOMCAT_BOOT
          TOMCAT_SHUTDOWN
       */
    logEvent.setLogType(logType);
      /*
       サービス名
          EOL-webapp-01
          EOL-webapp-02
          EOL-device-01
          EOL-device-02
       */
    logEvent.setSvcName(svcName);
    // EC2識別
    logEvent.setEc2Ip(svcIp);

    //【画面表示列】
    // 日時 yyyyMMddHHmmssSSS
    logEvent.setLogDate(logTime);
    // クライアントIP
    logEvent.setClientIp("");
    // 機能名
    logEvent.setFunctionName("");
    // 利用者ID
    logEvent.setUserId("");
    // 内部患者ID
    logEvent.setPatId("");
    // ログ内容
    logEvent.setMessage(message);
    // 対応内容
    logEvent.setTodo("");

    // セッションID
    logEvent.setSessionId("");
    // デバイスエッジNo
    logEvent.setDeNo("");
    // デバイスエッジ製造番号
    logEvent.setDeSerial("");
    // 型式
    logEvent.setMcnType("");
    // 型式コード
    logEvent.setMcnTypeCd("");
    // 画面コード
    logEvent.setFuncCd("");
    // invoke クラス
    logEvent.setInvokeClass("");
    return logEvent;
  }

}
