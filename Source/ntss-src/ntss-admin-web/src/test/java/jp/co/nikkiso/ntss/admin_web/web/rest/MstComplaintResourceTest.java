package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.doThrow;
import static org.mockito.BDDMockito.anyList;
import static org.mockito.BDDMockito.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstCompTreatment;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.service.ComplaintService;
import jp.co.nikkiso.ntss.core.entity.MstComplaint;

import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import tools.jackson.databind.ObjectMapper;

/**
 * MstComplaintResourceのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
public class MstComplaintResourceTest extends AbstractResourceTest {
  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * 愁訴処置マスタサービスクラス.
   */
  @MockitoBean
  private ComplaintService complaintService;

  /**
   * 愁訴マスタEntityの初期化.
   * @return 愁訴マスタのEntity
   */
  private List<MstComplaint> createComplaintEntity() {
    return Arrays.asList(
      new MstComplaint() {{
        setComplaintCd(1);
        setComplaintName("Name1");
        setFacilityCd("1001");
        setIsDel("0");
        setIsDisp("1");
      }},
      new MstComplaint() {{
        setComplaintCd(2);
        setComplaintName("Name2");
        setFacilityCd("1001");
        setIsDel("0");
        setIsDisp("1");
      }}
    );
  }

  /**
   * getAllMstComplaintsの検証.
   *
   * 条件：愁訴マスタに該当のデータがある
   * 結果：施設コードに該当する愁訴マスタが取得できること
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_getAllMstComplaints_正常_愁訴マスタに該当のデータがある() throws Exception {
    List<MstComplaint> response = createComplaintEntity();

    given(complaintService.getAllMstComplaints(any())).willReturn(response);

    mockMvc
      .perform(get("/api/complaint/mst-complaint"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$[0].complaint_cd", is(1)))
      .andExpect(jsonPath("$[0].complaint_name", is("Name1")))
      .andExpect(jsonPath("$[0].is_disp", is("1")))
      .andExpect(jsonPath("$[0].is_del", is("0")))
      .andExpect(jsonPath("$[1].complaint_cd", is(2)))
      .andExpect(jsonPath("$[1].complaint_name", is("Name2")))
      .andExpect(jsonPath("$[1].is_disp", is("1")))
      .andExpect(jsonPath("$[1].is_del", is("0")))
    ;

    // assert
    verify(complaintService, times(1)).getAllMstComplaints("facilityCd");
  }

  /**
   * getAllMstComplaintsの検証.
   *
   * 条件：愁訴マスタに該当のデータがない
   * 結果：空の愁訴マスタが取得できること
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_getAllMstComplaints_正常_愁訴マスタに該当のデータがない() throws Exception {
    given(complaintService.getAllMstComplaints(any())).willReturn(Collections.emptyList());

    // assert
    mockMvc
      .perform(get("/api/complaint/mst-complaint"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;

    // assert
    verify(complaintService, times(1)).getAllMstComplaints("facilityCd");
  }

  /**
   * 処置マスタEntityの初期化.
   * @return 処置マスタのEntity
   */
  private List<MstCompTreatment> createCompTreatmentEntity() {
    return Arrays.asList(
      new MstCompTreatment() {{
        setCompTreatmentCd(1);
        setFacilityCd("009999");
        setTreatment("処置内容1");
        setTreatClass(0);
        setTreatMedicineCd(11);
        setAmount(BigDecimal.valueOf(2.1));
        setProcedureCd(31);
        setTakeMedicineCd(41);
        setIsDel("0");
        setIsDisp("1");
      }},
      new MstCompTreatment() {{
        setCompTreatmentCd(2);
        setFacilityCd("009999");
        setTreatment("処置内容2");
        setTreatClass(2);
        setIsDel("0");
        setIsDisp("1");
      }}
    );
  }

  /**
   * getAllMstCompTreatmentsの検証.
   *
   * 条件：処置マスタに該当のデータがある
   * 結果：施設コードに該当する処置マスタが取得できること
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_getAllMstCompTreatments_正常_処置マスタに該当のデータがある() throws Exception {
    List<MstCompTreatment> response = createCompTreatmentEntity();

    given(complaintService.getAllMstCompTreatments(any())).willReturn(response);

    // assert
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/complaint/mst-comp-treatment")
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$[0].comp_treatment_cd", is(1)))
      .andExpect(jsonPath("$[0].facility_cd", is("009999")))
      .andExpect(jsonPath("$[0].treatment", is("処置内容1")))
      .andExpect(jsonPath("$[0].treat_class", is("0")))
      .andExpect(jsonPath("$[0].treat_medicine_cd", is(11)))
      .andExpect(jsonPath("$[0].amount", is(2.1)))
      .andExpect(jsonPath("$[0].procedure_cd", is(31)))
      .andExpect(jsonPath("$[0].take_medicine_cd", is(41)))
      .andExpect(jsonPath("$[0].is_disp", is("1")))
      .andExpect(jsonPath("$[0].is_del", is("0")))
      .andExpect(jsonPath("$[1].comp_treatment_cd", is(2)))
      .andExpect(jsonPath("$[1].facility_cd", is("009999")))
      .andExpect(jsonPath("$[1].treatment", is("処置内容2")))
      .andExpect(jsonPath("$[1].treat_class", is("2")))
      .andExpect(jsonPath("$[1].treat_medicine_cd", is(nullValue())))
      .andExpect(jsonPath("$[1].amount", is(nullValue())))
      .andExpect(jsonPath("$[1].procedure_cd", is(nullValue())))
      .andExpect(jsonPath("$[1].take_medicine_cd", is(nullValue())))
      .andExpect(jsonPath("$[1].is_disp", is("1")))
      .andExpect(jsonPath("$[1].is_del", is("0")))
    ;

    // assert
    verify(complaintService, times(1)).getAllMstCompTreatments("facilityCd");
  }

  /**
   * getAllMstCompTreatmentsの検証.
   *
   * 条件：処置マスタに該当のデータがない
   * 結果：空の処置マスタが取得できること
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_getAllMstCompTreatments_正常_処置マスタに該当のデータがない() throws Exception {
    given(complaintService.getAllMstCompTreatments(any())).willReturn(Collections.emptyList());

    // assert
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/complaint/mst-comp-treatment")
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;

    // assert
    verify(complaintService, times(1)).getAllMstCompTreatments("facilityCd");
  }

  /**
   * updateMstComplaints()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_updateMstComplaints_成功() throws Exception {
    // 事前準備
    final String facilityCd = "000001";
    MstComplaint updateComplaints = new MstComplaint() {{
      setComplaintCd(1);
      setComplaintName("Name1");
      setFacilityCd(facilityCd);
      setIsDel("0");
      setIsDisp("1");
      setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
      setIsUpdate(true);
    }};
    MstComplaint insertComplaints = new MstComplaint() {{
      setComplaintName("Name2");
      setFacilityCd(facilityCd);
      setIsDel("0");
      setIsDisp("1");
      setIsUpdate(false);
    }};
    List<MstComplaint> request = Arrays.asList(updateComplaints, insertComplaints);
    int[] updateResult = {1, 1};

    String requestBody = mapper.writeValueAsString(request);
    ArgumentCaptor<String> args1 = ArgumentCaptor.forClass(String.class);
    Class<List<MstComplaint>> listClass = (Class<List<MstComplaint>>)(Class)List.class;
    ArgumentCaptor<List<MstComplaint>> args2 = ArgumentCaptor.forClass(listClass);

    // Mock化
    given(complaintService.updateMstComplaints(args1.capture(), args2.capture())).willReturn(updateResult);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/complaint/mst-complaint")
        .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(complaintService, times(1)).updateMstComplaints(anyString(), anyList());
    assertThat(args1.getValue(), is(facilityCd));
    assertThat(mapper.writeValueAsString(args2.getValue()), is(requestBody));
    result.andExpect(status().isOk());
  }

  /**
   * updateMstComplaints()の検証.
   * <p>
   * 条件：失敗（該当データなし） 結果：失敗レスポンス(Status:500)が返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_updateMstComplaints_失敗_該当データなし() throws Exception {
    // 事前準備
    final String facilityCd = "000001";
    MstComplaint updateComplaints = new MstComplaint() {{
      setComplaintCd(1);
      setComplaintName("Name1");
      setFacilityCd(facilityCd);
      setIsDel("0");
      setIsDisp("1");
      setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
      setIsUpdate(true);
    }};
    MstComplaint insertComplaints = new MstComplaint() {{
      setComplaintName("Name2");
      setFacilityCd(facilityCd);
      setIsDel("0");
      setIsDisp("1");
      setIsUpdate(false);
    }};
    List<MstComplaint> request = Arrays.asList(updateComplaints, insertComplaints);

    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    doThrow(new NotExistException("")).when(complaintService).updateMstComplaints(anyString(), any());

    // API実行
    ResultActions result = mockMvc.perform(put("/api/complaint/mst-complaint")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(complaintService, times(1)).updateMstComplaints(anyString(), anyList());
    result.andExpect(status().isInternalServerError());
  }

  /**
   * updateMstCompTreatments()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_updateMstCompTreatments_成功() throws Exception {
    // 事前準備
    final String facilityCd = "000001";
    MstCompTreatment updateCompTreatment = new MstCompTreatment() {{
      setCompTreatmentCd(1);
      setFacilityCd(facilityCd);
      setTreatment("name1");
      setTreatClass(1);
      setTreatMedicineCd(1);
      setAmount(new BigDecimal("12.12"));
      setProcedureCd(1);
      setTakeMedicineCd(1);
      setIsDel("0");
      setIsDisp("1");
      setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
      setIsUpdate(true);
    }};
    MstCompTreatment insertCompTreatment = new MstCompTreatment() {{
      setFacilityCd(facilityCd);
      setTreatment("name2");
      setTreatClass(1);
      setTreatMedicineCd(1);
      setAmount(new BigDecimal("12.12"));
      setProcedureCd(1);
      setTakeMedicineCd(1);
      setIsDel("0");
      setIsDisp("1");
      setIsUpdate(false);
    }};
    List<MstCompTreatment> request = Arrays.asList(updateCompTreatment, insertCompTreatment);
    int[] updateResult = {1, 1};

    String requestBody = mapper.writeValueAsString(request);
    ArgumentCaptor<String> args1 = ArgumentCaptor.forClass(String.class);
    Class<List<MstCompTreatment>> listClass = (Class<List<MstCompTreatment>>)(Class)List.class;
    ArgumentCaptor<List<MstCompTreatment>> args2 = ArgumentCaptor.forClass(listClass);

    // Mock化
    given(complaintService.updateMstCompTreatments(args1.capture(), args2.capture())).willReturn(updateResult);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/complaint/mst-comp-treatment")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(complaintService, times(1)).updateMstCompTreatments(anyString(), anyList());
    assertThat(args1.getValue(), is(facilityCd));
    assertThat(mapper.writeValueAsString(args2.getValue()), is(requestBody));
    result.andExpect(status().isOk());
  }

  /**
   * updateMstCompTreatments()の検証.
   * <p>
   * 条件：失敗（該当データなし） 結果：失敗レスポンス(Status:500)が返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_updateMstCompTreatments_失敗_該当データなし() throws Exception {
    // 事前準備
    final String facilityCd = "000001";
    MstCompTreatment updateCompTreatment = new MstCompTreatment() {{
      setCompTreatmentCd(1);
      setFacilityCd(facilityCd);
      setTreatment("name1");
      setTreatClass(1);
      setTreatMedicineCd(1);
      setAmount(new BigDecimal("12.12"));
      setProcedureCd(1);
      setTakeMedicineCd(1);
      setIsDel("0");
      setIsDisp("1");
      setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
      setIsUpdate(true);
    }};
    MstCompTreatment insertCompTreatment = new MstCompTreatment() {{
      setFacilityCd(facilityCd);
      setTreatment("name2");
      setTreatClass(1);
      setTreatMedicineCd(1);
      setAmount(new BigDecimal("12.12"));
      setProcedureCd(1);
      setTakeMedicineCd(1);
      setIsDel("0");
      setIsDisp("1");
      setIsUpdate(false);
    }};
    List<MstCompTreatment> request = Arrays.asList(updateCompTreatment, insertCompTreatment);

    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    doThrow(new NotExistException("")).when(complaintService).updateMstCompTreatments(anyString(), any());

    // API実行
    ResultActions result = mockMvc.perform(put("/api/complaint/mst-comp-treatment")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(complaintService, times(1)).updateMstCompTreatments(anyString(), anyList());
    result.andExpect(status().isInternalServerError());
  }
}
