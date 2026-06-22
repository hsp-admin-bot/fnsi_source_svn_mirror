package jp.co.nikkiso.ntss.core.logger;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.spi.LoggingEvent;
import ch.qos.logback.core.Appender;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.Mock;
import org.slf4j.LoggerFactory;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

@RunWith(SpringRunner.class)
@SpringBootTest
public class EventLoggerTest {

  /**
   * テスト用施設コード.
   * LoggerFactoryに渡すために、ここに定義している.
   */
  private final String facilityCd = "009999";

  private EventLogger target;

  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  @Mock
  private Appender mockAppender;

  // Appender#doAppendの引数のキャプチャ
  @Captor
  private ArgumentCaptor<LoggingEvent> captorLoggingEvent;

  // mockAppenderを設定
  @Before
  public void setup() {
    final Logger logger = (Logger) LoggerFactory.getLogger(this.facilityCd);
    logger.addAppender(mockAppender);
    target = new EventLogger(logger);
  }

  // mockAppenderを外す
  @After
  public void teardown() {
    final Logger logger = (Logger) LoggerFactory.getLogger(this.facilityCd);
    logger.detachAppender(mockAppender);
  }

  @Test
  public void test_info_正常_施設コードあり() {
    // arrange

    // action
    target.info(new EventLogMessage(
      facilityCd
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
    ));

    // assert
    verify(mockAppender, times(1)).doAppend(captorLoggingEvent.capture());
    final LoggingEvent loggingEvent = captorLoggingEvent.getValue();
    assertThat(loggingEvent.getLevel()).isEqualTo(Level.INFO);
    assertThat(loggingEvent.getFormattedMessage()).isEqualTo(
      "\"Info\"" +
      ",\"009999\"" +
      ",\"利用者ID\"" +
      ",\"クライアントIP\"" +
      ",\"セッションID\"" +
      ",\"デバイスエッジNo\"" +
      ",\"デバイスエッジ製造番号\"" +
      ",\"型式\"" +
      ",\"型式コード\"" +
      ",\"EC2識別\"" +
      ",\"サービス名\"" +
      ",\"画面コード\"" +
      ",\"内部患者ID\"" +
      ",\"SQL名\"" +
      ",\"ログ内容\"" +
      ",\"対応内容\""
    );
  }

  @Test
  public void test_info_異常_パラメータNULL() {
    // arrange
    // assert
    expectedException.expect(IllegalArgumentException.class);
    expectedException.expectMessage("Parameter is null");

    // action
    target.info(null);

    // assert
    verify(mockAppender, never()).doAppend(any());
  }

  @Test
  public void test_warn_正常_施設コードあり() {
    // arrange

    // action
    target.warn(new EventLogMessage(
      facilityCd
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
    ));

    // assert
    verify(mockAppender, times(1)).doAppend(captorLoggingEvent.capture());
    final LoggingEvent loggingEvent = captorLoggingEvent.getValue();
    assertThat(loggingEvent.getLevel()).isEqualTo(Level.WARN);
    assertThat(loggingEvent.getFormattedMessage()).isEqualTo(
      "\"Warning\"" +
      ",\"009999\"" +
      ",\"利用者ID\"" +
      ",\"クライアントIP\"" +
      ",\"セッションID\"" +
      ",\"デバイスエッジNo\"" +
      ",\"デバイスエッジ製造番号\"" +
      ",\"型式\"" +
      ",\"型式コード\"" +
      ",\"EC2識別\"" +
      ",\"サービス名\"" +
      ",\"画面コード\"" +
      ",\"内部患者ID\"" +
      ",\"SQL名\"" +
      ",\"ログ内容\"" +
      ",\"対応内容\""
    );
  }

  @Test
  public void test_warn_異常_パラメータNULL() {
    // arrange
    // assert
    expectedException.expect(IllegalArgumentException.class);
    expectedException.expectMessage("Parameter is null");

    // action
    target.warn(null);

    // assert
    verify(mockAppender, never()).doAppend(any());
  }

  @Test
  public void test_error_正常_施設コードあり() {
    // arrange

    // action
    target.error(new EventLogMessage(
      facilityCd
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
    ));

    // assert
    verify(mockAppender, times(1)).doAppend(captorLoggingEvent.capture());
    final LoggingEvent loggingEvent = captorLoggingEvent.getValue();
    assertThat(loggingEvent.getLevel()).isEqualTo(Level.ERROR);
    assertThat(loggingEvent.getFormattedMessage()).isEqualTo(
      "\"Error\"" +
      ",\"009999\"" +
      ",\"利用者ID\"" +
      ",\"クライアントIP\"" +
      ",\"セッションID\"" +
      ",\"デバイスエッジNo\"" +
      ",\"デバイスエッジ製造番号\"" +
      ",\"型式\"" +
      ",\"型式コード\"" +
      ",\"EC2識別\"" +
      ",\"サービス名\"" +
      ",\"画面コード\"" +
      ",\"内部患者ID\"" +
      ",\"SQL名\"" +
      ",\"ログ内容\"" +
      ",\"対応内容\""
    );
  }

  @Test
  public void test_error_異常_パラメータNULL() {
    // arrange
    // assert
    expectedException.expect(IllegalArgumentException.class);
    expectedException.expectMessage("Parameter is null");

    // action
    target.error(null);

    // assert
    verify(mockAppender, never()).doAppend(any());
  }

}
