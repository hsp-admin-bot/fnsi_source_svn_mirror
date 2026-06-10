package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordAddition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordCondition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordDeviceSetInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordEquipInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMediInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMonitor;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResult;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResultMerge;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordRoundsInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordVersionInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordVitalMonitor;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordWeight;
import org.assertj.core.api.Assertions;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

import static org.assertj.core.api.Assertions.tuple;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.not;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertThat;

/**
 * {@link TreatmentRecordDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/TreatmentRecordDaoTest.before.sql")
public class TreatmentRecordDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private TreatmentRecordDao target;

  /**
   * 治療情報DAO.
   */
  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * selectTreatmentRecordResultByOrdNo()の検証.
   * <p>
   * 条件：該当データなし
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void test_selectTreatmentRecordByOrdNo_異常_該当データなし() {

    // 事前準備
    Long ordNo = 10L;

    // 実行
    target.selectTreatmentRecordResultByOrdNo(ordNo);
  }

  /**
   * selectTreatmentRecordResultByOrdNo()の検証.
   * <p>
   * 条件：該当データが削除済み
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void test_selectTreatmentRecordByOrdNo_異常_該当データ削除済み() {

    // 事前準備
    Long ordNo = 12L;

    // 実行
    target.selectTreatmentRecordResultByOrdNo(ordNo);
  }

  /**
   * selectTreatmentRecordResultByOrdNo()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  public void test_selectTreatmentRecordByOrdNo_正常_該当データあり() {

    // 事前準備
    Long ordNo = 1L;

    // 実行
    TreatmentRecordResult result = target.selectTreatmentRecordResultByOrdNo(ordNo);

    // 検証
    assertThat(result, notNullValue());
    assertThat(result.getOrdNo(), is(1L));
    assertThat(result.getPatId(), is(2L));
    assertThat(result.getFnPatId(), is("00003"));
    assertThat(result.getTreatDate(), is("20190213"));
    assertThat(result.getTreatWeek(), is((short) 1));
    assertThat(result.getFacilityCd(), is("009999"));
    assertThat(result.getFacilityName(), is("テスト施設名"));
    assertThat(result.getRstDialysisState(), is("3"));
    assertThat(result.getRstKurCd(), is(11L));
    assertThat(result.getRstKurName(), is("クール1"));
    assertThat(result.getRstBedCd(), is(12L));
    assertThat(result.getRstBedName(), is("ベッド1"));
    assertThat(result.getRstStartDate(), is(Timestamp.valueOf("2019-02-13 12:00:00")));
    assertThat(result.getRstEndDate(), is(Timestamp.valueOf("2019-02-13 18:00:00")));
    assertThat(result.getRstInOutClass(), is((short) 1));
    assertThat(result.getRstDialysisCnt(), is(2));
    assertThat(result.getRstWardCd(), is(13));
    assertThat(result.getRstWardName(), is("病棟名1"));
    assertThat(result.getRstCourseCd(), is(14));
    assertThat(result.getRstCourseName(), is("診療科名1"));
    assertThat(result.getRstPunctureUserInfo().getUserId1(), is(101L));
    assertThat(result.getRstPunctureUserInfo().getUserLastName1(), is("穿刺1"));
    assertThat(result.getRstPunctureUserInfo().getUserFirstName1(), is("太郎"));
    assertThat(result.getRstPunctureUserInfo().getUserId2(), is(102L));
    assertThat(result.getRstPunctureUserInfo().getUserLastName2(), is("穿刺2"));
    assertThat(result.getRstPunctureUserInfo().getUserFirstName2(), is("次郎"));
    assertThat(result.getRstPunctureUserInfo().getDate(), is(Timestamp.valueOf("2019-02-13 13:00:00")));
    assertThat(result.getRstPunctureUserInfo().getDate1(), is(Timestamp.valueOf("2019-02-13 13:01:00")));
    assertThat(result.getRstPunctureUserInfo().getDate2(), is(Timestamp.valueOf("2019-02-13 13:02:00")));
    assertThat(result.getRstReturnUserInfo().getUserId1(), is(103L));
    assertThat(result.getRstReturnUserInfo().getUserLastName1(), is("返血1"));
    assertThat(result.getRstReturnUserInfo().getUserFirstName1(), is("太郎"));
    assertThat(result.getRstReturnUserInfo().getUserId2(), is(104L));
    assertThat(result.getRstReturnUserInfo().getUserLastName2(), is("返血2"));
    assertThat(result.getRstReturnUserInfo().getUserFirstName2(), is("次郎"));
    assertThat(result.getRstReturnUserInfo().getDate(), is(Timestamp.valueOf("2019-02-13 13:30:00")));
    assertThat(result.getRstReturnUserInfo().getDate1(), is(Timestamp.valueOf("2019-02-13 13:31:00")));
    assertThat(result.getRstReturnUserInfo().getDate2(), is(Timestamp.valueOf("2019-02-13 13:32:00")));
    assertThat(result.getRstChargeUserInfo().getUserId1(), is(105L));
    assertThat(result.getRstChargeUserInfo().getUserLastName1(), is("担当1"));
    assertThat(result.getRstChargeUserInfo().getUserFirstName1(), is("太郎"));
    assertThat(result.getRstChargeUserInfo().getUserId2(), is(106L));
    assertThat(result.getRstChargeUserInfo().getUserLastName2(), is("担当2"));
    assertThat(result.getRstChargeUserInfo().getUserFirstName2(), is("次郎"));
    assertThat(result.getRstChargeUserInfo().getDate1(), is(Timestamp.valueOf("2019-02-13 14:01:00")));
    assertThat(result.getRstChargeUserInfo().getDate2(), is(Timestamp.valueOf("2019-02-13 14:02:00")));
    assertThat(result.getUpDate(), is(Timestamp.valueOf("2019-02-13 14:30:00")));
    assertThat(result.getRegDate(), is(Timestamp.valueOf("2019-02-13 14:00:00")));
    assertThat(result.getRstTreatmentCd(), is(100));
    assertThat(result.getRstTreatmentName(), is("テスト治療方法１"));
  }

  /**
   * updateTreatmentRecordForResult()の検証.
   * <p>
   * 条件：治療記録(実績情報)画面の入力項目に該当する項目を更新する.
   * 結果：該当データを更新できること(更新対象外項目は更新されていないこと)
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForResult_正常() {

    // 事前準備
    Long ordNo = 9001L;
    TreatmentRecordResult entity = target.selectTreatmentRecordResultByOrdNo(ordNo);

    // 実行
    entity.setRstKurCd(9901L);
    entity.setRstKurName("クール9901");
    entity.setRstBedCd(9902L);
    entity.setRstBedName("ベッド9902");
    entity.setRstStartDate(Timestamp.valueOf("2019-04-01 00:00:01"));
    entity.setRstEndDate(Timestamp.valueOf("2019-04-01 00:01:01"));
    entity.setRstInOutClass((short) 9);
    entity.setRstDialysisCnt(9905);
    entity.setRstWardCd(9906);
    entity.setRstWardName("病棟名9906");
    entity.setRstCourseCd(9907);
    entity.setRstCourseName("診療科名9907");
    entity.getRstPunctureUserInfo().setUserId1(9908L);
    entity.getRstPunctureUserInfo().setUserLastName1("穿刺9908");
    entity.getRstPunctureUserInfo().setUserFirstName1("太郎9908");
    entity.getRstPunctureUserInfo().setUserId2(9909L);
    entity.getRstPunctureUserInfo().setUserLastName2("穿刺9909");
    entity.getRstPunctureUserInfo().setUserFirstName2("太郎9909");
    entity.getRstPunctureUserInfo().setDate("2019-04-02 00:01:01");
    entity.getRstPunctureUserInfo().setDate1(Timestamp.valueOf("2019-04-02 00:02:01"));
    entity.getRstPunctureUserInfo().setDate2(Timestamp.valueOf("2019-04-02 00:03:01"));
    entity.getRstReturnUserInfo().setUserId1(9910L);
    entity.getRstReturnUserInfo().setUserLastName1("返血9910");
    entity.getRstReturnUserInfo().setUserFirstName1("太郎9910");
    entity.getRstReturnUserInfo().setUserId2(9911L);
    entity.getRstReturnUserInfo().setUserLastName2("返血9911");
    entity.getRstReturnUserInfo().setUserFirstName2("太郎9911");
    entity.getRstReturnUserInfo().setDate("2019-04-03 00:01:01");
    entity.getRstReturnUserInfo().setDate1(Timestamp.valueOf("2019-04-03 00:02:01"));
    entity.getRstReturnUserInfo().setDate2(Timestamp.valueOf("2019-04-03 00:03:01"));
    entity.getRstChargeUserInfo().setUserId1(9912L);
    entity.getRstChargeUserInfo().setUserLastName1("担当9912");
    entity.getRstChargeUserInfo().setUserFirstName1("太郎9912");
    entity.getRstChargeUserInfo().setUserId2(9913L);
    entity.getRstChargeUserInfo().setUserLastName2("担当9913");
    entity.getRstChargeUserInfo().setUserFirstName2("太郎9913");
    entity.getRstChargeUserInfo().setDate1(Timestamp.valueOf("2019-04-04 00:01:01"));
    entity.getRstChargeUserInfo().setDate2(Timestamp.valueOf("2019-04-04 00:02:01"));
    // 治療方法コード
    entity.setRstTreatmentCd(1102);
    // 治療方法名
    entity.setRstTreatmentName("テスト治療法（更新）");

    int updateCount = target.updateTreatmentRecordForResult(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証(更新対象項目)
    TreatmentRecordResult updatedEntity = target.selectTreatmentRecordResultByOrdNo(ordNo);
    assertEquals(entity, updatedEntity);

    // 検証(更新対象外項目)
    assertThat(entity.getOrdNo(), is(ordNo));
    assertThat(entity.getPatId(), is(3L));
    assertThat(entity.getFnPatId(), is("90003"));
    assertThat(entity.getTreatDate(), is("20190201"));
    assertThat(entity.getTreatWeek(), is((short)1));
    assertThat(entity.getFacilityCd(), is("009990"));
    assertThat(entity.getFacilityName(), is("テスト施設名９９９０"));
    assertThat(entity.getRegDate(), is(Timestamp.valueOf("2019-02-04 14:00:00.000")));
    assertThat(entity.getRstPunctureUserInfo().getDate(), is(Timestamp.valueOf("2019-04-02 00:01:01")));
    assertThat(entity.getRstPunctureUserInfo().getDate1(), is(Timestamp.valueOf("2019-04-02 00:02:01")));
    assertThat(entity.getRstPunctureUserInfo().getDate2(), is(Timestamp.valueOf("2019-04-02 00:03:01")));
    assertThat(entity.getRstReturnUserInfo().getDate(), is(Timestamp.valueOf("2019-04-03 00:01:01")));
    assertThat(entity.getRstReturnUserInfo().getDate1(), is(Timestamp.valueOf("2019-04-03 00:02:01")));
    assertThat(entity.getRstReturnUserInfo().getDate2(), is(Timestamp.valueOf("2019-04-03 00:03:01")));
    assertThat(entity.getRstChargeUserInfo().getDate1(), is(Timestamp.valueOf("2019-04-04 00:01:01")));
    assertThat(entity.getRstChargeUserInfo().getDate2(), is(Timestamp.valueOf("2019-04-04 00:02:01")));
    assertThat(entity.getRstTreatmentCd(), is(1102));
    assertThat(entity.getRstTreatmentName(), is("テスト治療法（更新）"));
  }

  /**
   * updateTreatmentRecordForResult()の検証.
   * <p>
   * 条件：存在しないレコードを更新する
   * 結果：更新件数０件であること
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForResult_異常_存在しないレコード更新() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordResult entity = target.selectTreatmentRecordResultByOrdNo(ordNo);

    // 実行
    Long notFoundOrdNo = 99999L;
    entity.setOrdNo(notFoundOrdNo);
    entity.setRstKurCd(9901L);
    entity.setRstKurName("クール9901");
    entity.setRstBedCd(9902L);
    entity.setRstBedName("ベッド9902");
    entity.setRstStartDate(Timestamp.valueOf("2019-04-01 00:00:01"));
    entity.setRstEndDate(Timestamp.valueOf("2019-04-01 00:01:01"));
    entity.setRstInOutClass((short) 9);
    entity.setRstDialysisCnt(9905);
    entity.setRstWardCd(9906);
    entity.setRstWardName("病棟名9906");
    entity.setRstCourseCd(9907);
    entity.setRstCourseName("診療科名9907");
    // 治療方法コード
    entity.setRstTreatmentCd(999);
    entity.setRstTreatmentName("テスト治療法９９９");
    // 治療方法名
    entity.setRstPunctureUserInfo(null);
    entity.setRstReturnUserInfo(null);
    entity.setRstChargeUserInfo(null);
    entity.setUpDate(null);

    int count = target.updateTreatmentRecordForResult(notFoundOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForResult()の検証.
   * <p>
   * 条件：削除済レコードを更新する
   * 結果：更新件数０件であること
   * </p>
   */
  @Test
  public void test_updateTreatmnetRecordForResult_異常_削除済レコード更新() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordResult entity = target.selectTreatmentRecordResultByOrdNo(ordNo);

    // 実行
    Long deletedOrdNo = 9002L;
    entity.setOrdNo(deletedOrdNo);
    entity.setRstKurCd(9901L);
    entity.setRstKurName("クール9901");
    entity.setRstBedCd(9902L);
    entity.setRstBedName("ベッド9902");
    entity.setRstStartDate(Timestamp.valueOf("2019-04-01 00:00:01"));
    entity.setRstEndDate(Timestamp.valueOf("2019-04-01 00:01:01"));
    entity.setRstInOutClass((short) 9);
    entity.setRstDialysisCnt(9905);
    entity.setRstWardCd(9906);
    entity.setRstWardName("病棟名9906");
    entity.setRstCourseCd(9907);
    entity.setRstCourseName("診療科名9907");
    // 治療方法コード
    entity.setRstTreatmentCd(999);
    // 治療方法名
    entity.setRstTreatmentName("テスト治療方法９９９");
    entity.setRstPunctureUserInfo(null);
    entity.setRstReturnUserInfo(null);
    entity.setRstChargeUserInfo(null);
    entity.setUpDate(null);

    int count = target.updateTreatmentRecordForResult(deletedOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForResult()の検証.
   * <p>
   * 条件：過去実績のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されること.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForResult_正常_版番号_版番号更新フラグ_更新する() {

    // 事前準備
    Long ordNo = 100001L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("6"));

    // 実行
    TreatmentRecordResult entity = target.selectTreatmentRecordResultByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordForResult(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("6"));
    // 検証：確定フラグが更新されていない事
    assertThat(updated.getIsConfirm(), is("0"));
  }

  /**
   * updateTreatmentRecordForResult()の検証.
   * <p>
   * 条件：過去実績以外のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されないこと.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForResult_正常_版番号_版番号更新フラグ_更新しない() {

    // 事前準備
    Long ordNo = 100002L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("1"));

    // 実行
    TreatmentRecordResult entity = target.selectTreatmentRecordResultByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordForResult(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("1"));
  }

  /**
   * selectTreatmentRecordMediInfoByOrdNo()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordMediInfoByOrdNo.before.sql")
  public void test_selectTreatmentRecordMediInfoByOrdNo_正常_該当データあり() {
    // arrange
    final long ordNo = 1L;

    // action
    TreatmentRecordMediInfo result = target.selectTreatmentRecordMediInfoByOrdNo(ordNo);

    // assert
    assertThat(result.getOrdNo(), is(1L));
    assertThat(result.getTreatDate(), is("20190201"));
    assertThat(result.getRstDialysisState(), is("0"));
    assertThat(result.getRstStartDate(), is(Timestamp.valueOf("2019-03-01 12:00:00")));
    // JSONの項目が多いので、文字列で取得できることのみを確認。個々のプロパティのチェックは行わない
    assertThat(result.getRstMediInfo(), is("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]"));
    assertThat(result.getUpDate(), is(Timestamp.valueOf("2019-03-01 13:00:00")));
    assertThat(result.getRegDate(), is(Timestamp.valueOf("2019-03-01 13:10:00")));
  }

  /**
   * selectTreatmentRecordConditionByOrdNo()の検証.
   * <p>
   * 条件：該当データなし
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void test_selectTreatmentRecordConditionByOrdNo_異常_該当データなし() {

    // 事前準備
    Long ordNo = 10L;

    // 実行
    target.selectTreatmentRecordConditionByOrdNo(ordNo);
  }

  /**
   * selectTreatmentRecordMediInfoByOrdNo()の検証.
   * <p>
   * 条件：該当データが削除済み
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordMediInfoByOrdNo.before.sql")
  public void test_selectTreatmentRecordMediInfoByOrdNo_異常_該当データなし() {
    // arrange
    final long ordNo = 9999L;

    // action
    // assert
    target.selectTreatmentRecordMediInfoByOrdNo(ordNo);
  }

  /**
   * selectTreatmentRecordMediInfoByOrdNo()の検証.
   * <p>
   * 条件：該当データ削除済み
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordMediInfoByOrdNo.before.sql")
  public void test_selectTreatmentRecordMediInfoByOrdNo_異常_該当データ削除済み() {
    // arrange
    final long ordNo = 2L;

    // action
    // assert
    target.selectTreatmentRecordMediInfoByOrdNo(ordNo);
  }

  /**
   * updateTreatmentRecordForMediInfo()の検証.
   * <p>
   * 条件：治療記録(投与薬剤)画面の入力項目に該当する項目を更新する.
   * 結果：該当データを更新できること(更新対象外項目は更新されていないこと)
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordMediInfoByOrdNo.before.sql")
  public void test_updateTreatmentRecordForMediInfo_正常() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordMediInfo entity = target.selectTreatmentRecordMediInfoByOrdNo(ordNo);

    // 実行
    entity.setRstMediInfo("[{\"cd\": 3, \"name\": \"nameUpdate3\"}, {\"cd\": 1, \"name\": \"nameUpdate1\"}]");


    int updateCount = target.updateTreatmentRecordForMediInfo(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証(更新対象項目)
    TreatmentRecordMediInfo updatedEntity = target.selectTreatmentRecordMediInfoByOrdNo(ordNo);
    assertThat(entity.getRstMediInfo(), is(updatedEntity.getRstMediInfo()));

    // 検証(更新対象外項目)
    assertThat(entity.getOrdNo(), is(updatedEntity.getOrdNo()));
    assertThat(entity.getTreatDate(), is(updatedEntity.getTreatDate()));
    assertThat(entity.getRstDialysisState(), is(updatedEntity.getRstDialysisState()));
    assertThat(entity.getRstStartDate(), is(updatedEntity.getRstStartDate()));
    assertThat(entity.getRegDate(), is(Timestamp.valueOf("2019-03-01 13:10:00")));
  }

  /**
   * updateTreatmentRecordForMediInfo()の検証.
   * <p>
   * 条件：存在しないレコードを更新する
   * 結果：更新件数０件であること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordMediInfoByOrdNo.before.sql")
  public void test_updateTreatmentRecordForMediInfo_異常_存在しないレコード更新() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordMediInfo entity = target.selectTreatmentRecordMediInfoByOrdNo(ordNo);

    // 実行
    Long notFoundOrdNo = 99999L;
    entity.setRstMediInfo("[{\"cd\": 3, \"name\": \"nameUpdate3\"}, {\"cd\": 1, \"name\": \"nameUpdate1\"}]");

    int count = target.updateTreatmentRecordForMediInfo(notFoundOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForMediInfo()の検証.
   * <p>
   * 条件：削除済レコードを更新する
   * 結果：更新件数０件であること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordMediInfoByOrdNo.before.sql")
  public void test_updateTreatmentRecordForMediInfo_異常_削除済レコード更新() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordMediInfo entity = target.selectTreatmentRecordMediInfoByOrdNo(ordNo);

    // 実行
    Long deletedOrdNo = 2L;
    entity.setOrdNo(deletedOrdNo);
    entity.setRstMediInfo("[{\"cd\": 3, \"name\": \"nameUpdate3\"}, {\"cd\": 1, \"name\": \"nameUpdate1\"}]");
    entity.setUpDate(null);

    int count = target.updateTreatmentRecordForMediInfo(deletedOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForMediInfo()の検証.
   * <p>
   * 条件：過去実績のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されること.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForMediInfo_正常_版番号_版番号更新フラグ_更新する() {

    // 事前準備
    Long ordNo = 100001L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("6"));

    // 実行
    TreatmentRecordMediInfo entity = target.selectTreatmentRecordMediInfoByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordForMediInfo(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("6"));
    // 検証：確定フラグが更新されていない事
    assertThat(updated.getIsConfirm(), is("0"));
  }

  /**
   * updateTreatmentRecordForMediInfo()の検証.
   * <p>
   * 条件：過去実績以外のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されないこと.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForMediInfo_正常_版番号_版番号更新フラグ_更新しない() {

    // 事前準備
    Long ordNo = 100002L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("1"));

    // 実行
    TreatmentRecordMediInfo entity = target.selectTreatmentRecordMediInfoByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordForMediInfo(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("1"));
  }


  /**
   * selectTreatmentRecordConditionByOrdNo()の検証.
   * <p>
   * 条件：該当データ削除済み
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void test_selectTreatmentRecordConditionByOrdNo_異常_該当データ削除済み() {

    // 事前準備
    Long ordNo = 12L;

    // 実行
    target.selectTreatmentRecordConditionByOrdNo(ordNo);
  }

  /**
   * selectTreatmentRecordConditionByOrdNo()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  public void test_selectTreatmentRecordConditionByOrdNo_正常_該当データあり() {

    // 事前準備
    Long ordNo = 21L;

    // 実行
    TreatmentRecordCondition result = target.selectTreatmentRecordConditionByOrdNo(ordNo);

    // 検証
    assertThat(result, notNullValue());
    assertThat(result.getOrdNo(), is(21L));
    assertThat(result.getIndTreatStartTime(), is("1423"));
    String value = result.getRstCondInfo().replaceAll("\r\n", "");
    assertThat(value, is("{\"1\": {\"value\": \"0400\", \"value_name_1\": null}}"));
    assertThat(result.getRstDw(), is(new BigDecimal("66.30")));
    assertThat(result.getUpDate(), is(Timestamp.valueOf("2019-02-13 14:30:00")));
    assertThat(result.getRegDate(), is(Timestamp.valueOf("2019-02-13 14:00:00")));
  }

  /**
   * updateTreatmentRecordForCondition()の検証.
   * <p>
   * 条件：治療記録(治療条件)画面の入力項目に該当する項目を更新する.
   * 結果：該当データを更新できること(更新対象外項目は更新されていないこと)
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForCondition_正常() {

    // 事前準備
    Long ordNo = 9011L;
    TreatmentRecordCondition entity = target.selectTreatmentRecordConditionByOrdNo(ordNo);

    // 実行
    entity.setRstCondInfo("{\"1\": {\"unit\": null, \"value\": \"0400\"}, \"2\": {\"unit\": null, \"value\": 3}}");
    // 治療条件ではDWは表示のみとなった為、更新される事は無い.
    // entity.setRstDw(BigDecimal.valueOf(12.34));

    int updateCount = target.updateTreatmentRecordForCondition(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証(更新対象項目)
    TreatmentRecordCondition updatedEntity = target.selectTreatmentRecordConditionByOrdNo(ordNo);
    assertEquals(entity, updatedEntity);

    // 検証(更新対象外項目)
    assertThat(entity.getRegDate(), is(Timestamp.valueOf("2019-02-13 14:00:00.000")));
    assertThat(entity.getRstDw().toString(), is("99.90"));
  }

  /**
   * updateTreatmentRecordForCondition()の検証.
   * <p>
   * 条件：存在しないレコードを更新する
   * 結果：更新件数０件であること
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForCondition_異常_存在しないレコード更新() {

    // 事前準備
    Long ordNo = 9011L;
    TreatmentRecordCondition entity = target.selectTreatmentRecordConditionByOrdNo(ordNo);

    // 実行
    Long notFoundOrdNo = 99999L;
    entity.setIndTreatStartTime("1725");
    entity.setRstCondInfo("{\"1\": {\"unit\": null, \"value\": \"0400\"}, \"2\": {\"unit\": null, \"value\": 3}}");
    entity.setRstDw(BigDecimal.valueOf(12.34));

    int count = target.updateTreatmentRecordForCondition(notFoundOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForCondition()の検証.
   * <p>
   * 条件：削除済レコードを更新する
   * 結果：更新件数０件であること
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForCondition_異常_削除済レコード更新() {

    // 事前準備
    Long ordNo = 9011L;
    TreatmentRecordCondition entity = target.selectTreatmentRecordConditionByOrdNo(ordNo);

    // 実行
    Long deletedOrdNo = 9012L;
    entity.setIndTreatStartTime("1725");
    entity.setRstCondInfo("{\"1\": {\"unit\": null, \"value\": \"0400\"}, \"2\": {\"unit\": null, \"value\": 3}}");
    entity.setRstDw(BigDecimal.valueOf(12.34));

    int count = target.updateTreatmentRecordForCondition(deletedOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForCondition()の検証.
   * <p>
   * 条件：過去実績のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されること.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForCondition_正常_版番号_版番号更新フラグ_更新する() {

    // 事前準備
    Long ordNo = 100001L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("6"));

    // 実行
    TreatmentRecordCondition entity = target.selectTreatmentRecordConditionByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordForCondition(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("6"));
    // 検証：確定フラグが更新されていない事
    assertThat(updated.getIsConfirm(), is("0"));
  }

  /**
   * updateTreatmentRecordForCondition()の検証.
   * <p>
   * 条件：過去実績以外のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されないこと.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForCondition_正常_版番号_版番号更新フラグ_更新しない() {

    // 事前準備
    Long ordNo = 100002L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("1"));

    // 実行
    TreatmentRecordCondition entity = target.selectTreatmentRecordConditionByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordForCondition(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("1"));
  }


  /**
   * selectTreatmentRecordWeightByOrdNo() の検証.
   * <p>
   * 条件：該当データなし
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void test_selectTreatmentRecordWeightByOrdNo_異常_該当データなし() {

    // 事前準備
    final Long ordNo = Long.MAX_VALUE;

    // 実行
    target.selectTreatmentRecordWeightByOrdNo(ordNo);
  }

  /**
   * selectTreatmentRecordWeightByOrdNo() の検証.
   * <p>
   * 条件：該当データが削除済
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void test_selectTreatmentRecordWeightByOrdNo_異常_該当データ削除済み() {

    // 事前準備
    final Long ordNo = 90003L;

    // 実行
    target.selectTreatmentRecordWeightByOrdNo(ordNo);
  }

  /**
   * selectTreatmentRecordWeightByOrdNo() の検証.
   * <p>
   * 条件：該当データあり、かつ、前回透析実績なし
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  public void test_selectTreatmentRecordWeightByOrdNo_正常_前回なし() {

    // 事前準備
    final Long ordNo = 90001L;

    // 実行
    TreatmentRecordWeight entity = target.selectTreatmentRecordWeightByOrdNo(ordNo);

    // 検証
    assertThat(entity, notNullValue());
    assertThat(entity.getOrdNo(), is(ordNo));
    assertThat(entity.getLastWeight(), nullValue());
    assertThat(entity.getRstDw(),  is(new BigDecimal("59.10")));
    assertThat(entity.getTargetWeight(), is(new BigDecimal("21.1")));
    assertThat(entity.getWaterRemovalAmountLimit(), is(new BigDecimal("5.1")));
    assertThat(entity.getRstWeightInfo(), is("{\"weight_after\": 58.1}"));
    assertThat(entity.getRstTareInfo(), is("{\"after\": {\"name_1\": \"項目21名称\"}, \"before\": {\"name_1\": \"項目11名称\"}}"));
    assertThat(entity.getRstOffWaterInfo(), is("{\"name_1\": \"項目1名称\", \"weight_1\": 1}"));
    assertThat(entity.getUpDate(), is(Timestamp.valueOf("2019-04-01 12:00:00")));
    assertThat(entity.getRegDate(), is(Timestamp.valueOf("2019-04-01 13:00:00")));
  }

  /**
   * selectTreatmentRecordWeightByOrdNo() の検証.
   * <p>
   * 条件：該当データあり、かつ、前回透析実績あり
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  public void test_selectTreatmentRecordWeightByOrdNo_正常_前回あり() {

    // 事前準備
    final Long ordNo = 90005L;

    // 実行
    TreatmentRecordWeight entity = target.selectTreatmentRecordWeightByOrdNo(ordNo);

    // 検証
    assertThat(entity, notNullValue());
    assertThat(entity.getLastWeight(), is(new BigDecimal("58.2")));
    assertThat(entity.getRstDw(),  is(new BigDecimal("59.50")));
    assertThat(entity.getTargetWeight(), is(new BigDecimal("21.5")));
    assertThat(entity.getWaterRemovalAmountLimit(), is(new BigDecimal("5.5")));
    assertThat(entity.getRstWeightInfo(), is("{\"weight_after\": 58.5}"));
    assertThat(entity.getRstTareInfo(), is("{\"after\": {\"name_1\": \"項目25名称\"}, \"before\": {\"name_1\": \"項目15名称\"}}"));
    assertThat(entity.getRstOffWaterInfo(), is("{\"name_1\": \"項目5名称\", \"weight_1\": 5}"));
    assertThat(entity.getUpDate(), is(Timestamp.valueOf("2019-04-01 12:00:00")));
    assertThat(entity.getRegDate(), is(Timestamp.valueOf("2019-04-01 13:00:00")));
  }

  /**
   * selectMniMonitorForRecirculationRate()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：指定したテーブルから、指定した条件のデータがすべて取得できること
   * </p>
   */
  @Test
  public void test_selectMniMonitorForRecirculationRate_正常_該当データあり() {
    // 事前準備
    Long ordNo = 13L;
    Short dataType = 3;

    // 実行
    List<MniMonitor> result = target.selectMniMonitorForRecirculationRate(ordNo, dataType);

    // 検証
    Assertions.assertThat(result)
      .extracting(
        MniMonitor::getBioMoniCtlNo,
        MniMonitor::getFacilityCd,
        MniMonitor::getOrdNo,
        MniMonitor::getPatId,
        MniMonitor::getDataType,
        MniMonitor::getMonitorData,
        MniMonitor::getOccurDate,
        MniMonitor::getRegDate,
        MniMonitor::getUpDate
      )
      .hasSize(3)
      .containsExactly(
        tuple(1L, "009999", 13L, 4L, Short.valueOf("3"), "{\"0\": \"test1\", \"1\": \"data1\"}", Timestamp.valueOf("2019-03-22 14:30:00"), Timestamp.valueOf("2019-03-22 14:30:00"), Timestamp.valueOf("2019-03-22 14:30:00")),
        tuple(2L, "009999", 13L, 4L, Short.valueOf("3"), "{\"0\": \"test2\", \"1\": \"data2\"}", Timestamp.valueOf("2019-03-22 14:34:00"), Timestamp.valueOf("2019-03-22 14:30:00"), Timestamp.valueOf("2019-03-22 14:34:00")),
        tuple(3L, "009999", 13L, 4L, Short.valueOf("3"), "{\"0\": \"test3\", \"1\": \"data3\"}", Timestamp.valueOf("2019-03-22 14:35:20"), Timestamp.valueOf("2019-03-22 14:30:00"), Timestamp.valueOf("2019-03-22 14:35:20"))
      );
  }

  /**
   * selectMniMonitorForRecirculationRate()の検証.
   * <p>
   * 条件：該当データなし
   * 結果：空のリストを取得できること
   * </p>
   */
  @Test
  public void test_selectMniMonitorForRecirculationRate_正常_該当データなしの場合は空のリストを返すこと() {
    // 事前準備
    Long ordNo = 15L;
    Short dataType = 3;

    // 実行
    List<MniMonitor> result = target.selectMniMonitorForRecirculationRate(ordNo, dataType);

    // 検証
    Assertions.assertThat(result).isEmpty();
  }

  /**
   * updateTreatmentRecordForWeight()の検証.
   * <p>
   * 条件：治療記録(体重情報)画面の入力項目に該当する項目を更新する.
   * 結果：該当データを更新できること(更新対象外項目は更新されていないこと)
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForWeight_正常() {

    // 事前準備
    Long ordNo = 90005L;
    TreatmentRecordWeight entity = target.selectTreatmentRecordWeightByOrdNo(ordNo);

    // 実行
    entity.setRstWeightInfo("{\"1\": {\"unit\": null, \"value\": \"0400\"}, \"2\": {\"unit\": null, \"value\": 3}}");
    entity.setRstTareInfo("{\"11\": {\"unit\": null, \"value\": \"0400\"}, \"12\": {\"unit\": null, \"value\": 3}}");
    entity.setRstOffWaterInfo("{\"21\": {\"unit\": null, \"value\": \"0400\"}, \"22\": {\"unit\": null, \"value\": 3}}");
    entity.setRstDw(BigDecimal.valueOf(12.34));

    int updateCount = target.updateTreatmentRecordForWeight(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証(更新対象項目)
    TreatmentRecordWeight updatedEntity = target.selectTreatmentRecordWeightByOrdNo(ordNo);
    assertEquals(entity, updatedEntity);

    // 検証(更新対象外項目)
    assertThat(entity.getLastWeight(), is(new BigDecimal("58.2")));
    assertThat(entity.getRstDw(),  is(new BigDecimal("12.34")));
    assertThat(entity.getTargetWeight(), is(new BigDecimal("21.5")));
    assertThat(entity.getWaterRemovalAmountLimit(), is(new BigDecimal("5.5")));
    assertThat(entity.getRegDate(), is(Timestamp.valueOf("2019-04-01 13:00:00")));
  }

  /**
   * updateTreatmentRecordForWeight()の検証.
   * <p>
   * 条件：存在しないレコードを更新する
   * 結果：更新件数０件であること
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForWeight_異常_存在しないレコード更新() {

    // 事前準備
    Long ordNo = 90001L;
    TreatmentRecordWeight entity = target.selectTreatmentRecordWeightByOrdNo(ordNo);

    // 実行
    Long notFoundOrdNo = 99999L;
    entity.setRstWeightInfo("{\"1\": {\"unit\": null, \"value\": \"0400\"}, \"2\": {\"unit\": null, \"value\": 3}}");
    entity.setRstTareInfo("{\"11\": {\"unit\": null, \"value\": \"0400\"}, \"12\": {\"unit\": null, \"value\": 3}}");
    entity.setRstOffWaterInfo("{\"21\": {\"unit\": null, \"value\": \"0400\"}, \"22\": {\"unit\": null, \"value\": 3}}");
    entity.setRstDw(BigDecimal.valueOf(12.34));

    int count = target.updateTreatmentRecordForWeight(notFoundOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForWeight()の検証.
   * <p>
   * 条件：削除済レコードを更新する
   * 結果：更新件数０件であること
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForWeight_異常_削除済レコード更新() {

    // 事前準備
    Long ordNo = 90001L;
    TreatmentRecordWeight entity = target.selectTreatmentRecordWeightByOrdNo(ordNo);

    // 実行
    Long deletedOrdNo = 9012L;
    entity.setRstWeightInfo("{\"1\": {\"unit\": null, \"value\": \"0400\"}, \"2\": {\"unit\": null, \"value\": 3}}");
    entity.setRstTareInfo("{\"11\": {\"unit\": null, \"value\": \"0400\"}, \"12\": {\"unit\": null, \"value\": 3}}");
    entity.setRstOffWaterInfo("{\"21\": {\"unit\": null, \"value\": \"0400\"}, \"22\": {\"unit\": null, \"value\": 3}}");
    entity.setRstDw(BigDecimal.valueOf(12.34));

    int count = target.updateTreatmentRecordForWeight(deletedOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForWeight()の検証.
   * <p>
   * 条件：過去実績のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されること.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForWeight_正常_版番号_版番号更新フラグ_更新する() {

    // 事前準備
    Long ordNo = 100001L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("6"));

    // 実行
    TreatmentRecordWeight entity = target.selectTreatmentRecordWeightByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordForWeight(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("6"));
    // 検証：確定フラグが更新されていない事
    assertThat(updated.getIsConfirm(), is("0"));
  }

  /**
   * updateTreatmentRecordForWeight()の検証.
   * <p>
   * 条件：過去実績以外のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されないこと.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForWeight_正常_版番号_版番号更新フラグ_更新しない() {

    // 事前準備
    Long ordNo = 100002L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("1"));

    // 実行
    TreatmentRecordWeight entity = target.selectTreatmentRecordWeightByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordForWeight(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("1"));
  }

  /**
   * selectTreatmentRecordEquipInfoByOrdNo()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordEquipInfoByOrdNo.before.sql")
  public void test_selectTreatmentRecordEquipInfoByOrdNo_正常_該当データあり() {
    // arrange
    final long ordNo = 1L;

    // action
    TreatmentRecordEquipInfo result = target.selectTreatmentRecordEquipInfoByOrdNo(ordNo);

    // assert
    assertThat(result.getOrdNo(), is(1L));
    assertThat(result.getRstDialysisState(), is("0"));
    // JSONの項目が多いので、文字列で取得できることのみを確認。個々のプロパティのチェックは行わない
    assertThat(result.getRstEquipInfo(), is("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]"));
    assertThat(result.getUpDate(), is(Timestamp.valueOf("2019-03-25 13:00:00")));
    assertThat(result.getRegDate(), is(Timestamp.valueOf("2019-03-25 13:10:00")));
  }

  /**
   * selectTreatmentRecordEquipInfoByOrdNo()の検証.
   * <p>
   * 条件：該当データが削除済み
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordEquipInfoByOrdNo.before.sql")
  public void test_selectTreatmentRecordEquipInfoByOrdNo_異常_該当データなし() {
    // arrange
    final long ordNo = 9999L;

    // action
    // assert
    target.selectTreatmentRecordEquipInfoByOrdNo(ordNo);
  }

  /**
   * selectTreatmentRecordEquipInfoByOrdNo()の検証.
   * <p>
   * 条件：該当データ削除済み
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordEquipInfoByOrdNo.before.sql")
  public void test_selectTreatmentRecordEquipInfoByOrdNo_異常_該当データ削除済み() {
    // arrange
    final long ordNo = 2L;

    // action
    // assert
    target.selectTreatmentRecordEquipInfoByOrdNo(ordNo);
  }

  /**
   * updateTreatmentRecordForEquipInfo()の検証.
   * <p>
   * 条件：治療記録(医療材料)画面の入力項目に該当する項目を更新する.
   * 結果：該当データを更新できること(更新対象外項目は更新されていないこと)
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordEquipInfoByOrdNo.before.sql")
  public void test_updateTreatmentRecordForEquipInfo_正常() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordEquipInfo entity = target.selectTreatmentRecordEquipInfoByOrdNo(ordNo);

    // 実行
    entity.setRstEquipInfo("[{\"cd\": 3, \"name\": \"nameUpdate3\"}, {\"cd\": 1, \"name\": \"nameUpdate1\"}]");

    int updateCount = target.updateTreatmentRecordForEquipInfo(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証(更新対象項目)
    TreatmentRecordEquipInfo updatedEntity = target.selectTreatmentRecordEquipInfoByOrdNo(ordNo);
    assertThat(entity.getRstEquipInfo(), is(updatedEntity.getRstEquipInfo()));

    // 検証(更新対象外項目)
    assertThat(entity.getOrdNo(), is(updatedEntity.getOrdNo()));
    assertThat(entity.getRstDialysisState(), is(updatedEntity.getRstDialysisState()));
    assertThat(entity.getRegDate(), is(Timestamp.valueOf("2019-03-25 13:10:00")));
  }

  /**
   * updateTreatmentRecordForEquipInfo()の検証.
   * <p>
   * 条件：存在しないレコードを更新する
   * 結果：更新件数０件であること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordEquipInfoByOrdNo.before.sql")
  public void test_updateTreatmentRecordForEquipInfo_異常_存在しないレコード更新() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordEquipInfo entity = target.selectTreatmentRecordEquipInfoByOrdNo(ordNo);

    // 実行
    Long notFoundOrdNo = 99999L;
    entity.setRstEquipInfo("[{\"cd\": 3, \"name\": \"nameUpdate3\"}, {\"cd\": 1, \"name\": \"nameUpdate1\"}]");

    int count = target.updateTreatmentRecordForEquipInfo(notFoundOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForEquipInfo()の検証.
   * <p>
   * 条件：削除済レコードを更新する
   * 結果：更新件数０件であること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordEquipInfoByOrdNo.before.sql")
  public void test_updateTreatmentRecordForEquipInfo_異常_削除済レコード更新() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordEquipInfo entity = target.selectTreatmentRecordEquipInfoByOrdNo(ordNo);

    // 実行
    Long deletedOrdNo = 2L;
    entity.setOrdNo(deletedOrdNo);
    entity.setRstEquipInfo("[{\"cd\": 3, \"name\": \"nameUpdate3\"}, {\"cd\": 1, \"name\": \"nameUpdate1\"}]");

    int count = target.updateTreatmentRecordForEquipInfo(deletedOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForEquipInfo()の検証.
   * <p>
   * 条件：過去実績のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されること.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForEquipInfo_正常_版番号_版番号更新フラグ_更新する() {

    // 事前準備
    Long ordNo = 100001L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("6"));

    // 実行
    TreatmentRecordEquipInfo entity = target.selectTreatmentRecordEquipInfoByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordForEquipInfo(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("6"));
    // 検証：確定フラグが更新されていない事
    assertThat(updated.getIsConfirm(), is("0"));
  }

  /**
   * updateTreatmentRecordForEquipInfo()の検証.
   * <p>
   * 条件：過去実績以外のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されないこと.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForEquipInfo_正常_版番号_版番号更新フラグ_更新しない() {

    // 事前準備
    Long ordNo = 100002L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("1"));

    // 実行
    TreatmentRecordEquipInfo entity = target.selectTreatmentRecordEquipInfoByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordForEquipInfo(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("1"));
  }

  /**
   * selectLatestOrdNoByPatIdAndFacilityCd()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectLatestOrdNoByPatIdAndFacilityCd.before.sql")
  public void test_selectLatestOrdNoByPatIdAndFacilityCd_正常_該当データあり() {
    // arrange
    final long patId = 1L;
    final String facilityCd = "000001";
    final long ordNo = 2L;

    // action
    Long result = target.selectLatestOrdNoByPatIdAndFacilityCd(patId, facilityCd);

    // assert
    assertThat(result, is(ordNo));
  }

  /**
   * selectLatestOrdNoByPatIdAndFacilityCd()の検証.
   * <p>
   * 条件：該当データなし（削除データ）
   * 結果：該当データを取得できないこと
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectLatestOrdNoByPatIdAndFacilityCd.before.sql")
  public void test_selectLatestOrdNoByPatIdAndFacilityCd_正常_該当データなし_削除データ() {
    // arrange
    final long patId = 3L;
    final String facilityCd = "000001";

    // action
    Long result = target.selectLatestOrdNoByPatIdAndFacilityCd(patId, facilityCd);

    // assert
    assertThat(result, nullValue());
  }

  /**
   * selectLatestOrdNoByPatIdAndFacilityCd()の検証.
   * <p>
   * 条件：該当データなし（登録データなし）
   * 結果：該当データを取得できないこと
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectLatestOrdNoByPatIdAndFacilityCd.before.sql")
  public void test_selectLatestOrdNoByPatIdAndFacilityCd_正常_該当データなし_登録データなし() {
    // arrange
    final long patId = 9L;
    final String facilityCd = "000001";

    // action
    Long result = target.selectLatestOrdNoByPatIdAndFacilityCd(patId, facilityCd);

    // assert
    assertThat(result, nullValue());
  }

  /**
   * selectTreatmentRecordAdditionByOrdNo()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordAdditionByOrdNo.before.sql")
  public void test_selectTreatmentRecordAdditionByOrdNo_正常_該当データあり() {
    // arrange
    final Long ordNo = 1L;
    final Long patId = 2L;
    final String facilityCd = "009999";
    final String treatDate = "20190416";
    final Long kurCd = 3L;
    final Long treatmentCd = 4L;
    final String comment = "[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]";
    final Long indKurCd = 1001L;
    final Long indTreatmentCd = 1002L;

    // action
    TreatmentRecordAddition result = target.selectTreatmentRecordAdditionByOrdNo(ordNo);

    // assert
    assertThat(result.getOrdNo(), is(ordNo));
    assertThat(result.getPatId(), is(patId));
    assertThat(result.getFacilityCd(), is(facilityCd));
    assertThat(result.getTreatDate(), is(treatDate));
    assertThat(result.getIndKurCd(), is(indKurCd));
    assertThat(result.getIndTreatmentCd(), is(indTreatmentCd));
    assertThat(result.getRstKurCd(), is(kurCd));
    assertThat(result.getRstTreatmentCd(), is(treatmentCd));
    assertThat(result.getRstIndCommentInfo(), is(comment));
    assertThat(result.getUpDate(), is(Timestamp.valueOf("2019-03-01 13:00:00")));
    assertThat(result.getRegDate(), is(Timestamp.valueOf("2019-03-01 13:10:00")));
  }

  /**
   * selectTreatmentRecordAdditionByOrdNo()の検証.
   * <p>
   * 条件：OrdNoに該当するレコードが存在しない
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordAdditionByOrdNo.before.sql")
  public void test_selectTreatmentRecordAdditionByOrdNo_異常_該当データなし() {
    // arrange
    final long ordNo = 9999L;

    // action
    // assert
    target.selectTreatmentRecordAdditionByOrdNo(ordNo);
  }

  /**
   * selectTreatmentRecordAdditionByOrdNo()の検証.
   * <p>
   * 条件：該当データ削除済み
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordAdditionByOrdNo.before.sql")
  public void test_selectTreatmentRecordAdditionByOrdNo_異常_該当データ削除済み() {
    // arrange
    final long ordNo = 2L;

    // action
    // assert
    target.selectTreatmentRecordAdditionByOrdNo(ordNo);
  }

  /**
   * selectByOrdNoForSummary()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectByOrdNoForSummary.before.sql")
  public void test_selectByOrdNoForSummary_正常_該当データあり() {
    // arrange
    final long ordNo = 1L;
    OrdMain expected = new OrdMain() {
      {
        setFacilityCd("009999");
        setTreatDate("20190412");
        setTreatWeek(Short.valueOf("5"));
        setRstBedCd(1L);
        setRstBedName("ベッド１");
        setRstKurCd(2);
        setRstKurName("クール１");
        setRstTreatmentCd(3);
        setRstTreatmentName("治療方法１");
        setRstDialysisState("1");
      }
    };

    // action
    OrdMain result = target.selectByOrdNoForSummary(ordNo);

    // assert
    assertThat(result.getFacilityCd(), is(expected.getFacilityCd()));
    assertThat(result.getTreatDate(), is(expected.getTreatDate()));
    assertThat(result.getTreatWeek(), is(expected.getTreatWeek()));
    assertThat(result.getRstBedCd(), is(expected.getRstBedCd()));
    assertThat(result.getRstBedName(), is(expected.getRstBedName()));
    assertThat(result.getRstKurCd(), is(expected.getRstKurCd()));
    assertThat(result.getRstKurName(), is(expected.getRstKurName()));
    assertThat(result.getRstTreatmentCd(), is(expected.getRstTreatmentCd()));
    assertThat(result.getRstTreatmentName(), is(expected.getRstTreatmentName()));
    assertThat(result.getRstDialysisState(), is(expected.getRstDialysisState()));
  }

  /**
   * selectByOrdNoForSummary()の検証.
   * <p>
   * 条件：該当データなし（削除データ）
   * 結果：該当データを取得できないこと
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectByOrdNoForSummary.before.sql")
  public void test_selectByOrdNoForSummary_正常_該当データなし_削除データ() {
    // arrange
    final long ordNo = 2L;

    // action
    target.selectByOrdNoForSummary(ordNo);
  }

  /**
   * selectByOrdNoForSummary()の検証.
   * <p>
   * 条件：該当データなし（登録データなし）
   * 結果：該当データを取得できないこと
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectByOrdNoForSummary.before.sql")
  public void test_selectByOrdNoForSummary_正常_該当データなし_登録データなし() {
    // arrange
    final long ordNo = 3L;

    // action
    target.selectByOrdNoForSummary(ordNo);
  }


  /**
   * updateTreatmentRecordForAddition()の検証.
   * <p>
   * 条件：治療記録(指示コメント)画面の入力項目に該当する項目を更新する.
   * 結果：該当データを更新できること(更新対象外項目は更新されていないこと)
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordAdditionByOrdNo.before.sql")
  public void test_updateTreatmentRecordForAddition_正常() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordAddition entity = target.selectTreatmentRecordAdditionByOrdNo(ordNo);

    // 実行
    entity.setRstIndCommentInfo("[{\"cd\": 3, \"name\": \"nameUpdate3\"}, {\"cd\": 1, \"name\": \"nameUpdate1\"}]");

    int updateCount = target.updateTreatmentRecordForAddition(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証(更新対象項目)
    TreatmentRecordAddition updatedEntity = target.selectTreatmentRecordAdditionByOrdNo(ordNo);
    assertThat(entity.getRstIndCommentInfo(), is(updatedEntity.getRstIndCommentInfo()));

    // 検証(更新対象外項目)
    assertThat(entity.getRstIndCommentInfo(), is(updatedEntity.getRstIndCommentInfo()));
  }

  /**
   * updateTreatmentRecordForAddition()の検証.
   * <p>
   * 条件：存在しないレコードを更新する
   * 結果：更新件数０件であること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordAdditionByOrdNo.before.sql")
  public void test_updateTreatmentRecordForAddition_異常_存在しないレコード更新() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordAddition entity = target.selectTreatmentRecordAdditionByOrdNo(ordNo);

    // 実行
    Long notFoundOrdNo = 99999L;
    entity.setRstIndCommentInfo("[{\"cd\": 3, \"name\": \"nameUpdate3\"}, {\"cd\": 1, \"name\": \"nameUpdate1\"}]");

    int count = target.updateTreatmentRecordForAddition(notFoundOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForAddition()の検証.
   * <p>
   * 条件：削除済レコードを更新する
   * 結果：更新件数０件であること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordAdditionByOrdNo.before.sql")
  public void test_updateTreatmentRecordForAddition_異常_削除済レコード更新() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordAddition entity = target.selectTreatmentRecordAdditionByOrdNo(ordNo);

    // 実行
    Long deletedOrdNo = 2L;
    entity.setRstIndCommentInfo("[{\"cd\": 3, \"name\": \"nameUpdate3\"}, {\"cd\": 1, \"name\": \"nameUpdate1\"}]");

    int count = target.updateTreatmentRecordForAddition(deletedOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForAddition()の検証.
   * <p>
   * 条件：過去実績のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されること.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForAddition_正常_版番号_版番号更新フラグ_更新する() {

    // 事前準備
    Long ordNo = 100001L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("6"));

    // 実行
    TreatmentRecordAddition entity = target.selectTreatmentRecordAdditionByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordForAddition(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("6"));
    // 検証：確定フラグが更新されていない事
    assertThat(updated.getIsConfirm(), is("0"));
  }

  /**
   * updateTreatmentRecordForAddition()の検証.
   * <p>
   * 条件：過去実績以外のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されないこと.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForAddition_正常_版番号_版番号更新フラグ_更新しない() {

    // 事前準備
    Long ordNo = 100002L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("1"));

    // 実行
    TreatmentRecordAddition entity = target.selectTreatmentRecordAdditionByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordForAddition(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("1"));
  }

  /**
   * selectTreatmentRecordVitalMonitors()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：指定したテーブルから、指定した条件のデータがすべて取得できること
   * </p>
   */
  @Test
  public void test_selectTreatmentRecordVitalMonitors_正常_該当データあり() {
    // 事前準備
    Long ordNo = 14L;
    String facilityCd = "0000000";

    // 実行
    List<TreatmentRecordVitalMonitor> result = target.selectTreatmentRecordVitalMonitors(facilityCd, ordNo);

    // 検証
    Assertions.assertThat(result)
      .extracting(
        TreatmentRecordVitalMonitor::getBioMoniCtlNo,
        TreatmentRecordVitalMonitor::getDataType,
        TreatmentRecordVitalMonitor::getMonitorData,
        TreatmentRecordVitalMonitor::getOccurDate
      )
      .hasSize(4)
      .containsExactly(
        tuple(8L, Short.valueOf("5"), "{\"0\": \"test4\", \"1\": \"data4\"}", Timestamp.valueOf("2019-03-22 14:00:00")),
        tuple(5L, Short.valueOf("2"), "{\"0\": \"test1\", \"1\": \"data1\"}", Timestamp.valueOf("2019-03-22 14:10:00")),
        tuple(7L, Short.valueOf("4"), "{\"0\": \"test3\", \"1\": \"data3\"}", Timestamp.valueOf("2019-03-22 14:13:00")),
        tuple(9L, Short.valueOf("6"), "{\"0\": \"test5\", \"1\": \"data5\"}", Timestamp.valueOf("2019-03-22 14:30:00"))
      );
  }

  /**
   * selectTreatmentRecordVitalMonitors()の検証.
   * <p>
   * 条件：該当データなし
   * 結果：空のリストを取得できること
   * </p>
   */
  @Test
  public void test_selectTreatmentRecordVitalMonitors_正常_該当データなしの場合は空のリストを返すこと() {
    // 事前準備
    Long ordNo = 15L;
    String facilityCd = "0000000";

    // 実行
    List<TreatmentRecordVitalMonitor> result = target.selectTreatmentRecordVitalMonitors(facilityCd, ordNo);

    // 検証
    Assertions.assertThat(result).isEmpty();
  }

