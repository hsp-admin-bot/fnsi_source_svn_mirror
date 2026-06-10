package jp.co.nikkiso.ntss.admin_web.service;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterColumn;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.service.master.MasterEditService;
import jp.co.nikkiso.ntss.admin_web.service.master.ReferenceComboService;
import jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.SysMasterDefineDao;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstSelector.Item;
import jp.co.nikkiso.ntss.core.entity.MstSelector.OrderSettings;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.ColumnInfo;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.Combo;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.ComboData;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.ComboValue;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.Field;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.FieldType;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.ReferenceComboDef;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.Validation;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceCombo;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboDefNode;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboTargetTable;

/**
 * MasterEditServiceImplのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class MasterEditServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private MasterEditService target;

  /**
   * マスタ定義のMockBean.
   */
  @MockBean
  private SysMasterDefineDao sysMasterDefineDao;

  /**
   * 汎用マスタメンテナンスDaoのMockBean.
   */
  @MockBean
  private MasterMaintenanceGenericDao mstMaintenaceGenericDao;

  /**
   * 選択肢マスタのMockBean.
   */
  @MockBean
  private MstSelectorDao mstSelectorDao;

  /**
   * 参照型コンボのサービスクラスのMockBean.
   */
  @MockBean
  private ReferenceComboService referenceComboService;

  /**
   * 検証用のマスタ定義データ
   */
  private SysMasterDefine getSysMasterDefine() {
    SysMasterDefine sysMasterDefine = new SysMasterDefine();

    sysMasterDefine.setMasterPhysicalName("mst_facility");
    sysMasterDefine.setMasterName("施設マスタ");
    sysMasterDefine.setMode("1");
    sysMasterDefine.setAllowSort("0");
    sysMasterDefine.setAllowAddRecord("1");
    sysMasterDefine.setDispOrder(3);

    ColumnInfo columnInfo = new ColumnInfo();
    List<Field> fields = new ArrayList<Field>();

    // 1列目
    Field field1 = new Field();
    field1.setPhysicalName("facility_cd");
    field1.setTitle("施設コード");
    field1.setType(FieldType.STRING);
    field1.setAlias("code");
    field1.setEditable(false);
    fields.add(field1);

    // 2列目
    Field field2 = new Field();
    Validation validation2 = new Validation();

    field2.setPhysicalName("facility_name");
    field2.setTitle("施設名");
    field2.setType(FieldType.STRING);
    field2.setAlias("name");
    field2.setEditable(true);

    validation2.setMaxlength(30);
    validation2.setRequired(true);
    field2.setValidation(validation2);

    fields.add(field2);

    // 3列目
    Field field3 = new Field();
    Validation validation3 = new Validation();

    field3.setPhysicalName("interval");
    field3.setTitle("間隔");
    field3.setType(FieldType.NUMBER);

    validation3.setMin(new BigDecimal("-1"));
    validation3.setMax(new BigDecimal("20"));
    field3.setValidation(validation3);

    fields.add(field3);

    // 4列目
    Field field4 = new Field();

    field4.setPhysicalName("reg_date");
    field4.setTitle("更新日");
    field4.setType(FieldType.DATE);
    field4.setHidden(true);
    fields.add(field4);

    // 5列目
    Field field5 = new Field();
    field5.setPhysicalName("prefectures_cd");
    field5.setTitle("都道府県コード");
    field5.setEditable(true);
    field5.setType(FieldType.COMBO_SPECIFIC);
    field5.setHidden(false);
    fields.add(field5);

    // 6列目
    Field field6 = new Field();
    field6.setPhysicalName("");
    field6.setTitle("詳細");
    field6.setEditable(true);
    field6.setType(FieldType.MODAL);
    fields.add(field6);

    // 7列目
    Field field7 = new Field();
    field7.setPhysicalName("use_function");
    field7.setTitle("使用可能機能");
    field7.setEditable(true);
    field7.setType(FieldType.JSON);
    fields.add(field7);

    // 8列目
    Field field8 = new Field();
    field8.setPhysicalName("is_disp");
    field8.setTitle("削除");
    field8.setEditable(true);
    field8.setType(FieldType.DISP);
    fields.add(field8);

    // 9列目 参照型コンボ（validationが未設定）
    Field field9 = new Field();
    field9.setPhysicalName("test_combo2");
    field9.setTitle("テストコンボ2");
    field9.setEditable(true);
    field9.setType(FieldType.COMBO_REFERENCE);
    fields.add(field9);

    // 10列目 参照型コンボ（validationが設定、requriedにfalseが設定）
    Field field10 = new Field();
    Validation validation10 = new Validation();

    validation10.setRequired(false);
    field10.setValidation(validation10);

    field10.setPhysicalName("test_combo3");
    field10.setTitle("テストコンボ3");
    field10.setEditable(true);
    field10.setType(FieldType.COMBO_REFERENCE);
    fields.add(field10);

    // 11列目 参照型コンボ（validationが設定、requriedにtrueが設定）
    Field field11 = new Field();
    Validation validation11 = new Validation();

    validation11.setRequired(true);
    field11.setValidation(validation11);

    field11.setPhysicalName("test_combo4");
    field11.setTitle("テストコンボ4");
    field11.setEditable(true);
    field11.setType(FieldType.COMBO_REFERENCE);
    fields.add(field11);

    columnInfo.setFields(fields);
    sysMasterDefine.setColumnInfo(columnInfo);

    ComboData comboData = new ComboData();
    List<Combo> combos = new ArrayList<Combo>();

    List<ComboValue> comboValues = new ArrayList<ComboValue>();
    ComboValue comboValue01 = new ComboValue("01", "北海道");
    comboValues.add(comboValue01);

    ComboValue comboValue02 = new ComboValue("02", "青森県");
    comboValues.add(comboValue02);

    ComboValue comboValue03 = new ComboValue("03", "岩手県");
    comboValues.add(comboValue03);

    ComboValue comboValue04 = new ComboValue("04", "宮城県");
    comboValues.add(comboValue04);

    ComboValue comboValue05 = new ComboValue("05", "秋田県");
    comboValues.add(comboValue05);

    Combo combo1 = new Combo("prefectures_cd", comboValues);

    combos.add(combo1);
    comboData.setCombos(combos);

    sysMasterDefine.setComboData(comboData);

    // 参照型コンボ定義
    ReferenceComboDef referenceComboDef = new ReferenceComboDef();

    // test_combo2用
    ReferenceComboDefNode referenceComboDefNode1 = new ReferenceComboDefNode();
    ReferenceComboTargetTable referenceComboTargetTable1 = new ReferenceComboTargetTable();
    referenceComboTargetTable1.setName("mst_test_table");
    referenceComboTargetTable1.setDisplayColumn("die_name");
    referenceComboTargetTable1.setIdentifier("die_cd");
    referenceComboTargetTable1.setReferencedColumn("test_numeric");

    referenceComboDefNode1.setPhysicalName("test_combo2");
    referenceComboDefNode1.setReferenceComboTargetTable(referenceComboTargetTable1);

    // test_combo3用
    ReferenceComboDefNode referenceComboDefNode2 = new ReferenceComboDefNode();
    ReferenceComboTargetTable referenceComboTargetTable2 = new ReferenceComboTargetTable();
    referenceComboTargetTable2.setName("mst_test_table");
    referenceComboTargetTable2.setDisplayColumn("die_name");
    referenceComboTargetTable2.setIdentifier("die_cd");
    referenceComboTargetTable2.setReferencedColumn("test_numeric");

    referenceComboDefNode2.setPhysicalName("test_combo3");
    referenceComboDefNode2.setReferenceComboTargetTable(referenceComboTargetTable2);

    // test_combo4用
    ReferenceComboDefNode referenceComboDefNode3 = new ReferenceComboDefNode();
    ReferenceComboTargetTable referenceComboTargetTable3 = new ReferenceComboTargetTable();
    referenceComboTargetTable3.setName("mst_test_table");
    referenceComboTargetTable3.setDisplayColumn("die_name");
    referenceComboTargetTable3.setIdentifier("die_cd");
    referenceComboTargetTable3.setReferencedColumn("test_numeric");

    referenceComboDefNode3.setPhysicalName("test_combo4");
    referenceComboDefNode3.setReferenceComboTargetTable(referenceComboTargetTable3);

    List<ReferenceComboDefNode> list = new ArrayList<>();
    list.add(referenceComboDefNode1);
    list.add(referenceComboDefNode2);
    list.add(referenceComboDefNode3);

    referenceComboDef.setList(list);
    sysMasterDefine.setReferenceComboDef(Optional.of(referenceComboDef));

    return sysMasterDefine;
  }

  /**
   * 検証用のマスタ定義データ（参照型コンボ定義が空）
   */
  private SysMasterDefine getSysMasterDefineReferenceComboDefEmpty() {
    SysMasterDefine sysMasterDefine = new SysMasterDefine();

    sysMasterDefine.setMasterPhysicalName("mst_facility");
    sysMasterDefine.setMasterName("施設マスタ");
    sysMasterDefine.setMode("1");
    sysMasterDefine.setAllowSort("0");
    sysMasterDefine.setAllowAddRecord("1");
    sysMasterDefine.setDispOrder(3);

    ColumnInfo columnInfo = new ColumnInfo();
    List<Field> fields = new ArrayList<Field>();

    // 1列目
    Field field1 = new Field();
    field1.setPhysicalName("facility_cd");
    field1.setTitle("施設コード");
    field1.setType(FieldType.STRING);
    field1.setAlias("code");
    field1.setEditable(false);
    fields.add(field1);

    // 2列目
    Field field2 = new Field();
    Validation validation2 = new Validation();

    field2.setPhysicalName("facility_name");
    field2.setTitle("施設名");
    field2.setType(FieldType.STRING);
    field2.setAlias("name");
    field2.setEditable(true);

    validation2.setMaxlength(30);
    validation2.setRequired(true);
    field2.setValidation(validation2);

    fields.add(field2);

    // 3列目
    Field field3 = new Field();
    field3.setPhysicalName("test_combo2");
    field3.setTitle("テストコンボ2");
    field3.setEditable(true);
    field3.setType(FieldType.COMBO_REFERENCE);
    fields.add(field3);

    columnInfo.setFields(fields);
    sysMasterDefine.setColumnInfo(columnInfo);

    // 参照型コンボ定義
    sysMasterDefine.setReferenceComboDef(Optional.empty());

    return sysMasterDefine;
  }

  /**
   * 検証用のマスタ定義データ（カラム定義がNull）
   */
  private SysMasterDefine getSysMasterDefineColumnInfoNull() {
    SysMasterDefine sysMasterDefine = new SysMasterDefine();

    sysMasterDefine.setMasterPhysicalName("mst_facility");
    sysMasterDefine.setMasterName("施設マスタ");
    sysMasterDefine.setMode("1");
    sysMasterDefine.setAllowSort("0");
    sysMasterDefine.setAllowAddRecord("1");
    sysMasterDefine.setDispOrder(3);

    sysMasterDefine.setColumnInfo(null);

    return sysMasterDefine;
  }

  /**
   * 検証用のマスタ定義データ（カラム定義のフィールド定義が空）
   */
  private SysMasterDefine getSysMasterDefineColumnInfoEmpty() {
    SysMasterDefine sysMasterDefine = new SysMasterDefine();

    sysMasterDefine.setMasterPhysicalName("mst_facility");
    sysMasterDefine.setMasterName("施設マスタ");
    sysMasterDefine.setMode("1");
    sysMasterDefine.setAllowSort("0");
    sysMasterDefine.setAllowAddRecord("1");
    sysMasterDefine.setDispOrder(3);

    ColumnInfo columnInfo = new ColumnInfo();
    List<Field> fields = Collections.emptyList();
    columnInfo.setFields(fields);

    sysMasterDefine.setColumnInfo(columnInfo);

    return sysMasterDefine;
  }

  /**
   * 検証用のマスタセレクタデータ
   */
  private MstSelector getMstSelectorForUpdate() {
    MstSelector mstSelector = new MstSelector();

    mstSelector.setFacilityCd("10001");
    mstSelector.setMasterPhysicalName("mst_facility");

    return mstSelector;
  }

  /**
   * 検証用のマスタ定義データ
   */
  private MstSelector getMstSelector() {
    MstSelector mstSelector = new MstSelector();

    mstSelector.setFacilityCd("10001");
    mstSelector.setMasterPhysicalName("mst_facility");

    List<Item> items = new ArrayList<>();

    Item item1 = new Item();
    item1.setCode(3L);
    item1.setName("施設名3");
    items.add(item1);

    Item item2 = new Item();
    item2.setCode(5L);
    item2.setName("施設名5");
    items.add(item2);

    Item item3 = new Item();
    item3.setCode(1L);
    item3.setName("施設名1");
    items.add(item3);

    OrderSettings orderSettings = new OrderSettings();
    orderSettings.setItems(items);

    mstSelector.setOrderSettings(orderSettings);

    return mstSelector;
  }

  private List<ReferenceCombo> getReferenceCombos() {
    return Arrays.asList(
        new ReferenceCombo(5, "name5", 2L),
        new ReferenceCombo(3, "name3", 1L)
        );
  }

  /**
   * getMasterData()の検証.
   * 条件：マスタデータが複数件取得
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getMasterData_正常_データ取得() {

    // 事前準備
    SysMasterDefine sysMasterDefine = getSysMasterDefine();
    MstSelector mstSelector = getMstSelector();
    List<ReferenceCombo> referenceCombos = getReferenceCombos();

    Map<String, Object> dataMap1 = new HashMap<>();
    dataMap1.put("code", "10001");
    dataMap1.put("name", "施設名");
    dataMap1.put("facilityNameKana", "施設カナ名");
    dataMap1.put("prefecturesCd", "01");
    dataMap1.put("departmentCd", "A1");
    dataMap1.put("aliveMoniInterval", 1);
    dataMap1.put("prefecturesCd", "01");
    dataMap1.put("useFunction", "{\"func_cds\": []}");
    dataMap1.put("isDisp", "1");
    dataMap1.put("test_combo2", "1");
    List<Map<String, Object>> data = Arrays.asList(dataMap1);

    String facilityCd = "001";

    // Mock化
    given(sysMasterDefineDao.selectByName("mst_facility")).willReturn(sysMasterDefine);
    given(mstMaintenaceGenericDao.getMasterData(sysMasterDefine, facilityCd)).willReturn(data);
    given(mstSelectorDao.selectByName(facilityCd, "mst_facility")).willReturn(mstSelector);
    given(referenceComboService.build(any(), any())).willReturn(referenceCombos);

    // 実行
    MasterDataResponse result = target.getMasterData("mst_facility", facilityCd);

    // 検証
    verify(sysMasterDefineDao, times(1)).selectByName("mst_facility");
    assertThat(result, notNullValue());

    assertThat(result.columns.get(0).field, is("sortRank"));
    assertThat(result.columns.get(0).title, is("並び順"));
    assertThat(result.columns.get(0).hidden, is(false));
    assertThat(result.columns.get(0).values, is(nullValue()));
    assertThat(result.columns.get(0).format, is("{0:n0}"));
    assertThat(result.columns.get(0).editable, is(false));

    assertThat(result.columns.get(1).field, is("sortInputTime"));
    assertThat(result.columns.get(1).title, is("sortInputTime"));
    assertThat(result.columns.get(1).hidden, is(true));
    assertThat(result.columns.get(1).values, is(nullValue()));
    assertThat(result.columns.get(1).editable, is(true));

    assertThat(result.columns.get(2).field, is("code")); // 施設コードを別名でフィールド作成
    assertThat(result.columns.get(2).title, is(sysMasterDefine.getColumnInfo().getFields().get(0).getTitle()));
    assertThat(result.columns.get(2).hidden, is(true));
    assertThat(result.columns.get(2).values, is(nullValue()));
    assertThat(result.columns.get(2).editable, is(false));

    assertThat(result.columns.get(3).field, is("name")); // 施設名を別名でフィールド作成
    assertThat(result.columns.get(3).title, is(sysMasterDefine.getColumnInfo().getFields().get(1).getTitle()));
    assertThat(result.columns.get(3).hidden, is(false));
    assertThat(result.columns.get(3).values, is(nullValue()));
    assertThat(result.columns.get(3).editable, is(true));

    assertThat(result.columns.get(4).field, is(sysMasterDefine.getColumnInfo().getFields().get(2).getPhysicalName()));
    assertThat(result.columns.get(4).title, is(sysMasterDefine.getColumnInfo().getFields().get(2).getTitle()));
    assertThat(result.columns.get(4).hidden, is(false));
    assertThat(result.columns.get(4).format, is("{0:n0}"));
    assertThat(result.columns.get(4).values, is(nullValue()));
    assertThat(result.columns.get(4).editable, is(true));

    assertThat(result.columns.get(5).field, is("regDate"));
    assertThat(result.columns.get(5).title, is(sysMasterDefine.getColumnInfo().getFields().get(3).getTitle()));
    assertThat(result.columns.get(5).hidden, is(true));
    assertThat(result.columns.get(5).format, is("{0:yyyy/MM/dd}"));
    assertThat(result.columns.get(5).values, is(nullValue()));
    assertThat(result.columns.get(5).editable, is(true));

    assertThat(result.columns.get(6).field, is("prefecturesCd"));
    assertThat(result.columns.get(6).title, is(sysMasterDefine.getColumnInfo().getFields().get(4).getTitle()));
    assertThat(result.columns.get(6).hidden, is(false));
    assertThat(result.columns.get(6).values, is(sysMasterDefine.getComboData().getCombos().get(0).getValues()));
    assertThat(result.columns.get(6).editable, is(true));

    assertThat(result.columns.get(7).field, is("$modalType"));
    assertThat(result.columns.get(7).title, is("詳細"));
    assertThat(result.columns.get(7).hidden, is(false));
    assertThat(result.columns.get(7).values, is(nullValue()));
    assertThat(result.columns.get(7).editable, is(true));

    assertThat(result.columns.get(8).field, is("useFunction"));
    assertThat(result.columns.get(8).title, is(sysMasterDefine.getColumnInfo().getFields().get(6).getTitle()));
    assertThat(result.columns.get(8).hidden, is(false));
    assertThat(result.columns.get(8).values, is(nullValue()));
    assertThat(result.columns.get(8).editable, is(true));

    assertThat(result.columns.get(9).field, is("isDisp"));
    assertThat(result.columns.get(9).title, is(sysMasterDefine.getColumnInfo().getFields().get(7).getTitle()));
    assertThat(result.columns.get(9).hidden, is(false));
    assertThat(result.columns.get(9).editable, is(true));

    assertThat(result.columns.get(10).field, is("testCombo2"));
    assertThat(result.columns.get(10).title, is(sysMasterDefine.getColumnInfo().getFields().get(8).getTitle()));
    assertThat(result.columns.get(10).hidden, is(false));
    assertThat(result.columns.get(10).values.get(0).getValue(), is(""));    // 先頭が空白行
    assertThat(result.columns.get(10).values.get(0).getText(), is(" "));
    assertThat(result.columns.get(10).values.get(1).getValue(), is(5));
    assertThat(result.columns.get(10).values.get(1).getText(), is("name5"));
    assertThat(result.columns.get(10).values.get(2).getValue(), is(3));
    assertThat(result.columns.get(10).values.get(2).getText(), is("name3"));
    assertThat(result.columns.get(10).editable, is(true));

    assertThat(result.columns.get(11).field, is("testCombo3"));
    assertThat(result.columns.get(11).title, is(sysMasterDefine.getColumnInfo().getFields().get(9).getTitle()));
    assertThat(result.columns.get(11).hidden, is(false));
    assertThat(result.columns.get(11).values.get(0).getValue(), is(""));    // 先頭が空白行
    assertThat(result.columns.get(11).values.get(0).getText(), is(" "));
    assertThat(result.columns.get(11).values.get(1).getValue(), is(5));
    assertThat(result.columns.get(11).values.get(1).getText(), is("name5"));
    assertThat(result.columns.get(11).values.get(2).getValue(), is(3));
    assertThat(result.columns.get(11).values.get(2).getText(), is("name3"));
    assertThat(result.columns.get(11).editable, is(true));

    assertThat(result.columns.get(12).field, is("testCombo4"));
    assertThat(result.columns.get(12).title, is(sysMasterDefine.getColumnInfo().getFields().get(10).getTitle()));
    assertThat(result.columns.get(12).hidden, is(false));
    assertThat(result.columns.get(12).values.get(0).getValue(), is(5));
    assertThat(result.columns.get(12).values.get(0).getText(), is("name5"));
    assertThat(result.columns.get(12).values.get(1).getValue(), is(3));
    assertThat(result.columns.get(12).values.get(1).getText(), is("name3"));
    assertThat(result.columns.get(12).editable, is(true));

    assertThat(result.columns.get(13).field, is("operation"));
    assertThat(result.columns.get(13).title, is("operation"));
    assertThat(result.columns.get(13).hidden, is(true));
    assertThat(result.columns.get(13).values, is(nullValue()));
    assertThat(result.columns.get(13).editable, is(true));

    assertThat(result.columns.get(14).field, is("allowAddRecord"));
    assertThat(result.columns.get(14).title, is("allowAddRecord"));
    assertThat(result.columns.get(14).hidden, is(true));
    assertThat(result.columns.get(14).values, is(nullValue()));
    assertThat(result.columns.get(14).editable, is(true));

    // 施設コードは別名のcodeでフィールド作成
    assertThat(result.localDataSource.schema.model.fields.get("code").toString(), is("{type=STRING}"));
    // 施設名は別名のnameでフィールド作成
    assertThat(result.localDataSource.schema.model.fields.get("name").toString(),
        is("{type=STRING, validation={maxlength=30, required=true}}"));
    // 間隔は別名を設定していないため物理名称でフィールド作成
    assertThat(result.localDataSource.schema.model.fields.get("interval").toString(),
        is("{type=NUMBER, validation={min=-1, max=20}}"));
    // ソート項目はNUMBERでフィールド作成
    assertThat(result.localDataSource.schema.model.fields.get("sortRank").toString(), is("{defaultValue=0, type=NUMBER, validation={min=0}}"));
    assertThat(result.localDataSource.schema.model.fields.get("sortInputTime").toString(), is("{type=NUMBER}"));
    // 削除は規定値1を設定
    assertThat(result.localDataSource.schema.model.fields.get("isDisp").toString(), is("{defaultValue=1, type=STRING}"));

    assertThat(result.localDataSource.data.get(0).get("code"), is("10001"));
    assertThat(result.localDataSource.data.get(0).get("name"), is("施設名"));
    assertThat(result.localDataSource.data.get(0).get("facilityNameKana"), is("施設カナ名"));
    assertThat(result.localDataSource.data.get(0).get("prefecturesCd"), is("01"));
    assertThat(result.localDataSource.data.get(0).get("departmentCd"), is("A1"));
    assertThat(result.localDataSource.data.get(0).get("aliveMoniInterval"), is(1));
    assertThat(result.localDataSource.data.get(0).get("prefecturesCd"), is("01"));
    assertThat(result.localDataSource.data.get(0).get("sortRank"), is(999999));
    assertThat(result.localDataSource.data.get(0).get("sortInputTime"), is(nullValue()));
    assertThat(result.localDataSource.data.get(0).get("useFunction"), is("{\"func_cds\": []}"));

  }

  /**
   * updateMasterData()の検証.
   *
   * 条件：挿入データ１件、更新データ１件
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_updateMasterData_正常() {

    // 事前準備
    @SuppressWarnings("serial")
    Map<String, Object> dataMap1 = new HashMap<String, Object>() {
      {
        put("code", 10001);
        put("name", "施設名");
        put("facilityNameKana", "施設カナ名");
        put("prefecturesCd", "01");
        put("departmentCd", "A1");
        put("operation", null);
        put("sortRank", 3);
      }
    };
    @SuppressWarnings("serial")
    Map<String, Object> dataMap2 = new HashMap<String, Object>() {
      {
        put("code", 10002);
        put("name", "施設名2");
        put("facilityNameKana", "施設カナ名");
        put("prefecturesCd", "01");
        put("departmentCd", "A1");
        put("operation", AdminWebConstant.MasterOperationType.INSERT);
        put("sortRank", 2);
      }
    };
    @SuppressWarnings("serial")
    Map<String, Object> dataMap3 = new HashMap<String, Object>() {
      {
        put("code", 10003);
        put("name", "施設名3");
        put("facilityNameKana", "施設カナ名2");
        put("prefecturesCd", "02");
        put("departmentCd", "A2");
        put("operation", AdminWebConstant.MasterOperationType.UPDATE);
        put("sortRank", 1);
      }
    };
    List<Map<String, Object>> data = Arrays.asList(dataMap1, dataMap2, dataMap3);

    String masterName = "mst_facility";
    String facilityCd = "10001";

    SysMasterDefine sysMasterDefine = getSysMasterDefine();
    MstSelector mstSelector = getMstSelectorForUpdate();

    // Mock化
    given(sysMasterDefineDao.selectByName(masterName)).willReturn(sysMasterDefine);
    given(mstSelectorDao.selectByName(facilityCd, masterName)).willReturn(mstSelector);
    given(mstMaintenaceGenericDao.getFieldName(any(), any())).willReturn("facility_cd");
    given(mstMaintenaceGenericDao.selectCurrentSeq(any(), any())).willReturn(1L);

    // 実行
    MasterUpdateResponse result = target.updateMasterData(masterName, facilityCd, data);

    // 検証
    verify(mstMaintenaceGenericDao, times(1)).insertMasterData(dataMap2, sysMasterDefine, facilityCd);
    verify(mstMaintenaceGenericDao, times(1)).updateMasterData(dataMap3, sysMasterDefine);
    verify(mstMaintenaceGenericDao, times(1)).selectCurrentSeq("facility_cd", masterName);
    verify(mstMaintenaceGenericDao, times(1)).getFieldName(MasterMaintenanceGenericDao.ALIAS_CODE, sysMasterDefine);
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, is(nullValue()));

  }

  /**
   * getMasterData()のソートの検証.
   *
   * 条件：挿入データ１件、更新データ１件
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getMasterData_ソート() {

    // 事前準備
    SysMasterDefine sysMasterDefine = getSysMasterDefine();
    MstSelector mstSelector = getMstSelector();

    Map<String, Object> dataMap1 = new HashMap<>();
    dataMap1.put("code", 1L);
    dataMap1.put("name", "施設名1");
    dataMap1.put("facilityNameKana", "施設カナ名1");
    dataMap1.put("prefecturesCd", "01");
    dataMap1.put("departmentCd", "A1");
    dataMap1.put("aliveMoniInterval", 1);
    dataMap1.put("prefecturesCd", "01");

    Map<String, Object> dataMap2 = new HashMap<>();
    dataMap2.put("code", 2L);
    dataMap2.put("name", "施設名2");
    dataMap2.put("facilityNameKana", "施設カナ名2");
    dataMap2.put("prefecturesCd", "02");
    dataMap2.put("departmentCd", "A2");
    dataMap2.put("aliveMoniInterval", 2);
    dataMap2.put("prefecturesCd", "02");

    Map<String, Object> dataMap3 = new HashMap<>();
    dataMap3.put("code", 3L);
    dataMap3.put("name", "施設名3");
    dataMap3.put("facilityNameKana", "施設カナ名3");
    dataMap3.put("prefecturesCd", "03");
    dataMap3.put("departmentCd", "A3");
    dataMap3.put("aliveMoniInterval", 3);
    dataMap3.put("prefecturesCd", "03");

    Map<String, Object> dataMap4 = new HashMap<>();
    dataMap4.put("code", 4L);
    dataMap4.put("name", "施設名4");
    dataMap4.put("facilityNameKana", "施設カナ名4");
    dataMap4.put("prefecturesCd", "04");
    dataMap4.put("departmentCd", "A4");
    dataMap4.put("aliveMoniInterval", 4);
    dataMap4.put("prefecturesCd", "04");

    Map<String, Object> dataMap5 = new HashMap<>();
    dataMap5.put("code", 5L);
    dataMap5.put("name", "施設名5");
    dataMap5.put("facilityNameKana", "施設カナ名5");
    dataMap5.put("prefecturesCd", "05");
    dataMap5.put("departmentCd", "A5");
    dataMap5.put("aliveMoniInterval", 5);
    dataMap5.put("prefecturesCd", "05");
    List<Map<String, Object>> data = Arrays.asList(dataMap1, dataMap2, dataMap3, dataMap4, dataMap5);

    String facilityCd = "10001";
    String masterPhysicalName = "mst_facility";

    // Mock化
    given(sysMasterDefineDao.selectByName(masterPhysicalName)).willReturn(sysMasterDefine);
    given(mstMaintenaceGenericDao.getMasterData(sysMasterDefine, facilityCd)).willReturn(data);
    given(mstSelectorDao.selectByName(facilityCd, masterPhysicalName)).willReturn(mstSelector);

    // 実行
    MasterDataResponse result = target.getMasterData("mst_facility", facilityCd);

    // 検証
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, masterPhysicalName);
    assertThat(result, notNullValue());

    // 1列目
    assertThat(result.localDataSource.data.get(0).get("code"), is(3L));
    assertThat(result.localDataSource.data.get(0).get("name"), is("施設名3"));
    assertThat(result.localDataSource.data.get(0).get("facilityNameKana"), is("施設カナ名3"));
    assertThat(result.localDataSource.data.get(0).get("prefecturesCd"), is("03"));
    assertThat(result.localDataSource.data.get(0).get("departmentCd"), is("A3"));
    assertThat(result.localDataSource.data.get(0).get("aliveMoniInterval"), is(3));
    assertThat(result.localDataSource.data.get(0).get("prefecturesCd"), is("03"));
    assertThat(result.localDataSource.data.get(0).get("sortRank"), is(1));
    assertThat(result.localDataSource.data.get(0).get("sortInputTime"), is(nullValue()));

    // 2列目
    assertThat(result.localDataSource.data.get(1).get("code"), is(5L));
    assertThat(result.localDataSource.data.get(1).get("name"), is("施設名5"));
    assertThat(result.localDataSource.data.get(1).get("facilityNameKana"), is("施設カナ名5"));
    assertThat(result.localDataSource.data.get(1).get("prefecturesCd"), is("05"));
    assertThat(result.localDataSource.data.get(1).get("departmentCd"), is("A5"));
    assertThat(result.localDataSource.data.get(1).get("aliveMoniInterval"), is(5));
    assertThat(result.localDataSource.data.get(1).get("prefecturesCd"), is("05"));
    assertThat(result.localDataSource.data.get(1).get("sortRank"), is(2));
    assertThat(result.localDataSource.data.get(1).get("sortInputTime"), is(nullValue()));

    // 3列目
    assertThat(result.localDataSource.data.get(2).get("code"), is(1L));
    assertThat(result.localDataSource.data.get(2).get("name"), is("施設名1"));
    assertThat(result.localDataSource.data.get(2).get("facilityNameKana"), is("施設カナ名1"));
    assertThat(result.localDataSource.data.get(2).get("prefecturesCd"), is("01"));
    assertThat(result.localDataSource.data.get(2).get("departmentCd"), is("A1"));
    assertThat(result.localDataSource.data.get(2).get("aliveMoniInterval"), is(1));
    assertThat(result.localDataSource.data.get(2).get("prefecturesCd"), is("01"));
    assertThat(result.localDataSource.data.get(2).get("sortRank"), is(3));
    assertThat(result.localDataSource.data.get(2).get("sortInputTime"), is(nullValue()));

    // 4列目
    assertThat(result.localDataSource.data.get(3).get("code"), is(2L));
    assertThat(result.localDataSource.data.get(3).get("name"), is("施設名2"));
    assertThat(result.localDataSource.data.get(3).get("facilityNameKana"), is("施設カナ名2"));
    assertThat(result.localDataSource.data.get(3).get("prefecturesCd"), is("02"));
    assertThat(result.localDataSource.data.get(3).get("departmentCd"), is("A2"));
    assertThat(result.localDataSource.data.get(3).get("aliveMoniInterval"), is(2));
    assertThat(result.localDataSource.data.get(3).get("prefecturesCd"), is("02"));
    assertThat(result.localDataSource.data.get(3).get("sortRank"), is(999999));
    assertThat(result.localDataSource.data.get(3).get("sortInputTime"), is(nullValue()));

    // 5列目
    assertThat(result.localDataSource.data.get(4).get("code"), is(4L));
    assertThat(result.localDataSource.data.get(4).get("name"), is("施設名4"));
    assertThat(result.localDataSource.data.get(4).get("facilityNameKana"), is("施設カナ名4"));
    assertThat(result.localDataSource.data.get(4).get("prefecturesCd"), is("04"));
    assertThat(result.localDataSource.data.get(4).get("departmentCd"), is("A4"));
    assertThat(result.localDataSource.data.get(4).get("aliveMoniInterval"), is(4));
    assertThat(result.localDataSource.data.get(4).get("prefecturesCd"), is("04"));
    assertThat(result.localDataSource.data.get(4).get("sortRank"), is(999999));
    assertThat(result.localDataSource.data.get(4).get("sortInputTime"), is(nullValue()));

  }

  /**
   * getMasterData()の参照型コンボの構造定義データが設定されていない場合の検証.
   *
   * 条件：データが１件取得
   * 結果：空のレスポンスが返されること
   */
  @Test
  public void test_getMasterData_参照型コンボの構造定義データが設定されていない場合() {
    SysMasterDefine sysMasterDefine = getSysMasterDefineReferenceComboDefEmpty();

    final String facilityCd = "001";
    final String masterName = "mst_facility";

    // Mock化
    given(sysMasterDefineDao.selectByName(any())).willReturn(sysMasterDefine);

    // 実行
    MasterDataResponse result = target.getMasterData(masterName, facilityCd);
    MasterColumn combo2Column = result.columns.stream()
        .filter(c -> c.field.equals("testCombo2"))
        .findFirst()
        .get();

    assertThat(combo2Column.title, is("テストコンボ2"));
    assertThat(combo2Column.values, nullValue());
  }

  /**
   * getMasterData()のカラム定義が設定されていない場合.
   *
   * 条件：データが１件取得
   * 結果：空のレスポンスが返されること
   */
  @Test
  public void test_getMasterData_カラム定義が設定されていない() {
    SysMasterDefine sysMasterDefine = getSysMasterDefineColumnInfoNull();

    final String facilityCd = "001";
    final String masterName = "mst_facility";

    // Mock化
    given(sysMasterDefineDao.selectByName(any())).willReturn(sysMasterDefine);

    // 実行
    MasterDataResponse result = target.getMasterData(masterName, facilityCd);

    assertThat(result.columns, is(Collections.emptyList()));
    assertThat(result.localDataSource.data, is(Collections.emptyList()));
    assertThat(result.localDataSource.schema.model.fields.isEmpty(), is(true));

  }

  /**
   * getMasterData()のカラム定義のフィールド定義が空.
   *
   * 条件：データが１件取得
   * 結果：空のレスポンスが返されること
   */
  @Test
  public void test_getMasterData_カラム定義のフィールド定義が空() {
    SysMasterDefine sysMasterDefine = getSysMasterDefineColumnInfoEmpty();

    final String facilityCd = "001";
    final String masterName = "mst_facility";

    // Mock化
    given(sysMasterDefineDao.selectByName(any())).willReturn(sysMasterDefine);

    // 実行
    MasterDataResponse result = target.getMasterData(masterName, facilityCd);

    assertThat(result.columns, is(Collections.emptyList()));
    assertThat(result.localDataSource.data, is(Collections.emptyList()));
    assertThat(result.localDataSource.schema.model.fields.isEmpty(), is(true));

  }

  /**
   * getColumnInfo()の検証.
   * 条件：マスタ定義情報が取得できる
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getColumnInfo_正常_データ取得_カラム情報あり() {

    // 事前準備
    SysMasterDefine sysMasterDefine = new SysMasterDefine();
    SysMasterDefine.ColumnInfo columnInfo = new SysMasterDefine.ColumnInfo("{\"fields\": [{\"type\": \"number\", \"alias\": \"code\", \"title\": \"治療方法コード\", \"format\": null, \"hidden\": \"true\", \"editable\": \"false\", \"validation\": {\"max\": null, \"min\": null, \"required\": \"true\", \"maxlength\": null}, \"physical_name\": \"treatment_cd\"}, {\"type\": \"string\", \"alias\": \"name\", \"title\": \"治療方法名\", \"format\": null, \"hidden\": \"false\", \"editable\": \"true\", \"validation\": {\"max\": 50, \"min\": 10, \"required\": \"false\", \"maxlength\": 20}, \"physical_name\": \"treatment_name\"}]}");
    sysMasterDefine.setColumnInfo(columnInfo);

    String masterName = "mst_facility";

    // Mock化
    given(sysMasterDefineDao.selectByName(masterName)).willReturn(sysMasterDefine);

    // 実行
    SysMasterDefine.ColumnInfo result = target.getColumnInfo(masterName);

    // 検証
    verify(sysMasterDefineDao, times(1)).selectByName(masterName);
    assertThat(result, notNullValue());

    assertThat(result.getFields().get(0).getType(), is(FieldType.valueOf("NUMBER")));
    assertThat(result.getFields().get(0).getAlias(), is("code"));
    assertThat(result.getFields().get(0).getTitle(), is("治療方法コード"));
    assertThat(result.getFields().get(0).getFormat(), nullValue());
    assertThat(result.getFields().get(0).getHidden(), is(true));
    assertThat(result.getFields().get(0).getEditable(), is(false));
    assertThat(result.getFields().get(0).getValidation().getMax(), nullValue());
    assertThat(result.getFields().get(0).getValidation().getMin(), nullValue());
    assertThat(result.getFields().get(0).getValidation().isRequired(), is(true));
    assertThat(result.getFields().get(0).getValidation().getMaxlength(), nullValue());
    assertThat(result.getFields().get(0).getPhysicalName(), is("treatment_cd"));

    assertThat(result.getFields().get(1).getType(), is(FieldType.valueOf("STRING")));
    assertThat(result.getFields().get(1).getAlias(), is("name"));
    assertThat(result.getFields().get(1).getTitle(), is("治療方法名"));
    assertThat(result.getFields().get(1).getFormat(), nullValue());
    assertThat(result.getFields().get(1).getHidden(), is(false));
    assertThat(result.getFields().get(1).getEditable(), is(true));
    assertThat(result.getFields().get(1).getValidation().getMax(), is(new BigDecimal("50")));
    assertThat(result.getFields().get(1).getValidation().getMin(), is(new BigDecimal("10")));
    assertThat(result.getFields().get(1).getValidation().isRequired(), is(false));
    assertThat(result.getFields().get(1).getValidation().getMaxlength(), is(20));
    assertThat(result.getFields().get(1).getPhysicalName(), is("treatment_name"));
  }

  /**
   * getColumnInfo()の検証.
   * 条件：マスタ定義情報が取得できる
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getColumnInfo_正常_データ取得_カラム情報なし() {

    // 事前準備
    SysMasterDefine sysMasterDefine = new SysMasterDefine();
    SysMasterDefine.ColumnInfo columnInfo = new SysMasterDefine.ColumnInfo("{\"fields\": []}");
    sysMasterDefine.setColumnInfo(columnInfo);

    String masterName = "mst_facility";

    // Mock化
    given(sysMasterDefineDao.selectByName(masterName)).willReturn(sysMasterDefine);

    // 実行
    SysMasterDefine.ColumnInfo result = target.getColumnInfo(masterName);

    // 検証
    verify(sysMasterDefineDao, times(1)).selectByName(masterName);
    assertThat(result, notNullValue());

    assertThat(result.getFields(), hasSize(0));
  }

  /**
   * getColumnInfo()の検証.
   * 条件：マスタ定義情報が取得できない
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getColumnInfo_正常_データ取得_マスタ定義情報なし() {

    // 事前準備
    String masterName = "mst_test";

    // Mock化
    given(sysMasterDefineDao.selectByName(masterName)).willReturn(null);

    // 実行
    SysMasterDefine.ColumnInfo result = target.getColumnInfo(masterName);

    // 検証
    verify(sysMasterDefineDao, times(1)).selectByName(masterName);
    assertThat(result, notNullValue());

    assertThat(result.getFields(), hasSize(0));
  }

}
