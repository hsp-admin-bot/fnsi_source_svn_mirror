package jp.co.nikkiso.ntss.core.entity.custom;

import java.math.BigDecimal;
import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonFormat;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import lombok.Getter;
import lombok.Setter;

/**
 * 体重計用必要指示情報取得エンティティ
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainForWeightInd {

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
   * 装置モード(指示)
   */
  private Integer indDeviceMode;
  /**
   * クールコード
   */
  private Long indKurCd;
  /**
   * クール名
   */
  private String indKurName;
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
   * 治療予定指示者情報
   */
  private String indScheduleUserInfo;
  /**
   * 治療条件情報
   */
  private String indCondInfo;
  /**
   * 風袋情報
   */
  private String indTareInfo;
  /**
   * 除水情報
   */
  private String indOffWaterInfo;
  /**
   * 版番号
   */
  private Integer rstEdition;
  /**
   * 治療状況
   */
  private String rstDialysisState;
  /**
   * 実績治療方法コード
   */
  private Integer rstTreatmentCd;
  /**
   * 装置モード(実績)
   */
  private Integer rstDeviceMode;
  /**
   * 実績治療方法名
   */
  private String rstTreatmentName;
  /**
   * 実績クールコード
   */
  private Long rstKurCd;
  /**
   * 実績クール名
   */
  private String rstKurName;
  /**
   * 実績ベッドコード
   */
  private Long rstBedCd;
  /**
   * 実績ベッド名
   */
  private String rstBedName;
  /**
   * 実績血液浄化装置名称
   */
  private String bloodPurifierName;
  /**
   * 実績I-HDF引き残し量
   */
  private BigDecimal pullLeaveAmount;
  /**
   * 実績治療条件
   */
  private String rstCondInfo;
  /**
   * 実績風袋情報
   */
  private String rstTareInfo;
  /**
   * 実績除水情報
   */
  private String rstOffWaterInfo;
  /**
   * 実績体重情報
   */
  private String rstWeightInfo;
  /**
   * 測定記録コード
   */
  private Long weightScaleNo;
  /**
   * 治療開始日時
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp rstStartDate;
  /**
   * 治療終了日時
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp rstEndDate;
  /**
   * 車いす使用フラグ
   */
  private String isWheelChair;
  /**
   * 実績：登録区分
   */
  private Integer rstInputClass;

  // #10833(暫定) 2024.08.19 add 指示/実績DWを取得 TDC米沢 start
  /**
   * 指示DW
   */
  private BigDecimal indDw;
  /**
   * 実績DW
   */
  private BigDecimal rstDw;
  // #10833(暫定) 2024.08.19 add 指示/実績DWを取得 TDC米沢 end
}
