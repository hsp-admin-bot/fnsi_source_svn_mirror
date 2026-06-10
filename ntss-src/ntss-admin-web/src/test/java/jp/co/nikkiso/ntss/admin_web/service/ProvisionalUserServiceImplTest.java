package jp.co.nikkiso.ntss.admin_web.service;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.anyLong;
import static org.mockito.BDDMockito.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.never;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import java.util.ArrayList;
import java.util.Arrays;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.ProvisionalUserResponse;
import jp.co.nikkiso.ntss.admin_web.service.userAccount.ProvisionalUserService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.exception.DataSourceInconsistencyException;

/**
 * ProvisionalUserServiceImplのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class ProvisionalUserServiceImplTest {

  // データソース間不整合のエラーメッセージ
  private static final String DATA_SOURCE_INCONSISTENCY_MESSAGE = DataSourceInconsistencyException.createMessage(0L, DataSourceName.DEFAULT, DataSourceName.AUTH);

  /**
   * テスト対象.
   */
  @Autowired
  private ProvisionalUserService target;

  /**
   * 例外.
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * 利用者マスタDaoのMockBean.
   */
  @MockBean
  private MstUserDao mstUserDao;

  /**
   * 利用者マスタ(認証DB)DaoのMockBean.
   */
  @MockBean
  private MstUserAuthenticationDao mstUserAuthenticationDao;


  /**
   * 利用者マスタ(個人情報DB)DaoのMockBean.
   */
  @MockBean
  private MstPersonalUserDao mstPersonalUserDao;


  /**
   * パスワードエンコーダ.
   */
  @Autowired
  private PasswordEncoder passwordEncoder;

  @Test
  public void test_updateProvisionalUser_正常_重複チェックで表示用IDが同じレコードが存在しない() {
    MstUser mstUser = new MstUser() {
      {
        setUserId(1L);
      }
    };
    MstUserAuthentication mstUser2 = new MstUserAuthentication() {
      {
        setUserId(1L);
        setFacilityCd("000001");
        setDispUserId("userId1");
      }
    };

    MstPersonalUser updPersonalUser = new MstPersonalUser(){
      {
        setUserId(1L);
        setUserLastName("test");
        setUserFirstName("user");
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(mstUser);
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(mstUser2);
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(mstUser2);
    given(mstUserAuthenticationDao.selectDispUserId(anyString(),"000001")).willReturn(new ArrayList<>());
    given(mstUserDao.updateIsProvisional(any())).willReturn(1);
    given(mstUserDao.updateRegPasswordDate(anyLong())).willReturn(1);
    given(mstUserAuthenticationDao.updateDispUserIdAndUserPassword(any())).willReturn(1);
    given(mstPersonalUserDao.selectById(anyLong())).willReturn(updPersonalUser);
    given(mstUserDao.updateIsConsent(anyLong())).willReturn(1);
    given(mstPersonalUserDao.updateUserName(any())).willReturn(1);

    // 実行
    ProvisionalUserResponse result = target.updateProvisionalUser("previsional_001", "previsional_002", "pass12345", "001234", 1L,"test","user", true, true);

    // 検証
    verify(mstUserDao, times(1)).selectById(1L);
    verify(mstUserAuthenticationDao, times(3)).selectById(1L);
    verify(mstUserAuthenticationDao, times(1)).selectDispUserId("previsional_002","000001");
    verify(mstUserDao, times(1)).updateIsProvisional(mstUser);
    verify(mstUserAuthenticationDao, times(1)).updateDispUserIdAndUserPassword(mstUser2);
    verify(mstUserDao, times(1)).updateRegPasswordDate(1L);
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, is(nullValue()));
    assertThat(mstUser2.getDispUserId(), is("previsional_002"));
    assertThat(passwordEncoder.matches("pass12345", mstUser2.getUserPassword()), is(true));
  }

  @Test
  public void test_updateProvisionalUser_正常_重複チェックで同一ユーザーIDが返却() {
    // 事前準備
    Long userId = 900000000001L;
    String dispUserId = "800000000001";

    MstUser mstUser = new MstUser() {
      {
        setUserId(userId);
      }
    };
    MstUserAuthentication mstUser2 = new MstUserAuthentication() {
      {
        setDispUserId(dispUserId);
        setUserId(userId);
      }
    };
    MstPersonalUser updPersonalUser = new MstPersonalUser(){
      {
        setUserId(userId);
        setUserLastName("test");
        setUserFirstName("user");
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(mstUser);
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(mstUser2);
    given(mstUserAuthenticationDao.selectDispUserId(anyString(),"000001")).willReturn(Arrays.asList(mstUser2));
    given(mstUserDao.updateIsProvisional(any())).willReturn(1);
    given(mstUserDao.updateRegPasswordDate(anyLong())).willReturn(1);
    given(mstUserAuthenticationDao.updateDispUserIdAndUserPassword(any())).willReturn(1);
    given(mstPersonalUserDao.selectById(anyLong())).willReturn(updPersonalUser);
    given(mstUserDao.updateIsConsent(anyLong())).willReturn(1);
    given(mstPersonalUserDao.updateUserName(any())).willReturn(1);

    // 実行
    ProvisionalUserResponse result = target.updateProvisionalUser(dispUserId, "previsional_002", "pass12345", "001234", 1L,"test","user", true, true);

    // 検証
    verify(mstUserDao, times(1)).selectById(1L);
    verify(mstUserAuthenticationDao, times(1)).selectById(1L);
    verify(mstUserAuthenticationDao, times(1)).selectDispUserId("previsional_002","000001");
    verify(mstUserDao, times(1)).updateIsProvisional(mstUser);
    verify(mstUserAuthenticationDao, times(1)).updateDispUserIdAndUserPassword(mstUser2);
    verify(mstUserDao, times(1)).updateRegPasswordDate(userId);
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, is(nullValue()));
    assertThat(mstUser2.getDispUserId(), is("previsional_002"));
    assertThat(passwordEncoder.matches("pass12345", mstUser2.getUserPassword()), is(true));
  }

  @Test
  public void test_updateProvisionalUser_異常_指定したユーザのレコードが見つからない_医療DB() {
    // 事前準備
    expectedException.expect(DataSourceInconsistencyException.class);
    expectedException.expectMessage(DATA_SOURCE_INCONSISTENCY_MESSAGE);
    MstUserAuthentication userAuthentication = new MstUserAuthentication();
    MstPersonalUser personalUser = new MstPersonalUser();

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(null);
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(userAuthentication);
    given(mstPersonalUserDao.selectById(anyLong())).willReturn(personalUser);

    // 実行
    try {
      target.updateProvisionalUser("previsional_001", "previsional_002", "pass12345", "001234", 1L,"test","user", true, true);

    } finally {
      // 検証
      verify(mstUserDao, times(1)).selectById(1L);
      verify(mstUserAuthenticationDao, times(1)).selectById(1L);
      verify(mstPersonalUserDao,times(1)).selectById(1L);
      verify(mstUserAuthenticationDao, never()).selectDispUserId("previsional_002","000001");
    }
  }

  @Test
  public void test_updateProvisionalUser_異常_指定したユーザのレコードが見つからない_認証DB() {
    // 事前準備
    expectedException.expect(DataSourceInconsistencyException.class);
    expectedException.expectMessage(DATA_SOURCE_INCONSISTENCY_MESSAGE);
    MstUser mstUser = new MstUser();
    MstPersonalUser personalUser = new MstPersonalUser();

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(mstUser);
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(null);
    given(mstPersonalUserDao.selectById(anyLong())).willReturn(personalUser);

    // 実行
    try {
      target.updateProvisionalUser("previsional_001", "previsional_002", "pass12345", "001234", 1L,"test","user", true, true);

    } finally {
      // 検証
      verify(mstUserDao, times(1)).selectById(1L);
      verify(mstUserAuthenticationDao, times(1)).selectById(1L);
      verify(mstPersonalUserDao,times(1)).selectById(1L);
      verify(mstUserAuthenticationDao, never()).selectDispUserId("previsional_002","000001");
    }
  }

  @Test
  public void test_updateProvisionalUser_異常_指定したユーザのレコードが見つからない_個人情報DB() {
    // 事前準備
    expectedException.expect(DataSourceInconsistencyException.class);
    expectedException.expectMessage(DATA_SOURCE_INCONSISTENCY_MESSAGE);
    MstUser mstUser = new MstUser();
    MstUserAuthentication userAuthentication = new MstUserAuthentication();

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(mstUser);
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(userAuthentication);
    given(mstPersonalUserDao.selectById(anyLong())).willReturn(null);

    // 実行
    try {
      target.updateProvisionalUser("previsional_001", "previsional_002", "pass12345", "001234", 1L,"test","user", true, true);

    } finally {
      // 検証
      verify(mstUserDao, times(1)).selectById(1L);
      verify(mstUserAuthenticationDao, times(1)).selectById(1L);
      verify(mstPersonalUserDao,times(1)).selectById(1L);
      verify(mstUserAuthenticationDao, never()).selectDispUserId("previsional_002","000001");
    }
  }



  @Test
  public void test_updateProvisionalUser_異常_新規ユーザIDが重複している() {
    // 事前準備
    Long userId = 900000000001L;
    Long userId2 = 900000000002L;
    String dispUserId = "800000000001";

    MstUser mstUser = new MstUser() {
      {
        setUserId(userId);
      }
    };

    MstUserAuthentication mstUser2 = new MstUserAuthentication() {
      {
        setDispUserId(dispUserId);
        setUserId(userId);
        setFacilityCd("001234");
      }
    };
    MstUserAuthentication mstUser3 = new MstUserAuthentication() {
      {
        setDispUserId("previsional_002");
        setUserId(userId2);
        setFacilityCd("001234");
      }
    };

    MstPersonalUser updPersonalUser = new MstPersonalUser(){
      {
        setUserId(userId);
        setUserLastName("test");
        setUserFirstName("user");
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(mstUser);
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(mstUser2);
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(mstUser2);
    given(mstUserAuthenticationDao.selectDispUserId(anyString(),"000001")).willReturn(Arrays.asList(mstUser2, mstUser3));
    given(mstUserDao.updateIsProvisional(any())).willReturn(1);
    given(mstUserAuthenticationDao.updateDispUserIdAndUserPassword(any())).willReturn(1);
    given(mstPersonalUserDao.selectById(anyLong())).willReturn(updPersonalUser);
    given(mstUserDao.updateIsConsent(anyLong())).willReturn(1);
    given(mstPersonalUserDao.updateUserName(any())).willReturn(1);

    // 実行
    ProvisionalUserResponse result = target.updateProvisionalUser("previsional_001", "previsional_002", "pass12345", "001234", 1L,"test","user", true, true);

    // 検証
    verify(mstUserDao, times(1)).selectById(1L);
    verify(mstUserAuthenticationDao, times(1)).selectById(1L);
    verify(mstUserAuthenticationDao, times(1)).selectById(1L);
    verify(mstUserAuthenticationDao, times(1)).selectDispUserId("previsional_002","000001");
    verify(mstUserDao, never()).updateIsProvisional(mstUser);
    verify(mstUserAuthenticationDao, never()).updateDispUserIdAndUserPassword(mstUser2);
    verify(mstPersonalUserDao,never()).updateUserName(updPersonalUser);
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.USER_ID_EXISTED.getMessage()));
  }

  @Test
  public void test_updateProvisionalUser_異常_更新処理が失敗する_DB間結果相違() {
    // 事前準備
    expectedException.expect(DataSourceInconsistencyException.class);
    expectedException.expectMessage(DATA_SOURCE_INCONSISTENCY_MESSAGE);
    MstUser mstUser = new MstUser() {
      {
        setUserId(1L);
      }
    };
    MstUserAuthentication mstUser2 = new MstUserAuthentication() {
      {
        setUserId(1L);
        setFacilityCd("001234");
        setDispUserId("previsional_001");
      }
    };
    MstUserAuthentication mstUser3 = new MstUserAuthentication() {
      {
        setUserId(2L);
        setFacilityCd("001234");
        setDispUserId("previsional_999");
      }
    };

    MstPersonalUser updPersonalUser = new MstPersonalUser(){
      {
        setUserId(1L);
        setUserLastName("test");
        setUserFirstName("user");
      }
    };

    // Mock化
    given(mstUserDao.selectById(1L)).willReturn(mstUser);
    given(mstUserAuthenticationDao.selectById(1L)).willReturn(mstUser2);
    given(mstUserAuthenticationDao.selectDispUserId("previsional_002","000001")).willReturn(Arrays.asList(mstUser2, mstUser3));
    given(mstUserDao.updateIsProvisional(mstUser)).willReturn(0);
    given(mstUserAuthenticationDao.updateDispUserIdAndUserPassword(mstUser2)).willReturn(1);
    given(mstPersonalUserDao.selectById(anyLong())).willReturn(updPersonalUser);
    given(mstUserDao.updateIsConsent(anyLong())).willReturn(0);
    given(mstPersonalUserDao.updateUserName(any())).willReturn(0);

    // 実行
    try {
      target.updateProvisionalUser("previsional_001", "previsional_002", "pass12345", "001234", 1L, "test", "user", true, true);

    } finally {
      // 検証
      verify(mstUserDao, times(1)).selectById(1L);
      verify(mstUserAuthenticationDao, times(2)).selectById(1L);
      verify(mstUserAuthenticationDao, times(1)).selectDispUserId("previsional_002","000001");
      verify(mstUserDao, times(1)).updateIsProvisional(mstUser);
      verify(mstUserAuthenticationDao, times(0)).updateDispUserIdAndUserPassword(mstUser2);
      verify(mstPersonalUserDao,never()).updateUserName(updPersonalUser);
    }
  }

  @Test
  public void test_updateProvisionalUser_異常_更新処理が失敗する_両DBとも同じ異常値() {
    // 事前準備
    expectedException.expect(DataSourceInconsistencyException.class);
    expectedException.expectMessage(DATA_SOURCE_INCONSISTENCY_MESSAGE);
    MstUser mstUser = new MstUser() {
      {
        setUserId(1L);
      }
    };
    MstUserAuthentication mstUser2 = new MstUserAuthentication() {
      {
        setUserId(1L);
        setFacilityCd("001234");
        setDispUserId("previsional_001");
      }
    };
    MstUserAuthentication mstUser3 = new MstUserAuthentication() {
      {
        setUserId(2L);
        setFacilityCd("001234");
        setDispUserId("previsional_999");
      }
    };

    MstPersonalUser updPersonalUser = new MstPersonalUser(){
      {
        setUserId(1L);
        setUserLastName("test");
        setUserFirstName("user");
      }
    };

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(mstUser);
    given(mstUserAuthenticationDao.selectById(anyLong())).willReturn(mstUser2);
    given(mstUserAuthenticationDao.selectDispUserId(anyString(),"000001")).willReturn(Arrays.asList(mstUser2, mstUser3));
    given(mstUserDao.updateIsProvisional(any())).willReturn(0);
    given(mstUserAuthenticationDao.updateDispUserIdAndUserPassword(any())).willReturn(0);
    given(mstPersonalUserDao.selectById(anyLong())).willReturn(updPersonalUser);
    given(mstUserDao.updateIsConsent(anyLong())).willReturn(0);
    given(mstPersonalUserDao.updateUserName(any())).willReturn(0);


    // 実行
    try {
      target.updateProvisionalUser("previsional_001", "previsional_002", "pass12345", "001234", 1L, "test","user", true, true);

    } finally {
      // 検証
      verify(mstUserDao, times(1)).selectById(1L);
      verify(mstUserAuthenticationDao, times(2)).selectById(1L);
      verify(mstUserAuthenticationDao, times(1)).selectDispUserId("previsional_002","000001");
      verify(mstUserDao, times(1)).updateIsProvisional(mstUser);
      verify(mstUserAuthenticationDao, times(0)).updateDispUserIdAndUserPassword(mstUser2);
      verify(mstPersonalUserDao,never()).updateUserName(updPersonalUser);
    }
  }

}
