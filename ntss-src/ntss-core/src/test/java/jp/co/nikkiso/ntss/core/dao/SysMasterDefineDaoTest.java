package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.hamcrest.Matchers.hasSize;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;

import java.math.BigDecimal;
import java.util.List;

import org.assertj.core.api.Assertions;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.Combo;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.ComboData;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.Field;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.FieldType;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboDefNode;

/**
 * {@link SysMasterDefineDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/SysMasterDefineDaoTest.before.sql")
public class SysMasterDefineDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private SysMasterDefineDao target;

  /**
   * selectByName()の検証.
   * <p>
   *   条件：データが存在するマスターコードを指定
   *   結果：結果が取得できること
   * </p>
   */
  @Test
  public void test_selectByName_正常_データあり() {
    // 実行
    SysMasterDefine result = target.selectByName("900002");

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.getMasterPhysicalName(), is("900002"));
    assertThat(result.getMasterName(), is("マスタ名2"));
    assertThat(result.getMode(), is("2"));
    assertThat(result.getAllowSort(), is("0"));
    assertThat(result.getAllowAddRecord(), is("1"));
    assertThat(result.getDispOrder(), is(2));
    assertFalse(result.getReferenceComboDef().isPresent());

    // カラム情報
    List<Field> fields = result.getColumnInfo().getFields();
    // 削除(表示・非表示)
    assertThat(fields.get(0).getPhysicalName(), is("isDeleted"));
    assertThat(fields.get(0).getTitle(), is(""));
    assertThat(fields.get(0).getType(), is(FieldType.BOOLEAN));
    assertThat(fields.get(0).getSelectable(), is(true));
    assertThat(fields.get(0).getEditable(), nullValue());
    assertThat(fields.get(0).getValidation(), nullValue());
    assertThat(fields.get(0).getFieldName(), is("isDeleted"));
    // 商品ID
    assertThat(fields.get(1).getPhysicalName(), is("ProductID"));
    assertThat(fields.get(1).getTitle(), is("商品ID"));
    assertThat(fields.get(1).getType(), is(FieldType.NUMBER));
    assertThat(fields.get(1).getSelectable(), is(true));
    assertThat(fields.get(1).getEditable(), is(false));
    assertThat(fields.get(1).getValidation(), notNullValue());
    assertThat(fields.get(1).getValidation().getMaxlength(), is(6));
    assertThat(fields.get(1).getValidation().getMin(), nullValue());
    assertThat(fields.get(1).getValidation().getMax(), nullValue());
    assertThat(fields.get(1).getAlias(), is("code"));
    assertThat(fields.get(1).getFieldName(), is("code"));
    // 商品名
    assertThat(fields.get(2).getPhysicalName(), is("ProductName"));
    assertThat(fields.get(2).getTitle(), is("商品名"));
    assertThat(fields.get(2).getType(), is(FieldType.STRING));
    assertThat(fields.get(2).getSelectable(), nullValue());
    assertThat(fields.get(2).getEditable(), nullValue());
    assertThat(fields.get(2).getValidation(), notNullValue());
    assertThat(fields.get(2).getValidation().getMaxlength(), is(20));
    assertThat(fields.get(2).getValidation().getMin(), nullValue());
    assertThat(fields.get(2).getValidation().getMax(), nullValue());
    assertThat(fields.get(2).getAlias(), is("name"));
    assertThat(fields.get(2).getFieldName(), is("name"));
    // 商品カナ名
    assertThat(fields.get(3).getPhysicalName(), is("ProductNameKana"));
    assertThat(fields.get(3).getTitle(), is("商品カナ名"));
    assertThat(fields.get(3).getType(), is(FieldType.STRING));
    assertThat(fields.get(3).getSelectable(), nullValue());
    assertThat(fields.get(3).getEditable(), nullValue());
    assertThat(fields.get(3).getValidation(), notNullValue());
    assertThat(fields.get(3).getValidation().getMaxlength(), is(20));
    assertThat(fields.get(3).getValidation().getMin(), nullValue());
    assertThat(fields.get(3).getValidation().getMax(), nullValue());
    assertThat(fields.get(3).getFieldName(), is("ProductNameKana"));
    // 都道府県コード
    assertThat(fields.get(4).getPhysicalName(), is("prefecturesCd"));
    assertThat(fields.get(4).getTitle(), is("都道府県コード"));
    assertThat(fields.get(4).getType(), is(FieldType.NUMBER));
    assertThat(fields.get(4).getSelectable(), nullValue());
    assertThat(fields.get(4).getEditable(), nullValue());
    assertThat(fields.get(4).getValidation(), notNullValue());
    assertThat(fields.get(4).getValidation().getMaxlength(), is(2));
    assertThat(fields.get(4).getValidation().getMin(), nullValue());
    assertThat(fields.get(4).getValidation().getMax(), nullValue());
    assertThat(fields.get(4).getFieldName(), is("prefecturesCd"));
    // 部署符号
    assertThat(fields.get(5).getPhysicalName(), is("departmentCd"));
    assertThat(fields.get(5).getTitle(), is("部署符号"));
    assertThat(fields.get(5).getType(), nullValue());
    assertThat(fields.get(5).getSelectable(), nullValue());
    assertThat(fields.get(5).getEditable(), nullValue());
    assertThat(fields.get(5).getValidation(), notNullValue());
    assertThat(fields.get(5).getValidation().getMaxlength(), is(4));
    assertThat(fields.get(5).getValidation().getMin(), nullValue());
    assertThat(fields.get(5).getValidation().getMax(), nullValue());
    assertThat(fields.get(5).getValidation().isRequired(), is(false));
    assertThat(fields.get(5).getFormat(), nullValue());
    assertThat(fields.get(5).getFieldName(), is("departmentCd"));
    // 死活監視間隔
    assertThat(fields.get(6).getPhysicalName(), is("aliveMoniInterval"));
    assertThat(fields.get(6).getTitle(), is("死活監視間隔"));
    assertThat(fields.get(6).getType(), is(FieldType.NUMBER));
    assertThat(fields.get(6).getSelectable(), nullValue());
    assertThat(fields.get(6).getEditable(), nullValue());
    assertThat(fields.get(6).getValidation(), notNullValue());
    assertThat(fields.get(6).getValidation().getMaxlength(), nullValue());
    assertThat(fields.get(6).getValidation().getMin(), is(new BigDecimal("1")));
    assertThat(fields.get(6).getValidation().getMax(), is(new BigDecimal("10")));
    assertThat(fields.get(6).getValidation().isRequired(), is(true));
    assertThat(fields.get(6).getFormat(), is("n0"));
    assertThat(fields.get(6).getFieldName(), is("aliveMoniInterval"));
    // データ操作タイプ
    assertThat(fields.get(7).getPhysicalName(), is("operation"));
    assertThat(fields.get(7).getTitle(), is("operation"));
    assertThat(fields.get(7).getType(), is(FieldType.NUMBER));
    assertThat(fields.get(7).getSelectable(), nullValue());
    assertThat(fields.get(7).getEditable(), nullValue());
    assertThat(fields.get(7).getValidation(), nullValue());
    assertThat(fields.get(7).getFieldName(), is("operation"));
    // モーダル
    assertThat(fields.get(8).getPhysicalName(), is(""));
    assertThat(fields.get(8).getTitle(), is("詳細"));
    assertThat(fields.get(8).getType(), is(FieldType.MODAL));
    assertThat(fields.get(8).getSelectable(), nullValue());
    assertThat(fields.get(8).getEditable(), nullValue());
    assertThat(fields.get(8).getValidation(), nullValue());
    assertThat(fields.get(8).getFieldName(), is(""));

  }

  /**
   * selectByName()の検証.
   * <p>
   *   条件：データが存在しないマスターコードを指定
   *   結果：結果がnullになること
   * </p>
   */
  @Test
  public void test_selectByName_正常_データなし() {
    // 実行
    SysMasterDefine result = target.selectByName("999999");

    // 検証
    assertThat(result, is(nullValue()));
  }

  /**
   * selectByUserType()の検証.
   * <p>
   * 条件：userTypeが日機装社員ユーザー
   * 結果：全件取得できること、並び順がdisp_order通りであること
   * </p>
   */
  @Test
  public void test_selectByUserType_正常_日機装社員ユーザー() {
    // 実行
    List<SysMasterDefine> result = target.selectByUserType("1");

    // 検証
    assertThat(result, hasSize(10));

    assertThat(result.get(0).getMasterPhysicalName(), is("900001"));
    assertThat(result.get(0).getMasterName(), is("マスタ名1"));
    assertThat(result.get(0).getMode(), is("1"));
    assertThat(result.get(0).getDispClass(), is("0"));
    assertTrue(result.get(0).getReferenceComboDef().isPresent());
    assertThat(result.get(0).getReferenceComboDef().get().getList(), hasSize(1));
    ReferenceComboDefNode def0 = result.get(0).getReferenceComboDef().get().getList().get(0);
    assertThat(def0.getPhysicalName(), is("ref_combo"));
    assertThat(def0.getReferenceComboTargetTable().getName(), is("tgt_tbl"));
    assertThat(def0.getReferenceComboTargetTable().getReferencedColumn(), is("col1"));
    assertThat(def0.getReferenceComboTargetTable().getDisplayColumn(), is("col2"));
    assertThat(def0.getReferenceComboTargetTable().getIdentifier(), is("pkey"));

    assertThat(result.get(1).getMasterPhysicalName(), is("900002"));
    assertThat(result.get(1).getMasterName(), is("マスタ名2"));
    assertThat(result.get(1).getMode(), is("2"));
    assertThat(result.get(1).getAllowSort(), is("0"));
    assertThat(result.get(1).getAllowAddRecord(), is("1"));
    assertThat(result.get(1).getDispOrder(), is(2));
    assertThat(result.get(1).getDispClass(), is("1"));
    assertFalse(result.get(1).getReferenceComboDef().isPresent());

    assertThat(result.get(2).getMasterPhysicalName(), is("900003"));
    assertThat(result.get(2).getMode(), is("3"));
    assertThat(result.get(2).getDispClass(), nullValue());
    assertTrue(result.get(2).getReferenceComboDef().isPresent());
    assertThat(result.get(2).getReferenceComboDef().get().getList(), hasSize(2));

    Assertions.assertThat(result.get(2).getReferenceComboDef().get().getList())
      .extracting(
        ReferenceComboDefNode::getPhysicalName
      )
      .containsExactlyInAnyOrder("ref_combo_1", "ref_combo_2");

    assertThat(result.get(3).getMasterPhysicalName(), is("900004"));
    assertThat(result.get(3).getMode(), is("4"));
    assertThat(result.get(3).getDispClass(), is("2"));
    assertFalse(result.get(3).getReferenceComboDef().isPresent());
    assertThat(result.get(4).getMasterPhysicalName(), is("900005"));
    assertThat(result.get(4).getMode(), is("1"));
    assertThat(result.get(4).getDispClass(), nullValue());
    assertFalse(result.get(4).getReferenceComboDef().isPresent());
    assertThat(result.get(5).getMasterPhysicalName(), is("900006"));
    assertThat(result.get(5).getMode(), is("2"));
    assertThat(result.get(5).getDispClass(), nullValue());
    assertFalse(result.get(5).getReferenceComboDef().isPresent());
    assertThat(result.get(6).getMasterPhysicalName(), is("900007"));
    assertThat(result.get(6).getMode(), is("3"));
    assertThat(result.get(6).getDispClass(), nullValue());
    assertFalse(result.get(6).getReferenceComboDef().isPresent());
    assertThat(result.get(7).getMasterPhysicalName(), is("900008"));
    assertThat(result.get(7).getMode(), is("4"));
    assertThat(result.get(7).getDispClass(), nullValue());
    assertFalse(result.get(7).getReferenceComboDef().isPresent());
    assertThat(result.get(8).getMasterPhysicalName(), is("900010"));
    assertThat(result.get(8).getMode(), is("1"));
    assertThat(result.get(8).getDispClass(), nullValue());
    assertFalse(result.get(8).getReferenceComboDef().isPresent());
    assertThat(result.get(9).getMasterPhysicalName(), is("900009"));
    assertThat(result.get(9).getMode(), is("1"));
    assertThat(result.get(9).getDispClass(), nullValue());
    assertFalse(result.get(9).getReferenceComboDef().isPresent());

    // カラム情報
    List<Field> fields = result.get(1).getColumnInfo().getFields();
    // 削除(表示・非表示)
    assertThat(fields.get(0).getPhysicalName(), is("isDeleted"));
    assertThat(fields.get(0).getTitle(), is(""));
    assertThat(fields.get(0).getType(), is(FieldType.BOOLEAN));
    assertThat(fields.get(0).getSelectable(), is(true));
    assertThat(fields.get(0).getEditable(), nullValue());
    assertThat(fields.get(0).getValidation(), nullValue());
    assertThat(fields.get(0).getFieldName(), is("isDeleted"));
    // 商品ID
    assertThat(fields.get(1).getPhysicalName(), is("ProductID"));
    assertThat(fields.get(1).getTitle(), is("商品ID"));
    assertThat(fields.get(1).getType(), is(FieldType.NUMBER));
    assertThat(fields.get(1).getSelectable(), is(true));
    assertThat(fields.get(1).getEditable(), is(false));
    assertThat(fields.get(1).getValidation(), notNullValue());
    assertThat(fields.get(1).getValidation().getMaxlength(), is(6));
    assertThat(fields.get(1).getValidation().getMin(), nullValue());
    assertThat(fields.get(1).getValidation().getMax(), nullValue());
    assertThat(fields.get(1).getFieldName(), is("code"));
    // 商品名
    assertThat(fields.get(2).getPhysicalName(), is("ProductName"));
    assertThat(fields.get(2).getTitle(), is("商品名"));
    assertThat(fields.get(2).getType(), is(FieldType.STRING));
    assertThat(fields.get(2).getSelectable(), nullValue());
    assertThat(fields.get(2).getEditable(), nullValue());
    assertThat(fields.get(2).getValidation(), notNullValue());
    assertThat(fields.get(2).getValidation().getMaxlength(), is(20));
    assertThat(fields.get(2).getValidation().getMin(), nullValue());
    assertThat(fields.get(2).getValidation().getMax(), nullValue());
    assertThat(fields.get(2).getFieldName(), is("name"));
    // 商品カナ名
    assertThat(fields.get(3).getPhysicalName(), is("ProductNameKana"));
    assertThat(fields.get(3).getTitle(), is("商品カナ名"));
    assertThat(fields.get(3).getType(), is(FieldType.STRING));
    assertThat(fields.get(3).getSelectable(), nullValue());
    assertThat(fields.get(3).getEditable(), nullValue());
    assertThat(fields.get(3).getValidation(), notNullValue());
    assertThat(fields.get(3).getValidation().getMaxlength(), is(20));
    assertThat(fields.get(3).getValidation().getMin(), nullValue());
    assertThat(fields.get(3).getValidation().getMax(), nullValue());
    assertThat(fields.get(3).getFieldName(), is("ProductNameKana"));
    // 都道府県コード
    assertThat(fields.get(4).getPhysicalName(), is("prefecturesCd"));
    assertThat(fields.get(4).getTitle(), is("都道府県コード"));
    assertThat(fields.get(4).getType(), is(FieldType.NUMBER));
    assertThat(fields.get(4).getSelectable(), nullValue());
    assertThat(fields.get(4).getEditable(), nullValue());
    assertThat(fields.get(4).getValidation(), notNullValue());
    assertThat(fields.get(4).getValidation().getMaxlength(), is(2));
    assertThat(fields.get(4).getValidation().getMin(), nullValue());
    assertThat(fields.get(4).getValidation().getMax(), nullValue());
    assertThat(fields.get(4).getFieldName(), is("prefecturesCd"));
    // 部署符号
    assertThat(fields.get(5).getPhysicalName(), is("departmentCd"));
    assertThat(fields.get(5).getTitle(), is("部署符号"));
    assertThat(fields.get(5).getType(), nullValue());
    assertThat(fields.get(5).getSelectable(), nullValue());
    assertThat(fields.get(5).getEditable(), nullValue());
    assertThat(fields.get(5).getValidation(), notNullValue());
    assertThat(fields.get(5).getValidation().getMaxlength(), is(4));
    assertThat(fields.get(5).getValidation().getMin(), nullValue());
    assertThat(fields.get(5).getValidation().getMax(), nullValue());
    assertThat(fields.get(5).getFieldName(), is("departmentCd"));
    // 死活監視間隔
    assertThat(fields.get(6).getPhysicalName(), is("aliveMoniInterval"));
    assertThat(fields.get(6).getTitle(), is("死活監視間隔"));
    assertThat(fields.get(6).getType(), is(FieldType.NUMBER));
    assertThat(fields.get(6).getSelectable(), nullValue());
    assertThat(fields.get(6).getEditable(), nullValue());
    assertThat(fields.get(6).getValidation(), notNullValue());
    assertThat(fields.get(6).getValidation().getMaxlength(), nullValue());
    assertThat(fields.get(6).getValidation().getMin(), is(new BigDecimal("1")));
    assertThat(fields.get(6).getValidation().getMax(), is(new BigDecimal("10")));
    assertThat(fields.get(6).getFieldName(), is("aliveMoniInterval"));
    // データ操作タイプ
    assertThat(fields.get(7).getPhysicalName(), is("operation"));
    assertThat(fields.get(7).getTitle(), is("operation"));
    assertThat(fields.get(7).getType(), is(FieldType.NUMBER));
    assertThat(fields.get(7).getSelectable(), nullValue());
    assertThat(fields.get(7).getEditable(), nullValue());
    assertThat(fields.get(7).getValidation(), nullValue());
    assertThat(fields.get(7).getFieldName(), is("operation"));
    // モーダル
    assertThat(fields.get(8).getPhysicalName(), is(""));
    assertThat(fields.get(8).getTitle(), is("詳細"));
    assertThat(fields.get(8).getType(), is(FieldType.MODAL));
    assertThat(fields.get(8).getSelectable(), nullValue());
    assertThat(fields.get(8).getEditable(), nullValue());
    assertThat(fields.get(8).getValidation(), nullValue());
    assertThat(fields.get(8).getFieldName(), is(""));

    // コンボデータ
    // 固有コンボボックス
    List<Combo> comboFields = result.get(0).getComboData().getCombos();
    assertThat(comboFields.get(0).getPhysicalName(), is("column1"));
    assertThat(comboFields.get(0).getValues().get(0).getValue(), is("011"));
    assertThat(comboFields.get(0).getValues().get(0).getText(), is("test011"));
    assertThat(comboFields.get(0).getValues().get(1).getValue(), is("012"));
    assertThat(comboFields.get(0).getValues().get(1).getText(), is("test012"));
    assertThat(comboFields.get(0).getValues().get(2).getValue(), is("013"));
    assertThat(comboFields.get(0).getValues().get(2).getText(), is("test013"));

    assertThat(comboFields.get(1).getPhysicalName(), is("column2"));
    assertThat(comboFields.get(1).getValues().get(0).getValue(), is("021"));
    assertThat(comboFields.get(1).getValues().get(0).getText(), is("test021"));
    assertThat(comboFields.get(1).getValues().get(1).getValue(), is("022"));
    assertThat(comboFields.get(1).getValues().get(1).getText(), is("test022"));
    assertThat(comboFields.get(1).getValues().get(2).getValue(), is("023"));
    assertThat(comboFields.get(1).getValues().get(2).getText(), is("test023"));

    assertThat(comboFields.get(2).getPhysicalName(), is("column3"));
    assertThat(comboFields.get(2).getValues().get(0).getValue(), is("031"));
    assertThat(comboFields.get(2).getValues().get(0).getText(), is("test031"));
    assertThat(comboFields.get(2).getValues().get(1).getValue(), is("032"));
    assertThat(comboFields.get(2).getValues().get(1).getText(), is("test032"));
    assertThat(comboFields.get(2).getValues().get(2).getValue(), is("033"));
    assertThat(comboFields.get(2).getValues().get(2).getText(), is("test033"));

    // コンボデータなし
    ComboData comboFields3 = result.get(1).getComboData();
    assertThat(comboFields3, nullValue());

  }

  /**
   * selectByUserType()の検証.
   * <p>
   * 条件：userTypeが一般ユーザー
   * 結果：表示区分が2:制限なしのものが取得できること
   * </p>
   */
  @Test
  public void test_selectByUserType_正常_一般ユーザー() {
    // 実行
    List<SysMasterDefine> result = target.selectByUserType(CoreConstant.UserType.GENERAL);

    // 検証
    assertThat(result, hasSize(1));
    assertThat(result.get(0).getMasterPhysicalName(), is("900004"));
    assertThat(result.get(0).getDispClass(), is("2"));
  }

  /**
   * selectByUserType()の検証.
   * <p>
   * 条件：userTypeが日機装or一般ユーザーに該当しない
   * 結果：一般ユーザーの場合と結果が同じになること
   * </p>
   */
  @Test
  public void test_selectByUserType_正常_日機装でも一般ユーザーでもないユーザー() {
    // 実行
    List<SysMasterDefine> result = target.selectByUserType("3");

    // 検証
    assertThat(result, hasSize(1));
    assertThat(result.get(0).getMasterPhysicalName(), is("900004"));
    assertThat(result.get(0).getDispClass(), is("2"));
  }

  /**
   * selectByUserType()の検証.
   * <p>
   * 条件：userTypeがNull値
   * 結果：一般ユーザーの場合と結果が同じになること
   * </p>
   */
  @Test
  public void test_selectByUserType_正常_Null() {
    // 実行
    List<SysMasterDefine> result = target.selectByUserType(null);

    // 検証
    assertThat(result, hasSize(1));
    assertThat(result.get(0).getMasterPhysicalName(), is("900004"));
    assertThat(result.get(0).getDispClass(), is("2"));
  }

}
