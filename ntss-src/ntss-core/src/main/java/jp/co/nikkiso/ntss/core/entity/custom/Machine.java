package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

/**
 * 装置一覧取得用Entiy.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class Machine {

  /**
   * 施設名.
   */
  private String facilityName;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 型式コード.
   */
  private String machineTypeCd;

  /**
   * 型式.
   */
  private String machineType;

  /**
   * 製造番号.
   */
  private String machineSerial;
  //スペースを削除する 6901 関 start
  public String getMachineSerial() {
    if (machineSerial != null) {
      return machineSerial.trim();
    }
    return machineSerial;
  }

  public void setMachineSerial(String machineSerial) {
    if (machineSerial != null) {
      this.machineSerial = machineSerial.trim();
    }
  }
  //スペースを削除する 6901 end
  /**
   * 機種.
   */
  private String model;

  /**
   * 装置名.
   */
  private String machineName;

  /**
   * ベッド名.
   */
  private String bedName;

  /**
   * 工程.
   */
  private String processState;

  /**
   * 緊急発報件数.
   */
  private Integer mNoticeCnt;

  /**
   * 予防保守件数.
   */
  private Integer preventiveMainteCnt;

  /**
   * 通信不良有無.
   */
  private Integer isPreventiveMainte;

  /**
   * 色分けフラグ.
   * <p>
   * 0: なし
   * 1: 緊急発報
   * 2: 予防保守
   * 3: 通信不良
   * </p>
   */
  private int colorFlg;

  /**
   * 通信フォーマット
   */
  private String comFormatCd;

  /**
   * 通信種別
   */
  private Integer comType;

  /**
   * デバイスエッジ番号
   */
  private Integer deviceEdgeNo;

  /**
   * FTP収集.
   */
  private String isFtp;

  /**
   * バージョン
   */
  private String version;

  /**
   * サービス対応件数.
   */
  private Integer serviceSupportCnt;

  /**
   * 最大イベント発生日時
   * ※対処済の場合には設定されない.
   */
  @Transient
  private Timestamp maxEventRegDate;

  /**
   * 最新の未対処イベント発生日時
   */
  private Timestamp latestPendingDate;

  /**
   * 最新の対処中イベント発生日時
   */
  private Timestamp latestWipDate;

  /**
   * ベッドマスタ表示順
   */
  private String bedDispNo;

  /**
   * 装置マスタ表示順
   */
  private String machineDispNo;

  /**
   * 自己診断結果
   */
  private String selfMeasureResult;
}
