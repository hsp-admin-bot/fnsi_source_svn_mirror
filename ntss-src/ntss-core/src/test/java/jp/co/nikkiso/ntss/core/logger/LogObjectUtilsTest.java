package jp.co.nikkiso.ntss.core.logger;

import org.junit.Test;

import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;

/**
 * {@link LogObjectUtils}のテストクラス
 */
public class LogObjectUtilsTest {

  /**
   * {@link LogObjectUtils#readSqlFile(String)}の検証.
   *
   * <p>
   *   条件 : 存在するSQLファイルパスを指定する.
   *   結果 : SQLファイルに記載されたSQL文が返却される事.
   * </p>
   */
  @Test
  public void test_readSqlFile_正常_SQLファイルが存在する() {
    // 事前準備
    String sqlFilePath = "/OrdMainDao/selectAll";
    //　実行
    String result = LogObjectUtils.readSqlFile(sqlFilePath);
    // 検証
    assertThat(result, is("select /*%expand \"A\" */* from ord_main A ;"));
  }

  /**
   * {@link LogObjectUtils#readSqlFile(String)}の検証.
   *
   * <p>
   *   条件 : 存在しないSQLファイルパスを指定する.
   *   結果 : 空文字が返却される事.
   * </p>
   */
  @Test
  public void test_readSqlFile_異常_SQLファイルが存在しない() {
    // 事前準備(存在しないSQLファイル)
    String sqlFilePath = "/OrdMainDao/notExistSqlFile";
    //　実行
    String result = LogObjectUtils.readSqlFile(sqlFilePath);
    // 検証
    assertThat(result, is(""));
  }

}
