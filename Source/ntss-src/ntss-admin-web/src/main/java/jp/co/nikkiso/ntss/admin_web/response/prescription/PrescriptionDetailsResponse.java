package jp.co.nikkiso.ntss.admin_web.response.prescription;

import jp.co.nikkiso.ntss.core.entity.OrdPersonalPrescription;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import lombok.AllArgsConstructor;
import lombok.Data;
/**
 * 処方詳細APIの応答クラス.
 */
@AllArgsConstructor
@Data
public class PrescriptionDetailsResponse {

  /**
   * 処方箋情報オブジェクト
   */
  private OrdPrescription ordPrescription;

  /**
   * 個人処方箋オブジェクトの注文
   */
  private OrdPersonalPrescription ordPersonalPrescription;
}
