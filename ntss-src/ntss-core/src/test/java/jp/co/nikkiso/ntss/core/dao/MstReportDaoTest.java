package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstReport;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Timestamp;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

/**
 * {@link MstReportDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MstReportDaoTest.before.sql")
public class MstReportDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MstReportDao target;

  /**
   * selectByCd()の検証.
   * <p>
   * 条件：データが存在する帳票番号を指定 結果：結果が取得できること
   * </p>
   */
  @Test
  public void test_selectByCd_正常_データあり() {
    // 実行
    MstReport result = target.selectByCd(1L);

    // 検証
    assertThat(result).isNotNull();
    assertThat(result.getFacilityCd()).isEqualTo("00001");
    assertThat(result.getReportName()).isEqualTo("report");
    assertThat(result.getReportPath().getBucket()).isEqualTo("bucket");
    assertThat(result.getReportPath().getXlsxZip()).isEqualTo("xlsx_zip");
    assertThat(result.getReportPath().getReportZip()).isEqualTo("report_zip");
    assertThat(result.getReportPath().getXlsxFilename()).isEqualTo("xlsx_filename");
    assertThat(result.getReportPath().getHtmlFilename()).isEqualTo("html_filename");
    assertThat(result.getReportPath().getXmlFilename()).isEqualTo("xml_filename");
    assertThat(result.getReportClass()).isEqualTo(2);
    assertThat(result.getExtractionCondition()).isEqualTo("{\"ord_no\": 1, \"pat_id\": 11}");
    assertThat(result.getDefaultPrinter()).isEqualTo(11);
    assertThat(result.getIsDisp()).isEqualTo("1");
    assertThat(result.getIsDel()).isEqualTo("0");
    assertThat(result.getRegDate()).isEqualTo(Timestamp.valueOf("2019-02-13 14:30:00"));
    assertThat(result.getUpDate()).isEqualTo(Timestamp.valueOf("2019-02-13 14:00:00"));

  }

  /**
   * selectByCd()の検証.
   * <p>
   * 条件：データが存在しない帳票番号を指定
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void test_selectByCd_正常_データなし_帳票番号不一致() {
    // 実行
    // 検証
    target.selectByCd(4L);
  }

  /**
   * selectByCd()の検証.
   * <p>
   * 条件：表示フラグが非表示の帳票番号を指定
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void test_selectByCd_正常_データなし_表示フラグ不一致() {
    // 実行
    // 検証
    target.selectByCd(2L);
  }

  /**
   * selectByCd()の検証.
   * <p>
   * 条件：削除フラグが削除済みの帳票番号を指定
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void test_selectByCd_正常_データなし_削除フラグ不一致() {
    // 実行
    // 検証
    target.selectByCd(3L);
  }

  /**
   * selectReports()の検証.
   * <p>
   * 条件：データが存在する帳票種別、帳票区分、施設コードを指定
   * 結果：結果が取得できること
   * </p>
   */
  @Test
  public void test_selectReports_正常_データあり_全項目指定() {
    // 実行
    List<MstReport> results = target.selectReports(2, 1, "00001");

    // 検証
    assertThat(results).isNotNull();
    assertThat(results.size()).isEqualTo(1);
    assertThat(results.get(0).getReportCd()).isEqualTo(1L);
    assertThat(results.get(0).getFacilityCd()).isEqualTo("00001");
    assertThat(results.get(0).getReportName()).isEqualTo("report");
    assertThat(results.get(0).getReportPath().getBucket()).isEqualTo("bucket");
    assertThat(results.get(0).getReportPath().getXlsxZip()).isEqualTo("xlsx_zip");
    assertThat(results.get(0).getReportPath().getReportZip()).isEqualTo("report_zip");
    assertThat(results.get(0).getReportPath().getXlsxFilename()).isEqualTo("xlsx_filename");
    assertThat(results.get(0).getReportPath().getHtmlFilename()).isEqualTo("html_filename");
    assertThat(results.get(0).getReportPath().getXmlFilename()).isEqualTo("xml_filename");
    assertThat(results.get(0).getReportClass()).isEqualTo(2);
    assertThat(results.get(0).getReportType()).isEqualTo(1);
    assertThat(results.get(0).getExtractionCondition()).isEqualTo("{\"ord_no\": 1, \"pat_id\": 11}");
    assertThat(results.get(0).getDefaultPrinter()).isEqualTo(11);
    assertThat(results.get(0).getIsDisp()).isEqualTo("1");
    assertThat(results.get(0).getIsDel()).isEqualTo("0");
    assertThat(results.get(0).getRegDate()).isEqualTo(Timestamp.valueOf("2019-02-13 14:30:00"));
    assertThat(results.get(0).getUpDate()).isEqualTo(Timestamp.valueOf("2019-02-13 14:00:00"));
  }

  /**
   * selectReports()の検証.
   * <p>
   * 条件：データが存在する帳票種別、帳票区分、施設コードを指定
   * 結果：結果が取得できること
   * </p>
   */
  @Test
  public void test_selectReports_正常_データあり_施設コードを指定() {
    // 実行
    List<MstReport> results = target.selectReports(null, null, "00002");

    // 検証
    assertThat(results).isNotNull();
    assertThat(results.size()).isEqualTo(1);
    assertThat(results.get(0).getReportCd()).isEqualTo(11L);
    assertThat(results.get(0).getFacilityCd()).isEqualTo("00002");
    assertThat(results.get(0).getReportClass()).isEqualTo(2);
    assertThat(results.get(0).getReportType()).isEqualTo(2);
    assertThat(results.get(0).getExtractionCondition()).isEqualTo("{\"ord_no\": 11, \"pat_id\": 111}");
    assertThat(results.get(0).getDefaultPrinter()).isEqualTo(21);
  }

  /**
   * selectReports()の検証.
   * <p>
   * 条件：データが存在する帳票種別、帳票区分、施設コードを指定
   * 結果：結果が取得できること
   * </p>
   */
  @Test
  public void test_selectReports_正常_データあり_帳票種別と施設コードを指定() {
    // 実行
    List<MstReport> results = target.selectReports(2, null, "00001");

    // 検証
    assertThat(results).isNotNull();
    assertThat(results.size()).isEqualTo(2);
    assertThat(results.get(0).getReportCd()).isEqualTo(1L);
    assertThat(results.get(0).getFacilityCd()).isEqualTo("00001");
    assertThat(results.get(0).getReportClass()).isEqualTo(2);
    assertThat(results.get(0).getReportType()).isEqualTo(1);
    assertThat(results.get(0).getExtractionCondition()).isEqualTo("{\"ord_no\": 1, \"pat_id\": 11}");
    assertThat(results.get(0).getDefaultPrinter()).isEqualTo(11);
    assertThat(results.get(1).getReportCd()).isEqualTo(10L);
    assertThat(results.get(1).getFacilityCd()).isEqualTo("00001");
    assertThat(results.get(1).getReportClass()).isEqualTo(2);
    assertThat(results.get(1).getReportType()).isEqualTo(2);
    assertThat(results.get(1).getExtractionCondition()).isEqualTo("{\"ord_no\": 10, \"pat_id\": 110}");
    assertThat(results.get(1).getDefaultPrinter()).isEqualTo(20);
  }

  /**
   * selectReports()の検証.
   * <p>
   * 条件：データが存在しない帳票種別、帳票区分、施設コードを指定
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void test_selectReports_正常_データなし() {
    // 実行
    // 検証
    target.selectReports(null, null, "99999");
  }

}
