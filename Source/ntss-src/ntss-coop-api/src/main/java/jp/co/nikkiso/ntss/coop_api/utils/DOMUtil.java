package jp.co.nikkiso.ntss.coop_api.utils;

import java.io.IOException;
import java.io.StringReader;

import javax.xml.namespace.QName;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * DOM操作をまとめたユーティリティクラス。
 */
public class DOMUtil {
  // DocumentBuilderオブジェクト、XPathオブジェクトとも以下の性質を持つ。
  // (1) 作成に時間コストがかかる。そのため特別な事情がない限り、都度作成するよりは1つ作成して使いまわす方が良い。
  // (2) 内部状態を持つ。つまりマルチスレッドセーフでない。
  // 上記の理由により、スレッド別にキャッシュする方法を採った。

  /** DocumentBuilderオブジェクトのスレッド別キャッシュ */
  private static ThreadLocal<DocumentBuilder> documentBuilderCache = new ThreadLocal<>();

  /** XPathFactoryオブジェクトのスレッド別キャッシュ */
  private static ThreadLocal<XPath> xpathCache = new ThreadLocal<>();

  /**
   * XML形式文字列を解析し、DOMを作成する。
   *
   * @param str XML形式文字列
   * @return 解析結果のDOM
   * @throws ParserConfigurationException
   * @throws SAXException
   * @throws IOException
   */
  public static Document parse(String str) throws ParserConfigurationException, SAXException, IOException {
    InputSource is = new InputSource(new StringReader(str));
    return getDocumentBuilder().parse(is);
  }

  /**
   * DocumentBuilderオブジェクトを取得する。
   *
   * @return DocumentBuilderオブジェクト
   * @throws ParserConfigurationException
   */
  private static synchronized DocumentBuilder getDocumentBuilder() throws ParserConfigurationException {
    DocumentBuilder builder = documentBuilderCache.get();

    if (builder == null) {
      DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
      builder = dbFactory.newDocumentBuilder();
      documentBuilderCache.set(builder);
    }

    return builder;
  }

  /**
   * DOMからXPath表現に該当する箇所を抽出する。
   *
   * @param expression XPath表現
   * @param source DOMオブジェクト
   * @return 該当箇所の文字列
   * @throws XPathExpressionException
   */
  public static String evaluate(String expression, Object source) throws XPathExpressionException {
    return getXPath().evaluate(expression, source);
  }

  /**
   * DOMからXPath表現に該当する箇所を抽出する。
   *
   * @param expression XPath表現
   * @param source DOMオブジェクト
   * @param returnType 返値の型
   * @return 該当箇所（型はreturnType引数に従う）
   * @throws XPathExpressionException
   */
  public static Object evaluate(String expression, Object source, QName returnType) throws XPathExpressionException {
    return getXPath().evaluate(expression, source, returnType);
  }

  /**
   * XPathオブジェクトを取得する。
   *
   * @return XPathオブジェクト
   */
  private static synchronized XPath getXPath() {
    XPath xp = xpathCache.get();

    if (xp == null) {
      XPathFactory factory = XPathFactory.newInstance();
      xp = factory.newXPath();
      xpathCache.set(xp);
    }

    return xp;
  }
}
