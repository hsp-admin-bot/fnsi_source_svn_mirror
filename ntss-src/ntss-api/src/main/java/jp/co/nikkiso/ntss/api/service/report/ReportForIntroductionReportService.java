package jp.co.nikkiso.ntss.api.service.report;
// mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
import java.util.Map;

public interface ReportForIntroductionReportService {

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

  // add #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
  byte[] getReportExcelFileForIntroductionReportbyHTMLPrint(Long reportCd, Map<String, Object> dataKey);
  // add #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
}
// mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end
