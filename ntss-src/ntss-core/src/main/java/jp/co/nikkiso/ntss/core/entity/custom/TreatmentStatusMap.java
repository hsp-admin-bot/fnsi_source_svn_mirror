package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 治療状況リスト用のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class TreatmentStatusMap extends BaseEntity {

  /**
   * 施設コード.
   */
//  private String facilityCd;

  /**
   * システムで管理する一意なオーダー番号.
   */
  private Long ordNo;

  /**
   * 患者ID.
   */
  private Long patId;

  /**
   * 指示：ベッドコード
   */
  private String indBedCd;

  /**
   * 指示：VAコード
   */
  private Integer indVaCd;

  /**
   * 指示：治療方法コード
   */
  private Integer indTreatmentCd;

  /**
   * 実績：入外区分
   */
//  private Short rstInOutClass;

  /**
   * 装置番号
   */
  private Long machineNo;

  /**
   * シャント位置
   */
  private Short shuntPosition;

  /**
   * 感染症フラグ
   */
  private String isInfection;

  /**
   * 型式コード
   */
  private String machineTypeCd;

  /**
   * 対応可否フラグ（HD）
   */
  private String isSupportHd;

  /**
   * 対応可否フラグ（ECUM）
   */
  private String isSupportEcum;

  /**
   * 対応可否フラグ（HDF）
   */
  private String isSupportHdf;

  /**
   * 対応可否フラグ（HF）
   */
  private String isSupportHf;

  /**
   * 対応可否フラグ（HD+補液）
   */
  private String isSupportHdHo;

  /**
   * 対応可否フラグ（ECUM+補液）
   */
  private String isSupportEcumHo;

  /**
   * 対応可否フラグ（AFBF）
   */
  private String isSupportAfbf;

  /**
   * 対応可否フラグ（OHDF）
   */
  private String isSupportOhdf;

  /**
   * 対応可否フラグ（OHF）
   */
  private String isSupportOhf;

  /**
   * 対応可否フラグ（I-HDF）
   */
  private String isSupportIhdf;

  /**
   * 対応可否フラグ（特殊浄化）
   */
  private String isSupportBloodPurify;

  /**
   * 製造番号
   */
  private String machineSerial;
  //スペースを削除する 6901 関 start
  public String getMachineSerial() {
    if (machineSerial != null) {
      return machineSerial.trim();
    }
    return machineSerial;
  }

  public void setMachineSerial(String machineSerial) {
    if (machineSerial != null) {
      this.machineSerial = machineSerial.trim();
    }
  }
  //スペースを削除する 6901 end
  /**
   * 工程
   */
  private String processState;

  /**
   * VA方向
   */
  private String vaDirect;

  /**
   * 感染症有無
   */
  private String isInfect;

  /**
   * 装置モード
   */
  private Integer deviceMode;
}
