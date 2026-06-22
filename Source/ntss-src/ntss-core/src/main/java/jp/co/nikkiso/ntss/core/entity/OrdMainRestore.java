package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import java.math.BigDecimal;
import java.sql.Timestamp;


/**
 * 透析情報クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_main_restore")
@Getter
@Setter
public class OrdMainRestore extends BaseBlankEntity {
  @Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ordNo;

  /**
   * 実績：条件送信日時
   */
  private Timestamp delDate;

  /**
   * システムで管理する一意な患者ID
   */
  private Long patId;

  /**
   * FNW+で管理する施設内の一意な患者ID
   */
  private String fnPatId;

  /**
   * 治療日
   */
  private String treatDate;

  /**
   * 治療曜日
   */
  private Short treatWeek;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 施設名
   */
  private String facilityName;

  /**
   * 指示：VAコード
   */
  private Integer indVaCd;

  /**
   * 指示：治療方法コード
   */
  private Integer indTreatmentCd;

  /**
   * 指示：治療方法名
   */
  private String indTreatmentName;

  /**
   * 指示：クールコード
   */
  private Integer indKurCd;

  /**
   * 指示：クール名
   */
  private String indKurName;

  /**
   * 指示：治療開始時刻
   */
  private String indTreatStartTime;

  /**
   * 指示：ベッドコード
   */
  private Integer indBedCd;

  /**
   * 指示：ベッド名
   */
  private String indBedName;

  /**
   * 指示：治療予定指示者情報
   */
  private String indScheduleUserInfo;

  /**
   * 指示：治療条件情報
   */
  private String indCondInfo;

  /**
   * 指示：投与薬剤情報
   */
  private String indMediInfo;

  /**
   * 指示：医療材料情報
   */
  private String indEquipInfo;

  /**
   * 指示：指示コメント情報
   */
  private String indIndCommentInfo;

  /**
   * 指示：風袋補正
   */
  private String indTareInfo;

  /**
   * 指示：除水補正
   */
  private String indOffWaterInfo;

  /**
   * 実績：FNW+透析番号
   */
  private Long rstFnDialysisNo;

  /**
   * 実績：関連透析番号
   */
  private Long rstRelationDialysisNo;

  /**
   * 実績：版番号
   */
  private Integer rstEdition;

  /**
   * 実績：版番号更新フラグ
   */
  private String rstIsUpdateEdition;

  /**
   * 実績：登録区分
   */
  private Short rstInputClass;

  /**
   * 実績：治療状況
   */
  private String rstDialysisState;

  /**
   * 実績：治療方法コード
   */
  private Integer rstTreatmentCd;

  /**
   * 実績：治療方法名
   */
  private String rstTreatmentName;

  /**
   * 実績：クールコード
   */
  private Integer rstKurCd;

  /**
   * 実績：クール名
   */
  private String rstKurName;

  /**
   * 実績：ベッドコード
   */
  //mod 8347【デグレ】????患者治療割り当てができない zhao start
  //  private Integer rstBedCd;
  private Long rstBedCd;
  //mod 8347【デグレ】????患者治療割り当てができない zhao end

  /**
   * 実績：ベッド名
   */
  private String rstBedName;

  /**
   * 実績：装置番号
   */
  private Long rstMachineNo;

  /**
   * 実績：装置名
   */
  private String rstMachineName;

  /**
   * 実績：条件送信日時
   */
  private Timestamp rstCondSendDate;

  /**
   * 実績：受付日時
   */
  private Timestamp rstAcceptDate;

  /**
   * 実績：治療開始日時
   */
  private Timestamp rstStartDate;

  /**
   * 実績：治療終了日時
   */
  private Timestamp rstEndDate;

  /**
   * 実績：帰宅日時
   */
  private Timestamp rstReturnHomeDate;

  /**
   * 実績：入外区分
   */
  private Short rstInOutClass;

  /**
   * 実績：透析回数
   */
  private Integer rstDialysisCnt;

  /**
   * 実績：病棟コード
   */
  private Integer rstWardCd;

  /**
   * 実績：病棟名
   */
  private String rstWardName;

  /**
   * 実績：診療科コード
   */
  private Integer rstCourseCd;

  /**
   * 実績：診療科名
   */
  private String rstCourseName;

  /**
   * 実績：穿刺者情報
   */
  private String rstPunctureUserInfo;

  /**
   * 実績：返血者情報
   */
  private String rstReturnUserInfo;

  /**
   * 実績：担当者情報
   */
  private String rstChargeUserInfo;

  /**
   * 実績：血液循環積算値
   */
  private Double rstBloodCirculateTotal;

  /**
   * 実績：透析運転時間
   */
  private Short rstRunningTime;

  /**
   * 実績：Kt/V
   */
  private Double rstKtV;

  /**
   * 実績：透析記録確認日時
   */
  private Timestamp recSetDate;

  /**
   * 実績：送信管理番号
   */
  private Long sendCtlNo;

  /**
   * 実績：血液浄化装置名称
   */
  private String bloodPurifierName;

  /**
   * 実績：プログラム補液引き残し量
   */
  private Double pullLeaveAmount;

  /**
   * 実績：治療条件情報
   */
  private String rstCondInfo;

  /**
   * 実績：投与薬剤情報
   */
  private String rstMediInfo;

  /**
   * 実績：医療材料情報
   */
  private String rstEquipInfo;

  /**
   * 実績：指示コメント情報
   */
  private String rstIndCommentInfo;

  /**
   * 実績：風袋補正
   */
  private String rstTareInfo;

  /**
   * 実績：除水補正
   */
  private String rstOffWaterInfo;

  /**
   * 実績：体重情報
   */
  private String rstWeightInfo;
  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//  /**
