package jp.co.nikkiso.ntss.api.model.indHistory;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class ValiOrdMedi {

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
  private String date_interval;
  private String count_before;
  private String count_after;
  private String init_date;
  private String is_deadline;
  private String is_edit_other_amount;
  private String is_rst_update;
  private List<String> treat_dates;
  private List<String> treat_date_list_all;
  private Boolean interval_flg;
  /**
   * タイトル
   */
  protected String hosp_pat_id;
  protected String user_id;
  /**
   * 2 : 一括編集
   */
  private String update_flag;

  //add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
  /**
   * 変更画面終了日或いは回数を選択する(true：回数、false：終了日)
   */
  private Boolean number_of_doses;
  //add 11555 指示履歴への記録の残り方が仕様と異なる zkm end

}
