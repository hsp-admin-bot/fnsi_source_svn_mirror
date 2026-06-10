package jp.co.nikkiso.ntss.api.service.utils;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import jp.co.nikkiso.ntss.api.domain.report.ReportXmlClassificationDataCode;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlConv;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlFilter;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlFilterTable;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlFormatCondition;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlGroup;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlParam;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlTmplRepeat;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlTotalTable;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellValue;
import org.apache.poi.ss.usermodel.FormulaEvaluator;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.util.CellRangeAddress;
import org.springframework.util.StringUtils;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.api.service.LogServiceImpl;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;

/**
 * 帳票ユーティリティクラス.
 */
@Slf4j
public class ReportUtils {

  private static Pattern positionRegex = Pattern.compile("^([^\\-]+)\\-*(\\d*)$");
  private static Pattern positionRegexTmpl = Pattern.compile("^([^\\-]+)\\-*(\\d*)\\.([^\\.]+)*$");
  private static Pattern positionRegexTmplSyohou = Pattern.compile("^([^-]+):([^-]+)-*(\\d*).([^-]+)-*(\\d*)$");
  // add 8473-1 書式が正しく反映されていない個所がある。 by Luantian start
  public  static Pattern getPositionRegexTmpl(){
    return positionRegexTmpl;
  }
  // add 8473-1 書式が正しく反映されていない個所がある。 by Luantian end
  // add 8473-1 書式が正しく反映されていない個所がある。 吉 start
  public  static Pattern getPositionRegex(){
    return positionRegex;
  }
  // add 8473-1 書式が正しく反映されていない個所がある。 吉 end
  // add 2021-07-27 #5814:フリー計算したexcelセルの背景色に赤色をつけてしまう。色付けないように修正してください。 孫 start
  /**
   * エラー時に帳票デザインHTMLへ出力する文字列.
   */
  private static final String DISPLAY_HTML_ERROR = "ｴﾗｰ";
  // add 2021-07-27 #5814:フリー計算したexcelセルの背景色に赤色をつけてしまう。色付けないように修正してください。 孫 end

  //regin 关键字
  private static final String key_1 = "#";
  private static final String key_2 = ":";
  private static final String key_3 = ".";
  private static final String key_4 = "-";
  private static final String key_5 = "N";
  private static final int key_6 = (int) 'A';
  private static final int key_7 = (int) 'Z';
  //endregin 关键字
  /**
   * POIセル範囲の取得.
   *
   * @param sheet ワークシート
   * @param position セル参照文字列(R1C1形式)
   * @return セル範囲
   */
  public static CellRangeAddress getCellRange(Sheet sheet, String position) {
    Matcher m = positionRegex.matcher(position);
    if (!m.matches()) {
      return null;
    }

    CellRangeAddress cellRange = CellRangeAddress.valueOf(m.group(1));
    if (!StringUtils.isEmpty(m.group(2))) {
      // "-[0-9]"が末尾についていたら、行位置のオフセットとみなす
      int offset = Integer.valueOf(m.group(2)) - 1;
      //
      if (position.startsWith("A7:F9") || position.startsWith("A10:F12")){
        offset *= 2;
      }

      cellRange = moveRange(sheet, cellRange, offset);
    }
    return cellRange;
  }

  /**
   * POIセル範囲の移動.
   *
   * @param sheet ワークシート
   * @param base ベースセル範囲
   * @param offset Y方向の移動量
   * @return 移動後のセル範囲
   */
  private static CellRangeAddress moveRange(Sheet sheet, CellRangeAddress base, int offset) {
    // セル結合されている場合を考慮する
    for (int i = 0; i < offset; i++) {
      int delta = 0;
      CellRangeAddress cra = sheet.getMergedRegions().stream()
        .filter(e -> e.isInRange(base.getFirstRow(), base.getFirstColumn()))
        .findFirst()
        .orElse(null);
      if (cra != null) {
        delta = cra.getLastRow() - cra.getFirstRow();
      }
      base.setFirstRow(base.getFirstRow() + delta + 1);
      base.setLastRow(base.getLastRow() + delta + 1);
    }

    return base;
  }

  /**
   * POIセルオブジェクトの取得.
   *
   * @param sheet ワークシート
   * @param rowIndex 行インデックス
   * @param columnIndex 列インデックス
   * @return POIセルオブジェクト
   */
  public static Cell getCell(Sheet sheet, int rowIndex, int columnIndex) {
    // add #6346 処方の項目が足りない 王永吉 start
    if (sheet.getRow(rowIndex) == null) {
      sheet.createRow(rowIndex);
    }
    // add #6346 処方の項目が足りない 王永吉 end
    return Optional.ofNullable(sheet.getRow(rowIndex))
      // mod #6416 PDF出力ファイルとexcel出力ファイルと表示内容が異なる 歴 start
      //.map(row -> row.getCell(columnIndex))
      .map(row -> row.getCell(columnIndex) == null ? row.createCell(columnIndex) : row.getCell(columnIndex))
      // mod #6416 PDF出力ファイルとexcel出力ファイルと表示内容が異なる 歴 end
      .orElse(null);
  }

  /**
   * POIセルオブジェクトの取得(セル範囲の左上).
   *
   * @param sheet ワークシート
   * @param position セル参照文字列(R1C1形式)
   * @return POIセルオブジェクト
   */
  public static Cell getFirstCell(Sheet sheet, String position) {
    return Optional.ofNullable(getCellRange(sheet, position))
      .map(range -> getCell(sheet, range.getFirstRow(), range.getFirstColumn()))
      .orElse(null);
  }

