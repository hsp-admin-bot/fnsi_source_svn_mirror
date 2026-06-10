package jp.co.nikkiso.ntss.admin_web.web.rest;

import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.response.monitor.MonitorGraphDefineResponse;
import jp.co.nikkiso.ntss.admin_web.service.MonitorGraphService;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * MonitorGraphResourceのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
public class MonitorGraphResourceTest extends AbstractResourceTest {
  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * モニタグラフマスタサービスクラス.
   */
  @MockBean
  private MonitorGraphService monitorGraphService;

  /**
   * モニタグラフマスタResponseの初期化.
   * @return モニタグラフマスタのResponse
   */
  private List<MonitorGraphDefineResponse> createMonitorGraphDefine() {
    return new ArrayList<>();
  }

  /**
   * createMonitorGraphDefineResponse()の検証.
   *
   * 条件：モニタグラフマスタに該当のデータがある
   * 結果：施設コードに該当するモニタグラフ設定が取得できること
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_createMonitorGraphDefineResponse_正常_モニタグラフマスタに該当のデータがある() throws Exception {
    List<MonitorGraphDefineResponse> response = createMonitorGraphDefine();

    given(monitorGraphService.createMonitorGraphDefineResponse(any())).willReturn(response);

    mockMvc
      .perform(get("/api/monitor/graph-define"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$[0].monitor_graph_cd", is(1)))
      .andExpect(jsonPath("$[0].monitor_graph_name", is("name1")))
      .andExpect(jsonPath("$[0].left_data_index", is("11")))
      .andExpect(jsonPath("$[0].left_color", is("#ff0001")))
      .andExpect(jsonPath("$[0].right_data_index", is("21")))
      .andExpect(jsonPath("$[0].right_color", is("#ff0011")))
      .andExpect(jsonPath("$[1].monitor_graph_cd", is(2)))
      .andExpect(jsonPath("$[1].monitor_graph_name", is("name2")))
      .andExpect(jsonPath("$[1].left_data_index", is("12")))
      .andExpect(jsonPath("$[1].left_color", is("#ff0002")))
      .andExpect(jsonPath("$[1].right_data_index", is("22")))
      .andExpect(jsonPath("$[1].right_color", is("#ff0012")))
    ;

    // assert
    verify(monitorGraphService, times(1)).createMonitorGraphDefineResponse("facilityCd");
  }

  /**
   * createMonitorGraphDefineResponse()の検証.
   *
   * 条件：モニタグラフマスタに該当のデータがない
   * 結果：空のモニタグラフ設定が取得できること
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_getAllMstComplaints_正常_モニタグラフマスタに該当のデータがない() throws Exception {
    given(monitorGraphService.createMonitorGraphDefineResponse(any())).willReturn(Collections.emptyList());

    // assert
    mockMvc
      .perform(get("/api/monitor/graph-define"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;

    // assert
    verify(monitorGraphService, times(1)).createMonitorGraphDefineResponse("facilityCd");
  }
}
