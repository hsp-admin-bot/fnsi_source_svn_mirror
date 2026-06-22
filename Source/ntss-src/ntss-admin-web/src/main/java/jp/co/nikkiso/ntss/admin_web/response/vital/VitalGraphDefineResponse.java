package jp.co.nikkiso.ntss.admin_web.response.vital;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;

/**
 * モニタグラフ設定のResponse.
 */
@AllArgsConstructor
public class VitalGraphDefineResponse {

  /**
   * バイトルグラフコード.
   */
  private Integer vitalGraphCd;

  /**
   * バイタルグラフ名.
   */
  private String vitalGraphName;

  /**
   * 線色.
   */
  private String vitalLineColor;

  /**
   * 線サイズ.
   */
  private String vitalLineSize;

  /**
   * 線タイプ値.
   */
  private String vitalLineTypeValue;

  /**
   * ポイント色.
   */
  private String vitalPointColor;

  /**
   * ポイントサイズ.
   */
  private String vitalPointSize;

  /**
   * ポイントタイプ値.
   */
  private String vitalPointTypeValue;

  @JsonProperty("vital_graph_cd")
  public Integer getVitalGraphCd() {
    return vitalGraphCd;
  }

  @JsonProperty("vital_graph_name")
  public String getVitalGraphName() {
    return vitalGraphName;
  }

  @JsonProperty("vital_line_color")
  public String getVitalLineColor() {
    return vitalLineColor;
  }

  @JsonProperty("vital_line_size")
  public String getVitalLineSize() {
    return vitalLineSize;
  }

  @JsonProperty("vital_line_type_value")
  public String getVitalLineTypeValue() {
    return vitalLineTypeValue;
  }

  @JsonProperty("vital_point_color")
  public String getVitalPointColor() {
    return vitalPointColor;
  }

  @JsonProperty("vital_point_size")
  public String getVitalPointSize() {
    return vitalPointSize;
  }

  @JsonProperty("vital_point_type_value")
  public String getVitalPointTypeValue() {
    return vitalPointTypeValue;
  }
}
