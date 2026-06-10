package jp.co.nikkiso.ntss.api.service.report.utils;

import jp.co.nikkiso.ntss.api.service.utils.ReportZipFile;
import org.junit.Test;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;

public class ReportZipFileTest {

  /**
   * getFileToString()の検証.
   *
   * 条件：圧縮ファイルに帳票定義XMLと帳票デザインHTMLが格納されていること（ファイル名が日本語）
   * 結果：帳票定義XMLと帳票デザインHTMLの内容が取得できること
   */
  @Test
  public void test_getFileToString_成功_対象ファイルあり_日本語() throws Throwable {

    // 事前準備
    Path path = Paths.get(getClass().getClassLoader().getResource("resource.report/テスト日本語ファイル.zip").toURI());
    ReportZipFile zip = new ReportZipFile(Files.readAllBytes(path));

    String expectedXml = "<xml></xml>";
    String expectedHtml = "<html></html>";

    // 実行
    String resultXml = zip.getFileToString("テストレポート.xml");
    String resultHtml = zip.getFileToString("テストレポート.html");

    // 検証
    assertThat(resultXml, is(expectedXml));
    assertThat(resultHtml, is(expectedHtml));
  }

  /**
   * getFileToString()の検証.
   *
   * 条件：圧縮ファイルに帳票定義XMLと帳票デザインHTMLが格納されていること（ファイル名が英字）
   * 結果：帳票定義XMLと帳票デザインHTMLの内容が取得できること
   */
  @Test
  public void test_getFileToString_成功_対象ファイルあり_英字() throws Throwable {

    // 事前準備
    Path path = Paths.get(getClass().getClassLoader().getResource("resource.report/テスト英字ファイル.zip").toURI());
    ReportZipFile zip = new ReportZipFile(Files.readAllBytes(path));

    String expectedXml = "<xml></xml>";
    String expectedHtml = "<html></html>";

    // 実行
    String resultXml = zip.getFileToString("testReport.xml");
    String resultHtml = zip.getFileToString("testReport.html");

    // 検証
    assertThat(resultXml, is(expectedXml));
    assertThat(resultHtml, is(expectedHtml));
  }

  /**
   * getFileToString()の検証.
   *
   * 条件：圧縮ファイルに指定されたファイルが格納されていないこと
   * 結果：<code>null</code>が返却されること
   */
  @Test
  public void test_getFileToString_成功_対象ファイルなし() throws Throwable {

    // 事前準備
    Path path = Paths.get(getClass().getClassLoader().getResource("resource.report/テスト英字ファイル.zip").toURI());
    ReportZipFile zip = new ReportZipFile(Files.readAllBytes(path));

    // 実行
    String result = zip.getFileToString("noFile.xml");

    // 検証
    assertThat(result, is(nullValue()));
  }

  /**
   * getFile()の検証.
   *
   * 条件：圧縮ファイルに帳票定義XMLと帳票デザインHTMLが格納されていること（ファイル名が日本語）
   * 結果：帳票定義XMLと帳票デザインHTMLの内容が取得できること
   */
  @Test
  public void test_getFile_成功_対象ファイルあり_日本語() throws Throwable {

    // 事前準備
    Path path = Paths.get(getClass().getClassLoader().getResource("resource.report/テスト日本語ファイル.zip").toURI());
    ReportZipFile zip = new ReportZipFile(Files.readAllBytes(path));

    String expectedXml = "<xml></xml>";
    String expectedHtml = "<html></html>";

    // 実行
    byte[] resultXml = zip.getFile("テストレポート.xml");
    byte[] resultHtml = zip.getFile("テストレポート.html");

    // 検証
    assertThat(resultXml, is(expectedXml.getBytes(StandardCharsets.UTF_8)));
    assertThat(resultHtml, is(expectedHtml.getBytes(StandardCharsets.UTF_8)));
  }

  /**
   * getFile()の検証.
   *
   * 条件：圧縮ファイルに指定されたファイルが格納されていないこと
   * 結果：<code>null</code>が返却されること
   */
  @Test
  public void test_getFile_成功_対象ファイルなし() throws Throwable {

    // 事前準備
    Path path = Paths.get(getClass().getClassLoader().getResource("resource.report/テスト英字ファイル.zip").toURI());
    ReportZipFile zip = new ReportZipFile(Files.readAllBytes(path));

    // 実行
    byte[] result = zip.getFile("noFile.xml");

    // 検証
    assertThat(result, is(nullValue()));
  }

}
