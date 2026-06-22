package jp.co.nikkiso.ntss.device_edge.request.hostNotify;

import lombok.Data;

@Data
public class AlarmNotifyRequest {
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
   * 発生日時[yyyymmddHHMMss形式文字列]
   */
  private String occurDate;

  /**
   * 通知情報 固定長文字列 モニタ番号[3桁]:通知状態[16進2桁]モニタ番号[3桁]:通知状態[16進2桁]...
   * ※通知状態は 0x01：下限通知、0x02：上限通知 の組み合わせ
   */
  private String content;
}
