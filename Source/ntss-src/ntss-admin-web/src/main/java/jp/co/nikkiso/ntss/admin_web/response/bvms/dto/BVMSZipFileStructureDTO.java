package jp.co.nikkiso.ntss.admin_web.response.bvms.dto;

import lombok.Data;

@Data
public class BVMSZipFileStructureDTO {
    // データ収集管理番号[可変長]
    private String managementNumber;

    // 型式コード[3桁]
    private String machineTypeCd;
    // 通信フォーマット
    private String comFormatCd;
    // 製造番号
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
    //
    private String treatDate;

    private String startTime;

    private String endTime;
}
