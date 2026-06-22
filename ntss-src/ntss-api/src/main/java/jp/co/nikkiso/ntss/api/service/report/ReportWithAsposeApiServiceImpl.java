package jp.co.nikkiso.ntss.api.service.report;

import com.aspose.cells.BackgroundType;
import com.aspose.cells.BorderCollection;
import com.aspose.cells.BorderType;
import com.aspose.cells.Cell;
import com.aspose.cells.CellArea;
import com.aspose.cells.CellValueType;
import com.aspose.cells.Cells;
import com.aspose.cells.CellsUnitType;
import com.aspose.cells.Color;
import com.aspose.cells.Comment;
import com.aspose.cells.License;
import com.aspose.cells.Picture;
import com.aspose.cells.Row;
import com.aspose.cells.RowCollection;
import com.aspose.cells.Style;
import com.aspose.cells.TextAlignmentType;
import com.aspose.cells.VisibilityType;
import com.aspose.cells.Workbook;
import com.aspose.cells.Worksheet;
import com.aspose.cells.WorksheetCollection;
import com.google.zxing.BarcodeFormat;
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlGroup;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlParam;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlTmplRepeat;
import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.api.service.utils.ReportUtils;
import jp.co.nikkiso.ntss.api.service.utils.ReportZipFile;
import jp.co.nikkiso.ntss.api.service.utils.TmpFileService;
import jp.co.nikkiso.ntss.api.utils.AsposeExcelUtil;
import jp.co.nikkiso.ntss.api.utils.CreateQrUtil;
import jp.co.nikkiso.ntss.api.utils.ImageProcessing;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.NtssUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.poi.ss.formula.FormulaParseException;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.BuiltinFormats;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.ss.util.CellReference;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Lazy;
import org.springframework.core.io.ResourceLoader;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import java.awt.Graphics2D;
import java.awt.Font;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.TreeMap;
import java.util.function.Function;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static java.util.stream.Collectors.toList;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Lazy
@Service
public class ReportWithAsposeApiServiceImpl implements ReportWithAsposeApiService {

  /**
   * 帳票出力情報のKey項目に使用する複数ページ区切り文字列.
   */
  private static final String MULTIPLE_PAGES_SEPARATOR = "#";

  /**
   * Excelシート名プレフィックス
   */
  private static final String SHEET_NAME_PREFIX = "ページ";

  /**
   * エラー時に帳票デザインHTMLへ出力する文字列.
   */
  private static final String DISPLAY_HTML_ERROR = "ｴﾗｰ";

  /**
   * 計算式に基づく計算が失敗した場合に設定する文字列.
   */
  private static final String FAILED_CALC = "failed calc";

  /**
   * ラベル用の出力データ数
   */
  private static final String LABEL_OUTPUT_COUNT = "labelOutputCount";

  /**
   * イメージ
   */
  @Value("${ntss.pat-event.s3-bucket:#{null}}")
  private String s3BucketForImage;

  /**
   * 印刷ファイル作成の為の一時保存Path.
   */
  @Value("${ntss.report.createTmpDir}")
  private String createTmpDir;

  /** ロックサービス */
  private final LogService logService;

  /**
   * 帳票マスタDAOインタフェース.
   */
  private final MstReportDao mstReportDao;

  /**
   * 帳票ファイル取得のServiceインタフェース.
   */
  private final ReportS3Service reportS3Service;

  /**
   * 帳票のチャート生成のServiceインタフェース.
   */
  @Autowired
  private ReportChartService reportChartService;

  @Autowired
  private TmpFileService tmpFileService;

