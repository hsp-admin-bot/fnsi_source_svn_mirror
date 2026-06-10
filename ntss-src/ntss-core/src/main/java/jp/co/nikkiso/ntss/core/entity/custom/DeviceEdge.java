package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * デバイスエッジ一覧取得用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class DeviceEdge {

  /**
   * シリアルNo.
   */
  private String serialNo;

  /**
   * 部署符号.
   */
  private String departmentCd;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 施設名.
   */
  private String facilityName;

  /**
   * 施設カナ名.
   */
  private String facilityNameKana;

  /**
   * デバイスエッジ番号.
   */
  private Integer deviceEdgeNo;

  /**
   * デバイス名.
   */
  private String deviceName;

  /**
   * 死活監視ステータス.
   */
  private String aliveMoniStatus;

  /**
   * 都道府県コード.
   */
  @Column(name = "prefectures_cd")
  private String prefCd;

  /**
   * 都道府県名.
   */
  private String prefName;

  /**
   * 最終確認日時(yyyy/MM/dd HH24:MI:SS).
   */
  private String lastMoniTime;

  /**
   * 死活ステータス変化日時
   */
  private Timestamp aliveMoniStatusChangeDate;

}
