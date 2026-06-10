package jp.co.nikkiso.ntss.core.entity;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * モニタデータクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class MniMonitorCalendr extends BaseEntity {
  /**
   * 生体モニタリング管理番号
   */
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

  private Date TreatDate;
}