  /**
   * セル参照文字列で指定されたセルのデータ型を取得.
   *
   * @param params Param要素情報
   * @param position セル参照文字列 ( 例：A1、1#A1:B10-1.B1-1 のような文字列を想定 )
   * @return データタイプ
   */
  public static String getDataType(List<ReportXmlParam> params, String position) {
    String dataType = ReportXmlParam.DATA_TYPE_STRING;
    String[] positionList = position.split("\\.");
    String tmpCellId = "";

    if (positionList.length > 1) {
      // 2分割の場合は、後半の文字列を使用
      String[] strList = positionList[1].split("-");
      tmpCellId = strList[0];
    } else if (positionList.length == 1) {
      // 分割なしの場合
      Pattern positionSplitter = Pattern.compile("^\\d*#*([a-zA-Z]+\\d+\\:*[a-zA-Z]*\\d*)\\-*\\d*");
      Matcher m = positionSplitter.matcher(positionList[0]);
      if (m.matches()) {
        tmpCellId = m.group(1);
      }
    }

    if (!StringUtils.isEmpty(tmpCellId)) {
      // セルをキーにパラメータから対象の dataType を取得
      final String cellId = tmpCellId;
      Optional<ReportXmlParam> param = params.stream().filter(p -> p.getId().equals(cellId)).findFirst();
      if (param.isPresent()) {
        dataType = param.get().getDataType();
      }
    }

    return dataType;
  }

  /**
   * セル参照文字列で指定されたセルのパラメータを取得.
   *
   * @param params Param要素情報
   * @param position セル参照文字列 ( 例：A1、1#A1:B10-1.B1-1 のような文字列を想定 )
   * @return パラメータオブジェクト
   */
  public static ReportXmlParam getTargetParam(List<ReportXmlParam> params, String position) {

    ReportXmlParam resultParam = null;
    String[] positionList = position.split("\\.");
    String tmpCellId = "";

    if (positionList.length > 1) {
      // 2分割の場合は、後半の文字列を使用
      String[] strList = positionList[1].split("-");
      tmpCellId = strList[0];
    } else if (positionList.length == 1) {
      // 分割なしの場合
      Pattern positionSplitter = Pattern.compile("^\\d*#*([a-zA-Z]+\\d+\\:*[a-zA-Z]*\\d*)\\-*\\d*");
      Matcher m = positionSplitter.matcher(positionList[0]);
      if (m.matches()) {
        tmpCellId = m.group(1);
      }
    }

    if (!StringUtils.isEmpty(tmpCellId)) {
      // セルをキーにパラメータから対象の dataType を取得
      final String cellId = tmpCellId;
      Optional<ReportXmlParam> param = params.stream().filter(p -> p.getId().equals(cellId)).findFirst();
      if (param.isPresent()) {
        resultParam = param.get();
      }
    }

    return resultParam;
  }

  /**
   * セルの関数計算結果を取得.
   * @param sheet ワークシート
   * @param evaluator FormulaEvaluator
   * @param position セル参照文字列(R1C1形式)
   * @return 計算結果
   */
  public static Object getFormulaResultValue(Sheet sheet, FormulaEvaluator evaluator, String position) {
    Cell targetCell = getFirstCell(sheet, position);
    CellValue value = evaluator.evaluate(targetCell);

    switch (value.getCellType()) {
    case STRING:
      return value.getStringValue();
    case NUMERIC:
      return value.getNumberValue();
    case BOOLEAN:
      return value.getBooleanValue();
// add 2021-07-27 #5814:フリー計算したexcelセルの背景色に赤色をつけてしまう。色付けないように修正してください。 孫 start
    case ERROR:
      return DISPLAY_HTML_ERROR;
// add 2021-07-27 #5814:フリー計算したexcelセルの背景色に赤色をつけてしまう。色付けないように修正してください。 孫 end
    default:
      break;
    }

    return "";
  }

