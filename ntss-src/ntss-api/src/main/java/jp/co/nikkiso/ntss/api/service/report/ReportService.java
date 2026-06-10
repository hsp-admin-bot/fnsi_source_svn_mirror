package jp.co.nikkiso.ntss.api.service.report;

import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.OrdMain;

import java.net.URL;
import java.util.List;
import java.util.Map;

/**
 * 帳票作成のServiceインタフェース.
 */
public interface ReportService {
  /**
   * 帳票情報(HTML)の取得.
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @param targetPrinter 印刷先プリンタ
   * @param userId 帳票を出力したユーザID
   * @return 帳票HTML
   */
  String getReportHtml(Long reportCd, Map<String, Object> dataKey, Long targetPrinter, Long userId);


  /**
   * 帳票マスタを読み込む.
   * @param reportCd レポートコード
   * @return mst_reportエンティティ
   */
  MstReport getMstReport(Long reportCd);

  /**
   * 帳票マスタを読み込む.
   * @param reportCd レポートコード
   * @return mst_reportエンティティ
   */
  MstReport getMstReportForIntroLetter(Long reportCd);

  /**
   * 帳票マスタを読み込む.
   * @param funcCd 機能コード
   * @param facilityCd 施設コード
   * @return mst_reportエンティティのリスト
   */
  // mod FNSI-#522、IES364 選択された機能により、対象の帳票を表示する。 夏 start
  //List<MstReport> getMstReport(String funcCd, String facilityCd);
  List<MstReport> getMstReport(String funcCd, String facilityCd, String printFlag);
  // mod FNSI-#522、IES364 選択された機能により、対象の帳票を表示する。 夏 end
  // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
//  //add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 start
//  List<MstReport> getMstReportFixed(String funcCd, String facilityCd);
//  //add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 end
  List<MstReport> getMstReportFixed(String funcCd, String facilityCd, String printFlag);
  // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

  // add #12419 各画面の機能帳票リストが機能帳票マスタの表示順になっていない limingzhe start
  /**
   * 機能帳票マスタを読み込む.
   * @param facilityCd 施設コード
   * @param funcCd 機能コード
   * @return mst_reportエンティティのリスト
   */
  List<MstReport> getAllMstFunctionReportForFixedAndNormal(String facilityCd, String funcCd, String printFlag);
  // add #12419 各画面の機能帳票リストが機能帳票マスタの表示順になっていない limingzhe end

  /**
   * 帳票種別、帳票区分、施設コードをもとに、帳票マスタを取得します.
   * @param reportClass 帳票種別
   * @param reportType 帳票区分
   * @param facilityCd 施設コード
   * @return 帳票マスタエンティティ
   */
  MstReport getMstReport(Integer reportClass, Integer reportType, String facilityCd);

  /**
   * 施設CDで全ての帳票の習得
   * @param facilityCd
   * @return List<MstReport>
   */
   List<MstReport> getMstReportByFacilityCd(String facilityCd);

   // add #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
  /**
   * is_dispの表示/非表示と関係なく、施設CDにより帳票を取得
   * @param facilityCd
   * @return List<MstReport>
   */
  List<MstReport> getMstReportByFacilityCdNoIsDisp(String facilityCd);
  // add #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end

  /**
   * HTMLをPDFに変換する.
   *
   * @param html HTMLデータ
   * @param s3Path 格納先のS3パス
   * @return 処理結果(true:成功 false:失敗)
   */
  boolean convertHtmlToPdf(String html, String s3Path);

  // add 8188 【デグレ】自動印刷で文字化けが発生する 夏 start
  /**
   * byte[]をPDFに変換する.
   *
   * @param excelBytes byte[]データ
   * @param s3Path 格納先のS3パス
   * @return 処理結果(true:成功 false:失敗)
   */
  boolean convertBytesToPdf(byte[] excelBytes, String s3Path);
  // add 8188 【デグレ】自動印刷で文字化けが発生する 夏 end

