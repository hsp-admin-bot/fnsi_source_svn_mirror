package jp.co.nikkiso.ntss.admin_web.response.details.graph;

import java.util.Collections;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.details.graph.dissolution.DissolutionGraph1;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.dissolution.DissolutionGraph2;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.dissolution.DissolutionGraph3;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.dissolution.DissolutionGraph4;
import lombok.AllArgsConstructor;

/**
 * 溶解記録グラフのResponse.
 */
@AllArgsConstructor
public class DissolutionGraphResponse {

  /**
   * 基準日.
   */
  public String baseDate;

  /**
   * 溶解記録グラフ1のデータのリスト.
   */
  public List<DissolutionGraph1> graph1s;

  /**
   * 溶解記録グラフ2のデータリスト.
   */
  public List<DissolutionGraph2> graph2s;

  /**
   * 溶解記録グラフ3のデータリスト.
   */
  public List<DissolutionGraph3> graph3s;

  /**
   * 溶解記録グラフ4のデータリスト.
   */
  public List<DissolutionGraph4> graph4s;

  /**
   * 空の基準日とリストを返すコンストラクタ.
   * 取得結果0件時に使用する
   */
  public DissolutionGraphResponse() {
    this.baseDate = "";
    this.graph1s = Collections.emptyList();
    this.graph2s = Collections.emptyList();
    this.graph3s = Collections.emptyList();
    this.graph4s = Collections.emptyList();
  }

}