//  /**
//   * selectTreatmentRecordVitalByOrdNo()の検証.
//   * <p>
//   * 条件：該当データあり
//   * 結果：該当データを取得できること
//   * </p>
//   */
//  @Test
//  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordVitalByOrdNo.before.sql")
//  public void test_selectTreatmentRecordVitalByOrdNo_正常_該当データあり() {
//    // arrange
//    final Long ordNo = 1L;
//    final Timestamp rstStartDate = Timestamp.valueOf("2019-05-10 13:10:00");
//    final String treatDate = "20190416";
//    final String vitalInfo = "[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]";
//
//    // action
//    TreatmentRecordVital result = target.selectTreatmentRecordVitalByOrdNo(ordNo);
//
//    // assert
//    assertThat(result.getOrdNo(), is(ordNo));
//    assertThat(result.getRstStartDate(), is(rstStartDate));
//    assertThat(result.getTreatDate(), is(treatDate));
//    assertThat(result.getRstVitalInfo(), is(vitalInfo));
//    assertThat(result.getUpDate(), is(Timestamp.valueOf("2019-03-01 13:00:00")));
//    assertThat(result.getRegDate(), is(Timestamp.valueOf("2019-03-01 13:10:00")));
//}

//  /**
//   * selectTreatmentRecordVitalByOrdNo()の検証.
//   * <p>
//   * 条件：OrdNoに該当するレコードが存在しない
//   * 結果：EmptyResultDataAccessException例外が投げられること
//   * </p>
//   */
//  @Test(expected = EmptyResultDataAccessException.class)
//  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordVitalByOrdNo.before.sql")
//  public void test_selectTreatmentRecordVitalByOrdNo_異常_該当データなし() {
//    // arrange
//    final long ordNo = 9999L;
//
//    // action
//    // assert
//    target.selectTreatmentRecordVitalByOrdNo(ordNo);
//  }

