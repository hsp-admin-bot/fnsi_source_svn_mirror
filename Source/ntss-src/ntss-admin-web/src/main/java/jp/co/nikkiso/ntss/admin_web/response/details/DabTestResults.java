package jp.co.nikkiso.ntss.admin_web.response.details;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.details.model.HemodilutionModel;
import jp.co.nikkiso.ntss.admin_web.response.details.model.PipingModel;
import lombok.AllArgsConstructor;

/**
 * 透析装置の自己診断結果記録を表すクラス.
 * <p>それぞれ過去2週間分のデータを保持</p>
 */
@AllArgsConstructor
public class DabTestResults {

  /**
   * 配管テスト結果記録のリスト.
   */
  public List<PipingModel> piping;

  /**
   * 希釈テスト結果記録のリスト.
   */
  public List<HemodilutionModel> hemodilution;

}
