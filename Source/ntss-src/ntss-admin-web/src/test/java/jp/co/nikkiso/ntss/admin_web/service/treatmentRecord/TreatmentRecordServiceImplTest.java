package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import static java.util.Arrays.asList;
import static jp.co.nikkiso.ntss.admin_web.service.master.ReferenceComboTargetDefinition.BED;
import static jp.co.nikkiso.ntss.admin_web.service.master.ReferenceComboTargetDefinition.KUR;
import static jp.co.nikkiso.ntss.admin_web.service.master.ReferenceComboTargetDefinition.TREATMENT;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.nullValue;
import static org.hamcrest.Matchers.samePropertyValuesAs;
import static org.junit.Assert.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.never;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import tools.jackson.core.JacksonException;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordAddition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordCondition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordEquipInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMediInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResult;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordVitalMonitor;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordWeight;
import org.junit.Ignore;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.test.context.junit4.SpringRunner;

import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.Multimap;
import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.RecirculationRate;
import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.TreatmentRecordSummary;
import jp.co.nikkiso.ntss.admin_web.service.master.ReferenceComboService;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceCombo;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboTargetTable;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.exception.RequiredException;



@RunWith(SpringRunner.class)
@SpringBootTest
public class TreatmentRecordServiceImplTest {
  /**
   * テスト対象クラス
   */
  @Autowired
  private TreatmentRecordService target;

  /**
   * 参照型コンボのServiceのMockBean.
   */
  @MockitoBean
  private ReferenceComboService referenceComboService;

  /**
   * 治療情報のMockBean.
   */
  @MockitoBean
  private TreatmentRecordDao treatmentRecordDao;

  /**
   * オーダメインのMockBean.
   */
  @MockitoBean
  private OrdMainDao ordMainDao;

  /**
   * 装置マスタのMockBean.
   */
  @MockitoBean
  private MstMachineDao mstMachineDao;

  /**
   * 装置モニタデータのMockBean
   */
  @MockitoBean
  private MniMonitorDao mniMonitorDao;

  /**
   * 例外の発生をテストするためのルール
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * getOrdMain(privateメソッド)をinvokeする.
   *
   * @param ordNo オーダ番号
   * @return 治療記録エンティティ
   * @throws Throwable
   */
  private OrdMain invokeGetOrdMain(Long ordNo) throws Throwable {
    try {
      Method method = TreatmentRecordServiceImpl.class.getDeclaredMethod("getOrdMain", Long.class);
      method.setAccessible(true);
      return (OrdMain) method.invoke(target, ordNo);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      e.printStackTrace();
    }
    return null;
  }

