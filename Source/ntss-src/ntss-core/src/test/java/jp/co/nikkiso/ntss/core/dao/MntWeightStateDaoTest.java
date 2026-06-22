package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

import java.math.BigDecimal;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;
import jp.co.nikkiso.ntss.core.entity.MntWeightState;

/**
 * {@link MntWeightStateDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MntWeightStateDaoTest.before.sql")
public class MntWeightStateDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  MntWeightStateDao target;


  /**
   * selectByWeightCd()の検証.
   * <p>
   *   条件:該当データなし
   *   結果:取得結果nullであること
   * </p>
   */
  @Test
  public void test_selectByWeightCd_正常_該当データなし() {

    // 事前準備
    Long weightNo = -1L;
    // 実行
    MntWeightState result = target.selectByWeightCd(weightNo);

    // 検証
    assertThat(result, nullValue());
  }

  /**
   * selectByWeightCd()の検証.
   * <p>
   *   条件:該当データあり
   *   結果:取得結果が正しいこと
   * </p>
   */
  @Test
  public void test_selectByWeightCd_正常_該当データあり() {

    // 事前準備
    Long weightNo = 0L;
    // 実行
    MntWeightState result = target.selectByWeightCd(weightNo);

    // 検証
    assertThat(result, notNullValue());
    assertThat(result.getWeightCd(), is(0L));
    assertThat(result.getIsConnect(), is("1"));
    assertThat(result.getScaleValue(), is(new BigDecimal("50.500")));
    assertThat(result.getBarcodeValue(), is("0123456"));
    assertThat(result.getCardReadValue(), is("{}"));
    assertThat(result.getCardWriteValue(), is("{}"));
    assertThat(result.getWriteResult(), is(1));
  }

}
