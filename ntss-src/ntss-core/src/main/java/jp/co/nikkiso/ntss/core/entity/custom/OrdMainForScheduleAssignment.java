package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * スケジュール割り当て用スケジュール取得エンティティ
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainForScheduleAssignment {

  /**
   * オーダーID(内部用).
   */
  private Long ordNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 患者ID(内部用).
   */
  private Long patId;
  /**
   * 治療日(yyyymmdd)
   */
  private String treatDate;
  /**
   * 治療曜日(1：月曜日 ～ 7：日曜日)
   */
  private Short treatWeek;
  /**
   * 指示：クールコード
   */
  private Long indKurCd;
  /**
   * 指示：クール名
   */
  private String indKurName;
  /**
   * 実績：クールコード
   */
  private Long rstKurCd;
  /**
   * 実績：クール名
   */
  private String rstKurName;
  /**
   * 指示：ベッドコード
   */
  private Long indBedCd;
  /**
   * 指示：ベッド名
   */
  private String indBedName;
  /**
   * 実績：ベッドコード
   */
  private Long rstBedCd;
  /**
   * 実績：ベッド名
   */
  private String rstBedName;
  /**
   * 治療状況
   */
  private String rstDialysisState;
  /**
   * 指示：装置モード
   */
  private Integer indDeviceMode;
  /**
   * 実績：装置モード
   */
  private Integer rstDeviceMode;
  /**
   * 実績：装置番号
   */
  private Long rstMachineNo;
  /**
   * 実績：体重情報
   */
  private String rstWeightInfo;
  /**
   * 治療開始日時
   */
  private Timestamp rstStartDate;
  /**
   * 治療終了日時
   */
  private Timestamp rstEndDate;
  /**
   * 指示：クール開始時刻
   */
  private String indKurStartTime;
  /**
   * 指示：ベッドマスタ表示順
   */
  private Long indBedOrderIndex;
}
