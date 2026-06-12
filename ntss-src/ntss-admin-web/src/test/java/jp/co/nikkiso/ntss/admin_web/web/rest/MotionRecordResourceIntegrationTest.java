package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.nullValue;
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

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneId;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.admin_web.constant.RestDocMessage;
import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;

/**
 * MotionRecordResourceのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/MotionRecordResourceIntegrationTest.before.sql")
@WithMockUser
public class MotionRecordResourceIntegrationTest extends AbstractResourceIntegrationTest {

  /**
   * getMotionRecords()の検証.
   * <p>
   * 条件: 該当データなし<br>
   * 結果: 空のレスポンスが生成されること
   * </p>
   */
  @Test
  public void test_getMotionRecords_該当データなし() throws Exception {

    final String facilityCd = "nothing";
    final String machineTypeCd = "nothing";
    final String machineSerial = "nothing";
    final String userTypeCd = "noAnyone";
    final String baseDate = "noDate";

    mockMvc.perform(get("/api/motion_record/{facilityCd}/{machineTypeCd}/{machineSerial}/{userTyeCd}/{baseDate}", facilityCd, machineTypeCd, machineSerial, userTypeCd, baseDate))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.baseDate", is("")))
      .andExpect(jsonPath("$.motionRecords", hasSize(0)));

  }

  /**
   * getMotionRecords()の検証.
   * <p>
   *　該当データ1件
   * </p>
   */
  @Test
  public void test_getMotionRecords_該当データ1件() throws Exception {

    final String facilityCd = "900001";
    final String machineTypeCd = "901";
    final String machineSerial = "90000001";
    final String userTypeCd = "NKK";
    final String baseDate = "20010101";

    mockMvc.perform(get("/api/motion_record/{facilityCd}/{machineTypeCd}/{machineSerial}/{userTyeCd}/{baseDate}", facilityCd, machineTypeCd, machineSerial, userTypeCd, baseDate))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.baseDate", is("20010101")))
      .andExpect(jsonPath("$.motionRecords", hasSize(1)))
      .andExpect(jsonPath("$.motionRecords[0].eventRegDate", is("2001/01/01")))
      .andExpect(jsonPath("$.motionRecords[0].eventRegTime", is("00:00:01")))
      .andExpect(jsonPath("$.motionRecords[0].dataType", equalTo(1)));
    // TODO 項目がたりない

  }

  /**
   * getMotionRecords()の検証.
   * <p>
   * 該当データ複数
   * </p>
   */
  @Test
  public void test_getMotionRecords_該当データ複数() throws Exception {

    final String facilityCd = "900002";
    final String machineTypeCd = "902";
    final String machineSerial = "90000002";
    final String userTypeCd = "test";
    final String baseDate = "20141214";

    mockMvc.perform(get("/api/motion_record/{facilityCd}/{machineTypeCd}/{machineSerial}/{userTyeCd}/{baseDate}", facilityCd, machineTypeCd, machineSerial, userTypeCd, baseDate))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.baseDate", is("20031231")))
      .andExpect(jsonPath("$.motionRecords", hasSize(3)))
      .andExpect(jsonPath("$.motionRecords[0].eventRegDate", is("2014/12/14")))
      .andExpect(jsonPath("$.motionRecords[0].eventRegTime", is("14:44:43")))
      .andExpect(jsonPath("$.motionRecords[0].dataType", equalTo(3)))
      .andExpect(jsonPath("$.motionRecords[1].eventRegDate", is("2014/12/13")))
      .andExpect(jsonPath("$.motionRecords[1].eventRegTime", is("14:44:44")))
      .andExpect(jsonPath("$.motionRecords[1].dataType", equalTo(5)))
      .andExpect(jsonPath("$.motionRecords[2].eventRegDate", is("2014/12/12")))
      .andExpect(jsonPath("$.motionRecords[2].eventRegTime", is("14:44:44")))
      .andExpect(jsonPath("$.motionRecords[2].dataType", equalTo(4)));
    // TODO 項目がたりない

  }

  /**
   * getGatheringStatus()の検証.
   * <p>
   *   条件：成功_該当データあり
   *   結果：データ収集ステータスが格納された成功レスポンスが返されること
   * </p>
   */
  @Test
  public void test_getGatheringStatus_正常_該当データあり() throws Exception {
    // 事前準備
    Long userId = 1L;
    String facilityCd = "000001";
    String sysDate = "2017-12-06";
    Integer gatheringStatus = 1;

    // システム日時を固定
    DateTimeUtils.setClock(Clock.fixed(Instant.parse(sysDate + "T12:00:00.00Z"), ZoneId.systemDefault()));

    // 実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/motion_record/gathering_status/{userId}/{facilityCd}", userId, facilityCd));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.gatheringStatus", is(gatheringStatus)))
      .andDo(document("motion_record/gathering_status/ok",
          pathParameters(
            parameterWithName("userId").description(RestDocMessage.Request.USER_ID),
            parameterWithName("facilityCd").description(RestDocMessage.Request.FACILITY_CD)),
          responseFields(
            attributes(
              key("description").value(""),
              key("operationTargetTable").value("")
            ),
            fieldWithPath("gatheringStatus").description("データ収集ステータス(-2:一部異常/-1:異常/0:依頼中/1:処理中/2:転送完了)")
          )));

  }

  /**
   * getGatheringStatus()の検証.
   * <p>
   *   条件：成功_該当データあり
   *   結果：データ収集ステータスにnullが格納された成功レスポンスが返されること
   * </p>
   */
  @Test
  public void test_getGatheringStatus_正常_該当データなし() throws Exception {
    // 事前準備
    Long userId = 2L;
    String facilityCd = "000001";
    String sysDate = "2017-12-06";

    // システム日時を固定
    DateTimeUtils.setClock(Clock.fixed(Instant.parse(sysDate + "T12:00:00.00Z"), ZoneId.systemDefault()));

    // 実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/motion_record/gathering_status/{userId}/{facilityCd}", userId, facilityCd));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.gatheringStatus", nullValue()));

  }

}
