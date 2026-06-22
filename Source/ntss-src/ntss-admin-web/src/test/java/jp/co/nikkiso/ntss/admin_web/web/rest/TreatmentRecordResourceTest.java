package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.junit.Assert.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.doNothing;
import static org.mockito.BDDMockito.doThrow;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.TimeZone;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.VitalMonitorData;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordAddition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordCondition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordDeviceSetInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordEquipInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMediInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMonitor;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResult;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordRoundsInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordSetting;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordVital;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordVitalMonitor;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordWeight;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.RecirculationRate;
import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.TreatmentRecordSummary;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordMonitorService;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordRoundService;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordService;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordSettingService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.exception.RequiredException;

/**
 * TreatmentRecordResourceのテストクラス.
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
public class TreatmentRecordResourceTest extends AbstractResourceTest {

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * 治療記録Service.
   */
  @MockitoBean
  private TreatmentRecordService treatmentRecordService;

  /**
   * 治療記録(モニタ)Service.
   */
  @MockitoBean
  private TreatmentRecordMonitorService treatmentRecordMonitorService;

  /**
   * 治療記録(装置設定)Service.
   */
  @MockitoBean
  private TreatmentRecordSettingService treatmentRecordSettingService;

  /**
   * 治療記録(回診記録)Service.
   */
  @MockitoBean
  private TreatmentRecordRoundService treatmentRecordRoundService;

  /**
   * 実績情報のテストデータ
   * @return {@link TreatmentRecordResult}
   */
  private TreatmentRecordResult getTreatmentRecordResult() {
    TreatmentRecordResult data = new TreatmentRecordResult();
    TreatmentRecordResult.RstUserInfo rstPunctureUserInfo = new TreatmentRecordResult.RstUserInfo();
    TreatmentRecordResult.RstUserInfo rstReturnUserInfo = new TreatmentRecordResult.RstUserInfo();
    TreatmentRecordResult.RstUserInfo rstChargeUserInfo = new TreatmentRecordResult.RstUserInfo();

    rstPunctureUserInfo.setUserId1(1L);
    rstPunctureUserInfo.setUserLastName1("穿刺者名_姓1");
    rstPunctureUserInfo.setUserFirstName1("穿刺者名_名1");
    rstPunctureUserInfo.setUserId2(2L);
    rstPunctureUserInfo.setUserLastName2("穿刺者名_姓2");
    rstPunctureUserInfo.setUserFirstName2("穿刺者名_名2");
    rstPunctureUserInfo.setDate("2019-02-20 12:00:00");
    rstPunctureUserInfo.setDate1(Timestamp.valueOf("2019-02-20 12:01:00"));
    rstPunctureUserInfo.setDate2(Timestamp.valueOf("2019-02-20 12:02:00"));

    rstReturnUserInfo.setUserId1(3L);
    rstReturnUserInfo.setUserLastName1("返血者名_姓1");
    rstReturnUserInfo.setUserFirstName1("返血者名_名1");
    rstReturnUserInfo.setUserId2(4L);
    rstReturnUserInfo.setUserLastName2("返血者名_姓2");
    rstReturnUserInfo.setUserFirstName2("返血者名_名2");
    rstReturnUserInfo.setDate("2019-02-20 18:00:00");
    rstReturnUserInfo.setDate1(Timestamp.valueOf("2019-02-20 18:01:00"));
    rstReturnUserInfo.setDate2(Timestamp.valueOf("2019-02-20 18:02:00"));

    rstChargeUserInfo.setUserId1(5L);
    rstChargeUserInfo.setUserLastName1("担当者名_姓1");
    rstChargeUserInfo.setUserFirstName1("担当者名_名1");
    rstChargeUserInfo.setUserId2(6L);
    rstChargeUserInfo.setUserLastName2("担当者名_姓2");
    rstChargeUserInfo.setUserFirstName2("担当者名_名2");
    rstChargeUserInfo.setDate1(Timestamp.valueOf("2019-02-20 19:01:00"));
    rstChargeUserInfo.setDate2(Timestamp.valueOf("2019-02-20 19:02:00"));

    data.setRstDialysisState("1");
    data.setRstKurCd(2L);
    data.setRstKurName("クール名");
    data.setRstBedCd(5L);
    data.setRstBedName("ベッド名");
    data.setRstStartDate(Timestamp.valueOf("2019-02-15 06:00:00"));
    data.setRstEndDate(Timestamp.valueOf("2019-02-15 11:30:00"));
    data.setRstInOutClass((short)1);
    data.setRstDialysisCnt(2);
    data.setRstWardCd(7);
    data.setRstWardName("病棟名");
    data.setRstCourseCd(8);
    data.setRstCourseName("診療科名");
    // 治療方法コード
    data.setRstTreatmentCd(100);
    // 治療方法名
    data.setRstTreatmentName("テスト治療法");
    data.setRstPunctureUserInfo(rstPunctureUserInfo);
    data.setRstReturnUserInfo(rstReturnUserInfo);
    data.setRstChargeUserInfo(rstChargeUserInfo);

    return data;
  }

  /**
   * 治療条件のテストデータ取得
   * @return 治療条件のテストデータ
   */
  private TreatmentRecordCondition getTreatmentRecordCondition() {
    TreatmentRecordCondition data = new TreatmentRecordCondition();

    data.setIndTreatStartTime("1423");
    data.setRstCondInfo("{\"1\": {\"value\": \"0400\", \"value_name_1\": null}}");
    data.setRstDw(BigDecimal.valueOf(66.30));

    return data;
  }

  private TreatmentRecordWeight getTreatmentRecordWeight() {
    TreatmentRecordWeight data = new TreatmentRecordWeight();

    data.setLastWeight(BigDecimal.valueOf(53.96));
    data.setRstDw(BigDecimal.valueOf(66.30));
    data.setTargetWeight(BigDecimal.valueOf(51.5));
    data.setWaterRemovalAmountLimit(BigDecimal.valueOf(6.43));
    data.setRstWeightInfo("{\"1\": {\"value\": \"0400\", \"value_name_1\": null}}");
    data.setRstTareInfo("{\"1\": {\"value\": \"0500\", \"value_name_1\": null}}");
    data.setRstOffWaterInfo("{\"1\": {\"value\": \"0600\", \"value_name_1\": null}}");

    return data;
  }

  private List<RecirculationRate> getRecirculationRate() {
    List<RecirculationRate> datas = new ArrayList<>();

    ZonedDateTime date = ZonedDateTime.of(2019, 2, 20, 12, 0,0, 0, ZoneId.systemDefault());
    RecirculationRate data = new RecirculationRate(123L, date, 10, 20);
    datas.add(data);

    return datas;
  }

  private TreatmentRecordMediInfo getTreatmentRecordMediInfo() {
    TreatmentRecordMediInfo data = new TreatmentRecordMediInfo();

    data.setRstMediInfo("{\"1\": {\"value\": \"0400\", \"value_name_1\": null}}");

    return data;
  }

  private TreatmentRecordEquipInfo getTreatmentRecordEquipInfo() {
    TreatmentRecordEquipInfo data = new TreatmentRecordEquipInfo();

    data.setRstEquipInfo("{\"1\": {\"value\": \"0400\", \"value_name_1\": null}}");

    return data;
  }

  private TreatmentRecordAddition getTreatmentRecordAddition() {
    TreatmentRecordAddition data = new TreatmentRecordAddition();

    data.setRstIndCommentInfo("{\"1\": {\"value\": \"0400\", \"value_name_1\": null}}");

    return data;
  }

  private TreatmentRecordVital getTreatmentRecordVital() {
    TreatmentRecordVital data = new TreatmentRecordVital();

//    data.setRstVitalInfo("{\"1\": {\"value\": \"0400\", \"value_name_1\": null}}");

    return data;
  }

  private TreatmentRecordVitalMonitor getVitalMonitor(Long bioMoniCtlNo, Short dataType) {
    TreatmentRecordVitalMonitor vitalMonitor = new TreatmentRecordVitalMonitor();
    vitalMonitor.setBioMoniCtlNo(bioMoniCtlNo);
    vitalMonitor.setDataType(dataType);
    vitalMonitor.setMonitorData("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    vitalMonitor.setOccurDate(Timestamp.valueOf("2019-05-08 12:00:00.000"));

    return vitalMonitor;
  }

  private TreatmentRecordMonitor getMonitor(Long bioMoniCtlNo) {
    TreatmentRecordMonitor mniMonitor = new TreatmentRecordMonitor();
    mniMonitor.setBioMoniCtlNo(bioMoniCtlNo);
    mniMonitor.setMonitorData("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    mniMonitor.setOccurDate(Timestamp.valueOf("2019-05-08 12:00:00.000"));
    mniMonitor.setIsDel("0");

    return mniMonitor;
  }

  private TreatmentRecordRoundsInfo getTreatmentRecordRoundsInfo() {
    TreatmentRecordRoundsInfo data = new TreatmentRecordRoundsInfo();

    data.setRstRoundsInfo("{\"1\": {\"value\": \"0400\", \"value_name_1\": null}}");

    return data;
  }

  /**
   * getTreatmentRecordSummary()の検証.
   * <p>
   * 条件：成功、閲覧権限ユーザ 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordSummary_成功_閲覧権限() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordSummary response = new TreatmentRecordSummary(
      "2019/04/09(火)",
      "ベッド１",
      "クール１",
      "治療方法１"
    );

    // Mock化
    given(treatmentRecordService.getTreatmentRecordSummary(anyLong())).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/summary", ordNo)
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordService, times(1)).getTreatmentRecordSummary(ordNo);
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.treatment_date", is(response.getTreatmentDate())))
      .andExpect(jsonPath("$.bed_name", is(response.getBedName())))
      .andExpect(jsonPath("$.kur_name", is(response.getKurName())))
      .andExpect(jsonPath("$.treatment_name", is(response.getTreatmentName())));
  }

  /**
   * getTreatmentRecordSummary()の検証.
   * <p>
   * 条件：成功、代理編集権限ユーザ 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_PEDIT)
  public void test_getTreatmentRecordSummary_成功_代理編集権限() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordSummary response = new TreatmentRecordSummary(
      "2019/04/09(火)",
      "ベッド１",
      "クール１",
      "治療方法１"
    );

    // Mock化
    given(treatmentRecordService.getTreatmentRecordSummary(anyLong())).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/summary", ordNo)
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordService, times(1)).getTreatmentRecordSummary(ordNo);
    result
      .andExpect(status().isOk());
  }

  /**
   * getTreatmentRecordSummary()の検証.
   * <p>
   * 条件：成功、編集権限ユーザ 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_getTreatmentRecordSummary_成功_編集権限() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordSummary response = new TreatmentRecordSummary(
      "2019/04/09(火)",
      "ベッド１",
      "クール１",
      "治療方法１"
    );

    // Mock化
    given(treatmentRecordService.getTreatmentRecordSummary(anyLong())).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/summary", ordNo)
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordService, times(1)).getTreatmentRecordSummary(ordNo);
    result
      .andExpect(status().isOk());
  }

  /**
   * getTreatmentRecordSummary()の検証.
   * <p>
   * 条件：失敗 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordSummary_失敗() throws Exception {
    // 事前準備
    Long ordNo = 12345L;

    // Mock化
    given(treatmentRecordService.getTreatmentRecordSummary(anyLong())).willThrow(new NotExistException("治療記録が見つからない"));

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/summary", ordNo)
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordService, times(1)).getTreatmentRecordSummary(ordNo);
    result
      .andExpect(status().isInternalServerError());
  }

  /**
   * getTreatmentRecordResult()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordResult_成功() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordResult response = getTreatmentRecordResult();
    SimpleDateFormat f = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    f.setTimeZone(TimeZone.getTimeZone("UTC"));

    // Mock化
    given(treatmentRecordService.getTreatmentRecordResult(anyLong())).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/result", ordNo)
        .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordService, times(1)).getTreatmentRecordResult(ordNo);
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.rst_dialysis_state", is(response.getRstDialysisState())))
      .andExpect(jsonPath("$.rst_kur_cd", is(response.getRstKurCd().intValue())))
      .andExpect(jsonPath("$.rst_kur_name", is(response.getRstKurName())))
      .andExpect(jsonPath("$.rst_bed_cd", is(response.getRstBedCd().intValue())))
      .andExpect(jsonPath("$.rst_bed_name", is(response.getRstBedName())))
      .andExpect(jsonPath("$.rst_start_date", is("2019-02-15T06:00:00.000+09:00")))
      .andExpect(jsonPath("$.rst_end_date", is("2019-02-15T11:30:00.000+09:00")))
      .andExpect(jsonPath("$.rst_in_out_class", is(response.getRstInOutClass().intValue())))
      .andExpect(jsonPath("$.rst_dialysis_cnt", is(response.getRstDialysisCnt())))
      .andExpect(jsonPath("$.rst_ward_cd", is(response.getRstWardCd())))
      .andExpect(jsonPath("$.rst_ward_name", is(response.getRstWardName())))
      .andExpect(jsonPath("$.rst_course_cd", is(response.getRstCourseCd())))
      .andExpect(jsonPath("$.rst_course_name", is(response.getRstCourseName())))
      .andExpect(jsonPath("$.rst_treatment_cd", is(response.getRstTreatmentCd())))
      .andExpect(jsonPath("$.rst_treatment_name", is(response.getRstTreatmentName())))
      .andExpect(jsonPath("$.rst_puncture_user_info.user_id_1", is(response.getRstPunctureUserInfo().getUserId1().intValue())))
      .andExpect(jsonPath("$.rst_puncture_user_info.user_last_name_1", is(response.getRstPunctureUserInfo().getUserLastName1())))
      .andExpect(jsonPath("$.rst_puncture_user_info.user_first_name_1", is(response.getRstPunctureUserInfo().getUserFirstName1())))
      .andExpect(jsonPath("$.rst_puncture_user_info.user_id_2", is(response.getRstPunctureUserInfo().getUserId2().intValue())))
      .andExpect(jsonPath("$.rst_puncture_user_info.user_last_name_2", is(response.getRstPunctureUserInfo().getUserLastName2())))
      .andExpect(jsonPath("$.rst_puncture_user_info.user_first_name_2", is(response.getRstPunctureUserInfo().getUserFirstName2())))
      .andExpect(jsonPath("$.rst_puncture_user_info.date", is("2019-02-20T12:00:00.000+09:00")))
      .andExpect(jsonPath("$.rst_return_user_info.user_id_1", is(response.getRstReturnUserInfo().getUserId1().intValue())))
      .andExpect(jsonPath("$.rst_return_user_info.user_last_name_1", is(response.getRstReturnUserInfo().getUserLastName1())))
      .andExpect(jsonPath("$.rst_return_user_info.user_first_name_1", is(response.getRstReturnUserInfo().getUserFirstName1())))
      .andExpect(jsonPath("$.rst_return_user_info.user_id_2", is(response.getRstReturnUserInfo().getUserId2().intValue())))
      .andExpect(jsonPath("$.rst_return_user_info.user_last_name_2", is(response.getRstReturnUserInfo().getUserLastName2())))
      .andExpect(jsonPath("$.rst_return_user_info.user_first_name_2", is(response.getRstReturnUserInfo().getUserFirstName2())))
      .andExpect(jsonPath("$.rst_return_user_info.date", is("2019-02-20T18:00:00.000+09:00")))
      .andExpect(jsonPath("$.rst_charge_user_info.user_id_1", is(response.getRstChargeUserInfo().getUserId1().intValue())))
      .andExpect(jsonPath("$.rst_charge_user_info.user_last_name_1", is(response.getRstChargeUserInfo().getUserLastName1())))
      .andExpect(jsonPath("$.rst_charge_user_info.user_first_name_1", is(response.getRstChargeUserInfo().getUserFirstName1())))
      .andExpect(jsonPath("$.rst_charge_user_info.user_id_2", is(response.getRstChargeUserInfo().getUserId2().intValue())))
      .andExpect(jsonPath("$.rst_charge_user_info.user_last_name_2", is(response.getRstChargeUserInfo().getUserLastName2())))
      .andExpect(jsonPath("$.rst_charge_user_info.user_first_name_2", is(response.getRstChargeUserInfo().getUserFirstName2())));
  }

  /**
   * getTreatmentRecordResult()の検証.
   * <p>
   * 条件：失敗 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordResult_失敗() throws Exception {
    // 事前準備
    Long ordNo = 12345L;

    // Mock化
    given(treatmentRecordService.getTreatmentRecordResult(anyLong())).willThrow(new NotExistException("治療記録が見つからない"));

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/result", ordNo)
        .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordService, times(1)).getTreatmentRecordResult(ordNo);
    result
      .andExpect(status().isInternalServerError());
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordResult_成功() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordResult request = getTreatmentRecordResult();
    String requestBody = mapper.writeValueAsString(request);
    ArgumentCaptor<Long> args1 = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<TreatmentRecordResult> args2 = ArgumentCaptor.forClass(TreatmentRecordResult.class);

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordResult(args1.capture(), args2.capture());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordResult(anyLong(), any());
    assertThat(args1.getValue(), is(ordNo));
    assertThat(mapper.writeValueAsString(args2.getValue()), is(requestBody));
    result.andExpect(status().isOk());
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * <p>
   * 条件：失敗（該当データなし） 結果：失敗レスポンス(Status:500)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordResult_失敗_該当データなし() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordResult request = getTreatmentRecordResult();
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    doThrow(new NotExistException("")).when(treatmentRecordService).updateTreatmentRecordResult(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordResult(anyLong(), any());
    result.andExpect(status().isInternalServerError());

  }

  /**
   * updateTreatmentRecordResult()の検証.
   * <p>
   * 条件：失敗（入外区分未入力） 結果：失敗レスポンス(Status:400)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Ignore
  public void test_updateTreatmentRecordResult_失敗_入外区分未入力() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordResult request = getTreatmentRecordResult();
    request.setRstInOutClass(null);

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordResult(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(request)).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(0)).updateTreatmentRecordResult(anyLong(), any());
    result.andExpect(status().isBadRequest());
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * <p>
   * 条件：成功（入外区分未入力） 結果：成功レスポンス(Status:200)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordResult_成功_入外区分未入力() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordResult request = getTreatmentRecordResult();
    request.setRstInOutClass(null);

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordResult(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(request)).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordResult(anyLong(), any());
    result.andExpect(status().isOk());
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * <p>
   * 条件：失敗（透析開始日時未入力） 結果：失敗レスポンス(Status:400)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Ignore
  public void test_updateTreatmentRecordResult_失敗_透析開始日時未入力() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordResult request = getTreatmentRecordResult();
    request.setRstStartDate(null);

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordResult(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(request)).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(0)).updateTreatmentRecordResult(anyLong(), any());
    result.andExpect(status().isBadRequest());
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * <p>
   * 条件：成功（透析開始日時未入力） 結果：成功レスポンス(Status:200)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordResult_成功_透析開始日時未入力() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordResult request = getTreatmentRecordResult();
    request.setRstStartDate(null);

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordResult(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(request)).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordResult(anyLong(), any());
    result.andExpect(status().isOk());
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * <p>
   * 条件：失敗（透析終了日時未入力） 結果：成功レスポンス(Status:200)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordResult_成功_透析終了日時未入力() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordResult request = getTreatmentRecordResult();
    request.setRstEndDate(null);

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordResult(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(request)).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordResult(anyLong(), any());
    result.andExpect(status().isOk());
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * <p>
   * 条件：失敗（クール未入力） 結果：失敗レスポンス(Status:400)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Ignore
  public void test_updateTreatmentRecordResult_失敗_クール未入力() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordResult request = getTreatmentRecordResult();
    request.setRstKurCd(null);
    request.setRstKurName("");

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordResult(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(request)).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(0)).updateTreatmentRecordResult(anyLong(), any());
    result.andExpect(status().isBadRequest());
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * <p>
   * 条件：成功（クール未入力） 結果：成功レスポンス(Status:200)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordResult_成功_クール未入力() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordResult request = getTreatmentRecordResult();
    request.setRstKurCd(null);
    request.setRstKurName("");

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordResult(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(request)).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordResult(anyLong(), any());
    result.andExpect(status().isOk());
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * <p>
   * 条件：失敗（ベッド未入力） 結果：失敗レスポンス(Status:400)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Ignore
  public void test_updateTreatmentRecordResult_失敗_ベッド未入力() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordResult request = getTreatmentRecordResult();
    request.setRstBedCd(null);
    request.setRstBedName("");

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordResult(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(request)).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(0)).updateTreatmentRecordResult(anyLong(), any());
    result.andExpect(status().isBadRequest());
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * <p>
   * 条件：成功（ベッド未入力） 結果：成功レスポンス(Status:200)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordResult_成功_ベッド未入力() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordResult request = getTreatmentRecordResult();
    request.setRstBedCd(null);
    request.setRstBedName("");

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordResult(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(request)).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordResult(anyLong(), any());
    result.andExpect(status().isOk());
  }

  /**
   * getTreatmentRecordMediInfo()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordMediInfo_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordMediInfo mediInfo = new TreatmentRecordMediInfo();
    mediInfo.setOrdNo(ordNo);
    mediInfo.setTreatDate("20190201");
    mediInfo.setRstDialysisState("0");
    mediInfo.setRstStartDate(Timestamp.valueOf("2019-03-01 12:00:00.000"));
    mediInfo.setRstMediInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    given(treatmentRecordService.getTreatmentRecordMediInfo(any())).willReturn(mediInfo);

    // action
    // assert
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/medi_info", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.treat_date", is("20190201")))
      .andExpect(jsonPath("$.rst_dialysis_state", is("0")))
      .andExpect(jsonPath("$.rst_start_date", is("2019-03-01T12:00:00.000+09:00")))
      .andExpect(jsonPath("$.rst_medi_info", is("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]")))
    ;

    // assert
    verify(treatmentRecordService, times(1)).getTreatmentRecordMediInfo(ordNo);
  }

  /**
   * getTreatmentRecordCondition()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordCondition_成功() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordCondition response = getTreatmentRecordCondition();

    // Mock化
    given(treatmentRecordService.getTreatmentRecordCondition(anyLong())).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/condition", ordNo)
        .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordService, times(1)).getTreatmentRecordCondition(ordNo);
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.ind_treat_start_time", is(response.getIndTreatStartTime())))
      .andExpect(jsonPath("$.rst_cond_info", is(response.getRstCondInfo())))
      .andExpect(jsonPath("$.rst_dw", is(response.getRstDw().doubleValue())));
  }

  /**
   * getTreatmentRecordEquipInfo()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordEquipInfo_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordEquipInfo equipInfo = new TreatmentRecordEquipInfo();
    equipInfo.setOrdNo(ordNo);
    equipInfo.setRstDialysisState("0");
    equipInfo.setRstEquipInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    given(treatmentRecordService.getTreatmentRecordEquipInfo(any())).willReturn(equipInfo);

    // action
    // assert
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/equip_info", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.rst_dialysis_state", is("0")))
      .andExpect(jsonPath("$.rst_equip_info", is("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]")))
    ;

    // assert
    verify(treatmentRecordService, times(1)).getTreatmentRecordEquipInfo(ordNo);
  }

  /**
   * getTreatmentRecordMediInfo()の検証.
   * <p>
   * 条件：失敗 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordMediInfo_失敗() throws Exception {
    // arrange
    final Long ordNo = 1L;
    given(treatmentRecordService.getTreatmentRecordMediInfo(any())).willThrow(NotExistException.class);

    // action
    // assert
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/medi_info", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isInternalServerError())
    ;

    // assert
    verify(treatmentRecordService, times(1)).getTreatmentRecordMediInfo(ordNo);
  }

  /**
   * getTreatmentRecordCondition()の検証.
   * <p>
   * 条件：失敗 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordCondition_失敗() throws Exception {
    // 事前準備
    Long ordNo = 12345L;

    // Mock化
    given(treatmentRecordService.getTreatmentRecordCondition(anyLong())).willThrow(new NotExistException("治療記録(治療条件)が見つからない"));

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/condition", ordNo)
        .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordService, times(1)).getTreatmentRecordCondition(ordNo);
    result
      .andExpect(status().isInternalServerError());
  }

  /**
   * getTreatmentRecordEquipInfo()の検証.
   * <p>
   * 条件：失敗 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordEquipInfo_失敗() throws Exception {
    // arrange
    final Long ordNo = 1L;
    given(treatmentRecordService.getTreatmentRecordEquipInfo(any())).willThrow(NotExistException.class);

    // action
    // assert
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/equip_info", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isInternalServerError())
    ;

    // assert
    verify(treatmentRecordService, times(1)).getTreatmentRecordEquipInfo(ordNo);
  }

  /**
   * updateTreatmentRecordEquipInfo()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordEquipInfo_成功() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordEquipInfo request = getTreatmentRecordEquipInfo();
    String requestBody = mapper.writeValueAsString(request);
    ArgumentCaptor<Long> args1 = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<TreatmentRecordEquipInfo> args2 = ArgumentCaptor.forClass(TreatmentRecordEquipInfo.class);

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordEquipInfo(args1.capture(), args2.capture());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/equip_info", ordNo)
        .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordEquipInfo(anyLong(), any());
    assertThat(args1.getValue(), is(ordNo));
    assertThat(mapper.writeValueAsString(args2.getValue()), is(requestBody));
    result.andExpect(status().isOk());
  }

  /**
   * updateTreatmentRecordEquipInfo()の検証.
   * <p>
   * 条件：失敗（該当データなし） 結果：失敗レスポンス(Status:500)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordEquipInfo_失敗_該当データなし() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordEquipInfo request = getTreatmentRecordEquipInfo();
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    doThrow(new NotExistException("")).when(treatmentRecordService).updateTreatmentRecordEquipInfo(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/equip_info", ordNo)
        .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordEquipInfo(anyLong(), any());
    result.andExpect(status().isInternalServerError());
  }

  /**
   * updateTreatmentRecordCondition()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordCondition_成功() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordCondition request = getTreatmentRecordCondition();
    String requestBody = mapper.writeValueAsString(request);
    ArgumentCaptor<Long> args1 = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<TreatmentRecordCondition> args2 = ArgumentCaptor.forClass(TreatmentRecordCondition.class);

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordCondition(args1.capture(), args2.capture());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/condition", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordCondition(anyLong(), any());
    assertThat(args1.getValue(), is(ordNo));
    assertThat(mapper.writeValueAsString(args2.getValue()), is(requestBody));
    result.andExpect(status().isOk());
  }

  /**
   * updateTreatmentRecordCondition()の検証.
   * <p>
   * 条件：失敗（該当データなし） 結果：失敗レスポンス(Status:500)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordCondition_失敗_該当データなし() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordCondition request = getTreatmentRecordCondition();
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    doThrow(new NotExistException("")).when(treatmentRecordService).updateTreatmentRecordCondition(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/condition", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordCondition(anyLong(), any());
    result.andExpect(status().isInternalServerError());
  }

//  /**
//   * updateTreatmentRecordCondition()の検証.
//   * <p>
//   * 条件：失敗（治療方法未入力） 結果：失敗レスポンス(Status:400)が返されること
//   * </p>
//   */
//  @Test
//  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
//  public void test_updateTreatmentRecordCondition_失敗_治療方法未入力() throws Exception {
//    // 事前準備
//    Long ordNo = 12345L;
//    TreatmentRecordCondition request = getTreatmentRecordCondition();
//    request.setRstTreatmentCd(null);
//    request.setRstTreatmentName("");
//    String requestBody = mapper.writeValueAsString(request);
//
//    // Mock化
//    doNothing().when(treatmentRecordService).updateTreatmentRecordCondition(anyLong(), any());
//
//    // API実行
//    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/condition", ordNo)
//      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));
//
//    // 検証
//    verify(treatmentRecordService, times(0)).updateTreatmentRecordCondition(anyLong(), any());
//    result.andExpect(status().isBadRequest());
//  }

  /**
   * getRecirculationRate()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getRecirculationRate_成功() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    List<RecirculationRate> response = getRecirculationRate();

    // Mock化
    given(treatmentRecordService.getRecirculationRate(anyLong())).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/recirculation-rate", ordNo)
        .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordService, times(1)).getRecirculationRate(ordNo);
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$[0].bio_moni_ctl_no", is(response.get(0).getBioMoniCtlNo().intValue())))
      .andExpect(jsonPath("$[0].date", is("2019-02-20T12:00:00+09:00")))
      .andExpect(jsonPath("$[0].recirculation_rate", is(response.get(0).getRecirculationRate())))
      .andExpect(jsonPath("$[0].blood_flow", is(response.get(0).getBloodFlow())));
  }

  /**
   * updateTreatmentRecordMediInfo()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordMediInfo_成功() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordMediInfo request = getTreatmentRecordMediInfo();
    String requestBody = mapper.writeValueAsString(request);
    ArgumentCaptor<Long> args1 = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<TreatmentRecordMediInfo> args2 = ArgumentCaptor.forClass(TreatmentRecordMediInfo.class);

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordMediInfo(args1.capture(), args2.capture());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/medi_info", ordNo)
        .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordMediInfo(anyLong(), any());
    assertThat(args1.getValue(), is(ordNo));
    assertThat(mapper.writeValueAsString(args2.getValue()), is(requestBody));
    result.andExpect(status().isOk());
  }

  /**
   * getTreatmentRecordWeight()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordWeight_成功() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordWeight response = getTreatmentRecordWeight();

    // Mock化
    given(treatmentRecordService.getTreatmentRecordWeight(anyLong())).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/weight", ordNo)
        .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordService, times(1)).getTreatmentRecordWeight(ordNo);
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.last_weight", is(response.getLastWeight().doubleValue())))
      .andExpect(jsonPath("$.rst_dw", is(response.getRstDw().doubleValue())))
      .andExpect(jsonPath("$.target_weight", is(response.getTargetWeight().doubleValue())))
      .andExpect(jsonPath("$.water_removal_amount_limit", is(response.getWaterRemovalAmountLimit().doubleValue())))
      .andExpect(jsonPath("$.rst_weight_info", is(response.getRstWeightInfo())))
      .andExpect(jsonPath("$.rst_tare_info", is(response.getRstTareInfo())))
      .andExpect(jsonPath("$.rst_off_water_info", is(response.getRstOffWaterInfo())));
  }

  /**
   * updateTreatmentRecordMediInfo()の検証.
   * <p>
   * 条件：失敗（該当データなし） 結果：失敗レスポンス(Status:500)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordMediInfo_失敗_該当データなし() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordMediInfo request = getTreatmentRecordMediInfo();
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    doThrow(new NotExistException("")).when(treatmentRecordService).updateTreatmentRecordMediInfo(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/medi_info", ordNo)
        .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordMediInfo(anyLong(), any());
    result.andExpect(status().isInternalServerError());
  }

  /**
   * getTreatmentRecordWeight()の検証.
   * <p>
   * 条件：失敗 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordWeight_失敗() throws Exception {
    // 事前準備
    Long ordNo = 12345L;

    // Mock化
    given(treatmentRecordService.getTreatmentRecordWeight(anyLong())).willThrow(new NotExistException("治療記録(体重情報)が見つからない"));

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/weight", ordNo)
        .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordService, times(1)).getTreatmentRecordWeight(ordNo);
    result
      .andExpect(status().isInternalServerError());
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordWeight_成功() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordWeight request = getTreatmentRecordWeight();
    String requestBody = mapper.writeValueAsString(request);
    ArgumentCaptor<Long> args1 = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<TreatmentRecordWeight> args2 = ArgumentCaptor.forClass(TreatmentRecordWeight.class);

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordWeight(args1.capture(), args2.capture());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/weight", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordWeight(anyLong(), any());
    assertThat(args1.getValue(), is(ordNo));
    assertThat(mapper.writeValueAsString(args2.getValue()), is(requestBody));
    result.andExpect(status().isOk());
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   * <p>
   * 条件：失敗（該当データなし） 結果：失敗レスポンス(Status:500)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordWeight_失敗_該当データなし() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordWeight request = getTreatmentRecordWeight();
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    doThrow(new NotExistException("")).when(treatmentRecordService).updateTreatmentRecordWeight(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/weight", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordWeight(anyLong(), any());
    result.andExpect(status().isInternalServerError());
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   * <p>
   * 条件：失敗（測定日時未入力） 結果：失敗レスポンス(Status:400)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordWeight_失敗_測定日時未入力() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordWeight request = getTreatmentRecordWeight();
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    doThrow(new RequiredException("")).when(treatmentRecordService).updateTreatmentRecordWeight(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/weight", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordWeight(anyLong(), any());
    result.andExpect(status().isBadRequest());
  }

  /**
   * getLatestOrdNo()の検証.
   * <p>
   * 条件：成功（オーダ番号あり） 結果：成功レスポンス(Status:200)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getLatestOrdNo_成功_オーダ番号あり() throws Exception {
    // 事前準備
    Long patId = 12345L;
    Long ordNo = 9L;

    // Mock化
    given(treatmentRecordService.getLatestOrdNo(anyLong(), anyString())).willReturn(ordNo);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{pat_id}/latest-ord-no", patId)
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordService, times(1)).getLatestOrdNo(anyLong(), any());
    result.andExpect(status().isOk())
      .andExpect(content().string(ordNo.toString()));
  }

  /**
   * getLatestOrdNo()の検証.
   * <p>
   * 条件：成功（オーダ番号なし） 結果：成功レスポンス(Status:200)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getLatestOrdNo_成功_オーダ番号なし() throws Exception {
    // 事前準備
    Long patId = 12345L;
    Long ordNo = null;

    // Mock化
    given(treatmentRecordService.getLatestOrdNo(anyLong(), anyString())).willReturn(ordNo);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{pat_id}/latest-ord-no", patId)
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordService, times(1)).getLatestOrdNo(anyLong(), any());
    result.andExpect(status().isOk())
      .andExpect(content().string(""));
  }

  /**
   * getTreatmentRecordAddition()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordAddition_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordAddition addition = new TreatmentRecordAddition();
    addition.setPatId(10L);
    addition.setFacilityCd("009999");
    addition.setTreatDate("20190415");
    addition.setRstKurCd(20L);
    addition.setRstTreatmentCd(30L);
    addition.setRstIndCommentInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    given(treatmentRecordService.getTreatmentRecordAddition(any())).willReturn(addition);

    // action
    // assert
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/addition", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.pat_id", is(10)))
      .andExpect(jsonPath("$.facility_cd", is("009999")))
      .andExpect(jsonPath("$.treat_date", is("20190415")))
      .andExpect(jsonPath("$.rst_kur_cd", is(20)))
      .andExpect(jsonPath("$.rst_treatment_cd", is(30)))
      .andExpect(jsonPath("$.rst_ind_comment_info", is("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]")))
    ;

    // assert
    verify(treatmentRecordService, times(1)).getTreatmentRecordAddition(ordNo);
  }


  /**
   * getTreatmentRecordAddition()の検証.
   * <p>
   * 条件：失敗 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordAddition_失敗() throws Exception {
    // 事前準備
    Long ordNo = 12345L;

    // Mock化
    given(treatmentRecordService.getTreatmentRecordAddition(anyLong())).willThrow(new NotExistException("治療記録(指示コメント)が見つからない"));

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/addition", ordNo)
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordService, times(1)).getTreatmentRecordAddition(ordNo);
    result
      .andExpect(status().isInternalServerError());
  }

  /**
   * updateTreatmentRecordAddition()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordAddition_成功() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordAddition request = getTreatmentRecordAddition();
    String requestBody = mapper.writeValueAsString(request);
    ArgumentCaptor<Long> args1 = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<TreatmentRecordAddition> args2 = ArgumentCaptor.forClass(TreatmentRecordAddition.class);

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordAddition(args1.capture(), args2.capture());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/addition", ordNo)
        .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordAddition(anyLong(), any());
    assertThat(args1.getValue(), is(ordNo));
    assertThat(mapper.writeValueAsString(args2.getValue()), is(requestBody));
    result.andExpect(status().isOk());
  }

  /**
   * updateTreatmentRecordAddition()の検証.
   * <p>
   * 条件：失敗（該当データなし） 結果：失敗レスポンス(Status:500)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordAddition_失敗_該当データなし() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordAddition request = getTreatmentRecordAddition();
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    doThrow(new NotExistException("")).when(treatmentRecordService).updateTreatmentRecordAddition(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/addition", ordNo)
        .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).updateTreatmentRecordAddition(anyLong(), any());
    result.andExpect(status().isInternalServerError());
  }

  /**
   * updateTreatmentRecordAddition()の検証.
   * <p>
   * 条件：失敗（指示コメントnull） 結果：失敗レスポンス(Status:400)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordAddition_失敗_指示コメントnull() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordAddition request = getTreatmentRecordAddition();
    request.setRstIndCommentInfo(null);

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordAddition(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/addition", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(request)).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(0)).updateTreatmentRecordAddition(anyLong(), any());
    result.andExpect(status().isBadRequest());
  }

  /**
   * updateTreatmentRecordAddition()の検証.
   * <p>
   * 条件：失敗（指示コメント空文字） 結果：失敗レスポンス(Status:400)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordAddition_失敗_指示コメント空文字() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordAddition request = getTreatmentRecordAddition();
    request.setRstIndCommentInfo("");

    // Mock化
    doNothing().when(treatmentRecordService).updateTreatmentRecordAddition(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/addition", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(request)).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(0)).updateTreatmentRecordAddition(anyLong(), any());
    result.andExpect(status().isBadRequest());
  }

  /**
   * getTreatmentRecordVitalMonitor()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordVitalMonitor_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;
    List<TreatmentRecordVitalMonitor> vitalMonitors = Arrays.asList(
      getVitalMonitor(1L, (short)1),
      getVitalMonitor(2L, (short)2),
      getVitalMonitor(3L, (short)3)
    );
    SimpleDateFormat sf = new SimpleDateFormat(CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601);
    sf.setTimeZone(TimeZone.getTimeZone(CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO));

    given(treatmentRecordService.getTreatmentRecordVitalMonitors(any(),any())).willReturn(vitalMonitors);

    // action
    // assert
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/vital-monitor", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$[0].bio_moni_ctl_no", is(vitalMonitors.get(0).getBioMoniCtlNo().intValue())))
      .andExpect(jsonPath("$[0].data_type", is(vitalMonitors.get(0).getDataType().intValue())))
      .andExpect(jsonPath("$[0].monitor_data", is(vitalMonitors.get(0).getMonitorData())))
      .andExpect(jsonPath("$[0].occur_date", is(sf.format(vitalMonitors.get(0).getOccurDate()))))
      .andExpect(jsonPath("$[1].bio_moni_ctl_no", is(vitalMonitors.get(1).getBioMoniCtlNo().intValue())))
      .andExpect(jsonPath("$[1].data_type", is(vitalMonitors.get(1).getDataType().intValue())))
      .andExpect(jsonPath("$[1].monitor_data", is(vitalMonitors.get(1).getMonitorData())))
      .andExpect(jsonPath("$[1].occur_date", is(sf.format(vitalMonitors.get(1).getOccurDate()))))
      .andExpect(jsonPath("$[2].bio_moni_ctl_no", is(vitalMonitors.get(2).getBioMoniCtlNo().intValue())))
      .andExpect(jsonPath("$[2].data_type", is(vitalMonitors.get(2).getDataType().intValue())))
      .andExpect(jsonPath("$[2].monitor_data", is(vitalMonitors.get(2).getMonitorData())))
      .andExpect(jsonPath("$[2].occur_date", is(sf.format(vitalMonitors.get(2).getOccurDate()))))
    ;

    // assert
    verify(treatmentRecordService, times(1)).getTreatmentRecordVitalMonitors(any(),ordNo);
  }

  /**
   * getTreatmentRecordVitalMonitor()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること（結果が0件）
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordVitalMonitor_成功_0件() throws Exception {
    // arrange
    final Long ordNo = 1L;

    given(treatmentRecordService.getTreatmentRecordVitalMonitors(any(), any())).willReturn(Collections.emptyList());

    // action
    // assert
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/vital-monitor", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;

    // assert
    verify(treatmentRecordService, times(1)).getTreatmentRecordVitalMonitors(any(), ordNo);
  }

  /**
   * getTreatmentRecordMonitor()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordMonitor_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;
    List<TreatmentRecordMonitor> moniMonitors = Arrays.asList(
      getMonitor(1L),
      getMonitor(2L),
      getMonitor(3L)
    );
    SimpleDateFormat sf = new SimpleDateFormat(CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601);
    sf.setTimeZone(TimeZone.getTimeZone(CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO));

    given(treatmentRecordMonitorService.getTreatmentRecordMonitors(any())).willReturn(moniMonitors);

    // action
    // assert
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/monitor", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$[0].bio_moni_ctl_no", is(moniMonitors.get(0).getBioMoniCtlNo().intValue())))
      .andExpect(jsonPath("$[0].monitor_data", is(moniMonitors.get(0).getMonitorData())))
      .andExpect(jsonPath("$[0].occur_date", is(sf.format(moniMonitors.get(0).getOccurDate()))))
      .andExpect(jsonPath("$[0].is_del", is(moniMonitors.get(0).getIsDel())))
      .andExpect(jsonPath("$[1].bio_moni_ctl_no", is(moniMonitors.get(1).getBioMoniCtlNo().intValue())))
      .andExpect(jsonPath("$[1].monitor_data", is(moniMonitors.get(1).getMonitorData())))
      .andExpect(jsonPath("$[1].occur_date", is(sf.format(moniMonitors.get(1).getOccurDate()))))
      .andExpect(jsonPath("$[1].is_del", is(moniMonitors.get(0).getIsDel())))
      .andExpect(jsonPath("$[2].bio_moni_ctl_no", is(moniMonitors.get(2).getBioMoniCtlNo().intValue())))
      .andExpect(jsonPath("$[2].monitor_data", is(moniMonitors.get(2).getMonitorData())))
      .andExpect(jsonPath("$[2].occur_date", is(sf.format(moniMonitors.get(2).getOccurDate()))))
      .andExpect(jsonPath("$[2].is_del", is(moniMonitors.get(0).getIsDel())))
    ;

    // assert
    verify(treatmentRecordMonitorService, times(1)).getTreatmentRecordMonitors(ordNo);
  }

  /**
   * getTreatmentRecordMonitor()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること（結果が0件）
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordMonitor_成功_0件() throws Exception {
    // arrange
    final Long ordNo = 1L;

    given(treatmentRecordMonitorService.getTreatmentRecordMonitors(any())).willReturn(Collections.emptyList());

    // action
    // assert
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/monitor", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;

    // assert
    verify(treatmentRecordMonitorService, times(1)).getTreatmentRecordMonitors(ordNo);
  }

  /**
   * getTreatmentRecordSetting()の検証.
   * <p>
   * 条件：成功
   * 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordSetting_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;
    List<TreatmentRecordSetting> settings = Arrays.asList(
      new TreatmentRecordSetting(
        Timestamp.valueOf("2019-06-13 09:00:00.000")
        , "{\"a\": \"aaa\", \"b\": \"bbb\"}"
        , (short)0
      ),
      new TreatmentRecordSetting(
        Timestamp.valueOf("2019-06-14 11:40:00.000")
        , "{\"a\": \"aaa\", \"b\": \"bbb\"}"
        , (short)1
      )
    );

    given(treatmentRecordSettingService.getOrdTreatConditionByOrdNo(any())).willReturn(settings);

    // action
    // assert
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/setting", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$[0].receive_date", is("2019-06-13T09:00:00.000+09:00")))
      .andExpect(jsonPath("$[0].treat_condition", is("{\"a\": \"aaa\", \"b\": \"bbb\"}")))
      .andExpect(jsonPath("$[0].treat_class", is(0)))
      .andExpect(jsonPath("$[1].receive_date", is("2019-06-14T11:40:00.000+09:00")))
      .andExpect(jsonPath("$[1].treat_condition", is("{\"a\": \"aaa\", \"b\": \"bbb\"}")))
      .andExpect(jsonPath("$[1].treat_class", is(1)))
    ;

    // assert
    verify(treatmentRecordSettingService, times(1)).getOrdTreatConditionByOrdNo(ordNo);
  }

  /**
   * getTreatmentRecordDeviceSetInfo()の検証.
   * <p>
   * 条件：成功
   * 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordDeviceSetInfo_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordDeviceSetInfo deviceSetInfo = new TreatmentRecordDeviceSetInfo(
      any()
      , "009999"
    );
    given(treatmentRecordSettingService.getTreatmentRecordDeviceSetInfoByOrdNo(anyLong()))
      .willReturn(deviceSetInfo);

    // action
    // assert
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/rst-device-set-info", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.rst_device_set_info", is("{\"a\": \"aaa\", \"b\": \"bbb\"}")))
      .andExpect(jsonPath("$.pat_id", is(11)))
      .andExpect(jsonPath("$.facility_cd", is("009999")))
    ;

    // assert
    verify(treatmentRecordSettingService, times(1))
      .getTreatmentRecordDeviceSetInfoByOrdNo(ordNo);
  }

  /**
   * getTreatmentRecordDeviceSetInfo()の検証.
   * <p>
   * 条件：失敗
   * 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordDeviceSetInfo_失敗() throws Exception {
    // 事前準備
    Long ordNo = 12345L;

    // Mock化
    given(treatmentRecordSettingService.getTreatmentRecordDeviceSetInfoByOrdNo(anyLong()))
      .willThrow(new NotExistException("治療記録(装置設定)が見つからない"));

    // API実行
    ResultActions result =
      mockMvc
        .perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/rst-device-set-info", ordNo)
          .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordSettingService, times(1))
      .getTreatmentRecordDeviceSetInfoByOrdNo(ordNo);
    result
      .andExpect(status().isInternalServerError());
  }

  /**
   * getTreatmentRecordRoundsInfo()の検証.
   * <p>
   * 条件：成功
   * 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordRoundsInfo_成功() throws Exception {
    // arrange
    final long ordNo = 1L;
    TreatmentRecordRoundsInfo roundsInfo = new TreatmentRecordRoundsInfo();
    roundsInfo.setRstRoundsInfo("{\"cd\": 1, \"name\": \"name1\"}");
    roundsInfo.setUpDate(Timestamp.valueOf("2019-03-01 13:00:00"));

    given(treatmentRecordRoundService.getTreatmentRecordRoundsInfoByOrdNo(anyLong()))
    .willReturn(roundsInfo);

    // action
    // assert
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/rst-rounds-info", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.rst_rounds_info", is("{\"cd\": 1, \"name\": \"name1\"}")))
      .andExpect(jsonPath("$.up_date", is("2019-03-01T13:00:00.000+09:00")))
    ;

    // assert
    verify(treatmentRecordRoundService, times(1))
      .getTreatmentRecordRoundsInfoByOrdNo(ordNo);
  }

  /**
   * getTreatmentRecordRoundsInfo()の検証.
   * <p>
   * 条件：失敗
   * 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordRoundsInfo_失敗() throws Exception {
    // 事前準備
    Long ordNo = 12345L;

    // Mock化
    given(treatmentRecordRoundService.getTreatmentRecordRoundsInfoByOrdNo(anyLong()))
      .willThrow(new NotExistException("治療記録(回診記録情報)が見つからない"));

    // API実行
    ResultActions result =
      mockMvc
        .perform(MockMvcRequestBuilders.get("/api/treatment-record/{ord_no}/rst-rounds-info", ordNo)
          .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordRoundService, times(1))
      .getTreatmentRecordRoundsInfoByOrdNo(ordNo);
    result
      .andExpect(status().isInternalServerError());
  }

  /**
   * updateTreatmentRecordRoundsInfo()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordRoundsInfo_成功() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordRoundsInfo request = getTreatmentRecordRoundsInfo();
    String requestBody = mapper.writeValueAsString(request);
    ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<TreatmentRecordRoundsInfo> roundsInfoCaptor = ArgumentCaptor.forClass(TreatmentRecordRoundsInfo.class);

    // Mock化
    doNothing().when(treatmentRecordRoundService).updateTreatmentRecordRoundsInfo(ordNoCaptor.capture(), roundsInfoCaptor.capture());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/rst-rounds-info", ordNo)
        .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordRoundService, times(1)).updateTreatmentRecordRoundsInfo(anyLong(), any());
    assertThat(ordNoCaptor.getValue(), is(ordNo));
    assertThat(mapper.writeValueAsString(roundsInfoCaptor.getValue()), is(requestBody));
    result.andExpect(status().isOk());
  }

  /**
   * updateTreatmentRecordRoundsInfo()の検証.
   * <p>
   * 条件：失敗（該当データなし） 結果：失敗レスポンス(Status:500)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordRoundsInfo_失敗_該当データなし() throws Exception {
    // 事前準備
    Long ordNo = 12345L;
    TreatmentRecordRoundsInfo request = getTreatmentRecordRoundsInfo();
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    doThrow(new NotExistException("")).when(treatmentRecordRoundService).updateTreatmentRecordRoundsInfo(anyLong(), any());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/rst-rounds-info", ordNo)
        .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordRoundService, times(1)).updateTreatmentRecordRoundsInfo(anyLong(), any());
    result.andExpect(status().isInternalServerError());
  }

  /**
   * updateTreatmentRecordVitalForMniMonitor()の検証.
   * <p>
   * 条件：成功
   * 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordVitalForMniMonitor_成功() throws Exception {
    // 事前準備
    Long bioMniCtlNo = 1L;
    short dataType = 3;
    Long ordNo = 1L;
    Long patId = 10L;
    Long updStaffId = 1L;
    String monitorData = "{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}";
    List<MniMonitor> request = Arrays.asList(
      getMniMonitor(bioMniCtlNo, dataType, ordNo, patId, monitorData, updStaffId)
    );
    VitalMonitorData vitalMonitorData = new VitalMonitorData(){{
      setVitalData(request);
    }};
    String requestBody = mapper.writeValueAsString(vitalMonitorData);
    ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<List<MniMonitor>> vitalMonitorDataCaptor = ArgumentCaptor.forClass(List.class);
    ArgumentCaptor<Long> updStaffIdCaptor = ArgumentCaptor.forClass(Long.class);

    // Mock化
    doNothing().when(treatmentRecordService).insertOrUpdateTreatmentRecordForMniMonitor(
      ordNoCaptor.capture(),
      vitalMonitorDataCaptor.capture(),
      updStaffIdCaptor.capture()
    );

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/vital-monitor-data", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).insertOrUpdateTreatmentRecordForMniMonitor(anyLong(), any(), anyLong());
    assertThat(ordNoCaptor.getValue(), is(ordNo));
    assertThat(mapper.writeValueAsString(vitalMonitorDataCaptor.getValue()), is(mapper.writeValueAsString(request)));
    assertThat(updStaffIdCaptor.getValue(), is(updStaffId));
    result.andExpect(status().isOk());
  }

  /**
   * updateTreatmentRecordVitalForMniMonitor()の検証.
   * <p>
   * 条件：失敗
   * 結果：失敗レスポンス(Status:500)が返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordVitalForMniMonitor_失敗_該当オーダ番号が存在しない() throws Exception {
    // 事前準備
    Long bioMniCtlNo = 1L;
    short dataType = 3;
    Long ordNo = 1L;
    Long patId = 10L;
    Long updStaffId = 1L;
    String monitorData = "{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}";
    List<MniMonitor> request = Arrays.asList(
      getMniMonitor(bioMniCtlNo, dataType, ordNo, patId, monitorData, updStaffId)
    );
    VitalMonitorData vitalMonitorData = new VitalMonitorData(){{
      setVitalData(request);
    }};
    String requestBody = mapper.writeValueAsString(vitalMonitorData);

    // Mock化
    doThrow(new NotExistException("")).when(treatmentRecordService).insertOrUpdateTreatmentRecordForMniMonitor(anyLong(), any(), anyLong());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/treatment-record/{ord_no}/vital-monitor-data", ordNo)
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(treatmentRecordService, times(1)).insertOrUpdateTreatmentRecordForMniMonitor(anyLong(), any(), anyLong());
    result.andExpect(status().isInternalServerError());
  }

  /**
   * テスト用：登録、更新する{@link MniMonitor}作成.
   * @param dataType データ種別
   * @param ordNo オーダ番号
   * @param patId 患者番号
   * @param monitorData モニタデータ
   * @return 登録する装置モニタデータ
   */
  private MniMonitor getMniMonitor(
    Long bioMniCtlNo,
    Short dataType,
    Long ordNo,
    Long patId,
    String monitorData,
    Long updStaffId) {
    MniMonitor insertTestMonitorData = new MniMonitor();
    insertTestMonitorData.setBioMoniCtlNo(bioMniCtlNo);
    insertTestMonitorData.setOrdNo(ordNo);
    insertTestMonitorData.setPatId(patId);
    insertTestMonitorData.setDataType(dataType);
    insertTestMonitorData.setIsDel("0");
    insertTestMonitorData.setMonitorData(monitorData);
    insertTestMonitorData.setOccurDate(Timestamp.valueOf("2019-11-21 12:00:00.000"));
    insertTestMonitorData.setUpdStaffId(updStaffId);
    return insertTestMonitorData;
  }
}
