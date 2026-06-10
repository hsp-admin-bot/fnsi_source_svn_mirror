package jp.co.nikkiso.ntss.monitoring.web.dto;

import static org.hamcrest.CoreMatchers.is;
import static org.junit.Assert.assertThat;

import org.junit.Test;

public class MonitorParameterDtoTest {

  @Test
  public void buildMonitorKeyParamはmonitor_keysがnullの場合には空のリストを返すこと() {
    MonitorParameterDto dto = new MonitorParameterDto();
    assertThat(dto.buildMonitorKeyParam().size(), is(0));
  }
  @Test
  public void buildMonitorKeyParamはmonitor_keysが空文字列の場合は空のリストを返すこと() {
    MonitorParameterDto dto = new MonitorParameterDto();
    String[] strs = {};
    dto.setMonitorKeys(strs);
    assertThat(dto.buildMonitorKeyParam().size(), is(0));
  }
  @Test
  public void buildMonitorKeyParamはmonitor_keysが文字列配列の場合は文字列のリストを返すこと() {
    MonitorParameterDto dto = new MonitorParameterDto();
    String[] strs = {"a", "b", "c"};
    dto.setMonitorKeys(strs);
    assertThat(dto.buildMonitorKeyParam().get(0), is(strs[0]));
    assertThat(dto.buildMonitorKeyParam().get(1), is(strs[1]));
    assertThat(dto.buildMonitorKeyParam().get(2), is(strs[2]));
  }
}
