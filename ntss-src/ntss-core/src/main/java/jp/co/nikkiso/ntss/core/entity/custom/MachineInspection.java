package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 日常点検・定期点検用の装置リスト取得用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MachineInspection {
  /**
   * 装置マスタ.装置番号
   */
	private Long machineNo;
  /**
   * 装置マスタ.装置名
   */
	private String machineName;
  /**
   * 型式マスタ.型式コード
   */
	private String machineTypeCd;
  /**
   * 型式マスタ.型式
   */
	private String machineType;
  /**
   * ベッドマスタ.ベッド名
   */
	private String bedName;
  /**
   * 装置マスタ.製造番号
   */
	private String machineSerial;
  /**
   * 型式マスタ.機種
   */
	private String model;

  /**
   * 装置マスタ表示順
   */
  private Long machineOrderIndex;
  /**
   * ベッドマスタ表示順
   */
  private Long bedOrderIndex;
}
