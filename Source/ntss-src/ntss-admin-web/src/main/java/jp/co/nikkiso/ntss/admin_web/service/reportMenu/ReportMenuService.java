package jp.co.nikkiso.ntss.admin_web.service.reportMenu;

import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.custom.ReportMenuSortContainer;

import java.text.ParseException;
import java.util.List;
import java.util.Map;

/**
 * 帳票出力するServiceインタフェース.
 */
public interface ReportMenuService {

  /**
   * 帳票画面から検索条件で治療リストの検索
   *
   * @param reportMenu
   * @return
   */
  Map<Long, List<Long>> getOrdNoList(ReportMenuSortContainer reportMenu);

  /**
   * 帳票出力結果がHTMLに変換
   *
   * @param reportMenu
   * @param userName ユーザー名
   * @return
   */
  List<Map<Long, List<String>>> getHtmlReport(ReportMenuSortContainer reportMenu, String userName) throws Exception;

  /**
   * Zipファイルの生成
   *
   * @param patFile
   * @param reportName
   * @param option
   * @return
   */
  /*mod FNSI-改修内容装置帳票の対応 任 start*/
  /*byte[] zipFile(List<Map<Long, List<byte[]>>> patFile, String reportName, Integer option);*/
  byte[] zipFile(List<Map<Long, List<byte[]>>> patFile, String reportName, Integer option,Integer reportClass);
  /*mod FNSI-改修内容装置帳票の対応 任 end*/
  /**
   * Zipファイルの生成
   *
   * @param patPdf
   * @param patExcel
   * @param reportName
   * @return
   */
  byte[] zipFileMultiPat(byte[] patPdf, byte[] patExcel, String reportName);

  /**
   * ファイルの生成
   *
   * @param html
   * @return
   */
  byte[] convertHtmlToPdf(String html) throws Exception;

  /**
   * 患者IDでファイル名の生成
   *
   * @param patId
   * @param reportName
   * @return
   */
  String getFileNameByPatId(Long patId, String reportName);

  /**
   * ソートされたOrdList習得
   *
   * @param reportMenu
   * @return
   */
  List<OrdMain> getOrdNoListSorted(ReportMenuSortContainer reportMenu);

  /**
   * 帳票htmlを取得します.
   * 出力する帳票htmlは画面で指定された並び順に従った順番です.
   *
   * @param reportMenu 帳票出力用のパラメータ
   * @param userId     利用者ID
   * @param userName   利用者名
   * @return 生成した帳票html
   */
  String getHtmlReportSorted(ReportMenuSortContainer reportMenu, Long userId, String userName) throws Exception;

  /**
   * 帳票印刷
   *
   * @param patHtmls
   * @param reportName
   * @param printerCd
   * @throws Exception
   */
  void printReport(List<Map<Long, List<String>>> patHtmls, String reportName, Long printerCd) throws Exception;

  /**
   * pdf帳票印刷
   * @param patPdfFiles
   * @param reportName
   * @param printerCd
   * @throws Exception
   */
  void printPdfReport(List<Map<Long, List<byte[]>>> patPdfFiles, String reportName, Long printerCd) throws Exception;

  //add #9616 帳票印刷失敗通知がされない 李 start
  void printPdfReport(List<Map<Long, List<byte[]>>> patPdfFiles, String reportName, Long printerCd, String reportType) throws Exception;
  //add #9616 帳票印刷失敗通知がされない 李 end

  //add  Aspose.cells plug-in integration  吉 start
  // mod 9608 紹介状印刷時に同時に出力される透析レポートについて　吉 start
  // void IntroductionLetterPrintPdfReport(Map<String, byte[]>patPdfFiles, String reportName, Long printerCd) throws Exception;
  void IntroductionLetterPrintPdfReport(Map<String, byte[]>patPdfFiles, String reportName, Long printerCd, String facilityCd) throws Exception;
  // mod 9608 紹介状印刷時に同時に出力される透析レポートについて　吉 end
  //add  Aspose.cells plug-in integration  吉 end

  // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
  void printPdfReportForReferralLetter(List<Map<Long, List<byte[]>>> patPdfFiles, String reportName, Long printerCd, String reportType) throws Exception ;
  // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end

  //add #9616 帳票印刷失敗通知がされない 李 start
  void IntroductionLetterPrintPdfReport(Map<String, byte[]>patPdfFiles, String reportName, Long printerCd, String facilityCd, String reportType) throws Exception;
  //add #9616 帳票印刷失敗通知がされない 李 end