//   * 実績：バイタル情報
//   */
//  private String rstVitalInfo;
  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
  /**
   * 実績：愁訴情報
   */
  private String rstComplaintInfo;

  /**
   * 実績：愁訴処置情報
   */
  private String rstTreatmentInfo;

  /**
   * 実績：愁訴処置者情報
   */
  private String rstTreatStaffInfo;

  /**
   * 実績：回診記録情報
   */
  private String rstRoundsInfo;

  /**
   * 削除フラグ
   */
  private String isDel;

  /**
   * 登録日時
   */
  private Timestamp regDate;

	/**
   * 更新日時
   */
  private Timestamp upDate;

  /**
   * 指示:装置設定情報
   */
  private String indDeviceSetInfo;
  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//  /**
//   * 実績:装置設定情報
//   */
//  private String rstDeviceSetInfo;
  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
  /**
   * 指示:装置設定情報の利用者情報
   */
  @Transient
  private String indDeviceUserInfo;

  /**
   * 投与薬剤コピーフラグ
   */
  @Transient
  private String isCopyIndMedi = "0";

  /**
   * 参照用オーダ番号
   */
  @Transient
  private Long baseOrdNo;

  /**
   * 実績:DW
   */
  private BigDecimal rstDw;

  /**
   * 実績:体重測定記録番号
   */
  private Long weightScaleNo;

  /**
   * 治療種別
   */
  private Double treatType;

  /**
   * 確定フラグ
   * 0:未確定
   * 1:確定
   */
  private String isConfirm;

  /**
   * 指示:DW
   */
  private BigDecimal indDw;

  /**
   * 実績：特殊浄化回数.
   */
  private Integer rstPurificationCnt;

  /**
   * 加算情報
   */
  private String additionInfo;

  /**
   * 最終更新指示者ID
   */
  private Long upIndUserId;

  /**
   * 最終更新者ID
   */
  private Long upUserId;

  /**
   * 指示：FNW+同日複数回
   */
  private Double fnPlural;

  /**
   * BVMSファイルのパス
   */
  private String bvmsPath;
  // add 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 関 start
  /**
   * 初版確定日時
   */
  private Timestamp rstEditionDate;

  /**
   * 最新版確定日時
   */
  private Timestamp curEditionDate;

  /**
   * DW指示者情报
   */
  private String indDwUserInfo;

  /**
   * 装置モード
   */
  private Integer indDeviceMode;

  /**
   * 実績：装置モード
   */
  private Integer rstDeviceMode;
  // add 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 関 end
}
