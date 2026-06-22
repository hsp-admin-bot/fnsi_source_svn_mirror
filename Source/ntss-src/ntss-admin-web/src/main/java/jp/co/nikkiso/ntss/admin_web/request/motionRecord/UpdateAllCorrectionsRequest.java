package jp.co.nikkiso.ntss.admin_web.request.motionRecord;

import lombok.Data;

/**
 * 全対象データ対処者更新APIのRequestクラス.
 */
@Data
public class UpdateAllCorrectionsRequest {

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
   * ユーザID.
   */
  private Long userId;

  /**
   * データ種別.
   */
  private String dataType;

}
