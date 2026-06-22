package jp.co.nikkiso.ntss.admin_web.response.details;

import lombok.AllArgsConstructor;

/**
 * 装置動作記録詳細_自己診断結果(DAB)のRespnse
 */
@AllArgsConstructor
public class DabTestResultDetailResponse {

  /**
   * 基準日.
   */
  public String baseDateForTestResult;

  /**
   * 自己診断結果(DAB).
   */
  public DabTestResults dabTestResults;
  
  /**
   * スキップ行数.
   */
  public Integer offset;

}