  /**
   * POIセルオブジェクトの取得(セル範囲の左上).
   *
   * @param sheet ワークシート
   * @param position セル参照文字列(R1C1形式)
   * @param isDirectionX X方向に繰り返す場合、<code>true</code>、Y方向に繰り返す場合、<code>false</code>
   * @param tmplOffset テンプレート繰り返しの移動量
   * @return POIセルオブジェクト
   */
  // mod 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 start
  //public static Cell getFirstCell(Sheet sheet, String position, boolean isDirectionX, int tmplOffset) {
  public static Cell getFirstCell(Sheet sheet, String position, boolean isDirectionX, int tmplOffset, int tmplOffsetCol, Optional<ReportXmlTmplRepeat> tmplRepeat) {
  // mod 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 end
    Matcher m = positionRegexTmpl.matcher(position);
    if (!m.matches()) {
      return null;
    }
    CellRangeAddress range = Optional.ofNullable(getCellRange(sheet, m.group(3))).orElse(null);
    if (range == null) {
      return null;
    }

    // del 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 start
    //int offset = (Integer.valueOf(m.group(2)) - 1) * tmplOffset;
    // del 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 end

    // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 start
    int cols,rows,offset,offset1 = 0;
    int repeatCountH = tmplRepeat.get().getRepeatCountH();
    int repeatCountV = tmplRepeat.get().getRepeatCountV();
    int marginV = tmplRepeat.get().getMarginV();
    int marginH = tmplRepeat.get().getMarginH();

    if (isDirectionX) {
      if((Integer.valueOf(m.group(2))%repeatCountH) == 0){
        cols = repeatCountH*(Integer.valueOf(m.group(2))/repeatCountH)-(repeatCountH-1);
        rows = (Integer.valueOf(m.group(2))/repeatCountH) -1;
      }else{
        cols = repeatCountH*(Integer.valueOf(m.group(2))/repeatCountH)+1;
        rows = (Integer.valueOf(m.group(2))/repeatCountH);
      }
      offset = (Integer.valueOf(m.group(2)) - cols) * tmplOffset + (Integer.valueOf(m.group(2)) - cols) * marginH;
      offset1 =  rows * tmplOffsetCol + rows * marginV;
    }else{
      if((Integer.valueOf(m.group(2))%repeatCountV) == 0){
        cols = repeatCountV*(Integer.valueOf(m.group(2))/repeatCountV)-(repeatCountV-1);
        rows = (Integer.valueOf(m.group(2))/repeatCountV) -1;
      }else{
        cols = repeatCountV*(Integer.valueOf(m.group(2))/repeatCountV)+1;
        rows = (Integer.valueOf(m.group(2))/repeatCountV);
      }
      offset = (Integer.valueOf(m.group(2)) - cols) * tmplOffsetCol + (Integer.valueOf(m.group(2)) - cols) * marginV;
      offset1 =  rows * tmplOffset + rows * marginH;
    }
    // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 end
    //add 【帳票T】機能帳票「予定」画面配布リスト(ベッド)プレビューブランクボード liuc start
    if(offset < 0 ) offset = 0;
    if(offset1 < 0 ) offset1 = 0;
    //add 【帳票T】機能帳票「予定」画面配布リスト(ベッド)プレビューブランクボード liuc end
    if (isDirectionX) {
      range.setFirstColumn(range.getFirstColumn() + offset);
      range.setLastColumn(range.getLastColumn() + offset);
      // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 start
      range.setFirstRow(range.getFirstRow() + offset1);
      range.setLastRow(range.getLastRow() + offset1);
      // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 end
    } else {
      // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 start
      range.setFirstColumn(range.getFirstColumn() + offset1);
      range.setLastColumn(range.getLastColumn() + offset1);
      // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 end
      range.setFirstRow(range.getFirstRow() + offset);
      range.setLastRow(range.getLastRow() + offset);
    }

    return getCell(sheet, range.getFirstRow(), range.getFirstColumn());
  }

  /**
   * テンプレート繰り返しの移動量を取得します.
   *
   * @param position セル参照文字列
   * @param isDirectionX X方向に繰り返す場合、<code>true</code>、Y方向に繰り返す場合、<code>false</code>
   * @return テンプレート繰り返しの移動量
   */
  public static int getTmplOffset(String position, boolean isDirectionX) {
    CellRangeAddress cellRange = CellRangeAddress.valueOf(position);
    if (isDirectionX) {
      return cellRange.getLastColumn() - cellRange.getFirstColumn() + 1;
    } else {
      return cellRange.getLastRow() - cellRange.getFirstRow() + 1;
    }
  }

