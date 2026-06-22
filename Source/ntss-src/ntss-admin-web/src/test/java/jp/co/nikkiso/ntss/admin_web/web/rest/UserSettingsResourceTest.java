package jp.co.nikkiso.ntss.admin_web.web.rest;

import static java.util.Collections.emptyList;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.empty;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Arrays;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.request.userSettings.AlterSplitFrameRequest;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import org.hamcrest.Matchers;
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

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.request.userSettings.AlterFontSizeRequest;
import jp.co.nikkiso.ntss.admin_web.request.userSettings.AlterMenuBarRequest;
import jp.co.nikkiso.ntss.admin_web.request.userSettings.AlterThemeRequest;
import jp.co.nikkiso.ntss.admin_web.response.UserSettingsResponse;
import jp.co.nikkiso.ntss.admin_web.service.userSettings.UserSettingsService;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

/**
 * UserSettingsResourceのテストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
public class UserSettingsResourceTest extends AbstractResourceTest {

  /**
   * ユーザ設定Service.
   */
  @MockitoBean
  private UserSettingsService userSettingsService;

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

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

    AlterFontSizeRequest request = new AlterFontSizeRequest() {
      {
        setUserId(900000000001L);
        setFontSize(3);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateFontSize(anyLong(), anyInt()))
      .willReturn(new UserSettingsResponse());

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/font_size")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateFontSize(900000000001L, 3);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.isSuccess", is(true)))
      .andExpect(jsonPath("$.errorMessage", nullValue()));
  }

  /**
   * alterFontSize()の検証.
   * <p>
   *   条件：該当ユーザIDなし
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterFontSize_失敗_該当ユーザIDなし() throws Exception {

    AlterFontSizeRequest request = new AlterFontSizeRequest() {
      {
        setUserId(900000000001L);
        setFontSize(3);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateFontSize(anyLong(), anyInt()))
      .willReturn(new UserSettingsResponse(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/font_size")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateFontSize(900000000001L, 3);
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage())));
  }

  /**
   * alterFontSize()の検証.
   * <p>
   *   条件：文字サイズ指定が不正
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterFontSize_失敗_文字サイズ指定不正() throws Exception {

    AlterFontSizeRequest request = new AlterFontSizeRequest() {
      {
        setUserId(900000000001L);
        setFontSize(6);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateFontSize(anyLong(), anyInt()))
      .willReturn(new UserSettingsResponse(AdminWebMessage.Error.FONT_SIZE_INCORRECT.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/font_size")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateFontSize(900000000001L, 6);
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.FONT_SIZE_INCORRECT.getMessage())));
  }

  /**
   * alterFontSize()の検証.
   * <p>
   *   条件：DB更新失敗
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_alterFontSize_失敗_DB更新失敗() throws Exception {

    AlterFontSizeRequest request = new AlterFontSizeRequest() {
      {
        setUserId(900000000001L);
        setFontSize(3);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateFontSize(anyLong(), anyInt()))
      .willReturn(new UserSettingsResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/font_size")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateFontSize(900000000001L, 3);
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage())));
  }

  /**
   * alterTheme()の検証.
   * <p>
   *   条件：成功
   *   結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  public void test_alterTheme_成功() throws Exception {

    AlterThemeRequest request = new AlterThemeRequest() {
      {
        setUserId(900000000001L);
        setTheme(0);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateTheme(anyLong(), anyInt()))
      .willReturn(new UserSettingsResponse());

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/theme")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateTheme(900000000001L, 0);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.isSuccess", is(true)))
      .andExpect(jsonPath("$.errorMessage", nullValue()));
  }

  /**
   * alterTheme()の検証.
   * <p>
   *   条件：該当ユーザIDなし
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_alterTheme_失敗_該当ユーザIDなし() throws Exception {

    AlterThemeRequest request = new AlterThemeRequest() {
      {
        setUserId(900000000001L);
        setTheme(1);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateTheme(anyLong(), anyInt()))
      .willReturn(new UserSettingsResponse(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/theme")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateTheme(900000000001L, 1);
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage())));
  }

  /**
   * alterTheme()の検証.
   * <p>
   *   条件：テーマの指定が不正
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_alterTheme_失敗_テーマ指定不正() throws Exception {

    AlterThemeRequest request = new AlterThemeRequest() {
      {
        setUserId(900000000001L);
        setTheme(3);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateTheme(anyLong(), anyInt()))
      .willReturn(new UserSettingsResponse(AdminWebMessage.Error.THEME_INCORRECT.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/theme")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateTheme(900000000001L, 3);
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.THEME_INCORRECT.getMessage())));
  }

  /**
   * alterTheme()の検証.
   * <p>
   *   条件：DB更新失敗
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_alterTheme_失敗_DB更新失敗() throws Exception {

    AlterThemeRequest request = new AlterThemeRequest() {
      {
        setUserId(900000000001L);
        setTheme(0);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateTheme(anyLong(), anyInt()))
      .willReturn(new UserSettingsResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/theme")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateTheme(900000000001L, 0);
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage())));
  }

  /**
   * alterMenuBar()の検証.
   * <p>
   *   条件：成功
   *   結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  public void test_alterMenuBar_成功() throws Exception {

    Long userId = 900000000001L;
    Integer isDispMenu = 0;
    List<String> useFunctions = Arrays.asList("function1", "function2", "function3");
    String initialFunction = "function1";
    AlterMenuBarRequest request = new AlterMenuBarRequest() {
      {
        setUserId(userId);
        setIsDispMenu(isDispMenu);
        setUseFunctions(useFunctions);
        setInitialFunction(initialFunction);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateMenuBar(anyLong(), anyInt(), anyList(), anyString()))
      .willReturn(new UserSettingsResponse());

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/menu_bar")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateMenuBar(userId, isDispMenu, useFunctions, initialFunction);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.isSuccess", is(true)))
      .andExpect(jsonPath("$.errorMessage", nullValue()));
  }

  /**
   * alterMenuBar()の検証.
   * <p>
   *   条件：該当ユーザIDなし
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_alterMenuBar_失敗_該当ユーザIDなし() throws Exception {

    Long userId = 900000000001L;
    Integer isDispMenu = 1;
    List<String> useFunctions = Arrays.asList("function3", "function1", "function2");
    String initialFunction = "function3";
    AlterMenuBarRequest request = new AlterMenuBarRequest() {
      {
        setUserId(userId);
        setIsDispMenu(isDispMenu);
        setUseFunctions(useFunctions);
        setInitialFunction(initialFunction);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateMenuBar(anyLong(), anyInt(), anyList(), anyString()))
      .willReturn(new UserSettingsResponse(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/menu_bar")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateMenuBar(userId, isDispMenu, useFunctions, initialFunction);
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage())));
  }

  /**
   * alterMenuBar()の検証.
   * <p>
   *   条件：メニュー表示フラグ指定不正
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_alterMenuBar_失敗_メニュー表示フラグ指定不正() throws Exception {

    Long userId = 900000000001L;
    Integer isDispMenu = 1;
    List<String> useFunctions = Arrays.asList("function3", "function1", "function2");
    String initialFunction = "function3";
    AlterMenuBarRequest request = new AlterMenuBarRequest() {
      {
        setUserId(userId);
        setIsDispMenu(isDispMenu);
        setUseFunctions(useFunctions);
        setInitialFunction(initialFunction);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateMenuBar(anyLong(), anyInt(), anyList(), anyString()))
      .willReturn(new UserSettingsResponse(AdminWebMessage.Error.IS_DISP_MENU_INCORRECT.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/menu_bar")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateMenuBar(userId, isDispMenu, useFunctions, initialFunction);
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.IS_DISP_MENU_INCORRECT.getMessage())));
  }

  /**
   * alterMenuBar()の検証.
   * <p>
   *   条件：使用機能コード指定不正
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_alterMenuBar_失敗_使用機能コード指定不正() throws Exception {

    Long userId = 900000000001L;
    Integer isDispMenu = 1;
    List<String> useFunctions = Arrays.asList("function3", "function1", "function2");
    String initialFunction = "function3";
    AlterMenuBarRequest request = new AlterMenuBarRequest() {
      {
        setUserId(userId);
        setIsDispMenu(isDispMenu);
        setUseFunctions(useFunctions);
        setInitialFunction(initialFunction);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateMenuBar(anyLong(), anyInt(), anyList(), anyString()))
      .willReturn(new UserSettingsResponse(AdminWebMessage.Error.USE_FUNCTION_INCORRECT.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/menu_bar")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateMenuBar(userId, isDispMenu, useFunctions, initialFunction);
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USE_FUNCTION_INCORRECT.getMessage())));
  }

  /**
   * alterMenuBar()の検証.
   * <p>
   *   条件：初期表示機能コード指定不正
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_alterMenuBar_失敗_初期表示機能コード指定不正() throws Exception {

    Long userId = 900000000001L;
    Integer isDispMenu = 1;
    List<String> useFunctions = Arrays.asList("function3", "function1", "function2");
    String initialFunction = "function3";
    AlterMenuBarRequest request = new AlterMenuBarRequest() {
      {
        setUserId(userId);
        setIsDispMenu(isDispMenu);
        setUseFunctions(useFunctions);
        setInitialFunction(initialFunction);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateMenuBar(anyLong(), anyInt(), anyList(), anyString()))
      .willReturn(new UserSettingsResponse(AdminWebMessage.Error.INITIAL_FUNCTION_INCORRECT.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/menu_bar")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateMenuBar(userId, isDispMenu, useFunctions, initialFunction);
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.INITIAL_FUNCTION_INCORRECT.getMessage())));
  }

  /**
   * alterMenuBar()の検証.
   * <p>
   *   条件：DB更新失敗
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_alterMenuBar_失敗_DB更新失敗() throws Exception {

    Long userId = 900000000001L;
    Integer isDispMenu = 1;
    List<String> useFunctions = Arrays.asList("function3", "function1", "function2");
    String initialFunction = "function3";
    AlterMenuBarRequest request = new AlterMenuBarRequest() {
      {
        setUserId(userId);
        setIsDispMenu(isDispMenu);
        setUseFunctions(useFunctions);
        setInitialFunction(initialFunction);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateMenuBar(anyLong(), anyInt(), anyList(), anyString()))
      .willReturn(new UserSettingsResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/menu_bar")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateMenuBar(userId, isDispMenu, useFunctions, initialFunction);
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage())));
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
   * getPersonalSettings()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   * @throws Exception
   */
  @Test
  @NtssMockUser(userId = 1L)
  public void test_getPersonalSettings_成功() throws Exception {
    // 事前準備
    Long userId = 1L;
    Integer tabDeifineCd = 2;
    List<MstUser.SettingValue> settingsValues = createSettingValue();

    // Mock化
    given(userSettingsService.getPersonalSettings(userId, tabDeifineCd)).willReturn(settingsValues);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/user_settings/personal_settings/{tab_define_cd}", tabDeifineCd)
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(userSettingsService, times(1)).getPersonalSettings(userId, tabDeifineCd);
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$", hasSize(settingsValues.size())))
      .andExpect(jsonPath("$[0].setting_identifier", Matchers.is(settingsValues.get(0).getSettingId())))
      .andExpect(jsonPath("$[0].value", Matchers.is(settingsValues.get(0).getSettingValue())))
      .andExpect(jsonPath("$[1].setting_identifier", Matchers.is(settingsValues.get(1).getSettingId())))
      .andExpect(jsonPath("$[1].value", Matchers.is(settingsValues.get(1).getSettingValue())))
      .andExpect(jsonPath("$[2].setting_identifier", Matchers.is(settingsValues.get(2).getSettingId())))
      .andExpect(jsonPath("$[2].value", Matchers.is(settingsValues.get(2).getSettingValue())))
      .andExpect(jsonPath("$[3].setting_identifier", Matchers.is(settingsValues.get(3).getSettingId())))
      .andExpect(jsonPath("$[3].value", Matchers.is(settingsValues.get(3).getSettingValue())))
      .andExpect(jsonPath("$[4].setting_identifier", Matchers.is(settingsValues.get(4).getSettingId())))
      .andExpect(jsonPath("$[4].value", Matchers.is(settingsValues.get(4).getSettingValue())))
    ;
  }

  /**
   * getPersonalSettings()の検証.
   * <p>
   * 条件：成功（データなし） 結果：成功レスポンスが返されること
   * </p>
   * @throws Exception
   */
  @Test
  @NtssMockUser(userId = 1L)
  public void test_getPersonalSettings_成功_データなし() throws Exception {
    // 事前準備
    Long userId = 1L;
    Integer tabDeifineCd = 2;
    List<MstUser.SettingValue> settingsValues = emptyList();

    // Mock化
    given(userSettingsService.getPersonalSettings(userId, tabDeifineCd)).willReturn(settingsValues);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/user_settings/personal_settings/{tab_define_cd}", tabDeifineCd)
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(userSettingsService, times(1)).getPersonalSettings(userId, tabDeifineCd);
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$", empty()))
    ;
  }

  /**
   * updatePersonalSettings()の検証.
   * <p>
   * 条件：成功
   * 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(userId = 1L)
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

    ArgumentCaptor<MstUser.PersonalSetting> settingCaptor = ArgumentCaptor.forClass(MstUser.PersonalSetting.class);

    // Mock化
    given(userSettingsService.updatePersonalSettings(anyLong(), settingCaptor.capture())).willReturn(true);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/user_settings/personal_settings")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updatePersonalSettings(anyLong(), any());
    result
      .andExpect(status().isOk());
    assertThat(settingCaptor.getValue(), is(notNullValue()));
    for (int i = 0; i < values.size(); i++) {
      assertThat(settingCaptor.getValue().getValues().get(i).getSettingId(), is(values.get(i).getSettingId()));
      assertThat(settingCaptor.getValue().getValues().get(i).getSettingValue(), is(values.get(i).getSettingValue()));
    }
  }

  /**
   * updatePersonalSettings()の検証.
   * <p>
   * 条件：ユーザーIDに該当する利用者マスタが存在しない
   * 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(userId = 1L)
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

    // Mock化
    given(userSettingsService.updatePersonalSettings(anyLong(), any())).willThrow(new NotExistException(""));

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/user_settings/personal_settings")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updatePersonalSettings(anyLong(), any());
    result
      .andExpect(status().isInternalServerError());
  }

  /**
   * alterSplitFrame()の検証.
   * <p>
   *   条件：成功
   *   結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  public void test_alterSplitFrame_成功() throws Exception {

    AlterSplitFrameRequest request = new AlterSplitFrameRequest() {
      {
        setUserId(900000000001L);
        setIsSplitFrame(0);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateSplitFrame(anyLong(), anyInt()))
      .willReturn(new UserSettingsResponse());

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/split_frame")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateSplitFrame(900000000001L, 0);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.isSuccess", is(true)))
      .andExpect(jsonPath("$.errorMessage", nullValue()));
  }

  /**
   * alterSplitFrame()の検証.
   * <p>
   *   条件：該当ユーザIDなし
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_alterSplitFrame_失敗_該当ユーザIDなし() throws Exception {

    AlterSplitFrameRequest request = new AlterSplitFrameRequest() {
      {
        setUserId(900000000001L);
        setIsSplitFrame(1);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateSplitFrame(anyLong(), anyInt()))
      .willReturn(new UserSettingsResponse(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/split_frame")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateSplitFrame(900000000001L, 1);
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage())));
  }

  /**
   * alterSplitFrame()の検証.
   * <p>
   *   条件：画面フレーム分割フラグの指定が不正
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_alterSplitFrame_失敗_画面フレーム分割フラグ指定不正() throws Exception {

    AlterSplitFrameRequest request = new AlterSplitFrameRequest() {
      {
        setUserId(900000000001L);
        setIsSplitFrame(3);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateSplitFrame(anyLong(), anyInt()))
      .willReturn(new UserSettingsResponse(AdminWebMessage.Error.SPLIT_FRAME_INCORRECT.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/split_frame")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateSplitFrame(900000000001L, 3);
    result.andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.SPLIT_FRAME_INCORRECT.getMessage())));
  }

  /**
   * alterSplitFrame()の検証.
   * <p>
   *   条件：DB更新失敗
   *   結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  public void test_alterSplitFrame_失敗_DB更新失敗() throws Exception {

    AlterSplitFrameRequest request = new AlterSplitFrameRequest() {
      {
        setUserId(900000000001L);
        setIsSplitFrame(0);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(userSettingsService.updateSplitFrame(anyLong(), anyInt()))
      .willReturn(new UserSettingsResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()));

    // API実行
    ResultActions result = mockMvc.perform(put("/api/user_settings/split_frame")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userSettingsService, times(1)).updateSplitFrame(900000000001L, 0);
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage())));
  }
}
