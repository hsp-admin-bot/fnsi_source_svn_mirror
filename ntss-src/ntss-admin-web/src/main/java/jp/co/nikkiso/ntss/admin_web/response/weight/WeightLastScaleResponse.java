package jp.co.nikkiso.ntss.admin_web.response.weight;

import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;
import lombok.AllArgsConstructor;

/**
 * 体重計指示取得のResponse.
 */
@AllArgsConstructor
public class WeightLastScaleResponse {
  /**
   * 前回測定記録
   */
  public OrdWeightScale ordWeightScale;
  /**
   * 空の情報を返却するコンストラクタ.
   * 検索結果0件時のレスポンスに使用
   */
  public WeightLastScaleResponse() {
    this.ordWeightScale = null;
  }

}
