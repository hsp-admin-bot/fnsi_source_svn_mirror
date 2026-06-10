package jp.co.nikkiso.ntss.admin_web.response.details.graph.dissolution;

import lombok.AllArgsConstructor;

/**
 * 溶解記録のグラフ4のデータ1件を表すクラス.
 */
@AllArgsConstructor
public class DissolutionGraph4 {

  /**
   * イベント発生日付(yyyy/MM/dd).
   */
  public String evenetRegDate;

  /**
   * イベント発生時刻(HH24:MI:SS).
   */
  public String evenetRegTime;

  /**
   * 濃度.
   */
  public String concentration;

  /**
   * 液温度.
   */
  public String temperature;

}
