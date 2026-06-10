package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MstStaffFacility;
import jp.co.nikkiso.ntss.core.entity.custom.ChargeStaffFacility;

/**
 * {@link MstStaffFacilityDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MstStaffFacilityDaoTest.before.sql")
public class MstStaffFacilityDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MstStaffFacilityDao target;

  /**
   * selectAll()の検証.
   * <p>
   *   条件：なし
   *   結果：取得結果2件であること
   * </p>
   */
  @Test
  public void test_selectAll_正常() {
    // 実行
    List<MstStaffFacility> result = target.selectAll();

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.size(), is(4));
    assertThat(result.get(0).getUserId(), is(900000000001L));
    assertThat(result.get(0).getFacilityCd(), is("900001"));
    assertThat(result.get(1).getUserId(), is(900000000001L));
    assertThat(result.get(1).getFacilityCd(), is("900002"));
    assertThat(result.get(2).getUserId(), is(990000000001L));
    assertThat(result.get(2).getFacilityCd(), is("900001"));
    assertThat(result.get(3).getUserId(), is(990000000001L));
    assertThat(result.get(3).getFacilityCd(), is("900003"));
  }

  /**
   * selectByUserId()の検証.
   * <p>
   *   条件：データが存在するユーザーIDを指定
   *   結果：取得結果2件であること
   * </p>
   */
  @Test
  public void test_selectByUserId_正常_検索結果2件() {
    // 実行
    List<MstStaffFacility> result = target.selectByUserId(900000000001L);

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.size(), is(2));
    assertThat(result.get(0).getUserId(), is(900000000001L));
    assertThat(result.get(0).getFacilityCd(), is("900001"));
    assertThat(result.get(1).getUserId(), is(900000000001L));
    assertThat(result.get(1).getFacilityCd(), is("900002"));
  }

  /**
   * selectByUserId()の検証.
   * <p>
   *   条件：データが存在しないユーザーIDを指定
   *   結果：取得結果0件であること
   * </p>
   */
  @Test
  public void test_selectByUserId_正常_検索結果0件() {
    // 実行
    List<MstStaffFacility> result = target.selectByUserId(1L);

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result, is(Collections.emptyList()));
  }

  /**
   * selectByKey()の検証.
   * <p>
   *   条件：データが存在するユーザーID・施設コードを指定
   *   結果：結果が取得できること
   * </p>
   */
  @Test
  public void test_selectByKey_正常_データあり() {
    // 実行
    MstStaffFacility result = target.selectByKey(900000000001L, "900001");

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.getUserId(), is(900000000001L));
    assertThat(result.getFacilityCd(), is("900001"));
  }

  /**
   * selectByKey()の検証.
   * <p>
   *   条件：データが存在しないユーザーID・施設コードを指定
   *   結果：結果がnullになること
   * </p>
   */
  @Test
  public void test_selectByKey_正常_データなし() {
    // 実行
    MstStaffFacility result = target.selectByKey(900000000002L, "900001");

    // 検証
    assertThat(result, is(nullValue()));
  }

  /**
   * test_selectStaffFacilities()の検証.
   * <p>
   *   条件：データが存在するユーザーIDを指定
   *   結果：取得結果2件であること
   * </p>
   */
  @Test
  public void test_selectStaffFacilities_正常_検索結果2件() {
    // 実行
    List<ChargeStaffFacility> result = target.selectStaffFacilities(900000000001L);

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.size(), is(2));
    assertThat(result.get(0).getFacilityCd(), is("900001"));
    assertThat(result.get(0).getFacilityName(), is("テスト施設1"));
    assertThat(result.get(0).getFacilityNameKana(), is("テストシセツ1"));
    assertThat(result.get(0).getDepartmentCd(), is("9001"));
    assertThat(result.get(0).getPrefecturesCd(), is("01"));
    assertThat(result.get(0).getPrefecturesName(), is("東京都"));
    assertThat(result.get(1).getFacilityCd(), is("900002"));
    assertThat(result.get(1).getFacilityName(), is("テスト施設2"));
    assertThat(result.get(1).getFacilityNameKana(), is("テストシセツ2"));
    assertThat(result.get(1).getDepartmentCd(), is("9002"));
    assertThat(result.get(1).getPrefecturesCd(), is("02"));
    assertThat(result.get(1).getPrefecturesName(), is("福井県"));
  }

  /**
   * test_selectStaffFacilities()の検証.
   * <p>
   *   条件：データが存在しないユーザーIDを指定
   *   結果：結果がnullになること
   * </p>
   */
  @Test
  public void test_selectStaffFacilities_正常_検索結果0件() {
    // 実行
    List<ChargeStaffFacility> result = target.selectStaffFacilities(900000000002L);

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.size(), is(0));
  }

  /**
   * selectChargeStaffFacilities()の検証.
   * <p>
   *   条件：担当施設があるユーザーIDを指定
   *   結果：全施設のデータが返り、担当している施設のフラグがtrueであること
   * </p>
   */
  @Test
  public void test_selectChargeStaffFacilities_担当施設があるユーザー() {
    // 実行
    List<ChargeStaffFacility> result = target.selectChargeStaffFacilities(900000000001L);

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.size(), is(3));
    assertThat(result.get(0).getIsCharge(), is(true));
    assertThat(result.get(0).getFacilityCd(), is("900001"));
    assertThat(result.get(0).getFacilityName(), is("テスト施設1"));
    assertThat(result.get(0).getFacilityNameKana(), is("テストシセツ1"));
    assertThat(result.get(0).getDepartmentCd(), is("9001"));
    assertThat(result.get(0).getPrefecturesCd(), is("01"));
    assertThat(result.get(0).getPrefecturesName(), is("東京都"));
    assertThat(result.get(1).getIsCharge(), is(true));
    assertThat(result.get(1).getFacilityCd(), is("900002"));
    assertThat(result.get(1).getFacilityName(), is("テスト施設2"));
    assertThat(result.get(1).getFacilityNameKana(), is("テストシセツ2"));
    assertThat(result.get(1).getDepartmentCd(), is("9002"));
    assertThat(result.get(1).getPrefecturesCd(), is("02"));
    assertThat(result.get(1).getPrefecturesName(), is("福井県"));
    assertThat(result.get(2).getIsCharge(), is(false));
    assertThat(result.get(2).getFacilityCd(), is("900003"));
    assertThat(result.get(2).getFacilityName(), is("テスト施設3"));
    assertThat(result.get(2).getFacilityNameKana(), is("テストシセツ3"));
    assertThat(result.get(2).getDepartmentCd(), is("9003"));
    assertThat(result.get(2).getPrefecturesCd(), is("01"));
    assertThat(result.get(2).getPrefecturesName(), is("東京都"));

  }

  /**
   * selectChargeStaffFacilities()の検証.
   * <p>
   *   条件：担当施設がないユーザーIDを指定
   *   結果：全施設のデータが返り、担当施設フラグが全てfalseであること
   * </p>
   */
  @Test
  public void test_selectChargeStaffFacilities_担当施設がないユーザー() {
    // 実行
    List<ChargeStaffFacility> result = target.selectChargeStaffFacilities(900000000002L);

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.size(), is(3));
    assertThat(result.get(0).getIsCharge(), is(false));
    assertThat(result.get(0).getFacilityCd(), is("900001"));
    assertThat(result.get(0).getFacilityName(), is("テスト施設1"));
    assertThat(result.get(0).getFacilityNameKana(), is("テストシセツ1"));
    assertThat(result.get(0).getDepartmentCd(), is("9001"));
    assertThat(result.get(0).getPrefecturesCd(), is("01"));
    assertThat(result.get(0).getPrefecturesName(), is("東京都"));
    assertThat(result.get(1).getIsCharge(), is(false));
    assertThat(result.get(1).getFacilityCd(), is("900003"));
    assertThat(result.get(1).getFacilityName(), is("テスト施設3"));
    assertThat(result.get(1).getFacilityNameKana(), is("テストシセツ3"));
    assertThat(result.get(1).getDepartmentCd(), is("9003"));
    assertThat(result.get(1).getPrefecturesCd(), is("01"));
    assertThat(result.get(1).getPrefecturesName(), is("東京都"));
    assertThat(result.get(2).getIsCharge(), is(false));
    assertThat(result.get(2).getFacilityCd(), is("900002"));
    assertThat(result.get(2).getFacilityName(), is("テスト施設2"));
    assertThat(result.get(2).getFacilityNameKana(), is("テストシセツ2"));
    assertThat(result.get(2).getDepartmentCd(), is("9002"));
    assertThat(result.get(2).getPrefecturesCd(), is("02"));
    assertThat(result.get(2).getPrefecturesName(), is("福井県"));

  }

  /**
   * deleteByUserId()の検証.
   *
   * <p>
   *   条件：担当施設があるユーザーIDを指定
   *   結果：紐付く担当施設のレコードが削除されること
   * </p>
   */
  @Test
  public void test_deleteByUserId_正常_削除対象あり() {
    int beforeSize = target.selectAll().size();

    // 実行
    int deleteSize = target.deleteByUserId(900000000001L);
    List<MstStaffFacility> msf = target.selectAll();

    // 検証
    assertThat(beforeSize, is(4));
    assertThat(deleteSize, is(2));
    assertThat(msf.size(), is(2));
    assertThat(msf.get(0).getUserId(), is(990000000001L));
    assertThat(msf.get(0).getFacilityCd(), is("900001"));
    assertThat(msf.get(1).getUserId(), is(990000000001L));
    assertThat(msf.get(1).getFacilityCd(), is("900003"));
  }

  /**
   * deleteByUserId()の検証.
   *
   * <p>
   *   条件：担当施設がないユーザーIDを指定
   *   結果：レコードが削除されないこと
   * </p>
   */
  @Test
  public void test_deleteByUserId_正常_削除対象なし() {
    int beforeSize = target.selectAll().size();

    // 実行
    int deleteSize = target.deleteByUserId(900000000003L);
    List<MstStaffFacility> msf = target.selectAll();

    // 検証
    assertThat(beforeSize, is(4));
    assertThat(deleteSize, is(0));
    assertThat(msf.size(), is(4));
  }

  /**
   * insert(List<MstStaffFacility>)の検証.
   *
   * <p>
   *   条件：ユーザーに紐づく施設を2件登録
   *   結果：レコードが2件登録されること
   * </p>
   */
  @Test
  public void test_insert_正常_2件登録() {

    int beforeSize = target.selectAll().size();
    List<MstStaffFacility> msf = Arrays.asList(
            getMstStaffFacility(900000000001L, "900003"),
            getMstStaffFacility(900000000003L, "900001")
    );

    // 実行
    int[] insertSize = target.insert(msf);
    int afterSize = target.selectAll().size();

    // 検証
    assertThat(insertSize.length, is(2));
    assertThat(insertSize[0], is(1));
    assertThat(insertSize[1], is(1));
    assertThat(afterSize, is(beforeSize + msf.size()));
    assertThat(target.selectByKey(900000000001L, "900003"), notNullValue());
    assertThat(target.selectByKey(900000000003L, "900001"), notNullValue());
  }

  /**
   * insert(List<MstStaffFacility>)の検証.
   *
   * <p>
   *   条件：登録施設が0件であること
   *   結果：レコードが登録されないこと
   * </p>
   */
  @Test
  public void test_insert_正常_登録件数0_空のリスト() {

    int beforeSize = target.selectAll().size();

    // 実行
    int[] insertSize = target.insert(Collections.emptyList());
    int afterSize = target.selectAll().size();

    // 検証
    assertThat(insertSize.length, is(0));
    assertThat(beforeSize, is(afterSize));
  }

  /**
   * ユーザーID、施設コードを設定したMstStaffFacilityエンティティを返す
   *
   * @param userId ユーザーID
   * @param facilityCd 施設コード
   * @return MstStaffFacility
   */
  private MstStaffFacility getMstStaffFacility(Long userId, String facilityCd) {
    return new MstStaffFacility() {
      {
        setUserId(userId);
        setFacilityCd(facilityCd);
      }
    };
  }
}
