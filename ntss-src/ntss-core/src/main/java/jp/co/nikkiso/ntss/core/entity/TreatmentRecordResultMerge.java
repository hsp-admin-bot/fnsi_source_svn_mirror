package jp.co.nikkiso.ntss.core.entity;

import java.math.BigDecimal;
import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

/**
 * 治療情報のEntity（実績マージ情報）.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_main")
@Getter
@Setter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@EqualsAndHashCode(callSuper = false)
public class TreatmentRecordResultMerge extends BaseEntity {

  /**
   * オーダ番号.
   */
  @Id
  private Long ordNo;

  /**
   * 患者ID.
   */
  private Long patId;

  /**
   * 院内表示用の患者ID.
   */
  private String hospPatId;

  /**
   * 患者名.
   */
  private String patName;

  /**
   * 登録区分.
   */
  private Integer rstInputClass;

  /**
   * 治療状況.
   */
  private String rstDialysisState;

  /**
   * 治療方法コード.
   */
  private String rstTreatmentCd;

  /**
   * 治療方法名.
   */
  private String rstTreatmentName;

  /**
   * クールコード.
   */
  private Long rstKurCd;

  /**
   * クール名.
   */
  private String rstKurName;

  /**
   * ベッドコード.
   */
  private Long rstBedCd;

  /**
   * ベッド名.
   */
  private String rstBedName;

  /**
   * 装置名.
   */
  private String rstMachineName;

  /**
   * 条件送信日時.
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp rstCondSendDate;

  /**
   * 受付日時.
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp rstAcceptDate;

  /**
   * 治療開始日時.
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp rstStartDate;

  /**
   * 治療終了日時.
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp rstEndDate;

  /**
   * 帰宅日時.
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp rstReturnHomeDate;

  /**
   * 入外区分.
   */
  private Integer rstInOutClass;

  /**
   * 透析回数.
   */
  private Integer rstDialysisCnt;

  /**
   * 病棟コード.
   */
  private Integer rstWardCd;

  /**
   * 病棟名.
   */
  private String rstWardName;

  /**
   * 診療科コード.
   */
  private Integer rstCourseCd;

  /**
   * 診療科名.
   */
  private String rstCourseName;

  /**
   * DW.
   */
  private BigDecimal rstDw;

  /**
   * 穿刺者情報.
   */
  private String rstPunctureUserInfo;

  /**
   * 返血者情報.
   */
  private String rstReturnUserInfo;

  /**
   * 担当者情報.
   */
  private String rstChargeUserInfo;

  /**
   * 血液循環積算値.
   */
  private BigDecimal rstBloodCirculateTotal;

  /**
   * 透析運転時間.
   */
  private Integer rstRunningTime;

  /**
   * Kt/V.
   */
  private BigDecimal rstKtV;

  /**
   * 透析記録確認日時.
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp recSetDate;

  /**
   * 送信管理番号
   */
  private Long sendCtlNo;

  /**
   * 血液浄化装置名称.
   */
  private String bloodPurifierName;

  /**
   * プログラム補液引き残し量.
   */
  private BigDecimal pullLeaveAmount;

  /**
   * 治療条件情報.
   */
  private String rstCondInfo;

  /**
   * 投与薬剤情報.
   */
  private String rstMediInfo;

  /**
   * 医療材料情報.
   */
  private String rstEquipInfo;

  /**
   * 指示コメント情報.
   */
  private String rstIndCommentInfo;

  /**
   * 風袋補正.
   */
  private String rstTareInfo;

  /**
   * 除水補正.
   */
  private String rstOffWaterInfo;
  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//  /**
//   * 装置設定情報.
//   */
//  private String rstDeviceSetInfo;
  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
  /**
   * 体重測定記録番号.
   */
  private Long weightScaleNo;

  /**
   * 体重情報.
   */
  private String rstWeightInfo;
  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//  /**
//   * バイタル情報.
//   */
//  private String rstVitalInfo;
  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
  /**
   * 愁訴情報.
   */
  private String rstComplaintInfo;

  /**
   * 愁訴処置情報.
   */
  private String rstTreatmentInfo;

  /**
   * 愁訴処置者情報.
   */
  private String rstTreatStaffInfo;

  /**
   * 回診記録情報.
   */
  private String rstRoundsInfo;

  /**
   * 特殊浄化回数.
   */
  private Integer rstPurificationCnt;

  // TODO BaseEntityを使用するAPIがすべて返却しないなら、BaseEntityにJsonIgnoreを記載したい。現状テストがないため、判断不可
  @Override
  @JsonIgnore
  public Timestamp getRegDate() {
    return super.getRegDate();
  }

  @Override
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  public Timestamp getUpDate() {
    return super.getUpDate();
  }

  @Override
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  public void setUpDate(Timestamp value) {
    super.setUpDate(value);
  }

  /**
   * バイタル情報マージ有無
   * true : マージする
   * false: マージしない
   */
  @Transient
  private boolean isVitalMerge;

  /**
   * モニタ情報マージ有無
   * true : マージする
   * false: マージしない
   */
  @Transient
  private boolean isMonitorMerge;

  /**
   * マージ元のオーダ番号
   * ※このオーダ番号に該当する情報を更新する.
   */
  @Transient
  private Long mergeOrdNo;

  /**
   * 更新者ID
   * ※内部利用者ID
   */
  @Transient
  private Long updStaffId;

  /**
   * 治療日.
   */
  private String treatDate;

  //add FNSI修正486改修 房 start
  @Transient
  private Boolean deleteFlag;
  @Transient
  private Long baseOrdNo;
  @Transient
  private String baseFacilityCd;
  @Transient
  private String baseSendMsgFlag;
  @Transient
  private String baseUpdateFlag;
  @Transient
  private Long baseBedCd;
  @Transient
  private Long merOrdNo;
  @Transient
  private String mergeFacilityCd;
  @Transient
  private String mergeSendMsgFlag;
  @Transient
  private String mergeUpdateFlag;
  @Transient
  private Long mergeBedCd;
  @Transient
  private Boolean deviceSetRecordFlag;
  @Transient
  private Long deviceFromOrdNo;
  @Transient
  private Boolean deviceSetInfoFlag;
  /**
   * 指示コメント情報.
   */
  private String indIndCommentInfo;
  /**
   * 投与薬剤情報.
   */
  private String indMediInfo;
  @Transient
  private Boolean ordCheckListFlag;
  //add FNSI修正486改修 房 end

  // #10344 Add
  /** マージ用投与薬剤リスト長 */
  @Transient
  private Integer mergeMediInfoArrayLen;
  @Transient
  private String mergeRstMediInfo;
  // #10344 Add

  // # 11467【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B Start
  private Integer rstDeviceMode;
  // # 11467【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B End
  
  /**
   * 患者氏名(姓)
   */
  @Transient
  private String patLastName;
  /**
   * 患者氏名(名)
   */
  @Transient
  private String patFirstName;
  /**
   * 患者氏名(カタカナ姓)
   */
  @Transient
  private String patLastNameKana;
  /**
   * 患者氏名(カタカナ名)
   */
  @Transient
  private String patFirstNameKana;
  /**
   * 実績：クール開始時刻
   */
  private String rstKurStartTime;
  /**
   * 実績：治療方法マスタ表示順
   */
  private Long rstTreatmentOrderIndex;
  /**
   * 実績：ベッドマスタ表示順
   */
  private Long rstBedOrderIndex;
}
