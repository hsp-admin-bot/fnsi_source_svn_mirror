package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
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
@Sql(value = "classpath:resource.script/RoundTypeResourceIntegrationTest.before.sql")
public class RoundTypeResourceIntegrationTest extends AbstractResourceIntegrationTest {

  /**
   * getRoundTypeNameAndContentの検証.
   *
   * 条件：成功, 種別マスタに該当するデータあり
   * 結果：成功レスポンスが返されること
   */
  @Test
  public void test_getRoundTypeNameAndContent_正常_種別マスタに該当するデータあり() throws Exception{
    String facilityCd = "1001";

    mockMvc
      .perform(RestDocumentationRequestBuilders
          .get("/api/round-type/{facility_cd}/name-and-content", facilityCd))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$[0].round_type_cd", is(1)))
      .andExpect(jsonPath("$[0].round_type_name", is("name1")))
      .andExpect(jsonPath("$[0].content", is("content1")))
      .andExpect(jsonPath("$[0].is_content_omission", is("0")))
      .andExpect(jsonPath("$[0].comment_post_default", is("0")))
      .andExpect(jsonPath("$[0].posting_class_default", is("1")))
      .andExpect(jsonPath("$[1].round_type_cd", is(5)))
      .andExpect(jsonPath("$[1].round_type_name", is("name5")))
      .andExpect(jsonPath("$[1].content", is("content5")))
      .andExpect(jsonPath("$[1].is_content_omission", is("1")))
      .andExpect(jsonPath("$[1].comment_post_default", is("0")))
      .andExpect(jsonPath("$[1].posting_class_default", is("1")))
      .andExpect(jsonPath("$[2].round_type_cd", is(4)))
      .andExpect(jsonPath("$[2].round_type_name", is("name4")))
      .andExpect(jsonPath("$[2].content", is("content4")))
      .andExpect(jsonPath("$[2].is_content_omission", is("0")))
      .andExpect(jsonPath("$[2].comment_post_default", is("1")))
      .andExpect(jsonPath("$[2].posting_class_default", is("0")))
      .andDo(document("round-type/name-and-content/get/ok",
          pathParameters(
              parameterWithName("facility_cd").description("[必須]施設コード")),
          responseFields(
            attributes(
              key("description").value("概要:施設コードに対応する種別を取得する")
              , key("operationTargetTable").value("操作対象テーブル:種別マスタ（mst_round_type）")
            ),
            fieldWithPath("[]").description("種別情報")
            , fieldWithPath("[].round_type_cd").description("種別コード")
            , fieldWithPath("[].round_type_name").description("種別名")
            , fieldWithPath("[].content").description("内容")
            , fieldWithPath("[].is_content_omission").description("内容省略フラグ")
            , fieldWithPath("[].comment_post_default").description("指示コメント転記初期値")
            , fieldWithPath("[].posting_class_default").description("転記区分初期値")
          )))
    ;
  }

  /**
   * getRoundTypeNameAndContentの検証.
   *
   * 条件：成功, 種別マスタに該当するデータなし
   * 結果：成功レスポンスが返されること
   */
  @Test
  public void test_getRoundTypeNameAndContent_正常_種別マスタに該当するデータなし() throws Exception{
    String facilityCd = "9999";

    mockMvc
      .perform(get("/api/round-type/{facilityCd}/name-and-content", facilityCd))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;
  }
}
