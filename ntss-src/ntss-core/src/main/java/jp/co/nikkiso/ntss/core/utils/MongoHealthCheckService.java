package jp.co.nikkiso.ntss.core.utils;

import com.mongodb.ConnectionString;
import com.mongodb.MongoClientSettings;
import com.mongodb.MongoTimeoutException;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoDatabase;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLogger;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import lombok.extern.slf4j.Slf4j;
import org.bson.Document;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

@Slf4j
@Component
public class MongoHealthCheckService {

  /**
   * ロガー生成コンポーネント
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Value("${spring.data.mongodb.host}")
  private String host;

  @Value("${spring.data.mongodb.port}")
  private String port;

  @Value("${spring.data.mongodb.database}")
  private String database;

  @Value("${spring.data.mongodb.username}")
  private String username;

  @Value("${spring.data.mongodb.password}")
  private String password;

  @Value("${spring.application.name}")
  private String serviceName;

  private final String SYSTEM = "system";

  private static final String WRITE_IN_LOG_STOP = "mongodbサービスが切断されました！";

  private static final String WRITE_IN_LOG_RUN = "mongodbサービスの接続に成功しました！";


  // MongoDB接続状態を保存するための原子的静的変数を定義する(プロジェクト起動時、デフォルトのmongoは使用できず、監視期間40秒でmongoサービス状態を起動する)
  private static AtomicBoolean atomicBoolean = new AtomicBoolean(false);

  private static AtomicBoolean writeLogFileStatuStop = new AtomicBoolean(false);

  private static AtomicBoolean writeLogFileStatusRun = new AtomicBoolean(false);

  // MongoDB接続状態の取得
  public static boolean getMongoDBConnected() {
    return atomicBoolean.get();
  }

  // MongoDB接続状態の設定
  public static void setMongoDBConnected(boolean isConnected) {
    atomicBoolean.getAndSet(isConnected);
  }


  public static boolean getWriteLogFileStop() {
    return writeLogFileStatuStop.get();
  }

  public static void setWriteLogFileStop(boolean isWriteed) {
    writeLogFileStatuStop.getAndSet(isWriteed);
  }

  public static boolean getWriteLogFileRun() {
    return writeLogFileStatusRun.get();
  }

  public static void setWriteLogFileRun(boolean isWriteed) {
    writeLogFileStatusRun.getAndSet(isWriteed);
  }

  /**
   * mongodbハートビートの検証
   * mongodbサービス健康診断方法
   */
  public void checkMongoHealth() {
    if (getMongoDBConnected()) {
      return;
    }
    long startTime = 0;
    String connectionString = "mongodb://"+ host +":"+ port;
    int timeoutMs = 30000;
    // 接続文字列オブジェクトの作成
    ConnectionString connString = new ConnectionString(connectionString);
    MongoClientSettings updatedSettings = MongoClientSettings.builder()
      .applyConnectionString(connString)
      // springboot-stata-mongodbで構成されたタイムアウトは、デフォルトの構成を上書きできない30秒です。したがって、この構成は無効です
      .applyToSocketSettings(builder -> builder.readTimeout(timeoutMs, TimeUnit.MILLISECONDS))
      .build();
    // MongoDBクライアントの作成
    MongoClient mongoClient = MongoClients.create(updatedSettings); // 连接到 MongoDB 服务
    try {
      // adminデータベースの取得
      MongoDatabase database = mongoClient.getDatabase("admin");
      // 取得開始時間
      startTime = System.nanoTime();
      // pingコマンドの実行
      Document pingResult = database.runCommand(new Document("ping", 1));
      //Document result = this.mongoTemplate.executeCommand("{ buildInfo: 1 }");
      // ping結果のチェック
      if (pingResult.get("ok").equals(1.0)) {
        // mongopdb状態をグローバル変数に同期する
        setMongoDBConnected(true);
        //logファイルに書き込む
        if (!getWriteLogFileRun()) {
          // ログ出力
          outLogToSystem(WRITE_IN_LOG_RUN);
          //log書き込み状態の変更
          setWriteLogFileRun(true);
          setWriteLogFileStop(false);
        }
      } else {
        //mongopdb状態をグローバル変数に同期する
        setMongoDBConnected(false);
        if (!getWriteLogFileStop()) {
          // ログ出力
          outLogToSystem(WRITE_IN_LOG_STOP);
          //log書き込み状態の変更
          setWriteLogFileStop(true);
          setWriteLogFileRun(false);
        }
      }
    } catch (MongoTimeoutException e) {
      //将mongopdb状态同步到全局变量中
      setMongoDBConnected(false);
      //logファイルに書き込む
      if (!getWriteLogFileStop()) {
        // ログ出力
        outLogToSystem(WRITE_IN_LOG_STOP);
        //log書き込み状態の変更
        setWriteLogFileStop(true);
        setWriteLogFileRun(false);
      }
      // 終了時間の取得
      long endTime = System.nanoTime();
      // コード実行時間の計算（単位：ミリ秒）
      long durationInMillis = (endTime - startTime) / 1_000_000;
      // 印刷実行時間
      System.err.println("コード実行時間：" + durationInMillis/1000 + " 秒");
    } finally {
      // MongoDB接続を閉じる
      mongoClient.close();
    }
  }

  /**
   * System下のlogファイルへの書き込み
   *
   * @param logMessage
   */
  public void outLogToSystem(String logMessage) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(logMessage);
    // 本アプリケーションが稼働しているIPアドレスを取得
    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
    eventLogMessage.setServiceName(serviceName);
    EventLogger logger = eventLoggerFactory.getLogger(SYSTEM, LogClass.APP);
    // ログ出力
    logger.error(eventLogMessage);
  }

}
