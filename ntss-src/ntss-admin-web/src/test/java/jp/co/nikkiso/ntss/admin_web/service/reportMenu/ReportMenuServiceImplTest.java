package jp.co.nikkiso.ntss.admin_web.service.reportMenu;

import jp.co.nikkiso.ntss.admin_web.service.MstInfoService;
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.core.dao.ReportMenuDao;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.ReportMenuSortContainer;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;
import static org.mockito.BDDMockito.given;

/**
 * {@link ReportMenuServiceImpl}のテストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class ReportMenuServiceImplTest {

  /**
   * テスト対象クラス
   */
  @Autowired
  private ReportMenuService reportMenuService;

  /**
   * {@link ReportMenuDao}
   */
  @MockBean
  private ReportMenuDao reportMenuDao;

  /**
   * {@link MstInfoService}
   */
  @MockBean
  private MstInfoService mstInfoService;

  /**
   * createDistributionListDataKey(privateメソッド)をinvokeする.
   *
   * @param condition 帳票出力条件
   * @return 配布リスト用のデータキー
   */
  private Map<String, Object> invokeCreateDistributionListDataKey(ReportMenuSortContainer condition) {
    try {
      Method method = ReportMenuServiceImpl.class.getDeclaredMethod("createDistributionListDataKey", ReportMenuSortContainer.class);
      method.setAccessible(true);
      return (Map<String, Object>) method.invoke(reportMenuService, condition);
    } catch (NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    }
    return null;
  }

  /**
   * createDistributionListDataKey()の検証.
   *
   * <p>
   *   条件：ダイアライザ指定なし
   *   結果：データキー内の{@link ReportConstant.ReportDataKey#DIALYZER_IDS}に0が格納されたサイズ:1のリストが設定される事
   * </p>
   */
  @Test
  public void test_createDistributionListDataKey_正常_ダイアライザ指定なし() {
    // 事前準備
    Long[] ordNos = {10L,20L,30L};
    Long[] patIds = {1001L,1002L,1003L};
    Integer[] medicineCds = {1,2,3,4};
    Integer[] equipmentCds = {5,6,7,8};
    String specifyDate = "20200408";
    String facilityCd = "009999";

    // テスト用の帳票出力メニューからのパラメータ
    ReportMenuSortContainer condition = new ReportMenuSortContainer();
    condition.setSpecifyDate(specifyDate);
    condition.setFacilityCd(facilityCd);
    condition.setPatIds(Arrays.asList(patIds));
    condition.setMedicineCdList(Arrays.asList(medicineCds));
    condition.setEquipmentCdList(Arrays.asList(equipmentCds));

    // Mock
    given(reportMenuDao.selectByTreatDate(patIds[0], specifyDate, null, null)).willReturn(createOrdMainList(ordNos[0], patIds[0], specifyDate));
    given(reportMenuDao.selectByTreatDate(patIds[1], specifyDate, null, null)).willReturn(createOrdMainList(ordNos[1], patIds[1], specifyDate));
    given(reportMenuDao.selectByTreatDate(patIds[2], specifyDate, null, null)).willReturn(createOrdMainList(ordNos[2], patIds[2], specifyDate));

    // 実行
    Map<String, Object> result = invokeCreateDistributionListDataKey(condition);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(6));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.DATE));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.ORD_NOS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.TEMPLATE_PARAMS));

    // テンプレート外：日付のチェック
    assertThat(result.get(ReportConstant.ReportDataKey.DATE), is(specifyDate));
    // テンプレート外：オーダ番号のチェック
    List<Long> resultOrdNoOutTemp = ((List<Long>)result.get(ReportConstant.ReportDataKey.ORD_NOS));
    assertThat(resultOrdNoOutTemp.size(),is(3));
    for (int index = 0; index < resultOrdNoOutTemp.size(); index++) {
      assertThat(resultOrdNoOutTemp.get(index), is(ordNos[index]));
    }
    // テンプレート外：薬剤分類のチェック
    List<Integer> resultMedicineClassOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
    assertThat(resultMedicineClassOutTemp.size(),is(4));
    for (int index = 0; index < resultMedicineClassOutTemp.size(); index++) {
      assertThat(resultMedicineClassOutTemp.get(index), is(medicineCds[index]));
    }
    // テンプレート外：医療材料分類のチェック
    List<Integer> resultEquipmentClassOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    assertThat(resultEquipmentClassOutTemp.size(),is(4));
    for (int index = 0; index < resultEquipmentClassOutTemp.size(); index++) {
      assertThat(resultEquipmentClassOutTemp.get(index), is(equipmentCds[index]));
    }
    // テンプレート外：ダイアライザのチェック
    List<Integer> resultDialyzerCdOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
    assertThat(resultDialyzerCdOutTemp.size(), is(1));
    assertThat(resultDialyzerCdOutTemp.get(0), is(0));

    // テンプレート内：件数チェック
    List<Map<String, Object>> templateParams = (List<Map<String, Object>>) result.get(ReportConstant.ReportDataKey.TEMPLATE_PARAMS);
    assertThat(templateParams.size(), is(3));
    for (int index = 0; index < templateParams.size(); index++) {
      // 各データキーの存在チェック
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.ORD_NOS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS));

      List<Integer> resultOrdNoInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.ORD_NOS));
      assertThat(resultOrdNoInTemp.size(), is(1));
      assertThat(resultOrdNoInTemp.get(0), is(ordNos[index]));

      // テンプレート内：薬剤分類のチェック
      List<Integer> resultMedicineClassInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.MEDICINE_IDS));
      assertThat(resultMedicineClassInTemp.size(),is(4));
      for (int index2 = 0; index2 < resultMedicineClassInTemp.size(); index2++) {
        assertThat(resultMedicineClassInTemp.get(index2), is(medicineCds[index2]));
      }

      // テンプレート内：医療材料分類のチェック
      List<Integer> resultEquipmentClassInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
      assertThat(resultEquipmentClassInTemp.size(),is(4));
      for (int index2 = 0; index2 < resultEquipmentClassInTemp.size(); index2++) {
        assertThat(resultEquipmentClassInTemp.get(index2), is(equipmentCds[index2]));
      }
      // テンプレート内：ダイアライザのチェック
      List<Integer> resultDialyzerCdInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.DIALYZER_IDS));
      assertThat(resultDialyzerCdInTemp.size(), is(1));
      assertThat(resultDialyzerCdInTemp.get(0), is(0));
    }
  }

  /**
   * createDistributionListDataKey()の検証.
   *
   * <p>
   *   条件：ダイアライザ指定あり
   *   結果：データキー内の{@link ReportConstant.ReportDataKey#DIALYZER_IDS}にダイアライザコードのリストがに含まれる事
   * </p>
   */
  @Test
  public void test_createDistributionListDataKey_正常_ダイアライザ指定あり() {
    // 事前準備
    Long[] ordNos = {10L,20L,30L};
    Long[] patIds = {1001L,1002L,1003L};
    Integer[] medicineCds = {1,2,3,4};
    Integer[] equipmentCds = {0,5,6,7,8};
    String specifyDate = "20200408";
    String facilityCd = "009999";

    // テスト用の帳票出力メニューからのパラメータ
    ReportMenuSortContainer condition = new ReportMenuSortContainer();
    condition.setSpecifyDate(specifyDate);
    condition.setFacilityCd(facilityCd);
    condition.setPatIds(Arrays.asList(patIds));
    condition.setMedicineCdList(Arrays.asList(medicineCds));
    condition.setEquipmentCdList(Arrays.asList(equipmentCds));

    // テスト用ダイアライザマスタ
    List<MstDialyzer> dialyzerList = new ArrayList<>();
    for (int index = 1; index <= 5; index++) {
      MstDialyzer mstDialyzer = new MstDialyzer();
      mstDialyzer.setDialyzerCd(index);
      mstDialyzer.setFacilityCd(facilityCd);
      dialyzerList.add(mstDialyzer);
    }

    // Mock
    given(reportMenuDao.selectByTreatDate(patIds[0], specifyDate, null, null)).willReturn(createOrdMainList(ordNos[0], patIds[0], specifyDate));
    given(reportMenuDao.selectByTreatDate(patIds[1], specifyDate, null, null)).willReturn(createOrdMainList(ordNos[1], patIds[1], specifyDate));
    given(reportMenuDao.selectByTreatDate(patIds[2], specifyDate, null, null)).willReturn(createOrdMainList(ordNos[2], patIds[2], specifyDate));
    given(mstInfoService.findMstDialyzerAllByFacillityCd(facilityCd)).willReturn(dialyzerList);

    // 実行
    Map<String, Object> result = invokeCreateDistributionListDataKey(condition);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(6));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.DATE));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.ORD_NOS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.TEMPLATE_PARAMS));

    // テンプレート外：日付のチェック
    assertThat(result.get(ReportConstant.ReportDataKey.DATE), is(specifyDate));
    // テンプレート外：オーダ番号のチェック
    List<Long> resultOrdNoOutTemp = ((List<Long>)result.get(ReportConstant.ReportDataKey.ORD_NOS));
    assertThat(resultOrdNoOutTemp.size(),is(3));
    for (int index = 0; index < resultOrdNoOutTemp.size(); index++) {
      assertThat(resultOrdNoOutTemp.get(index), is(ordNos[index]));
    }
    // テンプレート外：薬剤分類のチェック
    List<Integer> resultMedicineClassOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
    assertThat(resultMedicineClassOutTemp.size(),is(4));
    for (int index = 0; index < resultMedicineClassOutTemp.size(); index++) {
      assertThat(resultMedicineClassOutTemp.get(index), is(medicineCds[index]));
    }
    // テンプレート外：医療材料分類のチェック
    List<Integer> resultEquipmentClassOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    assertThat(resultEquipmentClassOutTemp.size(),is(5));
    for (int index = 0; index < resultEquipmentClassOutTemp.size(); index++) {
      assertThat(resultEquipmentClassOutTemp.get(index), is(equipmentCds[index]));
    }
    // テンプレート外：ダイアライザのチェック
    List<Integer> resultDialyzerCdOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
    assertThat(resultDialyzerCdOutTemp.size(),is(5));
    for (int index = 0; index < resultDialyzerCdOutTemp.size(); index++) {
      assertThat(resultDialyzerCdOutTemp.get(index), is(index + 1));
    }

    // テンプレート内：件数チェック
    List<Map<String, Object>> templateParams = (List<Map<String, Object>>) result.get(ReportConstant.ReportDataKey.TEMPLATE_PARAMS);
    assertThat(templateParams.size(), is(3));
    for (int index = 0; index < templateParams.size(); index++) {
      // 各データキーの存在チェック
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.ORD_NOS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS));

      List<Integer> resultOrdNoInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.ORD_NOS));
      assertThat(resultOrdNoInTemp.size(), is(1));
      assertThat(resultOrdNoInTemp.get(0), is(ordNos[index]));

      // テンプレート内：薬剤分類のチェック
      List<Integer> resultMedicineClassInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.MEDICINE_IDS));
      assertThat(resultMedicineClassInTemp.size(),is(4));
      for (int index2 = 0; index2 < resultMedicineClassInTemp.size(); index2++) {
        assertThat(resultMedicineClassInTemp.get(index2), is(medicineCds[index2]));
      }

      // テンプレート内：医療材料分類のチェック
      List<Integer> resultEquipmentClassInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
      assertThat(resultEquipmentClassInTemp.size(),is(5));
      for (int index2 = 0; index2 < resultEquipmentClassInTemp.size(); index2++) {
        assertThat(resultEquipmentClassInTemp.get(index2), is(equipmentCds[index2]));
      }
      // テンプレート内：ダイアライザのチェック
      List<Integer> resultDialyzerCdInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.DIALYZER_IDS));
      assertThat(resultDialyzerCdInTemp.size(),is(5));
      for (int index2 = 0; index2 < resultDialyzerCdInTemp.size(); index2++) {
        assertThat(resultDialyzerCdInTemp.get(index2), is(index2 + 1));
      }
    }
  }

  /**
   * createDistributionListDataKey()の検証.
   *
   * <p>
   *   条件：指定日付の患者の治療情報（ordMain)が存在しない場合
   *   結果：テンプレート内外のオーダ番号に条件に合致するオーダ番号が含まれない事
   * </p>
   */
  @Test
  public void test_createDistributionListDataKey_正常_指定日付の患者の治療情報が存在しない() {
    // 事前準備
    Long[] ordNos = {10L,20L,30L};
    Long[] patIds = {1001L,1002L,1003L};
    Integer[] medicineCds = {1,2,3,4};
    Integer[] equipmentCds = {0,5,6,7,8};
    String specifyDate = "20200408";
    String facilityCd = "009999";

    // テスト用の帳票出力メニューからのパラメータ
    ReportMenuSortContainer condition = new ReportMenuSortContainer();
    condition.setSpecifyDate(specifyDate);
    condition.setFacilityCd(facilityCd);
    condition.setPatIds(Arrays.asList(patIds));
    condition.setMedicineCdList(Arrays.asList(medicineCds));
    condition.setEquipmentCdList(Arrays.asList(equipmentCds));

    // テスト用ダイアライザマスタ
    List<MstDialyzer> dialyzerList = new ArrayList<>();
    for (int index = 1; index <= 5; index++) {
      MstDialyzer mstDialyzer = new MstDialyzer();
      mstDialyzer.setDialyzerCd(index);
      mstDialyzer.setFacilityCd(facilityCd);
      dialyzerList.add(mstDialyzer);
    }

    // Mock
    given(reportMenuDao.selectByTreatDate(patIds[0], specifyDate, null, null)).willReturn(createOrdMainList(ordNos[0], patIds[0], specifyDate));
    given(reportMenuDao.selectByTreatDate(patIds[1], specifyDate, null, null)).willReturn(Collections.emptyList());
    given(reportMenuDao.selectByTreatDate(patIds[2], specifyDate, null, null)).willReturn(createOrdMainList(ordNos[2], patIds[2], specifyDate));
    given(mstInfoService.findMstDialyzerAllByFacillityCd(facilityCd)).willReturn(dialyzerList);

    // 実行
    Map<String, Object> result = invokeCreateDistributionListDataKey(condition);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(6));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.DATE));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.ORD_NOS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.TEMPLATE_PARAMS));

    // テンプレート外：日付のチェック
    assertThat(result.get(ReportConstant.ReportDataKey.DATE), is(specifyDate));
    // テンプレート外：オーダ番号のチェック
    List<Long> resultOrdNoOutTemp = ((List<Long>)result.get(ReportConstant.ReportDataKey.ORD_NOS));
    assertThat(resultOrdNoOutTemp.size(),is(2));
    assertThat(resultOrdNoOutTemp.get(0), is(ordNos[0]));
    assertThat(resultOrdNoOutTemp.get(1), is(ordNos[2]));
    // テンプレート外：薬剤分類のチェック
    List<Integer> resultMedicineClassOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
    assertThat(resultMedicineClassOutTemp.size(),is(4));
    for (int index = 0; index < resultMedicineClassOutTemp.size(); index++) {
      assertThat(resultMedicineClassOutTemp.get(index), is(medicineCds[index]));
    }
    // テンプレート外：医療材料分類のチェック
    List<Integer> resultEquipmentClassOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    assertThat(resultEquipmentClassOutTemp.size(),is(5));
    for (int index = 0; index < resultEquipmentClassOutTemp.size(); index++) {
      assertThat(resultEquipmentClassOutTemp.get(index), is(equipmentCds[index]));
    }
    // テンプレート外：ダイアライザのチェック
    List<Integer> resultDialyzerCdOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
    assertThat(resultDialyzerCdOutTemp.size(),is(5));
    for (int index = 0; index < resultDialyzerCdOutTemp.size(); index++) {
      assertThat(resultDialyzerCdOutTemp.get(index), is(index + 1));
    }

    // テンプレート内：件数チェック
    List<Map<String, Object>> templateParams = (List<Map<String, Object>>) result.get(ReportConstant.ReportDataKey.TEMPLATE_PARAMS);
    assertThat(templateParams.size(), is(2));
    for (int index = 0; index < templateParams.size(); index++) {
      // 各データキーの存在チェック
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.ORD_NOS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS));

      List<Integer> resultOrdNoInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.ORD_NOS));
      if (index != 1) {
        assertThat(resultOrdNoInTemp.size(), is(1));
        assertThat(resultOrdNoInTemp.get(0), is(ordNos[index]));
      }

      // テンプレート内：薬剤分類のチェック
      List<Integer> resultMedicineClassInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.MEDICINE_IDS));
      assertThat(resultMedicineClassInTemp.size(),is(4));
      for (int index2 = 0; index2 < resultMedicineClassInTemp.size(); index2++) {
        assertThat(resultMedicineClassInTemp.get(index2), is(medicineCds[index2]));
      }

      // テンプレート内：医療材料分類のチェック
      List<Integer> resultEquipmentClassInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
      assertThat(resultEquipmentClassInTemp.size(),is(5));
      for (int index2 = 0; index2 < resultEquipmentClassInTemp.size(); index2++) {
        assertThat(resultEquipmentClassInTemp.get(index2), is(equipmentCds[index2]));
      }
      // テンプレート内：ダイアライザのチェック
      List<Integer> resultDialyzerCdInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.DIALYZER_IDS));
      assertThat(resultDialyzerCdInTemp.size(),is(5));
      for (int index2 = 0; index2 < resultDialyzerCdInTemp.size(); index2++) {
        assertThat(resultDialyzerCdInTemp.get(index2), is(index2 + 1));
      }
    }
  }

  /**
   * createDistributionListDataKey()の検証.
   *
   * <p>
   *   条件：薬剤分類が未指定の場合
   *   結果：テンプレート内外のデータキー内の{@link ReportConstant.ReportDataKey#MEDICINE_IDS}に0が格納されたサイズ:1のリストが設定される事
   * </p>
   */
  @Test
  public void test_createDistributionListDataKey_正常_薬剤分類指定なし() {
    // 事前準備
    Long[] ordNos = {10L,20L,30L};
    Long[] patIds = {1001L,1002L,1003L};
    Integer[] equipmentCds = {0,5,6,7,8};
    String specifyDate = "20200408";
    String facilityCd = "009999";

    // テスト用の帳票出力メニューからのパラメータ
    ReportMenuSortContainer condition = new ReportMenuSortContainer();
    condition.setSpecifyDate(specifyDate);
    condition.setFacilityCd(facilityCd);
    condition.setPatIds(Arrays.asList(patIds));
    condition.setMedicineCdList(Collections.emptyList());
    condition.setEquipmentCdList(Arrays.asList(equipmentCds));

    // テスト用ダイアライザマスタ
    List<MstDialyzer> dialyzerList = new ArrayList<>();
    for (int index = 1; index <= 5; index++) {
      MstDialyzer mstDialyzer = new MstDialyzer();
      mstDialyzer.setDialyzerCd(index);
      mstDialyzer.setFacilityCd(facilityCd);
      dialyzerList.add(mstDialyzer);
    }

    // Mock
    given(reportMenuDao.selectByTreatDate(patIds[0], specifyDate, null, null)).willReturn(createOrdMainList(ordNos[0], patIds[0], specifyDate));
    given(reportMenuDao.selectByTreatDate(patIds[1], specifyDate, null, null)).willReturn(Collections.emptyList());
    given(reportMenuDao.selectByTreatDate(patIds[2], specifyDate, null, null)).willReturn(createOrdMainList(ordNos[2], patIds[2], specifyDate));
    given(mstInfoService.findMstDialyzerAllByFacillityCd(facilityCd)).willReturn(dialyzerList);

    // 実行
    Map<String, Object> result = invokeCreateDistributionListDataKey(condition);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(6));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.DATE));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.ORD_NOS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.TEMPLATE_PARAMS));

    // テンプレート外：日付のチェック
    assertThat(result.get(ReportConstant.ReportDataKey.DATE), is(specifyDate));
    // テンプレート外：オーダ番号のチェック
    List<Long> resultOrdNoOutTemp = ((List<Long>)result.get(ReportConstant.ReportDataKey.ORD_NOS));
    assertThat(resultOrdNoOutTemp.size(),is(2));
    assertThat(resultOrdNoOutTemp.get(0), is(ordNos[0]));
    assertThat(resultOrdNoOutTemp.get(1), is(ordNos[2]));
    // テンプレート外：薬剤分類のチェック
    List<Integer> resultMedicineClassOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
    assertThat(resultMedicineClassOutTemp.size(), is(1));
    assertThat(resultMedicineClassOutTemp.get(0), is(0));

    // テンプレート外：医療材料分類のチェック
    List<Integer> resultEquipmentClassOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    assertThat(resultEquipmentClassOutTemp.size(),is(5));
    for (int index = 0; index < resultEquipmentClassOutTemp.size(); index++) {
      assertThat(resultEquipmentClassOutTemp.get(index), is(equipmentCds[index]));
    }
    // テンプレート外：ダイアライザのチェック
    List<Integer> resultDialyzerCdOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
    assertThat(resultDialyzerCdOutTemp.size(),is(5));
    for (int index = 0; index < resultDialyzerCdOutTemp.size(); index++) {
      assertThat(resultDialyzerCdOutTemp.get(index), is(index + 1));
    }

    // テンプレート内：件数チェック
    List<Map<String, Object>> templateParams = (List<Map<String, Object>>) result.get(ReportConstant.ReportDataKey.TEMPLATE_PARAMS);
    assertThat(templateParams.size(), is(2));
    for (int index = 0; index < templateParams.size(); index++) {
      // 各データキーの存在チェック
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.ORD_NOS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS));

      List<Integer> resultOrdNoInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.ORD_NOS));
      if (index != 1) {
        assertThat(resultOrdNoInTemp.size(), is(1));
        assertThat(resultOrdNoInTemp.get(0), is(ordNos[index]));
      }

      // テンプレート内：薬剤分類のチェック
      List<Integer> resultMedicineClassInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.MEDICINE_IDS));
      assertThat(resultMedicineClassInTemp.size(), is(1));
      assertThat(resultMedicineClassInTemp.get(0), is(0));

      // テンプレート内：医療材料分類のチェック
      List<Integer> resultEquipmentClassInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
      assertThat(resultEquipmentClassInTemp.size(),is(5));
      for (int index2 = 0; index2 < resultEquipmentClassInTemp.size(); index2++) {
        assertThat(resultEquipmentClassInTemp.get(index2), is(equipmentCds[index2]));
      }
      // テンプレート内：ダイアライザのチェック
      List<Integer> resultDialyzerCdInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.DIALYZER_IDS));
      assertThat(resultDialyzerCdInTemp.size(),is(5));
      for (int index2 = 0; index2 < resultDialyzerCdInTemp.size(); index2++) {
        assertThat(resultDialyzerCdInTemp.get(index2), is(index2 + 1));
      }
    }
  }

  /**
   * createDistributionListDataKey()の検証.
   *
   * <p>
   *   条件：医療材料分類が未指定の場合（ダイアライザ指定もなし）
   *   結果：データキー内の{@link ReportConstant.ReportDataKey#EQUIPMENT_IDS}に0が格納されたサイズ:1のリストがに含まれる事
   * </p>
   */
  @Test
  public void test_createDistributionListDataKey_正常_医療材料分類指定なし() {
    // 事前準備
    Long[] ordNos = {10L,20L,30L};
    Long[] patIds = {1001L,1002L,1003L};
    Integer[] medicineCds = {1,2,3,4};
    String specifyDate = "20200408";
    String facilityCd = "009999";

    // テスト用の帳票出力メニューからのパラメータ
    ReportMenuSortContainer condition = new ReportMenuSortContainer();
    condition.setSpecifyDate(specifyDate);
    condition.setFacilityCd(facilityCd);
    condition.setPatIds(Arrays.asList(patIds));
    condition.setMedicineCdList(Arrays.asList(medicineCds));
    condition.setEquipmentCdList(Collections.emptyList());

    // Mock
    given(reportMenuDao.selectByTreatDate(patIds[0], specifyDate, null, null)).willReturn(createOrdMainList(ordNos[0], patIds[0], specifyDate));
    given(reportMenuDao.selectByTreatDate(patIds[1], specifyDate, null, null)).willReturn(createOrdMainList(ordNos[1], patIds[1], specifyDate));
    given(reportMenuDao.selectByTreatDate(patIds[2], specifyDate, null, null)).willReturn(createOrdMainList(ordNos[2], patIds[2], specifyDate));

    // 実行
    Map<String, Object> result = invokeCreateDistributionListDataKey(condition);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(6));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.DATE));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.ORD_NOS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    assertTrue(result.containsKey(ReportConstant.ReportDataKey.TEMPLATE_PARAMS));

    // テンプレート外：日付のチェック
    assertThat(result.get(ReportConstant.ReportDataKey.DATE), is(specifyDate));
    // テンプレート外：オーダ番号のチェック
    List<Long> resultOrdNoOutTemp = ((List<Long>)result.get(ReportConstant.ReportDataKey.ORD_NOS));
    assertThat(resultOrdNoOutTemp.size(),is(3));
    for (int index = 0; index < resultOrdNoOutTemp.size(); index++) {
      assertThat(resultOrdNoOutTemp.get(index), is(ordNos[index]));
    }
    // テンプレート外：薬剤分類のチェック
    List<Integer> resultMedicineClassOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
    assertThat(resultMedicineClassOutTemp.size(),is(4));
    for (int index = 0; index < resultMedicineClassOutTemp.size(); index++) {
      assertThat(resultMedicineClassOutTemp.get(index), is(medicineCds[index]));
    }
    // テンプレート外：医療材料分類のチェック
    List<Integer> resultEquipmentClassOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    assertThat(resultEquipmentClassOutTemp.size(),is(1));
    assertThat(resultEquipmentClassOutTemp.get(0), is(0));

    // テンプレート外：ダイアライザのチェック
    List<Integer> resultDialyzerCdOutTemp = ((List<Integer>)result.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
    assertThat(resultDialyzerCdOutTemp.size(),is(1));
    assertThat(resultDialyzerCdOutTemp.get(0), is(0));

    // テンプレート内：件数チェック
    List<Map<String, Object>> templateParams = (List<Map<String, Object>>) result.get(ReportConstant.ReportDataKey.TEMPLATE_PARAMS);
    assertThat(templateParams.size(), is(3));
    for (int index = 0; index < templateParams.size(); index++) {
      // 各データキーの存在チェック
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.ORD_NOS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS));
      assertTrue(templateParams.get(index).containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS));

      List<Integer> resultOrdNoInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.ORD_NOS));
      assertThat(resultOrdNoInTemp.size(), is(1));
      assertThat(resultOrdNoInTemp.get(0), is(ordNos[index]));

      // テンプレート内：薬剤分類のチェック
      List<Integer> resultMedicineClassInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.MEDICINE_IDS));
      assertThat(resultMedicineClassInTemp.size(),is(4));
      for (int index2 = 0; index2 < resultMedicineClassInTemp.size(); index2++) {
        assertThat(resultMedicineClassInTemp.get(index2), is(medicineCds[index2]));
      }

      // テンプレート内：医療材料分類のチェック
      List<Integer> resultEquipmentClassInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
      assertThat(resultEquipmentClassInTemp.size(),is(1));
      assertThat(resultEquipmentClassInTemp.get(0), is(0));

      // テンプレート内：ダイアライザのチェック
      List<Integer> resultDialyzerCdInTemp = ((List<Integer>)templateParams.get(index).get(ReportConstant.ReportDataKey.DIALYZER_IDS));
      assertThat(resultDialyzerCdInTemp.size(),is(1));
      assertThat(resultDialyzerCdInTemp.get(0), is(0));
    }
  }

  /**
   * {@link OrdMain}のリストを作成する.
   *
   * @param ordNo オーダ番号
   * @param patId 患者番号
   * @param treatDate 治療日
   * @return {@link OrdMain}のリスト
   */
  private List<OrdMain> createOrdMainList(Long ordNo, Long patId, String treatDate) {
    OrdMain ordMain = new OrdMain();
    ordMain.setOrdNo(ordNo);
    ordMain.setPatId(patId);
    ordMain.setTreatDate(treatDate);
    return Arrays.asList(ordMain);
  }
}
