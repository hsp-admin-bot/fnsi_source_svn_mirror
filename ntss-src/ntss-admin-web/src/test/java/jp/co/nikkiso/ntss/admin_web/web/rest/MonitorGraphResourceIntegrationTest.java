package jp.co.nikkiso.ntss.admin_web.web.rest;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.snippet.Attributes.attributes;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql(value = "classpath:resource.script/MonitorGraphResourceIntegrationTest.before.sql")
public class MonitorGraphResourceIntegrationTest extends AbstractResourceIntegrationTest {

  @Autowired
  private ObjectMapper objectMapper;

  /**
   * getMonitorGraphDefine()の検証.
   *
   * 条件：成功, モニタグラフマスタに該当するデータあり
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(facilityCd = "1001")
  public void test_getAllMstComplaints_正常_モニタグラフマスタに該当するデータあり() throws Exception{

    mockMvc
      .perform(RestDocumentationRequestBuilders
          .get("/api/monitor/graph-define"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(3)))
      .andExpect(jsonPath("$[0].monitor_graph_cd", is(1)))
      .andExpect(jsonPath("$[0].monitor_graph_name", is("name1")))
      .andExpect(jsonPath("$[0].left_data_index", is("11")))
      .andExpect(jsonPath("$[0].left_color", is("#ff0001")))
      .andExpect(jsonPath("$[0].right_data_index", is("21")))
      .andExpect(jsonPath("$[0].right_color", is("#ff0011")))
      .andExpect(jsonPath("$[1].monitor_graph_cd", is(5)))
      .andExpect(jsonPath("$[1].monitor_graph_name", is("name5")))
      .andExpect(jsonPath("$[1].left_data_index", is("15")))
      .andExpect(jsonPath("$[1].left_color", is("#ff0005")))
      .andExpect(jsonPath("$[1].right_data_index", is("25")))
      .andExpect(jsonPath("$[1].right_color", is("#ff0015")))
      .andExpect(jsonPath("$[2].monitor_graph_cd", is(4)))
      .andExpect(jsonPath("$[2].monitor_graph_name", is("name4")))
      .andExpect(jsonPath("$[2].left_data_index", is("14")))
      .andExpect(jsonPath("$[2].left_color", is("#ff0004")))
      .andExpect(jsonPath("$[2].right_data_index", is("24")))
      .andExpect(jsonPath("$[2].right_color", is("#ff0014")))
      .andDo(document("monitor/graph-define/get/ok",
          responseFields(
            attributes(
              key("description").value("概要:施設コードに対応するモニタグラフ設定を取得する")
              , key("operationTargetTable").value("操作対象テーブル:モニタグラフマスタ（mst_monitor_graph）")
            ),
            fieldWithPath("[]").description("モニタグラフ設定")
            , fieldWithPath("[].monitor_graph_cd").description("モニタグラフコード")
            , fieldWithPath("[].monitor_graph_name").description("モニタグラフ名")
            , fieldWithPath("[].left_data_index").description("左項目コード")
            , fieldWithPath("[].left_color").description("左グラフ色")
            , fieldWithPath("[].right_data_index").description("右項目コード")
            , fieldWithPath("[].right_color").description("右グラフ色")
          )))
    ;
  }

  /**
   * getMonitorGraphDefine()の検証.
   *
   * 条件：成功, モニタグラフマスタに該当するデータなし
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(facilityCd = "9999")
  public void test_getAllMstComplaints_正常_モニタグラフマスタに該当するデータなし() throws Exception{

    mockMvc
      .perform(RestDocumentationRequestBuilders
        .get("/api/monitor/graph-define"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;
  }
}
