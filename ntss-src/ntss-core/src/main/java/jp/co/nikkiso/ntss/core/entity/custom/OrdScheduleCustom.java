package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * ord_schedule(治療スケジュール)のカスタムエンティティクラス.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdScheduleCustom {
  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * オーダ番号
   */
  private Long ordNo;

  /**
   * 治療日
   */
  private String treatDate;

  /**
   * クールコード
   */
  private Long kurCd;

  /**
   * クール名称
   */
  private String kurName;

  /**
   * ベッドコード
   */
  private Long bedCd;

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * 治療曜日
   */
  private Short treatWeek;

}
