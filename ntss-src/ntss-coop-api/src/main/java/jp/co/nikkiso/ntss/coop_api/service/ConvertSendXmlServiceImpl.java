package jp.co.nikkiso.ntss.coop_api.service;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.collections.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.service.ConvertSendCommonServiceImpl.FileNames;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.FileUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.ElementsValue;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDetailDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility.ReportType;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

@Service
public class ConvertSendXmlServiceImpl implements ConvertSendByFormatService {
  /** DI */
  @Autowired
  MstCoopLayoutDao mstCoopLayoutDao;
  @Autowired
  MstCoopLayoutDetailDao mstCoopLayoutDetailDao;
  @Autowired
  SysCoopJournalDao sysCoopJournalDao;
  @Autowired
  ClockWrapper clockWrapper;
  @Autowired
  ConvertSendCommonService convertSendCommonService;
  @Autowired
  private FileUtil fileUtil;
  @Autowired
  private LogService logService;

  // mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
  @Autowired
  private ConvertCommonService convertCommonService;
  // mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
  @Autowired
  private JournalService journalService;

  /** レポートファイル一時出力フォルダ */
  @Value("${ntss.report.createJournalTmp}")
  private String createJournalTmp;

  //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
//  /** バイト長計算に必要な標準文字コード(Shift-JIS) */
//  private static final String DEFAULT_ENCODE = JournalConvertConstants.TELEGRAM_ENCODING_BY_SJIS;
  /** バイト長計算に必要な標準文字コード(MS932) */
  private static final String DEFAULT_ENCODE = JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932;
//mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end

  /** 予約語 $JOURNAL */
  private static final String KEY_JOURNAL = "$JOURNAL";

  /** 予約語 $COUNT */
  private static final String KEY_COUNT = "$COUNT";

  /** 予約語 $ROW_COUNT */
  private static final String KEY_ROW_COUNT = "$ROW_COUNT";

  // add 2021-11-17 #5896:SSI連携ができない(カルテ記載連携) 孫 start
  /** 予約語 $SYSDATE */
  private static final String KEY_SYSDATE = "$SYSDATE";

  /** 予約語 $SYSTIME */
  private static final String KEY_SYSTIME = "$SYSTIME";
  // add 2021-11-17 #5896:SSI連携ができない(カルテ記載連携) 孫 end

  /* del by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // // add 2020-12-30 No.724:電文内データ文字列結合 商 start
  // private List<Map<String, Object>> itemSuffixList = new ArrayList<>();
  // private List<Map<String, Object>> itemSuffixDetailList = new ArrayList<>();
  // private String nodeName = "";
  // // add 2020-12-30 No.724:電文内データ文字列結合 商 end
  // private int rowCount = 1;
  /* del by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  @Autowired
  private ConvertDocumentContentService convertDocumentContentService;

  @Override
  public void createTelegram(SysCoopJournal journal) {
    String facilityCd = journal.getFacilityCd();

// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////    // ジャーナルから変換したいレイアウトを取得する
////    MstCoopLayout layout = mstCoopLayoutDao.select(facilityCd, journal.getCoopCd(), journal.getCoopCdIndex(), JournalConvertConstants.DIRECTION_SEND, convertSendCommonService.getCoopCdSub(journal.getCrud()));
//    // 連携版番号
//    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
//
//    // ジャーナルから変換したいレイアウトを取得する
//    MstCoopLayout layout = mstCoopLayoutDao.select(facilityCd, journal.getCoopCd(), journal.getCoopCdIndex(), coopVersion,
//      JournalConvertConstants.DIRECTION_SEND, convertSendCommonService.getCoopCdSub(journal.getCrud()));
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//
//    // レイアウトがない場合はジャーナルをエラーにして、次のジャーナル変換に移る
//    if (layout == null) throw new NtssException("対象ジャーナルの送信用変換レイアウトが存在しません。 "
//        + "facility_cd:[" + journal.getFacilityCd() + "], "
//        + "coop_cd:[" + journal.getCoopCd() + "], "
//// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        + "coop_version:[" + coopVersion + "], "
//// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//        + "coop_cd_sub:[" + convertSendCommonService.getCoopCdSub(journal.getCrud()) + "]");
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
    String coopCdSub = convertSendCommonService.getCoopCdSub(journal.getCrud());
    MstCoopLayout layout = convertCommonService.getMstCoopLayoutBySub(facilityCd, JournalConvertConstants.DIRECTION_SEND,
      journal.getCoopCd(), journal.getCoopCdIndex(), coopVersion, coopCdSub);
    /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    List<MstCoopIni> coopIniList = convertCommonService.getMstCoopIniByFacilityCd(facilityCd);
    MstCoopIni coopIni = CollectionUtils.isEmpty(coopIniList) ? null : coopIniList.get(0);
    /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
    /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    // add 2020-12-30 No.724:電文内データ文字列結合 商 start
    // itemSuffixList = getItemSuffixList(layout.getCoopExtSetting());
    XmlTelegramContext xmlTelegramContext = new XmlTelegramContext();
    xmlTelegramContext.setItemSuffixList(getItemSuffixList(layout.getCoopExtSetting()));
    // add 2020-12-30 No.724:電文内データ文字列結合 商 end
    /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

    // data-setを利用した出力がある場合に限り、あらかじめdata-setをリクエストしておく
    /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
    Map<String, List<Map<String, Object>>> dataSetResultMap = convertSendCommonService.createRequestAndRequestByDataSetApi(journal, layout.getCoopExtSetting(), null, coopIni);

    // 送信用の電文を作成
    // rowCount = 1;
    String telegram = createTelegram(layout.getCoopSetting(), journal, dataSetResultMap, layout.getCoopExtSetting(), coopIni, xmlTelegramContext);
    /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */

    String dumpPath = null;
    String dump = null;
    // 電文種別がレポート対象かどうか
    if (convertSendCommonService.isReport(journal)) {
      // レポート対象の場合

      if (ReportType.TAR.equals(ReportType.getReportType(journal.getCoopCdIndex()))) {
        // coop_cd_indexがtarの場合

        // 帳票作成待ちデータの場合、帳票データを作成する
        journal = journalService.createJournalReportDump(journal);

        // ファイル名を取得
        Map<String, String> fileNames = convertSendCommonService.getFileNames(journal);

        String pdfName = fileNames.get(FileNames.PDF_NAME.getKey());
        String dumpName = fileNames.get(FileNames.DUMP_NAME.getKey());
        String compressName = fileNames.get(FileNames.COMPRESSION_NAME.getKey());

        outputDebugLog(facilityCd, String.format("pdf_name:[%s], dump_name:[%s], compression_name:[%s]"
            , pdfName, dumpName, compressName));

        if (StringUtils.isEmpty(pdfName) || StringUtils.isEmpty(dumpName) || StringUtils.isEmpty(compressName)) {
          // coop_cd_indexがtarの場合、ファイル名が３つ揃わないとエラー
          String error = "ファイル名が取得できませんでした。";
          outputErrorLog(facilityCd, error);
          throw new NtssException(error);
        }

        // ctlNoの取得
        String journalCtlNo = String.valueOf(journal.getCtlNo()) + "_";
        // ctlNo_dumpPath.拡張子
        Path tmpDir = Paths.get(createJournalTmp, journalCtlNo + dumpName);
        // 拡張子の削除
        String tmpDirRemoveExtention = fileUtil.removeExtension(tmpDir.toString());

        outputDebugLog(facilityCd, String.format("生成ディレクトリ:" + tmpDirRemoveExtention));

        // 一時保存フォルダの作成
        fileUtil.createTempDirectorie(journal.getFacilityCd(), tmpDirRemoveExtention);

        // xmlファイルの作成
        fileUtil.writeFile(journal.getFacilityCd(), tmpDirRemoveExtention, dumpName, telegram, DEFAULT_ENCODE);

        // 既存のPDFファイル名をXMLに揃える
        fileUtil.renameFile(journal.getFacilityCd(), createJournalTmp,
            journalCtlNo + journal.getDumpPath(), pdfName);
        // PDFファイルをXMLと同じ階層に移動
        fileUtil.moveFile(facilityCd, createJournalTmp, tmpDirRemoveExtention, pdfName);

        // 圧縮するファイルにPDFとXMLを指定
        List<String> fileList = Arrays.asList(pdfName, dumpName);
        // 圧縮ファイルの作成
        fileUtil.compressTar(journal.getFacilityCd(), tmpDirRemoveExtention, journalCtlNo + compressName, fileList);
        // 圧縮ファイルを配信用フォルダに移動
        String deliveryJournalTmp = fileUtil.getDistFolderPath();
        fileUtil.moveFile(journal.getFacilityCd(), tmpDirRemoveExtention, deliveryJournalTmp,
            journalCtlNo + compressName);

        try {
          fileUtil.deleteDirectoryRecursively(tmpDirRemoveExtention);
          outputDebugLog(facilityCd, "tmpDir removed: " + tmpDirRemoveExtention);
        } catch (IOException e) {
          outputDebugLog(facilityCd, "tmpDir removed faild: " + e.getMessage());
        }

        // 電文パスにcompression_nameを設定
        dumpPath = compressName;
        // 配信時に取得させるため、dumpにnullにする
        dump = null;
      } else {
        // ファイル名を取得
        Map<String, String> fileNames = convertSendCommonService.getFileNames(journal);

        // coop_cd_indexがtar以外の場合
        String dumpName = fileNames.get(FileNames.DUMP_NAME.getKey());
        if (StringUtils.isEmpty(dumpName)) {
          String error = "ファイル名が取得できませんでした。";
          outputErrorLog(journal.getFacilityCd(), error);
          throw new NtssException(error);
        }
        dumpPath = fileNames.get(FileNames.DUMP_NAME.getKey());
        dump = telegram;
      }
    } else {
      // レポート対象外の場合
      dumpPath = convertSendCommonService.getDumpFileName(layout, journal);
      dump = telegram;
    }

