package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 警報注意発生記録のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_alarm_record")
@Getter
@Setter
public class MntAlarmRecord extends BaseEntity {

  /**
   * 管理番号.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long alarmNo;

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
   * 発生日時.
   */
  private Timestamp occurDate;

  /**
   * 発生区分.
   */
  private Integer occurClass;

  /**
   * モニタ項目番号.
   */
  private Integer moniNo;

  /**
   * 発生種類.
   */
  private Integer alarmClass;

  /**
   * 患者ID.
   */
  private String patId;

  /**
   * 治療番号.
   */
  private Integer ordNo;

  /**
   * 内容.
   */
  private String alarmRecordMessage;

  /**
   * 表示フラグ.
   */
  private String isDisp;

  /**
   * 削除フラグ.
   */
  private String isDel;

}