  /**
   * HTMLをPDFに変換し、一時フォルダに保存する.
   *
   * @param html HTMLデータ
   * @param OutputPath 出力一時フォルダパス
   * @param fileName 出力ファイル名
   * @return 処理結果(true:成功 false:失敗)
   */
  boolean convertHtmlToPdfOutputTmp(String html, String OutputPath, String fileName);

  /**
   * 帳票Excelファイルを生成する.
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @param s3Path 格納先のS3パス
   * @return 処理結果(true:成功 false:失敗)
   */
  boolean getReportExcel(Long reportCd, Map<String, Object> dataKey, String s3Path);

  /**
   * 帳票をイメージを生成する.
   *
   * @param reportCd 帳票コード
   * @param dataKey データ抽出キー
   * @param extension 生成する画像の拡張子
   * @return 生成した画像をBase64化した文字列
   */
  String getReportImage(Long reportCd, Map<String, Object> dataKey, String extension, URL url);

  /**
   * スケジュール表 帳票情報(HTML)の取得.
   *
   * @param dataKey データ抽出キー
   * @param targetPrinter 印刷先プリンタ
   * @param userId 帳票を出力したユーザID
   * @return 帳票HTML
   */
  String getReportHtmlSchedule(Map<String, Object> dataKey, Long targetPrinter, Long userId);

  /**
   * 水質調査一覧 帳票情報(HTML)の取得.
   *
   * @param dataKey データ抽出キー
   * @param targetPrinter 印刷先プリンタ
   * @param userId 帳票を出力したユーザID
   * @return 帳票HTML
   */
  String getReportHtmlWaterSurvey(Map<String, Object> dataKey, Long targetPrinter, Long userId);

  /*add FNSI-改修内容5984 任 start*/
  List<OrdMain> getOrdNoList(List<Long> patIdList, String treatDate);
  /*add FNSI-改修内容5984 任 end*/

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：01：治療経過表 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  byte[] getReportExcelFileForDialysisReport(Long reportCd, Map<String, Object> dataKey);

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：02：単患者帳票 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @param searchInfo 検索条件データ
   * @return Excelファイル
   */
  // del #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
  //byte[] getReportExcelFileForOnePatient(Long reportCd, Map<String, Object> dataKey, Map<String, Object> searchInfo);
  // del #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：03：複数患者帳票 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  byte[] getReportExcelFileForMultiPatient(Long reportCd, Map<String, Object> dataKey);

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：04：準備リスト 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  byte[] getReportExcelFileForPreparationList(Long reportCd, Map<String, Object> dataKey);

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：05：配布リスト（ベッド） 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  // del #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
  //byte[] getReportExcelFileForDistributionListBed(Long reportCd, Map<String, Object> dataKey);
  // del #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：06：配布リスト（物品） 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  // del #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
  //byte[] getReportExcelFileForDistributionListGoods(Long reportCd, Map<String, Object> dataKey);
  // del #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：07：装置帳票 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  // del #11117 日常点検記録簿が1ページ1装置で出力される limingzhe start
  //byte[] getReportExcelFileForMachineReport(Long reportCd, Map<String, Object> dataKey);
  // del #11117 日常点検記録簿が1ページ1装置で出力される limingzhe end

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：08：ラベル 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  // del #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
  //byte[] getReportExcelFileForLabelReport(Long reportCd, Map<String, Object> dataKey);
  // del #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end

  /**
   * ラベル帳票出力データ並び替えを取得
   * @param item ソートキー
   * @return ソートキーの文字、順序
   */
  String[] MakeSortList(Map<String, String> item);
  // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
  /**
   * is_delの論理削除/論理削除なしと関係なく、施設CDにより帳票を取得
   * @param facilityCd
   * @return List<MstReport>
   */
  List<MstReport> getMstReportByFacilityCdNoIsDel(String facilityCd);
  // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
}
