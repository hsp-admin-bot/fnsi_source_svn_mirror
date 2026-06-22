package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 体重計患者選択用スケジュール取得エンティティ
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainForWeightSchedule {

  /**
   * オーダーID(内部用).
   */
  private Long ordNo;
  /**
   * 患者ID(内部用).
   */
  private Long patId;
  /**
   * 施設コード.
   */
  private String facilityCd;
  /**
   * 同姓同名.
   */
  private String isSame;

  /**
   * 治療日(yyyymmdd)
   */
  private String treatDate;
  /**
   * 治療方法コード
   */
  private Integer indTreatmentCd;
  /**
   * 治療方法名
   */
  private String indTreatmentName;
  /**
   * 装置モード
   */
  private Integer indDeviceMode;
  /**
   * 治療方法コード
   */
  private Integer rstTreatmentCd;
  /**
   * 治療方法名
   */
  private String rstTreatmentName;
  /**
   * 装置モード
   */
  private Integer rstDeviceMode;
  /**
   * クールコード
   */
  private Long indKurCd;
  /**
   * クール名
   */
  private String indKurName;
  /**
   * クールコード
   */
  private Long rstKurCd;
  /**
   * クール名
   */
  private String rstKurName;
  /**
   * 治療開始時間
   */
  private String indTreatStartTime;
  /**
   * ベッドコード
   */
  private Long indBedCd;
  /**
   * ベッド名
   */
  private String indBedName;
  /**
   * ベッドコード
   */
  private Long rstBedCd;
  /**
   * ベッド名
   */
  private String rstBedName;
  /**
   * 版番号
   */
  private Integer rstEdition;
  /**
   * 治療状況
   */
  private String rstDialysisState;
  /**
   * 治療開始日
   */
  private Timestamp rstStartDate;
  /**
   * 指示：クール開始時刻
   */
  private String indKurStartTime;
  /**
   * 実績：クール開始時刻
   */
  private String rstKurStartTime;
  /**
   * 指示：治療方法マスタ表示順
   */
  private Long indTreatmentOrderIndex;
  /**
   * 実績：治療方法マスタ表示順
   */
  private Long rstTreatmentOrderIndex;
  /**
   * 指示：ベッドマスタ表示順
   */
  private Long indBedOrderIndex;
  /**
   * 実績：ベッドマスタ表示順
   */
  private Long rstBedOrderIndex;
}
