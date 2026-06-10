package jp.co.nikkiso.ntss.admin_web.response.details.graph.dab;

import lombok.AllArgsConstructor;

/**
 * DAB自己診断のグラフ3のデータ1件を表すクラス.
 */
@AllArgsConstructor
public class DabGraph3 {

  /**
   * イベント発生日付(yyyy/MM/dd).
   */
  public String evenetRegDate;

  /**
   * イベント発生時刻(HH24:MI:SS).
   */
  public String evenetRegTime;

  /**
   * 注水判定時間.
   */
  public String judgementTermInjection;

  /**
   * 排液判定時間.
   */
  public String judgementTermDrainage;

}
