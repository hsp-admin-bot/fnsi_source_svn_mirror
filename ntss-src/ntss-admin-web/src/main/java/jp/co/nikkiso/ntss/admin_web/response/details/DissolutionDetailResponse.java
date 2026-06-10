package jp.co.nikkiso.ntss.admin_web.response.details;

import java.util.Collections;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.details.model.DissolutionModel;
import lombok.AllArgsConstructor;

/**
 * 装置動作記録詳細_溶解記録のResponse.
 */
@AllArgsConstructor
public class DissolutionDetailResponse {

  /**
   * 基準日.
   */
  public String baseDateForDissolution;

  /**
   * 過去三3日分の溶解記録のリスト.
   */
  public List<DissolutionModel> dissolutions;

  /**
   * 空のレスポンスを返却するコンストラクタ.
   */
  public DissolutionDetailResponse() {
    this.baseDateForDissolution = "";
    this.dissolutions = Collections.emptyList();
  }
  
  /**
   * スキップ行数.
   */
  public Integer offset;

}
