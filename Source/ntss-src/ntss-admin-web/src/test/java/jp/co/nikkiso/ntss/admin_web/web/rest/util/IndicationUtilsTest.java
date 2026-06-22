package jp.co.nikkiso.ntss.admin_web.web.rest.util;

import org.junit.Test;
import java.util.List;
import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;

/**
 * {@link IndicationUtils}のテストクラス
 */
public class IndicationUtilsTest {

  /**
   * {@link IndicationUtils#getWeekPattern(String)}の検証.
   */
  @Test
  public void test_正常() {
    // 検証Json文字列
    final String target = "[{\"text\":\"全\",\"done\":true,\"value\":0}]";
    // 実行
    List<Integer> result = IndicationUtils.getWeekPattern(target);
    // 検証
    assertThat(result.size(), is(7));
    assertThat(result.get(0), is (1));
    assertThat(result.get(1), is (2));
    assertThat(result.get(2), is (3));
    assertThat(result.get(3), is (4));
    assertThat(result.get(4), is (5));
    assertThat(result.get(5), is (6));
    assertThat(result.get(6), is (7));
  }
}
