package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 *
 * @author ntss
 *
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class TreatmentStatusListAlarmRecord {

  /**
   * 発生日
   */
  private String eventRegDate;

  /**
   * 履歴タイプ
   */
  private String logType;

  /**
   * ベッド名.
   */
  private String bedName;

  /**
   * 患者名.
   */
  private Long patId;

  /**
   * メッセージ
   */
  private String machineRecordMessage;

  /**
   * 装置記録コード
   */
  private String machineRecordCd;

  // add FNSI-警報・報知追加 付 start
  /**
   * 型式コード
   */
  private String machineTypeCd;
  /**
   * ord_no
   */
  private Long ordNo;

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
  // add FNSI-警報・報知追加 付 end
}
