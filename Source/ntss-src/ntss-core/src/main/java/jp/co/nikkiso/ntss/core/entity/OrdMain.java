package jp.co.nikkiso.ntss.core.entity;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.OrdMainEntityListener;
import lombok.Getter;
import lombok.Setter;


/**
 * 透析情報クラス
 */
@Entity(listener = OrdMainEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_main")
@Getter
@Setter
//mod #10412 次患者更新関連全体見直し対応 朴 start implements Serializable 追加
public class OrdMain extends BaseBlankEntity implements Serializable {
//mod #10412 次患者更新関連全体見直し対応 朴 end
  @Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ordNo;

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

  /* add by shiyw 2024-01-29 [#10196] --start */
  /**
   * 装置モード
   */
  private Integer indDeviceMode;
  /* add by shiyw 2024-01-29 [#10196] --end */

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

  /* add by shiyw 2024-06-03 [#10196] --start */
  /**
   * 実績：装置モード
   */
  private Integer rstDeviceMode;
  /* add by shiyw 2024-06-03 [#10196] --end */

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
  //private Integer rstBedCd;
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

  /* del by shiyw 2024-02-29 [#10196]ord_mainのデータ定義の修正 --start */
//  /**
//   * 実績:装置設定情報
//   */
//  private String rstDeviceSetInfo;
  /* del by shiyw 2024-02-29 [#10196]ord_mainのデータ定義の修正 --end */

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

  /* add by shiyw 2024-01-29 [#10196] --start */
  /**
   * DW指示者情报
   */
  private String indDwUserInfo;
  /* add by shiyw 2024-01-29 [#10196] --end */

  /**
   * 実績：特殊浄化回数.
   */
  private Integer rstPurificationCnt;

  /**
   * 加算情報
   */
  private String additionInfo;
  //

  // add FNSI-最終更新指示者のカラム追加と更新処理 楊 start
  /**
   * 最終更新指示者ID
   */
  private Long upIndUserId;

  /**
   * 最終更新者ID
   */
  private Long upUserId;
  // add FNSI-最終更新指示者のカラム追加と更新処理 楊 end

  /**
   * 初版確定日時
   */
  private Timestamp rstEditionDate;

  /**
   * 最新版確定日時
   */
  private Timestamp curEditionDate;

  /**
   * BVMSファイルのパス
   */
  private String bvmsPath;
  //mod 10929 コンバートされた患者が削除できない zhao start
//  5941【試験T】【結合テスト】装置設定_除水補正:变更后的除水補正数据不能反映到【患者経過総合ビューア】画面 zhao start
//  private String fnPlural;
  private Double fnPlural;
//  5941【試験T】【結合テスト】装置設定_除水補正:变更后的除水補正数据不能反映到【患者経過総合ビューア】画面 zhao end
  //mod 10929 コンバートされた患者が削除できない zhao end


  @Override
  public String toString() {
    return "{" +
      "\"ordNo\":" + ordNo +
      ", \"patId\":" + patId +
      ", \"fnPatId\":\"" + fnPatId + '\"' +
      ", \"treatDate\":\"" + treatDate + '\"' +
      ", \"treatWeek\":" + treatWeek +
      ", \"facilityCd\":\"" + facilityCd + '\"' +
      ", \"facilityName\":\"" + facilityName + '\"' +
      ", \"indVaCd\":" + indVaCd +
      ", \"indTreatmentCd\":" + indTreatmentCd +
      ", \"indTreatmentName\":\"" + indTreatmentName + '\"' +
      ", \"indKurCd\":" + indKurCd +
      ", \"indKurName\":\"" + indKurName + '\"' +
      ", \"indTreatStartTime\":\"" + indTreatStartTime + '\"' +
      ", \"indBedCd\":" + indBedCd +
      ", \"indBedName\":\"" + indBedName + '\"' +
      ", \"indScheduleUserInfo\":" + indScheduleUserInfo +
      ", \"indCondInfo\":" + indCondInfo +
      ", \"indMediInfo\":" + indMediInfo +
      ", \"indEquipInfo\":" + indEquipInfo +
      ", \"indIndCommentInfo\":" + indIndCommentInfo +
      ", \"indTareInfo\":" + indTareInfo +
      ", \"indOffWaterInfo\":" + indOffWaterInfo +
      ", \"rstFnDialysisNo\":" + rstFnDialysisNo +
      ", \"rstRelationDialysisNo\":" + rstRelationDialysisNo +
      ", \"rstEdition\":" + rstEdition +
      ", \"rstIsUpdateEdition\":\"" + rstIsUpdateEdition + '\"' +
      ", \"rstInputClass\":" + rstInputClass +
      ", \"rstDialysisState\":\"" + rstDialysisState + '\"' +
      ", \"rstTreatmentCd\":" + rstTreatmentCd +
      ", \"rstTreatmentName\":\"" + rstTreatmentName + '\"' +
      ", \"rstKurCd\":" + rstKurCd +
      ", \"rstKurName\":\"" + rstKurName + '\"' +
      ", \"rstBedCd\":" + rstBedCd +
      ", \"rstBedName\":\"" + rstBedName + '\"' +
      ", \"rstMachineNo\":" + rstMachineNo +
      ", \"rstMachineName\":\"" + rstMachineName + '\"' +
      ", \"rstCondSendDate\":\"" + rstCondSendDate + '\"' +
      ", \"rstAcceptDate\":\"" + rstAcceptDate + '\"' +
      ", \"rstStartDate\":\"" + rstStartDate + '\"' +
      ", \"rstEndDate\":\"" + rstEndDate + '\"' +
      ", \"rstReturnHomeDate\":\"" + rstReturnHomeDate + '\"' +
      ", \"rstInOutClass\":" + rstInOutClass +
      ", \"rstDialysisCnt\":" + rstDialysisCnt +
      ", \"rstWardCd\":" + rstWardCd +
      ", \"rstWardName\":\"" + rstWardName + '\"' +
      ", \"rstCourseCd\":" + rstCourseCd +
      ", \"rstCourseName\":\"" + rstCourseName + '\"' +
      ", \"rstPunctureUserInfo\":" + rstPunctureUserInfo +
      ", \"rstReturnUserInfo\":" + rstReturnUserInfo +
      ", \"rstChargeUserInfo\":" + rstChargeUserInfo +
      ", \"rstBloodCirculateTotal\":" + rstBloodCirculateTotal +
      ", \"rstRunningTime\":" + rstRunningTime +
      ", \"rstKtV\":" + rstKtV +
      ", \"recSetDate\":\"" + recSetDate + '\"' +
      ", \"sendCtlNo\":" + sendCtlNo +
      ", \"bloodPurifierName\":\"" + bloodPurifierName + '\"' +
      ", \"pullLeaveAmount\":" + pullLeaveAmount +
      ", \"rstCondInfo\":" + rstCondInfo +
      ", \"rstMediInfo\":" + rstMediInfo +
      ", \"rstEquipInfo\":" + rstEquipInfo +
      ", \"rstIndCommentInfo\":" + rstIndCommentInfo +
      ", \"rstTareInfo\":" + rstTareInfo +
      ", \"rstOffWaterInfo\":" + rstOffWaterInfo +
      ", \"rstWeightInfo\":" + rstWeightInfo +
//      ", \"rstVitalInfo\":" + rstVitalInfo + // del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
      ", \"rstComplaintInfo\":" + rstComplaintInfo +
      ", \"rstTreatmentInfo\":" + rstTreatmentInfo +
      ", \"rstTreatStaffInfo\":" + rstTreatStaffInfo +
      ", \"rstRoundsInfo\":" + rstRoundsInfo +
      ", \"isDel\":\"" + isDel + '\"' +
      ", \"regDate\":\"" + regDate + '\"' +
      ", \"upDate\":\"" + upDate + '\"' +
      ", \"indDeviceSetInfo\":" + indDeviceSetInfo +
//      ", \"rstDeviceSetInfo\":" + rstDeviceSetInfo + // del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
      ", \"indDeviceUserInfo\":" + indDeviceUserInfo +
      ", \"isCopyIndMedi\":\"" + isCopyIndMedi + '\"' +
      ", \"baseOrdNo\":" + baseOrdNo +
      ", \"rstDw\":" + rstDw +
      ", \"weightScaleNo\":" + weightScaleNo +
      ", \"treatType\":" + treatType +
      ", \"isConfirm\":\"" + isConfirm + '\"' +
      ", \"indDw\":" + indDw +
      ", \"rstPurificationCnt\":" + rstPurificationCnt +
      ", \"additionInfo\":" + additionInfo + ' ' +
      ", \"upIndUserId\":" + upIndUserId +
      ", \"upUserId\":" + upUserId +
      ", \"rstEditionDate\":\"" + rstEditionDate + '\"' +
      ", \"curEditionDate\":\"" + curEditionDate + '\"' +
      ", \"indDwUserInfo\":\"" + indDwUserInfo + '\"' +
      ", \"indDeviceMode\":\"" + indDeviceMode + '\"' +
      ", \"rstDeviceMode\":\"" + rstDeviceMode + '\"' +
      ", \"bvmsPath\":\"" + bvmsPath + '\"' +
      ", \"fnPlural\":\"" + fnPlural + '\"' +
      '}';
  }
}
