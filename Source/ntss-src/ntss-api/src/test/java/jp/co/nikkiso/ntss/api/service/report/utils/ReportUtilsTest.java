package jp.co.nikkiso.ntss.api.service.report.utils;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.hamcrest.Matchers.samePropertyValuesAs;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;

import jp.co.nikkiso.ntss.api.domain.report.ReportXmlFilter;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlGroup;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlParam;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlTmplRepeat;
import jp.co.nikkiso.ntss.api.service.utils.ReportUtils;
import jp.co.nikkiso.ntss.core.exception.NtssException;

public class ReportUtilsTest {

  /**
   * 例外の発生をテストするためのルール
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * getParamElements()の検証.
   *
   * 条件：指定されたXMLがParseできる
   * 結果：Param要素の情報が返却されること
   */
  @Test
  public void test_getParamElements_成功() {
    // 事前準備
    StringBuilder sb = new StringBuilder();
    sb.append("<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>");
    sb.append("<ReportDefinition>");
    sb.append("  <report type=\"Dialysis\" hasTmpl=\"0\" />");
    sb.append("  <paramTable>");
    sb.append("    <param id=\"1\" dispType=\"2\" dataCode=\"3\" sqlCode=\"4\" dataType=\"5\" isShrink=\"6\" dispLength=\"7\" filterType=\"8\" dispFormat=\"9\" formula=\"10\" groupID=\"11\" isInTmpl=\"12\" isNewPage=\"13\" colWidth=\"14\" />");
    sb.append("    <param id=\"\" dispType=\"\" dataCode=\"\" sqlCode=\"\" dataType=\"\" isShrink=\"\" dispLength=\"\" filterType=\"\" dispFormat=\"\" formula=\"\" groupID=\"\" />");
    sb.append("    <param />");
    sb.append("  </paramTable>");
    sb.append("  <groupTable>");
    sb.append("    <group id=\"1\" repeatMax=\"2\" isNewPage=\"3\" filterType=\"4\" />");
    sb.append("    <group id=\"9\" repeatMax=\"9\" isNewPage=\"9\" filterType=\"9\" />");
    sb.append("  </groupTable>");
    sb.append("</ReportDefinition>");
    String reportXml = sb.toString();
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    List<ReportXmlParam> expected = Arrays.asList(
//      ReportXmlParam.of(null,"1", "2", "3", "4", "5", "6", "7", "9", "10", "11", "12", "13", "14", Collections.EMPTY_LIST, null, Collections.EMPTY_LIST, null, null, null, "", Collections.EMPTY_MAP)
//      , ReportXmlParam.of(null,"", "", "", "", "", "", "", "", "", "", "", "", "", Collections.EMPTY_LIST, null, Collections.EMPTY_LIST, null, null, null, "", Collections.EMPTY_MAP)
//      , ReportXmlParam.of(null,"", "", "", "", "", "", "", "", "", "", "", "", "", Collections.EMPTY_LIST, null, Collections.EMPTY_LIST, null, null, null, "", Collections.EMPTY_MAP)
//    );
    List<ReportXmlParam> expected = Arrays.asList(
      ReportXmlParam.of(null,null,"1", "2", "3", "4", "5", "6", "7", "9", "10", "11", "12", "13", "14","15", null, null, null, Collections.EMPTY_LIST, null, null, null, null, null, null, null, null, null, null)
    );
// mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    // 実行
    List<ReportXmlParam> result = ReportUtils.getParamElements(reportXml);

    // 検証
    assertThat(result, hasSize(3));
    assertThat(result.get(0), is(samePropertyValuesAs(expected.get(0))));
    assertThat(result.get(1), is(samePropertyValuesAs(expected.get(1))));
    assertThat(result.get(2), is(samePropertyValuesAs(expected.get(2))));
  }

  /**
   * getParamElements()の検証.
   *
   * 条件：指定されたXMLがParseできる
   * 結果：groupId属性に該当するgroup要素の情報が返却されること
   */
  @Test
  public void test_getParamElements_成功_group属性() {
    // 事前準備
    StringBuilder sb = new StringBuilder();
    sb.append("<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>");
    sb.append("<ReportDefinition>");
    sb.append("  <paramTable>");
    sb.append("    <param id=\"1\" groupID=\"1\" />");
    sb.append("    <param id=\"2\" groupID=\"2\" />");
    sb.append("    <param id=\"3\" groupID=\"\" />");
    sb.append("  </paramTable>");
    sb.append("  <groupTable>");
    sb.append("    <group id=\"1\" repeatMax=\"2\" isNewPage=\"3\" filterType=\"4\" />");
    sb.append("    <group id=\"9\" repeatMax=\"9\" isNewPage=\"9\" filterType=\"9\" />");
    sb.append("  </groupTable>");
    sb.append("</ReportDefinition>");
    String reportXml = sb.toString();

    ReportXmlGroup group = new ReportXmlGroup("1", 2, 3, "4", Collections.EMPTY_LIST);

    // 実行
    List<ReportXmlParam> result = ReportUtils.getParamElements(reportXml);

    // 検証
    assertThat(result, hasSize(3));
    assertThat(result.get(0).getReportXmlGroup(), is(samePropertyValuesAs(group)));
    assertThat(result.get(1).getReportXmlGroup(), nullValue());
    assertThat(result.get(2).getReportXmlGroup(), nullValue());
  }

  /**
   * getParamElements()の検証.
   *
   * 条件：指定されたXMLがParseできる
   * 結果：group要素に含まれるfilter要素の情報が返却されること
   */
  @Test
  public void test_getParamElements_成功_filter要素() throws Throwable {
    // 事前準備
    StringBuilder sb = new StringBuilder();
    sb.append("<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>");
    sb.append("<ReportDefinition>");
    sb.append("  <paramTable>");
    sb.append("    <param id=\"1\" groupID=\"1\" />");
    sb.append("    <param id=\"2\" groupID=\"2\" />");
    sb.append("    <param id=\"3\" groupID=\"3\" />");
    sb.append("  </paramTable>");
    sb.append("  <groupTable>");
    sb.append("    <group id=\"1\" repeatMax=\"1\" isNewPage=\"1\" filterType=\"1\">");
    sb.append("      <filterTable>");
    sb.append("        <filter item=\"item1-1\" col=\"col1-1\" />");
    sb.append("      </filterTable>");
    sb.append("    </group>");
    sb.append("    <group id=\"2\" repeatMax=\"2\" isNewPage=\"2\" filterType=\"2\">");
    sb.append("      <filterTable>");
    sb.append("        <filter item=\"item2-1\" col=\"col2-1\" />");
    sb.append("        <filter item=\"item2-2\" col=\"col2-2\" />");
    sb.append("      </filterTable>");
    sb.append("    </group>");
    sb.append("    <group id=\"3\" repeatMax=\"3\" isNewPage=\"3\" filterType=\"3\" />");
    sb.append("  </groupTable>");
    sb.append("</ReportDefinition>");
    String reportXml = sb.toString();

    ReportXmlFilter filter11 = new ReportXmlFilter("item1-1", "col1-1", "");
    ReportXmlFilter filter21 = new ReportXmlFilter("item2-1", "col2-1", "");
    ReportXmlFilter filter22 = new ReportXmlFilter("item2-2", "col2-2", "");

    // 実行
    List<ReportXmlParam> result = ReportUtils.getParamElements(reportXml);

    // 検証
    assertThat(result, hasSize(3));
    assertThat(result.get(0).getReportXmlGroup().getReportXmlFilters(), hasSize(1));
    assertThat(result.get(0).getReportXmlGroup().getReportXmlFilters().get(0), is(samePropertyValuesAs(filter11)));
    assertThat(result.get(1).getReportXmlGroup().getReportXmlFilters(), hasSize(2));
    assertThat(result.get(1).getReportXmlGroup().getReportXmlFilters().get(0), is(samePropertyValuesAs(filter21)));
    assertThat(result.get(1).getReportXmlGroup().getReportXmlFilters().get(1), is(samePropertyValuesAs(filter22)));
    assertThat(result.get(2).getReportXmlGroup().getReportXmlFilters(), hasSize(0));
  }

  /**
   * getParamElements()の検証.
   *
   * 条件：指定されたXMLがParseできる
   * 結果：tmplRepeat要素の情報が返却されること
   */
  @Test
  public void test_getParamElements_成功_tmplRepeat要素() {
    // 事前準備
    StringBuilder sb = new StringBuilder();
    sb.append("<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>");
    sb.append("<ReportDefinition>");
    sb.append("  <paramTable>");
    sb.append("    <param id=\"1\" isInTmpl=\"1\" />");
    sb.append("    <param id=\"2\" isInTmpl=\"0\" />");
    sb.append("    <param id=\"3\" isInTmpl=\"\" />");
    sb.append("    <param id=\"4\" isInTmpl=\"1\" />");
    sb.append("  </paramTable>");
    sb.append("  <tmplRepeat id=\"12345\" repeatMode=\"Dialysis\" repeatMax=\"5\" isNewPage=\"0\" direction=\"1\" />");
    sb.append("</ReportDefinition>");
    String reportXml = sb.toString();

    ReportXmlTmplRepeat repeat = new ReportXmlTmplRepeat("12345", 0, 0, 0, 0, 5, "Dialysis", "",0, "1", 0, 0);

    // 実行
    List<ReportXmlParam> result = ReportUtils.getParamElements(reportXml);

    // 検証
    assertThat(result, hasSize(4));
    assertThat(result.get(0).getReportXmlTmplRepeat(), is(samePropertyValuesAs(repeat)));
    assertThat(result.get(1).getReportXmlGroup(), nullValue());
    assertThat(result.get(2).getReportXmlGroup(), nullValue());
    assertThat(result.get(3).getReportXmlTmplRepeat(), is(samePropertyValuesAs(repeat)));
  }

  /**
   * getParamElements()の検証.
   *
   * 条件：指定されたXMLがParseできる
   * 結果：tmplRepeat要素が複数存在する場合、tmplRepeat要素の情報が返却されないこと
   */
  @Test
  public void test_getParamElements_成功_tmplRepeat要素が複数() {
    // 事前準備
    StringBuilder sb = new StringBuilder();
    sb.append("<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>");
    sb.append("<ReportDefinition>");
    sb.append("  <paramTable>");
    sb.append("    <param id=\"1\" isInTmpl=\"1\" />");
    sb.append("  </paramTable>");
    sb.append("  <tmplRepeat id=\"12345\" repeatMode=\"Dialysis\" repeatMax=\"5\" isNewPage=\"0\" direction=\"1\" />");
    sb.append("  <tmplRepeat id=\"99999\" repeatMode=\"Dialysis\" repeatMax=\"5\" isNewPage=\"0\" direction=\"1\" />");
    sb.append("</ReportDefinition>");
    String reportXml = sb.toString();

    // 実行
    List<ReportXmlParam> result = ReportUtils.getParamElements(reportXml);

    // 検証
    assertThat(result, hasSize(1));
    assertThat(result.get(0).getReportXmlGroup(), nullValue());
  }

  /**
   * getParamElements()の検証.
   *
   * 条件：指定されたXMLがParseできない
   * 結果：NtssExceptionが発生すること
   */
  @Test
  public void test_getParamElements_異常() {
    // 事前準備
    String reportXml = "あいうえお";

    // 実行
    // 検証
    expectedException.expect(NtssException.class);
    expectedException.expectMessage("");
    ReportUtils.getParamElements(reportXml);
  }

}
