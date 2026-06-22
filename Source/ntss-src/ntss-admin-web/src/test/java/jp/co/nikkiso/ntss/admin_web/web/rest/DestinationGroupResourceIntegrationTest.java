package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.CoreMatchers.is;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.request.RequestDocumentation.parameterWithName;
import static org.springframework.restdocs.request.RequestDocumentation.pathParameters;
import static org.springframework.restdocs.snippet.Attributes.attributes;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql(value = "classpath:resource.script/DestinationGroupResourceIntegrationTest.before.sql")
public class DestinationGroupResourceIntegrationTest extends AbstractResourceIntegrationTest {

  /**
   * getDestinationGroupNameの検証.
   *
   * 条件：成功, 送信先グループに該当するデータあり
   * 結果：成功レスポンスが返されること
   */
  @Test
  public void test_getDestinationGroupName_正常_送信先グループに該当するデータあり() throws Exception{
    Long destinationGroupCd = 1L;

    mockMvc
      .perform(RestDocumentationRequestBuilders
          .get("/api/destination_group/{destinationGroupCd}/name", destinationGroupCd))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.name", is("グループ1")))
      .andDo(document("destination_group/name/get/ok",
          pathParameters(
              parameterWithName("destinationGroupCd").description("[必須]送信先グループコード")),
          responseFields(
            attributes(
              key("description").value("概要:送信先グループコードに対応する送信先グループ名を取得する")
              , key("operationTargetTable").value("操作対象テーブル:送信先グループマスタ（mst_destination_group）")
            ),
            fieldWithPath("name").description("送信先グループ名")
          )))
    ;
  }

  /**
   * getDestinationGroupNameの検証.
   *
   * 条件：成功, 送信先グループに該当するデータなし
   * 結果：成功レスポンスが返されること
   */
  @Test
  public void test_getDestinationGroupName_正常_送信先グループに該当するデータなし() throws Exception{
    mockMvc
      .perform(get("/api/destination_group/{destinationGroupCd}/name", "999"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.name", is("")))
    ;
  }
}