  /**
   * 複数な患者の印刷実装
   *
   * @param html
   * @param printerCd
   * @throws Exception
   */
  //mod 帳票印刷の命名規則が変更されました 吉 start
//  void printReportMultiPat(String html, Long printerCd) throws Exception;
  void printReportMultiPat(String html, Long printerCd,String reportName) throws Exception;
  //mod 帳票印刷の命名規則が変更されました 吉 end
  /*add FNSI-改修内容装置帳票の対応 任 start*/
  Long getReportCd(ReportMenuSortContainer reportMenu) throws Exception;
  /*add FNSI-改修内容装置帳票の対応 任 end*/
  // add FNSI-印刷失敗時の通知を追加 江 start
  void registerNotification(String facilityCd, String reportType, String reportName) throws Exception;
  // add FNSI-印刷失敗時の通知を追加 江 end
  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 start
  List<Long> getPatIdByPayLoad(ReportMenuSortContainer payload) throws Exception;
  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end
//add 5565 並び替えを実施してもその情報が保持されない 吉 start
  int saveSortList(MstReport payload) throws Exception;
  //add 5565 並び替えを実施してもその情報が保持されない 吉 end
  MstReport getSortList(String facilityCd, Long printerCd) throws Exception;
  // add #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 start
  void getOption(boolean optionFlag);
  // add #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 end
  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ Asposeを使用する前提の処理です
   * ※ 帳票種別：02：単患者帳票 用の処理です
   *
   * @param reportMenu
   * @param userName
   * @return
   */
  List<Map<Long, byte[]>> getReportExcelFilesForOnePatient(ReportMenuSortContainer reportMenu, String userName) throws Exception;

  /**
   * 帳票種別：02：単患者帳票 で使用する sys_data_set に渡すパラメータを生成
   * ※ 帳票種別：02：単患者帳票 用の処理です
   *
   * @param
   * @param
   * @return
   */
  Map<String, Object> createDataKeyForOnePatient(Map<String,List> searchList, String fromDate, String toData, String facilityCd, List<Long> ordNos, Long patId, List<Long> ordPrescriptionNos);

  //add #9058【IES起票】状況マップ画面にて単患者帳票機能帳票印刷後線とプレビューが不一致 liuc start
  /**
   * pdf機能帳票印刷
   * バッチ
   * @param patPdfFiles
   * @param reportName
   * @param printerCd
   * @throws Exception
   */
  void engineryReportPdfPrintBatch(List<Map<Long, List<byte[]>>> patPdfFiles, String reportName, Long printerCd) throws Exception;


  /**
   * pdf機能帳票印刷
   * @param excelBytes
   * @param pdfPath
   * @param printerCd
   * @throws Exception
   */
  void engineryReportPdfPrint(byte[] excelBytes, String pdfPath, Long printerCd) throws Exception;

  /**
   * バイトをhtmlに変換
   *
   * @param excelBytes
   * @return
   */
  String convertBtyesToHtml(byte[] excelBytes) throws Exception;
  //add #9058【IES起票】状況マップ画面にて単患者帳票機能帳票印刷後線とプレビューが不一致 liuc end


  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ Asposeを使用する前提の処理です
   * ※ 帳票種別：03：複数患者帳票 用の処理です
   *
   * @param reportMenu
   * @param userName
   * @return
   */
  public byte[] getReportExcelFilesForMultiplePatient(ReportMenuSortContainer reportMenu, String userName) throws Exception;

  /**
   * 帳票出力結果のPDFファイルを取得.
   * ※ Asposeを使用する前提の処理です
   * ※ 帳票種別：03：複数患者帳票 用の処理です
   *
   * @param patPdfFiles
   * @param reportName
   * @param printerCd
   * @return
   */
  void printPdfReportForMultiplePatient(List<Map<Long, List<byte[]>>> patPdfFiles, String reportName, Long printerCd)
    throws Exception;

  //add #9616 帳票印刷失敗通知がされない 李 start
  /**
   * 帳票出力結果のPDFファイルを取得.
   * ※ Asposeを使用する前提の処理です
   * ※ 帳票種別：03：複数患者帳票 用の処理です
   *
   * @param patPdfFiles
   * @param reportName
   * @param printerCd
   * @param reportType
   * @return
   */
  void printPdfReportForMultiplePatient(List<Map<Long, List<byte[]>>> patPdfFiles, String reportName, Long printerCd, String reportType)
    throws Exception;
  //add #9616 帳票印刷失敗通知がされない 李 end

