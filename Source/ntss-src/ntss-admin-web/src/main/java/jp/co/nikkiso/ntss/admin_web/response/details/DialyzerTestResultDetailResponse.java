package jp.co.nikkiso.ntss.admin_web.response.details;

import lombok.AllArgsConstructor;

/**
 * 装置動作記録詳細_自己診断結果(透析装置)のResponse.
 */
@AllArgsConstructor
public class DialyzerTestResultDetailResponse {

  /**
   * 基準日.
   */
  public String baseDateForTestResult;

  /**
   * 自己診断結果(透析装置).
   */
  public DialyzerTestResults dialyzerTestResults;
  
  /**
   * スキップ行数.
   */
  public Integer offset;

}
