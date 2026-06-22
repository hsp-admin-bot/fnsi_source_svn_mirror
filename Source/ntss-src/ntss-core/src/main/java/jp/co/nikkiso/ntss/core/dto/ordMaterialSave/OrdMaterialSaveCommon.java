package jp.co.nikkiso.ntss.core.dto.ordMaterialSave;

import lombok.Data;
import org.seasar.doma.Entity;

import java.sql.Timestamp;

@Entity
@Data
public class OrdMaterialSaveCommon {

  /**
   * 管理番号
   */
  private Long ordMaterialSaveNo;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * データ基準日
   */
  private String suppliesBaseDate;

  /**
   * データ基準番号
   */
  private Long suppliesBaseNo;

  /**
   * データ発生元区分
   */
  private String suppliesSourceClass;

  /**
   * 物品区分
   */
  private String suppliesClass;

  /**
   * 物品コード
   */
  private String suppliesCd;

  /**
   * 調整薬剤コード
   */
  private String medicineMixCd;

  /**
   * 分類コード
   */
  private String classCd;

  /**
   * 指示・実績区分
   */
  private String indRstClass;

  /**
   * 指示・実績値
   */
  private String indRstValue;

  /**
   * レセ値
   */
  private String receiptValue;

  /**
   * 確定フラグ
   */
  private String isConfirm;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;

  /** 処方薬剤単位 */
  private String prescriptionUnit;

  /** 処方調剤単位 */
  private String frequencyFlg;

  /** 処方調剤量 */
  private String frequencyNum;

  private String standardMedicineCd;
}
