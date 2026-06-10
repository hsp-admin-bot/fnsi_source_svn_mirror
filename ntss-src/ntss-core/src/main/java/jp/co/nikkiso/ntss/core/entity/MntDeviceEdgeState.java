package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * デバイスエッジ状態管理のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_device_edge_state")
@Getter
@Setter
public class MntDeviceEdgeState extends BaseEntity {

  /**
   * 施設コード.
   */
  @Id
  private String facilityCd;

  /**
   * デバイスエッジ番号.
   */
  @Id
  private Integer deviceEdgeNo;

  /**
   * 死活監視ステータス.
   */
  private String aliveMoniStatus;

  /**
   * バージョン情報
   */
  private String versionInformation;

  /**
   * 死活監視メール送信状況
   */
  private Short sendMailStatus;

  /**
   * 予約更新指示番号
   */
  private Long manageNo;

  /**
   * 予約更新日時
   */
  private Timestamp managePlanDate;

  /**
   * 最終確認日時.
   */
  private Timestamp lastMoniTime;

  /**
   * 死活ステータス変化日時
   */
  private Timestamp aliveMoniStatusChangeDate;
}
