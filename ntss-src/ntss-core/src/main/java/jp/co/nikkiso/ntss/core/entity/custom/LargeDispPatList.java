package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 治療状況リスト大画面表示基本情報Entity
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class LargeDispPatList {

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * オーダー番号
   */
  private Long ordNo;

  /**
   * ベッドNo
   */
  private String bedName;

  /**
   * 実績：条件送信日時
   */
  private Timestamp rstCondSendDate;

  /**
   * 実績：治療状況
   */
  private String rstDialysisState;

  /**
   * 実績：治療開始日時
   */
  private Timestamp rstStartDate;

  /**
   * 実績：治療終了日時
   */
  private Timestamp rstEndDate;

  /**
   * 実績：入外区分
   */
  private int rstInOutClass;

  /**
   * 実績：穿刺者1入力日時
   */
  private String puncture1Date;

  /**
   * 実績：穿刺者2入力日時
   */
  private String puncture2Date;

  /**
   * 実績：返血者1入力日時
   */
  private String return1Date;

  /**
   * 実績：返血者2入力日時
   */
  private String return2Date;

  /**
   * 実績：投与薬剤情報
   */
  private String rstMediInfo;

  /**
   * モニタデータ
   */
  private String monitorData;

}