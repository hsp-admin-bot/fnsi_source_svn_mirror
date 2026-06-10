package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 通信サーバ用治療情報クラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvOrdMain extends BaseEntity {

  @Id
  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ordNo;

  /**
   * システムで管理する一意な患者ID
   */
  private Long patId;

  /**
   * 治療日
   */
  private String treatDate;

  /**
   * 治療曜日
   */
  private int treatWeek;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 施設名
   */
  private String facilityName;

  /**
   * 実績：治療状況
   */
  private String rstDialysisState;

  /**
   * 実績：治療方法コード
   */
  private int rstTreatmentCd;

  /**
   * 実績：治療方法名
   */
  private String rstTreatmentName;

  /**
   * 実績：クールコード
   */
  private Long rstKurCd;

  /**
   * 実績：クール名
   */
  private String rstKurName;

  /**
   * 実績：ベッドコード
   */
  private Long rstBedCd;

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
   * 実績：入外区分
   */
  private int rstInOutClass;

  /**
   * 実績：透析回数
   */
  private int rstDialysisCnt;

  /**
   * 実績：病棟名
   */
  private String rstWardName;

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
  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//  /**
//   * 実績：装置設定情報
//   */
//  private String rstDeviceSetInfo;
  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
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

  /**
  * 実績：治療状況
  */
  private String dialState;

  /**
   * 実績：条件送信日時
   */
  private Timestamp sendDate;

  /**
   * 実績：治療開始日時
   */
  private Timestamp startDate;

  /**
   * 実績：治療終了日時
   */
  private Timestamp endDate;

  /**
   * 実績：血液循環積算値
   */
  private String rstBloodCirculate;

  /**
   * 実績：透析運転時間
   */
  private String rstRunningTime;

  /**
   * 実績：Kt/V
   */
  private String rstKtv;

  /**
   * 実績：プログラム補液引き残し量
   */
  private String pullLeaveAmount;

  /**
   * 実績：除水積算値（体重情報）
   */
  private String addTotal;

  /**
   * 実績：補液積算値（体重情報）
   */
  private String addWaterTotal;

  /**
   * 実績：Kt/V測定値（体重情報）
   */
  private String KtvMeasure;

  /**
   * 実績：URR（体重情報）
   */
  private String ufr;

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

}
