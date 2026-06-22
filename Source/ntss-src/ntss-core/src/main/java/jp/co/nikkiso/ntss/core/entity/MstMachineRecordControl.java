package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置記録マスタのEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_machine_record_control")
@Getter
@Setter
public class MstMachineRecordControl extends BaseBlankEntity {
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 装置記録コード.<br>
   * 日機装装置：0000～FFFF、死活監視用：G000～GZZZ
   */
  private String machineRecordCd;

  /**
   * 装置記録メッセージ.
   */
  private String machineRecordMessage;

  /**
   * 表示フラグ.
   */
  private String dispFlg;

//  del 装置記録マスタ 装置フラグを削除，警報フラグを削除 start
  /**
   * 装置フラグ.
   */
//  private String machineFlg;

  /**
   * 警報フラグ.
   */
//  private String alarmFlg;
//  del 装置記録マスタ 装置フラグを削除，警報フラグを削除 end4

  /**
   * 登録日時.
   */
  private Timestamp regDate;

  /**
   * 更新日時.
   */
  private Timestamp upDate;

}
