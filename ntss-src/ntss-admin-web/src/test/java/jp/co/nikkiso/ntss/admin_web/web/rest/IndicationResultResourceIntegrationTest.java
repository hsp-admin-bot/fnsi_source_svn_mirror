package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.core.dao.MstUserDao;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.request.RequestDocumentation.parameterWithName;
import static org.springframework.restdocs.request.RequestDocumentation.pathParameters;
import static org.springframework.restdocs.request.RequestDocumentation.requestParameters;
import static org.springframework.restdocs.snippet.Attributes.attributes;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * IndicationResultResourceの結合テストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/IndicationResultResourceIntegrationTest.before.sql")
public class IndicationResultResourceIntegrationTest extends AbstractResourceIntegrationTest {

  @Autowired
  private MstUserDao mstUserDao;

  /**
   * getList()の検証.
   * 条件: 患者IDに該当するレコードが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser
  public void test_getList_成功() throws Exception {
    // arrange
    final Long patId = 1L;

    String treatDateFrom = "20190610";
    String treatDateTo = "20190620";

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/indication-result/{pat_id}/list", patId)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .param("treat_date_from", treatDateFrom)
      .param("treat_date_to", treatDateTo)
      .with(csrf()));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$", hasSize(5)))
      .andExpect(jsonPath("$[0].ord_no", is(1)))
      .andExpect(jsonPath("$[0].category", is("1")))
      .andExpect(jsonPath("$[0].ind_rst_type", is(1)))
      .andExpect(jsonPath("$[0].treatment_date", is("20190610")))
      .andExpect(jsonPath("$[0].treatment_cd", is(11)))
      .andExpect(jsonPath("$[0].treatment_name", is("【指示】治療方法名1")))
      .andExpect(jsonPath("$[0].kur_cd", is(11)))
      .andExpect(jsonPath("$[0].kur_name", is("【指示】クール1")))
      .andExpect(jsonPath("$[0].kur_start_time", is("000000")))
      .andExpect(jsonPath("$[0].start_date", is("2019-06-10T09:00:00.000+09:00")))
      .andExpect(jsonPath("$[0].end_date", nullValue()))
      .andExpect(jsonPath("$[0].bed_cd", is(12)))
      .andExpect(jsonPath("$[0].bed_name", is("【指示】ベッド1")))
      .andExpect(jsonPath("$[1].ord_no", is(2)))
      .andExpect(jsonPath("$[1].category", is("1")))
      .andExpect(jsonPath("$[1].ind_rst_type", is(1)))
      .andExpect(jsonPath("$[1].treatment_date", is("20190620")))
      .andExpect(jsonPath("$[1].treatment_cd", is(12)))
      .andExpect(jsonPath("$[1].treatment_name", is("【指示】治療方法名2")))
      .andExpect(jsonPath("$[1].kur_cd", is(12)))
      .andExpect(jsonPath("$[1].kur_name", is("【指示】クール2")))
      .andExpect(jsonPath("$[1].kur_start_time", is("170000")))
      .andExpect(jsonPath("$[1].start_date", is("2019-06-20T10:00:00.000+09:00")))
      .andExpect(jsonPath("$[1].end_date", nullValue()))
      .andExpect(jsonPath("$[1].bed_cd", is(13)))
      .andExpect(jsonPath("$[1].bed_name", is("【指示】ベッド2")))
      .andExpect(jsonPath("$[2].ord_no", is(6)))
      .andExpect(jsonPath("$[2].category", is("1")))
      .andExpect(jsonPath("$[2].ind_rst_type", is(1)))
      .andExpect(jsonPath("$[2].treatment_date", is("20190620")))
      .andExpect(jsonPath("$[2].treatment_cd", is(12)))
      .andExpect(jsonPath("$[2].treatment_name", is("【指示】治療方法名2")))
      .andExpect(jsonPath("$[2].kur_cd", is(12)))
      .andExpect(jsonPath("$[2].kur_name", is("【指示】クール2")))
      .andExpect(jsonPath("$[2].kur_start_time", is("170000")))
      .andExpect(jsonPath("$[2].start_date", is("2019-06-20T13:00:00.000+09:00")))
      .andExpect(jsonPath("$[2].end_date", nullValue()))
      .andExpect(jsonPath("$[2].bed_cd", is(13)))
      .andExpect(jsonPath("$[2].bed_name", is("【指示】ベッド2")))
      .andExpect(jsonPath("$[3].ord_no", is(1)))
      .andExpect(jsonPath("$[3].category", is("1")))
      .andExpect(jsonPath("$[3].ind_rst_type", is(2)))
      .andExpect(jsonPath("$[3].treatment_date", is("20190610")))
      .andExpect(jsonPath("$[3].treatment_cd", is(21)))
      .andExpect(jsonPath("$[3].treatment_name", is("【実績】治療方法名1")))
      .andExpect(jsonPath("$[3].kur_cd", is(21)))
      .andExpect(jsonPath("$[3].kur_name", is("【実績】クール1")))
      .andExpect(jsonPath("$[3].kur_start_time", is("120000")))
      .andExpect(jsonPath("$[3].start_date", is("2019-06-10T12:00:00.000+09:00")))
      .andExpect(jsonPath("$[3].end_date", is("2019-06-10T18:00:00.000+09:00")))
      .andExpect(jsonPath("$[3].bed_cd", is(22)))
      .andExpect(jsonPath("$[3].bed_name", is("【実績】ベッド1")))
      .andExpect(jsonPath("$[4].ord_no", is(2)))
      .andExpect(jsonPath("$[4].category", is("1")))
      .andExpect(jsonPath("$[4].ind_rst_type", is(2)))
      .andExpect(jsonPath("$[4].treatment_date", is("20190620")))
      .andExpect(jsonPath("$[4].treatment_cd", is(22)))
      .andExpect(jsonPath("$[4].treatment_name", is("【実績】治療方法名2")))
      .andExpect(jsonPath("$[4].kur_cd", is(22)))
      .andExpect(jsonPath("$[4].kur_name", is("【実績】クール2")))
      .andExpect(jsonPath("$[4].kur_start_time", is("100000")))
      .andExpect(jsonPath("$[4].start_date", is("2019-06-20T12:30:00.000+09:00")))
      .andExpect(jsonPath("$[4].end_date", is("2019-06-20T18:30:00.000+09:00")))
      .andExpect(jsonPath("$[4].bed_cd", is(23)))
      .andExpect(jsonPath("$[4].bed_name", is("【実績】ベッド2")))
      .andDo(
        document("indication_result/list/get/ok",
          pathParameters(
            parameterWithName("pat_id").description("[必須]患者ID")
          ),
          requestParameters(
            parameterWithName("treat_date_from").description("[必須]治療日(From)"),
            parameterWithName("treat_date_to").description("[必須]治療日(To)"),
            parameterWithName("_csrf").ignored()
          ),
          responseFields(
            attributes(
              key("description").value("概要：指定された患者IDに該当する予実リストを取得するAPI"),
              key("operationTargetTable").value("操作対象テーブル：治療記録 (ord_main)、ベッドグループ・透析室マスタ (mst_room_bed_group)")
            ),
            fieldWithPath("[]").description("予実リスト")
            , fieldWithPath("[].category").description("カテゴリ")
            , fieldWithPath("[].ind_rst_type").description("予実（1:予定、2:実績）")
            , fieldWithPath("[].ord_no").description("オーダ番号")
            , fieldWithPath("[].treatment_date").description("治療日")
            , fieldWithPath("[].treatment_cd").description("治療方法コード")
            , fieldWithPath("[].treatment_name").description("治療方法名")
            , fieldWithPath("[].kur_cd").description("クールコード").optional()
            , fieldWithPath("[].kur_name").description("クール名")
            , fieldWithPath("[].start_date").description("治療開始日時").optional()
            , fieldWithPath("[].end_date").description("治療終了日時").optional()
            , fieldWithPath("[].bed_cd").description("ベッドコード")
            , fieldWithPath("[].bed_name").description("ベッド名")
            , fieldWithPath("[].kur_start_time").description("クール開始時刻").optional()
            , fieldWithPath("[].operator_id").description("操作者ID(ログ出力用)").optional()
            , fieldWithPath("[].target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
          )
        )
      )
    ;
  }
}
