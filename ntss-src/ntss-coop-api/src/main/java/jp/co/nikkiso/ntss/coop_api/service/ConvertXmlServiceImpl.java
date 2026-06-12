package jp.co.nikkiso.ntss.coop_api.service;

import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.AUX_CODE_ALL;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.AUX_CODE_PRELOGIC;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;

import jp.co.nikkiso.ntss.coop_api.utils.DOMUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.JsonMapUtil;
import jp.co.nikkiso.ntss.coop_api.utils.Key0Constant;
import jp.co.nikkiso.ntss.coop_api.utils.LayoutExtSettingUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ValueEvaluatorUtil;
import jp.co.nikkiso.ntss.core.dao.MstCoopIniDao;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.collections4.MapUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultMap;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDetailDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import lombok.extern.slf4j.Slf4j;

/**
 * XML形式文字列をJSON形式に変換するサービスクラス。
 *
 * @see jp.co.nikkiso.ntss.coop_api.service.ConvertByFormatService
 */
@Service
@Slf4j
public class ConvertXmlServiceImpl implements ConvertByFormatService {

  /** 抽出対象を示すプレフィックス: col: */
  private static final String PREFIX_COL = "col:";

  /** 繰返しを示す属性: repeat */
  private static final String ATTR_REPEAT = "repeat";

  /** レイアウト分岐を示す属性: detail: */
  private static final String ATTR_DETAIL = "detail";

  /** 抽出対象のキー（テーブル名.カラム名.JSONキー名）を取り出す正規表現 */
  private static final String REGEXP_COL_VALUE = String.format("^%s([^,]*)(\\s*,\\s*((const|json|dataset|default)%s.*))?$",
      PREFIX_COL, JournalConvertConstants.EVAL_LABEL_DELIM);

  /** REGEXP_COL_VALUEで抽出した項目のインデックス: col指定の値 */
  private static final int INDEX_COL_VALUE = 1;

  /** REGEXP_COL_VALUEで抽出した項目のインデックス: オプション（const:～等） */
  private static final int INDEX_OPTION = 3;

  /** XPath表現: 着目しているノード */
  private static final String XPATH_HERE = ".";

  /** XPath表現: パス区切りを示す記号 */
  private static final String XPATH_DELIM = "/";

  /** XPath表現: 属性を示すプレフィックス */
  private static final String XPATH_PREFIX_ATTR = "@";

  /** XPath表現: 抽出条件の開始を表す記号 */
  private static final String XPATH_ATTRS_START = "[";

  /** XPath表現: 抽出条件の論理積を表す文字列 */
  private static final String XPATH_ATTRS_AND = " and ";

  /** XPath表現: 抽出条件の終了を表す記号 */
  private static final String XPATH_ATTRS_END = "]";

  /** XPath表現: テキストノード */
  private static final String XPATH_NODE_TEXT = "text()";

  /** レイアウトから「col:」で始まるテキストノードと属性ノードを抽出するXPath表現 */
  // 「ネストを問わないテキストノード（//text()）、もしくは、ネストを問わない要素の属性ノード（//@*）で、
  // 値から前後の空白・改行・タブを除いた結果（normalize-space(.)）がcol:で始まる（starts-with(*, 'col:')）もの」の意
  private static final String XPATH_ATTR_AND_TEXT_COL = String
      .format("(.//%s|.//%s*)[starts-with(normalize-space(.), '%s')]", XPATH_NODE_TEXT, XPATH_PREFIX_ATTR, PREFIX_COL);

  /** XPath表現: 属性repeat='true'を持つ要素（レイアウト解析用） */
  private static final String XPATH_ATTR_REPEAT = String.format(".//*[%s%s='true']", XPATH_PREFIX_ATTR, ATTR_REPEAT);

  /** XPath表現: 属性detailを持つ要素（レイアウト解析用、属性値は問わない） */
  private static final String XPATH_ATTR_DETAIL = String.format(".//*[%s%s]", XPATH_PREFIX_ATTR, ATTR_DETAIL);

  /** 要素に属性を結合するフォーマット */
  private static final String ATTR_FORMAT = "%s%s='%s'";

  /** レイアウトのdetail属性の値において、電文種別詳細コードと電文種別詳細補足コードキーを分けるデリミタ */
  private static final String DETAIL_DELIM = ",";

  /** DAOオブジェクト */
  @Autowired
  private MstCoopLayoutDao mstCoopLayoutDao;

  @Autowired
  private MstCoopLayoutDetailDao mstCoopLayoutDetailDao;

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  @Autowired
  private LayoutExtSettingUtil layoutExtSettingUtil;

  @Autowired
  private ValueEvaluatorUtil valueEvaluatorUtil;

  //add 7503 profile連携（XML）で受信した指示医コード・名称 zhaoqi 20221111 start
  @Autowired
  MstCoopIniDao mstCoopIniDao;
  //add 7503 profile連携（XML）で受信した指示医コード・名称 zhaoqi 20221111 end

  // mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
  @Autowired
  private ConvertCommonService convertCommonService;
  // mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

  /**
   * レイアウトXMLでcol属性が指定された項目の値をXML形式電文から取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param key0 電子カルテ種別
   * @param coopCdSub 電文種別補足コード
   * @param telegram 変換対象文字列
   * @param keyResult key属性が指定された項目の値
   * @return col:指定収集結果
   * @throws UnsupportedEncodingException SJISエンコーディングが使用できない場合
   * @see ConvertByFormatService#convert(String, String, String, String, byte[], jp.co.nikkiso.ntss.core.entity.xml.Root, jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting, jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultMap)
   */
  @Override
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  public ResultMap convert(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopCdSub, byte[] telegram,
//                           ResultMap keyResult)
//    throws UnsupportedEncodingException {
  public ResultMap convert(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopVersion,
                           String key0, String coopCdSub, byte[] telegram, ResultMap keyResult)
    throws UnsupportedEncodingException {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    try {
      // 電文のDOMを取得する。
      // 電文のエンコーディングはShift_JISとする。
      //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
//      String telegramStr = new String(telegram, JournalConvertConstants.TELEGRAM_ENCODING_BY_SJIS);
      String telegramStr = new String(telegram, JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932);
      //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
      Document telegramDOM = DOMUtil.parse(telegramStr);

      // レイアウトのDOMを取得する。
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      MstCoopLayout mcl = getMstCoopLayout(facilityCd, direction, coopCd, coopCdIndex, coopCdSub);
      MstCoopLayout mcl = getMstCoopLayout(facilityCd, direction, coopCd, coopCdIndex, coopVersion, coopCdSub);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      Document layoutDOM = DOMUtil.parse(mcl.getCoopSetting());

      // 電文を解析する。
      ResultMap colResult = new ResultMap();
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      parse(facilityCd, direction, coopCd, coopCdIndex, coopCdSub, telegramDOM, layoutDOM, colResult, mcl.getCoopExtSetting());
      parse(facilityCd, key0, direction, coopCd, coopCdIndex, coopVersion, coopCdSub, telegramDOM, layoutDOM, colResult,
        mcl.getCoopExtSetting());
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      // add 2021-09-09 #5897:CSI連携ができないの対応 孫 start
      // detailデータがList以外場合、Listを作成する
      if (!MapUtils.isEmpty(colResult)) {
        Set<String> keySet = colResult.keySet();
        for (String key : keySet) {
          Object value = colResult.get(key);
          if (key.startsWith("$journal.detail.") && !(value instanceof List)) {
            List<Object> listValue = new ArrayList<>();
            listValue.add(value);
            colResult.put(key, listValue);
          }
        }
      }
      // add 2021-09-09 #5897:CSI連携ができないの対応 孫 end
      JsonMapUtil.makeListOnSingleMap(colResult);
      return colResult;

    } catch (ParserConfigurationException | SAXException | IOException | XPathExpressionException e) {
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      String errMsg = String.format("XML電文解析エラーが発生しました。 施設コード={%s}", facilityCd);
      String errMsg = String.format("XML電文解析エラーが発生しました。 施設コード={%s}, 連携版番号={%s}", facilityCd, coopVersion);
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(errMsg);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg, e);
    }
  }

