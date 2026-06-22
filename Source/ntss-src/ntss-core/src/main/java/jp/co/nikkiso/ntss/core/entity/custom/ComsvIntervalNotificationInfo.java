package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 定期的に血圧未測定間隔やケア未実施間隔の通知に必要な情報を取得するEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvIntervalNotificationInfo {

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 型式コード.
   */
  private String machineTypeCd;

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
   * システムで管理する一意なオーダ番号.
   */
  private Long ordNo;

  /**
   * ベッド名.
   */
  private String bedName;

  /**
   * 警報リスト
   */
  private String alarmList;

  /**
   * システムで管理する一意な患者ID
   */
  private Long patId;

  /**
   * 実績：治療方法コード
   */
  private Integer rstTreatmentCd;

  /**
   * 実績：治療開始日時
   */
  private Timestamp rstStartDate;

  /**
   * 実績：投与薬剤情報
   */
  private String rstMediInfo;

  /**
   * 実績：愁訴情報
   */
  private String rstComplaintInfo;

  /**
   * 実績：愁訴処置情報
   */
  private String rstTreatmentInfo;

  /**
   * 実績：愁訴処置者情報
   */
  private String rstTreatStaffInfo;

  /**
   * 装置モード
   */
  private Integer deviceMode;

  /**
   * ホスト報知情報
   */
  private String hostNotificationInfo;

  /* add by chamaojia 2026-04-13 [11740] 【#11471】特殊浄化判定処理の見直し --start */
  /**
   * 通信種別
   */
  private Integer comType;
  /* add by chamaojia 2026-04-13 [11740] 【#11471】特殊浄化判定処理の見直し --end */
}
