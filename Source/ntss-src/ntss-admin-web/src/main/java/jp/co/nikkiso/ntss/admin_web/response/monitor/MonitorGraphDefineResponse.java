package jp.co.nikkiso.ntss.admin_web.response.monitor;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;

/**
 * モニタグラフ設定のResponse.
 */
@AllArgsConstructor
public class MonitorGraphDefineResponse {

  /**
   * モニタグラフコード.
   */
  private Integer monitorGraphCd;

  /**
   * モニタグラフ名.
   */
  private String monitorGraphName;

  /**
   * 左項目コード.
   */
  private String leftDataIndex;

  /**
   * 左グラフ色.
   */
  private String leftColor;

  //add FNSI-改修内容 グラフ様式修正 房 start
  /**
   * 左線サイズ.
   */
  private String leftLineSize;

  /**
   * 左線タイプ値.
   */
  private String leftLineTypeValue;

  /**
   * 左ポイント色.
   */
  private String leftPointColor;

  /**
   * 左ポイントサイズ.
   */
  private String leftPointSize;

  /**
   * 左ポイントタイプ値.
   */
  private String leftPointTypeValue;
  //add FNSI-改修内容 グラフ様式修正 房 end

  /**
   * 右項目コード.
   */
  private String rightDataIndex;

  /**
   * 右グラフ色.
   */
  private String rightColor;

  //add FNSI-改修内容 グラフ様式修正 房 start
  /**
   * 右線サイズ.
   */
  private String rightLineSize;

  /**
   * 右線タイプ値.
   */
  private String rightLineTypeValue;

  /**
   * 右ポイント色.
   */
  private String rightPointColor;

  /**
   * 右ポイントサイズ.
   */
  private String rightPointSize;

  /**
   * 右ポイントタイプ値.
   */
  private String rightPointTypeValue;
  //add FNSI-改修内容 グラフ様式修正 房 end
  //add FNSI-9858-改修内容 グラフ様式追加最大値と最小値 杜天成 start
  /**
   * 左グラフ上限.
   */
  private String leftGraphUpperLimit;
  /**
   * 右グラフ上限.
   */
  private String rightGraphUpperLimit;
  /**
   * 左グラフ下限.
   */
  private String leftGraphLowerLimit;
  /**
   * 右グラフ下限.
   */
  private String rightGraphLowerLimit;
  //add FNSI-9858-改修内容 グラフ様式追加最大値と最小値 杜天成 end

  @JsonProperty("monitor_graph_cd")
  public Integer getMonitorGraphCd() {
    return monitorGraphCd;
  }

  @JsonProperty("monitor_graph_name")
  public String getMonitorGraphName() {
    return monitorGraphName;
  }

  @JsonProperty("left_data_index")
  public String getLeftDataIndex() {
    return leftDataIndex;
  }

  @JsonProperty("left_color")
  public String getLeftColor() {
    return leftColor;
  }

  @JsonProperty("right_data_index")
  public String getRightDataIndex() {
    return rightDataIndex;
  }

  @JsonProperty("right_color")
  public String getRightColor() {
    return rightColor;
  }

  //add FNSI-改修内容 グラフ様式修正 房 start
  @JsonProperty("left_line_size")
  public String getLeftLineSize() {
    return leftLineSize;
  }

  @JsonProperty("left_line_type_value")
  public String getLeftLineTypeValue() {
    return leftLineTypeValue;
  }

  @JsonProperty("left_point_color")
  public String getLeftPointColor() {
    return leftPointColor;
  }

  @JsonProperty("left_point_size")
  public String getLeftPointSize() {
    return leftPointSize;
  }

  @JsonProperty("left_point_type_value")
  public String getLeftPointTypeValue() {
    return leftPointTypeValue;
  }

  @JsonProperty("right_line_size")
  public String getRightLineSize() {
    return rightLineSize;
  }

  @JsonProperty("right_line_type_value")
  public String getRightLineTypeValue() {
    return rightLineTypeValue;
  }

  @JsonProperty("right_point_color")
  public String getRightPointColor() {
    return rightPointColor;
  }

  @JsonProperty("right_point_size")
  public String getRightPointSize() {
    return rightPointSize;
  }

  @JsonProperty("right_point_type_value")
  public String getRightPointTypeValue() {
    return rightPointTypeValue;
  }
  //add FNSI-改修内容 グラフ様式修正 房 end
  //add FNSI-9858-改修内容 グラフ様式追加最大値と最小値 杜天成 start
  @JsonProperty("left_graph_upper_limit")
  public String getLeftGraphUpperLimit() { return leftGraphUpperLimit; }
  @JsonProperty("right_graph_upper_limit")
  public String getRightGraphUpperLimit() {
    return rightGraphUpperLimit;
  }
  @JsonProperty("left_graph_lower_limit")
  public String getLeftGraphLowerLimit() {
    return leftGraphLowerLimit;
  }
  @JsonProperty("right_graph_lower_limit")
  public String getRightGraphLowerLimit() {
    return rightGraphLowerLimit;
  }
  //add FNSI-9858-改修内容 グラフ様式追加最大値と最小値 杜天成 end
  //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
  /**
   * 左項目name.
   */
  private String leftName;
  /**
   * 右項目name.
   */
  private String rightName;
  @JsonProperty("left_name")
  public String getLeftName() {
    return leftName;
  }
  @JsonProperty("right_name")
  public String getRightName() {
    return rightName;
  }
  //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end

}
