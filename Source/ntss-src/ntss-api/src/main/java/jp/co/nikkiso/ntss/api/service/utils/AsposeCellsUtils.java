package jp.co.nikkiso.ntss.api.service.utils;

import com.aspose.cells.Font;
import com.aspose.cells.FontConfigs;
import com.aspose.cells.GridlineType;
import com.aspose.cells.HtmlCrossType;
import com.aspose.cells.HtmlSaveOptions;
import com.aspose.cells.ImageOrPrintOptions;
import com.aspose.cells.ImageSaveOptions;
import com.aspose.cells.ImageType;
import com.aspose.cells.PdfSaveOptions;
import com.aspose.cells.PlacementType;
import com.aspose.cells.Row;
import com.aspose.cells.RowCollection;
import com.aspose.cells.SaveFormat;
import com.aspose.cells.Shape;
import com.aspose.cells.ShapeCollection;
import com.aspose.cells.SheetRender;
import com.aspose.cells.SvgSaveOptions;
import com.aspose.cells.Workbook;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AsposeCellsUtils {

  /**
  ライセンス設定方法については、下記 URL をご参照ください。
  https://www.xlsoft.com/jp/products/aspose/use_license.html?tab=1
  */
//  static {
//    License license = new License();
//    license.setLicense("Aspose.Cells.Java.lic");
//  }
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public static void getLicense(URL licUrl) throws IOException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    com.aspose.cells.License license = new com.aspose.cells.License();
    try {
      InputStream is = licUrl.openStream();
      license.setLicense(is);
    } catch (IOException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      throw e;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    }
  }
  /**
   * Excel Convert To Svg
   * @param inputStream
   * @throws Exception
   */
  public static String excelToSvg(InputStream inputStream, URL url) throws Exception {
    getLicense(url);
    Workbook excel = new Workbook(inputStream);
//    SvgSaveOptions svgSaveOptions = new SvgSaveOptions();
//    svgSaveOptions.setSheetIndex(-1);
//    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
//    excel.save(byteArrayOutputStream, svgSaveOptions);
//    String svgStr = new String(byteArrayOutputStream.toByteArray());
//    // add #10633 【たくしん会】帳票のフォント問題 吉 start
    // mod #10633 【たくしん会】帳票のフォント問題 高 start
//    Map<String,String> fontMap = FontSubstitutionUtil.checkAndReplaceFonts(excel);
    Map<String,String> fontMap = FontSubstitutionUtil.checkAndReplaceFontsSvg(excel);
    // mod #10633 【たくしん会】帳票のフォント問題 高 end
    Font[] fonts = excel.getFonts();
    // add #10633 【たくしん会】帳票のフォント問題 高 start
    Map<String,String> replaceTmp = new HashMap<>();
    // add #10633 【たくしん会】帳票のフォント問題 高 end
    for (Font font : fonts){
      if(fontMap.containsKey(font.getName())){
        FontConfigs.setFontSubstitutes(font.getName(), new String[] { fontMap.get(font.getName()) });
        // add #10633 【たくしん会】帳票のフォント問題 高 start
        replaceTmp.put(font.getName(),fontMap.get(font.getName()));
        // add #10633 【たくしん会】帳票のフォント問題 高 end
      }
    }
    // add #10633 【たくしん会】帳票のフォント問題 吉 end
    // Excelの計算式の再計算処理
    excel.calculateFormula();
    String svgStr = "";
    if(excel.getWorksheets().getCount() > excel.getWorksheets().getActiveSheetIndex()){
      // add #7233 デフォルト帳票について 日本指摘対応 商 start
      String uuid = UUID.randomUUID().toString();
      // add #7233 デフォルト帳票について 日本指摘対応 商 end
      for(int i = excel.getWorksheets().getActiveSheetIndex() ; i<excel.getWorksheets().getCount() ; i++){
        // add 10375 10846患者イベント(テキストエリア)の出力が不正 吉 start
        ShapeCollection shapes = excel.getWorksheets().get(i).getShapes();
        int shapeCount = shapes.getCount();
        for (int j = 0; j < shapeCount;j++) {
          Shape shape = shapes.get(j);
          shape.setPlacement(PlacementType.MOVE_AND_SIZE);
        }
        // add 10848 プレビューだけ行の高さが詰まる 房 start
        Map<Integer, Double> heightMap = saveRowHeight(excel.getWorksheets().get(i).getCells().getRows());
        // add 10848 プレビューだけ行の高さが詰まる 房 end
        excel.getWorksheets().get(i).autoFitRows(true);
        // add 10848 プレビューだけ行の高さが詰まる 房 start
        handleRowHeight(excel.getWorksheets().get(i).getCells().getRows(), heightMap);
        // add 10848 プレビューだけ行の高さが詰まる 房 end
        // add 10375 10846患者イベント(テキストエリア)の出力が不正 吉 end

        // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//        SvgSaveOptions svgSaveOptions = new SvgSaveOptions();
//        svgSaveOptions.setSheetIndex(i);
//        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
//        excel.save(byteArrayOutputStream, svgSaveOptions);
        ImageOrPrintOptions options = new ImageOrPrintOptions();
        options.setImageType(ImageType.SVG);
        options.setOnePagePerSheet(true);
        options.setFontSubstitutionCharGranularity(true);
        SheetRender sr = new SheetRender(excel.getWorksheets().get(i), options);
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        sr.toImage(0,  byteArrayOutputStream);
        // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　end
        String tempVal = new String(byteArrayOutputStream.toByteArray());
        // add #12245 【因島】帳票に出力されない画像がある  吉 start
        String clipPrefix = "CLIP-" + uuid + "-" + i + "-";
        tempVal = tempVal.replaceAll("id=\"CLIP(.*?)\"", "id=\"" + clipPrefix + "$1\"");
        tempVal = tempVal.replaceAll("url\\(#CLIP(.*?)\\)", "url(#" + clipPrefix + "$1)");
        // add #12245 【因島】帳票に出力されない画像がある  吉 end

//        tempVal = tempVal.replaceAll("font-size=\"([1-9]{1,}\\.{0,}[0-9]{0,})\"?","style=\"font-size:$1 !important\"");
        //add 9453 因島帳票の表示不具合（静的静脈圧とΔBVリスト） - 2 李 start*/
        tempVal = tempVal.replaceAll("font-size=\"([1-9]{1,}\\.{0,}[0-9]{0,})\"?","style=\"font-size:$1px !important\"");
        //add 9453 因島帳票の表示不具合（静的静脈圧とΔBVリスト） - 2 李 end*/
        // add Aspose.cells関連バッグ対応 吉 end
        // mod 7822 バイタルグラフ，トレンドデータの表示が荒くて読めない。 吉 start
        // svgStr += "<div>" + tempVal + "</div>";
        // add 10605 【デグレ】観察記録がテンプレート繰返しされない 房 start
        // mod #10943 患者イベントの複数クラスをグループに纏めて抽出したとき項目の順番が狂う 房 start
        //tempVal = tempVal.replace(".f", ".style" + uuid + i + " .f");
        //tempVal = tempVal.replace(".p", ".style" + uuid + i + " .p");
        tempVal = replaceElementF(tempVal, uuid, i);
        tempVal = replaceElementP(tempVal, uuid, i);
        // mod #10943 患者イベントの複数クラスをグループに纏めて抽出したとき項目の順番が狂う 房 end
        // add 10605 【デグレ】観察記録がテンプレート繰返しされない 房 end
        // mod 10605 【デグレ】観察記録がテンプレート繰返しされない 房 start
        svgStr += "<div style=\"text-align:center;\" class=\"style" + uuid + i + "\" >" + tempVal + "</div>";
        // mod 10605 【デグレ】観察記録がテンプレート繰返しされない 房 end
        // mod 7822 バイタルグラフ，トレンドデータの表示が荒くて読めない。 吉 end
      }
    }
    return svgStr ;
  }
  // add #10943 患者イベントの複数クラスをグループに纏めて抽出したとき項目の順番が狂う 房 start
  private static String replaceElementP(String str, String uuid, int i) {
    // mod #10968 処方箋帳票のレイアウト崩れ 房 start
    Pattern pattern = Pattern.compile("\\.p[0-9]+(\\r)?(\\n)?(\\r\\n)?\\{");
    // mod #10968 処方箋帳票のレイアウト崩れ 房 end
    Matcher matcher = pattern.matcher(str);
    while (matcher.find()) {
      String matcherStr = matcher.group();
      str = str.replace(matcherStr, ".style" + uuid + i + " " + matcherStr);
    }
    return str;
  }

  private static String replaceElementF(String str, String uuid, int i) {
    // mod #10968 処方箋帳票のレイアウト崩れ 房 start
    Pattern pattern = Pattern.compile("\\.f[0-9]+(\\r)?(\\n)?(\\r\\n)?\\{");
    // mod #10968 処方箋帳票のレイアウト崩れ 房 end
    Matcher matcher = pattern.matcher(str);
    while (matcher.find()) {
      String matcherStr = matcher.group();
      str = str.replace(matcherStr, ".style" + uuid + i + " " + matcherStr);
    }
    return str;
  }
  // add #10943 患者イベントの複数クラスをグループに纏めて抽出したとき項目の順番が狂う 房 end

  // add #7880 帳票：ラベルが正しく表示されない 姜 start

  /**
   * Excel Convert To Svg
   * @param inputStream
   * @param url
   * @return
   * @throws Exception
   */
  public static String excelToSvgLabel(InputStream inputStream, URL url) throws Exception {
    getLicense(url);
    Workbook excel = new Workbook(inputStream);
    // add #10633 【たくしん会】帳票のフォント問題 吉 start
    Map<String,String> fontMap = FontSubstitutionUtil.checkAndReplaceFonts(excel);
    Font[] fonts = excel.getFonts();
    for (Font font : fonts){
      if(fontMap.containsKey(font.getName())){
        FontConfigs.setFontSubstitutes(font.getName(), new String[] { fontMap.get(font.getName()) });
      }
    }
    // add #10633 【たくしん会】帳票のフォント問題 吉 end
    // add #11330 紹介状画面で計算式が機能しないときがある sunsy start
    // Excelの計算式の再計算処理
    excel.calculateFormula();
    // add #11330 紹介状画面で計算式が機能しないときがある sunsy end
    String svgStr = "";
    if (excel.getWorksheets().getCount() > excel.getWorksheets().getActiveSheetIndex()) {
      for (int i = excel.getWorksheets().getActiveSheetIndex(); i<excel.getWorksheets().getCount(); i++) {
        // add 10375 10846患者イベント(テキストエリア)の出力が不正 吉 start
        ShapeCollection shapes = excel.getWorksheets().get(i).getShapes();
        int shapeCount = shapes.getCount();
        for (int j = 0; j < shapeCount;j++) {
          Shape shape = shapes.get(j);
          shape.setPlacement(PlacementType.MOVE_AND_SIZE);
        }
        excel.getWorksheets().get(i).autoFitRows(true);
        // add 10375 10846患者イベント(テキストエリア)の出力が不正 吉 end
        SvgSaveOptions svgSaveOptions = new SvgSaveOptions();
        svgSaveOptions.setSheetIndex(i);

        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        excel.save(byteArrayOutputStream, svgSaveOptions);
        String tempVal = new String(byteArrayOutputStream.toByteArray());
        // del #12445 【因島】帳票に出力されない画像がある sunsy start
//        tempVal = tempVal.replace("CLIP", "CLIP-" + i + "-");
        // del #12445 【因島】帳票に出力されない画像がある sunsy end
        tempVal = tempVal.replaceAll("font-size=\"([1-9]{1,}\\.{0,}[0-9]{0,})\"?", "style=\"font-size:$1 !important\"");
        tempVal = tempVal.replaceAll("width=\"[0-9]+\\.[0-9]+pt\"", "width=\"584pt\"");
        svgStr += "<div>" + tempVal + "</div>";
      }
    }
    return svgStr ;
  }
  // add #7880 帳票：ラベルが正しく表示されない 姜 end

  /**
   * Excel Convert To HTML
   * @param inputStream
   * @throws Exception
   */
  public static String excelToHtml(InputStream inputStream, URL url) throws Exception {
    getLicense(url);
    Workbook excel = new Workbook(inputStream);
    // add #11330 紹介状画面で計算式が機能しないときがある sunsy start
    // Excelの計算式の再計算処理
    excel.calculateFormula();
    // add #11330 紹介状画面で計算式が機能しないときがある sunsy end
    HtmlSaveOptions htmlSaveOptions = new HtmlSaveOptions();
    htmlSaveOptions.setExportActiveWorksheetOnly(false);
    htmlSaveOptions.setExportHiddenWorksheet(false);
    htmlSaveOptions.setExcludeUnusedStyles(false);
    htmlSaveOptions.setExportWorksheetCSSSeparately(true);
    htmlSaveOptions.setSaveAsSingleFile(true);
    htmlSaveOptions.setExportSingleTab(true);
    htmlSaveOptions.setExportPrintAreaOnly(true);
    //mod  Aspose.cells plug-in integration  吉 start
    // htmlSaveOptions.setWorksheetScalable(true);
    htmlSaveOptions.setExportCellCoordinate(true);
    htmlSaveOptions.setHtmlCrossStringType(HtmlCrossType.CROSS);
    htmlSaveOptions.setWorksheetScalable(true);
    //mod  Aspose.cells plug-in integration  吉 end
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    excel.save(byteArrayOutputStream, htmlSaveOptions);
    String htmlStr = new String(byteArrayOutputStream.toByteArray());
//    return trimScript(htmlStr);
    return htmlStr;
  }

  /**
   * Temporarily used to process unauthorized Aspose.cells to generate redundant html content
   * @param content
   * @return
   */
