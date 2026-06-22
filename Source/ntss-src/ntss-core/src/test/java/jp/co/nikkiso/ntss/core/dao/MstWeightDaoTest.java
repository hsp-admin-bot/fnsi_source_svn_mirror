package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MstWeight;

/**
 * {@link MstWeightDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql( "classpath:dao.script/MstWeightDaoTest.before.sql")
public class MstWeightDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  MstWeightDao target;


  /**
   * selectByWeightCd()の検証.
   * <p>
   *   条件：該当データなし
   *   結果：取得結果nullであること
   * </p>
   */
  @Test
  public void test_selectByWeightCd_正常_該当データなし() {

    // 事前準備
    Long obsRecNo = -1L;
    // 実行
    MstWeight result = target.selectByWeightCd(obsRecNo);

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
    Long obsRecNo = 0L;
    // 実行
    MstWeight result = target.selectByWeightCd(obsRecNo);

    // 検証
    assertThat(result, notNullValue());
    assertThat(result.getFacilityCd(), is("mwtest"));
    assertThat(result.getPortName(), is("COM1"));
    assertThat(result.getDeviceClass(), is((short)0));
    assertThat(result.getIsAutoSendBefore(), is("0"));
    assertThat(result.getIsAutoSendAfter(), is("0"));
    assertThat(result.getWaitAutoSendBefore(), is((short)0));
    assertThat(result.getWaitAutoSendAfter(), is((short)0));
    assertThat(result.getIsDefaultPrintBefore(), is("0"));
    assertThat(result.getIsDefaultPrintAfter(), is("0"));
    assertThat(result.getPrinterClass(), is((short)0));
    assertThat(result.getBedGroupCd(), is(0));
    assertThat(result.getIsHasCardReader(), is("0"));
    assertThat(result.getCheckContent(), is("{}"));
    assertThat(result.getPrintSetting(), is("{}"));
    assertThat(result.getColorSetting(), is("{}"));
    assertThat(result.getAudioSetting(), is("{}"));
    assertThat(result.getIsDisp(), is("1"));
    assertThat(result.getIsDel(), is("0"));
  }

  /**
   * selectByFacility() の検証
   * <p>
   *   条件:該当データなし
   *   結果:取得結果が空配列であること
   * </p>
   */
  @Test
  public void test_selectByFacility_正常_該当データなし() {

    // 事前準備
    String facilityCd = "------";
    // 実行
    List<MstWeight> result = target.selectByFacility(facilityCd);

    // 検証
    assertThat(result.size(), is(0));
  }

  /**
   * selectByFacility() の検証
   * <p>
   *   条件:該当データなし
   *   結果:取得結果が正しいこと
   * </p>
   */
  @Test
  public void test_selectByFacility_正常_該当データあり() {

    // 事前準備
    String facilityCd = "mwtest";
    // 実�?
    List<MstWeight> result = target.selectByFacility(facilityCd);

    // 検証
    assertThat(result.size(), is(1));
    assertThat(result.get(0).getFacilityCd(), is("mwtest"));
    assertThat(result.get(0).getPortName(), is("COM1"));
    assertThat(result.get(0).getDeviceClass(), is((short)0));
    assertThat(result.get(0).getIsAutoSendBefore(), is("0"));
    assertThat(result.get(0).getIsAutoSendAfter(), is("0"));
    assertThat(result.get(0).getWaitAutoSendBefore(), is((short)0));
    assertThat(result.get(0).getWaitAutoSendAfter(), is((short)0));
    assertThat(result.get(0).getIsDefaultPrintBefore(), is("0"));
    assertThat(result.get(0).getIsDefaultPrintAfter(), is("0"));
    assertThat(result.get(0).getPrinterClass(), is((short)0));
    assertThat(result.get(0).getBedGroupCd(), is(0));
    assertThat(result.get(0).getIsHasCardReader(), is("0"));
    assertThat(result.get(0).getCheckContent(), is("{}"));
    assertThat(result.get(0).getPrintSetting(), is("{}"));
    assertThat(result.get(0).getColorSetting(), is("{}"));
    assertThat(result.get(0).getAudioSetting(), is("{}"));
    assertThat(result.get(0).getIsDisp(), is("1"));
    assertThat(result.get(0).getIsDel(), is("0"));
  }


}
