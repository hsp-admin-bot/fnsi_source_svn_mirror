package jp.co.nikkiso.ntss.admin_web.response.patInfo;

import lombok.Data;

/**
 * 患者情報リスト返却用APIのResponseクラス.
 */
@Data
public class PatByFCAndPIdsResponse {

  /**
   * システムで管理する一意な患者ID
   */
  private Long pat_id;
  /**
   * 院内表示用の患者ID
   */
  private String hosp_pat_id;
  /**
   * 患者氏名(漢字姓)
   */
  private String pat_last_name;
  /**
   * 患者氏名(漢字名)
   */
  private String pat_first_name;
  /**
   * 患者氏名(カタカナ姓)
   */
  private String pat_last_name_kana;
  /**
   * 患者氏名(カタカナ名)
   */
  private String pat_first_name_kana;

  /**
   * 入外区分
   */
  private Integer in_out_class;

  /**
   * 同姓同名
   */
  private String is_same;
}