  /**
   * インスタンスメソッド
   */
  @Autowired
  public ReportWithAsposeApiServiceImpl(
    MstReportDao mstReportDao
    , LogService logService
    , ReportS3Service reportS3Service
    , @Qualifier("webApplicationContext") ResourceLoader resourceLoader) {
    this.mstReportDao = mstReportDao;
    this.logService = logService;
    this.reportS3Service = reportS3Service;
    try {
      // Initializes & load Aspose License
      URL licUrl = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
      License license = new License();
      license.setLicense(licUrl.openStream());
    } catch (IOException e) {
      // エラーメッセージ
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage("asposeのライセンスを取得する場合、エラーが発生する：" + ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
  }

  /**
   * ラベル帳票作成
   * @param mstReport
   * @param reportZipFile
   * @param params
   * @param reportOutputInfo
   * @param calcResult
   * @param dataKey
   * @return
   */
  public Workbook getReportExcelWorkbookToLabel(
    MstReport mstReport,
    ReportZipFile reportZipFile,
    List<ReportXmlParam> params,
    Map<String, String> reportOutputInfo,
    Map<String, String> calcResult,
    Map<String, Object> dataKey
  ){
    String firstEditSheetName = null;
    Integer stPos = 1;
    if (null != dataKey.get("startPos")) {
      stPos = (Integer) dataKey.get("startPos");
    } else if ((null != dataKey.get("stPos"))) {
      stPos = (Integer) dataKey.get("stPos");
    }
    // asposeでEXCELを取得する。
    Workbook baseWorkbook = this.getReportWorkbook(mstReport, reportZipFile);
    try {
      WorksheetCollection workSheets = baseWorkbook.getWorksheets();
      Worksheet paramSheet = workSheets.get("パラメータ");
      Cells paramCells = paramSheet.getCells();
      RowCollection allRows = paramCells.getRows();

      // Getting grouping parameters cell's index from header row
      int groupNameIndex = 0;
      int repeatAddressIndex = 0;
      int cellAddressIndex = 0;
      // Loop find index
      Row headRow = allRows.get(0);
      for (int i = 0; i < headRow.getLastDataCell().getColumn(); i++) {
        Cell cell = headRow.get(i);
        switch (cell.getStringValue()) {
          case "GroupName" -> groupNameIndex = i;
          case "RepeatAddress" -> repeatAddressIndex = i;
          case "CellAddress" -> cellAddressIndex = i;
          default -> {}
        }
      }
      // Groupプロパティ取得
      Map<String, String> repeatAddressMap = new HashMap<>();
      for (int i = 1; i < allRows.getCount(); i++) {
        Row eachRow = allRows.get(i);
        if (StringUtils.isNotEmpty(eachRow.get(groupNameIndex).getStringValue())) {
          repeatAddressMap.put(
            eachRow.get(cellAddressIndex).getStringValue()
            , eachRow.get(repeatAddressIndex).getStringValue()
          );
        }
      }
      // ページ総数を取得
      int pageCount = getPageCount(reportOutputInfo);
      // del #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
//      // テンプレートの繰り返しを取得する。
//      ReportXmlTmplRepeat reportXmlTmplRepeat = params.get(0).getReportXmlTmplRepeat();
//      // mod #10691 【デグレ】パラメータ改頁設定が機能していない 高 start
//      List<ReportXmlParam> filtered = params.stream()
//        .filter(p -> p.getReportXmlGroup() == null)
//        .filter(p -> {
//          String t = p.getIsInTmpl();
//          return "0".equals(t);
//        })
//        .filter(p -> "1".equals(p.getIsNewPage()))
//        .collect(Collectors.toList());
//      boolean parFlag = reportXmlTmplRepeat.getIsNewPage() == 0 && filtered.size() == 0 ? true : false;
//      if (parFlag) {
////      if (reportXmlTmplRepeat.getIsNewPage() == 0) {
//        // mod #10691 【デグレ】パラメータ改頁設定が機能していない 高 end
//        pageCount = 1;
//      }
      // del #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
      if (reportOutputInfo.size() > 0){
        if (reportOutputInfo.containsKey("SyohouTyouHyou_Num")){
          reportOutputInfo.remove("SyohouTyouHyou_Num");
        }
        if (reportOutputInfo.containsKey("Over")){
          reportOutputInfo.remove("Over");
        }
        reportOutputInfo = sortByKeyB(sortByKeyA(reportOutputInfo));
      }
      // Getting Base WorkSheet
      Worksheet baseSheet = workSheets.get(workSheets.getActiveSheetIndex());
      // 埋め込み先のセル値をクリア
      for(ReportXmlParam reportXmlParam : params) {
        Optional.ofNullable(AsposeExcelUtil.getFirstCellOfPosition(baseSheet, reportXmlParam.getId()))
          .ifPresent(cell -> cell.setValue(null));
      }
      // add #12165 "印刷情報"項目が、ラベル帳票だと出力されない 高 start
      // 全ページ共通のセル値を埋め込む
      Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
        .filter(entry -> !entry.getKey().contains(MULTIPLE_PAGES_SEPARATOR))
        .forEach(
          entry ->  {
            String replaceKey = "";
            String dataType = ReportXmlParam.DATA_TYPE_STRING;
            boolean isImage = false;
            ReportXmlParam targetParam = ReportUtils.getTargetParam(params, entry.getKey());

            // 対象項目の設定を取得
            if (targetParam != null) {
              dataType = targetParam.getDataType();
              isImage = StringUtils.equals("true", targetParam.getIsImage());
            }

            if (!repeatAddressMap.isEmpty()) {
              replaceKey = this.getReplaceKeyForRepeat(entry.getKey(), repeatAddressMap);
            }
            if (StringUtils.isEmpty(replaceKey)) {
              // replace対象がなかった場合、取得に失敗した場合は元のセルに対して処理を実施する
              replaceKey = entry.getKey();
            }
            setCellValue(mstReport, baseSheet, entry, replaceKey, dataType, isImage);
          });
      // add #12165 "印刷情報"項目が、ラベル帳票だと出力されない 高 end
      Optional<ReportXmlTmplRepeat> tmplRepeat = params.stream()
        .filter(p -> p.isTmplRepeat())
        .map(p -> p.getReportXmlTmplRepeat())
        .findFirst();
      // add #11535 帳票の汎用バーコード出力対応 吉 start
      Map<String,String> funcCellMap = new HashMap<>();
      // add #11535 帳票の汎用バーコード出力対応 吉 end
      if (!tmplRepeat.isEmpty()) {
        // 全ページ共通のセル値を埋め込む
        Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
          .filter(e -> e.getKey().indexOf(MULTIPLE_PAGES_SEPARATOR) < 0)
          .forEach(e -> setCellValueByPositionAndType(baseSheet, e.getKey(), e.getValue(), ReportUtils.getDataType(params, e.getKey())));
        String[] idFT = tmplRepeat.get().getId().split(":");
        // tmplRepeatの開始コラム
        int tmplColFrom = 0;
        // tmplRepeatの終了コラム
        int tmplColTo = 0;
        // tmplRepeatのコラム数
        int tmplColCount = 0;
        // tmplRepeatの開始行
        int tmplRowFrom = 0;
        // tmplRepeatの終了行
        int tmplRowTo = 0;
        // tmplRepeatの行数
        int tmplRowCount = 0;
        // 繰返回数(縦)
        String range = tmplRepeat.get().getId();
        String startCell = range.split(":")[0];
        String rowPart = startCell.replaceAll("[A-Za-z]", "");
        int rowIndex = Integer.parseInt(rowPart);
        String colPart = startCell.replaceAll("[0-9]", "");
        int colIndex = 0;
        for (int i = 0; i < colPart.length(); i++) {
          colIndex = colIndex * 26 + (colPart.charAt(i) - 'A' + 1);
        }
        // mod #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy start
//        int repeatCount_V = tmplRepeat.get().getRepeatCountV() + (rowIndex - 1);
//        int repeatCount_H = tmplRepeat.get().getRepeatCountH() + (colIndex - 1);
        int repeatCount_V = tmplRepeat.get().getRepeatCountV();
        int repeatCount_H = tmplRepeat.get().getRepeatCountH();
        // mod #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy end
        int marginV = tmplRepeat.get().getMarginV();
        int marginH = tmplRepeat.get().getMarginH();
        boolean isDirectionX = tmplRepeat.map(p -> ReportXmlTmplRepeat.DIRECTION_Z.equals(p.getDirection())).orElse(false);
        int tmplOffset = tmplRepeat.map(p -> ReportUtils.getTmplOffset(p.getId(), true)).orElse(0);
        int tmplOffsetCol = tmplRepeat.map(p -> ReportUtils.getTmplOffset(p.getId(), false)).orElse(0);
        for (int page = 0; page < pageCount; page++) {
          // mod #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy start
//          if(page+1 == pageCount){
          // 仕様の削除は開始頁と終了頁のみで行う
          if(page+1 == pageCount || page == 0){
          // mod #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy end
            tmplRowFrom = getRowCount(idFT[0]);
            tmplRowTo = getRowCount(idFT[1]);
            tmplRowCount = tmplRowTo - tmplRowFrom + 1;
            tmplColFrom = getColumnCount(idFT[0]);
            tmplColTo = getColumnCount(idFT[1]);
            tmplColCount = tmplColTo - tmplColFrom + 1;
            // コピー元(コラム)
            Cell sourceCell = null;
            Style emptyStyle = baseWorkbook.createStyle();
            // mod #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy start
//            for(int i= tmplRowTo+marginV;i<(tmplRowCount +marginV) * repeatCount_V; i++){
//              for(int j= 0;j<(tmplColCount+marginH) * repeatCount_H; j++){
//                sourceCell = baseSheet.getCells().get(i ,j);
//                clearBorderStyle(sourceCell, emptyStyle);
//              }
//            }
            //テンプレートの下部分に対する仕様削除
            for(int i= tmplRowTo+marginV;i<tmplRowFrom - 1 + (tmplRowCount +marginV) * repeatCount_V; i++){
              for(int j= tmplColFrom - 1;j<tmplColFrom - 1 + (tmplColCount+marginH) * repeatCount_H; j++){
                sourceCell = baseSheet.getCells().get(i ,j);
                clearBorderStyle(sourceCell, emptyStyle);
              }
            }

//            for(int i= 0;i<(tmplRowCount +marginV); i++){
//              for(int j= tmplColCount+marginH;j<(tmplColCount+marginH) * repeatCount_H; j++){
//                sourceCell = baseSheet.getCells().get(i ,j);
//                clearBorderStyle(sourceCell, emptyStyle);
//              }
//            }
            //テンプレートの右部分に対する仕様削除
            for(int i= tmplRowFrom - 1;i<tmplRowFrom - 1 + tmplRowCount + marginV; i++){
              for(int j= tmplColTo + marginH;j<tmplColFrom - 1 + (tmplColCount + marginH) * repeatCount_H; j++){
                sourceCell = baseSheet.getCells().get(i ,j);
                clearBorderStyle(sourceCell, emptyStyle);
              }
            }
            // mod #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy end
          }
          int newSheetIndex = workSheets.addCopy(baseSheet.getIndex());
          Worksheet destSheet = workSheets.get(newSheetIndex);
          destSheet.setName(String.format("%s%d", SHEET_NAME_PREFIX, page + 1));
          if(StringUtils.isEmpty(firstEditSheetName)) {
            firstEditSheetName = String.format("%s%d", SHEET_NAME_PREFIX, page + 1);
          }
          final String pagePrefix = String.format("%d%s", page + 1, MULTIPLE_PAGES_SEPARATOR);
          if (repeatAddressMap.size() > 0) {
            setShrinkToFit(destSheet, repeatAddressMap, params);
          }
          copyFixedValueForLabel(destSheet, tmplRepeat, page, stPos, dataKey);
          Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
            .filter(e -> e.getKey().startsWith(pagePrefix))
            .forEach(e -> {
              final String key = e.getKey().substring(pagePrefix.length());
              String dataType = ReportUtils.getDataType(params, key);
              String replaceKey = null;
              if (tmplRepeat.isPresent() && key.startsWith(tmplRepeat.get().getId())) {
                if (repeatAddressMap.size() > 0) {
                  replaceKey = getReplaceKey(key, repeatAddressMap);
                }
                if (replaceKey != null) {
                  // mod #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy start
//                  setCellValue(destSheet, replaceKey, e.getValue(), isDirectionX, tmplOffset, tmplOffsetCol, dataType, tmplRepeat);
                  setCellValueForLabel(destSheet, replaceKey, e.getValue(), isDirectionX, tmplOffset, tmplOffsetCol, dataType, tmplRepeat);
                  // mod #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy end
                } else {
                  // mod #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy start
//                  setCellValue(destSheet, replaceKey, e.getValue(), isDirectionX, tmplOffset, tmplOffsetCol, dataType, tmplRepeat);
                  // mod #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 start
//                  setCellValueForLabel(destSheet, replaceKey, e.getValue(), isDirectionX, tmplOffset, tmplOffsetCol, dataType, tmplRepeat);
                  setCellValueForLabel(destSheet, key, e.getValue(), isDirectionX, tmplOffset, tmplOffsetCol, dataType, tmplRepeat);
                  // mod #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 end
                  // mod #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy end
                }
              } else {
                if (repeatAddressMap.size() > 0) {
                  replaceKey = getReplaceKeyForRepeat(key, repeatAddressMap);
                }
                if (replaceKey != null) {
                  setCellValueByPositionAndType(destSheet, replaceKey, e.getValue(), dataType);
                } else {
                  setCellValueByPositionAndType(destSheet, key, e.getValue(), dataType);
                }
              }
            });
          // Excel関数を埋め込む
          List <Integer> repCountList = new ArrayList<>();
          // mod #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe start
          Map<String, String> reportOutputInfobyPage = reportOutputInfo.entrySet().stream()
            .filter(entry -> entry.getKey().startsWith(pagePrefix))
            .collect(Collectors.toMap(entry -> entry.getKey(), entry -> entry.getValue()));
          //for (Map.Entry<String, String> entry : reportOutputInfo.entrySet())
          for (Map.Entry<String, String> entry : reportOutputInfobyPage.entrySet())
          // mod #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe end
          {
            String key = entry.getKey();
            if(key.contains(".")){
              String key1 = key.split("\\.")[0];
              int repCount1 = Integer.valueOf(key1.split("-")[1]);
              if(!repCountList.contains(repCount1)){
                repCountList.add(repCount1);
              }
            }
          }
          final List<Integer> lastRepCount = new ArrayList<>(repCountList);
          // mod #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe start
          // バーコード対象セルの場合はマッピングを保持
          funcCellMap.putAll(formulaCalculateForParams(baseWorkbook, destSheet, params, lastRepCount));
          // mod #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe end
          // add #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe start
          if (tmplRepeat.isPresent()) {
            // テンプレート繰返しでの計算式繰返し（「=」で始まる計算式）
            List<String> paramIdInTmpl = params.stream().filter(p -> p.isTmplRepeat()).map(p -> p.getId()).collect(toList());
            formulaCalculateFromTmpl(destSheet, tmplRepeat.get(), paramIdInTmpl, lastRepCount.size());
          }
          // add #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe end
          if(mstReport.getReportClass() == ReportConstant.ReportClass.LABEL_REPORT) {
            copyStyleFromTmpl(destSheet, tmplRepeat, ReportConstant.ReportClass.LABEL_REPORT);
            labelRemoveStartCell(destSheet, tmplRepeat, stPos);
          }
        }
        baseWorkbook.getWorksheets().removeAt(baseSheet.getIndex());
        // activeSheetを設定する
        if(StringUtils.isNotEmpty(firstEditSheetName)) {
          baseWorkbook.getWorksheets().setActiveSheetName(firstEditSheetName);
        }
      }
      // add #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 start
      else {
        boolean isDirectionX = tmplRepeat.map(p -> ReportXmlTmplRepeat.DIRECTION_Z.equals(p.getDirection())).orElse(false);
        int tmplOffset = tmplRepeat.map(p -> ReportUtils.getTmplOffset(p.getId(), true)).orElse(0);
        int tmplOffsetCol = tmplRepeat.map(p -> ReportUtils.getTmplOffset(p.getId(), false)).orElse(0);
        boolean tmplIsNewPage = tmplRepeat.map(p -> ReportXmlTmplRepeat.IS_NEW_PAGE_YES.equals(p.getIsNewPage())).orElse(false);
        List<ReportXmlGroup> groupNewPageList =
          params.stream().filter(p -> p.getReportXmlGroup() != null && p.getReportXmlGroup().getIsNewPage() == 1)
            .map(ReportXmlParam::getReportXmlGroup)
            .collect(toList());

        if (tmplIsNewPage || !groupNewPageList.isEmpty()) {
          pageCount = this.getPageCount(reportOutputInfo);
        }
        // ページごとに異なる項目を埋め込む
        for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
          final String pagePrefix = String.format("%d%s", pageIndex + 1, MULTIPLE_PAGES_SEPARATOR);
          // Copy sheet from baseModelSheet
          try {
            // Create a new sheet
            int newSheetIndex = workSheets.addCopy(baseSheet.getIndex());
            Worksheet destSheet = workSheets.get(newSheetIndex);
            destSheet.setName(String.format("%s%d", SHEET_NAME_PREFIX, pageIndex + 1));
            if(StringUtils.isEmpty(firstEditSheetName)) {
              firstEditSheetName = String.format("%s%d", SHEET_NAME_PREFIX, pageIndex + 1);
            }
            // copy infos from base sheet, including PageSetup(means property print area has been copied too)
            Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
              .filter(entry -> entry.getKey().startsWith(pagePrefix))
              .forEach(entry -> {
                final String key = entry.getKey().substring(pagePrefix.length());
                // 対象項目の設定を取得
                String dataType = ReportXmlParam.DATA_TYPE_STRING;
                boolean isImage = false;
                ReportXmlParam targetParam = ReportUtils.getTargetParam(params, key);
                if (targetParam != null) {
                  dataType = targetParam.getDataType();
                  isImage = StringUtils.equals("true", targetParam.getIsImage());
                }
                String replaceKey = null;
                if (tmplRepeat.isPresent() && key.startsWith(tmplRepeat.get().getId())) {
                  // テンプレート内項目の処理
                  if (!repeatAddressMap.isEmpty()) {
                    // テンプレート内の繰り返し設定がある場合、貼り付けセルを取得
                    replaceKey = this.getReplaceKey(key, repeatAddressMap);
                  }
                  if (StringUtils.isEmpty(replaceKey)) {
                    // 対象がなかった場合、取得に失敗した場合は元のセルに対して処理を実施する
                    replaceKey = key;
                  }
                  // テンプレート繰り返し内でのデータ貼り付けセルを取得
                  if(isImage) {
                    // データが画像の場合
                    String path = entry.getValue();
                    if (StringUtils.isNotEmpty(path)) {
                      // Getting images from S3 service
                      String bucket = String.format(s3BucketForImage, mstReport.getFacilityCd());
                      byte[] excelBytes = reportS3Service.getOutputFileData(bucket, path);
                      CellRangeAddress cellAddresses = AsposeExcelUtil.getCellAddressOfPositionInTmpl(baseSheet, replaceKey, isDirectionX
                        , tmplOffset, tmplOffsetCol, tmplRepeat);
                      try {
                        addPicture(destSheet, cellAddresses, new ByteArrayInputStream(excelBytes));
                      } catch (Exception ex) {
                        // エラーメッセージ
                        EventLogMessage eventLogMessage = new EventLogMessage();
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                        eventLogMessage.setLogMessage("asposeでグラフのINSERTはエラー：" + ExcetionStackTraceToString(ex));
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                      }
                    }
                  }
                  else {
                    Cell targetCell = AsposeExcelUtil.getFirstCellOfPosition(destSheet, replaceKey, isDirectionX
                      , tmplOffset, tmplOffsetCol, tmplRepeat);
                    setCellValueByType(targetCell, entry.getValue(), dataType);
                  }
                }
                else {
                  // テンプレート外項目の処理
                  if (!repeatAddressMap.isEmpty()) {
                    // 繰り返し設定がある場合、貼り付けセルを取得
                    replaceKey = this.getReplaceKeyForRepeat(key, repeatAddressMap);
                  }
                  if (StringUtils.isEmpty(replaceKey)) {
                    // 対象がなかった場合、取得に失敗した場合は元のセルに対して処理を実施する
                    replaceKey = key;
                  }
                  this.setCellValue(mstReport, destSheet, entry, replaceKey, dataType, isImage);
                }
              });
            stdCopyStyleFromCells(destSheet, repeatAddressMap);
            if (tmplRepeat.isPresent()) {
              copyStyleFromTmpl(destSheet, tmplRepeat,ReportConstant.ReportClass.LABEL_REPORT);
            }
            // Excel関数を埋め込む
            List <Integer> repCountList = new LinkedList<>();
            for (Map.Entry<String, String> entry : reportOutputInfo.entrySet()) {
              String key = entry.getKey();
              if (key.contains(".")) {
                String key1 = key.split("\\.")[0];
                int repCount1 = Integer.parseInt(key1.split("-")[1]);
                if(!repCountList.contains(repCount1)){
                  repCountList.add(repCount1);
                }
              }
            }
            final List<Integer> lastRepCount = new ArrayList<>(repCountList);
            // mod #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe start
            // バーコード対象セルの場合はマッピングを保持
            funcCellMap.putAll(formulaCalculateForParams(baseWorkbook, destSheet, params, lastRepCount));
            // mod #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe end
            //qrコード
            Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
              .forEach(entry -> {
                if(entry.getKey().startsWith(pagePrefix)){
                  final String key = entry.getKey().substring(pagePrefix.length());
                  Map<String,String> qrCodeCell =  params.stream()
                    .filter(p -> !StringUtils.isEmpty(p.getDataCode()) && p.getDataCode().equals("qrCode"))
                    .collect(Collectors.toMap(m -> m.getId() , m -> m.getColWidth() + "-" + m.getRowHeight()));
                  if(null != qrCodeCell && qrCodeCell.size()>0){
                    for(Map.Entry<String, String> entry1 : qrCodeCell.entrySet()){
                      if(entry1.getKey().equals(key)){
                        createQRPic(entry1.getValue(),key,destSheet,entry.getValue());
                      }
                    }
                  }
                }else{
                  Map<String,String> qrCodeForNewOne =  params.stream()
                    .filter(p -> !StringUtils.isEmpty(p.getDataCode()) && p.getDataCode().equals("qrCodeForNewOne"))
                    .collect(Collectors.toMap(m -> m.getId() , m -> m.getColWidth() + "-" + m.getRowHeight()));
                  if(null != qrCodeForNewOne && qrCodeForNewOne.size()>0){
                    for(Map.Entry<String, String> entry1 : qrCodeForNewOne.entrySet()){
                      if(entry1.getKey().equals(entry.getKey())){
                        createQRPic(entry1.getValue(),entry.getKey(),destSheet,entry.getValue());
                      }
                    }
                  }
                }
              });
          } catch (Exception e) {
            // エラーメッセージ
            EventLogMessage eventLogMessage = new EventLogMessage();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
            eventLogMessage.setLogMessage("asposeでグラフのINSERTはエラー：" + ExcetionStackTraceToString(e));
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        } // End Loop for pages
        // レイアウトシートを削除
        workSheets.removeAt(baseSheet.getIndex());
        if(StringUtils.isNotEmpty(firstEditSheetName)) {
          workSheets.setActiveSheetName(firstEditSheetName);
        }
      }
      // add #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 end

      // add #11535 帳票の汎用バーコード出力対応 吉 start
      Map<String, String> templInFuncQRInfoList = params.stream()
        .filter(p -> p.getDataCode() != null && !"".equals(p.getBarCode()) && p.isTmplRepeat())
        .collect(Collectors.toMap(
          ReportXmlParam::getId,
          p -> p.getBarCode() + "-" + p.getColWidth() + "-" + p.getRowHeight()
        ));
      Map<String, String> templOutFuncQRInfoList = params.stream()
        .filter(p -> p.getDataCode() != null && !"".equals(p.getBarCode()) && !p.isTmplRepeat())
        .collect(Collectors.toMap(
          ReportXmlParam::getId,
          p -> p.getBarCode() + "-" + p.getColWidth() + "-" + p.getRowHeight()
        ));
      if(templInFuncQRInfoList.size()>0){
        WorksheetCollection worksheets = baseWorkbook.getWorksheets();
        for (int i = 0; i < worksheets.getCount(); i++) {
          Worksheet sheet = worksheets.get(i);
          int visibility = sheet.getVisibilityType();
          //（0 表示 visible）
          if (visibility == VisibilityType.VISIBLE) {
            for(Map.Entry<String, String> entry1 : templInFuncQRInfoList.entrySet()){
              if(null != funcCellMap && funcCellMap.size() > 0){
                for(Map.Entry<String, String> funcEntry : funcCellMap.entrySet()){
                  if(funcEntry.getValue().equals(entry1.getKey())){
                    String cellId = funcEntry.getKey();
                    Cell cell = AsposeExcelUtil.getFirstCellOfPosition(sheet, cellId);
                    String valueToBarCode = String.valueOf(cell.getValue());
                    if(StringUtils.isEmpty(valueToBarCode) || StringUtils.isEmpty(valueToBarCode.strip()) || "null".equals(valueToBarCode)){
                      continue;
                    }
                    String[] arr = entry1.getValue().split("-");
                    try {
                      CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(sheet, cellId);
                      int firstRow = cellRange.getFirstRow();
                      int firstCol = cellRange.getFirstColumn();
                      Cell targetCell = sheet.getCells().get(firstRow, firstCol);
                      Style style = targetCell.getStyle();
                      int rotation = style.getRotationAngle();
                      BufferedImage qrCodeImage;
                      if(rotation == 90){
                        qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[2]) * 1.3333),(int)(Integer.valueOf(arr[1]) * 1.3333));
                        qrCodeImage = rotateImage(qrCodeImage, -rotation);
                      }else {
                        qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[1]) * 1.3333),(int)(Integer.valueOf(arr[2]) * 1.3333));
                      }
                      ByteArrayOutputStream baos = new ByteArrayOutputStream();
                      ImageIO.write(qrCodeImage, "PNG", baos);
                      if(getMergedArea(sheet, cell.getRow(), cell.getColumn()) != null){
                        CellArea area = getMergedArea(sheet, cell.getRow(), cell.getColumn());
                        CellRangeAddress cellRange1 = new CellRangeAddress(area.StartRow,area.EndRow,area.StartColumn,area.EndColumn);
                        addPicture(sheet, cellRange1, new ByteArrayInputStream(baos.toByteArray()));
                      }else{
                        CellRangeAddress cellRange1 = AsposeExcelUtil.getCellRange(sheet, cellId);
                        addPicture(sheet, cellRange1, new ByteArrayInputStream(baos.toByteArray()));
                      }
                    }catch (Exception e){
                      continue;
                    }
                  }
                }
              }else{
                String cellId = entry1.getKey();
                Cell cell = AsposeExcelUtil.getFirstCellOfPosition(sheet, cellId);
                String valueToBarCode = String.valueOf(cell.getValue());
                if(StringUtils.isEmpty(valueToBarCode) || StringUtils.isEmpty(valueToBarCode.strip()) || "null".equals(valueToBarCode)){
                  continue;
                }
                String[] arr = entry1.getValue().split("-");
                try {
                  CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(sheet, cellId);
                  int firstRow = cellRange.getFirstRow();
                  int firstCol = cellRange.getFirstColumn();
                  Cell targetCell = sheet.getCells().get(firstRow, firstCol);
                  Style style = targetCell.getStyle();
                  int rotation = style.getRotationAngle();
                  BufferedImage qrCodeImage;
                  if(rotation == 90){
                    qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[2]) * 1.3333),(int)(Integer.valueOf(arr[1]) * 1.3333));
                    qrCodeImage = rotateImage(qrCodeImage, -rotation);
                  }else {
                    qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[1]) * 1.3333),(int)(Integer.valueOf(arr[2]) * 1.3333));
                  }
                  ByteArrayOutputStream baos = new ByteArrayOutputStream();
                  ImageIO.write(qrCodeImage, "PNG", baos);
                  addPicture(sheet, cellRange, new ByteArrayInputStream(baos.toByteArray()));
                }catch (Exception e){
                  continue;
                }
              }
            }
          }
        }
      }
      if(templOutFuncQRInfoList.size()>0){
        WorksheetCollection worksheets = baseWorkbook.getWorksheets();
        for (int i = 0; i < worksheets.getCount(); i++) {
          Worksheet sheet = worksheets.get(i);
          int visibility = sheet.getVisibilityType();
          if (visibility == VisibilityType.VISIBLE){
            for(Map.Entry<String, String> entry1 : templOutFuncQRInfoList.entrySet()){
              String cellId = entry1.getKey();
              Cell cell = AsposeExcelUtil.getFirstCellOfPosition(sheet, cellId);
              String valueToBarCode = String.valueOf(cell.getValue());
              if(StringUtils.isEmpty(valueToBarCode) || StringUtils.isEmpty(valueToBarCode.strip()) || "null".equals(valueToBarCode)){
                continue;
              }
              String[] arr = entry1.getValue().split("-");
              try {
                CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(sheet, cellId);
                int firstRow = cellRange.getFirstRow();
                int firstCol = cellRange.getFirstColumn();
                Cell targetCell = sheet.getCells().get(firstRow, firstCol);
                Style style = targetCell.getStyle();
                int rotation = style.getRotationAngle();
                BufferedImage qrCodeImage;
                if(rotation == 90){
                  qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[2]) * 1.3333),(int)(Integer.valueOf(arr[1]) * 1.3333));
                  qrCodeImage = rotateImage(qrCodeImage, -rotation);
                }else {
                  qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[1]) * 1.3333),(int)(Integer.valueOf(arr[2]) * 1.3333));
                }
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                ImageIO.write(qrCodeImage, "PNG", baos);
                addPicture(sheet, cellRange, new ByteArrayInputStream(baos.toByteArray()));
              }catch (Exception e){
                continue;
              }
            }
          }
        }
      }
      // add #11535 帳票の汎用バーコード出力対応 吉 end
    } catch (Exception e) {
      // エラーメッセージ
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage("asposeで帳票お作成エラー：" + ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    return baseWorkbook;
  }

  /**
   * AsposeのWorkbook作成
   * @param mstReport
   * @param reportZipFile
   * @param params
   * @param reportOutputInfo
   * @param calcResult
   * @param graphOrdNo
   * @param dataKeyOut
   * @param getColWidth
   * @param getRowHeight
   * @return
   */
  public Workbook getReportExcelWorkbook(MstReport mstReport,
                                         ReportZipFile reportZipFile,
                                         List<ReportXmlParam> params,
                                         Map<String, String> reportOutputInfo,
                                         Map<String, String> calcResult,
                                         Long graphOrdNo,
                                         Map<String, Object> dataKeyOut,
                                         String getColWidth,
                                         String getRowHeight){
    // asposeでEXCELを取得する。
    Workbook baseWorkbook = this.getReportWorkbook(mstReport, reportZipFile);
    String firstEditSheetName = null;
    try {
      WorksheetCollection workSheets = baseWorkbook.getWorksheets();
      Worksheet paramSheet = workSheets.get("パラメータ");
      Cells paramCells = paramSheet.getCells();
      RowCollection allRows = paramCells.getRows();

      List<ReportXmlParam> tmplGroupId = params.stream()
        .filter(p -> !(p.getGroupId().equals("")))
        .collect(toList());

      // Getting grouping parameters cell's index from header row
      int groupNameIndex = 0;
      int repeatAddressIndex = 0;
      int cellAddressIndex = 0;
      // Loop find index
      Row headRow = allRows.get(0);
      for (int i = 0; i < headRow.getLastDataCell().getColumn(); i++) {
        Cell cell = headRow.get(i);
        switch (cell.getStringValue()) {
          case "GroupName" -> groupNameIndex = i;
          case "RepeatAddress" -> repeatAddressIndex = i;
          case "CellAddress" -> cellAddressIndex = i;
          default -> {}
        }
      }

      // Groupプロパティ取得
      Map<String, String> repeatAddressMap = new HashMap<>();
      for (int i = 1; i < allRows.getCount(); i++) {
        Row eachRow = allRows.get(i);
        if (StringUtils.isNotEmpty(eachRow.get(groupNameIndex).getStringValue())) {
          repeatAddressMap.put(
            eachRow.get(cellAddressIndex).getStringValue()
            , eachRow.get(repeatAddressIndex).getStringValue()
          );
        }
      }

      // テンプレートの繰り返しを取得する。
      ReportXmlTmplRepeat reportXmlTmplRepeat = params.get(0).getReportXmlTmplRepeat();

      if (reportXmlTmplRepeat != null) {
        // 単患者帳票、かつ抽出条件が検査日の場合
        if (ReportConstant.ReportClass.ONE_PATIENT_REPORT.equals(mstReport.getReportClass()) && "Examin".equals(reportXmlTmplRepeat.getRepeatMode())) {
          dataKeyOut.put("onePatientReportType", "2");
        }
      }
      // ページ総数を取得
      int pageCount = getPageCount(reportOutputInfo);
      if (!ReportConstant.ReportClass.ONE_TOTAL_REPORT.equals(mstReport.getReportClass())
        && !ReportConstant.ReportClass.INTRODUCTION_REPORT.equals(mstReport.getReportClass())
        // add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe start
        && !ReportConstant.ReportClass.MACHINE_REPORT.equals(mstReport.getReportClass())
        // add #10691 【デグレ】パラメータ改頁設定が機能していない 高 start
        && !ReportConstant.ReportClass.DIALYSIS_REPORT.equals(mstReport.getReportClass())
        && !ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT.equals(mstReport.getReportClass())
        && !ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT.equals(mstReport.getReportClass())
        // add #10691 【デグレ】パラメータ改頁設定が機能していない 高 end
        // add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe end
        // add #11973 日常点検一覧帳票が正常に出せない limingzhe start
        && !ReportConstant.ReportClass.MULTI_TOTAL_REPORT.equals(mstReport.getReportClass())
        // add #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 start
        && !ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT.equals(mstReport.getReportClass()
// add #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 end
      )
        // add #11973 日常点検一覧帳票が正常に出せない limingzhe end
      ) {
        if (StringUtils.isNotEmpty(reportXmlTmplRepeat.getId()) && reportXmlTmplRepeat.getIsNewPage() == 0) {
          pageCount = 1;
        }
      }

      if (reportOutputInfo.size() > 0){
        if (reportOutputInfo.containsKey("SyohouTyouHyou_Num")){
          reportOutputInfo.remove("SyohouTyouHyou_Num");
        }
        if (reportOutputInfo.containsKey("Over")){
          reportOutputInfo.remove("Over");
        }
        reportOutputInfo = sortByKeyB(sortByKeyA(reportOutputInfo));
      }

      List<Long> patIdList = new LinkedList<>();
      if(null != dataKeyOut.get("patIds")){
        patIdList = (List<Long>) dataKeyOut.get("patIds");
      }

      // Getting Base WorkSheet
      Worksheet baseSheet = workSheets.get(workSheets.getActiveSheetIndex());
      Worksheet finalBaseSt = baseSheet;

      // 埋め込み先のセル値をクリア
      for(ReportXmlParam reportXmlParam : params) {
        Optional.ofNullable(AsposeExcelUtil.getFirstCellOfPosition(baseSheet, reportXmlParam.getId()))
          .ifPresent(cell -> cell.setValue(null));
      }
      Worksheet tempFinalBaseSheet = baseSheet;
      Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
        .filter(e -> e.getKey().indexOf(MULTIPLE_PAGES_SEPARATOR) < 0)
        .forEach(e -> {
          String replaceKey = "";
          String dataType = ReportUtils.getDataType(params, e.getKey());
          if (repeatAddressMap.size() > 0) {
            replaceKey = getReplaceKeyForRepeat(e.getKey(), repeatAddressMap);
          }
          if (!StringUtils.isEmpty(replaceKey)) {
            // del #10385 患者イベント(画像)の出力が不正 高 start
//            if(mstReport.getReportClass() == ReportConstant.ReportClass.MULTI_TOTAL_REPORT){
//              Cell targetCell = AsposeExcelUtil.getFirstCellOfPosition(tempFinalBaseSheet, replaceKey);
//              setCellValueByType(targetCell, e.getValue(), dataType);
//            }else {
            // del #10385 患者イベント(画像)の出力が不正 高 end
                if(!dataType.equals("byte[]")){
                  setCellValueByPositionAndType(tempFinalBaseSheet, replaceKey, e.getValue(), dataType);
                }
                // add #12157 帳票のデータ項目でpat_eventの内部ファイルパスが出力される limingzhe start
                else {
                  setCellValue(mstReport, tempFinalBaseSheet, e, replaceKey, dataType, true);
                }
                // add #12157 帳票のデータ項目でpat_eventの内部ファイルパスが出力される limingzhe end
              // del #10385 患者イベント(画像)の出力が不正 高 start
//              }
            // del #10385 患者イベント(画像)の出力が不正 高 end
          } else {
            // add #12157 帳票のデータ項目でpat_eventの内部ファイルパスが出力される limingzhe start
            if(!dataType.equals("byte[]")){
            // add #12157 帳票のデータ項目でpat_eventの内部ファイルパスが出力される limingzhe end
              if(e.getValue().contains("(place)")){
                setCellValueByPositionAndType(tempFinalBaseSheet, e.getKey(), "", dataType);
              }else{
                setCellValueByPositionAndType(tempFinalBaseSheet, e.getKey(), e.getValue(), dataType);
              }
            // add #12157 帳票のデータ項目でpat_eventの内部ファイルパスが出力される limingzhe start
            }
            else {
              setCellValue(mstReport, tempFinalBaseSheet, e, e.getKey(), dataType, true);
            }
            // add #12157 帳票のデータ項目でpat_eventの内部ファイルパスが出力される limingzhe end
          }
        });
      Optional<ReportXmlTmplRepeat> tmplRepeat = params.stream()
        .filter(p -> p.isTmplRepeat())
        .map(p -> p.getReportXmlTmplRepeat())
        .findFirst();

      List groupList = params.stream().filter(p->p.getReportXmlGroup() != null)
        .map(p -> p.getReportXmlGroup())
        .collect(toList());

      Map<String, String> reportInfoDl= new HashMap<>();
      Set<Map.Entry<String, String>> sets = reportOutputInfo.entrySet();
      for (Map.Entry<String, String> set : sets) {
        String ket = set.getKey();
        if (ket.contains("$")){
          reportInfoDl.put(ket,set.getValue());
        }
      }
      Set<Map.Entry<String, String>> setsReportInfoDl = reportInfoDl.entrySet();
      for (Map.Entry<String, String> setDl : setsReportInfoDl) {
        if (setDl.getKey().contains("$")){
          String cellName = subStrBefore(setDl.getKey());
          reportOutputInfo.put(cellName,setDl.getValue());
          reportOutputInfo.remove(setDl.getKey(),setDl.getValue());
        }
      }

      boolean isDirectionX = tmplRepeat.map(p -> ReportXmlTmplRepeat.DIRECTION_Z.equals(p.getDirection())).orElse(false);
      int tmplOffset = tmplRepeat.map(p -> ReportUtils.getTmplOffset(p.getId(), true)).orElse(0);
      int tmplOffsetCol = tmplRepeat.map(p -> ReportUtils.getTmplOffset(p.getId(), false)).orElse(0);
      Optional<String> graphId = getGraphId(params);
      List<byte[]> chartData = Collections.emptyList();
      Optional<Integer> graphNewPage = getGraphNewPage(params);

      if (graphOrdNo != null && graphId.isPresent()) {
        // add #10633 【たくしん会】帳票のフォント問題 吉 start
        String fountStr  = getCellFontName(mstReport,reportZipFile,params);
        dataKeyOut.put("fountStr",fountStr);
        // add #10633 【たくしん会】帳票のフォント問題 吉 end
        if (ReportXmlGroup.IS_NEW_PAGE_YES.equals(graphNewPage.get())) {
          dataKeyOut.put("highchatIsNewPage","1");
        } else {
          dataKeyOut.put("highchatIsNewPage","0");
        }
        // 処理に必要な引数を空データで作成 ( BVMSのデータ分岐のみに使用する為、この処理ルートでは不要と判断しています )
        chartData = dataKeyOut.containsKey(ReportConstant.ReportDataKey.BVMS_CHART_DATA)
          ? (List<byte[]>) dataKeyOut.get(ReportConstant.ReportDataKey.BVMS_CHART_DATA) : createChartImageResByte(graphOrdNo.longValue(), dataKeyOut, getColWidth, getRowHeight);
      }

      int number = 0;
      if (pageCount >chartData.size() || pageCount == chartData.size()) {
        number = pageCount;
      } else {
        if(graphNewPage.isPresent()) {
          if (ReportXmlGroup.IS_NEW_PAGE_YES.equals(graphNewPage.get())) {
            number = chartData.size();
          } else {
            number = pageCount;
          }
        }
      }
      // add #11535 帳票の汎用バーコード出力対応 吉 start
      Map<String,String> funcCellMap = new HashMap<>();
      // add #11535 帳票の汎用バーコード出力対応 吉 end
      for (int page = 0; page < number; page++) {
        final String pagePrefix = String.format("%d%s", page + 1, MULTIPLE_PAGES_SEPARATOR);
        int newSheetIndex = workSheets.addCopy(baseSheet.getIndex());
        Worksheet destSheet = workSheets.get(newSheetIndex);
        destSheet.setName(String.format("%s%d", SHEET_NAME_PREFIX, page + 1));
        // スタイルのコピー
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
        //copyExcelStyle(destSheet, mstReport, groupList, repeatAddressMap, tmplRepeat);
        copyExcelStyle(destSheet, mstReport, groupList, repeatAddressMap, tmplRepeat, dataKeyOut.get("newPageCountFlag") != null);
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
        if(StringUtils.isEmpty(firstEditSheetName)) {
          firstEditSheetName = String.format("%s%d", SHEET_NAME_PREFIX, page + 1);
        }
        Stream<Map.Entry<String, String>> streamMap = Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
          .filter(e -> e.getKey().startsWith(pagePrefix));
        if (mstReport.getReportClass() == 2 && mstReport.getReportType() == 2){
          // 単患者の場合
          onePatientEdit(destSheet, streamMap, pagePrefix, params, repeatAddressMap, tmplRepeat);
        } else if (mstReport.getReportClass() == 2 && mstReport.getReportType() == 1){
          // 単患者⇒処方帳票
          onePatientOfPrescriptionEdit(destSheet, streamMap, pagePrefix, params, repeatAddressMap, tmplRepeat);
        } else if(mstReport.getReportClass() == 9 && mstReport.getReportType() == 2){
          // 紹介状
          introductionEdit(destSheet, streamMap, pagePrefix, params, repeatAddressMap, tmplRepeat, isDirectionX, tmplOffset, tmplOffsetCol);
        } else if(mstReport.getReportClass() == ReportConstant.ReportClass.MULTI_TOTAL_REPORT){
          // 複数集計
          multiTotalEdit(destSheet, streamMap, pagePrefix, params, repeatAddressMap, tmplRepeat, isDirectionX, tmplOffset, tmplOffsetCol);
        }
        // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
        else if(mstReport.getReportClass() == ReportConstant.ReportClass.ONE_TOTAL_REPORT){
          // 単集計
          multiTotalEdit(destSheet, streamMap, pagePrefix, params, repeatAddressMap, tmplRepeat, isDirectionX, tmplOffset, tmplOffsetCol);
        }
        // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
        // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
//        else if(mstReport.getReportClass() == 9 && mstReport.getReportType() == 1 && "曜日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
//          // 紹介状⇒集計⇒曜日
//          introductionByDayOfWeekEdit(destSheet, streamMap, pagePrefix, params, tmplRepeat, allRows, tmplGroupId);
//        } else if(mstReport.getReportClass() == 9 && mstReport.getReportType() == 1 && "日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
//          // 紹介状⇒集計⇒日
//          introductionByDay(destSheet, streamMap, pagePrefix, params, tmplRepeat, allRows, tmplGroupId);
//        }
        else if(mstReport.getReportClass() == ReportConstant.ReportClass.INTRODUCTION_REPORT && mstReport.getReportType() == 1) {
          // 紹介状⇒集計
          multiTotalEdit(destSheet, streamMap, pagePrefix, params, repeatAddressMap, tmplRepeat, isDirectionX, tmplOffset, tmplOffsetCol);
        }
        // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
        else {
          // 上記以外
          if ((!ReportConstant.ReportClass.LABEL_REPORT.equals(mstReport.getReportClass()) && !ReportConstant.ReportClass.MACHINE_REPORT.equals(mstReport.getReportClass())&&!ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT.equals(mstReport.getReportClass())) && tmplRepeat.isPresent()) {
            copyFixedValue(destSheet, tmplRepeat, page, dataKeyOut);
          }
          if(mstReport.getReportClass() == ReportConstant.ReportClass.LABEL_REPORT) {
            copyFixedValueForLabel(destSheet, tmplRepeat, page, 1, dataKeyOut);
          }
          List<ReportXmlParam> outTempList = params.stream().filter(f -> ("0".equals(f.getIsInTmpl()))).distinct().collect(Collectors.toList());
          Map<String, String> resultMap = outTempList.stream()
            .collect(Collectors.toMap(
              ReportXmlParam::getId,      // key id
              ReportXmlParam::getDataType // value dataType
            ));
          List<ReportXmlParam> inTempList = params.stream().filter(f -> ("1".equals(f.getIsInTmpl()))).distinct().collect(Collectors.toList());
          String dataTypeInTmp = inTempList.size()==1 ? inTempList.get(0).getDataType() : "";
          streamMap.forEach(e -> {
            String dataType = "";
            String conKey = "";
            String key = e.getKey().substring(pagePrefix.length());
            if (key.contains("-")) {
              conKey = key.substring(0, key.indexOf("-"));
              dataType = resultMap.containsKey(conKey) ? resultMap.get(conKey) : ReportUtils.getDataType(params, key);
            } else {
              dataType = ReportUtils.getDataType(params, key);
            }
            String replaceKey = null;
            if (tmplRepeat.isPresent() && key.startsWith(tmplRepeat.get().getId()) && mstReport.getReportClass() != ReportConstant.ReportClass.ONE_TOTAL_REPORT) {
              if (repeatAddressMap.size() > 0) {
                replaceKey = getReplaceKey(key, repeatAddressMap);
              }
              if (replaceKey != null) {
                setCellValue(destSheet, replaceKey, e.getValue(), isDirectionX, tmplOffset, tmplOffsetCol, dataType, tmplRepeat);
                if (repeatAddressMap.size() > 0) {
                  setShrinkToFit(destSheet, repeatAddressMap, params);
                }
              } else {
                if(e.getValue().contains("(place)")){
                  setCellValue(destSheet, key, "", isDirectionX, tmplOffset, tmplOffsetCol, dataType, tmplRepeat);
                }else{
                  setCellValue(destSheet, key, e.getValue(), isDirectionX, tmplOffset, tmplOffsetCol, dataType, tmplRepeat);
                }
              }
            } else {
              // 繰り返しデータの割り当て先にkeyを差替える(テンプレート繰り返し出ない場合の処理)
              String includedKey = "";
              if (tmplRepeat.isPresent()) {
                includedKey = "_" + tmplRepeat.get().getId();
              }
              if (repeatAddressMap.size() > 0) {
                if (mstReport.getReportClass() == ReportConstant.ReportClass.ONE_TOTAL_REPORT && key.contains("_V")) {
                  replaceKey = getReplaceKeyForRepeat_V(key, repeatAddressMap);
                } else if (mstReport.getReportClass() == ReportConstant.ReportClass.ONE_TOTAL_REPORT && !StringUtils.isEmpty(includedKey) && key.contains(includedKey)) {
                  replaceKey = tmplRepeat.get().getId();
                } else {
                  replaceKey = getReplaceKeyForRepeat(key, repeatAddressMap);
                }
              }
              if (replaceKey != null) {
                if (mstReport.getReportClass() == ReportConstant.ReportClass.ONE_TOTAL_REPORT && key.contains("_V")) {
                  setCellValue_V(destSheet, key.split("_V")[0], e.getValue(), dataType);
                } else if (mstReport.getReportClass() == ReportConstant.ReportClass.ONE_TOTAL_REPORT && !StringUtils.isEmpty(includedKey) && key.contains(includedKey)){
                  setCellValueForOneTotal(destSheet, key, e.getValue(), dataTypeInTmp);
                } else {
                  if(mstReport.getReportClass() == ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT){
                    Cell targetCell = AsposeExcelUtil.getFirstCellOfPosition(destSheet, replaceKey);
                    setCellValueByType(targetCell, e.getValue(), ReportXmlParam.DATA_TYPE_STRING);
                  }else {
                    setCellValueByPositionAndType(destSheet, replaceKey, e.getValue(), dataType);
                  }
                }
              } else {
                setCellValueByPositionAndType(destSheet, key, e.getValue(), dataType);
              }
            }
          });
        }
        // スタイルのコピー
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
        //copyExcelStyle(destSheet, mstReport, groupList, repeatAddressMap, tmplRepeat);
        copyExcelStyle(destSheet, mstReport, groupList, repeatAddressMap, tmplRepeat, dataKeyOut.get("newPageCountFlag") != null);
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
        List <Integer> repCountList = new ArrayList<>();
        for (Map.Entry<String, String> entry : reportOutputInfo.entrySet()) {
          String key = entry.getKey();
          // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
          if(key.contains("@")) continue;
          // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end
          if(key.contains(".")){
            if (Integer.parseInt(key.substring(0,key.indexOf("#"))) == page + 1) {
              String key1 = key.split("\\.")[0];
              int repCount1 = Integer.valueOf(key1.split("-")[1]);
              if(!repCountList.contains(repCount1)){
                repCountList.add(repCount1);
              }
            }
          }
        }

        // add #10447 テンプレート繰返しでの計算式繰返しの制限事項対応③（項目指定とセル指定の混在）高 start
        // 2つのMap（帳票出力結果 + 計算結果）を結合し、指定ページPrefixのキーのみを対象とする
        Stream<Map.Entry<String, String>> streamMapNew =
          Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
            .filter(e -> e.getKey().startsWith(pagePrefix));
        // 各キー・値ペアを処理
        streamMapNew.forEach(e -> {
          // 帳票パラメータ単位でループ
          for (ReportXmlParam param : params) {
            // 関数を持たないパラメータは対象外
            if (!param.hasFunction()) continue;
            // 対象セル（テンプレート上の基準セル）を取得
            Cell targetCell = AsposeExcelUtil.getFirstCellOfPosition(destSheet, param.getId());
            if (targetCell == null) continue;
            /**
             * 以下条件すべて満たす場合のみ処理対象：
             *
             * ① キーにparam IDが含まれている（対象セルとの紐付け）
             * ② param側の関数が「セル参照を含む演算式」である
             * ③ 値側が "formula=" 形式である（＝数式として扱う必要あり）
             * ④ 値側の数式も「セル参照を含む演算式」である
             */
            if (e.getKey().contains(param.getId())
              && hasConcatCellReference(param.getFunction())
              && e.getValue().contains("formula=")
              && hasConcatCellReference(e.getValue().replace("formula=", ""))) {
              // 繰り返しが存在しない場合は、元セルにそのまま関数を設定
              if (repCountList.size() == 0) {
                // mod #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe start
                //targetCell.setFormula(param.getFunction());
                try {
                  targetCell.setFormula(param.getFunction());
                } catch (Exception ex) {
                  targetCell.setFormula(null);
                  targetCell.setValue(" ");
                }
                // mod #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe end
              }
              // キーからインデックス（繰り返し番号）を取得
              int index = getIndexFromKey(e.getKey());
              // 繰り返し回数分ループ
              for (int i = 0; i < repCountList.size(); i++) {
                // 対象インデックスと一致しない場合はスキップ
                if (index != repCountList.get(i)) {
                  continue;
                }
                // 元セル位置をアドレスとして保持
                CellRangeAddress tempAddress = new CellRangeAddress(
                  targetCell.getRow(),
                  targetCell.getRow(),
                  targetCell.getColumn(),
                  targetCell.getColumn()
                );
                // 繰り返し用キーを生成（テンプレートID + 繰り返し番号 + セル位置）
                String key1 = param.getReportXmlTmplRepeat().getId()
                  + "-" + repCountList.get(i)
                  + "." + tempAddress.formatAsString();
                // 実際に書き込む対象セル（繰り返し後のセル）を取得
                Cell lastCell = AsposeExcelUtil.getFirstCellOfPosition(
                  destSheet, key1, isDirectionX, tmplOffset, tmplOffsetCol, tmplRepeat
                );
                // 数式内のセル参照位置を、コピー先セルに合わせて変換
                String formula = AsposeExcelUtil.changeFormulaLocation(
                  targetCell,
                  lastCell,
                  e.getValue().replace("formula=", ""),
                  param.getReportXmlTmplRepeat().getId()
                );
                // スタイルをコピー
                lastCell.setStyle(targetCell.getStyle());
                // del #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe start
//                // バーコード対象セルの場合はマッピングを保持
//                if (param.getBarCode() != null) {
//                  funcCellMap.put(lastCell.getName(), param.getId());
//                }
                // del #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe end
                // 数式設定（失敗時は空白設定）
                try {
                  lastCell.setFormula(formula);
                } catch (Exception ex) {
                  lastCell.setFormula(null);
                  lastCell.setValue(" ");
                }
              }
              // paramループを抜ける（該当paramは1つのみ想定）
              break;
            }
          }
        });
        // add #10447 テンプレート繰返しでの計算式繰返しの制限事項対応③（項目指定とセル指定の混在）高 end

        // mod #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe start
        final List<Integer> lastRepCount = new ArrayList<>(repCountList);
        // バーコード対象セルの場合はマッピングを保持
        funcCellMap.putAll(formulaCalculateForParams(baseWorkbook, destSheet, params, lastRepCount));
        // mod #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe end
        if(graphNewPage.isPresent()) {
          CellRangeAddress range = AsposeExcelUtil.getCellRange(destSheet, graphId.get());
          if (ReportXmlGroup.IS_NEW_PAGE_YES.equals(graphNewPage.get())) {
            if (page < chartData.size()) {
              // イメージを追加
              // mod #11737 グラフがセルサイズにフィットしないときがある 吉 start
              // addPicture(destSheet, range, new ByteArrayInputStream(chartData.get(page)));
              addHighchartPicture(destSheet, range, new ByteArrayInputStream(chartData.get(page)));
              // mod #11737 グラフがセルサイズにフィットしないときがある 吉 end
            }
          } else {
            if (page < pageCount) {
              if(chartData != null && chartData.size() > 0) {
                // イメージを追加
                // mod #11737 グラフがセルサイズにフィットしないときがある 吉 start
                // addPicture(destSheet, range, new ByteArrayInputStream(chartData.get(0)));
                addHighchartPicture(destSheet, range, new ByteArrayInputStream(chartData.get(0)));
                // mod #11737 グラフがセルサイズにフィットしないときがある 吉 end
              }
            }
          }
        }

        if(mstReport.getReportClass() == ReportConstant.ReportClass.LABEL_REPORT) {
          reportMergedRegionForLabel(destSheet, tmplRepeat, page, 1, dataKeyOut);
        }
        if(mstReport.getReportClass() == ReportConstant.ReportClass.ONE_PATIENT_REPORT) {
          List<ReportXmlParam> sqlCode31List = params.stream()
            .filter(p -> (p.getSqlCode().equals("31")))
            .collect(toList());
          if (sqlCode31List.size() > 0) {
            reportMergedRegionForOnePatient(destSheet, tmplRepeat);
          }
        }
        Map<String, String> finalReportOutputInfo = reportOutputInfo;
        params.stream()
          .filter(param -> "true".equals(param.getIsImage()))
          .forEach(param ->{
            // mod #12157 帳票のデータ項目でpat_eventの内部ファイルパスが出力される limingzhe start
//            String path = "";
//            if(param.getDataType().equals("byte[]")){
//              path = finalReportOutputInfo.get(param.getId());
//              if (path == null) {
//                for (String key : finalReportOutputInfo.keySet()){
//                  if (key.contains(param.getId())) {
//                    path = finalReportOutputInfo.get(key);
//                  }
//                }
//              }
//              if (path != null) {
//                path = path.replace("(place)","");
//              }
//            }
//            if(null != path && !"".equals(path)){
//              // 画像を取得し出力内容に含める
//              String bucket = String.format(s3BucketForImage, mstReport.getFacilityCd());
//              byte[] excelBytes = reportS3Service.getOutputFileData(bucket, path);
//              CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(finalBaseSt, param.getId());
//              try {
//                addPicture(destSheet, cellRange, new ByteArrayInputStream(excelBytes));
//              } catch (Exception e) {
//                // エラーメッセージ
//                EventLogMessage eventLogMessage = new EventLogMessage();
//                eventLogMessage.setLogMessage("asposeで帳票お作成エラー：" + NtssUtils.ExcetionStackTraceToString(e));
//                logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
//              }
//            }
            finalReportOutputInfo.entrySet()
              .stream()
              .filter(info -> info.getKey().contains(param.getId()))
              .forEach(info -> {
                String key = info.getKey();
                String replaceKey = null;
                if(key.startsWith(pagePrefix)){
                  key = key.substring(pagePrefix.length());
                  if (tmplRepeat.isPresent() && key.startsWith(tmplRepeat.get().getId())) {
                    // テンプレート内項目の処理
                    if (!repeatAddressMap.isEmpty()) {
                      // テンプレート内の繰り返し設定がある場合、貼り付けセルを取得
                      replaceKey = this.getReplaceKey(key, repeatAddressMap);
                    }
                    if (StringUtils.isEmpty(replaceKey)) {
                      // 対象がなかった場合、取得に失敗した場合は元のセルに対して処理を実施する
                      replaceKey = key;
                    }
                    // テンプレート繰り返し内でのデータ貼り付けセルを取得
                    String path = info.getValue();
                    // データが画像の場合
                    if (StringUtils.isNotEmpty(path)) {
                      // Getting images from S3 service
                      String bucket = String.format(s3BucketForImage, mstReport.getFacilityCd());
                      byte[] excelBytes = reportS3Service.getOutputFileData(bucket, path);
                      CellRangeAddress cellAddresses = AsposeExcelUtil.getCellAddressOfPositionInTmpl(destSheet, replaceKey, isDirectionX
                        , tmplOffset, tmplOffsetCol, tmplRepeat);
                      try {
                        addPicture(destSheet, cellAddresses, new ByteArrayInputStream(excelBytes));
                      } catch (Exception ex) {
                        // エラーメッセージ
                        EventLogMessage eventLogMessage = new EventLogMessage();
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                        eventLogMessage.setLogMessage("asposeでグラフのINSERTはエラー：" + ExcetionStackTraceToString(ex));
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                      }
                    }
                  }
                  else {
                    // テンプレート外項目の処理
                    if (!repeatAddressMap.isEmpty()) {
                      // 繰り返し設定がある場合、貼り付けセルを取得
                      replaceKey = this.getReplaceKeyForRepeat(key, repeatAddressMap);
                    }
                    if (StringUtils.isEmpty(replaceKey)) {
                      // 対象がなかった場合、取得に失敗した場合は元のセルに対して処理を実施する
                      replaceKey = key;
                    }
                    setCellValue(mstReport, destSheet, info, replaceKey, param.getDataType(), true);
                  }
                }
              });
            // mod #12157 帳票のデータ項目でpat_eventの内部ファイルパスが出力される limingzhe end
          });

        // add #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe start
        if (tmplRepeat.isPresent()) {
          // テンプレート繰返しでの計算式繰返し（「=」で始まる計算式）
          List<String> paramIdInTmpl = params.stream().filter(p -> p.isTmplRepeat()).map(p -> p.getId()).collect(toList());
          formulaCalculateFromTmpl(destSheet, tmplRepeat.get(), paramIdInTmpl, repCountList.size());
        }
        // add #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe end
        // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 start
        //qrコード
        Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
          .forEach(entry -> {
            if(entry.getKey().startsWith(pagePrefix)){
              final String key = entry.getKey().substring(pagePrefix.length());
              Map<String,String> qrCodeCell =  params.stream()
                .filter(p -> !StringUtils.isEmpty(p.getDataCode()) && p.getDataCode().equals("qrCode"))
                .collect(Collectors.toMap(m -> m.getId() , m -> m.getColWidth() + "-" + m.getRowHeight()));
              if(null != qrCodeCell && qrCodeCell.size()>0){
                for(Map.Entry<String, String> entry1 : qrCodeCell.entrySet()){
                  if(entry1.getKey().equals(key)){
                    createQRPic(entry1.getValue(),key,destSheet,entry.getValue());
                  }
                }
              }
            }else{
              Map<String,String> qrCodeForNewOne =  params.stream()
                .filter(p -> !StringUtils.isEmpty(p.getDataCode()) && p.getDataCode().equals("qrCodeForNewOne"))
                .collect(Collectors.toMap(m -> m.getId() , m -> m.getColWidth() + "-" + m.getRowHeight()));
              if(null != qrCodeForNewOne && qrCodeForNewOne.size()>0){
                for(Map.Entry<String, String> entry1 : qrCodeForNewOne.entrySet()){
                  if(entry1.getKey().equals(entry.getKey())){
                    createQRPic(entry1.getValue(),entry.getKey(),destSheet,entry.getValue());
                  }
                }
              }
            }
          });
        // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 end
      }
      baseWorkbook.getWorksheets().removeAt(baseSheet.getIndex());
      // activeSheetを設定する
      if(StringUtils.isNotEmpty(firstEditSheetName)) {
        baseWorkbook.getWorksheets().setActiveSheetName(firstEditSheetName);
      }
      // add #11535 帳票の汎用バーコード出力対応 吉 start
      Map<String, String> templInFuncQRInfoList = params.stream()
        .filter(p -> p.getDataCode() != null && !"".equals(p.getBarCode()) && p.isTmplRepeat())
        .collect(Collectors.toMap(
          ReportXmlParam::getId,
          p -> p.getBarCode() + "-" + p.getColWidth() + "-" + p.getRowHeight()
        ));
      Map<String, String> templOutFuncQRInfoList = params.stream()
        .filter(p -> p.getDataCode() != null && !"".equals(p.getBarCode()) && !p.isTmplRepeat())
        .collect(Collectors.toMap(
          ReportXmlParam::getId,
          p -> p.getBarCode() + "-" + p.getColWidth() + "-" + p.getRowHeight()
        ));
      if(templInFuncQRInfoList.size()>0){
        WorksheetCollection worksheets = baseWorkbook.getWorksheets();
        for (int i = 0; i < worksheets.getCount(); i++) {
          Worksheet sheet = worksheets.get(i);
          int visibility = sheet.getVisibilityType();
          //（0 表示 visible）
          if (visibility == VisibilityType.VISIBLE) {
            for(Map.Entry<String, String> entry1 : templInFuncQRInfoList.entrySet()){
              if(null != funcCellMap && funcCellMap.size() > 0){
                for(Map.Entry<String, String> funcEntry : funcCellMap.entrySet()){
                  if(funcEntry.getValue().equals(entry1.getKey())){
                    String cellId = funcEntry.getKey();
                    Cell cell = AsposeExcelUtil.getFirstCellOfPosition(sheet, cellId);
                    String valueToBarCode = String.valueOf(cell.getValue());
                    if(StringUtils.isEmpty(valueToBarCode) || StringUtils.isEmpty(valueToBarCode.strip()) || "null".equals(valueToBarCode)){
                      continue;
                    }
                    String[] arr = entry1.getValue().split("-");
                    try {
                      CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(sheet, cellId);
                      int firstRow = cellRange.getFirstRow();
                      int firstCol = cellRange.getFirstColumn();
                      Cell targetCell = sheet.getCells().get(firstRow, firstCol);
                      Style style = targetCell.getStyle();
                      int rotation = style.getRotationAngle();
                      BufferedImage qrCodeImage;
                      if(rotation == 90){
                        qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[2]) * 1.3333),(int)(Integer.valueOf(arr[1]) * 1.3333));
                        qrCodeImage = rotateImage(qrCodeImage, -rotation);
                      }else {
                        qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[1]) * 1.3333),(int)(Integer.valueOf(arr[2]) * 1.3333));
                      }
                      ByteArrayOutputStream baos = new ByteArrayOutputStream();
                      ImageIO.write(qrCodeImage, "PNG", baos);

                      if(getMergedArea(sheet, cell.getRow(), cell.getColumn()) != null){
                        CellArea area = getMergedArea(sheet, cell.getRow(), cell.getColumn());
                        CellRangeAddress cellRange1 = new CellRangeAddress(area.StartRow,area.EndRow,area.StartColumn,area.EndColumn);
                        addPicture(sheet, cellRange1, new ByteArrayInputStream(baos.toByteArray()));
                      }else{
                        CellRangeAddress cellRange1 = AsposeExcelUtil.getCellRange(sheet, cellId);
                        addPicture(sheet, cellRange1, new ByteArrayInputStream(baos.toByteArray()));
                      }
                    }catch (Exception e){
                      continue;
                    }
                  }
                }
              }else{
                String cellId = entry1.getKey();
                Cell cell = AsposeExcelUtil.getFirstCellOfPosition(sheet, cellId);
                String valueToBarCode = String.valueOf(cell.getValue());
                if(StringUtils.isEmpty(valueToBarCode) || StringUtils.isEmpty(valueToBarCode.strip()) || "null".equals(valueToBarCode)){
                  continue;
                }
                String[] arr = entry1.getValue().split("-");
                try {
                  CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(sheet, cellId);
                  int firstRow = cellRange.getFirstRow();
                  int firstCol = cellRange.getFirstColumn();
                  Cell targetCell = sheet.getCells().get(firstRow, firstCol);
                  Style style = targetCell.getStyle();
                  int rotation = style.getRotationAngle();
                  BufferedImage qrCodeImage;
                  if(rotation == 90){
                    qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[2]) * 1.3333),(int)(Integer.valueOf(arr[1]) * 1.3333));
                    qrCodeImage = rotateImage(qrCodeImage, -rotation);
                  }else {
                    qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[1]) * 1.3333),(int)(Integer.valueOf(arr[2]) * 1.3333));
                  }
                  ByteArrayOutputStream baos = new ByteArrayOutputStream();
                  ImageIO.write(qrCodeImage, "PNG", baos);
                  addPicture(sheet, cellRange, new ByteArrayInputStream(baos.toByteArray()));
                }catch (Exception e){
                  continue;
                }
              }
            }
          }
        }
      }
      if(templOutFuncQRInfoList.size()>0){
        WorksheetCollection worksheets = baseWorkbook.getWorksheets();
        for (int i = 0; i < worksheets.getCount(); i++) {
          Worksheet sheet = worksheets.get(i);
          int visibility = sheet.getVisibilityType();
          if (visibility == VisibilityType.VISIBLE){
            for(Map.Entry<String, String> entry1 : templOutFuncQRInfoList.entrySet()){
              String cellId = entry1.getKey();
              Cell cell = AsposeExcelUtil.getFirstCellOfPosition(sheet, cellId);
              String valueToBarCode = String.valueOf(cell.getValue());
              if(StringUtils.isEmpty(valueToBarCode) || StringUtils.isEmpty(valueToBarCode.strip()) || "null".equals(valueToBarCode)){
                continue;
              }
              String[] arr = entry1.getValue().split("-");
              try {
                CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(sheet, cellId);
                int firstRow = cellRange.getFirstRow();
                int firstCol = cellRange.getFirstColumn();
                Cell targetCell = sheet.getCells().get(firstRow, firstCol);
                Style style = targetCell.getStyle();
                int rotation = style.getRotationAngle();
                BufferedImage qrCodeImage;
                if(rotation == 90){
                  qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[2]) * 1.3333),(int)(Integer.valueOf(arr[1]) * 1.3333));
                  qrCodeImage = rotateImage(qrCodeImage, -rotation);
                }else {
                  qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[1]) * 1.3333),(int)(Integer.valueOf(arr[2]) * 1.3333));
                }
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                ImageIO.write(qrCodeImage, "PNG", baos);
                addPicture(sheet, cellRange, new ByteArrayInputStream(baos.toByteArray()));
              }catch (Exception e){
                continue;
              }
            }
          }
        }
      }
      // add #11535 帳票の汎用バーコード出力対応 吉 end
    } catch (Exception e) {
      // エラーメッセージ
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage("asposeで帳票お作成エラー：" + ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    return baseWorkbook;
  }

  // add #11535 帳票の汎用バーコード出力対応 吉 start
  public static CellArea getMergedArea(Worksheet sheet, int row, int col) {
    ArrayList<CellArea> mergedAreas = sheet.getCells().getMergedCells();
    for (CellArea area : mergedAreas) {
      if (row >= area.StartRow && row <= area.EndRow &&
        col >= area.StartColumn && col <= area.EndColumn) {
        return area;
      }
    }
    return null;
  }
  // add #11535 帳票の汎用バーコード出力対応 吉 end

  // add #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
  public Workbook getReportExcelWorkbookbyHTMLPrint(MstReport mstReport,
                                         ReportZipFile reportZipFile,
                                         List<ReportXmlParam> params,
                                         Map<String, String> reportOutputInfo,
                                         Map<String, Object> dataKeyOut){
    // asposeでEXCELを取得する。
    Workbook baseWorkbook = this.getReportWorkbook(mstReport, reportZipFile);
    String firstEditSheetName = null;
    try {
      WorksheetCollection workSheets = baseWorkbook.getWorksheets();
      // Getting Base WorkSheet
      Worksheet baseSheet = workSheets.get(workSheets.getActiveSheetIndex());
      Worksheet finalBaseSt = baseSheet;

      // 埋め込み先のセル値をクリア
      for(ReportXmlParam reportXmlParam : params) {
        Optional.ofNullable(AsposeExcelUtil.getFirstCellOfPosition(baseSheet, reportXmlParam.getId()))
          .ifPresent(cell -> cell.setValue(null));
      }

      Worksheet tempFinalBaseSheet = baseSheet;
      reportOutputInfo.entrySet().stream()
        .forEach(e -> {
          ReportXmlParam resultParam = null;
          Optional<ReportXmlParam> param = params.stream().filter(p -> p.getId().equals(e.getKey()) || p.getRepeatAddress().contains(e.getKey())).findFirst();
          if (param.isPresent()) {
            resultParam = param.get();
          }

          String dataType = resultParam != null ? resultParam.getDataType() : "";
          boolean bHaveFormula = resultParam != null ? resultParam.isFormulaToCalc() : false;
          if(resultParam != null){
            if(dataType.equals(ReportXmlParam.DATA_TYPE_DATE_TIME) || (dataType.equals(ReportXmlParam.DATA_TYPE_DECIMAL) && !bHaveFormula)){
              Cell targetCell = AsposeExcelUtil.getFirstCellOfPosition(tempFinalBaseSheet, e.getKey());
              Style style = targetCell.getStyle();
              if(style.getHorizontalAlignment() == TextAlignmentType.GENERAL){
                style.setHorizontalAlignment(TextAlignmentType.RIGHT);
                targetCell.setStyle(style);
              }
            }
          }

          if(!dataType.equals("byte[]")) dataType = ReportXmlParam.DATA_TYPE_STRING;
          if(e.getValue().contains("(place)")){
            setCellValueByPositionAndType(tempFinalBaseSheet, e.getKey(), "", dataType);
          }else{
            setCellValueByPositionAndType(tempFinalBaseSheet, e.getKey(), e.getValue(), dataType);
          }
        });

      Worksheet paramSheet = workSheets.get("パラメータ");
      Cells paramCells = paramSheet.getCells();
      RowCollection allRows = paramCells.getRows();

      // Getting grouping parameters cell's index from header row
      int groupNameIndex = 0;
      int repeatAddressIndex = 0;
      int cellAddressIndex = 0;
      // Loop find index
      Row headRow = allRows.get(0);
      for (int i = 0; i < headRow.getLastDataCell().getColumn(); i++) {
        Cell cell = headRow.get(i);
        switch (cell.getStringValue()) {
          case "GroupName" -> groupNameIndex = i;
          case "RepeatAddress" -> repeatAddressIndex = i;
          case "CellAddress" -> cellAddressIndex = i;
          default -> {}
        }
      }

      // Groupプロパティ取得
      Map<String, String> repeatAddressMap = new HashMap<>();
      for (int i = 1; i < allRows.getCount(); i++) {
        Row eachRow = allRows.get(i);
        if (StringUtils.isNotEmpty(eachRow.get(groupNameIndex).getStringValue())) {
          repeatAddressMap.put(
            eachRow.get(cellAddressIndex).getStringValue()
            , eachRow.get(repeatAddressIndex).getStringValue()
          );
        }
      }

      Optional<ReportXmlTmplRepeat> tmplRepeat = params.stream()
        .filter(p -> p.isTmplRepeat())
        .map(p -> p.getReportXmlTmplRepeat())
        .findFirst();

      List groupList = params.stream().filter(p->p.getReportXmlGroup() != null)
        .map(p -> p.getReportXmlGroup())
        .collect(toList());

      int number = 1;
      for (int page = 0; page < number; page++) {
        int newSheetIndex = workSheets.addCopy(baseSheet.getIndex());
        Worksheet destSheet = workSheets.get(newSheetIndex);
        destSheet.setName(String.format("%s%d", SHEET_NAME_PREFIX, page + 1));
        if(StringUtils.isEmpty(firstEditSheetName)) {
          firstEditSheetName = String.format("%s%d", SHEET_NAME_PREFIX, page + 1);
        }
        // 紹介状(集計)
        if (ReportConstant.ReportClass.INTRODUCTION_REPORT.equals(mstReport.getReportClass()) && mstReport.getReportType() == 1) {
          if (groupList.size() != 0) {
            if (tmplRepeat.isPresent()) {
              repeatAddressMap.remove(tmplRepeat.get().getId());
            }
            copyStyleFromCells(destSheet, repeatAddressMap);
          }
          if (tmplRepeat.isPresent()) {
            copyStyleFromConvert(destSheet, tmplRepeat, dataKeyOut.get("newPageCountFlag") != null);
          }
        }
        // 紹介状(テンプレート)
        else if (ReportConstant.ReportClass.INTRODUCTION_REPORT.equals(mstReport.getReportClass()) && mstReport.getReportType() == 2) {
          if (groupList.size() != 0) {
            if (tmplRepeat.isPresent()) {
              repeatAddressMap.remove(tmplRepeat.get().getId());
            }
            copyStyleFromCells(destSheet, repeatAddressMap);
          }
          if (tmplRepeat.isPresent()) {
            copyStyleFromTmpl(destSheet, tmplRepeat,ReportConstant.ReportClass.INTRODUCTION_REPORT);
          }
        }
        Map<String, String> finalReportOutputInfo = reportOutputInfo;
        params.stream()
          .filter(param -> "true".equals(param.getIsImage()))
          .forEach(param ->{
            if(param.getDataType().equals("byte[]")){
              if(finalReportOutputInfo.get(param.getId()) != null && !"".equals(finalReportOutputInfo.get(param.getId()))) {
                byte[] excelBytes = Base64.getDecoder().decode(finalReportOutputInfo.get(param.getId()));
                CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(finalBaseSt, param.getId());
                try {
                  addPicture(destSheet, cellRange, new ByteArrayInputStream(excelBytes));
                } catch (Exception e) {
                  // エラーメッセージ
                  EventLogMessage eventLogMessage = new EventLogMessage();
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                  eventLogMessage.setLogMessage("asposeで帳票お作成エラー：" + ExcetionStackTraceToString(e));
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                  logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                }
              }
            }
          });
      }
      baseWorkbook.getWorksheets().removeAt(baseSheet.getIndex());
      // activeSheetを設定する
      if(StringUtils.isNotEmpty(firstEditSheetName)) {
        baseWorkbook.getWorksheets().setActiveSheetName(firstEditSheetName);
      }
    } catch (Exception e) {
      // エラーメッセージ
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage("asposeで帳票お作成エラー：" + ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    return baseWorkbook;
  }
  // add #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end

  /**
   * 帳票Excelファイルに値を埋め込んだワークブックを返します
   * ※帳票種別：02：単患者帳票 用の処理です
   *
   * @param mstReport 帳票マスタ
   * @param reportZipFile 帳票Zipファイル
   * @param params Param要素情報
   * @param reportOutputInfo 帳票出力情報
   * @param calcResult 計算結果
   */
  @Override
  public Workbook getReportExcelWbForOnePatient(
    MstReport mstReport,
    ReportZipFile reportZipFile,
    List<ReportXmlParam> params,
    Map<String, String> reportOutputInfo,
    Map<String, String> calcResult) {
    String firstEditSheetName = "";
    // asposeでEXCELを取得する。
    Workbook baseWorkbook = this.getReportWorkbook(mstReport, reportZipFile);

    WorksheetCollection workSheets = baseWorkbook.getWorksheets();
    Worksheet paramSheet = workSheets.get("パラメータ");
    Cells paramCells = paramSheet.getCells();
    RowCollection allRows = paramCells.getRows();

    // Getting grouping parameters cell's index from header row
    int groupNameIndex = 0;
    int repeatAddressIndex = 0;
    int cellAddressIndex = 0;
    // Loop find index
    Row headRow = allRows.get(0);
    for (int i = 0; i < headRow.getLastDataCell().getColumn(); i++) {
      Cell cell = headRow.get(i);
      switch (cell.getStringValue()) {
        case "GroupName" -> groupNameIndex = i;
        case "RepeatAddress" -> repeatAddressIndex = i;
        case "CellAddress" -> cellAddressIndex = i;
        default -> {}
      }
    }

    // Groupプロパティ取得
    Map<String, String> repeatAddressMap = new HashMap<>();
    for (int i = 1; i < allRows.getCount(); i++) {
      Row eachRow = allRows.get(i);
      if (StringUtils.isNotEmpty(eachRow.get(groupNameIndex).getStringValue())) {
        repeatAddressMap.put(
          eachRow.get(cellAddressIndex).getStringValue()
          , eachRow.get(repeatAddressIndex).getStringValue()
        );
      }
    }

    // Getting Base WorkSheet
    Worksheet baseSheet = workSheets.get(workSheets.getActiveSheetIndex());

    // 埋め込み先のセル値をクリア
    params.forEach(
      reportXmlParam ->
        Optional.ofNullable(AsposeExcelUtil.getFirstCellOfPosition(baseSheet, reportXmlParam.getId()))
                .ifPresent(cell -> cell.setValue(null))
    );

    // 全ページ共通のセル値を埋め込む
    Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
        .filter(entry -> !entry.getKey().contains(MULTIPLE_PAGES_SEPARATOR))
        .forEach(
          entry ->  {
            String replaceKey = "";
            String dataType = ReportXmlParam.DATA_TYPE_STRING;
            boolean isImage = false;
            ReportXmlParam targetParam = ReportUtils.getTargetParam(params, entry.getKey());

            // 対象項目の設定を取得
            if (targetParam != null) {
              dataType = targetParam.getDataType();
              isImage = StringUtils.equals("true", targetParam.getIsImage());
            }

            if (!repeatAddressMap.isEmpty()) {
              replaceKey = this.getReplaceKeyForRepeat(entry.getKey(), repeatAddressMap);
            }
            if (StringUtils.isEmpty(replaceKey)) {
              // replace対象がなかった場合、取得に失敗した場合は元のセルに対して処理を実施する
              replaceKey = entry.getKey();
            }
            setCellValue(mstReport, baseSheet, entry, replaceKey, dataType, isImage);
          });

    // tmplRepeat要素情報を取得する(tmplRepeat要素は1つしか存在しないため、どのparam要素情報から取得してもOK)
    Optional<ReportXmlTmplRepeat> tmplRepeat = params.stream()
      .filter(ReportXmlParam::isTmplRepeat)
      .map(ReportXmlParam::getReportXmlTmplRepeat)
      .findFirst();

    boolean isDirectionX = tmplRepeat.map(p -> ReportXmlTmplRepeat.DIRECTION_Z.equals(p.getDirection())).orElse(false);
    int tmplOffset = tmplRepeat.map(p -> ReportUtils.getTmplOffset(p.getId(), true)).orElse(0);
    int tmplOffsetCol = tmplRepeat.map(p -> ReportUtils.getTmplOffset(p.getId(), false)).orElse(0);
    boolean tmplIsNewPage = tmplRepeat.map(p -> ReportXmlTmplRepeat.IS_NEW_PAGE_YES.equals(p.getIsNewPage())).orElse(false);

    List<ReportXmlGroup> groupNewPageList =
      params.stream().filter(p -> p.getReportXmlGroup() != null && p.getReportXmlGroup().getIsNewPage() == 1)
      .map(ReportXmlParam::getReportXmlGroup)
      .toList();

    int pageCount = 1;
    // mod #10691 【デグレ】パラメータ改頁設定が機能していない 高 start
    List<ReportXmlParam> filtered = params.stream()
      .filter(p -> p.getReportXmlGroup() == null)
      .filter(p -> {
        String t = p.getIsInTmpl();
        return "0".equals(t) || StringUtils.isEmpty(t);
      })
      .filter(p -> "1".equals(p.getIsNewPage()))
      .collect(Collectors.toList());
    boolean parFlag = filtered.size() != 0 ? true : false;
    if (tmplIsNewPage || !groupNewPageList.isEmpty() || parFlag) {
//    if (tmplIsNewPage || !groupNewPageList.isEmpty()) {
      // mod #10691 【デグレ】パラメータ改頁設定が機能していない 高 end
      pageCount = this.getPageCount(reportOutputInfo);
    }
    // add #11535 帳票の汎用バーコード出力対応 吉 start
    Map<String,String> funcCellMap = new HashMap<>();
    // add #11535 帳票の汎用バーコード出力対応 吉 end
    // ページごとに異なる項目を埋め込む
    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      final String pagePrefix = String.format("%d%s", pageIndex + 1, MULTIPLE_PAGES_SEPARATOR);
      // Copy sheet from baseModelSheet
      try {
        // Create a new sheet
        int newSheetIndex = workSheets.addCopy(baseSheet.getIndex());
        Worksheet destSheet = workSheets.get(newSheetIndex);
        destSheet.setName(String.format("%s%d", SHEET_NAME_PREFIX, pageIndex + 1));
        if(StringUtils.isEmpty(firstEditSheetName)) {
          firstEditSheetName = String.format("%s%d", SHEET_NAME_PREFIX, pageIndex + 1);
        }
        // copy infos from base sheet, including PageSetup(means property print area has been copied too)
        Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
          .filter(entry -> entry.getKey().startsWith(pagePrefix))
          .forEach(entry -> {
            final String key = entry.getKey().substring(pagePrefix.length());
            // 対象項目の設定を取得
            String dataType = ReportXmlParam.DATA_TYPE_STRING;
            boolean isImage = false;
            ReportXmlParam targetParam = ReportUtils.getTargetParam(params, key);
            if (targetParam != null) {
              dataType = targetParam.getDataType();
              isImage = StringUtils.equals("true", targetParam.getIsImage());
            }
            String replaceKey = null;
            if (tmplRepeat.isPresent() && key.startsWith(tmplRepeat.get().getId())) {
              // テンプレート内項目の処理
              if (!repeatAddressMap.isEmpty()) {
                // テンプレート内の繰り返し設定がある場合、貼り付けセルを取得
                replaceKey = this.getReplaceKey(key, repeatAddressMap);
              }
              if (StringUtils.isEmpty(replaceKey)) {
                // 対象がなかった場合、取得に失敗した場合は元のセルに対して処理を実施する
                replaceKey = key;
              }
              // テンプレート繰り返し内でのデータ貼り付けセルを取得
              // add #12157 帳票のデータ項目でpat_eventの内部ファイルパスが出力される limingzhe start
              if(isImage) {
                // データが画像の場合
                String path = entry.getValue();
                if (StringUtils.isNotEmpty(path)) {
                  // Getting images from S3 service
                  String bucket = String.format(s3BucketForImage, mstReport.getFacilityCd());
                  byte[] excelBytes = reportS3Service.getOutputFileData(bucket, path);
                  CellRangeAddress cellAddresses = AsposeExcelUtil.getCellAddressOfPositionInTmpl(baseSheet, replaceKey, isDirectionX
                    , tmplOffset, tmplOffsetCol, tmplRepeat);
                  try {
                    addPicture(destSheet, cellAddresses, new ByteArrayInputStream(excelBytes));
                  } catch (Exception ex) {
                    // エラーメッセージ
                    EventLogMessage eventLogMessage = new EventLogMessage();
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                    eventLogMessage.setLogMessage("asposeでグラフのINSERTはエラー：" + ExcetionStackTraceToString(ex));
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                    logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                  }
                }
              }
              else {
              // add #12157 帳票のデータ項目でpat_eventの内部ファイルパスが出力される limingzhe end
                Cell targetCell = AsposeExcelUtil.getFirstCellOfPosition(destSheet, replaceKey, isDirectionX
                  , tmplOffset, tmplOffsetCol, tmplRepeat);
                setCellValueByType(targetCell, entry.getValue(), dataType);
              // add #12157 帳票のデータ項目でpat_eventの内部ファイルパスが出力される limingzhe start
              }
              // add #12157 帳票のデータ項目でpat_eventの内部ファイルパスが出力される limingzhe end
            }
            else {
              // テンプレート外項目の処理
              if (!repeatAddressMap.isEmpty()) {
                // 繰り返し設定がある場合、貼り付けセルを取得
                replaceKey = this.getReplaceKeyForRepeat(key, repeatAddressMap);
              }
              if (StringUtils.isEmpty(replaceKey)) {
                // 対象がなかった場合、取得に失敗した場合は元のセルに対して処理を実施する
                replaceKey = key;
              }
              this.setCellValue(mstReport, destSheet, entry, replaceKey, dataType, isImage);
            }
          });
        stdCopyStyleFromCells(destSheet, repeatAddressMap);
        if (tmplRepeat.isPresent()) {
          copyStyleFromTmpl(destSheet, tmplRepeat,ReportConstant.ReportClass.ONE_PATIENT_REPORT);
        }
        // Excel関数を埋め込む
        List <Integer> repCountList = new LinkedList<>();
        // mod #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe start
        Map<String, String> reportOutputInfobyPage = reportOutputInfo.entrySet().stream()
          .filter(entry -> entry.getKey().startsWith(pagePrefix))
          .collect(Collectors.toMap(entry -> entry.getKey(), entry -> entry.getValue()));
        //for (Map.Entry<String, String> entry : reportOutputInfo.entrySet())
        for (Map.Entry<String, String> entry : reportOutputInfobyPage.entrySet())
        // mod #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe end
        {
          String key = entry.getKey();
          if (key.contains(".")) {
            String key1 = key.split("\\.")[0];
            int repCount1 = Integer.parseInt(key1.split("-")[1]);
            if(!repCountList.contains(repCount1)){
              repCountList.add(repCount1);
            }
          }
        }

        // add #10447 テンプレート繰返しでの計算式繰返しの制限事項対応③（項目指定とセル指定の混在）高 start
        // 2つのMap（帳票出力結果 + 計算結果）を結合し、指定ページPrefixのキーのみを対象とする
        Stream<Map.Entry<String, String>> streamMapNew =
          Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
            .filter(e -> e.getKey().startsWith(pagePrefix));
        // 各キー・値ペアを処理
        streamMapNew.forEach(e -> {
          // 帳票パラメータ単位でループ
          for (ReportXmlParam param : params) {
            // 関数を持たないパラメータは対象外
            if (!param.hasFunction()) continue;
            // 対象セル（テンプレート上の基準セル）を取得
            Cell targetCell = AsposeExcelUtil.getFirstCellOfPosition(destSheet, param.getId());
            if (targetCell == null) continue;
            /**
             * 以下条件すべて満たす場合のみ処理対象：
             *
             * ① キーにparam IDが含まれている（対象セルとの紐付け）
             * ② param側の関数が「セル参照を含む演算式」である
             * ③ 値側が "formula=" 形式である（＝数式として扱う必要あり）
             * ④ 値側の数式も「セル参照を含む演算式」である
             */
            if (e.getKey().contains(param.getId())
              && hasConcatCellReference(param.getFunction())
              && e.getValue().contains("formula=")
              && hasConcatCellReference(e.getValue().replace("formula=", ""))) {
              // 繰り返しが存在しない場合は、元セルにそのまま関数を設定
              if (repCountList.size() == 0) {
                // mod #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe start
                //targetCell.setFormula(param.getFunction());
                try {
                  targetCell.setFormula(param.getFunction());
                } catch (Exception ex) {
                  targetCell.setFormula(null);
                  targetCell.setValue(" ");
                }
                // mod #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe end
              }
              // キーからインデックス（繰り返し番号）を取得
              int index = getIndexFromKey(e.getKey());
              // 繰り返し回数分ループ
              for (int i = 0; i < repCountList.size(); i++) {
                // 対象インデックスと一致しない場合はスキップ
                if (index != repCountList.get(i)) {
                  continue;
                }
                // 元セル位置をアドレスとして保持
                CellRangeAddress tempAddress = new CellRangeAddress(
                  targetCell.getRow(),
                  targetCell.getRow(),
                  targetCell.getColumn(),
                  targetCell.getColumn()
                );
                // 繰り返し用キーを生成（テンプレートID + 繰り返し番号 + セル位置）
                String key1 = param.getReportXmlTmplRepeat().getId()
                  + "-" + repCountList.get(i)
                  + "." + tempAddress.formatAsString();
                // 実際に書き込む対象セル（繰り返し後のセル）を取得
                Cell lastCell = AsposeExcelUtil.getFirstCellOfPosition(
                  destSheet, key1, isDirectionX, tmplOffset, tmplOffsetCol, tmplRepeat
                );
                // 数式内のセル参照位置を、コピー先セルに合わせて変換
                String formula = AsposeExcelUtil.changeFormulaLocation(
                  targetCell,
                  lastCell,
                  e.getValue().replace("formula=", ""),
                  param.getReportXmlTmplRepeat().getId()
                );
                // スタイルをコピー
                lastCell.setStyle(targetCell.getStyle());
                // del #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe start
//                // バーコード対象セルの場合はマッピングを保持
//                if (param.getBarCode() != null) {
//                  funcCellMap.put(lastCell.getName(), param.getId());
//                }
                // del #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe end
                // 数式設定（失敗時は空白設定）
                try {
                  lastCell.setFormula(formula);
                } catch (Exception ex) {
                  lastCell.setFormula(null);
                  lastCell.setValue(" ");
                }
              }
              // paramループを抜ける（該当paramは1つのみ想定）
              break;
            }
          }
        });
        // add #10447 テンプレート繰返しでの計算式繰返しの制限事項対応③（項目指定とセル指定の混在）高 end

        final List<Integer> lastRepCount = new ArrayList<>(repCountList);
        // mod #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe start
        // バーコード対象セルの場合はマッピングを保持
        funcCellMap.putAll(formulaCalculateForParams(baseWorkbook, destSheet, params, lastRepCount));
        // mod #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe end
        // add #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe start
        if (tmplRepeat.isPresent()) {
          // テンプレート繰返しでの計算式繰返し（「=」で始まる計算式）
          List<String> paramIdInTmpl = params.stream().filter(p -> p.isTmplRepeat()).map(p -> p.getId()).collect(toList());
          formulaCalculateFromTmpl(destSheet, tmplRepeat.get(), paramIdInTmpl, lastRepCount.size());
        }
        // add #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe end
        // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 start
        //qrコード
        Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
          .forEach(entry -> {
            if(entry.getKey().startsWith(pagePrefix)){
              final String key = entry.getKey().substring(pagePrefix.length());
              Map<String,String> qrCodeCell =  params.stream()
                .filter(p -> !StringUtils.isEmpty(p.getDataCode()) && p.getDataCode().equals("qrCode"))
                .collect(Collectors.toMap(m -> m.getId() , m -> m.getColWidth() + "-" + m.getRowHeight()));
              if(null != qrCodeCell && qrCodeCell.size()>0){
                for(Map.Entry<String, String> entry1 : qrCodeCell.entrySet()){
                  if(entry1.getKey().equals(key)){
                    createQRPic(entry1.getValue(),key,destSheet,entry.getValue());
                  }
                }
              }
            }else{
              Map<String,String> qrCodeForNewOne =  params.stream()
                .filter(p -> !StringUtils.isEmpty(p.getDataCode()) && p.getDataCode().equals("qrCodeForNewOne"))
                .collect(Collectors.toMap(m -> m.getId() , m -> m.getColWidth() + "-" + m.getRowHeight()));
              if(null != qrCodeForNewOne && qrCodeForNewOne.size()>0){
                for(Map.Entry<String, String> entry1 : qrCodeForNewOne.entrySet()){
                  if(entry1.getKey().equals(entry.getKey())){
                    createQRPic(entry1.getValue(),entry.getKey(),destSheet,entry.getValue());
                  }
                }
              }
            }
          });
        // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 end
      } catch (Exception e) {
        // エラーメッセージ
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        eventLogMessage.setLogMessage("asposeでグラフのINSERTはエラー：" + ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    } // End Loop for pages
    // レイアウトシートを削除
    workSheets.removeAt(baseSheet.getIndex());
    if(StringUtils.isNotEmpty(firstEditSheetName)) {
      workSheets.setActiveSheetName(firstEditSheetName);
    }
    // 全シート計算式を再計算
    // del #11755 「##=」でstring型を参照すると空値のときにnullと出る start
//    baseWorkbook.calculateFormula();
    // del #11755 「##=」でstring型を参照すると空値のときにnullと出る end
    // add #11535 帳票の汎用バーコード出力対応 吉 start
    Map<String, String> templInFuncQRInfoList = params.stream()
      .filter(p -> p.getDataCode() != null && !"".equals(p.getBarCode()) && p.isTmplRepeat())
      .collect(Collectors.toMap(
        ReportXmlParam::getId,
        p -> p.getBarCode() + "-" + p.getColWidth() + "-" + p.getRowHeight()
      ));
    Map<String, String> templOutFuncQRInfoList = params.stream()
      .filter(p -> p.getDataCode() != null && !"".equals(p.getBarCode()) && !p.isTmplRepeat())
      .collect(Collectors.toMap(
        ReportXmlParam::getId,
        p -> p.getBarCode() + "-" + p.getColWidth() + "-" + p.getRowHeight()
      ));
    if(templInFuncQRInfoList.size()>0){
      WorksheetCollection worksheets = baseWorkbook.getWorksheets();
      for (int i = 0; i < worksheets.getCount(); i++) {
        Worksheet sheet = worksheets.get(i);
        int visibility = sheet.getVisibilityType();
        //（0 表示 visible）
        if (visibility == VisibilityType.VISIBLE && !"レイアウト".equals(sheet.getName())) {
          for(Map.Entry<String, String> entry1 : templInFuncQRInfoList.entrySet()){
            if(null != funcCellMap && funcCellMap.size() > 0){
              for(Map.Entry<String, String> funcEntry : funcCellMap.entrySet()){
                if(funcEntry.getValue().equals(entry1.getKey())){
                  String cellId = funcEntry.getKey();
                  Cell cell = AsposeExcelUtil.getFirstCellOfPosition(sheet, cellId);
                  String valueToBarCode = String.valueOf(cell.getValue());
                  if(StringUtils.isEmpty(valueToBarCode) || StringUtils.isEmpty(valueToBarCode.strip()) || "null".equals(valueToBarCode)){
                    continue;
                  }
                  String[] arr = entry1.getValue().split("-");
                  try {
                    CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(sheet, cellId);
                    int firstRow = cellRange.getFirstRow();
                    int firstCol = cellRange.getFirstColumn();
                    Cell targetCell = sheet.getCells().get(firstRow, firstCol);
                    Style style = targetCell.getStyle();
                    int rotation = style.getRotationAngle();
                    BufferedImage qrCodeImage;
                    if(rotation == 90){
                      qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[2]) * 1.3333),(int)(Integer.valueOf(arr[1]) * 1.3333));
                      qrCodeImage = rotateImage(qrCodeImage, -rotation);
                    }else {
                      qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[1]) * 1.3333),(int)(Integer.valueOf(arr[2]) * 1.3333));
                    }
                    ByteArrayOutputStream baos = new ByteArrayOutputStream();
                    ImageIO.write(qrCodeImage, "PNG", baos);

                    if(getMergedArea(sheet, cell.getRow(), cell.getColumn()) != null){
                      CellArea area = getMergedArea(sheet, cell.getRow(), cell.getColumn());
                      CellRangeAddress cellRange1 = new CellRangeAddress(area.StartRow,area.EndRow,area.StartColumn,area.EndColumn);
                      addPicture(sheet, cellRange1, new ByteArrayInputStream(baos.toByteArray()));
                    }else{
                      CellRangeAddress cellRange1 = AsposeExcelUtil.getCellRange(sheet, cellId);
                      addPicture(sheet, cellRange1, new ByteArrayInputStream(baos.toByteArray()));
                    }
                  }catch (Exception e){
                    continue;
                  }
                }
              }
            }else{
              String cellId = entry1.getKey();
              Cell cell = AsposeExcelUtil.getFirstCellOfPosition(sheet, cellId);
              String valueToBarCode = String.valueOf(cell.getValue());
              if(StringUtils.isEmpty(valueToBarCode) || StringUtils.isEmpty(valueToBarCode.strip()) || "null".equals(valueToBarCode)){
                continue;
              }
              String[] arr = entry1.getValue().split("-");
              try {
                CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(sheet, cellId);
                int firstRow = cellRange.getFirstRow();
                int firstCol = cellRange.getFirstColumn();
                Cell targetCell = sheet.getCells().get(firstRow, firstCol);
                Style style = targetCell.getStyle();
                int rotation = style.getRotationAngle();
                BufferedImage qrCodeImage;
                if(rotation == 90){
                  qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[2]) * 1.3333),(int)(Integer.valueOf(arr[1]) * 1.3333));
                  qrCodeImage = rotateImage(qrCodeImage, -rotation);
                }else {
                  qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[1]) * 1.3333),(int)(Integer.valueOf(arr[2]) * 1.3333));
                }
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                ImageIO.write(qrCodeImage, "PNG", baos);
                addPicture(sheet, cellRange, new ByteArrayInputStream(baos.toByteArray()));
              }catch (Exception e){
                continue;
              }
            }
          }
        }
      }
    }
    if(templOutFuncQRInfoList.size()>0){
      WorksheetCollection worksheets = baseWorkbook.getWorksheets();
      for (int i = 0; i < worksheets.getCount(); i++) {
        Worksheet sheet = worksheets.get(i);
        int visibility = sheet.getVisibilityType();
        if (visibility == VisibilityType.VISIBLE){
          for(Map.Entry<String, String> entry1 : templOutFuncQRInfoList.entrySet()){
            String cellId = entry1.getKey();
            Cell cell = AsposeExcelUtil.getFirstCellOfPosition(sheet, cellId);
            String valueToBarCode = String.valueOf(cell.getValue());
            if(StringUtils.isEmpty(valueToBarCode) || StringUtils.isEmpty(valueToBarCode.strip()) || "null".equals(valueToBarCode)){
              continue;
            }
            String[] arr = entry1.getValue().split("-");
            try {
              CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(sheet, cellId);
              int firstRow = cellRange.getFirstRow();
              int firstCol = cellRange.getFirstColumn();
              Cell targetCell = sheet.getCells().get(firstRow, firstCol);
              Style style = targetCell.getStyle();
              int rotation = style.getRotationAngle();
              BufferedImage qrCodeImage;
              if(rotation == 90){
                qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[2]) * 1.3333),(int)(Integer.valueOf(arr[1]) * 1.3333));
                qrCodeImage = rotateImage(qrCodeImage, -rotation);
              }else {
                qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int)(Integer.valueOf(arr[1]) * 1.3333),(int)(Integer.valueOf(arr[2]) * 1.3333));

              }
              ByteArrayOutputStream baos = new ByteArrayOutputStream();
              ImageIO.write(qrCodeImage, "PNG", baos);
              addPicture(sheet, cellRange, new ByteArrayInputStream(baos.toByteArray()));
            }catch (Exception e){
              continue;
            }
          }
        }
      }
    }
    // add #11535 帳票の汎用バーコード出力対応 吉 end
    return baseWorkbook;
  }


  public static BufferedImage rotateImage(BufferedImage img, double angleDegrees) {
    double radians = Math.toRadians(angleDegrees);
    double sin = Math.abs(Math.sin(radians));
    double cos = Math.abs(Math.cos(radians));
    int w = img.getWidth();
    int h = img.getHeight();
    int newWidth = (int) Math.floor(w * cos + h * sin);
    int newHeight = (int) Math.floor(h * cos + w * sin);

    BufferedImage rotated = new BufferedImage(newWidth, newHeight, img.getType());
    Graphics2D g2d = rotated.createGraphics();
    g2d.translate((newWidth - w) / 2, (newHeight - h) / 2);
    g2d.rotate(radians, w / 2, h / 2);
    g2d.drawRenderedImage(img, null);
    g2d.dispose();
    return rotated;
  }

  /**
   * 帳票マスタ情報を取得する
   * @param reportCd  ID
   * @return  帳票マスタ
   */
  protected MstReport getMstReport(Long reportCd) {
    try {
      return this.mstReportDao.selectByCd(reportCd);
    } catch (EmptyResultDataAccessException erException) {
      // エラーメッセージ
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage("There is no MstReport:" + ExcetionStackTraceToString(erException));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      throw new NotExistException("テンプレートがない");
    }
  }

  /**
   * 帳票マスタ設定を取得する
   * @param mstReport     帳票マスタ
   * @param reportZipFile Zipフェール
   * @return  帳票マスタ設定
   */
  private Workbook getReportWorkbook(MstReport mstReport, ReportZipFile reportZipFile) {
    // エクセルファイルを取得
    byte[] excelData = reportZipFile.getFile(mstReport.getReportPath().getXlsxFilename());
    if (excelData != null && excelData.length > 0) {
      try (InputStream is = new ByteArrayInputStream(excelData)) {
        return new Workbook(is);
      } catch (Exception e) {
        // エラーメッセージ
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        eventLogMessage.setLogMessage("帳票デザインExcelファイルを取得できません:" + ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        throw new NtssException("帳票デザインExcelファイルを取得できません。", e);
      }
    } else {
      throw new NotExistException("帳票デザインExcelファイルを取得できません。");
    }
  }

  /**
   * ページ総数を取得します.
   *
   * @param reportOutputInfo 帳票出力情報
   * @return ページ総数
   */
  private int getPageCount(Map<String, String> reportOutputInfo) {
    return Optional
      .ofNullable(reportOutputInfo)
      .orElse(new HashMap<>())
      .keySet()
      .stream()
      .filter(r -> r.contains(MULTIPLE_PAGES_SEPARATOR))
      .map(r -> Integer.parseInt(r.substring(0, r.indexOf(MULTIPLE_PAGES_SEPARATOR))))
      .max(Comparator.naturalOrder())
      .orElse(1);
  }

  /**
   * keyを取得する.
   *
   * @param key key
   * @param repeatAddressMap ReplaceKeyMap
   */
  private String getReplaceKey(String key, Map<String, String> repeatAddressMap) {
    String replaceKey = null;

    String[] keyIds = key.split("\\.");
    String keyId = keyIds.length == 2 ? keyIds[1] : keyIds[0];

    String[] cellAdds = keyId.split("-");

    if (cellAdds.length == 2 && !repeatAddressMap.isEmpty()) {
      final String cellAddress = cellAdds[0];
      final int cellAddrIndex = Integer.parseInt(cellAdds[1]);

      Map.Entry<String, String> cellAddressExcel = repeatAddressMap.entrySet()
        .stream()
        .filter(entry -> StringUtils.equals(entry.getKey(), cellAddress))
        .findFirst()
        .orElse(null);

      if (cellAddressExcel != null) {
        String[] repeatAdders = cellAddressExcel.getValue().split(",");
        if (cellAddrIndex <= repeatAdders.length) {
          String tempKey = key.replace(cellAddress, repeatAdders[cellAddrIndex - 1]);
          String[] tempKeys = tempKey.split("-");
          if (tempKeys.length == 3) {
            replaceKey = tempKeys[0] + "-" + tempKeys[1];
          }
        }
      }
    }

    // 対象がなかった場合、取得に失敗した場合は元のセルに対して処理を実施する
    return StringUtils.isEmpty(replaceKey) ? key : replaceKey;
  }

  /**
   * keyを取得する(テンプレート繰り返しではない通常の繰り返し処理のデータ割り当て先keyを応答する).
   *
   * @param key key
   * @param repeatAddressMap ReplaceKeyMap
   */
  private String getReplaceKeyForRepeat(String key, Map<String, String> repeatAddressMap) {
    String replaceKey = null;
    // key から、map の key と index を取得
    String indexKey;
    int cellAddrIndex = 0;
    if(key.contains(".")){
      return null;
    }
    if (key.contains("-")) {
      String[] tmpStr = key.split("-");
      indexKey = tmpStr[0];
      cellAddrIndex = Integer.parseInt(tmpStr[1]) > 0 ? Integer.parseInt(tmpStr[1]) -1 : 0;
    } else {
      indexKey = key;
    }
    // key、index を元に、必要なキーを取得
    String str = repeatAddressMap.get(indexKey);
    if (str != null && str.contains(",")) {
      String[] repeatAddresses = str.split(",");
      if (cellAddrIndex < repeatAddresses.length) {
        replaceKey = repeatAddresses[cellAddrIndex];
      }else{
        int page = cellAddrIndex/repeatAddresses.length;
        replaceKey = repeatAddresses[cellAddrIndex - (repeatAddresses.length * page)];
      }
    }
    if (replaceKey == null) {
      // replace不要の場合
      replaceKey = key;
    }
    // 対象がなかった場合、取得に失敗した場合は元のセルに対して処理を実施する
    return StringUtils.isEmpty(replaceKey) ? key : replaceKey;
  }

  /**
   *　セルの編集
   * @param mstReport
   * @param sheet
   * @param entry
   * @param replaceKey
   * @param dataType
   * @param isImage
   * @param sheet
   */
  private void setCellValue(MstReport mstReport
    , Worksheet sheet
    , Map.Entry<String, String> entry
    , String replaceKey
    , String dataType
    , boolean isImage) {
    if (isImage) {
      // データが画像の場合
      String path = entry.getValue();
      if (StringUtils.isNotEmpty(path)) {
        // Getting images from S3 service
        String bucket = String.format(s3BucketForImage, mstReport.getFacilityCd());
        byte[] excelBytes = reportS3Service.getOutputFileData(bucket, path);
        CellRangeAddress cellAddresses = AsposeExcelUtil.getCellRange(sheet, replaceKey);
        try {
          addPicture(sheet, cellAddresses, new ByteArrayInputStream(excelBytes));
        } catch (Exception ex) {
          // エラーメッセージ
          EventLogMessage eventLogMessage = new EventLogMessage();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
          eventLogMessage.setLogMessage("asposeでグラフのINSERTはエラー：" + ExcetionStackTraceToString(ex));
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        }
      }
    }
    // その他、普通なデータ
    else {
      setCellValueByPositionAndType(sheet, replaceKey, entry.getValue(), dataType);
    }
  }

  /**
   * セルに値を設定します.
   *
   * @param sheet     シートセル
   * @param position  セル位置
   * @param value     値
   * @param dataType  データタイプ
   */
  private void setCellValueByPositionAndType(Worksheet sheet, String position, String value, String dataType) {
    // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
    if(!StringUtils.isEmpty(value) && value.matches("(?i)^data:image/.*;base64,.*")){
      imgForIntroductionReport(sheet, position, value);
    } else {
      // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
      Cell cell = AsposeExcelUtil.getFirstCellOfPosition(sheet, position);
      setCellValueByType(cell, value, dataType);
      // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
    }
    // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
  }

  /**
   * セルに値を設定します.
   *
   * @param cell セル
   * @param value 値
   * @param dataType データタイプ
   */
  private void setCellValueByType(Cell cell, String value, String dataType) {
    if (cell == null || StringUtils.isEmpty(value)
      || StringUtils.isEmpty(dataType) || StringUtils.equals("byte[]", dataType)) {
      return;
    }

    // 計算エラーの場合空白を表示する
    if (FAILED_CALC.equals(value)) {
      cell.setValue("");
    }
    else if (DISPLAY_HTML_ERROR.equals(value)) {
      cell.setValue(value);
    }
    // add #10447 テンプレート繰返しでの計算式繰返しの制限事項対応③（項目指定とセル指定の混在）高 start
    else if (value.contains("formula=")) {
      value = value.replace("formula=","");
      cell.setFormula(value);
    }
    // add #10447 テンプレート繰返しでの計算式繰返しの制限事項対応③（項目指定とセル指定の混在）高 end
    else {
      switch (dataType) {
        // データタイプ：数値
        case ReportXmlParam.DATA_TYPE_DECIMAL -> {
          try {
            // 治療経過表の透析時間「hh:mm」
            if (StringUtils.isNotEmpty(value) && value.contains(":")) {
              String[] tmpTimeChars = value.split(":");
              int minutes = Integer.parseInt(tmpTimeChars[0]) * 60 + Integer.parseInt(tmpTimeChars[1]);
              value = String.valueOf(minutes);
            }
            // 数値型でExcelに貼り付け
            cell.putValue(value, true);
          } catch (NumberFormatException e) {
            // 数値に変換できなかった場合は、文字列としてExcelに張り付け
            cell.setValue(value);
          }
        }
        // データタイプ：日付
        case ReportXmlParam.DATA_TYPE_DATE_TIME -> {
          // Excel側の書式を適用させる為、データを Date型に変換してから適用します (処理内容はformatValueに定義されていたもの)
          try {
            if (StringUtils.isNotEmpty(value)) {
              if (value.length() <= 5) {
                if(value.contains(":")) {
                  String[] tmpTimeChars = value.split(":");
                  int minutes = Integer.parseInt(tmpTimeChars[0]) * 60 + Integer.parseInt(tmpTimeChars[1]);
                  value = String.valueOf(minutes);
                }
                int displayHours = Integer.parseInt(value) / 60;
                int displayMinutes = Integer.parseInt(value) % 60;
                // 分数値を HH:MM 形式に変換する
                String time = String.format("%02d:%02d", displayHours, displayMinutes);

                // 時間の項目に書式が設定できないものがある
                if (null != cell.getStyle() && "[h]:mm".equals(cell.getStyle().getCustom())) {
                  cell.setValue(time);
                } else if (null != cell.getStyle() && "[h]:mm:ss".equals(cell.getStyle().getCustom())){
                  cell.setValue(time + ":00");
                } else if (null != cell.getStyle() && "[h]\"時間\"mm\"分\"ss\"秒\"".equals(cell.getStyle().getCustom())) {
                  cell.setValue(time.split(":")[0] + "時間" + time.split(":")[1] + "分" + "00秒");
                } else if (null != cell.getStyle() && "h\"時\"mm\"分\"ss\"秒\"".equals(cell.getStyle().getCustom())
                  || BuiltinFormats.getBuiltinFormat(33).equals(cell.getStyle().getCustom())) {
                  cell.setValue(Integer.valueOf(time.split(":")[0]) % 24 + "時" + time.split(":")[1] + "分00秒");
                } else if (null != cell.getStyle() && "[h]\"時間\"mm\"分\"".equals(cell.getStyle().getCustom())) {
                  cell.setValue(time.split(":")[0] + "時間" + time.split(":")[1] + "分");
                } else if (null != cell.getStyle() && "h\"時\"mm\"分\"".equals(cell.getStyle().getCustom())
                  || BuiltinFormats.getBuiltinFormat(32).equals(cell.getStyle().getCustom())) {
                  cell.setValue(Integer.valueOf(time.split(":")[0]) % 24 + "時" + time.split(":")[1] + "分");
                } else if (null != cell.getStyle() && "hh:mm".equals(cell.getStyle().getCustom())) {
                  int hourSplit = Integer.valueOf(time.split(":")[0]) % 24;
                  String minutesSplit = time.split(":")[1];
                  String timeIn24 = hourSplit  + ":" + minutesSplit;
                  if (hourSplit < 10) {
                    cell.setValue("0" + timeIn24);
                  } else {
                    cell.setValue(timeIn24);
                  }
                } else if (null != cell.getStyle() && "h:mm".equals(cell.getStyle().getCustom())) {
                  cell.setValue(Integer.valueOf(time.split(":")[0]) % 24 + ":" + time.split(":")[1]);
                } else if (null != cell.getStyle() && "h:mm:ss".equals(cell.getStyle().getCustom())) {
                  String timeIn24 = Integer.valueOf(time.split(":")[0]) % 24 + ":" + time.split(":")[1] + ":00";
                  cell.setValue(timeIn24);
                } else if (null != cell.getStyle() && "hh:mm:ss".equals(cell.getStyle().getCustom())) {
                  int hourSplit = Integer.valueOf(time.split(":")[0]) % 24;
                  String minutesSplit = time.split(":")[1];
                  String timeIn24 = hourSplit  + ":" + minutesSplit + ":00";
                  if (hourSplit < 10) {
                    cell.setValue("0" + timeIn24);
                  } else {
                    cell.setValue(timeIn24);
                  }
                }else if(null != cell.getStyle() && "h:mm\\ AM/PM".equals(cell.getStyle().getCustom())){
                  String timeIn24 = Integer.valueOf(time.split(":")[0]) % 24 + ":" + time.split(":")[1];
                  cell.setValue(timeIn24);
                } else {
                  SimpleDateFormat sdFormat = new SimpleDateFormat(cell.getStyle().getCustom());
                  Date dateStr = sdFormat.parse(time);
                  cell.setValue(dateStr);
                }
              }
              else if (value.length() == 8) {
                Date date = new SimpleDateFormat("yyyyMMdd").parse(value);
                cell.setValue(date);
              }
              else {
                if(value != null && value.length() > 10) {
                  if (" ".equals(value.substring(10,11))) {
                    // yyyy/MM/dd HH:mm
                    if(value.contains("/") && !value.contains("ss")) {
                      value = value.replace("/", "-");
                      SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                      Date dateStr = sf.parse(value);
                      cell.setValue(dateStr);
                    }
                    else{
                      SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
                      Date dateStr = sf.parse(value);
                      cell.setValue(dateStr);
                    }
                  }else if (!value.contains(":")) {
                    SimpleDateFormat sf = new SimpleDateFormat("yyyyMMddHHmmss");
                    // add #11554 データクラス「指示履歴」の仕様変更 sunsy start
                    if (value.length() > 14) {
                      value = value.substring(0, 14);
                    }
                    // add #11554 データクラス「指示履歴」の仕様変更 sunsy end
                    Date dateStr = sf.parse(value);
                    cell.setValue(dateStr);
                  }else {
                    SimpleDateFormat sf = new SimpleDateFormat(CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601);
                    Date dateStr = sf.parse(value);
                    cell.setValue(dateStr);
                  }
                }else{
                  // yyyy/MM/dd
                  if(value.contains("/")) {
                    value = value.replace("/", "-");
                  }
                  SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
                  Date dateStr = df.parse(value);
                  cell.setValue(dateStr);
                }
              }
            }
          } catch (Exception e) {
            cell.setValue(value);
          }
        }
        // その他
        default -> {
          if (StringUtils.isNotEmpty(value)) {
            if (value != null && value.contains("\uFEFF")) {
              value = value.replace("\uFEFF", "");
            }
            if(value.contains("\n")){
              cell.getStyle().setTextWrapped(true);
            }
            // del #12323 【因島】データ内に「改行コード」があると文字数制限の行送り時に文字が欠損する limingzhe start
//            if(value.contains("#b")){
//              value = value.replaceAll("#b","");
//            }
            // del #12323 【因島】データ内に「改行コード」があると文字数制限の行送り時に文字が欠損する limingzhe end
            // del #11513 患者名が指定文字数ぶん出ない 高 start
//            if(value.contains(" ")){
//              value = value.replaceAll(" ","");
//            }
            // del #11513 患者名が指定文字数ぶん出ない 高 end
            cell.setValue(value);
          }
        }
      }
    }
  }

  /**
   * テンプレート繰り返し個所の値、スタイルコピー：繰り返し元のセルの値、スタイル、結合状態をテンプレート繰り返しの回数分コピーする.
   * @param sheet
   * @param tmplRepeat
   * @param reportClass
   */
  private void copyStyleFromTmpl(Worksheet sheet, Optional<ReportXmlTmplRepeat> tmplRepeat, Integer reportClass) {
    Cells baseCells = sheet.getCells();
    // テンプレート文字列が空の場合は処理をスキップ
    if (StringUtils.isEmpty(tmplRepeat.get().getId())) {
      return;
    }
    // テンプレート設定を取得
    // 繰返回数(縦)
    int repeatCount_V = tmplRepeat.get().getRepeatCountV();
    // 繰返回数(横)
    int repeatCount_H = tmplRepeat.get().getRepeatCountH();

    if (repeatCount_V <= 1 && repeatCount_H <= 1) {
      // 繰り返し回数がどちらも1回の場合は実施不要
      return;
    }
    // テンプレート範囲を取得
    String[] idFT = tmplRepeat.get().getId().split(":");
    if (idFT.length == 2) {
      // テンプレート範囲の取得
      CellRangeAddress tmplRange = CellRangeAddress.valueOf(tmplRepeat.get().getId());
      // テンプレート範囲の開始Column
      int tmplColFrom = tmplRange.getFirstColumn();
      // テンプレート範囲の終了Column
      int tmplColTo = tmplRange.getLastColumn();
      // テンプレート範囲のColumn数
      int tmplColCount = tmplColTo - tmplColFrom + 1;
      // テンプレート範囲の開始Row
      int tmplRowFrom = tmplRange.getFirstRow();
      // テンプレート範囲の終了Row
      int tmplRowTo = tmplRange.getLastRow();
      // テンプレート範囲のRow数
      int tmplRowCount = tmplRowTo - tmplRowFrom + 1;
      // 余白(縦)
      int marginV = tmplRepeat.get().getMarginV();
      // 余白(横)
      int marginH = tmplRepeat.get().getMarginH();
      // style、value のコピー
      for (int rCount = tmplRowFrom; rCount <= tmplRowTo; rCount++) {
        for (int cCount = tmplColFrom; cCount <= tmplColTo; cCount++) {
          Cell sourceCell = baseCells.get(rCount, cCount);
          if (ReportXmlTmplRepeat.DIRECTION_Z.equals(String.valueOf(tmplRepeat.get().getDirection()))) {
            // Z方向
            for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
              for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
                if (hCount == 1 && vCount == 1) {
                  // コピー先が同じテンプレート範囲の為除外
                  continue;
                }
                templateCopyHandle(baseCells, sourceCell, rCount, cCount, tmplRowCount, tmplColCount
                  ,marginV, marginH, vCount, hCount, reportClass);
              }
            }
          } else {
            // N方向
            for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
              for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
                if (hCount == 1 && vCount == 1) {
                  // コピー先が同じテンプレート範囲の為除外
                  continue;
                }
                templateCopyHandle(baseCells, sourceCell, rCount, cCount, tmplRowCount, tmplColCount
                    ,marginV, marginH, vCount, hCount, reportClass);
              }
            }
          }
        }
      }
    } else {
      String cellReference= tmplRepeat.get().getId();
      // セル参照を解析します
      CellReference ref = new CellReference(cellReference);

      // 列と行のインデックスを取得します
      int rowIndex = ref.getRow();
      int colIndex = ref.getCol();
      Cell sourceCell = baseCells.get(rowIndex, colIndex);
      if (ReportXmlTmplRepeat.DIRECTION_Z.equals(String.valueOf(tmplRepeat.get().getDirection()))) {
        // Z方向
        for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
          for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
            if (hCount == 1 && vCount == 1) {
              // コピー先が同じテンプレート範囲の為除外
              continue;
            }
            templateCopySampleHandle(baseCells, sourceCell, rowIndex, colIndex, vCount, hCount, reportClass);
          }
        }
      } else {
        // N方向
        for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
          for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
            if (hCount == 1 && vCount == 1) {
              // コピー先が同じテンプレート範囲の為除外
              continue;
            }
            templateCopySampleHandle(baseCells, sourceCell, rowIndex, colIndex, vCount, hCount, reportClass);
          }
        }
      }
    }
  }

  /**
   * テンプレートのコピーを行う
   * @param baseCells
   * @param sourceCell
   * @param rowIndex
   * @param colIndex
   * @param vCount
   * @param hCount
   */
  private void templateCopySampleHandle(Cells baseCells, Cell sourceCell, int rowIndex, int colIndex, int vCount, int hCount, Integer reportClass) {
    // コピー先セルを取得
    int tmpRowNo = rowIndex + (vCount -1);
    int tmpColNo = colIndex + (hCount - 1);
    Cell targetCell = baseCells.get(tmpRowNo, tmpColNo);
    CellArea targetMergeCellArea = getMergedCell(baseCells, targetCell);
    if(targetMergeCellArea != null) {
      baseCells.unMerge(targetMergeCellArea.StartRow, targetMergeCellArea.StartColumn
        ,targetMergeCellArea.EndRow - targetMergeCellArea.StartRow + 1
        ,targetMergeCellArea.EndColumn - targetMergeCellArea.StartColumn + 1);
    }
    if (reportClass.equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)) {
      targetCell.setStyle(copyStyle(sourceCell.getStyle(), targetCell.getStyle(), baseCells.getFirstCell().getWorksheet()));
    } else if(targetCell != null && targetCell.getType() != CellValueType.IS_NULL) {
      targetCell.setStyle(copyStyle(sourceCell.getStyle(), targetCell.getStyle(), baseCells.getFirstCell().getWorksheet()));
    }
  }

  /**
   * テンプレートのコピーを行う
   * @param baseCells
   * @param sourceCell
   * @param rCount
   * @param cCount
   * @param tmplRowCount
   * @param tmplColCount
   * @param marginV
   * @param marginH
   * @param vCount
   * @param hCount
   */
  private void templateCopyHandle(Cells baseCells, Cell sourceCell, int rCount, int cCount, int tmplRowCount, int tmplColCount
      ,int marginV, int marginH, int vCount, int hCount, Integer reportClass) {
    // コピー先セルを取得
    int tmpRowNo = rCount + (tmplRowCount + marginV) * (vCount - 1);
    int tmpColNo = cCount + (tmplColCount + marginH) * (hCount - 1);
    Cell targetCell = baseCells.get(tmpRowNo, tmpColNo);
    CellArea baseMergeCellArea = getMergedCell(baseCells, sourceCell);
    CellArea targetMergeCellArea = getMergedCell(baseCells, targetCell);
    if(targetMergeCellArea != null) {
      if(baseMergeCellArea == null) {
        baseCells.unMerge(targetMergeCellArea.StartRow, targetMergeCellArea.StartColumn
          ,targetMergeCellArea.EndRow - targetMergeCellArea.StartRow + 1
          ,targetMergeCellArea.EndColumn - targetMergeCellArea.StartColumn + 1);
      } else {
        // mod #11615 テンプレート範囲のセル結合状態が繰り返し先と異なっていると出力結果が空白になる 高 start
//        if((targetMergeCellArea.StartRow - baseMergeCellArea.StartRow) != (targetCell.getRow() - sourceCell.getRow())
//          || (targetMergeCellArea.EndColumn - baseMergeCellArea.EndColumn) != (targetCell.getColumn() - sourceCell.getColumn())) {
        if((targetMergeCellArea.StartRow - baseMergeCellArea.StartRow) != (targetCell.getRow() - sourceCell.getRow())
          || (targetMergeCellArea.EndRow - baseMergeCellArea.EndRow) != (targetCell.getRow() - sourceCell.getRow())
          || (targetMergeCellArea.EndColumn - baseMergeCellArea.EndColumn) != (targetCell.getColumn() - sourceCell.getColumn())
          || (targetMergeCellArea.EndColumn - baseMergeCellArea.EndColumn) != (targetCell.getColumn() - sourceCell.getColumn())) {
          // mod #11615 テンプレート範囲のセル結合状態が繰り返し先と異なっていると出力結果が空白になる 高 end
          baseCells.unMerge(targetMergeCellArea.StartRow, targetMergeCellArea.StartColumn
            ,targetMergeCellArea.EndRow - targetMergeCellArea.StartRow + 1
            ,targetMergeCellArea.EndColumn - targetMergeCellArea.StartColumn + 1);
        }
      }
    }
    if (reportClass.equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)) {
      targetCell.setStyle(copyStyle(sourceCell.getStyle(), targetCell.getStyle(), baseCells.getFirstCell().getWorksheet()));
    } else if(targetCell != null && targetCell.getType() != CellValueType.IS_NULL) {
      targetCell.setStyle(copyStyle(sourceCell.getStyle(), targetCell.getStyle(), baseCells.getFirstCell().getWorksheet()));
    }
    if(baseMergeCellArea != null) {
      if(sourceCell.getColumn() == baseMergeCellArea.EndColumn && sourceCell.getRow() == baseMergeCellArea.EndRow) {
        int rowOffset = targetCell.getRow() - sourceCell.getRow();
        int columnOffset = targetCell.getColumn() - sourceCell.getColumn();
        baseCells.merge(baseMergeCellArea.StartRow + rowOffset, baseMergeCellArea.StartColumn + columnOffset
          ,baseMergeCellArea.EndRow - baseMergeCellArea.StartRow + 1
          ,baseMergeCellArea.EndColumn - baseMergeCellArea.StartColumn + 1);
      }
    }
    //　行の高さを設定
    baseCells.getRows().get(targetCell.getRow()).setHeight(baseCells.getRowHeight(sourceCell.getRow()));
    // 列の幅さを設定
    baseCells.getColumns().get(targetCell.getColumn()).setWidth(baseCells.getColumnWidth(sourceCell.getColumn()));
  }

  /**
   * ンプレート繰り返しの元テンプレートの罫線を除くスタイルと、結合状態をコピー
   * @param sheet
   * @param repeatAddressMap
   */
  private void stdCopyStyleFromCells(Worksheet sheet, Map<String, String> repeatAddressMap) {
    if (repeatAddressMap != null && repeatAddressMap.size() > 0) {
      for (String keyCell : repeatAddressMap.keySet()) {
        String cellListStr = repeatAddressMap.get(keyCell);
        String[] cellList = cellListStr.split(",");

        if (cellList.length <= 1) {
          // リストが空、もしくは1件のみの場合は処理をせず次の処理に飛ばします ( 1件目がkeyCellと同じの為、処理不要 )
          continue;
        }
        // セルのスタイルコピーを実施
        for (int ii = 1; ii < cellList.length; ii++) {
          if (cellList[ii].contains(":")) {
            // 結合セルだった場合、結合の範囲内で一式スタイルのコピーを行い、最後に結合処理を行う
            // コピー元範囲
            CellRangeAddress srcRange = CellRangeAddress.valueOf(keyCell);
            // コピー元セルの開始行
            int tmplRowFrom = srcRange.getFirstRow();
            // コピー元セルの開始Column
            int tmplColFrom = srcRange.getFirstColumn();
            // コピー元セルの終了行
            int tmplRowTo = srcRange.getLastRow();
            // コピー元セルの終了Column
            int tmplColTo = srcRange.getLastColumn();

            // コピー先範囲
            CellRangeAddress destRange = CellRangeAddress.valueOf(cellList[ii]);
            // コピー先セルの開始行
            int destRowFrom = destRange.getFirstRow();
            // コピー先セルの開始Column
            int destColFrom = destRange.getFirstColumn();
            // コピー先セルの終了行
            int destRowTo = destRange.getLastRow();
            // コピー先セルの終了Column
            int destColTo = destRange.getLastColumn();

            // style のコピー
            for (int i = tmplRowFrom; i <= tmplRowTo; i++) {
              for (int j = tmplColFrom; j <= tmplColTo; j++) {
                Cell fromCell = sheet.getCells().get(i, j);
                Cell toCell = sheet.getCells().get(destRowFrom + (i - tmplRowFrom), destColFrom + (j - tmplColFrom));
                toCell.setStyle(copyStyle(fromCell.getStyle(), toCell.getStyle(), sheet));
                if(fromCell.getComment() != null) {
                  commentCopy(fromCell.getComment(), toCell.getComment());
                }
              }
            }
            sheet.getCells().merge(destRowFrom, destColFrom, destRowTo - destRowFrom + 1, destColTo - destColFrom + 1);
          } else {
            // 単体セルだった場合、スタイルのコピーのみ実施
            if (!cellList[ii].matches("^[A-Z]+\\d+$")) {
              // コピー先セルがA1参照形式(A1等の指定方式)になっていなければ処理をスキップ
              continue;
            }
            // コピー元セル取得
            CellReference srcCellObj = new CellReference(keyCell);
            Cell fromCell = sheet.getCells().get(srcCellObj.getRow(), srcCellObj.getCol());
            // コピー先セル取得
            CellReference destCellObj = new CellReference(cellList[ii]);
            Cell toCell = sheet.getCells().get(destCellObj.getRow(), destCellObj.getCol());
            toCell.setStyle(copyStyle(fromCell.getStyle(), toCell.getStyle(), sheet));
            if(fromCell.getComment() != null) {
              commentCopy(fromCell.getComment(), toCell.getComment());
            }
          }
        }
      }
    }
  }

  /**
   * mergeRangeかどうか
   * @param cells
   * @param cell
   * @return
   */
  private CellArea getMergedCell(Cells cells, Cell cell) {
    CellArea[] cellAreas = cells.getMergedAreas();
    if(cellAreas != null && cellAreas.length > 0) {
      for(CellArea cellArea : cellAreas) {
        if(cell.getRow() >= cellArea.StartRow && cell.getRow() <= cellArea.EndRow) {
          if(cell.getColumn() >= cellArea.StartColumn && cell.getColumn() <= cellArea.EndColumn) {
            return cellArea;
          }
        }
      }
    }
    return null;
  }

  /**
   * borderを除いて、スタイルをコピーする。
   * @param fromStyle
   * @param toStyle
   * @param worksheet
   * @return
   */
  private Style copyStyle(Style fromStyle, Style toStyle, Worksheet worksheet) {
    Style style = worksheet.getWorkbook().createStyle();
    style.copy(fromStyle);
    BorderCollection borderCollection = toStyle.getBorders();
    style.setBorder(BorderType.TOP_BORDER, borderCollection.getByBorderType(BorderType.TOP_BORDER).getLineStyle()
      , borderCollection.getByBorderType(BorderType.BOTTOM_BORDER).getColor());
    style.setBorder(BorderType.BOTTOM_BORDER, borderCollection.getByBorderType(BorderType.BOTTOM_BORDER).getLineStyle()
      , borderCollection.getByBorderType(BorderType.BOTTOM_BORDER).getColor());
    style.setBorder(BorderType.LEFT_BORDER, borderCollection.getByBorderType(BorderType.LEFT_BORDER).getLineStyle()
      , borderCollection.getByBorderType(BorderType.BOTTOM_BORDER).getColor());
    style.setBorder(BorderType.RIGHT_BORDER, borderCollection.getByBorderType(BorderType.RIGHT_BORDER).getLineStyle()
      , borderCollection.getByBorderType(BorderType.BOTTOM_BORDER).getColor());
    return style;
  }

  /**
   * 出力データを並べる
   * @param map
   * @return
   */
  private Map<String, String> sortByKeyA(Map<String, String> map) {
    Map<String, String> result = new LinkedHashMap<>(map.size());
    map.entrySet().stream()
      .sorted(Map.Entry.comparingByKey())
      .forEachOrdered(e -> result.put(e.getKey(), e.getValue()));
    return result;
  }

  /**
   * 出力データを並べる
   * @param map
   * @return
   */
  private Map<String, String> sortByKeyB(Map<String, String> map) {
    Map<String, String> treeMap = new TreeMap<String, String>(new Comparator<String>() {
      @Override
      public int compare(String o1, String o2) {
        if (o1.length() > o2.length()){
          return 1;
        } else if (o1.length() < o2.length()){
          return -1;
        } else{
          return o1.compareTo(o2);
        }
      }
    });
    treeMap.putAll(map);
    return treeMap;
  }

  /**
   * rangeの行数を取得する。
   * @param idFT
   * @return
   */
  private int getRowCount(String idFT) {
    int row = 0;
    char[]c = idFT.toUpperCase().toCharArray();
    int index = 0;
    int count = 0;
    while (index < c.length) {
      if (c[index] < 'A' || c[index] > 'Z') {
        break;
      } else {
        count++;
      }
      index++;
    }
    row = Integer.valueOf(idFT.substring(count, idFT.length()));
    return row;
  }

  /**
   * rangeの列数を取得する。
   * @param idFT
   * @return
   */
  private int getColumnCount(String idFT) {
    int column = 0;
    char[]c = idFT.toUpperCase().toCharArray();
    int index = 0;
    while (index < c.length) {
      if (c[index] < 'A' || c[index] > 'Z') {
        break;
      }
      column = column * 26 + (c[index] - 'A' + 1);
      index++;
    }
    return column;
  }

  /**
   * 帳票の縮小表示を設定する.
   *
   * @param st
   * @param repeatAddressMap
   * @param params
   */
  private void setShrinkToFit(Worksheet st, Map<String, String> repeatAddressMap, List<ReportXmlParam> params) {
    for (int index = 0; index < params.size(); index++) {
      String key = params.get(index).getId();
      for (String cellAddressExcel : repeatAddressMap.keySet()) {
        if (key.equals(cellAddressExcel)) {
          String[] repeatAddress = repeatAddressMap.get(cellAddressExcel).split(",");
          if (repeatAddress.length > 1) {
            for (int i = 1; i < repeatAddress.length; i++) {
              copyShrinkToFit(st, repeatAddress[0], repeatAddress[i]);
            }
          }
        }
      }
    }
  }

  /**
   * 帳票の縮小表示をコピーする.
   *
   * @param st
   * @param srcKey
   * @param destKey
   */
  private void copyShrinkToFit(Worksheet st, String srcKey, String destKey) {
    String[] srcKeys;
    String[] destKeys;
    int srcRowFrom = 0;
    int srcRowTo = 0;
    int srcColFrom = 0;
    int srcColTo = 0;
    int destRowFrom = 0;
    int destRowTo = 0;
    int destColFrom = 0;
    int destColTo = 0;
    if (srcKey.contains(":")) {
      srcKeys = srcKey.split(":");
      if (srcKeys.length == 2) {
        srcRowFrom = getRowCount(srcKeys[0]);
        srcRowTo = getRowCount(srcKeys[1]);
        srcColFrom = getColumnCount(srcKeys[0]);
        srcColTo = getColumnCount(srcKeys[1]);
      } else {
        srcRowFrom = getRowCount(srcKey);
        srcRowTo = srcRowFrom;
        srcColFrom = getColumnCount(srcKey);
        srcColTo = srcColFrom;
      }
      // 結合セルを含む
      if (destKey.contains(":")) {
        destKeys = destKey.split(":");
        if (destKeys.length == 2) {
          destRowFrom = getRowCount(destKeys[0]);
          destRowTo = getRowCount(destKeys[1]);
          destColFrom = getColumnCount(destKeys[0]);
          destColTo = getColumnCount(destKeys[1]);
        }
      } else {
        // 結合セルを含まない
        destRowFrom = getRowCount(destKey);
        destRowTo = destRowFrom;
        destColFrom = getColumnCount(destKey);
        destColTo = destColFrom;
      }

      // セルが等しい場合
      if (((srcRowTo - srcRowFrom) == (destRowTo - destRowFrom)) && ((srcColTo - srcColFrom) == (destColTo - destColFrom))) {
        List<Cell> srcCellList = new ArrayList<>();
        List<Cell> destCellList = new ArrayList<>();
        for (int i = srcRowFrom - 1; i< srcRowTo; i++) {
          for (int j = srcColFrom - 1; j < srcColTo; j++) {
            srcCellList.add(st.getCells().get(i, j));
          }
        }
        for (int i = destRowFrom - 1; i< destRowTo; i++) {
          for (int j = destColFrom - 1; j < destColTo; j++) {
            destCellList.add(st.getCells().get(i, j));
          }
        }
        if (srcCellList.size() == destCellList.size()) {
          for (int i = 0; i < srcCellList.size(); i++) {
            destCellList.get(i).getStyle().setShrinkToFit(srcCellList.get(i).getStyle().getShrinkToFit());
          }
        }
      }
    }
  }

  /**
   * valueの編集
   * @param str
   * @return
   */
  private  String subStrAfter(String str)
  {
    String str1 = "";
    String str2 = "";
    try {
      str1 = str.substring(0,str.indexOf("$"));
      str2 = str.substring(str1.length() + 1);
    } catch (Exception e) {
      str2 = "1";
    }
    return  str2;
  }

  /**
   * valueの編集
   * @param str
   * @return
   */
  private  String subStrBefore(String str)
  {
    String str1 = "";
    try {
      str1 = str.substring(0,str.indexOf("$"));
    } catch (Exception e) {
      str1 = str;
    }
    return  str1;
  }

  /**
   * グラフ項目のIDを取得します.
   *
   * @param params Param要素情報
   * @return グラフ項目のID
   */
  private Optional<String> getGraphId(List<ReportXmlParam> params) {
    return params.stream()
      .filter(e -> e.getGroupId().indexOf("グラフ") >= 0)
      .map(e -> e.getId())
      .findFirst();
  }

  /**
   * グラフ項目のページを取得します.
   * @param params
   * @return
   */
  private Optional<Integer> getGraphNewPage(List<ReportXmlParam> params) {
    return params.stream()
      .filter(e -> e.getGroupId().indexOf("グラフ") >= 0)
      .map(e -> e.getReportXmlGroup().getIsNewPage())
      .findFirst();
  }

  private void setCellValuePrescription(Worksheet st, String position, String value, String dataType, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    // POIセルオブジェクトの取得(セル範囲の左上)
    Cell targetCell = AsposeExcelUtil.getFirstCellPrescription(st, position, tmplRepeat);

    // targetCellがnull以外、positionに「-」が含まれている場合
    if (targetCell != null && position.indexOf("-") != -1) {
      int index = position.indexOf(".");
      String positionOld = position.substring(index + 1);
      // POIセルオブジェクトの取得
      Cell targetCellOld = AsposeExcelUtil.getFirstCellOfPosition(st, positionOld);
      // セルスタイルをコピーする
      targetCell.setStyle(targetCellOld.getStyle());
    }
    // セルに値を設定します
    setCellValueByType(targetCell, value, dataType);
  }

  /**
   * 帳票の固定値をコピーする.
   *
   * @param st
   * @param tmplRepeat
   */
  private void copyFixedValueForOnePatient(Worksheet st, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    String[] idFT = tmplRepeat.get().getId().split(":");
    if(idFT.length==2) {
      // tmplRepeatの開始コラム
      int tmplColFrom = 0;
      // tmplRepeatの終了コラム
      int tmplColTo = 0;
      // tmplRepeatのコラム数
      int tmplColCount = 0;
      // tmplRepeatの開始行
      int tmplRowFrom = 0;
      // tmplRepeatの終了行
      int tmplRowTo = 0;
      // tmplRepeatの行数
      int tmplRowCount = 0;

      tmplColFrom = getColumnCount(idFT[0]);
      tmplColTo = getColumnCount(idFT[1]);
      tmplColCount = tmplColTo - tmplColFrom + 1;

      tmplRowFrom = getRowCount(idFT[0]);
      tmplRowTo = getRowCount(idFT[1]);
      tmplRowCount = tmplRowTo - tmplRowFrom + 1;

      // 繰返回数(縦)
      int repeatCount_V = tmplRepeat.get().getRepeatCountV();
      // 繰返回数(横)
      int repeatCount_H = tmplRepeat.get().getRepeatCountH();
      // 余白(縦)
      int marginV = tmplRepeat.get().getMarginV();
      // 余白(横)
      int marginH = tmplRepeat.get().getMarginH();

      // コピー元(コラム)
      Cell sourceCell = null;

      // コピー先(コラム)
      Cell destCell = null;

      for (int i = tmplRowFrom - 1; i< tmplRowTo; i++) {
        for (int j = tmplColFrom - 1; j < tmplColTo; j++) {
          sourceCell = st.getCells().get(i, j);
          for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
            for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
              if (hCount == 1 && vCount == 1) {
                continue;
              }
              int tempRowNumber = i + (tmplRowCount + marginV) * (vCount -1);
              int tempColumnNumber = j+ (tmplColCount + marginH) * (hCount - 1);
              destCell = st.getCells().get(tempRowNumber, tempColumnNumber);
              // 帳票のCellをコピー
              copyCell(sourceCell, destCell);
            }
          }
        }
      }
    }
  }

  /**
   * セルに値を設定します.
   *
   */
  private void setCellValueForOnePatient(Worksheet st, String position, String value, String dataType, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    Cell targetCell = AsposeExcelUtil.getCellForOnePatient(st, position, tmplRepeat);
    setCellValueByType(targetCell, value, dataType);
  }

  /**
   * セルに値を設定します.
   * @param st
   * @param position
   * @param value
   * @param dataType
   * @param tmplRepeat
   */
  private void setCellValueOnePat(Worksheet st, String position, String value, String dataType, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    Cell targetCell = AsposeExcelUtil.getFirstCellOnePat(st, position, tmplRepeat);
    if (targetCell != null && position.indexOf("-")!= -1) {
      int index = position.indexOf(".");
      String positionOld = position.substring(index+1);
      Cell targetCellOld = AsposeExcelUtil.getFirstCellOfPosition(st, positionOld);
      targetCell.setStyle(targetCellOld.getStyle());
    }
    setCellValueByType(targetCell, value, dataType);
  }

  public String getNextUpEn(String en){
    char lastE = 'a';
    char st = en.toCharArray()[0];
    if(Character.isUpperCase(st)){
      if(en.equals("Z")){
        return "A";
      }
      if(en==null || en.equals("")){
        return "A";
      }
      lastE = 'Z';
    }else{
      if(en.equals("z")){
        return "a";
      }
      if(en==null || en.equals("")){
        return "a";
      }
      lastE = 'z';
    }
    int lastEnglish = (int)lastE;
    char[] c = en.toCharArray();
    if(c.length>1){
      return null;
    }else{
      int now = (int)c[0];
      if(now >= lastEnglish)
        return null;
      char uppercase = (char)(now+1);
      return String.valueOf(uppercase);
    }
  }

  /**
   * テンプレート繰り返し：繰り返し元のスタイル、結合状態をデータの数だけコピーする.
   *
   * @param st
   * @param tmplRepeat
   */
  private void copyFixedValue(Worksheet st, Optional<ReportXmlTmplRepeat> tmplRepeat, Integer page, Map<String, Object> dataKey) {
    String[] idFT = tmplRepeat.get().getId().split(":");
    if(idFT.length==2) {
      // tmplRepeatの開始コラム
      int tmplColFrom = 0;
      // tmplRepeatの終了コラム
      int tmplColTo = 0;
      // tmplRepeatのコラム数
      int tmplColCount = 0;
      // tmplRepeatの開始行
      int tmplRowFrom = 0;
      // tmplRepeatの終了行
      int tmplRowTo = 0;
      // tmplRepeatの行数
      int tmplRowCount = 0;

      // 繰返回数(縦)
      int repeatCount_V = tmplRepeat.get().getRepeatCountV();
      // 繰返回数(横)
      int repeatCount_H = tmplRepeat.get().getRepeatCountH();
      // 余白(縦)
      int marginV = tmplRepeat.get().getMarginV();
      // 余白(横)
      int marginH = tmplRepeat.get().getMarginH();
      int repeatMax = tmplRepeat.get().getRepeatMax();
      tmplRowFrom = getRowCount(idFT[0]);
      tmplRowTo = getRowCount(idFT[1]);
      tmplRowCount = tmplRowTo - tmplRowFrom + 1;

      tmplColFrom = getColumnCount(idFT[0]);
      tmplColTo = getColumnCount(idFT[1]);
      tmplColCount = tmplColTo - tmplColFrom + 1;

      List<Long> patId = (List<Long>) dataKey.get("patIds");
      int multipleOutputCount = patId.size();

      Cell sourceCell = null;
      // style のコピー
      int i = tmplRowFrom - 1;
      int j = tmplColFrom - 1;
      for (; i< tmplRowTo; i++) {
        for (; j < tmplColTo; j++) {
          sourceCell = st.getCells().get(i ,j);
          int dataCount = 0;
          if (ReportXmlTmplRepeat.DIRECTION_Z.equals(String.valueOf(tmplRepeat.get().getDirection()))) {
            // Z方向
            int vCount = 1;
            int hCount = 1;
            flgStyleCopyZ :
            for (; vCount <= repeatCount_V; vCount ++) {
              for (; hCount <= repeatCount_H; hCount ++) {
                dataCount = dataCount + 1;
                if (dataCount > multipleOutputCount - (repeatMax * page)) {
                  break flgStyleCopyZ; // ラベル：flgStyleCopyZ の付いたforループ全体を抜ける
                }
                if (hCount == 1 && vCount == 1) {
                  continue;
                }
                Cell destCell = st.getCells().get(i + (tmplRowCount + marginV) * (vCount -1), j+ (tmplColCount + marginH) * (hCount - 1));
                // 帳票のCellをコピー
                copyCell(sourceCell, destCell);
              }
            }
          } else {
            // N方向
            int hCount = 1;
            int vCount = 1;
            flgStyleCopyN :
            for (; hCount <= repeatCount_H; hCount ++) {
              for (; vCount <= repeatCount_V; vCount ++) {
                dataCount = dataCount + 1;
                if (dataCount > multipleOutputCount - (repeatMax * page)) {
                  break flgStyleCopyN; // ラベル：flgStyleCopyN の付いたforループ全体を抜ける
                }
                if (hCount == 1 && vCount == 1) {
                  continue;
                }
                Cell destCell = st.getCells().get(i + (tmplRowCount + marginV) * (vCount -1), j+ (tmplColCount + marginH) * (hCount - 1));
                // 帳票のCellをコピー
                copyCell(sourceCell, destCell);
              }
            }
          }
        }
      }

      // 結合状態のコピー
      int mergedCount = st.getCells().getMergedAreas().length;
      CellArea[] mergeAreas = st.getCells().getMergedAreas();
      for(i = 0; i < mergedCount; i++) {
        // 結合されたセルを取得
        CellRangeAddress region = new CellRangeAddress(mergeAreas[i].StartRow, mergeAreas[i].EndRow, mergeAreas[i].StartColumn, mergeAreas[i].EndColumn);
        // コピー元範囲内の結合セルだった場合、処理を実施 (getメソッドでのRow/Column数取得は0スタートの為、比較値を-1しておく)
        if (tmplRowFrom - 1 <= region.getFirstRow()
          && tmplColFrom - 1 <= region.getFirstColumn()
          && tmplRowTo - 1 >= region.getLastRow()
          && tmplColTo - 1 >= region.getLastColumn()) {
          int mgDataCount = 0;
          if(ReportXmlTmplRepeat.DIRECTION_Z.equals(String.valueOf(tmplRepeat.get().getDirection()))) {
            // Z方向
            flgMergedCopyZ :
            for (int mgVCount = 1; mgVCount <= repeatCount_V; mgVCount++) {
              for (int mgHCount = 1; mgHCount <= repeatCount_H; mgHCount++) {
                mgDataCount = mgDataCount + 1;
                if (mgDataCount > multipleOutputCount - (repeatMax * page)) {
                  break flgMergedCopyZ; // ラベル：flgMergedCopyZ の付いたforループ全体を抜ける
                }
                if (mgHCount == 1 && mgVCount == 1) { // 1つめはコピー元なので処理不要
                  continue;
                }
                try {
                  st.getCells().merge(region.getFirstRow() + ((tmplRowCount + marginV) * (mgVCount - 1)), region.getFirstColumn() + ((tmplColCount + marginH) * (mgHCount - 1))
                    ,region.getLastRow() - region.getFirstRow() + 1, region.getLastColumn() - region.getFirstColumn() + 1);
                } catch (Exception e) {
                  // 結合先が結合状態の場合、エラーになるので、処理をスキップする
                }
              }
            }
          } else {
            // N方向
            flgMergedCopyN :
            for (int mgHCount = 1; mgHCount <= repeatCount_H; mgHCount++) {
              for (int mgVCount = 1; mgVCount <= repeatCount_V; mgVCount++) {
                mgDataCount = mgDataCount + 1;
                if (mgDataCount > multipleOutputCount - (repeatMax * page)) {
                  break flgMergedCopyN; // ラベル：flgMergedCopyN の付いたforループ全体を抜ける
                }
                if (mgHCount == 1 && mgVCount == 1) { // 1つめはコピー元なので処理不要
                  continue;
                }
                try {
                  st.getCells().merge(region.getFirstRow() + ((tmplRowCount + marginV) * (mgVCount - 1)), region.getFirstColumn() + ((tmplColCount + marginH) * (mgHCount - 1))
                    ,region.getLastRow() - region.getFirstRow() + 1, region.getLastColumn() - region.getFirstColumn() + 1);
                } catch (Exception e) {
                  // 結合先が結合状態の場合、エラーになるので、処理をスキップする
                }
              }
            }
          }
        }
      }
    }
  }

  /**
   * ラベル帳票の固定値をコピーする.
   *
   * @param st
   * @param tmplRepeat
   * @param page
   */
  private void copyFixedValueForLabel(Worksheet st, Optional<ReportXmlTmplRepeat> tmplRepeat, Integer page, Integer stPos, Map<String, Object> dataKey) {
    String[] idFT = tmplRepeat.get().getId().split(":");
    if(idFT.length==2) {
      // tmplRepeatの開始コラム
      int tmplColFrom = 0;
      // tmplRepeatの終了コラム
      int tmplColTo = 0;
      // tmplRepeatのコラム数
      int tmplColCount = 0;
      // tmplRepeatの開始行
      int tmplRowFrom = 0;
      // tmplRepeatの終了行
      int tmplRowTo = 0;
      // tmplRepeatの行数
      int tmplRowCount = 0;
      // 繰返回数(縦)
      int repeatCount_V = tmplRepeat.get().getRepeatCountV();
      // 繰返回数(横)
      int repeatCount_H = tmplRepeat.get().getRepeatCountH();
      // 余白(縦)
      int marginV = tmplRepeat.get().getMarginV();
      // 余白(横)
      int marginH = tmplRepeat.get().getMarginH();
      int repeatMax = tmplRepeat.get().getRepeatMax();

      tmplRowFrom = getRowCount(idFT[0]);
      tmplRowTo = getRowCount(idFT[1]);
      tmplRowCount = tmplRowTo - tmplRowFrom + 1;

      tmplColFrom = getColumnCount(idFT[0]);
      tmplColTo = getColumnCount(idFT[1]);
      tmplColCount = tmplColTo - tmplColFrom + 1;

      Cell sourceCell = null;
      for (int i = tmplRowFrom - 1; i< tmplRowTo; i++) {
        for (int j = tmplColFrom - 1; j < tmplColTo; j++) {
          sourceCell = st.getCells().get(i, j);

          int dataCount = 0;
          // 繰り返し方向：Z型
          if (ReportXmlTmplRepeat.DIRECTION_Z.equals(String.valueOf(tmplRepeat.get().getDirection()))) {
            flag :
            for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
              for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
                dataCount = dataCount + 1;
                Integer labelOutputCount = (Integer)dataKey.get(LABEL_OUTPUT_COUNT);
                if (dataCount > labelOutputCount + stPos - 1 - (repeatMax * page)) {
                  break flag;
                }
                if (hCount == 1 && vCount == 1) {
                  continue;
                }
                Cell destCell = st.getCells().get(i + (tmplRowCount + marginV) * (vCount -1), j+ (tmplColCount + marginH) * (hCount - 1));
                if (dataCount >= stPos || !String.format("%s%d", SHEET_NAME_PREFIX, 1).equals(st.getName())) {
                  // 帳票のCellをコピー
                  // mod #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy start
//                  copyCell(sourceCell, destCell);
                  copyCellForLabel(sourceCell, destCell);
                  // mod #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy end
                }
              }
            }
          }
          // 繰り返し方向：N型
          if (ReportXmlTmplRepeat.DIRECTION_N.equals(String.valueOf(tmplRepeat.get().getDirection()))) {
            flag :
            for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
              for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
                dataCount = dataCount + 1;
                Integer labelOutputCount = (Integer) dataKey.get(LABEL_OUTPUT_COUNT);
                if (dataCount > labelOutputCount + stPos - 1 - (repeatMax * page)) {
                  break flag;
                }
                if (hCount == 1 && vCount == 1) {
                  continue;
                }
                Cell destCell = st.getCells().get(i + (tmplRowCount + marginV) * (vCount -1), j+ (tmplColCount + marginH) * (hCount - 1));
                // 帳票のCellをコピー
                if (dataCount >= stPos || !String.format("%s%d", SHEET_NAME_PREFIX, 1).equals(st.getName())) {
                  // 帳票のCellをコピー
                  // mod #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy start
//                  copyCell(sourceCell, destCell);
                  copyCellForLabel(sourceCell, destCell);
                  // mod #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy end
                }
              }
            }
          }
        }
      }
    }
  }

  /**
   * セルを設定する。
   * @param st
   * @param position
   * @param value
   * @param isDirectionX
   * @param tmplOffset
   * @param tmplOffsetCol
   * @param dataType
   * @param tmplRepeat
   */
  private void setCellValue(Worksheet st, String position, String value, boolean isDirectionX, int tmplOffset, int tmplOffsetCol, String dataType, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    Cell targetCell = AsposeExcelUtil.getFirstCellOfPosition(st, position, isDirectionX, tmplOffset, tmplOffsetCol, tmplRepeat);
    if (position.indexOf("-")!= -1) {
      int index = position.indexOf(".");
      String positionOld = position.substring(index + 1);
      Cell targetCellOld = AsposeExcelUtil.getFirstCellOfPosition(st, positionOld);
      // del #11889 テンプレート繰り返しで罫線の一部が変わってしまう　高　start
//      targetCell.setStyle(targetCellOld.getStyle());
      // del #11889 テンプレート繰り返しで罫線の一部が変わってしまう　高　end
    }
    setCellValueByType(targetCell, value, dataType);
  }
  // add #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy start
  /**
   * ラベルのセルを設定する。
   * @param st
   * @param position
   * @param value
   * @param isDirectionX
   * @param tmplOffset
   * @param tmplOffsetCol
   * @param dataType
   * @param tmplRepeat
   */
  private void setCellValueForLabel(Worksheet st, String position, String value, boolean isDirectionX, int tmplOffset, int tmplOffsetCol, String dataType, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    Cell targetCell = AsposeExcelUtil.getFirstCellOfPosition(st, position, isDirectionX, tmplOffset, tmplOffsetCol, tmplRepeat);
    if (position.indexOf("-")!= -1) {
      int index = position.indexOf(".");
      String positionOld = position.substring(index + 1);
      Cell targetCellOld = AsposeExcelUtil.getFirstCellOfPosition(st, positionOld);
      targetCell.setStyle(targetCellOld.getStyle());
    }
    setCellValueByType(targetCell, value, dataType);
  }
  // add #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy end

  /**
   * keyを取得する(テンプレート繰り返しではない通常の繰り返し処理のデータ割り当て先keyを応答する).
   *
   * @param key key
   * @param repeatAddressMap ReplaceKeyMap
   */
  private String getReplaceKeyForRepeat_V(String key, Map<String, String> repeatAddressMap) {
    String replaceKey = null;
    // key から、map の key と index を取得
    String indexKey = "";
    String strV = "";
    Integer cellAddrIndex = 0;
    if (key.indexOf("-") > -1) {
      String[] tmpStr = key.split("-");
      indexKey = tmpStr[0];
      strV = tmpStr[1];
      String[] strVS = strV.split("_V");
      cellAddrIndex = Integer.valueOf(strVS[0]);
    } else {
      indexKey = key;
    }
    // key、index を元に、必要なキーを取得
    String str = repeatAddressMap.get(indexKey);
    if (str != null && str.indexOf(",") > -1) {
      String[] repeatAddress = str.split(",");
      if (cellAddrIndex <= repeatAddress.length) {
        replaceKey = repeatAddress[cellAddrIndex - 1];
      }
    }
    if (replaceKey == null) {
      // replace不要の場合
      replaceKey = key;
    }
    return replaceKey;
  }

  /**
   * セルに値を設定します.
   *
   * @param st シート
   * @param position セル位置
   * @param value 値
   * @param dataType データタイプ
   */
  private void setCellValue_V(Worksheet st, String position, String value, String dataType) {
    Cell targetCell = AsposeExcelUtil.getFirstCellForOneTotal(st, position);
    setCellValueByType(targetCell, value, dataType);
  }

  /**
   * セルの設定
   * @param st
   * @param key
   * @param value
   * @param dataTypeInTmp
   */
  private void setCellValueForOneTotal(Worksheet st, String key, String value, String dataTypeInTmp) {
    if ("byte[]".equals(dataTypeInTmp)) {
      return;
    }
    String tempKey = "";
    if (key.contains("-")) {
      tempKey = key.substring(0, key.indexOf("-"));
    } else {
      tempKey = key;
    }
    int tmplRowFrom = 0;
    int tmplColFrom = 0;
    tmplColFrom = getColumnCount(tempKey);
    tmplRowFrom = getRowCount(tempKey);

    Cell cell = st.getCells().get(tmplRowFrom - 1, tmplColFrom - 1);
    if (StringUtils.isEmpty(value)) {
      cell.setValue("");
    } else {
      if (!"".equals(dataTypeInTmp) && !"string".equals(dataTypeInTmp) && isNumeric(value)) {
        cell.setValue(Double.valueOf(value));
      } else {
        cell.setValue(value);
      }
    }
  }

  /**
   * 数字型の判定処理
   * @param str　文字列
   * @return true:数字型 false:非数字型
   */
  public static boolean isNumeric(String str) {
    if (str == null || str.isEmpty()) {
      return false;
    }
    int decimalCount = 0;
    boolean hasNegativeSign = false;
    for (int i = 0; i < str.length(); i++) {
      char c = str.charAt(i);
      // Check for negative sign only at the beginning
      if (i == 0 && c == '-') {
        hasNegativeSign = true;
      } else if (c == '.') {
        decimalCount++;
        // Ensure decimal point occurs only once
        if (decimalCount > 1) {
          return false;
        }
      } else if (!Character.isDigit(c)) {
        return false;
      }
    }
    // If there is a negative sign, string length should be greater than 1
    if (hasNegativeSign && str.length() == 1) {
      return false;
    }
    return true;
  }

  /**
   * 指定されたシートのセルスタイルをコピーします。
   *
   * @param st                シート
   * @param repeatAddressMap  繰り返しアドレスのマップ
   */
  private void copyStyleFromCells(Worksheet st, Map<String, String> repeatAddressMap) {
    if (repeatAddressMap.size() > 0) {
      // データ例：D9 = D9,D10,D11,D12,D13,,, のようなデータのリストです
      for (String keyCell : repeatAddressMap.keySet()) {
        // セルリストを取得します
        String cellListStr = repeatAddressMap.get(keyCell);
        // セルリストを分割します
        String[] cellList = cellListStr.split(",");

        if (cellList.length <= 1) {
          // リストが空、もしくは1件のみの場合は処理をせず次の処理に飛ばします ( 1件目がkeyCellと同じの為、処理不要 )
          continue;
        }
        // セルのスタイルコピーを実施
        for (int ii = 1; ii < cellList.length; ii++) {
          if (cellList[0].contains(":")) {
            // 結合セルだった場合、結合の範囲内で一式スタイルのコピーを行い、最後に結合処理を行う
            // コピー元範囲
            CellRangeAddress srcRange = CellRangeAddress.valueOf(keyCell);
            // コピー元セルの開始行
            int tmplRowFrom = srcRange.getFirstRow();
            // コピー元セルの開始Column
            int tmplColFrom = srcRange.getFirstColumn();
            // コピー元セルの終了行
            int tmplRowTo = srcRange.getLastRow();
            // コピー元セルの終了Column
            int tmplColTo = srcRange.getLastColumn();

            // コピー先範囲
            CellRangeAddress destRange = CellRangeAddress.valueOf(cellList[ii]);
            // コピー先セルの開始行
            int destRowFrom = destRange.getFirstRow();
            // コピー先セルの開始Column
            int destColFrom = destRange.getFirstColumn();
            // add #12382 "##実績.投薬.薬剤名"を繰り返し表示すると書式設定が正しく出力されないことがある 高 start
            // コピー先セルの終了行
            int destRowTo = destRange.getLastRow();
            // コピー先セルの終了Column
            int destColTo = destRange.getLastColumn();
            // add #12382 "##実績.投薬.薬剤名"を繰り返し表示すると書式設定が正しく出力されないことがある 高 end
            Cell sourceCell = null;
            // style のコピー
            for (int i = tmplRowFrom; i <= tmplRowTo; i++) {
              for (int j = tmplColFrom; j <= tmplColTo; j++) {
                // add #12382 "##実績.投薬.薬剤名"を繰り返し表示すると書式設定が正しく出力されないことがある 高 start
                if (destRowFrom + ( i - tmplRowFrom) > destRowTo ||  (destColFrom + ( j - tmplColFrom)) > destColTo) break;
                // add #12382 "##実績.投薬.薬剤名"を繰り返し表示すると書式設定が正しく出力されないことがある 高 end
                // コピー元Cellを取得
                sourceCell = st.getCells().get(i, j);
                // コピー先Cellを取得
                Cell destCell = st.getCells().get(destRowFrom + ( i - tmplRowFrom), (destColFrom + ( j - tmplColFrom)));
                // style のコピーを実施
                destCell.setStyle(copyStyle(sourceCell.getStyle(), destCell.getStyle(), st));
                // コメントのコピーを実施
                if (sourceCell.getComment() != null) {
                  commentCopy(sourceCell.getComment(), destCell.getComment());
                }
              }
            }

          } else {
            // 単体セルだった場合、スタイルのコピーのみ実施
            if (!cellList[ii].matches("^[A-Z]+\\d+$")) {
              // コピー先セルがA1参照形式(A1等の指定方式)になっていなければ処理をスキップ
              continue;
            }
            // コピー元セル取得
            CellReference srcCellObj = new CellReference(keyCell);
            Cell sourceCell = st.getCells().get(srcCellObj.getRow(), srcCellObj.getCol());
            // コピー先セル取得
            CellReference destCellObj = new CellReference(cellList[ii]);
            Cell destCell = st.getCells().get(destCellObj.getRow(), destCellObj.getCol());
            // style のコピーを実施
            destCell.setStyle(copyStyle(sourceCell.getStyle(), destCell.getStyle(), st));
            if (sourceCell.getComment() != null) {
              commentCopy(sourceCell.getComment(), destCell.getComment());
            }
          }
        }
      }
    }
  }

  /**
   * コメントコピー
   * @param sourceComment
   * @param targetComment
   */
  private void commentCopy(Comment sourceComment, Comment targetComment) {
    if(sourceComment != null && targetComment != null) {
      targetComment.setAuthor(sourceComment.getAuthor());
      targetComment.setHeight(sourceComment.getHeight());
      targetComment.setAutoSize(sourceComment.getAutoSize());
      targetComment.setNote(sourceComment.getNote());
      targetComment.setHeightCM(sourceComment.getHeightCM());
      targetComment.setHeightInch(sourceComment.getHeightInch());
      try {
        targetComment.setHtmlNote(sourceComment.getHtmlNote());
      } catch (Exception e) {
        // エラーメッセージ
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        eventLogMessage.setLogMessage("asposeのcellのコメントのコピーはエラー：" + ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      targetComment.setTextHorizontalAlignment(sourceComment.getTextHorizontalAlignment());
      targetComment.setTextOrientationType(sourceComment.getTextOrientationType());
      targetComment.setTextVerticalAlignment(sourceComment.getTextVerticalAlignment());
      targetComment.setVisible(sourceComment.isVisible());
      targetComment.setWidth(sourceComment.getWidth());
      targetComment.setWidthCM(sourceComment.getWidthCM());
      targetComment.setWidthInch(sourceComment.getWidthInch());
    }
  }

  /**
   * セルスタイルを複製します。(集計)
   *
   * @param st           シート
   * @param tmplRepeat   繰り返し情報を持つオプション
   */
  // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
  //private void copyStyleFromConvert(Worksheet st, Optional<ReportXmlTmplRepeat> tmplRepeat){
  private void copyStyleFromConvert(Worksheet st, Optional<ReportXmlTmplRepeat> tmplRepeat, boolean bCopyAll){
  // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
    // テンプレート文字列が空の場合は処理をスキップ
    if (StringUtils.isEmpty(tmplRepeat.get().getId())) {
      return;
    }
    // テンプレート設定を取得
    // 繰返回数(縦)
    int repeatCount_V = tmplRepeat.get().getRepeatCountV();
    // 繰返回数(横)
    int repeatCount_H = tmplRepeat.get().getRepeatCountH();

    if (repeatCount_V <= 1 && repeatCount_H <= 1) {
      // 繰り返し回数がどちらも1回の場合は実施不要
      return;
    }

    // テンプレート範囲を取得
    String[] idFT = tmplRepeat.get().getId().split(":");
    if (idFT.length == 2) {
      // テンプレート範囲の取得
      CellRangeAddress tmplRange = CellRangeAddress.valueOf(tmplRepeat.get().getId());
      // テンプレート範囲の開始Column
      int tmplColFrom = tmplRange.getFirstColumn();
      // テンプレート範囲の終了Column
      int tmplColTo = tmplRange.getLastColumn();
      // テンプレート範囲のColumn数
      int tmplColCount = tmplColTo - tmplColFrom + 1;
      // テンプレート範囲の開始Row
      int tmplRowFrom = tmplRange.getFirstRow();
      // テンプレート範囲の終了Row
      int tmplRowTo = tmplRange.getLastRow();
      // テンプレート範囲のRow数
      int tmplRowCount = tmplRowTo - tmplRowFrom + 1;

      // 余白(縦)
      int marginV = tmplRepeat.get().getMarginV();
      // 余白(横)
      int marginH = tmplRepeat.get().getMarginH();

      // style、value のコピー
      Cell sourceCell = null;
      for (int rCount = tmplRowFrom; rCount <= tmplRowTo; rCount++) {
        for (int cCount = tmplColFrom; cCount <= tmplColTo; cCount++) {
          // スタイルコピー元セル取得
          // コピー元Cellを取得
          sourceCell = st.getCells().get(rCount, cCount);
          if (ReportXmlTmplRepeat.DIRECTION_Z.equals(String.valueOf(tmplRepeat.get().getDirection()))) {
            // Z方向
            for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
              for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
                if (hCount == 1 && vCount == 1) {
                  // コピー先が同じテンプレート範囲の為除外
                  continue;
                }
                // コピー先セルを取得
                int tmpRowNo = rCount + (tmplRowCount + marginV) * (vCount -1);
                int tmpColNo = cCount + (tmplColCount + marginH) * (hCount - 1);
                Cell destCell = st.getCells().get(tmpRowNo, tmpColNo);
                // srcCell の style、value をコピー
                // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
                //if (destCell != null && destCell.getType() != CellValueType.IS_NULL) {
                if (destCell != null && (destCell.getType() != CellValueType.IS_NULL || bCopyAll)) {
                // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
                  destCell.setStyle(copyStyle(sourceCell.getStyle(), destCell.getStyle(), st));
                }
              }
            }
          } else {
            // N方向
            for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
              for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
                if (hCount == 1 && vCount == 1) {
                  // コピー先が同じテンプレート範囲の為除外
                  continue;
                }
                // コピー先セルを取得
                int tmpRowNo = rCount + (tmplRowCount + marginV) * (vCount -1);
                int tmpColNo = cCount + (tmplColCount + marginH) * (hCount - 1);
                Cell destCell = st.getCells().get(tmpRowNo, tmpColNo);
                // 目標のセルです
                // srcCell の style、value をコピー
                // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
                //if (destCell != null && destCell.getType() != CellValueType.IS_NULL) {
                if (destCell != null && (destCell.getType() != CellValueType.IS_NULL || bCopyAll)) {
                // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
                  destCell.setStyle(copyStyle(sourceCell.getStyle(), destCell.getStyle(), st));
                }
              }
            }
          }
        }
      }

    } else {
      String cellReference= tmplRepeat.get().getId();

      // セル参照を解析します
      CellReference ref = new CellReference(cellReference);

      // 列と行のインデックスを取得します
      int rowIndex = ref.getRow();
      int colIndex = ref.getCol();

      // コピー元Cellを取得
      Cell sourceCell = st.getCells().get(rowIndex, colIndex);
      if (ReportXmlTmplRepeat.DIRECTION_Z.equals(String.valueOf(tmplRepeat.get().getDirection()))) {
        // Z方向
        for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
          for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
            if (hCount == 1 && vCount == 1) {
              // コピー先が同じテンプレート範囲の為除外
              continue;
            }
            // コピー先セルを取得
            int tmpRowNo = rowIndex + (vCount -1);
            int tmpColNo = colIndex + (hCount - 1);
            Cell destCell = st.getCells().get(tmpRowNo, tmpColNo);
            // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
            //if (destCell != null && destCell.getType() != CellValueType.IS_NULL) {
            if (destCell != null && (destCell.getType() != CellValueType.IS_NULL || bCopyAll)) {
            // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
              // ターゲットセルが空白セルでない場合、ソースセルのスタイルをコピーします
              destCell.setStyle(copyStyle(sourceCell.getStyle(), destCell.getStyle(), st));
            }
          }
        }
      } else {
        // N方向
        for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
          for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
            if (hCount == 1 && vCount == 1) {
              // コピー先が同じテンプレート範囲の為除外
              continue;
            }
            // コピー先セルを取得
            int tmpRowNo = rowIndex + (vCount -1);
            int tmpColNo = colIndex + (hCount - 1);
            Cell destCell = st.getCells().get(tmpRowNo, tmpColNo);
            // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
            //if (destCell != null && destCell.getType() != CellValueType.IS_NULL) {
            if (destCell != null && (destCell.getType() != CellValueType.IS_NULL || bCopyAll)) {
            // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
              // ターゲットセルが空白セルでない場合、ソースセルのスタイルをコピーします
              destCell.setStyle(copyStyle(sourceCell.getStyle(), destCell.getStyle(), st));
            }
          }
        }
      }
    }
  }

  /**
   * ラベル帳票のセルマージ.
   *
   * @param st
   * @param tmplRepeat
   * @param page
   * @param stPos
   */
  private void reportMergedRegionForLabel(Worksheet st, Optional<ReportXmlTmplRepeat> tmplRepeat, Integer page, Integer stPos, Map<String, Object> dataKey) {
    String[] idFT = tmplRepeat.get().getId().split(":");
    if(idFT.length == 2) {
      // tmplRepeatの開始コラム
      int tmplColFrom = 0;
      // tmplRepeatの終了コラム
      int tmplColTo = 0;
      // tmplRepeatのコラム数
      int tmplColCount = 0;
      // tmplRepeatの開始行
      int tmplRowFrom = 0;
      // tmplRepeatの終了行
      int tmplRowTo = 0;
      // tmplRepeatの行数
      int tmplRowCount = 0;

      tmplColFrom = getColumnCount(idFT[0]);
      tmplColTo = getColumnCount(idFT[1]);
      tmplColCount = tmplColTo - tmplColFrom + 1;

      tmplRowFrom = getRowCount(idFT[0]);
      tmplRowTo = getRowCount(idFT[1]);
      tmplRowCount = tmplRowTo - tmplRowFrom + 1;

      // セルマージ数
      int mergedCount = st.getCells().getMergedAreas().length;
      int targetFirstRow = 0;
      int targetLastRow = 0;
      int targetFirstColumn = 0;
      int targetLastColumn = 0;
      // 繰返回数(縦)
      int repeatCount_V = tmplRepeat.get().getRepeatCountV();
      // 繰返回数(横)
      int repeatCount_H = tmplRepeat.get().getRepeatCountH();
      // 余白(縦)
      int marginV = tmplRepeat.get().getMarginV();
      // 余白(横)
      int marginH = tmplRepeat.get().getMarginH();
      int repeatMax = tmplRepeat.get().getRepeatMax();

      for(int i = 0; i < mergedCount; i++) {
        CellArea tempCellArea = st.getCells().getMergedAreas()[i];
        CellRangeAddress region = new CellRangeAddress(tempCellArea.StartRow, tempCellArea.EndRow, tempCellArea.StartColumn, tempCellArea.EndColumn);
        targetFirstRow = region.getFirstRow();
        targetLastRow = region.getLastRow();
        targetFirstColumn = region.getFirstColumn();
        targetLastColumn = region.getLastColumn();
        int dataCount = 0;
        // 繰り返し方向：Z型
        if (ReportXmlTmplRepeat.DIRECTION_Z.equals(String.valueOf(tmplRepeat.get().getDirection()))) {
          flag :
          for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
            for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
              dataCount = dataCount + 1;
              Integer labelOutputCount = (Integer) dataKey.get(LABEL_OUTPUT_COUNT);
              if (labelOutputCount != null) {
                if (dataCount > labelOutputCount + stPos - 1 - (repeatMax * page)) {
                  break flag;
                }
              }
              if (hCount == 1 && vCount == 1) {
                continue;
              }
              int newFirstRow = 0;
              int newLastRow = 0;
              int newFirstColumn = 0;
              int newLastColumn = 0;
              if (vCount == 1) {
                newFirstRow = targetFirstRow;
              } else {
                newFirstRow = targetFirstRow + (tmplRowCount + marginV) * (vCount - 1);
              }
              newLastRow = newFirstRow + (targetLastRow - targetFirstRow);

              if (hCount == 1) {
                newFirstColumn = targetFirstColumn;
              } else {
                newFirstColumn = targetFirstColumn + (tmplColCount + marginH) * (hCount - 1);
              }
              newLastColumn = newFirstColumn + (targetLastColumn - targetFirstColumn);

              // セルマージ
              st.getCells().merge(newFirstRow, newFirstColumn, newLastRow - newFirstRow + 1, newLastColumn - newFirstColumn + 1);
            }
          }
        }
        // 繰り返し方向：N型
        if (ReportXmlTmplRepeat.DIRECTION_N.equals(String.valueOf(tmplRepeat.get().getDirection()))) {
          flag :
          for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
            for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
              dataCount = dataCount + 1;
              Integer labelOutputCount = (Integer) dataKey.get(LABEL_OUTPUT_COUNT);
              if (labelOutputCount != null) {
                if (dataCount > labelOutputCount + stPos - 1 - (repeatMax * page)) {
                  break flag;
                }
              }
              if (hCount == 1 && vCount == 1) {
                continue;
              }
              int newFirstRow = 0;
              int newLastRow = 0;
              int newFirstColumn = 0;
              int newLastColumn = 0;
              if (vCount == 1) {
                newFirstRow = targetFirstRow;
              } else {
                newFirstRow = targetFirstRow + (tmplRowCount + marginV) * (vCount - 1);
              }
              newLastRow = newFirstRow + (targetLastRow - targetFirstRow);

              if (hCount == 1) {
                newFirstColumn = targetFirstColumn;
              } else {
                newFirstColumn = targetFirstColumn + (tmplColCount + marginH) * (hCount - 1);
              }
              newLastColumn = newFirstColumn + (targetLastColumn - targetFirstColumn);

              // セルマージ
              st.getCells().merge(newFirstRow, newFirstColumn, newLastRow - newFirstRow + 1, newLastColumn - newFirstColumn + 1);
            }
          }
        }
      }
    }
  }

  /**
   * 帳票のセルマージ.
   *
   * @param st
   * @param tmplRepeat
   */
  private void reportMergedRegionForOnePatient(Worksheet st, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    String[] idFT = tmplRepeat.get().getId().split(":");
    if(idFT.length==2) {
      // tmplRepeatの開始コラム
      int tmplColFrom = 0;
      // tmplRepeatの終了コラム
      int tmplColTo = 0;
      // tmplRepeatのコラム数
      int tmplColCount = 0;
      // tmplRepeatの開始行
      int tmplRowFrom = 0;
      // tmplRepeatの終了行
      int tmplRowTo = 0;
      // tmplRepeatの行数
      int tmplRowCount = 0;

      tmplColFrom = getColumnCount(idFT[0]);
      tmplColTo = getColumnCount(idFT[1]);
      tmplColCount = tmplColTo - tmplColFrom + 1;

      tmplRowFrom = getRowCount(idFT[0]);
      tmplRowTo = getRowCount(idFT[1]);
      tmplRowCount = tmplRowTo - tmplRowFrom + 1;

      // セルマージ数
      int mergedCount = st.getCells().getMergedAreas().length;
      int targetFirstRow = 0;
      int targetLastRow = 0;
      int targetFirstColumn = 0;
      int targetLastColumn = 0;
      // 繰返回数(縦)
      int repeatCount_V = tmplRepeat.get().getRepeatCountV();
      // 繰返回数(横)
      int repeatCount_H = tmplRepeat.get().getRepeatCountH();
      // 余白(縦)
      int marginV = tmplRepeat.get().getMarginV();
      // 余白(横)
      int marginH = tmplRepeat.get().getMarginH();
      for(int i = 0; i < mergedCount; i++) {
        CellArea tempCellArea = st.getCells().getMergedAreas()[i];
        CellRangeAddress region = new CellRangeAddress(tempCellArea.StartRow, tempCellArea.EndRow, tempCellArea.StartColumn, tempCellArea.EndColumn);
        targetFirstRow = region.getFirstRow();
        targetLastRow = region.getLastRow();
        targetFirstColumn = region.getFirstColumn();
        targetLastColumn = region.getLastColumn();
        Cell oldCell = st.getCells().get(targetFirstRow, targetFirstColumn);
        for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
          for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
            if (hCount == 1 && vCount == 1) {
              continue;
            }

            int newFirstRow = 0;
            int newLastRow = 0;
            int newFirstColumn = 0;
            int newLastColumn = 0;

            if (vCount == 1) {
              newFirstRow = targetFirstRow;
            } else {
              newFirstRow = targetFirstRow + (tmplRowCount + marginV) * (vCount - 1);
            }
            newLastRow = newFirstRow + (targetLastRow - targetFirstRow);

            if (hCount == 1) {
              newFirstColumn = targetFirstColumn;
            } else {
              newFirstColumn = targetFirstColumn + (tmplColCount + marginH) * (hCount - 1);
            }
            newLastColumn = newFirstColumn + (targetLastColumn - targetFirstColumn);

            // セルマージ
            st.getCells().merge(newFirstRow, newFirstColumn, newLastRow - newFirstRow + 1, newLastColumn - newFirstColumn + 1);
            Cell newCell = st.getCells().get(newFirstRow, newFirstColumn);
            newCell.setStyle(oldCell.getStyle());
          }
        }
      }
    }
  }

  /**
   * patIdsでExcelを編集する。
   * @param workSheets
   * @param baseSheet
   * @param pcList
   * @param params
   * @throws Exception
   */
  // mod #12325 集計内訳の横単位表示を"曜日"で設定すると"VA画像"が表示されない 吉 start
  // private void workbookEditByPatIds(WorksheetCollection workSheets, Worksheet baseSheet,
  private void workbookEditByPatIds(MstReport mstReport,WorksheetCollection workSheets, Worksheet baseSheet,
                                    // mod #12325 集計内訳の横単位表示を"曜日"で設定すると"VA画像"が表示されない 吉 end
                                    List<Integer> pcList, List<ReportXmlParam> params,
                                    List<Long> patIdList,
                                    List<Worksheet> baseStList,
                                    Map<String, String> reportOutputInfo,
                                    Map<String, String> calcResult,
                                    Map<String, String> repeatAddressMap) throws Exception {
    // add #12325 集計内訳の横単位表示を"曜日"で設定すると"VA画像"が表示されない 吉 start
    Map<String, ReportXmlParam> paramMap = params.stream()
      .collect(Collectors.toMap(ReportXmlParam::getId, Function.identity(), (a, b) -> a));
    // add #12325 集計内訳の横単位表示を"曜日"で設定すると"VA画像"が表示されない 吉 end
    for(Integer patCount: pcList) {
      int newSheetIndex = workSheets.addCopy(baseSheet.getIndex());
      Worksheet baseStItem = workSheets.get(newSheetIndex);
      if(params != null){
        for(int j = 0; j < params.size(); j++){
          if("".equals(params.get(j).getIsInTmpl())){
            ReportXmlTmplRepeat reportXmlTmplRepeat = params.stream()
              .filter(p -> p.isTmplRepeat())
              .map(p -> p.getReportXmlTmplRepeat()).findFirst().orElse(null);
            String tmplRepeatAdd = null;
            if(reportXmlTmplRepeat != null){
              tmplRepeatAdd = reportXmlTmplRepeat.getId();
            }
            if(tmplRepeatAdd != null){
              String[] ids = tmplRepeatAdd.split(":");
              if(ids.length==2){
                String str=ids[0];
                String[] idArr = str.split("\\d");
                int firstId = idArr[0].length();
                String strA = str.substring(0, firstId);
                String str2 = ids[1];
                idArr = str2.split("\\d");
                int secondId = idArr[0].length();
                String strB = str2.substring(0, secondId);
                if(strA.equals(strB)){
                  int startId = Integer.parseInt(str.substring(firstId));
                  int endId = Integer.parseInt(str2.substring(secondId));
                  String strZ= str.substring(0,firstId);
                  int CountH = params.stream()
                    .filter(p -> p.isTmplRepeat())
                    .map(p -> p.getReportXmlTmplRepeat())
                    .findFirst().get().getRepeatCountH();
                  int len = patIdList.size();
                  if(CountH < patIdList.size()){
                    len = CountH;
                  }
                  for(int i = startId; i <= endId; i++){
                    for(int y = 1; y <= len; y++){
                      int finalY = y;
                      Cell tempCell =  Optional.ofNullable(baseStItem.getCells().getRows().get(i-1))
                        .map(row -> row.get(finalY))
                        .orElse(null);
                      Cell targetCellOld = AsposeExcelUtil.getFirstCellOfPosition(baseStItem, strZ+i);
                      if (targetCellOld != null && targetCellOld.getType() != CellValueType.IS_NULL) {
                        // 空白セルが setCellStyle の元に設定されると java.lang.NullPointerException が発生します。
                        try {
                          tempCell.setStyle(targetCellOld.getStyle());
                        } catch (Exception ex) {
                          // エラーメッセージ
                          EventLogMessage eventLogMessage = new EventLogMessage();
                          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                          eventLogMessage.setLogMessage("Excelのstyle作成エラー：" + ExcetionStackTraceToString(ex));
                          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      Worksheet finalBaseStItem = baseStItem;
      Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
        .filter(e -> e.getKey().indexOf(MULTIPLE_PAGES_SEPARATOR) < 0)
        .forEach(e -> {
          Integer pgCount = Integer.valueOf(subStrAfter(e.getKey())) - 1;
          if (pgCount == patCount) {
            String replaceKey = "";
            String key = e.getKey();
            if(e.getKey().contains("$")){
              key = key.substring(0,key.lastIndexOf("$"));
            }
            String dataType = ReportUtils.getDataType(params, key);
            // mod #12325 集計内訳の横単位表示を"曜日"で設定すると"VA画像"が表示されない 吉 start
//boolean flag = true;
//            for(ReportXmlParam param : params){
//              if(e.getKey().contains(param.getId()) && param.getDataType().equals("byte[]")){
//                flag = false;
//                break;
//              }
//            }
//            if(flag){
            if(paramMap.containsKey(key) && paramMap.get(key).getDataType().equals("byte[]")){
              setCellValue(mstReport, finalBaseStItem, e, key, dataType, true);
            }else {
              // mod #12325 集計内訳の横単位表示を"曜日"で設定すると"VA画像"が表示されない 吉 end
              if (repeatAddressMap.size() > 0) {
                replaceKey = getReplaceKeyForRepeat(e.getKey(), repeatAddressMap);
                replaceKey = subStrBefore(replaceKey);
              }
              if (replaceKey != null) {
                setCellValueByPositionAndType(finalBaseStItem, replaceKey, e.getValue(), dataType);
              } else {
                setCellValueByPositionAndType(finalBaseStItem, e.getKey(), e.getValue(), dataType);
              }
            }
          }
        });
      baseStList.add(finalBaseStItem);
    }
  }

  /**
   * 単患者
   * @param destSheet
   * @param streamMap
   * @param pagePrefix
   * @param params
   * @param repeatAddressMap
   * @param tmplRepeat
   */
  private void onePatientEdit(Worksheet destSheet,
                              Stream<Map.Entry<String, String>> streamMap,
                              String pagePrefix,
                              List<ReportXmlParam> params,
                              Map<String, String> repeatAddressMap,
                              Optional<ReportXmlTmplRepeat> tmplRepeat) {
    streamMap.forEach(e -> {
      final String key = e.getKey().substring(pagePrefix.length());
      String dataType = ReportUtils.getDataType(params, key);
      String replaceKey = null;
      if (tmplRepeat.isPresent() && key.startsWith(tmplRepeat.get().getId())) {
        // 繰り返し範囲がある場合
        if (repeatAddressMap.size() > 0) {
          replaceKey = getReplaceKey(key, repeatAddressMap);
          setShrinkToFit(destSheet, repeatAddressMap, params);
        }
        if (replaceKey != null) {
          // 繰り返しデータがある場合
          setCellValuePrescription(destSheet, replaceKey, e.getValue(), dataType, tmplRepeat);
        } else {
          // 繰り返しデータがない場合
          setCellValuePrescription(destSheet, key, e.getValue(), dataType, tmplRepeat);
        }
      }else {
        // 繰り返し範囲がある場合
        if (repeatAddressMap.size() > 0) {
          replaceKey = getReplaceKeyForRepeat(key, repeatAddressMap);
        }
        if (replaceKey != null) {
          // 繰り返しデータがある場合
          setCellValueByPositionAndType(destSheet, replaceKey, e.getValue(), dataType);
        } else {
          // 繰り返しデータがない場合
          setCellValueByPositionAndType(destSheet, key, e.getValue(), dataType);
        }
      }
    });
  }

  /**
   * 単患者⇒処方
   * @param destSheet
   * @param streamMap
   * @param pagePrefix
   * @param params
   * @param repeatAddressMap
   * @param tmplRepeat
   */
  private void onePatientOfPrescriptionEdit(Worksheet destSheet,
                          Stream<Map.Entry<String, String>> streamMap,
                          String pagePrefix,
                          List<ReportXmlParam> params,
                          Map<String, String> repeatAddressMap,
                          Optional<ReportXmlTmplRepeat> tmplRepeat) {
    List<ReportXmlParam> sqlCode31List = params.stream()
      .filter(p -> (p.getSqlCode().equals("31")))
      .collect(toList());
    if (sqlCode31List.size() > 0) {
      copyFixedValueForOnePatient(destSheet, tmplRepeat);
    }
    streamMap.forEach(e -> {
      final String key = e.getKey().substring(pagePrefix.length());
      String dataType = ReportUtils.getDataType(params, key);
      String replaceKey = null;
      if (tmplRepeat.isPresent() && key.startsWith(tmplRepeat.get().getId())) {
        if (params.get(0).getSqlCode().equals("31")) {
          setCellValueForOnePatient(destSheet, e.getKey(), e.getValue(), dataType, tmplRepeat);
        } else {
          // 繰り返し範囲がある場合
          if (repeatAddressMap.size() > 0) {
            replaceKey = getReplaceKey(key, repeatAddressMap);
            setShrinkToFit(destSheet, repeatAddressMap, params);
          }
          if (replaceKey != null) {
            // 繰り返しデータがある場合
            setCellValueOnePat(destSheet, replaceKey, e.getValue(), dataType, tmplRepeat);
          } else {
            // 繰り返しデータがない場合
            setCellValueOnePat(destSheet, e.getKey(), e.getValue(), dataType, tmplRepeat);
          }
        }
      }else {
        // 繰り返し範囲がある場合
        if (repeatAddressMap.size() > 0) {
          replaceKey = getReplaceKeyForRepeat(key, repeatAddressMap);
        }
        if (replaceKey != null) {
          // 繰り返しデータがある場合
          setCellValueByPositionAndType(destSheet, replaceKey, e.getValue(), dataType);
        } else {
          // 繰り返しデータがない場合
          setCellValueByPositionAndType(destSheet, key, e.getValue(), dataType);
        }
      }
    });
  }

  /**
   * 紹介状の編集
   * @param destSheet
   * @param streamMap
   * @param pagePrefix
   * @param params
   * @param repeatAddressMap
   * @param tmplRepeat
   * @param isDirectionX
   * @param tmplOffset
   * @param tmplOffsetCol
   */
  private void introductionEdit(Worksheet destSheet,
                                Stream<Map.Entry<String, String>> streamMap,
                                String pagePrefix,
                                List<ReportXmlParam> params,
                                Map<String, String> repeatAddressMap,
                                Optional<ReportXmlTmplRepeat> tmplRepeat,
                                boolean isDirectionX,
                                int tmplOffset,
                                int tmplOffsetCol) {
    streamMap.forEach(e -> {
      final String key = e.getKey().substring(pagePrefix.length());
      String dataType = ReportUtils.getDataType(params, key);
      String replaceKey = null;
      if (tmplRepeat.isPresent() && key.startsWith(tmplRepeat.get().getId())) {
        // 繰り返し範囲がある場合
        if (repeatAddressMap.size() > 0) {
          replaceKey = getReplaceKey(key, repeatAddressMap);
        }
        if (StringUtils.isEmpty(replaceKey)) {
          replaceKey = key;
        }
        Cell targetCell = AsposeExcelUtil.getFirstCellOfPosition(destSheet, replaceKey, isDirectionX, tmplOffset, tmplOffsetCol, tmplRepeat);
        setCellValueByType(targetCell, e.getValue(), dataType);
      }else {
        // 繰り返し範囲がある場合
        if (repeatAddressMap.size() > 0) {
          replaceKey = getReplaceKeyForRepeat(key, repeatAddressMap);
        }
        if (replaceKey != null) {
          // 繰り返しデータがある場合
          setCellValueByPositionAndType(destSheet, replaceKey, e.getValue(), dataType);
        } else {
          // 繰り返しデータがない場合
          setCellValueByPositionAndType(destSheet, key, e.getValue(), dataType);
        }
      }
    });
  }

  /**
   * 複数集計の編集
   * @param destSheet
   * @param streamMap
   * @param pagePrefix
   * @param params
   * @param repeatAddressMap
   * @param tmplRepeat
   * @param isDirectionX
   * @param tmplOffset
   * @param tmplOffsetCol
   */
  private void multiTotalEdit(Worksheet destSheet,
                              Stream<Map.Entry<String, String>> streamMap,
                              String pagePrefix,
                              List<ReportXmlParam> params,
                              Map<String, String> repeatAddressMap,
                              Optional<ReportXmlTmplRepeat> tmplRepeat,
                              boolean isDirectionX,
                              int tmplOffset,
                              int tmplOffsetCol) {
    streamMap.forEach(e -> {
      // 複数集計e = {TreeMap$Entry@19012} "2#A7-1" -> "ベッドB04"
      String key = e.getKey().substring(pagePrefix.length());
      // add #11973 日常点検一覧帳票が正常に出せない limingzhe start
      if(key.contains("@")){
        // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
        //int index = key.indexOf("@");
        //String addr = key.substring(0, index);
        //String dataType = key.substring(index+1);
        //setCellValueByPositionAndType(destSheet, addr, e.getValue(), dataType);
        String[] keyArr = key.split("@");
        String addr = keyArr[0];
        String dataType = keyArr[1];
        String dispFormat = null;
        if(keyArr.length > 2) dispFormat = keyArr[2];
        // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
        if(!StringUtils.isEmpty(e.getValue()) && e.getValue().matches("(?i)^data:image/.*;base64,.*")){
          imgForIntroductionReport(destSheet, addr, e.getValue());
        } else {
          // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
          Cell cell = AsposeExcelUtil.getFirstCellOfPosition(destSheet, addr);
          setCellValueByTypeForTotal(cell, e.getValue(), dataType, dispFormat);
          // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
        }
        // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
        // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
      }
      else {
      // add #11973 日常点検一覧帳票が正常に出せない limingzhe end
        String dataType = ReportUtils.getDataType(params, key);
        String replaceKey = null;
        Cell cell = AsposeExcelUtil.getFirstCellOfPosition(destSheet, key, isDirectionX, tmplOffset, tmplOffsetCol, tmplRepeat);
        if (tmplRepeat.isPresent() && key.startsWith(tmplRepeat.get().getId()) && null != cell) {
          if (repeatAddressMap.size() > 0) {
            replaceKey = getReplaceKey(key, repeatAddressMap);
          }
          if(replaceKey != null) {
            key = replaceKey;
          }
          Cell targetCell = AsposeExcelUtil.getFirstCellOfPosition(destSheet, key, isDirectionX, tmplOffset, tmplOffsetCol, tmplRepeat);
          setCellValueByType(targetCell, e.getValue(), dataType);
        } else {
          if (repeatAddressMap.size() > 0) {
            replaceKey = getReplaceKeyForRepeat(key, repeatAddressMap);
          }
          if (replaceKey != null) {
            Cell targetCell = AsposeExcelUtil.getFirstCellOfPosition(destSheet, replaceKey);
            setCellValueByType(targetCell, e.getValue(), dataType);
          } else {
            setCellValueByPositionAndType(destSheet, key, e.getValue(), dataType);
          }
        }
      // add #11973 日常点検一覧帳票が正常に出せない limingzhe start
      }
      // add #11973 日常点検一覧帳票が正常に出せない limingzhe end
    });
  }

  // add #11985 定期点検一覧帳票が正常に出せない limingzhe start
  /**
   * セルに値を設定します.
   *
   * @param cell セル
   * @param value 値
   * @param dataType データタイプ
   */
  private void setCellValueByTypeForTotal(Cell cell, String value, String dataType, String dispFormat) {
    if (cell == null || StringUtils.isEmpty(value)
      || StringUtils.isEmpty(dataType) || StringUtils.equals("byte[]", dataType)) {
      return;
    }

    // 計算エラーの場合空白を表示する
    if (FAILED_CALC.equals(value)) {
      cell.setValue("");
    }
    else if (DISPLAY_HTML_ERROR.equals(value)) {
      cell.setValue(value);
    }
    else {
      switch (dataType) {
        // データタイプ：数値
        case ReportXmlParam.DATA_TYPE_DECIMAL:
          try {
            // 治療経過表の透析時間「hh:mm」
            if (StringUtils.isNotEmpty(value) && value.contains(":")) {
              String[] tmpTimeChars = value.split(":");
              int minutes = Integer.parseInt(tmpTimeChars[0]) * 60 + Integer.parseInt(tmpTimeChars[1]);
              value = String.valueOf(minutes);
            }
            // 数値型でExcelに貼り付け
            cell.putValue(value, true);
          } catch (NumberFormatException e) {
            // 数値に変換できなかった場合は、文字列としてExcelに張り付け
            cell.setValue(value);
          }
          break;
        // データタイプ：日付
        case ReportXmlParam.DATA_TYPE_DATE_TIME:
          // Excel側の書式を適用させる為、データを Date型に変換してから適用します (処理内容はformatValueに定義されていたもの)
          String cellFormat = cell.getStyle().getCustom().replace("\\", "");
          if(dispFormat != null && !dispFormat.equals(cellFormat)){
            Style style = cell.getStyle();
            style.setCustom(dispFormat);
            cell.setStyle(style);
          }
          try {
            Date date = parseDate(value);
            cell.setValue(date);
          } catch (Exception e) {
            cell.setValue(value);
          }
          break;
        default:
          if (StringUtils.isNotEmpty(value)) {
            if (value != null && value.contains("\uFEFF")) {
              value = value.replace("\uFEFF", "");
            }
            if(value.contains("\n")){
              cell.getStyle().setTextWrapped(true);
            }
            cell.setValue(value);
          }
      }
    }
  }

  private static Date parseDate(String s) throws Exception {
    List<String> formats = Arrays.asList("yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd HH:mm", "MM-dd HH:mm", "yyyy-MM-dd", "EEEE", "yyyy-MM", "M月d日", "HH:mm:ss", "HH:mm", "yyyy/MM", CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601);
    for (String fmt : formats) {
      try {
        return new SimpleDateFormat(fmt).parse(s);
      } catch (Exception ignored) {}
    }
    if(isNumeric(s)){
      String format = Integer.parseInt(s) <= 12 ? "M" : "yyyy";
      try {
        return new SimpleDateFormat(format).parse(s);
      } catch (Exception ignored) {}
    }
    throw new Exception("日付形式を認識できません: " + s);
  }
  // add #11985 定期点検一覧帳票が正常に出せない limingzhe end

  /**
   * 紹介状⇒集計⇒曜日
   * @param destSheet
   * @param streamMap
   * @param pagePrefix
   * @param params
   * @param tmplRepeat
   * @param allRows
   * @param tmplGroupId
   */
  private void introductionByDayOfWeekEdit(Worksheet destSheet,
                                     Stream<Map.Entry<String, String>> streamMap,
                                     String pagePrefix,
                                     List<ReportXmlParam> params,
                                     Optional<ReportXmlTmplRepeat> tmplRepeat,
                                     RowCollection allRows,
                                     List<ReportXmlParam> tmplGroupId) {
    List<ReportXmlParam> paramAddress = params.stream().filter(p->p.getId().equals(p.getReportXmlTmplRepeat().getId())).collect(toList());
    // paramAddress リストから繰り返しアドレスを取得する
    String address = paramAddress.get(0).getRepeatAddress();
    // アドレスをカンマで分割し、valuesArray 配列に格納する
    String[] valuesArray = address.split(",");
    List<String> valuesList = Arrays.asList(valuesArray);
    // valuesList をソートする
    // mod #11294 紹介状で集計部分がずれて出力される 高 start
//    Collections.sort(valuesList);
    String direction = "0".equals(params.get(0).getReportXmlTmplRepeat().getDirection()) ? "N" : "Z";
    if (!isSorted(valuesList,direction)) {
      Collections.reverse(valuesList);
    }
    sortRanges(valuesList);
    // mod #11294 紹介状で集計部分がずれて出力される 高 end
    streamMap.forEach(e -> {
      final String key = e.getKey().substring(pagePrefix.length());
      String dataType = ReportUtils.getDataType(params, key);
      final String groupIdKey = key.split("-")[0];
      String keyOne = "";
      int positionIndex = 0;
      if (key.contains(".")) {
        String [] keyOnes = key.split("\\.");
        keyOne = keyOnes[0];
        if (keyOne.contains("#")) {
          keyOne = keyOnes[0].replace("#", "");
        }
        positionIndex= Integer.parseInt(keyOne.split("-")[1])-1;
      } else{
        positionIndex= Integer.parseInt(key.split("-")[1])-1;
      }
      Map<String, String> weekMap = new HashMap<>();
      String ce = tmplRepeat.get().getId();
      String firstCe = ce.substring(0, 1);
      weekMap.put("1", ce);
      for (int a = 2; a <= tmplRepeat.get().getRepeatCountV(); a++) {
        String next = getNextUpEn(firstCe);
        ce = ce.replace(firstCe, next);
        weekMap.put(String.valueOf(a), ce);
        firstCe = next;
      }
      if (key.contains(".")) {
        String [] keyOnes = key.split("\\.");
        keyOne = keyOnes[0];
      }
      if (tmplRepeat.isPresent() && weekMap.containsValue(keyOne.split("-")[0]) || key.startsWith(tmplRepeat.get().getId())) {
        if (key.contains(".")) {
          String [] keyOnes = key.split("\\.");
          keyOne = keyOnes[0];
          String baseCell = "";
          int rowOff =  Integer.valueOf(keyOne.split("-")[1]);
          int colOff =  Integer.valueOf(keyOnes[1].split("-")[1]);
          int rowOffset = 0;
          int colOffset = 0;
          if (keyOne.indexOf(":") != -1) {
            String startAddress = e.getKey().substring(e.getKey().indexOf("-")+1,e.getKey().indexOf("-")+2);
            String endAddress = e.getKey().substring(e.getKey().lastIndexOf("-")+1,e.getKey().lastIndexOf("-")+2);
            // 新しいアドレス、開始アドレス番号、終了アドレス番号、およびアドレス名を初期化
            int newAddress = 0;
            int startAddressNo = Integer.parseInt(startAddress);
            int endAddressNo = Integer.parseInt(endAddress);
            String addressName = "";
            // 新しいアドレスを計算し、開始アドレス番号と終了アドレス番号に基づく
            newAddress = (paramAddress.get(0).getReportXmlTmplRepeat().getRepeatCountV() * startAddressNo) + (endAddressNo - 1);
            // valuesList からアドレス名を取得
            addressName = valuesList.get(newAddress);
            // アドレス名から基本セルを抽出
            baseCell = addressName.substring(0,addressName.indexOf(":"));
            // 基本セルの行と列のオフセットを取得
            CellReference cellRef = new CellReference(baseCell);
            rowOffset = cellRef.getRow();
            colOffset = cellRef.getCol();
          } else {
            baseCell = keyOne.split("-")[0];
            CellReference cellRef = new CellReference(baseCell);
            rowOffset = cellRef.getRow() + colOff - 1;
            colOffset = cellRef.getCol() + rowOff;
          }
          Cell targetCell = destSheet.getCells().getRows().get(rowOffset).get(colOffset);
          setCellValueByType(targetCell, e.getValue(), ReportUtils.getDataType(params, key));
        }
      }else if(tmplGroupId != null && (tmplGroupId.stream().filter(p -> groupIdKey.equals(p.getId())) != null)){
        // げんざい現在ほじ保持しているじょーほー情報をしゅとく取得する
        List<ReportXmlParam> currentGroupId=  tmplGroupId.stream().filter(p -> groupIdKey.equals(p.getId())).collect(toList());
        // キーとDataCodeを介してExcel情報の保存場所を取得します key: 5 DataCode:18
        for(int i = 0; i <= allRows.getCount(); i++) {
          if(allRows.get(i).get(5).getStringValue() != null && allRows.get(i).get(18).getStringValue() != null
            && currentGroupId != null && currentGroupId.size() > 0) {
            if(allRows.get(i).get(5).getStringValue().equals(currentGroupId.get(0).getDataCode())
              && allRows.get(i).get(18).getStringValue().equals(groupIdKey)) {
              if(allRows.get(i).get(11).getStringValue() != null) {
                // すべて全てのいち位置セットをしゅとく取得する
                String[] positionArr = allRows.get(i).get(11).getStringValue().split(",");
                if(positionArr != null && positionArr.length >= positionIndex + 1) {
                  setCellValueByPositionAndType(destSheet, positionArr[positionIndex], e.getValue(), dataType);
                }
              }
              break;
            }
          }
        }
      }else {
        setCellValueByPositionAndType(destSheet, key, e.getValue(), dataType);
      }
    });
  }

  /**
   * 紹介状⇒集計⇒日
   * @param destSheet
   * @param streamMap
   * @param pagePrefix
   * @param params
   * @param tmplRepeat
   * @param allRows
   * @param tmplGroupId
   */
  private void introductionByDay(Worksheet destSheet,
                                 Stream<Map.Entry<String, String>> streamMap,
                                 String pagePrefix,
                                 List<ReportXmlParam> params,
                                 Optional<ReportXmlTmplRepeat> tmplRepeat,
                                 RowCollection allRows,
                                 List<ReportXmlParam> tmplGroupId) {
    // params リストから条件に一致する ReportXmlParam オブジェクトを抽出し、paramAddress リストに格納する
    List<ReportXmlParam> paramAddress = params.stream().filter(p->p.getId().equals(p.getReportXmlTmplRepeat().getId())).collect(toList());
    // paramAddress リストから繰り返しアドレスを取得する
    String address = paramAddress.get(0).getRepeatAddress();
    // アドレスをカンマで分割し、valuesArray 配列に格納する
    String[] valuesArray = address.split(",");
    List<String> valuesList = Arrays.asList(valuesArray);
    // valuesList をソートする
    // mod #11294 紹介状で集計部分がずれて出力される 高 start
    //    Collections.sort(valuesList);
    String direction = "0".equals(params.get(0).getReportXmlTmplRepeat().getDirection()) ? "N" : "Z";
    if (!isSorted(valuesList,direction)) {
      Collections.reverse(valuesList);
    }
    sortRanges(valuesList);
    // mod #11294 紹介状で集計部分がずれて出力される 高 end
    streamMap.forEach(e -> {
      final String key = e.getKey().substring(pagePrefix.length());
      String dataType = ReportUtils.getDataType(params, key);
      final String groupIdKey= key.split("-")[0];
      String keyOne = "";
      int positionIndex = 0;
      if (key.contains(".")) {
        String [] keyOnes = key.split("\\.");
        keyOne = keyOnes[0];
        if (keyOne.contains("#")) {
          keyOne = keyOnes[0].replace("#", "");
        }
        positionIndex= Integer.parseInt(keyOne.split("-")[1])-1;
      } else{
        positionIndex= Integer.parseInt(key.split("-")[1])-1;
      }
      Map<String, String> weekMap = new HashMap<>();
      String ce = tmplRepeat.get().getId();
      String firstCe = ce.substring(0, 1);
      weekMap.put("1", ce);
      for (int a = 2; a <= tmplRepeat.get().getRepeatCountV(); a++) {
        String next = getNextUpEn(firstCe);
        ce = ce.replace(firstCe, next);
        weekMap.put(String.valueOf(a), ce);
        firstCe = next;
      }
      if (key.contains(".")) {
        String [] keyOnes = key.split("\\.");
        keyOne = keyOnes[0];
      }
      if (tmplRepeat.isPresent() && weekMap.containsValue(keyOne.split("-")[0]) || key.startsWith(tmplRepeat.get().getId())) {
        if (key.contains(".")) {
          String [] keyOnes = key.split("\\.");
          keyOne = keyOnes[0];
          String baseCell = "";
          int rowOff =  Integer.valueOf(keyOne.split("-")[1]);
          int colOff =  Integer.valueOf(keyOnes[1].split("-")[1]);
          int rowOffset = 0;
          int colOffset = 0;
          if (keyOne.indexOf(":") != -1) {
            String startAddress = e.getKey().substring(e.getKey().indexOf("-")+1,e.getKey().indexOf("-")+2);
            String endAddress = e.getKey().substring(e.getKey().lastIndexOf("-")+1,e.getKey().lastIndexOf("-")+2);
            int newAddress = 0;
            int startAddressNo = Integer.parseInt(startAddress);
            int endAddressNo = Integer.parseInt(endAddress);
            String addressName = "";
            newAddress = (paramAddress.get(0).getReportXmlTmplRepeat().getRepeatCountV() * startAddressNo) + (endAddressNo - 1);
            addressName = valuesList.get(newAddress);
            baseCell = addressName.substring(0,addressName.indexOf(":"));
            CellReference cellRef = new CellReference(baseCell);
            rowOffset = cellRef.getRow();
            colOffset = cellRef.getCol();
          } else {
            baseCell = keyOne.split("-")[0];
            CellReference cellRef = new CellReference(baseCell);
            rowOffset = cellRef.getRow() + colOff - 1;
            colOffset = cellRef.getCol() + rowOff;
          }
          Cell targetCell = destSheet.getCells().get(rowOffset, colOffset);
          setCellValueByType(targetCell, e.getValue(), ReportUtils.getDataType(params, key));
        }
      }else if(tmplGroupId != null && (tmplGroupId.stream().filter(p -> groupIdKey.equals(p.getId())) != null) && (tmplGroupId.stream().filter(p -> groupIdKey.equals(p.getId())).collect(toList()).size() > 0)){
        // げんざい現在ほじ保持しているじょーほー情報をしゅとく取得する
        List<ReportXmlParam> currentGroupId=  tmplGroupId.stream().filter(p -> groupIdKey.equals(p.getId())).collect(toList());
        // キーとDataCodeを介してExcel情報の保存場所を取得します key: 5 DataCode:18
        for(int i = 0; i <= allRows.getCount(); i++) {
          if(allRows.get(i).get(5).getStringValue().equals(currentGroupId.get(0).getDataCode())
            && allRows.get(i).get(18).getStringValue().equals(groupIdKey)) {
            // すべて全てのいち位置セットをしゅとく取得する
            String[] positionArr = allRows.get(i).get(11).getStringValue().split(",");
            setCellValueByPositionAndType(destSheet, positionArr[positionIndex], e.getValue(), dataType);
            break;
          }
        }
      }else {
        setCellValueByPositionAndType(destSheet, key, e.getValue(), dataType);
      }
    });
  }

  /**
   * フラフのサイズを計算する。
   * @param range
   * @param worksheet
   * @param isRow
   * @return
   */
  private double computeRangeHeightAndWidth(CellRangeAddress range, Worksheet worksheet, boolean isRow) {
    BigDecimal result = new BigDecimal(0);
    if(isRow) {
      for(int i = range.getFirstRow(); i <= range.getLastRow(); i++) {
        // mod #11622 【デグレード】VA画像の表示が小さくなった limingzhe start
        //result = result.add(new BigDecimal(worksheet.getCells().getRowHeight(i, true, CellsUnitType.POINT)));
        result = result.add(new BigDecimal(worksheet.getCells().getRowHeight(i, false, CellsUnitType.POINT)));
        // mod #11622 【デグレード】VA画像の表示が小さくなった limingzhe end
      }
    } else {
      for(int i = range.getFirstColumn(); i <= range.getLastColumn(); i++) {
        // mod #11622 【デグレード】VA画像の表示が小さくなった limingzhe start
        //result = result.add(new BigDecimal(worksheet.getCells().getColumnWidth(i, true, CellsUnitType.POINT)));
        result = result.add(new BigDecimal(worksheet.getCells().getColumnWidth(i, false, CellsUnitType.POINT)));
        // mod #11622 【デグレード】VA画像の表示が小さくなった limingzhe end
      }
    }
    // Excelのセルの範囲がオバーないように、サイズは小さくなる。
    // mod #11622 【デグレード】VA画像の表示が小さくなった 吉 start
    // result = result.multiply(new BigDecimal(0.9));
    result = result.multiply(new BigDecimal(0.99));
    // mod #11622 【デグレード】VA画像の表示が小さくなった 吉  end
    return Double.parseDouble(result.toString());
  }

  /**
   * ラベル編集
   * @param st
   * @param tmplRepeat
   * @param stPos
   */
  private void labelRemoveStartCell(Worksheet st, Optional<ReportXmlTmplRepeat> tmplRepeat, Integer stPos){
    // テンプレート範囲を取得
    String[] idFT = tmplRepeat.get().getId().split(":");
    if (idFT.length == 2) {
      // tmplRepeatの開始コラム
      int tmplColFrom = 0;
      // tmplRepeatの終了コラム
      int tmplColTo = 0;
      // tmplRepeatの開始行
      int tmplRowFrom = 0;
      // tmplRepeatの終了行
      int tmplRowTo = 0;

      tmplRowFrom = getRowCount(idFT[0]);
      tmplRowTo = getRowCount(idFT[1]);

      tmplColFrom = getColumnCount(idFT[0]);
      tmplColTo = getColumnCount(idFT[1]);

      // style、value のコピー
      if (stPos > 1 && String.format("%s%d", SHEET_NAME_PREFIX, 1).equals(st.getName())) {
        Cell sourceCell = null;
        Style emptyStyle = st.getWorkbook().createStyle();
        for (int i = tmplRowFrom - 1; i< tmplRowTo; i++) {
          for (int j = tmplColFrom - 1; j < tmplColTo; j++) {
            sourceCell = st.getCells().get(i, j);
            sourceCell.setValue("");
            clearBorderStyle(sourceCell, emptyStyle);
          }
        }
      }
    }
  }

  /**
   * 装置のグラフ作成
   * @param ordNo
   * @param dataKey
   * @param getColWidth
   * @param getRowHeight
   * @return
   */
  public List<byte[]> createChartImageResByte(Long ordNo, Map<String, Object> dataKey, String getColWidth, String getRowHeight) {
    List<Integer>countSize = reportChartService.playWrightgetTableHeight(ordNo, ReportChartService.ChartImageType.PNG,getColWidth,getRowHeight,dataKey);
    int countWidth = 0;
    int tableHeight = 0;
    int charHeight = 0;
    int tableFirstTdWidth = 0;
    if(null != countSize && countSize.size() > 0){
        tableHeight = countSize.get(0);
        charHeight = countSize.get(1);
        tableFirstTdWidth = countSize.get(2);
        countWidth = countSize.get(3);
    }
    // モニタ項目Grid取得
    List<String> tableHtmlList = new ArrayList<>();
    if(null != countSize && countSize.size()>0){
      if(tableHeight >0){
        tableHtmlList = reportChartService.getTableHtml(ordNo,countWidth,tableHeight,tableFirstTdWidth,dataKey);
      }else{
        tableHtmlList.add("");
      }
      // mod #10633 【たくしん会】帳票のフォント問題 吉 end
    }else{
      tableHtmlList.add("");
    }
    if(null == countSize || countSize.size() == 0){
      countWidth = Integer.valueOf(getColWidth);
      charHeight = Integer.valueOf(getRowHeight);
    }
    dataKey.put("countWidth",countWidth);
    dataKey.put("countHeight",(tableHeight + charHeight));
    dataKey.put("tableHeight",tableHeight);
    dataKey.put("charHeight",charHeight);
    dataKey.put("tableHtmlList",tableHtmlList);
    dataKey.put("tableFirstTdWidth",tableFirstTdWidth);
    // グラフの生成
    List<byte[]> chartData = dataKey.containsKey(ReportConstant.ReportDataKey.BVMS_CHART_DATA)
      ? (List<byte[]>) dataKey.get(ReportConstant.ReportDataKey.BVMS_CHART_DATA)
      : reportChartService.getPngByPlayWright(ordNo, ReportChartService.ChartImageType.PNG,"deviceEdge".equals(dataKey.get("channel")),dataKey);
    return chartData;
  }

  // add #11622 【デグレード】VA画像の表示が小さくなった limingzhe start
  private int computeStartRowAndColumn(CellRangeAddress range, Worksheet worksheet, boolean isRow, double dOffset) {
    BigDecimal result = new BigDecimal(0);
    if(isRow) {
      for(int i = range.getFirstRow(); i <= range.getLastRow(); i++) {
        result = result.add(new BigDecimal(worksheet.getCells().getRowHeight(i, false, CellsUnitType.POINT)));
        if(Double.parseDouble(result.toString()) > dOffset) return i;
      }
    } else {
      for(int i = range.getFirstColumn(); i <= range.getLastColumn(); i++) {
        result = result.add(new BigDecimal(worksheet.getCells().getColumnWidth(i, false, CellsUnitType.POINT)));
        if(Double.parseDouble(result.toString()) > dOffset) return i;
      }
    }
    return isRow ? range.getFirstRow() : range.getFirstColumn();
  }

  private double computeStartHeightAndWidth(int start, int end, Worksheet worksheet, boolean isRow) {
    BigDecimal result = new BigDecimal(0);
    if(isRow) {
      for(int i = start; i <= end; i++) {
        result = result.add(new BigDecimal(worksheet.getCells().getRowHeight(i, false, CellsUnitType.POINT)));
      }
    } else {
      for(int i = start; i <= end; i++) {
        result = result.add(new BigDecimal(worksheet.getCells().getColumnWidth(i, false, CellsUnitType.POINT)));
      }
    }
    result = result.multiply(new BigDecimal(0.99));
    return Double.parseDouble(result.toString());
  }
  // add #11622 【デグレード】VA画像の表示が小さくなった limingzhe end
  /**
   * イメージを追加する
   * @param destSheet
   * @param range
   * @param inputStream
   * @throws Exception
   */
  private void addPicture(Worksheet destSheet, CellRangeAddress range, InputStream inputStream) throws Exception {
    // mod #12445 【因島】帳票に出力されない画像がある  吉 start
    // int pictureIndex = destSheet.getPictures().add(range.getFirstRow(), range.getFirstColumn(), inputStream);
    byte[] imageBytes = ImageProcessing.checkImageProcessing(inputStream);
    int pictureIndex = destSheet.getPictures().add(range.getFirstRow(), range.getFirstColumn(), new ByteArrayInputStream(imageBytes));
    BufferedImage bufferedImage = ImageIO.read(new ByteArrayInputStream(imageBytes));
    // mod #12445 【因島】帳票に出力されない画像がある  吉 end
    Picture picture = destSheet.getPictures().get(pictureIndex);
    // add #11622 【デグレード】VA画像の表示が小さくなった 吉 start
    // del #12445 【因島】帳票に出力されない画像がある  吉 start
    //BufferedImage bufferedImage = ImageIO.read(inputStream);
    // del #12445 【因島】帳票に出力されない画像がある  吉 end
    double picWidthInPt = bufferedImage.getWidth()* 0.75;
    double picHeightInPt = bufferedImage.getHeight()* 0.75;
    // add #11622 【デグレード】VA画像の表示が小さくなった 吉 end
    // セルのサイズを取得する。
    double rangeHeight = computeRangeHeightAndWidth(range, destSheet, true);
    double rangeWidth = computeRangeHeightAndWidth(range, destSheet, false);
    // del #11622 【デグレード】VA画像の表示が小さくなった 吉 start
    //    picture.setHeightPt(rangeHeight);
    //    picture.setWidthPt(rangeWidth);
    //    // 線と重ねないようにグラフを調整する。
    //    double picWidth = picture.getWidthPt();
    //    double picHeight = picture.getHeightPt();
    // del #11622 【デグレード】VA画像の表示が小さくなった 吉 end
    BigDecimal cellScale = new BigDecimal(rangeHeight).divide(new BigDecimal(rangeWidth), 2, RoundingMode.HALF_UP);
    // mod #11622 【デグレード】VA画像の表示が小さくなった 吉 start
//    BigDecimal picScale = new BigDecimal(picHeight).divide(new BigDecimal(picWidth), 2, RoundingMode.HALF_UP);
//    if(cellScale.compareTo(picScale) == 1) {
//      // 高さが高すぎる
//      BigDecimal tempHeight = new BigDecimal(rangeWidth).multiply(picScale);
//      picture.setHeightPt(tempHeight.doubleValue());
//    } else if(cellScale.compareTo(picScale) == -1) {
//      BigDecimal tempWidth = new BigDecimal(rangeHeight).divide(picScale, 2, RoundingMode.HALF_UP);
//      picture.setWidthPt(tempWidth.doubleValue());
//    }
//    picture.setLeft(2);
//    picture.setTop(2);
    BigDecimal picScale = new BigDecimal(picHeightInPt).divide(new BigDecimal(picWidthInPt), 2, RoundingMode.HALF_UP);
    int pixHeight = 0, pixWidth = 0;
    if (cellScale.compareTo(picScale) == 0) {
      picture.setHeightPt((int) rangeHeight);
      picture.setWidthPt((int) rangeWidth );
      pixHeight = (int) rangeHeight;
      pixWidth = (int) rangeWidth;
    } else if (cellScale.compareTo(picScale) > 0) {
      picture.setWidthPt((int) rangeWidth );
      picture.setHeightPt((int) (rangeWidth * picScale.doubleValue()));
      pixHeight = (int) (rangeWidth * picScale.doubleValue());
      pixWidth = (int) rangeWidth;
    } else {
      picture.setHeightPt((int) rangeHeight );
      picture.setWidthPt((int) (rangeHeight / picScale.doubleValue() ));
      pixHeight = (int) rangeHeight;
      pixWidth = (int) (rangeHeight / picScale.doubleValue());
    }
    int currentLeft = picture.getLeft();
    int currentTop = picture.getTop();
    int firstRow = range.getFirstRow();
    int firstColumn = range.getFirstColumn();
    Cell targetCell = destSheet.getCells().get(firstRow, firstColumn);
    targetCell.setValue("");
    Style style = targetCell.getStyle();
    double left = 0, top = 0;
    if(style.getHorizontalAlignment() == TextAlignmentType.RIGHT){
      left = ((int)rangeWidth - pixWidth);
    } else if(style.getHorizontalAlignment() == TextAlignmentType.CENTER){
      left = ((int)rangeWidth - pixWidth) / 2;
    }
    if(left > 0){
      int iStartColumn = computeStartRowAndColumn(range, destSheet, false, left);
      if(iStartColumn > firstColumn){
        picture.setUpperLeftColumn(iStartColumn);
        double startWidth = computeStartHeightAndWidth(firstColumn, iStartColumn - 1, destSheet, false);
        left = left - startWidth;
      }
    }
    if(style.getVerticalAlignment() == TextAlignmentType.BOTTOM){
      top = ((int)rangeHeight - pixHeight);
    } else if(style.getVerticalAlignment() == TextAlignmentType.CENTER){
      top = ((int)rangeHeight - pixHeight) / 2;
    }
    if(top > 0){
      int iStartRow = computeStartRowAndColumn(range, destSheet, true, top);
      if(iStartRow > firstRow){
        picture.setUpperLeftRow(iStartRow);
        double startHeight = computeStartHeightAndWidth(firstRow, iStartRow - 1, destSheet, true);
        top = top - startHeight;
      }
    }
    picture.setLeft(currentLeft + 1 + (int)(left * 4 / 3));
    picture.setTop(currentTop + 1 + (int)(top * 4 / 3));
    // mod #11622 【デグレード】VA画像の表示が小さくなった 吉 end
  }

  // add #11737 グラフがセルサイズにフィットしないときがある 吉 start
  private void addHighchartPicture(Worksheet destSheet, CellRangeAddress range, InputStream inputStream) throws Exception {
    int pictureIndex = destSheet.getPictures().add(range.getFirstRow(), range.getFirstColumn(), inputStream);
    Picture picture = destSheet.getPictures().get(pictureIndex);
    double rangeHeight = computeRangeHeightAndWidth(range, destSheet, true);
    double rangeWidth = computeRangeHeightAndWidth(range, destSheet, false);
    picture.setHeightPt(rangeHeight);
    picture.setWidthPt(rangeWidth);
    // 線と重ねないようにグラフを調整する。
    double picWidth = picture.getWidthPt();
    double picHeight = picture.getHeightPt();
    BigDecimal cellScale = new BigDecimal(rangeHeight).divide(new BigDecimal(rangeWidth), 2, RoundingMode.HALF_UP);
    BigDecimal picScale = new BigDecimal(picHeight).divide(new BigDecimal(picWidth), 2, RoundingMode.HALF_UP);
    int pixHeight = 0, pixWidth = 0;
    if (cellScale.compareTo(picScale) == 0) {
      picture.setHeightPt((int) rangeHeight);
      picture.setWidthPt((int) rangeWidth );
      pixHeight = (int) rangeHeight;
      pixWidth = (int) rangeWidth;
    } else if (cellScale.compareTo(picScale) > 0) {
      picture.setWidthPt((int) rangeWidth );
      picture.setHeightPt((int) (rangeWidth * picScale.doubleValue()));
      pixHeight = (int) (rangeWidth * picScale.doubleValue());
      pixWidth = (int) rangeWidth;
    } else {
      picture.setHeightPt((int) rangeHeight );
      picture.setWidthPt((int) (rangeHeight / picScale.doubleValue() ));
      pixHeight = (int) rangeHeight;
      pixWidth = (int) (rangeHeight / picScale.doubleValue());
    }
    int currentLeft = picture.getLeft();
    int currentTop = picture.getTop();
    int firstRow = range.getFirstRow();
    int firstColumn = range.getFirstColumn();
    Cell targetCell = destSheet.getCells().get(firstRow, firstColumn);
    Style style = targetCell.getStyle();
    double left = 0, top = 0;
    if(style.getHorizontalAlignment() == TextAlignmentType.RIGHT){
      left = ((int)rangeWidth - pixWidth);
    } else if(style.getHorizontalAlignment() == TextAlignmentType.CENTER){
      left = ((int)rangeWidth - pixWidth) / 2;
    }
    if(left > 0){
      int iStartColumn = computeStartRowAndColumn(range, destSheet, false, left);
      if(iStartColumn > firstColumn){
        picture.setUpperLeftColumn(iStartColumn);
        double startWidth = computeStartHeightAndWidth(firstColumn, iStartColumn - 1, destSheet, false);
        left = left - startWidth;
      }
    }
    if(style.getVerticalAlignment() == TextAlignmentType.BOTTOM){
      top = ((int)rangeHeight - pixHeight);
    } else if(style.getVerticalAlignment() == TextAlignmentType.CENTER){
      top = ((int)rangeHeight - pixHeight) / 2;
    }
    if(top > 0){
      int iStartRow = computeStartRowAndColumn(range, destSheet, true, top);
      if(iStartRow > firstRow){
        picture.setUpperLeftRow(iStartRow);
        double startHeight = computeStartHeightAndWidth(firstRow, iStartRow - 1, destSheet, true);
        top = top - startHeight;
      }
    }
    picture.setLeft(currentLeft + 1 + (int)(left * 4 / 3));
    picture.setTop(currentTop + 1 + (int)(top * 4 / 3));
  }
  // add #11737 グラフがセルサイズにフィットしないときがある 吉 end
  /**
   * セルをコピーする
   * @param sourceCell
   * @param destCell
   */
  private void copyCell(Cell sourceCell, Cell destCell) {
    // 帳票のCellをコピー
    // del #11889 テンプレート繰り返しで罫線の一部が変わってしまう　高　start
//    destCell.setStyle(sourceCell.getStyle());
    // del #11889 テンプレート繰り返しで罫線の一部が変わってしまう　高　end
    destCell.setValue(sourceCell.getValue());
    destCell.setFormula(sourceCell.getFormula());
    commentCopy(sourceCell.getComment(), destCell.getComment());
  }
  // add #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy start
  /**
   * バベルのセルをコピーする
   * @param sourceCell
   * @param destCell
   */
  private void copyCellForLabel(Cell sourceCell, Cell destCell) {
    // 帳票のCellをコピー
    destCell.setStyle(sourceCell.getStyle());
    // mod #12626 ラベル帳票で静的テキストが繰り返されない 高 start
//    destCell.setValue(sourceCell.getValue());
//    destCell.setFormula(sourceCell.getFormula());
    // コピー元セルの数式を取得
    String formula = sourceCell.getFormula();
    // 数式が存在する場合は、コピー先セルにも数式を設定
    if (formula != null && !formula.isEmpty()) {
      destCell.setFormula(formula);
    } else {
      // 数式が存在しない場合は、セルの値をそのまま設定
      destCell.putValue(sourceCell.getValue());
    }
    // mod #12626 ラベル帳票で静的テキストが繰り返されない 高 end
    commentCopy(sourceCell.getComment(), destCell.getComment());
    // add #11742 テンプレート繰り返し範囲の右上の書式がおかしい sunsy end
  }

  /**
   * borderをクリア
   * @param sourceCell
   */
  private void clearBorderStyle(Cell sourceCell, Style style) {
    // colorと関係ない
    style.setBorder(BorderType.BOTTOM_BORDER, BorderStyle.NONE.getCode(), Color.getBlack());
    style.setBorder(BorderType.LEFT_BORDER, BorderStyle.NONE.getCode(), Color.getBlack());
    style.setBorder(BorderType.RIGHT_BORDER, BorderStyle.NONE.getCode(), Color.getBlack());
    style.setBorder(BorderType.TOP_BORDER, BorderStyle.NONE.getCode(), Color.getBlack());
    style.setBackgroundColor(Color.getEmpty());
    sourceCell.setStyle(style);
  }

  /**
   * スタイルのコピー
   */
  private void copyExcelStyle(Worksheet destSheet, MstReport mstReport, List<ReportXmlParam> groupList
      ,Map<String, String> repeatAddressMap
      ,Optional<ReportXmlTmplRepeat> tmplRepeat
      // add #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
      , boolean bCopyAll
      // add #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
  ) {
    // 透析レポート
    if (ReportConstant.ReportClass.DIALYSIS_REPORT.equals(mstReport.getReportClass())) {
      if (groupList.size() != 0) {
        copyStyleFromCells(destSheet, repeatAddressMap);
      }
    }
    // 複数患者帳票
    else if (ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT.equals(mstReport.getReportClass())) {
      // add #11259 テンプレート内の繰り返しで2行目以降の書式がコピーされなくなっている 高 start
      if (groupList.size() != 0) {
        copyStyleFromCells(destSheet, repeatAddressMap);
      }
      // add #11259 テンプレート内の繰り返しで2行目以降の書式がコピーされなくなっている 高 end
      if (tmplRepeat.isPresent()) {
        copyStyleFromTmpl(destSheet, tmplRepeat,ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT);
      }
    }
    // 準備リスト
    else if (ReportConstant.ReportClass.PREPARATION_LIST_REPORT.equals(mstReport.getReportClass())) {
      if (groupList.size() != 0) {
        copyStyleFromCells(destSheet, repeatAddressMap);
      }
    }
    // 配布リスト（ベッド）
    else if (ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT.equals(mstReport.getReportClass())) {
      if (groupList.size() != 0) {
        copyStyleFromCells(destSheet, repeatAddressMap);
      }
      if (tmplRepeat.isPresent()) {
        copyStyleFromTmpl(destSheet, tmplRepeat,ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT);
      }
    }
    // 配布リスト（物品）
    else if (ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT.equals(mstReport.getReportClass())) {
      if (groupList.size() != 0) {
        copyStyleFromCells(destSheet, repeatAddressMap);
      }
      if (tmplRepeat.isPresent()) {
        copyStyleFromTmpl(destSheet, tmplRepeat,ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT);
      }
    }
    // 装置帳票
    else if (ReportConstant.ReportClass.MACHINE_REPORT.equals(mstReport.getReportClass())) {
      if (groupList.size() != 0) {
        copyStyleFromCells(destSheet, repeatAddressMap);
      }
      if (tmplRepeat.isPresent()) {
        copyStyleFromTmpl(destSheet, tmplRepeat, ReportConstant.ReportClass.MACHINE_REPORT);
      }
    }
    // 紹介状(集計)
    else if (ReportConstant.ReportClass.INTRODUCTION_REPORT.equals(mstReport.getReportClass()) && mstReport.getReportType() == 1) {
      if (groupList.size() != 0) {
        if (tmplRepeat.isPresent()) {
          repeatAddressMap.remove(tmplRepeat.get().getId());
        }
        copyStyleFromCells(destSheet, repeatAddressMap);
      }
      if (tmplRepeat.isPresent()) {
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
        //copyStyleFromConvert(destSheet, tmplRepeat);
        copyStyleFromConvert(destSheet, tmplRepeat, bCopyAll);
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
      }
    }
    // 紹介状(テンプレート)
    else if (ReportConstant.ReportClass.INTRODUCTION_REPORT.equals(mstReport.getReportClass()) && mstReport.getReportType() == 2) {
      if (groupList.size() != 0) {
        if (tmplRepeat.isPresent()) {
          repeatAddressMap.remove(tmplRepeat.get().getId());
        }
        copyStyleFromCells(destSheet, repeatAddressMap);
      }
      if (tmplRepeat.isPresent()) {
        copyStyleFromTmpl(destSheet, tmplRepeat,ReportConstant.ReportClass.INTRODUCTION_REPORT);
      }
    }
    // 単一集計
    else if (ReportConstant.ReportClass.ONE_TOTAL_REPORT.equals(mstReport.getReportClass())) {
      if (groupList.size() != 0) {
        if (tmplRepeat.isPresent()) {
          repeatAddressMap.remove(tmplRepeat.get().getId());
        }
        copyStyleFromCells(destSheet, repeatAddressMap);
      }
      if (tmplRepeat.isPresent()) {
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
        //copyStyleFromConvert(destSheet, tmplRepeat);
        copyStyleFromConvert(destSheet, tmplRepeat, false);
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
      }
    }
    // 複数集計
    else if (ReportConstant.ReportClass.MULTI_TOTAL_REPORT.equals(mstReport.getReportClass())) {
      if (groupList.size() != 0) {
        if (tmplRepeat.isPresent()) {
          repeatAddressMap.remove(tmplRepeat.get().getId());
        }
        copyStyleFromCells(destSheet, repeatAddressMap);
      }
      if (tmplRepeat.isPresent()) {
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
        //copyStyleFromConvert(destSheet, tmplRepeat);
        copyStyleFromConvert(destSheet, tmplRepeat, false);
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
      }
    }
  }

  // add #11294 紹介状で集計部分がずれて出力される 高 start
  public static boolean isSorted(List<String> list, String mode) {
    for (int i = 1; i < list.size(); i++) {
      //現在の要素と次の要素を取得します。
      String current = list.get(i - 1);
      String next = list.get(i);

      //パターンによってソートの根拠を選びます。
      if (mode.equals("N")) {
        // N型ソート:アルファベット順に比較します。
        String letterPartCurrent = current.replaceAll("[0-9]", "");
        String letterPartNext = next.replaceAll("[0-9]", "");
        if (letterPartCurrent.compareTo(letterPartNext) > 0) {
          return false; //現在の文字部分が次の文字部分より大きい場合です。
        }
      } else if (mode.equals("Z")) {
        // Z型ソート:数字順に比較します。
        int numberPartCurrent = extractNumber(current);
        int numberPartNext = extractNumber(next);
        if (numberPartCurrent > numberPartNext) {
          return false; // 現在の数字の部分が次の数字の部分より大きい場合です
        }
      }
    }
    return true; //リスト全体が与えられたパターンの順序付けと一致する場合、trueを返します。
  }

  /**
   * 数字の部分を抽出する方法です
   *
   * */
  public static int extractNumber(String range) {
    // 文字列の数字を一致させて返します
    String numberPart = range.replaceAll("[^0-9]", "");
    return Integer.parseInt(numberPart);
  }

  public static void sortRanges(List<String> valuesList) {

    valuesList.sort(new Comparator<String>() {
      @Override
      public int compare(String o1, String o2) {
        // 列と行番号を抽出します
        String[] parts1 = o1.split(":")[0].split("(?<=\\D)(?=\\d)"); // アルファベットと数字を分離します
        String[] parts2 = o2.split(":")[0].split("(?<=\\D)(?=\\d)");
        String column1 = parts1[0], column2 = parts2[0];
        int row1 = Integer.parseInt(parts1[1]);
        int row2 = Integer.parseInt(parts2[1]);

        // 列順,列が同じ時は行順です
        int columnCompare = column1.compareTo(column2);
        return columnCompare != 0 ? columnCompare : Integer.compare(row1, row2);
      }
    });
  }
  // add #11294 紹介状で集計部分がずれて出力される 高 end
  // add #10633 【たくしん会】帳票のフォント問題 吉 start
  @Override
  public String getCellFontName(MstReport mstReport,ReportZipFile reportZipFile,List<ReportXmlParam> params) {
    String key = params.stream().filter(e -> e.getGroupId().indexOf("グラフ") >= 0).map(ReportXmlParam::getId).findFirst().orElse("");
    Workbook baseWorkbook = this.getReportWorkbook(mstReport, reportZipFile);
    WorksheetCollection workSheets = baseWorkbook.getWorksheets();
    Worksheet destSheet = workSheets.get(workSheets.getActiveSheetIndex());
    com.aspose.cells.Cell targetCellOld = AsposeExcelUtil.getFirstCellOfPosition(destSheet, key);
    String fontName = targetCellOld.getStyle().getFont().getName();
    return fontName;
  }
  // add #10633 【たくしん会】帳票のフォント問題 吉 end

  // add #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe start
  /**
   * テンプレート繰返しでの計算式繰返し（「=」で始まる計算式）
   *
   * @param sheet current sheet
   * @param tmplRepeat tmplRepeat要素.
   * @param paramIdInTmpl テンプレート内 データ項目ID
   * @param tmplCount ページ遷移で増えたテンプレート数
   */
  private void formulaCalculateFromTmpl(
    Worksheet sheet,
    ReportXmlTmplRepeat tmplRepeat,
    List<String> paramIdInTmpl,
    Integer tmplCount
  ) {
    // テンプレート文字列が空の場合は処理をスキップ
    if (StringUtils.isEmpty(tmplRepeat.getId())) {
      return;
    }
    // テンプレート設定を取得
    // 繰返回数(縦)
    int repeatCount_V = tmplRepeat.getRepeatCountV();
    // 繰返回数(横)
    int repeatCount_H = tmplRepeat.getRepeatCountH();
    // 繰り返し回数がどちらも1回の場合は実施不要
    if (repeatCount_V <= 1 && repeatCount_H <= 1) {
      return;
    }
    if (tmplCount <= 1) {
      return;
    }

    // 余白(縦)
    int marginV = tmplRepeat.getMarginV();
    // 余白(横)
    int marginH = tmplRepeat.getMarginH();

    Cells baseCells = sheet.getCells();

    // テンプレート範囲を取得
    String[] idFT = tmplRepeat.getId().split(":");
    if (idFT.length == 2) {
      // テンプレート範囲の取得
      CellRangeAddress tmplRange = CellRangeAddress.valueOf(tmplRepeat.getId());
      // テンプレート範囲の開始Column
      int tmplColFrom = tmplRange.getFirstColumn();
      // テンプレート範囲の終了Column
      int tmplColTo = tmplRange.getLastColumn();
      // テンプレート範囲のColumn数
      int tmplColCount = tmplColTo - tmplColFrom + 1;
      // テンプレート範囲の開始Row
      int tmplRowFrom = tmplRange.getFirstRow();
      // テンプレート範囲の終了Row
      int tmplRowTo = tmplRange.getLastRow();
      // テンプレート範囲のRow数
      int tmplRowCount = tmplRowTo - tmplRowFrom + 1;

      for (int rowIndex = tmplRowFrom; rowIndex <= tmplRowTo; rowIndex++) {
        for (int colIndex = tmplColFrom; colIndex <= tmplColTo; colIndex++) {
          Cell sourceCell = baseCells.get(rowIndex, colIndex);
          CellRangeAddress sourceAddress = new CellRangeAddress(sourceCell.getRow(), sourceCell.getRow(), sourceCell.getColumn(), sourceCell.getColumn());
          if(paramIdInTmpl.stream().filter(id -> id.contains(sourceAddress.formatAsString())).count() > 0) {
            continue;
          }
          Integer count = 0;
          if (ReportXmlTmplRepeat.DIRECTION_Z.equals(String.valueOf(tmplRepeat.getDirection()))) {
            // Z方向
            for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
              for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
                count++;
                // コピー先が同じテンプレート範囲の為除外
                if (hCount == 1 && vCount == 1) {
                  continue;
                }
                // データのないテンプレートはコピーされません
                if(count > tmplCount) {
                  continue;
                }

                // コピー先セルを取得
                int tmpRowNo = rowIndex + (tmplRowCount + marginV) * (vCount - 1);
                int tmpColNo = colIndex + (tmplColCount + marginH) * (hCount - 1);
                Cell targetCell = baseCells.get(tmpRowNo, tmpColNo);

                templateCopyFormula(
                  sourceCell,
                  targetCell,
                  tmplRepeat.getId()
                );
              }
            }
          } else {
            // N方向
            for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
              for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
                count++;
                // コピー先が同じテンプレート範囲の為除外
                if (hCount == 1 && vCount == 1) {
                  continue;
                }
                // データのないテンプレートはコピーされません
                if(count > tmplCount) {
                  continue;
                }

                // コピー先セルを取得
                int tmpRowNo = rowIndex + (tmplRowCount + marginV) * (vCount - 1);
                int tmpColNo = colIndex + (tmplColCount + marginH) * (hCount - 1);
                Cell targetCell = baseCells.get(tmpRowNo, tmpColNo);

                templateCopyFormula(
                  sourceCell,
                  targetCell,
                  tmplRepeat.getId()
                );
              }
            }
          }
        }
      }
    } else {
      String cellReference = tmplRepeat.getId();
      // セル参照を解析します
      CellReference ref = new CellReference(cellReference);
      // 列と行のインデックスを取得します
      int rowIndex = ref.getRow();
      int colIndex = ref.getCol();

      // テンプレート範囲のColumn数
      int tmplColCount = 1;
      // テンプレート範囲のRow数
      int tmplRowCount = 1;

      Cell sourceCell = baseCells.get(rowIndex, colIndex);
      CellRangeAddress sourceAddress = new CellRangeAddress(sourceCell.getRow(), sourceCell.getRow(), sourceCell.getColumn(), sourceCell.getColumn());
      if(paramIdInTmpl.stream().filter(id -> id.contains(sourceAddress.formatAsString())).count() > 0) {
        return;
      }
      Integer count = 0;
      if (ReportXmlTmplRepeat.DIRECTION_Z.equals(String.valueOf(tmplRepeat.getDirection()))) {
        // Z方向
        for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
          for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
            count++;
            // コピー先が同じテンプレート範囲の為除外
            if (hCount == 1 && vCount == 1) {
              continue;
            }
            // データのないテンプレートはコピーされません
            if(count > tmplCount) {
              continue;
            }

            // コピー先セルを取得
            int tmpRowNo = rowIndex + (tmplRowCount + marginV) * (vCount - 1);
            int tmpColNo = colIndex + (tmplColCount + marginH) * (hCount - 1);
            Cell targetCell = baseCells.get(tmpRowNo, tmpColNo);

            templateCopyFormula(
              sourceCell,
              targetCell,
              tmplRepeat.getId()
            );
          }
        }
      } else {
        // N方向
        for (int hCount = 1; hCount <= repeatCount_H; hCount ++) {
          for (int vCount = 1; vCount <= repeatCount_V; vCount ++) {
            count++;
            // コピー先が同じテンプレート範囲の為除外
            if (hCount == 1 && vCount == 1) {
              continue;
            }
            // データのないテンプレートはコピーされません
            if(count > tmplCount) {
              continue;
            }

            // コピー先セルを取得
            int tmpRowNo = rowIndex + (tmplRowCount + marginV) * (vCount - 1);
            int tmpColNo = colIndex + (tmplColCount + marginH) * (hCount - 1);
            Cell targetCell = baseCells.get(tmpRowNo, tmpColNo);

            templateCopyFormula(
              sourceCell,
              targetCell,
              tmplRepeat.getId()
            );
          }
        }
      }
    }
  }

  /**
   * テンプレート内（「=」で始まる計算式）のコピーを行う
   * @param sourceCell 元のセル
   * @param targetCell ターゲット・セル
   * @param tmplId tmplRepeat.id属性
   */
  private void templateCopyFormula(
    Cell sourceCell,
    Cell targetCell,
    String tmplId
  ) {
    if(sourceCell == null) return;
    if(targetCell == null) return;
    if(!sourceCell.isFormula()) return;

    String formula = AsposeExcelUtil.changeFormulaLocation(sourceCell, targetCell, sourceCell.getFormula(), tmplId);
    targetCell.setStyle(sourceCell.getStyle());
    try {
      targetCell.setFormula(formula);
    } catch (Exception e) {
      targetCell.setFormula(null);
      targetCell.setValue(StringUtils.SPACE);
    }
  }
  // add #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe end

  // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 start
  public void createQRPic(String value,String key,Worksheet finalBaseSt,String content){
    try {
      // セルのサイズを取得する。
      CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(finalBaseSt, key);
      Cell cell = finalBaseSt.getCells().get(cellRange.getFirstRow(), cellRange.getFirstColumn());
      Style style =cell.getStyle();
      if(!StringUtils.isEmpty(content) && !content.contains("JAHIS10")){
        double rangeWidth = Double.valueOf(value.split("-")[0]);
        double rangeHeight = Double.valueOf(value.split("-")[1]);
        int picSize = rangeWidth > rangeHeight ? (int)rangeHeight : (int)rangeWidth;
        BufferedImage image = new BufferedImage(picSize, picSize, BufferedImage.TYPE_INT_RGB);
        Graphics2D g2d = image.createGraphics();
        java.awt.Color blackColor = new java.awt.Color(0xED, 0xED, 0xED);
        g2d.setColor(blackColor);
        g2d.fillRect(0, 0, image.getWidth(), image.getHeight());

        String sysFontStr = "SansSerif";
        g2d.setFont(new Font(sysFontStr, Font.PLAIN, style.getFont().getSize()));
        g2d.setColor(java.awt.Color.BLACK);
        g2d.drawString(content, 1, style.getFont().getSize()+1);
        g2d.dispose();

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(image, "PNG", baos);
        addPicture(finalBaseSt, cellRange, new ByteArrayInputStream(baos.toByteArray()));
      }else{
        double rangeWidth = Double.valueOf(value.split("-")[0]);
        double rangeHeight = Double.valueOf(value.split("-")[1]);
        double setCellSize = rangeWidth > rangeHeight ? rangeHeight : rangeWidth;
        if(!"".equals(content)){
          BufferedImage qrCodeImage = CreateQrUtil.createBarcode(content, BarcodeFormat.QR_CODE, (int)(setCellSize * 1.3333),(int)(setCellSize * 1.3333));
          ByteArrayOutputStream baos = new ByteArrayOutputStream();
          ImageIO.write(qrCodeImage, "PNG", baos);
          addPicture(finalBaseSt, cellRange, new ByteArrayInputStream(baos.toByteArray()));
        }
      }
    } catch (Exception e) {
      Style style = finalBaseSt.getCells().getStyle();
      style.setPattern(BackgroundType.SOLID);
      style.setForegroundColor(com.aspose.cells.Color.getGray());
      finalBaseSt.getCells().setStyle(style);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
  }
  // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 end
  // add #12324 紹介状の出力時にpat_eventを参照する zhao start
  /**
   * AsposeのWorkbook作成
   * @param mstReport
   * @param reportZipFile
   * @param params
   * @param reportOutputInfoList
   * @param calcResult
   * @param graphOrdNo
   * @param dataKeyOut
   * @param getColWidth
   * @param getRowHeight
   * @return
   */
  public Workbook getReportExcelWorkbookForIntroductionReport(MstReport mstReport,
                                                              ReportZipFile reportZipFile,
                                                              List<ReportXmlParam> params,
                                                              List<Map<String, String>> reportOutputInfoList,
                                                              Map<String, String> calcResult,
                                                              Long graphOrdNo,
                                                              Map<String, Object> dataKeyOut,
                                                              String getColWidth,
                                                              String getRowHeight){
    // asposeでEXCELを取得する。
    Workbook baseWorkbook = this.getReportWorkbook(mstReport, reportZipFile);
    String firstEditSheetName = null;
    try {
      WorksheetCollection workSheets = baseWorkbook.getWorksheets();
      Worksheet paramSheet = workSheets.get("パラメータ");
      Cells paramCells = paramSheet.getCells();
      RowCollection allRows = paramCells.getRows();

      List<ReportXmlParam> tmplGroupId = params.stream()
        .filter(p -> !(p.getGroupId().equals("")))
        .collect(toList());

      // Getting grouping parameters cell's index from header row
      int groupNameIndex = 0;
      int repeatAddressIndex = 0;
      int cellAddressIndex = 0;
      // Loop find index
      Row headRow = allRows.get(0);
      for (int i = 0; i < headRow.getLastDataCell().getColumn(); i++) {
        Cell cell = headRow.get(i);
        switch (cell.getStringValue()) {
          case "GroupName" -> groupNameIndex = i;
          case "RepeatAddress" -> repeatAddressIndex = i;
          case "CellAddress" -> cellAddressIndex = i;
          default -> {}
        }
      }

      // Groupプロパティ取得
      Map<String, String> repeatAddressMap = new HashMap<>();
      for (int i = 1; i < allRows.getCount(); i++) {
        Row eachRow = allRows.get(i);
        if (StringUtils.isNotEmpty(eachRow.get(groupNameIndex).getStringValue())) {
          repeatAddressMap.put(
            eachRow.get(cellAddressIndex).getStringValue()
            , eachRow.get(repeatAddressIndex).getStringValue()
          );
        }
      }

      // テンプレートの繰り返しを取得する。
      ReportXmlTmplRepeat reportXmlTmplRepeat = params.get(0).getReportXmlTmplRepeat();

      if (reportXmlTmplRepeat != null) {
        // 単患者帳票、かつ抽出条件が検査日の場合
        if (ReportConstant.ReportClass.ONE_PATIENT_REPORT.equals(mstReport.getReportClass()) && "Examin".equals(reportXmlTmplRepeat.getRepeatMode())) {
          dataKeyOut.put("onePatientReportType", "2");
        }
      }
      // ページ初期化
      int ctlNoPage = 0;
      for (Map<String, String> reportOutputInfo : reportOutputInfoList) {
        // ページ総数を取得
        int pageCount = getPageCount(reportOutputInfo);
        if (!ReportConstant.ReportClass.ONE_TOTAL_REPORT.equals(mstReport.getReportClass())
          && !ReportConstant.ReportClass.INTRODUCTION_REPORT.equals(mstReport.getReportClass())
          && !ReportConstant.ReportClass.MACHINE_REPORT.equals(mstReport.getReportClass())
          && !ReportConstant.ReportClass.DIALYSIS_REPORT.equals(mstReport.getReportClass())
          && !ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT.equals(mstReport.getReportClass())
          && !ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT.equals(mstReport.getReportClass())
          && !ReportConstant.ReportClass.MULTI_TOTAL_REPORT.equals(mstReport.getReportClass())
          && !ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT.equals(mstReport.getReportClass()
        )
        ) {
          if (StringUtils.isNotEmpty(reportXmlTmplRepeat.getId()) && reportXmlTmplRepeat.getIsNewPage() == 0) {
            pageCount = 1;
          }
        }

        if (reportOutputInfo.size() > 0) {
          if (reportOutputInfo.containsKey("SyohouTyouHyou_Num")) {
            reportOutputInfo.remove("SyohouTyouHyou_Num");
          }
          if (reportOutputInfo.containsKey("Over")) {
            reportOutputInfo.remove("Over");
          }
          reportOutputInfo = sortByKeyB(sortByKeyA(reportOutputInfo));
        }

        // Getting Base WorkSheet
        Worksheet baseSheetBk;
        if(ctlNoPage == 0){
          baseSheetBk = workSheets.get(workSheets.getActiveSheetIndex());
        } else {
          baseSheetBk = workSheets.get(workSheets.getActiveSheetIndex() - 1);
        }

        int copySheetIndex = workSheets.addCopy(baseSheetBk.getIndex());
        Worksheet baseSheet = workSheets.get(copySheetIndex);
        baseSheet.setName(baseSheetBk.getName() + "_copy");

        // 埋め込み先のセル値をクリア
        for (ReportXmlParam reportXmlParam : params) {
          Optional.ofNullable(AsposeExcelUtil.getFirstCellOfPosition(baseSheet, reportXmlParam.getId()))
            .ifPresent(cell -> cell.setValue(null));
        }
        Worksheet tempFinalBaseSheet = baseSheet;
        Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
          .filter(e -> e.getKey().indexOf(MULTIPLE_PAGES_SEPARATOR) < 0)
          .forEach(e -> {
            String replaceKey = "";
            String dataType = ReportUtils.getDataType(params, e.getKey());
            if (repeatAddressMap.size() > 0) {
              replaceKey = getReplaceKeyForRepeat(e.getKey(), repeatAddressMap);
            }
            if (!StringUtils.isEmpty(replaceKey)) {
              if (!dataType.equals("byte[]")) {
                setCellValueByPositionAndType(tempFinalBaseSheet, replaceKey, e.getValue(), dataType);
              } else {
                setCellValue(mstReport, tempFinalBaseSheet, e, replaceKey, dataType, true);
              }
            } else {
              if (!dataType.equals("byte[]")) {
                if (e.getValue().contains("(place)")) {
                  setCellValueByPositionAndType(tempFinalBaseSheet, e.getKey(), "", dataType);
                } else {
                  setCellValueByPositionAndType(tempFinalBaseSheet, e.getKey(), e.getValue(), dataType);
                }
              } else {
                setCellValue(mstReport, tempFinalBaseSheet, e, e.getKey(), dataType, true);
              }
            }
          });
        Optional<ReportXmlTmplRepeat> tmplRepeat = params.stream()
          .filter(p -> p.isTmplRepeat())
          .map(p -> p.getReportXmlTmplRepeat())
          .findFirst();

        List groupList = params.stream().filter(p -> p.getReportXmlGroup() != null)
          .map(p -> p.getReportXmlGroup())
          .collect(toList());

        Map<String, String> reportInfoDl = new HashMap<>();
        Set<Map.Entry<String, String>> sets = reportOutputInfo.entrySet();
        for (Map.Entry<String, String> set : sets) {
          String ket = set.getKey();
          if (ket.contains("$")) {
            reportInfoDl.put(ket, set.getValue());
          }
        }
        Set<Map.Entry<String, String>> setsReportInfoDl = reportInfoDl.entrySet();
        for (Map.Entry<String, String> setDl : setsReportInfoDl) {
          if (setDl.getKey().contains("$")) {
            String cellName = subStrBefore(setDl.getKey());
            reportOutputInfo.put(cellName, setDl.getValue());
            reportOutputInfo.remove(setDl.getKey(), setDl.getValue());
          }
        }

        boolean isDirectionX = tmplRepeat.map(p -> ReportXmlTmplRepeat.DIRECTION_Z.equals(p.getDirection())).orElse(false);
        int tmplOffset = tmplRepeat.map(p -> ReportUtils.getTmplOffset(p.getId(), true)).orElse(0);
        int tmplOffsetCol = tmplRepeat.map(p -> ReportUtils.getTmplOffset(p.getId(), false)).orElse(0);
        Optional<String> graphId = getGraphId(params);
        List<byte[]> chartData = Collections.emptyList();
        Optional<Integer> graphNewPage = getGraphNewPage(params);

        if (graphOrdNo != null && graphId.isPresent()) {
          String fountStr = getCellFontName(mstReport, reportZipFile, params);
          dataKeyOut.put("fountStr", fountStr);
          if (ReportXmlGroup.IS_NEW_PAGE_YES.equals(graphNewPage.get())) {
            dataKeyOut.put("highchatIsNewPage", "1");
          } else {
            dataKeyOut.put("highchatIsNewPage", "0");
          }
          // 処理に必要な引数を空データで作成 ( BVMSのデータ分岐のみに使用する為、この処理ルートでは不要と判断しています )
          chartData = dataKeyOut.containsKey(ReportConstant.ReportDataKey.BVMS_CHART_DATA)
            ? (List<byte[]>) dataKeyOut.get(ReportConstant.ReportDataKey.BVMS_CHART_DATA) : createChartImageResByte(graphOrdNo.longValue(), dataKeyOut, getColWidth, getRowHeight);
        }

        int number = 0;
        if (pageCount > chartData.size() || pageCount == chartData.size()) {
          number = pageCount;
        } else {
          if (graphNewPage.isPresent()) {
            if (ReportXmlGroup.IS_NEW_PAGE_YES.equals(graphNewPage.get())) {
              number = chartData.size();
            } else {
              number = pageCount;
            }
          }
        }
        Map<String, String> funcCellMap = new HashMap<>();
        for (int page = 0; page < number; page++) {
          final String pagePrefix = String.format("%d%s", page + 1, MULTIPLE_PAGES_SEPARATOR);
          int newSheetIndex = workSheets.addCopy(baseSheet.getIndex());
          Worksheet destSheet = workSheets.get(newSheetIndex);
          destSheet.setName(String.format("%s%d", SHEET_NAME_PREFIX, ctlNoPage + page + 1));
          // スタイルのコピー
          copyExcelStyle(destSheet, mstReport, groupList, repeatAddressMap, tmplRepeat, dataKeyOut.get("newPageCountFlag") != null);
          if (StringUtils.isEmpty(firstEditSheetName)) {
            firstEditSheetName = String.format("%s%d", SHEET_NAME_PREFIX, ctlNoPage + page + 1);
          }
          Stream<Map.Entry<String, String>> streamMap = Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
            .filter(e -> e.getKey().startsWith(pagePrefix));
          if (mstReport.getReportClass() == 9 && mstReport.getReportType() == 2) {
            // 紹介状
            introductionEdit(destSheet, streamMap, pagePrefix, params, repeatAddressMap, tmplRepeat, isDirectionX, tmplOffset, tmplOffsetCol);
          } else if (mstReport.getReportClass() == ReportConstant.ReportClass.INTRODUCTION_REPORT && mstReport.getReportType() == 1) {
            // 紹介状⇒集計
            multiTotalEdit(destSheet, streamMap, pagePrefix, params, repeatAddressMap, tmplRepeat, isDirectionX, tmplOffset, tmplOffsetCol);
          }
          // スタイルのコピー
          copyExcelStyle(destSheet, mstReport, groupList, repeatAddressMap, tmplRepeat, dataKeyOut.get("newPageCountFlag") != null);
          List<Integer> repCountList = new ArrayList<>();
          for (Map.Entry<String, String> entry : reportOutputInfo.entrySet()) {
            String key = entry.getKey();
            if (key.contains("@")) continue;
            if (key.contains(".")) {
              if (Integer.parseInt(key.substring(0, key.indexOf("#"))) == page + 1) {
                String key1 = key.split("\\.")[0];
                int repCount1 = Integer.valueOf(key1.split("-")[1]);
                if (!repCountList.contains(repCount1)) {
                  repCountList.add(repCount1);
                }
              }
            }
          }
          // mod #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe start
          final List<Integer> lastRepCount = new ArrayList<>(repCountList);
          // バーコード対象セルの場合はマッピングを保持
          funcCellMap.putAll(formulaCalculateForParams(baseWorkbook, destSheet, params, lastRepCount));
          // mod #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe end
          if (graphNewPage.isPresent()) {
            CellRangeAddress range = AsposeExcelUtil.getCellRange(destSheet, graphId.get());
            if (ReportXmlGroup.IS_NEW_PAGE_YES.equals(graphNewPage.get())) {
              if (page < chartData.size()) {
                // イメージを追加
                addHighchartPicture(destSheet, range, new ByteArrayInputStream(chartData.get(page)));
              }
            } else {
              if (page < pageCount) {
                if (chartData != null && chartData.size() > 0) {
                  // イメージを追加
                  addHighchartPicture(destSheet, range, new ByteArrayInputStream(chartData.get(0)));
                }
              }
            }
          }
          Map<String, String> finalReportOutputInfo = reportOutputInfo;
          params.stream()
            .filter(param -> "true".equals(param.getIsImage()))
            .forEach(param -> {
              finalReportOutputInfo.entrySet()
                .stream()
                .filter(info -> info.getKey().contains(param.getId()))
                .forEach(info -> {
                  String key = info.getKey();
                  String replaceKey = null;
                  if (key.startsWith(pagePrefix)) {
                    key = key.substring(pagePrefix.length());
                    if (tmplRepeat.isPresent() && key.startsWith(tmplRepeat.get().getId())) {
                      // テンプレート内項目の処理
                      if (!repeatAddressMap.isEmpty()) {
                        // テンプレート内の繰り返し設定がある場合、貼り付けセルを取得
                        replaceKey = this.getReplaceKey(key, repeatAddressMap);
                      }
                      if (StringUtils.isEmpty(replaceKey)) {
                        // 対象がなかった場合、取得に失敗した場合は元のセルに対して処理を実施する
                        replaceKey = key;
                      }
                      // テンプレート繰り返し内でのデータ貼り付けセルを取得
                      String path = info.getValue();
                      // データが画像の場合
                      if (StringUtils.isNotEmpty(path)) {
                        // Getting images from S3 service
                        String bucket = String.format(s3BucketForImage, mstReport.getFacilityCd());
                        byte[] excelBytes = reportS3Service.getOutputFileData(bucket, path);
                        CellRangeAddress cellAddresses = AsposeExcelUtil.getCellAddressOfPositionInTmpl(destSheet, replaceKey, isDirectionX
                          , tmplOffset, tmplOffsetCol, tmplRepeat);
                        try {
                          addPicture(destSheet, cellAddresses, new ByteArrayInputStream(excelBytes));
                        } catch (Exception ex) {
                          // エラーメッセージ
                          EventLogMessage eventLogMessage = new EventLogMessage();
                          eventLogMessage.setLogMessage("asposeでグラフのINSERTはエラー：" + NtssUtils.ExcetionStackTraceToString(ex));
                          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                        }
                      }
                    } else {
                      // テンプレート外項目の処理
                      if (!repeatAddressMap.isEmpty()) {
                        // 繰り返し設定がある場合、貼り付けセルを取得
                        replaceKey = this.getReplaceKeyForRepeat(key, repeatAddressMap);
                      }
                      if (StringUtils.isEmpty(replaceKey)) {
                        // 対象がなかった場合、取得に失敗した場合は元のセルに対して処理を実施する
                        replaceKey = key;
                      }
                      setCellValue(mstReport, destSheet, info, replaceKey, param.getDataType(), true);
                    }
                  }
                });
            });

          if (tmplRepeat.isPresent()) {
            // テンプレート繰返しでの計算式繰返し（「=」で始まる計算式）
            List<String> paramIdInTmpl = params.stream().filter(p -> p.isTmplRepeat()).map(p -> p.getId()).collect(toList());
            formulaCalculateFromTmpl(destSheet, tmplRepeat.get(), paramIdInTmpl, repCountList.size());
          }
          //qrコード
          Stream.concat(reportOutputInfo.entrySet().stream(), calcResult.entrySet().stream())
            .forEach(entry -> {
              if (entry.getKey().startsWith(pagePrefix)) {
                final String key = entry.getKey().substring(pagePrefix.length());
                Map<String, String> qrCodeCell = params.stream()
                  .filter(p -> !StringUtils.isEmpty(p.getDataCode()) && p.getDataCode().equals("qrCode"))
                  .collect(Collectors.toMap(m -> m.getId(), m -> m.getColWidth() + "-" + m.getRowHeight()));
                if (null != qrCodeCell && qrCodeCell.size() > 0) {
                  for (Map.Entry<String, String> entry1 : qrCodeCell.entrySet()) {
                    if (entry1.getKey().equals(key)) {
                      createQRPic(entry1.getValue(), key, destSheet, entry.getValue());
                    }
                  }
                }
              } else {
                Map<String, String> qrCodeForNewOne = params.stream()
                  .filter(p -> !StringUtils.isEmpty(p.getDataCode()) && p.getDataCode().equals("qrCodeForNewOne"))
                  .collect(Collectors.toMap(m -> m.getId(), m -> m.getColWidth() + "-" + m.getRowHeight()));
                if (null != qrCodeForNewOne && qrCodeForNewOne.size() > 0) {
                  for (Map.Entry<String, String> entry1 : qrCodeForNewOne.entrySet()) {
                    if (entry1.getKey().equals(entry.getKey())) {
                      createQRPic(entry1.getValue(), entry.getKey(), destSheet, entry.getValue());
                    }
                  }
                }
              }
            });
        }

        // 「レイアウト_copy」シートを削除する
        baseWorkbook.getWorksheets().removeAt(baseSheet.getIndex());

        if(ctlNoPage == reportOutputInfoList.size() - 1){
          // 「レイアウト」シートを削除する
          baseWorkbook.getWorksheets().removeAt(workSheets.getActiveSheetIndex() - 1);
        }

        // activeSheetを設定する
        if (StringUtils.isNotEmpty(firstEditSheetName)) {
          baseWorkbook.getWorksheets().setActiveSheetName(firstEditSheetName);
        }

        Map<String, String> templInFuncQRInfoList = params.stream()
          .filter(p -> p.getDataCode() != null && !"".equals(p.getBarCode()) && p.isTmplRepeat())
          .collect(Collectors.toMap(
            ReportXmlParam::getId,
            p -> p.getBarCode() + "-" + p.getColWidth() + "-" + p.getRowHeight()
          ));
        Map<String, String> templOutFuncQRInfoList = params.stream()
          .filter(p -> p.getDataCode() != null && !"".equals(p.getBarCode()) && !p.isTmplRepeat())
          .collect(Collectors.toMap(
            ReportXmlParam::getId,
            p -> p.getBarCode() + "-" + p.getColWidth() + "-" + p.getRowHeight()
          ));
        if (templInFuncQRInfoList.size() > 0) {
          WorksheetCollection worksheets = baseWorkbook.getWorksheets();
          for (int i = 0; i < worksheets.getCount(); i++) {
            Worksheet sheet = worksheets.get(i);
            int visibility = sheet.getVisibilityType();
            //（0 表示 visible）
            if (visibility == VisibilityType.VISIBLE) {
              for (Map.Entry<String, String> entry1 : templInFuncQRInfoList.entrySet()) {
                if (null != funcCellMap && funcCellMap.size() > 0) {
                  for (Map.Entry<String, String> funcEntry : funcCellMap.entrySet()) {
                    if (funcEntry.getValue().equals(entry1.getKey())) {
                      String cellId = funcEntry.getKey();
                      Cell cell = AsposeExcelUtil.getFirstCellOfPosition(sheet, cellId);
                      String valueToBarCode = String.valueOf(cell.getValue());
                      if (StringUtils.isEmpty(valueToBarCode) || StringUtils.isEmpty(valueToBarCode.strip()) || "null".equals(valueToBarCode)) {
                        continue;
                      }
                      String[] arr = entry1.getValue().split("-");
                      try {
                        CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(sheet, cellId);
                        int firstRow = cellRange.getFirstRow();
                        int firstCol = cellRange.getFirstColumn();
                        Cell targetCell = sheet.getCells().get(firstRow, firstCol);
                        Style style = targetCell.getStyle();
                        int rotation = style.getRotationAngle();
                        BufferedImage qrCodeImage;
                        if (rotation == 90) {
                          qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int) (Integer.valueOf(arr[2]) * 1.3333), (int) (Integer.valueOf(arr[1]) * 1.3333));
                          qrCodeImage = rotateImage(qrCodeImage, -rotation);
                        } else {
                          qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int) (Integer.valueOf(arr[1]) * 1.3333), (int) (Integer.valueOf(arr[2]) * 1.3333));
                        }
                        ByteArrayOutputStream baos = new ByteArrayOutputStream();
                        ImageIO.write(qrCodeImage, "PNG", baos);

                        if (getMergedArea(sheet, cell.getRow(), cell.getColumn()) != null) {
                          CellArea area = getMergedArea(sheet, cell.getRow(), cell.getColumn());
                          CellRangeAddress cellRange1 = new CellRangeAddress(area.StartRow, area.EndRow, area.StartColumn, area.EndColumn);
                          addPicture(sheet, cellRange1, new ByteArrayInputStream(baos.toByteArray()));
                        } else {
                          CellRangeAddress cellRange1 = AsposeExcelUtil.getCellRange(sheet, cellId);
                          addPicture(sheet, cellRange1, new ByteArrayInputStream(baos.toByteArray()));
                        }
                      } catch (Exception e) {
                        continue;
                      }
                    }
                  }
                } else {
                  String cellId = entry1.getKey();
                  Cell cell = AsposeExcelUtil.getFirstCellOfPosition(sheet, cellId);
                  String valueToBarCode = String.valueOf(cell.getValue());
                  if (StringUtils.isEmpty(valueToBarCode) || StringUtils.isEmpty(valueToBarCode.strip()) || "null".equals(valueToBarCode)) {
                    continue;
                  }
                  String[] arr = entry1.getValue().split("-");
                  try {
                    CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(sheet, cellId);
                    int firstRow = cellRange.getFirstRow();
                    int firstCol = cellRange.getFirstColumn();
                    Cell targetCell = sheet.getCells().get(firstRow, firstCol);
                    Style style = targetCell.getStyle();
                    int rotation = style.getRotationAngle();
                    BufferedImage qrCodeImage;
                    if (rotation == 90) {
                      qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int) (Integer.valueOf(arr[2]) * 1.3333), (int) (Integer.valueOf(arr[1]) * 1.3333));
                      qrCodeImage = rotateImage(qrCodeImage, -rotation);
                    } else {
                      qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int) (Integer.valueOf(arr[1]) * 1.3333), (int) (Integer.valueOf(arr[2]) * 1.3333));
                    }
                    ByteArrayOutputStream baos = new ByteArrayOutputStream();
                    ImageIO.write(qrCodeImage, "PNG", baos);
                    addPicture(sheet, cellRange, new ByteArrayInputStream(baos.toByteArray()));
                  } catch (Exception e) {
                    continue;
                  }
                }
              }
            }
          }
        }
        if (templOutFuncQRInfoList.size() > 0) {
          WorksheetCollection worksheets = baseWorkbook.getWorksheets();
          for (int i = 0; i < worksheets.getCount(); i++) {
            Worksheet sheet = worksheets.get(i);
            int visibility = sheet.getVisibilityType();
            if (visibility == VisibilityType.VISIBLE) {
              for (Map.Entry<String, String> entry1 : templOutFuncQRInfoList.entrySet()) {
                String cellId = entry1.getKey();
                Cell cell = AsposeExcelUtil.getFirstCellOfPosition(sheet, cellId);
                String valueToBarCode = String.valueOf(cell.getValue());
                if (StringUtils.isEmpty(valueToBarCode) || StringUtils.isEmpty(valueToBarCode.strip()) || "null".equals(valueToBarCode)) {
                  continue;
                }
                String[] arr = entry1.getValue().split("-");
                try {
                  CellRangeAddress cellRange = AsposeExcelUtil.getCellRange(sheet, cellId);
                  int firstRow = cellRange.getFirstRow();
                  int firstCol = cellRange.getFirstColumn();
                  Cell targetCell = sheet.getCells().get(firstRow, firstCol);
                  Style style = targetCell.getStyle();
                  int rotation = style.getRotationAngle();
                  BufferedImage qrCodeImage;
                  if (rotation == 90) {
                    qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int) (Integer.valueOf(arr[2]) * 1.3333), (int) (Integer.valueOf(arr[1]) * 1.3333));
                    qrCodeImage = rotateImage(qrCodeImage, -rotation);
                  } else {
                    qrCodeImage = CreateQrUtil.createBarcode(valueToBarCode, BarcodeFormat.valueOf(arr[0]), (int) (Integer.valueOf(arr[1]) * 1.3333), (int) (Integer.valueOf(arr[2]) * 1.3333));
                  }
                  ByteArrayOutputStream baos = new ByteArrayOutputStream();
                  ImageIO.write(qrCodeImage, "PNG", baos);
                  addPicture(sheet, cellRange, new ByteArrayInputStream(baos.toByteArray()));
                } catch (Exception e) {
                  continue;
                }
              }
            }
          }
        }
        ctlNoPage++;
      }
    } catch (Exception e) {
      // エラーメッセージ
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("asposeで帳票お作成エラー：" + NtssUtils.ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    return baseWorkbook;
  }
  // add #12324 紹介状の出力時にpat_eventを参照する zhao end
  // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
  /**
   * 紹介状の場合、valueにパースを保存する可能性がる
   * パースにより、S3からイメージを取得する
   * @param sheet シート
   * @param key キー
   * @param value 値
   * */
  private void imgForIntroductionReport(Worksheet sheet, String key, String value){
    // Getting images from S3 service
    String regex = "data:image/[^;]+;base64,([A-Za-z0-9+/=]+)";
    Pattern pattern = Pattern.compile(regex);
    Matcher matcher = pattern.matcher(value);
    if (matcher.find()) {
      CellRangeAddress cellAddresses = AsposeExcelUtil.getCellRange(sheet, key);
      try {
        addPicture(sheet, cellAddresses, new ByteArrayInputStream(Base64.getDecoder().decode(matcher.group(1))));
      } catch (Exception ex) {
        // エラーメッセージ
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("asposeでグラフのINSERTはエラー：" + NtssUtils.ExcetionStackTraceToString(ex));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }
  }
  // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
  // add #10447 テンプレート繰返しでの計算式繰返しの制限事項対応③（項目指定とセル指定の混在）高 start
  /**
   * 数式内に「セル参照と非セル要素の演算」が含まれているかを判定
   * ・複数演算子の混合式を許可
   * ・部分一致で判定（式のどこかに該当片があればOK）
   *
   * 例：
   * "" + BF5                → true
   * 70 + BF5                → true
   * [xx] + BF5              → true
   * BF5 + 70                → true
   * [xx] + BF5/[yy] & C4    → true
   *
   * 非対象：
   * BF5 + C1                → false（cell+cellのみ）
   */
  public boolean hasConcatCellReference(String formula) {
    if (formula == null || formula.isEmpty()) {
      return false;
    }
    // 正規化
    String target = formula.replace("$", "")
      .replace('＆', '&');
    // セル参照
    String cell = "[A-Z]+\\d+";
    // 非セル（数値 / プレースホルダ / 文字列）
    String number = "\\d+(\\.\\d+)?";
    String placeholder = "\\[[^\\]]+\\]";
    // Excelの "" エスケープ対応
    String stringLiteral = "\"([^\"]|\"\")*\"";
    String operand = "(" + number + "|" + placeholder + "|" + stringLiteral + ")";
    // 演算子
    String op = "[+\\-*/%&]";
    /**
     * ポイント：
     * ・cell と 非cell の二項演算が「どこかに」存在すればOK
     * ・複雑な式でも find() で部分一致を拾う
     */
    Pattern pattern = Pattern.compile(
      cell + "\\s*" + op + "\\s*" + operand   // cell + 非cell
        + "|"
        + operand + "\\s*" + op + "\\s*" + cell // 非cell + cell
    );
    return pattern.matcher(target).find();
  }
  /**
   * キー文字列からインデックス（繰り返し番号）を抽出する
   *
   * 想定フォーマット：
   *   xxxx-<index>.yyyy
   *   例：tmpl1-2.A1 → index = 2
   *
   * 処理内容：
   *   1. 最後の「-」の位置を取得
   *   2. その後に出現する最初の「.」の位置を取得
   *   3. 「-」と「.」の間の文字列を切り出し、数値に変換
   *
   * @param key 対象キー文字列
   * @return 抽出したインデックス（取得できない場合は -1）
   */
  private int getIndexFromKey(String key) {
    // 最後の「-」の位置を取得
    int dash = key.lastIndexOf('-');
    // 「-」以降で最初に出現する「.」の位置を取得
    int dot = key.indexOf('.', dash);
    // 「-」と「.」が両方存在する場合のみ処理
    if (dash != -1 && dot != -1) {
      // 「-」と「.」の間の文字列を抽出して整数に変換
      return Integer.parseInt(key.substring(dash + 1, dot));
    }
    // フォーマット不正の場合は -1 を返却
    return -1;
  }
  // add #10447 テンプレート繰返しでの計算式繰返しの制限事項対応③（項目指定とセル指定の混在）高 end

  // add #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe start
  private Map<String, String> formulaCalculateForParams(
    Workbook baseWorkbook,
    Worksheet sheet,
    List<ReportXmlParam> params,
    List<Integer> lastRepCount
  ){
    Map<String, String> funcCellMap = new HashMap<>();
    Optional<ReportXmlTmplRepeat> tmplRepeat = params.stream()
      .filter(p -> p.isTmplRepeat())
      .map(p -> p.getReportXmlTmplRepeat())
      .findFirst();
    boolean isDirectionX = tmplRepeat.map(p -> ReportXmlTmplRepeat.DIRECTION_Z.equals(p.getDirection())).orElse(false);
    int tmplOffset = tmplRepeat.map(p -> ReportUtils.getTmplOffset(p.getId(), true)).orElse(0);
    int tmplOffsetCol = tmplRepeat.map(p -> ReportUtils.getTmplOffset(p.getId(), false)).orElse(0);
    params.stream()
      .filter(ReportXmlParam::hasFunction)
      .forEach(reportXmlParam -> {
        Cell targetCell = AsposeExcelUtil.getFirstCellOfPosition(sheet, reportXmlParam.getId());
        if (targetCell != null
          && StringUtils.isNotEmpty(reportXmlParam.getFunction())
          && !reportXmlParam.getFunction().contains("null")
        ) {
          try {
            if (reportXmlParam.isTmplRepeat()) {
              for (Integer index : lastRepCount) {
                CellRangeAddress cellAddresses = new CellRangeAddress(targetCell.getRow(), targetCell.getRow(), targetCell.getColumn(), targetCell.getColumn());
                String key1 = reportXmlParam.getReportXmlTmplRepeat().getId()
                  + "-" + index
                  + "." + cellAddresses.formatAsString();
                Cell lastCell = AsposeExcelUtil.getFirstCellOfPosition(sheet, key1, isDirectionX, tmplOffset, tmplOffsetCol, tmplRepeat);
                if (lastCell == null) continue;
                if(null != reportXmlParam.getBarCode()){
                  funcCellMap.put(lastCell.getName(),reportXmlParam.getId());
                }
                if (!reportXmlParam.getFunction().contains("[##")) {
                  try {
                    String formula = AsposeExcelUtil.changeFormulaLocation(targetCell, lastCell
                      , reportXmlParam.getFunction(), reportXmlParam.getReportXmlTmplRepeat().getId());
                    lastCell.setStyle(targetCell.getStyle());
                    lastCell.setFormula(formula);
                  } catch (Exception e) {
                    lastCell.setFormula(null);
                    lastCell.setValue(StringUtils.SPACE);
                  }
                }
              }
              baseWorkbook.calculateFormula();
            }
            else {
              if (!reportXmlParam.getFunction().contains("[##")) {
                try {
                  targetCell.setFormula(reportXmlParam.getFunction());
                } catch (Exception ex) {
                  targetCell.setFormula(null);
                  targetCell.setValue(StringUtils.SPACE);
                }
                baseWorkbook.calculateFormula();
                if ((targetCell.getValue() == null && targetCell.getFormula() == null) || "#VALUE!".equals(targetCell.getValue())) {
                  targetCell.setValue("");
                }
              }
            }
          } catch (FormulaParseException ex) {
            // エラーメッセージ
            EventLogMessage eventLogMessage = new EventLogMessage();
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
      });

    for(String id : funcCellMap.keySet()) {
      Cell targetCell = AsposeExcelUtil.getFirstCellOfPosition(sheet, id);
      if ((targetCell.getValue() == null && targetCell.getFormula() == null) || "#VALUE!".equals(targetCell.getValue())) {
        targetCell.setValue("");
      }
    }
    return funcCellMap;
  }
  // add #12725 ##=の計算式で保存時にエラーにならないが出力時にエラー扱いのものがある limingzhe end
}
