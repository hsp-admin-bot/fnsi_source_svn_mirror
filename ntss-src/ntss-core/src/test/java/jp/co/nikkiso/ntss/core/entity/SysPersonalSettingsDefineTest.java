package jp.co.nikkiso.ntss.core.entity;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

/**
 * 共通設定タブ定義Entityのテストクラス
 */
public class SysPersonalSettingsDefineTest {

  public enum UserType {
    IPPAN(0),
    NIKKISO(1);

    private final Integer value;

    UserType(Integer value) {
      this.value = value;
    }

    public Integer get() {
      return this.value;
    }
  }

  public enum Administrator {
    FALSE(0),
    TRUE(1);

    private final Integer value;

    Administrator(Integer value) {
      this.value = value;
    }

    public Integer get() {
      return this.value;
    }
  }

  /**
   * canShow()の検証.
   *
   * 条件：editLevel=1である.
   * 結果：種別と管理者フラグの全ての組み合わせでtrueを返すこと.
   */
  @Test
  public void test_canShow_editLevel_is_1() {
    final SysPersonalSettingsDefine define = editLevel1();

    assertTrue(define.canShow(UserType.IPPAN.get(), Administrator.FALSE.get()));
    assertTrue(define.canShow(UserType.IPPAN.get(), Administrator.TRUE.get()));
    assertTrue(define.canShow(UserType.NIKKISO.get(), Administrator.FALSE.get()));
    assertTrue(define.canShow(UserType.NIKKISO.get(), Administrator.TRUE.get()));
  }

  /**
   * canShow()の検証.
   *
   * 条件：editLevel=2である.
   * 結果：管理者ユーザの場合のみtrueを返すこと.
   */
  @Test
  public void test_canShow_editLevel_is_2() {
    final SysPersonalSettingsDefine define = editLevel2();

    assertFalse(define.canShow(UserType.IPPAN.get(), Administrator.FALSE.get()));
    assertTrue(define.canShow(UserType.IPPAN.get(), Administrator.TRUE.get()));
    assertFalse(define.canShow(UserType.NIKKISO.get(), Administrator.FALSE.get()));
    assertTrue(define.canShow(UserType.NIKKISO.get(), Administrator.TRUE.get()));
  }

  /**
   * canShow()の検証.
   *
   * 条件：editLevel=3である.
   * 結果：日機装ユーザの場合のみtrueを返すこと.
   */
  @Test
  public void test_canShow_editLevel_is_3() {
    final SysPersonalSettingsDefine define = editLevel3();

    assertFalse(define.canShow(UserType.IPPAN.get(), Administrator.FALSE.get()));
    assertFalse(define.canShow(UserType.IPPAN.get(), Administrator.TRUE.get()));
    assertTrue(define.canShow(UserType.NIKKISO.get(), Administrator.FALSE.get()));
    assertTrue(define.canShow(UserType.NIKKISO.get(), Administrator.TRUE.get()));
  }

  /**
   * canShow()の検証.
   *
   * 条件：editLevel=4である.
   * 結果：管理者かつ日機装ユーザの場合のみtrueを返すこと.
   */
  @Test
  public void test_canShow_editLevel_is_4() {
    final SysPersonalSettingsDefine define = editLevel4();

    assertFalse(define.canShow(UserType.IPPAN.get(), Administrator.FALSE.get()));
    assertFalse(define.canShow(UserType.IPPAN.get(), Administrator.TRUE.get()));
    assertFalse(define.canShow(UserType.NIKKISO.get(), Administrator.FALSE.get()));
    assertTrue(define.canShow(UserType.NIKKISO.get(), Administrator.TRUE.get()));
  }

  /**
   * canShow()の検証.
   *
   * 条件：editLevel=1~4以外である.
   * 結果：種別と管理者フラグの全ての組み合わせでfalseを返すこと.
   */
  @Test
  public void test_canShow_editLevel_is_Other() {
    final SysPersonalSettingsDefine define = editLevelOther();

    assertFalse(define.canShow(UserType.IPPAN.get(), Administrator.FALSE.get()));
    assertFalse(define.canShow(UserType.IPPAN.get(), Administrator.TRUE.get()));
    assertFalse(define.canShow(UserType.NIKKISO.get(), Administrator.FALSE.get()));
    assertFalse(define.canShow(UserType.NIKKISO.get(), Administrator.TRUE.get()));
  }

  private SysPersonalSettingsDefine editLevel1() {
    return sysPersonalSettingsDefine("1");
  }

  private SysPersonalSettingsDefine editLevel2() {
    return sysPersonalSettingsDefine("2");
  }

  private SysPersonalSettingsDefine editLevel3() {
    return sysPersonalSettingsDefine("3");
  }

  private SysPersonalSettingsDefine editLevel4() {
    return sysPersonalSettingsDefine("4");
  }

  private SysPersonalSettingsDefine editLevelOther() {
    return sysPersonalSettingsDefine("5");
  }

  private SysPersonalSettingsDefine sysPersonalSettingsDefine(String editLevel) {
    return new SysPersonalSettingsDefine(
      null,
      null,
      editLevel,
      null,
      null,
      null
    );
  }
}
