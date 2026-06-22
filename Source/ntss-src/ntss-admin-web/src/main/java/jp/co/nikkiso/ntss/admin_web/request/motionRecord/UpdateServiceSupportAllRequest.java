package jp.co.nikkiso.ntss.admin_web.request.motionRecord;

import lombok.Data;

/**
 * 全サービス対応区分更新APIのRequestクラス.
 */
@Data
public class UpdateServiceSupportAllRequest {

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
   * サービス対応区分
   */
  private String serviceSupportType;

  // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 start
  /**
   * データ種別.
   */
  private String dataType;
  // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 end

}
