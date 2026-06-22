package jp.co.nikkiso.ntss.core.dto.nextpat;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * ベッドから見て-- ①治療中患者(ord_no)、次患者(next_ord_no)　←mnt_machine_stateより-- ②当日以降未来方向すべてのstat=0の最近のord_no(next_ord_no_stat0)-- ののEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class NextPatByBedInfo {

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * ベッドコード.
   */
  private Long bedCd;

  /**
   * 装置マスタの装置番号
   */
  private Long machineNo;

  /**
   * 装置マスタの型式コード.
   */
  private String machineTypeCd;

  /**
   * 装置マスタの製造番号.
   */
  private String machineSerial;

  /**
   * デバイスエッジ番号.
   */
  private Integer deviceEdgeNo;

  /**
   * システムで管理する一意な患者ID.
   */
  private Long patId;

  /**
   * システムで管理する一意なオーダ番号.
   */
  private Long ordNo;

  /**
   * 次回透析患者ID.
   */
  private Long nextPatid;

  /**
   * 次回透析オーダ番号.
   */
  private Long nextOrdNo;

  /**
   * 当日以降未来方向すべてのstat=0の最近のord_no.
   */
  private Long next_ord_no_stat0;
}
