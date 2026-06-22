package jp.co.nikkiso.ntss.admin_web.web.rest;

import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.request.userAccount.AlterProvisionalInfoRequest;
import jp.co.nikkiso.ntss.admin_web.request.userAccount.UpdateUserAccountInfoRequest;
import jp.co.nikkiso.ntss.admin_web.response.ProvisionalUserResponse;
import jp.co.nikkiso.ntss.admin_web.response.userAccount.UserAccountResponse;
import jp.co.nikkiso.ntss.admin_web.service.userAccount.ProvisionalUserService;
import jp.co.nikkiso.ntss.admin_web.service.userAccount.UserAccountService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.custom.UserAccountInfo;
import jp.co.nikkiso.ntss.core.exception.DataSourceInconsistencyException;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.ArgumentMatchers;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;

import java.sql.Timestamp;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.BDDMockito.any;
import static org.mockito.BDDMockito.anyBoolean;
import static org.mockito.BDDMockito.anyLong;
import static org.mockito.BDDMockito.anyString;
import static org.mockito.BDDMockito.doNothing;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import static org.mockito.BDDMockito.willThrow;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.request;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * UserResourceのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
public class UserResourceTest extends AbstractResourceTest {

  /**
   * アカウント情報Service.
   */
  @MockitoBean
  private UserAccountService userAccountService;

