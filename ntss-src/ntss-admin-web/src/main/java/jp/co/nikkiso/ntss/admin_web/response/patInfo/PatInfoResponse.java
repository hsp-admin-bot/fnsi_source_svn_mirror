package jp.co.nikkiso.ntss.admin_web.response.patInfo;

import lombok.Data;

/**
 * 患者情報リスト返却用APIのResponseクラス.
 */
@Data
public class PatInfoResponse {
  /**
   * システムで管理する一意な患者ID
   */
  private Long pat_id;
  /**
   * 院内表示用の患者ID
   */
  private String hosp_pat_id;
  /**
   * 登録施設コード
   */
  private String facility_cd;
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
   * 患者氏名(英字姓)
   */
  private String pat_last_name_alpha;
  /**
   * 患者氏名(英字名)
   */
  private String pat_first_name_alpha;
}
