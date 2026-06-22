package jp.co.nikkiso.ntss.data_gathering_auto.entity;

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

  @Column(name = "auto_gathering_start_time")
  private String autoGatheringStartTime;

  /**
   * テーブル外項目(次回実施日付：文字列で日付のみ)
   */
  private String autoGatheringNextProcDay;
}
