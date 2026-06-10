package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 処方一覧
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PrescriptionList {

  /**
   * 処方オーダー番号
   */
  private Long ordPrescriptionNo;
  
  /**
   * 処方オーダー番号
   */
  private Long ordPrescriptionNo2;
  
  /**
   * 患者ID
   */
  private Long patId;

  /**
   * 処方種別
   */
  private String prescriptionType;

  /**
   * 処方種別
   */
  private String prescriptionType2;

  /**
   * 交付日
   */
  private String issueDate;

  /**
   * 交付状態
   */
  private String issueState;

  /**
   * 交付状態
   */
  private String issueState2;

  /**
   * 指示：クール名
   */
  private String indKurName;

  /**
   * ベッド名
   */
  private String indBedName;

  /**
   * 指示：治療方法名
   */
  private String indTreatmentName;
  /**
   * クール開始時刻
   */
  private String kurStartTime;

  /**
   * 治療方法マスタ表示順
   */
  private Long treatmentOrderIndex;
  
  /**
   * ベッドマスタ表示順
   */
  private Long bedOrderIndex;

  //add #12462 患者共有情報 by zrx start
  /**
   * 施設コード
   */
  private String facilityCd;
  //add #12462 患者共有情報 by zrx end
}
