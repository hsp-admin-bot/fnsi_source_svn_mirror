package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstPrinter;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * プリンターマスタのDaoテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql( "classpath:dao.script/MstPrinterDaoTest.before.sql")
public class MstPrinterDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  MstPrinterDao target;

  /**
   * selectByFacilityCdの検証.
   *
   * 条件：データが存在する施設コードを指定
   * 結果：結果が取得できること
   */
  @Test
  public void test_selectByFacility_正常_該当データあり() {
    // arrange
    final String facilityCd = "1001";

    // action
    final List<MstPrinter> result = target.selectByFacilityCd(facilityCd);

    // assert
    assertThat(result).hasSize(3);

    MstPrinter printer1 = result.get(0);
    assertThat(printer1.getPrinterCd()).isEqualTo(1L);
    assertThat(printer1.getFacilityCd()).isEqualTo("1001");
    assertThat(printer1.getClientKey()).isEqualTo("clientKey1");
    assertThat(printer1.getPrinterName()).isEqualTo("name1");
    assertThat(printer1.getDispPrinterName()).isEqualTo("dispName1");
    assertThat(printer1.getIsDisp()).isEqualTo("1");
    assertThat(printer1.getIsDel()).isEqualTo("0");

    MstPrinter printer2 = result.get(1);
    assertThat(printer2.getPrinterCd()).isEqualTo(2L);
    assertThat(printer2.getFacilityCd()).isEqualTo("1001");
    assertThat(printer2.getClientKey()).isEqualTo("clientKey2");
    assertThat(printer2.getPrinterName()).isEqualTo("name2");
    assertThat(printer2.getDispPrinterName()).isEqualTo("dispName2");
    assertThat(printer2.getIsDisp()).isEqualTo("1");
    assertThat(printer2.getIsDel()).isEqualTo("0");

    MstPrinter printer3 = result.get(2);
    assertThat(printer3.getPrinterCd()).isEqualTo(3L);
    assertThat(printer3.getFacilityCd()).isEqualTo("1001");
    assertThat(printer3.getClientKey()).isEqualTo("clientKey3");
    assertThat(printer3.getPrinterName()).isEqualTo("name3");
    assertThat(printer3.getDispPrinterName()).isEqualTo("dispName3");
    assertThat(printer3.getIsDisp()).isEqualTo("0");
    assertThat(printer3.getIsDel()).isEqualTo("0");
  }

  /**
   * selectByFacilityCdの検証.
   *
   * 条件：データが存在しない施設コードを指定
   * 結果：空のリストを取得できること
   */
  @Test
  public void test_selectByFacility_正常_該当データなし() {
    // arrange
    final String facilityCd = "9999";

    // action
    final List<MstPrinter> result = target.selectByFacilityCd(facilityCd);

    // assert
    assertThat(result).hasSize(0);
  }

  /**
   * selectByPrinterCdの検証.
   *
   * 条件：データが存在するプリンターコードを指定
   * 結果：結果が取得できること
   */
  @Test
  public void test_selectByPrinterCd_正常_該当データあり() {
    // arrange
    final Long printerCd = 1L;

    // action
    final MstPrinter result = target.selectByPrinterCd(printerCd);

    // assert
    assertThat(result).isNotNull();
    assertThat(result.getPrinterCd()).isEqualTo(1L);
    assertThat(result.getFacilityCd()).isEqualTo("1001");
    assertThat(result.getClientKey()).isEqualTo("clientKey1");
    assertThat(result.getPrinterName()).isEqualTo("name1");
    assertThat(result.getDispPrinterName()).isEqualTo("dispName1");
    assertThat(result.getIsDisp()).isEqualTo("1");
    assertThat(result.getIsDel()).isEqualTo("0");
  }

  /**
   * selectByPrinterCdの検証.
   *
   * 条件：データが存在しないプリンターコードを指定
   * 結果：結果が取得できないこと
   */
  @Test
  public void test_selectByPrinterCd_正常_該当データなし() {
    // arrange
    final Long printerCd = 9999L;

    // action
    final MstPrinter result = target.selectByPrinterCd(printerCd);

    // assert
    assertThat(result).isNull();
  }
}
