package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * デバイスエッジマスタのEntity.
 */
@Entity(naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_device_edge")
@Getter
@Setter
public class MstDeviceEdge extends BaseBlankEntity {

  /**
   * シリアル番号
   */
  private String serialNo;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * デバイスエッジ番号.
   */
  private Integer deviceEdgeNo;

  /**
   * デバイスエッジ名.
   */
  private String deviceName;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

  /**
   * 設置日
   */
  private Timestamp settingDate;

  /**
   * 破棄日
   */
  private Timestamp deleteDate;

  /**
   * メモ
   */
  private String memo;

  /**
   * 登録日時.
   */
  private Timestamp regDate;

  /**
   * 更新日時.
   */
  private Timestamp upDate;
}
