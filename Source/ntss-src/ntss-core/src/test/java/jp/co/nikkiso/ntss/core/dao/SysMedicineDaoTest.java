package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.SysMedicine;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

/**
 * {@link SysMedicineDao}のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql( "classpath:dao.script/SysMedicineDaoTest.before.sql")
public class SysMedicineDaoTest {

  /**
   * {@link SysMedicineDao}
   */
  @Autowired
  SysMedicineDao sysMedicineDao;

  /**
   * {@link SysMedicineDao#selectAll()}の検証.
   * 条件：データが存在する
   * 結果：登録されている全データが取得出来る事
   */
  @Test
  public void test_selectAll_正常_データあり() {
    // 実行
    List<SysMedicine> result = sysMedicineDao.selectAll();
    // 検証
    assertThat(result).hasSize(30);
    // 1件目
    SysMedicine sysMedicine1 = result.get(0);
    assertThat(sysMedicine1.getCompanyNo()).isEqualTo("01");
    assertThat(sysMedicine1.getDispensingNo()).isEqualTo("01");
    assertThat(sysMedicine1.getJanCd()).isEqualTo("4987123031769");
    assertThat(sysMedicine1.getDrugPriceStandardCd()).isEqualTo("1112700X1011");
    assertThat(sysMedicine1.getLogisticsNo()).isEqualTo("01");
    assertThat(sysMedicine1.getManufactureCompany()).isEqualTo("武田薬品");
    assertThat(sysMedicine1.getNoticeName()).isEqualTo("（局）ハロタン");
    assertThat(sysMedicine1.getPkgAmount()).isEqualTo(new BigDecimal("250.0000"));
    assertThat(sysMedicine1.getPkgPresentation()).isEqualTo("調剤用");
    assertThat(sysMedicine1.getPkgQtyPerCartonQuantity()).isEqualTo(new BigDecimal("1.0000"));
    assertThat(sysMedicine1.getPkgQtyPerCartonUnit()).isEqualTo("入");
    assertThat(sysMedicine1.getPkgQtyQuantity()).isEqualTo(new BigDecimal("1.0000"));
    assertThat(sysMedicine1.getPkgQtyUnit()).isEqualTo("瓶");
    assertThat(sysMedicine1.getPkgTotalAmount()).isEqualTo(new BigDecimal("250.0000"));
    assertThat(sysMedicine1.getPkgTotalUnit()).isEqualTo("ＭＬ");
    assertThat(sysMedicine1.getPkgUnit()).isEqualTo("ＭＬ");
    assertThat(sysMedicine1.getPrescriptionNo()).isEqualTo("1003031");
    assertThat(sysMedicine1.getUsageCategoryClass()).isEqualTo("2");
    assertThat(sysMedicine1.getReceiptCd_1()).isEqualTo("661110021");
    assertThat(sysMedicine1.getReceiptCd_2()).isEqualTo("661110004");
    assertThat(sysMedicine1.getReceiptMedicineName()).isEqualTo("フローセン");
    assertThat(sysMedicine1.getRecordClass()).isEqualTo("4");
    assertThat(sysMedicine1.getSalesCompany()).isEqualTo("武田薬品");
    assertThat(sysMedicine1.getSalesName()).isEqualTo("フローセン");
    assertThat(sysMedicine1.getStandardMedicineCd()).isEqualTo("1112700X1038");
    assertThat(sysMedicine1.getStandardNo()).isEqualTo("1003031010101");
    assertThat(sysMedicine1.getStandardUnit()).isEqualTo("１ｍＬ");
    assertThat(sysMedicine1.getStandardUpDate()).isEqualTo("20100331");
    assertNull(sysMedicine1.getUnit());
    assertNull(sysMedicine1.getUnitConvertedAmount());
    assertNull(sysMedicine1.getUnitConvertedAmountSecond());
    assertNull(sysMedicine1.getUnitDecimalPoint());
    assertNull(sysMedicine1.getUnitDecimalPointSecond());
    assertNull(sysMedicine1.getUnitSecond());
    // 2件目
    SysMedicine sysMedicine2 = result.get(1);
    assertThat(sysMedicine2.getCompanyNo()).isEqualTo("01");
    assertThat(sysMedicine2.getDispensingNo()).isEqualTo("01");
    assertThat(sysMedicine2.getJanCd()).isEqualTo("4987128114603");
    assertThat(sysMedicine2.getDrugPriceStandardCd()).isEqualTo("1115400X1019");
    assertThat(sysMedicine2.getLogisticsNo()).isEqualTo("02");
    assertThat(sysMedicine2.getManufactureCompany()).isEqualTo("田辺三菱製薬");
    assertThat(sysMedicine2.getNoticeName()).isEqualTo("（局）注射用チオペンタールナトリウム");
    assertThat(sysMedicine2.getPkgAmount()).isEqualTo(new BigDecimal("1.0000"));
    assertThat(sysMedicine2.getPkgPresentation()).isEqualTo("");
    assertThat(sysMedicine2.getPkgQtyPerCartonQuantity()).isEqualTo(new BigDecimal("1.0000"));
    assertThat(sysMedicine2.getPkgQtyPerCartonUnit()).isEqualTo("入");
    assertThat(sysMedicine2.getPkgQtyQuantity()).isEqualTo(new BigDecimal("10.0000"));
    assertThat(sysMedicine2.getPkgQtyUnit()).isEqualTo("管");
    assertThat(sysMedicine2.getPkgTotalAmount()).isEqualTo(new BigDecimal("10.0000"));
    assertThat(sysMedicine2.getPkgTotalUnit()).isEqualTo("管");
    assertThat(sysMedicine2.getPkgUnit()).isEqualTo("管");
    assertThat(sysMedicine2.getPrescriptionNo()).isEqualTo("1003062");
    assertThat(sysMedicine2.getUsageCategoryClass()).isEqualTo("3");
    assertThat(sysMedicine2.getReceiptCd_1()).isEqualTo("641110021");
    assertThat(sysMedicine2.getReceiptCd_2()).isEqualTo("641110009");
    assertThat(sysMedicine2.getReceiptMedicineName()).isEqualTo("ラボナール注射用０．３ｇ　３００ｍｇ");
    assertThat(sysMedicine2.getRecordClass()).isEqualTo("1");
    assertThat(sysMedicine2.getSalesCompany()).isEqualTo("田辺三菱製薬");
    assertThat(sysMedicine2.getSalesName()).isEqualTo("ラボナール注射用０．３ｇ");
    assertThat(sysMedicine2.getStandardMedicineCd()).isEqualTo("1115400X1027");
    assertThat(sysMedicine2.getStandardNo()).isEqualTo("1003062010102");
    assertThat(sysMedicine2.getStandardUnit()).isEqualTo("３００ｍｇ１管");
    assertThat(sysMedicine2.getStandardUpDate()).isEqualTo("20100331");
    assertNull(sysMedicine2.getUnit());
    assertNull(sysMedicine2.getUnitConvertedAmount());
    assertNull(sysMedicine2.getUnitConvertedAmountSecond());
    assertNull(sysMedicine2.getUnitDecimalPoint());
    assertNull(sysMedicine2.getUnitDecimalPointSecond());
    assertNull(sysMedicine2.getUnitSecond());
  }

  /**
   * {@link SysMedicineDao#selectAll()}の検証.
   * 条件：データが存在しない事
   * 結果：空のリストが返却される事
   */
  @Test
  @Sql( "classpath:dao.script/SysMonitorItemDaoTestDelete.before.sql")
  public void test_selectAll_正常_データなし() {
    // 実行
    List<SysMedicine> result = sysMedicineDao.selectAll();
    // 検証
    assertTrue(result.isEmpty());
  }

  /**
   * {@link SysMedicineDao#selectByStandardNo(String)} の検証.
   * 条件:指定した基準番号に該当するデータが存在する事
   * 結果:基準番号に該当するデータが返却される事
   */
  @Test
  public void test_selectByStandardNo_正常_データあり() {
    // 実行
    SysMedicine result = sysMedicineDao.selectByStandardNo("1003031010101");
    // 検証
    assertNotNull(result);
    SysMedicine sysMedicine1 = result;
    assertThat(sysMedicine1.getCompanyNo()).isEqualTo("01");
    assertThat(sysMedicine1.getDispensingNo()).isEqualTo("01");
    assertThat(sysMedicine1.getJanCd()).isEqualTo("4987123031769");
    assertThat(sysMedicine1.getDrugPriceStandardCd()).isEqualTo("1112700X1011");
    assertThat(sysMedicine1.getLogisticsNo()).isEqualTo("01");
    assertThat(sysMedicine1.getManufactureCompany()).isEqualTo("武田薬品");
    assertThat(sysMedicine1.getNoticeName()).isEqualTo("（局）ハロタン");
    assertThat(sysMedicine1.getPkgAmount()).isEqualTo(new BigDecimal("250.0000"));
    assertThat(sysMedicine1.getPkgPresentation()).isEqualTo("調剤用");
    assertThat(sysMedicine1.getPkgQtyPerCartonQuantity()).isEqualTo(new BigDecimal("1.0000"));
    assertThat(sysMedicine1.getPkgQtyPerCartonUnit()).isEqualTo("入");
    assertThat(sysMedicine1.getPkgQtyQuantity()).isEqualTo(new BigDecimal("1.0000"));
    assertThat(sysMedicine1.getPkgQtyUnit()).isEqualTo("瓶");
    assertThat(sysMedicine1.getPkgTotalAmount()).isEqualTo(new BigDecimal("250.0000"));
    assertThat(sysMedicine1.getPkgTotalUnit()).isEqualTo("ＭＬ");
    assertThat(sysMedicine1.getPkgUnit()).isEqualTo("ＭＬ");
    assertThat(sysMedicine1.getPrescriptionNo()).isEqualTo("1003031");
    assertThat(sysMedicine1.getUsageCategoryClass()).isEqualTo("2");
    assertThat(sysMedicine1.getReceiptCd_1()).isEqualTo("661110021");
    assertThat(sysMedicine1.getReceiptCd_2()).isEqualTo("661110004");
    assertThat(sysMedicine1.getReceiptMedicineName()).isEqualTo("フローセン");
    assertThat(sysMedicine1.getRecordClass()).isEqualTo("4");
    assertThat(sysMedicine1.getSalesCompany()).isEqualTo("武田薬品");
    assertThat(sysMedicine1.getSalesName()).isEqualTo("フローセン");
    assertThat(sysMedicine1.getStandardMedicineCd()).isEqualTo("1112700X1038");
    assertThat(sysMedicine1.getStandardNo()).isEqualTo("1003031010101");
    assertThat(sysMedicine1.getStandardUnit()).isEqualTo("１ｍＬ");
    assertThat(sysMedicine1.getStandardUpDate()).isEqualTo("20100331");
    assertNull(sysMedicine1.getUnit());
    assertNull(sysMedicine1.getUnitConvertedAmount());
    assertNull(sysMedicine1.getUnitConvertedAmountSecond());
    assertNull(sysMedicine1.getUnitDecimalPoint());
    assertNull(sysMedicine1.getUnitDecimalPointSecond());
    assertNull(sysMedicine1.getUnitSecond());
  }

  /**
   * {@link SysMedicineDao#selectByStandardNo(String)} の検証.
   * 条件:指定した基準番号に該当するデータが存在しない事
   * 結果:<code>null</code>が返却される事
   */
  @Test
  public void test_selectByStandardNo_異常_データなし() {
    // 実行
    SysMedicine result = sysMedicineDao.selectByStandardNo("1");
    // 検証
    assertNull(result);
  }

  /**
   * {@link SysMedicineDao#selectSysMedicineByLimitAndOffset(Integer, Integer)}の検証.
   * 条件:データが存在する事
   * 結果:指定した開始位置から取得上限分のデータが取得出来る事
   */
  @Test
  public void test_selectSysMedicineByLimitAndOffset_正常_データあり() {
    // オフセット
    Integer offset = 0;
    // 取得上限
    Integer limit = 10;
    // 実行(1回目)
    List<SysMedicine> result1 = sysMedicineDao.selectSysMedicineByLimitAndOffset(limit, offset, null);
    // 1回目の検証
    assertThat(result1).hasSize(limit);
    // 1件目
    SysMedicine sysMedicine1 = result1.get(0);
    assertThat(sysMedicine1.getCompanyNo()).isEqualTo("01");
    assertThat(sysMedicine1.getDispensingNo()).isEqualTo("01");
    assertThat(sysMedicine1.getJanCd()).isEqualTo("4987123031769");
    assertThat(sysMedicine1.getDrugPriceStandardCd()).isEqualTo("1112700X1011");
    assertThat(sysMedicine1.getLogisticsNo()).isEqualTo("01");
    assertThat(sysMedicine1.getManufactureCompany()).isEqualTo("武田薬品");
    assertThat(sysMedicine1.getNoticeName()).isEqualTo("（局）ハロタン");
    assertThat(sysMedicine1.getPkgAmount()).isEqualTo(new BigDecimal("250.0000"));
    assertThat(sysMedicine1.getPkgPresentation()).isEqualTo("調剤用");
    assertThat(sysMedicine1.getPkgQtyPerCartonQuantity()).isEqualTo(new BigDecimal("1.0000"));
    assertThat(sysMedicine1.getPkgQtyPerCartonUnit()).isEqualTo("入");
    assertThat(sysMedicine1.getPkgQtyQuantity()).isEqualTo(new BigDecimal("1.0000"));
    assertThat(sysMedicine1.getPkgQtyUnit()).isEqualTo("瓶");
    assertThat(sysMedicine1.getPkgTotalAmount()).isEqualTo(new BigDecimal("250.0000"));
    assertThat(sysMedicine1.getPkgTotalUnit()).isEqualTo("ＭＬ");
    assertThat(sysMedicine1.getPkgUnit()).isEqualTo("ＭＬ");
    assertThat(sysMedicine1.getPrescriptionNo()).isEqualTo("1003031");
    assertThat(sysMedicine1.getUsageCategoryClass()).isEqualTo("2");
    assertThat(sysMedicine1.getReceiptCd_1()).isEqualTo("661110021");
    assertThat(sysMedicine1.getReceiptCd_2()).isEqualTo("661110004");
    assertThat(sysMedicine1.getReceiptMedicineName()).isEqualTo("フローセン");
    assertThat(sysMedicine1.getRecordClass()).isEqualTo("4");
    assertThat(sysMedicine1.getSalesCompany()).isEqualTo("武田薬品");
    assertThat(sysMedicine1.getSalesName()).isEqualTo("フローセン");
    assertThat(sysMedicine1.getStandardMedicineCd()).isEqualTo("1112700X1038");
    assertThat(sysMedicine1.getStandardNo()).isEqualTo("1003031010101");
    assertThat(sysMedicine1.getStandardUnit()).isEqualTo("１ｍＬ");
    assertThat(sysMedicine1.getStandardUpDate()).isEqualTo("20100331");
    assertNull(sysMedicine1.getUnit());
    assertNull(sysMedicine1.getUnitConvertedAmount());
    assertNull(sysMedicine1.getUnitConvertedAmountSecond());
    assertNull(sysMedicine1.getUnitDecimalPoint());
    assertNull(sysMedicine1.getUnitDecimalPointSecond());
    assertNull(sysMedicine1.getUnitSecond());
    // 最終
    SysMedicine sysMedicine1_Last = result1.get(result1.size() - 1);
    assertThat(sysMedicine1_Last.getStandardNo()).isEqualTo("1003116010301");
    // 実行(2回目)
    offset = limit + 1;
    List<SysMedicine> result2 = sysMedicineDao.selectSysMedicineByLimitAndOffset(limit, offset, null);
    // 2回目の検証
    // 取得した1件目と最後のデータの基準番号(HOTコード)を確認
    assertThat(result2).hasSize(limit);
    SysMedicine sysMedicine2_First = result2.get(0);
    assertThat(sysMedicine2_First.getStandardNo()).isEqualTo("1003116030201");
    SysMedicine sysMedicine2_Last = result2.get(result2.size() - 1);
    assertThat(sysMedicine2_Last.getStandardNo()).isEqualTo("1003116050302");
  }
}
