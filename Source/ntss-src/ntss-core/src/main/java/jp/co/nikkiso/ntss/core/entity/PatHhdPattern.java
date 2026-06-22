package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;


/**
 * pat_hhd_pattern(在宅患者治療パターン)のエンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_hhd_pattern")
@Getter
@Setter
public class PatHhdPattern extends BaseEntity {

  @Id
  /**
   * システムで管理する一意な患者ID
   */
  private Long patId;

  @Id
  /**
   * 管理番号
   */
  private Integer revision;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 適用開始日
   */
  private String indTreatStartDate;

  /**
   * ベッドコード
   */
  private Long bedCd;

  /**
   * 装置番号
   */
  private Long machineNo;

  /**
   * 指示：治療方法コード
   */
  private Integer indTreatmentCd;

  /**
   * 指示：治療条件情報
   */
  private String indCondInfo;

  /**
   * 指示：投与薬剤情報
   */
  private String indMediInfo;
}
