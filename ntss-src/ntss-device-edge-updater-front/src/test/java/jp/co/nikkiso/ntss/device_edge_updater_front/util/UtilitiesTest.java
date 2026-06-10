package jp.co.nikkiso.ntss.device_edge_updater_front.util;

import static org.hamcrest.CoreMatchers.is;
import static org.junit.Assert.assertThat;

import org.junit.Test;

import jp.co.nikkiso.ntss.device_edge_updater_front.util.Utilities;

public class UtilitiesTest {

  @Test
  public void isNumberは引数が整数の場合にはtrueを返すこと() {
    
    assertThat(Utilities.isNumber("999"), is(true));
  }
  
  @Test
  public void isNumberは引数が整数でない場合にはfalseを返すこと() {
    
    assertThat(Utilities.isNumber("A"), is(false));
    assertThat(Utilities.isNumber("1.5"), is(false));
  }
}
