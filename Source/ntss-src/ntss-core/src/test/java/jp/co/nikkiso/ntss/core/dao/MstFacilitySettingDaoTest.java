package jp.co.nikkiso.ntss.core.dao;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;

import java.util.List;

/**
 * {@link MstFacilitySettingDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql(value = "classpath:dao.script/MstFacilitySettingDaoTest.before.sql")
public class MstFacilitySettingDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MstFacilitySettingDao target;

  /**
   * getBySettingNoAndCd()の検証.
   * <p>
   *   条件：該当データあり(sys側とmst側の両方に設定済み)
   *   結果：レコードが取得できること／value値がmat側の値であること
   * </p>
   */
  @Test
  public void test_getBySettingNoAndCd_成功_データあり() {
    // arrange
    final String facilityCd = "000001";
    final String facility_setting_no = "1001";

    // action
    final FacilitySettingInfo result = target.getBySettingNoAndCd(facilityCd,facility_setting_no);

    // assert
    assertThat(result).isNotNull();
    final FacilitySettingInfo FacilitySettingInfo = result;
    assertThat(FacilitySettingInfo.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(FacilitySettingInfo.getFacilitySettingNo()).isEqualTo(facility_setting_no);
    assertThat(FacilitySettingInfo.getSettingName()).isEqualTo("テストデータ1");
    assertThat(FacilitySettingInfo.getInputType()).isEqualTo(4);
    assertThat(FacilitySettingInfo.getValue()).isEqualTo("1");
    assertThat(FacilitySettingInfo.getFunctionName()).isEqualTo("患者更新モード");
    assertThat(FacilitySettingInfo.getMakerSetting()).isEqualTo(0);
    assertThat(FacilitySettingInfo.getDispOrder()).isEqualTo(1);
  }

  /**
   * getBySettingNoAndCd()の検証.
   * <p>
   *   条件：該当データなし(該当施設設定番号レコードがsysに無し)
   *   結果：レコードが取得できないこと
   * </p>
   */
  @Test
  public void test_getBySettingNoAndCd_成功_データなし_該当施設設定番号レコードなし() {
    // arrange
    final String facilityCd = "000001";
    final String facility_setting_no = "4001";
    // action
    final FacilitySettingInfo result = target.getBySettingNoAndCd(facilityCd,facility_setting_no);

    // assert
    assertThat(result).isNull();
  }


  /**
   * getBySettingNoAndCd()の検証.
   * <p>
   *   条件：該当データあり（mstに無いためsysデータから取得)
   *   結果：レコードが取得できること
   * </p>
   */
  @Test
  public void test_getBySettingNoAndCd_成功_データなし_該当管理番号レコードなし() {
    // arrange
    final String facilityCd = "000001";
    final String facility_setting_no = "2001";

    // action
    final FacilitySettingInfo result = target.getBySettingNoAndCd(facilityCd,facility_setting_no);

    // assert
    assertThat(result).isNotNull();
    final FacilitySettingInfo FacilitySettingInfo = result;
    assertThat(FacilitySettingInfo.getFacilityCd()).isNotEqualTo(facilityCd);
    assertThat(FacilitySettingInfo.getFacilitySettingNo()).isEqualTo(facility_setting_no);
    assertThat(FacilitySettingInfo.getSettingName()).isEqualTo("テストデータ4");
    assertThat(FacilitySettingInfo.getInputType()).isEqualTo(3);
    assertThat(FacilitySettingInfo.getValue()).isEqualTo("0");
    assertThat(FacilitySettingInfo.getFunctionName()).isEqualTo("透析困難リセット");
    assertThat(FacilitySettingInfo.getMakerSetting()).isEqualTo(0);
    assertThat(FacilitySettingInfo.getDispOrder()).isEqualTo(4);
  }


  /**
   * getByFacilityCdAndCtlNo()の検証.
   * <p>
   *   条件：該当データなし(パラメータに値がない）
   *   結果：レコードが取得できないこと
   * </p>
   */
  @Test
  public void test_getBySettingNoAndCd_失敗_対象データ無し() {
    // arrange
    final String facilityCd = "000001";
    final String facility_setting_no = null;
    // action
    final FacilitySettingInfo result = target.getBySettingNoAndCd(facilityCd,facility_setting_no);

    // assert
    assertThat(result).isNull();
  }


  /**
   * selectFacilitySetting()の検証.
   * <p>
   *   条件：該当データ1件あり
   *   結果：レコードが取得できること
   * </p>
   */
  @Test
  public void test_selectFacilitySetting_成功_データ単体あり() {
    // arrange
    final String facilityCd = "000001";
    final String facility_setting_no = "1001";

    // action
    final List<FacilitySettingInfo> result = target.selectFacilitySetting(facilityCd,facility_setting_no);

    // assert
    assertThat(result).isNotEmpty();
    final FacilitySettingInfo FacilitySettingInfo = result.get(0);
    assertThat(FacilitySettingInfo.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(FacilitySettingInfo.getFacilitySettingNo()).isEqualTo(facility_setting_no);
    assertThat(FacilitySettingInfo.getSettingName()).isEqualTo("テストデータ1");
    assertThat(FacilitySettingInfo.getInputType()).isEqualTo(4);
    assertThat(FacilitySettingInfo.getValue()).isEqualTo("1");
    assertThat(FacilitySettingInfo.getFunctionName()).isEqualTo("患者更新モード");
    assertThat(FacilitySettingInfo.getMakerSetting()).isEqualTo(0);
    assertThat(FacilitySettingInfo.getDispOrder()).isEqualTo(1);

    //検索結果件数チェック
    assertThat(result.size()).isEqualTo(1);

  }

  /**
   * selectFacilitySetting()の検証.
   * <p>
   *   条件：該当データなし(該当施設設定番号レコードがsysに無し)
   *   結果：レコードが取得できないこと
   * </p>
   */
  @Test
  public void test_selectFacilitySetting_成功_データなし_該当施設設定番号レコードなし() {
    // arrange
    final String facilityCd = "000001";
    final String facility_setting_no = "4001";
    // action
    final List<FacilitySettingInfo> result = target.selectFacilitySetting(facilityCd,facility_setting_no);

    // assert
    assertThat(result).isEmpty();
  }

  /**
   * selectFacilitySetting()の検証.
   * <p>
   *   条件：該当データ1件あり
   *   結果：レコードが取得できること
   * </p>
   */
  @Test
  public void test_selectFacilitySetting_成功_データ複数あり() {
    // arrange
    final String facilityCd = "000001";
    final String facility_setting_no = null;

    // action
    final List<FacilitySettingInfo> result = target.selectFacilitySetting(facilityCd,facility_setting_no);

    // assert
    assertThat(result).isNotEmpty();
    // orderNoの値順であることのチェック
    final FacilitySettingInfo FacilitySettingInfo = result.get(0);
    assertThat(FacilitySettingInfo.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(FacilitySettingInfo.getFacilitySettingNo()).isEqualTo("1001");
    assertThat(FacilitySettingInfo.getSettingName()).isEqualTo("テストデータ1");
    assertThat(FacilitySettingInfo.getInputType()).isEqualTo(4);
    assertThat(FacilitySettingInfo.getValue()).isEqualTo("1");
    assertThat(FacilitySettingInfo.getFunctionName()).isEqualTo("患者更新モード");
    assertThat(FacilitySettingInfo.getMakerSetting()).isEqualTo(0);
    assertThat(FacilitySettingInfo.getDispOrder()).isEqualTo(1);

    //検索結果件数チェック
    assertThat(result.size()).isEqualTo(4);

  }

}
