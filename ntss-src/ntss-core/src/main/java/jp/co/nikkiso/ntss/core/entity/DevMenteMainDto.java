package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
public class DevMenteMainDto {

  private String bedName;
  private String machineName;
  private Long machineNo;
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
  private String machineType;
  private String machineTypeCd;

}