  /**
   * 帳票定義XmlからParam要素を取得します.
   *
   * @param reportXml 帳票定義Xml
   * @return Param要素情報
   */
  public static List<ReportXmlParam> getParamElements(String reportXml) {

    LogServiceImpl logService = new LogServiceImpl();
    try (InputStream inputStream = new ByteArrayInputStream(reportXml.getBytes(StandardCharsets.UTF_8))) {

      // 帳票定義Xmlをパース
      org.w3c.dom.Document document = getDomDocument(inputStream);

      // group要素を取得する
      Map<String, ReportXmlGroup> groups = new HashMap<>();
      NodeList nodeGroups = document.getElementsByTagName("group");
      for (Integer i = 0; i < nodeGroups.getLength(); i++) {
        Element element = (Element) nodeGroups.item(i);

        // filter要素を取得する
        List<ReportXmlFilter> filters = new ArrayList<>();
        NodeList nodeFilters = element.getElementsByTagName("filter");
        for (Integer j = 0; j < nodeFilters.getLength(); j++) {
          Element filterElement = (Element) nodeFilters.item(j);
          // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする sunsy start
//          filters.add(new ReportXmlFilter(filterElement.getAttribute("item"), filterElement.getAttribute("col")));
          filters.add(new ReportXmlFilter(filterElement.getAttribute("item"), filterElement.getAttribute("col"), filterElement.getAttribute("code")));
          // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする sunsy end
        }

        groups.put(
          element.getAttribute("id"),
          new ReportXmlGroup(
            element.getAttribute("id"),
            Integer.valueOf(element.getAttribute("repeatMax")),
            Integer.valueOf(element.getAttribute("isNewPage")),
            element.getAttribute("filterType"),
            filters
          )
        );
      }

      // tmplRepeat要素を取得する
      ReportXmlTmplRepeat repeat = null;
      NodeList nodeTmplRepeats = document.getElementsByTagName("tmplRepeat");
      if (nodeTmplRepeats.getLength() == 1) {
        Element element = (Element) nodeTmplRepeats.item(0);
        // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 start
        String repeatCountH = element.getAttribute("repeatCountH");
        String repeatCountV = element.getAttribute("repeatCountV");
        String marginV = element.getAttribute("marginV");
        String marginH = element.getAttribute("marginH");
        // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 end
        String repeatMax = element.getAttribute("repeatMax");
        String isNewPage = element.getAttribute("isNewPage");
        String sqlCd = element.getAttribute("baseSqlCd");
        String joinSqlCd = element.getAttribute("joinSqlCd");
        repeat = new ReportXmlTmplRepeat(
          element.getAttribute("id"),
          // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 start
          Integer.valueOf(StringUtils.isEmpty(repeatCountH) ? "0" : repeatCountH),
          Integer.valueOf(StringUtils.isEmpty(repeatCountV) ? "0" : repeatCountV),
          Integer.valueOf(StringUtils.isEmpty(marginV) ? "0" : marginV),
          Integer.valueOf(StringUtils.isEmpty(marginH) ? "0" : marginH),
          // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 end
          Integer.valueOf(StringUtils.isEmpty(repeatMax) ? "0" : repeatMax),
          element.getAttribute("repeatMode"),
          element.getAttribute("key"),
          Integer.valueOf(StringUtils.isEmpty(isNewPage) ? "0" : isNewPage),
          element.getAttribute("direction"),
          StringUtils.isEmpty(sqlCd) ? 0 : Integer.valueOf(sqlCd),
          StringUtils.isEmpty(joinSqlCd) ? 0 : Integer.valueOf(joinSqlCd)
        );
      }

      // add FNSI-523 2次元帳票対応 夏 start
      ReportXmlTotalTable total = null;
      NodeList nodeTotalTable = document.getElementsByTagName("totalTable");
      if (nodeTotalTable.getLength() == 1) {
        Element element = (Element) nodeTotalTable.item(0);
        String unitV = element.getAttribute("unitV");
        String unitDate = element.getAttribute("unitDate");
        String unitH = element.getAttribute("unitH");
        // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
        String effectDataV = element.getAttribute("effectDataV");
        // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
        // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
        String effectDataH = element.getAttribute("effectDataH");
        // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end
        String contents = element.getAttribute("contents");
        // add #11973 日常点検一覧帳票が正常に出せない limingzhe start
        String contentsType = element.getAttribute("contentsType");
        // add #11973 日常点検一覧帳票が正常に出せない limingzhe end
        String conversion = element.getAttribute("conversion");
        String countH = element.getAttribute("countH");
        String countV = element.getAttribute("countV");
        String originRange = element.getAttribute("originRange");
        // add 11011 集計内訳タブ仕様変更 高 start
        String unitVAddress = element.getAttribute("unitVAddress");
        String unitHAddress = element.getAttribute("unitHAddress");
        // add 11011 集計内訳タブ仕様変更 高 end
        total = new ReportXmlTotalTable(
          unitV,
          unitDate,
          unitH,
          // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
          effectDataV,
          // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
          // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
          effectDataH,
          // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end
          contents,
          // add #11973 日常点検一覧帳票が正常に出せない limingzhe start
          contentsType,
          // add #11973 日常点検一覧帳票が正常に出せない limingzhe end
          conversion,
          countH,
          countV,
          originRange,
          // add 11011 集計内訳タブ仕様変更 高 start
          unitVAddress,
          unitHAddress
          // add 11011 集計内訳タブ仕様変更 高 end
        );
      }
      // add FNSI-523 2次元帳票対応 夏 end

      List<ReportXmlParam> params = new ArrayList<>();

      // param要素を取得する
      NodeList param = document.getElementsByTagName("param");
      for (Integer i = 0; i < param.getLength(); i++) {
        Element element = (Element) param.item(i);

        // group要素を取得する
        String groupId = element.getAttribute("groupID");
        ReportXmlGroup group = groups.get(groupId);

        // function要素を取得する
        String function = null;
        NodeList functions = element.getElementsByTagName("function");
        if (functions.getLength() > 0) {
          function = ((Element)functions.item(0)).getAttribute("name");
        }

        // targetCell要素を取得する
        String targetCell = null;
        NodeList targetCells = element.getElementsByTagName("targetCell");
        if (targetCells.getLength() > 0) {
          targetCell = ((Element)targetCells.item(0)).getAttribute("ids");
        }

        // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
        List<ReportXmlFilterTable> reportXmlFilters = new ArrayList<>();
        // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end
        // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
        List<ReportXmlFilter> reportXmlFiltersForMainte = new ArrayList<>();
        // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
        List<ReportXmlConv> reportXmlConvs = new ArrayList<>();
        List<ReportXmlFormatCondition> reportXmlFormatConditions = new ArrayList<>();
        Map<String, ReportXmlClassificationDataCode> classificationDataCodes = new HashMap<>();
        ReportXmlParam reportXmlParam = ReportXmlParam.of(
		// add 2021-08-30 6009画像 李 start
          element.getAttribute("isImage"),
		// add 2021-08-30 6009画像 李 end
          // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正　②患者情報の表示のずれが発生　③空白画面の出力問題  吉 start
          element.getAttribute("repeatAddress"),
          // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正　②患者情報の表示のずれが発生　③空白画面の出力問題  吉 end
          element.getAttribute("id"),
          element.getAttribute("dispType"),
          element.getAttribute("dataCode"),
          element.getAttribute("sqlCode"),
          element.getAttribute("dataType"),
          element.getAttribute("isShrink"),
          element.getAttribute("dispLength"),
          // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
          element.getAttribute("filterType"),
          // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end
          element.getAttribute("dispFormat"),
          element.getAttribute("formula"),
          groupId,
          element.getAttribute("isInTmpl"),
          element.getAttribute("isNewPage"),
          element.getAttribute("colWidth"),
          // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
          element.getAttribute("rowHeight"),
          // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
          // add #11276 キー日付に対するデータ引き当て仕様対応 高　start
          element.getAttribute("dataPath"),
          // add #11276 キー日付に対するデータ引き当て仕様対応 高　end
          // add 9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について jiang start
          element.getAttribute("rowCount"),
          // add 9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について jiang end
          // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
          reportXmlFilters,
          // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end
          // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
          reportXmlFiltersForMainte,
          // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
          reportXmlConvs,
          group,
          reportXmlFormatConditions,
          function,
          targetCell,
          repeat,
          // add FNSI-523 2次元帳票対応 夏 start
          total,
          // add FNSI-523 2次元帳票対応 夏 end
          element.getAttribute("particular"),
          classificationDataCodes,
          // add #11535 帳票の汎用バーコード出力対応 吉 start
          element.getAttribute("barCode")
          // add #11535 帳票の汎用バーコード出力対応 吉 end
        );

        // conv要素を取得する
        NodeList convs = element.getElementsByTagName("conv");
        for (Integer x = 0; x < convs.getLength(); x++) {
          Element convElement = (Element) convs.item(x);
          ReportXmlConv conv = new ReportXmlConv(
            convElement.getAttribute("code"),
            convElement.getAttribute("item"),
            convElement.getAttribute("disp")
          );
          reportXmlConvs.add(conv);
        }

        // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
        // filterTable要素を取得する
        NodeList filters = element.getElementsByTagName("filter");
        for (Integer x = 0; x < filters.getLength(); x++) {
          Element filterTableElement = (Element) filters.item(x);
          // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
          if(filterTableElement.getAttribute("col").length() != 0){
            ReportXmlFilter filter = new ReportXmlFilter(
              filterTableElement.getAttribute("item"),
              filterTableElement.getAttribute("col"),
              filterTableElement.getAttribute("code")
            );
            reportXmlFiltersForMainte.add(filter);
          }
          else {
          // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
            ReportXmlFilterTable filter = new ReportXmlFilterTable(
              filterTableElement.getAttribute("code"),
              filterTableElement.getAttribute("before"),
              filterTableElement.getAttribute("after"),
              filterTableElement.getAttribute("other")
            );
            reportXmlFilters.add(filter);
          // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
          }
          // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
        }
        // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end

        // formatCondition要素を取得する
        NodeList formatConditions = element.getElementsByTagName("formatCondition");
        for (Integer x = 0; x < formatConditions.getLength(); x++) {
          Element formatConditionElement = (Element) formatConditions.item(x);
          ReportXmlFormatCondition formatCondition = new ReportXmlFormatCondition(
            formatConditionElement.getAttribute("comparisonOperator"),
            formatConditionElement.getAttribute("value"),
            formatConditionElement.getTextContent().trim()
          );
          reportXmlFormatConditions.add(formatCondition);
        }

        // dataCode(分類別DataCode)要素を取得する
        NodeList dataCodes = element.getElementsByTagName("classificationData");
        for (int x = 0; x < dataCodes.getLength(); x++) {
          Element dataCodeElement = (Element) dataCodes.item(x);

          NodeList elementsByTagName;

          // dataCode要素
          String dataCodeString = null;
          elementsByTagName = dataCodeElement.getElementsByTagName("dataCode");
          if(elementsByTagName.getLength() > 0)
          {
            dataCodeString = elementsByTagName.item(0).getTextContent().trim();
          }

          // fixString要素.固定文字列
          String fixString = null;
          elementsByTagName = dataCodeElement.getElementsByTagName("fixString");
          if(elementsByTagName.getLength() > 0)
          {
            fixString = elementsByTagName.item(0).getTextContent().trim();
          }

          ReportXmlClassificationDataCode dataCode = new ReportXmlClassificationDataCode(dataCodeString, fixString);

          classificationDataCodes.put(dataCodeElement.getAttribute("classNo"), dataCode);

        }

        params.add(reportXmlParam);
      }

      return params;

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("report xml parse param failed.");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(e);
    }
  }

