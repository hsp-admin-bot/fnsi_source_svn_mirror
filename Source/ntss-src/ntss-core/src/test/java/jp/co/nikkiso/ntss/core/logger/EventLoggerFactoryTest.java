package jp.co.nikkiso.ntss.core.logger;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * EventLoggerFactoryコンポーネントのテストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class EventLoggerFactoryTest {

  /**
   * EventLoggerFactoryコンポーネント
   */
  @Autowired
  private EventLoggerFactory target;

  /**
   * getLogger(facilityCd)の検証.
   * 条件: なし<br>
   * 結果: 戻り値 not NULL であること
   */
  @Test
  public void test_getLogger_facilityCd() {
    // arrange
    final String facilityCd = "009999";

    // action
    final EventLogger logger = target.getLogger(facilityCd);

    // assert
    assertThat(logger).isNotNull();
  }

  /**
   * getLogger(facilityCd)の検証.
   * 条件: 引数の施設コードがNULLである
   * 結果: IllegalArgumentExceptionが送出されること
   */
  @Test(expected = IllegalArgumentException.class)
  public void test_getLogger_facilityCd_is_null() {
    // action
    target.getLogger(null);
  }

  /**
   * getLogger(facilityCd)の検証.
   * 条件: 引数の施設コードが "" である
   * 結果: IllegalArgumentExceptionが送出されること
   */
  @Test(expected = IllegalArgumentException.class)
  public void test_getLogger_facilityCd_is_empty() {
    // arrange
    final String facilityCd = "";

    // action
    target.getLogger(facilityCd);
  }

  /**
   * getLogger()の検証.
   * 条件: なし<br>
   * 結果: 戻り値がNullでない事.
   */
  @Test
  public void test_getLogger() {
    // action
    final EventLogger logger = target.getLogger();
    // assert
    assertThat(logger).isNotNull();
  }

  /**
   * {@link EventLoggerFactory#getLogger(String, LogClass)}の検証.
   */
  @Test
  public void test_getLogger_アプリケーションログの確認() {
    // 事前準備
    final String facilityCd1 = "009999";
    final String facilityCd2 = "009998";
    final String facilityCd3 = "009997";
    // 実行
    final EventLogger logger1 = target.getLogger(facilityCd1, LogClass.APP);
    // 検証
    assertThat(logger1).isNotNull();
    // 実行
    final EventLogger logger2 = target.getLogger(facilityCd2, LogClass.APP);
    // 検証
    assertThat(logger2).isNotNull();
    // 実行
    final EventLogger logger3 = target.getLogger(facilityCd3, LogClass.APP);
    // 検証
    assertThat(logger3).isNotNull();
  }
}
