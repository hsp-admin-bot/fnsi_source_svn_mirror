package jp.co.nikkiso.ntss.device_edge.request.hostNotify;

import lombok.Data;

@Data
public class MedicineNotifyRequest {
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * デバイスエッジ番号
   */
  private Integer deviceEdgeNo;

  /**
   * 型式コード.
   */
  private String machineTypeCd;

  /**
   * 通信フォーマット
   */
  private String comFormatCd;

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
   * オーダー番号
   */
  private Long ordNo;

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * 発生日時[yyyymmddHHMMss形式文字列]
   */
  private String occurDate;

  /**
   * 通知情報 薬剤名称
   */
  private String medicineName;
}