  /**
   * @param inputStream InputStream
   * @return InputStreamの構文解析結果のDocument
   * @throws ParserConfigurationException
   * @throws SAXException 構文解析エラーが発生した場合。
   * @throws IOException 入出力エラーが発生した場合。
   */
  public static org.w3c.dom.Document getDomDocument(InputStream inputStream)
      throws ParserConfigurationException, SAXException, IOException {
    DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
    DocumentBuilder documentBuilder = documentBuilderFactory.newDocumentBuilder();
    org.w3c.dom.Document document = documentBuilder.parse(inputStream);
    return document;
  }

  /**
   * 縮小表示用のタグを追加します.
   *
   * @param element 縮小対象のElement情報
   * @param scale 縮小率
   * @param translate 位置
   */
  public static void appendTagFontSizeScale(org.jsoup.nodes.Element element, String scale, String translate) {
    String style = String.format("transform: scale(%1$s) translate(%2$spx); -webkit-transform: scale(%1$s) translate(%2$spx);", scale, translate);
    String tag = String.format("<div style=\"%s\">%s</div>", style, element.text());
    element.text("");
    element.append(tag);
  }

  // add #6346 処方の項目が足りない 王永吉 start
//  public static Cell getFirstCellSyohou(Sheet sheet, String position, boolean isDirectionX, int tmplOffset, int tmplOffsetCol, Optional<ReportXmlTmplRepeat> tmplRepeat, int doIntSize) {
  // mod Aspose.cells関連問題二回目対応 鄭爽 start
//  public static Cell getFirstCellSyohou(Sheet sheet, String position, boolean isDirectionX, int tmplOffset, int tmplOffsetCol,
//                                        Optional<ReportXmlTmplRepeat> tmplRepeat, int doIntSize, int groupCount) {
//    Matcher m = positionRegexTmplSyohou.matcher(position);
//    if (!m.matches()) {
//      return null;
//    }
//    CellRangeAddress range = Optional.ofNullable(getCellRange(sheet, m.group(4))).orElse(null);
//    if (range == null) {
//      return null;
//    }
//    int cols,rows,offset,offset1 = 0;
//    int repeatCountH = tmplRepeat.get().getRepeatCountH();
//    int repeatCountV = tmplRepeat.get().getRepeatCountV();
//    int marginV = tmplRepeat.get().getMarginV();
//    int marginH = tmplRepeat.get().getMarginH();
//    if (Integer.valueOf(m.group(3)) > 10){
//      if (repeatCountH < repeatCountV && repeatCountV == 10) {
//        if ((Integer.valueOf(m.group(3)) % doIntSize) == 0) {
//          cols = doIntSize * (Integer.valueOf(m.group(3)) / doIntSize) - (doIntSize - 1);
//          rows = (Integer.valueOf(m.group(3)) / doIntSize) - 1;
//        } else {
//          cols = doIntSize * (Integer.valueOf(m.group(3)) / doIntSize) + 1;
//          rows = (Integer.valueOf(m.group(3)) / doIntSize);
//        }
//        if (isDirectionX) {
//          offset = (Integer.valueOf(m.group(3)) - cols) * tmplOffset + (Integer.valueOf(m.group(3)) - cols) * marginH;
//          offset1 =  rows * tmplOffsetCol + rows * marginV;
//        } else {
//          offset = (Integer.valueOf(m.group(3)) - cols) * tmplOffsetCol + (Integer.valueOf(m.group(3)) - cols) * marginV;
//          offset1 = rows * tmplOffset + rows * marginH;
//        }
//      } else {
//        if ((Integer.valueOf(m.group(3)) % repeatCountV) == 0) {
//          cols = Integer.valueOf(m.group(3));
//          rows = Integer.valueOf(m.group(3)) - 1;
//        } else {
//          cols = doIntSize * (Integer.valueOf(m.group(3)) / doIntSize) + 1;
//          rows = (Integer.valueOf(m.group(3)) / doIntSize);
//        }
//        if (isDirectionX) {
//          offset = (Integer.valueOf(m.group(3)) - cols) * tmplOffset + (Integer.valueOf(m.group(3)) - cols) * marginH;
//          offset1 =  rows * tmplOffsetCol + rows * marginV;
//        } else {
//          offset = (Integer.valueOf(m.group(3)) - cols) * tmplOffsetCol + (Integer.valueOf(m.group(3)) - cols) * marginV;
//          offset1 = rows * tmplOffset + rows * marginH;
//        }
//      }
//
//    } else {
//      if (isDirectionX) {
//        if((Integer.valueOf(m.group(3))%repeatCountH) == 0){
//          cols = repeatCountH*(Integer.valueOf(m.group(3))/repeatCountH)-(repeatCountH-1);
//          rows = (Integer.valueOf(m.group(3))/repeatCountH) -1;
//        }else{
//          cols = repeatCountH*(Integer.valueOf(m.group(3))/repeatCountH)+1;
//          rows = (Integer.valueOf(m.group(3))/repeatCountH);
//        }
//        offset = (Integer.valueOf(m.group(3)) - cols) * tmplOffset + (Integer.valueOf(m.group(3)) - cols) * marginH;
//        offset1 =  rows * tmplOffsetCol + rows * marginV;
//      }else{
//        if((Integer.valueOf(m.group(3))%repeatCountV) == 0){
//          cols = repeatCountV*(Integer.valueOf(m.group(3))/repeatCountV)-(repeatCountV-1);
//          rows = (Integer.valueOf(m.group(3))/repeatCountV) -1;
//        }else{
//          cols = repeatCountV*(Integer.valueOf(m.group(3))/repeatCountV)+1;
//          rows = (Integer.valueOf(m.group(3))/repeatCountV);
//        }
//        offset = (Integer.valueOf(m.group(3)) - cols) * tmplOffsetCol + (Integer.valueOf(m.group(3)) - cols) * marginV;
//        offset1 =  rows * tmplOffset + rows * marginH;
//      }
//    }
//    int doGroupCount = 0;
//    if (groupCount > 1){
//      doGroupCount = groupCount - 1;
//    }
//
//    if (isDirectionX) {
//      range.setFirstColumn(range.getFirstColumn() + offset);
//      range.setLastColumn(range.getLastColumn() + offset);
//      range.setFirstRow(range.getFirstRow() + offset1);
//      range.setLastRow(range.getLastRow() + offset1);
//    } else {
//      range.setFirstColumn(range.getFirstColumn() + offset1);
//      range.setLastColumn(range.getLastColumn() + offset1);
//      range.setFirstRow(range.getFirstRow() + offset + doGroupCount);
//      range.setLastRow(range.getLastRow() + offset + doGroupCount);
//    }
//    return getCell(sheet, range.getFirstRow(), range.getFirstColumn());
//  }
  /**
   * POIセルオブジェクトの取得(セル範囲の左上).
   *
   * @param sheet ワークシート
   * @param position セル参照文字列(R1C1形式)
   * @param tmplRepeat テンプレート繰り返し
   * @return POIセルオブジェクト
   */
  public static Cell getFirstCellSyohou(Sheet sheet, String position, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    Matcher m = positionRegexTmplSyohou.matcher(position);
    if (!m.matches()) {
      return null;
    }
    CellRangeAddress range = Optional.ofNullable(getCellRange(sheet, m.group(4))).orElse(null);
    if (range == null) {
      return null;
    }
    int cols = 0;
    int rows = 0;
    // 繰返回数(横)
    int repeatCountH = tmplRepeat.get().getRepeatCountH();
    // 繰返回数(縦)
    int repeatCountV = tmplRepeat.get().getRepeatCountV();

    // セルの繰返回数
    int tmplInRepeatNum = 0;
    if (!StringUtils.isEmpty(m.group(5))) {
      tmplInRepeatNum = Integer.valueOf(m.group(5));
    }
    // セルの繰返回数がテンプレートの最大繰返回数以下、セルの繰返回数>0の場合
    if (tmplInRepeatNum <= tmplRepeat.get().getRepeatMax() && tmplInRepeatNum > 0) {
      // 繰返回数(横)が1の場合
      if (repeatCountH == 1) {
        rows = tmplInRepeatNum - 1;
        cols =  0;
        // 繰返回数(縦)が1の場合
      }else if (repeatCountV == 1) {
        rows = 0;
        cols = tmplInRepeatNum - 1;
      }
    }
    // first Column
    range.setFirstColumn(range.getFirstColumn() + cols);
    // last Column
    range.setLastColumn(range.getLastColumn() + cols);
    // first Row
    range.setFirstRow(range.getFirstRow() + rows);
    // last Row
    range.setLastRow(range.getLastRow() + rows);
    // POIセルオブジェクトの取得
    return getCell(sheet, range.getFirstRow(), range.getFirstColumn());
  }
  // mod Aspose.cells関連問題二回目対応 鄭爽 end
  // add #6346 処方の項目が足りない 王永吉 end
  // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
  public static Cell getFirstCellOnePat(Sheet sheet, String position, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    Matcher m = positionRegexTmplSyohou.matcher(position);
    if (!m.matches()) {
      return null;
    }
    CellRangeAddress range = Optional.ofNullable(getCellRange(sheet, m.group(4))).orElse(null);
    if (range == null) {
      return null;
    }
    int cols = 0;
    int rows = 0;
    int repeatCountH = tmplRepeat.get().getRepeatCountH();
    int repeatCountV = tmplRepeat.get().getRepeatCountV();

    // ↓下記修正では、割り当て先のセルが null になってしまう為、表示されないデータが発生します。
    // // add Aspose.cells関連問題8の二回目対応 夏 start
    // if (StringUtils.isEmpty(m.group(5))){
    //   return null;
    // }
    // // add Aspose.cells関連問題8の二回目対応 夏 end

    int tmplInRepeatNum = 0;
    if (!StringUtils.isEmpty(m.group(5))) {
      tmplInRepeatNum = Integer.valueOf(m.group(5));
    }
    if (tmplInRepeatNum > tmplRepeat.get().getRepeatMax()){

    } else if (tmplInRepeatNum > 0) {
      if (repeatCountH == 1) {
        rows = tmplInRepeatNum - 1;
        cols =  0;
      }else if (repeatCountV == 1) {
        rows = 0;
        cols = tmplInRepeatNum - 1;
      }
    }

    range.setFirstColumn(range.getFirstColumn() + cols);
    range.setLastColumn(range.getLastColumn() + cols);
    range.setFirstRow(range.getFirstRow() + rows);
    range.setLastRow(range.getLastRow() + rows);

    return getCell(sheet, range.getFirstRow(), range.getFirstColumn());
  }
  // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
  // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
  public static Cell getCellForOnePatient(Sheet sheet, String position, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    Matcher m = positionRegexTmplSyohou.matcher(position);
    if (!m.matches()) {
      return null;
    }
    CellRangeAddress range = Optional.ofNullable(getCellRange(sheet, m.group(4))).orElse(null);
    if (range == null) {
      return null;
    }
    int cols = 0;
    int rows = 0;
    int repeatCountH = tmplRepeat.get().getRepeatCountH();
    int repeatCountV = tmplRepeat.get().getRepeatCountV();

    if (repeatCountH == 1) {
      rows = Integer.valueOf(m.group(5)) - 1;
      cols =  0;
    }else if (repeatCountV == 1) {
      rows = 0;
      cols = Integer.valueOf(m.group(5)) - 1;
    }

    range.setFirstColumn(range.getFirstColumn() + cols);
    range.setLastColumn(range.getLastColumn() + cols);
    range.setFirstRow(range.getFirstRow() + rows);
    range.setLastRow(range.getLastRow() + rows);

    return getCell(sheet, range.getFirstRow(), range.getFirstColumn());
  }
  // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end