  String[] getStartAndEndDayByDate(String yyyyMMdd) throws ParseException;

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ Asposeを使用する前提の処理です
   * ※ 帳票種別：04：準備リスト 用の処理です
   *
   * @param reportMenu
   * @param userName
   * @return
   */
  byte[] getExcelReportForPreparationList(ReportMenuSortContainer reportMenu, String userName)
      throws Exception;

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ Asposeを使用する前提の処理です
   * ※ 帳票種別：05：配布リスト（ベッド） 用の処理です
   *
   * @param reportMenu
   * @param userName
   * @return
   */
  byte[] getExcelReportForDistributionListBed(ReportMenuSortContainer reportMenu, String userName) throws Exception;


  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ Asposeを使用する前提の処理です
   * ※ 帳票種別：06：配布リスト（物品） 用の処理です
   *
   * @param reportMenu
   * @param userName
   * @return
   */
  byte[] getExcelReportForDistributionListGoods(ReportMenuSortContainer reportMenu, String userName) throws Exception;

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ Asposeを使用する前提の処理です
   * ※ 帳票種別：08：ラベル 用の処理です
   *
   * @param reportMenu
   * @param userName
   * @return
   */
  byte[] getExcelReportForLabelReport(ReportMenuSortContainer reportMenu, String userName) throws Exception;

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ Asposeを使用する前提の処理です
   * ※ 帳票種別：09：紹介状 用の処理です
   *
   * @param reportMenu
   * @param userName
   * @return
   */
  // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
//  byte[] getExcelReportForIntroductionReport(ReportMenuSortContainer reportMenu, String userName) throws Exception;
  List<Map<Long, List<byte[]>>> getExcelReportForIntroductionReport(ReportMenuSortContainer reportMenu, String userName) throws Exception;
  // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ Asposeを使用する前提の処理です
   * ※ 帳票種別：09：紹介状 用の処理です
   *
   * @param reportMenu
   * @param userName
   * @return
   */
  List<Map<Long, List<byte[]>>> getExcelReportForIntroductionReport2(ReportMenuSortContainer reportMenu,
      String userName) throws Exception;

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ Asposeを使用する前提の処理です
   * ※ 帳票種別：01：治療経過表 用の処理です
   *
   * @param reportMenu
   * @param userName
   * @return
   */
  List<Map<Long, List<byte[]>>> getExcelReportForDialysisReport(ReportMenuSortContainer reportMenu, String userName)
      throws Exception;

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ Asposeを使用する前提の処理です
   * ※ 帳票種別：07：装置帳票 用の処理です
   *
   * @param reportMenu
   * @param userName
   * @return
   */
  List<Map<Long, List<byte[]>>> getExcelReportForMachineReport(ReportMenuSortContainer reportMenu, String userName)
      throws Exception;

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ Asposeを使用する前提の処理です
   * ※ 帳票種別：10：単集計 用の処理です
   *
   * @param reportMenu
   * @param userName
   * @return
   */
// mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 start
//  List<Map<Long, byte[]>>  getExcelReportForOneTotal(ReportMenuSortContainer reportMenu, String userName) throws Exception;
  List<Map<Long, List<byte[]>>>  getExcelReportForOneTotal(ReportMenuSortContainer reportMenu, String userName) throws Exception;
// mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 end


  // add 10546 複数集計出力時にサーバが高負荷になる gjn start
  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ Asposeを使用する前提の処理です
   * ※ 帳票種別：11：複数集計 用の処理です
   *
   * @param reportMenu
   * @param userName
   * @return
   */
  byte[] getExcelReportForMultiTotalHighPerformanceVersion(ReportMenuSortContainer reportMenu, String userName) throws Exception;
  // add 10546 複数集計出力時にサーバが高負荷になる gjn end
  // add #12324 紹介状の出力時にpat_eventを参照する zhao start
  List<PatEvent> getPatEvent(Long reportCd, Map<String, Object> dataKey);
  Map<String, List<Object>> getCtlNoGroup(List<PatEvent> patEventList);
  // add #12324 紹介状の出力時にpat_eventを参照する zhao end
}
