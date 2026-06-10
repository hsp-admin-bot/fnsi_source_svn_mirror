package jp.co.nikkiso.ntss.core;

import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;


@SpringBootApplication
public class TestApplication {

  @Autowired
  private EventLoggerFactory loggerFactory;

  public static void main(String[] args) {
    try (ConfigurableApplicationContext ctx = SpringApplication.run(TestApplication.class, args)) {
      TestApplication app = ctx.getBean(TestApplication.class);
      app.run(args);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    }
  }
  public void run(String... args) throws Exception {
    //アプリの処理

    {
      final EventLogMessage eventLogMessage = new EventLogMessage(
        "施設コード"
        , "利用者ID"
        , "クライアントIP"
        , "セッションID"
        , "デバイスエッジNo"
        , "デバイスエッジ製造番号"
        , "型式"
        , "型式コード"
        , "EC2識別"
        , "サービス名"
        , "画面コード"
        , "内部患者ID"
        , "SQL名"
        , "ログ内容"
        , "対応内容"
        , this.getClass().getName(),
        ""
      );
      loggerFactory.getLogger("009997").info(eventLogMessage);
      loggerFactory.getLogger("009997").info(eventLogMessage);
    }
    {
      final EventLogMessage eventLogMessage = new EventLogMessage(
        "施設コード"
        , "利用者ID"
        , "クライアントIP"
        , "セッションID"
        , "デバイスエッジNo"
        , "デバイスエッジ製造番号"
        , "型式"
        , "型式コード"
        , "EC2識別"
        , "サービス名"
        , "画面コード"
        , "内部患者ID"
        , "SQL名"
        , "ログ内容"
        , "対応内容"
        , this.getClass().getName(),
        ""
      );
      loggerFactory.getLogger("009998").info(eventLogMessage);
    }
    {
      final EventLogMessage eventLogMessage = new EventLogMessage(
        "施設コード"
        , "利用者ID"
        , "クライアントIP"
        , "セッションID"
        , "デバイスエッジNo"
        , "デバイスエッジ製造番号"
        , "型式"
        , "型式コード"
        , "EC2識別"
        , "サービス名"
        , "画面コード"
        , "内部患者ID"
        , "SQL名"
        , "ログ内容"
        , "対応内容"
        , this.getClass().getName(),
        ""
      );
      loggerFactory.getLogger("009999").info(eventLogMessage);
      Thread.sleep(61 * 1000);
      loggerFactory.getLogger("009999").info(eventLogMessage);
      loggerFactory.getLogger("009999").info(eventLogMessage);
    }

  }
}
