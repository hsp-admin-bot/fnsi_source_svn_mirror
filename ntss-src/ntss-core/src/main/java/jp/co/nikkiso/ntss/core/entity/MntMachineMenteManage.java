package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置メンテナンス管理のEntity.
 */
@Entity(listener = CommonEntityListener.class, naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_machine_mente_manage")
@Getter
@Setter
public class MntMachineMenteManage extends BaseBlankEntity {
  /**
   * 装置メンテナンス管理番号.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long machineMenteManageNo;

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
   * 通信フォーマット.
   */
  private String comFormatCd;

  /**
   * 測定日時.
   */
  private Timestamp measureDate;

  /**
   * 自己診断種別.
   */
  private Integer selfDiagKind;

  /**
   * メンテナンスデータ.
   */
  private String menteData;

  /**
   * 登録日時.
   */
  private Timestamp regDate;

  /**
   * 更新日時.
   */
  private Timestamp upDate;

}
