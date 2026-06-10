package jp.co.nikkiso.ntss.admin_web.service;

import static java.util.Collections.emptyList;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.anyLong;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.UserSettingsResponse;
import jp.co.nikkiso.ntss.admin_web.service.userSettings.UserSettingsService;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * UserSettingsServiceImplのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class UserSettingsServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private UserSettingsService target;

  /**
   * 利用者マスタのMockBean.
   */
  @MockBean
  private MstUserDao mstUserDao;

  /**
   * 例外の発生をテストするためのルール
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * updateFontSize()の検証.
   *
   * 条件：指定されたフォントサイズが0
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateFontSize_正常_指定サイズが0() {

    // 事前準備
    MstUser.UserSettings settings = new MstUser.UserSettings();
    settings.setFontSize(3);
    MstUser testUser = new MstUser() {
      {
        setUserId(111L);
        setUserSettings(settings);
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateFontSize(111L, 0);

    // 検証
    verify(mstUserDao, times(1)).selectById(111L);
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getFontSize(), is(0));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateFontSize()の検証.
   *
   * 条件：指定されたフォントサイズが3
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateFontSize_正常_指定サイズが3() {

    // 事前準備
    MstUser testUser = new MstUser();

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateFontSize(anyLong(), 3);

    // 検証
    verify(mstUserDao, times(1)).selectById(anyLong());
    verify(mstUserDao, times(1)).updateUserSettings(any(MstUser.class));
    assertThat(testUser.getUserSettings().getFontSize(), is(3));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateFontSize()の検証.
   *
   * 条件：指定されたフォントサイズがマイナス値（範囲外）
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateFontSize_異常_指定サイズがマイナス値() {

    // 実行
    UserSettingsResponse result = target.updateFontSize(1L, -1);

    // 検証
    // Dao処理は呼ばれないこと
    verify(mstUserDao, times(0)).selectById(anyLong());
    verify(mstUserDao, times(0)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.FONT_SIZE_INCORRECT.getMessage()));

  }

  /**
   * updateFontSize()の検証.
   *
   * 条件：指定されたフォントサイズが4（範囲外）
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateFontSize_異常_指定サイズが4() {

    // 実行
    UserSettingsResponse result = target.updateFontSize(1L, 4);

    // 検証
    // Dao処理は呼ばれないこと
    verify(mstUserDao, times(0)).selectById(anyLong());
    verify(mstUserDao, times(0)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.FONT_SIZE_INCORRECT.getMessage()));

  }

  /**
   * updateFontSize()の検証.
   *
   * 条件：指定されたユーザーIDに紐づくデータなし
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateFontSize_異常_該当ユーザーなし(){

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(null);

    // 実行
    UserSettingsResponse result = target.updateFontSize(0L, 0);

    // 検証
    verify(mstUserDao, times(1)).selectById(0L);
    // 更新メソッドが呼ばれないこと
    verify(mstUserDao, times(0)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage()));

  }

  /**
   * updateFontSize()の検証.
   *
   * 条件：DB更新失敗
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateFontSize_異常_DB更新失敗() {

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(new MstUser());
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(0);

    // 実行
    UserSettingsResponse result = target.updateFontSize(222L, 3);

    // 検証
    verify(mstUserDao, times(1)).selectById(anyLong());
    verify(mstUserDao, times(1)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()));

  }

  /**
   * updateTheme()の検証.
   *
   * 条件：指定されたテーマが0
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateTheme_正常_指定テーマが0() {

    // 事前準備
    MstUser.UserSettings settings = new MstUser.UserSettings();
    settings.setTheme(1);
    MstUser testUser = new MstUser() {
      {
        setUserId(111L);
        setUserSettings(settings);
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateTheme(111L, 0);

    // 検証
    verify(mstUserDao, times(1)).selectById(111L);
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getTheme(), is(0));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateTheme()の検証.
   *
   * 条件：指定されたテーマが1
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateTheme_正常_指定テーマが1() {

    // 事前準備
    MstUser testUser = new MstUser();

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateTheme(anyLong(), 1);

    // 検証
    verify(mstUserDao, times(1)).selectById(anyLong());
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getTheme(), is(1));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateTheme()の検証.
   *
   * 条件：指定されたテーマがマイナス値（範囲外）
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateTheme_異常_指定テーマがマイナス値() {

    // 実行
    UserSettingsResponse result = target.updateTheme(1L, -1);

    // 検証
    // Dao処理は呼ばれないこと
    verify(mstUserDao, times(0)).selectById(anyLong());
    verify(mstUserDao, times(0)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.THEME_INCORRECT.getMessage()));

  }

  /**
   * updateTheme()の検証.
   *
   * 条件：指定されたテーマが2（範囲外）
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateTheme_異常_指定テーマが2() {

    // 実行
    UserSettingsResponse result = target.updateTheme(1L, 2);

    // 検証
    // Dao処理は呼ばれないこと
    verify(mstUserDao, times(0)).selectById(anyLong());
    verify(mstUserDao, times(0)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.THEME_INCORRECT.getMessage()));

  }

  /**
   * updateTheme()の検証.
   *
   * 条件：指定されたユーザーIDに紐づくデータなし
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateTheme_異常_該当ユーザーなし(){

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(null);

    // 実行
    UserSettingsResponse result = target.updateTheme(0L, 0);

    // 検証
    verify(mstUserDao, times(1)).selectById(0L);
    // 更新メソッドが呼ばれないこと
    verify(mstUserDao, times(0)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage()));

  }

  /**
   * updateTheme()の検証.
   *
   * 条件：DB更新失敗
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateTheme_異常_DB更新失敗() {

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(new MstUser());
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(0);

    // 実行
    UserSettingsResponse result = target.updateTheme(222L, 1);

    // 検証
    verify(mstUserDao, times(1)).selectById(anyLong());
    verify(mstUserDao, times(1)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()));

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：指定されたメニューバー表示フラグが0
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateMenuBar_正常_指定メニューバー表示フラグが0() {

    // 事前準備
    MstUser.UserSettings settings = new MstUser.UserSettings();
    settings.setIsDispMenu(1);
    MstUser testUser = new MstUser() {
      {
        setUserId(111L);
        setUserSettings(settings);
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(111L, 0, null, null);

    // 検証
    verify(mstUserDao, times(1)).selectById(111L);
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getIsDispMenu(), is(0));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：指定されたメニューバー表示フラグが1
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateMenuBar_正常_指定メニューバー表示フラグが1() {

    // 事前準備
    MstUser.UserSettings settings = new MstUser.UserSettings();
    settings.setIsDispMenu(0);
    MstUser testUser = new MstUser() {
      {
        setUserId(111L);
        setUserSettings(settings);
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(111L, 1, null, null);

    // 検証
    verify(mstUserDao, times(1)).selectById(111L);
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getIsDispMenu(), is(1));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：指定されたメニューバー表示フラグが2
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateMenuBar_異常_指定メニューバー表示フラグが2() {

    // 実行
    UserSettingsResponse result = target.updateMenuBar(1L, 2, null, null);

    // 検証
    // Dao処理は呼ばれないこと
    verify(mstUserDao, times(0)).selectById(anyLong());
    verify(mstUserDao, times(0)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.IS_DISP_MENU_INCORRECT.getMessage()));

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：指定されたユーザーIDに紐づくデータなし
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateMenuBar_異常_該当ユーザーなし(){

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(null);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(0L, 0, null, null);

    // 検証
    verify(mstUserDao, times(1)).selectById(0L);
    // 更新メソッドが呼ばれないこと
    verify(mstUserDao, times(0)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage()));

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：DB更新失敗
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateMenuBar_異常_DB更新失敗() {

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(new MstUser());
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(0);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(222L, 1, null, null);

    // 検証
    verify(mstUserDao, times(1)).selectById(anyLong());
    verify(mstUserDao, times(1)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()));

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：指定されたメニューバー表示フラグが001
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateUseFunctions_正常_指定使用機能コードが001のみ() {

    // 事前準備
    MstUser.UserSettings settings = new MstUser.UserSettings();
    settings.setIsDispMenu(1);
    settings.setUseFunctions(Arrays.asList("001"));
    MstUser testUser = new MstUser() {
      {
        setUserId(111L);
        setUserSettings(settings);
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(
      testUser.getUserId(), testUser.getUserSettings().getIsDispMenu(), testUser.getUserSettings().getUseFunctions(), null);

    // 検証
    verify(mstUserDao, times(1)).selectById(111L);
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getIsDispMenu(), is(1));
    assertThat(testUser.getUserSettings().getUseFunctions(), is(Arrays.asList("001")));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：指定された使用機能コードが複数指定された場合(002, 004)
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateUseFunctions_正常_指定使用機能コードが複数指定_002と004() {

    // 事前準備
    MstUser.UserSettings settings = new MstUser.UserSettings();
    settings.setIsDispMenu(1);
    settings.setUseFunctions(Arrays.asList("002", "004"));
    MstUser testUser = new MstUser() {
      {
        setUserId(111L);
        setUserSettings(settings);
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(
      testUser.getUserId(), testUser.getUserSettings().getIsDispMenu(), testUser.getUserSettings().getUseFunctions(), null);

    // 検証
    verify(mstUserDao, times(1)).selectById(111L);
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getIsDispMenu(), is(1));
    assertThat(testUser.getUserSettings().getUseFunctions(), is(Arrays.asList("002", "004")));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：指定された使用機能コードが指定なし
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateUseFunctions_正常_指定使用機能コードが指定なし() {

    // 事前準備
    MstUser.UserSettings settings = new MstUser.UserSettings();
    settings.setIsDispMenu(1);
    settings.setUseFunctions(null);
    MstUser testUser = new MstUser() {
      {
        setUserId(111L);
        setUserSettings(settings);
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(
      testUser.getUserId(), testUser.getUserSettings().getIsDispMenu(), testUser.getUserSettings().getUseFunctions(), null);

    // 検証
    verify(mstUserDao, times(1)).selectById(111L);
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getIsDispMenu(), is(1));
    assertThat(testUser.getUserSettings().getUseFunctions(), is(emptyList()));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：指定された使用機能コードが複数指定かつ重複した場合(001, 001, 003)
   * 結果：重複コードが除外された上で更新され、成功レスポンスが返却されること
   */
  @Test
  public void test_updateUseFunctions_正常_指定使用機能コードが複数指定かつ重複_001と001と003() {

    // 事前準備
    MstUser.UserSettings settings = new MstUser.UserSettings();
    settings.setIsDispMenu(1);
    settings.setUseFunctions(Arrays.asList("001", "001", "003"));
    MstUser testUser = new MstUser() {
      {
        setUserId(111L);
        setUserSettings(settings);
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(
      testUser.getUserId(), testUser.getUserSettings().getIsDispMenu(), testUser.getUserSettings().getUseFunctions(), null);

    // 検証
    verify(mstUserDao, times(1)).selectById(111L);
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getIsDispMenu(), is(1));
    assertThat(testUser.getUserSettings().getUseFunctions(), is(Arrays.asList("001", "003")));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：指定されたユーザーIDに紐づくデータなし
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateUseFunctions_異常_該当ユーザーなし(){

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(null);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(0L, 0, Arrays.asList("001"), null);

    // 検証
    verify(mstUserDao, times(1)).selectById(0L);
    // 更新メソッドが呼ばれないこと
    verify(mstUserDao, times(0)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage()));

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：DB更新失敗
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateUseFunctions_異常_DB更新失敗() {

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(new MstUser());
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(0);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(222L, 1, Arrays.asList("002"), null);

    // 検証
    verify(mstUserDao, times(1)).selectById(anyLong());
    verify(mstUserDao, times(1)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()));

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：指定された初期表示機能コードが001
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateInitialFunction_正常_初期表示機能コードが001() {

    // 事前準備
    final String initialFunction = "001";
    MstUser.UserSettings settings = new MstUser.UserSettings();
    settings.setIsDispMenu(1);
    settings.setInitialFunction("002");
    MstUser testUser = new MstUser() {
      {
        setUserId(111L);
        setUserSettings(settings);
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(
      testUser.getUserId(), testUser.getUserSettings().getIsDispMenu(), testUser.getUserSettings().getUseFunctions(), initialFunction);

    // 検証
    verify(mstUserDao, times(1)).selectById(111L);
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getInitialFunction(), is(initialFunction));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：指定された初期表示機能コードが004
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateInitialFunction_正常_初期表示機能コードが004() {

    // 事前準備
    final String initialFunction = "004";
    MstUser.UserSettings settings = new MstUser.UserSettings();
    settings.setIsDispMenu(1);
    settings.setInitialFunction("002");
    MstUser testUser = new MstUser() {
      {
        setUserId(111L);
        setUserSettings(settings);
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(
      testUser.getUserId(), testUser.getUserSettings().getIsDispMenu(), testUser.getUserSettings().getUseFunctions(), initialFunction);

    // 検証
    verify(mstUserDao, times(1)).selectById(111L);
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getInitialFunction(), is(initialFunction));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：指定された初期表示機能コードがnull
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateInitialFunction_正常_初期表示機能コードがnull() {

    // 事前準備
    final String initialFunction = "";
    MstUser.UserSettings settings = new MstUser.UserSettings();
    settings.setIsDispMenu(1);
    settings.setInitialFunction("002");
    MstUser testUser = new MstUser() {
      {
        setUserId(111L);
        setUserSettings(settings);
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(
      testUser.getUserId(), testUser.getUserSettings().getIsDispMenu(), null, null);

    // 検証
    verify(mstUserDao, times(1)).selectById(111L);
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getInitialFunction(), is(initialFunction));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：指定された初期表示機能コードが空文字列
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateInitialFunction_正常_初期表示機能コードが空文字列() {

    // 事前準備
    final String initialFunction = "";
    MstUser.UserSettings settings = new MstUser.UserSettings();
    settings.setIsDispMenu(1);
    settings.setInitialFunction("002");
    MstUser testUser = new MstUser() {
      {
        setUserId(111L);
        setUserSettings(settings);
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(
      testUser.getUserId(), testUser.getUserSettings().getIsDispMenu(), null, initialFunction);

    // 検証
    verify(mstUserDao, times(1)).selectById(111L);
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getInitialFunction(), is(initialFunction));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：指定されたユーザーIDに紐づくデータなし
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateInitialFunction_異常_該当ユーザーなし(){

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(null);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(0L, 0, Arrays.asList("001"), "001");

    // 検証
    verify(mstUserDao, times(1)).selectById(0L);
    // 更新メソッドが呼ばれないこと
    verify(mstUserDao, times(0)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage()));

  }

  /**
   * updateMenuBar()の検証.
   *
   * 条件：DB更新失敗
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateInitialFunction_異常_DB更新失敗() {

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(new MstUser());
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(0);

    // 実行
    UserSettingsResponse result = target.updateMenuBar(222L, 1, Arrays.asList("002"), "002");

    // 検証
    verify(mstUserDao, times(1)).selectById(anyLong());
    verify(mstUserDao, times(1)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()));

  }

  /**
   * getPersonalSettings()の検証
   *
   * 条件：指定されたユーザーIDが存在しない
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getPersonalSettings_対象ユーザの設定なし() {
    // 事前準備
    Long userId = 1L;
    Integer tabDefineCd = 2;

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(null);

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("");
    target.getPersonalSettings(userId, tabDefineCd);

    verify(mstUserDao, times(1)).selectById(userId);
  }

  /**
   * 指定のタブ定義コードの設定値を作成して返します.
   * @param tabDefineCd タブ定義コード
   * @return タブ定義設定値テストデータ
   */
  private MstUser.PersonalSetting createPersonalSetting(Integer tabDefineCd) {
    return new MstUser.PersonalSetting(){
      {
        setTabDefineCd(tabDefineCd);
        setValues(Arrays.asList(new MstUser.SettingValue() {
          {
            setSettingId("1");
            setSettingValue("val" + tabDefineCd.toString());
          }
        }, new MstUser.SettingValue() {
          {
            setSettingId("2");
            setSettingValue(tabDefineCd * 10 + 2);
          }
        }, new MstUser.SettingValue() {
          {
            setSettingId("3");
            setSettingValue(tabDefineCd * 10  + 0.34);
          }
        }));
      }
    };
  }

  /**
   * getPersonalSettings()の検証
   *
   * 条件：指定されたタブ定義コードが存在しない
   * 結果：０件の定義が取得されること
   */
  @Test
  public void test_getPersonalSettings_対象タブ定義コードなし() {
    // 事前準備
    Long userId = 1L;
    Integer tabDefineCd = 2;
    MstUser.PersonalSetting setting = createPersonalSetting(1);
    MstUser user = new MstUser();
    user.setUserSettings(new MstUser.UserSettings(){
      {
        List<MstUser.PersonalSetting> settings = new ArrayList<>();
        settings.add(setting);
        setPersonalSettings(settings);
      }
    });

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(user);

    // 実行
    // 検証
    List<MstUser.SettingValue> actual = target.getPersonalSettings(userId, tabDefineCd);

    verify(mstUserDao, times(1)).selectById(userId);
    assertThat(actual, is(notNullValue()));
    assertThat(actual.size(), is(0));
  }

  /**
   * getPersonalSettings()の検証
   *
   * 条件：指定されたタブ定義コードが存在する
   * 結果：定義が取得されること
   */
  @Test
  public void test_getPersonalSettings_対象定義あり() {
    // 事前準備
    Long userId = 1L;
    Integer tabDefineCd = 2;
    MstUser.PersonalSetting setting = createPersonalSetting(tabDefineCd);
    MstUser user = new MstUser();
    user.setUserSettings(new MstUser.UserSettings(){
      {
        List<MstUser.PersonalSetting> settings = new ArrayList<>();
        settings.add(setting);
        setPersonalSettings(settings);
      }
    });

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(user);

    // 実行
    // 検証
    List<MstUser.SettingValue> actual = target.getPersonalSettings(userId, tabDefineCd);

    verify(mstUserDao, times(1)).selectById(userId);
    assertThat(actual, is(notNullValue()));
    assertThat(actual.size(), is(3));
    assertThat(actual.get(0).getSettingId(), is(setting.getValues().get(0).getSettingId()));
    assertThat(actual.get(0).getSettingValue(), is(setting.getValues().get(0).getSettingValue()));
    assertThat(actual.get(1).getSettingId(), is(setting.getValues().get(1).getSettingId()));
    assertThat(actual.get(1).getSettingValue(), is(setting.getValues().get(1).getSettingValue()));
    assertThat(actual.get(2).getSettingId(), is(setting.getValues().get(2).getSettingId()));
    assertThat(actual.get(2).getSettingValue(), is(setting.getValues().get(2).getSettingValue()));
  }

  /**
   * updatePersonalSettings()の検証
   *
   * 条件：指定されたユーザーIDが存在しない
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_updatePersonalSettings_対象ユーザの設定なし() {
    // 事前準備
    Long userId = 1L;
    Integer tabDefineCd = 2;
    MstUser.PersonalSetting setting = createPersonalSetting(tabDefineCd);

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(null);

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("");
    target.updatePersonalSettings(userId, setting);

    verify(mstUserDao, times(1)).selectById(userId);
    verify(mstUserDao, never()).updateUserSettings(any());
  }

  /**
   * updatePersonalSettings()の検証
   *
   * 条件：指定されたタブ定義コードが存在しない
   * 結果：指定タブ定義に対して指定の設定値が追加されること
   */
  @Test
  public void test_updatePersonalSettings_対象タブ定義コードなし() {
    // 事前準備
    Long userId = 1L;
    Integer tabDefineCd = 2;
    MstUser.PersonalSetting setting = createPersonalSetting(tabDefineCd);

    // 更新前ユーザ設定
    MstUser user = new MstUser();
    MstUser.PersonalSetting beforeSetting = createPersonalSetting(1);
    user.setUserSettings(new MstUser.UserSettings(){
      {
        List<MstUser.PersonalSetting> settings = new ArrayList<>();
        settings.add(beforeSetting);
        setPersonalSettings(settings);
      }
    });
    // 更新後ユーザ設定
    final ArgumentCaptor<MstUser> userCaptor = ArgumentCaptor.forClass(MstUser.class);

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(user);

    // 実行
    // 検証
    boolean actual = target.updatePersonalSettings(userId, setting);

    verify(mstUserDao, times(1)).selectById(userId);
    verify(mstUserDao, times(1)).updateUserSettings(userCaptor.capture());
    final MstUser updatedUser = userCaptor.getValue();
    List<MstUser.PersonalSetting> updatedPersonalSetting = updatedUser.getUserSettings().getPersonalSettings();
    assertThat(updatedPersonalSetting, is(notNullValue()));
    assertThat(updatedPersonalSetting.size(), is(2));
    assertThat(updatedPersonalSetting.get(0).getTabDefineCd(), is(beforeSetting.getTabDefineCd()));
    assertThat(updatedPersonalSetting.get(0).getValues(), is(notNullValue()));
    assertThat(updatedPersonalSetting.get(0).getValues().size(), is(beforeSetting.getValues().size()));
    assertThat(updatedPersonalSetting.get(1).getTabDefineCd(), is(setting.getTabDefineCd()));
    assertThat(updatedPersonalSetting.get(1).getValues(), is(notNullValue()));
    assertThat(updatedPersonalSetting.get(1).getValues().size(), is(setting.getValues().size()));
    for(int i = 0; i < setting.getValues().size(); i++) {
      assertThat(updatedPersonalSetting.get(1).getValues().get(i).getSettingId(), is(setting.getValues().get(i).getSettingId()));
      assertThat(updatedPersonalSetting.get(1).getValues().get(i).getSettingValue(), is(setting.getValues().get(i).getSettingValue()));
    }
  }

  /**
   * updatePersonalSettings()の検証
   *
   * 条件：指定されたタブ定義コードが存在する
   * 結果：指定のタブ定義が指定の設定値で更新されること
   */
  @Test
  public void test_updatePersonalSettings_対象タブ定義コードあり() {
    // 事前準備
    Long userId = 1L;
    Integer tabDefineCd = 2;
    MstUser.PersonalSetting setting = createPersonalSetting(tabDefineCd);

    // 更新前ユーザ設定
    MstUser user = new MstUser();
    MstUser.PersonalSetting beforeSetting = createPersonalSetting(1);
    beforeSetting.setTabDefineCd(tabDefineCd); // 違う内容で作成してタブ定義コードを合わせる
    user.setUserSettings(new MstUser.UserSettings(){
      {
        List<MstUser.PersonalSetting> settings = new ArrayList<>();
        settings.add(beforeSetting);
        setPersonalSettings(settings);
      }
    });
    // 更新後ユーザ設定
    final ArgumentCaptor<MstUser> userCaptor = ArgumentCaptor.forClass(MstUser.class);

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(user);

    // 実行
    // 検証
    boolean actual = target.updatePersonalSettings(userId, setting);

    verify(mstUserDao, times(1)).selectById(userId);
    verify(mstUserDao, times(1)).updateUserSettings(userCaptor.capture());
    final MstUser updatedUser = userCaptor.getValue();
    List<MstUser.PersonalSetting> updatedPersonalSetting = updatedUser.getUserSettings().getPersonalSettings();
    assertThat(updatedPersonalSetting, is(notNullValue()));
    assertThat(updatedPersonalSetting.size(), is(1));
    assertThat(updatedPersonalSetting.get(0).getTabDefineCd(), is(setting.getTabDefineCd()));
    assertThat(updatedPersonalSetting.get(0).getValues(), is(notNullValue()));
    assertThat(updatedPersonalSetting.get(0).getValues().size(), is(setting.getValues().size()));
    for(int i = 0; i < setting.getValues().size(); i++) {
      assertThat(updatedPersonalSetting.get(0).getValues().get(i).getSettingId(), is(setting.getValues().get(i).getSettingId()));
      assertThat(updatedPersonalSetting.get(0).getValues().get(i).getSettingValue(), is(setting.getValues().get(i).getSettingValue()));
    }
  }

  /**
   * updateSplitFrame()の検証.
   *
   * 条件：指定された画面フレーム分割フラグが0
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateSplitFrame_正常_画面フレーム分割フラグが0() {

    // 事前準備
    MstUser.UserSettings settings = new MstUser.UserSettings();
    settings.setIsSplitFrame(1);
    MstUser testUser = new MstUser() {
      {
        setUserId(111L);
        setUserSettings(settings);
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateSplitFrame(111L, 0);

    // 検証
    verify(mstUserDao, times(1)).selectById(111L);
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getIsSplitFrame(), is(0));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateSplitFrame()の検証.
   *
   * 条件：指定された画面フレーム分割フラグが1
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateSplitFrame_正常_指定画面フレーム分割フラグが1() {

    // 事前準備
    MstUser testUser = new MstUser();

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(testUser);
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(1);

    // 実行
    UserSettingsResponse result = target.updateSplitFrame(anyLong(), 1);

    // 検証
    verify(mstUserDao, times(1)).selectById(anyLong());
    verify(mstUserDao, times(1)).updateUserSettings(testUser);
    assertThat(testUser.getUserSettings().getIsSplitFrame(), is(1));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, nullValue());

  }

  /**
   * updateSplitFrame()の検証.
   *
   * 条件：指定された画面フレーム分割フラグが2（範囲外）
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateSplitFrame_異常_指定画面フレーム分割フラグが2() {

    // 実行
    UserSettingsResponse result = target.updateSplitFrame(1L, 2);

    // 検証
    // Dao処理は呼ばれないこと
    verify(mstUserDao, times(0)).selectById(anyLong());
    verify(mstUserDao, times(0)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.SPLIT_FRAME_INCORRECT.getMessage()));

  }

  /**
   * updateSplitFrame()の検証.
   *
   * 条件：指定されたユーザーIDに紐づくデータなし
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateSplitFrame_異常_該当ユーザーなし(){

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(null);

    // 実行
    UserSettingsResponse result = target.updateSplitFrame(0L, 0);

    // 検証
    verify(mstUserDao, times(1)).selectById(0L);
    // 更新メソッドが呼ばれないこと
    verify(mstUserDao, times(0)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage()));

  }

  /**
   * updateSplitFrame()の検証.
   *
   * 条件：DB更新失敗
   * 結果：失敗レスポンスが返却されること
   */
  @Test
  public void test_updateSplitFrame_異常_DB更新失敗() {

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(new MstUser());
    given(mstUserDao.updateUserSettings(any(MstUser.class))).willReturn(0);

    // 実行
    UserSettingsResponse result = target.updateSplitFrame(222L, 1);

    // 検証
    verify(mstUserDao, times(1)).selectById(anyLong());
    verify(mstUserDao, times(1)).updateUserSettings(any(MstUser.class));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()));

  }
}
