package jp.co.nikkiso.ntss.core.dao;

import static java.util.Arrays.asList;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;

import java.math.BigDecimal;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.SysPersonalSettingsDefine;

/**
 * {@link SysPersonalSettingsDefineDao}のテスト
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/SysPersonalSettingsDefineDaoTest.before.sql")
public class SysPersonalSettingsDefineDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private SysPersonalSettingsDefineDao target;

  /**
   * selectByTabDefineCd()の検証.
   * <p>
   *   条件：該当データあり
   *   結果：レコードが取得できること
   * </p>
   */
  @Test
  public void selectByTabDefineCd_正常_データあり() {
    // arrange
    final Integer tabDefineCd = 11;

    // action
    final SysPersonalSettingsDefine result = target.selectByTabDefineCd(tabDefineCd);

    // assert
    assertThat(result.getPersonalSettingsCd()).isEqualTo(1);
    assertThat(result.getTabDefineCd()).isEqualTo(tabDefineCd);
    assertThat(result.getEditLevel()).isEqualTo("1");

    final List<SysPersonalSettingsDefine.ItemInfoDetail> itemInfoDetail
      = result.getItemInfo().getItemInfoDetail();
    assertThat(itemInfoDetail)
      .hasSize(3)
      .extracting(
        SysPersonalSettingsDefine.ItemInfoDetail::getType,
        SysPersonalSettingsDefine.ItemInfoDetail::getTitle,
        SysPersonalSettingsDefine.ItemInfoDetail::getIdentifier
      )
      .containsOnly(
        tuple(SysPersonalSettingsDefine.ItemType.STRING, "項目3-1", "1"),
        tuple(SysPersonalSettingsDefine.ItemType.NUMBER, "項目3-2", "2"),
        tuple(SysPersonalSettingsDefine.ItemType.COMBO2, "項目3-4", "4")
      )
    ;

    final SysPersonalSettingsDefine.ItemInfoValidation itemInfoValidation1
      = itemInfoDetail.get(0).getValidation();
    assertThat(itemInfoValidation1.getMax()).isNull();
    assertThat(itemInfoValidation1.getMin()).isNull();
    assertThat(itemInfoValidation1.getRequired()).isEqualTo(true);
    assertThat(itemInfoValidation1.getDigit()).isNull();
    assertThat(itemInfoValidation1.getMaxlength()).isEqualTo(4);

    final SysPersonalSettingsDefine.ItemInfoValidation itemInfoValidation2
      = itemInfoDetail.get(1).getValidation();
    assertThat(itemInfoValidation2.getMax()).isEqualTo(BigDecimal.valueOf(5000L));
    assertThat(itemInfoValidation2.getMin()).isNull();
    assertThat(itemInfoValidation2.getRequired()).isNull();
    assertThat(itemInfoValidation2.getDigit()).isNull();
    assertThat(itemInfoValidation2.getMaxlength()).isNull();

    final SysPersonalSettingsDefine.ItemInfoValidation itemInfoValidation3
      = itemInfoDetail.get(2).getValidation();
    assertThat(itemInfoValidation3).isNull();

    final List<SysPersonalSettingsDefine.StaticCombo> staticCombos
      = result.getComboData().getCombos();
    final SysPersonalSettingsDefine.StaticCombo staticCombo1 = staticCombos.get(0);
    assertThat(staticCombo1.getSettingIdentifier()).isEqualTo("1");
    assertThat(staticCombo1.getValues())
      .extracting(
        SysPersonalSettingsDefine.StaticComboValue::getText,
        SysPersonalSettingsDefine.StaticComboValue::getValue
      )
      .containsOnly(
        tuple("データ1", 1),
        tuple("データ2", 2),
        tuple("データ5", 5)
      )
    ;
    final SysPersonalSettingsDefine.StaticCombo staticCombo2 = staticCombos.get(1);
    assertThat(staticCombo2.getSettingIdentifier()).isEqualTo("2");
    assertThat(staticCombo2.getValues())
      .extracting(
        SysPersonalSettingsDefine.StaticComboValue::getText,
        SysPersonalSettingsDefine.StaticComboValue::getValue
      )
      .containsOnly(
        tuple("データ6", 6),
        tuple("データ7", 7)
      )
    ;

    final List<SysPersonalSettingsDefine.ReferenceCombo> referenceComboDef
      = result.getReferenceComboDef().getCombos();
    assertThat(referenceComboDef).hasSize(1);
    final SysPersonalSettingsDefine.ReferenceCombo referenceComboDef1 = referenceComboDef.get(0);
    assertThat(referenceComboDef1.getSettingIdentifier()).isEqualTo("4");
    assertThat(referenceComboDef1.getTargetTable().getName()).isEqualTo("mst_treatment");
    assertThat(referenceComboDef1.getTargetTable().getIdentifier()).isEqualTo("treatment_cd");
    assertThat(referenceComboDef1.getTargetTable().getDisplayColumn()).isEqualTo("treatment_name");
    assertThat(referenceComboDef1.getTargetTable().getReferencedColumn()).isEqualTo("treatment_cd");
  }

  /**
   * selectByTabDefineCd()の検証.
   * <p>
   *   条件：該当データなし
   *   結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void selectByTabDefineCd_異常_データなし() {
    // arrange
    final Integer cd = 4;

    // action
    // assert
    target.selectByTabDefineCd(cd);
  }



  /**
   * selectByTabDefineCds()の検証.
   * <p>
   *   条件：該当データあり
   *   結果：レコードが取得できること
   * </p>
   */
  @Test
  public void selectByTabDefineCds_正常_データあり() {
    // arrange
    final Iterable<Integer> tabDefineCds = asList(11, 33, 44);

    // action
    final List<SysPersonalSettingsDefine> results = target.selectByTabDefineCds(tabDefineCds);

    // assert
    assertThat(results).hasSize(2);

    {
      final SysPersonalSettingsDefine result = results.get(0);
      assertThat(result.getPersonalSettingsCd()).isEqualTo(1);
      assertThat(result.getTabDefineCd()).isEqualTo(((List<Integer>) tabDefineCds).get(0));
      assertThat(result.getEditLevel()).isEqualTo("1");

      final List<SysPersonalSettingsDefine.ItemInfoDetail> itemInfoDetail
        = result.getItemInfo().getItemInfoDetail();
      assertThat(itemInfoDetail)
        .hasSize(3)
        .extracting(
          SysPersonalSettingsDefine.ItemInfoDetail::getType,
          SysPersonalSettingsDefine.ItemInfoDetail::getTitle,
          SysPersonalSettingsDefine.ItemInfoDetail::getIdentifier
        )
        .containsOnly(
          tuple(SysPersonalSettingsDefine.ItemType.STRING, "項目3-1", "1"),
          tuple(SysPersonalSettingsDefine.ItemType.NUMBER, "項目3-2", "2"),
          tuple(SysPersonalSettingsDefine.ItemType.COMBO2, "項目3-4", "4")
        )
      ;

      final SysPersonalSettingsDefine.ItemInfoValidation itemInfoValidation1
        = itemInfoDetail.get(0).getValidation();
      assertThat(itemInfoValidation1.getMax()).isNull();
      assertThat(itemInfoValidation1.getMin()).isNull();
      assertThat(itemInfoValidation1.getRequired()).isEqualTo(true);
      assertThat(itemInfoValidation1.getDigit()).isNull();
      assertThat(itemInfoValidation1.getMaxlength()).isEqualTo(4);

      final SysPersonalSettingsDefine.ItemInfoValidation itemInfoValidation2
        = itemInfoDetail.get(1).getValidation();
      assertThat(itemInfoValidation2.getMax()).isEqualTo(BigDecimal.valueOf(5000L));
      assertThat(itemInfoValidation2.getMin()).isNull();
      assertThat(itemInfoValidation2.getRequired()).isNull();
      assertThat(itemInfoValidation2.getDigit()).isNull();
      assertThat(itemInfoValidation2.getMaxlength()).isNull();

      final SysPersonalSettingsDefine.ItemInfoValidation itemInfoValidation3
        = itemInfoDetail.get(2).getValidation();
      assertThat(itemInfoValidation3).isNull();

      final List<SysPersonalSettingsDefine.StaticCombo> staticCombos
        = result.getComboData().getCombos();
      final SysPersonalSettingsDefine.StaticCombo staticCombo1 = staticCombos.get(0);
      assertThat(staticCombo1.getSettingIdentifier()).isEqualTo("1");
      assertThat(staticCombo1.getValues())
        .extracting(
          SysPersonalSettingsDefine.StaticComboValue::getText,
          SysPersonalSettingsDefine.StaticComboValue::getValue
        )
        .containsOnly(
          tuple("データ1", 1),
          tuple("データ2", 2),
          tuple("データ5", 5)
        )
      ;
      final SysPersonalSettingsDefine.StaticCombo staticCombo2 = staticCombos.get(1);
      assertThat(staticCombo2.getSettingIdentifier()).isEqualTo("2");
      assertThat(staticCombo2.getValues())
        .extracting(
          SysPersonalSettingsDefine.StaticComboValue::getText,
          SysPersonalSettingsDefine.StaticComboValue::getValue
        )
        .containsOnly(
          tuple("データ6", 6),
          tuple("データ7", 7)
        )
      ;

      final List<SysPersonalSettingsDefine.ReferenceCombo> referenceComboDef
        = result.getReferenceComboDef().getCombos();
      assertThat(referenceComboDef).hasSize(1);
      final SysPersonalSettingsDefine.ReferenceCombo referenceComboDef1 = referenceComboDef.get(0);
      assertThat(referenceComboDef1.getSettingIdentifier()).isEqualTo("4");
      assertThat(referenceComboDef1.getTargetTable().getName()).isEqualTo("mst_treatment");
      assertThat(referenceComboDef1.getTargetTable().getIdentifier()).isEqualTo("treatment_cd");
      assertThat(referenceComboDef1.getTargetTable().getDisplayColumn()).isEqualTo("treatment_name");
      assertThat(referenceComboDef1.getTargetTable().getReferencedColumn()).isEqualTo("treatment_cd");
    }

    {
      final SysPersonalSettingsDefine result = results.get(1);
      assertThat(result.getPersonalSettingsCd()).isEqualTo(3);
      assertThat(result.getTabDefineCd()).isEqualTo(((List<Integer>) tabDefineCds).get(1));
      assertThat(result.getEditLevel()).isEqualTo("4");

      final List<SysPersonalSettingsDefine.ItemInfoDetail> itemInfoDetail
        = result.getItemInfo().getItemInfoDetail();
      assertThat(itemInfoDetail)
        .hasSize(2)
        .extracting(
          SysPersonalSettingsDefine.ItemInfoDetail::getType,
          SysPersonalSettingsDefine.ItemInfoDetail::getTitle,
          SysPersonalSettingsDefine.ItemInfoDetail::getIdentifier
        )
        .containsOnly(
          tuple(SysPersonalSettingsDefine.ItemType.STRING, "項目6-1", "1"),
          tuple(SysPersonalSettingsDefine.ItemType.NUMBER, "項目6-2", "2")
        )
      ;

      final SysPersonalSettingsDefine.ItemInfoValidation itemInfoValidation1
        = itemInfoDetail.get(0).getValidation();
      assertThat(itemInfoValidation1.getMax()).isNull();
      assertThat(itemInfoValidation1.getMin()).isNull();
      assertThat(itemInfoValidation1.getRequired()).isTrue();
      assertThat(itemInfoValidation1.getDigit()).isNull();
      assertThat(itemInfoValidation1.getMaxlength()).isEqualTo(10);

      final SysPersonalSettingsDefine.ItemInfoValidation itemInfoValidation2
        = itemInfoDetail.get(1).getValidation();
      assertThat(itemInfoValidation2.getMax()).isEqualTo(BigDecimal.valueOf(9999.999));
      assertThat(itemInfoValidation2.getMin()).isEqualTo(BigDecimal.valueOf(0));
      assertThat(itemInfoValidation2.getRequired()).isTrue();
      assertThat(itemInfoValidation2.getDigit()).isEqualTo((short)3);
      assertThat(itemInfoValidation2.getMaxlength()).isNull();

      final SysPersonalSettingsDefine.StaticComboInfo comboData
        = result.getComboData();
      assertThat(comboData).isNull();
    }
  }

  /**
   * selectByTabDefineCds()の検証.
   * <p>
   *   条件：該当データなし
   *   結果：空のリストが取得できること
   * </p>
   */
  @Test
  public void selectByTabDefineCds_正常_データなし() {
    // arrange
    final Iterable<Integer> cds = asList(4, 5);

    // action
    final List<SysPersonalSettingsDefine> results = target.selectByTabDefineCds(cds);

    // assert
    assertThat(results).isEmpty();
  }
}