    // 電文パスの設定
    journal.setDumpPath(dumpPath);

    try {
      // 電文の設定
      if (dump != null) {
        journal.setDump(dump.getBytes(DEFAULT_ENCODE));
      } else {
        journal.setDump(null);
      }
    } catch (UnsupportedEncodingException e) {
      throw new NtssException("電文のエンコーディングがサポートされていない形式です。", e);
    }

// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    String message = "ConvertSendServiceImpl#createTelegram 電文内容 facility_cd:[" + facilityCd + "], coop_cd:[" + journal.getCoopCd() + "], telegram:[" + telegram + "]";
    String message = "ConvertSendServiceImpl#createTelegram 電文内容 facility_cd:[" + facilityCd
      + "], coop_cd:[" + journal.getCoopCd() + "], coop_version:[" + coopVersion + "], telegram:[" + telegram + "]";
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    outputInfoLog(facilityCd, message);
  }

  /**
   * coop_settingから電文を作成する
   * @param coopSetting
   * @param journal
   * @param dataSetResultMap
   * @param layoutExtSetting
   * @return
   */
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
  private String createTelegram(String coopSetting, SysCoopJournal journal, Map<String, List<Map<String, Object>>> dataSetResultMap,
      LayoutExtSetting layoutExtSetting, MstCoopIni coopIni, XmlTelegramContext xmlTelegramContext) {
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
    try {
      coopSetting = getDeleteNewLine(coopSetting);
      coopSetting = getDeleteSpace(coopSetting);
      InputStream inputStream = new ByteArrayInputStream(coopSetting.getBytes(StandardCharsets.UTF_8));
      // 帳票定義Xmlをパース
      DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
      DocumentBuilder documentBuilder;
      documentBuilder = documentBuilderFactory.newDocumentBuilder();
      Document document = documentBuilder.parse(inputStream);
      NodeList nodeList = document.getChildNodes();
      /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
      createTelegram(journal, document, nodeList, dataSetResultMap, coopIni, xmlTelegramContext);
      /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
      String telegram = createXMLString(document, layoutExtSetting);
      return telegram;
    } catch (ParserConfigurationException | SAXException | IOException | TransformerException e) {
      throw new NtssException("XML電文の作成に失敗しました。", e);
    }
  }
  /**
   * XML文字列を作成する
   * @param document
   * @param layoutExtSetting
   * @return
   * @throws TransformerException
   */
  private String createXMLString(Document document, LayoutExtSetting layoutExtSetting) throws TransformerException {
    StringWriter writer = new StringWriter();
    TransformerFactory factory = TransformerFactory.newInstance();
    Transformer transformer = factory.newTransformer();

    // XMLのエンコーディングを取得する。
    String xmlStandAlone = "";
    String xmlEncoding = "";
    if (layoutExtSetting != null && layoutExtSetting.containsKey("soap")) {
      Map<String, String> soapSetting = ObjectMapperUtil.castToStringStringMap(layoutExtSetting.get("soap"));
      if (soapSetting != null && soapSetting.containsKey("xmlStandAlone")) {
    	  xmlStandAlone = soapSetting.get("xmlStandAlone");
      }
      if (soapSetting != null && soapSetting.containsKey("xmlEncoding")) {
          xmlEncoding = soapSetting.get("xmlEncoding");
      }
    }

    transformer.setOutputProperty(OutputKeys.INDENT, "yes");
    //transformer.setOutputProperty(OutputKeys.METHOD, "xml");
    transformer.setOutputProperty("{http://xml.apache.org/xalan}indent-amount", "2");
    if (!StringUtils.isEmpty(xmlStandAlone)) {
	  transformer.setOutputProperty(OutputKeys.STANDALONE, xmlStandAlone);
	}
    // mod 2021-01-18 No.707:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
//    transformer.setOutputProperty(OutputKeys.ENCODING, "Shift_JIS");
    if (StringUtils.isEmpty(xmlEncoding)) {
      //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
      transformer.setOutputProperty(OutputKeys.ENCODING, "Shift_JIS");
//      transformer.setOutputProperty(OutputKeys.ENCODING, DEFAULT_ENCODE);
      //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
    } else {
      transformer.setOutputProperty(OutputKeys.ENCODING, xmlEncoding);
    }
    // mod 2021-01-18 No.707:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
    document.setXmlStandalone(true);

    transformer.transform(new DOMSource(document), new StreamResult(writer));
    //  &#65374; のように文字参照へ自動的に変換されて出力されるため対象の文字列を置き換える
    return writer.toString().replace("&#65374;", "～");
  }
  /**
   * 電文を作成する
   * @param journal
   * @param document
   * @param nodeList
   * @param dataSetResultMap
   * @throws UnsupportedEncodingException
   */
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
  private void createTelegram(SysCoopJournal journal, Document document, NodeList nodeList,
      Map<String, List<Map<String, Object>>> dataSetResultMap, MstCoopIni coopIni, XmlTelegramContext xmlTelegramContext) throws UnsupportedEncodingException {
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
    if (nodeList == null || nodeList.getLength() == 0) {
      return;
    }
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    for (int i = 0; i < nodeList.getLength();i++) {
      Node node = nodeList.item(i);
      NamedNodeMap attributeMap = node.getAttributes();
      // add 2020-12-30 No.724:電文内データ文字列結合 商 start
      if (StringUtils.isEmpty(node.getNodeValue())) {
        /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
        // nodeName = node.getNodeName();
        xmlTelegramContext.setNodeName(node.getNodeName());
        /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
      }

      if (("karte_ord".equals(journal.getCoopCd()) && "#karte_content#".equals(node.getNodeValue())) || ("rst_dial".equals(journal.getCoopCd()) && "#karte_content#".equals(node.getNodeValue()))) {
      	  String content = convertDocumentContentService.createContents(journal);
      	  node.setNodeValue(content);
          continue;
      }

      // add 2020-12-30 No.724:電文内データ文字列結合 商 end
      String detailId = "";
      String sqlCode = "";
      String isZeroDispVal = "";
      boolean isZeroDisp = false;
      if (attributeMap != null && attributeMap.getLength() > 0) {
        for (int j=0; j<attributeMap.getLength(); j++) {
          Node attributeNode = attributeMap.item(j);
          if ("_detail".equals(attributeNode.getNodeName()) && !StringUtils.isEmpty(attributeNode.getNodeValue())) {
            detailId = attributeNode.getNodeValue();
          }
          if ("_sqlCode".equals(attributeNode.getNodeName()) && !StringUtils.isEmpty(attributeNode.getNodeValue())) {
              sqlCode = attributeNode.getNodeValue();
            }
          if ("_isZeroDisp".equals(attributeNode.getNodeName()) && !StringUtils.isEmpty(attributeNode.getNodeValue())) {
        	  isZeroDispVal = attributeNode.getNodeValue();
            }
        }
      }
      //詳細が場合のみ詳細実行
      if (!StringUtils.isEmpty(detailId) && !StringUtils.isEmpty(sqlCode)){
        if (!dataSetResultMap.containsKey(sqlCode)) {
          throw new NtssException("SQLCODEに対するデータセットが存在しません。 SQLCODE:[" + sqlCode + "]");
        }
        List<Map<String, Object>> dataSetList = dataSetResultMap.get(sqlCode);
        // _isZeroDispがtrueの場合、SQL結果が0件でも親ノードを出力する
        if(dataSetList.size() == 0  && "true".equals(isZeroDispVal)) isZeroDisp = true;
        int count = 0;
        for (Map<String, Object> dataSetMap : dataSetList) {
          if (!dataSetMap.containsKey("detail_id")) {
            throw new NtssException("対象datasetに必須なキーである[detail_id]が存在しません。"
                + "facility_cd:[" + journal.getFacilityCd() + "], "
                + "coop_cd:[" + journal.getCoopCd() + "], "
// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
                + "coop_version:[" + coopVersion + "], "
// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                + "coop_cd_sub:[" + convertSendCommonService.getCoopCdSub(journal.getCrud()) + "]");
          }

// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////          MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(), journal.getCoopCd(), JournalConvertConstants.DIRECTION_SEND, detailId, String.valueOf(dataSetMap.get("detail_id")));
//          MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(), journal.getCoopCd(),
//            coopVersion, JournalConvertConstants.DIRECTION_SEND, detailId, String.valueOf(dataSetMap.get("detail_id")));
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//          // レイアウトがない場合はジャーナルをエラーにして、次のジャーナル変換に移る
//          if (layoutDetail == null) {
//            throw new NtssException("対象ジャーナルの送信用変換レイアウトDetailが存在しません。 "
//              + "facility_cd:[" + journal.getFacilityCd() + "], "
//              + "coop_cd:[" + journal.getCoopCd() + "], "
//// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//              + "coop_version:[" + coopVersion + "], "
//// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//              + "coop_cd_sub:[" + convertSendCommonService.getCoopCdSub(journal.getCrud()) + "], "
//              + "coop_cd_detail:[" + detailId + "], "
//              + "coop_cd_detail_sub:[" + String.valueOf(dataSetMap.get("detail_id")) + "]");
//          }
          MstCoopLayoutDetail layoutDetail = convertCommonService.getMstCoopLayoutDetailBySub(journal.getFacilityCd(),
            JournalConvertConstants.DIRECTION_SEND, journal.getCoopCd(), coopVersion, detailId,
            String.valueOf(dataSetMap.get("detail_id")));
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
          // add 2020-12-30 No.724:電文内データ文字列結合 商 start
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
          // itemSuffixDetailList = getItemSuffixList(layoutDetail.getCoopExtSetting());
          xmlTelegramContext.setItemSuffixDetailList(getItemSuffixList(layoutDetail.getCoopExtSetting()));
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
          // add 2020-12-30 No.724:電文内データ文字列結合 商 end
          /* upd by chamaojia 2026-04-24 [10959] add param coopIni --start */
          Map<String, List<Map<String, Object>>> tmpDataSetMap = convertSendCommonService.createRequestAndRequestByDataSetApi(journal,
            layoutDetail.getCoopExtSetting(), dataSetMap, coopIni);
          /* upd by chamaojia 2026-04-24 [10959] add param coopIni --end */
          if (tmpDataSetMap != null && !tmpDataSetMap.isEmpty()) {
            dataSetResultMap.putAll(tmpDataSetMap);
          }

          Element element = (Element)node;
          element.removeAttribute("_detail");
          element.removeAttribute("_sqlCode");
          element.removeAttribute("_isZeroDisp");
          /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
          createDetail(layoutDetail, journal, document, node, dataSetResultMap, dataSetMap, sqlCode, ++count, coopIni, xmlTelegramContext);
          /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
        }
        Node parentNode = node.getParentNode();
        // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj start
        // Node lastChild = parentNode.getLastChild();
        //add 9374 XMLフォーマットでの繰り返し処理でのデータ出力位置が不正 zhaoqi 20230821 start
        // parentNode.replaceChild(lastChild, node);
        //add 9374 XMLフォーマットでの繰り返し処理でのデータ出力位置が不正 zhaoqi 20230821 end
        //del 9374 XMLフォーマットでの繰り返し処理でのデータ出力位置が不正 zhaoqi 20230821 start
//        parentNode.removeChild(node);
        if(isZeroDisp) {
            Element element = (Element)node;
            element.removeAttribute("_detail");
            element.removeAttribute("_sqlCode");
            element.removeAttribute("_isZeroDisp");
        } else {
        	parentNode.removeChild(node);
        }
        //del 9374 XMLフォーマットでの繰り返し処理でのデータ出力位置が不正 zhaoqi 20230821 end
        // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj end
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
        createTelegram(journal, document, parentNode.getChildNodes(), dataSetResultMap, coopIni, xmlTelegramContext);
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
        return;
      } else if (!StringUtils.isEmpty(sqlCode)) {
        if (!dataSetResultMap.containsKey(sqlCode)) {
          throw new NtssException("SQLCODEに対するデータセットが存在しません。 SQLCODE:[" + sqlCode + "]");
        }
        int count = 0;
        List<Map<String, Object>> dataSetList = dataSetResultMap.get(sqlCode);
        // _isZeroDispがtrueの場合、SQL結果が0件でも親ノードを出力する
        if(dataSetList.size() == 0  && "true".equals(isZeroDispVal)) isZeroDisp = true;
        for (Map<String, Object> dataSetMap : dataSetList) {

          Element element = (Element)node;
          element.removeAttribute("_sqlCode");
          // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj start
         // createNode(journal, document, node, dataSetResultMap, dataSetMap, sqlCode, ++count);
         /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
          createNode(journal, null, node, dataSetResultMap, dataSetMap, sqlCode, ++count, coopIni, xmlTelegramContext);
          /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
          // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj end
        }
        Node parentNode = node.getParentNode();
        // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj start
        //add 9374 XMLフォーマットでの繰り返し処理でのデータ出力位置が不正 sunyn 20231019 start
        //Node lastChild = parentNode.getLastChild();
        //parentNode.replaceChild(lastChild, node);
        //add 9374 XMLフォーマットでの繰り返し処理でのデータ出力位置が不正 sunyn 20231019 end
        //del 9374 XMLフォーマットでの繰り返し処理でのデータ出力位置が不正 sunyn 20231019 start
//        parentNode.removeChild(node);
        if(isZeroDisp) {
        	Element element = (Element)node;
        	element.removeAttribute("_detail");
        	element.removeAttribute("_sqlCode");
        	element.removeAttribute("_isZeroDisp");
        } else {
        	parentNode.removeChild(node);
        }
        //del 9374 XMLフォーマットでの繰り返し処理でのデータ出力位置が不正 sunyn 20231019 end
        // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj end
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
        createTelegram(journal, document, parentNode.getChildNodes(), dataSetResultMap, coopIni, xmlTelegramContext);
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
        return;
      } else {
        // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj start
     // createTelegramFragment(document, node, dataSetResultMap, null, journal,null, null);
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
        createTelegramFragment(null, node, dataSetResultMap, null, journal, null, null, coopIni, xmlTelegramContext);
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
        // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj end
      }
      //再帰を行う
      // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj start
      // createTelegram(journal, document, node.getChildNodes(), dataSetResultMap);
      if (node.getChildNodes().getLength() > 0) {
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
        createTelegram(journal, document, node.getChildNodes(), dataSetResultMap, coopIni, xmlTelegramContext);
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
      }
      // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj end
    }
  }
  /**
   * ノードを作成する
   * @param journal
   * @param document
   * @param node
   * @param dataSetResultMap
   * @param dataSetResult
   * @param sqlCode
   * @param count
   * @throws UnsupportedEncodingException
   */
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
  private void createNode(SysCoopJournal journal, Document document, Node node, Map<String, List<Map<String, Object>>> dataSetResultMap,
      Map<String, Object> dataSetResult, String sqlCode, int count, MstCoopIni coopIni, XmlTelegramContext xmlTelegramContext) {
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
    try {
      Node parentNode = node.getParentNode();
      Node clonedNode = node.cloneNode(true);
      NamedNodeMap attributeMap = clonedNode.getAttributes();
      if (attributeMap != null && attributeMap.getLength() > 0) {
        for (int j=0; j<attributeMap.getLength(); j++) {
          Node attributeNode = attributeMap.item(j);
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
          if (KEY_COUNT.equals(attributeNode.getNodeValue())) {
            // mod 2020-12-30 No.724:電文内データ文字列結合 商 start
            //attributeNode.setNodeValue(String.valueOf(count));
            xmlTelegramContext.setNodeName(node.getNodeName());
            String newCount = String.valueOf(count);
            newCount = getSuffixStr(newCount, xmlTelegramContext.getItemSuffixList(), xmlTelegramContext.getNodeName());
            attributeNode.setNodeValue(newCount);
            // mod 2020-12-30 No.724:電文内データ文字列結合 商 end
          }
          if (KEY_ROW_COUNT.equals(attributeNode.getNodeValue())) {
            xmlTelegramContext.setNodeName(node.getNodeName());
            String newRowCount = String.valueOf(xmlTelegramContext.nextRowCount());
            attributeNode.setNodeValue(newRowCount);
          }
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
        }
      }
      // mod 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
//      createTelegramAttributes(document, clonedNode, dataSetResultMap, sqlCode, journal, null, dataSetResult);
//      createTelegramDetailFragment(document, clonedNode, dataSetResultMap, sqlCode, journal, dataSetResult);
      /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
      createTelegramAttributes(document, clonedNode, dataSetResultMap, sqlCode, journal, null, dataSetResult, count, coopIni, xmlTelegramContext);
      createTelegramDetailFragment(document, clonedNode, dataSetResultMap, sqlCode, journal, dataSetResult, count, coopIni, xmlTelegramContext);
      /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
      // mod 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end
      // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj start
      // parentNode.appendChild(clonedNode);
      parentNode.insertBefore(clonedNode, node);
      // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj end

    } catch (UnsupportedEncodingException e) {
      throw new NtssException("ノードXML作成に失敗しました。", e);
    }
  }
  /**
   * 詳細を作成する
   * @param parentLayoutDetail
   * @param journal
   * @param document
   * @param node
   * @param dataSetResultMap
   * @param dataSetResult
   * @param sqlCode
   * @param count
   */
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
  private void createDetail(MstCoopLayoutDetail parentLayoutDetail, SysCoopJournal journal, Document document, Node node,
      Map<String, List<Map<String, Object>>> dataSetResultMap, Map<String, Object> dataSetResult, String sqlCode, int count,
      MstCoopIni coopIni, XmlTelegramContext xmlTelegramContext) {
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
    try {
      String coopSetting = getDeleteNewLine(parentLayoutDetail.getCoopSetting());
      coopSetting = getDeleteSpace(coopSetting);
      InputStream inputStream = new ByteArrayInputStream(coopSetting.getBytes(StandardCharsets.UTF_8));
      // 帳票定義Xmlをパース
      DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
      DocumentBuilder documentBuilder = documentBuilderFactory.newDocumentBuilder();
      Document detailDocument = documentBuilder.parse(inputStream);
      Node rootNode = detailDocument.getDocumentElement();
      NodeList detailNodeList = rootNode.getChildNodes();
      Node parentNode = node.getParentNode();
      Node clonedNode = node.cloneNode(true);
      NamedNodeMap attributeMap = clonedNode.getAttributes();
      if (attributeMap != null && attributeMap.getLength() > 0) {
        for (int j=0; j<attributeMap.getLength(); j++) {
          Node attributeNode = attributeMap.item(j);
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
          if (KEY_COUNT.equals(attributeNode.getNodeValue())) {
            // mod 2020-12-30 No.724:電文内データ文字列結合 商 start
            //attributeNode.setNodeValue(String.valueOf(count));
            xmlTelegramContext.setNodeName(node.getNodeName());
            String newCount = String.valueOf(count);
            newCount = getSuffixStr(newCount, xmlTelegramContext.getItemSuffixList(), xmlTelegramContext.getNodeName());
            attributeNode.setNodeValue(newCount);
            // mod 2020-12-30 No.724:電文内データ文字列結合 商 end
          }
          if (KEY_ROW_COUNT.equals(attributeNode.getNodeValue())) {
            xmlTelegramContext.setNodeName(node.getNodeName());
            String newRowCount = String.valueOf(xmlTelegramContext.nextRowCount());
            attributeNode.setNodeValue(newRowCount);
          }
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
        }
      }
      // add #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 mengj start
      /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
      createTelegram(journal, document, detailNodeList, dataSetResultMap, coopIni, xmlTelegramContext);
      /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
      // add #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 mengj end
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage elm;
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      for (int i = 0; i < detailNodeList.getLength();i++) {
        Node detailNode = detailNodeList.item(i);
        NamedNodeMap tmpAttributeMap = detailNode.getAttributes();
        if (tmpAttributeMap != null && tmpAttributeMap.getLength() > 0) {
          for (int j=0; j<tmpAttributeMap.getLength(); j++) {
            Node attributeNode = tmpAttributeMap.item(j);
            //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
            elm = new EventLogMessage();
            elm.setLogMessage("attributeNode.getNodeName():" + attributeNode.getNodeName() + ", attributeNode.getNodeValue():" + attributeNode.getNodeValue());
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
            elm.setInvokeClass(this.getClass().getName());
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
            logService.log(LogLevel.INFO, elm, null, SERVICE_NAME.FNSI, null);
            //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
          }
        }
        // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj mengj start
        // mod 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
//        createTelegramAttributes(document, detailNode, dataSetResultMap, sqlCode, journal, null, dataSetResult);
        //createTelegramAttributes(document, detailNode, dataSetResultMap, sqlCode, journal, null, dataSetResult, count);
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
        createTelegramAttributes(null, detailNode, dataSetResultMap, sqlCode, journal, null, dataSetResult, count, coopIni, xmlTelegramContext);
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
        // mod 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end
        // Node adaptedDetailNode = document.adoptNode(detailNode);
        Node clonedDetailNode = detailNode.cloneNode(true);
        Node adaptedDetailNode = document.adoptNode(clonedDetailNode);
        Node importedDetailNode = clonedNode.getOwnerDocument().importNode(adaptedDetailNode, true);
        clonedNode.appendChild(importedDetailNode);
        // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj mengj end
      }
      // mod 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
//      createTelegramAttributes(document, clonedNode, dataSetResultMap, sqlCode, journal, null, dataSetResult);
//      createTelegramDetailFragment(document, clonedNode, dataSetResultMap, sqlCode, journal, dataSetResult);
      // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj start
      //createTelegramAttributes(document, clonedNode, dataSetResultMap, sqlCode, journal, null, dataSetResult, count);
      //createTelegramDetailFragment(document, clonedNode, dataSetResultMap, sqlCode, journal, dataSetResult, count);
      /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
      createTelegramAttributes(null, clonedNode, dataSetResultMap, sqlCode, journal, null, dataSetResult, count, coopIni, xmlTelegramContext);
      createTelegramDetailFragment(null, clonedNode, dataSetResultMap, sqlCode, journal, dataSetResult, count, coopIni, xmlTelegramContext);
      /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
      // mod 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end
      //parentNode.appendChild(clonedNode);
      parentNode.insertBefore(clonedNode, node);
      // mod #10139 XMLフォーマットでの繰り返し処理中での繰り返しが正しく動作しない 20240103 xugj end
    } catch (ParserConfigurationException | SAXException | IOException e) {
      throw new NtssException("詳細XML電文の作成に失敗しました。", e);
    }
  }
  /**
   * 詳細ノード値を作成
   * @param document
   * @param node
   * @param dataSetResultMap
   * @param sqlCode
   * @param journal
   * @param dataSetResult
   * @param count
   * @throws UnsupportedEncodingException
   */
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
  private void createTelegramDetailFragment(Document document, Node node, Map<String,
      List<Map<String, Object>>> dataSetResultMap, String sqlCode, SysCoopJournal journal,
// add 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
//      Map<String, Object> dataSetResult) throws UnsupportedEncodingException {
      Map<String, Object> dataSetResult, int count, MstCoopIni coopIni, XmlTelegramContext xmlTelegramContext) throws UnsupportedEncodingException {
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
// add 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end
    // add 2020-12-30 No.724:電文内データ文字列結合 商 start
    if (StringUtils.isEmpty(node.getNodeValue())) {
      /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
      // nodeName = node.getNodeName();
      xmlTelegramContext.setNodeName(node.getNodeName());
      /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
    }
    // add 2020-12-30 No.724:電文内データ文字列結合 商 end
    if (!StringUtils.isEmpty(node.getNodeValue())) {
      String replaceEscape =  node.getNodeValue().trim();
      /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
      if (replaceEscape.startsWith(KEY_JOURNAL)) {
        //ジャーナルテーブルのデータを取得する
        // mod 2020-12-30 No.724:電文内データ文字列結合 商 start
        //node.setNodeValue(convertSendCommonService.getJournalReplaceData(replaceEscape, journal));
        String newReplaceEscape = convertSendCommonService.getJournalReplaceData(replaceEscape, journal);
        newReplaceEscape = getSuffixStr(newReplaceEscape, xmlTelegramContext.getItemSuffixDetailList(), xmlTelegramContext.getNodeName());
        node.setNodeValue(newReplaceEscape);
        // mod 2020-12-30 No.724:電文内データ文字列結合 商 end
      }
      // add 2021-11-17 #5896:SSI連携ができない(カルテ記載連携) 孫 start
      else if (replaceEscape.startsWith(KEY_SYSDATE)){
        String newReplaceEscape = concatSYSDATE(replaceEscape);
        newReplaceEscape = getSuffixStr(newReplaceEscape, xmlTelegramContext.getItemSuffixDetailList(), xmlTelegramContext.getNodeName());
        node.setNodeValue(newReplaceEscape);
        // formatを削除する
        replaceEscape = KEY_SYSDATE;
      }
      else if (replaceEscape.startsWith(KEY_SYSTIME)){
        String newReplaceEscape = concatSYSTIME(replaceEscape);
        newReplaceEscape = getSuffixStr(newReplaceEscape, xmlTelegramContext.getItemSuffixDetailList(), xmlTelegramContext.getNodeName());
        node.setNodeValue(newReplaceEscape);
        // formatを削除する
        replaceEscape = KEY_SYSTIME;
      }
      // add 2021-11-17 #5896:SSI連携ができない(カルテ記載連携) 孫 end
      // add 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
      if (KEY_COUNT.equals(replaceEscape)) {
        xmlTelegramContext.setNodeName(node.getNodeName());
        String newCount = String.valueOf(count);
        newCount = getSuffixStr(newCount, xmlTelegramContext.getItemSuffixList(), xmlTelegramContext.getNodeName());
        node.setNodeValue(newCount);
      }
      if (KEY_ROW_COUNT.equals(replaceEscape)) {
        xmlTelegramContext.setNodeName(node.getNodeName());
        String newRowCount = String.valueOf(xmlTelegramContext.nextRowCount());
        node.setNodeValue(newRowCount);
      }
      /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
      // add 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end
      if (replaceEscape.indexOf(":") != -1) {
        String[] keyValueArray = replaceEscape.split(":");
        String key = keyValueArray[0];
        // 出力方法別
        ElementsValue elementVal = ElementsValue.getElement(key);
        switch(elementVal) {
          // dataset結果から抽出
          case DATASET:
          case AUTH_ID:
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 start
          case IN_HOSPITAL_CD_1: // 利用者マスタから院内コード1取得
          case IN_HOSPITAL_CD_2: // 利用者マスタから院内コード2取得
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 end
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 start
          case JOB_CD:   // 利用者マスタから職種コード取得
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 end
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
          case STAFF_NAME:   // 利用者マスタから利用者名取得
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end
            String datasetValue = dataSetResultMap.isEmpty() ? "": getDatasetValue(dataSetResultMap, keyValueArray[1], dataSetResult);
            // mod 2020-12-30 No.724:電文内データ文字列結合 商 start
            //node.setNodeValue(convertValue(elementVal, datasetValue));
            String newDatasetValue = convertValue(elementVal, datasetValue);
            /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
            newDatasetValue = getSuffixStr(newDatasetValue, xmlTelegramContext.getItemSuffixDetailList(), xmlTelegramContext.getNodeName());
            /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
            node.setNodeValue(newDatasetValue);
            // mod 2020-12-30 No.724:電文内データ文字列結合 商 end
            break;
          default:
            // 上記以外は処理なし
            break;
        }
      }
    }
    NodeList childNodes = node.getChildNodes();
    if (childNodes != null && childNodes.getLength() != 0) {
      for (int i = 0; i < childNodes.getLength();i++) {
        Node childNode = childNodes.item(i);
        // mod 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
//        // add 2021-09-24 #5897:CSI連携ができないの対応 孫 start
//        createTelegramAttributes(document, childNode, dataSetResultMap, sqlCode, journal, null, dataSetResult);
//        // add 2021-09-24 #5897:CSI連携ができないの対応 孫 end
//        createTelegramDetailFragment(document, childNode, dataSetResultMap, sqlCode, journal, dataSetResult);
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
        createTelegramAttributes(document, childNode, dataSetResultMap, sqlCode, journal, null, dataSetResult, count, coopIni, xmlTelegramContext);
        createTelegramDetailFragment(document, childNode, dataSetResultMap, sqlCode, journal, dataSetResult, count, coopIni, xmlTelegramContext);
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
        // mod 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end
      }
    }
  }
  /**
   * ノード値を作成
   * @param document
   * @param node
   * @param dataSetResultMap
   * @param sqlCode
   * @param journal
   * @param detailLayout
   * @param dataSetResult
   * @throws UnsupportedEncodingException
   */
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
  private void createTelegramFragment(Document document, Node node, Map<String,
      List<Map<String, Object>>> dataSetResultMap, String sqlCode, SysCoopJournal journal,
      MstCoopLayoutDetail detailLayout, Map<String, Object> dataSetResult, MstCoopIni coopIni, XmlTelegramContext xmlTelegramContext) throws UnsupportedEncodingException {
// mod 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
//    createTelegramAttributes(document, node, dataSetResultMap, sqlCode, journal, detailLayout, dataSetResult);
    createTelegramAttributes(document, node, dataSetResultMap, sqlCode, journal, detailLayout, dataSetResult, 0, coopIni, xmlTelegramContext);
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
// mod 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end

    /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    if (StringUtils.isEmpty(node.getNodeValue())) {
      return;
    }
    String replaceEscape =  node.getNodeValue().trim();
    if (replaceEscape.startsWith(KEY_JOURNAL)) {
      //ジャーナルテーブルのデータを取得する
      // mod 2020-12-30 No.724:電文内データ文字列結合 商 start
      //node.setNodeValue(convertSendCommonService.getJournalReplaceData(replaceEscape, journal));
      String newReplaceEscape = convertSendCommonService.getJournalReplaceData(replaceEscape, journal);
      newReplaceEscape = getSuffixStr(newReplaceEscape, xmlTelegramContext.getItemSuffixList(), xmlTelegramContext.getNodeName());
      node.setNodeValue(newReplaceEscape);
      // mod 2020-12-30 No.724:電文内データ文字列結合 商 end
    }
    // add 2021-11-17 #5896:SSI連携ができない(カルテ記載連携) 孫 start
    else if (replaceEscape.startsWith(KEY_SYSDATE)){
      String newReplaceEscape = concatSYSDATE(replaceEscape);
      newReplaceEscape = getSuffixStr(newReplaceEscape, xmlTelegramContext.getItemSuffixDetailList(), xmlTelegramContext.getNodeName());
      node.setNodeValue(newReplaceEscape);
      // formatを削除する
      replaceEscape = KEY_SYSDATE;
    }
    else if (replaceEscape.startsWith(KEY_SYSTIME)){
      String newReplaceEscape = concatSYSTIME(replaceEscape);
      newReplaceEscape = getSuffixStr(newReplaceEscape, xmlTelegramContext.getItemSuffixDetailList(), xmlTelegramContext.getNodeName());
      node.setNodeValue(newReplaceEscape);
      // formatを削除する
      replaceEscape = KEY_SYSTIME;
    }
    /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
    // add 2021-11-17 #5896:SSI連携ができない(カルテ記載連携) 孫 end
    if (replaceEscape.indexOf(":") != -1) {
      String[] keyValueArray = replaceEscape.split(":");
      String key = keyValueArray[0];
      // 出力方法別
      ElementsValue elementVal = ElementsValue.getElement(key);
      switch(elementVal) {
        // dataset結果から抽出
        case DATASET: // datasetから値を取得
        case AUTH_ID: // 利用者マスタから変換
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 start
        case IN_HOSPITAL_CD_1: // 利用者マスタから院内コード1取得
        case IN_HOSPITAL_CD_2: // 利用者マスタから院内コード2取得
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 end
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 start
        case JOB_CD:   // 利用者マスタから職種コード取得
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 end
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
        case STAFF_NAME:   // 利用者マスタから利用者名取得
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end
          if (!StringUtils.isEmpty(sqlCode) && detailLayout != null && dataSetResult != null && !dataSetResult.isEmpty()) {
            // String#splitはpatternで分割するため、ドット単体だと分割できない(matchせず空配列で返却される)のでPattern化する
            String[] dataSetArray = keyValueArray[1].split(Pattern.quote("."));
            String dataSetSqlCode = dataSetArray[0];
            String extractColumnName = dataSetArray[1];

            // 再帰的にもらった親detailレイアウトからのSQLCODEとitemタグからもらったdatasetのSQLCODEに差異がある場合は、itemタグのSQLCODEを優先しdatasetの取得を行う。
            if (!sqlCode.equals(dataSetSqlCode)) {
              /* upd by chamaojia 2026-04-24 [10959] add param coopIni --start */
              Map<String, List<Map<String, Object>>> dataSetMap = convertSendCommonService.createRequestAndRequestByDataSetApi(journal,
                detailLayout.getCoopExtSetting(), dataSetResult, coopIni);
              /* upd by chamaojia 2026-04-24 [10959] add param coopIni --end */
              if (dataSetMap != null && !dataSetMap.isEmpty()) {
                // 単発想定のため、決め打ち
                List<Map<String, Object>> dataSetList = dataSetMap.get(dataSetSqlCode);
                String dataSetSqlCodeValue = "";
                if (CollectionUtils.isEmpty(dataSetList) && !StringUtils.isEmpty(dataSetList.get(0).get(extractColumnName))) {
                  dataSetSqlCodeValue = String.valueOf(dataSetList.get(0).get(extractColumnName));
                }
                node.setNodeValue(convertValue(elementVal, dataSetSqlCodeValue));
              }
            } else {
              // 親オカレンスのsqlCodeとvalue="dataset:~~~"のsqlCodeが合致した場合はフォーマットに基づきカラムを抽出し電文に載せる
              String dataSetSqlCodeValue = dataSetResult.get(extractColumnName) == null ? "" : String.valueOf(dataSetResult.get(extractColumnName));
              node.setNodeValue(convertValue(elementVal, dataSetSqlCodeValue));
            }
          } else {
            // もしdatasetの結果が空だった場合は、空文字にしてパディングを入れる
            String datasetValue = dataSetResultMap.isEmpty() ? "": concatDatasetValue(dataSetResultMap, keyValueArray[1]);
            // mod 2020-12-30 No.724:電文内データ文字列結合 商 start
            //node.setNodeValue(convertValue(elementVal, datasetValue));
            String newDatasetValue = convertValue(elementVal, datasetValue);
            /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
            newDatasetValue = getSuffixStr(newDatasetValue, xmlTelegramContext.getItemSuffixList(), xmlTelegramContext.getNodeName());
            /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
            node.setNodeValue(newDatasetValue);
            // mod 2020-12-30 No.724:電文内データ文字列結合 商 end
          }
          break;
        default:
          // 上記以外は処理なし
          break;
      }
    }
  }
  /**
   * Attribute値を作成する
   * @param document
   * @param node
   * @param dataSetResultMap
   * @param sqlCode
   * @param journal
   * @param detailLayout
   * @param dataSetResult
   * @param count
   * @throws UnsupportedEncodingException
   */
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --start */
  private void createTelegramAttributes(Document document, Node node, Map<String,
      List<Map<String, Object>>> dataSetResultMap, String sqlCode, SysCoopJournal journal,
// mod 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
//      MstCoopLayoutDetail detailLayout, Map<String, Object> dataSetResult) throws UnsupportedEncodingException {
      MstCoopLayoutDetail detailLayout, Map<String, Object> dataSetResult, int count, MstCoopIni coopIni, XmlTelegramContext xmlTelegramContext) throws UnsupportedEncodingException {
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、xmlTelegramContext --end */
// mod 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end
    NamedNodeMap attributeMap = node.getAttributes();
    if (attributeMap == null || attributeMap.getLength() == 0) {
      return;
    }
    for (int j=0; j<attributeMap.getLength(); j++) {
      Node attributeNode = attributeMap.item(j);
      String attributeValue = attributeNode.getNodeValue();

      /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
      if (attributeValue.startsWith(KEY_JOURNAL)) {
        // ジャーナルテーブルのデータを取得する
        // mod 2020-12-30 No.724:電文内データ文字列結合 商 start
        //attributeNode.setNodeValue(convertSendCommonService.getJournalReplaceData(attributeValue, journal));
        xmlTelegramContext.setNodeName(node.getNodeName());
        String newAttributeValue = convertSendCommonService.getJournalReplaceData(attributeValue, journal);
        newAttributeValue = getSuffixStr(newAttributeValue, xmlTelegramContext.getItemSuffixList(), xmlTelegramContext.getNodeName());
        attributeNode.setNodeValue(newAttributeValue);
        // mod 2020-12-30 No.724:電文内データ文字列結合 商 end
      }
      // add 2021-11-17 #5896:SSI連携ができない(カルテ記載連携) 孫 start
      else if (attributeValue.startsWith(KEY_SYSDATE)){
        String newReplaceEscape = concatSYSDATE(attributeValue);
        newReplaceEscape = getSuffixStr(newReplaceEscape, xmlTelegramContext.getItemSuffixDetailList(), xmlTelegramContext.getNodeName());
        node.setNodeValue(newReplaceEscape);
        // formatを削除する
        attributeValue = KEY_SYSDATE;
      }
      else if (attributeValue.startsWith(KEY_SYSTIME)){
        String newReplaceEscape = concatSYSTIME(attributeValue);
        newReplaceEscape = getSuffixStr(newReplaceEscape, xmlTelegramContext.getItemSuffixDetailList(), xmlTelegramContext.getNodeName());
        node.setNodeValue(newReplaceEscape);
        // formatを削除する
        attributeValue = KEY_SYSTIME;
      }
      // add 2021-11-17 #5896:SSI連携ができない(カルテ記載連携) 孫 end

      // add 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
      if (KEY_COUNT.equals(attributeValue)) {
        xmlTelegramContext.setNodeName(node.getNodeName());
        String newCount = String.valueOf(count);
        newCount = getSuffixStr(newCount, xmlTelegramContext.getItemSuffixList(), xmlTelegramContext.getNodeName());
        attributeNode.setNodeValue(newCount);
      }
      if (KEY_ROW_COUNT.equals(attributeValue)) {
        xmlTelegramContext.setNodeName(node.getNodeName());
        String newRowCount = String.valueOf(xmlTelegramContext.nextRowCount());
        attributeNode.setNodeValue(newRowCount);
      }
      /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
      // add 2021-10-26 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end

      if (attributeValue.indexOf(":") != -1) {
        String[] keyValueArray = attributeValue.split(":");
        String key = keyValueArray[0];
        // 出力方法別
        ElementsValue elementVal = ElementsValue.getElement(key);
        switch(elementVal) {
          // dataset結果から抽出
          case DATASET:   // datasetから値を取得
          case AUTH_ID:   // 利用者マスタから取得
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 start
          case IN_HOSPITAL_CD_1: // 利用者マスタから院内コード1取得
          case IN_HOSPITAL_CD_2: // 利用者マスタから院内コード2取得
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 end
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 start
          case JOB_CD:   // 利用者マスタから職種コード取得
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 end
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
          case STAFF_NAME:   // 利用者マスタから利用者名取得
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end
            if (!StringUtils.isEmpty(sqlCode) && detailLayout != null && dataSetResult != null && !dataSetResult.isEmpty()) {
              // String#splitはpatternで分割するため、ドット単体だと分割できない(matchせず空配列で返却される)のでPattern化する
              String[] dataSetArray = keyValueArray[1].split(Pattern.quote("."));
              String dataSetSqlCode = dataSetArray[0];
              String extractColumnName = dataSetArray[1];

              // 再帰的にもらった親detailレイアウトからのSQLCODEとitemタグからもらったdatasetのSQLCODEに差異がある場合は、itemタグのSQLCODEを優先しdatasetの取得を行う。
              if (!sqlCode.equals(dataSetSqlCode)) {
                /* upd by chamaojia 2026-04-24 [10959] add param coopIni --start */
                Map<String, List<Map<String, Object>>> dataSetMap = convertSendCommonService.createRequestAndRequestByDataSetApi(journal,
                  detailLayout.getCoopExtSetting(), dataSetResult, coopIni);
                /* upd by chamaojia 2026-04-24 [10959] add param coopIni --end */
                if (dataSetMap != null && !dataSetMap.isEmpty()) {
                  // 単発想定のため、決め打ち
                  List<Map<String, Object>> dataSetList = dataSetMap.get(dataSetSqlCode);
                  String dataSetSqlCodeValue = "";
                  if (CollectionUtils.isEmpty(dataSetList) && !StringUtils.isEmpty(dataSetList.get(0).get(extractColumnName))) {
                    dataSetSqlCodeValue = String.valueOf(dataSetList.get(0).get(extractColumnName));
                  }
                  attributeNode.setNodeValue(convertValue(elementVal, dataSetSqlCodeValue));
                }
              } else {
                // 親オカレンスのsqlCodeとvalue="dataset:~~~"のsqlCodeが合致した場合はフォーマットに基づきカラムを抽出し電文に載せる
                String dataSetSqlCodeValue = dataSetResult.get(extractColumnName) == null ? "" : String.valueOf(dataSetResult.get(extractColumnName));
                attributeNode.setNodeValue(convertValue(elementVal, dataSetSqlCodeValue));
              }
            } else {
              // もしdatasetの結果が空だった場合は、空文字にしてパディングを入れる
              String datasetValue = dataSetResultMap.isEmpty() ? "": getDatasetValue(dataSetResultMap, keyValueArray[1], dataSetResult);
              if (datasetValue != null) {
                // mod 2020-12-30 No.724:電文内データ文字列結合 商 start
                //attributeNode.setNodeValue(convertValue(elementVal, datasetValue));
                String newDatasetValue = convertValue(elementVal, datasetValue);
                /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
                xmlTelegramContext.setNodeName(node.getNodeName());
                newDatasetValue = getSuffixStr(newDatasetValue, xmlTelegramContext.getItemSuffixDetailList(), xmlTelegramContext.getNodeName());
                /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
                attributeNode.setNodeValue(newDatasetValue);
                // mod 2020-12-30 No.724:電文内データ文字列結合 商 end
              }
// add 2021-10-13 CSIの「【透析予約送信】【エラー】不正な処理区分です。」の対応 孫 start
              else {
                attributeNode.setNodeValue(datasetValue);
              }
// add 2021-10-13 CSIの「【透析予約送信】【エラー】不正な処理区分です。」の対応 孫 end
            }
            break;
          default:
            // 上記以外は処理なし
            break;
        }
      }
    }
  }
  /**
   * XMLの内容から改行を削除する
   * @param xml
   * @return
   */
  private String getDeleteNewLine(String xml) {
    // mod 2021-01-18 No.707:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
//    return xml.replaceAll("\\r\\n|\\r|\\n", "");
    return xml.replaceAll("\\r\\n|\\r|\\n", " ");
    // mod 2021-01-18 No.707:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
  }

  /**
   * XMLの内容からインデントの空白を削除する
   * @param 削除前xml文字列
   * @return 削除後xml文字列
   */
  private String getDeleteSpace(String xml) {
    return xml.replaceAll(">[ |\\t]+<", "><");
  }

  /**
   * data-setでの電文作成
   *
   * @param dataSetResultMap - data-setの結果Map
   * @param dataSetValue - data-setの結果Mapから抽出したいキー
   * @return Paddingされたdata-setの値
   */
  private String concatDatasetValue(Map<String, List<Map<String, Object>>> dataSetResultMap, String dataSetValue) {
    String telegramFragment = "";
    // ドットで区切られているため、区切り文字がない場合はエラー
    if (dataSetValue.indexOf(".") == -1) {
      throw new NtssException("データセット取得フォーマット形式が不正です。 対象データ:[" + dataSetValue + "]");
    }

    // String#splitはpatternで分割するため、ドット単体だと分割できない(matchせず空配列で返却される)のでPattern化する
    String[] datasetArray = dataSetValue.split(Pattern.quote("."));
    String sqlCode = datasetArray[0];
    String extractColumnName = datasetArray[1];

    if (!dataSetResultMap.containsKey(sqlCode)) {
      throw new NtssException("SQLCODEに対するデータセットが存在しません。 SQLCODE:[" + sqlCode + "]");
    }

    List<Map<String, Object>> dataSetResultList = dataSetResultMap.get(sqlCode);
    for (Map<String, Object> dataSetResult : dataSetResultList) {
      telegramFragment = telegramFragment.concat(String.valueOf(dataSetResult.get(extractColumnName)));
    }

    return telegramFragment;
  }
  /**
   * data-setでの電文取得
   *
   * @param dataSetResultMap - data-setの結果Map
   * @param dataSetValue - data-setの結果Mapから抽出したいキー
   * @param dataSetResult - data-setの結果詳細Map
   * @return Paddingされたdata-setの値
   */
  private String getDatasetValue(Map<String, List<Map<String, Object>>> dataSetResultMap, String dataSetValue, Map<String, Object> dataSetResult) {
    String telegramFragment = "";
    // ドットで区切られているため、区切り文字がない場合はエラー
    if (dataSetValue.indexOf(".") == -1) {
      throw new NtssException("データセット取得フォーマット形式が不正です。 対象データ:[" + dataSetValue + "]");
    }

    // String#splitはpatternで分割するため、ドット単体だと分割できない(matchせず空配列で返却される)のでPattern化する
    String[] datasetArray = dataSetValue.split(Pattern.quote("."));
    String sqlCode = datasetArray[0];
    String extractColumnName = datasetArray[1];

    if (!dataSetResultMap.containsKey(sqlCode)) {
      throw new NtssException("SQLCODEに対するデータセットが存在しません。 SQLCODE:[" + sqlCode + "]");
    }

    List<Map<String, Object>> dataSetResultList = dataSetResultMap.get(sqlCode);
    if (dataSetResultList.size() == 1) {
      for (Map<String, Object> dataSet : dataSetResultList) {
        telegramFragment = dataSet.get(extractColumnName) == null ? "" : String.valueOf(dataSet.get(extractColumnName));
      }
    } else {
      if (dataSetResult == null) {
        return null;
      }
      telegramFragment = dataSetResult.get(extractColumnName) == null ? "" : String.valueOf(dataSetResult.get(extractColumnName));
    }
    return StringUtils.isEmpty(telegramFragment)? "":telegramFragment;
  }

  /**
   * 値の変換処理
   *
   * @param elementVal 属性のvalue値
   * @param value 変換対象の値
   * @return 変換後の値
   * */
  private String convertValue(ElementsValue elementVal, String value) {

    switch (elementVal) {
      case DATASET:   // dataset
        // 変換なし
        return value;
      case AUTH_ID:   // auth_id
        // 引数をもとに利用者マスタの検索
        return convertSendCommonService.getAuthId(value);
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 start
      case IN_HOSPITAL_CD_1:
        // 引数をもとに利用者マスタの院内コード1検索
        return convertSendCommonService.getInHospitalCd1(value);
      case IN_HOSPITAL_CD_2:
        // 引数をもとに利用者マスタの院内コード2検索
        return convertSendCommonService.getInHospitalCd2(value);
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 end
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 start
      case JOB_CD:   // job_cd
        // 引数をもとに利用者マスタの職種コード検索
        return convertSendCommonService.getJobCd(value);
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 end
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
      case STAFF_NAME:   //staff_name
        // 引数をもとに利用者マスタの利用者名検索
        return convertSendCommonService.getStaffName(value);
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end
      default:
        // それ以外はそのままの値を返却
        return value;
    }
  }

  /**
   * ログ出力
   *
   * @param level {@link LogLevel} ログレベル
   * @param facilityCd 施設コード
   * @param message ログメッセージ
   */
  private void outputLog(LogLevel level, String facilityCd, String message) {
    EventLogMessage elm = new EventLogMessage();
    elm.setFacilityCd(facilityCd);
    elm.setLogMessage(message);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    elm.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(level, elm, null, SERVICE_NAME.FNSI, null);
  }

  /**
   * エラーログ出力
   *
   * @param facilityCd 施設コード
   * @param message ログメッセージ
   */
  private void outputErrorLog(String facilityCd, String message) {
    outputLog(LogLevel.ERROR, facilityCd, message);
  }

  /**
   * インフォログ出力
   *
   * @param facilityCd 施設コード
   * @param message ログメッセージ
   * */
  private void outputInfoLog(String facilityCd, String message) {
    outputLog(LogLevel.INFO, facilityCd, message);
  }

  /**
   * デバッグログ出力
   *
   * @param facilityCd 施設コード
   * @param message ログメッセージ
   * */
  private void outputDebugLog(String facilityCd, String message) {
    outputLog(LogLevel.DEBUG, facilityCd, message);
  }

  // add 2020-12-30 No.724:電文内データ文字列結合 商 start
  /**
   * 接頭語、接尾語リスト取得
   *
   * @param layoutExtSetting 拡張設定値
   * @return 接頭語、接尾語リスト
   * */
  private List<Map<String, Object>> getItemSuffixList(LayoutExtSetting layoutExtSetting) {
    List<Map<String, Object>> list = new ArrayList<>();
    if (layoutExtSetting == null || !layoutExtSetting.containsKey("item_suffix")) {
      return list;
    } else {
      for (Map.Entry<String, Object> keyValue : layoutExtSetting.entrySet()) {
        if (!keyValue.getKey().equals("item_suffix")) continue;
        list = cast(keyValue.getValue());
      }
    }
    return list;
  }

  /**
   * 未検査キャスト用メソッド
   *
   * @param target - キャスト対象
   * @return T
   */
  @SuppressWarnings("unchecked")
  private <T> T cast(Object target) {
    T castTarget = (T)target;
    return castTarget;
  }

  /**
   * 変更後電文取得
   *
   * @param datasetValue
   * @param list
   * @return 変更後電文
   * */
  /* upd by chamaojia 2026-04-24 [10959] add param nodeName --start */
  private String getSuffixStr(String datasetValue, List<Map<String, Object>> list, String nodeName) {
  /* upd by chamaojia 2026-04-24 [10959] add param nodeName --end */
    if (StringUtils.isEmpty(datasetValue)) {
      return datasetValue;
    } else {
      String preChar = "";
      String aftChar = "";
      for (int i = 0; i < list.size(); i++) {
        if(list.get(i).containsKey("name")) {
          if(nodeName.equals(list.get(i).get("name"))) {
            if(list.get(i).containsKey("pre_char")) {
              preChar = String.valueOf(list.get(i).get("pre_char"));
            }
            if(list.get(i).containsKey("aft_char")) {
              aftChar = String.valueOf(list.get(i).get("aft_char"));
            }
            break;
          }
        }
      }
      return preChar + datasetValue + aftChar;
    }
  }
  // add 2020-12-30 No.724:電文内データ文字列結合 商 end

  /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  private static class XmlTelegramContext {
    private List<Map<String, Object>> itemSuffixList = new ArrayList<>();
    private List<Map<String, Object>> itemSuffixDetailList = new ArrayList<>();
    private String nodeName = "";
    private int rowCount = 1;

    private List<Map<String, Object>> getItemSuffixList() {
      return itemSuffixList;
    }

    private void setItemSuffixList(List<Map<String, Object>> itemSuffixList) {
      this.itemSuffixList = itemSuffixList;
    }

    private List<Map<String, Object>> getItemSuffixDetailList() {
      return itemSuffixDetailList;
    }

    private void setItemSuffixDetailList(List<Map<String, Object>> itemSuffixDetailList) {
      this.itemSuffixDetailList = itemSuffixDetailList;
    }

    private String getNodeName() {
      return nodeName;
    }

    private void setNodeName(String nodeName) {
      this.nodeName = nodeName;
    }

    private int nextRowCount() {
      return rowCount++;
    }
  }
  /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  // add 2021-11-17 #5896:SSI連携ができない(カルテ記載連携) 孫 start
  /**
   * 現在日での電文作成
   *
   * @param attributeValue - 属性値
   * @return 現在日
   */
  private String concatSYSDATE(String attributeValue) {
    // format[yyyyMMdd,yyyy/MM/dd,yyyy-MM-dd]
    String format = attributeValue.replace(KEY_SYSDATE, "");
    if (StringUtils.isEmpty(format)) {
      format = "yyyyMMdd";
    }
    try {
      DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern(format.trim());
      String timeTmp =  dateFormat.format(LocalDateTime.now(clockWrapper.getClock()));
      return timeTmp;
    } catch (Exception e) {
      throw new NtssException("現在日のフォーマット[" + attributeValue + "]不正。[" + e.getMessage() + "]");
    }
  }

  /**
   * 現在時刻での電文作成
   *
   * @param attributeValue - 属性値
   * @return 現在時刻
   */
  private String concatSYSTIME(String attributeValue) {
    // format[HHmmssSSS,HHmmss,HH:mm:ss.SSS,HH:mm:ss]
    String format = attributeValue.replace(KEY_SYSTIME, "");
    if (StringUtils.isEmpty(format)) {
      format = "HHmmss";
    }
    try {
      DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern(format.trim());
      String timeTmp =  dateFormat.format(LocalDateTime.now(clockWrapper.getClock()));
      return timeTmp;
    } catch (Exception e) {
      throw new NtssException("現在時刻のフォーマット[" + attributeValue + "]不正。[" + e.getMessage() + "]");
    }
  }
  // add 2021-11-17 #5896:SSI連携ができない(カルテ記載連携) 孫 end
}
