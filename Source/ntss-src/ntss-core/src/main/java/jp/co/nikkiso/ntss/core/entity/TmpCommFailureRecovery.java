package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 * 装置状態管理のEntity(AWSとDEの通信断からの復旧).
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "tmp_comm_failure_recovery")
@Getter
@Setter
public class TmpCommFailureRecovery extends BaseEntity{

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
   * 次回透析オーダ番号.
   */
  private Long nextOrdNo;
  /**
   * システムで管理する一意な患者ID.
   */
  private Long patId;

  /**
   * 次患者ID.
   */
  private Long nextPatid;
  /**
   * 透析開始日時.
   */
  private Timestamp startDate;

  /**
   * 透析終了日時.
   */
  private Timestamp endDate;

//  /**
//   * 条件送信日時.
//   */
//  private Timestamp condSendDate;
}
