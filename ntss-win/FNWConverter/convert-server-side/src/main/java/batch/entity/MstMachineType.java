package batch.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 型式マスタのEntity.
 */
@Entity(naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_machine_type")
@Getter
@Setter
public class MstMachineType extends BaseBlankEntity {

  /**
   * 型式コード.
   */
  private String machineTypeCd;

  /**
   * 型式.
   */
  private String machineType;

  /**
   * 機種.<br>
   * <li>001：RO
   * <li>002：供給装置
   * <li>003：溶解装置
   * <li>004：個人用透析装置
   * <li>005：透析装置
   */
  private String model;

  /**
   * メーカー.
   */
  private String maker;

  /**
   * 登録日時.
   */
  private Timestamp regDate;

  /**
   * 更新日時.
   */
  private Timestamp upDate;

  /**
   * 通信種別.
   */
  private String comType;

  /**
   * 装置モード.
   */
  private String treatMode;

}
