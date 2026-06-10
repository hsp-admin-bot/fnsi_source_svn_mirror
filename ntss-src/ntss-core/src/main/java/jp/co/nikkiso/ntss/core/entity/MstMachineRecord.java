package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 装置記録マスタのEntity.
 */
@Entity(naming=NamingType.SNAKE_LOWER_CASE, immutable = true)
@Table(name = "mst_machine_record")
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class MstMachineRecord extends BaseBlankEntity {

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
   * 推奨項目
   */
  private String isDefault;

  /**
   * ログ分類
   */
  private String logClass;

  /**
   * 対象機種
   */
  private String targetModel;

  /**
   * 登録日時.
   */
  private Timestamp regDate;

  /**
   * 更新日時.
   */
  private Timestamp upDate;

  //add bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- start
  /**
   * 表示フラグ.
   */
  private String dispFlg;
 //add bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- start
}
