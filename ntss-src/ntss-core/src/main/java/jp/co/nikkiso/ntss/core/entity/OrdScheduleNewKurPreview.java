package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;


/**
 * ord_schedule(治療スケジュール)のエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_schedule")
@Getter
@Setter
public class OrdScheduleNewKurPreview extends BaseBlankEntity {

  /**
   * key番号(ord_main: ord_no, pat_treatment_pattern: ctl_no)
   */
  private Long keyNo;

  /**
   * 治療日
   */
  private String treatDate;

  /**
   * クールコード
   */
  private Long kurCd;

  /**
   * ベッドコード
   */
  private Long bedCd;

  /**
   * ベッドコード
   */
  private Integer indTreatmentCd;

  /**
   * 患者ID
   */
  private Long patId;
  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * ダミーフラグ
   */
  private String dummy;

  /**
   * 治療曜日
   */
  private Short treatWeek;
}
