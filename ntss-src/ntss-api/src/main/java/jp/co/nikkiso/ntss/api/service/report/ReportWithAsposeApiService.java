package jp.co.nikkiso.ntss.api.service.report;

import com.aspose.cells.Workbook;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlParam;
import jp.co.nikkiso.ntss.api.service.utils.ReportZipFile;
import jp.co.nikkiso.ntss.core.entity.MstReport;

import java.util.List;
import java.util.Map;

public interface ReportWithAsposeApiService {

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
  Workbook getReportExcelWbForOnePatient(
    MstReport mstReport,
    ReportZipFile reportZipFile,
    List<ReportXmlParam> params,
    Map<String, String> reportOutputInfo,
    Map<String, String> calcResult);


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
  Workbook getReportExcelWorkbook(MstReport mstReport,
                                  ReportZipFile reportZipFile,
                                  List<ReportXmlParam> params,
                                  Map<String, String> reportOutputInfo,
                                  Map<String, String> calcResult,
                                  Long graphOrdNo,
                                  Map<String, Object> dataKeyOut,
                                  String getColWidth,
                                  String getRowHeight);

// add #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
  Workbook getReportExcelWorkbookbyHTMLPrint(MstReport mstReport,
                                  ReportZipFile reportZipFile,
                                  List<ReportXmlParam> params,
                                  Map<String, String> reportOutputInfo,
                                  Map<String, Object> dataKeyOut);
// add #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end

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
  Workbook getReportExcelWorkbookToLabel(
    MstReport mstReport,
    ReportZipFile reportZipFile,
    List<ReportXmlParam> params,
    Map<String, String> reportOutputInfo,
    Map<String, String> calcResult,
    Map<String, Object> dataKey
  );

  // add #10633 【たくしん会】帳票のフォント問題 吉 start
  /**
   * 取得cellのフォント
   * @param
   * @return
   */
  String getCellFontName(MstReport mstReport,ReportZipFile reportZipFile,List<ReportXmlParam> params);
  // add #10633 【たくしん会】帳票のフォント問題 吉 end
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
  Workbook getReportExcelWorkbookForIntroductionReport(MstReport mstReport,
                                                       ReportZipFile reportZipFile,
                                                       List<ReportXmlParam> params,
                                                       List<Map<String, String>> reportOutputInfoList,
                                                       Map<String, String> calcResult,
                                                       Long graphOrdNo,
                                                       Map<String, Object> dataKeyOut,
                                                       String getColWidth,
                                                       String getRowHeight);
  // add #12324 紹介状の出力時にpat_eventを参照する zhao end
}


