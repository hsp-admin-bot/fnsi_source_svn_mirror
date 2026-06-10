package jp.co.nikkiso.ntss.api.service.utils;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.ss.util.CellReference;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * セル内容が計算式である状況でのコピー処理
 */
public class ExcelCopyWithFormula {
  /**
   *
   * @param sourceCell  コピー元のセル
   * @param targetCell  コピー先のセル
   * @param templAddress テンプレート範囲
   * @return
   */
  public static String  changeCell (Cell sourceCell, Cell targetCell, String templAddress){
    String regex = "\\b([A-Z]+[0-9]+)";
    Pattern pattern = Pattern.compile(regex);
    String targerFormu =  sourceCell.getCellFormula();
    if (sourceCell != null && sourceCell.getCellType() == CellType.FORMULA) {
      String formulaStr = sourceCell.getCellFormula();
      Matcher matcher = pattern.matcher(formulaStr);
      while (matcher.find()) {
        CellRangeAddress range = CellRangeAddress.valueOf(templAddress);
        String adress  = sourceCell.getAddress().toString();
        CellReference cellRef1 = new CellReference(adress);
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
          CellReference newCell = new CellReference(targetCell.getRowIndex() + offsetRow, targetCell.getColumnIndex() + offsetCol);
          targerFormu = targerFormu.replace(matcher.group(1),newCell.formatAsString());
        }
      }
    }
    return targerFormu;
  }

  public static String  changeFormu (Cell sourceCell,Cell targetCell,String formulaStr,String templAddress){
    // #10490 テンプレート繰返しの計算式が余計に繰り返される 高　start
//    String regex = "\\b([A-Z]+[0-9]+)";
    String regex = "\\b([A-Za-z]+[0-9]+)\\b";
    // #10490 テンプレート繰返しの計算式が余計に繰り返される 高　end
    Pattern pattern = Pattern.compile(regex);
    String targerFormu =  formulaStr;
    Matcher matcher = pattern.matcher(formulaStr);
    while (matcher.find()) {
      CellRangeAddress range = CellRangeAddress.valueOf(templAddress);
      String adress  = sourceCell.getAddress().toString();
      CellReference cellRef1 = new CellReference(adress);
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
        CellReference newCell = new CellReference(targetCell.getRowIndex() + offsetRow, targetCell.getColumnIndex() + offsetCol);
        targerFormu = targerFormu.replace(matcher.group(1),newCell.formatAsString());
      }
    }
    return targerFormu;
  }
}
