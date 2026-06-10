package jp.co.nikkiso.ntss.core.entity.custom;

import java.math.BigDecimal;
import java.sql.Timestamp;

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
public class TreatmentStatusList extends BaseEntity {

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 施設名
   */
  private String facilityName;

  /**
   * システムで管理する一意なオーダー番号.
   */
  private Long ordNo;

  /**
   * 患者ID.
   */
  private Long patId;

  /**
   * 治療日.
   */
  private String treatDate;

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
   * 装置番号
   */
  private Long rstMachineNo;

  /**
   * 実績：治療開始日時
   */
  private Timestamp rstStartDate;

  /**
   * 実績：治療終了日時
   */
  private Timestamp rstEndDate;

  /**
   * 実績：担当者情報
   */
  private String rstChargeUserInfo;

  /**
   * 実績：穿刺者情報
   */
  private String rstPunctureUserInfo;

  /**
   * 実績：返血者情報
   */
  private String rstReturnUserInfo;

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
   * FNW+で管理する施設内の一意な患者ID
   */
  private Long fnPatId;
  /**
   * 治療曜日
   */
  private Integer treatWeek;
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
   * 指示：治療開始時刻
   */
  private String indTreatStartTime;
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
   * 指示：装置設定情報
   */
  private String indDeviceSetInfo;
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
  private Integer rstInputClass;
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
  private String rstAcceptDate;
  /**Timestamp
   * 実績：帰宅日時
   */
  private Timestamp rstReturnHomeDate;
  /**
   * 実績：入外区分
   */
  private Integer rstInOutClass;
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
   * 実績：血液循環積算値
   */
  private Double rstBloodCirculateTotal;
  /**
   * 実績：透析運転時間
   */
  private Integer rstRunningTime;
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
  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//  /**
//   * 実績：装置設定情報
//   */
//  private String rstDeviceSetInfo;
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
   * 削除フラグ.
   */
  private String isDel;
  /**
   * 穿刺ID1
   */
  private String rstPunctureUserIdA;
  /**
   * 穿刺ID2
   */
  private String rstPunctureUserIdB;
  /**
   * 穿刺登録日時1
   */
  private String rstPunctureDateA;
  /**
   * 穿刺登録日時2
   */
  private String rstPunctureDateB;
  /**
   * 穿刺登録日時
   */
  private String rstPunctureDate;
  /**
   * 返血者ID1
   */
  private String rstReturnUserIdA;
  /**
   * 返血者ID2
   */
  private String rstReturnUserIdB;
  /**
   * 返血登録日時1
   */
  private String rstReturnDateA;
  /**
   * 返血登録日時2
   */
  private String rstReturnDateB;
  /**
   * 返血登録日時
   */
  private String rstReturnDate;
  /**
   * 担当者ID1
   */
  private String rstChargeUserIdA;
  /**
   * 担当者ID2
   */
  private String rstChargeUserIdB;
  /**
   * 担当登録日時1
   */
  private String rstChargeDateA;
  /**
   * 担当登録日時2
   */
  private String rstChargeDateB;
  /**
   * 指示：マスタから取得したVA名
   */
  private String indMstVaName;
  /**
   * 指示：マスタから取得した治療方法名
   */
  private String indMstTreatmentName;
  /**
   * 指示：マスタから取得したクール名
   */
  private String indMstKurName;
  /**
   * 指示：マスタから取得したベッド名
   */
  private String indMstBedName;

  private BigDecimal rstDw;
  private BigDecimal indDw;
  private Long WeightScaleNo;

  /**
   * 装置エントリー状態[-1：空きベッド/0：治療後～確定前/1：次患者/2：現患者]
   */
  private Integer machineEntry;

  /**
   * 指示：マスタから取得した治療方法の装置モード
   */
  private Integer indTreatmentDeviceMode;
  /**
   * 実績：マスタから取得した治療方法の装置モード
   */
  private Integer rstTreatmentDeviceMode;

  /**
   * 指示変更ありフラグ
   */
  private String isContentChangedForMap;

  /*
   * 行番号
   */
  private Long ordIndex;

  /*
   * クール開始時刻
   */
  private String kurStartTime;

  // add FNSI-redmine 5461 劉祥霖　start
  private String isDummy;
  // add FNSI-redmine 5461 劉祥霖　end

  /* add by chamaojia 2024-03-28 [10303、10304] add object properties --start */
  /**
   * 型式コード.
   */
  private String machineTypeCd;

  /**
   * 製造番号.
   */
  private String machineSerial;
  /* add by chamaojia 2024-03-28 [10303、10304] add object properties --end */

  //add #12358 治療状況リスト・治療状況マップ・チェックリストの次患者表示次クールで数日先の予定が表示した。 zrx start
  private String targetDate;
  /**
   * クールコード
   */
  private Long firstKurCd;
  /**
   * 0：当日
   * 1：翌日
   */
  private Long lastFlg;
  //add #12358 治療状況リスト・治療状況マップ・チェックリストの次患者表示次クールで数日先の予定が表示した。 zrx end
}
