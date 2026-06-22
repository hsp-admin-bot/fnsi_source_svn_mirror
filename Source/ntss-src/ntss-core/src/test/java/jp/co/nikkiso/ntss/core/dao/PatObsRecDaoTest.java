package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

import java.sql.Timestamp;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.PatObsRec;
import jp.co.nikkiso.ntss.core.entity.custom.PatObsRecView;

/**
 * {@link PatObsRecDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql( "classpath:dao.script/PatObsRecDaoTest.before.sql")
public class PatObsRecDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  PatObsRecDao target;


  /**
   * selectByCd()の検証.
   * <p>
   *   条件：該当データなし
   *   結果：取得結果nullであること
   * </p>
   */
  @Test
  public void test_selectByCd_正常_該当データなし() {

    // 事前準備
    Long obsRecNo = 3L;
    // 実行
    PatObsRec result = target.selectByCd(obsRecNo);

    // 検証
    assertThat(result, nullValue());
  }

  /**
   * selectByCd()の検証.
   * <p>
   *   条件：該当データなし
   *   結果：取得結果nullであること
   * </p>
   */
  @Test
  public void test_selectByCd_正常_該当データあり() {

    // 事前準備
    Long obsRecNo = 0L;
    // 実行
    PatObsRec result = target.selectByCd(obsRecNo);

    // 検証
    assertThat(result, notNullValue());
    assertThat(result.getPatId(), is(1L));
    assertThat(result.getFacilityCd(), is("000001"));
    assertThat(result.getRecDate(), is(Timestamp.valueOf("2019-01-01 00:00:00")));
    assertThat(result.getUpCnt(), is((short) 0));
    assertThat(result.getOrdNo(), is(nullValue()));
    assertThat(result.getIsNewest(), is("0"));
  }

  /**
   * selectByViewSpan() の検証
   * <p>
   *   条件：該当データなし
   *   結果：取得結果が空配列であること
   * </p>
   */
  @Test
  public void selectByViewSpan_正常_該当データなし() {

    // 事前準備
    Long patId = 0L;
    Long ctlNo = 0L;
    Short kindNo = 0;
    Timestamp recDateFrom = Timestamp.valueOf("2019-01-01 00:00:00");
    Timestamp recDateTo = Timestamp.valueOf("2019-12-01 00:00:00");
    String isDel = "0";
    String isNewest = "0";
    // 実行
    List<PatObsRecView> result = target.selectByViewSpan(patId, ctlNo, kindNo, recDateFrom, recDateTo, isDel, isNewest);

    // 検証
    assertThat(result.size(), is(0));
  }

  /**
   * selectByViewSpan() の検証
   * <p>
   *   条件：該当データあり
   *   結果：取得結果が配列であること
   * </p>
   */
  @Test
  public void selectByViewSpan_正常_該当データあり() {

    // 事前準備
    Long patId = 1L;
    Long ctlNo = null;
    Short kindNo = null;
    Timestamp recDateFrom = Timestamp.valueOf("2019-01-01 00:00:00");
    Timestamp recDateTo = Timestamp.valueOf("2019-01-01 00:01:00");
    String isDel = "0";
    String isNewest = "0";
    // 実行
    List<PatObsRecView> result = target.selectByViewSpan(patId, ctlNo, kindNo, recDateFrom, recDateTo, isDel, isNewest);

    // 検証
    assertThat(result.size(), is(1));
    assertThat(result.get(0).getPatId(), is(1L));
    assertThat(result.get(0).getFacilityCd(), is("000001"));
    assertThat(result.get(0).getRecDate(), is(Timestamp.valueOf("2019-01-01 00:00:00")));
    assertThat(result.get(0).getUpCnt(), is(0));
    assertThat(result.get(0).getOrdNo(), is(nullValue()));
    assertThat(result.get(0).getIsNewest(), is("0"));
  }


  /**
   * selectByViewKey() の検証
   * <p>
   *   条件：該当データなし
   *   結果：取得結果が空配列であること
   * </p>
   */
  @Test
  public void test_selectByViewKey_正常_該当データなし() {

    // 事前準備
    Long patId = 0L;
    Long obsRecNo = 3L;
    // 実行
    PatObsRecView result = target.selectByViewKey(patId, obsRecNo);

    // 検証
    assertThat(result, nullValue());
  }

  /**
   * selectByCd()の検証.
   * <p>
   *   条件：該当データなし
   *   結果：取得結果nullであること
   * </p>
   */
  @Test
  public void test_selectByViewKey_正常_該当データあり() {

    // 事前準備
    Long patId = 1L;
    Long obsRecNo = 0L;
    // 実行
    PatObsRecView result = target.selectByViewKey(patId, obsRecNo);

    // 検証
    assertThat(result, notNullValue());
    assertThat(result.getPatId(), is(1L));
    assertThat(result.getFacilityCd(), is("000001"));
    assertThat(result.getRecDate(), is(Timestamp.valueOf("2019-01-01 00:00:00")));
    assertThat(result.getUpCnt(), is(0));
    assertThat(result.getOrdNo(), is(nullValue()));
    assertThat(result.getIsNewest(), is("0"));
    assertThat(result.getViewRecDate(), is("2019/01/01"));
    assertThat(result.getViewRecTime(), is("00:00:00"));
  }


}