//  /**
//   * selectTreatmentRecordVitalByOrdNo()の検証.
//   * <p>
//   * 条件：該当データ削除済み
//   * 結果：EmptyResultDataAccessException例外が投げられること
//   * </p>
//   */
//  @Test(expected = EmptyResultDataAccessException.class)
//  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordVitalByOrdNo.before.sql")
//  public void test_selectTreatmentRecordVitalByOrdNo_異常_該当データ削除済み() {
//    // arrange
//    final long ordNo = 2L;
//
//    // action
//    // assert
//    target.selectTreatmentRecordVitalByOrdNo(ordNo);
//  }

//  /**
//   * updateTreatmentRecordForVital()の検証.
//   * <p>
//   * 条件：治療記録(バイタル)画面の入力項目に該当する項目を更新する.
//   * 結果：該当データを更新できること(更新対象外項目は更新されていないこと)
//   * </p>
//   */
//  @Test
//  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordVitalByOrdNo.before.sql")
//  public void test_updateTreatmentRecordForVital_正常() {
//
//    // 事前準備
//    Long ordNo = 1L;
//    TreatmentRecordVital entity = target.selectTreatmentRecordVitalByOrdNo(ordNo);
//
//    // 実行
//    entity.setRstVitalInfo("[{\"cd\": 3, \"name\": \"nameUpdate3\"}, {\"cd\": 1, \"name\": \"nameUpdate1\"}]");
//
//    int updateCount = target.updateTreatmentRecordForVital(ordNo, entity);
//
//    // 検証(更新件数)
//    assertThat(updateCount, is(1));
//
//    // 検証(更新対象項目)
//    TreatmentRecordVital updatedEntity = target.selectTreatmentRecordVitalByOrdNo(ordNo);
//    assertThat(entity.getRstVitalInfo(), is(updatedEntity.getRstVitalInfo()));
//
//    // 検証(更新対象外項目)
//    assertThat(entity.getRstVitalInfo(), is(updatedEntity.getRstVitalInfo()));
//  }