  /**
   * XML形式電文を解析する。<br/>
   * repeat="true"が指定された要素が存在する場合、その下はカラムごとにまとめてリストとして抽出する。
   *
   * @param facilityCd 施設コード
   * @param key0 電子カルテ種別
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param coopCdSub 電文種別補足コード
   * @param telegramNode 電文DOMのノード
   * @param layoutNode レイアウトDOMのノード
   * @param result 抽出結果
   * @param extSetting レイアウト拡張設定
   * @throws XPathExpressionException
   * @throws SAXException
   * @throws IOException
   * @throws ParserConfigurationException
   */
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private void parse(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopCdSub,
//      Node telegramNode, Node layoutNode, ResultMap result, LayoutExtSetting extSetting)
//      throws XPathExpressionException, SAXException, IOException, ParserConfigurationException {
  private void parse(String facilityCd, String key0, String direction, String coopCd, String coopCdIndex, String coopVersion,
                     String coopCdSub, Node telegramNode, Node layoutNode, ResultMap result, LayoutExtSetting extSetting)
    throws XPathExpressionException, SAXException, IOException, ParserConfigurationException {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // 通常ノードの下を解析する。
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    parseUsualNode(facilityCd, direction, coopCd, coopCdIndex, coopCdSub, telegramNode, layoutNode, result, extSetting);
    parseUsualNode(facilityCd, key0, direction, coopCd, coopCdIndex, coopVersion, coopCdSub, telegramNode, layoutNode, result, extSetting);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // 0213debuglog
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(facilityCd + ":parseUsualNode result=" + result);
    eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // 繰返し構造の処理
    // repeat属性を持つ要素の下を解析する。
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    parseRepeatNode(facilityCd, direction, coopCd, coopCdIndex, coopCdSub, telegramNode, layoutNode, result, extSetting);
    parseRepeatNode(facilityCd, key0, direction, coopCd, coopCdIndex, coopVersion, coopCdSub, telegramNode, layoutNode, result, extSetting);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // 0213debuglog
    EventLogMessage eventLogMessage2 = new EventLogMessage();
    eventLogMessage2.setLogMessage(facilityCd + ":parseRepeatNode result=" + result);
    eventLogMessage2.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage2.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage2, null, SERVICE_NAME.FNSI, null);

    // レイアウト分岐の処理
    // detail属性を持つ要素の下を解析する。
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    parseDetailNode(facilityCd, direction, coopCd, coopCdIndex, coopCdSub, telegramNode, layoutNode, result, extSetting);
    parseDetailNode(facilityCd, key0, direction, coopCd, coopCdIndex, coopVersion, coopCdSub, telegramNode, layoutNode, result, extSetting);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // 0213debuglog
    EventLogMessage eventLogMessage3 = new EventLogMessage();
    eventLogMessage3.setLogMessage(facilityCd + ":parseDetailNode result=" + result);
    eventLogMessage3.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage3.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage3, null, SERVICE_NAME.FNSI, null);
  }

  /**
   * 通常のノード（detail, repeat="true"のいずれでもないノード）下を解析する。
   *
   * @param facilityCd 施設コード
   * @param key0 電子カルテ種別
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param coopCdSub 電文種別補足コード
   * @param telegramNode 電文DOMのノード
   * @param layoutNode レイアウトDOMのノード
   * @param result 抽出結果
   * @param extSetting レイアウト拡張設定
   * @throws XPathExpressionException
   */
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private void parseUsualNode(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopCdSub,
//                              Node telegramNode, Node layoutNode, ResultMap result, LayoutExtSetting extSetting)
//    throws XPathExpressionException {
  private void parseUsualNode(String facilityCd, String key0, String direction, String coopCd, String coopCdIndex, String coopVersion,
                  String coopCdSub, Node telegramNode, Node layoutNode, ResultMap result, LayoutExtSetting extSetting)
    throws XPathExpressionException {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    NodeList nodeList = (NodeList) DOMUtil.evaluate(XPATH_ATTR_AND_TEXT_COL, layoutNode, XPathConstants.NODESET);
    int len = nodeList.getLength();
    if (len == 0) {
      return;
    }

    ResultMap r = new ResultMap();

    for (int i = 0; i < len; ++i) {
      Node node = nodeList.item(i);

      // レイアウト中で「col:」が指定された箇所について、col:の後の値（抽出キー）とその位置を示す
      // XPath表現を取得する。
      String xpathStr = getXPathStr(node, layoutNode);

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(facilityCd + ":parseUsualNode xpath=" + xpathStr);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // 途中のノードにrepeat属性やdetail属性を持つ要素が出現する場合は対象外とする。
      if (xpathStr == null) {
        continue;
      }

      // col:指定の引数を取得する。
      String[] paramValue = getParamValue(node.getNodeValue(), REGEXP_COL_VALUE);

      // col:で指定された「テーブル名.カラム名.JSONキー名」の部分
      String colValue = paramValue[0];

      // オプション指定（json:JSONルックアップ置換キー等）
      String option = paramValue[1];

      // 0213debug
      String parentXpathStr = xpathStr.substring(0, xpathStr.lastIndexOf("/"));
      //Node parentTelegramElement = (Node) DOMUtil.evaluate(parentXpathStr, telegramNode, XPathConstants.NODE);

      // 0213debuglog
      EventLogMessage eventLogMessage3 = new EventLogMessage();
      eventLogMessage3.setLogMessage(facilityCd + ":parentXpathStr=" + parentXpathStr);
      eventLogMessage3.setFacilityCd(facilityCd);
      eventLogMessage3.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.DEBUG, eventLogMessage3, null, SERVICE_NAME.FNSI, null);

      String checkXPath = "count(" + parentXpathStr + ")";
      double count = (double) DOMUtil.evaluate(checkXPath, telegramNode, XPathConstants.NUMBER);

      eventLogMessage3.setLogMessage(facilityCd + ":count=" + count + ":checkXPath=" + checkXPath);
      logService.log(LogLevel.DEBUG, eventLogMessage3, null, SERVICE_NAME.FNSI, null);

      boolean existedFlg = true;

      if(count == 0.0) {
        existedFlg = false;
      }

      eventLogMessage3.setLogMessage(facilityCd + ":check_pass");
      logService.log(LogLevel.DEBUG, eventLogMessage3, null, SERVICE_NAME.FNSI, null);

      // XPath表現を使用して電文から対象項目を抽出する。
      String telegramValue = DOMUtil.evaluate(xpathStr, telegramNode);

      // 0213debuglog
      EventLogMessage eventLogMessage2 = new EventLogMessage();
      eventLogMessage2.setLogMessage(facilityCd + ":telegramValue=" + telegramValue);
      eventLogMessage2.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage2.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage2, null, SERVICE_NAME.FNSI, null);

      if (!StringUtils.isEmpty(telegramValue)) {
        telegramValue = telegramValue.trim();
      }

      // colにオプション（const/json/dataset/default）が指定されている場合
      // オプションにより値を置換する。
      if (!StringUtils.isEmpty(option)) {
        telegramValue = valueEvaluatorUtil.eval(telegramValue, option, facilityCd, extSetting, existedFlg);
      }

      //add 7503 profile連携（XML）で受信した指示医コード・名称 zhaoqi 20221111 start
      Node telegramDetailElement = (Node) DOMUtil.evaluate(xpathStr, telegramNode, XPathConstants.NODE);

// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      List<MstCoopIni> values = mstCoopIniDao.selectByFacilityCd(facilityCd);
// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      boolean checkNode = true;
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      if(values != null && values.size() > 0){
//        String memo = values.get(0).getCoopIniMemo();
//        if("日機装".equals(memo) && telegramDetailElement == null){
      if(Key0Constant.NKK.equals(key0) && telegramDetailElement == null){
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          if (telegramNode.getAttributes() != null) {
            String parentName = telegramNode.getParentNode().getNodeName();
            String name = telegramNode.getNodeName();
            NamedNodeMap attr = telegramNode.getAttributes();
            if (("StaffInfo".equals(parentName) && ("Doctor".equals(name) || "Nurse".equals(name)))
              || ("DialysisIndicatorInfo".equals(parentName) && "Doctor".equals(name))) {
              if (attr == null) {
                checkNode = false;
                //telegramValue = "-9999999";
              }
            }
          }else{
            if(xpathStr.indexOf("DialysisIndicatorInfo/Doctor") != -1){
              checkNode = false;
              //telegramValue = "-9999999";
            }
          }
        }
// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      }
// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      if(checkNode){
        // 返値に設定する。
        r.put(colValue, telegramValue);
      }
      //add 7503 profile連携（XML）で受信した指示医コード・名称 zhaoqi 20221111 end

      //del 7503 profile連携（XML）で受信した指示医コード・名称 zhaoqi 20221111 start
      // 返値に設定する。
      //r.put(colValue, telegramValue);
      //del 7503 profile連携（XML）で受信した指示医コード・名称 zhaoqi 20221111 end
    }
    // del 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
    //r = JsonMapUtil.collectJsonMapByKey(r);
    // del 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
    result.putAppendAll(r);
  }

  /**
   * repeat属性を持つ要素の下を解析する。
   *
   * @param facilityCd 施設コード
   * @param key0 電子カルテ種別
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopCoopVersion 連携版番号
   * @param coopCdSub 電文種別補足コード
   * @param telegramNode 電文DOMのノード
   * @param layoutNode レイアウトDOMのノード
   * @param result 抽出結果
   * @param extSetting レイアウト拡張設定
   * @throws XPathExpressionException
   * @throws SAXException
   * @throws IOException
   * @throws ParserConfigurationException
   */
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private void parseRepeatNode(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopCdSub,
//      Node telegramNode, Node layoutNode, ResultMap result, LayoutExtSetting extSetting)
//      throws XPathExpressionException, SAXException, IOException, ParserConfigurationException {
  private void parseRepeatNode(String facilityCd, String key0, String direction, String coopCd, String coopCdIndex,
        String coopVersion, String coopCdSub, Node telegramNode, Node layoutNode, ResultMap result, LayoutExtSetting extSetting)
    throws XPathExpressionException, SAXException, IOException, ParserConfigurationException {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // repeat属性を持つ要素を取得し、その下を解析する。
    NodeList repeatNodeList = (NodeList) DOMUtil.evaluate(XPATH_ATTR_REPEAT, layoutNode, XPathConstants.NODESET);
    int repeatNodeListLen = repeatNodeList.getLength();
    if (repeatNodeListLen == 0) {
      return;
    }

    for (int i = 0; i < repeatNodeListLen; ++i) {
      // XPath条件が「repeat属性を持つ要素」であるので、型検査なしにElementにキャストしている。
      Element elem = (Element) repeatNodeList.item(i);

      // repeat属性を持つ要素に対応する電文DOM上の位置を取得する。
      String xpathStr = getXPathStr(elem, layoutNode);

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(facilityCd + ":parseRepeatNode xpath=" + xpathStr);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      NodeList telegramChildrenNodeList = (NodeList) DOMUtil.evaluate(xpathStr, telegramNode, XPathConstants.NODESET);

      // 該当する要素が存在しない場合（レイアウトで規定した要素が省略されている場合）
      // 単純に無視する。
      int telegramRepeatNodeLen = telegramChildrenNodeList.getLength();
      if (telegramRepeatNodeLen == 0) {
        continue;
      }

      // レイアウトと電文の対応ノードについて再帰的に解析する。
      for (int j = 0; j < telegramRepeatNodeLen; ++j) {
        ResultMap r = new ResultMap();
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        parse(facilityCd, direction, coopCd, coopCdIndex, coopCdSub, telegramChildrenNodeList.item(j), elem, r, extSetting);
        parse(facilityCd, key0, direction, coopCd, coopCdIndex, coopVersion, coopCdSub, telegramChildrenNodeList.item(j),
          elem, r, extSetting);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        r = JsonMapUtil.collectJsonMapByKey(r);
        result.putAppendAll(r);
      }
    }
  }

  /**
   * detail属性を持つ要素の下を解析する。
   *
   * @param facilityCd 施設コード
   * @param key0 電子カルテ種別
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param coopCdSub 電文種別補足コード
   * @param telegramNode 電文DOMのノード
   * @param layoutNode レイアウトDOMのノード
   * @param result 抽出結果
   * @param extSetting レイアウト拡張設定
   * @throws XPathExpressionException
   * @throws IOException
   * @throws SAXException
   * @throws ParserConfigurationException
   */
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private void parseDetailNode(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopCdSub,
//      Node telegramNode, Node layoutNode, ResultMap result, LayoutExtSetting extSetting)
//      throws XPathExpressionException, ParserConfigurationException, SAXException, IOException {
  private void parseDetailNode(String facilityCd, String key0, String direction, String coopCd, String coopCdIndex,
      String coopVersion, String coopCdSub, Node telegramNode, Node layoutNode, ResultMap result, LayoutExtSetting extSetting)
    throws XPathExpressionException, ParserConfigurationException, SAXException, IOException {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // detail属性を持つ要素を取得し、その下を解析する。
    NodeList layoutDetaiNodeList = (NodeList) DOMUtil.evaluate(XPATH_ATTR_DETAIL, layoutNode, XPathConstants.NODESET);
    int layoutDetailNodeListLen = layoutDetaiNodeList.getLength();
    if (layoutDetailNodeListLen == 0) {
      return;
    }

    for (int i = 0; i < layoutDetailNodeListLen; ++i) {
      Element layoutDetailElement = (Element) layoutDetaiNodeList.item(i);

      // detail属性が指定されたノードまでのXPath表現
      String xpathStr = getXPathStr(layoutDetailElement, layoutNode);
      if (xpathStr == null) {
        continue;
      }

      // 分岐パラメータの名称（mst_coop_layout_detail.coop_cd_detail）をレイアウトから取得する。
      String[] detailValueArr = getDetailValue(layoutDetailElement.getAttribute(ATTR_DETAIL));
      String coopCdDetail = detailValueArr[0];

      // 分岐パラメータの値（mst_coop_layout_detail.coop_cd_detail_sub）を電文から取得する。
      String condValue = DOMUtil.evaluate(xpathStr + XPATH_DELIM + detailValueArr[1], telegramNode);
      String coopCdDetailSub = layoutExtSettingUtil.lookupExtSetting(extSetting, coopCdDetail, condValue);

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(facilityCd + ":parseDetailNode xpath=" + xpathStr + ", condValue= " + condValue + ", coopCdDetailSub=" + coopCdDetailSub);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // MstCoopLayoutDetailエンティティを取得する。
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      MstCoopLayoutDetail mcld = getMstCoopLayoutDetail(facilityCd, direction, coopCd, coopCdDetail, coopCdDetailSub);
      MstCoopLayoutDetail mcld = getMstCoopLayoutDetail(facilityCd, direction, coopCd, coopVersion, coopCdDetail,
        coopCdDetailSub);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

      // レイアウト詳細のDOMを取得する。
      // レイアウトと電文で要素の対応を一致させるため、getFirstElementメソッドを呼んでいる。
      // （呼ばないと、レイアウト詳細で先頭要素の前にコメントが記述された場合に対応できない。）
      // convertメソッドでは階層の深さを問わない「.//」で対象を取得するため、getFirstElement呼び出しは不要。
      Element layoutDetailDOM = getFirstElement(DOMUtil.parse(mcld.getCoopSetting()));

      LayoutExtSetting extSettingDetail = mcld.getCoopExtSetting();

      // 対応する電文中のノード下を再帰的に解析する。
      Node telegramDetailElement = (Node) DOMUtil.evaluate(xpathStr, telegramNode, XPathConstants.NODE);
      if (telegramDetailElement != null) {
        // mod 2021-09-09 #5897:CSI連携ができないの対応 孫 start
//        parse(facilityCd, direction, coopCd, coopCdIndex, coopCdSub, telegramDetailElement, layoutDetailDOM, result,
//            extSettingDetail);
        // ノード名
        String nodeName = telegramDetailElement.getNodeName();
        while(telegramDetailElement != null) {
          String nodeNameComp = telegramDetailElement.getNodeName();
          if (nodeName.equals(nodeNameComp)) {
            // MstCoopLayoutDetailエンティティを再取得するか？
            if (!AUX_CODE_ALL.equals(coopCdDetailSub)) {
              condValue = DOMUtil.evaluate(detailValueArr[1], telegramDetailElement);
              String coopCdDetailSubComp = layoutExtSettingUtil.lookupExtSetting(extSetting, coopCdDetail, condValue);
              if (!coopCdDetailSubComp.equals(coopCdDetailSub)) {
                // 分岐パラメータの値（mst_coop_layout_detail.coop_cd_detail_sub）を電文から取得する。
                coopCdDetailSub = layoutExtSettingUtil.lookupExtSetting(extSetting, coopCdDetail, condValue);

                eventLogMessage = new EventLogMessage();
                eventLogMessage.setLogMessage(facilityCd + ":parseDetailNode xpath=" + xpathStr + ", condValue= " + condValue + ", coopCdDetailSub=" + coopCdDetailSub);
                eventLogMessage.setFacilityCd(facilityCd);
                eventLogMessage.setInvokeClass(this.getClass().getName());
                logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

                // MstCoopLayoutDetailエンティティを取得する。
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//                mcld = getMstCoopLayoutDetail(facilityCd, direction, coopCd, coopCdDetail, coopCdDetailSub);
                mcld = getMstCoopLayoutDetail(facilityCd, direction, coopCd, coopVersion, coopCdDetail, coopCdDetailSub);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

                // レイアウト詳細のDOMを取得する。
                // レイアウトと電文で要素の対応を一致させるため、getFirstElementメソッドを呼んでいる。
                // （呼ばないと、レイアウト詳細で先頭要素の前にコメントが記述された場合に対応できない。）
                // convertメソッドでは階層の深さを問わない「.//」で対象を取得するため、getFirstElement呼び出しは不要。
                layoutDetailDOM = getFirstElement(DOMUtil.parse(mcld.getCoopSetting()));
                extSettingDetail = mcld.getCoopExtSetting();
              }
            }

            // ノード下を再帰的に解析する。
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//            parse(facilityCd, direction, coopCd, coopCdIndex, coopCdSub, telegramDetailElement, layoutDetailDOM, result,
//              extSettingDetail);
            parse(facilityCd, key0, direction, coopCd, coopCdIndex, coopVersion, coopCdSub, telegramDetailElement,
              layoutDetailDOM, result, extSettingDetail);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          }
          // 次のノードを取得する
          telegramDetailElement = telegramDetailElement.getNextSibling();
        }
        // mod 2021-09-09 #5897:CSI連携ができないの対応 孫 end
      }
    }
  }

  /**
   * パラメータ（col:）の値を取得する。
   *
   * @param paramStr パラメータ文字列
   * @param regExpStr パラメータの正規表現
   * @return パラメータの値（col指定の値、オプション名、オプション値）
   */
  private String[] getParamValue(String paramStr, String regExpStr) {
    Pattern p = Pattern.compile(regExpStr);
    Matcher m = p.matcher(paramStr.trim());
    return m.matches() ? new String[] {
        m.group(INDEX_COL_VALUE), m.group(INDEX_OPTION)
    } : null;
  }

  /**
   * detail属性の値から、レイアウト詳細取得用のパラメータ（coop_cd_detailの値, coop_cd_detail_sub取得キー）を取得する。
   *
   * @param detailStr detail属性の値
   * @return coop_cd_detailの値, coop_cd_detail_sub取得キー
   */
  private String[] getDetailValue(String detailStr) {
    if (StringUtils.isEmpty(detailStr)) {
      String errMsg = "レイアウト中のdetail属性の値が不正です。";
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(errMsg);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    }

    // 属性が指定されていない場合、直下のテキストノードの値をレイアウト判別に使用する。
    if (!detailStr.contains(DETAIL_DELIM)) {
      return new String[] { detailStr.trim(), XPATH_NODE_TEXT };
    }

    String[] arr = detailStr.split(DETAIL_DELIM, 2);
    return new String[] { arr[0].trim(), XPATH_PREFIX_ATTR + arr[1].trim() };
  }

  /**
   * 指定されたノードを抽出するためのXPath表現を取得する。<br/>
   * nodeStart引数からroot引数までの間のノードがrepeat属性やdetail属性を持つ場合はnullを返す。<br/>
   * nodeStart自身、root自身については問わない。
   *
   * @param start 開始ノード
   * @param root XPathの始点
   * @return XPath表現文字列
   */
  private String getXPathStr(Node start, Node root) {
    // nodeStartノードから親をたどり、rootノードに到達する直前までを取得する。
    // （stack上の登録順は、startノードが末尾、rootノード直前が先頭）
    Deque<Node> stack = new ArrayDeque<>();
    Node node = start;
    while (node != null && node != root) {
      stack.addFirst(node);

      switch (node.getNodeType()) {
        case Node.ATTRIBUTE_NODE:
          // 属性ノード
          // 属性を保持する要素ノードについて遡る。
          // （属性ノードのgetParentNode()はnullであることに注意）
          node = ((Attr) node).getOwnerElement();
          continue;

        case Node.ELEMENT_NODE:
          // 要素ノード
          // 開始ノードでない、かつ、repeat属性かdetail属性を持つ場合はnullを返す。
          // その他の場合は親ノードについて遡る。
          if (node != start) {
            Element e = (Element) node;
            if (e.hasAttribute(ATTR_REPEAT) || e.hasAttribute(ATTR_DETAIL)) {
              return null;
            }

            node = node.getParentNode();
            continue;
          }

        default:
          // その他のノード
          node = node.getParentNode();
          continue;
      }
    }

    String[] ls = stack.stream().map(e -> toString(e)).toArray(String[]::new);
    return XPATH_HERE + XPATH_DELIM + String.join(XPATH_DELIM, ls);
  }

  /**
   * ノードを文字列表現に変換する。
   *
   * @param node Nodeオブジェクト
   * @return 文字列表現
   */
  private String toString(Node node) {
    switch (node.getNodeType()) {
      case Node.ATTRIBUTE_NODE:
        // 属性ノード
        // @を属性名の先頭に付加する。
        return XPATH_PREFIX_ATTR + node.getNodeName();

      case Node.TEXT_NODE:
        // テキストノード
        // text()固定。
        return XPATH_NODE_TEXT;

      case Node.ELEMENT_NODE:
        // 要素ノード
        // 値がcol:で始まる属性が存在しない場合は要素名（XMLタグ名）を返す。
        // repeat, detail以外の属性が存在する場合は、「@属性名="属性値"」をandで結合し、[]で括った値を要素名の後に付加して返す。
        return toString((Element) node);

      default:
        // その他のノード
        // 処理対象ノードとして抽出されないため、ここには到達しない。
        // 不具合により到達した場合は例外を発生させる。
        throw new NtssException("XML電文のレイアウト解析でエラーが発生しました。");
    }
  }

  /**
   * DOM Elementオブジェクトを文字列表現に変換する。
   *
   * @param element Elementオブジェクト
   * @return 文字列表現
   */
  private String toString(Element element) {
    NamedNodeMap m = element.getAttributes();
    int len = m.getLength();

    // 抽出対象以外の属性が存在する場合
    // 子要素選択の限定条件として追加する。
    List<String> attrList = new ArrayList<>();
    if (len > 0) {
      for (int i = 0; i < len; ++i) {
        Attr attr = (Attr) m.item(i);
        String attrName = attr.getName().trim();
        String attrValue = attr.getValue().trim();

        // 以下の属性は含めない。
        // (1) 値が"col:"で始まるもの
        // (2) 属性名が"detail"であるもの
        // (3) 属性名が"repeat"であるもの
        if (attrValue.startsWith(PREFIX_COL) || attrName.equals(ATTR_DETAIL)
            || attrName.equals(ATTR_REPEAT)) {
          continue;
        }

        String s = String.format(ATTR_FORMAT, XPATH_PREFIX_ATTR, attrName, attrValue);
        attrList.add(s);
      }
    }

    return CollectionUtils.isEmpty(attrList) ? element.getNodeName()
        : element.getNodeName() + XPATH_ATTRS_START + String.join(XPATH_ATTRS_AND, attrList.toArray(new String[0]))
            + XPATH_ATTRS_END;
  }

  /**
   * ドキュメントの先頭要素を取得する。
   *
   * @param document ドキュメント
   * @return 先頭要素
   */
  private Element getFirstElement(Document document) {
    NodeList nodeList = document.getChildNodes();
    int len = nodeList.getLength();
    if (len == 0) {
      return null;
    }

    // 要素以外のノードが存在する場合はスキップする。
    for (int i = 0; i < len; ++i) {
      Node node = nodeList.item(i);
      if (node.getNodeType() == Node.ELEMENT_NODE) {
        return (Element) node;
      }
    }

    // 要素ノードが存在しない場合
    // （コメントしか存在しない等）
    // 解析不可であるため例外を発生させる。
    String errMsg = "レイアウト詳細が不正です。";
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(errMsg);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    throw new NtssException(errMsg);
  }

  /**
   * レイアウトエンティティ（mst_coop_layout）を取得する。<br/>
   * 該当するレコードが存在しない場合は例外を発生させる。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param coopCdSub 電文種別補足コード
   * @return レイアウトエンティティ
   */
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private MstCoopLayout getMstCoopLayout(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopCdSub) {
//    MstCoopLayout mcl = mstCoopLayoutDao.select(facilityCd, coopCd, coopCdIndex, direction, coopCdSub);
  private MstCoopLayout getMstCoopLayout(String facilityCd, String direction, String coopCd, String coopCdIndex,
                                         String coopVersion, String coopCdSub) {
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//    MstCoopLayout mcl = mstCoopLayoutDao.select(facilityCd, coopCd, coopCdIndex, coopVersion, direction, coopCdSub);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//    if (mcl != null) {
//      return mcl;
//    }
//
//    // 指定された条件のレコードが存在しない場合
//    // 例外を発生させる。
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////    String errMsg = String.format("電文変換レイアウトが設定されていません。施設コード:[%s], 送受信向き:[%s], 電文種別:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
////        facilityCd, direction, coopCd, coopCdIndex, coopCdSub);
//    String errMsg = String.format("電文変換レイアウトが設定されていません。施設コード:[%s], 送受信向き:[%s], 電文種別:[%s], 連携版番号:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
//      facilityCd, direction, coopCd, coopVersion, coopCdIndex, coopCdSub);
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage(errMsg);
//    eventLogMessage.setFacilityCd(facilityCd);
//    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
//    eventLogMessage.setInvokeClass(this.getClass().getName());
//    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
//    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//    throw new NtssException(errMsg);
    MstCoopLayout mcl = convertCommonService.getMstCoopLayoutBySub(facilityCd, direction,
      coopCd, coopCdIndex, coopVersion, coopCdSub);
    return mcl;
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
  }

  /**
   * レイアウト詳細エンティティ（mst_coop_layout_detail）を取得する。<br/>
   * 該当するレコードが存在しない場合は例外を発生させる。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopVersion 連携版番号
   * @param coopCdDetail 電文種別詳細コード
   * @param coopCdDetailSub 電文種別詳細補足コード
   * @return レイアウト詳細エンティティ
   */
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////  private MstCoopLayoutDetail getMstCoopLayoutDetail(String facilityCd, String direction, String coopCd,
////      String coopCdDetail, String coopCdDetailSub) {
////    MstCoopLayoutDetail mcld = mstCoopLayoutDetailDao.selectWithPre(facilityCd, coopCd, direction, coopCdDetail,
////        coopCdDetailSub, AUX_CODE_PRELOGIC, AUX_CODE_ALL);
//  private MstCoopLayoutDetail getMstCoopLayoutDetail(String facilityCd, String direction, String coopCd,
//      String coopVersion, String coopCdDetail, String coopCdDetailSub) {
//    MstCoopLayoutDetail mcld = mstCoopLayoutDetailDao.selectWithPre(facilityCd, coopCd, coopVersion, direction,
//      coopCdDetail, coopCdDetailSub, AUX_CODE_PRELOGIC, AUX_CODE_ALL);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//    if (mcld != null) {
//      return mcld;
//    }
//
//    // 指定された分岐値に対応するレコード、デフォルトとして使用するレコード（coop_cd_detail_sub="pre"）が
//    // 共に存在しない場合
//    // 電文の解析は失敗とし例外を発生させる。
//    String errMsg = String.format(
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////        "電文変換レイアウト詳細が設定されていません。 施設コード:[%s], 送受信向き:[%s], 電文種別:[%s], 電文種別詳細コード:[%s], 電文種別詳細補足コード:[%s], ",
////        facilityCd, direction, coopCd, coopCdDetail, coopCdDetailSub);
//      "電文変換レイアウト詳細が設定されていません。 施設コード:[%s], 送受信向き:[%s], 電文種別:[%s], 連携版番号:[%s], 電文種別詳細コード:[%s], 電文種別詳細補足コード:[%s], ",
//      facilityCd, direction, coopCd, coopVersion, coopCdDetail, coopCdDetailSub);
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage(errMsg);
//    eventLogMessage.setFacilityCd(facilityCd);
//    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
//    eventLogMessage.setInvokeClass(this.getClass().getName());
//    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
//    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//    throw new NtssException(errMsg);
//  }
  private MstCoopLayoutDetail getMstCoopLayoutDetail(String facilityCd, String direction, String coopCd,
                                                     String coopVersion, String coopCdDetail, String coopCdDetailSub) {
    // 指定された分岐値に対応するレコード、デフォルトとして使用するレコード（coop_cd_detail_sub="pre"）が
    // 共に存在しない場合、電文の解析は失敗とし例外を発生させる。
    MstCoopLayoutDetail mcld = convertCommonService.getMstCoopLayoutDetailWithPre(facilityCd, direction, coopCd, coopVersion,
      coopCdDetail, coopCdDetailSub, AUX_CODE_PRELOGIC, AUX_CODE_ALL);
    return mcld;
  }
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
}
