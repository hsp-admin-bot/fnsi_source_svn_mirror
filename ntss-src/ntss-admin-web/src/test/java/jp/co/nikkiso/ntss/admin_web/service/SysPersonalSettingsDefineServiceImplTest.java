package jp.co.nikkiso.ntss.admin_web.service;

import static java.util.Arrays.asList;
import static java.util.Collections.emptyList;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import java.math.BigDecimal;
import java.util.List;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.response.PersonalSettingsDefine;
import jp.co.nikkiso.ntss.admin_web.service.master.ReferenceComboService;
import jp.co.nikkiso.ntss.core.dao.SysPersonalSettingsDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysPersonalSettingsDefine;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceCombo;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboTargetTable;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

@RunWith(SpringRunner.class)
@SpringBootTest
public class SysPersonalSettingsDefineServiceImplTest {

  @MockBean
  private SysPersonalSettingsDefineDao sysPersonalSettingsDefineDao;

  @MockBean
  private ReferenceComboService referenceComboService;

  /**
   * 例外の発生をテストするためのルール
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * テスト対象クラス
   */
  @Autowired
  private SysPersonalSettingsDefineService target;

  /**
   * getPersonalSettingsDefine()の検証.
   *
   * 条件：共通設定タブ定義マスタに存在するタブ定義コードを指定する.
   * 結果：共通設定タブ情報を取得できること.
   */
  @Test
  public void test_getPersonalSettingsDefine_正常_データあり() {
    // arrange
    final String facilityCd = "00001";
    final Integer tabDefineCd  = 1;

    final SysPersonalSettingsDefine sysPersonalSettingsDefine = geneSysPersonalSettingsDefine(tabDefineCd);
    given(sysPersonalSettingsDefineDao.selectByTabDefineCd(any())).willReturn(sysPersonalSettingsDefine);

    final ArgumentCaptor<ReferenceComboTargetTable> targetTableArgumentCaptor
      = ArgumentCaptor.forClass(ReferenceComboTargetTable.class);
    given(referenceComboService.build(any(), targetTableArgumentCaptor.capture())).willReturn(asList(
      new ReferenceCombo(11L, "displayColumn1", 1L)
      , new ReferenceCombo(22L, "displayColumn2", 2L)
    ));

    // action
    final PersonalSettingsDefine result = target.getPersonalSettingsDefine(facilityCd, tabDefineCd);

    // assert
    verify(sysPersonalSettingsDefineDao, times(1)).selectByTabDefineCd(eq(tabDefineCd));
    verify(referenceComboService, times(2)).build(eq(facilityCd), any());

    final List<ReferenceComboTargetTable> targetTableArgs = targetTableArgumentCaptor.getAllValues();
    final ReferenceComboTargetTable targetTable1 = targetTableArgs.get(0);
    assertThat(targetTable1.getName()).isEqualTo("tableA");
    assertThat(targetTable1.getIdentifier()).isEqualTo("identifierColumnA");
    assertThat(targetTable1.getReferencedColumn()).isEqualTo("referenedColumnA");
    assertThat(targetTable1.getDisplayColumn()).isEqualTo("displayColumnA");
    final ReferenceComboTargetTable targetTable2 = targetTableArgs.get(1);
    assertThat(targetTable2.getName()).isEqualTo("tableB");
    assertThat(targetTable2.getIdentifier()).isEqualTo("identifierColumnB");
    assertThat(targetTable2.getReferencedColumn()).isEqualTo("referenedColumnB");
    assertThat(targetTable2.getDisplayColumn()).isEqualTo("displayColumnB");

    assertThat(result).isNotNull();
    assertThat(result.getTabDefineCd()).isEqualTo(tabDefineCd);
    assertThat(result.getEditLevel()).isEqualTo("1");

    final List<SysPersonalSettingsDefine.ItemInfoDetail> itemInfoDetail = result.getItemInfoDetail();
    assertThat(itemInfoDetail).hasSize(3);
    final SysPersonalSettingsDefine.ItemInfoDetail detail1 = itemInfoDetail.get(0);
    final SysPersonalSettingsDefine.ItemInfoValidation validation1 = detail1.getValidation();
    assertThat(detail1.getIdentifier()).isEqualTo("identifier1");
    assertThat(detail1.getTitle()).isEqualTo("title1");
    assertThat(detail1.getType()).isEqualTo(SysPersonalSettingsDefine.ItemType.NUMBER);
    assertThat(validation1.getMaxlength()).isEqualTo(1);
    assertThat(validation1.getMin()).isEqualTo(BigDecimal.valueOf(0.5));
    assertThat(validation1.getMax()).isEqualTo(BigDecimal.valueOf(100));
    assertThat(validation1.getRequired()).isTrue();
    assertThat(validation1.getDigit()).isEqualTo((short)1);

    final SysPersonalSettingsDefine.ItemInfoDetail detail2 = itemInfoDetail.get(1);
    final SysPersonalSettingsDefine.ItemInfoValidation validation2 = detail2.getValidation();
    assertThat(detail2.getIdentifier()).isEqualTo("identifier2");
    assertThat(detail2.getTitle()).isEqualTo("title2");
    assertThat(detail2.getType()).isEqualTo(SysPersonalSettingsDefine.ItemType.COMBO1);
    assertThat(validation2).isNull();

    final SysPersonalSettingsDefine.ItemInfoDetail detail3 = itemInfoDetail.get(2);
    final SysPersonalSettingsDefine.ItemInfoValidation validation3 = detail3.getValidation();
    assertThat(detail3.getIdentifier()).isEqualTo("identifier3");
    assertThat(detail3.getTitle()).isEqualTo("title3");
    assertThat(detail3.getType()).isEqualTo(SysPersonalSettingsDefine.ItemType.COMBO2);
    assertThat(validation3.getMaxlength()).isNull();
    assertThat(validation3.getMin()).isNull();
    assertThat(validation3.getMax()).isNull();
    assertThat(validation3.getRequired()).isTrue();
    assertThat(validation3.getDigit()).isNull();

    final List<SysPersonalSettingsDefine.StaticCombo> combos = result.getStaticCombo();
    assertThat(combos).hasSize(4);

    final SysPersonalSettingsDefine.StaticCombo combo1 = combos.get(0);
    assertThat(combo1.getSettingIdentifier()).isEqualTo("staticCombo1");
    final List<SysPersonalSettingsDefine.StaticComboValue> comboValues1 = combo1.getValues();
    assertThat(comboValues1)
      .hasSize(2)
      .extracting(
        SysPersonalSettingsDefine.StaticComboValue::getText
        , SysPersonalSettingsDefine.StaticComboValue::getValue
      )
      .containsExactly(
        tuple("text1-1", 111)
        , tuple("text1-2", 112)
      )
    ;

    final SysPersonalSettingsDefine.StaticCombo combo2 = combos.get(1);
    assertThat(combo2.getSettingIdentifier()).isEqualTo("staticCombo2");
    final List<SysPersonalSettingsDefine.StaticComboValue> comboValues2 = combo2.getValues();
    assertThat(comboValues2)
      .hasSize(2)
      .extracting(
        SysPersonalSettingsDefine.StaticComboValue::getText
        , SysPersonalSettingsDefine.StaticComboValue::getValue
      )
      .containsExactly(
        tuple("text2-1", 211)
        , tuple("text2-2", 212)
      )
    ;

    final SysPersonalSettingsDefine.StaticCombo combo3 = combos.get(2);
    assertThat(combo3.getSettingIdentifier()).isEqualTo("referenceComboA");
    final List<SysPersonalSettingsDefine.StaticComboValue> comboValues3 = combo3.getValues();
    assertThat(comboValues3)
      .hasSize(2)
      .extracting(
        SysPersonalSettingsDefine.StaticComboValue::getText
        , SysPersonalSettingsDefine.StaticComboValue::getValue
      )
      .containsExactly(
        tuple("displayColumn1", 11L)
        , tuple("displayColumn2", 22L)
      )
    ;

    final SysPersonalSettingsDefine.StaticCombo combo4 = combos.get(3);
    assertThat(combo4.getSettingIdentifier()).isEqualTo("referenceComboB");
    final List<SysPersonalSettingsDefine.StaticComboValue> comboValues4 = combo4.getValues();
    assertThat(comboValues4)
      .hasSize(2)
      .extracting(
        SysPersonalSettingsDefine.StaticComboValue::getText
        , SysPersonalSettingsDefine.StaticComboValue::getValue
      )
      .containsExactly(
        tuple("displayColumn1", 11L)
        , tuple("displayColumn2", 22L)
      )
    ;
  }

