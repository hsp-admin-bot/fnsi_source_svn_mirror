package jp.co.nikkiso.ntss.core.logger;

import org.junit.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * NtssLogMessageクラスのテストクラス
 */
public class EventLogMessageTest {

  /**
   * buildLogMessage()の検証.
   * 条件: なし<br>
   * 結果: メッセージがCSV形式で取得できること
   */
  @Test
  public void test_getLogMessage() {
    // arrange
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

    // action
    final String result = eventLogMessage.buildLogMessage(LogLevel.INFO);

    // assert
    assertThat(result).isEqualTo(
      "\"Info\"" +
      ",\"施設コード\"" +
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

  /**
   * buildLogMessage()の検証.
   * 条件: 空文字が含まれる場合<br>
   * 結果: 空文字は空文字で出力されること
   */
  @Test
  public void test_getLogMessage_空文字は空文字で出力されること() {
    // arrange
    final EventLogMessage eventLogMessage = new EventLogMessage(
      ""
      , "利用者ID"
      , "クライアントIP"
      , ""
      , "デバイスエッジNo"
      , "デバイスエッジ製造番号"
      , "型式"
      , "型式コード"
      , "EC2識別"
      , "サービス名"
      , ""
      , "内部患者ID"
      , "SQL名"
      , "ログ内容"
      , "対応内容"
      , this.getClass().getName(),
      ""
    );

    // action
    final String result = eventLogMessage.buildLogMessage(LogLevel.INFO);

    // assert
    assertThat(result).isEqualTo(
      "\"Info\"" +
      ",\"\"" +
      ",\"利用者ID\"" +
      ",\"クライアントIP\"" +
      ",\"\"" +
      ",\"デバイスエッジNo\"" +
      ",\"デバイスエッジ製造番号\"" +
      ",\"型式\"" +
      ",\"型式コード\"" +
      ",\"EC2識別\"" +
      ",\"サービス名\"" +
      ",\"\"" +
      ",\"内部患者ID\"" +
      ",\"SQL名\"" +
      ",\"ログ内容\"" +
      ",\"対応内容\""
    );
  }

  /**
   * buildLogMessage()の検証.
   * 条件: nullが含まれる場合<br>
   * 結果: nullは空文字で出力されること
   */
  @Test
  public void test_getLogMessage_nullは空文字で出力されること() {
    // arrange
    final EventLogMessage eventLogMessage = new EventLogMessage(
      null
      , "利用者ID"
      , null
      , ""
      , "デバイスエッジNo"
      , "デバイスエッジ製造番号"
      , "型式"
      , "型式コード"
      , "EC2識別"
      , "null"
      , ""
      , "内部患者ID"
      , "SQL名"
      , "ログ内容"
      , "対応内容"
      , this.getClass().getName(),
      ""
    );

    // action
    final String result = eventLogMessage.buildLogMessage(LogLevel.INFO);

    // assert
    assertThat(result).isEqualTo(
      "\"Info\"" +
      ",\"\"" +
      ",\"利用者ID\"" +
      ",\"\"" +
      ",\"\"" +
      ",\"デバイスエッジNo\"" +
      ",\"デバイスエッジ製造番号\"" +
      ",\"型式\"" +
      ",\"型式コード\"" +
      ",\"EC2識別\"" +
      ",\"null\"" +
      ",\"\"" +
      ",\"内部患者ID\"" +
      ",\"SQL名\"" +
      ",\"ログ内容\"" +
      ",\"対応内容\""
    );
  }

  /**
   * buildLogMessage()の検証.
   * 条件: カンマと二重引用符が含まれる場合<br>
   * 結果: カンマと二重引用符が出力されること
   */
  @Test
  public void test_getLogMessage_カンマと二重引用符が出力されること() {
    // arrange
    final EventLogMessage eventLogMessage = new EventLogMessage(
      null
      , "利用者ID"
      , null
      , ""
      , "デバイスエッジNo"
      , "デバイスエッジ製造番号"
      , "型式"
      , "型式コード"
      , "EC2,識別"
      , "サービス名"
      , ""
      , "内部患者ID"
      , "SQL名"
      , "ロ\"グ内\"容"
      , "対応,内容"
      , this.getClass().getName(),
      ""
    );

    // action
    final String result = eventLogMessage.buildLogMessage(LogLevel.INFO);

    // assert
    assertThat(result).isEqualTo(
      "\"Info\"" +
      ",\"\"" +
      ",\"利用者ID\"" +
      ",\"\"" +
      ",\"\"" +
      ",\"デバイスエッジNo\"" +
      ",\"デバイスエッジ製造番号\"" +
      ",\"型式\"" +
      ",\"型式コード\"" +
      ",\"EC2,識別\"" +
      ",\"サービス名\"" +
      ",\"\"" +
      ",\"内部患者ID\"" +
      ",\"SQL名\"" +
      ",\"ロ'グ内'容\"" +
      ",\"対応,内容\""
    );
  }
}
