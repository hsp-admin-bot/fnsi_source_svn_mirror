package jp.co.nikkiso.ntss.admin_web.response.details.graph;

import java.util.Collections;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.details.graph.dab.DabGraph1;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.dab.DabGraph2;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.dab.DabGraph3;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.dab.DabGraph4;
import jp.co.nikkiso.ntss.core.entity.custom.TestResultDetail;
import lombok.AllArgsConstructor;

/**
 * DAB自己診断グラフのResponse.
 */
@AllArgsConstructor
public class DabGraphResponse {
  
  /**
   * 基準日.
   */
  public String baseDate;
  
  /**
   * DAB自己診断グラフ1のデータのリスト.
   */
  public List<DabGraph1> graph1s;
  
  /**
   * DAB自己診断グラフ2のデータリスト.
   */
  public List<DabGraph2> graph2s;
  
  /**
   * DAB自己診断グラフ3のデータリスト.
   */
  public List<DabGraph3> graph3s;
  
  /**
   * DAB自己診断グラフ4のデータリスト.
   */
  public List<DabGraph4> graph4s;
  
  /**
   * 空の基準日とリストを返すコンストラクタ.
   * 取得結果0件時に使用する
   */
  public DabGraphResponse() {
    this.baseDate = "";
    this.graph1s = Collections.emptyList();
    this.graph2s = Collections.emptyList();
    this.graph3s = Collections.emptyList();
    this.graph4s = Collections.emptyList();
  }

//  add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
  /**
   * 自己診断情報.
   */
  public List<TestResultDetail> selftList;
//  add 7801【デグレ】自己診断結果の集計が不正_再発 関 end
}
