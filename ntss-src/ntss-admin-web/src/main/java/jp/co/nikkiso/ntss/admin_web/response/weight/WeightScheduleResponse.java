package jp.co.nikkiso.ntss.admin_web.response.weight;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * 体重計用スケジュール取得APIのResponseクラス.
 */
@AllArgsConstructor
@Data
public class WeightScheduleResponse {

  /**
   * オーダーID(内部用).
   */
  private Long ordNo;
  /**
   * 患者ID(内部用).
   */
  private Long patId;
  /**
   * 院内患者ID(内部用).
   */
  private String hospPatId;
  /**
   * 患者姓
   */
  private String patLastName;
  /**
   * 患者名
   */
  private String patFirstName;
  /**
   * 施設コード.
   */
  private String facilityCd;
  /**
   * 同姓同名.
   */
  private String isSame;

  /**
   * 治療日(yyyymmdd)
   */
  private String treatDate;
  /**
   * 治療方法コード
   */
  private Integer treatmentCd;
  /**
   * 治療方法名
   */
  private String treatmentName;
  /**
   * 装置モード
   */
  private Integer deviceMode;
  /**
   * クールコード
   */
  private Long kurCd;
  /**
   * クール名
   */
  private String kurName;
  /**
   * 治療開始予定時間
   */
  private String indTreatStartTime;
  /**
   * ベッドコード
   */
  private Long bedCd;
  /**
   * ベッド名
   */
  private String bedName;
  /**
   * 版番号
   */
  private Integer rstEdition;
  /**
   * 治療状況
   */
  private String rstDialysisState;

  /**
   * 治療開始時刻
   */
  private Timestamp rstStartDate;

  /**
   * 患者生年月日
   */
  private String patBirthday;
  // FNSI-add 入院・同姓同名配布 徐 start
  /**
   * 入外区分
   */
  private Integer inOutClass;
  // FNSI-add 入院・同姓同名配布 徐 end
  /**
   * 患者氏名(カタカナ性)
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
   * 治療方法マスタ表示順
   */
  private Long treatmentOrderIndex;
  /**
   * ベッドマスタ表示順
   */
  private Long bedOrderIndex;
}
