package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.snippet.Attributes.attributes;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql(value = "classpath:resource.script/MachineRecordResourceIntegrationTest.before.sql")
public class MachineRecordResourceIntegrationTest extends AbstractResourceIntegrationTest  {

  /**
   * getMachineRecordの検証.
   *
   * 条件：成功, 装置記録にデータあり
   * 結果：成功レスポンスが返されること
   */
  @Test
  public void test_getMachineRecord_正常_データあり() throws Exception{
    mockMvc
      .perform(get("/api/machine_record"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.machineRecords", hasSize(10)))
      .andExpect(jsonPath("$.machineRecords[0].code", is("0050")))
      .andExpect(jsonPath("$.machineRecords[0].message", is("投与薬剤")))
      .andExpect(jsonPath("$.machineRecords[0].is_default", is("1")))
      .andExpect(jsonPath("$.machineRecords[0].log_class", is("1")))
      .andExpect(jsonPath("$.machineRecords[0].target_model", is("1")))
      .andExpect(jsonPath("$.machineRecords[1].code", is("0060")))
      .andExpect(jsonPath("$.machineRecords[1].message", is("酸素吸入開始")))
      .andExpect(jsonPath("$.machineRecords[1].is_default", is("1")))
      .andExpect(jsonPath("$.machineRecords[1].log_class", is("2")))
      .andExpect(jsonPath("$.machineRecords[1].target_model", is("3")))
      .andExpect(jsonPath("$.machineRecords[2].code", is("0061")))
      .andExpect(jsonPath("$.machineRecords[2].message", is("酸素吸入終了")))
      .andExpect(jsonPath("$.machineRecords[2].is_default", is("1")))
      .andExpect(jsonPath("$.machineRecords[2].log_class", is("4")))
      .andExpect(jsonPath("$.machineRecords[2].target_model", is("6")))
      .andExpect(jsonPath("$.machineRecords[3].code", is("0101")))
      .andExpect(jsonPath("$.machineRecords[3].message", is("血圧測定")))
      .andExpect(jsonPath("$.machineRecords[3].is_default", is("1")))
      .andExpect(jsonPath("$.machineRecords[3].log_class", is("3")))
      .andExpect(jsonPath("$.machineRecords[3].target_model", is("2")))
      .andExpect(jsonPath("$.machineRecords[4].code", is("0102")))
      .andExpect(jsonPath("$.machineRecords[4].message", is("体温測定")))
      .andExpect(jsonPath("$.machineRecords[4].is_default", is("1")))
      .andExpect(jsonPath("$.machineRecords[4].log_class", is("5")))
      .andExpect(jsonPath("$.machineRecords[4].target_model", is("4")))
      .andExpect(jsonPath("$.machineRecords[5].code", is("0103")))
      .andExpect(jsonPath("$.machineRecords[5].message", is("ケア")))
      .andExpect(jsonPath("$.machineRecords[5].is_default", is("0")))
      .andExpect(jsonPath("$.machineRecords[5].log_class", is("1")))
      .andExpect(jsonPath("$.machineRecords[5].target_model", is("1")))
      .andExpect(jsonPath("$.machineRecords[6].code", is("0104")))
      .andExpect(jsonPath("$.machineRecords[6].message", is("透析前血圧")))
      .andExpect(jsonPath("$.machineRecords[6].is_default", is("0")))
      .andExpect(jsonPath("$.machineRecords[6].log_class", is("2")))
      .andExpect(jsonPath("$.machineRecords[6].target_model", is("3")))
      .andExpect(jsonPath("$.machineRecords[7].code", is("0105")))
      .andExpect(jsonPath("$.machineRecords[7].message", is("透析後血圧")))
      .andExpect(jsonPath("$.machineRecords[7].is_default", is("0")))
      .andExpect(jsonPath("$.machineRecords[7].log_class", is("2")))
      .andExpect(jsonPath("$.machineRecords[7].target_model", is("1")))
      .andExpect(jsonPath("$.machineRecords[8].code", is("0109")))
      .andExpect(jsonPath("$.machineRecords[8].message", is("引き残し量")))
      .andExpect(jsonPath("$.machineRecords[8].is_default", is("0")))
      .andExpect(jsonPath("$.machineRecords[8].log_class", is("6")))
      .andExpect(jsonPath("$.machineRecords[8].target_model", is("4")))
      .andExpect(jsonPath("$.machineRecords[9].code", is("0201")))
      .andExpect(jsonPath("$.machineRecords[9].message", is("ＬＣＤオープン")))
      .andExpect(jsonPath("$.machineRecords[9].is_default", is("0")))
      .andExpect(jsonPath("$.machineRecords[9].log_class", is("3")))
      .andExpect(jsonPath("$.machineRecords[9].target_model", is("6")))
      .andDo(document("machine_record/get/ok",
          responseFields(
            attributes(
              key("description").value("概要:装置記録の装置記録コードと装置記録メッセージを全件取得する")
              , key("operationTargetTable").value("操作対象テーブル:装置記録マスタ（mst_machine_record）")
            ),
            fieldWithPath("machineRecords").description("装置記録の装置記録コードと装置記録メッセージ")
            , fieldWithPath("machineRecords[].code").description("[必須]装置記録コード")
            , fieldWithPath("machineRecords[].message").description("装置記録メッセージ")
            , fieldWithPath("machineRecords[].is_default").description("[必須]推奨項目")
            , fieldWithPath("machineRecords[].log_class").description("[必須]ログ分類")
            , fieldWithPath("machineRecords[].target_model").description("[必須]対象機種")
          )))
    ;
  }
}
