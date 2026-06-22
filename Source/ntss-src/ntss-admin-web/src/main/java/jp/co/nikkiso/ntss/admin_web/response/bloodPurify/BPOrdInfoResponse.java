package jp.co.nikkiso.ntss.admin_web.response.bloodPurify;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 浄化装置通信アプリ用の透析情報.
 */
@AllArgsConstructor
@Getter
public class BPOrdInfoResponse {
  /**
   * オーダー番号(bigserial).
   */
  private Long ordNo;

  /**
   * ベッド名(character varying).
   */
  private String bedName;

  /**
   * 同姓同名かどうか(character varying "0" or "1").
   */
  private Boolean isSame;

  /**
   * 氏名(character varying).
   */
  private String patName;

  /**
   * 入外区分(smallint).
   */
  private Integer inOutClass;

  /**
   * 治療状況(character varying).
   */
  private String dialysisState;

  /**
   * クール名(character varying).
   */
  private String kurName;

  /**
   * クール開始時刻(character varying).
   */
  private String kurStartTime;

  /**
   * クール終了時刻(character varying).
   */
  private String kurEndTime;

  // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
  /**
   * 院内表示用の患者ID(character varying).
   */
  private String hosp_pat_id;

  /**
   * 治療方法名(character varying).
   */
  private String rst_treatment_name;
  // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end
}
