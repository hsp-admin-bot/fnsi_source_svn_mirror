package jp.co.nikkiso.ntss.admin_web.request.prescription;

import lombok.Data;

import java.util.List;
/**
 * 処方一覧のRequestクラス.
 */
@Data
public class PrescriptionListRequest {
  /**
   * 患者IDリスト
   */
  private List<Long> patIdList;
  /**
   * 交付日
   */
  private String issueDate;

  /**
   * 処方オーダー番号
   */
  private List<Long> ordPrescriptionNoList;

  /**
   * 保険医ID
   */
  private String insuDrId;

  /**
   * 保険医指定
   */
  private String selectedPreDoctor;

  /**
   * 交付ステータス
   */
  private String issueState;

  /**
   * 処方方法リスト
   */
  private List<String> prescriptionTypeList;

  /**
   * 施設コード
   */
  private String facilityCd;

  //add #12462 患者共有情報 by zrx start
  /**
   * 自施設(1) or 他施設(0)
   */
  private Integer patientShareMode;
  //add #12462 患者共有情報 by zrx end

}
