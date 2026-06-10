package jp.co.nikkiso.ntss.admin_web.request.creatingReport;

import lombok.Data;

import java.util.Map;

/**
 * 帳票APIのRequestクラス.
 */
@Data
public class ReportRequest {

  /**
   * 帳票種別.
   */
  private Integer reportClass;

  /**
   * 帳票区分.
   */
  private Integer reportType;

  /**
   * データ抽出キー.
   */
  private Map<String, Object> dataKey;

  /**
   * 印刷先プリンタ.
   */
  private Long targetPrinter;

  /**
   * PDF格納先パス(Amazon S3).
   */
  private String pdfPath;

  /**
   * Excelファイル格納先パス(Amazon S3).
   */
  private String excelPath;

}
