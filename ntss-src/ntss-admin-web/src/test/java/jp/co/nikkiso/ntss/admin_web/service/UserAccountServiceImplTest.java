package jp.co.nikkiso.ntss.admin_web.service;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.hamcrest.core.IsNull.notNullValue;
import static org.junit.Assert.assertThat;
import static org.mockito.BDDMockito.any;
import static org.mockito.BDDMockito.anyLong;
import static org.mockito.BDDMockito.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Arrays;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.request.userAccount.UpdateUserAccountInfoRequest;
import jp.co.nikkiso.ntss.admin_web.response.userAccount.UserAccountResponse;
import jp.co.nikkiso.ntss.admin_web.service.userAccount.UserAccountService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.custom.UserAccountInfo;
import jp.co.nikkiso.ntss.core.exception.DataSourceInconsistencyException;

/**
 * UserAccountServiceImplのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class UserAccountServiceImplTest {

  // データソース間不整合のエラーメッセージ
  private static final String DATA_SOURCE_INCONSISTENCY_MESSAGE = DataSourceInconsistencyException.createMessage(0L, DataSourceName.AUTH, DataSourceName.PERSONAL);

  /**
   * テスト対象クラス.
   */
  @Autowired
  private UserAccountService target;

  /**
   * 例外.
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * 利用者マスタのMockBean.
   */
  @MockitoBean
  private MstUserDao mstUserDao;

  /**
   * 利用者マスタ(認証DB)DaoのMockBean.
   */
  @MockitoBean
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  /**
   * 利用者マスタ(個人情報DB)のMockBean.
   */
  @MockitoBean
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * パスワードエンコーダ.
   */
  @Autowired
  private PasswordEncoder passwordEncoder;

  /**
   * createUserAccountResponse()のテスト.
   *
   * 条件：該当ユーザーなし(3テーブル全て)
   * 結果：空のレスポンスが返却されること
   */
  @Test
  public void test_createUserAccountResponse_該当ユーザーなし_3テーブル全て() throws IOException {
    // 事前準備
    Long userId = 10L;

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(null);
    given(mstPersonalUserDao.selectById(anyLong())).willReturn(null);
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(null);

    // 実行
    UserAccountResponse result = target.createUserAccountResponse(userId);

    // 検証
    verify(mstUserDao, times(1)).selectById(userId);
    verify(mstPersonalUserDao, times(1)).selectById(userId);
    verify(mstUserAuthenticationDao, times(1)).selectById(userId);
    assertThat(result, notNullValue());
    assertThat(result.userAccountInfo, nullValue());
  }

  /**
   * createUserAccountResponse()のテスト.
   *
   * 条件：該当ユーザーなし(個人情報DBのみ存在)
   * 結果：空のレスポンスが返却されること
   */
  @Test
  public void test_createUserAccountResponse_該当ユーザーなし_個人情報DBのみ() throws IOException {
    // 事前準備
    Long userId = 10L;

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(null);
    given(mstPersonalUserDao.selectById(anyLong())).willReturn(new MstPersonalUser());
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(null);

    // 実行
    UserAccountResponse result = target.createUserAccountResponse(userId);

    // 検証
    verify(mstUserDao, times(1)).selectById(userId);
    verify(mstPersonalUserDao, times(1)).selectById(userId);
    verify(mstUserAuthenticationDao, times(1)).selectById(userId);
    assertThat(result, notNullValue());
    assertThat(result.userAccountInfo, nullValue());
  }

  /**
   * createUserAccountResponse()のテスト.
   *
   * 条件：該当ユーザーなし(個人情報DBと認証DBのみ存在)
   * 結果：空のレスポンスが返却されること
   */
  @Test
  public void test_createUserAccountResponse_該当ユーザーなし_個人情報DBと認証DBのみ() throws IOException {
    // 事前準備
    Long userId = 10L;

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(null);
    given(mstPersonalUserDao.selectById(anyLong())).willReturn(new MstPersonalUser());
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(new MstUserAuthentication());

    // 実行
    UserAccountResponse result = target.createUserAccountResponse(userId);

    // 検証
    verify(mstUserDao, times(1)).selectById(userId);
    verify(mstPersonalUserDao, times(1)).selectById(userId);
    verify(mstUserAuthenticationDao, times(1)).selectById(userId);
    assertThat(result, notNullValue());
    assertThat(result.userAccountInfo, nullValue());
  }

  /**
   * createUserAccountResponse()のテスト.
   *
   * 条件：該当ユーザーあり
   * 結果：アカウント情報が設定されたレスポンスが返却されること
   */
  @Test
  public void test_createUserAccountResponse_正常() throws IOException {
    // 事前準備
    Long userId = 10L;
    MstUser.UserSettings userSettings = new MstUser.UserSettings() {
      {
        setFontSize(2);
        setTheme(0);
        setIsDispMenu(1);
        setInitialFunction("001");
        setUseFunctions(Arrays.asList("001", "003", "005"));
      }
    };
    MstUser user = new MstUser() {
      {
        setUserId(userId);
        setIsProvisional(0);
        setUserSettings(userSettings);
        setRegPasswordDate(Timestamp.valueOf("2019-01-03 10:10:10"));
      }
    };
    MstPersonalUser personalUser = new MstPersonalUser() {
      {
        setUserId(userId);
        setFacilityCd("facilityCd");
        setUserType(1);
        setUserLastName("userLastName");
        setUserFirstName("userFirstName");
        setUserLastNameKana("userLastNameKana");
        setUserFirstNameKana("userFirstNameKana");
        setUserLastNameAlpha("userLastNameAlpha");
        setUserFirstNameAlpha("userFirstNameAlpha");
        setUserEmailAddress1("userEmailAddress1");
        setUserEmailAddress2("userEmailAddress2");
        setExtensionNo("extensionNo");
        setHomeNo("homeNo");
        setMobilePhoneNo("mobilePhoneNo");
        setFaxNo("faxNo");
        setZipcd3("zipcd3");
        setZipcd4("zipcd4");
        setAddress("address");
        setAddressKana("addressKana");
        setJobCd("jobCd");
        setUpDate(Timestamp.valueOf("2019-01-01 10:10:10"));
        setRegDate(Timestamp.valueOf("2019-01-02 10:10:10"));
      }
    };
    MstUserAuthentication userAuthentication = new MstUserAuthentication() {
      {
        setUserId(userId);
        setDispUserId("dispUserId");
      }
    };

    UserAccountInfo accountInfo = new UserAccountInfo(){
      {
        setUserId(userId);
        setFacilityCd("facilityCd");
        setUserType(1);
        setUserLastName("userLastName");
        setUserFirstName("userFirstName");
        setUserLastNameKana("userLastNameKana");
        setUserFirstNameKana("userFirstNameKana");
        setUserLastNameAlpha("userLastNameAlpha");
        setUserFirstNameAlpha("userFirstNameAlpha");
        setUserEmailAddress1("userEmailAddress1");
        setUserEmailAddress2("userEmailAddress2");
        setExtensionNo("extensionNo");
        setHomeNo("homeNo");
        setMobilePhoneNo("mobilePhoneNo");
        setFaxNo("faxNo");
        setZipcd3("zipcd3");
        setZipcd4("zipcd4");
        setAddress("address");
        setAddressKana("addressKana");
        setJobCd("jobCd");
        setUpDate(Timestamp.valueOf("2019-01-01 10:10:10"));
        setRegDate(Timestamp.valueOf("2019-01-02 10:10:10"));
        setIsProvisional(0);
        setUserSettings(userSettings);
        setDispUserId("dispUserId");
        setIsSetQrCode(0);
        setRegPasswordDate(Timestamp.valueOf("2019-01-03 10:10:10"));
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(user);
    given(mstPersonalUserDao.selectById(anyLong())).willReturn(personalUser);
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(userAuthentication);

    // 実行
    UserAccountResponse result = target.createUserAccountResponse(userId);

    // 検証
    verify(mstUserDao, times(1)).selectById(userId);
    verify(mstPersonalUserDao, times(1)).selectById(userId);
    verify(mstUserAuthenticationDao, times(1)).selectById(userId);
    assertThat(result, notNullValue());
    assertThat(result.userAccountInfo, is(accountInfo));
  }

  /**
   * updateUserAccountInfo()の検証.
   *
   * 条件：利用者マスタ(認証DB/個人情報DB)の更新件数０件
   * 結果：データソース間不整合例外が発生すること
   */
  @Test
  public void test_updateUserAccountInfo_更新失敗_該当ユーザなし() {
    // 事前準備
    expectedException.expect(DataSourceInconsistencyException.class);
    expectedException.expectMessage(DATA_SOURCE_INCONSISTENCY_MESSAGE);

    UpdateUserAccountInfoRequest request = new UpdateUserAccountInfoRequest() {
      {
        setUserId(1L);
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
    MstUserAuthentication auth = new MstUserAuthentication() {
      {
        setUserPassword("[{\"password: \"userPasswordHistory\"}]");
      }
    };
    // Mock化
    given(mstUserAuthenticationDao.updateDispUserIdAndUserPassword(any(MstUserAuthentication.class))).willReturn(0);
    given(mstPersonalUserDao.update(any(MstPersonalUser.class))).willReturn(0);
    given(mstUserDao.updateRegPasswordDate(anyLong())).willReturn(0);
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(auth);

    // 実行
    try {
      target.updateUserAccountInfo(request);

    } finally {
      // 検証
      verify(mstUserAuthenticationDao, times(1)).updateDispUserIdAndUserPassword(any(MstUserAuthentication.class));
      verify(mstPersonalUserDao, times(0)).update(any(MstPersonalUser.class));
      verify(mstUserDao, times(0)).updateRegPasswordDate(anyLong());
      verify(mstUserAuthenticationDao, times(1)).selectById(anyLong());
    }

  }

  /**
   * updateUserAccountInfo()の検証.
   *
   * 条件：利用者マスタ(認証DB)の更新件数0件
   * 結果：データソース間不整合例外が発生すること
   */
  @Test
  public void test_updateUserAccountInfo_更新失敗_認証DBのみ更新失敗() {
    // 事前準備
    expectedException.expect(DataSourceInconsistencyException.class);
    expectedException.expectMessage(DATA_SOURCE_INCONSISTENCY_MESSAGE);

    UpdateUserAccountInfoRequest request = new UpdateUserAccountInfoRequest() {
      {
        setUserId(1L);
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
    MstUserAuthentication auth = new MstUserAuthentication() {
      {
        setUserPassword("[{\"password: \"userPasswordHistory\"}]");
      }
    };
    // Mock化
    given(mstUserAuthenticationDao.updateDispUserIdAndUserPassword(any(MstUserAuthentication.class))).willReturn(0);
    given(mstPersonalUserDao.update(any(MstPersonalUser.class))).willReturn(1);
    given(mstUserDao.updateRegPasswordDate(anyLong())).willReturn(0);
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(auth);

    // 実行
    try {
      target.updateUserAccountInfo(request);

    } finally {
      // 検証
      verify(mstUserAuthenticationDao, times(1)).updateDispUserIdAndUserPassword(any(MstUserAuthentication.class));
      verify(mstPersonalUserDao, times(0)).update(any(MstPersonalUser.class));
      verify(mstUserDao, times(0)).updateRegPasswordDate(anyLong());
      verify(mstUserAuthenticationDao, times(1)).selectById(anyLong());
    }

  }

  /**
   * updateUserAccountInfo()の検証.
   *
   * 条件：利用者マスタ(個人情報DB)の更新件数0件
   * 結果：データソース間不整合例外が発生すること
   */
  @Test
  public void test_updateUserAccountInfo_更新失敗_個人情報DBのみ更新失敗() {
    // 事前準備
    expectedException.expect(DataSourceInconsistencyException.class);
    expectedException.expectMessage(DATA_SOURCE_INCONSISTENCY_MESSAGE);

    UpdateUserAccountInfoRequest request = new UpdateUserAccountInfoRequest() {
      {
        setUserId(1L);
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
    MstUserAuthentication auth = new MstUserAuthentication() {
      {
        setUserPassword("[{\"password: \"userPasswordHistory\"}]");
      }
    };
    // Mock化
    given(mstUserAuthenticationDao.updateDispUserIdAndUserPassword(any(MstUserAuthentication.class))).willReturn(1);
    given(mstPersonalUserDao.update(any(MstPersonalUser.class))).willReturn(0);
    given(mstUserDao.updateRegPasswordDate(anyLong())).willReturn(0);
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(auth);

    // 実行
    try {
      target.updateUserAccountInfo(request);

    } finally {
      // 検証
      verify(mstUserAuthenticationDao, times(1)).updateDispUserIdAndUserPassword(any(MstUserAuthentication.class));
      verify(mstPersonalUserDao, times(1)).update(any(MstPersonalUser.class));
      verify(mstUserDao, times(0)).updateRegPasswordDate(anyLong());
      verify(mstUserAuthenticationDao, times(1)).selectById(anyLong());
    }
  }

  /**
   * updateUserAccountInfo()のテスト.
   *
   * 条件：更新成功
   * 結果：正常終了すること
   */
  @Test
  public void test_updateUserAccountInfo_更新成功() {
    // 事前準備
    UpdateUserAccountInfoRequest request = new UpdateUserAccountInfoRequest() {
      {
        setUserId(1L);
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
    MstUserAuthentication auth = new MstUserAuthentication() {
      {
        setUserPassword("[{\"password: \"userPasswordHistory\"}]");
      }
    };
    ArgumentCaptor<MstUserAuthentication> argsUserAuthentication = ArgumentCaptor.forClass(MstUserAuthentication.class);
    ArgumentCaptor<MstPersonalUser> argsPersonalUser = ArgumentCaptor.forClass(MstPersonalUser.class);
    ArgumentCaptor<Long> argsLong1 = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<Long> argsLong2 = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(mstUserAuthenticationDao.updateDispUserIdAndUserPassword(argsUserAuthentication.capture())).willReturn(1);
    given(mstPersonalUserDao.update(argsPersonalUser.capture())).willReturn(1);
    given(mstUserDao.updateRegPasswordDate(argsLong1.capture())).willReturn(1);
    given(mstUserAuthenticationDao.selectById(argsLong2.capture())).willReturn(auth);

    // 実行
    target.updateUserAccountInfo(request);

    // 検証
    verify(mstUserAuthenticationDao, times(1)).updateDispUserIdAndUserPassword(any(MstUserAuthentication.class));
    verify(mstPersonalUserDao, times(1)).update(any(MstPersonalUser.class));
    verify(mstUserDao, times(1)).updateRegPasswordDate(anyLong());
    verify(mstUserAuthenticationDao, times(1)).selectById(anyLong());

    assertThat(argsUserAuthentication.getValue().getUserId(), is(1L));
    assertThat(argsUserAuthentication.getValue().getFacilityCd(), is("919191"));
    assertThat(argsUserAuthentication.getValue().getDispUserId(), is("999"));
    assertThat(passwordEncoder.matches("password", argsUserAuthentication.getValue().getUserPassword()), is(true));
    assertThat(argsUserAuthentication.getValue().getFailureCnt(), nullValue());
    assertThat(argsUserAuthentication.getValue().getRegDate(), nullValue());
    assertThat(argsUserAuthentication.getValue().getUpDate(), nullValue());

    assertThat(argsPersonalUser.getValue().getUserId(), is(1L));
    assertThat(argsPersonalUser.getValue().getFacilityCd(), is("919191"));
    assertThat(argsPersonalUser.getValue().getUserType(), nullValue());
    assertThat(argsPersonalUser.getValue().getUserLastName(), is("01"));
    assertThat(argsPersonalUser.getValue().getUserFirstName(), is("02"));
    assertThat(argsPersonalUser.getValue().getUserLastNameKana(), is("03"));
    assertThat(argsPersonalUser.getValue().getUserFirstNameKana(), is("04"));
    assertThat(argsPersonalUser.getValue().getUserLastNameAlpha(), is("05"));
    assertThat(argsPersonalUser.getValue().getUserFirstNameAlpha(), is("06"));
    assertThat(argsPersonalUser.getValue().getUserEmailAddress1(), is("07"));
    assertThat(argsPersonalUser.getValue().getUserEmailAddress2(), is("08"));
    assertThat(argsPersonalUser.getValue().getExtensionNo(), is("09"));
    assertThat(argsPersonalUser.getValue().getHomeNo(), is("10"));
    assertThat(argsPersonalUser.getValue().getMobilePhoneNo(), is("11"));
    assertThat(argsPersonalUser.getValue().getFaxNo(), is("12"));
    assertThat(argsPersonalUser.getValue().getZipcd3(), is("13"));
    assertThat(argsPersonalUser.getValue().getZipcd4(), is("14"));
    assertThat(argsPersonalUser.getValue().getAddress(), is("15"));
    assertThat(argsPersonalUser.getValue().getAddressKana(), is("16"));
    assertThat(argsPersonalUser.getValue().getJobCd(), is("17"));
    assertThat(argsPersonalUser.getValue().getRegDate(), nullValue());
    assertThat(argsPersonalUser.getValue().getUpDate(), nullValue());

    assertThat(argsLong1.getValue(), is(1L));
  }

  /**
   * updateUserAccountInfo()のテスト(パスワードがnull).
   *
   * 条件：更新成功
   * 結果：正常終了すること、パスワードが更新されないこと
   */
  @Test
  public void test_updateUserAccountInfo_更新成功_パスワードがnull() {
    // 事前準備
    UpdateUserAccountInfoRequest request = new UpdateUserAccountInfoRequest() {
      {
        setUserPassword(null);
      }
    };
    ArgumentCaptor<MstUserAuthentication> argsUserAuthentication = ArgumentCaptor.forClass(MstUserAuthentication.class);
    ArgumentCaptor<MstPersonalUser> argsPersonalUser = ArgumentCaptor.forClass(MstPersonalUser.class);
    ArgumentCaptor<Long> argsLong = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(mstUserAuthenticationDao.updateDispUserIdAndUserPassword(argsUserAuthentication.capture())).willReturn(1);
    given(mstPersonalUserDao.update(argsPersonalUser.capture())).willReturn(1);
    given(mstUserDao.updateRegPasswordDate(argsLong.capture())).willReturn(0);

    // 実行
    target.updateUserAccountInfo(request);

    // 検証
    verify(mstUserAuthenticationDao, times(1)).updateDispUserIdAndUserPassword(any(MstUserAuthentication.class));
    verify(mstPersonalUserDao, times(1)).update(any(MstPersonalUser.class));
    verify(mstUserDao, times(0)).updateRegPasswordDate(anyLong());

    assertThat(argsUserAuthentication.getValue().getUserPassword(), nullValue());
  }

  /**
   * updateUserAccountInfo()のテスト(パスワードが空文字列).
   *
   * 条件：更新成功
   * 結果：正常終了すること、パスワードが更新されないこと
   */
  @Test
  public void test_updateUserAccountInfo_更新成功_パスワードが空文字列() {
    // 事前準備
    UpdateUserAccountInfoRequest request = new UpdateUserAccountInfoRequest() {
      {
        setUserPassword(null);
      }
    };
    ArgumentCaptor<MstUserAuthentication> argsUserAuthentication = ArgumentCaptor.forClass(MstUserAuthentication.class);
    ArgumentCaptor<MstPersonalUser> argsPersonalUser = ArgumentCaptor.forClass(MstPersonalUser.class);
    ArgumentCaptor<Long> argsLong = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(mstUserAuthenticationDao.updateDispUserIdAndUserPassword(argsUserAuthentication.capture())).willReturn(1);
    given(mstPersonalUserDao.update(argsPersonalUser.capture())).willReturn(1);
    given(mstUserDao.updateRegPasswordDate(argsLong.capture())).willReturn(0);

    // 実行
    target.updateUserAccountInfo(request);

    // 検証
    verify(mstUserAuthenticationDao, times(1)).updateDispUserIdAndUserPassword(any(MstUserAuthentication.class));
    verify(mstPersonalUserDao, times(1)).update(any(MstPersonalUser.class));
    verify(mstUserDao, times(0)).updateRegPasswordDate(anyLong());

    assertThat(argsUserAuthentication.getValue().getUserPassword(), nullValue());
  }

  /**
   * selectDuplicateCount()のテスト.
   *
   * 条件：表示用ユーザーID重複なし
   * 結果：0件
   */
  @Test
  public void test_selectDuplicateCount_重複なし() {
    // 事前準備
    MstUserAuthentication signInUser = new MstUserAuthentication() {
      {
        setUserId(99L);
        setFacilityCd("000002");
        setDispUserId("userId2");
      }
    };

    MstUserAuthentication otherUser1 = new MstUserAuthentication() {
      {
        setUserId(1L);
        setFacilityCd("000001");
        setDispUserId("userId1");
      }
    };
    MstUserAuthentication otherUser2 = new MstUserAuthentication() {
      {
        setUserId(2L);
        setFacilityCd("000001");
        setDispUserId("userId2");
      }
    };
    MstUserAuthentication otherUser3 = new MstUserAuthentication() {
      {
        setUserId(3L);
        setFacilityCd("000002");
        setDispUserId("userId1");
      }
    };
    MstUserAuthentication otherUser4 = new MstUserAuthentication() {
      {
        setUserId(4L);
        setFacilityCd("000002");
        setDispUserId("userId3");
      }
    };
    ArgumentCaptor<Long> argsLong = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<String> argsString = ArgumentCaptor.forClass(String.class);

    // Mock化
    given(mstUserAuthenticationDao
      .selectById(argsLong.capture())).willReturn(signInUser);
    given(mstUserAuthenticationDao
      .selectDispUserId(argsString.capture(),any())).willReturn(Arrays.asList(otherUser1, otherUser2, otherUser3, signInUser, otherUser4));

    // 実行
    long result = target.selectDuplicateCount("userId2", 99L);

    // 検証
    verify(mstUserAuthenticationDao, times(1)).selectById(anyLong());
    verify(mstUserAuthenticationDao, times(1)).selectDispUserId(anyString(),any());
    assertThat(argsLong.getValue(), is(99L));
    assertThat(argsString.getValue(), is("userId2"));
    assertThat(result, is(0L));
  }

  /**
   * selectDuplicateCount()のテスト.
   *
   * 条件：表示用ユーザーID重複なし
   * 結果：重複した件数を返すこと
   */
  @Test
  public void test_selectDuplicateCount_重複あり() {
    // 事前準備
    MstUserAuthentication signInUser = new MstUserAuthentication() {
      {
        setUserId(99L);
        setFacilityCd("000002");
        setDispUserId("userId2");
      }
    };

    MstUserAuthentication otherUser1 = new MstUserAuthentication() {
      {
        setUserId(1L);
        setFacilityCd("000001");
        setDispUserId("userId1");
      }
    };
    MstUserAuthentication otherUser2 = new MstUserAuthentication() {
      {
        setUserId(2L);
        setFacilityCd("000001");
        setDispUserId("userId2");
      }
    };
    MstUserAuthentication otherUser3 = new MstUserAuthentication() {
      {
        setUserId(3L);
        setFacilityCd("000002");
        setDispUserId("userId2");
      }
    };
    MstUserAuthentication otherUser4 = new MstUserAuthentication() {
      {
        setUserId(4L);
        setFacilityCd("000002");
        setDispUserId("userId3");
      }
    };
    ArgumentCaptor<Long> argsLong = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<String> argsString = ArgumentCaptor.forClass(String.class);

    // Mock化
    given(mstUserAuthenticationDao
      .selectById(argsLong.capture())).willReturn(signInUser);
    given(mstUserAuthenticationDao
      .selectDispUserId(argsString.capture(),any())).willReturn(Arrays.asList(otherUser1, otherUser2, otherUser3, signInUser, otherUser4));

    // 実行
    long result = target.selectDuplicateCount("userId2", 99L);

    // 検証
    verify(mstUserAuthenticationDao, times(1)).selectById(anyLong());
    verify(mstUserAuthenticationDao, times(1)).selectDispUserId(anyString(),any());
    assertThat(argsLong.getValue(), is(99L));
    assertThat(argsString.getValue(), is("userId2"));
    assertThat(result, is(1L));
  }

}