  /**
   * getPersonalSettingsDefine()の検証.
   *
   * 条件：参照コンボの設定が参照しているマスタにレコードがない.
   * 結果：共通設定タブ情報を取得できること. コンボデータは空リストとなること
   */
  @Test
  public void test_getPersonalSettingsDefine_正常_参照先マスタにレコードがない場合は空の配列を取得できること () {
    // arrange
    final String facilityCd = "00001";
    final Integer tabDefineCd  = 1;

    final SysPersonalSettingsDefine sysPersonalSettingsDefine = geneSysPersonalSettingsDefineHasNoStaticCombo(tabDefineCd);
    given(sysPersonalSettingsDefineDao.selectByTabDefineCd(any())).willReturn(sysPersonalSettingsDefine);

    final ArgumentCaptor<ReferenceComboTargetTable> targetTableArgumentCaptor
      = ArgumentCaptor.forClass(ReferenceComboTargetTable.class);
    given(referenceComboService.build(any(), targetTableArgumentCaptor.capture())).willReturn(emptyList());

    // action
    final PersonalSettingsDefine result = target.getPersonalSettingsDefine(facilityCd, tabDefineCd);

    // assert
    verify(sysPersonalSettingsDefineDao, times(1)).selectByTabDefineCd(eq(tabDefineCd));
    verify(referenceComboService, times(2)).build(eq(facilityCd), any());

    final List<ReferenceComboTargetTable> targetTableArgs = targetTableArgumentCaptor.getAllValues();
    final ReferenceComboTargetTable targetTable1 = targetTableArgs.get(0);
    assertThat(targetTable1.getName()).isEqualTo("tableA");
    assertThat(targetTable1.getIdentifier()).isEqualTo("identifierColumnA");
    assertThat(targetTable1.getReferencedColumn()).isEqualTo("referenedColumnA");
    assertThat(targetTable1.getDisplayColumn()).isEqualTo("displayColumnA");
    final ReferenceComboTargetTable targetTable2 = targetTableArgs.get(1);
    assertThat(targetTable2.getName()).isEqualTo("tableB");
    assertThat(targetTable2.getIdentifier()).isEqualTo("identifierColumnB");
    assertThat(targetTable2.getReferencedColumn()).isEqualTo("referenedColumnB");
    assertThat(targetTable2.getDisplayColumn()).isEqualTo("displayColumnB");

    assertThat(result).isNotNull();
    assertThat(result.getTabDefineCd()).isEqualTo(tabDefineCd);
    assertThat(result.getEditLevel()).isEqualTo("1");

    final List<SysPersonalSettingsDefine.ItemInfoDetail> itemInfoDetail = result.getItemInfoDetail();
    assertThat(itemInfoDetail).hasSize(3);
    final SysPersonalSettingsDefine.ItemInfoDetail detail1 = itemInfoDetail.get(0);
    final SysPersonalSettingsDefine.ItemInfoValidation validation1 = detail1.getValidation();
    assertThat(detail1.getIdentifier()).isEqualTo("identifier1");
    assertThat(detail1.getTitle()).isEqualTo("title1");
    assertThat(detail1.getType()).isEqualTo(SysPersonalSettingsDefine.ItemType.NUMBER);
    assertThat(validation1.getMaxlength()).isEqualTo(1);
    assertThat(validation1.getMin()).isEqualTo(BigDecimal.valueOf(0.5));
    assertThat(validation1.getMax()).isEqualTo(BigDecimal.valueOf(100));
    assertThat(validation1.getRequired()).isTrue();
    assertThat(validation1.getDigit()).isEqualTo((short)1);

    final SysPersonalSettingsDefine.ItemInfoDetail detail2 = itemInfoDetail.get(1);
    final SysPersonalSettingsDefine.ItemInfoValidation validation2 = detail2.getValidation();
    assertThat(detail2.getIdentifier()).isEqualTo("identifier2");
    assertThat(detail2.getTitle()).isEqualTo("title2");
    assertThat(detail2.getType()).isEqualTo(SysPersonalSettingsDefine.ItemType.COMBO1);
    assertThat(validation2).isNull();

    final SysPersonalSettingsDefine.ItemInfoDetail detail3 = itemInfoDetail.get(2);
    final SysPersonalSettingsDefine.ItemInfoValidation validation3 = detail3.getValidation();
    assertThat(detail3.getIdentifier()).isEqualTo("identifier3");
    assertThat(detail3.getTitle()).isEqualTo("title3");
    assertThat(detail3.getType()).isEqualTo(SysPersonalSettingsDefine.ItemType.COMBO2);
    assertThat(validation3.getMaxlength()).isNull();
    assertThat(validation3.getMin()).isNull();
    assertThat(validation3.getMax()).isNull();
    assertThat(validation3.getRequired()).isTrue();
    assertThat(validation3.getDigit()).isNull();

    final List<SysPersonalSettingsDefine.StaticCombo> combos = result.getStaticCombo();
    assertThat(combos).hasSize(2);

    final SysPersonalSettingsDefine.StaticCombo combo1 = combos.get(0);
    assertThat(combo1.getSettingIdentifier()).isEqualTo("referenceComboA");
    assertThat(combo1.getValues()).isEmpty();

    final SysPersonalSettingsDefine.StaticCombo combo2 = combos.get(1);
    assertThat(combo2.getSettingIdentifier()).isEqualTo("referenceComboB");
    assertThat(combo2.getValues()).isEmpty();
  }

