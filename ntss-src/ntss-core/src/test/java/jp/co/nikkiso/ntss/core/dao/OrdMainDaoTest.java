package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import java.io.IOException;
import java.math.BigDecimal;

import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForWeightInd;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstWeightInfo;

/**
 * {@link OrdMainDao} のテストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql( "classpath:dao.script/OrdMainDaoTest.before.sql")
@Sql( "classpath:dao.script/OrdMainDaoTest.selectMstTreatmentByOrdNo.before.sql")
public class OrdMainDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  OrdMainDao target;


  /**
   * selectForWeightIndByOrdNo()の検証.
   * <p>
   *   条件：該当データなし
   *   結果：取得結果nullであること
   * </p>
   */
  @Test
  public void test_selectForWeightIndByOrdNo_正常_該当データなし() {

    Long ordNo = -1L;
    OrdMainForWeightInd result = target.selectForWeightIndByOrdNo(ordNo);

    assertThat(result, nullValue());
  }

  /**
   * selectForWeightIndByOrdNo()の検証.
   * <p>
   *   条件：該当データあり
   *   結果：想定した取得結果であること
   * </p>
   */
  @Test
  public void selectForWeightIndByOrdNo_() {

    Long ordNo = 999990L;
    OrdMainForWeightInd result = target.selectForWeightIndByOrdNo(ordNo);

    assertThat(result, notNullValue());
    assertThat(result.getOrdNo(), is(999990L));
    assertThat(result.getFacilityCd(), is("999900"));
  }

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * updateWeightInfoの検証
   * <p>
   *   条件：JSONをupdate
   *   結果：想定したJSONが作成されていること
   * </p>
   * @throws IOException
   */
  @Test
  public void test_updateWeightInfo_OK() throws IOException {
    Long ordNo = 999990L;
    // 前体重と前体重測定日時の保存
    OrdMainRstWeightInfo dto = new OrdMainRstWeightInfo();
    dto.setWeightBefore(BigDecimal.valueOf(50)); // 前体重
    dto.setWeightMeasureBefore(BigDecimal.valueOf(50)); // 前体重測定値
    dto.setWaterRemovalTarget(BigDecimal.valueOf(50)); // 目標除水量
    target.updateWeightInfo(ordNo, mapper.writeValueAsString(dto));

    // 対象オーダーの取得
    String weight2 = target.selectWeightInfo(ordNo);
    OrdMainRstWeightInfo result = weight2 == null || weight2.isEmpty() ? new OrdMainRstWeightInfo()
        : mapper.readValue(weight2, OrdMainRstWeightInfo.class);

    assertThat(result, notNullValue());
    assertThat(result.getWeightBefore(), is(BigDecimal.valueOf(50)));
    assertThat(result.getWeightMeasureBefore(), is(BigDecimal.valueOf(50)));
    assertThat(result.getWaterRemovalTarget(), is(BigDecimal.valueOf(50)));
  }

  /**
   * updateRstTareの検証
   * <p>
   *   条件：JSONをupdateしてマージさせたい
   *   結果：想定したJSONが作成されていること
   * </p>
   * @throws IOException
   */
  @Test
  public void test_updateTstTare_OK() throws IOException {
    Long ordNo = 999990L;

    // 車いす情報を実績に保存
    target.updateRstTare(ordNo, "{\"aaa\": {\"aaaa\": \"abc\", \"aaab\": 0}}");
    target.updateRstTare(ordNo, "{\"bbb\": {\"aaaa\": \"abc\", \"aaab\": 0}}");
    // 対象オーダーの取得
    OrdMainForWeightInd result = target.selectForWeightIndByOrdNo(ordNo);
    assertThat(result, notNullValue());
    JsonNode list = mapper.readTree(result.getRstTareInfo());

    // 機能種別(func_class)
    assertThat(list.get("aaa").get("aaaa").asText(), is("abc"));
    assertThat(list.get("aaa").get("aaab").asText(), is("0"));
    assertThat(list.get("bbb").get("aaaa").asText(), is("abc"));
    assertThat(list.get("bbb").get("aaab").asText(), is("0"));
  }

  /**
   * {@link OrdMainDao#selectMstTreatmentByOrdNo(Long)}の検証.
   * <p>
   *   条件:指示情報及び実績情報に治療方法コードが設定されている事.
   *   結果:実績情報登録されている治療方法コードに該当する治療方法マスタが取得される事.
   * </p>
   */
  @Test
  public void test_selectMstTreatmentByOrdNo_正常_指示情報及び実績情報に治療方法が登録されている場合() {
    // 事前準備
    Long ordNo = 1000L;

    // 実行
    MstTreatment result = target.selectMstTreatmentByOrdNo(ordNo);

    // 検証
    assertNotNull(result);
    assertThat(result.getTreatmentCd(), is(2));
    assertThat(result.getFacilityCd(), is("009999"));
    assertNull(result.getFnTreatmentCd());
    assertThat(result.getTreatmentName(), is("テスト治療方法2"));
    assertThat(result.getIsDel(), is("0"));
  }

  /**
   * {@link OrdMainDao#selectMstTreatmentByOrdNo(Long)}の検証.
   * <p>
   *   条件:実績情報に治療方法コードが設定されていない事.
   *   結果:指示情報に登録されている治療方法コードに該当する治療方法マスタが取得される事.
   * </p>
   */
  @Test
  public void test_selectMstTreatmentByOrdNo_正常_実績情報に治療方法が登録されていない場合() {
    // 事前準備
    Long ordNo = 1001L;

    // 実行
    MstTreatment result = target.selectMstTreatmentByOrdNo(ordNo);

    // 検証
    assertNotNull(result);
    assertThat(result.getTreatmentCd(), is(1));
    assertThat(result.getFacilityCd(), is("009999"));
    assertNull(result.getFnTreatmentCd());
    assertThat(result.getTreatmentName(), is("テスト治療方法1"));
    assertThat(result.getIsDel(), is("0"));
  }

  /**
   * {@link OrdMainDao#selectMstTreatmentByOrdNo(Long)}の検証.
   * <p>
   *   条件:指示情報に治療方法コードが未設定で実績情報に治療方法コードが設定されている事.
   *   結果:指示情報に登録されている治療方法コードに該当する治療方法マスタが取得される事.
   * </p>
   */
  @Test
  public void test_selectMstTreatmentByOrdNo_正常_指示情報に治療方法が登録されていない場合() {
    // 事前準備
    Long ordNo = 1002L;

    // 実行
    MstTreatment result = target.selectMstTreatmentByOrdNo(ordNo);

    // 検証
    assertNotNull(result);
    assertThat(result.getTreatmentCd(), is(3));
    assertThat(result.getFacilityCd(), is("009999"));
    assertNull(result.getFnTreatmentCd());
    assertThat(result.getTreatmentName(), is("テスト治療方法3"));
    assertThat(result.getIsDel(), is("0"));
  }

  /**
   * {@link OrdMainDao#selectMstTreatmentByOrdNo(Long)}の検証.
   * <p>
   *   条件:実績情報及び指示情報に治療方法コードが設定されていない事.
   *   結果:<code>null</code>が取得される事.
   * </p>
   */
  @Test
  public void test_selectMstTreatmentByOrdNo_正常_実績情報かつ指示情報に治療方法が登録されていない場合() {
    // 事前準備
    Long ordNo = 1003L;

    // 実行
    MstTreatment result = target.selectMstTreatmentByOrdNo(ordNo);

    // 検証
    assertNull(result);
  }

  /**
   * {@link OrdMainDao#selectMstTreatmentByOrdNo(Long)}の検証.
   * <p>
   *   条件:実績情報に登録されている治療方法コードに該当する治療方法マスタが削除されている事.
   *   結果:<code>null</code>が取得される事.
   * </p>
   */
  @Test
  public void test_selectMstTreatmentByOrdNo_正常_実績情報の治療方法が削除されている場合() {
    // 事前準備
    Long ordNo = 1004L;

    // 実行
    MstTreatment result = target.selectMstTreatmentByOrdNo(ordNo);

    // 検証
    assertNotNull(result);
    assertThat(result.getTreatmentCd(), is(4));
    assertThat(result.getFacilityCd(), is("009999"));
    assertNull(result.getFnTreatmentCd());
    assertThat(result.getTreatmentName(), is("テスト治療方法4"));
    assertThat(result.getIsDel(), is("1"));
  }

  /**
   * {@link OrdMainDao#selectMstTreatmentByOrdNo(Long)}の検証.
   * <p>
   *   条件:指示情報に登録されている治療方法コードに該当する治療方法マスタが削除されている事.
   *       実績情報には治療方法が未登録である事.
   *   結果:<code>null</code>が取得される事.
   * </p>
   */
  @Test
  public void test_selectMstTreatmentByOrdNo_正常_実績情報の治療方法が未登録で指示情報の治療方法が削除されている場合() {
    // 事前準備
    Long ordNo = 1006L;

    // 実行
    MstTreatment result = target.selectMstTreatmentByOrdNo(ordNo);

    // 検証
    assertNotNull(result);
    assertThat(result.getTreatmentCd(), is(5));
    assertThat(result.getFacilityCd(), is("009999"));
    assertNull(result.getFnTreatmentCd());
    assertThat(result.getTreatmentName(), is("テスト治療方法5"));
    assertThat(result.getIsDel(), is("1"));
  }

  /**
   * {@link OrdMainDao#selectMstTreatmentByOrdNo(Long)}の検証.
   * <p>
   *   条件:指定されているオーダ番号のオーダが作成されている事.
   *   結果:<code>null</code>が取得される事.
   * </p>
   */
  @Test
  public void test_selectMstTreatmentByOrdNo_異常_オーダが削除されている場合() {
    // 事前準備
    Long ordNo = 1005L;

    // 実行
    MstTreatment result = target.selectMstTreatmentByOrdNo(ordNo);

    // 検証
    assertNull(result);
  }

  /**
   * {@link OrdMainDao#selectMstTreatmentByOrdNo(Long)}の検証.
   * <p>
   *   条件:指定されているオーダ番号のオーダが存在しない事.
   *   結果:<code>null</code>が取得される事.
   * </p>
   */
  @Test
  public void test_selectMstTreatmentByOrdNo_異常_オーダが存在しない場合() {
    // 事前準備
    Long ordNo = -1L;

    // 実行
    MstTreatment result = target.selectMstTreatmentByOrdNo(ordNo);

    // 検証
    assertNull(result);
  }
}
