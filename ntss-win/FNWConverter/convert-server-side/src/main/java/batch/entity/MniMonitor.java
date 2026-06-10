package batch.entity;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 * モニタデータクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mni_monitor")
@Getter
@Setter
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class MniMonitor extends BaseEntity {
  /**
   * 生体モニタリング管理番号
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
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

  public String getMachineSerial() {
    return machineSerial.trim();
  }

  public void setMachineSerial(String machineSerial) {
    this.machineSerial = machineSerial;
  }

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
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;

  /**
   * 更新者ID<br>
   * 装置から受信した時は{@code null}とする.
   * 治療記録のモニタ、バイタルで新規登録、登録済のデータに対する修正を行った場合にサインイン者の内部利用者IDを格納する.
   */
  private Long updStaffId;


  @Override
  public String toString() {
    StringBuffer sb = new StringBuffer();
    sb.append(facilityCd).append(",")
            .append(machineTypeCd == null ? "" : machineTypeCd).append(",")
            .append(machineSerial == null ? "" : machineSerial).append(",")
            .append(ordNo == null ? "" : ordNo).append(",")
            .append(patId == null ? "" : patId).append(",")
            .append(dataType == null ? "" : dataType).append(",")
            .append(monitorData == null ? "" : monitorData).append(",")
            .append(isDel == null ? "" : isDel).append(",")
            .append(occurDate == null ? "" : occurDate).append(",")
            .append(regDate == null ? "" : regDate).append(",")
            .append(upDate == null ? "" : upDate).append(",")
            .append(updStaffId == null ? "" : updStaffId);
    return sb.toString();
  }

}
