/**
 * プリンターマスタを表現するクラス.
 */

 export class MstPrinter {
  constructor(mstPrinter) {
    // プリンターコード
    this.printerCd = mstPrinter.printerCd;
    // プリンター名
    this.printerName = mstPrinter.printerName;
    // 表示プリンター名
    this.dispPrinterName = mstPrinter.dispPrinterName;

    // 表示プリンター名が未設定の場合、プリンター名を表示する
    if (!this.dispPrinterName) {
      this.dispPrinterName = this.printerName;
    }
  }
}
