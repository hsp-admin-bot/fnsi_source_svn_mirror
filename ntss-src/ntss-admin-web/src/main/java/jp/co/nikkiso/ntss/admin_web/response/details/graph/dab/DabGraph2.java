package jp.co.nikkiso.ntss.admin_web.response.details.graph.dab;

import lombok.AllArgsConstructor;

/**
 * DAB自己診断のグラフ2のデータ1件を表すクラス.
 */
@AllArgsConstructor
public class DabGraph2 {

  /**
   * イベント発生日付(yyyy/MM/dd).
   */
  public String evenetRegDate;

  /**
   * イベント発生時刻(HH24:MI:SS).
   */
  public String evenetRegTime;

  /**
   * 濃度 セル3.
   */
  public String concentrationCell3;

  /**
   * 濃度 セル4.
   */
  public String concentrationCell4;

}
