package jp.co.nikkiso.ntss.alive_moni_auto.entity;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;

import lombok.Getter;
import lombok.Setter;

/**
 * 施設マスタEntity.
 */
@Entity
@Getter
@Setter
public class MstFacilityCustom {
  
  @Id
  @Column(name = "facility_cd")
  private String facilityCd;

  @Column(name = "facility_name")
  private String facilityName;

  @Column(name = "alive_moni_interval")
  private Integer aliveMoniInterval;

  /**
   * テーブル外の項目 各施設ごとの処理実施フラグ(※現状、全体の停止処理時のみ使用)
   */
  private Boolean isStart = true;
}