  /**
   * 仮ユーザService.
   */
  @MockitoBean
  private ProvisionalUserService provisionalUserService;

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * alterProvisionalInfo()の検証.
   * <p>
   *   条件：成功
   *   結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterProvisionalInfo_正常_成功() throws Exception {

    // 事前準備
    AlterProvisionalInfoRequest request = new AlterProvisionalInfoRequest() {
      {
        setFacilityCd("provisional1");
        setDispUserIdPre("userIdPre");
        setDispUserIdNew("userIdNew");
        setUserPasswordNew("passwordNew");
        setUserLastName("test");
        setUserFirstName("user");
        setIsProvisional(true);
        setIsConsent(true);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(provisionalUserService.updateProvisionalUser(
      anyString(), anyString(), anyString(), anyString(),
      anyLong(), anyString(), anyString(), anyBoolean(), anyBoolean()))
      .willReturn(new ProvisionalUserResponse());

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user/provisional")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(provisionalUserService, times(1))
        .updateProvisionalUser("userIdPre", "userIdNew", "passwordNew", "provisional1", 1L,"test","user", true, true);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.isSuccess", is(true)))
      .andExpect(jsonPath("$.errorMessage", nullValue()));

  }

  /**
   * alterProvisionalInfo()の検証.
   * <p>
   *   条件：失敗_検索結果0件
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterProvisionalInfo_失敗_検索結果0件() throws Exception {

    // 事前準備
    AlterProvisionalInfoRequest request = new AlterProvisionalInfoRequest() {
      {
        setFacilityCd("noAnyone");
        setDispUserIdPre("userIdPre");
        setDispUserIdNew("userIdNew");
        setUserPasswordNew("passwordNew");
        setUserLastName("test");
        setUserFirstName("user");
        setIsProvisional(true);
        setIsConsent(true);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(provisionalUserService.updateProvisionalUser(anyString(), anyString(), anyString(), anyString(), anyLong(), anyString(), anyString(), anyBoolean(), anyBoolean()))
      .willReturn(new ProvisionalUserResponse(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user/provisional")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage())));

  }

  /**
   * alterProvisionalInfo()の検証.
   * <p>
   *   条件：失敗_ユーザーID重複
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterProvisionalInfo_失敗_ユーザーID重複() throws Exception {

    // 事前準備
    AlterProvisionalInfoRequest request = new AlterProvisionalInfoRequest() {
      {
        setFacilityCd("noAnyone");
        setDispUserIdPre("userIdPre");
        setDispUserIdNew("userIdNew");
        setUserPasswordNew("passwordNew");
        setUserLastName("test");
        setUserFirstName("user");
        setIsProvisional(true);
        setIsConsent(true);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(provisionalUserService.updateProvisionalUser(anyString(), anyString(), anyString(), anyString(), anyLong(), anyString(), anyString(), anyBoolean(), anyBoolean()))
      .willReturn(new ProvisionalUserResponse(AdminWebMessage.Error.USER_ID_EXISTED.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user/provisional")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_EXISTED.getMessage())));


  }

  /**
   * alterProvisionalInfo()の検証.
   * <p>
   *   条件：失敗_更新失敗
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterProvisionalInfo_失敗_更新失敗() throws Exception {

    // 事前準備
    AlterProvisionalInfoRequest request = new AlterProvisionalInfoRequest() {
      {
        setFacilityCd("noAnyone");
        setDispUserIdPre("userIdPre");
        setDispUserIdNew("userIdNew");
        setUserPasswordNew("passwordNew");
        setUserLastName("test");
        setUserFirstName("user");
        setIsProvisional(true);
        setIsConsent(true);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(provisionalUserService.updateProvisionalUser(anyString(), anyString(), anyString(), anyString(), anyLong(), anyString(), anyString(), anyBoolean(), anyBoolean()))
      .willReturn(new ProvisionalUserResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user/provisional")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage())));

  }

  /**
   * getUserAccount()の検証.
   * <p>
   * 条件：該当アカウント情報あり
   * 結果：ユーザIDに紐づくユーザ情報が返されること.
   * </p>
   */
  @Test
  @NtssMockUser(userId = 900000000001L)
  public void test_getUserAccount_正常_該当データあり() throws Exception {

    // 事前準備
    UserAccountResponse userAccountResponse = new UserAccountResponse(
      new UserAccountInfo() {
        {
         setDispUserId("900000000001");
         setUserId(900000000001L);
         setUserType(0);
         setFacilityCd("900001");
         setUserLastName("lastName");
         setUserFirstName("firstName");
         setUserLastNameKana("lastNameKana");
         setUserFirstNameKana("firstNameKana");
         setUserLastNameAlpha("lastNameAlpha");
         setUserFirstNameAlpha("firstNameAlpha");
         setUserEmailAddress1("emailAddress1@abc.jp");
         setUserEmailAddress2("emailAddress2@xxx.org");
         setExtensionNo("extensionNo");
         setHomeNo("homeNo");
         setMobilePhoneNo("mobilePhoneNo");
         setFaxNo("faxNo");
         setZipcd3("001");
         setZipcd4("0001");
         setAddress("address");
         setAddressKana("addressKana");
         setIsProvisional(0);
         setJobCd("01");
         setUserSettings(new MstUser.UserSettings() {
           {
             setIsDispMenu(0);
             setFontSize(3);
           }
           });
         setRegDate(Timestamp.valueOf("2018-05-25 17:16:55"));
         setUpDate(Timestamp.valueOf("2018-08-22 17:19:19.405"));
        }
      }
    );

    // Mock化
    given(userAccountService.createUserAccountResponse(anyLong())).willReturn(userAccountResponse);

    // API実行
    ResultActions result = mockMvc.perform(get("/api/user"));

    // 検証
    verify(userAccountService, times(1)).createUserAccountResponse(900000000001L);
    result.andExpect(status().isOk())
      .andExpect((jsonPath("$.userAccountInfo.userId", is(900000000001L))))
      .andExpect((jsonPath("$.userAccountInfo.dispUserId", is("900000000001"))))
      .andExpect((jsonPath("$.userAccountInfo.userType", is(0))))
      .andExpect((jsonPath("$.userAccountInfo.facilityCd", is("900001"))))
      .andExpect((jsonPath("$.userAccountInfo.userLastName", is("lastName"))))
      .andExpect((jsonPath("$.userAccountInfo.userFirstName", is("firstName"))))
      .andExpect((jsonPath("$.userAccountInfo.userLastNameKana", is("lastNameKana"))))
      .andExpect((jsonPath("$.userAccountInfo.userFirstNameKana", is("firstNameKana"))))
      .andExpect((jsonPath("$.userAccountInfo.userLastNameAlpha", is("lastNameAlpha"))))
      .andExpect((jsonPath("$.userAccountInfo.userFirstNameAlpha", is("firstNameAlpha"))))
      .andExpect((jsonPath("$.userAccountInfo.userEmailAddress1", is("emailAddress1@abc.jp"))))
      .andExpect((jsonPath("$.userAccountInfo.userEmailAddress2", is("emailAddress2@xxx.org"))))
      .andExpect((jsonPath("$.userAccountInfo.extensionNo", is("extensionNo"))))
      .andExpect((jsonPath("$.userAccountInfo.homeNo", is("homeNo"))))
      .andExpect((jsonPath("$.userAccountInfo.mobilePhoneNo", is("mobilePhoneNo"))))
      .andExpect((jsonPath("$.userAccountInfo.faxNo", is("faxNo"))))
      .andExpect((jsonPath("$.userAccountInfo.zipcd3", is("001"))))
      .andExpect((jsonPath("$.userAccountInfo.zipcd4", is("0001"))))
      .andExpect((jsonPath("$.userAccountInfo.address", is("address"))))
      .andExpect((jsonPath("$.userAccountInfo.addressKana", is("addressKana"))))
      .andExpect((jsonPath("$.userAccountInfo.isProvisional", is(0))))
      .andExpect((jsonPath("$.userAccountInfo.jobCd", is("01"))))
      .andExpect((jsonPath("$.userAccountInfo.userSettings.is_disp_menu", is(0))))
      .andExpect((jsonPath("$.userAccountInfo.userSettings.font_size", is(3))))
      .andExpect((jsonPath("$.userAccountInfo.regDate", is("2018-05-25T08:16:55.000+0000"))))
      .andExpect((jsonPath("$.userAccountInfo.upDate", is("2018-08-22T08:19:19.405+0000"))));
  }

  /**
   * getUserAccount()の検証.
   * <p>
   * 条件：エラー
   * 結果：エラーレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(userId = 10L)
  public void test_getUserAccount_エラー() throws Exception {

    // Mock化
    given(userAccountService.createUserAccountResponse(anyLong())).willReturn(new UserAccountResponse());

    // API検証
    mockMvc.perform(get("/api/user"))
      .andExpect(status().isInternalServerError());
  }

  /**
   * editUserAccountInfo()の検証.
   * <p>
   * 条件：更新成功.
   * 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  public void test_editUserAccountInfo_正常_更新成功() throws Exception {

    // 事前準備
    UpdateUserAccountInfoRequest request = new UpdateUserAccountInfoRequest(
      900000000001L,
      "dispUserId",
      "password",
      "lastName",
      "firstName",
      "lastNameKana",
      "firstNameKana",
      "lastNameAlpha",
      "firstNameAlpha",
      "emailAddress@111.111",
      "emailAddress2@222.22.22",
      "extensionNo",
      "homeNo",
      "mobilePhoneNo",
      "faxNo",
      "001",
      "0001",
      "address",
      "addressKana",
      1,
      "11",
      "11111",
      "22222",
      1,
      "900001",
      "0",
      "0",
      "userPasswordHistory"
    );
    String requestBody = mapper.writeValueAsString(request);
    ArgumentCaptor<UpdateUserAccountInfoRequest> args = ArgumentCaptor.forClass(UpdateUserAccountInfoRequest.class);

    // Mock化
    doNothing().when(userAccountService).updateUserAccountInfo(args.capture());

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userAccountService, times(1))
      .updateUserAccountInfo(ArgumentMatchers.any());
    assertThat(args.getValue().getUserId(), is(900000000001L));
    result.andExpect(status().isOk())
      .andExpect(content().string("true"));

  }

  /**
   * isDuplicateDispUserId()の検証.
   * <p>
   * 条件：重複あり
   * 結果：trueとエラーメッセージの設定されたResponseが返却されること
   * </p>
   */
  @Test
  public void test_isDuplicateDispUserId_正常_ユーザID重複あり() throws Exception {

    // 事前準備
    Long userId = 900000000001L;
    String dispUserId = "800000000001";

    // Mock化
    given(userAccountService.selectDuplicateCount(anyString(), anyLong())).willReturn(1L);

    // API実行
    ResultActions result = mockMvc.perform(request(HttpMethod.GET, "/api/user/check/{userId}/{dispUserId}", userId, dispUserId).with(csrf()));

    // 検証
    verify(userAccountService, times(1)).selectDuplicateCount(dispUserId, userId);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.result", is(true)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_EXISTED.getMessage())));
  }

  /**
   * isDuplicateDispUserId()の検証.
   * <p>
   * 条件：重複なし
   * 結果：falseの設定されたResponseが返却されること
   * </p>
   */
  @Test
  public void test_isDuplicateDispUserId_正常_ユーザID重複なし() throws Exception {

    // 事前準備
    Long userId = 900000000001L;
    String dispUserId = "800000000001";

    // Mock化
    given(userAccountService.selectDuplicateCount(anyString(), anyLong())).willReturn(0L);

    // API実行
    ResultActions result =
      mockMvc.perform(request(HttpMethod.GET, "/api/user/check/{userId}/{dispUserId}", userId, dispUserId).with(csrf()));

    // 検証
    verify(userAccountService, times(1)).selectDuplicateCount(dispUserId, userId);
    result.andExpect(status().isOk())
    .andExpect(jsonPath("$.result", is(false)))
    .andExpect(jsonPath("$.errorMessage", nullValue()));
  }

  /**
   * alterProvisionalInfo()の検証.
   * <p>
   *   条件：失敗（データソース間不整合）
   *   結果：失敗レスポンスが返されること(Status=500)
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterProvisionalInfo_失敗_データソース間不整合() throws Exception {

    // 事前準備
    AlterProvisionalInfoRequest request = new AlterProvisionalInfoRequest() {
      {
        setFacilityCd("provisional1");
        setDispUserIdPre("userIdPre");
        setDispUserIdNew("userIdNew");
        setUserPasswordNew("passwordNew");
        setUserLastName("test");
        setUserFirstName("user");
        setIsProvisional(true);
        setIsConsent(true);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(provisionalUserService.updateProvisionalUser(anyString(), anyString(), anyString(), anyString(), anyLong(), anyString(), anyString(), anyBoolean(), anyBoolean()))
      .willThrow(new DataSourceInconsistencyException(1L, DataSourceName.AUTH, DataSourceName.DEFAULT));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user/provisional")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.useResponseMessage", is(true)))
      .andExpect(jsonPath("$.message", is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage())));
  }

  /**
   * editUserAccountInfo()の検証.
   * <p>
   *   条件：失敗
   *   結果：失敗レスポンスが返されること(Status=500)
   * </p>
   */
  @Test
  public void test_editUserAccountInfo_失敗_データソース間不整合() throws Exception {

    // 事前準備
    UpdateUserAccountInfoRequest request = new UpdateUserAccountInfoRequest(
      900000000001L,
      "dispUserId",
      "password",
      "lastName",
      "firstName",
      "lastNameKana",
      "firstNameKana",
      "lastNameAlpha",
      "firstNameAlpha",
      "emailAddress@111.111",
      "emailAddress2@222.22.22",
      "extensionNo",
      "homeNo",
      "mobilePhoneNo",
      "faxNo",
      "001",
      "0001",
      "address",
      "addressKana",
      1,
      "11",
      "11111",
      "22222",
      1,
      "900001",
      "0",
      "0",
      "userPasswordHistory"
    );
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    willThrow(new DataSourceInconsistencyException(1L, DataSourceName.AUTH, DataSourceName.DEFAULT))
      .given(userAccountService).updateUserAccountInfo(any());

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.useResponseMessage", is(true)))
      .andExpect(jsonPath("$.message", is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage())));
  }

}
