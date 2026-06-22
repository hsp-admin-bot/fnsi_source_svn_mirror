package jp.co.nikkiso.ntss.admin_web.response.scheduleAssignment;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Data;

/**
 * チェックリスト用スケジュール取得APIのResponseクラス.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Data
public class ScheduleAssignmentResponse {

  /**
   * オーダー番号(内部用).
   */
  private Long ordNo;
  /**
   * 患者ID(内部用).
   */
  private Long patId;
  /**
   * 患者ID(院内表示用).
   */
  private String hospPatId;
  /**
   * 患者名
   */
  private String patName;
  /**
   * 施設コード.
   */
  private String facilityCd;
  /**
   * 治療日(yyyymmdd)
   */
  private String treatDate;
  /**
   * 治療曜日(1：月曜日 ～ 7：日曜日)
   */
  private Short treatWeek;
  /**
   * クールコード
   */
  private Long kurCd;
  /**
   * クール名
   */
  private String kurName;
  /**
   * ベッドコード
   */
  private Long bedCd;
  /**
   * ベッド名
   */
  private String bedName;
  /**
   * 治療状況
   */
  private String rstDialysisState;
  /**
   * 治療開始日時
   */
  private Timestamp rstStartDate;
  /**
   * 治療終了日時
   */
  private Timestamp rstEndDate;
  /**
   * 患者氏名(姓)
   */
  private String patLastName;
  /**
   * 患者氏名(名)
   */
  private String patFirstName;
  /**
   * 患者氏名(カタカナ姓)
   */
  private String patLastNameKana;
  /**
   * 患者氏名(カタカナ名)
   */
  private String patFirstNameKana;
  /**
   * クール開始時刻
   */
  private String kurStartTime;
  /**
   * ベッドマスタ表示順
   */
  private Long bedOrderIndex;
}
