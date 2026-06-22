package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;


/**
 * 装置マスタのEntity.
 */
@Entity(naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_machine")
@Getter
@Setter
public class MstMachineDatalistInit extends BaseBlankEntity {

  /**
   * 型式コード.
   */
  private String machine_type_cd;

  /**
   * 製造番号.
   */
  private String machine_serial;

  /**
   * 装置名.
   */
  private String machine_name;

  /**
   * 装置番号
   */
  private Long machine_no;

  /**
   * 型式
   */
  private String machine_type;

  /**
   * ベッド名
   */
  private String bed_name;

  /**
   * 設置日
   */
  private Timestamp setting_date;

  /**
   * 水質検査箇所名
   */
  private String point_name;

  /**
   * 水質検査箇所コード
   */
  private String survey_point_cd;

  /**
   * 水質検査種別名
   */
  private String survey_type_name;

}