  // add Aspose.cells関連問題対応 商 start
  /**
   * POIセルオブジェクトの取得(セル範囲の左上).
   *
   * @param sheet ワークシート
   * @param position セル参照文字列(R1C1形式)
   * @return POIセルオブジェクト
   */
  public static Cell getFirstCellForOneTotal(Sheet sheet, String position) {
    return Optional.ofNullable(getCellRangeForOneTotal(sheet, position))
      .map(range -> getCell(sheet, range.getFirstRow(), range.getFirstColumn()))
      .orElse(null);
  }

  /**
   * POIセル範囲の取得.
   *
   * @param sheet ワークシート
   * @param position セル参照文字列(R1C1形式)
   * @return セル範囲
   */
  public static CellRangeAddress getCellRangeForOneTotal(Sheet sheet, String position) {
    Matcher m = positionRegex.matcher(position);
    if (!m.matches()) {
      return null;
    }

    CellRangeAddress cellRange = CellRangeAddress.valueOf(m.group(1));
    if (!StringUtils.isEmpty(m.group(2))) {
      // "-[0-9]"が末尾についていたら、行位置のオフセットとみなす
      int offset = Integer.valueOf(m.group(2)) - 1;
      cellRange = moveRangeForOneTotal(sheet, cellRange, offset);
    }
    return cellRange;
  }

