package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;


/**
 * mst_bed(ベッドマスタ)+mst_machine(装置マスタ)一覧取得用エンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class BedMachine {
  /**
   * ベッドコード
   */
  private Long bedCd;

  // del #10280 ベッドマスタに不要なカラムが存在する dengshen start
  // /**
  //  * ベッド番号
  //  */
  // private Integer bedNo;
  // del #10280 ベッドマスタに不要なカラムが存在する dengshen end

  /**
   * ベッド名
   */
  private String bedName;


  /**
   * 装置番号
   */
  private Integer machineNo;

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
   * 装置名.
   */
  private String machineName;


  /**
   * 型式.
   */
  private String machineType;

  /**
   * 機種.
   */
  private String model;
}
