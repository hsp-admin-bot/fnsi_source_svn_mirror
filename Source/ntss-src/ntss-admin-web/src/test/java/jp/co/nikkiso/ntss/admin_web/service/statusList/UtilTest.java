/**
 *
 */
package jp.co.nikkiso.ntss.admin_web.service.statusList;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

/**
 * Utilのテストクラス.
 *
 * {@link jp.co.nikkiso.ntss.admin_web.service.statusList.Util} のテストクラス.
 */
public class UtilTest extends Util {

  /**
   * getFormattedNumberメソッド のためのテスト・メソッド.
   *
   * {@link jp.co.nikkiso.ntss.admin_web.service.statusList.Util#getFormattedNumber(java.lang.String, java.lang.Integer)} のためのテスト・メソッド。
   */
  @Test
  public void testGetFormattedNumber() {
    assertEquals("18.0", Util.getFormattedNumber("18", 1));
    assertEquals("18.1", Util.getFormattedNumber("18.12345", 1));
    assertEquals("18.1", Util.getFormattedNumber("18.19345", 1));
  }

}
