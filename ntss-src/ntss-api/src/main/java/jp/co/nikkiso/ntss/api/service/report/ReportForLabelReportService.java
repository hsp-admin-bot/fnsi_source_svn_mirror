package jp.co.nikkiso.ntss.api.service.report;
import java.util.Map;

public interface ReportForLabelReportService {

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：08：ラベル 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  byte[] getReportExcelFileForLabelReport(Long reportCd, Map<String, Object> dataKey);
}
