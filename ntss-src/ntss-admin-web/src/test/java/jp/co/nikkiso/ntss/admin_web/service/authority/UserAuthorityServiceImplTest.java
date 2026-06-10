package jp.co.nikkiso.ntss.admin_web.service.authority;

import jp.co.nikkiso.ntss.core.dao.MstUserDao;
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
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.test.context.junit4.SpringRunner;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.List;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.samePropertyValuesAs;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

/**
 * {@link UserAuthorityServiceImpl}のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class UserAuthorityServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private UserAuthorityService target;

  /**
   * 利用者マスタのMockBean.
   */
  @MockBean
  private MstUserDao mstUserDao;

  /**
   * 例外の発生をテストするためのルール.
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * getMstUser(privateメソッド)をinvokeする.
   *
   * @param userId ユーザーID
   * @return 利用者マスタエンティティ
   * @throws Throwable
   */
  private MstUser invokeGetMstUser(Long userId) throws Throwable {
    try {
      Method method = UserAuthorityServiceImpl.class.getDeclaredMethod("getMstUser", Long.class);
      method.setAccessible(true);
      return (MstUser) method.invoke(target, userId);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    }
    return null;
  }

  /**
   * getMstUser()の検証.
   *
   * 条件：指定されたユーザーIDに該当する利用者マスタが存在する
   * 結果：利用者マスタエンティティが返却されること
   */
  @Test
  public void test_getMstUser_成功_データあり() throws Throwable {
    // 事前準備
    Long userId = 12345L;
    MstUser expected = new MstUser();

    // Mock化
    given(mstUserDao.selectById(userId)).willReturn(expected);

    // 実行
    MstUser result = invokeGetMstUser(userId);

    // 検証
    verify(mstUserDao, times(1)).selectById(userId);
    assertThat(result, is(expected));
  }

  /**
   * getMstUser()の検証.
   *
   * 条件：指定されたユーザーIDに該当する利用者マスタが存在しない
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getMstUser_異常_データなし() throws Throwable {
    // 事前準備
    Long userId = 99999L;

    // Mock化
    given(mstUserDao.selectById(userId)).willThrow(EmptyResultDataAccessException.class);

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("");
    invokeGetMstUser(userId);
  }

  /**
   * getAuthorizedAuthorities()の検証.
   *
   * 条件：指定されたユーザーIDに該当する利用者マスタが存在する
   * 結果：許可権限のリストが返却されること
   */
  @Test
  public void test_getAuthorizedAuthorities_正常_取得() {
    // 事前準備
    Long userId = 10L;
    List<String> expected = Arrays.asList("011", "012", "013");
    MstUser mstUser = new MstUser() {
      {
        setUserSettings(new MstUser.UserSettings() {
          {
            setAuthorizedAuthorities(expected);
          }
        });
      }
    };

    // Mock化
    given(mstUserDao.selectById(userId)).willReturn(mstUser);

    // 実行
    List<String> result = target.getAuthorizedAuthorities(userId);

    // 検証
    verify(mstUserDao, times(1)).selectById(userId);
    assertThat(result, hasSize(3));
    assertThat(result.get(0), is(expected.get(0)));
    assertThat(result.get(1), is(expected.get(1)));
    assertThat(result.get(2), is(expected.get(2)));
  }

  /**
   * getAuthorizedAuthorities()の検証.
   *
   * 条件：指定されたユーザーIDに該当する利用者マスタが存在しない
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getAuthorizedAuthorities_異常_該当データなし() {
    // 事前準備
    Long userId = 12L;

    // Mock化
    given(mstUserDao.selectById(userId)).willThrow(EmptyResultDataAccessException.class);

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("");
    target.getAuthorizedAuthorities(userId);
  }

  /**
   * updateAuthorizedAuthorities()の検証.
   *
   * 条件：利用者マスタに存在するユーザーIDをもつレコードを指定する
   * 結果：ユーザー設定（利用者マスタ）の更新ができること
   */
  @Test
  public void test_updateAuthorizedAuthorities_成功_ユーザー情報の更新ができること() {
    // 事前準備
    final Long userId = 12345L;
    final List<String> authorities = Arrays.asList("001", "002", "003");
    final Boolean signoutFlg = false;

    final MstUser beUpdatedMstUser = new MstUser() {
      {
        setUserId(userId);
        setUserSettings(new UserSettings("{\"theme\": 0, \"authorized_authorities\": [\"000\"]}"));
        setIsProvisional(0);
        setIsDisp("1");
        setIsDel("2");
      }
    };
    final MstUser.UserSettings beUpdatedUserSettings = new MstUser.UserSettings("{\"theme\": 0, \"authorized_authorities\": [\"001\", \"002\", \"003\"]}");

    final ArgumentCaptor<Long> userIdCaptor = ArgumentCaptor.forClass(Long.class);
    given(mstUserDao.selectById(userIdCaptor.capture())).willReturn(beUpdatedMstUser);

    final ArgumentCaptor<MstUser> updateCaptor = ArgumentCaptor.forClass(MstUser.class);
    given(mstUserDao.updateUserSettings(updateCaptor.capture())).willReturn(1);

    // 実行
    target.updateAuthorizedAuthorities(userId, authorities, signoutFlg);

    // 検証
    final Long updatedUserId = userIdCaptor.getValue();
    assertThat(updatedUserId, is(userId));
    final MstUser updatedMstUser = updateCaptor.getValue();
    assertThat(updatedMstUser.getUserId(), is(beUpdatedMstUser.getUserId()));
    assertThat(updatedMstUser.getUserSettings(), is(samePropertyValuesAs(beUpdatedUserSettings)));
    assertThat(updatedMstUser.getIsProvisional(), is(beUpdatedMstUser.getIsProvisional()));
    assertThat(updatedMstUser.getIsDisp(), is(beUpdatedMstUser.getIsDisp()));
    assertThat(updatedMstUser.getIsDel(), is(beUpdatedMstUser.getIsDel()));
  }

  /**
   * updateAuthorizedAuthorities()の検証.
   *
   * 条件：利用者マスタに存在しないユーザーIDをもつレコードを指定する（取得時）
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_updateAuthorizedAuthorities_失敗_取得時_ユーザIDに一致する利用者マスタがない場合は例外が発生すること() {
    // arrange
    final Long userId = 99999L;
    final List<String> authorities = Arrays.asList("001", "002", "003");

    final ArgumentCaptor<Long> userIdCaptor = ArgumentCaptor.forClass(Long.class);
    given(mstUserDao.selectById(userId)).willThrow(EmptyResultDataAccessException.class);

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない利用者のユーザーIDを指定されています。");
    target.updateAuthorizedAuthorities(userId, authorities, false);
    verify(mstUserDao, times(1)).selectById(userId);
    final Long updatedUserId = userIdCaptor.getValue();
    assertThat(updatedUserId, is(userId));
    verify(mstUserDao, times(0)).selectById(anyLong());
  }

  /**
   * updateAuthorizedAuthorities()の検証.
   *
   * 条件：利用者マスタに存在しないユーザーIDをもつレコードを指定する（更新時）
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_updateAuthorizedAuthorities_失敗_更新時_ユーザIDに一致する利用者マスタがない場合は例外が発生すること() {
    // arrange
    final Long userId = 99999L;
    final List<String> authorities = Arrays.asList("001", "002", "003");

    final MstUser beUpdatedMstUser = new MstUser() {
      {
        setUserId(userId);
        setUserSettings(new UserSettings("{\"theme\": 0, \"authorized_authorities\": [\"000\"]}"));
        setIsProvisional(0);
        setIsDisp("1");
        setIsDel("2");
      }
    };

    final ArgumentCaptor<Long> userIdCaptor = ArgumentCaptor.forClass(Long.class);
    given(mstUserDao.selectById(userIdCaptor.capture())).willReturn(beUpdatedMstUser);

    final ArgumentCaptor<MstUser> updateCaptor = ArgumentCaptor.forClass(MstUser.class);
    given(mstUserDao.updateUserSettings(updateCaptor.capture())).willReturn(0);

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない利用者のユーザーIDを指定されています。");
    target.updateAuthorizedAuthorities(userId, authorities, false);
    verify(mstUserDao, times(1)).selectById(userId);
    final Long updatedUserId = userIdCaptor.getValue();
    assertThat(updatedUserId, is(userId));
    verify(mstUserDao, times(1)).updateUserSettings(beUpdatedMstUser);
    final MstUser updatedMstUser = updateCaptor.getValue();
    assertThat(updatedMstUser, is(beUpdatedMstUser));
  }

}
