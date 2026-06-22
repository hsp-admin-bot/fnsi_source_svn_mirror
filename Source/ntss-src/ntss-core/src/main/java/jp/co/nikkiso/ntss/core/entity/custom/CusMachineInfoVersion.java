package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 検査のための機械情報Entity
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE, immutable = true)
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class CusMachineInfoVersion {
  /**
   * 機械番号
   */
	private Long machineNo;
  /**
   * マシンタイプコード
   */
	private String machineTypeCd;
  /**
   * マシンタイプ
   */
	private String machineType;
  /**
   * マシン名
   */
	private String machineName;
  /**
   * 機械シリアル
   */
	private String machineSerial;
  /**
   * バージョン
   */
	private String version;
  /**
   * ベッド名
   */
	private String bedName;
}
