package jp.co.nikkiso.ntss.data_gathering.entity;

import java.sql.Timestamp;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置マスタEntity
 *
 */
@Entity
@Getter
@Setter
public class MstMachine {

  @Id
  @Column(name = "machine_type_cd")
  private String machineTypeCd;

  @Id
  @Column(name = "machine_serial")
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
  @Id
  @Column(name = "facility_cd")
  private String facilityCd;

  @Column(name = "ip_address")
  private Object ipAddress;

  @Column(name = "port")
  private String port;

  @Column(name = "com_format_cd")
  private String comFormatCd;

  @Column(name = "device_edge_no")
  private int deviceEdgeNo;

  @Column(name = "is_ftp")
  private String isFtp;

  @Column(name = "reg_date")
  private Timestamp regDate;

  @Column(name = "up_date")
  private Timestamp upDate;
}
