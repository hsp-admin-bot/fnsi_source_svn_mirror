package jp.co.nikkiso.ntss.device_edge.response.checkList;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Data;

/**
 * チェックリスト用スケジュール取得APIのResponseクラス.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Data
public class CheckListScheduleResponse {

  /**
   * オーダー番号(内部用).
   */
  private Long ordNo;
  /**
   * 患者ID(内部用).
   */
  private Long patId;
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
   * 指示：投与薬剤情報
   */
  private String indMediInfo;
  /**
   * 指示：治療条件情報
   */
  private String indCondInfo;
  /**
   * 指示：医療材料情報
   */
  private String indEquipInfo;
  /**
   * 実績：投与薬剤情報
   */
  private String rstMediInfo;
  /**
   * 実績：治療条件情報
   */
  private String rstCondInfo;
  /**
   * 実績：医療材料情報
   */
  private String rstEquipInfo;
  /**
   * 装置モード
   */
  private Integer deviceMode;
}
