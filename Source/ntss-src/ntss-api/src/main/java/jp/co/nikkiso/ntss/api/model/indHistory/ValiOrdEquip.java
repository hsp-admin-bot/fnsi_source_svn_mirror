package jp.co.nikkiso.ntss.api.model.indHistory;

import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
public class ValiOrdEquip {
  private String ord_no;
  private String dialysis_date_to;
  private String ind_schedule_user_info;
  private String pat_id;
  private String treat_date;
  private String ind_treatment_cd;
  private String ind_kur_cd;
  private String start_date;
  private String end_date;
  private String ind_user;
  private String weeks;
  private String ind_info;
  private String ind_dates;
  private String facility_cd;
  // 穴埋め
  private String auto_insert;
  // 編集対象
  private String target_equip_edit;
  private String is_deadline;
  private String is_edit_other_amount;
  // 編集対象医療材料の区分
  private String target_equip_edit_type;
  private String is_rst_update;
  /**
   * タイトル
   */
  protected String hosp_pat_id;
  protected String user_id;
  /**
   * 2 : 一括編集
   */
  private String update_flag;
}
