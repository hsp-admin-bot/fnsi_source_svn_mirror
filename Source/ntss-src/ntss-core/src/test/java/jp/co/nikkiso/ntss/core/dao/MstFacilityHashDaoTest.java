package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;

/**
 * {@link MstFacilityHashDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional(TransactionManagerName.AUTH)
@Sql(value = "classpath:dao.script/MstFacilityHashDaoTest.before.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
public class MstFacilityHashDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MstFacilityHashDao target;

  /**
   * selectByHashValue()の検証.
   * <p>
   *   条件：該当データあり
   *   結果：レコードが取得できること
   * </p>
   */
  @Test
  public void test_selectByHashValue_成功() {
    // 事前準備
    String facilityCd = "900001";
    String hashValue = "$2a$10$Ei5Hfv.SHGLaWeFLNQKtPOljvGEBkp.kpJINs12vpIcg0/qVcbhGy";

    // 実行
    MstFacilityHash result = target.selectByHashValue(hashValue);

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.getFacilityCd(), is(facilityCd));
    assertThat(result.getHashValue(), is(hashValue));
  }

  /**
   * selectByHashValue()の検証.
   * <p>
   *   条件：該当データなし
   *   結果：レコードが取得できないこと
   * </p>
   */
  @Test
  public void test_selectByHashValue_失敗() {
    // 実行
    MstFacilityHash result = target.selectByHashValue("invalid_hash");

    // 検証
    assertThat(result, nullValue());
  }

  /**
   * findByHashValue()の検証.
   * <p>
   *   条件：該当データあり
   *   結果：レコードが取得できること
   * </p>
   */
  @Test
  public void test_findByHashValue_成功() {
    // 事前準備
    String facilityCd = "900001";
    String hashValue = "$2a$10$Ei5Hfv.SHGLaWeFLNQKtPOljvGEBkp.kpJINs12vpIcg0/qVcbhGy";

    // 実行
    MstFacilityHash result = target.findByHashValue(hashValue);

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.getFacilityCd(), is(facilityCd));
    assertThat(result.getHashValue(), is(hashValue));
  }

  /**
   * selectByHashValue()の検証.
   * <p>
   *   条件：該当データなし
   *   結果：レコードが取得できること(-1)
   * </p>
   */
  @Test
  public void test_findByHashValue_失敗() {
    // 実行
    MstFacilityHash result = target.findByHashValue("invalid_hash");

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.getFacilityCd(), is("0"));
    assertThat(result.getHashValue(), is("0"));
  }



  /**
   * selectByFacilityCd()の検証.
   * <p>
   *   条件：該当データあり
   *   結果：レコードが取得できること
   * </p>
   */
  @Test
  public void test_selectByFacilityCd_成功() {
    // 事前準備
    String facilityCd = "900001";
    String hashValue = "$2a$10$Ei5Hfv.SHGLaWeFLNQKtPOljvGEBkp.kpJINs12vpIcg0/qVcbhGy";

    // 実行
    MstFacilityHash result = target.selectByFacilityCd(facilityCd);

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.getFacilityCd(), is(facilityCd));
    assertThat(result.getHashValue(), is(hashValue));
  }

  /**
   * selectByFacilityCd()の検証.
   * <p>
   *   条件：該当データなし
   *   結果：レコードが取得できないこと
   * </p>
   */
  @Test
  public void test_selectByFacilityCd_失敗() {
    // 実行
    MstFacilityHash result = target.selectByFacilityCd("invalid_cd");

    // 検証
    assertThat(result, nullValue());
  }

}
