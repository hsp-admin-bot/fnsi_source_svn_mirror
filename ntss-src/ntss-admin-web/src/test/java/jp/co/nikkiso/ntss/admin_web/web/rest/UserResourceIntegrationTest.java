package jp.co.nikkiso.ntss.admin_web.web.rest;

import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.constant.RestDocMessage;
import jp.co.nikkiso.ntss.admin_web.request.userAccount.AlterProvisionalInfoRequest;
import jp.co.nikkiso.ntss.admin_web.request.userAccount.UpdateUserAccountInfoRequest;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import org.assertj.core.util.Arrays;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.restdocs.payload.JsonFieldType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.Sql.ExecutionPhase;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;

import java.sql.Timestamp;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.requestFields;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.request.RequestDocumentation.parameterWithName;
import static org.springframework.restdocs.request.RequestDocumentation.pathParameters;
import static org.springframework.restdocs.snippet.Attributes.attributes;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.request;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * UserResourceの結合用テストクラス.
 *
 * @Transaction が付与されていると、呼び出し先のServiceでトランザクション制御が正しく行われない。
 * そのため、*.after.sql をテスト実行後に適用してテストデータの後始末を行う。
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Sql(value = "classpath:resource.script/UserResourceIntegrationTest.default.before.sql", config = @SqlConfig(dataSource = DataSourceName.DEFAULT, transactionManager = TransactionManagerName.DEFAULT))
@Sql(value = "classpath:resource.script/UserResourceIntegrationTest.personal.before.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
@Sql(value = "classpath:resource.script/UserResourceIntegrationTest.auth.before.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
@Sql(value = "classpath:resource.script/UserResourceIntegrationTest.default.after.sql", config = @SqlConfig(dataSource = DataSourceName.DEFAULT, transactionManager = TransactionManagerName.DEFAULT), executionPhase = ExecutionPhase.AFTER_TEST_METHOD)
@Sql(value = "classpath:resource.script/UserResourceIntegrationTest.personal.after.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL), executionPhase = ExecutionPhase.AFTER_TEST_METHOD)
@Sql(value = "classpath:resource.script/UserResourceIntegrationTest.auth.after.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH), executionPhase = ExecutionPhase.AFTER_TEST_METHOD)
public class UserResourceIntegrationTest extends AbstractResourceIntegrationTest {

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * 利用者マスタのDaoインタフェース.
   */
  @Autowired
  private MstUserDao mstUserDao;

  /**
   * 利用者マスタ(認証DB)のDaoインタフェース.
   */
  @Autowired
  private MstUserAuthenticationDao authenticationDao;


  /**
   * 利用者マスタ(個人情報DB)のDao.
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * パスワードエンコーダ.
   */
  @Autowired
  private PasswordEncoder passwordEncoder;

  /**
   * alterProvisionalInfo()の検証.
   * <p>
   *   条件：成功
   *   結果：成功レスポンスが返されること
   *        利用者マスタが更新されていること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "900001", userId = 900000000001L)
  public void test_alterProvisionalInfo_正常_成功() throws Exception {

    // 事前準備
    AlterProvisionalInfoRequest request = new AlterProvisionalInfoRequest() {
      {
        setFacilityCd("900001");
        setDispUserIdPre("800000000004");
        setDispUserIdNew("800000000014");
        setUserPasswordNew("passwordNew");
        setUserLastName("test");
        setUserFirstName("user");
        setIsProvisional(true);
        setIsConsent(true);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user/provisional")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.isSuccess", is(true)))
      .andExpect(jsonPath("$.errorMessage", nullValue()))
      .andDo(document("user/provisional/ok",
        requestFields(
          attributes(
            key("description").value(""),
            key("operationTargetTable").value("")
          ),
          fieldWithPath("facilityCd").description(RestDocMessage.Request.FACILITY_CD),
          fieldWithPath("dispUserIdPre").description("[必須]表示用ユーザーID(変更前)"),
          fieldWithPath("dispUserIdNew").description("[必須]表示用ユーザーID(変更後)"),
          fieldWithPath("userPasswordNew").description("[必須]ユーザーパスワード(変更後)"),
          fieldWithPath("userLastName").description("ユーザー姓(変更後)"),
          fieldWithPath("userFirstName").description("ユーザー名(変更後)"),
          fieldWithPath("isProvisional").description("仮登録フラグ"),
          fieldWithPath("isConsent").description("個人情報取扱い同意フラグ")
        )));

    // 更新された利用者マスタの検証
    MstUser mstUser = mstUserDao.selectById(900000000001L);
    MstUserAuthentication userAuthentication = authenticationDao.selectById(900000000001L);
    assertThat(userAuthentication.getDispUserId(), is(request.getDispUserIdNew()));
    assertThat(passwordEncoder.matches(request.getUserPasswordNew(), userAuthentication.getUserPassword()), is(true));
    assertThat(mstUser.getIsProvisional(), is(CoreConstant.ProvisionalStatus.NOT_PROVISIONAL));

  }

  /**
   * alterProvisionalInfo()の検証.
   * <p>
   *   条件：失敗_検索結果0件
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "900001", userId = 900000000005L)
  public void test_alterProvisionalInfo_失敗_検索結果0件() throws Exception {

    // 事前準備
    AlterProvisionalInfoRequest request = new AlterProvisionalInfoRequest() {
      {
        setFacilityCd("900001");
        setDispUserIdPre("700000000004");
        setDispUserIdNew("700000000014");
        setUserPasswordNew("passwordNew");
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user/provisional")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.useResponseMessage", is(true)))
      .andExpect(jsonPath("$.message", is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage())));
  }

  /**
   * alterProvisionalInfo()の検証.
   * <p>
   *   条件：失敗_ユーザーID重複
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "900001", userId = 900000000003L)
  public void test_alterProvisionalInfo_失敗_ユーザーID重複() throws Exception {

    // 事前準備
    AlterProvisionalInfoRequest request = new AlterProvisionalInfoRequest() {
      {
        setFacilityCd("900001");
        setDispUserIdPre("800000000004");
        setDispUserIdNew("800000000003");
        setUserPasswordNew("passwordNew");
        setUserLastName("test");
        setUserFirstName("user");
        setIsProvisional(true);
        setIsConsent(true);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user/provisional")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_EXISTED.getMessage())))
      .andDo(document("user/provisional/bad-request",
        responseFields(
          attributes(
            key("description").value(""),
            key("operationTargetTable").value("")
          ),
          fieldWithPath("isSuccess").description(RestDocMessage.Response.IS_SUCCESS),
          fieldWithPath("errorMessage").description(RestDocMessage.Response.ERROR_MESSAGE),
          fieldWithPath("useResponseMessage").description(RestDocMessage.Response.USE_RESPONSE_MESSAGE).type(JsonFieldType.BOOLEAN).optional(),
          fieldWithPath("message").description(RestDocMessage.Response.SYSTEM_ERROR_MESSAGE).type(JsonFieldType.STRING).optional()
        ))
      );
  }

  /**
   * alterProvisionalInfo()の検証.
   * <p>
   *   条件：失敗_データソース間不整合
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "900001", userId = 900000000004L)
  public void test_alterProvisionalInfo_失敗_データソース間不整合() throws Exception {

    // 事前準備
    AlterProvisionalInfoRequest request = new AlterProvisionalInfoRequest() {
      {
        setFacilityCd("900001");
        setDispUserIdPre("800000000004");
        setDispUserIdNew("800000000003");
        setUserPasswordNew("passwordNew");
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user/provisional")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.useResponseMessage", is(true)))
      .andExpect(jsonPath("$.message", is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage())))
      .andDo(document("user/provisional/internal-server-error"));
  }

  /**
   * editUserAccountInfo()の検証.
   * <p>
   * 条件：更新成功
   * 結果：成功Responseが返却されること、パスワードが変更されないこと
   * </p>
   */
  @Test
  public void test_editUserAccountInfo_更新成功_パスワード変更なし() throws Exception {
    // 事前準備
    Long userId = 999900000001L;
    UpdateUserAccountInfoRequest request = new UpdateUserAccountInfoRequest() {
      {
        setUserId(userId);
        setDispUserId("999");
        setUserLastName("01");
        setUserFirstName("02");
        setUserLastNameKana("03");
        setUserFirstNameKana("04");
        setUserLastNameAlpha("05");
        setUserFirstNameAlpha("06");
        setUserEmailAddress1("07");
        setUserEmailAddress2("08");
        setExtensionNo("09");
        setHomeNo("10");
        setMobilePhoneNo("11");
        setFaxNo("12");
        setZipcd3("13");
        setZipcd4("14");
        setAddress("15");
        setAddressKana("16");
        setIsProvisional(99);
        setJobCd("17");
        setFacilityCd("919191");
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", is(true)));

    { // 利用者マスタ(認証DB)更新なし確認
      MstUserAuthentication entity = authenticationDao.selectById(userId);
      assertThat(entity, notNullValue());
      assertThat(entity.getUserId(), is(999900000001L));
      assertThat(entity.getFacilityCd(), is("999001"));
      assertThat(entity.getDispUserId(), is("999"));
      assertThat(entity.getUserPassword(), is("$2a$10$gJv8X8lhSPyjQjMqn1Z80uT4vz0G.z83Lh2cNtMu4Kh2Iu8SqOR2u"));
      assertThat(entity.getFailureCnt(), is(0));
      assertThat(entity.getRegDate(), is(Timestamp.valueOf("2018-05-25 17:16:55")));
      assertThat(entity.getUpDate(), not(Timestamp.valueOf("2018-08-22 17:19:19.405")));
    }
    { // 利用者マスタ(個人情報DB)更新なし確認
      MstPersonalUser entity = mstPersonalUserDao.selectById(userId);
      assertThat(entity, notNullValue());
      assertThat(entity.getUserId(), is(999900000001L));
      assertThat(entity.getFacilityCd(), is("999001"));
      assertThat(entity.getUserType(), is(0));
      assertThat(entity.getUserLastName(), is("01"));
      assertThat(entity.getUserFirstName(), is("02"));
      assertThat(entity.getUserLastNameKana(), is("03"));
      assertThat(entity.getUserFirstNameKana(), is("04"));
      assertThat(entity.getUserLastNameAlpha(), is("05"));
      assertThat(entity.getUserFirstNameAlpha(), is("06"));
      assertThat(entity.getUserEmailAddress1(), is("07"));
      assertThat(entity.getUserEmailAddress2(), is("08"));
      assertThat(entity.getExtensionNo(), is("09"));
      assertThat(entity.getHomeNo(), is("10"));
      assertThat(entity.getMobilePhoneNo(), is("11"));
      assertThat(entity.getFaxNo(), is("12"));
      assertThat(entity.getZipcd3(), is("13"));
      assertThat(entity.getZipcd4(), is("14"));
      assertThat(entity.getAddress(), is("15"));
      assertThat(entity.getAddressKana(), is("16"));
      assertThat(entity.getJobCd(), is("17"));
      assertThat(entity.getRegDate(), is(Timestamp.valueOf("2018-05-25 17:16:55")));
      assertThat(entity.getUpDate(), not(Timestamp.valueOf("2018-08-22 17:19:19.405")));
    }
  }

  /**
   * editUserAccountInfo()の検証.
   * <p>
   * 条件：更新成功
   * 結果：成功Responseが返却されること、パスワードが変更されること
   * </p>
   */
  @Test
  public void test_editUserAccountInfo_更新成功_パスワード変更あり() throws Exception {
    // 事前準備
    Long userId = 999900000001L;
    UpdateUserAccountInfoRequest request = new UpdateUserAccountInfoRequest() {
      {
        setUserId(userId);
        setDispUserId("999");
        setUserPassword("password");
        setUserLastName("01");
        setUserFirstName("02");
        setUserLastNameKana("03");
        setUserFirstNameKana("04");
        setUserLastNameAlpha("05");
        setUserFirstNameAlpha("06");
        setUserEmailAddress1("07");
        setUserEmailAddress2("08");
        setExtensionNo("09");
        setHomeNo("10");
        setMobilePhoneNo("11");
        setFaxNo("12");
        setZipcd3("13");
        setZipcd4("14");
        setAddress("15");
        setAddressKana("16");
        setIsProvisional(99);
        setJobCd("17");
        setFacilityCd("919191");
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", is(true)));

    { // 利用者マスタ(認証DB)更新なし確認
      MstUserAuthentication entity = authenticationDao.selectById(userId);
      assertThat(entity, notNullValue());
      assertThat(entity.getUserId(), is(999900000001L));
      assertThat(entity.getFacilityCd(), is("999001"));
      assertThat(entity.getDispUserId(), is("999"));
      assertThat(passwordEncoder.matches("password", entity.getUserPassword()), is(true));
      assertThat(entity.getFailureCnt(), is(0));
      assertThat(entity.getRegDate(), is(Timestamp.valueOf("2018-05-25 17:16:55")));
      assertThat(entity.getUpDate(), not(Timestamp.valueOf("2018-08-22 17:19:19.405")));
    }
    { // 利用者マスタ(個人情報DB)更新なし確認
      MstPersonalUser entity = mstPersonalUserDao.selectById(userId);
      assertThat(entity, notNullValue());
      assertThat(entity.getUserId(), is(999900000001L));
      assertThat(entity.getFacilityCd(), is("999001"));
      assertThat(entity.getUserType(), is(0));
      assertThat(entity.getUserLastName(), is("01"));
      assertThat(entity.getUserFirstName(), is("02"));
      assertThat(entity.getUserLastNameKana(), is("03"));
      assertThat(entity.getUserFirstNameKana(), is("04"));
      assertThat(entity.getUserLastNameAlpha(), is("05"));
      assertThat(entity.getUserFirstNameAlpha(), is("06"));
      assertThat(entity.getUserEmailAddress1(), is("07"));
      assertThat(entity.getUserEmailAddress2(), is("08"));
      assertThat(entity.getExtensionNo(), is("09"));
      assertThat(entity.getHomeNo(), is("10"));
      assertThat(entity.getMobilePhoneNo(), is("11"));
      assertThat(entity.getFaxNo(), is("12"));
      assertThat(entity.getZipcd3(), is("13"));
      assertThat(entity.getZipcd4(), is("14"));
      assertThat(entity.getAddress(), is("15"));
      assertThat(entity.getAddressKana(), is("16"));
      assertThat(entity.getJobCd(), is("17"));
      assertThat(entity.getRegDate(), is(Timestamp.valueOf("2018-05-25 17:16:55")));
      assertThat(entity.getUpDate(), not(Timestamp.valueOf("2018-08-22 17:19:19.405")));
    }
  }

  /**
   * editUserAccountInfo()の検証.
   * <p>
   * 条件：更新失敗(利用者マスタ(認証DB)更新件数０件)
   * 結果：失敗Responseが返却されること
   * </p>
   */
  @Test
  public void test_editUserAccountInfo_更新失敗_利用者マスタ認証DB_更新０件() throws Exception {
    // 事前準備
    Long userId = 999900000003L;
    UpdateUserAccountInfoRequest request = new UpdateUserAccountInfoRequest() {{
      setUserId(userId);
      setUserLastName("userLastName");
      setUserFirstName("userFirstName");
      setUserEmailAddress1("userEmailAddress1");
      setJobCd("jobCd");
    }};
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.useResponseMessage", is(true)))
      .andExpect(jsonPath("$.message", is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage())));

    { // 利用者マスタ(認証DB)データなし確認
      MstUserAuthentication entity = authenticationDao.selectById(userId);
      assertThat(entity, nullValue());
    }
    { // 利用者マスタ(個人情報DB)更新なし確認
      MstPersonalUser entity = mstPersonalUserDao.selectById(userId);
      assertThat(entity, notNullValue());
      assertThat(entity.getUserId(), is(999900000003L));
      assertThat(entity.getFacilityCd(), is("999003"));
      assertThat(entity.getUserType(), is(1));
      assertThat(entity.getUserLastName(), is("lastName3"));
      assertThat(entity.getUserFirstName(), is("firstName3"));
      assertThat(entity.getUserLastNameKana(), is("lastNameKana3"));
      assertThat(entity.getUserFirstNameKana(), is("firstNameKana3"));
      assertThat(entity.getUserLastNameAlpha(), is("lastNameAlpha3"));
      assertThat(entity.getUserFirstNameAlpha(), is("firstNameAlpha3"));
      assertThat(entity.getUserEmailAddress1(), is("emailAddress1@abc3.jp"));
      assertThat(entity.getUserEmailAddress2(), is("emailAddress2@xxx3.org"));
      assertThat(entity.getExtensionNo(), is("extensionNo3"));
      assertThat(entity.getHomeNo(), is("homeNo3"));
      assertThat(entity.getMobilePhoneNo(), is("mobilePhoneNo3"));
      assertThat(entity.getFaxNo(), is("faxNo3"));
      assertThat(entity.getZipcd3(), is("0013"));
      assertThat(entity.getZipcd4(), is("00013"));
      assertThat(entity.getAddress(), is("address3"));
      assertThat(entity.getAddressKana(), is("addressKana3"));
      assertThat(entity.getJobCd(), is("03"));
      assertThat(entity.getRegDate(), is(Timestamp.valueOf("2018-05-26 17:16:55")));
      assertThat(entity.getUpDate(), is(Timestamp.valueOf("2018-08-23 17:19:19.405")));
    }
  }

  /**
   * editUserAccountInfo()の検証.
   * <p>
   * 条件：更新失敗(利用者マスタ(認証DB)更新エラー)
   * 結果：失敗Responseが返却されること
   * </p>
   */
  @Test
  public void test_editUserAccountInfo_更新失敗_利用者マスタ認証DB_更新エラー() throws Exception {
    // 事前準備
    Long userId = 999900000001L;
    UpdateUserAccountInfoRequest request = new UpdateUserAccountInfoRequest() {{
      setUserId(userId);
      setDispUserId("0123456789012"); // 桁数オーバー
    }};
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.useResponseMessage", is(true)))
      .andExpect(jsonPath("$.message", is(AdminWebMessage.Error.SQL_EXECUTION_ERROR.getMessage())));

    { // 利用者マスタ(認証DB)更新なし確認
      MstUserAuthentication entity = authenticationDao.selectById(userId);
      assertThat(entity, notNullValue());
      assertThat(entity.getUserId(), is(999900000001L));
      assertThat(entity.getFacilityCd(), is("999001"));
      assertThat(entity.getDispUserId(), is("999900000901"));
      assertThat(entity.getUserPassword(), is("$2a$10$gJv8X8lhSPyjQjMqn1Z80uT4vz0G.z83Lh2cNtMu4Kh2Iu8SqOR2u"));
      assertThat(entity.getFailureCnt(), is(0));
      assertThat(entity.getRegDate(), is(Timestamp.valueOf("2018-05-25 17:16:55")));
      assertThat(entity.getUpDate(), is(Timestamp.valueOf("2018-08-22 17:19:19.405")));
    }
    { // 利用者マスタ(個人情報DB)更新なし確認
      MstPersonalUser entity = mstPersonalUserDao.selectById(userId);
      assertThat(entity, notNullValue());
      assertThat(entity.getUserId(), is(999900000001L));
      assertThat(entity.getFacilityCd(), is("999001"));
      assertThat(entity.getUserType(), is(0));
      assertThat(entity.getUserLastName(), is("lastName"));
      assertThat(entity.getUserFirstName(), is("firstName"));
      assertThat(entity.getUserLastNameKana(), is("lastNameKana"));
      assertThat(entity.getUserFirstNameKana(), is("firstNameKana"));
      assertThat(entity.getUserLastNameAlpha(), is("lastNameAlpha"));
      assertThat(entity.getUserFirstNameAlpha(), is("firstNameAlpha"));
      assertThat(entity.getUserEmailAddress1(), is("emailAddress1@abc.jp"));
      assertThat(entity.getUserEmailAddress2(), is("emailAddress2@xxx.org"));
      assertThat(entity.getExtensionNo(), is("extensionNo"));
      assertThat(entity.getHomeNo(), is("homeNo"));
      assertThat(entity.getMobilePhoneNo(), is("mobilePhoneNo"));
      assertThat(entity.getFaxNo(), is("faxNo"));
      assertThat(entity.getZipcd3(), is("001"));
      assertThat(entity.getZipcd4(), is("0001"));
      assertThat(entity.getAddress(), is("address"));
      assertThat(entity.getAddressKana(), is("addressKana"));
      assertThat(entity.getJobCd(), is("01"));
      assertThat(entity.getRegDate(), is(Timestamp.valueOf("2018-05-25 17:16:55")));
      assertThat(entity.getUpDate(), is(Timestamp.valueOf("2018-08-22 17:19:19.405")));
    }
  }

  /**
   * editUserAccountInfo()の検証.
   * <p>
   * 条件：更新失敗(利用者マスタ(個人情報DB)更新エラー)
   * 結果：失敗Responseが返却されること
   * </p>
   */
  @Test
  public void test_editUserAccountInfo_更新失敗_利用者マスタ個人情報DB_更新０件() throws Exception {
    // 事前準備
    Long userId = 999900000002L;
    UpdateUserAccountInfoRequest request = new UpdateUserAccountInfoRequest() {{
      setUserId(userId);
      setDispUserId("012345678901");
    }};
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.useResponseMessage", is(true)))
      .andExpect(jsonPath("$.message", is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage())));

    { // 利用者マスタ(認証DB)更新なし確認
      MstUserAuthentication entity = authenticationDao.selectById(userId);
      assertThat(entity, notNullValue());
      assertThat(entity.getUserId(), is(999900000002L));
      assertThat(entity.getFacilityCd(), is("999002"));
      assertThat(entity.getDispUserId(), is("999900000902"));
      assertThat(entity.getUserPassword(), is("$2a$10$gJv8X8lhSPyjQjMqn1Z80uT4vz0G.z83Lh2cNtMu4Kh2Iu8SqOR2u"));
      assertThat(entity.getFailureCnt(), is(6));
      assertThat(entity.getRegDate(), is(Timestamp.valueOf("2018-05-25 17:16:55")));
      assertThat(entity.getUpDate(), is(Timestamp.valueOf("2018-08-22 17:19:19.405")));
    }
    { // 利用者マスタ(個人情報DB)データなし確認
      MstPersonalUser entity = mstPersonalUserDao.selectById(userId);
      assertThat(entity, nullValue());
    }
  }

  /**
   * editUserAccountInfo()の検証.
   * <p>
   * 条件：更新失敗(利用者マスタ(個人情報DB)更新エラー)
   * 結果：失敗Responseが返却されること
   * </p>
   */
  @Test
  public void test_editUserAccountInfo_更新失敗_利用者マスタ個人情報DB_更新エラー() throws Exception {
    // 事前準備
    Long userId = 999900000001L;
    UpdateUserAccountInfoRequest request = new UpdateUserAccountInfoRequest() {{
      setUserId(userId);
      setDispUserId("ZZZZZZ");
    }};
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.useResponseMessage", is(true)))
      .andExpect(jsonPath("$.message", is(AdminWebMessage.Error.SQL_EXECUTION_ERROR.getMessage())));

    { // 利用者マスタ(認証DB)更新なし確認
      MstUserAuthentication entity = authenticationDao.selectById(userId);
      assertThat(entity, notNullValue());
      assertThat(entity.getUserId(), is(999900000001L));
      assertThat(entity.getFacilityCd(), is("999001"));
      assertThat(entity.getDispUserId(), is("999900000901"));
      assertThat(entity.getUserPassword(), is("$2a$10$gJv8X8lhSPyjQjMqn1Z80uT4vz0G.z83Lh2cNtMu4Kh2Iu8SqOR2u"));
      assertThat(entity.getFailureCnt(), is(0));
      assertThat(entity.getRegDate(), is(Timestamp.valueOf("2018-05-25 17:16:55")));
      assertThat(entity.getUpDate(), is(Timestamp.valueOf("2018-08-22 17:19:19.405")));
    }
    { // 利用者マスタ(個人情報DB)更新なし確認
      MstPersonalUser entity = mstPersonalUserDao.selectById(userId);
      assertThat(entity, notNullValue());
      assertThat(entity.getUserId(), is(999900000001L));
      assertThat(entity.getFacilityCd(), is("999001"));
      assertThat(entity.getUserType(), is(0));
      assertThat(entity.getUserLastName(), is("lastName"));
      assertThat(entity.getUserFirstName(), is("firstName"));
      assertThat(entity.getUserLastNameKana(), is("lastNameKana"));
      assertThat(entity.getUserFirstNameKana(), is("firstNameKana"));
      assertThat(entity.getUserLastNameAlpha(), is("lastNameAlpha"));
      assertThat(entity.getUserFirstNameAlpha(), is("firstNameAlpha"));
      assertThat(entity.getUserEmailAddress1(), is("emailAddress1@abc.jp"));
      assertThat(entity.getUserEmailAddress2(), is("emailAddress2@xxx.org"));
      assertThat(entity.getExtensionNo(), is("extensionNo"));
      assertThat(entity.getHomeNo(), is("homeNo"));
      assertThat(entity.getMobilePhoneNo(), is("mobilePhoneNo"));
      assertThat(entity.getFaxNo(), is("faxNo"));
      assertThat(entity.getZipcd3(), is("001"));
      assertThat(entity.getZipcd4(), is("0001"));
      assertThat(entity.getAddress(), is("address"));
      assertThat(entity.getAddressKana(), is("addressKana"));
      assertThat(entity.getJobCd(), is("01"));
      assertThat(entity.getRegDate(), is(Timestamp.valueOf("2018-05-25 17:16:55")));
      assertThat(entity.getUpDate(), is(Timestamp.valueOf("2018-08-22 17:19:19.405")));
    }
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
    Long userId = 900000000002L;
    String dispUserId = "800000000001";

    // API実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/user/check/{userId}/{dispUserId}", userId, dispUserId));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.result", is(true)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_EXISTED.getMessage())))
      .andDo(document("user/check/ok1",
          pathParameters(
            parameterWithName("userId").description(RestDocMessage.Request.USER_ID),
            parameterWithName("dispUserId").description("[必須]表示用ユーザーID")),
          responseFields(
              attributes(
                key("description").value(""),
                key("operationTargetTable").value("")
              ),
              fieldWithPath("result").description(RestDocMessage.Response.IS_SUCCESS),
              fieldWithPath("errorMessage").description(RestDocMessage.Response.ERROR_MESSAGE)
          )));
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

    // API実行
    ResultActions result =
      mockMvc.perform(request(HttpMethod.GET, "/api/user/check/{userId}/{dispUserId}", userId, dispUserId));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.result", is(false)))
      .andExpect(jsonPath("$.errorMessage", nullValue()))
      .andDo(document("user/check/ok2"));
  }

  /**
   * getUserAccountInfo()の検証.
   * <p>
   *   条件：成功
   *   結果：成功レスポンスが返されること
   *        アカウント情報が取得されていること
   * </p>
   */
  @Test
  @NtssMockUser(userId = 1L)
  public void test_getUserAccountInfo_正常_成功() throws Exception {

    // API実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/user"));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.userAccountInfo.userId", is(1)))
      .andExpect(jsonPath("$.userAccountInfo.dispUserId", is("userAccount")))
      .andExpect(jsonPath("$.userAccountInfo.userType", is(0)))
      .andExpect(jsonPath("$.userAccountInfo.administrator", is(0)))
      .andExpect(jsonPath("$.userAccountInfo.facilityCd", is("900001")))
      .andExpect(jsonPath("$.userAccountInfo.userLastName", is("lastName")))
      .andExpect(jsonPath("$.userAccountInfo.userFirstName", is("firstName")))
      .andExpect(jsonPath("$.userAccountInfo.userLastNameKana", is("lastNameKana")))
      .andExpect(jsonPath("$.userAccountInfo.userFirstNameKana", is("firstNameKana")))
      .andExpect(jsonPath("$.userAccountInfo.userLastNameAlpha", is("lastNameAlpha")))
      .andExpect(jsonPath("$.userAccountInfo.userFirstNameAlpha", is("firstNameAlpha")))
      .andExpect(jsonPath("$.userAccountInfo.userEmailAddress1", is("emailAddress1@abc.jp")))
      .andExpect(jsonPath("$.userAccountInfo.userEmailAddress2", is("emailAddress2@xxx.org")))
      .andExpect(jsonPath("$.userAccountInfo.extensionNo", is("extensionNo")))
      .andExpect(jsonPath("$.userAccountInfo.homeNo", is("homeNo")))
      .andExpect(jsonPath("$.userAccountInfo.mobilePhoneNo", is("mobilePhoneNo")))
      .andExpect(jsonPath("$.userAccountInfo.faxNo", is("faxNo")))
      .andExpect(jsonPath("$.userAccountInfo.zipcd3", is("001")))
      .andExpect(jsonPath("$.userAccountInfo.zipcd4", is("0001")))
      .andExpect(jsonPath("$.userAccountInfo.address", is("address")))
      .andExpect(jsonPath("$.userAccountInfo.addressKana", is("addressKana")))
      .andExpect(jsonPath("$.userAccountInfo.isProvisional", is(1)))
      .andExpect(jsonPath("$.userAccountInfo.jobCd", is("01")))
      .andExpect(jsonPath("$.userAccountInfo.inHospitalCd_1", nullValue()))
      .andExpect(jsonPath("$.userAccountInfo.inHospitalCd_2", nullValue()))
      .andExpect(jsonPath("$.userAccountInfo.infoDispToAdmin", is("0")))
      .andExpect(jsonPath("$.userAccountInfo.userSettings.is_disp_menu", is(1)))
      .andExpect(jsonPath("$.userAccountInfo.userSettings.font_size", is(3)))
      .andExpect(jsonPath("$.userAccountInfo.userSettings.theme", is(0)))
      .andExpect(jsonPath("$.userAccountInfo.userSettings.authorized_functions", is(Arrays.asList(new String[]{}))))
      .andExpect(jsonPath("$.userAccountInfo.userSettings.personal_settings", is(Arrays.asList(new String[]{}))))
      .andExpect(jsonPath("$.userAccountInfo.userSettings.ind_rst_pattern", is(2)))
      .andExpect(jsonPath("$.userAccountInfo.userSettings.is_split_frame", is(1)))
      .andExpect(jsonPath("$.userAccountInfo.userSettings.initial_function", is("001")))
      .andExpect(jsonPath("$.userAccountInfo.userSettings.use_functions",
          is(Arrays.asList(new String[] { "005", "004", "003", "002", "001" }))))
      .andExpect(jsonPath("$.userAccountInfo.regDate", is("2018-05-25T08:16:55.000+0000")))
      .andExpect(jsonPath("$.userAccountInfo.upDate", is("2018-08-22T08:19:19.405+0000")))
      .andExpect(jsonPath("$.userAccountInfo.patId", is(1)))
      .andExpect(jsonPath("$.userAccountInfo.secretKey", nullValue()))
      .andDo(document("user/get/ok",
          responseFields(
            attributes(
              key("description").value(""),
              key("operationTargetTable").value("")
            ),
            fieldWithPath("userAccountInfo.userId").description("利用者ID"),
            fieldWithPath("userAccountInfo.dispUserId").description("表示利用者ID"),
            fieldWithPath("userAccountInfo.userType").description("利用者種別"),
            fieldWithPath("userAccountInfo.administrator").description("管理者フラグ"),
            fieldWithPath("userAccountInfo.facilityCd").description("施設コード"),
            fieldWithPath("userAccountInfo.userLastName").description("利用者名_姓"),
            fieldWithPath("userAccountInfo.userFirstName").description("利用者名_名"),
            fieldWithPath("userAccountInfo.userLastNameKana").description("利用者カナ名_姓"),
            fieldWithPath("userAccountInfo.userFirstNameKana").description("利用者カナ名_名"),
            fieldWithPath("userAccountInfo.userLastNameAlpha").description("利用者英字名_姓"),
            fieldWithPath("userAccountInfo.userFirstNameAlpha").description("利用者英字名_名"),
            fieldWithPath("userAccountInfo.userEmailAddress1").description("メールアドレス1"),
            fieldWithPath("userAccountInfo.userEmailAddress2").description("利用者種別"),
            fieldWithPath("userAccountInfo.userType").description("メールアドレス2"),
            fieldWithPath("userAccountInfo.extensionNo").description("内線番号"),
            fieldWithPath("userAccountInfo.homeNo").description("自宅番号"),
            fieldWithPath("userAccountInfo.mobilePhoneNo").description("携帯番号"),
            fieldWithPath("userAccountInfo.faxNo").description("FAX番号"),
            fieldWithPath("userAccountInfo.zipcd3").description("郵便番号(上3桁)"),
            fieldWithPath("userAccountInfo.zipcd4").description("郵便番号(下4桁)"),
            fieldWithPath("userAccountInfo.address").description("住所"),
            fieldWithPath("userAccountInfo.addressKana").description("住所ふりがな"),
            fieldWithPath("userAccountInfo.isProvisional").description("仮登録フラグ"),
            fieldWithPath("userAccountInfo.jobCd").description("職種コード"),
            fieldWithPath("userAccountInfo.inHospitalCd_1").description("院内コード1").ignored(),
            fieldWithPath("userAccountInfo.inHospitalCd_2").description("院内コード2").ignored(),
            fieldWithPath("userAccountInfo.infoDispToAdmin").description("管理者への表示許可"),
            fieldWithPath("userAccountInfo.patId").description("患者ID"),
            fieldWithPath("userAccountInfo.secretKey").description("シークレットキー").ignored(),
            fieldWithPath("userAccountInfo.isConsent").description("個人情報取扱い同意フラグ").ignored(),
            fieldWithPath("userAccountInfo.regDate").description("登録日時"),
            fieldWithPath("userAccountInfo.upDate").description("更新日時"),
            fieldWithPath("userAccountInfo.userSettings.*").ignored(),
            fieldWithPath("userAccountInfo.userSettings.use_functions[]").ignored(),
            fieldWithPath("userAccountInfo.anesthesiologistLicenseNo").ignored(),
            fieldWithPath("userAccountInfo.isSetQrCode").description("秘密キー設定フラグ").ignored(),
            fieldWithPath("userAccountInfo.regPasswordDate").description("パスワード変更日時").ignored())
      ));

  }

  /**
   * getUserAccountInfo()の検証.
   * <p>
   *   条件：失敗
   *   結果：失敗レスポンスが返されること
   *        アカウント情報が取得されていないこと
   * </p>
   */
  @Test
  @NtssMockUser(userId = 100L)
  public void test_getUserAccountInfo_失敗() throws Exception {

    // API実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/user"));

    // 検証
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.userAccountInfo", nullValue()))
      .andDo(document("user/get/internal_server_error"));

  }

}
