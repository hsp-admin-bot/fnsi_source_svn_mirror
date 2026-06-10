package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * モニタデータクラス(必要なフィールドのみ)
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MniMonitorSelected {
  /**
   * 生体モニタリング管理番号
   */
  private long bioMoniCtlNo;
  /**
   * モニタデータ
   */
  private String monitorData;
  /**
   * 発生日時
   */
  private Timestamp occurDate ; 
//  /**
//   * 型式コード
//   */
//  private String machineTypeCd;
//  /**
//   * 製造番号
//   */
//  private String machineSerial;
//  /**
//   * 一意なオーダー番号
//   */
//  private long ordNo;

}
