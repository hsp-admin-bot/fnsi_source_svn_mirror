package jp.co.nikkiso.ntss.api.service.report;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.hasEntry;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.anyLong;
import static org.mockito.BDDMockito.anyString;
import static org.mockito.BDDMockito.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.never;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import org.jsoup.Jsoup;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.api.domain.report.ReportXmlConv;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlFilter;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlFormatCondition;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlGroup;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlParam;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlTmplRepeat;
import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.api.service.utils.ReportZipFile;
import jp.co.nikkiso.ntss.core.dao.MstFunctionReportDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.entity.MstFunctionReport;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.exception.NtssException;


@RunWith(SpringRunner.class)
@SpringBootTest
public class ReportServiceImplTest {
  /**
   * テスト対象クラス
   */
  @Autowired
  private ReportService target;

  /**
   * 帳票取得のServiceのMockBean.
   */
  @MockitoBean
  private ReportS3Service reportS3Service;

  /**
   * 機能帳票マスタDaoのMockBean.
   */
  @MockitoBean
  private MstFunctionReportDao mstFunctionReportDao;

  /**
   * 帳票マスタDaoのMockBean.
   */
  @MockitoBean
  private MstReportDao mstReportDao;

  /**
   * SysDataSetから帳票出力情報を取得するServiceのMockBean.
   */
  @MockitoBean
  private SysDataSetService sysDataSetService;