  /**
   * POIセル範囲の移動.
   *
   * @param sheet ワークシート
   * @param base ベースセル範囲
   * @param offset Y方向の移動量
   * @return 移動後のセル範囲
   */
  private static CellRangeAddress moveRangeForOneTotal(Sheet sheet, CellRangeAddress base, int offset) {
    // セル結合されている場合を考慮する
    for (int i = 0; i < offset; i++) {
      int delta = 0;
      CellRangeAddress cra = sheet.getMergedRegions().stream()
        .filter(e -> e.isInRange(base.getFirstRow(), base.getFirstColumn()))
        .findFirst()
        .orElse(null);
      if (cra != null) {
        delta = cra.getLastColumn() - cra.getFirstColumn();
      }
      base.setFirstColumn(base.getFirstColumn() + delta + 1);
      base.setLastColumn(base.getLastColumn() + delta + 1);
    }

    return base;
  }
  // add Aspose.cells関連問題対応 商 end
  // add #8857 単患者帳票表示不正 姜 start
  /**
   * POIセルの取得.
   *
   * @return
   */
  public static String coordinate(String str, Optional<ReportXmlTmplRepeat> tmplRepeat) {

    String result = "";
    //パージ
    if (str.lastIndexOf(key_1) > -1) {
      result = str.substring(0, str.lastIndexOf(key_1) + 1);
    }
    int addrGroup = 0;
    int addrTemp = 0;
    String group = "";
    if (str.indexOf("-") == str.lastIndexOf("-") ) {
      group = str.substring(str.indexOf(".")+1);
    } else {
      addrTemp = Integer.parseInt(str.substring(str.indexOf("-") + 1,str.lastIndexOf(key_3))) - 1;
      addrGroup = Integer.parseInt(str.substring(str.lastIndexOf("-") + 1)) - 1;
      group = str.substring(str.lastIndexOf(key_3) + 1,str.lastIndexOf("-"));
      String tem1 = str.substring(str.lastIndexOf(key_1) + 1,str.indexOf(key_2));
      String tem2 = str.substring(str.indexOf(key_2) + 1,str.indexOf("-"));
      group = getF(group) + (getNumber(group) + addrGroup);

      group = tranString((trans(getF(tem2)) - trans(getF(tem1)) + 1) * addrTemp + trans(getF(group))) + getNumber(group);
    }

    result = group + "-1";
    return result;
  }