  /**
   * getPersonalSettingsDefine()の検証.
   *
   * 条件：共通設定タブ定義マスタに存在しないタブ定義コードを指定する.
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getPersonalsettingsDefine_異常_データなし() {
    // arrange
    final String facilityCd = "00001";
    final Integer tabDefineCd  = 1;

    given(sysPersonalSettingsDefineDao.selectByTabDefineCd(any())).willThrow(EmptyResultDataAccessException.class);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しないタブ定義コードを指定しています。");
    target.getPersonalSettingsDefine(facilityCd, tabDefineCd);
  }

  private SysPersonalSettingsDefine geneSysPersonalSettingsDefine(Integer tabDefineCd) {
    // StaticComboInfoを生成
    final List<SysPersonalSettingsDefine.StaticComboValue> staticComboValues1 = asList(
      new SysPersonalSettingsDefine.StaticComboValue("text1-1", 111)
      , new SysPersonalSettingsDefine.StaticComboValue("text1-2", 112)
    );
    final List<SysPersonalSettingsDefine.StaticComboValue> staticComboValues2 = asList(
      new SysPersonalSettingsDefine.StaticComboValue("text2-1", 211)
      , new SysPersonalSettingsDefine.StaticComboValue("text2-2", 212)
    );

    final List<SysPersonalSettingsDefine.StaticCombo> staticCombos = asList(
      new SysPersonalSettingsDefine.StaticCombo("staticCombo1", staticComboValues1)
      , new SysPersonalSettingsDefine.StaticCombo("staticCombo2", staticComboValues2)
    );

    final SysPersonalSettingsDefine.StaticComboInfo staticComboInfo = new SysPersonalSettingsDefine.StaticComboInfo(staticCombos);

    return this.geneSysPersonalSettingsDefine(tabDefineCd, staticComboInfo);
  }

  private SysPersonalSettingsDefine geneSysPersonalSettingsDefineHasNoStaticCombo(Integer tabDefineCd) {
    return this.geneSysPersonalSettingsDefine(tabDefineCd, null);
  }

  private SysPersonalSettingsDefine geneSysPersonalSettingsDefine(Integer tabDefineCd, SysPersonalSettingsDefine.StaticComboInfo staticComboInfo) {
    final Integer personalSettingsCd = 1;
    final String editLevel = "1";

    // ItemInfoを生成。
    final List<SysPersonalSettingsDefine.ItemInfoDetail> itemInfoDetails = asList(
      new SysPersonalSettingsDefine.ItemInfoDetail(
        SysPersonalSettingsDefine.ItemType.NUMBER
        , "title1"
        , "identifier1"
        , new SysPersonalSettingsDefine.ItemInfoValidation(1, BigDecimal.valueOf(0.5), BigDecimal.valueOf(100), true, (short) 1)
      ),
      new SysPersonalSettingsDefine.ItemInfoDetail(
        SysPersonalSettingsDefine.ItemType.COMBO1
        , "title2"
        , "identifier2"
        , null
      ),
      new SysPersonalSettingsDefine.ItemInfoDetail(
        SysPersonalSettingsDefine.ItemType.COMBO2
        , "title3"
        , "identifier3"
        , new SysPersonalSettingsDefine.ItemInfoValidation(null, null, null, true, null)
      )
    );
    final SysPersonalSettingsDefine.ItemInfo itemInfo = new SysPersonalSettingsDefine.ItemInfo(itemInfoDetails);

    // ReferenceComboDefを生成
    final SysPersonalSettingsDefine.TargetTable targetTableA
      = new SysPersonalSettingsDefine.TargetTable("tableA", "identifierColumnA", "displayColumnA", "referenedColumnA");
    final SysPersonalSettingsDefine.TargetTable targetTableB
      = new SysPersonalSettingsDefine.TargetTable("tableB", "identifierColumnB", "displayColumnB", "referenedColumnB");
    final SysPersonalSettingsDefine.ReferenceCombo referenceComboA
      = new SysPersonalSettingsDefine.ReferenceCombo("referenceComboA", targetTableA);
    final SysPersonalSettingsDefine.ReferenceCombo referenceComboB
      = new SysPersonalSettingsDefine.ReferenceCombo("referenceComboB", targetTableB);

    final SysPersonalSettingsDefine.ReferenceComboDef referenceComboDef
      = new SysPersonalSettingsDefine.ReferenceComboDef(asList(referenceComboA, referenceComboB));

    return new SysPersonalSettingsDefine(personalSettingsCd, tabDefineCd, editLevel, itemInfo, staticComboInfo, referenceComboDef);
  }

}
