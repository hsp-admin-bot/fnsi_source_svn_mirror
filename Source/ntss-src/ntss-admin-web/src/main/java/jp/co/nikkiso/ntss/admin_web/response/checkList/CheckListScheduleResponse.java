package jp.co.nikkiso.ntss.admin_web.response.checkList;

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
   * 施設コード.
   */
  private String facilityCd;
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
   * 患者名：姓
   */
  private String patLastName;
  /**
   * 患者名：名
   */
  private String patFirstName;
  // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
  /**
   * 患者ID(院内表示用).
   */
  private String hospPatId;
  // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
  // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
  /**
   * 患者名（仮名）
   */
  private String patNameKana;
  /**
   * 患者名：姓（仮名）
   */
  private String patLastNameKana;
  /**
   * 患者名：名（仮名）
   */
  private String patFirstNameKana;
  // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
  /**
   * 同姓同名
   */
  private String isSame;
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

  /**
   * 装置エントリー状態[0：エントリー外/1：次患者/2：現患者]
   */
  private Integer machineEntry;
  /**
   * 入外区分
   */
  private Integer inOutClass;
  /**
   * クール開始時刻
   */
  private String kurStartTime;  
  /**
   * ベッドマスタ表示順
   */
  private Long bedOrderIndex;  

}
