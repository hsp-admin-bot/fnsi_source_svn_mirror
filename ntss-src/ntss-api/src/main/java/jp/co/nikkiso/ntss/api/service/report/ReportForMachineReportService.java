package jp.co.nikkiso.ntss.api.service.report;
// add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe start
import java.util.Map;

public interface ReportForMachineReportService {

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：7：装置帳票 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  byte[] getReportExcelFileForMachineReport(Long reportCd, Map<String, Object> dataKey);

}
// add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe end
