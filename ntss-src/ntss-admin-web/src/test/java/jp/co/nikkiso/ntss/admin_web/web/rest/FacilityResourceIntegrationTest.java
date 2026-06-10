package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.hasSize;
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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Arrays;
import java.util.List;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.constant.RestDocMessage;
import jp.co.nikkiso.ntss.admin_web.request.facility.SetStaffFacilityRequest;
import jp.co.nikkiso.ntss.admin_web.response.facilities.StaffFacility;
import jp.co.nikkiso.ntss.core.dao.MstStaffFacilityDao;
import jp.co.nikkiso.ntss.core.entity.MstStaffFacility;

/**
 * FacilityResourceの結合用テストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/FacilityResourceIntegrationTest.before.sql")
public class FacilityResourceIntegrationTest extends AbstractResourceIntegrationTest {

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * 担当施設マスタのDaoインターフェイス.
   */
  @Autowired
  private MstStaffFacilityDao mstStaffFacilityDao;

  /**
   * getFacilities()の検証.
   * <p>
   * 条件: 該当ユーザIDなし
   * 結果: 空のレスポンスが生成されること
   * </p>
   */
  @Test
  public void test_getFacilities_該当ユーザなし() throws Exception {

    final Long userId = 0L;

    mockMvc.perform(get("/api/facilities/{userId}?isNkkFacility={isNkkFacility}", userId, false))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.facilities", hasSize(0)));

  }

  /**
   * getFacilities()の検証.
   * 正常
   */
  @Test
  public void test_getFacilities_正常() throws Exception {

    final String userId = "900000000001";

    mockMvc.perform(get("/api/facilities/{userId}?isNkkFacility={isNkkFacility}", userId, false))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.facilities", hasSize(2)))
      .andExpect(jsonPath("$.facilities[0].facilityCd", is("900001")))
      .andExpect(jsonPath("$.facilities[0].facilityName", is("テスト施設1")))
      .andExpect(jsonPath("$.facilities[0].departmentCd", is("9001")))
      .andExpect(jsonPath("$.facilities[0].mNoticeCnt", equalTo(3)))
      .andExpect(jsonPath("$.facilities[0].preventiveCnt", equalTo(3)))
      .andExpect(jsonPath("$.facilities[0].comProblemCnt", equalTo(2)))
      .andExpect(jsonPath("$.facilities[0].serviceSupportCnt", equalTo(2)))
      .andExpect(jsonPath("$.facilities[1].facilityCd", is("900002")))
      .andExpect(jsonPath("$.facilities[1].facilityName", is("テスト施設2")))
      .andExpect(jsonPath("$.facilities[1].departmentCd", is("9002")))
      .andExpect(jsonPath("$.facilities[1].mNoticeCnt", equalTo(1)))
      .andExpect(jsonPath("$.facilities[1].preventiveCnt", equalTo(1)))
      .andExpect(jsonPath("$.facilities[1].comProblemCnt", equalTo(0)))
      .andExpect(jsonPath("$.facilities[1].serviceSupportCnt", equalTo(1)));

  }

  /**
   * getStaffFacility()の検証.
   * 成功
   */
  @Test
  public void test_getStaffFacility_成功() throws Exception {
    // 事前準備
    String userId = "900000000001";
    List<StaffFacility> staffFacilities = Arrays.asList(
        new StaffFacility(true, "9001", "01", "東京都", "900001", "テスト施設1", "テストシセツ1"),
        new StaffFacility(true, "9002", "02", "福井県", "900002", "テスト施設2", "テストシセツ2"),
        new StaffFacility(false, "9003", "01", "東京都", "900003", "テスト施設3", "テストシセツ3")
    );

    // API実行
    ResultActions result =
      mockMvc.perform(RestDocumentationRequestBuilders.get("/api/facilities/staff_facility/{userId}", userId));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.staffFacilities", hasSize(3)))
      .andDo(document("facilities/staff_facility/get/ok",
          pathParameters(
              parameterWithName("userId").description(RestDocMessage.Request.USER_ID)),
          responseFields(
              attributes(
                key("description").value(""),
                key("operationTargetTable").value("")
              ),
              fieldWithPath("staffFacilities[]").description("[必須]担当施設リスト"),
              fieldWithPath("staffFacilities[].isCharge").description("担当フラグ"),
              fieldWithPath("staffFacilities[].departmentCd").description("部署符号"),
              fieldWithPath("staffFacilities[].prefecturesCd").description("都道府県コード"),
              fieldWithPath("staffFacilities[].prefecturesName").description("都道府県名称"),
              fieldWithPath("staffFacilities[].facilityCd").description("施設コード"),
              fieldWithPath("staffFacilities[].facilityName").description("施設名称"),
              fieldWithPath("staffFacilities[].facilityNameKana").description("施設カナ名称"))
        ));

    for (int i = 0; i < staffFacilities.size(); i++) {
      StaffFacility sf = staffFacilities.get(i);
      String prefix = String.format("$.staffFacilities[%d].", i);
      result
        .andExpect(jsonPath(prefix + "isCharge", is(sf.isCharge)))
        .andExpect(jsonPath(prefix + "departmentCd", is(sf.departmentCd)))
        .andExpect(jsonPath(prefix + "prefecturesCd", is(sf.prefecturesCd)))
        .andExpect(jsonPath(prefix + "prefecturesName", is(sf.prefecturesName)))
        .andExpect(jsonPath(prefix + "facilityCd", is(sf.facilityCd)))
        .andExpect(jsonPath(prefix + "facilityName", is(sf.facilityName)))
        .andExpect(jsonPath(prefix + "facilityNameKana", is(sf.facilityNameKana)));
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
    // 事前準備
    Long userId = 900000000001L;
    List<String> staffFacilityCds = Arrays.asList("900001", "900002", "900003");
    SetStaffFacilityRequest request = new SetStaffFacilityRequest() {
      {
      setStaffFacilityCds(staffFacilityCds);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result =  mockMvc.perform(RestDocumentationRequestBuilders.put("/api/facilities/staff_facility/{userId}", userId)
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.isSuccess", is(true)))
      .andExpect(jsonPath("$.errorMessage", nullValue()))
      .andDo(document("facilities/staff_facility/set/ok",
          pathParameters(
            parameterWithName("userId").description(RestDocMessage.Request.USER_ID)),
          requestFields(
            attributes(
              key("description").value(""),
              key("operationTargetTable").value("")
            ),
            fieldWithPath("staffFacilityCds[]").description("[必須]担当施設コードリスト"))
        ));

    // 更新された担当施設マスタ検証
    List<MstStaffFacility> entities = mstStaffFacilityDao.selectByUserId(userId);
    assertThat(entities.size(), is(staffFacilityCds.size()));
    for (int i = 0; i < staffFacilityCds.size(); i++) {
      assertThat(entities.get(i).getUserId(), is(userId));
      assertThat(entities.get(i).getFacilityCd(), is(staffFacilityCds.get(i)));
    }
  }

  /**
   * setStaffFacility()の検証.
   * <p>
   *   条件: 該当ユーザIDなし
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_setStaffFacility_失敗_該当ユーザなし() throws Exception {
    // 事前準備
    String userId = "990000000001";
    List<String> staffFacilityCds = Arrays.asList("900001", "900002", "900003");
    SetStaffFacilityRequest request = new SetStaffFacilityRequest() {
      {
      setStaffFacilityCds(staffFacilityCds);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result =  mockMvc.perform(RestDocumentationRequestBuilders.put("/api/facilities/staff_facility/{userId}", userId)
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isBadRequest())
    .andExpect(jsonPath("$.isSuccess", is(false)))
    .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage())))
      .andDo(document("facilities/staff_facility/set/bad-request1",
          responseFields(
              attributes(
                key("description").value(""),
                key("operationTargetTable").value("")
              ),
              fieldWithPath("isSuccess").description(RestDocMessage.Response.IS_SUCCESS),
              fieldWithPath("errorMessage").description(RestDocMessage.Response.ERROR_MESSAGE))
        ));
  }

  /**
   * setStaffFacility()の検証.
   * <p>
   *   条件: 該当施設コードなし
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_setStaffFacility_失敗_該当施設なし() throws Exception {
    // 事前準備
    String userId = "900000000001";
    List<String> staffFacilityCds = Arrays.asList("900001", "900002", "900004");
    SetStaffFacilityRequest request = new SetStaffFacilityRequest() {
      {
      setStaffFacilityCds(staffFacilityCds);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result =  mockMvc.perform(RestDocumentationRequestBuilders.put("/api/facilities/staff_facility/{userId}", userId)
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isBadRequest())
    .andExpect(jsonPath("$.isSuccess", is(false)))
    .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.FACILITY_CD_NOT_FOUND.getMessage())))
      .andDo(document("facilities/staff_facility/set/bad-request2"));
  }

  /**
   * getUseFunctions()の検証.
   * <p>
   *   条件: データあり
   *   結果：使用可能機能リストが返されること
   * </p>
   */
  @Test
  public void test_getUseFunctions_成功_データあり() throws Exception {
    // 事前準備
    String facilityCd = "900001";

    // API実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/facilities/{facilityCd}/use-functions", facilityCd));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(3)))
      .andExpect(jsonPath("$[0]", is("00a")))
      .andExpect(jsonPath("$[1]", is("00b")))
      .andExpect(jsonPath("$[2]", is("00c")))
      .andDo(document("facilities/use-functions/get/ok",
        pathParameters(
          parameterWithName("facilityCd").description(RestDocMessage.Request.FACILITY_CD)),
        responseFields(
          attributes(
            key("description").value("概要：指定された施設コードに該当する施設の使用可能機能を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：施設マスタ (mst_facility)")
          ),
          fieldWithPath("[]").description("[必須]使用可能機能リスト"))
      ));
  }

  /**
   * getUseFunctions()の検証.
   * <p>
   *   条件: データなし(空リスト)
   *   結果：空リストが返されること
   * </p>
   */
  @Test
  public void test_getUseFunctions_成功_データなし_空リスト() throws Exception {
    // 事前準備
    String facilityCd = "900002";

    // API実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/facilities/{facilityCd}/use-functions", facilityCd));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)));
  }


  /**
   * getUseFunctions()の検証.
   * <p>
   *   条件: データなし(NULL)
   *   結果：空リストが返されること
   * </p>
   */
  @Test
  public void test_getUseFunctions_成功_データなし_NULL() throws Exception {
    // 事前準備
    String facilityCd = "900003";

    // API実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/facilities/{facilityCd}/use-functions", facilityCd));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)));
  }

  /**
   * getUseFunctions()の検証.
   * <p>
   *   条件: データなし(施設なし)
   *   結果：空リストが返されること
   * </p>
   */
  @Test
  public void test_getUseFunctions_成功_データなし_施設なし() throws Exception {
    // 事前準備
    String facilityCd = "900004";

    // API実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/facilities/{facilityCd}/use-functions", facilityCd));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)));
  }

  /**
   * getDisplayNameAndContentsIdByFacilityCd()の検証.
   * <p>
   *   条件: データあり
   *   結果：個人設定タブ定義が返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "009999", userType = 1, administrator = 1)
  public void test_getDisplayNameAndContentsIdByFacilityCd_成功_データあり() throws Exception {
    // arrange
    final String facilityCd = "009999";

    // action
    ResultActions result = mockMvc.perform(
      RestDocumentationRequestBuilders.get("/api/facilities/{facilityCd}/personal-setting/tab/define", facilityCd)
    );

    // assert
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(2)))
      .andExpect(jsonPath("$[0].tabDefineCd", is(3)))
      .andExpect(jsonPath("$[0].displayName", is("タブC")))
      .andExpect(jsonPath("$[0].contentsId", is("tab-contents-C")))
      .andExpect(jsonPath("$[0].mode", is("1")))
      .andExpect(jsonPath("$[1].tabDefineCd", is(1)))
      .andExpect(jsonPath("$[1].displayName", is("タブA")))
      .andExpect(jsonPath("$[1].contentsId", is("tab-contents-A")))
      .andExpect(jsonPath("$[1].mode", is("0")))
      .andDo(document("facilities/personal-setting/tab/define/get/ok",
        pathParameters(
          parameterWithName("facilityCd").description(RestDocMessage.Request.FACILITY_CD)),
        responseFields(
          attributes(
            key("description").value("概要：指定された施設コードに該当する施設の個人設定タブ定義を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：施設ごとの個人設定タブ定義 (mst_personal_tab_define)")
          ),
          fieldWithPath("[]").description("[必須]個人設定タブ定義リスト"),
          fieldWithPath("[].tabDefineCd").description("[必須]タブ定義コード"),
          fieldWithPath("[].displayName").description("[必須]タブ表示名"),
          fieldWithPath("[].contentsId").description("[必須]タブコンテンツID"),
          fieldWithPath("[].mode").description("[必須]モード（1.共通画面を使用 2.個別画面を使用）"))
        ));
  }

  /**
   * getDisplayNameAndContentsIdByFacilityCd()の検証.
   * <p>
   *   条件: データなし(施設なし)
   *   結果：空リストが返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "xxxxxx", userType = 1, administrator = 1)
  public void test_getDisplayNameAndContentsIdByFacilityCd_成功_データなし() throws Exception {
    // arrange
    final String facilityCd = "xxxxxx";

    // action
    ResultActions result = mockMvc.perform(
      get("/api/facilities/{facilityCd}/personal-setting/tab/define", facilityCd)
    );

    // assert
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)));
  }

  /**
   * getDoctorsByFacilityCd()の検証.
   * <p>
   *   条件: データあり
   *   結果：医師のリストが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  @Sql("classpath:resource.script/FacilityResourceIntegrationTest.getDoctors.MstJob.before.sql")
  @Sql(value = "classpath:resource.script/FacilityResourceIntegrationTest.getDoctors.MstPersonalUser.before.sql", config = @SqlConfig(dataSource = CoreConstant.DataSourceName.PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  public void test_getDoctorsByFacilityCd_成功_データあり() throws Exception {
    // arrange
    final String facilityCd = "009999";

    // action
    ResultActions result = mockMvc.perform(
      RestDocumentationRequestBuilders.get("/api/facilities/{facilityCd}/personal-user/job/doctor", facilityCd)
    );

    // assert
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(2)))
      .andExpect(jsonPath("$[0].user_id", is(11)))
      .andExpect(jsonPath("$[0].user_last_name", is("lastName11")))
      .andExpect(jsonPath("$[0].user_first_name", is("firstName11")))
      .andExpect(jsonPath("$[1].user_id", is(12)))
      .andExpect(jsonPath("$[1].user_last_name", is("lastName12")))
      .andExpect(jsonPath("$[1].user_first_name", is("firstName12")))
      .andDo(document("facilities/personal-user/job/doctor/get/ok",
        pathParameters(
          parameterWithName("facilityCd").description(RestDocMessage.Request.FACILITY_CD)),
        responseFields(
          attributes(
            key("description").value("概要：指定された施設コードに該当する医師のリストを取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：利用者マスタ(mst_personal_user)、職種マスタ(mst_job)")
          ),
          fieldWithPath("[]").description("[必須]医師リスト"),
          fieldWithPath("[].user_id").description("[必須]利用者ID（内部用ID）"),
          fieldWithPath("[].user_last_name").description("[必須]利用者名_姓"),
          fieldWithPath("[].user_first_name").description("[必須]利用者名_名"),
          fieldWithPath("[].is_del").description("削除フラグ").optional())
      ));
  }

  /**
   * getDoctorsByFacilityCd()の検証.
   * <p>
   *   条件: 医師が存在しない
   *   結果：空リストが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  @Sql("classpath:resource.script/FacilityResourceIntegrationTest.getDoctors.MstJob.before.sql")
  @Sql(value = "classpath:resource.script/FacilityResourceIntegrationTest.getDoctors.MstPersonalUser.before.sql", config = @SqlConfig(dataSource = CoreConstant.DataSourceName.PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  public void test_getDoctorsByFacilityCd_成功_データなし() throws Exception {
    // arrange
    final String facilityCd = "999999";

    // action
    ResultActions result = mockMvc.perform(
      RestDocumentationRequestBuilders.get("/api/facilities/{facilityCd}/personal-user/job/doctor", facilityCd)
    );

    // assert
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)));
  }
}