//  /**
//   * updateTreatmentRecordForVital()の検証.
//   * <p>
//   * 条件：存在しないレコードを更新する
//   * 結果：更新件数０件であること
//   * </p>
//   */
//  @Test
//  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordVitalByOrdNo.before.sql")
//  public void test_updateTreatmentRecordForVital_異常_存在しないレコード更新() {
//
//    // 事前準備
//    Long ordNo = 1L;
//    TreatmentRecordVital entity = target.selectTreatmentRecordVitalByOrdNo(ordNo);
//
//    // 実行
//    Long notFoundOrdNo = 99999L;
//    entity.setRstVitalInfo("[{\"cd\": 3, \"name\": \"nameUpdate3\"}, {\"cd\": 1, \"name\": \"nameUpdate1\"}]");
//
//    int count = target.updateTreatmentRecordForVital(notFoundOrdNo, entity);
//
//    // 検証
//    assertThat(count, is(0));
//  }

//  /**
//   * updateTreatmentRecordForVital()の検証.
//   * <p>
//   * 条件：削除済レコードを更新する
//   * 結果：更新件数０件であること
//   * </p>
//   */
//  @Test
//  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordVitalByOrdNo.before.sql")
//  public void test_updateTreatmentRecordForVital_異常_削除済レコード更新() {
//
//    // 事前準備
//    Long ordNo = 1L;
//    TreatmentRecordVital entity = target.selectTreatmentRecordVitalByOrdNo(ordNo);
//
//    // 実行
//    Long deletedOrdNo = 2L;
//    entity.setRstVitalInfo("[{\"cd\": 3, \"name\": \"nameUpdate3\"}, {\"cd\": 1, \"name\": \"nameUpdate1\"}]");
//
//    int count = target.updateTreatmentRecordForVital(deletedOrdNo, entity);
//
//    // 検証
//    assertThat(count, is(0));
//  }

