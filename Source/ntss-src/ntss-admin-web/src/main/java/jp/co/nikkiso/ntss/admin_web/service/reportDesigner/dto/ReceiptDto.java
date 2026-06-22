package jp.co.nikkiso.ntss.admin_web.service.reportDesigner.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReceiptDto {

  /**
   * データ種別コード
   */
  private Integer classCd;

  /**
   * データ種別名称.
   */
  private String className;

  /**
   * データ分類コード
   */
  private Integer kindCd;

  /**
   * データ分類名称
   */
  private String kindName;

  /**
   * 項目コード
   */
  private Integer receiptCd;

  /**
   * 項目名
   */
  private String receiptName;

}
