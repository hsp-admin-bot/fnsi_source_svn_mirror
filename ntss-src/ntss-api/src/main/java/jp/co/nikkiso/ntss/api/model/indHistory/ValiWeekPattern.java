package jp.co.nikkiso.ntss.api.model.indHistory;


import lombok.Getter;
import lombok.Setter;

/**
 * 曜日パターン変更
 */
@Getter
@Setter
public class ValiWeekPattern {
  /**
   * 患者ID
   */
  private String pat_id;
  /**
   * 施設コード
   */
  private String facility_cd;
  /**
   * 指示:治療方法
   */
  private String ind_treatment_cd;
  /**
   * 指示者コード
   */
  private String ind_user;
  /**
   * 更新者コード
   */
  private String upd_user;
  /**
   * 適用開始日
   */
  private String ind_treat_start_date;
  /**
   * 曜日パターン情報
   */
  private String week_pattern_info;
  /**
   * 移動対象曜日リスト
   */
  private String move_target_week_list;
  /**
   * 更新日時
   */
  private String up_date;
  /**
   * 終了日
   */
  private String end_date;
  // add 投与間隔月１のものが月を跨いだ場合、メッセージを出す。 李 start
  /**
   * 更新フラグ
   */
  private boolean update_flg;
  // add 投与間隔月１のものが月を跨いだ場合、メッセージを出す。 李 end
  // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
  /**
   * footer
   */
  private String footer_flg;
  private String hosp_pat_id;
  private Boolean cover;
  private Boolean skip;
  private String facilitySettingExamValue;
  private String facilitySettingRadValue;
  private String facilitySettingEventValue;
  private Boolean is_deadline;
}
