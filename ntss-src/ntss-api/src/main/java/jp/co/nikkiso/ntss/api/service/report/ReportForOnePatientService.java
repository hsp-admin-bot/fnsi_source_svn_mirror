package jp.co.nikkiso.ntss.api.service.report;
// add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
import java.util.Map;

public interface ReportForOnePatientService {

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：2：単患者帳票 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  byte[] getReportExcelFileForOnePatient(Long reportCd, Map<String, Object> dataKey, Map<String, Object> searchInfo);

}
// add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
