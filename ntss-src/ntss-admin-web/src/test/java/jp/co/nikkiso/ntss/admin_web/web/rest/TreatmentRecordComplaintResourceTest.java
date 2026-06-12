package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.junit.Assert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.sql.Timestamp;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
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
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordComplaintService;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordComplaint;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

/**
 * TreatmentRecordResourceのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
public class TreatmentRecordComplaintResourceTest extends AbstractResourceTest {

  @Autowired
  private ObjectMapper objectMapper;

  /**
   * 治療記録(愁訴処置)Service.
   */
  @MockitoBean
  private TreatmentRecordComplaintService treatmentRecordComplaintService;

  /**
   * getTreatmentRecordComplaint()の検証.
   * <p>
   * 条件：成功、閲覧権限ユーザ 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordComplaint_成功_閲覧権限() throws Exception {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordComplaint complaint = new TreatmentRecordComplaint();
    complaint.setRstStartDate(Timestamp.valueOf("2019-05-29 13:00:00"));
    complaint.setRstEndDate(Timestamp.valueOf("2019-05-29 18:00:00"));
    complaint.setRstComplaintInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    complaint.setRstTreatmentInfo("[{\"cd\": 11, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    complaint.setRstTreatStaffInfo("[{\"cd\": 21, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    complaint.setUpDate(Timestamp.valueOf("2019-05-29 21:00:00"));
    given(treatmentRecordComplaintService.getTreatmentRecordComplaint(any())).willReturn(complaint);

    // action
    // assert
    mockMvc
      .perform(get("/api/treatment-record/{ord_no}/complaint", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.rst_start_date", is("2019-05-29T13:00:00.000+09:00")))
      .andExpect(jsonPath("$.rst_end_date", is("2019-05-29T18:00:00.000+09:00")))
      .andExpect(jsonPath("$.rst_complaint_info", is("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]")))
      .andExpect(jsonPath("$.rst_treatment_info", is("[{\"cd\": 11, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]")))
      .andExpect(jsonPath("$.rst_treat_staff_info", is("[{\"cd\": 21, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]")))
      .andExpect(jsonPath("$.up_date", is("2019-05-29T21:00:00.000+09:00")))
    ;

    // assert
    verify(treatmentRecordComplaintService, times(1)).getTreatmentRecordComplaint(ordNo);
  }

  /**
   * getTreatmentRecordComplaint()の検証.
   * <p>
   * 条件：成功、代理編集権限ユーザ 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_PEDIT)
  public void test_getTreatmentRecordComplaint_成功_代理編集権限() throws Exception {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordComplaint complaint = new TreatmentRecordComplaint();
    complaint.setRstStartDate(Timestamp.valueOf("2019-05-29 13:00:00"));
    complaint.setRstEndDate(Timestamp.valueOf("2019-05-29 18:00:00"));
    complaint.setRstComplaintInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    complaint.setRstTreatmentInfo("[{\"cd\": 11, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    complaint.setRstTreatStaffInfo("[{\"cd\": 21, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    complaint.setUpDate(Timestamp.valueOf("2019-05-29 21:00:00"));
    given(treatmentRecordComplaintService.getTreatmentRecordComplaint(any())).willReturn(complaint);

    // action
    // assert
    mockMvc
      .perform(get("/api/treatment-record/{ord_no}/complaint", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
    ;

    // assert
    verify(treatmentRecordComplaintService, times(1)).getTreatmentRecordComplaint(ordNo);
  }

  /**
   * getTreatmentRecordComplaint()の検証.
   * <p>
   * 条件：成功、編集権限ユーザ 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_getTreatmentRecordComplaint_成功_編集権限() throws Exception {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordComplaint complaint = new TreatmentRecordComplaint();
    complaint.setRstStartDate(Timestamp.valueOf("2019-05-29 13:00:00"));
    complaint.setRstEndDate(Timestamp.valueOf("2019-05-29 18:00:00"));
    complaint.setRstComplaintInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    complaint.setRstTreatmentInfo("[{\"cd\": 11, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    complaint.setRstTreatStaffInfo("[{\"cd\": 21, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    given(treatmentRecordComplaintService.getTreatmentRecordComplaint(any())).willReturn(complaint);

    // action
    // assert
    mockMvc
      .perform(get("/api/treatment-record/{ord_no}/complaint", ordNo)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
    ;

    // assert
    verify(treatmentRecordComplaintService, times(1)).getTreatmentRecordComplaint(ordNo);
  }

  /**
   * getTreatmentRecordComplaint()の検証.
   * <p>
   * 条件：失敗 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordComplaint_失敗() throws Exception {
    // 事前準備
    Long ordNo = 12345L;

    // Mock化
    given(treatmentRecordComplaintService.getTreatmentRecordComplaint(anyLong())).willThrow(new NotExistException("治療記録(愁訴処置)が見つからない"));

    // API実行
    ResultActions result = mockMvc.perform(get("/api/treatment-record/{ord_no}/complaint", ordNo)
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(treatmentRecordComplaintService, times(1)).getTreatmentRecordComplaint(ordNo);
    result
      .andExpect(status().isInternalServerError());
  }

  /**
   * updateTreatmentRecordComplaint()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordComplaint_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;

    final Timestamp rstStartDate = Timestamp.valueOf("2019-12-31 13:00:00");
    final Timestamp rstEndDate = Timestamp.valueOf("2019-12-31 18:00:00");
    final String rstComplaintInfoForUpdate
      = "[{\"cd\": 110, \"name\": \"name110\"}, {\"cd\": 201, \"name\": \"name201\"}]";
    final String rstTreatmentInfoForUpdate
      = "[{\"cd\": 120, \"name\": \"name120\"}, {\"cd\": 202, \"name\": \"name202\"}]";
    final String rstTreatStaffInfoForUpdate
      = "[{\"cd\": 130, \"name\": \"name130\"}, {\"cd\": 203, \"name\": \"name203\"}]";

    final TreatmentRecordComplaint treatmentRecordComplaint = new TreatmentRecordComplaint();
    treatmentRecordComplaint.setRstStartDate(rstStartDate);
    treatmentRecordComplaint.setRstEndDate(rstEndDate);
    treatmentRecordComplaint.setRstComplaintInfo(rstComplaintInfoForUpdate);
    treatmentRecordComplaint.setRstTreatmentInfo(rstTreatmentInfoForUpdate);
    treatmentRecordComplaint.setRstTreatStaffInfo(rstTreatStaffInfoForUpdate);
    String requestBody = objectMapper.writeValueAsString(treatmentRecordComplaint);

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordComplaint> complaintCaptor = ArgumentCaptor.forClass(TreatmentRecordComplaint.class);

    given(
      treatmentRecordComplaintService.updateTreatmentRecordComplaint(ordNoCaptor.capture(), complaintCaptor.capture())
    ).willReturn(1);

    // action
    ResultActions result = mockMvc.perform(put("/api/treatment-record/{ord_no}/complaint", ordNo)
      .contentType(MediaType.APPLICATION_JSON)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    verify(treatmentRecordComplaintService, times(1)).updateTreatmentRecordComplaint(any(), any());
    assertThat(ordNoCaptor.getValue(), is(ordNo));
    assertThat(objectMapper.writeValueAsString(complaintCaptor.getValue()), is(requestBody));
    result.andExpect(status().isOk());
  }

  /**
   * updateTreatmentRecordComplaint()の検証.
   * <p>
   * 条件：失敗 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordComplaint_失敗() throws Exception {
    // arrange
    final Long ordNo = 1L;

    final Timestamp rstStartDate = Timestamp.valueOf("2019-12-31 13:00:00");
    final Timestamp rstEndDate = Timestamp.valueOf("2019-12-31 18:00:00");
    final String rstComplaintInfoForUpdate
      = "[{\"cd\": 110, \"name\": \"name110\"}, {\"cd\": 201, \"name\": \"name201\"}]";
    final String rstTreatmentInfoForUpdate
      = "[{\"cd\": 120, \"name\": \"name120\"}, {\"cd\": 202, \"name\": \"name202\"}]";
    final String rstTreatStaffInfoForUpdate
      = "[{\"cd\": 130, \"name\": \"name130\"}, {\"cd\": 203, \"name\": \"name203\"}]";

    final TreatmentRecordComplaint treatmentRecordComplaint = new TreatmentRecordComplaint();
    treatmentRecordComplaint.setRstStartDate(rstStartDate);
    treatmentRecordComplaint.setRstEndDate(rstEndDate);
    treatmentRecordComplaint.setRstComplaintInfo(rstComplaintInfoForUpdate);
    treatmentRecordComplaint.setRstTreatmentInfo(rstTreatmentInfoForUpdate);
    treatmentRecordComplaint.setRstTreatStaffInfo(rstTreatStaffInfoForUpdate);
    String requestBody = objectMapper.writeValueAsString(treatmentRecordComplaint);

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordComplaint> complaintCaptor = ArgumentCaptor.forClass(TreatmentRecordComplaint.class);

    given(
      treatmentRecordComplaintService.updateTreatmentRecordComplaint(ordNoCaptor.capture(), complaintCaptor.capture())
    ).willThrow(NotExistException.class);

    // action
    ResultActions result = mockMvc.perform(put("/api/treatment-record/{ord_no}/complaint", ordNo)
      .contentType(MediaType.APPLICATION_JSON)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    verify(treatmentRecordComplaintService, times(1)).updateTreatmentRecordComplaint(any(), any());
    assertThat(ordNoCaptor.getValue(), is(ordNo));
    assertThat(objectMapper.writeValueAsString(complaintCaptor.getValue()), is(requestBody));
    result.andExpect(status().isInternalServerError());
  }
}
