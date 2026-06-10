package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

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

import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.request.facility.SetStaffFacilityRequest;
import jp.co.nikkiso.ntss.admin_web.response.StaffFacilitySettingsResponse;
import jp.co.nikkiso.ntss.admin_web.response.facilities.StaffFacility;
import jp.co.nikkiso.ntss.admin_web.response.facilities.StaffFacilityResponse;
import jp.co.nikkiso.ntss.admin_web.response.personalUser.UserIdAndUserName;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.PersonalTabDefineService;
import jp.co.nikkiso.ntss.admin_web.service.PersonalUserService;
import jp.co.nikkiso.ntss.admin_web.service.facilities.FacilitiesService;
import jp.co.nikkiso.ntss.core.entity.TabDisplayNameAndContentsId;

/**
 * FacilityResourceのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
public class FacilityResourceTest extends AbstractResourceTest {

  /**
   * 稼働ビューア施設一覧Service.
   */
  @MockBean
  private FacilitiesService facilitiesService;

  /**
   * 個人設定タブ定義のService.
   */
  @MockBean
  private PersonalTabDefineService personalTabDefineService;

  /**
   * 利用者のService.
   */
  @MockBean
  private PersonalUserService personalUserService;

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * getStaffFacility()の検証.
   * 正常_0件を返す
   */
  @Test
  public void test_getStaffFacility_正常_0件を返す() throws Exception {

    Long userId = 1L;

    // Mock化
    given(facilitiesService.getStaffFacility(anyLong())).willReturn(new StaffFacilityResponse());

    // API実行
    ResultActions result =  mockMvc.perform(get("/api/facilities/staff_facility/{userId}", userId).with(csrf()));

    // 検証
    verify(facilitiesService, times(1))
      .getStaffFacility(userId);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.staffFacilities", hasSize(0)));

  }

  /**
   * getStaffFacility()の検証.
   * 正常_2件返す
   */
  @Test
  public void test_getStaffFacility_正常_2件返す() throws Exception {

    Long userId = 1L;
    // 事前準備
    List<StaffFacility> staffFacilities = Arrays.asList(
      new StaffFacility(
        true,
          "001",
        "S001",
          "001",
          "テスト県",
          "テスト施設",
          "テストしせつ"
      ),
      new StaffFacility(
        false,
          "002",
        "S002",
          "002",
          "テスト県2",
          "テスト施設2",
          "テストしせつ2"
      )
    );
    StaffFacilityResponse response = new StaffFacilityResponse(staffFacilities);

    // Mock化
    given(facilitiesService.getStaffFacility(anyLong())).willReturn(response);

    // API実行
    ResultActions result =  mockMvc.perform(get("/api/facilities/staff_facility/{userId}", userId).with(csrf()));

    // 検証
    verify(facilitiesService, times(1))
      .getStaffFacility(userId);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.staffFacilities", hasSize(staffFacilities.size())));

    for(int i = 0; i < staffFacilities.size(); i++) {
      StaffFacility sf = staffFacilities.get(i);
      result.andExpect(jsonPath(String.format("$.staffFacilities[%d].isCharge",i), is(sf.isCharge)))
        .andExpect(jsonPath(String.format("$.staffFacilities[%d].facilityCd",i), is(sf.facilityCd)))
        .andExpect(jsonPath(String.format("$.staffFacilities[%d].departmentCd",i), is(sf.departmentCd)))
        .andExpect(jsonPath(String.format("$.staffFacilities[%d].prefecturesCd",i), is(sf.prefecturesCd)))
        .andExpect(jsonPath(String.format("$.staffFacilities[%d].prefecturesName",i), is(sf.prefecturesName)))
        .andExpect(jsonPath(String.format("$.staffFacilities[%d].facilityName",i), is(sf.facilityName)))
        .andExpect(jsonPath(String.format("$.staffFacilities[%d].facilityNameKana",i), is(sf.facilityNameKana)));
    }

  }

  /**
   * setStaffFacility()の検証.
   * <p>
   *   条件：成功
   *   結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  public void test_setStaffFacility_成功() throws Exception {

    Long userId = 1L;
    List<String> staffFacilityCds = Arrays.asList("000001", "000002", "000003");
    SetStaffFacilityRequest request = new SetStaffFacilityRequest() {
      {
        setStaffFacilityCds(staffFacilityCds);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(facilitiesService.updateStaffFacility(anyLong(), anyList()))
      .willReturn(new StaffFacilitySettingsResponse());

    // API実行
    ResultActions result =  mockMvc.perform(put("/api/facilities/staff_facility/{userId}", userId)
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // 検証
    verify(facilitiesService, times(1)).updateStaffFacility(userId, staffFacilityCds);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.isSuccess", is(true)))
      .andExpect(jsonPath("$.errorMessage", nullValue()));
  }

  /**
   * setStaffFacility()の検証.
   * <p>
   *   条件：該当ユーザーIDなし
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_setStaffFacility_失敗_該当ユーザーIDなし() throws Exception {

    Long userId = 1L;
    List<String> staffFacilityCds = Arrays.asList("000001", "000002", "000003");
    SetStaffFacilityRequest request = new SetStaffFacilityRequest() {
      {
        setStaffFacilityCds(staffFacilityCds);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(facilitiesService.updateStaffFacility(anyLong(), anyList()))
      .willReturn(new StaffFacilitySettingsResponse(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage()));

    // API実行
    ResultActions result =  mockMvc.perform(put("/api/facilities/staff_facility/{userId}", userId)
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // 検証
    verify(facilitiesService, times(1)).updateStaffFacility(userId, staffFacilityCds);
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage())));
  }

  /**
   * setStaffFacility()の検証.
   * <p>
   *   条件：該当施設コードなし
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_setStaffFacility_失敗_該当施設コードなし() throws Exception {

    Long userId = 1L;
    List<String> staffFacilityCds = Arrays.asList("999991", "999992", "999993");
    SetStaffFacilityRequest request = new SetStaffFacilityRequest() {
      {
        setStaffFacilityCds(staffFacilityCds);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(facilitiesService.updateStaffFacility(anyLong(), anyList()))
      .willReturn(new StaffFacilitySettingsResponse(AdminWebMessage.Error.FACILITY_CD_NOT_FOUND.getMessage()));

    // API実行
    ResultActions result =  mockMvc.perform(put("/api/facilities/staff_facility/{userId}", userId)
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // 検証
    verify(facilitiesService, times(1)).updateStaffFacility(userId, staffFacilityCds);
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.FACILITY_CD_NOT_FOUND.getMessage())));
  }

  /**
   * setStaffFacility()の検証.
   * <p>
   *   条件：DB更新失敗
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_setStaffFacility_失敗_DB更新失敗() throws Exception {

    Long userId = 1L;
    List<String> staffFacilityCds = Arrays.asList("000001", "000002", "000003");
    SetStaffFacilityRequest request = new SetStaffFacilityRequest() {
      {
        setStaffFacilityCds(staffFacilityCds);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(facilitiesService.updateStaffFacility(anyLong(), anyList()))
      .willReturn(new StaffFacilitySettingsResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()));

    // API実行
    ResultActions result =  mockMvc.perform(put("/api/facilities/staff_facility/{userId}", userId)
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // 検証
    verify(facilitiesService, times(1)).updateStaffFacility(userId, staffFacilityCds);
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage())));
  }

  /**
   * getUseFunctions()の検証.
   * <p>
   *   条件：データあり
   *   結果：使用可能機能リストが返されること
   * </p>
   */
  @Test
  public void test_getUseFunctions_正常_データあり() throws Exception {
    // arrange
    final String facilityCd = "001";
    given(facilitiesService.getUseFunctions(anyString()))
      .willReturn(Arrays.asList("00a", "00b", "00c"));

    // action
    ResultActions result =  mockMvc.perform(get("/api/facilities/{facilityCd}/use-functions", facilityCd)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    verify(facilitiesService, times(1)).getUseFunctions(facilityCd);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(3)))
      .andExpect(jsonPath("$[0]", is("00a")))
      .andExpect(jsonPath("$[1]", is("00b")))
      .andExpect(jsonPath("$[2]", is("00c")));
  }

  /**
   * getUseFunctions()の検証.
   * <p>
   *   条件：データなし
   *   結果：空リストが返されること
   * </p>
   */
  @Test
  public void test_getUseFunctions_正常_データなし() throws Exception {
    // arrange
    final String facilityCd = "001";
    given(facilitiesService.getUseFunctions(anyString()))
      .willReturn(Collections.emptyList());

    // action
    ResultActions result =  mockMvc.perform(get("/api/facilities/{facilityCd}/use-functions", facilityCd)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    verify(facilitiesService, times(1)).getUseFunctions(facilityCd);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)));
  }

  /**
   * getDisplayNameAndContentsIdByFacilityCd()の検証.
   * <p>
   *   条件：データあり
   *   結果：個人設定タブ定義が返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "001", userType = 1, administrator = 1)
  public void test_getDisplayNameAndContentsIdByFacilityCd_正常_データあり() throws Exception {
    // arrange
    final String facilityCd = "001";
    final List<TabDisplayNameAndContentsId> fixture = Arrays.asList(
      new TabDisplayNameAndContentsId(1, "tabA", "idA", "1")
      , new TabDisplayNameAndContentsId(2, "tabB", "idB", "1")
      , new TabDisplayNameAndContentsId(3, "tabC", "idC", "0")
    );

    final ArgumentCaptor<NtssUser> ntssUserCaptor = ArgumentCaptor.forClass(NtssUser.class);
    given(personalTabDefineService.getDisplayNameAndContentsIdByFacilityCd(ntssUserCaptor.capture()))
      .willReturn(fixture);

    // action
    ResultActions result =  mockMvc.perform(get("/api/facilities/{facilityCd}/personal-setting/tab/define", facilityCd)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    verify(personalTabDefineService, times(1)).getDisplayNameAndContentsIdByFacilityCd(any());
    final NtssUser ntssUser = ntssUserCaptor.getValue();
    assertThat(ntssUser.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(ntssUser.getUserType()).isEqualTo(1);
    assertThat(ntssUser.getAdministrator()).isEqualTo(1);

    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(3)))
      .andExpect(jsonPath("$[0].displayName", is("tabA")))
      .andExpect(jsonPath("$[0].contentsId", is("idA")))
      .andExpect(jsonPath("$[0].mode", is("1")))
      .andExpect(jsonPath("$[1].displayName", is("tabB")))
      .andExpect(jsonPath("$[1].contentsId", is("idB")))
      .andExpect(jsonPath("$[1].mode", is("1")))
      .andExpect(jsonPath("$[2].displayName", is("tabC")))
      .andExpect(jsonPath("$[2].contentsId", is("idC")))
      .andExpect(jsonPath("$[2].mode", is("0")))
    ;
  }

  /**
   * getDisplayNameAndContentsIdByFacilityCd()の検証.
   * <p>
   *   条件：データなし
   *   結果：空リストが返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "001", userType = 1, administrator = 1)
  public void test_getDisplayNameAndContentsIdByFacilityCd_正常_データなし() throws Exception {
    // arrange
    final String facilityCd = "001";
    final List<TabDisplayNameAndContentsId> fixture = Collections.emptyList();


    final ArgumentCaptor<NtssUser> ntssUserCaptor = ArgumentCaptor.forClass(NtssUser.class);
    given(personalTabDefineService.getDisplayNameAndContentsIdByFacilityCd(ntssUserCaptor.capture()))
      .willReturn(fixture);

    // action
    ResultActions result =  mockMvc.perform(get("/api/facilities/{facilityCd}/personal-setting/tab/define", facilityCd)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    verify(personalTabDefineService, times(1)).getDisplayNameAndContentsIdByFacilityCd(any());
    final NtssUser ntssUser = ntssUserCaptor.getValue();
    assertThat(ntssUser.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(ntssUser.getUserType()).isEqualTo(1);
    assertThat(ntssUser.getAdministrator()).isEqualTo(1);

    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)));
  }

  /**
   * getDoctorsByFacilityCd()の検証.
   * <p>
   *   条件：データあり
   *   結果：医師のリストが返されること
   * </p>
   */
  @Test
  public void test_getDoctorsByFacilityCd_正常_データあり() throws Exception {
    // arrange
    final String facilityCd = "001";
    final List<UserIdAndUserName> doctors = Arrays.asList(
      new UserIdAndUserName(11L, "lastName11", "firstName11","", "0",any())
      , new UserIdAndUserName(12L, "lastName12", "firstName12", "", "0",any())
      , new UserIdAndUserName(13L, "lastName13", "firstName13","",  "0",any())
    );
    given(personalUserService.getDoctorsByFacilityCd(anyString()))
      .willReturn(doctors);

    // action
    ResultActions result =  mockMvc.perform(get("/api/facilities/{facilityCd}/personal-user/job/doctor", facilityCd)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    verify(personalUserService, times(1)).getDoctorsByFacilityCd(facilityCd);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(3)))
      .andExpect(jsonPath("$[0].user_id", is(11)))
      .andExpect(jsonPath("$[0].user_last_name", is("lastName11")))
      .andExpect(jsonPath("$[0].user_first_name", is("firstName11")))
      .andExpect(jsonPath("$[1].user_id", is(12)))
      .andExpect(jsonPath("$[1].user_last_name", is("lastName12")))
      .andExpect(jsonPath("$[1].user_first_name", is("firstName12")))
      .andExpect(jsonPath("$[2].user_id", is(13)))
      .andExpect(jsonPath("$[2].user_last_name", is("lastName13")))
      .andExpect(jsonPath("$[2].user_first_name", is("firstName13")))
    ;
  }

  /**
   * getDoctorsByFacilityCd()の検証.
   * <p>
   *   条件：データなし
   *   結果：空リストが返されること
   * </p>
   */
  @Test
  public void test_getDoctorsByFacilityCd_正常_データなし() throws Exception {
    // arrange
    final String facilityCd = "002";
    final List<UserIdAndUserName> doctors = Collections.emptyList();
    given(personalUserService.getDoctorsByFacilityCd(anyString()))
      .willReturn(doctors);

    // action
    ResultActions result =  mockMvc.perform(get("/api/facilities/{facilityCd}/personal-user/job/doctor", facilityCd)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    verify(personalUserService, times(1)).getDoctorsByFacilityCd(facilityCd);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)));
  }
}
