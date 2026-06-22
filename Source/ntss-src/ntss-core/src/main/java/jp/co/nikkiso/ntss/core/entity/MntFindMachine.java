package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;


/**
 * 検出した装置のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_find_machine")
@Getter
@Setter
public class MntFindMachine extends BaseEntity {

  /**
   * 施設コード.
   */
  @Id
  private String facilityCd;

  /**
   * 通信フォーマット.
   */
  @Id
  private String comFormatCd;
  /**
   * 製造番号.
   */
  @Id
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
   * 通信種別.
   */
  @Id
  private Integer comType;

  /**
   * IPアドレス.
   */
  @Id
  private String ipAddress;

  /**
   * デバイスエッジ番号.
   */
  private Integer deviceEdgeNo;
}


