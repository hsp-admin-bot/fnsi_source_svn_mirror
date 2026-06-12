package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 未割付治療予定一覧取得エンティティ
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainForNotAssignedSchedule {

  /**
   * オーダーID(内部用).
   */
  private Long ordNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 患者ID(内部用).
   */
  private Long patId;
  //#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない Start
   /**
   * 同姓同名区分
   */
  private int issame;
  /**
   * 患者ID
   */
  private String hospPatId;
   /**
   * 入外区分
   */
  private int inOutClass;
  //#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない End
  /**
   * 患者名
   */
  private String patName;
  /**
   * 治療日(yyyymmdd)
   */
  private String treatDate;
  /**
   * 治療曜日(1：月曜日 ～ 7：日曜日)
   */
  private Short treatWeek;
  /**
   * 指示：クールコード
   */
  private Long indKurCd;
  /**
   * 指示：クール名
   */
  private String indKurName;

  /**
   * 指示：治療方法コード
   */
  private String indTreatmentCd;

  /**
   * 指示：治療方法名
   */
  private String indTreatmentName;

}
