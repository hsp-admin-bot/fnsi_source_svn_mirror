package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
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
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.request.userSettings.AlterSplitFrameRequest;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import org.hamcrest.Matchers;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.request.userSettings.AlterFontSizeRequest;
import jp.co.nikkiso.ntss.admin_web.request.userSettings.AlterMenuBarRequest;
import jp.co.nikkiso.ntss.admin_web.request.userSettings.AlterThemeRequest;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.admin_web.constant.RestDocMessage;


/**
 * UserSettingsResourceの結合用テストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/UserSettingsResourceIntegrationTest.before.sql")
public class UserSettingsResourceIntegrationTest extends AbstractResourceIntegrationTest {

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
   * alterFontSize()の検証.
   * <p>
   *   条件：成功
   *   結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterFontSize_成功() throws Exception {

    // 事前準備
    Long userId = 900000000001L;
    int fontSize = 1;
    AlterFontSizeRequest request = new AlterFontSizeRequest() {
      {
        setUserId(userId);
        setFontSize(fontSize);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/font_size")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.isSuccess", is(true)))
      .andExpect(jsonPath("$.errorMessage", nullValue()))
      .andDo(document("user_settings/font_size/ok",
          requestFields(
            attributes(
              key("description").value(""),
              key("operationTargetTable").value("")
            ),
            fieldWithPath("userId").description(RestDocMessage.Request.USER_ID),
            fieldWithPath("fontSize").description("[必須]文字サイズ(0:小～3:特大)"))
        ));

    // 更新された利用者マスタの検証
    MstUser mstUser = mstUserDao.selectById(userId);
    assertThat(mstUser.getUserSettings().getFontSize(), is(fontSize));

  }

  /**
   * alterFontSize()の検証.
   * <p>
   *   条件：失敗_文字サイズ指定不正
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterFontSize_失敗_文字サイズ指定不正() throws Exception {

    // 事前準備
    Long userId = 900000000001L;
    int fontSize = 4;
    AlterFontSizeRequest request = new AlterFontSizeRequest() {
      {
        setUserId(userId);
        setFontSize(fontSize);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/font_size")
        .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.FONT_SIZE_INCORRECT.getMessage())))
      .andDo(document("user_settings/font_size/bad-request1",
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
   * alterFontSize()の検証.
   * <p>
   *   条件：失敗_該当ユーザーなし
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterFontSize_失敗_該当ユーザーなし() throws Exception {

    // 事前準備
    Long userId = 900000000002L;
    int fontSize = 1;
    AlterFontSizeRequest request = new AlterFontSizeRequest() {
      {
        setUserId(userId);
        setFontSize(fontSize);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/font_size")
        .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage())))
      .andDo(document("user_settings/font_size/bad-request2"));
  }

  /**
   * alterTheme()の検証.
   * <p>
   *   条件：成功
   *   結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterTheme_成功() throws Exception {

    // 事前準備
    Long userId = 900000000001L;
    int theme = 1;
    AlterThemeRequest request = new AlterThemeRequest() {
      {
        setUserId(userId);
        setTheme(theme);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/theme")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.isSuccess", is(true)))
      .andExpect(jsonPath("$.errorMessage", nullValue()))
      .andDo(document("user_settings/theme/ok",
          requestFields(
            attributes(
              key("description").value(""),
              key("operationTargetTable").value("")
            ),
            fieldWithPath("userId").description(RestDocMessage.Request.USER_ID),
            fieldWithPath("theme").description("[必須]テーマ(0:白 1:黒)"))
        ));

    // 更新された利用者マスタの検証
    MstUser mstUser = mstUserDao.selectById(userId);
    assertThat(mstUser.getUserSettings().getTheme(), is(theme));

  }

  /**
   * alterTheme()の検証.
   * <p>
   *   条件：失敗_テーマ指定不正
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterTheme_失敗_テーマ指定不正() throws Exception {

    // 事前準備
    Long userId = 900000000001L;
    int theme = 2;
    AlterThemeRequest request = new AlterThemeRequest() {
      {
        setUserId(userId);
        setTheme(theme);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/theme")
        .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.THEME_INCORRECT.getMessage())))
      .andDo(document("user_settings/theme/bad-request1",
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
   * alterTheme()の検証.
   * <p>
   *   条件：失敗_該当ユーザーなし
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterTheme_失敗_該当ユーザーなし() throws Exception {

    // 事前準備
    Long userId = 900000000002L;
    int theme = 0;
    AlterThemeRequest request = new AlterThemeRequest() {
      {
        setUserId(userId);
        setTheme(theme);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/theme")
        .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage())))
      .andDo(document("user_settings/theme/bad-request2"));
  }

  /**
   * alterMenuBar()の検証.
   * <p>
   *   条件：成功
   *   結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterMenuBar_成功() throws Exception {

    // 事前準備
    Long userId = 900000000001L;
    int isDispMenu = 1;
    List<String> useFunctions = Arrays.asList("001", "003", "002");
    String initialFunction = "002";
    AlterMenuBarRequest request = new AlterMenuBarRequest() {
      {
        setUserId(userId);
        setIsDispMenu(isDispMenu);
        setUseFunctions(useFunctions);
        setInitialFunction(initialFunction);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/menu_bar")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.isSuccess", is(true)))
      .andExpect(jsonPath("$.errorMessage", nullValue()))
      .andDo(document("user_settings/menu_bar/ok",
        requestFields(
          attributes(
            key("description").value(""),
            key("operationTargetTable").value("")
          ),
          fieldWithPath("userId").description(RestDocMessage.Request.USER_ID),
          fieldWithPath("isDispMenu").description("[必須]メニューバー表示フラグ(0:非表示 1:表示)"),
          fieldWithPath("useFunctions").description("[必須]使用可能機能一覧"),
          fieldWithPath("initialFunction").description("[必須]初期表示機能"))
      ));

    // 更新された利用者マスタの検証
    MstUser mstUser = mstUserDao.selectById(userId);
    assertThat(mstUser.getUserSettings().getIsDispMenu(), is(isDispMenu));
    assertThat(mstUser.getUserSettings().getUseFunctions(), is(useFunctions));
    assertThat(mstUser.getUserSettings().getInitialFunction(), is(initialFunction));

  }

  /**
   * alterMenuBar()の検証.
   * <p>
   *   条件：失敗_メニュー表示フラグ不正
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterMenuBar_失敗_メニュー表示フラグ指定不正() throws Exception {

    // 事前準備
    Long userId = 900000000001L;
    int isDispMenu = 2;
    List<String> useFunctions = Collections.emptyList();
    String initialFunction = "";
    AlterMenuBarRequest request = new AlterMenuBarRequest() {
      {
        setUserId(userId);
        setIsDispMenu(isDispMenu);
        setUseFunctions(useFunctions);
        setInitialFunction(initialFunction);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/menu_bar")
        .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.IS_DISP_MENU_INCORRECT.getMessage())))
      .andDo(document("user_settings/menu_bar/bad-request1",
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
   * alterMeunBar()の検証.
   * <p>
   *   条件：失敗_該当ユーザーなし
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterMenuBar_失敗_該当ユーザーなし() throws Exception {

    // 事前準備
    Long userId = 900000000002L;
    int isDispMenu = 0;
    List<String> useFunctions = Collections.emptyList();
    String initialFunction = "";
    AlterMenuBarRequest request = new AlterMenuBarRequest() {
      {
        setUserId(userId);
        setIsDispMenu(isDispMenu);
        setUseFunctions(useFunctions);
        setInitialFunction(initialFunction);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/menu_bar")
        .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage())))
      .andDo(document("user_settings/menu_bar/bad-request4"));
  }

  /**
   * getPersonalSettings()の検証.
   * 条件: ログインユーザーに該当する利用者マスタが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(userId = 900000000001L)
  public void test_getPersonalSettings_成功() throws Exception {
    Integer tabDeifineCd = 1;

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/user_settings/personal_settings/{tab_define_cd}", tabDeifineCd)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .with(csrf()));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$", hasSize(3)))
      .andExpect(jsonPath("$[0].setting_identifier", Matchers.is("1")))
      .andExpect(jsonPath("$[0].value", Matchers.is("val1")))
      .andExpect(jsonPath("$[1].setting_identifier", Matchers.is("2")))
      .andExpect(jsonPath("$[1].value", Matchers.is(2)))
      .andExpect(jsonPath("$[2].setting_identifier", Matchers.is("3")))
      .andExpect(jsonPath("$[2].value", Matchers.is(1.45)))
      .andDo(
        document("user_settings/personal_settings/get/ok",
          pathParameters(
            parameterWithName("tab_define_cd").description("[必須]タブ定義コード")
          ),
          responseFields(
            attributes(
              key("description").value("概要：ログインユーザーに設定されている共通設定タブで入力した個人設定値を取得するAPI"),
              key("operationTargetTable").value("操作対象テーブル：利用者マスタ (mst_user)")
            ),
            fieldWithPath("[]").description("個人設定値")
            , fieldWithPath("[].setting_identifier").description("設定項目ID")
            , fieldWithPath("[].value").description("設定項目値")
          )
        )
      )
    ;
  }

  /**
   * getPersonalSettings()の検証.
   * 条件: ログインユーザーに該当する利用者マスタが登録されていない
   * 結果: 失敗レスポンスが返されること
   */
  @Test
  @NtssMockUser(userId = 99L)
  public void test_getPersonalSettings_失敗() throws Exception {
    Integer tabDeifineCd = 1;

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/user_settings/personal_settings/{tab_define_cd}/", tabDeifineCd)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .with(csrf()));

    result
      .andExpect(status().isInternalServerError())
      .andDo(document("user_settings/personal_settings/get/internal_server_error"));
  }

  /**
   * user_settings.personal_settingsのvaluesを生成します.
   * @return 共通設定タブの個人設定値テストデータ
   */
  List<MstUser.SettingValue> createSettingValue() {
    return Arrays.asList(
      new MstUser.SettingValue("{\"setting_identifier\": \"1\",\"value\": \"val1\"}"),
      new MstUser.SettingValue("{\"setting_identifier\": \"2\",\"value\": 2}"),
      new MstUser.SettingValue("{\"setting_identifier\": \"3\",\"value\": 1.24}"),
      new MstUser.SettingValue("{\"setting_identifier\": \"4\",\"value\": \"val4\"}"),
      new MstUser.SettingValue("{\"setting_identifier\": \"5\",\"value\": \"val5\"}")
    );
  }

  /**
   * updatePersonalSettings()の検証.
   * 条件: ログインユーザーに該当する利用者マスタが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(userId = 900000000001L)
  public void test_updatePersonalSettings_成功() throws Exception {
    // 事前準備
    List<MstUser.SettingValue> values = createSettingValue();
    MstUser.PersonalSetting request = new MstUser.PersonalSetting() {
      {
        setTabDefineCd(2);
        setValues(values);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/user_settings/personal_settings")
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf()));

    result
      .andExpect(status().isOk())
      .andDo(
        document("user_settings/personal_settings/put/ok",
          requestFields(
            attributes(
              key("description").value("概要：ログインユーザーに設定されている共通設定タブで入力した個人設定値を更新するAPI"),
              key("operationTargetTable").value("操作対象テーブル：利用者マスタ (mst_user)")
            ),
            fieldWithPath("tab_define_cd").description("[必須]タブ定義コード")
            , fieldWithPath("values").description("個人設定値")
            , fieldWithPath("values[].setting_identifier").description("個人設定ID")
            , fieldWithPath("values[].value").description("個人設定値")
          )
        )
      )
    ;
  }

  /**
   * updatePersonalSettings()の検証.
   * 条件: ログインユーザーに該当する利用者マスタが登録されていない
   * 結果: 失敗レスポンスが返されること
   */
  @Test
  @NtssMockUser(userId = 99L)
  public void test_updatePersonalSettings_失敗() throws Exception {
    // 事前準備
    List<MstUser.SettingValue> values = createSettingValue();
    MstUser.PersonalSetting request = new MstUser.PersonalSetting() {
      {
        setTabDefineCd(2);
        setValues(values);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/user_settings/personal_settings")
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf()));

    result
      .andExpect(status().isInternalServerError())
      .andDo(document("user_settings/personal_settings/put/internal_server_error"));
  }

  /**
   * alterSplitFrame()の検証.
   * <p>
   *   条件：成功
   *   結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterSplitFrame_成功() throws Exception {

    // 事前準備
    Long userId = 900000000001L;
    int splitFrame = 1;
    AlterSplitFrameRequest request = new AlterSplitFrameRequest() {
      {
        setUserId(userId);
        setIsSplitFrame(splitFrame);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/split_frame")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.isSuccess", is(true)))
      .andExpect(jsonPath("$.errorMessage", nullValue()))
      .andDo(document("user_settings/split_frame/ok",
        requestFields(
          attributes(
            key("description").value("概要：指定されたユーザーIDに該当する利用者マスタの画面フレーム分割を設定するAPI"),
            key("operationTargetTable").value("操作対象テーブル：利用者マスタ (mst_user)")
          ),
          fieldWithPath("userId").description(RestDocMessage.Request.USER_ID),
          fieldWithPath("isSplitFrame").description("[必須]画面フレーム分割フラグ(0:しない 1:する)"))
      ));

    // 更新された利用者マスタの検証
    MstUser mstUser = mstUserDao.selectById(userId);
    assertThat(mstUser.getUserSettings().getIsSplitFrame(), is(splitFrame));
  }

  /**
   * alterSplitFrame()の検証.
   * <p>
   *   条件：失敗_画面フレーム分割フラグ指定不正
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterSplitFrame_失敗_画面フレーム分割フラグ指定不正() throws Exception {

    // 事前準備
    Long userId = 900000000001L;
    int splitFrame = 2;
    AlterSplitFrameRequest request = new AlterSplitFrameRequest() {
      {
        setUserId(userId);
        setIsSplitFrame(splitFrame);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/split_frame")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.SPLIT_FRAME_INCORRECT.getMessage())))
      .andDo(document("user_settings/split_frame/bad-request1",
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
   * alterSplitFrame()の検証.
   * <p>
   *   条件：失敗_該当ユーザーなし
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterSplitFrame_失敗_該当ユーザーなし() throws Exception {

    // 事前準備
    Long userId = 900000000002L;
    int splitFrame = 0;
    AlterSplitFrameRequest request = new AlterSplitFrameRequest() {
      {
        setUserId(userId);
        setIsSplitFrame(splitFrame);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/split_frame")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody));

    // 検証
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage())))
      .andDo(document("user_settings/split_frame/bad-request2"));
  }
}
