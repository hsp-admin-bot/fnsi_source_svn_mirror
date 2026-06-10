package jp.co.nikkiso.ntss.admin_web.web.rest;

import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordResultMergeService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResultMerge;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.List;
import java.util.TimeZone;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.junit.Assert.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.anyLong;
import static org.mockito.BDDMockito.anyString;
import static org.mockito.BDDMockito.doNothing;
import static org.mockito.BDDMockito.doThrow;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * TreatmentRecordResultMergeResourceのテストクラス.
 * <pre>
 * Spring Security の 認可 のテストを実施する場合は、以下を変更する.
 *   (test) jp.co.nikkiso.ntss.admin_web.security.SecurityConfig
 *     <code>@EnableGlobalMethodSecurity(prePostEnabled = false) -> @EnableGlobalMethodSecurity(prePostEnabled = true)</code>
 * </pre>
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
public class TreatmentRecordResultMergeResourceTest extends AbstractResourceTest {

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * 治療記録（実績マージ）Service.
   */
  @MockBean
  private TreatmentRecordResultMergeService treatmentRecordResultMergeService;

  private TreatmentRecordResultMerge getTreatmentRecordResultMerge(Long ordNo, Long patId, String hospPatId, String patName) {
    TreatmentRecordResultMerge data = new TreatmentRecordResultMerge();
    data.setOrdNo(ordNo);
    data.setPatId(patId);
    data.setHospPatId(hospPatId);
    data.setPatName(patName);
    data.setRstInputClass(1);
    data.setRstDialysisState("2");
    data.setRstTreatmentName("3");
    data.setRstKurCd(4L);
    data.setRstKurName("5");
    data.setRstBedCd(6L);
    data.setRstBedName("7");
    data.setRstMachineName("8");
    data.setRstCondSendDate(Timestamp.valueOf("2019-06-01 12:01:00"));
    data.setRstAcceptDate(Timestamp.valueOf("2019-06-02 12:01:00"));
    data.setRstStartDate(Timestamp.valueOf("2019-06-03 12:01:00"));
    data.setRstEndDate(Timestamp.valueOf("2019-06-04 12:01:00"));
    data.setRstReturnHomeDate(Timestamp.valueOf("2019-06-05 12:01:00"));
    data.setRstInOutClass(9);
    data.setRstDialysisCnt(10);
    data.setRstWardCd(11);
    data.setRstWardName("12");
    data.setRstCourseCd(13);
    data.setRstCourseName("14");
    data.setRstDw(BigDecimal.valueOf(15.0));
    data.setRstPunctureUserInfo("{\"value\": \"16\"}");
    data.setRstReturnUserInfo("{\"value\": \"17\"}");
    data.setRstChargeUserInfo("{\"value\": \"18\"}");
    data.setRstBloodCirculateTotal(BigDecimal.valueOf(19.0));
    data.setRstRunningTime(20);
    data.setRstKtV(BigDecimal.valueOf(21.0));
    data.setRecSetDate(Timestamp.valueOf("2019-06-06 12:01:00"));
    data.setSendCtlNo(22L);
    data.setBloodPurifierName("23");
    data.setPullLeaveAmount(BigDecimal.valueOf(24.0));
    data.setRstCondInfo("{\"value\": \"25\"}");
    data.setRstMediInfo("{\"value\": \"26\"}");
    data.setRstEquipInfo("{\"value\": \"27\"}");
    data.setRstIndCommentInfo("{\"value\": \"28\"}");
    data.setRstTareInfo("{\"value\": \"29\"}");
    data.setRstOffWaterInfo("{\"value\": \"30\"}");
//    data.setRstDeviceSetInfo("{\"value\": \"31\"}");// del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
    data.setWeightScaleNo(32L);
    data.setRstWeightInfo("{\"value\": \"33\"}");
//    data.setRstVitalInfo("{\"value\": \"34\"}");
    data.setRstComplaintInfo("{\"value\": \"35\"}");
    data.setRstTreatmentInfo("{\"value\": \"36\"}");
    data.setRstTreatStaffInfo("{\"value\": \"37\"}");
    data.setRstRoundsInfo("{\"value\": \"38\"}");
    data.setUpDate(Timestamp.valueOf("2019-06-10 12:01:00"));
    data.setRegDate(Timestamp.valueOf("2019-06-11 12:01:00"));
    return data;
  }

