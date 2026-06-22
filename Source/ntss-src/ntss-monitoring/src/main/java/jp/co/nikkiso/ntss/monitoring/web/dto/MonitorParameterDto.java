package jp.co.nikkiso.ntss.monitoring.web.dto;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import jp.co.nikkiso.ntss.monitoring.util.Utilities;
import lombok.Data;

@Data
public class MonitorParameterDto {
  /**
   * 生体モニタリング管理番号
   */
  private long bioMoniCtlNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 型式コード
   */
  private String machineTypeCd;
  /**
   * 製造番号
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
   * 一意なオーダー番号
   */
  private String ordNo;
  /**
   * 発生日時
   */
  private Timestamp occurDate;
  /**
   * 取得するモニタデータのキー値
   */
  private String[] monitorKeys;

  /**
   * 指定ordNoを数値化して返す関数
   * 数値化できない場合は-1を返す
   * @return
   */
  public long getNumOrdNo() {
    long r = -1L;
    try {
      if(this.ordNo != null && Utilities.isNumber(this.ordNo.trim())){
        r = Long.parseLong(this.ordNo.trim());
      }
    } catch (Exception e) {
      r = -1;
    }
    return r;
  }

  /**
   * モニタデータの配列をListに変換して取得する
   * @return
   */
  public List<String> buildMonitorKeyParam() {
    List<String> retVal = new ArrayList<>();

    // ΔBV
    boolean has17 = false;
    // ΔBV plus
    boolean has100 = false;

    if (monitorKeys != null) {
      for (String key : monitorKeys) {
        retVal.add(key);
        if(key.equals("17")) {
          has17 = true;
        }
        if(key.equals("100")) {
          has100 = true;
        }
      }
    }
    if((has17 || has100) && (has17 != has100)) {
      // ΔBVかΔ100のどちらかだけ指定されている場合は両方の値を返す
      if(has17) {
        retVal.add("100");
      } else {
        retVal.add("17");
      }
    }

    return retVal;
  }
}
