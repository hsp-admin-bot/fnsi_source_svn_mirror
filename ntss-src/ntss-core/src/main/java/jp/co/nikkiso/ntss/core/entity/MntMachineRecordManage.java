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
 * 装置記録管理のEntity.
 */
@Entity(listener = CommonEntityListener.class, naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_machine_record_manage")
@Getter
@Setter
public class MntMachineRecordManage extends BaseBlankEntity {
  /**
   * 装置記録管理番号.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long machineRecordManageNo;

  /**
   * イベント発生日時.
   */
  private Timestamp eventRegDate;

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
   * 装置記録コード.
   */
  private String machineRecordCd;

  /**
   * 装置記録メッセージ.
   */
  private String machineRecordMessage;

  /**
   * 装置記録補助データ.
   */
  private String machineRecordAuxData;

  /**
   * 備考.
   */
  private String remarks;

  /**
   * 登録日時.
   */
  private Timestamp regDate;

  /**
   * 更新日時.
   */
  private Timestamp upDate;

}