  /**
   * getOrdMain()の検証.
   *
   * 条件：指定されたオーダ番号に該当する治療情報が存在する
   * 結果：治療記録エンティティが返却されること
   */
  @Test
  public void test_getOrdMain_成功_データあり() throws Throwable {
    // 事前準備
    Long ordNo = 10L;
    OrdMain expected = new OrdMain();

    // Mock化
    given(treatmentRecordDao.selectByOrdNoForSummary(ordNo)).willReturn(expected);

    // 実行
    OrdMain result = invokeGetOrdMain(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectByOrdNoForSummary(ordNo);
    assertThat(result, is(expected));
  }

  /**
   * getOrdMain()の検証.
   *
   * 条件：指定されたオーダ番号に該当する治療情報が存在しない
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getOrdMain_異常_データなし() throws Throwable {
    // 事前準備
    Long ordNo = 12L;

    // Mock化
    given(treatmentRecordDao.selectByOrdNoForSummary(ordNo)).willThrow(EmptyResultDataAccessException.class);

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("");
    invokeGetOrdMain(ordNo);
  }

  /**
   * formatTreatmentDate(privateメソッド)をinvokeする.
   *
   * @param treatDate 治療日
   * @return
   * @throws Throwable
   */
  private String invokeFormatTreatmentDate(String treatDate) throws Throwable {
    try {
      Method method = TreatmentRecordServiceImpl.class.getDeclaredMethod("formatTreatmentDate", String.class);
      method.setAccessible(true);
      return (String) method.invoke(target, treatDate);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      e.printStackTrace();
    }
    return null;
  }

  /**
   * formatTreatmentDate()の検証.
   *
   * 条件：有効な治療日が指定されること
   * 結果：指定された治療日が正しくフォーマットされること
   */
  @Test
  public void test_formatTreatmentDate_正常_有効日付指定() throws Throwable {
    // 事前準備
    String treatDate = "20190411";
    String expected = "2019/04/11";

    // 実行
    String result = invokeFormatTreatmentDate(treatDate);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatTreatmentDate()の検証.
   *
   * 条件：存在しない日付が指定されること
   * 結果：指定された日付がフォーマットされずにそのまま返却されること
   */
  @Test
  public void test_formatTreatmentDate_正常_無効日付指定() throws Throwable {
    // 事前準備
    String treatDate = "20190431";
    String expected = "20190431";

    // 実行
    String result = invokeFormatTreatmentDate(treatDate);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatTreatmentDate()の検証.
   *
   * 条件：無効な日付(アルファベットなど)が指定されること
   * 結果：指定された日付がフォーマットされずにそのまま返却されること
   */
  @Test
  public void test_formatTreatmentDate_正常_日付形式ではない文字列指定() throws Throwable {
    // 事前準備
    String treatDate = "abcdef";
    String expected = "abcdef";

    // 実行
    String result = invokeFormatTreatmentDate(treatDate);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatTreatmentDate()の検証.
   *
   * 条件：日付が未設定(空文字)
   * 結果：「透析日未定」が返却されること
   */
  @Test
  public void test_formatTreatmentDate_正常_空文字指定() throws Throwable {
    // 事前準備
    String treatDate = "";
    String expected = "透析日未定";

    // 実行
    String result = invokeFormatTreatmentDate(treatDate);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatTreatmentDate()の検証.
   *
   * 条件：日付が未設定(null)
   * 結果：「透析日未定」が返却されること
   */
  @Test
  public void test_formatTreatmentDate_正常_null指定() throws Throwable {
    // 事前準備
    String treatDate = null;
    String expected = "透析日未定";

    // 実行
    String result = invokeFormatTreatmentDate(treatDate);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatTreatmentWeek(privateメソッド)をinvokeする.
   *
   * @param treatWeek 治療曜日
   * @return
   * @throws Throwable
   */
  private String invokeFormatTreatmentWeek(Short treatWeek) throws Throwable {
    try {
      Method method = TreatmentRecordServiceImpl.class.getDeclaredMethod("formatTreatmentWeek", Short.class);
      method.setAccessible(true);
      return (String) method.invoke(target, treatWeek);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      e.printStackTrace();
    }
    return null;
  }

  /**
   * formatTreatmentWeek()の検証.
   *
   * 条件：有効範囲の値が指定されること
   * 結果：指定された治療曜日が正しくフォーマットされること
   */
  @Test
  public void test_formatTreatmentWeek_正常_有効範囲の値() throws Throwable {
    // 事前準備
    Map<Short, String> params = new HashMap() {
      {
        put((short)1, "(月)");
        put((short)2, "(火)");
        put((short)3, "(水)");
        put((short)4, "(木)");
        put((short)5, "(金)");
        put((short)6, "(土)");
        put((short)7, "(日)");
      }
    };

    executeFormatTreatmentWeek(params);
  }

  /**
   * formatTreatmentWeek()の検証.
   *
   * 条件：有効範囲外の値が指定されること
   * 結果：指定された治療曜日コード値が括弧付きとなって返却されること
   */
  @Test
  public void test_formatTreatmentWeek_正常_有効範囲外の値() throws Throwable {
    // 事前準備
    Map<Short, String> params = new HashMap() {
      {
        put((short)0, "(0)");
        put((short)8, "(8)");
      }
    };

    executeFormatTreatmentWeek(params);
  }

  /**
   * formatTreatmentWeek()の検証.
   *
   * 条件：null指定されること
   * 結果：空文字が返却されること
   */
  @Test
  public void test_formatTreatmentWeek_正常_null値() throws Throwable {
    // 事前準備
    Short treatWeek = null;
    String expected = "";

    String result = invokeFormatTreatmentWeek(treatWeek);

    // 検証
    assertThat(result, is(expected));

  }

  /**
   * formatTreatmentWeek()の検証実行を行う.
   * @param params パラメータと期待値が格納されたMap
   */
  private void executeFormatTreatmentWeek(Map<Short, String> params) {
    params.forEach((k, v) -> {
      // 実行
      String result = null;
      try {
        result = invokeFormatTreatmentWeek(k);
      } catch (Throwable throwable) {
        fail();
      }

      // 検証
      assertThat(result, is(v));
    });
  }

  /**
   * formatPastResultMasterName(privateメソッド)をinvokeする.
   *
   * @param cd コード
   * @param name 名称
   * @return
   * @throws Throwable
   */
  private String invokeFormatPastResultMasterName(Integer cd, String name) throws Throwable {
    try {
      Method method = TreatmentRecordServiceImpl.class.getDeclaredMethod("formatPastResultMasterName", Integer.class, String.class);
      method.setAccessible(true);
      return (String) method.invoke(target, cd, name);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      e.printStackTrace();
    }
    return null;
  }

  /**
   * formatPastResultMasterName()の検証.
   *
   * 条件：マスタ名称に値が設定されている
   * 結果：マスタ名称が返されること
   */
  @Test
  public void test_formatPastResultMasterName_正常_nameに設定あり() throws Throwable {
    // 事前準備
    Integer cd = 1;
    String name = "マスタ名称";
    String expected = "マスタ名称";

    // 実行
    String result = invokeFormatPastResultMasterName(cd, name);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatPastResultMasterName()の検証.
   *
   * 条件：マスタ名称・コードともに値が設定されていない
   * 結果：「未登録」が返されること
   */
  @Test
  public void test_formatPastResultMasterName_正常_nameとcdに設定なし() throws Throwable {
    // 事前準備
    Multimap<Integer, String> params = ArrayListMultimap.create();
    params.put(null, null);
    params.put(0, null);
    params.put(null, "");
    params.put(0, "");

    executePastResultMasterName(params, "未登録");
  }

  /**
   * formatPastResultMasterName()の検証.
   *
   * 条件：マスタ名称の値が設定されていない、かつ コードが設定されている
   * 結果：空文字が返されること
   */
  @Test
  public void test_formatPastResultMasterName_正常_nameが設定なしかつcdが設定あり() throws Throwable {
    // 事前準備
    Multimap<Integer, String> params = ArrayListMultimap.create();
    params.put(1, null);
    params.put(1, "");

    executePastResultMasterName(params, "");
  }

  /**
   * formatPastResultMasterName()の検証実行を行う.
   *
   * @param params パラメータが格納されたMap
   * @param expected 期待値
   */
  private void executePastResultMasterName(Multimap<Integer, String> params, String expected) {
    for (Map.Entry<Integer, String> entry : params.entries()) {
      // 実行
      String result = null;

      try {
        result = invokeFormatPastResultMasterName(entry.getKey(), entry.getValue());
      } catch (Throwable e) {
        fail();
      }

      // 検証
      assertThat(result, is(expected));
    }
  }

  /**
   * formatNotPastResultMasterName(privateメソッド)をinvokeする.
   *
   * @param facilityCd 施設コード
   * @param referenceComboTargetTable マスタを定義するクラス
   * @param cd コード
   * @param name 名称
   * @return
   * @throws Throwable
   */
  private String invokeFormatNotPastResultMasterName(String facilityCd, ReferenceComboTargetTable referenceComboTargetTable, Integer cd, String name) throws Throwable {
    try {
      Method method = TreatmentRecordServiceImpl.class.getDeclaredMethod("formatNotPastResultMasterName", String.class, ReferenceComboTargetTable.class, Integer.class, String.class);
      method.setAccessible(true);
      return (String) method.invoke(target, facilityCd, referenceComboTargetTable, cd, name);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      e.printStackTrace();
    }
    return null;
  }

  /**
   * formatNotPastResultMasterName()の検証.
   *
   * 条件：mst_selectorにマスタ名が設定されている
   * 結果：mst_selectorのマスタ名称が返されること
   */
  @Test
  public void test_formatNotPastResultMasterName_正常_mst_selectorにマスタ名あり() throws Throwable {
    // 事前準備
    String facilityCd = "009999";
    ReferenceComboTargetTable referenceComboTargetTable = new ReferenceComboTargetTable();
    Integer cd = 1;
    String name = "マスタ名称（仮）";
    String expected = "マスタ名称";

    final ArgumentCaptor<String> facilityCdCaptor = ArgumentCaptor.forClass(String.class);
    final ArgumentCaptor<ReferenceComboTargetTable> targetTableArgsCaptor = ArgumentCaptor.forClass(ReferenceComboTargetTable.class);
    given(referenceComboService.build(facilityCdCaptor.capture(), targetTableArgsCaptor.capture())).willReturn(
      asList(new ReferenceCombo(1, "マスタ名称", 1L))
    );

    // 実行
    String result = invokeFormatNotPastResultMasterName(facilityCd, referenceComboTargetTable, cd, name);

    // 検証
    verify(referenceComboService, times(1)).build(facilityCd, referenceComboTargetTable);
    assertThat(result, is(expected));
  }

  /**
   * formatNotPastResultMasterName()の検証.
   *
   * 条件：該当のmst_selectorレコードは存在するが、マスタ名を表すjson keyがないこと
   * 結果：「」（空文字）が返されること
   */
  @Test
  public void test_formatNotPastResultMasterName_正常_mst_selectorレコードありかつマスタ名Keyなし() throws Throwable {
    // 事前準備
    String facilityCd = "009999";
    ReferenceComboTargetTable referenceComboTargetTable = new ReferenceComboTargetTable();
    Integer cd = 1;
    String name = "マスタ名称（仮）";
    String expected = "";

    final ArgumentCaptor<String> facilityCdCaptor = ArgumentCaptor.forClass(String.class);
    final ArgumentCaptor<ReferenceComboTargetTable> targetTableArgsCaptor = ArgumentCaptor.forClass(ReferenceComboTargetTable.class);
    given(referenceComboService.build(facilityCdCaptor.capture(), targetTableArgsCaptor.capture())).willReturn(
      asList(new ReferenceCombo(1, null, 1L))
    );

    // 実行
    String result = invokeFormatNotPastResultMasterName(facilityCd, referenceComboTargetTable, cd, name);

    // 検証
    verify(referenceComboService, times(1)).build(facilityCd, referenceComboTargetTable);
    assertThat(result, is(expected));
  }

  /**
   * formatNotPastResultMasterName()の検証.
   *
   * 条件：該当のmst_selectorレコード配列に指定されたcdに該当するレコードがないかつord_mainのマスタ名が設定されていること
   * 結果：「"【削除】" + ord_mainのマスタ名」が返されること
   */
  @Test
  public void test_formatNotPastResultMasterName_正常_mst_selectorの中にcdと該当するレコードなしかつord_mainのマスタ名設定あり() throws Throwable {
    // 事前準備
    String facilityCd = "009999";
    ReferenceComboTargetTable referenceComboTargetTable = new ReferenceComboTargetTable();
    Integer cd = 1;
    String name = "マスタ名称（仮）";
    String expected = "【削除】マスタ名称（仮）";

    final ArgumentCaptor<String> facilityCdCaptor = ArgumentCaptor.forClass(String.class);
    final ArgumentCaptor<ReferenceComboTargetTable> targetTableArgsCaptor = ArgumentCaptor.forClass(ReferenceComboTargetTable.class);
    given(referenceComboService.build(facilityCdCaptor.capture(), targetTableArgsCaptor.capture())).willReturn(
      asList(new ReferenceCombo(2, "マスタ名称", 2L))
    );

    // 実行
    String result = invokeFormatNotPastResultMasterName(facilityCd, referenceComboTargetTable, cd, name);

    // 検証
    verify(referenceComboService, times(1)).build(facilityCd, referenceComboTargetTable);
    assertThat(result, is(expected));
  }


  /**
   * formatNotPastResultMasterName()の検証.
   *
   * 条件：該当のmst_selectorレコード配列がないかつord_mainのマスタ名が設定されていること
   * 結果：「"【削除】" + ord_mainのマスタ名」が返されること
   */
  @Test
  public void test_formatNotPastResultMasterName_正常_mst_selector配列なしかつord_mainのマスタ名設定あり() throws Throwable {
    // 事前準備
    String facilityCd = "009999";
    ReferenceComboTargetTable referenceComboTargetTable = new ReferenceComboTargetTable();
    Integer cd = 1;
    String name = "マスタ名称（仮）";
    String expected = "【削除】マスタ名称（仮）";

    final ArgumentCaptor<String> facilityCdCaptor = ArgumentCaptor.forClass(String.class);
    final ArgumentCaptor<ReferenceComboTargetTable> targetTableArgsCaptor = ArgumentCaptor.forClass(ReferenceComboTargetTable.class);
    given(referenceComboService.build(facilityCdCaptor.capture(), targetTableArgsCaptor.capture())).willReturn(
      Collections.emptyList()
    );

    // 実行
    String result = invokeFormatNotPastResultMasterName(facilityCd, referenceComboTargetTable, cd, name);

    // 検証
    verify(referenceComboService, times(1)).build(facilityCd, referenceComboTargetTable);
    assertThat(result, is(expected));
  }

  /**
   * formatNotPastResultMasterName()の検証.
   *
   * 条件：該当のmst_selectorレコード配列に指定されたcdに該当するレコードがないかつord_mainのマスタ名が設定されていないこと
   * 結果：コード値が返されること
   */
  @Test
  public void test_formatNotPastResultMasterName_正常_mst_selectorの中にcdと該当するレコードなしかつord_mainのマスタ名設定なし() throws Throwable {
    // 事前準備
    String facilityCd = "009999";
    ReferenceComboTargetTable referenceComboTargetTable = new ReferenceComboTargetTable();
    Integer cd = 1;
    String[] names = {"", null};
    String expected = "1";

    final ArgumentCaptor<String> facilityCdCaptor = ArgumentCaptor.forClass(String.class);
    final ArgumentCaptor<ReferenceComboTargetTable> targetTableArgsCaptor = ArgumentCaptor.forClass(ReferenceComboTargetTable.class);
    given(referenceComboService.build(facilityCdCaptor.capture(), targetTableArgsCaptor.capture())).willReturn(
      asList(new ReferenceCombo(2, "マスタ名称", 2L))
    );

    int count = 0;
    for (String name: names) {

      // 実行
      String result = invokeFormatNotPastResultMasterName(facilityCd, referenceComboTargetTable, cd, name);

      // 検証
      verify(referenceComboService, times(++count)).build(facilityCd, referenceComboTargetTable);
      assertThat(result, is(expected));
    }
  }

  /**
   * formatNotPastResultMasterName()の検証.
   *
   * 条件：ord_mainのコード値が設定されていない
   * 結果：「未登録」が返されること
   */
  @Test
  public void test_formatNotPastResultMasterName_正常_ord_mainのコード値が設定されていない() throws Throwable {
    // 事前準備
    String facilityCd = "009999";
    ReferenceComboTargetTable referenceComboTargetTable = new ReferenceComboTargetTable();
    Integer[] cds = {0, null};
    String name = "コード名称";
    String expected = "未登録";

    final ArgumentCaptor<String> facilityCdCaptor = ArgumentCaptor.forClass(String.class);
    final ArgumentCaptor<ReferenceComboTargetTable> targetTableArgsCaptor = ArgumentCaptor.forClass(ReferenceComboTargetTable.class);
    given(referenceComboService.build(facilityCdCaptor.capture(), targetTableArgsCaptor.capture())).willReturn(
      asList(new ReferenceCombo(2, "マスタ名称", 2L))
    );

    for (Integer cd: cds) {
      // 実行
      String result = invokeFormatNotPastResultMasterName(facilityCd, referenceComboTargetTable, cd, name);

      // 検証
      verify(referenceComboService, never()).build(facilityCd, referenceComboTargetTable);
      assertThat(result, is(expected));
    }
  }

  /**
   * getTreatmentRecordSummary()の検証.
   *
   * 条件：「ord_main」の「実績：治療状況（rst_dialysis_state）」が「6:後体重確認済み」である。
   * 結果：responseを返す
   */
  @Test
  public void test_getTreatmentRecordSummary_正常_過去実績の確認() {
    // 事前準備
    Long ordNo = 10L;
    OrdMain ordMain = new OrdMain(){
      {
        setTreatDate("20190412");
        setTreatWeek(Short.valueOf("5"));
        setRstBedCd(1L);
        setRstBedName("ベッド１");
        setRstKurCd(2);
        setRstKurName("クール１");
        setRstTreatmentCd(3);
        setRstTreatmentName("治療方法１");
        setRstDialysisState("6");
      }
    };
    TreatmentRecordSummary expected = new TreatmentRecordSummary("2019/04/12(金)", "ベッド１", "クール１", "治療方法１");

    // Mock化
    given(treatmentRecordDao.selectByOrdNoForSummary(ordNo)).willReturn(ordMain);


    // 実行
    TreatmentRecordSummary result = target.getTreatmentRecordSummary(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectByOrdNoForSummary(ordNo);
    assertThat(result, is(samePropertyValuesAs(expected)));
  }

  /**
   * getTreatmentRecordSummary()の検証.
   *
   * 条件：「ord_main」の「実績：治療状況（rst_dialysis_state）」が「6:後体重確認済み」以外である。
   *       治療日が空の場合
   * 結果：responseを返す
   */
  @Test
  public void test_getTreatmentRecordSummary_正常_過去実績以外かつ治療日が空の確認() {
    // 事前準備
    Long ordNo1 = 10L;
    Long ordNo2 = 11L;
    String facilityCd = "009999";
    OrdMain ordMain1 = new OrdMain() {
      {
        setFacilityCd(facilityCd);
        setTreatDate("");
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
    OrdMain ordMain2 = new OrdMain() {
      {
        setFacilityCd(facilityCd);
        setTreatDate(null);
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

    TreatmentRecordSummary expected = new TreatmentRecordSummary("透析日未定", "【削除】ベッド１", "【削除】クール１", "【削除】治療方法１");

    // Mock化
    given(treatmentRecordDao.selectByOrdNoForSummary(ordNo1)).willReturn(ordMain1);
    given(treatmentRecordDao.selectByOrdNoForSummary(ordNo2)).willReturn(ordMain2);
    given(referenceComboService.build(anyString(), any())).willReturn(
      Collections.emptyList()
    );

    // 実行(治療日が空の場合)
    TreatmentRecordSummary result1 = target.getTreatmentRecordSummary(ordNo1);

    // 検証
    verify(treatmentRecordDao, times(1)).selectByOrdNoForSummary(ordNo1);
    verify(referenceComboService, times(3)).build(anyString(), any());
    assertThat(result1, is(samePropertyValuesAs(expected)));

    // 実行(治療日がnullの場合)
    TreatmentRecordSummary result2 = target.getTreatmentRecordSummary(ordNo2);

    // 検証
    verify(treatmentRecordDao, times(1)).selectByOrdNoForSummary(ordNo2);
    verify(referenceComboService, times(6)).build(anyString(), any());
    assertThat(result2, is(samePropertyValuesAs(expected)));
  }

  /**
   * getTreatmentRecordSummary()の検証.
   *
   * 条件：「ord_main」の「実績：治療状況（rst_dialysis_state）」が「6:後体重確認済み」以外である。
   * 結果：responseを返す
   */
  @SuppressWarnings("unchecked")
  @Test
  public void test_getTreatmentRecordSummary_正常_過去実績以外かつmst_selectorのマスタ名の確認() {
    // 事前準備
    Long ordNo = 10L;
    String facilityCd = "009999";
    OrdMain ordMain = new OrdMain() {
      {
        setFacilityCd(facilityCd);
        setTreatDate("");
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

    ReferenceComboTargetTable bed = BED.getValue();
    ReferenceComboTargetTable kur = KUR.getValue();
    ReferenceComboTargetTable treatment = TREATMENT.getValue();

    TreatmentRecordSummary expected = new TreatmentRecordSummary("透析日未定", "ベッドマスタ１", "クールマスタ１", "治療方法マスタ１");

    final ArgumentCaptor<ReferenceComboTargetTable> masterCaptor = ArgumentCaptor.forClass(ReferenceComboTargetTable.class);
    final ArgumentCaptor<String> facilityCdCaptor = ArgumentCaptor.forClass(String.class);

    // Mock化
    given(treatmentRecordDao.selectByOrdNoForSummary(ordNo)).willReturn(ordMain);
    given(referenceComboService.build(facilityCdCaptor.capture(), masterCaptor.capture())).willReturn(
      asList(new ReferenceCombo(1, "ベッドマスタ１", 1L)),
      asList(new ReferenceCombo(2, "クールマスタ１", 2L)),
      asList(new ReferenceCombo(3, "治療方法マスタ１", 3L))
    );

    // 実行
    TreatmentRecordSummary result = target.getTreatmentRecordSummary(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectByOrdNoForSummary(ordNo);
    verify(referenceComboService, times(3)).build(anyString(), any());

    assertThat(facilityCdCaptor.getAllValues().get(0), is(facilityCd));
    assertThat(facilityCdCaptor.getAllValues().get(1), is(facilityCd));
    assertThat(facilityCdCaptor.getAllValues().get(2), is(facilityCd));
    assertThat(masterCaptor.getAllValues().get(0), is(samePropertyValuesAs(bed)));
    assertThat(masterCaptor.getAllValues().get(1), is(samePropertyValuesAs(kur)));
    assertThat(masterCaptor.getAllValues().get(2), is(samePropertyValuesAs(treatment)));

    assertThat(result, is(samePropertyValuesAs(expected)));
  }

  /**
   * getTreatmentRecordResult()の検証.
   *
   * 条件：指定されたオーダ番号に該当する治療情報が存在する
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getTreatmentRecordResult_正常_取得() {
    // 事前準備
    Long ordNo = 10L;
    TreatmentRecordResult expected = getResultDummyData();

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordResultByOrdNo(ordNo)).willReturn(expected);

    // 実行
    TreatmentRecordResult result = target.getTreatmentRecordResult(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordResultByOrdNo(ordNo);
    assertThat(result, is(expected));

  }

  /**
   * getTreatmentRecordResult()の検証.
   *
   * 条件：指定されたオーダ番号に該当する治療情報が存在しない
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getTreatmentRecordResult_異常_該当データなし() throws Exception {
    // 事前準備
    Long ordNo = 12L;

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordResultByOrdNo(ordNo)).willThrow(EmptyResultDataAccessException.class);

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("");
    target.getTreatmentRecordResult(ordNo);

  }

  /**
   * updateTreatmentRecordResult()の検証.
   *
   * 条件：治療記録マスタに存在するOrdNoをもつレコードを指定する
   * 結果：実績情報の更新ができること
   */
  @Test
  public void test_updateTreatmentRecordResult_成功_実績情報の更新ができること() {
    // arrange
    final Long ordNo = 10L;
    final TreatmentRecordResult beUpdatedTreatmentRecordResult = getResultDummyData();
    beUpdatedTreatmentRecordResult.setRstBedCd(300L);
    beUpdatedTreatmentRecordResult.setRstBedName("Other Bed");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordResult> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordResult.class);
    given(treatmentRecordDao.updateTreatmentRecordForResult(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // action
    target.updateTreatmentRecordResult(ordNo, beUpdatedTreatmentRecordResult);

    // assert
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(10L));
    final TreatmentRecordResult updatedTreatmentRecordResult = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordResult, is(beUpdatedTreatmentRecordResult));
  }

  /**
   * updateTreatmentRecordResult()の検証.
   *
   * 条件：治療記録マスタに存在しないOrdNoをもつレコードを指定する
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_updateTreatmentRecordResult_失敗_コードに一致する治療記録がない場合は例外が発生すること() {
    // arrange
    final Long ordNo = 10L;
    final TreatmentRecordResult beUpdatedTreatmentRecordResult = getResultDummyData();
    beUpdatedTreatmentRecordResult.setRstBedCd(300L);
    beUpdatedTreatmentRecordResult.setRstBedName("Other Bed");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordResult> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordResult.class);
    given(treatmentRecordDao.updateTreatmentRecordForResult(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(0);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.updateTreatmentRecordResult(ordNo, beUpdatedTreatmentRecordResult);
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(10L));
    final TreatmentRecordResult updatedTreatmentRecordResult = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordResult, is(beUpdatedTreatmentRecordResult));
  }

  /**
   * getTreatmentRecordMediInfo()の検証.
   *
   * 条件：治療記録マスタに存在するOrdNoをもつレコードを指定する
   * 結果：投与薬剤情報を取得できること
   */
  @Test
  public void test_getTreatmentRecordMediInfo_成功() {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordMediInfo mediInfo = new TreatmentRecordMediInfo();
    mediInfo.setOrdNo(ordNo);
    mediInfo.setTreatDate("20190201");
    mediInfo.setRstDialysisState("0");
    mediInfo.setRstStartDate(Timestamp.valueOf("2019-03-01 12:00:00.000"));
    mediInfo.setRstMediInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    given(treatmentRecordDao.selectTreatmentRecordMediInfoByOrdNo(any())).willReturn(mediInfo);

    // action
    TreatmentRecordMediInfo result = target.getTreatmentRecordMediInfo(ordNo);

    // assert
    assertThat(result.getOrdNo(), is(ordNo));
    assertThat(result.getTreatDate(), is("20190201"));
    assertThat(result.getRstDialysisState(), is("0"));
    assertThat(result.getRstStartDate(), is(Timestamp.valueOf("2019-03-01 12:00:00.000")));
    assertThat(result.getRstMediInfo(), is("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]"));

    verify(treatmentRecordDao, times(1)).selectTreatmentRecordMediInfoByOrdNo(ordNo);
  }

  /**
   * getTreatmentRecordMediInfo()の検証.
   *
   * 条件：治療記録マスタに存在しないOrdNoを指定する
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getTreatmentRecordMediInfo_失敗() {
    // arrange
    final Long ordNo = 1L;
    given(treatmentRecordDao.selectTreatmentRecordMediInfoByOrdNo(any())).willThrow(EmptyResultDataAccessException.class);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.getTreatmentRecordMediInfo(ordNo);

    verify(treatmentRecordDao, times(1)).selectTreatmentRecordMediInfoByOrdNo(ordNo);
  }

  /**
   * updateTreatmentRecordMediInfo()の検証.
   *
   * 条件：治療情報に存在するOrdNoをもつレコードを指定する
   * 結果：投与薬剤情報の更新ができること
   */
  @Test
  public void test_updateTreatmentRecordMediInfo_成功_投与薬剤情報の更新ができること() {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordMediInfo beforeUpdateTreatmentRecordMediInfo = new TreatmentRecordMediInfo();
    beforeUpdateTreatmentRecordMediInfo.setOrdNo(ordNo);
    beforeUpdateTreatmentRecordMediInfo.setTreatDate("20190201");
    beforeUpdateTreatmentRecordMediInfo.setRstDialysisState("0");
    beforeUpdateTreatmentRecordMediInfo.setRstStartDate(Timestamp.valueOf("2019-03-01 12:00:00.000"));
    beforeUpdateTreatmentRecordMediInfo.setRstMediInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordMediInfo> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordMediInfo.class);
    given(treatmentRecordDao.updateTreatmentRecordForMediInfo(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // action
    target.updateTreatmentRecordMediInfo(ordNo, beforeUpdateTreatmentRecordMediInfo);

    // assert
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(1L));
    final TreatmentRecordMediInfo updatedTreatmentRecordMediInfo = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordMediInfo, is(beforeUpdateTreatmentRecordMediInfo));
  }

  /**
   * updateTreatmentRecordMediInfo()の検証.
   *
   * 条件：治療情報に存在しないOrdNoをもつレコードを指定する
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_updateTreatmentRecordMediInfo_失敗_コードに一致する治療情報がない場合は例外が発生すること() {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordMediInfo beforeUpdateTreatmentRecordMediInfo = new TreatmentRecordMediInfo();
    beforeUpdateTreatmentRecordMediInfo.setOrdNo(ordNo);
    beforeUpdateTreatmentRecordMediInfo.setTreatDate("20190201");
    beforeUpdateTreatmentRecordMediInfo.setRstDialysisState("0");
    beforeUpdateTreatmentRecordMediInfo.setRstStartDate(Timestamp.valueOf("2019-03-01 12:00:00.000"));
    beforeUpdateTreatmentRecordMediInfo.setRstMediInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordMediInfo> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordMediInfo.class);
    given(treatmentRecordDao.updateTreatmentRecordForMediInfo(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(0);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.updateTreatmentRecordMediInfo(ordNo, beforeUpdateTreatmentRecordMediInfo);
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(10L));
    final TreatmentRecordMediInfo updatedTreatmentRecordMediInfo = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordMediInfo, is(beforeUpdateTreatmentRecordMediInfo));
  }

  /**
   * getTreatmentRecordCondition()の検証.
   *
   * 条件：指定されたオーダ番号に該当する治療情報が存在する
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getTreatmentRecordCondition_正常_取得() {
    // 事前準備
    Long ordNo = 10L;
    TreatmentRecordCondition expected = getConditionDummyData();

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo)).willReturn(expected);

    // 実行
    TreatmentRecordCondition result = target.getTreatmentRecordCondition(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordConditionByOrdNo(ordNo);
    assertThat(result, is(expected));

  }

  /**
   * getTreatmentRecordCondition()の検証.
   *
   * 条件：指定されたオーダ番号に該当する治療情報が存在しない
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getTreatmentRecordCondition_異常_該当データなし() throws Exception {
    // 事前準備
    Long ordNo = 12L;

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo)).willThrow(EmptyResultDataAccessException.class);

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("");
    target.getTreatmentRecordCondition(ordNo);

  }

  /**
   * updateTreatmentRecordCondition()の検証.
   *
   * 条件：治療記録マスタに存在するOrdNoをもつレコードを指定する
   * 結果：治療条件の更新ができること
   */
  @Test
  public void test_updateTreatmentRecordCondition_成功_治療条件の更新ができること() {
    // arrange
    final Long ordNo = 10L;
    final TreatmentRecordCondition beUpdatedTreatmentRecordCondition = getConditionDummyData();

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordCondition> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordCondition.class);
    given(treatmentRecordDao.updateTreatmentRecordForCondition(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // action
    target.updateTreatmentRecordCondition(ordNo, beUpdatedTreatmentRecordCondition);

    // assert
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(10L));
    final TreatmentRecordCondition updatedTreatmentRecordCondition = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordCondition, is(beUpdatedTreatmentRecordCondition));
  }

  /**
   * updateTreatmentRecordCondition()の検証.
   *
   * 条件：治療記録マスタに存在しないOrdNoをもつレコードを指定する
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_updateTreatmentRecordCondition_失敗_コードに一致する治療記録がない場合は例外が発生すること() {
    // arrange
    final Long ordNo = 10L;
    final TreatmentRecordCondition beUpdatedTreatmentRecordCondition = getConditionDummyData();

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordCondition> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordCondition.class);
    given(treatmentRecordDao.updateTreatmentRecordForCondition(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(0);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.updateTreatmentRecordCondition(ordNo, beUpdatedTreatmentRecordCondition);
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(10L));
    final TreatmentRecordCondition updatedTreatmentRecordCondition = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordCondition, is(beUpdatedTreatmentRecordCondition));
  }

  /**
   * getTreatmentRecordWeight()の検証.
   *
   * 条件：指定されたオーダ番号に該当する治療情報が存在する
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getTreatmentRecordWeight_正常_取得() {
    // 事前準備
    Long ordNo = 10L;
    TreatmentRecordWeight expected = getWeightDummyData();

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordWeightByOrdNo(ordNo)).willReturn(expected);

    // 実行
    TreatmentRecordWeight result = target.getTreatmentRecordWeight(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordWeightByOrdNo(ordNo);
    assertThat(result, is(expected));

  }

  /**
   * getTreatmentRecordWeight()の検証.
   *
   * 条件：指定されたオーダ番号に該当する治療情報が存在しない
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getTreatmentRecordWeight_異常_該当データなし() throws Exception {
    // 事前準備
    Long ordNo = 12L;

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordWeightByOrdNo(ordNo)).willThrow(EmptyResultDataAccessException.class);

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("");
    target.getTreatmentRecordWeight(ordNo);

  }

  /**
   * updateTreatmentRecordWeight()の検証.
   *
   * 条件：治療記録マスタに存在するOrdNoをもつレコードを指定する
   * 結果：体重情報の更新ができること
   */
  @Test
  public void test_updateTreatmentRecordWeight_成功_体重情報の更新ができること() throws JacksonException {
    // arrange
    final Long ordNo = 10L;
    final TreatmentRecordWeight beUpdatedTreatmentRecordWeight = getWeightDummyData();
    beUpdatedTreatmentRecordWeight.setRstWeightInfo("{\"weight_after_date\": \"2019-03-20T15:30:00+09:00\", \"weight_before_date\": \"2019-03-20T12:00:00+09:00\"}");
    beUpdatedTreatmentRecordWeight.setRstTareInfo("OtherRstTareInfo");
    beUpdatedTreatmentRecordWeight.setRstOffWaterInfo("OtherRstOffWaterInfo");
    beUpdatedTreatmentRecordWeight.setRstDw(BigDecimal.valueOf(12.34));

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordWeight> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordWeight.class);
    given(treatmentRecordDao.updateTreatmentRecordForWeight(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // action
    target.updateTreatmentRecordWeight(ordNo, beUpdatedTreatmentRecordWeight);

    // assert
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(10L));
    final TreatmentRecordWeight updatedTreatmentRecordWeight = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordWeight, is(beUpdatedTreatmentRecordWeight));
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   *
   * 条件：治療記録マスタに存在しないOrdNoをもつレコードを指定する
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_updateTreatmentRecordWeight_失敗_コードに一致する治療記録がない場合は例外が発生すること() throws JacksonException {
    // arrange
    final Long ordNo = 12L;
    final TreatmentRecordWeight beUpdatedTreatmentRecordWeight = getWeightDummyData();
    beUpdatedTreatmentRecordWeight.setRstWeightInfo("{\"weight_after_date\": \"2019-03-20T15:30:00+09:00\", \"weight_before_date\": \"2019-03-20T12:00:00+09:00\",  \"re_loop_rate_1\": {\"date\": \"2019-03-20T09:00:00+09:00\", \"value\": 50}}");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordWeight> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordWeight.class);
    given(treatmentRecordDao.updateTreatmentRecordForWeight(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(0);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.updateTreatmentRecordWeight(ordNo, beUpdatedTreatmentRecordWeight);
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(12L));
    final TreatmentRecordWeight updatedTreatmentRecordWeight = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordWeight, is(beUpdatedTreatmentRecordWeight));
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   *
   * 条件：必須項目weight_before_dateを設定していないEntityを指定する
   * 結果：RequiredExceptionがThrowされること
   */
  @Test
  @Ignore
  public void test_updateTreatmentRecordWeight_失敗_必須項目weight_before_dateが設定されていない場合例外が発生すること() throws JacksonException {
    // arrange
    final Long ordNo = 13L;
    final TreatmentRecordWeight beUpdatedTreatmentRecordWeight = getWeightDummyData();
    beUpdatedTreatmentRecordWeight.setRstWeightInfo("{\"weight_after_date\": \"2019-03-20T15:30:00+09:00\"}");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordWeight> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordWeight.class);
    given(treatmentRecordDao.updateTreatmentRecordForWeight(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // action/assert
    expectedException.expect(RequiredException.class);
    expectedException.expectMessage("必須項目が設定されていません。");
    target.updateTreatmentRecordWeight(ordNo, beUpdatedTreatmentRecordWeight);
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(13L));
    final TreatmentRecordWeight updatedTreatmentRecordWeight = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordWeight, is(beUpdatedTreatmentRecordWeight));
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   *
   * 条件：必須項目weight_before_dateを設定していないEntityを指定する
   * 結果：例外が発生しないこと
   */
  @Test
  public void test_updateTreatmentRecordWeight_成功_weight_before_dateが設定されていない場合_例外が発生しないこと() throws JacksonException {
    // arrange
    final Long ordNo = 13L;
    final TreatmentRecordWeight beUpdatedTreatmentRecordWeight = getWeightDummyData();
    beUpdatedTreatmentRecordWeight.setRstWeightInfo("{\"weight_after_date\": \"2019-03-20T15:30:00+09:00\"}");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordWeight> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordWeight.class);
    given(treatmentRecordDao.updateTreatmentRecordForWeight(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // action/assert
    target.updateTreatmentRecordWeight(ordNo, beUpdatedTreatmentRecordWeight);
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(13L));
    final TreatmentRecordWeight updatedTreatmentRecordWeight = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordWeight, is(beUpdatedTreatmentRecordWeight));
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   *
   * 条件：必須項目weight_after_dateを設定していないEntityを指定する
   * 結果：RequiredExceptionがThrowされること
   */
  @Test
  @Ignore
  public void test_updateTreatmentRecordWeight_失敗_必須項目weight_after_dateが設定されていない場合例外が発生すること() throws JacksonException {
    // arrange
    final Long ordNo = 13L;
    final TreatmentRecordWeight beUpdatedTreatmentRecordWeight = getWeightDummyData();
    beUpdatedTreatmentRecordWeight.setRstWeightInfo("{\"weight_before_date\": \"2019-03-20T12:00:00+09:00\"}");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordWeight> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordWeight.class);
    given(treatmentRecordDao.updateTreatmentRecordForWeight(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // action/assert
    expectedException.expect(RequiredException.class);
    expectedException.expectMessage("必須項目が設定されていません。");
    target.updateTreatmentRecordWeight(ordNo, beUpdatedTreatmentRecordWeight);
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(13L));
    final TreatmentRecordWeight updatedTreatmentRecordWeight = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordWeight, is(beUpdatedTreatmentRecordWeight));
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   *
   * 条件：必須項目weight_after_dateを設定していないEntityを指定する
   * 結果：例外が発生しないこと
   */
  @Test
  public void test_updateTreatmentRecordWeight_成功_weight_after_dateが設定されていない場合_例外が発生しないこと() throws JacksonException {
    // arrange
    final Long ordNo = 13L;
    final TreatmentRecordWeight beUpdatedTreatmentRecordWeight = getWeightDummyData();
    beUpdatedTreatmentRecordWeight.setRstWeightInfo("{\"weight_before_date\": \"2019-03-20T12:00:00+09:00\"}");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordWeight> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordWeight.class);
    given(treatmentRecordDao.updateTreatmentRecordForWeight(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // action/assert
    target.updateTreatmentRecordWeight(ordNo, beUpdatedTreatmentRecordWeight);
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(13L));
    final TreatmentRecordWeight updatedTreatmentRecordWeight = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordWeight, is(beUpdatedTreatmentRecordWeight));
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   *
   * 条件：必須項目weight_before_date, weight_after_dateのどちらも設定していないEntityを指定する
   * 結果：RequiredExceptionがThrowされること
   */
  @Test
  @Ignore
  public void test_updateTreatmentRecordWeight_失敗_必須項目の２つとも設定されていない場合例外が発生すること() throws JacksonException {
    // arrange
    final Long ordNo = 13L;
    final TreatmentRecordWeight beUpdatedTreatmentRecordWeight = getWeightDummyData();
    beUpdatedTreatmentRecordWeight.setRstWeightInfo("");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordWeight> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordWeight.class);
    given(treatmentRecordDao.updateTreatmentRecordForWeight(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // action/assert
    expectedException.expect(RequiredException.class);
    expectedException.expectMessage("必須項目が設定されていません。");
    target.updateTreatmentRecordWeight(ordNo, beUpdatedTreatmentRecordWeight);
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(13L));
    final TreatmentRecordWeight updatedTreatmentRecordWeight = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordWeight, is(beUpdatedTreatmentRecordWeight));
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   *
   * 条件：weight_before_date, weight_after_dateのどちらも設定していないEntityを指定する
   * 結果：例外が発生しないこと
   */
  @Test
  public void test_updateTreatmentRecordWeight_成功_前体重測定日_後体重測定日が設定されていない場合_例外が発生しないこと() throws JacksonException {
    // arrange
    final Long ordNo = 13L;
    final TreatmentRecordWeight beUpdatedTreatmentRecordWeight = getWeightDummyData();
    beUpdatedTreatmentRecordWeight.setRstWeightInfo("");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordWeight> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordWeight.class);
    given(treatmentRecordDao.updateTreatmentRecordForWeight(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // action/assert
    target.updateTreatmentRecordWeight(ordNo, beUpdatedTreatmentRecordWeight);
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(13L));
    final TreatmentRecordWeight updatedTreatmentRecordWeight = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordWeight, is(beUpdatedTreatmentRecordWeight));
  }

  /**
   * getRecirculationRate()の検証.
   *
   * 条件：指定されたオーダ番号に該当する装置モニタデータが存在する
   *       再循環率データは6件存在
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getRecirculationRate_正常_5件取得() {
    // 事前準備
    Long ordNo = 10L;
    Short dataTypeRecirculationRate = 3;
    Short dataTypeMonitor = 1;

    List<MniMonitor> recirculationRates = Arrays.asList(
      getMniMonitor(1L, 3, Timestamp.valueOf("2019-03-22 12:00:00"), "{\"89\": 70}"),
      getMniMonitor(2L, 3, Timestamp.valueOf("2019-03-22 13:00:00"), "{\"89\": 75}"),
      getMniMonitor(3L, 3, Timestamp.valueOf("2019-03-22 13:30:00"), "{\"89\": 80}"),
      getMniMonitor(4L, 3, Timestamp.valueOf("2019-03-22 14:00:00"), "{\"89\": 85}"),
      getMniMonitor(5L, 3, Timestamp.valueOf("2019-03-22 15:00:00"), "{\"89\": 90}"),
      getMniMonitor(6L, 3, Timestamp.valueOf("2019-03-22 16:00:00"), "{\"89\": 95}")
    );
    List<MniMonitor> bloodFlows = Arrays.asList(
      getMniMonitor(11L, 1, Timestamp.valueOf("2019-03-22 11:30:00"), "{\"8\": 90}"),
      getMniMonitor(12L, 1, Timestamp.valueOf("2019-03-22 12:00:00"), "{\"8\": 100}"),
      getMniMonitor(13L, 1, Timestamp.valueOf("2019-03-22 14:00:00"), "{\"8\": 110}"),
      getMniMonitor(14L, 1, Timestamp.valueOf("2019-03-22 14:30:00"), "{\"8\": 120}"),
      getMniMonitor(15L, 1, Timestamp.valueOf("2019-03-22 17:00:00"), "{\"8\": 130}")
    );
    List<RecirculationRate> expected = Arrays.asList(
      new RecirculationRate(1L, ZonedDateTime.of(2019, 3, 22, 12, 0, 0, 0, ZoneId.systemDefault()), 70, 100),
      new RecirculationRate(2L, ZonedDateTime.of(2019, 3, 22, 13, 0, 0, 0, ZoneId.systemDefault()), 75, 100),
      new RecirculationRate(3L, ZonedDateTime.of(2019, 3, 22, 13, 30, 0, 0, ZoneId.systemDefault()), 80, 100),
      new RecirculationRate(4L, ZonedDateTime.of(2019, 3, 22, 14, 0, 0, 0, ZoneId.systemDefault()), 85, 110),
      new RecirculationRate(5L, ZonedDateTime.of(2019, 3, 22, 15, 0, 0, 0, ZoneId.systemDefault()), 90, 120)
    );

    // Mock化
    given(treatmentRecordDao.selectMniMonitorForRecirculationRate(ordNo, dataTypeRecirculationRate)).willReturn(recirculationRates);
    given(treatmentRecordDao.selectMniMonitorForRecirculationRate(ordNo, dataTypeMonitor)).willReturn(bloodFlows);

    // 実行
    List<RecirculationRate> result = target.getRecirculationRate(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectMniMonitorForRecirculationRate(ordNo, dataTypeRecirculationRate);
    verify(treatmentRecordDao, times(1)).selectMniMonitorForRecirculationRate(ordNo, dataTypeMonitor);
    assertThat(result, not(nullValue()));
    assertRecirculationRates(result, expected);
  }

  /**
   * getRecirculationRate()の検証.
   *
   * 条件：指定されたオーダ番号に該当する装置モニタデータが存在しない
   * 結果：成功レスポンスが返却されること（リストは空）
   */
  @Test
  public void test_getRecirculationRate_正常_データが空() {
    // 事前準備
    Long ordNo = 10L;
    Short dataTypeRecirculationRate = 3;
    Short dataTypeMonitor = 1;

    List<MniMonitor> recirculationRates = Collections.emptyList();
    List<MniMonitor> bloodFlows = Collections.emptyList();
    List<RecirculationRate> expected = Collections.emptyList();

    // Mock化
    given(treatmentRecordDao.selectMniMonitorForRecirculationRate(ordNo, dataTypeRecirculationRate)).willReturn(recirculationRates);
    given(treatmentRecordDao.selectMniMonitorForRecirculationRate(ordNo, dataTypeMonitor)).willReturn(bloodFlows);

    // 実行
    List<RecirculationRate> result = target.getRecirculationRate(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectMniMonitorForRecirculationRate(ordNo, dataTypeRecirculationRate);
    verify(treatmentRecordDao, times(1)).selectMniMonitorForRecirculationRate(ordNo, dataTypeMonitor);
    assertThat(result, not(nullValue()));
    assertRecirculationRates(result, expected);
  }

  /**
   * getRecirculationRate()の検証.
   *
   * 条件：指定されたオーダ番号に該当する装置モニタデータが存在する
   *       再循環率データは4件存在、血流量データは0件
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getRecirculationRate_正常_血流量データなし() {
    // 事前準備
    Long ordNo = 10L;
    Short dataTypeRecirculationRate = 3;
    Short dataTypeMonitor = 1;

    List<MniMonitor> recirculationRates = Arrays.asList(
      getMniMonitor(1L, 3, Timestamp.valueOf("2019-03-22 12:00:00"), "{\"89\": 70}"),
      getMniMonitor(2L, 3, Timestamp.valueOf("2019-03-22 13:00:00"), "{\"89\": 75}"),
      getMniMonitor(3L, 3, Timestamp.valueOf("2019-03-22 13:30:00"), "{\"89\": 80}"),
      getMniMonitor(4L, 3, Timestamp.valueOf("2019-03-22 16:00:00"), "{\"89\": 95}")
    );
    List<MniMonitor> bloodFlows = Collections.emptyList();
    List<RecirculationRate> expected = Arrays.asList(
      new RecirculationRate(1L, ZonedDateTime.of(2019, 3, 22, 12, 0, 0, 0, ZoneId.systemDefault()), 70, null),
      new RecirculationRate(2L, ZonedDateTime.of(2019, 3, 22, 13, 0, 0, 0, ZoneId.systemDefault()), 75, null),
      new RecirculationRate(3L, ZonedDateTime.of(2019, 3, 22, 13, 30, 0, 0, ZoneId.systemDefault()), 80, null),
      new RecirculationRate(4L, ZonedDateTime.of(2019, 3, 22, 16, 0, 0, 0, ZoneId.systemDefault()), 95, null)
    );

    // Mock化
    given(treatmentRecordDao.selectMniMonitorForRecirculationRate(ordNo, dataTypeRecirculationRate)).willReturn(recirculationRates);
    given(treatmentRecordDao.selectMniMonitorForRecirculationRate(ordNo, dataTypeMonitor)).willReturn(bloodFlows);

    // 実行
    List<RecirculationRate> result = target.getRecirculationRate(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectMniMonitorForRecirculationRate(ordNo, dataTypeRecirculationRate);
    verify(treatmentRecordDao, times(1)).selectMniMonitorForRecirculationRate(ordNo, dataTypeMonitor);
    assertThat(result, not(nullValue()));
    assertRecirculationRates(result, expected);
  }

  /**
   * getRecirculationRate()の検証.
   *
   * 条件：指定されたオーダ番号に該当する装置モニタデータが存在する
   *       再循環率データは2件存在、血流量データは4件
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getRecirculationRate_正常_血流量データの境界値確認() {
    // 事前準備
    Long ordNo = 10L;
    Short dataTypeRecirculationRate = 3;
    Short dataTypeMonitor = 1;

    List<MniMonitor> recirculationRates = Arrays.asList(
      getMniMonitor(1L, 3, Timestamp.valueOf("2019-03-22 12:00:00"), "{\"89\": 70}"),
      getMniMonitor(2L, 3, Timestamp.valueOf("2019-03-22 16:00:00"), "{\"89\": 95}")
    );
    List<MniMonitor> bloodFlows = Arrays.asList(
      getMniMonitor(11L, 1, Timestamp.valueOf("2019-03-21 12:00:00"), "{\"8\": 122}"),
      getMniMonitor(12L, 1, Timestamp.valueOf("2019-03-22 16:59:00"), "{\"8\": 131}"),
      getMniMonitor(13L, 1, Timestamp.valueOf("2019-03-22 16:00:00"), "{\"8\": 132}"),
      getMniMonitor(14L, 1, Timestamp.valueOf("2019-03-22 16:01:00"), "{\"8\": 133}")
    );
    List<RecirculationRate> expected = Arrays.asList(
      new RecirculationRate(1L, ZonedDateTime.of(2019, 3, 22, 12, 0, 0, 0, ZoneId.systemDefault()), 70, 122),
      new RecirculationRate(2L, ZonedDateTime.of(2019, 3, 22, 16, 0, 0, 0, ZoneId.systemDefault()), 95, 132)
    );

    // Mock化
    given(treatmentRecordDao.selectMniMonitorForRecirculationRate(ordNo, dataTypeRecirculationRate)).willReturn(recirculationRates);
    given(treatmentRecordDao.selectMniMonitorForRecirculationRate(ordNo, dataTypeMonitor)).willReturn(bloodFlows);

    // 実行
    List<RecirculationRate> result = target.getRecirculationRate(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectMniMonitorForRecirculationRate(ordNo, dataTypeRecirculationRate);
    verify(treatmentRecordDao, times(1)).selectMniMonitorForRecirculationRate(ordNo, dataTypeMonitor);
    assertThat(result, not(nullValue()));
    assertRecirculationRates(result, expected);
  }

  /**
   * getTreatmentRecordEquipInfo()の検証.
   *
   * 条件：治療記録マスタに存在するOrdNoをもつレコードを指定する
   * 結果：医療材料情報を取得できること
   */
  @Test
  public void test_getTreatmentRecordEquipInfo_成功() {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordEquipInfo EquipInfo = new TreatmentRecordEquipInfo();
    EquipInfo.setOrdNo(ordNo);
    EquipInfo.setRstDialysisState("0");
    EquipInfo.setRstEquipInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    given(treatmentRecordDao.selectTreatmentRecordEquipInfoByOrdNo(any())).willReturn(EquipInfo);

    // action
    TreatmentRecordEquipInfo result = target.getTreatmentRecordEquipInfo(ordNo);

    // assert
    assertThat(result.getOrdNo(), is(ordNo));
    assertThat(result.getRstDialysisState(), is("0"));
    assertThat(result.getRstEquipInfo(), is("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]"));

    verify(treatmentRecordDao, times(1)).selectTreatmentRecordEquipInfoByOrdNo(ordNo);
  }

  /**
   * getTreatmentRecordEquipInfo()の検証.
   *
   * 条件：治療記録マスタに存在しないOrdNoを指定する
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getTreatmentRecordEquipInfo_失敗() {
    // arrange
    final Long ordNo = 1L;
    given(treatmentRecordDao.selectTreatmentRecordEquipInfoByOrdNo(any())).willThrow(EmptyResultDataAccessException.class);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.getTreatmentRecordEquipInfo(ordNo);

    verify(treatmentRecordDao, times(1)).selectTreatmentRecordEquipInfoByOrdNo(ordNo);
  }

  /**
   * updateTreatmentRecordEquipInfo()の検証.
   *
   * 条件：治療情報に存在するOrdNoをもつレコードを指定する
   * 結果：医療材料情報の更新ができること
   */
  @Test
  public void test_updateTreatmentRecordEquipInfo_成功_医療材料情報の更新ができること() {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordEquipInfo beforeUpdateTreatmentRecordEquipInfo = new TreatmentRecordEquipInfo();
    beforeUpdateTreatmentRecordEquipInfo.setOrdNo(ordNo);
    beforeUpdateTreatmentRecordEquipInfo.setRstDialysisState("0");
    beforeUpdateTreatmentRecordEquipInfo.setRstEquipInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordEquipInfo> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordEquipInfo.class);
    given(treatmentRecordDao.updateTreatmentRecordForEquipInfo(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // action
    target.updateTreatmentRecordEquipInfo(ordNo, beforeUpdateTreatmentRecordEquipInfo);

    // assert
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(1L));
    final TreatmentRecordEquipInfo updatedTreatmentRecordEquipInfo = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordEquipInfo, is(beforeUpdateTreatmentRecordEquipInfo));
  }

  /**
   * updateTreatmentRecordEquipInfo()の検証.
   *
   * 条件：治療情報に存在しないOrdNoをもつレコードを指定する
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_updateTreatmentRecordEquipInfo_失敗_コードに一致する治療情報がない場合は例外が発生すること() {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordEquipInfo beforeUpdateTreatmentRecordEquipInfo = new TreatmentRecordEquipInfo();
    beforeUpdateTreatmentRecordEquipInfo.setOrdNo(ordNo);
    beforeUpdateTreatmentRecordEquipInfo.setRstDialysisState("0");
    beforeUpdateTreatmentRecordEquipInfo.setRstEquipInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordEquipInfo> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordEquipInfo.class);
    given(treatmentRecordDao.updateTreatmentRecordForEquipInfo(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(0);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.updateTreatmentRecordEquipInfo(ordNo, beforeUpdateTreatmentRecordEquipInfo);
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(10L));
    final TreatmentRecordEquipInfo updatedTreatmentRecordEquipInfo = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordEquipInfo, is(beforeUpdateTreatmentRecordEquipInfo));
  }
  /**
   * getLatestOrdNo()の検証.
   *
   * 条件：指定された患者ID、施設コードに該当する、治療記録レコードが存在する
   * 結果：該当する治療記録レコードのオーダ番号が返却されること
   */
  @Test
  public void test_getLatestOrdNo_成功_オーダ番号あり() {
    // arrange
    final Long patId = 1L;
    final String facilityCd = "009999";
    final Long ordNo = 2L;
    given(treatmentRecordDao.selectLatestOrdNoByPatIdAndFacilityCd(anyLong(), anyString())).willReturn(ordNo);

    // action
    Long result = target.getLatestOrdNo(patId, facilityCd);

    // assert
    assertThat(result, is(ordNo));

    verify(treatmentRecordDao, times(1)).selectLatestOrdNoByPatIdAndFacilityCd(patId, facilityCd);
  }

  /**
   * getLatestOrdNo()の検証.
   *
   * 条件：指定された患者ID、施設コードに該当する、治療記録レコードが存在しない
   * 結果：nullが返却されること
   */
  @Test
  public void test_getLatestOrdNo_成功_オーダ番号なし() {
    // arrange
    final Long patId = 1L;
    final String facilityCd = "009999";
    given(treatmentRecordDao.selectLatestOrdNoByPatIdAndFacilityCd(anyLong(), anyString())).willReturn(null);

    // action
    Long result = target.getLatestOrdNo(patId, facilityCd);

    // assert
    assertThat(result, nullValue());

    verify(treatmentRecordDao, times(1)).selectLatestOrdNoByPatIdAndFacilityCd(patId, facilityCd);
  }

  /**
   * getTreatmentRecordAddition()の検証.
   *
   * 条件：治療記録マスタに存在するOrdNoをもつレコードを指定する
   * 結果：指示コメント情報を取得できること
   */
  @Test
  public void test_getTreatmentRecordAddition_成功() {
    // arrange
    final Long ordNo = 1L;
    final Long patId = 2L;
    final String facilityCd = "009999";
    final String treatDate = "20190416";
    final Long kurCd = 3L;
    final Long treatmentCd = 4L;
    final String comment = "[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]";
    TreatmentRecordAddition addition = new TreatmentRecordAddition();
    addition.setPatId(patId);
    addition.setFacilityCd(facilityCd);
    addition.setTreatDate(treatDate);
    addition.setRstKurCd(kurCd);
    addition.setRstTreatmentCd(treatmentCd);
    addition.setRstIndCommentInfo(comment);
    given(treatmentRecordDao.selectTreatmentRecordAdditionByOrdNo(any())).willReturn(addition);

    // action
    TreatmentRecordAddition result = target.getTreatmentRecordAddition(ordNo);

    // assert
    assertThat(result.getPatId(), is(patId));
    assertThat(result.getFacilityCd(), is(facilityCd));
    assertThat(result.getTreatDate(), is(treatDate));
    assertThat(result.getRstKurCd(), is(kurCd));
    assertThat(result.getRstTreatmentCd(), is(treatmentCd));
    assertThat(result.getRstIndCommentInfo(), is(comment));

    verify(treatmentRecordDao, times(1)).selectTreatmentRecordAdditionByOrdNo(ordNo);
  }

  /**
   * getTreatmentRecordAddition()の検証.
   *
   * 条件：治療記録マスタに存在しないOrdNoを指定する
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getTreatmentRecordAddition_失敗() {
    // arrange
    final Long ordNo = 1L;
    given(treatmentRecordDao.selectTreatmentRecordAdditionByOrdNo(any())).willThrow(EmptyResultDataAccessException.class);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.getTreatmentRecordAddition(ordNo);

    verify(treatmentRecordDao, times(1)).selectTreatmentRecordAdditionByOrdNo(ordNo);
  }

  /**
   * データ準備（実績情報）
   */
  private TreatmentRecordResult getResultDummyData() {
    TreatmentRecordResult dummyData = new TreatmentRecordResult();
    dummyData.setOrdNo(10L);
    dummyData.setFnPatId("fnPatIdX");
    dummyData.setTreatDate("20181231");
    dummyData.setTreatWeek(Short.valueOf("1"));
    dummyData.setFacilityCd("1234");
    dummyData.setFacilityName("facility5");
    // 治療項目コード
    dummyData.setRstTreatmentCd(100);
    // 治療項目名
    dummyData.setRstTreatmentName("テスト治療項目");
    dummyData.setRstDialysisState("1");
    dummyData.setRstKurCd(20L);
    dummyData.setRstKurName("kur1");
    dummyData.setRstBedCd(30L);
    dummyData.setRstBedName("bed2");
    dummyData.setRstStartDate(Timestamp.valueOf("2018-12-31 13:16:55"));
    dummyData.setRstEndDate(Timestamp.valueOf("2018-12-31 17:30:24"));
    dummyData.setRstInOutClass(Short.valueOf("0"));
    dummyData.setRstDialysisCnt(120);
    dummyData.setRstWardCd(33);
    dummyData.setRstWardName("病棟１");
    dummyData.setRstCourseCd(93);
    dummyData.setRstCourseName("内科");
    dummyData.setRstPunctureUserInfo(new TreatmentRecordResult.RstUserInfo() {
      {
        setUserId1(1L);
        setUserFirstName1("穿刺");
        setUserLastName1("太郎");
        setUserId2(2L);
        setUserFirstName2("穿刺");
        setUserLastName2("二郎");
        setDate("2018-12-31 13:35:12");
        setDate1(Timestamp.valueOf("2018-12-31 13:36:12"));
        setDate2(Timestamp.valueOf("2018-12-31 13:37:12"));
      }
    });
    dummyData.setRstReturnUserInfo(new TreatmentRecordResult.RstUserInfo() {
      {
        setUserId1(11L);
        setUserFirstName1("返血");
        setUserLastName1("太郎");
        setUserId2(12L);
        setUserFirstName2("返血");
        setUserLastName2("二郎");
        setDate("2018-12-31 14:55:44");
        setDate1(Timestamp.valueOf("2018-12-31 14:56:44"));
        setDate2(Timestamp.valueOf("2018-12-31 14:57:44"));
      }
    });
    dummyData.setRstChargeUserInfo(new TreatmentRecordResult.RstUserInfo() {
      {
        setUserId1(21L);
        setUserFirstName1("担当");
        setUserLastName1("太郎");
        setUserId2(22L);
        setUserFirstName2("担当");
        setUserLastName2("二郎");
        setDate1(Timestamp.valueOf("2018-12-31 15:55:44"));
        setDate2(Timestamp.valueOf("2018-12-31 15:56:44"));
      }
    });
    dummyData.setUpDate(Timestamp.valueOf("2018-12-31 14:01:00"));

    return dummyData;
  }

  /**
   * データ準備（実績情報）
   */
  private TreatmentRecordCondition getConditionDummyData() {
    TreatmentRecordCondition dummyData = new TreatmentRecordCondition();
    dummyData.setIndTreatStartTime("1400");
    dummyData.setRstCondInfo("1400");
    dummyData.setRstDw(BigDecimal.valueOf(73.21));
    return dummyData;
  }


  /**
   * データ準備（体重情報）
   */
  private TreatmentRecordWeight getWeightDummyData() {
    TreatmentRecordWeight dummyData = new TreatmentRecordWeight();
    dummyData.setLastWeight(BigDecimal.valueOf(62.3));
    dummyData.setRstDw(BigDecimal.valueOf(73.21));
    dummyData.setWaterRemovalAmountLimit(BigDecimal.valueOf(1.42));
    dummyData.setRstWeightInfo("WeightInfo");
    dummyData.setRstTareInfo("rstTareInfo");
    dummyData.setRstOffWaterInfo("rstOffWaterInfo");
    return new TreatmentRecordWeight();
  }

  /**
   * データ準備（装置モニタデータ）
   */
  private MniMonitor getMniMonitor(Long bioMoniCtlNo, Integer dataType, Timestamp occurDate, String monitorData) {
    return new MniMonitor() {
      {
        setBioMoniCtlNo(bioMoniCtlNo);
        setDataType(dataType.shortValue());
        setOccurDate(occurDate);
        setMonitorData(monitorData);
      }
    };
  }

  /**
   * 再循環率データリストのAssertion
   * @param result
   * @param expected
   */
  private void assertRecirculationRates(List<RecirculationRate> result, List<RecirculationRate> expected) {
    assertThat(result.size(), is(expected.size()));
    for (int i = 0; i < result.size(); i++) {
      assertThat(result.get(i).getBioMoniCtlNo(), is(expected.get(i).getBioMoniCtlNo()));
      assertThat(result.get(i).getDate(), is(expected.get(i).getDate()));
      assertThat(result.get(i).getRecirculationRate(), is(expected.get(i).getRecirculationRate()));
      assertThat(result.get(i).getBloodFlow(), is(expected.get(i).getBloodFlow()));
    }
  }

  /**
   * updateTreatmentRecordAddition()の検証.
   *
   * 条件：治療情報に存在するOrdNoをもつレコードを指定する
   * 結果：指示コメント情報の更新ができること
   */
  @Test
  public void test_updateTreatmentRecordAddition_成功_指示コメント情報の更新ができること() {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordAddition beforeUpdateTreatmentRecordAddition = new TreatmentRecordAddition();
    beforeUpdateTreatmentRecordAddition.setRstIndCommentInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordAddition> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordAddition.class);
    given(treatmentRecordDao.updateTreatmentRecordForAddition(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // action
    target.updateTreatmentRecordAddition(ordNo, beforeUpdateTreatmentRecordAddition);

    // assert
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(1L));
    final TreatmentRecordAddition updatedTreatmentRecordAddition = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordAddition, is(beforeUpdateTreatmentRecordAddition));
  }

  /**
   * updateTreatmentRecordAddition()の検証.
   *
   * 条件：治療情報に存在しないOrdNoをもつレコードを指定する
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_updateTreatmentRecordAddition_失敗_コードに一致する治療情報がない場合は例外が発生すること() {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordAddition beforeUpdateTreatmentRecordAddition = new TreatmentRecordAddition();
    beforeUpdateTreatmentRecordAddition.setRstIndCommentInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordAddition> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordAddition.class);
    given(treatmentRecordDao.updateTreatmentRecordForAddition(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(0);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.updateTreatmentRecordAddition(ordNo, beforeUpdateTreatmentRecordAddition);
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(10L));
    final TreatmentRecordAddition updatedTreatmentRecordAddition = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordAddition, is(beforeUpdateTreatmentRecordAddition));
  }

  private TreatmentRecordVitalMonitor getVitalMonitor(Long bioMoniCtlNo, Short dataType) {
    TreatmentRecordVitalMonitor vitalMonitor = new TreatmentRecordVitalMonitor();
    vitalMonitor.setBioMoniCtlNo(bioMoniCtlNo);
    vitalMonitor.setDataType(dataType);
    vitalMonitor.setMonitorData("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    vitalMonitor.setOccurDate(Timestamp.valueOf("2019-05-08 12:00:00.000"));

    return vitalMonitor;
  }

  /**
   * getTreatmentRecordVitalMonitor()の検証.
   *
   * 条件：指定されたオーダ番号に該当する装置モニタデータが存在する
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getTreatmentRecordVitalMonitor_正常() {
    // 事前準備
    Long ordNo = 10L;

    List<TreatmentRecordVitalMonitor> mniMonitors = Arrays.asList(
        getVitalMonitor(1L, (short)2),
        getVitalMonitor(2L, (short)4),
        getVitalMonitor(3L, (short)2),
        getVitalMonitor(4L, (short)6)
    );

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordVitalMonitors(any(), ordNo)).willReturn(mniMonitors);

    // 実行
    List<TreatmentRecordVitalMonitor> result = target.getTreatmentRecordVitalMonitors(any(), ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordVitalMonitors(any(), ordNo);
    assertThat(result, not(nullValue()));
    assertThat(result.size(), is(mniMonitors.size()));
    for (int i = 0; i < mniMonitors.size(); i++) {
      assertThat(result.get(i), samePropertyValuesAs(mniMonitors.get(i)));
    }
  }

  /**
   * getTreatmentRecordVitalMonitor()の検証.
   *
   * 条件：指定されたオーダ番号に該当する装置モニタデータが存在しない
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getTreatmentRecordVitalMonitor_正常_0件() {
    // 事前準備
    Long ordNo = 10L;

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordVitalMonitors(any(), ordNo)).willReturn(Collections.emptyList());

    // 実行
    List<TreatmentRecordVitalMonitor> result = target.getTreatmentRecordVitalMonitors(any(), ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordVitalMonitors(any(), ordNo);
    assertThat(result, not(nullValue()));
    assertThat(result.size(), is(0));
  }

  /**
   * テスト用：登録、更新する{@link MniMonitor}作成.
   * @param dataType データ種別
   * @param ordNo オーダ番号
   * @param patId 患者番号
   * @param monitorData モニタデータ
   * @param updStaffId 更新者ID
   * @return 登録する装置モニタデータ
   */
  private MniMonitor getMniMonitor(
    Long bioMniCtlNo,
    Short dataType,
    Long ordNo,
    Long patId,
    String monitorData,
    Long updStaffId) {
    MniMonitor insertTestMonitorData = new MniMonitor();
    insertTestMonitorData.setBioMoniCtlNo(bioMniCtlNo);
    insertTestMonitorData.setOrdNo(ordNo);
    insertTestMonitorData.setPatId(patId);
    insertTestMonitorData.setDataType(dataType);
    insertTestMonitorData.setIsDel("0");
    insertTestMonitorData.setMonitorData(monitorData);
    insertTestMonitorData.setOccurDate(Timestamp.valueOf("2019-11-21 12:00:00.000"));
    insertTestMonitorData.setUpdStaffId(updStaffId);
    return insertTestMonitorData;
  }

  /**
   * {@link TreatmentRecordServiceImpl#insertOrUpdateTreatmentRecordForMniMonitor(Long, List, Long)} の検証.
   * <p>
   *   条件：存在するオーダ番号を指定する
   *   結果：装置モニタデータに登録される事
   * </p>
   */
  @Test
  public void test_insertOrUpdateTreatmentRecordForMniMonitor_正常_装置モニタデータに登録される事() {
    // 各種キー
    Long bioMniCtlNo = 0L;
    short dataType = 3;
    Long ordNo = 1L;
    Long patId = 10L;
    Long updStaffId = 100L;
    Long machineNo = 1000L;
    String facilityCd = "nkknkk";
    String machineTypeCd = "1";
    String machineSerial = "2";
    // 登録する装置モニタデータ
    List<MniMonitor> insertMniMonitorList = Arrays.asList(
      getMniMonitor(bioMniCtlNo, dataType,ordNo,patId,"{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}", updStaffId)
    );

    // オーダメイン
    OrdMain ordMain = new OrdMain(){{
      setOrdNo(ordNo);
      setPatId(patId);
      setRstMachineNo(machineNo);
      setFacilityCd(facilityCd);
    }};
    // 装置マスタ
    MstMachine mstMachine = new MstMachine(){{
      setMachineTypeCd(machineTypeCd);
      setMachineSerial(machineSerial);
    }};
    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<Long> machineNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<MniMonitor> mniMonitorCaptor = ArgumentCaptor.forClass(MniMonitor.class);
    given(ordMainDao.selectByOrdNo(ordNoCaptor.capture())).willReturn(ordMain);
    given(mstMachineDao.selectByMachineNo(machineNoCaptor.capture())).willReturn(mstMachine);
    given(mniMonitorDao.insert(mniMonitorCaptor.capture())).willReturn(1);

    // 実行
    target.insertOrUpdateTreatmentRecordForMniMonitor(ordNo, insertMniMonitorList, updStaffId);

    // 検証
    verify(ordMainDao, times(1)).selectByOrdNo(ordNo);
    verify(mstMachineDao, times(1)).selectByMachineNo(machineNo);
    verify(mniMonitorDao, times(1)).insert(insertMniMonitorList.get(0));

    // assert(ordMainDao)
    assertThat(ordNoCaptor.getValue(), is(ordNo));
    // assert(mstMachineDao)
    assertThat(machineNoCaptor.getValue(), is(machineNo));
    // assert
    assertThat(mniMonitorCaptor.getValue().getFacilityCd(), is(facilityCd));
    assertThat(mniMonitorCaptor.getValue().getMachineTypeCd(), is(machineTypeCd));
    assertThat(mniMonitorCaptor.getValue().getMachineSerial(), is(machineSerial));
    assertThat(mniMonitorCaptor.getValue().getDataType(), is(dataType));
    assertThat(mniMonitorCaptor.getValue().getUpdStaffId(), is(updStaffId));
  }

  /**
   * {@link TreatmentRecordServiceImpl#insertOrUpdateTreatmentRecordForMniMonitor(Long, List, Long)} の検証.
   * <p>
   *   条件：装置番号に該当する装置マスタがない
   *   結果：装置モニタデータの型式コードと製造番号が{@code null}で登録される事
   * </p>
   */
  @Test
  public void test_insertOrUpdateTreatmentRecordForMniMonitor_正常_該当する装置マスタが存在しない場合にnullで登録される事() {
    // 各種キー
    Long bioMniCtlNo = 0L;
    short dataType = 3;
    Long ordNo = 1L;
    Long patId = 10L;
    Long updStaffId = 100L;
    Long machineNo = 1000L;
    String facilityCd = "nkknkk";
    String machineTypeCd = "1";
    String machineSerial = "2";
    // 登録する装置モニタデータ
    List<MniMonitor> insertMniMonitorList = Arrays.asList(
      getMniMonitor(bioMniCtlNo, dataType,ordNo,patId,"{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}", updStaffId)
    );

    // オーダメイン
    OrdMain ordMain = new OrdMain(){{
      setOrdNo(ordNo);
      setPatId(patId);
      setRstMachineNo(machineNo);
      setFacilityCd(facilityCd);
    }};

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<Long> machineNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<MniMonitor> mniMonitorCaptor = ArgumentCaptor.forClass(MniMonitor.class);
    given(ordMainDao.selectByOrdNo(ordNoCaptor.capture())).willReturn(ordMain);
    given(mstMachineDao.selectByMachineNo(machineNoCaptor.capture())).willReturn(null);
    given(mniMonitorDao.insert(mniMonitorCaptor.capture())).willReturn(1);


    // Daoの呼ばれる回数のチェック
    // 実行
    target.insertOrUpdateTreatmentRecordForMniMonitor(ordNo, insertMniMonitorList, updStaffId);

    // 検証
    verify(ordMainDao, times(1)).selectByOrdNo(ordNo);
    verify(mstMachineDao, times(1)).selectByMachineNo(machineNo);
    verify(mniMonitorDao, times(1)).insert(insertMniMonitorList.get(0));

    // assert(ordMainDao)
    assertThat(ordNoCaptor.getValue(), is(ordNo));
    // assert(mstMachineDao)
    assertThat(machineNoCaptor.getValue(), is(machineNo));
    // assert
    assertThat(mniMonitorCaptor.getValue().getMachineTypeCd(), is(nullValue()));
    assertThat(mniMonitorCaptor.getValue().getMachineSerial(), is(nullValue()));
  }

  /**
   * {@link TreatmentRecordServiceImpl#insertOrUpdateTreatmentRecordForMniMonitor(Long, List, Long)} の検証.
   * <p>
   *   条件：登録する装置モニタデータのデータ種別を0とする
   *   結果：データ種別が2で登録される事
   * </p>
   */
  @Test
  public void test_insertOrUpdateTreatmentRecordForMniMonitor_正常_データ種別が0の場合に2で登録される事() {
    // 各種キー
    Long bioMniCtlNo = 0L;
    short dataType = 0;
    Long ordNo = 1L;
    Long patId = 10L;
    Long updStaffId = 100L;
    Long machineNo = 1000L;
    String facilityCd = "nkknkk";
    String machineTypeCd = "1";
    String machineSerial = "2";
    // 登録する装置モニタデータ
    List<MniMonitor> insertMniMonitorList = Arrays.asList(
      getMniMonitor(bioMniCtlNo, dataType,ordNo,patId,"{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}", updStaffId)
    );

    // オーダメイン
    OrdMain ordMain = new OrdMain(){{
      setOrdNo(ordNo);
      setPatId(patId);
      setRstMachineNo(machineNo);
      setFacilityCd(facilityCd);
    }};
    // 装置マスタ
    MstMachine mstMachine = new MstMachine(){{
      setMachineTypeCd(machineTypeCd);
      setMachineSerial(machineSerial);
    }};
    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<Long> machineNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<MniMonitor> mniMonitorCaptor = ArgumentCaptor.forClass(MniMonitor.class);
    given(ordMainDao.selectByOrdNo(ordNoCaptor.capture())).willReturn(ordMain);
    given(mstMachineDao.selectByMachineNo(machineNoCaptor.capture())).willReturn(mstMachine);
    given(mniMonitorDao.insert(mniMonitorCaptor.capture())).willReturn(1);


    // Daoの呼ばれる回数のチェック
    // 実行
    target.insertOrUpdateTreatmentRecordForMniMonitor(ordNo, insertMniMonitorList, updStaffId);

    // 検証
    verify(ordMainDao, times(1)).selectByOrdNo(ordNo);
    verify(mstMachineDao, times(1)).selectByMachineNo(machineNo);
    verify(mniMonitorDao, times(1)).insert(insertMniMonitorList.get(0));

    // assert(ordMainDao)
    assertThat(ordNoCaptor.getValue(), is(ordNo));
    // assert(mstMachineDao)
    assertThat(machineNoCaptor.getValue(), is(machineNo));
    // assert
    assertThat(mniMonitorCaptor.getValue().getDataType(), is((short)2));
  }


  /**
   * {@link TreatmentRecordServiceImpl#insertOrUpdateTreatmentRecordForMniMonitor(Long, List, Long)} の検証.
   * <p>
   *   条件：存在しないオーダ番号を指定する
   *   結果：例外が発生する事
   * </p>
   */
  @Test
  public void test_insertOrUpdateTreatmentRecordForMniMonitor_異常_該当するオーダ番号がない場合に例外が発生する事() {
    // 各種キー
    Long bioMniCtlNo = 0L;
    short dataType = 3;
    Long ordNo = 1L;
    Long patId = 10L;
    Long updStaffId = 100L;
    // 登録する装置モニタデータ
    List<MniMonitor> insertMniMonitorList = Arrays.asList(
      getMniMonitor(bioMniCtlNo, dataType,ordNo,patId,"{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}", updStaffId)
    );

    given(ordMainDao.selectByOrdNo(anyLong())).willReturn(null);

    // 実行
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.insertOrUpdateTreatmentRecordForMniMonitor(ordNo, insertMniMonitorList, 1L);
  }

  /**
   * {@link TreatmentRecordServiceImpl#insertOrUpdateTreatmentRecordForMniMonitor(Long, List, Long)} の検証.
   * <p>
   *   条件：装置モニタデータが存在すること
   *   結果：装置モニタデータが更新されること
   * </p>
   */
  @Test
  public void test_insertOrUpdateTreatmentRecordForMniMonitor_正常_装置モニタデータが更新される事() {
    // 各種キー
    Long bioMniCtlNo = 1L;
    short dataType = 3;
    Long ordNo = 1L;
    Long patId = 10L;
    Long updStaffId = 100L;
    Long machineNo = 1000L;
    String monitorData = "{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}";
    // 登録する装置モニタデータ
    List<MniMonitor> insertMniMonitorList = Arrays.asList(
      getMniMonitor(bioMniCtlNo, dataType, ordNo, patId, monitorData, updStaffId)
    );

    final ArgumentCaptor<MniMonitor> mniMonitorCaptor = ArgumentCaptor.forClass(MniMonitor.class);
    final ArgumentCaptor<Long> bioMniCtlNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<Short> dataTypeCaptor = ArgumentCaptor.forClass(Short.class);
    final ArgumentCaptor<String> monitorDataCaptor = ArgumentCaptor.forClass(String.class);
    final ArgumentCaptor<String> isDelCaptor = ArgumentCaptor.forClass(String.class);
    final ArgumentCaptor<Timestamp> occurDateCaptor = ArgumentCaptor.forClass(Timestamp.class);
    final ArgumentCaptor<Timestamp> upDateCaptor = ArgumentCaptor.forClass(Timestamp.class);
    final ArgumentCaptor<Long> updStaffIdCaptor = ArgumentCaptor.forClass(Long.class);
    given(mniMonitorDao.updateMonitorData(
      bioMniCtlNoCaptor.capture(),
      dataTypeCaptor.capture(),
      monitorDataCaptor.capture(),
      isDelCaptor.capture(),
      occurDateCaptor.capture(),
      upDateCaptor.capture(),
      updStaffIdCaptor.capture())).willReturn(1);

    // 実行
    target.insertOrUpdateTreatmentRecordForMniMonitor(ordNo, insertMniMonitorList, updStaffId);

    // 検証
    verify(ordMainDao, times(0)).selectByOrdNo(ordNo);
    verify(mstMachineDao, times(0)).selectByMachineNo(machineNo);

    // assert
    assertThat(bioMniCtlNoCaptor.getValue(), is(bioMniCtlNo));
    assertThat(dataTypeCaptor.getValue(), is(dataType));
    assertThat(monitorDataCaptor.getValue(), is(monitorData));
    assertThat(isDelCaptor.getValue(), is("0"));
    assertThat(occurDateCaptor.getValue(), is(Timestamp.valueOf("2019-11-21 12:00:00.000")));
    assertThat(updStaffIdCaptor.getValue(), is(updStaffId));
  }
}
