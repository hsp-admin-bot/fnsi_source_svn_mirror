package jp.co.nikkiso.ntss.api.service.report;

import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.SysMonitorItem;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

/**
 * {@link ReportChartServiceImpl} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class ReportChartServiceImplTest {
  /**
   * テスト対象クラス
   */
  @Autowired
  private ReportChartService target;

  /**
   * {@link OrdMainDao}インタフェース.
   */
  @MockBean
  private OrdMainDao ordMainDao;

  /**
   * getReportGraphByOrdNo(privateメソッド)を{@link Method#invoke(Object, Object...)}する.
   *
   * @param ordNo オーダ番号
   * @return リスト
   * @throws Throwable
   */
  private List<ReportChartServiceImpl.ReportGraphSetting> invokeGetReportGraphSettingByOrdNo(Long ordNo) throws Throwable {
    try {
      Method method = ReportChartServiceImpl.class.getDeclaredMethod("getReportGraphSettingByOrdNo", Long.class);
      method.setAccessible(true);
      return (List<ReportChartServiceImpl.ReportGraphSetting>) method.invoke(target, ordNo);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    }
    return null;
  }

  /**
   * convertReportGraphSettingToSysMonitorItem(privateメソッド)を{@link Method#invoke(Object, Object...)}する.
   *
   * @param reportGraphSettingList 帳票グラフ設定
   * @return {@link SysMonitorItem}のリスト
   * @throws Throwable
   */
  private List<SysMonitorItem> invokeConvertReportGraphSettingToSysMonitorItem(
    List<ReportChartServiceImpl.ReportGraphSetting> reportGraphSettingList) throws Throwable {
    try {
      Method method = ReportChartServiceImpl.class.getDeclaredMethod("convertReportGraphSettingToSysMonitorItem", List.class);
      method.setAccessible(true);
      return (List<SysMonitorItem>) method.invoke(target, reportGraphSettingList);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    }
    return null;
  }

  /**
   * createPlotData(privateメソッド) を{@link Method#invoke(Object, Object...)}する.
   *
   * @param monitorData モニタデータ
   *                     key : 発生日時({@link Timestamp})
   *                     value : モニタ値
   * @return プロットデータのリスト
   * @throws Throwable
   */
  private List<String> invokeCreatePlotData(Map<Timestamp, String> monitorData) throws Throwable{
    try {
      Method method = ReportChartServiceImpl.class.getDeclaredMethod("createPlotData", Map.class);
      method.setAccessible(true);
      return (List<String>) method.invoke(target, monitorData);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    }
    return null;
  }

  /**
   * getChartJson(privateメソッド) を{@link Method#invoke(Object, Object...)}する.
   *
   * @return グラフ用のテンプレート文字列
   * @throws Throwable
   */
  private String invokeGetChartJson() throws Throwable{
    try {
      Method method = ReportChartServiceImpl.class.getDeclaredMethod("getChartJson");
      method.setAccessible(true);
      return (String) method.invoke(target);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    }
    return null;
  }

  /**
   * isBp(privateメソッド) を{@link Method#invoke(Object, Object...)}する.
   *
   * @param monitorItemCd モニタ項目コード
   * @return true : 最高血圧、最低血圧、平均血圧の何れかの場合
   *         false : 血圧以外
   * @throws Throwable
   */
  private boolean invokeIsBp(String monitorItemCd) throws Throwable{
    try {
      Method method = ReportChartServiceImpl.class.getDeclaredMethod("isBp", String.class);
      method.setAccessible(true);
      return (boolean) method.invoke(target, monitorItemCd);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    }
    return false;
  }

  /**
   * isDecimal(privateメソッド) を{@link Method#invoke(Object, Object...)}する.
   *
   * @param doubleVal 判定する数値
   * @return true : 小数値
   *         false : 整数値
   * @throws Throwable
   */
  private boolean invokeIsDecimal(Double doubleVal) throws Throwable{
    try {
      Method method = ReportChartServiceImpl.class.getDeclaredMethod("isDecimal", Double.class);
      method.setAccessible(true);
      return (boolean) method.invoke(target, doubleVal);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    }
    return false;
  }



  /**
   * getReportGraphSettingByOrdNo(Long)(privateメソッド)の検証
   *
   * <p>
   *   条件:実績情報に治療方法コードが設定されている事.
   *   結果:実績情報の治療方法コードに登録されている帳票グラフ設定が取得出来る事.
   * </p>
   */
  @Test
  public void test_invokeGetReportGraphSettingByOrdNo_正常_実績情報に治療方法コードが設定されている場合() throws Throwable {
    // 事前準備
    Long ordNo = 1L;

    // mockで返却する治療方法マスタ
    MstTreatment mstTreatment = new MstTreatment(){
      {
        setTreatmentCd(1);
        setTreatmentName("テスト治療方法");
        setReportGraphSetting("[\n" +
          "    {\n" +
          "        \"is_bp\": false,\n" +
          "        \"cd\": \"90\",\n" +
          "        \"type\": 1,\n" +
          "        \"plot_type\": \"triangle\",\n" +
          "        \"plot_color\": \"#111111\",\n" +
          "        \"plot_size\": 3,\n" +
          "        \"line_type\": \"Solid\",\n" +
          "        \"line_color\": \"#222222\",\n" +
          "        \"line_thickness\": 2,\n" +
          "        \"max\": 10,\n" +
          "        \"min\": 1\n" +
          "    },\n" +
          "    {\n" +
          "        \"is_bp\": true,\n" +
          "        \"cd\": \"91\",\n" +
          "        \"type\": 1,\n" +
          "        \"plot_type\": \"triangle-b\",\n" +
          "        \"plot_color\": \"#999999\",\n" +
          "        \"plot_size\": 2,\n" +
          "        \"line_type\": \"Solid\",\n" +
          "        \"line_color\": \"#999999\",\n" +
          "        \"line_thickness\": 1,\n" +
          "        \"max\": 250,\n" +
          "        \"min\": 0\n" +
          "    }\n" +
          "]");
      }
    };

    // mockで返却するOrdMain
    OrdMain ordMain = new OrdMain();
    ordMain.setFacilityCd("test");

    // Mock
    given(ordMainDao.selectMstTreatmentByOrdNo(ordNo)).willReturn(mstTreatment);
    given(ordMainDao.selectByOrdNo(ordNo)).willReturn(ordMain);

    // 実行
    List<ReportChartServiceImpl.ReportGraphSetting> result = invokeGetReportGraphSettingByOrdNo(ordNo);

    // 検証
    verify(ordMainDao, times(1)).selectMstTreatmentByOrdNo(ordNo);
    verify(ordMainDao, times(1)).selectByOrdNo(ordNo);
    assertNotNull(result);
    assertThat(result.size(), is(2));
    // 取得の確認(1件目)
    assertThat(result.get(0).isBp(), is(false));
    assertThat(result.get(0).getCd(), is("90"));
    assertThat(result.get(0).getType(), is(1));
    assertThat(result.get(0).getPlotType(), is("triangle"));
    assertThat(result.get(0).getPlotColor(), is("#111111"));
    assertThat(result.get(0).getPlotSize(), is(3));
    assertThat(result.get(0).getLineType(), is("Solid"));
    assertThat(result.get(0).getLineColor(), is("#222222"));
    assertThat(result.get(0).getLineThickness(), is(2));
    assertThat(result.get(0).getMax(), is(Double.parseDouble("10.0")));
    assertThat(result.get(0).getMin(), is(Double.parseDouble("1.0")));
    assertNotNull(result.get(0).getName());
    // 取得の確認(2件目)
    assertThat(result.get(1).isBp(), is(true));
    assertThat(result.get(1).getCd(), is("91"));
    assertThat(result.get(1).getType(), is(1));
    assertThat(result.get(1).getPlotType(), is("triangle-b"));
    assertThat(result.get(1).getPlotColor(), is("#999999"));
    assertThat(result.get(1).getPlotSize(), is(2));
    assertThat(result.get(1).getLineType(), is("Solid"));
    assertThat(result.get(1).getLineColor(), is("#999999"));
    assertThat(result.get(1).getLineThickness(), is(1));
    assertThat(result.get(1).getMax(), is(Double.parseDouble("250.0")));
    assertThat(result.get(1).getMin(), is(Double.parseDouble("0.0")));
    assertNotNull(result.get(1).getName());
  }

  /**
   * getReportGraphSettingByOrdNo(Long)(privateメソッド)の検証
   *
   * <p>
   *   条件:指示情報及び実績情報の治療方法コードが未設定である事.
   *   結果:空のリストが返却される事.
   * </p>
   *
   * @throws {@link Throwable} privateメソッドinvokeに失敗した場合
   */
  @Test
  public void test_invokeGetReportGraphSettingByOrdNo_異常_指示情報及び実績情報の治療方法コードが未設定の場合() throws Throwable {
    // 事前準備
    Long ordNo = 1L;

    // mockで返却するOrdMain
    OrdMain ordMain = new OrdMain();
    ordMain.setFacilityCd("test");

    // Mock
    given(ordMainDao.selectMstTreatmentByOrdNo(ordNo)).willReturn(null);
    given(ordMainDao.selectByOrdNo(ordNo)).willReturn(ordMain);

    // 実行
    List<ReportChartServiceImpl.ReportGraphSetting> result = invokeGetReportGraphSettingByOrdNo(ordNo);

    // 検証
    verify(ordMainDao, times(1)).selectMstTreatmentByOrdNo(ordNo);
    verify(ordMainDao, times(1)).selectByOrdNo(ordNo);
    assertNotNull(result);
    assertThat(result.size(), is(0));
  }

  /**
   * getReportGraphSettingByOrdNo(Long)(privateメソッド)の検証
   *
   * <p>
   *   条件:指示情報及び実績情報の治療方法コードの帳票グラフ設定が未設定である事.
   *   結果:空のリストが返却される事.
   * </p>
   *
   * @throws {@link Throwable} privateメソッドinvokeに失敗した場合
   */
  @Test
  public void test_invokeGetReportGraphSettingByOrdNo_異常_帳票グラフ設定が未設定の場合() throws Throwable {
    // 事前準備
    Long ordNo = 1L;

    // mockで返却する治療方法マスタ
    MstTreatment mstTreatment = new MstTreatment(){
      {
        setTreatmentCd(1);
        setTreatmentName("テスト治療方法");
        setReportGraphSetting(null);
      }
    };

    // mockで返却するOrdMain
    OrdMain ordMain = new OrdMain();
    ordMain.setFacilityCd("test");

    // Mock
    given(ordMainDao.selectMstTreatmentByOrdNo(ordNo)).willReturn(mstTreatment);
    given(ordMainDao.selectByOrdNo(ordNo)).willReturn(ordMain);


    // 実行
    List<ReportChartServiceImpl.ReportGraphSetting> result = invokeGetReportGraphSettingByOrdNo(ordNo);

    // 検証
    verify(ordMainDao, times(1)).selectMstTreatmentByOrdNo(ordNo);
    verify(ordMainDao, times(1)).selectByOrdNo(ordNo);
    assertNotNull(result);
    assertThat(result.size(), is(0));
  }

  /**
   * ConvertReportGraphSettingToSysMonitorItem(List)(privateメソッド)の検証
   *
   * <p>
   *   条件:有効な帳票グラフ設定のリストを与える事.
   *   結果:{@link SysMonitorItem}のリストが取得出来る事.
   * </p>
   */
  @Test
  public void test_invokeConvertReportGraphSettingToSysMonitorItem_正常_帳票グラフ設定が登録されている場合() throws Throwable {
    // 事前準備
    ReportChartServiceImpl.ReportGraphSetting data1 = new ReportChartServiceImpl.ReportGraphSetting(){
      {
        setBp(false);
        setCd("100");
        setType(1);
        setPlotType("AAA");
        setPlotColor("Color1");
        setPlotSize(2);
        setLineType("BBB");
        setLineColor("Color2");
        setLineThickness(3);
        setMax(100D);
        setMin(10D);
      }
    };

    ReportChartServiceImpl.ReportGraphSetting data2 = new ReportChartServiceImpl.ReportGraphSetting(){
      {
        setBp(true);
        setCd("200");
        setType(4);
        setPlotType("CCC");
        setPlotColor("Color3");
        setPlotSize(5);
        setLineType("DDD");
        setLineColor("Color4");
        setLineThickness(6);
        setMax(200D);
        setMin(20D);
      }
    };

    List<ReportChartServiceImpl.ReportGraphSetting> param = new ArrayList<>();
    param.add(data1);
    param.add(data2);

    // 実行
    List<SysMonitorItem> result = invokeConvertReportGraphSettingToSysMonitorItem(param);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(2));
    assertThat(result.get(0).getMoniDataNo(), is("100"));
    assertThat(result.get(1).getMoniDataNo(), is("200"));
  }

  /**
   * convertReportGraphSettingToSysMonitorItem(List)(privateメソッド)の検証
   *
   * <p>
   *   条件:有効な帳票グラフ設定のリストを与える事.
   *   結果:空のリストが取得出来る事.
   * </p>
   */
  @Test
  public void test_invokeConvertReportGraphSettingToSysMonitorItem_異常_帳票グラフ設定が登録されていない場合() throws Throwable {
    // 実行
    List<SysMonitorItem> result = invokeConvertReportGraphSettingToSysMonitorItem(Collections.emptyList());

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(0));
  }

  /**
   * createPlotData(Map)(privateメソッド)の検証
   *
   * <p>
   *   条件:モニタデータが存在する事.
   *        ※モニタデータに空のデータ及び<code>null</code>が含まれる事.
   *   結果:プロット用のデータのリストが取得出来る事.
   *        モニタデータが空のデータ及び<code>null</code>は含まれない事.
   * </p>
   */
  @Test
  public void test_invokeCreatePlotData_正常_モニタデータが存在する場合() throws Throwable {
    // 事前準備
    Map<Timestamp, String> monitorData = new TreeMap<>();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    // 1件目
    monitorData.put(new Timestamp(sdf.parse("2020-06-23 10:00:00").getTime()), "12.3");
    monitorData.put(new Timestamp(sdf.parse("2020-06-23 10:05:00").getTime()), "45.6");
    monitorData.put(new Timestamp(sdf.parse("2020-06-23 10:10:00").getTime()), "");
    monitorData.put(new Timestamp(sdf.parse("2020-06-23 10:15:00").getTime()), "78.9");
    monitorData.put(new Timestamp(sdf.parse("2020-06-23 10:20:00").getTime()), null);

    // 実行
    List<String> result = invokeCreatePlotData(monitorData);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(3));

    // 1件目
    assertThat(result.get(0), is(String.format("[%d, %f]", sdf.parse("2020-06-23 10:00:00").getTime(), new BigDecimal("12.3"))));
    assertThat(result.get(1), is(String.format("[%d, %f]", sdf.parse("2020-06-23 10:05:00").getTime(), new BigDecimal("45.6"))));
    assertThat(result.get(2), is(String.format("[%d, %f]", sdf.parse("2020-06-23 10:15:00").getTime(), new BigDecimal("78.9"))));
}

  /**
   * createPlotData(Map)(privateメソッド)の検証
   *
   * <p>
   *   条件:モニタデータが存在しない(空リスト)事.
   *   結果:空のリストが取得出来る事.
   * </p>
   */
  @Test
  public void test_invokeCreatePlotData_異常_モニタデータが存在しない場合() throws Throwable {
    // テスト用データ
    Map<Timestamp, String> monitorData = new TreeMap<>();

    // 実行
    List<String> result = invokeCreatePlotData(monitorData);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(0));
  }

  /**
   * getChartJson(privateメソッド)の検証
   *
   * <p>
   *   条件:ファイルが存在する事.
   *   結果:文字列が取得出来る事.
   * </p>
   * @throws Throwable
   */
  @Test
  public void test_invokeGetChartJson_正常_ファイルが存在する場合() throws Throwable {
    // 実行
    String result = invokeGetChartJson();

    // 検証
    assertNotNull(result);
  }

  /**
   * isBp(privateメソッド)の検証
   *
   * <p>
   *   条件:最高血圧のモニタ項目コードである事.
   *   結果:<code>true</code>が取得出来る事.
   * </p>
   * @throws Throwable
   */
  @Test
  public void test_isBp_正常_最高血圧のモニタ項目コードの場合() throws Throwable {
    // 実行
    boolean result = invokeIsBp("90");

    // 検証
    assertTrue(result);
  }

  /**
   * isBp(privateメソッド)の検証
   *
   * <p>
   *   条件:最低血圧のモニタ項目コードである事.
   *   結果:<code>true</code>が取得出来る事.
   * </p>
   * @throws Throwable
   */
  @Test
  public void test_isBp_正常_最低血圧のモニタ項目コードの場合() throws Throwable {
    // 実行
    boolean result = invokeIsBp("91");

    // 検証
    assertTrue(result);
  }

  /**
   * isBp(privateメソッド)の検証
   *
   * <p>
   *   条件:平均血圧のモニタ項目コードである事.
   *   結果:<code>true</code>が取得出来る事.
   * </p>
   * @throws Throwable
   */
  @Test
  public void test_isBp_正常_平均血圧のモニタ項目コードの場合() throws Throwable {
    // 実行
    boolean result = invokeIsBp("92");

    // 検証
    assertTrue(result);
  }

  /**
   * isBp(privateメソッド)の検証
   *
   * <p>
   *   条件:血圧のモニタ項目コード以外である事.
   *   結果:<code>false</code>が取得出来る事.
   * </p>
   * @throws Throwable
   */
  @Test
  public void test_isBp_正常_血圧以外のモニタ項目コードの場合() throws Throwable {
    // 実行
    boolean result = invokeIsBp("100");

    // 検証
    assertFalse(result);
  }

  /**
   * isDecimal(privateメソッド)の検証
   *
   * <p>
   *   条件:小数値である事.
   *   結果:<code>true</code>が取得出来る事.
   * </p>
   * @throws Throwable
   */
  @Test
  public void test_isDecimal_正常_小数値の場合() throws Throwable {
    // 実行
    boolean result = invokeIsDecimal(1.1);

    // 検証
    assertTrue(result);
  }

  /**
   * isDecimal(privateメソッド)の検証
   *
   * <p>
   *   条件:整数値である事.
   *   結果:<code>false</code>が取得出来る事.
   * </p>
   * @throws Throwable
   */
  @Test
  public void test_isDecimal_正常_整数値の場合() throws Throwable {
    // 実行
    boolean result = invokeIsDecimal(1.0);

    // 検証
    assertFalse(result);
  }
}


