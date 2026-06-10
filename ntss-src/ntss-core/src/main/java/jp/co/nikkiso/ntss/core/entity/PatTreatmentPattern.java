package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;


/**
 * pat_treatment_pattern(患者治療パターン)のエンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_treatment_pattern")
@Getter
@Setter
public class PatTreatmentPattern extends BaseBlankEntity {

  @Id
  /**
   * システムで管理する一意な患者ID
   */
  private Long patId;

  @Id
  /**
   * 管理番号
   */
  private Long ctlNo;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 治療種別
   */
  private Double treatType;

  /**
   * 適用開始日
   */
  private String indTreatStartDate;

  /**
   * 指示：治療方法コード
   */
  private Integer indTreatmentCd;

  /**
   * 指示：クールコード
   */
  private Long indKurCd;

  /**
   * 治療曜日
   */
  private Short treatWeek;

  /**
   * 指示：スケジュール情報
   */
  private String indSchInfo;

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
   * 指示：風袋補正情報
   */
  private String indTareInfo;

  /**
   * 指示：除水補正情報
   */
  private String indOffWaterInfo;

  /**
   * 指示：装置設定情報
   */
  private String indDeviceSetInfo;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;

  // add #12462 患者情報共有 zrx start
  /**
   * 共有先患者ID
   */
  @Transient
  private Long ownPatId;
  // add #12462 患者情報共有 zrx end
}
