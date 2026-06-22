package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 装置マスタのEntity.
 */
@Entity(naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_water_survey")
@Getter
@Setter
public class MstMachineDatalist extends BaseBlankEntity {

  /**
   * 水質検査箇所コード
   */
  private String survey_point_cd;

  /**
   * 検査日
   */
  private String inspection_date;

  /**
   * しきい値判断上下区分
   */
  private String initial_string;

  /**
   * 採取時刻
   */
  private String time;

  /**
   * 結果
   */
  private String value;

  /**
   * 採取者
   */
  private Integer picker;

  /**
   * 検査者
   */
  private String inspector;

  /**
   * 結果
   */
  private String text;

  /**
   * 結果
   */
  private String unit;
}
