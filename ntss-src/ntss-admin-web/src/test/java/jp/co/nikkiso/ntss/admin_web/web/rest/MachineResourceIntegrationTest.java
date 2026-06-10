package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.hasSize;
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

import jp.co.nikkiso.ntss.admin_web.constant.RestDocMessage;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

/**
 * MachinesResourceの結合用テストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/MachinesResourceTest.before.sql")
public class MachineResourceIntegrationTest extends AbstractResourceIntegrationTest {

  /**
   * getMachines()の検証.
   * <p>
   * 条件: 該当装置なし<br>
   * 結果: 空のレスポンスが生成されること
   * </p>
   */
  @Test
  public void test_getMachines_該当施設なし() throws Exception {

    final String facilityCd = "nothing";

    mockMvc.perform(get("/api/machines/{facilityCd}?isNkkFacility={isNkkFacility}", facilityCd, false))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.machines", hasSize(0)));

  }

  /**
   * getMachines()の検証.
   * <p>
   * 正常パターン_取得結果1件
   * </p>
   */
  @Test
  public void test_getMachines_取得結果1件() throws Exception {

    final String facilityCd = "900001";

    // API実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/machines/{facilityCd}?isNkkFacility={isNkkFacility}", facilityCd, false));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.machines", hasSize(1)))
      .andDo(document("machines/get/ok",
        pathParameters(
          parameterWithName("facilityCd").description(RestDocMessage.Request.FACILITY_CD)),
        responseFields(
          attributes(
            key("description").value(""),
            key("operationTargetTable").value("")
          ),
          fieldWithPath("machines[]").description("[必須]装置リスト"),
          fieldWithPath("machines[].facilityName").description("施設名"),
          fieldWithPath("machines[].facilityCd").description("施設コード"),
          fieldWithPath("machines[].machineTypeCd").description("型式コード"),
          fieldWithPath("machines[].machineType").description("型式"),
          fieldWithPath("machines[].machineSerial").description("製造番号"),
          fieldWithPath("machines[].model").description("機種"),
          fieldWithPath("machines[].machineName").description("装置名"),
          fieldWithPath("machines[].bedName").description("ベッド名"),
          fieldWithPath("machines[].processState").description("工程"),
          fieldWithPath("machines[].mnoticeCnt").description("緊急発報件数"),
          fieldWithPath("machines[].preventiveMainteCnt").description("予防保守件数"),
          fieldWithPath("machines[].isPreventiveMainte").description("通信不良有無"),
          fieldWithPath("machines[].serviceSupportCnt").description("サービス対応件数"),
          fieldWithPath("machines[].colorFlg").description("色分けフラグ"),
          fieldWithPath("machines[].comFormatCd").description("通信フォーマット"),
          fieldWithPath("machines[].comType").description("通信種別"),
          fieldWithPath("machines[].deviceEdgeNo").description("デバイスエッジ番号"),
          fieldWithPath("machines[].isFtp").description("FTP収集"),
          fieldWithPath("machines[].version").description("バージョン"),
          fieldWithPath("machines[].maxEventRegDate").description("最大イベント発生日時"),
          fieldWithPath("machines[].latestPendingDate").description("最新の未対処イベント発生日時"),
          fieldWithPath("machines[].latestWipDate").description("最新の対処中イベント発生日時"),
          fieldWithPath("machines[].bedDispNo").description("ベッドマスタ表示順"),
          fieldWithPath("machines[].machineDispNo").description("装置マスタ表示順"))
      ));

    result.andExpect(jsonPath("$.machines[0].facilityName", is("テスト施設名")))
      .andExpect(jsonPath("$.machines[0].facilityCd", is("900001")))
      .andExpect(jsonPath("$.machines[0].machineTypeCd", is("999")))
      .andExpect(jsonPath("$.machines[0].machineSerial", is("90000001")))
      .andExpect(jsonPath("$.machines[0].model", is("099")))
      .andExpect(jsonPath("$.machines[0].machineName", is("テスト装置")))
      .andExpect(jsonPath("$.machines[0].processState", is("01")))
      .andExpect(jsonPath("$.machines[0].isFtp", is("0")))
      .andExpect(jsonPath("$.machines[0].version", is("1")));

  }

  /**
   * getMachines()の検証.
   * <p>
   * 正常パターン_取得結果複数
   * </p>
   */
  @Test
  public void test_getMachines_取得結果複数() throws Exception {

    final String facilityCd = "900002";

    mockMvc.perform(get("/api/machines/{facilityCd}?isNkkFacility={isNkkFacility}", facilityCd, false))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.machines", hasSize(4)))
      .andExpect(jsonPath("$.machines[0].facilityName", is("ESMクリニック")))
      .andExpect(jsonPath("$.machines[0].facilityCd", is("900002")))
      .andExpect(jsonPath("$.machines[0].machineTypeCd", is("904")))
      .andExpect(jsonPath("$.machines[0].machineSerial",is("90000044")))
      .andExpect(jsonPath("$.machines[0].model", is("001")))
      .andExpect(jsonPath("$.machines[0].machineName", is("ESMマシン4")))
      .andExpect(jsonPath("$.machines[0].processState", is("10")))
      .andExpect(jsonPath("$.machines[0].isFtp", is("1")))
      .andExpect(jsonPath("$.machines[0].version", is("5")))
      .andExpect(jsonPath("$.machines[1].facilityName", is("ESMクリニック")))
      .andExpect(jsonPath("$.machines[1].facilityCd", is("900002")))
      .andExpect(jsonPath("$.machines[1].machineTypeCd", is("903")))
      .andExpect(jsonPath("$.machines[1].machineSerial",is("90000043")))
      .andExpect(jsonPath("$.machines[1].model", is("002")))
      .andExpect(jsonPath("$.machines[1].machineName", is("ESMマシン3")))
      .andExpect(jsonPath("$.machines[1].processState", is("01")))
      .andExpect(jsonPath("$.machines[1].isFtp", is("1")))
      .andExpect(jsonPath("$.machines[1].version", is("4")))
      .andExpect(jsonPath("$.machines[2].facilityName", is("ESMクリニック")))
      .andExpect(jsonPath("$.machines[2].facilityCd", is("900002")))
      .andExpect(jsonPath("$.machines[2].machineTypeCd", is("902")))
      .andExpect(jsonPath("$.machines[2].machineSerial",is("90000042")))
      .andExpect(jsonPath("$.machines[2].model", is("003")))
      .andExpect(jsonPath("$.machines[2].machineName", is("ESMマシン2")))
      .andExpect(jsonPath("$.machines[2].processState", is("00")))
      .andExpect(jsonPath("$.machines[2].isFtp", is("0")))
      .andExpect(jsonPath("$.machines[2].version", is("3")))
      .andExpect(jsonPath("$.machines[3].facilityName", is("ESMクリニック")))
      .andExpect(jsonPath("$.machines[3].facilityCd", is("900002")))
      .andExpect(jsonPath("$.machines[3].machineTypeCd", is("901")))
      .andExpect(jsonPath("$.machines[3].machineSerial",is("90000041")))
      .andExpect(jsonPath("$.machines[3].model", is("004")))
      .andExpect(jsonPath("$.machines[3].machineName", is("ESMマシン1")))
      .andExpect(jsonPath("$.machines[3].processState", is("-1")))
      .andExpect(jsonPath("$.machines[3].isFtp", is("0")))
      .andExpect(jsonPath("$.machines[3].version", is("2")));

  }

}
