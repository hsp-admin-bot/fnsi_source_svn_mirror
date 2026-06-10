package jp.co.nikkiso.ntss.admin_web.response.creatingReport;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.Map;

/**
 * 帳票HTML取得のResponse.
 */
@AllArgsConstructor
@Getter
public class ReportHtmlResponse {

  /**
   * 帳票HTML情報.
   */
  private String reportHtml;

  /**
   * データ抽出キー.
   */
  private Map<String, Object> dataKey;
}
