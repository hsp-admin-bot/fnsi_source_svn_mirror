package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 条件送信履歴作成に必要な情報を指示データから取得するためのエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdWeightScaleBuildInfo {

  /**
   * オーダー番号
   */
  private Long ordNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 装置番号
   */
  private Long machineNo;
  /**
   * 装置名称
   */
  private String machineName;
  /**
   * ベッドコード[指示]
   */
  private Long indBedCd;
  /**
   * ベッド名称[指示]
   */
  private String indBedName;
  /**
   * クールコード[指示]
   */
  private Long indKurCd;
  /**
   * クール名称[指示]
   */
  private String indKurName;

  /**
   * ベッドコード[実績]
   */
  private Long rstBedCd;
  /**
   * ベッド名称[実績]
   */
  private String rstBedName;
  /**
   * クールコード[実績]
   */
  private Long rstKurCd;
  /**
   * クール名称[実績]
   */
  private String rstKurName;
  /**
   * 患者ID
   */
  private Long patId;
  /**
   * 風袋
   */
  private String indTareInfo;
  /**
   * 除水
   */
  private String indOffWaterInfo;
}
