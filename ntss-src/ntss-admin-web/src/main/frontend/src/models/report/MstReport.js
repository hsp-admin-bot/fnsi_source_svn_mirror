/**
 * 帳票マスタを表現するクラス.
 */

export class MstReport {
  constructor(mstReport) {
    // レポートコード
    this.reportCd = mstReport.reportCd;
    // 帳票名
    this.reportName = mstReport.reportName;
    // 3ファイルのフルパス
    this.reportPath = mstReport.reportPath;
    // 帳票種別
    this.reportClass = mstReport.reportClass;
    // 帳票区分
    this.reportType = mstReport.reportType;
    // 抽出条件
    // mod 2021-03-09 No.751:装置帳票の場合、「mst_report」の項目「extraction_condition」を更新する必要となる。 孫 start
    // this.extractionCondition = JSON.parse(mstReport.extractionCondition);
    this.extractionCondition = JSON.parse(JSON.stringify(mstReport.extractionCondition));
    // mod 2021-03-09 No.751:装置帳票の場合、「mst_report」の項目「extraction_condition」を更新する必要となる。 孫 end
    // プリンター初期値
    this.defaultPrinter = mstReport.defaultPrinter;
  }
}
