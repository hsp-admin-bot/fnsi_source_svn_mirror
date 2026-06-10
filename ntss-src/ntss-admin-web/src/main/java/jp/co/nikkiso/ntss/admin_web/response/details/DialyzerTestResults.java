package jp.co.nikkiso.ntss.admin_web.response.details;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.details.model.BloodLeakageTestModel;
import jp.co.nikkiso.ntss.admin_web.response.details.model.ConcentrationTestModel;
import jp.co.nikkiso.ntss.admin_web.response.details.model.DialysateFlowRateTestModel;
import jp.co.nikkiso.ntss.admin_web.response.details.model.UfrcTestModel;
import lombok.AllArgsConstructor;

/**
 * 透析装置の自己診断結果記録を表すクラス.
 * <p>それぞれ過去2週間分のデータを保持</p>
 */
@AllArgsConstructor
public class DialyzerTestResults {

  /**
   * 配管(UFRC)自己診断結果記録のリスト.
   */
  public List<UfrcTestModel> ufrc;

  /**
   * 漏血自己診断結果記録のリスト.
   */
  public List<BloodLeakageTestModel> bloodLeakage;

  /**
   * 透析液流量自己診断結果記録のリスト.
   */
  public List<DialysateFlowRateTestModel> dialysateFlowRate;

  /**
   * 濃度自己診断結果記録のリスト.
   */
  public List<ConcentrationTestModel> concentration;

}