  /**
   * 例外の発生をテストするためのルール
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * getSqlCode(privateメソッド)をinvokeする.
   *
   * @param params Param要素情報
   * @return SQLCODEリスト
   * @throws Throwable
   */
  @SuppressWarnings("unchecked")
  private List<String> invokeGetSqlCode(List<ReportXmlParam> params) throws Throwable {
    try {
      Method method = ReportServiceImpl.class.getDeclaredMethod("getSqlCode", List.class);
      method.setAccessible(true);
      return (List<String>) method.invoke(target, params);
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
   * convertDataCodeToId(privateメソッド)をinvokeする.
   *
   * @param params Param要素情報
   * @param reportOutputInfo 帳票出力情報
   * @return 変換後の帳票出力情報
   * @throws Throwable
   */
  @SuppressWarnings("unchecked")
  private Map<String, String> invokeConvertDataCodeToId(List<ReportXmlParam> params, Map<Long, List<Map<String, Object>>> reportOutputInfo) throws Throwable {
    try {
      Method method = ReportServiceImpl.class.getDeclaredMethod("convertDataCodeToId", List.class, Map.class);
      method.setAccessible(true);
      return (Map<String, String>) method.invoke(target, params, reportOutputInfo);
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
   * filterReportInfo(privateメソッド)をinvokeする.
   *
   * @param param Param要素情報
   * @param reportInfo 帳票出力情報
   * @throws Throwable
   */
  @SuppressWarnings("unchecked")
  private List<Map<String, Object>> invokeFilterReportInfo(ReportXmlParam param, List<Map<String, Object>> reportInfo) throws Throwable {
    try {
      Method method = ReportServiceImpl.class.getDeclaredMethod("filterReportInfo", ReportXmlParam.class, List.class);
      method.setAccessible(true);
      return (List<Map<String, Object>>) method.invoke(target, param, reportInfo);
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
   * formatValue(privateメソッド)をinvokeする.
   *
   * @param param Param要素情報
   * @param value 値
   * @throws Throwable
   */
  @SuppressWarnings("unchecked")
  private String invokeFormatValue(ReportXmlParam param, Object value) throws Throwable {
    try {
      Method method = ReportServiceImpl.class.getDeclaredMethod("formatValue", ReportXmlParam.class, Object.class);
      method.setAccessible(true);
      return (String) method.invoke(target, param, value);
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
   * convertValue(privateメソッド)をinvokeする.
   *
   * @param param Param要素情報
   * @param value 値
   * @throws Throwable
   */
  @SuppressWarnings("unchecked")
  private String invokeConvertValue(ReportXmlParam param, String value) throws Throwable {
    try {
      Method method = ReportServiceImpl.class.getDeclaredMethod("convertValue", ReportXmlParam.class, String.class);
      method.setAccessible(true);
      return (String) method.invoke(target, param, value);
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
   * getCalcResult(privateメソッド)をinvokeする.
   *
   * @param params Param要素情報
   * @param reportInfo 帳票出力情報
   * @throws Throwable
   */
  @SuppressWarnings("unchecked")
  private Map<String, String> invokeGetCalcResult(List<ReportXmlParam> params, Map<Long, List<Map<String, Object>>> reportInfo) throws Throwable {
    try {
      Method method = ReportServiceImpl.class.getDeclaredMethod("getCalcResult", List.class, Map.class);
      method.setAccessible(true);
      return (Map<String, String>) method.invoke(target, params, reportInfo);
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
   * calcOfFormula(privateメソッド)をinvokeする.
   *
   * @param formula 計算式
   * @return 計算結果
   * @throws Throwable
   */
  @SuppressWarnings("unchecked")
  private String invokeCalcOfFormula(String formula) throws Throwable {
    try {
      Method method = ReportServiceImpl.class.getDeclaredMethod("calcOfFormula", String.class);
      method.setAccessible(true);
      return (String) method.invoke(target, formula);
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
   * reflectReportHtml(privateメソッド)をinvokeする.
   *
   * @param reportHtml 帳票デザインHTML
   * @param reportOutputInfo 帳票出力情報
   * @param calcResult 計算結果
   * @param formatConditionInfo 条件付き書式情報
   * @return 反映後の帳票デザインHTML
   * @throws Throwable
   */
  @SuppressWarnings("unchecked")
  private String invokeReflectReportHtml(
    String reportHtml,
    Map<String, String> reportOutputInfo,
    Map<String, String> calcResult,
    Map<String, String> formatConditionInfo,
    Map<String, String> chartInfo,
    Map<String, String[]> resizeFontSizeInfo
  ) throws Throwable {
    try {
      Method method = ReportServiceImpl.class.getDeclaredMethod("reflectReportHtml", String.class, Map.class, Map.class, Map.class, Map.class, Map.class);
      method.setAccessible(true);
      return (String) method.invoke(target, reportHtml, reportOutputInfo, calcResult, formatConditionInfo, chartInfo, resizeFontSizeInfo);
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
   * createFormatConditionInfo(privateメソッド)をinvokeする.
   *
   * @param params Param要素情報
   * @param reportOutputInfo 帳票出力情報
   * @param reportCd レポートCD
   * @throws Throwable
   */
  @SuppressWarnings("unchecked")
  private Map<String, String> invokeCreateFormatConditionInfo(List<ReportXmlParam> params, Map<String, String> reportOutputInfo, Long reportCd) throws Throwable {
    try {
      Method method = ReportServiceImpl.class.getDeclaredMethod("createFormatConditionInfo", List.class, Map.class, Long.class);
      method.setAccessible(true);
      return (Map<String, String>) method.invoke(target, params, reportOutputInfo, reportCd);
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
   * createResizeFontSizeInfo(privateメソッド)をinvokeする.
   *
   * @param reportHtml 帳票デザインHTML
   * @param params Param要素情報
   * @param reportOutputInfo 帳票出力情報
   * @param formatConditionInfo 条件付き書式情報
   * @throws Throwable
   */
  @SuppressWarnings("unchecked")
  private Map<String, String[]> invokeCreateResizeFontSizeInfo(String reportHtml, List<ReportXmlParam> params, Map<String, String> reportOutputInfo, Map<String, String> formatConditionInfo) throws Throwable {
    try {
      Method method = ReportServiceImpl.class.getDeclaredMethod("createResizeFontSizeInfo", String.class, List.class, Map.class, Map.class);
      method.setAccessible(true);
      return (Map<String, String[]>) method.invoke(target, reportHtml, params, reportOutputInfo, formatConditionInfo);
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
   * getMstReport()の検証.
   *
   * 条件：指定された帳票番号に該当する帳票マスタが存在する
   * 結果：帳票マスタエンティティが返却されること
   */
  @Test
  public void test_getMstReport_成功_データあり() throws Throwable {
    // 事前準備
    Long reportCd = 10L;
    MstReport expected = new MstReport();

    // Mock化
    given(mstReportDao.selectByCd(reportCd)).willReturn(expected);

    // 実行
    MstReport result = target.getMstReport(reportCd);

    // 検証
    verify(mstReportDao, times(1)).selectByCd(reportCd);
    assertThat(result, is(expected));
  }

  /**
   * getMstReport()の検証.
   *
   * 条件：指定された帳票番号に該当する帳票マスタが存在しない
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getMstReport_異常_データなし() throws Throwable {
    // 事前準備
    Long reportCd = 12L;

    // Mock化
    given(mstReportDao.selectByCd(reportCd)).willThrow(EmptyResultDataAccessException.class);

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("");
    target.getMstReport(reportCd);
  }

  /**
   * getMstReport()の検証.
   *
   * 条件：機能コード、施設コードに該当する機能帳票マスタが存在し、レポートCDに該当する帳票マスタが存在する
   * 結果：帳票マスタエンティティが返却されること
   */
  @Test
  public void test_getMstReport_成功_機能帳票マスタデータあり_帳票マスタデータあり() {
    // 事前準備
    final String funcCd = "001";
    final String facilityCd = "000001";

    final Long reportCd1 = 1L;
    final Long reportCd2 = 2L;
    final Long reportCd3 = 3L;

    List<MstFunctionReport> mstFunctionReports = Arrays.asList(
      new MstFunctionReport() {
        {
          setReportCd(reportCd1);
        }
      }
      ,new MstFunctionReport() {
        {
          setReportCd(reportCd2);
        }
      }
    );
    MstReport mstReport1 = new MstReport() {
      {
        setReportCd(reportCd1);
        //setExtractionCondition("[\"pat_id\"]");
        setIsDisp("1");
        setIsDel("0");
      }
    };
    MstReport mstReport2 = new MstReport() {
      {
        setReportCd(reportCd2);
        //setExtractionCondition("[\"ord_no\"]");
        setIsDisp("1");
        setIsDel("0");
      }
    };
    MstReport mstReport3 = new MstReport() {
      {
        setReportCd(reportCd3);
        //setExtractionCondition("[\"ord_no\"]");
        setIsDisp("1");
        setIsDel("0");
      }
    };

    // Mock化
    given(mstFunctionReportDao.selectByFunctionCdAndFacilityCd(funcCd, facilityCd,null)).willReturn(mstFunctionReports);
    given(mstReportDao.selectAll(facilityCd)).willReturn(Arrays.asList(mstReport2, mstReport1, mstReport3));

    // 実行
    List<MstReport> result = target.getMstReport(funcCd, facilityCd,null);

    // 検証
    verify(mstFunctionReportDao, times(1)).selectByFunctionCdAndFacilityCd(anyString(), anyString(),null);
    verify(mstReportDao, times(1)).selectAll(anyString());
    assertThat(result, hasSize(2));
    assertThat(result.get(0), is(mstReport1));
    assertThat(result.get(1), is(mstReport2));
  }

  /**
   * getMstReport()の検証.
   *
   * 条件：機能コード、施設コードに該当する機能帳票マスタが存在し、レポートCDに該当する帳票マスタが削除済
   * 結果：空のリストが返却されること
   */
  @Test
  public void test_getMstReport_成功_機能帳票マスタデータあり_帳票マスタデータなし() {
    // 事前準備
    final String funcCd = "001";
    final String facilityCd = "000001";

    final Long reportCd1 = 1L;
    final Long reportCd2 = 2L;

    List<MstFunctionReport> mstFunctionReports = Arrays.asList(
      new MstFunctionReport() {
        {
          setReportCd(reportCd1);
        }
      }
      ,new MstFunctionReport() {
        {
          setReportCd(reportCd2);
        }
      }
    );
    MstReport mstReport1 = new MstReport() {
        {
          setReportCd(reportCd1);
          //setExtractionCondition("[\"pat_id\"]");
          setIsDisp("1");
          setIsDel("1");
        }
      };
      MstReport mstReport2 = new MstReport() {
        {
          setReportCd(reportCd2);
          //setExtractionCondition("[\"ord_no\"]");
          setIsDisp("0");
          setIsDel("0");
        }
      };

    // Mock化
    given(mstFunctionReportDao.selectByFunctionCdAndFacilityCd(funcCd, facilityCd,null)).willReturn(mstFunctionReports);
    given(mstReportDao.selectAll(facilityCd)).willReturn(Arrays.asList(mstReport1, mstReport2));

    // 実行
    List<MstReport> result = target.getMstReport(funcCd, facilityCd,null);

    // 検証
    verify(mstFunctionReportDao, times(1)).selectByFunctionCdAndFacilityCd(anyString(), anyString(),null);
    verify(mstReportDao, times(1)).selectAll(anyString());
    assertThat(result, hasSize(0));
  }

  /**
   * getMstReport()の検証.
   *
   * 条件：機能コード、施設コードに該当する機能帳票マスタが存在しない
   * 結果：空のリストが返却されること
   */
  @Test
  public void test_getMstReport_成功_機能帳票マスタデータなし() {
    // 事前準備
    final String funcCd = "001";
    final String facilityCd = "000001";

    List<MstFunctionReport> mstFunctionReports = Collections.EMPTY_LIST;

    // Mock化
    given(mstFunctionReportDao.selectByFunctionCdAndFacilityCd(funcCd, facilityCd,null)).willReturn(mstFunctionReports);
    given(mstReportDao.selectByCd(anyLong())).willThrow(EmptyResultDataAccessException.class);

    // 実行
    List<MstReport> result = target.getMstReport(funcCd, facilityCd,null);

    // 検証
    verify(mstFunctionReportDao, times(1)).selectByFunctionCdAndFacilityCd(anyString(), anyString(),null);
    verify(mstReportDao, times(0)).selectByCd(anyLong());
    assertThat(result, hasSize(0));
  }

  /**
   * getMstReport()の検証.
   *
   * 条件：指定された帳票種別、帳票区分、施設コードに該当する帳票マスタが存在する
   * 結果：帳票マスタエンティティが返却されること
   */
  @Test
  public void test_getMstReport_帳票種別_帳票区分_施設コード_成功_データあり() throws Throwable {
    // 事前準備
    Integer reportClass = 1;
    Integer reportType = 2;
    String facilityCd = "3";
    MstReport expected1 = new MstReport() {
      {
        setReportCd(1L);
      }
    };
    MstReport expected2 = new MstReport() {
      {
        setReportCd(2L);
      }
    };
    List<MstReport> mstReports = Arrays.asList(expected1, expected2);

    // Mock化
    given(mstReportDao.selectReports(reportClass, reportType, facilityCd)).willReturn(mstReports);

    // 実行
    MstReport result = target.getMstReport(reportClass, reportType, facilityCd);

    // 検証
    verify(mstReportDao, times(1)).selectReports(reportClass, reportType, facilityCd);
    assertThat(result, is(expected1));
  }

  /**
   * getMstReport()の検証.
   *
   * 条件：指定された帳票種別、帳票区分、施設コードに該当する帳票マスタが存在しない
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getMstReport_帳票種別_帳票区分_施設コード_異常_データなし() throws Throwable {
    // 事前準備
    Integer reportClass = 1;
    Integer reportType = 2;
    String facilityCd = "3";

    // Mock化
    given(mstReportDao.selectReports(reportClass, reportType, facilityCd)).willThrow(EmptyResultDataAccessException.class);

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("");
    target.getMstReport(reportClass, reportType, facilityCd);
  }

  /**
   * getReportHtml()の検証.
   *
   * 条件：指定された帳票コードに該当する帳票マスタが存在する
   * 結果：responseを返す
   */
  @Test
  public void test_getReportHtml_正常取得() throws Throwable {
    // 事前準備
    Long reportCd = 1L;
    @SuppressWarnings("serial")
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("param1", "value1");
        put("param2", "value2");
      }
    };
    Long targetPrinter = 1L;
    Long userId = 99999L;

    String reportZip = "テスト透析レポート.zip";
    String htmlName = "testDialysisReport.html";
    String xmlName = "testDialysisReport.xml";
    String bucket = "ntss-esm";

    MstReport mstReport = new MstReport();
    mstReport.setReportCd(reportCd);
    mstReport.setReportClass(ReportConstant.ReportClass.DIALYSIS_REPORT);
    MstReport.ReportPath reportPath = new MstReport.ReportPath();
    reportPath.setReportZip(reportZip);
    reportPath.setHtmlFilename(htmlName);
    reportPath.setXmlFilename(xmlName);
    reportPath.setBucket(bucket);
    mstReport.setReportPath(reportPath);

    Path path = Paths.get(getClass().getClassLoader().getResource("resource.report/" + reportZip).toURI());
    byte[] bytes = Files.readAllBytes(path);
    ReportZipFile zip = new ReportZipFile(bytes);

    String reportHtml = zip.getFileToString(htmlName);

    List<Map<String, Object>> reportOutputInfo1 = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("1", "test1");
          put("4", "test2");
          put("10", "10");
          put("11", "8");
        }
      });
    List<Map<String, Object>> reportOutputInfo2 = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("3", "test3");
        }
      });

    org.jsoup.nodes.Document document = Jsoup.parse(reportHtml);
    document.getElementById("M1:O1").text("test1");
    document.getElementById("M1:O3").text("test3");
    document.getElementById("M1:O4").text("test2");
    document.getElementById("M1:O5").text("2");
    String expected = document.html();

    // Mock化
    given(mstReportDao.selectByCd(reportCd)).willReturn(mstReport);
    given(reportS3Service.getReportFile(bucket, reportZip, null)).willReturn(bytes);
    given(sysDataSetService.getDataList(1L, dataKey)).willReturn(reportOutputInfo1);
    given(sysDataSetService.getDataList(3L, dataKey)).willReturn(reportOutputInfo2);

    // 実行
    String result = target.getReportHtml(reportCd, dataKey, targetPrinter, userId);

    // 検証
    verify(mstReportDao, times(1)).selectByCd(reportCd);
    verify(reportS3Service, times(1)).getReportFile(bucket, reportZip, null);
    verify(sysDataSetService, times(1)).getDataList(eq(1L), eq(dataKey));
    verify(sysDataSetService, times(1)).getDataList(eq(3L), eq(dataKey));
    assertThat(result, is(expected));
  }

  /**
   * getReportHtml()の検証.
   *
   * 条件：指定された帳票コードに該当する帳票マスタが存在しない
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getReportHtml_異常_該当データなし() throws Exception {
    // 事前準備
    Long reportCd = 99999L;
    @SuppressWarnings("serial")
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("param1", "value1");
        put("param2", "value2");
      }
    };
    Long targetPrinter = 1L;
    Long userId = 99999L;

    // Mock化
    given(mstReportDao.selectByCd(reportCd)).willThrow(EmptyResultDataAccessException.class);
    given(sysDataSetService.getDataList(any(), any())).willReturn(Collections.emptyList());

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("");
    verify(sysDataSetService, never()).getDataList(any(), any());
    target.getReportHtml(reportCd, dataKey, targetPrinter, userId);
  }

  /**
   * getReportHtml()の検証.
   *
   * 条件：指定された帳票コードに該当する帳票マスタが存在するが帳票種別未指定の場合
   * 結果：空のhtmlが返却される事
   */
  @Test
  public void test_getReportHtml_異常_帳票種別未指定() throws Throwable {
    // 事前準備
    Long reportCd = 1L;
    @SuppressWarnings("serial")
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("param1", "value1");
        put("param2", "value2");
      }
    };
    Long targetPrinter = 1L;
    Long userId = 99999L;

    String reportZip = "テスト透析レポート.zip";
    String htmlName = "testDialysisReport.html";
    String xmlName = "testDialysisReport.xml";
    String bucket = "ntss-esm";

    MstReport mstReport = new MstReport();
    mstReport.setReportCd(reportCd);
    MstReport.ReportPath reportPath = new MstReport.ReportPath();
    reportPath.setReportZip(reportZip);
    reportPath.setHtmlFilename(htmlName);
    reportPath.setXmlFilename(xmlName);
    reportPath.setBucket(bucket);
    mstReport.setReportPath(reportPath);

    Path path = Paths.get(getClass().getClassLoader().getResource("resource.report/" + reportZip).toURI());
    byte[] bytes = Files.readAllBytes(path);
    ReportZipFile zip = new ReportZipFile(bytes);

    String reportHtml = zip.getFileToString(htmlName);

    List<Map<String, Object>> reportOutputInfo1 = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("1", "test1");
          put("4", "test2");
          put("10", "10");
          put("11", "8");
        }
      });
    List<Map<String, Object>> reportOutputInfo2 = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("3", "test3");
        }
      });

    // Mock化
    given(mstReportDao.selectByCd(reportCd)).willReturn(mstReport);
    given(reportS3Service.getReportFile(bucket, reportZip, null)).willReturn(bytes);
    given(sysDataSetService.getDataList(1L, dataKey)).willReturn(reportOutputInfo1);
    given(sysDataSetService.getDataList(3L, dataKey)).willReturn(reportOutputInfo2);

    // 実行
    String result = target.getReportHtml(reportCd, dataKey, targetPrinter, userId);

    // 検証
    verify(mstReportDao, times(1)).selectByCd(reportCd);
    verify(reportS3Service, times(0)).getReportFile(bucket, reportZip, null);
    verify(sysDataSetService, times(0)).getDataList(eq(1L), eq(dataKey));
    verify(sysDataSetService, times(0)).getDataList(eq(3L), eq(dataKey));
    assertThat(result, is(""));
  }

  /**
   * getSqlCode()の検証.
   *
   * 条件：指定されたParam要素情報にSQLCODEが存在する
   * 結果：SQLCODEのリストが返却されること
   */
  @Test
  public void test_getSqlCode_成功_データあり() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
    //    List<ReportXmlParam> params = Arrays.asList(
    //      ReportXmlParam.of(null,"1", "", "", "1", "", "", "", "", "", null, null, null, "", "null, null, null, null, null, null, null, null)
    //      , ReportXmlParam.of(null,"2", "", "", "2", "", "", "", "", "", null, null, null, "", null, null, null, null, null, null, null, null)
    //      , ReportXmlParam.of(null,"3", "", "", "2", "", "", "", "", "", null, null, null, "", null, null, null, null, null, null, null, null)
    //      , ReportXmlParam.of(null,"4", "", "", "3", "", "", "", "", "", null, null, null, "", null, null, null, null, null, null, null, null)
    //      , ReportXmlParam.of(null,"5", "", "", "", "", "", "", "", "", null, null, null, "",  null, null, null, null, null, null, null, null)
    //      , ReportXmlParam.of(null,"6", "", "", null, "", "", "", "", "", null, null, null, "", null, null, null, null, null, null, null, null)
    //      , ReportXmlParam.of(null,"7", "1", "", null, "", "", "", "", "[4.1]-[5.1]", null, null, "", null,  null, null, null, null, null, null, null, null)
    //    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"1", "", "", "1", "", "", "", "", "", null, null, null, "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"2", "", "", "2", "", "", "", "", "", null, null, null, "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"3", "", "", "2", "", "", "", "", "", null, null, null, "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"4", "", "", "3", "", "", "", "", "", null, null, null, "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"5", "", "", "", "", "", "", "", "", null, null, null, "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"6", "", "", null, "", "", "", "", "", null, null, null, "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"7", "1", "", null, "", "", "", "", "[4.1]-[5.1]", null, null, "", null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end

    List<String> expected = Arrays.asList("1", "2", "3", "4", "5");

    // 実行
    List<String> result = invokeGetSqlCode(params);

    // 検証
    assertThat(result).hasSize(5).containsExactly(expected.toArray(new String[expected.size()]));
  }

  /**
   * getSqlCode()の検証.
   *
   * 条件：指定されたParam要素情報が空のリスト
   * 結果：空のリストが返却されること
   */
  @Test
  public void test_getSqlCode_成功_データなし() throws Throwable {
    // 事前準備
    List<ReportXmlParam> params = Arrays.asList();

    // 実行
    List<String> result = invokeGetSqlCode(params);

    // 検証
    assertThat(result).hasSize(0);
  }

  /**
   * convertDataCodeToId()の検証.
   *
   * 条件：単一項目のParam要素情報と帳票出力情報が指定されている
   * 結果：帳票出力情報のkey項目に設定されている内容が データ項目コード -> id属性値 に変換されていること
   */
  @Test
  public void test_convertDataCodeToId_成功_単一項目_Param要素情報あり_帳票出力情報あり() throws Throwable {
    // 事前準備
    // id属性値、dataCode属性値、sqlCode属性値、groupId属性値
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"1", "", "1", "1", "", "", "", "", "", "", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"2", "", "1", "2", "", "", "", "", "", "", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"3", "", "2", "2", "", "", "", "", "", "", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"4", "", "1", "3", "", "", "", "", "", "", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"5", "", "3", "2", "", "", "", "", "", "", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"6", "", "1", "4", "", "", "", "", "", "", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"", "", "1", "5", "", "", "", "", "", "", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,null, "", "1", "6", "", "", "", "", "", "", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"10", "", "0", "10", "", "0", "5", "", "", "", "", "1", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"11", "", "1", "10", "", "0", "5", "", "", "", "", "1", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"12", "", "2", "10", "", "0", "5", "", "", "", "", "1", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"13", "", "3", "10", "", "0", "", "", "", "", "", "1", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"14", "", "4", "10", "", "0", "5", "", "", "", "", "", "", null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"15", "", "5", "10", "", "1", "5", "", "", "", "", "1", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"16", "", "6", "10", "", "0", "5", "", "", "", "", "1", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"17", "", "7", "10", "", "0", "5", "", "", "", "", "1", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"18", "", "8", "10", "", "0", "5", "", "", "", "", "1", "",  null, null, null, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"1", "", "1", "1", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"2", "", "1", "2", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"3", "", "2", "2", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"4", "", "1", "3", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"5", "", "3", "2", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"6", "", "1", "4", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"7", "", "1", "5", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"8", "", "1", "5", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"10", "", "0", "10", "", "0", "5", "", "", "", "", "1", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"11", "", "1", "10", "", "0", "5", "", "", "", "", "1", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"12", "", "2", "10", "", "0", "5", "", "", "", "", "1", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"13", "", "3", "10", "", "0", "", "", "", "", "", "1", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"14", "", "4", "10", "", "0", "5", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"15", "", "5", "10", "", "1", "5", "", "", "", "", "1", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"16", "", "6", "10", "", "0", "5", "", "", "", "", "1", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"17", "", "7", "10", "", "0", "5", "", "", "", "", "1", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"18", "", "8", "10", "", "0", "5", "", "", "", "", "1", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    // Map<SqlCode, List<Map<DataCode, Value>>>
    Map<Long, List<Map<String, Object>>> reportOutputInfo = new HashMap<Long, List<Map<String, Object>>>() {
      {
        put(1L, Arrays.asList(new HashMap<String, Object>() {
          {
            put("1", "1-1");
          }
        }));
        put(2L, Arrays.asList(new HashMap<String, Object>() {
          {
            put("1", "2-1");
            put("2", "2-2");
            put("3", "2-3");
          }
        }));
        put(3L, Arrays.asList(new HashMap<String, Object>() {
          {
            put("1", "3-1");
          }
        }));
        put(4L, Arrays.asList());
        put(10L, Arrays.asList(new HashMap<String, Object>() {
          {
            put("0", "12345");
            put("1", "123456");
            put("2", "12345678901");
            put("3", "12345678901");
            put("4", "12345678901");
            put("5", "12345678901");
            put("6", "１２3");
            put("7", "１２３");
            put("8", "１２34");
          }
        }));
      }
    };

    // Map<id属性値, Value>
    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("1", "1-1");
        put("2", "2-1");
        put("3", "2-2");
        put("4", "3-1");
        put("5", "2-3");
        put("10", "12345");
        put("1#11", "12345");
        put("2#11", "6");
        put("1#12", "12345");
        put("2#12", "67890");
        put("3#12", "1");
        put("13", "12345678901");
        put("14", "12345678901");
        put("15", "12345678901");
        put("16", "１２3");
        put("1#17", "１２");
        put("2#17", "３");
        put("1#18", "１２3");
        put("2#18", "4");
      }
    };

    // 実行
    Map<String, String> result = invokeConvertDataCodeToId(params, reportOutputInfo);

    // 検証
    assertThat(result.size(), is(expected.size()));
    assertThat(result, hasEntry("1", "1-1"));
    assertThat(result, hasEntry("2", "2-1"));
    assertThat(result, hasEntry("3", "2-2"));
    assertThat(result, hasEntry("4", "3-1"));
    assertThat(result, hasEntry("5", "2-3"));
    assertThat(result, hasEntry("10", "12345"));
    assertThat(result, hasEntry("1#11", "12345"));
    assertThat(result, hasEntry("2#11", "6"));
    assertThat(result, hasEntry("1#12", "12345"));
    assertThat(result, hasEntry("2#12", "67890"));
    assertThat(result, hasEntry("3#12", "1"));
    assertThat(result, hasEntry("13", "12345678901"));
    assertThat(result, hasEntry("14", "12345678901"));
    assertThat(result, hasEntry("15", "12345678901"));
    assertThat(result, hasEntry("16", "１２3"));
    assertThat(result, hasEntry("1#17", "１２"));
    assertThat(result, hasEntry("2#17", "３"));
    assertThat(result, hasEntry("1#18", "１２3"));
    assertThat(result, hasEntry("2#18", "4"));
  }

  /**
   * convertDataCodeToId()の検証.
   *
   * 条件：複数項目のParam要素情報と帳票出力情報が指定されている
   * 結果：帳票出力情報のkey項目に設定されている内容が データ項目コード -> id属性値 に変換されていること
   */
  @Test
  public void test_convertDataCodeToId_成功_複数項目_Param要素情報あり_帳票出力情報あり() throws Throwable {
    // 事前準備
    // id属性値、dataCode属性値、sqlCode属性値、groupId属性値、group要素
    ReportXmlGroup group22 = new ReportXmlGroup("22", 10, 1, "", Collections.EMPTY_LIST);
    ReportXmlGroup group23 = new ReportXmlGroup("23", 2, 1, "", Collections.EMPTY_LIST);
    ReportXmlGroup group24 = new ReportXmlGroup("24", 2, 0, "", Collections.EMPTY_LIST);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"1", "", "1", "1", "", "", "", "", "", "11", "", "", "", null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"2", "", "1", "2", "", "", "", "", "", "21", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"3", "", "2", "2", "", "", "", "", "", "22", "", "", "", null, group22, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"4", "", "3", "2", "", "", "", "", "", "23", "", "", "",  null, group23, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"5", "", "4", "2",  "", "", "", "", "", "", "24","", "",  null, group24, null, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"1", "", "1", "1", "", "", "", "", "", "11", "", "", "", "",  null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"2", "", "1", "2", "", "", "", "", "", "21", "", "", "", "",  null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"3", "", "2", "2", "", "", "", "", "", "22", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"4", "", "3", "2", "", "", "", "", "", "23", "", "", "", "",  null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"5", "", "4", "2",  "", "", "", "", "", "", "24","", "", "",  null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end

    // Map<SqlCode, List<Map<DataCode, Value>>>
    Map<Long, List<Map<String, Object>>> reportOutputInfo = new HashMap<Long, List<Map<String, Object>>>() {
      {
        put(1L, Arrays.asList(new HashMap<String, Object>() {
          {
            put("1", "1-1");
          }
        }));
        put(2L, Arrays.asList(
          new HashMap<String, Object>() {
            {
              put("1", "2-1-1");
              put("2", "2-1-2");
              put("3", "2-1-3");
              put("4", "2-1-4");
            }
          }
          , new HashMap<String, Object>() {
            {
              put("1", "2-2-1");
              put("2", "2-2-2");
              put("3", "2-2-3");
              put("4", "2-2-4");
            }
          }
          , new HashMap<String, Object>() {
            {
              put("1", "2-3-1");
              put("2", "2-3-2");
              put("3", "2-3-3");
              put("4", "2-3-4");
            }
          })
        );
      }
    };

    // Map<id属性値, Value>
    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("1#1-1", "1-1");
        put("1#2-1", "2-1-1");
        put("1#2-2", "2-2-1");
        put("1#2-3", "2-3-1");
        put("1#3-1", "2-1-2");
        put("1#3-2", "2-2-2");
        put("1#3-3", "2-3-2");
        put("1#4-1", "2-1-3");
        put("1#4-2", "2-2-3");
        put("2#4-1", "2-3-3");
        put("1#5-1", "2-1-4");
        put("1#5-2", "2-2-4");
      }
    };

