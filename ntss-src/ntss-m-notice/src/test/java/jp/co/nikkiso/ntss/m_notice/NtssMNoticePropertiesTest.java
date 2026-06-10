package jp.co.nikkiso.ntss.m_notice;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.transaction.annotation.Transactional;

import static jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName.PERSONAL;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;

/**
 * NtssMNoticePropertiesのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class NtssMNoticePropertiesTest {

  /**
   * テスト対象.
   */
  @Autowired
  private NtssMNoticeProperties target;

  /**
   * isNikkisoUserMailAddressの検証.
   *
   * 条件：引数に null 指定、日機装社員のメールアドレスかチェック
   * 結果：false
   */
  @Test
  public void test_isNikkisoUserMailAddress_引数Null_日機装チェック() {
    assertThat(target.chkMailAddressUserType(null, true), is(false));
  }

  /**
   * isNikkisoUserMailAddressの検証.
   *
   * 条件：引数に null 指定、一般ユーザのメールアドレスかチェック
   * 結果：false
   */
  @Test
  public void test_isNikkisoUserMailAddress_引数Null_一般チェック() {
    assertThat(target.chkMailAddressUserType(null, false), is(false));
  }

  /**
   * isNikkisoUserMailAddressの検証.
   *
   * 条件：引数に 空文字 指定、日機装社員のメールアドレスかチェック
   * 結果：false
   */
  @Test
  public void test_isNikkisoUserMailAddress_引数空文字_日機装チェック() {
    assertThat(target.chkMailAddressUserType("", true), is(false));
  }

  /**
   * isNikkisoUserMailAddressの検証.
   *
   * 条件：引数に 空文字 指定、一般ユーザのメールアドレスかチェック
   * 結果：false
   */
  @Test
  public void test_isNikkisoUserMailAddress_引数空文字_一般チェック() {
    assertThat(target.chkMailAddressUserType("", false), is(false));
  }

  /**
   * isNikkisoUserMailAddressの検証.
   *
   * 条件：引数に "xxxx@nikkiso.co.jp" 指定、日機装社員のメールアドレスかチェック
   *      "xxxx@nikkiso.co.jp"は日機装社員1名のみ設定
   * 結果：true
   */
  @Test
  @Sql(value = "classpath:resource/NtssMNoticePropertiesTest.before.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  public void test_isNikkisoUserMailAddress_日機装ユーザー指定_日機装チェック() {
    assertThat(target.chkMailAddressUserType("xxxx@nikkiso.co.jp", true), is(true));
  }

  /**
   * isNikkisoUserMailAddressの検証.
   *
   * 条件：引数に "xxxx@nikkiso.co.jp" 指定、一般ユーザのメールアドレスかチェック
   *      "xxxx@nikkiso.co.jp"は日機装社員1名のみ設定
   * 結果：false
   */
  @Test
  @Sql(value = "classpath:resource/NtssMNoticePropertiesTest.before.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  public void test_isNikkisoUserMailAddress_日機装ユーザー指定_一般チェック() {
    assertThat(target.chkMailAddressUserType("xxxx@nikkiso.co.jp", false), is(false));
  }

  /**
   * isNikkisoUserMailAddressの検証.
   *
   * 条件：引数に "yyyy@esm.co.jp" 指定、日機装社員のメールアドレスかチェック
   *      "yyyy@esm.co.jp"は一般ユーザ1名のみ設定
   * 結果：false
   */
  @Test
  @Sql(value = "classpath:resource/NtssMNoticePropertiesTest.before.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  public void test_isNikkisoUserMailAddress_一般ユーザー指定_日機装チェック() {
    assertThat(target.chkMailAddressUserType("yyyy@esm.co.jp", true), is(false));
  }

  /**
   * isNikkisoUserMailAddressの検証.
   *
   * 条件：引数に "yyyy@esm.co.jp" 指定、一般ユーザのメールアドレスかチェック
   *      "yyyy@esm.co.jp"は一般ユーザ1名のみ設定
   * 結果：true
   */
  @Test
  @Sql(value = "classpath:resource/NtssMNoticePropertiesTest.before.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  public void test_isNikkisoUserMailAddress_一般ユーザー指定_一般チェック() {
    assertThat(target.chkMailAddressUserType("yyyy@esm.co.jp", false), is(true));
  }

  /**
   * isNikkisoUserMailAddressの検証.
   *
   * 条件：引数に "multi@nikkiso.com" 指定、日機装社員のメールアドレスかチェック
   *      "multi@nikkiso.com"は日機装社員複数名が設定
   * 結果：true
   */
  @Test
  @Sql(value = "classpath:resource/NtssMNoticePropertiesTest.before.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  public void test_isNikkisoUserMailAddress_日機装ユーザー複数指定_日機装チェック() {
    assertThat(target.chkMailAddressUserType("multi@nikkiso.com", true), is(true));
  }

  /**
   * isNikkisoUserMailAddressの検証.
   *
   * 条件：引数に "multi@nikkiso.com" 指定、一般ユーザのメールアドレスかチェック
   *      "multi@nikkiso.com"は日機装社員複数名が設定
   * 結果：false
   */
  @Test
  @Sql(value = "classpath:resource/NtssMNoticePropertiesTest.before.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  public void test_isNikkisoUserMailAddress_日機装ユーザー複数指定_一般チェック() {
    assertThat(target.chkMailAddressUserType("multi@nikkiso.com", false), is(false));
  }

  /**
   * isNikkisoUserMailAddressの検証.
   *
   * 条件：引数に "multi@docomo.ne.jp" 指定、日機装社員のメールアドレスかチェック
   *      "multi@docomo.ne.jp"は一般ユーザ複数名が設定
   * 結果：false
   */
  @Test
  @Sql(value = "classpath:resource/NtssMNoticePropertiesTest.before.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  public void test_isNikkisoUserMailAddress_一般ユーザー複数指定_日機装チェック() {
    assertThat(target.chkMailAddressUserType("multi@docomo.ne.jp", true), is(false));
  }

  /**
   * isNikkisoUserMailAddressの検証.
   *
   * 条件：引数に "multi@docomo.ne.jp" 指定、一般ユーザのメールアドレスかチェック
   *      "multi@docomo.ne.jp"は一般ユーザ複数名が設定
   * 結果：true
   */
  @Test
  @Sql(value = "classpath:resource/NtssMNoticePropertiesTest.before.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  public void test_isNikkisoUserMailAddress_一般ユーザー複数指定_一般チェック() {
    assertThat(target.chkMailAddressUserType("multi@docomo.ne.jp", false), is(true));
  }

  /**
   * isNikkisoUserMailAddressの検証.
   *
   * 条件：引数に "nikkiso_general@nikkiso.co.jp" 指定、日機装社員のメールアドレスかチェック
   *      "nikkiso_general@nikkiso.co.jp"は日機装社員・一般ユーザが設定
   * 結果：false
   */
  @Test
  @Sql(value = "classpath:resource/NtssMNoticePropertiesTest.before.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  public void test_isNikkisoUserMailAddress_日機装_一般ユーザー指定_日機装チェック() {
    assertThat(target.chkMailAddressUserType("nikkiso_general@nikkiso.co.jp", true), is(true));
  }

  /**
   * isNikkisoUserMailAddressの検証.
   *
   * 条件：引数に "nikkiso_general@nikkiso.co.jp" 指定、日機装社員のメールアドレスかチェック
   *      "nikkiso_general@nikkiso.co.jp"は日機装社員・一般ユーザが設定
   * 結果：false
   */
  @Test
  @Sql(value = "classpath:resource/NtssMNoticePropertiesTest.before.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  public void test_isNikkisoUserMailAddress_日機装_一般ユーザー指定_一般チェック() {
    assertThat(target.chkMailAddressUserType("nikkiso_general@nikkiso.co.jp", false), is(true));
  }

}
