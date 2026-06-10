package jp.co.nikkiso.ntss.admin_web.response.weight;

import lombok.NoArgsConstructor;

/**
 * 検査マスタ取得時のResponse.
 */
@NoArgsConstructor
public class MstWeightExamResponse {

  /**
   * 検査マスタ主キー.
   */
  public Long cd;
  /**
   * 検査マスタ名称
   */
  public String name;
  /**
   * 検査マスタ単位
   */
  public String unit;
}