    // 実行
    Map<String, String> result = invokeConvertDataCodeToId(params, reportOutputInfo);

    // 検証
    assertThat(result.size(), is(expected.size()));
    assertThat(result, hasEntry("1#1-1", "1-1"));
    assertThat(result, hasEntry("1#2-1", "2-1-1"));
    assertThat(result, hasEntry("1#2-2", "2-2-1"));
    assertThat(result, hasEntry("1#2-3", "2-3-1"));
    assertThat(result, hasEntry("1#3-1", "2-1-2"));
    assertThat(result, hasEntry("1#3-2", "2-2-2"));
    assertThat(result, hasEntry("1#3-3", "2-3-2"));
    assertThat(result, hasEntry("1#4-1", "2-1-3"));
    assertThat(result, hasEntry("1#4-2", "2-2-3"));
    assertThat(result, hasEntry("2#4-1", "2-3-3"));
    assertThat(result, hasEntry("1#5-1", "2-1-4"));
    assertThat(result, hasEntry("1#5-2", "2-2-4"));
  }

  /**
   * convertDataCodeToId()の検証.
   *
   * 条件：単一項目、複数項目が混在したParam要素情報と帳票出力情報が指定されている
   * 結果：帳票出力情報のkey項目に設定されている内容が データ項目コード -> id属性値 に変換されていること
   */
  @Test
  public void test_convertDataCodeToId_成功_単一項目_複数項目_混在_Param要素情報あり_帳票出力情報あり() throws Throwable {
    // 事前準備
    // id属性値、dataCode属性値、sqlCode属性値、groupId属性値
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"1", "", "1", "1", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"2", "", "1", "2", "", "", "", "", "", "22", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"3", "", "2", "2", "", "", "", "", "", "22", "", "", "",  null, null, null, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"1", "", "1", "1", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"2", "", "1", "2", "", "", "", "", "", "22", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"3", "", "2", "2", "", "", "", "", "", "22", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    // Map<SqlCode, List<Map<DataCode, Value>>>
    Map<Long, List<Map<String, Object>>> reportOutputInfo = new HashMap<Long, List<Map<String, Object>>>() {
      {
        put(1L, Arrays.asList(new HashMap<String, Object>() {
          {
            put("1", "1-1");
          }
        }));
        put(2L, Arrays.asList(
          new HashMap<String, Object>() {
            {
              put("1", "2-1-1");
              put("2", "2-1-2");
            }
          }
          , new HashMap<String, Object>() {
            {
              put("1", "2-2-1");
              put("2", "2-2-2");
            }
          })
        );
      }
    };

    // Map<id属性値, Value>
    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("1", "1-1");
        put("1#2-1", "2-1-1");
        put("1#2-2", "2-2-1");
        put("1#3-1", "2-1-2");
        put("1#3-2", "2-2-2");
      }
    };

    // 実行
    Map<String, String> result = invokeConvertDataCodeToId(params, reportOutputInfo);

    // 検証
    assertThat(result.size(), is(expected.size()));
    assertThat(result, hasEntry("1", "1-1"));
    assertThat(result, hasEntry("1#2-1", "2-1-1"));
    assertThat(result, hasEntry("1#2-2", "2-2-1"));
    assertThat(result, hasEntry("1#3-1", "2-1-2"));
    assertThat(result, hasEntry("1#3-2", "2-2-2"));
  }

  /**
   * convertDataCodeToId()の検証.
   *
   * 条件：テンプレート繰り返し情報と帳票出力情報が指定されている(改ページなし)
   * 結果：帳票出力情報のkey項目に設定されている内容が データ項目コード -> id属性値 に変換されていること
   */
  @Test
  public void test_convertDataCodeToId_成功_テンプレート繰り返し項目_改ページなし_Param要素情報あり_帳票出力情報あり() throws Throwable {
    // 事前準備
    ReportXmlTmplRepeat tmplRepeat = new ReportXmlTmplRepeat("tmpl", 0, 0, 0, 0, 2, "", "",0, "1", 0, 0);
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"1", "", "1", "1", "", "", "", "", "", "", "0", "", "", null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"2", "", "2", "1", "", "", "", "", "", "", "1", "", "", null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"3", "", "3", "1", "", "", "", "", "", "", "0", "", "", null, null, null, null, null, tmplRepeat, null, null)
//      , ReportXmlParam.of(null,"4", "", "1", "2", "", "", "", "", "", "", "1", "", "", null, null, null, null, null, tmplRepeat, null, null)
//      , ReportXmlParam.of(null,"5", "", "2", "2", "", "", "", "", "", "1", "1", "", "",", null, null, null, null, null, tmplRepeat, null, null)
//      , ReportXmlParam.of(null,"6", "", "1", "3", "", "", "", "", "", "", "1", "", "", null, null, null, null, null, tmplRepeat, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"1", "", "1", "1", "", "", "", "", "", "", "0", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"2", "", "2", "1", "", "", "", "", "", "", "1", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"3", "", "3", "1", "", "", "", "", "", "", "0", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"4", "", "1", "2", "", "", "", "", "", "", "1", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"5", "", "2", "2", "", "", "", "", "", "1", "1", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"6", "", "1", "3", "", "", "", "", "", "", "1", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end

    // Map<SqlCode, List<Map<DataCode, Value>>>
    Map<Long, List<Map<String, Object>>> reportOutputInfo = new HashMap<Long, List<Map<String, Object>>>() {
      {
        put(1L, Arrays.asList(new HashMap<String, Object>() {
          {
            put("1", "1-1");
            put("2", "1-2");
            put("3", "1-3");
          }
        }));
        put(2L, Arrays.asList(
          new HashMap<String, Object>() {
            {
              put("1", "2-1-1");
              put("2", "2-1-2");
            }
          }
          , new HashMap<String, Object>() {
            {
              put("1", "2-2-1");
              put("2", "2-2-2");
            }
          }
          , new HashMap<String, Object>() {
            {
              put("1", "2-3-1");
              put("2", "2-3-2");
            }
          })
        );
        put(3L, Arrays.asList(
          new HashMap<String, Object>() {
            {
              put("1", "3-1-1");
            }
          }
          , new HashMap<String, Object>() {
            {
              put("1", "3-2-1");
            }
          })
        );
      }
    };

    // Map<id属性値, Value>
    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("1", "1-1");
        put("2", "1-2");
        put("3", "1-3");
        put("1#tmpl-1.4", "2-1-1");
        put("1#tmpl-2.4", "2-2-1");
        put("1#tmpl-1.5-1", "2-1-2");
        put("1#tmpl-2.5-1", "2-2-2");
        put("1#tmpl-1.6-1", "3-1-1");
        put("1#tmpl-2.6-1", "3-2-1");
      }
    };

    // 実行
    Map<String, String> result = invokeConvertDataCodeToId(params, reportOutputInfo);

    // 検証
    assertThat(result.size(), is(expected.size()));
    assertThat(result, hasEntry("1", "1-1"));
    assertThat(result, hasEntry("2", "1-2"));
    assertThat(result, hasEntry("3", "1-3"));
    assertThat(result, hasEntry("1#tmpl-1.4", "2-1-1"));
    assertThat(result, hasEntry("1#tmpl-2.4", "2-2-1"));
    assertThat(result, hasEntry("1#tmpl-1.5-1", "2-1-2"));
    assertThat(result, hasEntry("1#tmpl-2.5-1", "2-2-2"));
    assertThat(result, hasEntry("1#tmpl-1.6", "3-1-1"));
    assertThat(result, hasEntry("1#tmpl-2.6", "3-2-1"));
  }

  /**
   * convertDataCodeToId()の検証.
   *
   * 条件：テンプレート繰り返し情報と帳票出力情報が指定されている(改ページあり)
   * 結果：帳票出力情報のkey項目に設定されている内容が データ項目コード -> id属性値 に変換されていること
   */
  @Test
  public void test_convertDataCodeToId_成功_テンプレート繰り返し項目_改ページあり_Param要素情報あり_帳票出力情報あり() throws Throwable {
    // 事前準備
    ReportXmlTmplRepeat tmplRepeat = new ReportXmlTmplRepeat("tmpl", 0, 0, 0, 0, 2, "", "",1, "1", 0, 0);
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"1", "", "1", "1", "", "", "", "", "", "", "0", "", "", null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"2", "", "2", "1", "", "", "", "", "", "", "1", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"3", "", "3", "1", "", "", "", "", "", "", "0", "", "",  null, null, null, null, null, tmplRepeat, null, null)
//      , ReportXmlParam.of(null,"4", "", "1", "2", "", "", "", "", "", "", "1", "", "",  null, null, null, null, null, tmplRepeat, null, null)
//      , ReportXmlParam.of(null,"5", "", "2", "2", "", "", "", "", "", "1", "1", "", "", null, null, null, null, null, tmplRepeat, null, null)
//      , ReportXmlParam.of(null,"6", "", "1", "3", "", "", "", "", "", "", "1", "", "",  null, null, null, null, null, tmplRepeat, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"1", "", "1", "1", "", "", "", "", "", "", "0", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"2", "", "2", "1", "", "", "", "", "", "", "1", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"3", "", "3", "1", "", "", "", "", "", "", "0", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"4", "", "1", "2", "", "", "", "", "", "", "1", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"5", "", "2", "2", "", "", "", "", "", "1", "1", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"6", "", "1", "3", "", "", "", "", "", "", "1", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end

    // Map<SqlCode, List<Map<DataCode, Value>>>
    Map<Long, List<Map<String, Object>>> reportOutputInfo = new HashMap<Long, List<Map<String, Object>>>() {
      {
        put(1L, Arrays.asList(new HashMap<String, Object>() {
          {
            put("1", "1-1");
            put("2", "1-2");
            put("3", "1-3");
          }
        }));
        put(2L, Arrays.asList(
          new HashMap<String, Object>() {
            {
              put("1", "2-1-1");
              put("2", "2-1-2");
            }
          }
          , new HashMap<String, Object>() {
            {
              put("1", "2-2-1");
              put("2", "2-2-2");
            }
          }
          , new HashMap<String, Object>() {
            {
              put("1", "2-3-1");
              put("2", "2-3-2");
            }
          })
        );
        put(3L, Arrays.asList(
          new HashMap<String, Object>() {
            {
              put("1", "3-1-1");
            }
          }
          , new HashMap<String, Object>() {
            {
              put("1", "3-2-1");
            }
          })
        );
      }
    };

    // Map<id属性値, Value>
    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("1", "1-1");
        put("2", "1-2");
        put("3", "1-3");
        put("1#tmpl-1.4", "2-1-1");
        put("1#tmpl-2.4", "2-2-1");
        put("2#tmpl-1.4", "2-3-1");
        put("1#tmpl-1.5-1", "2-1-2");
        put("1#tmpl-2.5-1", "2-2-2");
        put("2#tmpl-1.5-1", "2-3-2");
        put("1#tmpl-1.6-1", "3-1-1");
        put("1#tmpl-2.6-1", "3-2-1");
      }
    };

    // 実行
    Map<String, String> result = invokeConvertDataCodeToId(params, reportOutputInfo);

    // 検証
    assertThat(result.size(), is(expected.size()));
    assertThat(result, hasEntry("1", "1-1"));
    assertThat(result, hasEntry("2", "1-2"));
    assertThat(result, hasEntry("3", "1-3"));
    assertThat(result, hasEntry("1#tmpl-1.4", "2-1-1"));
    assertThat(result, hasEntry("1#tmpl-2.4", "2-2-1"));
    assertThat(result, hasEntry("2#tmpl-1.4", "2-3-1"));
    assertThat(result, hasEntry("1#tmpl-1.5-1", "2-1-2"));
    assertThat(result, hasEntry("1#tmpl-2.5-1", "2-2-2"));
    assertThat(result, hasEntry("2#tmpl-1.5-1", "2-3-2"));
    assertThat(result, hasEntry("1#tmpl-1.6", "3-1-1"));
    assertThat(result, hasEntry("1#tmpl-2.6", "3-2-1"));
  }

  /**
   * convertDataCodeToId()の検証.
   *
   * 条件：Param要素情報が指定されている、帳票出力情報が指定されていない
   * 結果：空の帳票出力情報が返却されること
   */
  @Test
  public void test_convertDataCodeToId_成功_Param要素情報あり_帳票出力情報なし() throws Throwable {
    // 事前準備
    // id属性値、dataCode属性値、sqlCode属性値、groupId属性値
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"1", "", "1", "1", "", "", "", "", "", "", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"2", "", "1", "2", "", "", "", "", "", "", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"3", "", "2", "2", "", "", "", "", "", "", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"4", "", "1", "3", "", "", "", "", "", "", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"5", "", "3", "2", "", "", "", "", "", "", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"6", "", "1", "4", "", "", "", "", "", "", "", "", "",  null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"", "", "1", "5", "", "", "", "", "", "", "", "", "", "null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,null, "", "1", "6", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"1", "", "1", "1", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"2", "", "1", "2", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"3", "", "2", "2", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"4", "", "1", "3", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"5", "", "3", "2", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"6", "", "1", "4", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"", "", "1", "5", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,null, "", "1", "6", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end

    // Map<SqlCode, List<Map<DataCode, Value>>>
    Map<Long, List<Map<String, Object>>> reportOutputInfo = new HashMap<Long, List<Map<String, Object>>>() {
      {
        put(1L, Arrays.asList());
        put(2L, Arrays.asList());
        put(3L, Arrays.asList());
        put(4L, Arrays.asList());
      }
    };

    // Map<id属性値, Value>
    Map<String, String> expected = new HashMap<>();

    // 実行
    Map<String, String> result = invokeConvertDataCodeToId(params, reportOutputInfo);

    // 検証
    assertThat(result.size(), is(expected.size()));
  }

  /**
   * convertDataCodeToId()の検証.
   *
   * 条件：Param要素情報が指定されていない、帳票出力情報が指定されている
   * 結果：空の帳票出力情報が返却されること
   */
  @Test
  public void test_convertDataCodeToId_成功_Param要素情報なし_帳票出力情報あり() throws Throwable {
    // 事前準備
    // id属性値、dataCode属性値、sqlCode属性値、groupId属性値
    List<ReportXmlParam> params = Arrays.asList();

    // Map<SqlCode, List<Map<DataCode, Value>>>
    Map<Long, List<Map<String, Object>>> reportOutputInfo = new HashMap<>();

    // Map<id属性値, Value>
    Map<String, String> expected = new HashMap<>();

    // 実行
    Map<String, String> result = invokeConvertDataCodeToId(params, reportOutputInfo);

    // 検証
    assertThat(result.size(), is(expected.size()));
  }

  /**
   * filterReportInfo()の検証.
   *
   * 条件：帳票出力情報をフィルタリングするための情報が指定されていること
   * 結果：フィルタリングされた帳票出力情報が取得できること
   */
  @Test
  public void test_filterReportInfo_成功_単一定義_単項目() throws Throwable {
    // 事前準備
    List<ReportXmlFilter> filters = Arrays.asList(
      new ReportXmlFilter("value1", "item1",null)
    );
    ReportXmlGroup group = new ReportXmlGroup("", 0, 0, "", filters);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"", "", "", "", "", "", "", "", "", "", "", "", "", null, group, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"", "", "", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    List<Map<String, Object>> reportInfo = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("item1", "value1");
          put("item2", "value2");
        }
      }
      , new HashMap<String, Object>() {
        {
          put("item1", "value9");
          put("item2", "value2");
        }
      }
    );

    // 実行
    List<Map<String, Object>> result = invokeFilterReportInfo(param, reportInfo);

    // 検証
    assertThat(result.size(), is(1));
    assertThat(result.get(0), hasEntry("item1", "value1"));
    assertThat(result.get(0), hasEntry("item2", "value2"));
  }

  /**
   * filterReportInfo()の検証.
   *
   * 条件：帳票出力情報をフィルタリングするための情報が指定されていること
   * 結果：フィルタリングされた帳票出力情報が取得できること
   */
  @Test
  public void test_filterReportInfo_成功_単一定義_複項目() throws Throwable {
    // 事前準備
    List<ReportXmlFilter> filters = Arrays.asList(
      new ReportXmlFilter("value1.value2", "item1.item2",null)
    );
    ReportXmlGroup group = new ReportXmlGroup("", 0, 0, "", filters);
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
    // ReportXmlParam param = ReportXmlParam.of(null,"", "", "", "", "", "", "", "", "", "", "", "", "", null, group, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"", "", "", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    List<Map<String, Object>> reportInfo = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("item1", "value1");
          put("item2", "value2");
          put("item3", "value3");
        }
      }
      , new HashMap<String, Object>() {
        {
          put("item1", "value9");
          put("item2", "value2");
          put("item4", "value4");
        }
      }
      , new HashMap<String, Object>() {
        {
          put("item1", "value1");
          put("item2", "value9");
          put("item5", "value5");
        }
      }
    );

    // 実行
    List<Map<String, Object>> result = invokeFilterReportInfo(param, reportInfo);

    // 検証
    assertThat(result.size(), is(1));
    assertThat(result.get(0), hasEntry("item1", "value1"));
    assertThat(result.get(0), hasEntry("item2", "value2"));
    assertThat(result.get(0), hasEntry("item3", "value3"));
  }

  /**
   * filterReportInfo()の検証.
   *
   * 条件：帳票出力情報をフィルタリングするための情報が指定されていること
   * 結果：フィルタリングされた帳票出力情報が取得できること
   */
  @Test
  public void test_filterReportInfo_成功_複数定義_単項目() throws Throwable {
    // 事前準備
    List<ReportXmlFilter> filters = Arrays.asList(
      new ReportXmlFilter("value1", "item1",null)
      , new ReportXmlFilter("2", "item2",null)
    );
    ReportXmlGroup group = new ReportXmlGroup("", 0, 0, "", filters);
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
    // ReportXmlParam param = ReportXmlParam.of(null,"", "", "", "", "", "", "", "", "", "", "", "", "", null, group, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"", "", "", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end

    List<Map<String, Object>> reportInfo = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("item1", "value1");
          put("item2", 2);
        }
      }
      , new HashMap<String, Object>() {
        {
          put("item1", "value9");
          put("item2", 2);
        }
      }
      , new HashMap<String, Object>() {
        {
          put("item1", "value1");
          put("item2", 9);
        }
      }
      , new HashMap<String, Object>() {
        {
          put("item1", "value9");
          put("item2", 9);
        }
      }
    );

    // 実行
    List<Map<String, Object>> result = invokeFilterReportInfo(param, reportInfo);

    // 検証
    assertThat(result.size(), is(3));
    assertThat(result.get(0), hasEntry("item1", "value1"));
    assertThat(result.get(0), hasEntry("item2", 2));
    assertThat(result.get(1), hasEntry("item1", "value9"));
    assertThat(result.get(1), hasEntry("item2", 2));
    assertThat(result.get(2), hasEntry("item1", "value1"));
    assertThat(result.get(2), hasEntry("item2", 9));
  }

  /**
   * filterReportInfo()の検証.
   *
   * 条件：帳票出力情報をフィルタリングするための情報が指定されていること
   * 結果：フィルタリングされた帳票出力情報が取得できること
   */
  @Test
  public void test_filterReportInfo_成功_複数定義_複項目() throws Throwable {
    // 事前準備
    List<ReportXmlFilter> filters = Arrays.asList(
      new ReportXmlFilter("value1", "item1",null)
      , new ReportXmlFilter("value2.value3", "item2.item3",null)
    );
    ReportXmlGroup group = new ReportXmlGroup("", 0, 0, "", filters);
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
    // ReportXmlParam param = ReportXmlParam.of(null,"", "", "", "", "", "", "", "", "", "", "", "", "", null, group, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"", "", "", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end

    List<Map<String, Object>> reportInfo = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("item1", "value1");
          put("item2", "value9");
          put("item3", "value9");
          put("item4", "value4");
        }
      }
      , new HashMap<String, Object>() {
        {
          put("item1", "value9");
          put("item2", "value2");
          put("item3", "value3");
          put("item5", "value5");
        }
      }
      , new HashMap<String, Object>() {
        {
          put("item1", "value9");
          put("item2", "value9");
          put("item3", "value3");
          put("item6", "value6");
        }
      }
    );

    // 実行
    List<Map<String, Object>> result = invokeFilterReportInfo(param, reportInfo);

    // 検証
    assertThat(result.size(), is(2));
    assertThat(result.get(0), hasEntry("item1", "value1"));
    assertThat(result.get(0), hasEntry("item2", "value9"));
    assertThat(result.get(0), hasEntry("item3", "value9"));
    assertThat(result.get(0), hasEntry("item4", "value4"));
    assertThat(result.get(1), hasEntry("item1", "value9"));
    assertThat(result.get(1), hasEntry("item2", "value2"));
    assertThat(result.get(1), hasEntry("item3", "value3"));
    assertThat(result.get(1), hasEntry("item5", "value5"));
  }

  /**
   * filterReportInfo()の検証.
   *
   * 条件：帳票出力情報をフィルタリングするための情報が指定されていること
   * 結果：フィルタリングされた帳票出力情報が取得できること
   */
  @Test
  public void test_filterReportInfo_成功_フィルタの結果0件() throws Throwable {
    // 事前準備
    List<ReportXmlFilter> filters = Arrays.asList(
      new ReportXmlFilter("value1", "item1",null)
    );
    ReportXmlGroup group = new ReportXmlGroup("", 0, 0, "", filters);
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
    // ReportXmlParam param = ReportXmlParam.of(null,"", "", "", "", "", "", "", "", "", "", "", "", "", null, group, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"", "", "", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    List<Map<String, Object>> reportInfo = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("item2", "value2");
        }
      }
    );

    // 実行
    List<Map<String, Object>> result = invokeFilterReportInfo(param, reportInfo);

    // 検証
    assertThat(result.size(), is(0));
  }

  /**
   * filterReportInfo()の検証.
   *
   * 条件：帳票出力情報をフィルタリングするための情報が指定されていないこと
   * 結果：引数で指定した帳票出力情報がそのまま取得できること
   */
  @Test
  public void test_filterReportInfo_成功_フィルタ定義指定なし_filterなし() throws Throwable {
    // 事前準備
    List<ReportXmlFilter> filters = Collections.EMPTY_LIST;
    ReportXmlGroup group = new ReportXmlGroup("", 0, 0, "", filters);
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
    // ReportXmlParam param = ReportXmlParam.of(null,"", "", "", "", "", "", "", "", "", "", "", "", "", null, group, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"", "", "", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    List<Map<String, Object>> reportInfo = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("item2", "value2");
        }
      }
    );

    // 実行
    List<Map<String, Object>> result = invokeFilterReportInfo(param, reportInfo);

    // 検証
    assertThat(result.size(), is(1));
    assertThat(result.get(0), hasEntry("item2", "value2"));
  }

  /**
   * filterReportInfo()の検証.
   *
   * 条件：帳票出力情報をフィルタリングするための情報が指定されていないこと
   * 結果：引数で指定した帳票出力情報がそのまま取得できること
   */
  @Test
  public void test_filterReportInfo_成功_フィルタ定義指定なし_groupなし() throws Throwable {
    // 事前準備
    ReportXmlGroup group = null;
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
    //    ReportXmlParam param = ReportXmlParam.of(null,"", "", "", "", "", "", "", "", "", "", "", "", "", null, group, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"", "", "", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    List<Map<String, Object>> reportInfo = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("item2", "value2");
        }
      }
    );

    // 実行
    List<Map<String, Object>> result = invokeFilterReportInfo(param, reportInfo);

    // 検証
    assertThat(result.size(), is(1));
    assertThat(result.get(0), hasEntry("item2", "value2"));
  }

  /**
   * formatValue()の検証.
   *
   * 条件：文字列をフォーマットする情報が指定されていること
   * 結果：フォーマットされた値が取得できること
   */
  @Test
  public void test_formatValue_成功_文字列() throws Throwable {
    // 事前準備
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
    //    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1", "", "string", "", "", "", "%.10s", "", "", "", "", "", null, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "string", "", "", "", "%.10s", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    String value = "１２３４５６７８９０１";
    String expected = "１２３４５６７８９０";

    // 実行
    String result = invokeFormatValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatValue()の検証.
   *
   * 結果：フォーマットされた値が取得できること
   * 条件：数値をフォーマットする情報が指定されていること
   */
  @Test
  public void test_formatValue_成功_数値() throws Throwable {
    // 事前準備
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1", "", "decimal", "", "", "", "%.2f", "", "", "", "", "", null, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "decimal", "", "", "", "%.2f", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    BigDecimal value = BigDecimal.valueOf(19.3);
    String expected = "19.30";

    // 実行
    String result = invokeFormatValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatValue()の検証.
   *
   * 条件：日付（String型）をフォーマットする情報が指定されていること
   * 結果：フォーマットされた値が取得できること
   */
  @Test
  public void test_formatValue_成功_日付_String() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1",  "", "DateTime", "", "", "", "HH:mm", "", "", "", "", "", null, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "DateTime", "", "", "", "HH:mm", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    String value = "2018-08-30T18:30:02.000+09:00";
    String expected = "18:30";

    // 実行
    String result = invokeFormatValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatValue()の検証.
   *
   * 条件：日付（Timestamp型）をフォーマットする情報が指定されていること
   * 結果：フォーマットされた値が取得できること
   */
  @Test
  public void test_formatValue_成功_日付_Timestamp() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1", "", "DateTime", "", "", "HH:mm", "", "", "", "", "", "", null, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "DateTime", "", "", "HH:mm", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Timestamp value = Timestamp.valueOf("2018-08-30 18:30:02.000");
    String expected = "18:30";

    // 実行
    String result = invokeFormatValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatValue()の検証.
   *
   * 条件：日付（Date型）をフォーマットする情報が指定されていること
   * 結果：フォーマットされた値が取得できること
   */
  @Test
  public void test_formatValue_成功_日付_Date() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1", "", "DateTime", "", "", "HH:mm", "", "", "", "", "", "", null, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "DateTime", "", "", "HH:mm", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Date value = Date.from(LocalDateTime.of(2019, 8, 30, 18, 30, 10).toInstant(ZoneOffset.of("+9")));
    String expected = "18:30";

    // 実行
    String result = invokeFormatValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatValue()の検証.
   *
   * 条件：日付（その他）をフォーマットする情報が指定されていること
   * 結果：指定した値が返却されること
   */
  @Test
  public void test_formatValue_成功_日付_その他() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1",  "", "DateTime", "", "", "HH:mm", "", "", "", "", "", "", null, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "DateTime", "", "", "HH:mm", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    int value = 1;
    String expected = "1";

    // 実行
    String result = invokeFormatValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatValue()の検証.
   *
   * 条件：日付のフォーマットが失敗する
   * 結果：指定した値が返却されること
   */
  @Test
  public void test_formatValue_失敗_日付のフォーマットが失敗する() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1", "", "DateTime", "", "", "HH:mm", "", "", "", "", "", "", null, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "DateTime", "", "", "HH:mm", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    String value = "test";
    String expected = "test";

    // 実行
    String result = invokeFormatValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatValue()の検証.
   *
   * 条件：数値のフォーマットが失敗する
   * 結果：指定した値が返却されること
   */
  @Test
  public void test_formatValue_失敗_数値のフォーマットが失敗する() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1", "", "decimal", "", "", "0.00", "", "", "", "", "", "", null, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "decimal", "", "", "0.00", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    String value = "test";
    String expected = "test";

    // 実行
    String result = invokeFormatValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatValue()の検証.
   *
   * 条件：DataTypeに想定外の型が指定されていること
   * 結果：指定した値が返却されること
   */
  @Test
  public void test_formatValue_成功_DataTypeに想定外の型が指定されている() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1",  "", "int", "", "", "%.10s", "", "", "", "", "", "", null, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "int", "", "", "%.10s", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    String value = "１２３４５６７８９０１";
    String expected = "１２３４５６７８９０１";

    // 実行
    String result = invokeFormatValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatValue()の検証.
   *
   * 条件：DataTypeが指定されていないこと
   * 結果：指定した値が返却されること
   */
  @Test
  public void test_formatValue_成功_DataTypeが指定されていない() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1", "", "", "", "", "%.10s", "", "", "", "", "", "", null, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "", "", "", "%.10s", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    String value = "１２３４５６７８９０１";
    String expected = "１２３４５６７８９０１";

    // 実行
    String result = invokeFormatValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatValue()の検証.
   *
   * 条件：dispFormatが指定されていないこと
   * 結果：指定した値が返却されること
   */
  @Test
  public void test_formatValue_成功_dispFormatが指定されていない() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1", "", "string", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "string", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    String value = "１２３４５６７８９０１";
    String expected = "１２３４５６７８９０１";

    // 実行
    String result = invokeFormatValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatValue()の検証.
   *
   * 条件：valueが空であること
   * 結果：指定した値が返却されること
   */
  @Test
  public void test_formatValue_成功_valueが空である() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1", "", "string", "", "", "%.10s", "", "", "", "", "", "", null, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "string", "", "", "%.10s", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    String value = "";
    String expected = "";

    // 実行
    String result = invokeFormatValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * formatValue()の検証.
   *
   * 条件：valueがnullであること
   * 結果：空文字が返却されること
   */
  @Test
  public void test_formatValue_成功_valueがnullである() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1",  "", "string", "", "", "%.10s", "", "", "", "", "", "", null, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "string", "", "", "%.10s", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    String expected = "";

    // 実行
    String result = invokeFormatValue(param, null);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * convertValue()の検証.
   *
   * 条件：コードを名称に変換するための情報が指定されていること
   * 結果：名称に変換された値が取得できること
   */
  @Test
  public void test_convertValue_成功_名称に変換された値が取得できる() throws Throwable {
    // 事前準備
    List<ReportXmlConv> reportXmlConvs = Arrays.asList(
      new ReportXmlConv("1", "item01", "disp01")
      , new ReportXmlConv("2", "item02", "disp02")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1", "", "", "", "", "", "", "", "", "", "", "", reportXmlConvs, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    String value = "1";
    String expected = "disp01";

    // 実行
    String result = invokeConvertValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * convertValue()の検証.
   *
   * 条件：コードに該当する変換情報が指定されていないこと
   * 結果：指定した値が返却されること
   */
  @Test
  public void test_convertValue_成功_コードに該当する変換情報が指定されていない() throws Throwable {
    // 事前準備
    List<ReportXmlConv> reportXmlConvs = Arrays.asList(
      new ReportXmlConv("1", "item01", "disp01")
      , new ReportXmlConv("2", "item02", "disp02")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1", "", "", "", "", "", "", "", "", "", "", "", reportXmlConvs, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    String value = "99";
    String expected = "99";

    // 実行
    String result = invokeConvertValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * convertValue()の検証.
   *
   * 条件：値が空の場合
   * 結果：指定した値が返却されること
   */
  @Test
  public void test_convertValue_成功_値が空() throws Throwable {
    // 事前準備
    List<ReportXmlConv> reportXmlConvs = Arrays.asList(
      new ReportXmlConv("1", "item01", "disp01")
      , new ReportXmlConv("2", "item02", "disp02")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1", "", "", "", "", "", "", "", "", "", "", "", reportXmlConvs, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    String value = "";
    String expected = "";

    // 実行
    String result = invokeConvertValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * convertValue()の検証.
   *
   * 条件：変換情報が指定されていないこと(NULL)
   * 結果：指定した値が返却されること
   */
  @Test
  public void test_convertValue_成功_変換情報が指定されていない_NULL() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    String value = "1";
    String expected = "1";

    // 実行
    String result = invokeConvertValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * convertValue()の検証.
   *
   * 条件：変換情報が指定されていないこと(空のリスト)
   * 結果：指定した値が返却されること
   */
  @Test
  public void test_convertValue_成功_変換情報が指定されていない_空のリスト() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    ReportXmlParam param = ReportXmlParam.of(null,"A1", "1",  "", "", "", "", "", "", "", "", "", "", "", Collections.EMPTY_LIST, null, null, null, null, null, null, null);
    ReportXmlParam param = ReportXmlParam.of(null,null,"A1", "1", "", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    String value = "1";
    String expected = "1";

    // 実行
    String result = invokeConvertValue(param, value);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * getCalcResult()の検証.
   *
   * 条件：Param要素情報に計算するための情報が全て設定されている
   * 結果：Param要素情報に設定されている情報に計算結果が正しく返却されること
   */
  @Test
  public void test_getCalcResult_成功_Param要素情報_全て設定() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"A1", "1", "", "", "", "", "", "[1.1]-[1.2]", "", "", "", "", "", null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"A2", "0", "", "", "", "", "", "[1.1]-[1.2]", "", "", "", "", "", null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"A3", "1", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null)
//      , ReportXmlParam.of(null,"A4", "1", "", "", "", "", "", "[2.1] / 100", "", "", "", "", "", null, null, null, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"A1", "1", "", "", "", "", "", "", "[1.1]-[1.2]", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"A2", "0", "", "", "", "", "", "", "[1.1]-[1.2]", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"A3", "1", "", "", "", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
      , ReportXmlParam.of(null,null,"A4", "1", "", "", "", "", "", "", "[2.1] / 100", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    // Map<SqlCode, List<Map<DataCode, Value>>>
    Map<Long, List<Map<String, Object>>> reportOutputInfo = new HashMap<Long, List<Map<String, Object>>>() {
      {
        put(1L, Arrays.asList(new HashMap<String, Object>() {
          {
            put("1", "10");
            put("2", "2");
          }
        }));
        put(2L, Arrays.asList(new HashMap<String, Object>() {
          {
            put("1", "190");
          }
        }));
      }
    };

    // Map<id属性値, Value>
    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("A1", "8");
        put("A4", "1.9");
      }
    };

    // 実行
    Map<String, String> result = invokeGetCalcResult(params, reportOutputInfo);

    // 検証
    assertThat(result.size(), is(expected.size()));
    assertThat(result, hasEntry("A1", "8"));
    assertThat(result, hasEntry("A4", "1.9"));
  }

  /**
   * getCalcResult()の検証.
   *
   * 条件：帳票出力情報にSqlCodeに該当するデータが存在しない
   * 結果：計算結果に "failed calc" が返却されること
   */
  @Test
  public void test_getCalcResult_成功_帳票出力情報_該当データなし_SqlCode() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
////      ReportXmlParam.of(null,"A1", "1", "", "", "", "", "", "[1.1]-[1.2]", "", "", "", "", "", null, null, null, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"A1", "1", "", "", "", "", "", "", "[1.1]-[1.2]", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end

    // Map<SqlCode, List<Map<DataCode, Value>>>
    Map<Long, List<Map<String, Object>>> reportOutputInfo = new HashMap<Long, List<Map<String, Object>>>() {
      {
        put(2L, Arrays.asList(new HashMap<String, Object>() {
          {
            put("1", "10");
            put("2", "2");
          }
        }));
      }
    };

    // Map<id属性値, Value>
    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("A1", "failed calc");
      }
    };

    // 実行
    Map<String, String> result = invokeGetCalcResult(params, reportOutputInfo);

    // 検証
    assertThat(result.size(), is(expected.size()));
    assertThat(result, hasEntry("A1", "failed calc"));
  }

  /**
   * getCalcResult()の検証.
   *
   * 条件：帳票出力情報にデータ項目コードに該当するデータが存在しない
   * 結果：計算結果に "failed calc" が返却されること
   */
  @Test
  public void test_getCalcResult_成功_帳票出力情報_該当データなし_データ項目コード() throws Throwable {
    // 事前準備
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"A1", "1", "", "", "", "", "", "[1.1]-[1.2]", "", "", "", "", "", null, null, null, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"A1", "1", "", "", "", "", "", "", "[1.1]-[1.2]", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    // Map<SqlCode, List<Map<DataCode, Value>>>
    Map<Long, List<Map<String, Object>>> reportOutputInfo = new HashMap<Long, List<Map<String, Object>>>() {
      {
        put(1L, Arrays.asList(new HashMap<String, Object>() {
          {
            put("1", "10");
          }
        }));
      }
    };

    // Map<id属性値, Value>
    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("A1", "failed calc");
      }
    };

    // 実行
    Map<String, String> result = invokeGetCalcResult(params, reportOutputInfo);

    // 検証
    assertThat(result.size(), is(expected.size()));
    assertThat(result, hasEntry("A1", "failed calc"));
  }

  /**
   * calcOfFormula()の検証.
   *
   * 条件：2項の四則演算（+）の計算式が指定されている
   * 結果：四則演算が正しくされていること
   */
  @Test
  public void test_calcOfFormula_成功_四則演算_足し算() throws Throwable {
    // 事前準備
    String formula = "12+34";
    String expected = "46";

    // 実行
    String result = invokeCalcOfFormula(formula);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * calcOfFormula()の検証.
   *
   * 条件：2項の四則演算（-）の計算式が指定されている
   * 結果：四則演算が正しくされていること
   */
  @Test
  public void test_calcOfFormula_成功_四則演算_引き算() throws Throwable {
    // 事前準備
    String formula = "56-34";
    String expected = "22";

    // 実行
    String result = invokeCalcOfFormula(formula);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * calcOfFormula()の検証.
   *
   * 条件：2項の四則演算（*）の計算式が指定されている
   * 結果：四則演算が正しくされていること
   */
  @Test
  public void test_calcOfFormula_成功_四則演算_掛け算() throws Throwable {
    // 事前準備
    String formula = "12*34";
    String expected = "408";

    // 実行
    String result = invokeCalcOfFormula(formula);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * calcOfFormula()の検証.
   *
   * 条件：2項の四則演算（/）の計算式が指定されている
   * 結果：四則演算が正しくされていること
   */
  @Test
  public void test_calcOfFormula_成功_四則演算_割り算() throws Throwable {
    // 事前準備
    String formula = "408/12";
    String expected = "34";

    // 実行
    String result = invokeCalcOfFormula(formula);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * calcOfFormula()の検証.
   *
   * 条件：四則演算の前後にスペースが設定されている計算式が指定されている
   * 結果：四則演算が正しくされていること
   */
  @Test
  public void test_calcOfFormula_成功_四則演算_スペースあり() throws Throwable {
    // 事前準備
    String formula = "12 + 34";
    String expected = "46";

    // 実行
    String result = invokeCalcOfFormula(formula);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * calcOfFormula()の検証.
   *
   * 条件：3項以上の四則演算の計算式が指定されている
   * 結果：例外(NtssException)がスローされること
   */
  @Test
  public void test_calcOfFormula_失敗_四則演算_3項以上() throws Throwable {
    // 事前準備
    String formula = "12+34+56";

    // 検証
    // 実行
    expectedException.expect(NtssException.class);
    expectedException.expectMessage("");
    invokeCalcOfFormula(formula);
  }

  /**
   * calcOfFormula()の検証.
   *
   * 条件：不備がある計算式が指定されている
   * 結果：例外(NtssException)がスローされること
   */
  @Test
  public void test_calcOfFormula_失敗_四則演算_不備がある計算式() throws Throwable {
    // 事前準備
    String formula = "12+";

    // 検証
    // 実行
    expectedException.expect(NtssException.class);
    expectedException.expectMessage("");
    invokeCalcOfFormula(formula);
  }

  /**
   * reflectReportHtml()の検証.
   *
   * 条件：帳票デザインHTMLに反映する帳票出力情報が指定されている
   * 結果：帳票出力情報の内容が帳票デザインHTMLへ反映され返却されること
   */
  @Test
  public void test_reflectReportHtml_成功_反映された() throws Throwable {
    // 事前準備
    StringBuilder sb = new StringBuilder();
    sb.append("<HTML xmlns=\"http://www.w3.org/TR/REC-html40\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\">");
    sb.append("<HEAD>");
    sb.append("<META content=\"text/html; charset=utf-8\" http-equiv=Content-Type>");
    sb.append("<META name=ProgId content=Excel.Sheet>");
    sb.append("<META name=Generator content=\"Microsoft Excel 15\"><LINK rel=File-List href=\"透析レポート(サンプル).files/filelist.xml\">");
    sb.append("</HEAD>");
    sb.append("<BODY>");
    sb.append("<DIV id=レイアウト_20190509180033 align=center x:publishsource=\"Excel\">");
    sb.append("<TABLE>");
    sb.append("<TBODY>");
    sb.append("<TD id=\"A1:A2\"></TD>");
    sb.append("<TD id=\"B1:C1\"></TD>");
    sb.append("<TD id=\"D1:E2\"></TD>");
    sb.append("<TD id=\"F1:F1\"></TD>");
    sb.append("<TD id=\"F2:F2\"></TD>");
    sb.append("<TD id=\"M1:M1\"></TD>");
    sb.append("<TD id=\"M2:M2\"></TD>");
    sb.append("<TD id=\"M3:M3\"></TD>");
    sb.append("</TBODY>");
    sb.append("</TABLE>");
    sb.append("</DIV>");
    sb.append("</BODY>");
    sb.append("</HTML>");
    String reportHtml = sb.toString();

    // Map<id属性値, Value>
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1:A2", "test1");
        put("B1:C1", "test2");
        put("D1:E2", "test3");
        put("1#M1:M1", "test4-1");
        put("1#M2:M2", "test5-1");
        put("2#M2:M2", "test5-2");
        put("1#M3:M3", "test6-1");
        put("2#M3:M3", "test6-2");
        put("3#M3:M3", "test6-3");
      }
    };

    // Map<id属性値, Value>
    Map<String, String> calcResutl = new HashMap<String, String>() {
      {
        put("F1:F1", "12345");
        put("F2:F2", "failed calc");
      }
    };

    org.jsoup.nodes.Document document = Jsoup.parse(reportHtml);
    document.getElementById("A1:A2").text("test1");
    document.getElementById("B1:C1").text("test2");
    document.getElementById("D1:E2").text("test3");
    document.getElementById("F1:F1").text("12345");
    document.getElementById("F2:F2").text("ERROR");
    document.getElementById("F2:F2").attr("style", "background-color: red;");
    org.jsoup.nodes.Element element1 = document.getElementsByTag("body").first();
    org.jsoup.nodes.Element element2 = element1.clone();
    org.jsoup.nodes.Element element3 = element1.clone();
    element1.getElementById("M1:M1").text("test4-1");
    element1.getElementById("M2:M2").text("test5-1");
    element1.getElementById("M3:M3").text("test6-1");
    element2.getElementById("M2:M2").text("test5-2");
    element2.getElementById("M3:M3").text("test6-2");
    element3.getElementById("M3:M3").text("test6-3");
    element1.append("<div style=\"page-break-before: always\" />");
    element1.append(element2.html());
    element1.append("<div style=\"page-break-before: always\" />");
    element1.append(element3.html());
    String expected = document.html();

    // 実行
    String result = invokeReflectReportHtml(reportHtml, reportOutputInfo, calcResutl, Collections.EMPTY_MAP, Collections.EMPTY_MAP, Collections.EMPTY_MAP);

    // 検証
    assertThat(result).isEqualTo(expected);
  }

  /**
   * reflectReportHtml()の検証.
   *
   * 条件：帳票デザインHTMLに反映する帳票出力情報が指定されていない
   * 結果：指定された帳票デザインHTMLがそのまま返却されること
   */
  @Test
  public void test_reflectReportHtml_成功_反映データなし() throws Throwable {
    // 事前準備
    StringBuilder sb = new StringBuilder();
    sb.append("<HTML xmlns=\"http://www.w3.org/TR/REC-html40\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\">");
    sb.append("<HEAD>");
    sb.append("<META content=\"text/html; charset=utf-8\" http-equiv=Content-Type>");
    sb.append("<META name=ProgId content=Excel.Sheet>");
    sb.append("<META name=Generator content=\"Microsoft Excel 15\"><LINK rel=File-List href=\"透析レポート(サンプル).files/filelist.xml\">");
    sb.append("</HEAD>");
    sb.append("<BODY>");
    sb.append("<DIV id=レイアウト_20190509180033 align=center x:publishsource=\"Excel\">");
    sb.append("<TABLE><TBODY>");
    sb.append("<TD id=\"A1:A2\"></TD>");
    sb.append("<TD id=\"B1:C1\"></TD>");
    sb.append("<TD id=\"D1:E2\"></TD>");
    sb.append("</TBODY></TABLE></DIV></BODY></HTML>");
    String reportHtml = sb.toString();

    // Map<id属性値, Value>
    Map<String, String> reportOutputInfo = new HashMap<>();
    Map<String, String> calcResult = new HashMap<>();

    org.jsoup.nodes.Document document = Jsoup.parse(reportHtml);
    String expected = document.html();

    // 実行
    String result = invokeReflectReportHtml(reportHtml, reportOutputInfo, calcResult, Collections.EMPTY_MAP, Collections.EMPTY_MAP, Collections.EMPTY_MAP);

    // 検証
    assertThat(result).isEqualTo(expected);
  }

  /**
   * reflectReportHtml()の検証.
   *
   * 条件：帳票デザインHTMLに反映する帳票出力情報と条件付き書式が指定されている
   * 結果：帳票出力情報と条件付き書式の内容が帳票デザインHTMLへ反映され返却されること
   */
  @Test
  public void test_reflectReportHtml_成功_条件付き書式が反映された() throws Throwable {
    // 事前準備
    StringBuilder sb = new StringBuilder();
    sb.append("<HTML xmlns=\"http://www.w3.org/TR/REC-html40\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\">");
    sb.append("<HEAD>");
    sb.append("<META content=\"text/html; charset=utf-8\" http-equiv=Content-Type>");
    sb.append("<META name=ProgId content=Excel.Sheet>");
    sb.append("<META name=Generator content=\"Microsoft Excel 15\"><LINK rel=File-List href=\"透析レポート(サンプル).files/filelist.xml\">");
    sb.append("</HEAD>");
    sb.append("<BODY>");
    sb.append("<DIV id=レイアウト_20190509180033 align=center x:publishsource=\"Excel\">");
    sb.append("<TABLE><TBODY>");
    sb.append("<TD id=\"A1:A2\"></TD>");
    sb.append("<TD id=\"B1:C1\"></TD>");
    sb.append("<TD id=\"D1:E2\"></TD>");
    sb.append("<TD id=\"F1:F1\"></TD>");
    sb.append("<TD id=\"F2:F2\" class=\"test-class\"></TD>");
    sb.append("</TBODY></TABLE></DIV></BODY></HTML>");
    String reportHtml = sb.toString();

    // Map<id属性値, Value>
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1:A2", "test1");
        put("B1:C1", "test2");
        put("D1:E2", "test3");
      }
    };

    // Map<id属性値, Value>
    Map<String, String> formatConditionInfo = new HashMap<String, String>() {
      {
        put("B1:C1", "test-add-class1");
        put("F2:F2", "test-add-class2");
      }
    };

    org.jsoup.nodes.Document document = Jsoup.parse(reportHtml);
    document.getElementById("A1:A2").text("test1");
    document.getElementById("B1:C1").text("test2");
    document.getElementById("D1:E2").text("test3");
    document.getElementById("B1:C1").addClass("test-add-class1");
    document.getElementById("F2:F2").addClass("test-add-class2");
    String expected = document.html();

    // 実行
    String result = invokeReflectReportHtml(reportHtml, reportOutputInfo, Collections.EMPTY_MAP, formatConditionInfo, Collections.EMPTY_MAP, Collections.EMPTY_MAP);

    // 検証
    assertThat(result).isEqualTo(expected);
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：検証値が文字列で値がある_評価結果がtrue
   * 結果：idとclassのMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_検証値が文字列で値がある_評価結果がtrue() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition("==", "'testValue'", "testClass")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"A4", "1", "", "string", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"A4", "1", "", "", "string", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "testValue");
        put("B10", "10");
        put("B11", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("A4", "testClass");
      }
    };

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：検証値が文字列で値がある_評価結果がfalse
   * 結果：空のMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_検証値が文字列で値がある_評価結果がfalse() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition("!=", "'testValue'", "testClass")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"A4", "1", "", "string", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"A4", "1", "", "", "string", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "testValue");
        put("B10", "10");
        put("B11", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {};

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：検証値が文字列で値が空_評価結果がtrue
   * 結果：idとclassのMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_検証値が文字列で値が空_評価結果がtrue() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition("==", "''", "testClass")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"A4", "1", "", "string", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"A4", "1", "", "", "string", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "");
        put("B10", "10");
        put("B11", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("A4", "testClass");
      }
    };

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：検証値が文字列で値が空_評価結果がfalse
   * 結果：空のMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_検証値が文字列で値が空_評価結果がfalse() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition("==", "'testValue'", "testClass")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"A4", "1", "", "string", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"A4", "1", "", "", "string", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "");
        put("B10", "10");
        put("B11", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {};

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：検証値が空_評価結果がtrue
   * 結果：idとclassのMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_検証値が空_評価結果がtrue() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition("==", "", "testClass")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"A4", "1", "", "string", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"A4", "1", "", "", "string", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "");
        put("B10", "10");
        put("B11", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("A4", "testClass");
      }
    };

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：検証値が空_評価結果がfalse
   * 結果：空のMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_検証値が空_評価結果がfalse() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition("==", "", "testClass")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"A4", "1", "", "string", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"A4", "1", "", "", "string", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "testValue");
        put("B10", "10");
        put("B11", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {};

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：検証値が空文字_評価結果がtrue
   * 結果：idとclassのMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_検証値が空文字_評価結果がtrue() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition("==", "''", "testClass")
    );
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"A4", "1", "", "string", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"A4", "1", "", "", "string", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "");
        put("B10", "10");
        put("B11", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("A4", "testClass");
      }
    };

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：検証値が空文字_評価結果がfalse
   * 結果：空のMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_検証値が空文字_評価結果がfalse() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition("==", "''", "testClass")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"A4", "1",  "", "string", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"A4", "1", "", "", "string", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "testValue");
        put("B10", "10");
        put("B11", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {};

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：検証値が文字列以外_評価結果がtrue
   * 結果：idとclassのMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_検証値が文字列以外_評価結果がtrue() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition(">=", "9", "testClass")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"B10", "1", "", "decimal", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"B10", "1", "", "", "decimal", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "test4");
        put("B10", "10");
        put("B11", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("B10", "testClass");
      }
    };

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：検証値が文字列以外_評価結果がfalse
   * 結果：空のMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_検証値が文字列以外_評価結果がfalse() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition("<", "10", "testClass")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"B10", "1", "", "decimal", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"B10", "1", "", "", "decimal", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "test4");
        put("B10", "10");
        put("B11", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {};

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：検証値が文字列以外で値が空_評価結果がtrue
   * 結果：idとclassのMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_検証値が文字列以外で値が空_評価結果がfalse() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition("<=", "9", "testClass")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"B10", "1",  "", "decimal", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"B10", "1", "", "", "decimal", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "test4");
        put("B10", "");
        put("B11", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {};

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：formatConditionが複数_1番目の評価結果がtrue
   * 結果：formatConditionの1番目のidとclassのMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_formatConditionが複数_1番目の評価結果がtrue() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition(">=", "9", "testClass1"),
    new ReportXmlFormatCondition(">=", "8", "testClass2")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"B10", "1", "", "decimal", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"B10", "1", "", "", "decimal", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "test4");
        put("B10", "10");
        put("B11", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("B10", "testClass1");
      }
    };

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：formatConditionが複数_2番目の評価結果がtrue
   * 結果：formatConditionの2番目のidとclassのMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_formatConditionが複数_2番目の評価結果がtrue() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition("==", "9", "testClass1"),
      new ReportXmlFormatCondition("==", "10", "testClass2")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"B10", "1", "", "decimal", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"B10", "1", "", "", "decimal", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "test4");
        put("B10", "10");
        put("B11", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("B10", "testClass2");
      }
    };

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：idが複数行に該当_評価結果がtrue
   * 結果：複数行のidとclassのMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_idが複数行に該当_評価結果がtrue() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition(">=", "8", "testClass")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"B10", "1",  "", "decimal", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"B10", "1", "", "", "decimal", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "test4");
        put("B10-1", "10");
        put("B10-2", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {
      {
        put("B10-1", "testClass");
        put("B10-2", "testClass");
      }
    };

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createFormatConditionInfo()の検証.
   *
   * 条件：検証時に例外が発生
   * 結果：空のMapが取得できること
   */
  @Test
  public void test_createFormatConditionInfo_成功_検証時に例外が発生() throws Throwable {
    // 事前準備
    List<ReportXmlFormatCondition> reportXmlFormatConditions = Arrays.asList(
      new ReportXmlFormatCondition(">>", "9", "testClass")
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"B10", "1", "", "decimal", "", "", "", "", "", "", "", "", "", null, null, reportXmlFormatConditions, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"B10", "1", "", "", "decimal", "", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        put("A1", "test1");
        put("A4", "test4");
        put("B10", "10");
        put("B11", "8");
      }
    };
    Long reportCd = 1L;

    Map<String, String> expected = new HashMap<String, String>() {};

    // 実行
    Map<String, String> result = invokeCreateFormatConditionInfo(params, reportOutputInfo, reportCd);

    // 検証
    assertThat(result, is(expected));
  }

  /**
   * createResizeFontSizeInfo()の検証.
   *
   * 条件：縮小率が算出される（複数行も含む）
   * 結果：縮小率変更のidとscale,translateのMapが取得できること
   */
  @Test
  public void test_createResizeFontSizeInfo_成功_縮小率が算出される() throws Throwable {
    // 事前準備
    StringBuilder sb = new StringBuilder();
    sb.append("<HTML xmlns=\"http://www.w3.org/TR/REC-html40\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\">");
    sb.append("<HEAD>");
    sb.append("<META content=\"text/html; charset=utf-8\" http-equiv=Content-Type>");
    sb.append("<META name=ProgId content=Excel.Sheet>");
    sb.append("<META name=Generator content=\"Microsoft Excel 15\"><LINK rel=File-List href=\"透析レポート(サンプル).files/filelist.xml\">");
    sb.append("<style id=\"透析レポート_20190524_2049_20190524205013_Styles\">");
    sb.append("<!--table");
    sb.append("{mso-displayed-decimal-separator:\"\\.\";");
    sb.append("mso-displayed-thousand-separator:\"\\,\";}");
    sb.append(".testclass");
    sb.append("{font-size:10.0pt;}");
    sb.append(".addclass");
    sb.append("{font-size:20.0pt;}");
    sb.append("-->");
    sb.append("</style>");
    sb.append("</HEAD>");
    sb.append("<BODY>");
    sb.append("<DIV id=レイアウト_20190509180033 align=center x:publishsource=\"Excel\">");
    sb.append("<TABLE><TBODY>");
    sb.append("<TD id=\"A1:A2\" class=\"testclass\"></TD>");
    sb.append("<TD id=\"B1:C1\" class=\"testclass\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("<TD id=\"B2:C2\" class=\"testclass\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("<TD id=\"B3:C3\" class=\"testclass\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("<TD id=\"B4:C4\" class=\"testclass\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("<TD id=\"D1:E2\"></TD>");
    sb.append("<TD id=\"F1:F1\"></TD>");
    sb.append("<TD id=\"F2:F2-1\" class=\"testclass\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("<TD id=\"F2:F2-2\" class=\"testclass\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("</TBODY></TABLE></DIV></BODY></HTML>");
    String reportHtml = sb.toString();
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"A1:A2", "1", "", "", "decimal", "1", "", "", "", "", "", "", "50",  null, null, null, null, null, null, null, null),
//      ReportXmlParam.of(null,"B1:C1", "1", "", "", "decimal", "1", "", "", "", "", "", "", "50",  null, null, null, null, null, null, null, null),
//      ReportXmlParam.of(null,"B2:C2", "1", "", "", "decimal", "0", "", "", "", "", "", "", "50",  null, null, null, null, null, null, null, null),
//      ReportXmlParam.of(null,"B3:C3", "1", "", "", "decimal", "1", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null),
//      ReportXmlParam.of(null,"B4:C4", "1", "", "", "decimal", "1", "", "", "", "", "", "", "50",  null, null, null, null, null, null, null, null),
//      ReportXmlParam.of(null,"F2:F2", "1", "", "", "decimal", "1", "", "", "", "", "", "", "50",  null, null, null, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"A1:A2", "1", "", "", "decimal", "1", "", "", "", "", "", "", "50", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null),
      ReportXmlParam.of(null,null,"B1:C1", "1", "", "", "decimal", "1", "", "", "", "", "", "", "50", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null),
      ReportXmlParam.of(null,null,"B2:C2", "1", "", "", "decimal", "0", "", "", "", "", "", "", "50", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null),
      ReportXmlParam.of(null,null,"B3:C3", "1", "", "", "decimal", "1", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null),
      ReportXmlParam.of(null,null,"B4:C4", "1", "", "", "decimal", "1", "", "", "", "", "", "", "50", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null),
      ReportXmlParam.of(null,null,"F2:F2", "1", "", "", "decimal", "1", "", "", "", "", "", "", "50", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        // 縮小なし
        put("A1:A2", "test1");
        // 半角のみ
        put("B1:C1", "testtesttesttesttesttesttest");
        // isShrinkが"0"
        put("B2:C2", "testtesttesttesttesttesttest");
        // colWidthが未設定
        put("B3:C3", "testtesttesttesttesttesttest");
        // 条件付き書式が設定
        put("B4:C4", "testtesttesttesttesttesttest");
        // 半角全角混在
        put("F2:F2-1", "testtesttestテストテストテスト");
        // scaleが0.1未満
        put("F2:F2-2", "testtesttestテストテストテストtesttesttestテストテストテストtesttesttestテストテストテスト");
      }
    };

    Map<String, String> formatConditionInfo = new HashMap<String, String>() {
      {
        put("B4:C4", "addclass");
      }
    };

    // 実行
    Map<String, String[]> result = invokeCreateResizeFontSizeInfo(reportHtml, params, reportOutputInfo, formatConditionInfo);

    // 検証
    assertThat(result.size(), is(4));
    assertThat(result.get("B1:C1")[0], is("0.24"));
    assertThat(result.get("B1:C1")[1], is("-80.00"));
    assertThat(result.get("B4:C4")[0], is("0.12"));
    assertThat(result.get("B4:C4")[1], is("-185.00"));
    assertThat(result.get("F2:F2-1")[0], is("0.22"));
    assertThat(result.get("F2:F2-1")[1], is("-87.50"));
    assertThat(result.get("F2:F2-2")[0], is("0.10"));
    assertThat(result.get("F2:F2-2")[1], is("-225.00"));
  }

  /**
   * createResizeFontSizeInfo()の検証.
   *
   * 条件：styleタグが取得できない
   * 結果：空のMapが取得できること
   */
  @Test
  public void test_createResizeFontSizeInfo_成功_styleタグが取得できない() throws Throwable {
    // 事前準備
    StringBuilder sb = new StringBuilder();
    sb.append("<HTML xmlns=\"http://www.w3.org/TR/REC-html40\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\">");
    sb.append("<HEAD>");
    sb.append("<META content=\"text/html; charset=utf-8\" http-equiv=Content-Type>");
    sb.append("<META name=ProgId content=Excel.Sheet>");
    sb.append("<META name=Generator content=\"Microsoft Excel 15\"><LINK rel=File-List href=\"透析レポート(サンプル).files/filelist.xml\">");
    sb.append("</HEAD>");
    sb.append("<BODY>");
    sb.append("<DIV id=レイアウト_20190509180033 align=center x:publishsource=\"Excel\">");
    sb.append("<TABLE><TBODY>");
    sb.append("<TD id=\"A1:A2\"></TD>");
    sb.append("<TD id=\"B1:C1\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("<TD id=\"B2:C2\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("<TD id=\"B3:C3\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("<TD id=\"D1:E2\"></TD>");
    sb.append("<TD id=\"F1:F1\"></TD>");
    sb.append("<TD id=\"F2:F2-1\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("<TD id=\"F2:F2-2\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("</TBODY></TABLE></DIV></BODY></HTML>");
    String reportHtml = sb.toString();
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> params = Arrays.asList(
//      ReportXmlParam.of(null,"A1:A2", "1", "", "", "decimal", "1", "", "", "", "", "", "", "50",  null, null, null, null, null, null, null, null),
//      ReportXmlParam.of(null,"B1:C1", "1", "", "", "decimal", "1", "", "", "", "", "", "", "50",  null, null, null, null, null, null, null, null),
//      ReportXmlParam.of(null,"B2:C2", "1", "", "", "decimal", "0", "", "", "", "", "", "", "50",  null, null, null, null, null, null, null, null),
//      ReportXmlParam.of(null,"B3:C3", "1", "", "", "decimal", "1", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null),
//      ReportXmlParam.of(null,"F2:F2", "1", "", "", "decimal", "1", "", "", "", "", "", "", "50",  null, null, null, null, null, null, null, null)
//    );
    List<ReportXmlParam> params = Arrays.asList(
      ReportXmlParam.of(null,null,"A1:A2", "1", "", "", "decimal", "1", "", "", "", "", "", "", "50", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null),
      ReportXmlParam.of(null,null,"B1:C1", "1", "", "", "decimal", "1", "", "", "", "", "", "", "50", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null),
      ReportXmlParam.of(null,null,"B2:C2", "1", "", "", "decimal", "0", "", "", "", "", "", "", "50", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null),
      ReportXmlParam.of(null,null,"B3:C3", "1", "", "", "decimal", "1", "", "", "", "", "", "", "", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null),
      ReportXmlParam.of(null,null,"F2:F2", "1", "", "", "decimal", "1", "", "", "", "", "", "", "50", "", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    );
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        // 縮小なし
        put("A1:A2", "test1");
        // 半角のみ
        put("B1:C1", "testtesttesttesttesttesttest");
        // isShrinkが"0"
        put("B2:C2", "testtesttesttesttesttesttest");
        // colWidthが未設定
        put("B3:C3", "testtesttesttesttesttesttest");
        // 半角全角混在
        put("F2:F2-1", "testtesttestテストテストテスト");
        // scaleが0.1未満
        put("F2:F2-2", "testtesttestテストテストテストtesttesttestテストテストテストtesttesttestテストテストテスト");
      }
    };

    // 実行
    Map<String, String[]> result = invokeCreateResizeFontSizeInfo(reportHtml, params, reportOutputInfo, Collections.EMPTY_MAP);

    // 検証
    assertThat(result.size(), is(0));
  }

  /**
   * reflectReportHtml()の検証.
   *
   * 条件：帳票デザインHTMLに反映する帳票出力情報と縮小率が指定されている
   * 結果：帳票出力情報と縮小率の内容が帳票デザインHTMLへ反映され返却されること
   */
  @Test
  public void test_reflectReportHtml_成功_縮小率が反映された() throws Throwable {
    // 事前準備
    StringBuilder sb = new StringBuilder();
    sb.append("<HTML xmlns=\"http://www.w3.org/TR/REC-html40\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\">");
    sb.append("<HEAD>");
    sb.append("<META content=\"text/html; charset=utf-8\" http-equiv=Content-Type>");
    sb.append("<META name=ProgId content=Excel.Sheet>");
    sb.append("<META name=Generator content=\"Microsoft Excel 15\"><LINK rel=File-List href=\"透析レポート(サンプル).files/filelist.xml\">");
    sb.append("</HEAD>");
    sb.append("<BODY>");
    sb.append("<DIV id=レイアウト_20190509180033 align=center x:publishsource=\"Excel\">");
    sb.append("<TABLE><TBODY>");
    sb.append("<TD id=\"A1:A2\"></TD>");
    sb.append("<TD id=\"B1:C1\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("<TD id=\"B2:C2\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("<TD id=\"B3:C3\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("<TD id=\"D1:E2\"></TD>");
    sb.append("<TD id=\"F1:F1\"></TD>");
    sb.append("<TD id=\"F2:F2-1\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("<TD id=\"F2:F2-2\" style=\"BORDER-RIGHT: black 0.5pt solid\"></TD>");
    sb.append("</TBODY></TABLE></DIV></BODY></HTML>");
    String reportHtml = sb.toString();

    // Map<id属性値, Value>
    Map<String, String> reportOutputInfo = new HashMap<String, String>() {
      {
        // 縮小なし
        put("A1:A2", "test1");
        // 半角のみ
        put("B1:C1", "testtesttesttesttesttesttest");
        // isShrinkが"0"
        put("B2:C2", "testtesttesttesttesttesttest");
        // colWidthが未設定
        put("B3:C3", "testtesttesttesttesttesttest");
        // 半角全角混在
        put("F2:F2-1", "testtesttestテストテストテスト");
        // scaleが0.1未満
        put("F2:F2-2", "testtesttestテストテストテストtesttesttestテストテストテストtesttesttestテストテストテスト");
      }
    };

    String[] resize1 = {"0.24", "-80.01"};
    String[] resize2 = {"0.22", "-87.53"};
    String[] resize3 = {"0.10", "-224.83"};

    // Map<id属性値, Value>
    Map<String, String[]> resizeFontSizeInfo = new HashMap<>();
    resizeFontSizeInfo.put("B1:C1", resize1);
    resizeFontSizeInfo.put("F2:F2-1", resize2);
    resizeFontSizeInfo.put("F2:F2-2", resize3);

    StringBuilder sbExpect = new StringBuilder();
    sbExpect.append("<HTML xmlns=\"http://www.w3.org/TR/REC-html40\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\">");
    sbExpect.append("<HEAD>");
    sbExpect.append("<META content=\"text/html; charset=utf-8\" http-equiv=Content-Type>");
    sbExpect.append("<META name=ProgId content=Excel.Sheet>");
    sbExpect.append("<META name=Generator content=\"Microsoft Excel 15\"><LINK rel=File-List href=\"透析レポート(サンプル).files/filelist.xml\">");
    sbExpect.append("</HEAD>");
    sbExpect.append("<BODY>");
    sbExpect.append("<DIV id=レイアウト_20190509180033 align=center x:publishsource=\"Excel\">");
    sbExpect.append("<TABLE><TBODY>");
    sbExpect.append("<TD id=\"A1:A2\">test1</TD>");
    sbExpect.append("<TD id=\"B1:C1\" style=\"BORDER-RIGHT: black 0.5pt solid\">");
    sbExpect.append("<DIV style=\"transform: scale(0.24) translate(-80.01px); -webkit-transform: scale(0.24) translate(-80.01px);\">testtesttesttesttesttesttest</DIV>");
    sbExpect.append("</TD>");
    sbExpect.append("<TD id=\"B2:C2\" style=\"BORDER-RIGHT: black 0.5pt solid\">testtesttesttesttesttesttest</TD>");
    sbExpect.append("<TD id=\"B3:C3\" style=\"BORDER-RIGHT: black 0.5pt solid\">testtesttesttesttesttesttest</TD>");
    sbExpect.append("<TD id=\"D1:E2\"></TD>");
    sbExpect.append("<TD id=\"F1:F1\"></TD>");
    sbExpect.append("<TD id=\"F2:F2-1\" style=\"BORDER-RIGHT: black 0.5pt solid\">");
    sbExpect.append("<DIV style=\"transform: scale(0.22) translate(-87.53px); -webkit-transform: scale(0.22) translate(-87.53px);\">testtesttestテストテストテスト</DIV>");
    sbExpect.append("</TD>");
    sbExpect.append("<TD id=\"F2:F2-2\" style=\"BORDER-RIGHT: black 0.5pt solid\">");
    sbExpect.append("<DIV style=\"transform: scale(0.10) translate(-224.83px); -webkit-transform: scale(0.10) translate(-224.83px);\">testtesttestテストテストテストtesttesttestテストテストテストtesttesttestテストテストテスト</TD>");
    sbExpect.append("</TD>");
    sbExpect.append("</TBODY></TABLE></DIV></BODY></HTML>");
    String reportHtmlExpect = sbExpect.toString();

    org.jsoup.nodes.Document documentExpect = Jsoup.parse(reportHtmlExpect);

    // 実行
    String result = invokeReflectReportHtml(reportHtml, reportOutputInfo, Collections.EMPTY_MAP, Collections.EMPTY_MAP, Collections.EMPTY_MAP, resizeFontSizeInfo);

    // 検証
    assertThat(result).isEqualTo(documentExpect.html());
  }

  @Test
  public void test_getReportImage_正常() throws IOException, URISyntaxException {
    // 事前準備
    Long reportCd = 1L;
    @SuppressWarnings("serial")
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("param1", "value1");
        put("param2", "value2");
      }
    };
    Long targetPrinter = 1L;
    Long userId = 99999L;

    String reportZip = "テスト透析レポート.zip";
    String htmlName = "testDialysisReport.html";
    String xmlName = "testDialysisReport.xml";
    String bucket = "ntss-esm";

    MstReport mstReport = new MstReport();
    mstReport.setReportCd(reportCd);
    MstReport.ReportPath reportPath = new MstReport.ReportPath();
    reportPath.setReportZip(reportZip);
    reportPath.setHtmlFilename(htmlName);
    reportPath.setXmlFilename(xmlName);
    reportPath.setBucket(bucket);
    mstReport.setReportPath(reportPath);

    Path path = Paths.get(getClass().getClassLoader().getResource("resource.report/" + reportZip).toURI());
    byte[] bytes = Files.readAllBytes(path);
    ReportZipFile zip = new ReportZipFile(bytes);

    String reportHtml = zip.getFileToString(htmlName);

    List<Map<String, Object>> reportOutputInfo1 = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("1", "test1");
          put("4", "test2");
          put("10", "10");
          put("11", "8");
        }
      });
    List<Map<String, Object>> reportOutputInfo2 = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("3", "test3");
        }
      });

    org.jsoup.nodes.Document document = Jsoup.parse(reportHtml);
    document.getElementById("M1:O1").text("test1");
    document.getElementById("M1:O3").text("test3");
    document.getElementById("M1:O4").text("test2");
    document.getElementById("M1:O5").text("2");
    String expected = document.html();

    // Mock化
    given(mstReportDao.selectByCd(reportCd)).willReturn(mstReport);
    given(reportS3Service.getReportFile(bucket, reportZip, null)).willReturn(bytes);
    given(sysDataSetService.getDataList(1L, dataKey)).willReturn(reportOutputInfo1);
    given(sysDataSetService.getDataList(3L, dataKey)).willReturn(reportOutputInfo2);

    // 実行
    try {
      String result = target.getReportImage(reportCd, dataKey, "png", new URL(""));
    } catch (NtssException e) {
      // wkhtmltoimageがインストールされていない場合
      return;
    }

    // 検証
    verify(mstReportDao, times(1)).selectByCd(reportCd);
    verify(reportS3Service, times(1)).getReportFile(bucket, reportZip, null);
    verify(sysDataSetService, times(1)).getDataList(eq(1L), eq(dataKey));
    verify(sysDataSetService, times(1)).getDataList(eq(3L), eq(dataKey));
  }
}