  /**
   * getResultMergeList()の検証.
   * <p>
   * 条件：成功、閲覧権限ユーザ 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getResultMergeList_成功_閲覧権限ユーザ() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    String facilityCd = "000001";
    List<TreatmentRecordResultMerge> response = Arrays.asList(
      getTreatmentRecordResultMerge(1L, 1L, "000000000001", "テスト患者1"),
      getTreatmentRecordResultMerge(2L, 2L, "000000000002", "テスト患者2")
    );
    SimpleDateFormat sf = new SimpleDateFormat(CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601);
    sf.setTimeZone(TimeZone.getTimeZone(CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO));

    // Mock化
    given(treatmentRecordResultMergeService.getResultMergeList(anyLong(), anyString())).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/result-merge", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // 検証
    verify(treatmentRecordResultMergeService, times(1)).getResultMergeList(ordNo, facilityCd);
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$", hasSize(2)))
      .andExpect(jsonPath("$[0].ord_no", is(response.get(0).getOrdNo().intValue())))
      .andExpect(jsonPath("$[0].pat_id", is(response.get(0).getPatId().intValue())))
      .andExpect(jsonPath("$[0].hosp_pat_id", is(response.get(0).getHospPatId())))
      .andExpect(jsonPath("$[0].pat_name", is(response.get(0).getPatName())))
      .andExpect(jsonPath("$[0].rst_input_class", is(response.get(0).getRstInputClass())))
      .andExpect(jsonPath("$[0].rst_dialysis_state", is(response.get(0).getRstDialysisState())))
      .andExpect(jsonPath("$[0].rst_treatment_name", is(response.get(0).getRstTreatmentName())))
      .andExpect(jsonPath("$[0].rst_kur_cd", is(response.get(0).getRstKurCd().intValue())))
      .andExpect(jsonPath("$[0].rst_kur_name", is(response.get(0).getRstKurName())))
      .andExpect(jsonPath("$[0].rst_bed_cd", is(response.get(0).getRstBedCd().intValue())))
      .andExpect(jsonPath("$[0].rst_bed_name", is(response.get(0).getRstBedName())))
      .andExpect(jsonPath("$[0].rst_machine_name", is(response.get(0).getRstMachineName())))
      .andExpect(jsonPath("$[0].rst_cond_send_date", is(sf.format(response.get(0).getRstCondSendDate()))))
      .andExpect(jsonPath("$[0].rst_accept_date", is(sf.format(response.get(0).getRstAcceptDate()))))
      .andExpect(jsonPath("$[0].rst_start_date", is(sf.format(response.get(0).getRstStartDate()))))
      .andExpect(jsonPath("$[0].rst_end_date", is(sf.format(response.get(0).getRstEndDate()))))
      .andExpect(jsonPath("$[0].rst_return_home_date", is(sf.format(response.get(0).getRstReturnHomeDate()))))
      .andExpect(jsonPath("$[0].rst_in_out_class", is(response.get(0).getRstInOutClass())))
      .andExpect(jsonPath("$[0].rst_dialysis_cnt", is(response.get(0).getRstDialysisCnt())))
      .andExpect(jsonPath("$[0].rst_ward_cd", is(response.get(0).getRstWardCd())))
      .andExpect(jsonPath("$[0].rst_ward_name", is(response.get(0).getRstWardName())))
      .andExpect(jsonPath("$[0].rst_course_cd", is(response.get(0).getRstCourseCd())))
      .andExpect(jsonPath("$[0].rst_course_name", is(response.get(0).getRstCourseName())))
      .andExpect(jsonPath("$[0].rst_dw", is(response.get(0).getRstDw().doubleValue())))
      .andExpect(jsonPath("$[0].rst_puncture_user_info", is(response.get(0).getRstPunctureUserInfo())))
      .andExpect(jsonPath("$[0].rst_return_user_info", is(response.get(0).getRstReturnUserInfo())))
      .andExpect(jsonPath("$[0].rst_charge_user_info", is(response.get(0).getRstChargeUserInfo())))
      .andExpect(jsonPath("$[0].rst_blood_circulate_total", is(response.get(0).getRstBloodCirculateTotal().doubleValue())))
      .andExpect(jsonPath("$[0].rst_running_time", is(response.get(0).getRstRunningTime())))
      .andExpect(jsonPath("$[0].rst_kt_v", is(response.get(0).getRstKtV().doubleValue())))
      .andExpect(jsonPath("$[0].rec_set_date", is(sf.format(response.get(0).getRecSetDate()))))
      .andExpect(jsonPath("$[0].send_ctl_no", is(response.get(0).getSendCtlNo().intValue())))
      .andExpect(jsonPath("$[0].blood_purifier_name", is(response.get(0).getBloodPurifierName())))
      .andExpect(jsonPath("$[0].pull_leave_amount", is(response.get(0).getPullLeaveAmount().doubleValue())))
      .andExpect(jsonPath("$[0].rst_cond_info", is(response.get(0).getRstCondInfo())))
      .andExpect(jsonPath("$[0].rst_medi_info", is(response.get(0).getRstMediInfo())))
      .andExpect(jsonPath("$[0].rst_equip_info", is(response.get(0).getRstEquipInfo())))
      .andExpect(jsonPath("$[0].rst_ind_comment_info", is(response.get(0).getRstIndCommentInfo())))
      .andExpect(jsonPath("$[0].rst_tare_info", is(response.get(0).getRstTareInfo())))
      .andExpect(jsonPath("$[0].rst_off_water_info", is(response.get(0).getRstOffWaterInfo())))
//      .andExpect(jsonPath("$[0].rst_device_set_info", is(response.get(0).getRstDeviceSetInfo())))// del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
      .andExpect(jsonPath("$[0].weight_scale_no", is(response.get(0).getWeightScaleNo().intValue())))
      .andExpect(jsonPath("$[0].rst_weight_info", is(response.get(0).getRstWeightInfo())))
//      .andExpect(jsonPath("$[0].rst_vital_info", is(response.get(0).getRstVitalInfo())))
      .andExpect(jsonPath("$[0].rst_complaint_info", is(response.get(0).getRstComplaintInfo())))
      .andExpect(jsonPath("$[0].rst_treatment_info", is(response.get(0).getRstTreatmentInfo())))
      .andExpect(jsonPath("$[0].rst_treat_staff_info", is(response.get(0).getRstTreatStaffInfo())))
      .andExpect(jsonPath("$[0].rst_rounds_info", is(response.get(0).getRstRoundsInfo())))
      .andExpect(jsonPath("$[0].up_date", is(sf.format(response.get(0).getUpDate()))))
      .andExpect(jsonPath("$[1].ord_no", is(response.get(1).getOrdNo().intValue())))
      .andExpect(jsonPath("$[1].pat_id", is(response.get(1).getPatId().intValue())))
      .andExpect(jsonPath("$[1].hosp_pat_id", is(response.get(1).getHospPatId())))
      .andExpect(jsonPath("$[1].pat_name", is(response.get(1).getPatName())))
      .andExpect(jsonPath("$[1].rst_input_class", is(response.get(1).getRstInputClass())))
      .andExpect(jsonPath("$[1].rst_dialysis_state", is(response.get(1).getRstDialysisState())))
      .andExpect(jsonPath("$[1].rst_treatment_name", is(response.get(1).getRstTreatmentName())))
      .andExpect(jsonPath("$[1].rst_kur_cd", is(response.get(1).getRstKurCd().intValue())))
      .andExpect(jsonPath("$[1].rst_kur_name", is(response.get(1).getRstKurName())))
      .andExpect(jsonPath("$[1].rst_bed_cd", is(response.get(1).getRstBedCd().intValue())))
      .andExpect(jsonPath("$[1].rst_bed_name", is(response.get(1).getRstBedName())))
      .andExpect(jsonPath("$[1].rst_machine_name", is(response.get(1).getRstMachineName())))
      .andExpect(jsonPath("$[1].rst_cond_send_date", is(sf.format(response.get(1).getRstCondSendDate()))))
      .andExpect(jsonPath("$[1].rst_accept_date", is(sf.format(response.get(1).getRstAcceptDate()))))
      .andExpect(jsonPath("$[1].rst_start_date", is(sf.format(response.get(1).getRstStartDate()))))
      .andExpect(jsonPath("$[1].rst_end_date", is(sf.format(response.get(1).getRstEndDate()))))
      .andExpect(jsonPath("$[1].rst_return_home_date", is(sf.format(response.get(1).getRstReturnHomeDate()))))
      .andExpect(jsonPath("$[1].rst_in_out_class", is(response.get(1).getRstInOutClass())))
      .andExpect(jsonPath("$[1].rst_dialysis_cnt", is(response.get(1).getRstDialysisCnt())))
      .andExpect(jsonPath("$[1].rst_ward_cd", is(response.get(1).getRstWardCd())))
      .andExpect(jsonPath("$[1].rst_ward_name", is(response.get(1).getRstWardName())))
      .andExpect(jsonPath("$[1].rst_course_cd", is(response.get(1).getRstCourseCd())))
      .andExpect(jsonPath("$[1].rst_course_name", is(response.get(1).getRstCourseName())))
      .andExpect(jsonPath("$[1].rst_dw", is(response.get(1).getRstDw().doubleValue())))
      .andExpect(jsonPath("$[1].rst_puncture_user_info", is(response.get(1).getRstPunctureUserInfo())))
      .andExpect(jsonPath("$[1].rst_return_user_info", is(response.get(1).getRstReturnUserInfo())))
      .andExpect(jsonPath("$[1].rst_charge_user_info", is(response.get(1).getRstChargeUserInfo())))
      .andExpect(jsonPath("$[1].rst_blood_circulate_total", is(response.get(1).getRstBloodCirculateTotal().doubleValue())))
      .andExpect(jsonPath("$[1].rst_running_time", is(response.get(1).getRstRunningTime())))
      .andExpect(jsonPath("$[1].rst_kt_v", is(response.get(1).getRstKtV().doubleValue())))
      .andExpect(jsonPath("$[1].rec_set_date", is(sf.format(response.get(1).getRecSetDate()))))
      .andExpect(jsonPath("$[1].send_ctl_no", is(response.get(1).getSendCtlNo().intValue())))
      .andExpect(jsonPath("$[1].blood_purifier_name", is(response.get(1).getBloodPurifierName())))
      .andExpect(jsonPath("$[1].pull_leave_amount", is(response.get(1).getPullLeaveAmount().doubleValue())))
      .andExpect(jsonPath("$[1].rst_cond_info", is(response.get(1).getRstCondInfo())))
      .andExpect(jsonPath("$[1].rst_medi_info", is(response.get(1).getRstMediInfo())))
      .andExpect(jsonPath("$[1].rst_equip_info", is(response.get(1).getRstEquipInfo())))
      .andExpect(jsonPath("$[1].rst_ind_comment_info", is(response.get(1).getRstIndCommentInfo())))
      .andExpect(jsonPath("$[1].rst_tare_info", is(response.get(1).getRstTareInfo())))
      .andExpect(jsonPath("$[1].rst_off_water_info", is(response.get(1).getRstOffWaterInfo())))
//      .andExpect(jsonPath("$[1].rst_device_set_info", is(response.get(1).getRstDeviceSetInfo())))// del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
      .andExpect(jsonPath("$[1].weight_scale_no", is(response.get(1).getWeightScaleNo().intValue())))
      .andExpect(jsonPath("$[1].rst_weight_info", is(response.get(1).getRstWeightInfo())))
//      .andExpect(jsonPath("$[1].rst_vital_info", is(response.get(1).getRstVitalInfo())))
      .andExpect(jsonPath("$[1].rst_complaint_info", is(response.get(1).getRstComplaintInfo())))
      .andExpect(jsonPath("$[1].rst_treatment_info", is(response.get(1).getRstTreatmentInfo())))
      .andExpect(jsonPath("$[1].rst_treat_staff_info", is(response.get(1).getRstTreatStaffInfo())))
      .andExpect(jsonPath("$[1].rst_rounds_info", is(response.get(1).getRstRoundsInfo())))
      .andExpect(jsonPath("$[1].up_date", is(sf.format(response.get(1).getUpDate()))))
    ;
  }

  /**
   * getResultMergeList()の検証.
   * <p>
   * 条件：成功、代理編集権限ユーザ 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_PEDIT)
  public void test_getResultMergeList_成功_代理編集権限ユーザ() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    String facilityCd = "000001";
    List<TreatmentRecordResultMerge> response = Arrays.asList(
      getTreatmentRecordResultMerge(1L, 1L, "000000000001", "テスト患者1"),
      getTreatmentRecordResultMerge(2L, 2L, "000000000002", "テスト患者2")
    );
    SimpleDateFormat sf = new SimpleDateFormat(CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601);
    sf.setTimeZone(TimeZone.getTimeZone(CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO));

    // Mock化
    given(treatmentRecordResultMergeService.getResultMergeList(anyLong(), anyString())).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/result-merge", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // 検証
    verify(treatmentRecordResultMergeService, times(1)).getResultMergeList(ordNo, facilityCd);
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$", hasSize(2)))
    ;
  }

  /**
   * getResultMergeList()の検証.
   * <p>
   * 条件：成功、編集権限ユーザ 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_getResultMergeList_成功_編集権限ユーザ() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    String facilityCd = "000001";
    List<TreatmentRecordResultMerge> response = Arrays.asList(
      getTreatmentRecordResultMerge(1L, 1L, "000000000001", "テスト患者1"),
      getTreatmentRecordResultMerge(2L, 2L, "000000000002", "テスト患者2")
    );
    SimpleDateFormat sf = new SimpleDateFormat(CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601);
    sf.setTimeZone(TimeZone.getTimeZone(CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO));

    // Mock化
    given(treatmentRecordResultMergeService.getResultMergeList(anyLong(), anyString())).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/result-merge", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // 検証
    verify(treatmentRecordResultMergeService, times(1)).getResultMergeList(ordNo, facilityCd);
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$", hasSize(2)))
    ;
  }

  /**
   * getResultMergeList()の検証.
   * <p>
   * 条件：失敗 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getResultMergeList_失敗() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    String facilityCd = "000001";

    // Mock化
    given(treatmentRecordResultMergeService.getResultMergeList(anyLong(), anyString())).willThrow(new NotExistException("治療記録（実績マージ情報）が見つからない"));

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/result-merge", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // 検証
    verify(treatmentRecordResultMergeService, times(1)).getResultMergeList(ordNo, facilityCd);
    result
      .andExpect(status().isInternalServerError());
  }

  /**
   * updateResultMerge()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateResultMerge_成功() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordResultMerge request = getTreatmentRecordResultMerge(1L, 1L, "000000000001", "テスト患者1");
    // 更新者IDを設定
    request.setUpdStaffId(1L);
    String requestBody = mapper.writeValueAsString(request);
    ArgumentCaptor<Long> args1 = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<TreatmentRecordResultMerge> args2 = ArgumentCaptor.forClass(TreatmentRecordResultMerge.class);

    // Mock化
    doNothing().when(treatmentRecordResultMergeService).updateResultMerge(args1.capture(), args2.capture());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/result-merge", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordResultMergeService, times(1)).updateResultMerge(anyLong(), any());
    assertThat(args1.getValue(), is(ordNo));
    assertThat(mapper.writeValueAsString(args2.getValue()), is(requestBody));
    result.andExpect(status().isOk());
  }

  /**
   * updateResultMerge()の検証.
   * <p>
   * 条件：失敗（該当データなし） 結果：失敗レスポンス(Status:500)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateResultMerge_失敗_該当データなし() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordResultMerge request = getTreatmentRecordResultMerge(1L, 1L, "000000000001", "テスト患者1");
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    doThrow(new NotExistException("")).when(treatmentRecordResultMergeService).updateResultMerge(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/result-merge", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordResultMergeService, times(1)).updateResultMerge(anyLong(), any());
    result.andExpect(status().isInternalServerError());
  }

}
