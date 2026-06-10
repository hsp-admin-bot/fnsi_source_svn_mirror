package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

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

import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;

/**
 * {@link PatObsRecDao} のテストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql( "classpath:dao.script/OrdWeightScaleDaoTest.before.sql")
public class OrdWeightScaleDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  OrdWeightScaleDao target;


  /**
   * selectByCd()の検証.
   * <p>
   *   条件：該当データなし
   *   結果：取得結果nullであること
   * </p>
   */
  @Test
  public void test_selectByCd_正常_該当データなし() {

    Long weightScaleNo = -1L;
    OrdWeightScale result = target.selectByCd(weightScaleNo);

    assertThat(result, nullValue());
  }

  /**
   * selectByCd()の検証.
   * <p>
   *   条件：該当データあり
   *   結果：想定した取得結果であること
   * </p>
   */
  @Test
  public void test_selectByCd_正常_該当データあり() {

    Long weightScaleNo = 9999L;
    OrdWeightScale result = target.selectByCd(weightScaleNo);

    assertThat(result, notNullValue());
    assertThat(result.getWeightScaleNo(), is(9999L));
    assertThat(result.getOrdNo(), is(0L));
    assertThat(result.getFacilityCd(), is("wstest"));
    assertThat(result.getWeightCd(), is(0L));
    assertThat(result.getWeightName(), is("test"));
    assertThat(result.getMachineNo(), is(0L));
    assertThat(result.getMachineName(), is("test"));
    assertThat(result.getWeightScaleStatus(), is((short)0));
    assertThat(result.getMessage(), is("test"));
    assertThat(result.getMeasureDate(), is(Timestamp.valueOf("2000-01-01 00:00:00")));
    assertThat(result.getKurCd(), is(0L));
    assertThat(result.getKurName(), is("test"));
    assertThat(result.getBedCd(), is(0L));
    assertThat(result.getBedName(), is("test"));
    assertThat(result.getPatId(), is(0L));
    assertThat(result.getScaleClass(), is((short)0));
    assertThat(result.getScaleMode(), is((short)0));
    assertThat(result.getScaleValue(), is(new BigDecimal("51.50")));
    assertThat(result.getRstTareInfo(), is("{}"));
    assertThat(result.getRstOffWaterInfo(), is("{}"));
    assertThat(result.getWeightValue(), is(new BigDecimal("51.000")));
    assertThat(result.getTargetWeightValue(), is(new BigDecimal("50.000")));
    assertThat(result.getOffWaterLimit(), is(new BigDecimal("2.500")));
    assertThat(result.getWheelChairCd(), is(0L));
    assertThat(result.getWheelChairName(), is("test"));
    assertThat(result.getWheelChairWeight(), is(new BigDecimal("10000")));
    assertThat(result.getUserId(), is(0L));
  }

  /**
   * selectByFacility() の検証
   * <p>
   *   条件:該当データなし
   *   結果:取得結果が空配列であること
   * </p>
   */
  @Test
  public void selectByFacility_正常_該当データなし() {

    String facilityCd = "";
    Timestamp startDate = null;
    Timestamp endDate = null;
    List<OrdWeightScale> result = target.selectByFacility(facilityCd, startDate, endDate);

    assertThat(result.size(), is(0));
  }

  /**
   * selectByFacility() の検証
   * <p>
   *   条件：該当データあり
   *   結果：取得結果が測定微降順であること
   * </p>
   */
  @Test
  public void selectByFacility_正常_該当データあり() {

    String facilityCd = "wstest";
    Timestamp startDate = Timestamp.valueOf("2000-01-01 00:00:00");
    Timestamp endDate = Timestamp.valueOf("2000-01-08 00:00:00");
    List<OrdWeightScale> result = target.selectByFacility(facilityCd, startDate, endDate);

    // 検証
    assertThat(result.size(), is(2));
    assertThat(result.get(0).getWeightScaleNo(), is(10000L));
    assertThat(result.get(0).getOrdNo(), is(0L));
    assertThat(result.get(0).getFacilityCd(), is("wstest"));
    assertThat(result.get(0).getWeightCd(), is(0L));
    assertThat(result.get(0).getWeightName(), is("test"));
    assertThat(result.get(0).getMachineNo(), is(0L));
    assertThat(result.get(0).getMachineName(), is("test"));
    assertThat(result.get(0).getWeightScaleStatus(), is((short)0));
    assertThat(result.get(0).getMessage(), is("test"));
    assertThat(result.get(0).getMeasureDate(), is(Timestamp.valueOf("2000-01-02 00:00:00")));
    assertThat(result.get(0).getKurCd(), is(0L));
    assertThat(result.get(0).getKurName(), is("test"));
    assertThat(result.get(0).getBedCd(), is(0L));
    assertThat(result.get(0).getBedName(), is("test"));
    assertThat(result.get(0).getPatId(), is(0L));
    assertThat(result.get(0).getScaleClass(), is((short)0));
    assertThat(result.get(0).getScaleMode(), is((short)0));
    assertThat(result.get(0).getScaleValue(), is(new BigDecimal("51.50")));
    assertThat(result.get(0).getRstTareInfo(), is("{}"));
    assertThat(result.get(0).getRstOffWaterInfo(), is("{}"));
    assertThat(result.get(0).getWeightValue(), is(new BigDecimal("51.000")));
    assertThat(result.get(0).getTargetWeightValue(), is(new BigDecimal("50.000")));
    assertThat(result.get(0).getOffWaterLimit(), is(new BigDecimal("2.500")));
    assertThat(result.get(0).getWheelChairCd(), is(0L));
    assertThat(result.get(0).getWheelChairName(), is("test"));
    assertThat(result.get(0).getWheelChairWeight(), is(new BigDecimal("10000")));
    assertThat(result.get(0).getUserId(), is(0L));
    assertThat(result.get(1).getWeightScaleNo(), is(9999L));
    assertThat(result.get(1).getMeasureDate(), is(Timestamp.valueOf("2000-01-01 00:00:00")));
  }

  /**
   * updatePrintStatus()の検証.
   * <p>
   *   条件：既存のデータに印刷結果を更新する
   *   結果：印刷結果のみが更新されること
   * </p>
   */
  @Test
  public void test_updatePrintStatus_正常_該当データあり() {

    Long weightScaleNo = 9999L;

    OrdWeightScale upd = new OrdWeightScale();
    String dummyPrintContent = "dummy";
    String dummyPrintMessage = "dummy";
    upd.setWeightScaleNo(weightScaleNo);
    upd.setPrintContent(dummyPrintContent);
    upd.setPrintErrorMessage(dummyPrintMessage);
    upd.setPrintStatus(1);

    int r = target.updatePrintStatus(upd);
    assertThat(r, is(1));

    OrdWeightScale result = target.selectByCd(weightScaleNo);
    assertThat(result, notNullValue());
    assertThat(result.getWeightScaleNo(), is(9999L));
    assertThat(result.getOrdNo(), is(0L));
    assertThat(result.getFacilityCd(), is("wstest"));
    assertThat(result.getWeightCd(), is(0L));
    assertThat(result.getWeightName(), is("test"));
    assertThat(result.getMachineNo(), is(0L));
    assertThat(result.getMachineName(), is("test"));
    assertThat(result.getWeightScaleStatus(), is((short)0));
    assertThat(result.getMessage(), is("test"));
    assertThat(result.getMeasureDate(), is(Timestamp.valueOf("2000-01-01 00:00:00")));
    assertThat(result.getKurCd(), is(0L));
    assertThat(result.getKurName(), is("test"));
    assertThat(result.getBedCd(), is(0L));
    assertThat(result.getBedName(), is("test"));
    assertThat(result.getPatId(), is(0L));
    assertThat(result.getScaleClass(), is((short)0));
    assertThat(result.getScaleMode(), is((short)0));
    assertThat(result.getScaleValue(), is(new BigDecimal("51.50")));
    assertThat(result.getRstTareInfo(), is("{}"));
    assertThat(result.getRstOffWaterInfo(), is("{}"));
    assertThat(result.getWeightValue(), is(new BigDecimal("51.000")));
    assertThat(result.getTargetWeightValue(), is(new BigDecimal("50.000")));
    assertThat(result.getOffWaterLimit(), is(new BigDecimal("2.500")));
    assertThat(result.getWheelChairCd(), is(0L));
    assertThat(result.getWheelChairName(), is("test"));
    assertThat(result.getWheelChairWeight(), is(new BigDecimal("10000")));
    assertThat(result.getUserId(), is(0L));
    assertThat(result.getPrintStatus(), is(1));
    assertThat(result.getPrintContent(), is(nullValue()));
    assertThat(result.getPrintErrorMessage(), is(dummyPrintMessage));
  }


}
