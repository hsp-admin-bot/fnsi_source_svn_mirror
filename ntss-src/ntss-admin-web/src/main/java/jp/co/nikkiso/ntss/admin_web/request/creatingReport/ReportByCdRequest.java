package jp.co.nikkiso.ntss.admin_web.request.creatingReport;

import lombok.Data;

import java.util.Map;

/**
 * レポートコードを使用した帳票APIのRequestクラス.
 */
@Data
public class ReportByCdRequest {

  /**
   * プレビューフラグ
   */
  private Boolean isPreview;

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