  /**
   * 26進数から10進数に変更する
   *
   * @param str 26進数
   * @return 10進数
   */
  public static int trans(String str) {
    str = str.toUpperCase();
    int count = 0;
    for (int i = str.length() - 1, j = 1; i >= 0; i--, j *= 26) {
      char c = str.charAt(i);
      if (c < key_6 || c > key_7) {
        return 0;
      }
      count += ((int) c - key_6) * j;
    }
    return count + 1;
  }

  /**
   * 10進数から26進数に変更する
   *
   * @param n 10進数
   * @return 26進数
   */
  public static String tranString(int n) {
    String s = "";
    while (n > 0) {
      int m = n % 26;
      s = (char) (m + key_6 - 1) + s;
      n = (n - m) / 26;
    }
    return s;
  }
  public static int getNumber(String str) {
    Scanner in = new Scanner(str);
    String charList = in.nextLine();
    StringBuffer sb = new StringBuffer();

    for (int i = 0; i < charList.length(); i++) {
      if (Character.isDigit(charList.charAt(i))) {
        sb.append(charList.charAt(i));
      }
    }
    return Integer.parseInt(sb.toString());
  }
  public static String getF(String str) {
    Scanner in = new Scanner(str);
    String charList = in.nextLine();
    StringBuffer sb = new StringBuffer();

    for (int i = 0; i < charList.length(); i++) {
      if (!Character.isDigit(charList.charAt(i))) {
        sb.append(charList.charAt(i));
      }
    }
    return sb.toString();
  }
  // add #8857 単患者帳票表示不正 姜 end
}
