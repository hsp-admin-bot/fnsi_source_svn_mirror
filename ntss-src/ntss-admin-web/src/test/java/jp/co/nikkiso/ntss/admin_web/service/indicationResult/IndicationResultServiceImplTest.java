package jp.co.nikkiso.ntss.admin_web.service.indicationResult;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.core.dao.IndicationResultDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.IndicationResult;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.PatMain;

@RunWith(SpringRunner.class)
@SpringBootTest
public class IndicationResultServiceImplTest {

  /**
   * テスト対象クラス
   */
  @Autowired
  private IndicationResultService target;

  /**
   * 予実リストDaoのMockBean.
   */
  @MockBean
  private IndicationResultDao indicationResultDao;

  /**
   * 利用者マスタのDaoのMockBean.
   */
  @MockBean
  private MstUserDao mstUserDao;

  /**
   * クールマスタのMockBean.
   */
  @MockBean
  private MstKurDao mstKurDao;

  /**
   * ベッドマスタのMockBean.
   */
  @MockBean
  private MstBedDao mstBedDao;

  /**
   * 治療方法マスタのMockBean.
   */
  @MockBean
  private MstTreatmentDao mstTreatmentDao;

  /**
   * 患者基本情報のMockBean.
   */
  @MockBean
  private PatMainDao patMainDao;

  /**
   * 例外の発生をテストするためのルール
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * getList()の検証.
   *
   * 条件：指定された患者IDに該当する予実リストが存在する
   * 結果：予実リストエンティティのリストが返却されること
   */
  @Test
  public void test_getList_成功_データあり() {
    // 事前準備
    Long patId = 10L;
    String treatDateFrom = "20190610";
    String treatDateTo = "20190620";
    List<IndicationResult> indicationResultList = Arrays.asList(
      new IndicationResult(),
      new IndicationResult()
    );

    PatMain patMain = new PatMain();
    String facilityCd = "009999";
    patMain.setFacility_cd(facilityCd);
    SelectOptions selectOptions = SelectOptions.get();
    List<MstKur> mstKurList = Arrays.asList(
        new MstKur(),
        new MstKur()
    );

    List<MstBed> mstBedList = Arrays.asList(
        new MstBed(),
        new MstBed()
    );

    MstTreatment mstTreatmentSearchData = new MstTreatment();
    mstTreatmentSearchData.setFacilityCd(facilityCd);
    List<MstTreatment> mstTreatmentList = Arrays.asList(
        new MstTreatment(),
        new MstTreatment()
    );

    IndicationResult indicationResult = new IndicationResult();
    indicationResult.setKurStartTime("000000");
    indicationResult.setKurName("クール未登録");
    indicationResult.setBedName("ベッド未登録");
    indicationResult.setTreatmentName("治療方法未登録");
    List<IndicationResult> expected = Arrays.asList(
        indicationResult,
        indicationResult
      );

    // Mock化
    given(indicationResultDao.selectByPatIdAndTreatDate(patId, treatDateFrom, treatDateTo,null)).willReturn(indicationResultList);
    given(patMainDao.selectById(patId)).willReturn(patMain);
    given(mstKurDao.selectByFacilityCd(selectOptions, facilityCd, "0")).willReturn(mstKurList);
    given(mstBedDao.selectAll(selectOptions)).willReturn(mstBedList);
    given(mstTreatmentDao.selectAll(selectOptions, mstTreatmentSearchData)).willReturn(mstTreatmentList);

    // 実行
    List<IndicationResult> result = target.getList(patId, treatDateFrom, treatDateTo, "");

    // 検証
    verify(indicationResultDao, times(1)).selectByPatIdAndTreatDate(patId, treatDateFrom, treatDateTo,null);
    assertThat(result, hasSize(2));
    assertThat(result, is(expected));
  }

  /**
   * getList()の検証.
   *
   * 条件：指定された患者IDに該当する予実リストが存在しない
   * 結果：空のリストが返却されること
   */
  @Test
  public void test_getList_成功_データなし() {
    // 事前準備
    Long patId = 10L;
    String treatDateFrom = "20190610";
    String treatDateTo = "20190620";
    List<IndicationResult> indicationResultList = Collections.emptyList();

    PatMain patMain = new PatMain();
    String facilityCd = "009999";
    patMain.setFacility_cd(facilityCd);
    SelectOptions selectOptions = SelectOptions.get();
    List<MstKur> mstKurList = Arrays.asList(
        new MstKur(),
        new MstKur()
    );

    List<MstBed> mstBedList = Arrays.asList(
        new MstBed(),
        new MstBed()
    );

    MstTreatment mstTreatmentSearchData = new MstTreatment();
    mstTreatmentSearchData.setFacilityCd(facilityCd);
    List<MstTreatment> mstTreatmentList = Arrays.asList(
        new MstTreatment(),
        new MstTreatment()
    );

    // Mock化
    given(indicationResultDao.selectByPatIdAndTreatDate(patId, treatDateFrom, treatDateTo,null)).willReturn(indicationResultList);
    given(patMainDao.selectById(patId)).willReturn(patMain);
    given(mstKurDao.selectByFacilityCd(selectOptions, facilityCd, "0")).willReturn(mstKurList);
    given(mstBedDao.selectAll(selectOptions)).willReturn(mstBedList);
    given(mstTreatmentDao.selectAll(selectOptions, mstTreatmentSearchData)).willReturn(mstTreatmentList);

    // 実行
    List<IndicationResult> result = target.getList(patId, treatDateFrom, treatDateTo, "");

    // 検証
    verify(indicationResultDao, times(1)).selectByPatIdAndTreatDate(patId, treatDateFrom, treatDateTo,null);
    assertThat(result, hasSize(0));
  }

}
