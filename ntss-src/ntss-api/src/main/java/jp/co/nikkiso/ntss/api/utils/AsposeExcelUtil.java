package jp.co.nikkiso.ntss.api.utils;

import com.aspose.cells.CalculationOptions;
import com.aspose.cells.Cell;
import com.aspose.cells.CellArea;
import com.aspose.cells.Worksheet;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlTmplRepeat;
import org.apache.commons.lang3.StringUtils;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.ss.util.CellReference;

import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AsposeExcelUtil {

  private static final Pattern positionRegex = Pattern.compile("^([^\\-]+)\\-*(\\d*)$");

  private static final Pattern positionRegexTmpl = Pattern.compile("^([^\\-]+)\\-*(\\d*)\\.([^\\.]+)*$");

  private static final Pattern positionRegexTmplPrescription = Pattern.compile("^([^-]+):([^-]+)-*(\\d*).([^-]+)-*(\\d*)$");

  private static final String DISPLAY_HTML_ERROR = "ｴﾗｰ";

  /**
   * Getting range of Excel by position
   * @param sheet cells in sheets
   * @param position  selected position
   * @return  selected Range
   */
  public static CellRangeAddress getCellRange(Worksheet sheet, String position) {
    Matcher m = positionRegex.matcher(position);
    if (!m.matches()) {
      return null;
    }
    CellRangeAddress cellRange = CellRangeAddress.valueOf(m.group(1));
    if (StringUtils.isNotEmpty(m.group(2))) {
      // "-[0-9]"が末尾についていたら、行位置のオフセットとみなす
      int offset = Integer.valueOf(m.group(2)) - 1;
      if (position.startsWith("A7:F9") || position.startsWith("A10:F12")){
        offset *= 2;
      }

      cellRange = moveAsRange(sheet, cellRange, offset);
    }
    return cellRange;
  }

  /**
   * セルは結合の場合、起始行列を取得する。
   * @param sheet
   * @param base
   * @param offset
   * @return
   */
  private static CellRangeAddress moveAsRange(Worksheet sheet, CellRangeAddress base, int offset) {
    // セル結合されている場合を考慮する
    for (int i = 0; i < offset; i++) {
      int delta = 0;
      CellArea[] cellAreas = sheet.getCells().getMergedAreas();
      CellArea tempCellArea = null;
      for(CellArea cellArea : cellAreas) {
        if(base.getFirstRow() >= cellArea.StartRow && base.getLastRow() <= cellArea.EndRow) {
          if(base.getFirstColumn() >= cellArea.StartColumn && base.getLastColumn() <= cellArea.EndColumn) {
            tempCellArea = cellArea;
            break;
          }
        }
      }
      if (tempCellArea != null) {
        delta = tempCellArea.EndRow - tempCellArea.StartRow;
      }
      base.setFirstRow(base.getFirstRow() + delta + 1);
      base.setLastRow(base.getLastRow() + delta + 1);
    }
    return base;
  }

  /**
   * XMLでセルを取得する。
   * @param sheet
   * @param position
   * @param isDirectionX
   * @param tmplOffset
   * @param tmplOffsetCol
   * @param tmplRepeat
   * @return
   */
  public static Cell getFirstCellOfPosition(Worksheet sheet, String position, boolean isDirectionX, int tmplOffset, int tmplOffsetCol, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    Matcher m = positionRegexTmpl.matcher(position);
    if (!m.matches()) {
      return null;
    }
    CellRangeAddress range = Optional.ofNullable(getCellRange(sheet, m.group(3))).orElse(null);
    if (range == null) {
      return null;
    }
    int cols,rows,offset,offset1 = 0;
    int repeatCountH = tmplRepeat.get().getRepeatCountH();
    int repeatCountV = tmplRepeat.get().getRepeatCountV();
    int marginV = tmplRepeat.get().getMarginV();
    int marginH = tmplRepeat.get().getMarginH();
    if (isDirectionX) {
      if((Integer.valueOf(m.group(2))%repeatCountH) == 0){
        cols = repeatCountH *(Integer.valueOf(m.group(2))/repeatCountH)-(repeatCountH-1);
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
    if(offset < 0 ) offset = 0;
    if(offset1 < 0 ) offset1 = 0;
    if (isDirectionX) {
      range.setFirstColumn(range.getFirstColumn() + offset);
      range.setLastColumn(range.getLastColumn() + offset);
      range.setFirstRow(range.getFirstRow() + offset1);
      range.setLastRow(range.getLastRow() + offset1);
    } else {
      range.setFirstColumn(range.getFirstColumn() + offset1);
      range.setLastColumn(range.getLastColumn() + offset1);
      range.setFirstRow(range.getFirstRow() + offset);
      range.setLastRow(range.getLastRow() + offset);
    }
    return getCell(sheet, range.getFirstRow(), range.getFirstColumn());
  }

  /**
   * asposeのセルを取得する。
   * @param sheet
   * @param rowIndex
   * @param columnIndex
   * @return
   */
  public static Cell getCell(Worksheet sheet, int rowIndex, int columnIndex) {
    return Optional.ofNullable(sheet.getCells().getRows().get(rowIndex))
      .map(row -> row.get(columnIndex))
      .orElse(null);
  }

  /**
   * positionでセルを取得する。
   * @param sheet
   * @param position
   * @return
   */
  public static Cell getFirstCellOfPosition(Worksheet sheet, String position) {
    return Optional.ofNullable(getCellRange(sheet, position))
      .map(range -> getCell(sheet, range.getFirstRow(), range.getFirstColumn()))
      .orElse(null);
  }

  /**
   * 関数設定
   * @param sourceCell
   * @param targetCell
   * @param formulaStr
   * @param tempAddress
   * @return
   */
  public static String  changeFormulaLocation(Cell sourceCell, Cell targetCell, String formulaStr, String tempAddress){
    String regex = "\\b([A-Za-z]+[0-9]+)\\b";
    Pattern pattern = Pattern.compile(regex);
    String targetFormula =  formulaStr;
    Matcher matcher = pattern.matcher(formulaStr);
    // add #11694 ##=計算式をテンプレートで繰り返すときセル番地の計算を間違うことがある 吉 start
    StringBuffer result = new StringBuffer();
    // add #11694 ##=計算式をテンプレートで繰り返すときセル番地の計算を間違うことがある 吉 end
    while (matcher.find()) {
      // add #11694 ##=計算式をテンプレートで繰り返すときセル番地の計算を間違うことがある 吉 start
      int start = matcher.start();
      // add #11694 ##=計算式をテンプレートで繰り返すときセル番地の計算を間違うことがある 吉 end
      CellRangeAddress range = CellRangeAddress.valueOf(tempAddress);
      CellRangeAddress cellAddresses = new CellRangeAddress(sourceCell.getRow(), sourceCell.getRow(), sourceCell.getColumn(), sourceCell.getColumn());
      String address  = cellAddresses.formatAsString();
      CellReference cellRef1 = new CellReference(address);
      CellReference cellRef2 = new CellReference(matcher.group(1));
      // セルの行または列の位置を取得する
      if(range.isInRange(cellRef2)){
        int row1 = cellRef1.getRow();
        int col1 = cellRef1.getCol();
        int row2 = cellRef2.getRow();
        int col2 = cellRef2.getCol();
        // オフセット値を計算する
        int offsetRow = row2 - row1;
        int offsetCol = col2 - col1;
        CellReference newCell = new CellReference(targetCell.getRow() + offsetRow, targetCell.getColumn() + offsetCol);
        // mod #11694 ##=計算式をテンプレートで繰り返すときセル番地の計算を間違うことがある 吉 start
        // targetFormula = targetFormula.replace(matcher.group(1),newCell.formatAsString());
        if (!isInsideQuotes(formulaStr, start)) {
          matcher.appendReplacement(result, newCell.formatAsString());
        }
        // mod #11694 ##=計算式をテンプレートで繰り返すときセル番地の計算を間違うことがある 吉 end
      }
    }
    // mod #11694 ##=計算式をテンプレートで繰り返すときセル番地の計算を間違うことがある 吉 start
    // return targetFormula;
    matcher.appendTail(result);
    return result.toString();
    // mod #11694 ##=計算式をテンプレートで繰り返すときセル番地の計算を間違うことがある 吉 end
  }
  // add #11694 ##=計算式をテンプレートで繰り返すときセル番地の計算を間違うことがある 吉 start
  private static boolean isInsideQuotes(String str, int pos) {
    boolean insideQuotes = false;
    for (int i = 0; i < pos; i++) {
      if (str.charAt(i) == '"') {
        insideQuotes = !insideQuotes;
      }
    }
    return insideQuotes;
  }
  // add #11694 ##=計算式をテンプレートで繰り返すときセル番地の計算を間違うことがある 吉 end
  /**
   * Asposeセルオブジェクトの取得(セル範囲の左上).
   *
   * @param sheet ワークシート
   * @param position セル参照文字列(R1C1形式)
   * @param tmplRepeat テンプレート繰り返し
   * @return POIセルオブジェクト
   */
  public static Cell getFirstCellPrescription(Worksheet sheet, String position, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    Matcher m = positionRegexTmplPrescription.matcher(position);
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
    if (!org.springframework.util.StringUtils.isEmpty(m.group(5))) {
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

  /**
   * range名で位置を変換する。
   * @param sheet
   * @param position
   * @param tmplRepeat
   * @return
   */
  public static Cell getCellForOnePatient(Worksheet sheet, String position, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    Matcher m = positionRegexTmplPrescription.matcher(position);
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

  /**
   * セル変換
   * @param sheet
   * @param position
   * @param tmplRepeat
   * @return
   */
  public static Cell getFirstCellOnePat(Worksheet sheet, String position, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    Matcher m = positionRegexTmplPrescription.matcher(position);
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

    int tmplInRepeatNum = 0;
    if (!org.springframework.util.StringUtils.isEmpty(m.group(5))) {
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

  /**
   * Asposeセルオブジェクトの取得(セル範囲の左上).
   *
   * @param sheet ワークシート
   * @param position セル参照文字列(R1C1形式)
   * @return POIセルオブジェクト
   */
  public static Cell getFirstCellForOneTotal(Worksheet sheet, String position) {
    return Optional.ofNullable(getCellRangeForOneTotal(sheet, position))
      .map(range -> getCell(sheet, range.getFirstRow(), range.getFirstColumn()))
      .orElse(null);
  }

  /**
   * Asposeセル範囲の取得.
   *
   * @param sheet ワークシート
   * @param position セル参照文字列(R1C1形式)
   * @return セル範囲
   */
  public static CellRangeAddress getCellRangeForOneTotal(Worksheet sheet, String position) {
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
   * Asposeセル範囲の移動.
   *
   * @param sheet ワークシート
   * @param base ベースセル範囲
   * @param offset Y方向の移動量
   * @return 移動後のセル範囲
   */
  private static CellRangeAddress moveRangeForOneTotal(Worksheet sheet, CellRangeAddress base, int offset) {
    // セル結合されている場合を考慮する
    for (int i = 0; i < offset; i++) {
      int delta = 0;
      CellArea tempCellArea = null;
      CellArea[] cellAreas = sheet.getCells().getMergedAreas();
      for(CellArea cellArea : cellAreas) {
        if(base.getFirstRow() >= cellArea.StartRow && base.getLastRow() <= cellArea.EndRow) {
          if(base.getFirstColumn() >= cellArea.StartColumn && base.getLastColumn() <= cellArea.EndColumn) {
            tempCellArea = cellArea;
            break;
          }
        }
      }
      if (tempCellArea != null) {
        delta = tempCellArea.EndColumn - tempCellArea.StartColumn;
      }
      base.setFirstColumn(base.getFirstColumn() + delta + 1);
      base.setLastColumn(base.getLastColumn() + delta + 1);
    }
    return base;
  }

  /**
   * セルの関数計算結果を取得.
   * @param sheet ワークシート
   * @param position セル参照文字列(R1C1形式)
   * @return 計算結果
   */
  public static Object getFormulaResultValue(Worksheet sheet, String position) {
    Cell targetCell = getFirstCellOfPosition(sheet, position);
    CalculationOptions calculationOptions = new CalculationOptions();
    calculationOptions.setIgnoreError(true);
    targetCell.calculate(calculationOptions);
    // 関数エラーの場合、空白を返す。
    if("#VALUE!".equals(targetCell.getValue())) {
      return "";
    }
    return targetCell.getValue();
  }

  // add #12157 帳票のデータ項目でpat_eventの内部ファイルパスが出力される limingzhe start
  /**
   * XMLでセルを取得する。
   * @param sheet
   * @param position
   * @param isDirectionX
   * @param tmplOffset
   * @param tmplOffsetCol
   * @param tmplRepeat
   * @return
   */
  public static CellRangeAddress getCellAddressOfPositionInTmpl(Worksheet sheet, String position, boolean isDirectionX, int tmplOffset, int tmplOffsetCol, Optional<ReportXmlTmplRepeat> tmplRepeat) {
    Matcher m = positionRegexTmpl.matcher(position);
    if (!m.matches()) {
      return null;
    }
    CellRangeAddress range = Optional.ofNullable(getCellRange(sheet, m.group(3))).orElse(null);
    if (range == null) {
      return null;
    }
    int cols,rows,offset,offset1 = 0;
    int repeatCountH = tmplRepeat.get().getRepeatCountH();
    int repeatCountV = tmplRepeat.get().getRepeatCountV();
    int marginV = tmplRepeat.get().getMarginV();
    int marginH = tmplRepeat.get().getMarginH();
    if (isDirectionX) {
      if((Integer.valueOf(m.group(2))%repeatCountH) == 0){
        cols = repeatCountH *(Integer.valueOf(m.group(2))/repeatCountH)-(repeatCountH-1);
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
    if(offset < 0 ) offset = 0;
    if(offset1 < 0 ) offset1 = 0;
    if (isDirectionX) {
      range.setFirstColumn(range.getFirstColumn() + offset);
      range.setLastColumn(range.getLastColumn() + offset);
      range.setFirstRow(range.getFirstRow() + offset1);
      range.setLastRow(range.getLastRow() + offset1);
    } else {
      range.setFirstColumn(range.getFirstColumn() + offset1);
      range.setLastColumn(range.getLastColumn() + offset1);
      range.setFirstRow(range.getFirstRow() + offset);
      range.setLastRow(range.getLastRow() + offset);
    }
    return range;
  }
  // add #12157 帳票のデータ項目でpat_eventの内部ファイルパスが出力される limingzhe end
}
