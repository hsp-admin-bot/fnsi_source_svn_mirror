package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage.ManageInfo;
import lombok.Getter;
import lombok.Setter;

/**
 * デバイスエッジ状態管理と指示管理のEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class DeviceEdgeStateWithManage {

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * デバイスエッジ番号.
   */
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
   * 指示者
   */
  private Long userId;

  /**
   * 指示種別
   */
  private Short orderClass;

  /**
   * 指示対象.
   */
  private Short orderTargetClass;

  /**
   * 応答ステータス.
   */
  private Short responseStatus;

  /**
   * 情報.
   */
  private ManageInfo manageInfo;
}
