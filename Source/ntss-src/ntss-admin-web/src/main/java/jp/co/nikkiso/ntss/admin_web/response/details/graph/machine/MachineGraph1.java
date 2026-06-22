package jp.co.nikkiso.ntss.admin_web.response.details.graph.machine;

import lombok.AllArgsConstructor;

/**
 * 透析装置自己診断のグラフ1のデータ1件を表すクラス.
 */
@AllArgsConstructor
public class MachineGraph1 {

  /**
   * イベント発生日付(yyyy/MM/dd).
   */
  public String evenetRegDate;

  /**
   * イベント発生時刻(HH24:MI:SS).
   */
  public String evenetRegTime;

  /**
   * 配管漏れ(陰圧).
   */
  public String negativePipeLeakage;

  /**
   * 配管漏れ(陽圧).
   */
  public String positivePipeLeakage;

  /**
   * CF漏れ.
   */
  public String cfLeakage;

  /**
   * CF2漏れ.
   */
  public String cf2Leakage;

}