//  public static String trimScript(String content) {
//    String result = null;
//    String regEx = "<[\\s]*?script[^>]*?>[\\s\\S]*?<[\\s]*?\\/[\\s]*?script[\\s]*?>";
//    Pattern p = Pattern.compile(regEx);
//    Matcher m = p.matcher(content.toLowerCase());
//    result = content;
//    result = result.replace("<div id='section'>","<div id='section' style='position: relative;float: none;'>");
//    result = result.replace("<div id='table_0' style='display:none'","<div id='table_0'");
//    result = result.replace("<div id='table_1' sheetname='evaluation warning'>","<div id='table_1' style='display:none' sheetname='evaluation warning'>");
//    result = result.replace("<div id='footer'>","<div style='display:none' id='footer'>");
//    return result;
//  }


  /**
   * Excel Convert To PDF
   * @param inputStream
   * @param outputStream
   * @throws Exception
   */
  public static void excelToPdf(InputStream inputStream, OutputStream outputStream, URL url) throws Exception {
    getLicense(url);
    Workbook excel = new Workbook(inputStream);
    // add #10633 【たくしん会】帳票のフォント問題 吉 start
    Map<String,String> fontMap = FontSubstitutionUtil.checkAndReplaceFonts(excel);
    Font[] fonts = excel.getFonts();
    for (Font font : fonts){
      if(fontMap.containsKey(font.getName())){
        FontConfigs.setFontSubstitutes(font.getName(), new String[] { fontMap.get(font.getName()) });
      }
    }
    // add #10633 【たくしん会】帳票のフォント問題 吉 end
    // add #11330 紹介状画面で計算式が機能しないときがある sunsy start
    // Excelの計算式の再計算処理
    excel.calculateFormula();
    // add #11330 紹介状画面で計算式が機能しないときがある sunsy end
    // add 10375 10846 患者イベント(テキストエリア)の出力が不正 吉 start
    for(int i = excel.getWorksheets().getActiveSheetIndex() ; i<excel.getWorksheets().getCount() ; i++) {
      ShapeCollection shapes = excel.getWorksheets().get(i).getShapes();
      int shapeCount = shapes.getCount();
      for (int j = 0; j < shapeCount;j++) {
        Shape shape = shapes.get(j);
        shape.setPlacement(PlacementType.MOVE_AND_SIZE);
      }
      // add 10848 プレビューだけ行の高さが詰まる 房 start
      Map<Integer, Double> heightMap = saveRowHeight(excel.getWorksheets().get(i).getCells().getRows());
      // add 10848 プレビューだけ行の高さが詰まる 房 end
      excel.getWorksheets().get(i).autoFitRows(true);
      // add 10848 プレビューだけ行の高さが詰まる 房 start
      handleRowHeight(excel.getWorksheets().get(i).getCells().getRows(), heightMap);
      // add 10848 プレビューだけ行の高さが詰まる 房 end
    }
    // add 10375 10846 患者イベント(テキストエリア)の出力が不正 吉 end
    PdfSaveOptions pdfSaveOptions = new PdfSaveOptions();
    pdfSaveOptions.setOnePagePerSheet(false);
    pdfSaveOptions.setAllColumnsInOnePagePerSheet(false);
    pdfSaveOptions.setCalculateFormula(true);
    // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
    pdfSaveOptions.setFontSubstitutionCharGranularity(true);
    // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end
    pdfSaveOptions.setGridlineType(GridlineType.HAIR);
    excel.save(outputStream, pdfSaveOptions);
  }

  /**
   * Excel Convert To BMP
   * @param inputStream
   * @param outputStream
   * @throws Exception
   */
  public static void excelToBmp(InputStream inputStream, OutputStream outputStream, URL url) throws Exception {
    getLicense(url);
    Workbook excel = new Workbook(inputStream);
    // add #10633 【たくしん会】帳票のフォント問題 吉 start
    Map<String,String> fontMap = FontSubstitutionUtil.checkAndReplaceFonts(excel);
    Font[] fonts = excel.getFonts();
    for (Font font : fonts){
      if(fontMap.containsKey(font.getName())){
        FontConfigs.setFontSubstitutes(font.getName(), new String[] { fontMap.get(font.getName()) });
      }
    }
    // add #10633 【たくしん会】帳票のフォント問題 吉 end
    // add #11330 紹介状画面で計算式が機能しないときがある sunsy start
    // Excelの計算式の再計算処理
    excel.calculateFormula();
    // add #11330 紹介状画面で計算式が機能しないときがある sunsy end
    // add 10375 10846 紹介状で印刷押下でエラー発生/印刷されない 吉 start
    for(int i = excel.getWorksheets().getActiveSheetIndex() ; i<excel.getWorksheets().getCount() ; i++) {
      ShapeCollection shapes = excel.getWorksheets().get(i).getShapes();
      int shapeCount = shapes.getCount();
      for (int j = 0; j < shapeCount;j++) {
        Shape shape = shapes.get(j);
        shape.setPlacement(PlacementType.MOVE_AND_SIZE);
      }
      excel.getWorksheets().get(i).autoFitRows(true);
    }
    ImageSaveOptions imageSaveOptions = new ImageSaveOptions(SaveFormat.BMP);
    excel.save(outputStream, imageSaveOptions);
  }

  // add 10848 プレビューだけ行の高さが詰まる 房 start
  /**
   * 行の高さを保存する。
   * @param rowCollection
   * @return
   */
  private static Map<Integer, Double> saveRowHeight(RowCollection rowCollection) {
    if(rowCollection.getCount() > 0) {
      Map<Integer, Double> heightMap = new HashMap<>();
      Iterator iterator = rowCollection.iterator();
      while(iterator.hasNext()) {
        Row row = (Row)iterator.next();
        heightMap.put(row.getIndex(), row.getHeight());
      }
      return heightMap;
    }
    return null;
  }

  /**
   * 行の高を調整する。
   * @param rowCollection
   * @param heightMap
   */
  private static void handleRowHeight(RowCollection rowCollection, Map<Integer, Double> heightMap) {
    if(heightMap != null && rowCollection.getCount() > 0) {
      Iterator iterator = rowCollection.iterator();
      while(iterator.hasNext()) {
        Row row = (Row)iterator.next();
        double height = row.getHeight();
        if(height < heightMap.get(row.getIndex())) {
          row.setHeight(heightMap.get(row.getIndex()));
        }
        row.setHeightMatched(false);
      }
    }
  }
  // add 10848 プレビューだけ行の高さが詰まる 房 end

  // add 10933 装置にて横長のレポート表示をした際に拡大表示で画面が乱れる 房 start
  /**
   * Excel Convert To BMP
   * @param inputStream
   * @param outputStream
   * @throws Exception
   */
  public static void excelToBmpForDeviceByInitSheet(InputStream inputStream, OutputStream outputStream, URL url) throws Exception {
    getLicense(url);
    Workbook excel = new Workbook(inputStream);
    // add #11330 紹介状画面で計算式が機能しないときがある sunsy start
    // Excelの計算式の再計算処理
    excel.calculateFormula();
    // add #11330 紹介状画面で計算式が機能しないときがある sunsy end
// add #10633 【たくしん会】帳票のフォント問題 吉 start
    Map<String,String> fontMap = FontSubstitutionUtil.checkAndReplaceFonts(excel);
    Font[] fonts = excel.getFonts();
    for (Font font : fonts){
      if(fontMap.containsKey(font.getName())){
        FontConfigs.setFontSubstitutes(font.getName(), new String[] { fontMap.get(font.getName()) });
      }
    }
    // add #10633 【たくしん会】帳票のフォント問題 吉 end
    int printIndex = excel.getWorksheets().getActiveSheetIndex();
    ShapeCollection shapes = excel.getWorksheets().get(printIndex).getShapes();
    int shapeCount = shapes.getCount();
    if(shapeCount > 0) {
      for (int j = 0; j < shapeCount;j++) {
        Shape shape = shapes.get(j);
        shape.setPlacement(PlacementType.MOVE_AND_SIZE);
      }
    }
    Map<Integer, Double> heightMap = saveRowHeight(excel.getWorksheets().get(printIndex).getCells().getRows());
    excel.getWorksheets().get(printIndex).autoFitRows(true);
    handleRowHeight(excel.getWorksheets().get(printIndex).getCells().getRows(), heightMap);
    ImageOrPrintOptions options = new ImageOrPrintOptions();
    // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
    options.setFontSubstitutionCharGranularity(true);
    // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end

    //Set output image format
    options.setImageType(ImageType.BMP);
    //Set Horizontal resolution
    options.setHorizontalResolution(600);

    //Set Vertical Resolution
    options.setVerticalResolution(600);
    SheetRender sheetRender = new SheetRender(excel.getWorksheets().get(printIndex), options);
    //Save chart as Image using ImageOrPrint Options
    sheetRender.toImage(0, outputStream);
  }
  // add 10933 装置にて横長のレポート表示をした際に拡大表示で画面が乱れる 房 end

}
