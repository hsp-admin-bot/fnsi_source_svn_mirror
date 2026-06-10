package jp.co.nikkiso.ntss.core.dao;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Timestamp;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.IndicationResult;

/**
 * {@link IndicationResultDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/IndicationResultDaoTest.before.sql")
public class IndicationResultDaoTest {

  @Autowired
  private IndicationResultDao target;

  /**
   * selectByPatIdAndTreatDate()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：治療記録から予実リスト情報のリストが取得できること
   * </p>
   */
  @Test
  public void test_selectByPatIdAndTreatDate_正常_データあり() {
    // arrange
    final Long patId = 1L;
    final String treatDateFrom = "20190610";
    final String treatDateTo = "20190620";

    final IndicationResult[] expected = {
      new IndicationResult() {
        {
          setOrdNo(1L);
          setCategory("1");
          setIndRstType(1);
          setTreatmentDate("20190610");
          setTreatmentCd(11);
          setTreatmentName("【指示】治療方法名1");
          setKurCd(11L);
          setKurName("【指示】クール1");
          setBedCd(12L);
          setBedName("【指示】ベッド1");
          setStartDate(Timestamp.valueOf("2019-06-10 09:00:00"));
        }
      },
      new IndicationResult() {
        {
          setOrdNo(2L);
          setCategory("1");
          setIndRstType(1);
          setTreatmentDate("20190620");
          setTreatmentCd(12);
          setTreatmentName("【指示】治療方法名2");
          setKurCd(12L);
          setKurName("【指示】クール2");
          setBedCd(13L);
          setBedName("【指示】ベッド2");
          setStartDate(Timestamp.valueOf("2019-06-20 10:00:00"));
        }
      },
      new IndicationResult() {
        {
          setOrdNo(1L);
          setCategory("1");
          setIndRstType(2);
          setTreatmentDate("20190610");
          setTreatmentCd(21);
          setTreatmentName("【実績】治療方法名1");
          setKurCd(21L);
          setKurName("【実績】クール1");
          setBedCd(22L);
          setBedName("【実績】ベッド1");
          setStartDate(Timestamp.valueOf("2019-06-10 12:00:00"));
          setEndDate(Timestamp.valueOf("2019-06-10 18:00:00"));
        }
      },
      new IndicationResult() {
        {
          setOrdNo(2L);
          setCategory("1");
          setIndRstType(2);
          setTreatmentDate("20190620");
          setTreatmentCd(22);
          setTreatmentName("【実績】治療方法名2");
          setKurCd(22L);
          setKurName("【実績】クール2");
          setBedCd(23L);
          setBedName("【実績】ベッド2");
          setStartDate(Timestamp.valueOf("2019-06-20 12:30:00"));
          setEndDate(Timestamp.valueOf("2019-06-20 18:30:00"));
        }
      }
    };

    // action
    final List<IndicationResult> result = target.selectByPatIdAndTreatDate(patId, treatDateFrom, treatDateTo, null);

    // assert
    assertThat(result).isNotEmpty();
    assertThat(result)
      .hasSize(4)
      .containsExactly(expected);
  }

  /**
   * selectByPatIdAndTreatDate()の検証.
   * <p>
   * 条件：該当データなし(患者IDが違う)
   * 結果：空のリストが取得できること
   * </p>
   */
  @Test
  public void test_selectByPatIdAndTreatDate_正常_データなし_患者IDが違う() {
    // arrange
    final Long patId = 99L;
    final String treatDateFrom = "20190610";
    final String treatDateTo = "20190620";

    // action
    final List<IndicationResult> result = target.selectByPatIdAndTreatDate(patId, treatDateFrom, treatDateTo, null);

    // assert
    assertThat(result).isEmpty();
  }

  /**
   * selectByPatIdAndTreatDate()の検証.
   * <p>
   * 条件：該当データなし(治療日の範囲)
   * 結果：空のリストが取得できること
   * </p>
   */
  @Test
  public void test_selectByPatIdAndTreatDate_正常_データなし_治療日の範囲が違う() {
    // arrange
    final Long patId = 1L;
    final String treatDateFrom = "20190601";
    final String treatDateTo = "20190609";

    // action
    final List<IndicationResult> result = target.selectByPatIdAndTreatDate(patId, treatDateFrom, treatDateTo, null);

    // assert
    assertThat(result).isEmpty();
  }


  /**
   * selectByPatIdAndTreatDate()の検証.
   * <p>
   * 条件：該当データあり(実績なし)
   * 結果：治療記録から予実リスト情報のリストが取得できること
   * </p>
   */
  @Test
  public void test_selectByPatIdAndTreatDate_正常_データあり_実績なし() {
    // arrange
    final Long patId = 2L;
    final String treatDateFrom = "20190601";
    final String treatDateTo = "20190615";

    final IndicationResult[] expected = {
      new IndicationResult() {
        {
          setOrdNo(6L);
          setCategory("1");
          setIndRstType(1);
          setTreatmentDate("20190610");
          setTreatmentCd(12);
          setTreatmentName("【指示】治療方法名2");
          setKurCd(12L);
          setKurName("【指示】クール2");
          setBedCd(13L);
          setBedName("【指示】ベッド2");
          setStartDate(Timestamp.valueOf("2019-06-10 13:00:00"));
        }
      }};

    // action
    final List<IndicationResult> result = target.selectByPatIdAndTreatDate(patId, treatDateFrom, treatDateTo, null);

    // assert
    assertThat(result).isNotEmpty();
    assertThat(result)
      .hasSize(1)
      .containsExactly(expected);
  }
}
