package jp.co.nikkiso.ntss.api.model;

import lombok.Data;

@Data
public class HighChartsJsonModel {

  /**
   *　JSONデータ
   */
  private String jsonStr;

  /**
   *　時間オフセット
   */
  private String offsetValue;

  /**
   *　幅
   */
  private Integer width;

  /**
   *　高さ
   */
  private Integer height;

  /**
   * オーダー
   */
  private Long ordNo;
}
