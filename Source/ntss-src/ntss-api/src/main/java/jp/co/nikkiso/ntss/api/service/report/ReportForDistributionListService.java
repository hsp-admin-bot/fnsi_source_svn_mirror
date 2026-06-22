package jp.co.nikkiso.ntss.api.service.report;
import java.util.Map;

public interface ReportForDistributionListService {

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：05：配布リスト（ベッド） 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  byte[] getReportExcelFileForDistributionListBed(Long reportCd, Map<String, Object> dataKey);

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：06：配布リスト（物品） 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  byte[] getReportExcelFileForDistributionListGoods(Long reportCd, Map<String, Object> dataKey);
}
