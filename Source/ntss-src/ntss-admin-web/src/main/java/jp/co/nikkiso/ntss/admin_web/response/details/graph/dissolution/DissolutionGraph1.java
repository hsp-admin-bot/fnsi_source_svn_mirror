package jp.co.nikkiso.ntss.admin_web.response.details.graph.dissolution;

import lombok.AllArgsConstructor;

/**
 * 溶解記録のグラフ1のデータ1件を表すクラス.
 */
@AllArgsConstructor
public class DissolutionGraph1 {

  /**
   * イベント発生日付(yyyy/MM/dd).
   */
  public String evenetRegDate;

  /**
   * イベント発生時刻(HH24:MI:SS).
   */
  public String evenetRegTime;

  /**
   * B原液濃度.
   */
  public String concentrationB;

  /**
   * A原液濃度.
   */
  public String concentrationA;

}
