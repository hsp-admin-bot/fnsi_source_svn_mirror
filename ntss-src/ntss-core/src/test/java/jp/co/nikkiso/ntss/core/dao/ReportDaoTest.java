package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.custom.Vital;

/**
 * {@link ReportDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/ReportDaoTest.before.sql")
public class ReportDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private ReportDao target;

  /**
   * selectVitalData()の検証.
   * <p>
   * 条件：データが存在するオーダ番号を指定
   * 結果：結果が取得できること
   * </p>
   */
  @Test
  public void test_selectVitalData_正常_データあり() {
    // 事前準備
    Long ordNo = 5L;

    // 実行
    List<Vital> result = target.selectVitalData(ordNo);

    // 検証
    assertThat(result.size(), is(12));
    assertThat(result.get(0).getBioMoniCtlNo(), is(37L));
    assertThat(result.get(0).getDataType(), is(5));
    assertThat(result.get(0).getOccurDate(), is(Timestamp.valueOf("2019-05-10 13:00:00")));
    assertThat(result.get(0).getBpClass(), nullValue());
    assertThat(result.get(0).getBpMax(), is(BigDecimal.valueOf(111)));
    assertThat(result.get(0).getBpMin(), is(BigDecimal.valueOf(81)));
    assertThat(result.get(0).getBpAve(), is(BigDecimal.valueOf(124)));
    assertThat(result.get(0).getPulse(), is(BigDecimal.valueOf(51)));
    assertThat(result.get(0).getTemperature(), nullValue());
    assertThat(result.get(0).getBloodSugarLevel(), nullValue());
    assertThat(result.get(0).getIsDel(), is("0"));
  }

  /**
   * selectVitalData()の検証.
   * <p>
   * 条件：データが存在しないオーダ番号を指定
   * 結果：0件のリストが取得できること
   * </p>
   */
  @Test
  public void test_selectVitalData_正常_データなし() {
    // 事前準備
    Long ordNo = 1L;

    // 実行
    List<Vital> result = target.selectVitalData(ordNo);

    // 検証
    assertThat(result.size(), is(0));
  }

}
