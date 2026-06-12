package jp.co.nikkiso.ntss.core.entity;

import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.SequenceGenerator;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;


import java.sql.Timestamp;
import java.util.Objects;

/**
 * モニタデータクラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mni_monitor")
@Getter
@Setter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class MniMonitor extends BaseEntity {
  /**
   * 生体モニタリング管理番号
   */
  @Id
//  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @GeneratedValue(strategy = GenerationType.SEQUENCE)
  @SequenceGenerator(sequence = "mni_monitor_bio_moni_ctl_no_seq")
  private Long bioMoniCtlNo;
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
    // mod FNSI-8577 LJX start
    //return machineSerial.trim();
    if (machineSerial != null) {
      return machineSerial.trim();
    }
    return machineSerial;
    // mod FNSI-8577 LJX end
  }

  public void setMachineSerial(String machineSerial) {
    // mod FNSI-8577 LJX start
    //this.machineSerial = machineSerial.trim();
    if (machineSerial != null) {
      this.machineSerial = machineSerial.trim();
    }
    // mod FNSI-8577 LJX end
  }
  //スペースを削除する 6901 end

  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ordNo;
  /**
   * システムで管理する一意な患者ID
   */
  private Long patId;
  /**
   * データ種別
   */
  private Short dataType;
  /**
   * モニタデータ
   */
  private String monitorData;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 発生日時
   */
  private Timestamp occurDate;
  /**
   * 更新者ID<br>
   * 装置から受信した時は{@code null}とする.
   * 治療記録のモニタ、バイタルで新規登録、登録済のデータに対する修正を行った場合にサインイン者の内部利用者IDを格納する.
   */
  private Long updStaffId;

  // #10344 Add for use List.contains to find the records which has been modified
  @Override
  public boolean equals(Object o){
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    MniMonitor monitor = (MniMonitor) o;

    return Objects.equals(this.bioMoniCtlNo, monitor.getBioMoniCtlNo())
      && Objects.equals(this.facilityCd, monitor.getFacilityCd())
      && Objects.equals(this.machineTypeCd, monitor.getMachineTypeCd())
      && Objects.equals(this.getMachineSerial(), monitor.getMachineSerial())
      && Objects.equals(this.ordNo, monitor.getOrdNo())
      && Objects.equals(this.patId, monitor.getPatId())
      && Objects.equals(this.dataType, monitor.getDataType())
      && Objects.equals(this.isDel, monitor.getIsDel())
      && Objects.equals(this.occurDate, monitor.getOccurDate())
      && Objects.equals(this.updStaffId, monitor.getUpdStaffId())
      && Objects.equals(this.monitorData, monitor.getMonitorData());
  }
}
