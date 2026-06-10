package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.CoreMatchers.is;
import static org.junit.Assert.assertThat;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

/**
 * {@link Db6FunctionDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class Db6FunctionDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  Db6FunctionDao target;


  /**
   * personalInfoEncrypto()の検証.
   * <p>
   *   条件：文字 '0' を与える
   *   結果：1ビット左シフトしたHEX文字列 '60' が返ること
   * </p>
   */
  @Test
  public void test_personalInfoEncrypto_正常() {

    // 事前準備
    String text = "0";
    // 実行
    String result = target.personalInfoEncrypto(text);

    // 検証
    assertThat(result, is("60"));
  }

  /**
   * personalInfoDecrypto()の検証.
   * <p>
   *   条件：HEX文字列 '60' を与える
   *   結果：1ビット右シフトした文字列 '0' が返ること
   * </p>
   */
  @Test
  public void test_personalInfoDecrypto_正常() {

    // 事前準備
    String text = "60";
    // 実行
    String result = target.personalInfoDecrypto(text);

    // 検証
    assertThat(result, is("0"));
  }

}