//  /**
//   * updateTreatmentRecordForVital()の検証.
//   * <p>
//   * 条件：過去実績のデータを更新する.
//   * 結果：版番号と版番号更新フラグが更新されること.
//   * </p>
//   */
//  @Test
//  public void test_updateTreatmentRecordForVital_正常_版番号_版番号更新フラグ_更新する() {
//
//    // 事前準備
//    Long ordNo = 100001L;
//
//    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
//    assertThat(ordMain.getRstEdition(), is(0));
//    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
//    assertThat(ordMain.getRstDialysisState(), is("6"));
//
//    // 実行
//    TreatmentRecordVital entity = target.selectTreatmentRecordVitalByOrdNo(ordNo);
//    int updateCount = target.updateTreatmentRecordForVital(ordNo, entity);
//
//    // 検証(更新件数)
//    assertThat(updateCount, is(1));
//
//    // 検証
//    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
//    assertThat(updated.getRstEdition(), is(1));
//    assertThat(updated.getRstIsUpdateEdition(), is("1"));
//    assertThat(updated.getRstDialysisState(), is("6"));
//  }

//  /**
//   * updateTreatmentRecordForVital()の検証.
//   * <p>
//   * 条件：過去実績以外のデータを更新する.
//   * 結果：版番号と版番号更新フラグが更新されないこと.
//   * </p>
//   */
//  @Test
//  public void test_updateTreatmentRecordForVital_正常_版番号_版番号更新フラグ_更新しない() {
//
//    // 事前準備
//    Long ordNo = 100002L;
//
//    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
//    assertThat(ordMain.getRstEdition(), is(0));
//    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
//    assertThat(ordMain.getRstDialysisState(), is("1"));
//
//    // 実行
//    TreatmentRecordVital entity = target.selectTreatmentRecordVitalByOrdNo(ordNo);
//    int updateCount = target.updateTreatmentRecordForVital(ordNo, entity);
//
//    // 検証(更新件数)
//    assertThat(updateCount, is(1));
//
//    // 検証
//    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
//    assertThat(updated.getRstEdition(), is(0));
//    assertThat(updated.getRstIsUpdateEdition(), is("0"));
//    assertThat(updated.getRstDialysisState(), is("1"));
//  }

  /**
   * selectTreatmentRecordMonitors()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：指定したテーブルから、指定した条件のデータがすべて取得できること
   * </p>
   */
  @Test
  public void test_selectTreatmentRecordMonitors_正常_該当データあり() {
    // 事前準備
    Long ordNo = 14L;

    // 実行
    List<TreatmentRecordMonitor> result = target.selectTreatmentRecordMonitors(ordNo);

    // 検証
    Assertions.assertThat(result)
      .extracting(
        TreatmentRecordMonitor::getBioMoniCtlNo,
        TreatmentRecordMonitor::getMonitorData,
        TreatmentRecordMonitor::getOccurDate,
        TreatmentRecordMonitor::getIsDel
      )
      .hasSize(3)
      .containsExactly(
        tuple(13L, "{\"0\": \"test3\", \"1\": \"data3\"}", Timestamp.valueOf("2019-03-22 14:32:20"), "0"),
        tuple(11L, "{\"0\": \"test1\", \"1\": \"data1\"}", Timestamp.valueOf("2019-03-22 14:33:00"), "0"),
        tuple(12L, "{\"0\": \"test2\", \"1\": \"data2\"}", Timestamp.valueOf("2019-03-22 14:35:00"), "0")
      );
  }

  /**
   * selectTreatmentRecordMonitors()の検証.
   * <p>
   * 条件：該当データなし
   * 結果：空のリストを取得できること
   * </p>
   */
  @Test
  public void test_selectTreatmentRecordMonitors_正常_該当データなしの場合は空のリストを返すこと() {
    // 事前準備
    Long ordNo = 15L;

    // 実行
    List<TreatmentRecordMonitor> result = target.selectTreatmentRecordMonitors(ordNo);

    // 検証
    Assertions.assertThat(result).isEmpty();
  }

//  /**
//   * selectTreatmentRecordRstMonitorByOrdNo()の検証.
//   * <p>
//   * 条件：該当データあり
//   * 結果：該当データを取得できること
//   * </p>
//   */
//  @Test
//  public void test_selectTreatmentRecordRstMonitorByOrdNo_正常_該当データあり() {
//
//    // 事前準備
//    Long ordNo = 1L;
//
//    // 実行
//    TreatmentRecordRstMonitor result = target.selectTreatmentRecordRstMonitorByOrdNo(ordNo);
//
//    // 検証
//    assertThat(result, notNullValue());
//    assertThat(result.getRstStartDate(), is(Timestamp.valueOf("2019-02-13 12:00:00")));
//    assertThat(result.getUpDate(), is(Timestamp.valueOf("2019-02-13 14:30:00")));
//  }

//  /**
//   * selectTreatmentRecordRstMonitorByOrdNo()の検証.
//   * <p>
//   * 条件：該当データが削除済み
//   * 結果：EmptyResultDataAccessException例外が投げられること
//   * </p>
//   */
//  @Test(expected = EmptyResultDataAccessException.class)
//  public void test_selectTreatmentRecordRstMonitorByOrdNo_異常_該当データ削除済み() {
//
//    // 事前準備
//    Long ordNo = 12L;
//
//    // 実行
//    target.selectTreatmentRecordRstMonitorByOrdNo(ordNo);
//  }

