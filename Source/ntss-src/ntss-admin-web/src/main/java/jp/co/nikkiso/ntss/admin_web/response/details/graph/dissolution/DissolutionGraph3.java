package jp.co.nikkiso.ntss.admin_web.response.details.graph.dissolution;

import lombok.AllArgsConstructor;

/**
 * 溶解記録のグラフ3のデータ1件を表すクラス.
 */
@AllArgsConstructor
public class DissolutionGraph3 {
  
  /**
   * イベント発生日付(yyyy/MM/dd).
   */
  public String evenetRegDate;

  /**
   * イベント発生時刻(HH24:MI:SS).
   */
  public String evenetRegTime;

  /**
   * B原液溶解時間.
   */
  public String dissolutionTimeB;

  /**
   * A原液溶解時間.
   */
  public String dissolutionTimeA;

}
