package jp.co.nikkiso.ntss.api.service.report;
// add #11973 日常点検一覧帳票が正常に出せない limingzhe start
import java.util.Map;

public interface ReportForTotalService {

  // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：09：紹介状 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  byte[] getReportExcelFileForIntroductionReport(Long reportCd, Map<String, Object> dataKey);
  // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end

  // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：10:単集計 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  byte[] getReportExcelFileForOneTotal(Long reportCd, Map<String, Object> dataKey);
  // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end

  /**
   * 帳票出力結果のExcelファイルを取得.
   * ※ 常にAsposeを使用します
   * ※ 帳票種別：11：複数集計 用の処理です
   *
   * @param reportCd レポートコード
   * @param dataKey データ抽出キー
   * @return Excelファイル
   */
  byte[] getReportExcelFileForMultiTotal(Long reportCd, Map<String, Object> dataKey);

}

// add #11973 日常点検一覧帳票が正常に出せない limingzhe end