//  /**
//   * selectTreatmentRecordRstMonitorByOrdNo()の検証.
//   * <p>
//   * 条件：該当データなし
//   * 結果：EmptyResultDataAccessException例外が投げられること
//   * </p>
//   */
//  @Test(expected = EmptyResultDataAccessException.class)
//  public void test_selectTreatmentRecordRstMonitorByOrdNo_異常_該当データなし() {
//
//    // 事前準備
//    Long ordNo = 10L;
//
//    // 実行
//    target.selectTreatmentRecordRstMonitorByOrdNo(ordNo);
//  }

  /**
   * selectTreatmentRecordDeviceSetInfoByOrdNo()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordDeviceSetInfoByOrdNo.before.sql")
  public void test_selectTreatmentRecordDeviceSetInfoByOrdNo_正常_該当データあり() {
    // arrange
    final Long ordNo = 1L;
    final Long patId = 11L;
    final String facilityCd = "009999";
    final String rstDeviceSetInfo = "{\"cd\": 11, \"name\": \"name11\"}";

    // action
    TreatmentRecordDeviceSetInfo result = target.selectTreatmentRecordDeviceSetInfoByOrdNo(ordNo);

    // assert
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//    assertThat(result.getRstDeviceSetInfo(), is(rstDeviceSetInfo));
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
    assertThat(result.getPatId(), is(patId));
    assertThat(result.getFacilityCd(), is(facilityCd));

  }

  /**
   * selectTreatmentRecordDeviceSetInfoByOrdNo()の検証.
   * <p>
   * 条件：OrdNoに該当するレコードが存在しない
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordDeviceSetInfoByOrdNo.before.sql")
  public void test_selectTreatmentRecordDeviceSetInfoByOrdNo_異常_該当データなし() {
    // arrange
    final long ordNo = 9999L;

    // action
    // assert
    target.selectTreatmentRecordDeviceSetInfoByOrdNo(ordNo);
  }

  /**
   * selectTreatmentRecordDeviceSetInfoByOrdNo()の検証.
   * <p>
   * 条件：該当データ削除済み
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordDeviceSetInfoByOrdNo.before.sql")
  public void test_selectTreatmentRecordDeviceSetInfoByOrdNo_異常_該当データ削除済み() {
    // arrange
    final long ordNo = 2L;

    // action
    // assert
    target.selectTreatmentRecordDeviceSetInfoByOrdNo(ordNo);
  }

  /**
   * selectTreatmentRecordRoundsInfoByOrdNo()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordRoundsInfoByOrdNo.before.sql")
  public void test_selectTreatmentRecordRoundsInfoByOrdNo_正常_該当データあり() {
    // arrange
    final Long ordNo = 1L;
    final String rstRoundsInfo = "[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]";
    final Timestamp upDate = Timestamp.valueOf("2019-03-01 13:00:00");
    final Timestamp regDate = Timestamp.valueOf("2019-03-01 13:10:00");

    // action
    TreatmentRecordRoundsInfo result = target.selectTreatmentRecordRoundsInfoByOrdNo(ordNo);

    // assert
    assertThat(result.getOrdNo(), is(ordNo));
    assertThat(result.getRstRoundsInfo(), is(rstRoundsInfo));
    assertThat(result.getUpDate(), is(upDate));
    assertThat(result.getRegDate(), is(regDate));
  }

  /**
   * selectTreatmentRecordRoundsInfoByOrdNo()の検証.
   * <p>
   * 条件：該当データあり（rst_rounds_infoがnull）
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordRoundsInfoByOrdNo.before.sql")
  public void test_selectTreatmentRecordRoundsInfoByOrdNo_正常_該当データあり_null() {
    // arrange
    final Long ordNo = 2L;
    final String rstRoundsInfo = null;

    // action
    TreatmentRecordRoundsInfo result = target.selectTreatmentRecordRoundsInfoByOrdNo(ordNo);

    // assert
    assertThat(result.getRstRoundsInfo(), is(rstRoundsInfo));
  }

  /**
   * selectTreatmentRecordRoundsInfoByOrdNo()の検証.
   * <p>
   * 条件：OrdNoに該当するレコードが存在しない
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordRoundsInfoByOrdNo.before.sql")
  public void test_selectTreatmentRecordRoundsInfoByOrdNo_異常_該当データなし() {
    // arrange
    final long ordNo = 9999L;

    // action
    // assert
    target.selectTreatmentRecordRoundsInfoByOrdNo(ordNo);
  }

  /**
   * updateTreatmentRecordForRoundsInfo()の検証.
   * <p>
   * 条件：治療記録(回診記録)画面の入力項目に該当する項目を更新する.
   * 結果：該当データを更新できること(更新対象外項目は更新されていないこと)
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordRoundsInfoByOrdNo.before.sql")
  public void test_updateTreatmentRecordForRoundsInfo_正常() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordRoundsInfo entity = target.selectTreatmentRecordRoundsInfoByOrdNo(ordNo);

    // 実行
    entity.setRstRoundsInfo("[{\"cd\": 3, \"name\": \"nameUpdate3\"}, {\"cd\": 1, \"name\": \"nameUpdate1\"}]");

    int updateCount = target.updateTreatmentRecordForRoundsInfo(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証(更新対象項目)
    TreatmentRecordRoundsInfo updatedEntity = target.selectTreatmentRecordRoundsInfoByOrdNo(ordNo);
    assertThat(entity.getRstRoundsInfo(), is(updatedEntity.getRstRoundsInfo()));
  }

  /**
   * updateTreatmentRecordForRoundsInfo()の検証.
   * <p>
   * 条件：存在しないレコードを更新する
   * 結果：更新件数０件であること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordRoundsInfoByOrdNo.before.sql")
  public void test_updateTreatmentRecordForRoundsInfo_異常_存在しないレコード更新() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordRoundsInfo entity = target.selectTreatmentRecordRoundsInfoByOrdNo(ordNo);

    // 実行
    Long notFoundOrdNo = 99999L;
    entity.setRstRoundsInfo("[{\"cd\": 3, \"name\": \"nameUpdate3\"}, {\"cd\": 1, \"name\": \"nameUpdate1\"}]");

    int count = target.updateTreatmentRecordForRoundsInfo(notFoundOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForRoundsInfo()の検証.
   * <p>
   * 条件：過去実績のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されること.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForRoundsInfo_正常_版番号_版番号更新フラグ_更新する() {

    // 事前準備
    Long ordNo = 100001L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("6"));

    // 実行
    TreatmentRecordRoundsInfo entity = target.selectTreatmentRecordRoundsInfoByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordForRoundsInfo(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("6"));
    // 検証：確定フラグが更新されていない事
    assertThat(updated.getIsConfirm(), is("0"));
  }

  /**
   * updateTreatmentRecordForRoundsInfo()の検証.
   * <p>
   * 条件：過去実績以外のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されないこと.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForRoundsInfo_正常_版番号_版番号更新フラグ_更新しない() {

    // 事前準備
    Long ordNo = 100002L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("1"));

    // 実行
    TreatmentRecordRoundsInfo entity = target.selectTreatmentRecordRoundsInfoByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordForRoundsInfo(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("1"));
  }

  /**
   * selectTreatmentRecordResultMergeByOrdNo()の検証.
   * <p>
   * 条件：該当データあり、同日同患者の選択以外の実績なし、かつ 予定無し患者なし
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordResultMergeByOrdNo.before.sql")
  public void test_selectTreatmentRecordResultMergeByOrdNo_正常_同日同患者の選択以外の実績なし_予定無し患者なし() {

    // 事前準備
    final Long ordNo = 1L;

    // 実行
    List<TreatmentRecordResultMerge> entityies = target.selectTreatmentRecordResultMergeByOrdNo(ordNo);

    // 検証
    assertThat(entityies, notNullValue());
    assertThat(entityies, hasSize(1));
    assertThat(entityies.get(0).getOrdNo(), is(1L));
    assertThat(entityies.get(0).getPatId(), is(2L));
    assertThat(entityies.get(0).getPatName(), nullValue());
    assertThat(entityies.get(0).getRstInputClass(), is(3));
    assertThat(entityies.get(0).getRstDialysisState(), is("4"));
    assertThat(entityies.get(0).getRstTreatmentName(), is("5"));
    assertThat(entityies.get(0).getRstKurCd(), is(6L));
    assertThat(entityies.get(0).getRstKurName(), is("7"));
    assertThat(entityies.get(0).getRstBedCd(), is(8L));
    assertThat(entityies.get(0).getRstBedName(), is("9"));
    assertThat(entityies.get(0).getRstMachineName(), is("10"));
    assertThat(entityies.get(0).getRstCondSendDate(), is(Timestamp.valueOf("2019-06-01 12:00:00")));
    assertThat(entityies.get(0).getRstAcceptDate(), is(Timestamp.valueOf("2019-06-02 12:00:00")));
    assertThat(entityies.get(0).getRstStartDate(), is(Timestamp.valueOf("2019-06-03 12:00:00")));
    assertThat(entityies.get(0).getRstEndDate(), is(Timestamp.valueOf("2019-06-04 12:00:00")));
    assertThat(entityies.get(0).getRstReturnHomeDate(), is(Timestamp.valueOf("2019-06-05 12:00:00")));
    assertThat(entityies.get(0).getRstInOutClass(), is(11));
    assertThat(entityies.get(0).getRstDialysisCnt(), is(12));
    assertThat(entityies.get(0).getRstWardCd(), is(13));
    assertThat(entityies.get(0).getRstWardName(), is("14"));
    assertThat(entityies.get(0).getRstCourseCd(), is(15));
    assertThat(entityies.get(0).getRstCourseName(), is("16"));
    assertThat(entityies.get(0).getRstDw(), is(new BigDecimal("17.00")));
    assertThat(entityies.get(0).getRstPunctureUserInfo(), is("{\"value\": \"18\"}"));
    assertThat(entityies.get(0).getRstReturnUserInfo(), is("{\"value\": \"19\"}"));
    assertThat(entityies.get(0).getRstChargeUserInfo(), is("{\"value\": \"20\"}"));
    assertThat(entityies.get(0).getRstBloodCirculateTotal(), is(new BigDecimal("21.00")));
    assertThat(entityies.get(0).getRstRunningTime(), is(22));
    assertThat(entityies.get(0).getRstKtV(), is(new BigDecimal("23.00")));
    assertThat(entityies.get(0).getRecSetDate(), is(Timestamp.valueOf("2019-06-06 12:00:00")));
    assertThat(entityies.get(0).getSendCtlNo(), is(24L));
    assertThat(entityies.get(0).getBloodPurifierName(), is("25"));
    assertThat(entityies.get(0).getPullLeaveAmount(), is(new BigDecimal("2.60")));
    assertThat(entityies.get(0).getRstCondInfo(), is("{\"value\": \"27\"}"));
    assertThat(entityies.get(0).getRstMediInfo(), is("{\"value\": \"28\"}"));
    assertThat(entityies.get(0).getRstEquipInfo(), is("{\"value\": \"29\"}"));
    assertThat(entityies.get(0).getRstIndCommentInfo(), is("{\"value\": \"30\"}"));
    assertThat(entityies.get(0).getRstTareInfo(), is("{\"value\": \"31\"}"));
    assertThat(entityies.get(0).getRstOffWaterInfo(), is("{\"value\": \"32\"}"));
//    assertThat(entityies.get(0).getRstDeviceSetInfo(), is("{\"value\": \"33\"}"));// del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
    assertThat(entityies.get(0).getWeightScaleNo(), is(34L));
    assertThat(entityies.get(0).getRstWeightInfo(), is("{\"value\": \"35\"}"));
//    assertThat(entityies.get(0).getRstVitalInfo(), is("{\"value\": \"36\"}"));
    assertThat(entityies.get(0).getRstComplaintInfo(), is("{\"value\": \"37\"}"));
    assertThat(entityies.get(0).getRstTreatmentInfo(), is("{\"value\": \"38\"}"));
    assertThat(entityies.get(0).getRstTreatStaffInfo(), is("{\"value\": \"39\"}"));
    assertThat(entityies.get(0).getRstRoundsInfo(), is("{\"value\": \"40\"}"));
    assertThat(entityies.get(0).getUpDate(), is(Timestamp.valueOf("2019-06-26 19:00:00")));
    assertThat(entityies.get(0).getRegDate(), is(Timestamp.valueOf("2019-06-26 18:00:00")));
  }

  /**
   * selectTreatmentRecordResultMergeByOrdNo()の検証.
   * <p>
   * 条件：該当データあり、同日同患者の選択以外の実績あり、かつ 予定無し患者なし
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordResultMergeByOrdNo.before.sql")
  public void test_selectTreatmentRecordResultMergeByOrdNo_正常_同日同患者の選択以外の実績あり_予定無し患者なし() {

    // 事前準備
    final Long ordNo = 11L;

    // 実行
    List<TreatmentRecordResultMerge> entityies = target.selectTreatmentRecordResultMergeByOrdNo(ordNo);

    // 想定する検証結果
    // 取得件数：5件
    // 取得順序：オーダ番号 16 -> 17 -> 11 -> 18 -> 19

    // 検証
    assertThat(entityies, notNullValue());
    assertThat(entityies, hasSize(5));
    assertThat(entityies.get(0).getOrdNo(), is(16L));
    assertThat(entityies.get(0).getPatId(), is(2L));
    assertThat(entityies.get(0).getPatName(), nullValue());
    assertThat(entityies.get(0).getRstInputClass(), is(8));
    assertThat(entityies.get(0).getRstDialysisState(), is("3"));
    assertThat(entityies.get(0).getRstTreatmentName(), is("5"));
    assertThat(entityies.get(0).getRstKurCd(), is(6L));
    assertThat(entityies.get(0).getRstKurName(), is("7"));
    assertThat(entityies.get(0).getRstBedCd(), is(8L));
    assertThat(entityies.get(0).getRstBedName(), is("1"));
    assertThat(entityies.get(0).getRstMachineName(), is("10"));
    assertThat(entityies.get(0).getRstCondSendDate(), is(Timestamp.valueOf("2019-06-01 12:00:00")));
    assertThat(entityies.get(0).getRstAcceptDate(), is(Timestamp.valueOf("2019-06-02 12:00:00")));
    assertThat(entityies.get(0).getRstStartDate(), is(Timestamp.valueOf("2019-06-03 12:00:00")));
    assertThat(entityies.get(0).getRstEndDate(), is(Timestamp.valueOf("2019-06-04 12:00:00")));
    assertThat(entityies.get(0).getRstReturnHomeDate(), is(Timestamp.valueOf("2019-06-05 12:00:00")));
    assertThat(entityies.get(0).getRstInOutClass(), is(11));
    assertThat(entityies.get(0).getRstDialysisCnt(), is(12));
    assertThat(entityies.get(0).getRstWardCd(), is(13));
    assertThat(entityies.get(0).getRstWardName(), is("14"));
    assertThat(entityies.get(0).getRstCourseCd(), is(15));
    assertThat(entityies.get(0).getRstCourseName(), is("16"));
    assertThat(entityies.get(0).getRstDw(), is(new BigDecimal("17.00")));
    assertThat(entityies.get(0).getRstPunctureUserInfo(), is("{\"value\": \"18\"}"));
    assertThat(entityies.get(0).getRstReturnUserInfo(), is("{\"value\": \"19\"}"));
    assertThat(entityies.get(0).getRstChargeUserInfo(), is("{\"value\": \"20\"}"));
    assertThat(entityies.get(0).getRstBloodCirculateTotal(), is(new BigDecimal("21.00")));
    assertThat(entityies.get(0).getRstRunningTime(), is(22));
    assertThat(entityies.get(0).getRstKtV(), is(new BigDecimal("23.00")));
    assertThat(entityies.get(0).getRecSetDate(), is(Timestamp.valueOf("2019-06-06 12:00:00")));
    assertThat(entityies.get(0).getSendCtlNo(), is(24L));
    assertThat(entityies.get(0).getBloodPurifierName(), is("25"));
    assertThat(entityies.get(0).getPullLeaveAmount(), is(new BigDecimal("2.60")));
    assertThat(entityies.get(0).getRstCondInfo(), is("{\"value\": \"27\"}"));
    assertThat(entityies.get(0).getRstMediInfo(), is("{\"value\": \"28\"}"));
    assertThat(entityies.get(0).getRstEquipInfo(), is("{\"value\": \"29\"}"));
    assertThat(entityies.get(0).getRstIndCommentInfo(), is("{\"value\": \"30\"}"));
    assertThat(entityies.get(0).getRstTareInfo(), is("{\"value\": \"31\"}"));
    assertThat(entityies.get(0).getRstOffWaterInfo(), is("{\"value\": \"32\"}"));
//    assertThat(entityies.get(0).getRstDeviceSetInfo(), is("{\"value\": \"33\"}"));// del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
    assertThat(entityies.get(0).getWeightScaleNo(), is(34L));
    assertThat(entityies.get(0).getRstWeightInfo(), is("{\"value\": \"35\"}"));
//    assertThat(entityies.get(0).getRstVitalInfo(), is("{\"value\": \"36\"}"));
    assertThat(entityies.get(0).getRstComplaintInfo(), is("{\"value\": \"37\"}"));
    assertThat(entityies.get(0).getRstTreatmentInfo(), is("{\"value\": \"38\"}"));
    assertThat(entityies.get(0).getRstTreatStaffInfo(), is("{\"value\": \"39\"}"));
    assertThat(entityies.get(0).getRstRoundsInfo(), is("{\"value\": \"40\"}"));
    assertThat(entityies.get(0).getUpDate(), is(Timestamp.valueOf("2019-06-26 19:00:00")));
    assertThat(entityies.get(0).getRegDate(), is(Timestamp.valueOf("2019-06-26 18:00:00")));
    // 2件目以降は相違がある項目のみ検証
    assertThat(entityies.get(1).getOrdNo(), is(17L));
    assertThat(entityies.get(1).getPatId(), is(2L));
    assertThat(entityies.get(1).getRstInputClass(), is(9));
    assertThat(entityies.get(1).getRstDialysisState(), is("4"));
    assertThat(entityies.get(1).getRstBedName(), is("9"));
    assertThat(entityies.get(1).getRstStartDate(), is(Timestamp.valueOf("2019-06-02 12:00:00")));
    assertThat(entityies.get(2).getOrdNo(), is(11L));
    assertThat(entityies.get(2).getPatId(), is(2L));
    assertThat(entityies.get(2).getRstInputClass(), is(3));
    assertThat(entityies.get(2).getRstDialysisState(), is("4"));
    assertThat(entityies.get(2).getRstBedName(), is("9"));
    assertThat(entityies.get(2).getRstStartDate(), is(Timestamp.valueOf("2019-06-03 12:00:00")));
    assertThat(entityies.get(3).getOrdNo(), is(18L));
    assertThat(entityies.get(3).getPatId(), is(2L));
    assertThat(entityies.get(3).getRstInputClass(), is(10));
    assertThat(entityies.get(3).getRstDialysisState(), is("5"));
    assertThat(entityies.get(3).getRstBedName(), is("9"));
    assertThat(entityies.get(3).getRstStartDate(), is(Timestamp.valueOf("2019-06-03 12:00:00")));
    assertThat(entityies.get(4).getOrdNo(), is(19L));
    assertThat(entityies.get(4).getPatId(), is(2L));
    assertThat(entityies.get(4).getRstInputClass(), is(11));
    assertThat(entityies.get(4).getRstDialysisState(), is("6"));
    assertThat(entityies.get(4).getRstBedName(), is("9"));
    assertThat(entityies.get(4).getRstStartDate(), is(Timestamp.valueOf("2019-06-03 12:00:00")));
  }

  /**
   * selectTreatmentRecordResultMergeByOrdNo()の検証.
   * <p>
   * 条件：該当データあり、同日同患者の選択以外の実績なし、かつ 予定無し患者あり
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordResultMergeByOrdNo.before.sql")
  public void test_selectTreatmentRecordResultMergeByOrdNo_正常_同日同患者の選択以外の実績なし_予定無し患者あり() {

    // 事前準備
    final Long ordNo = 31L;

    // 実行
    List<TreatmentRecordResultMerge> entityies = target.selectTreatmentRecordResultMergeByOrdNo(ordNo);

    // 検証
    assertThat(entityies, notNullValue());
    assertThat(entityies, hasSize(2));
    assertThat(entityies.get(0).getOrdNo(), is(31L));
    assertThat(entityies.get(0).getPatId(), is(2L));
    assertThat(entityies.get(0).getPatName(), nullValue());
    assertThat(entityies.get(0).getRstInputClass(), is(3));
    assertThat(entityies.get(0).getRstDialysisState(), is("4"));
    assertThat(entityies.get(0).getRstTreatmentName(), is("5"));
    assertThat(entityies.get(0).getRstKurCd(), is(6L));
    assertThat(entityies.get(0).getRstKurName(), is("7"));
    assertThat(entityies.get(0).getRstBedCd(), is(8L));
    assertThat(entityies.get(0).getRstBedName(), is("9"));
    assertThat(entityies.get(0).getRstMachineName(), is("10"));
    assertThat(entityies.get(0).getRstCondSendDate(), is(Timestamp.valueOf("2019-06-01 12:00:00")));
    assertThat(entityies.get(0).getRstAcceptDate(), is(Timestamp.valueOf("2019-06-02 12:00:00")));
    assertThat(entityies.get(0).getRstStartDate(), is(Timestamp.valueOf("2019-06-03 12:00:00")));
    assertThat(entityies.get(0).getRstEndDate(), is(Timestamp.valueOf("2019-06-04 12:00:00")));
    assertThat(entityies.get(0).getRstReturnHomeDate(), is(Timestamp.valueOf("2019-06-05 12:00:00")));
    assertThat(entityies.get(0).getRstInOutClass(), is(11));
    assertThat(entityies.get(0).getRstDialysisCnt(), is(12));
    assertThat(entityies.get(0).getRstWardCd(), is(13));
    assertThat(entityies.get(0).getRstWardName(), is("14"));
    assertThat(entityies.get(0).getRstCourseCd(), is(15));
    assertThat(entityies.get(0).getRstCourseName(), is("16"));
    assertThat(entityies.get(0).getRstDw(), is(new BigDecimal("17.00")));
    assertThat(entityies.get(0).getRstPunctureUserInfo(), is("{\"value\": \"18\"}"));
    assertThat(entityies.get(0).getRstReturnUserInfo(), is("{\"value\": \"19\"}"));
    assertThat(entityies.get(0).getRstChargeUserInfo(), is("{\"value\": \"20\"}"));
    assertThat(entityies.get(0).getRstBloodCirculateTotal(), is(new BigDecimal("21.00")));
    assertThat(entityies.get(0).getRstRunningTime(), is(22));
    assertThat(entityies.get(0).getRstKtV(), is(new BigDecimal("23.00")));
    assertThat(entityies.get(0).getRecSetDate(), is(Timestamp.valueOf("2019-06-06 12:00:00")));
    assertThat(entityies.get(0).getSendCtlNo(), is(24L));
    assertThat(entityies.get(0).getBloodPurifierName(), is("25"));
    assertThat(entityies.get(0).getPullLeaveAmount(), is(new BigDecimal("2.60")));
    assertThat(entityies.get(0).getRstCondInfo(), is("{\"value\": \"27\"}"));
    assertThat(entityies.get(0).getRstMediInfo(), is("{\"value\": \"28\"}"));
    assertThat(entityies.get(0).getRstEquipInfo(), is("{\"value\": \"29\"}"));
    assertThat(entityies.get(0).getRstIndCommentInfo(), is("{\"value\": \"30\"}"));
    assertThat(entityies.get(0).getRstTareInfo(), is("{\"value\": \"31\"}"));
    assertThat(entityies.get(0).getRstOffWaterInfo(), is("{\"value\": \"32\"}"));
//    assertThat(entityies.get(0).getRstDeviceSetInfo(), is("{\"value\": \"33\"}"));// del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
    assertThat(entityies.get(0).getWeightScaleNo(), is(34L));
    assertThat(entityies.get(0).getRstWeightInfo(), is("{\"value\": \"35\"}"));
//    assertThat(entityies.get(0).getRstVitalInfo(), is("{\"value\": \"36\"}"));
    assertThat(entityies.get(0).getRstComplaintInfo(), is("{\"value\": \"37\"}"));
    assertThat(entityies.get(0).getRstTreatmentInfo(), is("{\"value\": \"38\"}"));
    assertThat(entityies.get(0).getRstTreatStaffInfo(), is("{\"value\": \"39\"}"));
    assertThat(entityies.get(0).getRstRoundsInfo(), is("{\"value\": \"40\"}"));
    assertThat(entityies.get(0).getUpDate(), is(Timestamp.valueOf("2019-06-26 19:00:00")));
    assertThat(entityies.get(0).getRegDate(), is(Timestamp.valueOf("2019-06-26 18:00:00")));
    // 2件目以降は相違がある項目のみ検証
    assertThat(entityies.get(1).getOrdNo(), is(32L));
    assertThat(entityies.get(1).getPatId(), nullValue());
    assertThat(entityies.get(1).getRstInputClass(), is(1));
    assertThat(entityies.get(1).getRstDialysisState(), is("4"));
    assertThat(entityies.get(1).getRstBedName(), is("9"));
    assertThat(entityies.get(1).getRstStartDate(), is(Timestamp.valueOf("2019-06-03 12:00:00")));
  }

  /**
   * selectTreatmentRecordResultMergeByOrdNo()の検証.
   * <p>
   * 条件：該当データあり、同日同患者の選択以外の実績あり、かつ 予定無し患者あり
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordResultMergeByOrdNo.before.sql")
  public void test_selectTreatmentRecordResultMergeByOrdNo_正常_同日同患者の選択以外の実績あり_予定無し患者あり() {

    // 事前準備
    final Long ordNo = 41L;

    // 実行
    List<TreatmentRecordResultMerge> entityies = target.selectTreatmentRecordResultMergeByOrdNo(ordNo);

    // 検証
    assertThat(entityies, notNullValue());
    assertThat(entityies, hasSize(3));
    assertThat(entityies.get(0).getOrdNo(), is(42L));
    assertThat(entityies.get(0).getPatId(), is(2L));
    assertThat(entityies.get(0).getPatName(), nullValue());
    assertThat(entityies.get(0).getRstInputClass(), is(2));
    assertThat(entityies.get(0).getRstDialysisState(), is("4"));
    assertThat(entityies.get(0).getRstTreatmentName(), is("5"));
    assertThat(entityies.get(0).getRstKurCd(), is(6L));
    assertThat(entityies.get(0).getRstKurName(), is("7"));
    assertThat(entityies.get(0).getRstBedCd(), is(8L));
    assertThat(entityies.get(0).getRstBedName(), is("1"));
    assertThat(entityies.get(0).getRstMachineName(), is("10"));
    assertThat(entityies.get(0).getRstCondSendDate(), is(Timestamp.valueOf("2019-06-01 12:00:00")));
    assertThat(entityies.get(0).getRstAcceptDate(), is(Timestamp.valueOf("2019-06-02 12:00:00")));
    assertThat(entityies.get(0).getRstStartDate(), is(Timestamp.valueOf("2019-06-03 12:00:00")));
    assertThat(entityies.get(0).getRstEndDate(), is(Timestamp.valueOf("2019-06-04 12:00:00")));
    assertThat(entityies.get(0).getRstReturnHomeDate(), is(Timestamp.valueOf("2019-06-05 12:00:00")));
    assertThat(entityies.get(0).getRstInOutClass(), is(11));
    assertThat(entityies.get(0).getRstDialysisCnt(), is(12));
    assertThat(entityies.get(0).getRstWardCd(), is(13));
    assertThat(entityies.get(0).getRstWardName(), is("14"));
    assertThat(entityies.get(0).getRstCourseCd(), is(15));
    assertThat(entityies.get(0).getRstCourseName(), is("16"));
    assertThat(entityies.get(0).getRstDw(), is(new BigDecimal("17.00")));
    assertThat(entityies.get(0).getRstPunctureUserInfo(), is("{\"value\": \"18\"}"));
    assertThat(entityies.get(0).getRstReturnUserInfo(), is("{\"value\": \"19\"}"));
    assertThat(entityies.get(0).getRstChargeUserInfo(), is("{\"value\": \"20\"}"));
    assertThat(entityies.get(0).getRstBloodCirculateTotal(), is(new BigDecimal("21.00")));
    assertThat(entityies.get(0).getRstRunningTime(), is(22));
    assertThat(entityies.get(0).getRstKtV(), is(new BigDecimal("23.00")));
    assertThat(entityies.get(0).getRecSetDate(), is(Timestamp.valueOf("2019-06-06 12:00:00")));
    assertThat(entityies.get(0).getSendCtlNo(), is(24L));
    assertThat(entityies.get(0).getBloodPurifierName(), is("25"));
    assertThat(entityies.get(0).getPullLeaveAmount(), is(new BigDecimal("2.60")));
    assertThat(entityies.get(0).getRstCondInfo(), is("{\"value\": \"27\"}"));
    assertThat(entityies.get(0).getRstMediInfo(), is("{\"value\": \"28\"}"));
    assertThat(entityies.get(0).getRstEquipInfo(), is("{\"value\": \"29\"}"));
    assertThat(entityies.get(0).getRstIndCommentInfo(), is("{\"value\": \"30\"}"));
    assertThat(entityies.get(0).getRstTareInfo(), is("{\"value\": \"31\"}"));
    assertThat(entityies.get(0).getRstOffWaterInfo(), is("{\"value\": \"32\"}"));
//    assertThat(entityies.get(0).getRstDeviceSetInfo(), is("{\"value\": \"33\"}"));// del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
    assertThat(entityies.get(0).getWeightScaleNo(), is(34L));
    assertThat(entityies.get(0).getRstWeightInfo(), is("{\"value\": \"35\"}"));
//    assertThat(entityies.get(0).getRstVitalInfo(), is("{\"value\": \"36\"}"));
    assertThat(entityies.get(0).getRstComplaintInfo(), is("{\"value\": \"37\"}"));
    assertThat(entityies.get(0).getRstTreatmentInfo(), is("{\"value\": \"38\"}"));
    assertThat(entityies.get(0).getRstTreatStaffInfo(), is("{\"value\": \"39\"}"));
    assertThat(entityies.get(0).getRstRoundsInfo(), is("{\"value\": \"40\"}"));
    assertThat(entityies.get(0).getUpDate(), is(Timestamp.valueOf("2019-06-26 19:00:00")));
    assertThat(entityies.get(0).getRegDate(), is(Timestamp.valueOf("2019-06-26 18:00:00")));
    // 2件目以降は相違がある項目のみ検証
    assertThat(entityies.get(1).getOrdNo(), is(43L));
    assertThat(entityies.get(1).getPatId(), nullValue());
    assertThat(entityies.get(1).getRstInputClass(), is(3));
    assertThat(entityies.get(1).getRstDialysisState(), is("4"));
    assertThat(entityies.get(1).getRstBedName(), is("9"));
    assertThat(entityies.get(1).getRstStartDate(), is(Timestamp.valueOf("2019-06-02 12:00:00")));
    assertThat(entityies.get(2).getOrdNo(), is(41L));
    assertThat(entityies.get(2).getPatId(), is(2L));
    assertThat(entityies.get(2).getRstInputClass(), is(1));
    assertThat(entityies.get(2).getRstDialysisState(), is("4"));
    assertThat(entityies.get(2).getRstBedName(), is("9"));
    assertThat(entityies.get(2).getRstStartDate(), is(Timestamp.valueOf("2019-06-03 12:00:00")));
  }

  /**
   * selectTreatmentRecordResultMergeByOrdNo()の検証.
   * <p>
   * 条件：該当データなし
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordResultMergeByOrdNo.before.sql")
  public void test_selectTreatmentRecordResultMergeByOrdNo_異常_該当データなし() {

    // 事前準備
    final Long ordNo = Long.MAX_VALUE;

    // 実行
    target.selectTreatmentRecordResultMergeByOrdNo(ordNo);
  }

  /**
   * selectTreatmentRecordResultMergeByOrdNo()の検証.
   * <p>
   * 条件：該当データが削除済
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordResultMergeByOrdNo.before.sql")
  public void test_selectTreatmentRecordResultMergeByOrdNo_異常_該当データ削除済み() {

    // 事前準備
    final Long ordNo = 99L;

    // 実行
    target.selectTreatmentRecordWeightByOrdNo(ordNo);
  }

  /**
   * updateTreatmentRecordForResultMerge()の検証.
   * <p>
   * 条件：治療記録（実績マージ）画面の入力項目に該当する項目を更新する.
   * 結果：該当データを更新できること（更新対象外項目は更新されていないこと）
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordResultMergeByOrdNo.before.sql")
  public void test_updateTreatmentRecordForResultMerge_正常() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordResultMerge entity = target.selectTreatmentRecordResultMergeByOrdNo(ordNo).get(0);

    entity.setOrdNo(99L);
    entity.setPatId(99L);
    entity.setPatName("テスト患者");
    entity.setRstInputClass(4);
    entity.setRstDialysisState("5");
    entity.setRstTreatmentName("6");
    entity.setRstKurCd(7L);
    entity.setRstKurName("8");
    entity.setRstBedCd(9L);
    entity.setRstBedName("10");
    entity.setRstMachineName("11");
    entity.setRstCondSendDate(Timestamp.valueOf("2019-06-02 12:00:00"));
    entity.setRstAcceptDate(Timestamp.valueOf("2019-06-03 12:00:00"));
    entity.setRstStartDate(Timestamp.valueOf("2019-06-04 12:00:00"));
    entity.setRstEndDate(Timestamp.valueOf("2019-06-05 12:00:00"));
    entity.setRstReturnHomeDate(Timestamp.valueOf("2019-06-06 12:00:00"));
    entity.setRstInOutClass(12);
    entity.setRstDialysisCnt(13);
    entity.setRstWardCd(14);
    entity.setRstWardName("15");
    entity.setRstCourseCd(16);
    entity.setRstCourseName("17");
    entity.setRstDw(new BigDecimal("18.00"));
    entity.setRstPunctureUserInfo("{\"value\": \"19\"}");
    entity.setRstReturnUserInfo("{\"value\": \"20\"}");
    entity.setRstChargeUserInfo("{\"value\": \"21\"}");
    entity.setRstBloodCirculateTotal(new BigDecimal("22.00"));
    entity.setRstRunningTime(23);
    entity.setRstKtV(new BigDecimal("24.00"));
    entity.setRecSetDate(Timestamp.valueOf("2019-06-07 12:00:00"));
    entity.setSendCtlNo(25L);
    entity.setBloodPurifierName("26");
    entity.setPullLeaveAmount(new BigDecimal("2.70"));
    entity.setRstCondInfo("{\"value\": \"28\"}");
    entity.setRstMediInfo("{\"value\": \"29\"}");
    entity.setRstEquipInfo("{\"value\": \"30\"}");
    entity.setRstIndCommentInfo("{\"value\": \"31\"}");
    entity.setRstTareInfo("{\"value\": \"32\"}");
    entity.setRstOffWaterInfo("{\"value\": \"33\"}");
//    entity.setRstDeviceSetInfo("{\"value\": \"34\"}");// del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
    entity.setWeightScaleNo(35L);
    entity.setRstWeightInfo("{\"value\": \"36\"}");
//    entity.setRstVitalInfo("{\"value\": \"37\"}");
    entity.setRstComplaintInfo("{\"value\": \"38\"}");
    entity.setRstTreatmentInfo("{\"value\": \"39\"}");
    entity.setRstTreatStaffInfo("{\"value\": \"40\"}");
    entity.setRstRoundsInfo("{\"value\": \"41\"}");

    // 実行
    int updateCount = target.updateTreatmentRecordForResultMerge(ordNo, entity);

    // 検証
    assertThat(updateCount, is(1));
    TreatmentRecordResultMerge updatedEntity = target.selectTreatmentRecordResultMergeByOrdNo(ordNo).get(0);
    assertThat(updatedEntity.getOrdNo(), is(1L));
    assertThat(updatedEntity.getPatId(), is(2L));
    assertThat(updatedEntity.getPatName(), nullValue());
    assertThat(updatedEntity.getRstInputClass(), is(3));
    assertThat(updatedEntity.getRstDialysisState(), is("4"));
    assertThat(updatedEntity.getRstTreatmentName(), is("5"));
    assertThat(updatedEntity.getRstKurCd(), is(7L));
    assertThat(updatedEntity.getRstKurName(), is("8"));
    assertThat(updatedEntity.getRstBedCd(), is(9L));
    assertThat(updatedEntity.getRstBedName(), is("10"));
    assertThat(updatedEntity.getRstMachineName(), is("10"));
    assertThat(updatedEntity.getRstCondSendDate(), is(Timestamp.valueOf("2019-06-02 12:00:00")));
    assertThat(updatedEntity.getRstAcceptDate(), is(Timestamp.valueOf("2019-06-03 12:00:00")));
    assertThat(updatedEntity.getRstStartDate(), is(Timestamp.valueOf("2019-06-04 12:00:00")));
    assertThat(updatedEntity.getRstEndDate(), is(Timestamp.valueOf("2019-06-05 12:00:00")));
    assertThat(updatedEntity.getRstReturnHomeDate(), is(Timestamp.valueOf("2019-06-06 12:00:00")));
    assertThat(updatedEntity.getRstInOutClass(), is(12));
    assertThat(updatedEntity.getRstDialysisCnt(), is(13));
    assertThat(updatedEntity.getRstWardCd(), is(14));
    assertThat(updatedEntity.getRstWardName(), is("15"));
    assertThat(updatedEntity.getRstCourseCd(), is(16));
    assertThat(updatedEntity.getRstCourseName(), is("17"));
    assertThat(updatedEntity.getRstDw(), is(new BigDecimal("17.00")));
    assertThat(updatedEntity.getRstPunctureUserInfo(), is("{\"value\": \"19\"}"));
    assertThat(updatedEntity.getRstReturnUserInfo(), is("{\"value\": \"20\"}"));
    assertThat(updatedEntity.getRstChargeUserInfo(), is("{\"value\": \"21\"}"));
    assertThat(updatedEntity.getRstBloodCirculateTotal(), is(new BigDecimal("22.00")));
    assertThat(updatedEntity.getRstRunningTime(), is(23));
    assertThat(updatedEntity.getRstKtV(), is(new BigDecimal("24.00")));
    assertThat(updatedEntity.getRecSetDate(), is(Timestamp.valueOf("2019-06-07 12:00:00")));
    assertThat(updatedEntity.getSendCtlNo(), is(25L));
    assertThat(updatedEntity.getBloodPurifierName(), is("26"));
    assertThat(updatedEntity.getPullLeaveAmount(), is(new BigDecimal("2.70")));
    assertThat(updatedEntity.getRstCondInfo(), is("{\"value\": \"28\"}"));
    assertThat(updatedEntity.getRstMediInfo(), is("{\"value\": \"29\"}"));
    assertThat(updatedEntity.getRstEquipInfo(), is("{\"value\": \"30\"}"));
    assertThat(updatedEntity.getRstIndCommentInfo(), is("{\"value\": \"31\"}"));
    assertThat(updatedEntity.getRstTareInfo(), is("{\"value\": \"32\"}"));
    assertThat(updatedEntity.getRstOffWaterInfo(), is("{\"value\": \"33\"}"));
//    assertThat(updatedEntity.getRstDeviceSetInfo(), is("{\"value\": \"34\"}"));// del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
    assertThat(updatedEntity.getWeightScaleNo(), is(35L));
    assertThat(updatedEntity.getRstWeightInfo(), is("{\"value\": \"36\"}"));
//    assertThat(updatedEntity.getRstVitalInfo(), is("{\"value\": \"37\"}"));
    assertThat(updatedEntity.getRstComplaintInfo(), is("{\"value\": \"38\"}"));
    assertThat(updatedEntity.getRstTreatmentInfo(), is("{\"value\": \"39\"}"));
    assertThat(updatedEntity.getRstTreatStaffInfo(), is("{\"value\": \"40\"}"));
    assertThat(updatedEntity.getRstRoundsInfo(), is("{\"value\": \"41\"}"));
  }

  /**
   * updateTreatmentRecordForResultMerge()の検証.
   * <p>
   * 条件：存在しないレコードを更新する
   * 結果：更新件数0件であること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordResultMergeByOrdNo.before.sql")
  public void test_updateTreatmentRecordForResultMerge_異常_存在しないレコード更新() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordResultMerge entity = target.selectTreatmentRecordResultMergeByOrdNo(ordNo).get(0);

    // 実行
    Long notFoundOrdNo = Long.MAX_VALUE;

    int count = target.updateTreatmentRecordForResultMerge(notFoundOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForResultMerge()の検証.
   * <p>
   * 条件：削除済レコードを更新する
   * 結果：更新件数0件であること
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/TreatmentRecordDaoTest.selectTreatmentRecordResultMergeByOrdNo.before.sql")
  public void test_updateTreatmentRecordForResultMerge_異常_削除済レコード更新() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordResultMerge entity = target.selectTreatmentRecordResultMergeByOrdNo(ordNo).get(0);

    // 実行
    Long deletedOrdNo = 20L;

    int count = target.updateTreatmentRecordForResultMerge(deletedOrdNo, entity);

    // 検証
    assertThat(count, is(0));
  }

  /**
   * updateTreatmentRecordForResultMerge()の検証.
   * <p>
   * 条件：過去実績のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されること.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForResultMerge_正常_版番号_版番号更新フラグ_更新する() {

    // 事前準備
    Long ordNo = 100001L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("6"));

    // 実行
    TreatmentRecordResultMerge entity = target.selectTreatmentRecordResultMergeByOrdNo(ordNo).get(0);
    int updateCount = target.updateTreatmentRecordForResultMerge(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("6"));
    // 検証：確定フラグが更新されていない事
    assertThat(updated.getIsConfirm(), is("0"));
  }

  /**
   * updateTreatmentRecordForResultMerge()の検証.
   * <p>
   * 条件：過去実績以外のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されないこと.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForResultMerge_正常_版番号_版番号更新フラグ_更新しない() {

    // 事前準備
    Long ordNo = 100002L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("1"));

    // 実行
    TreatmentRecordResultMerge entity = target.selectTreatmentRecordResultMergeByOrdNo(ordNo).get(0);
    int updateCount = target.updateTreatmentRecordForResultMerge(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("1"));
  }

  /**
   * updateTreatmentRecordForVersionInfo()の検証.
   * <p>
   * 条件：版情報を更新する（過去実績のデータ）.
   * 結果：版番号と版番号更新フラグが更新されること.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForVersionInfo_正常_版番号_版番号更新フラグ_更新する() {

    // 事前準備
    TreatmentRecordVersionInfo entity = new TreatmentRecordVersionInfo() {
      {
        setOrdNo(100001L);
        setUpDate(Timestamp.valueOf("2019-08-27 12:00:00"));
      }
    };

    OrdMain ordMain = ordMainDao.selectByOrdNo(entity.getOrdNo());
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("6"));

    // 実行
    int updateCount = target.updateTreatmentRecordForVersionInfo(entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(entity.getOrdNo());
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("6"));
    // 検証：確定フラグが更新されていない事
    assertThat(updated.getIsConfirm(), is("0"));
  }

  /**
   * updateTreatmentRecordForVersionInfo()の検証.
   * <p>
   * 条件：版情報を更新する（過去実績以外のデータ）.
   * 結果：版番号と版番号更新フラグが更新されないこと.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordForVersionInfo_正常_版番号_版番号更新フラグ_更新しない() {

    // 事前準備
    TreatmentRecordVersionInfo entity = new TreatmentRecordVersionInfo() {
      {
        setOrdNo(100002L);
        setUpDate(Timestamp.valueOf("2019-08-27 12:00:00"));
      }
    };

    OrdMain ordMain = ordMainDao.selectByOrdNo(entity.getOrdNo());
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("1"));

    // 実行
    int updateCount = target.updateTreatmentRecordForVersionInfo(entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(entity.getOrdNo());
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("1"));
  }

  /**
   * selectMstTreatmentByOrdNo()の検証.
   * <p>
   * 条件：該当する治療記録と治療方法マスタが存在する.
   * 結果：治療記録の治療方法コードに該当する治療方法マスタが取得できること.
   * </p>
   */
  @Test
  public void test_selectMstTreatmentByOrdNo_正常() {
    // 事前準備
    Long ordNo = 200001L;

    // 実行
    MstTreatment result = target.selectMstTreatmentByOrdNo(ordNo);

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.getTreatmentCd(), is(1));
    assertThat(result.getTreatmentName(), is("治療方法１"));
  }

  /**
   * selectMstTreatmentByOrdNo()の検証.
   * <p>
   * 条件：該当する治療記録が削除済.
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void test_selectMstTreatmentByOrdNo_異常_削除済() {
    // 事前準備
    Long ordNo = 200002L;

    // 実行
    target.selectMstTreatmentByOrdNo(ordNo);
  }
}
