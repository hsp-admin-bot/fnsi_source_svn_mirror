package jp.co.nikkiso.ntss.admin_web.response.creatingReport;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * プリンタ情報.
 */
@AllArgsConstructor
@Getter
public class PrinterInfo {

  /**
   * プリンタコード.
   */
  private Long printerCd;

  /**
   * プリンタ名.
   */
  private String printerName;

  /**
   * 表示プリンタ名.
   */
  private String dispPrinterName;

}
