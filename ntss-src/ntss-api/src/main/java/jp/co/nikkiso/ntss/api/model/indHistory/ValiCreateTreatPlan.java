package jp.co.nikkiso.ntss.api.model.indHistory;

import lombok.Getter;
import lombok.Setter;

import java.math.BigInteger;

@Getter
@Setter
public class ValiCreateTreatPlan {
  private String treatment_set_cd;
  private String up_date;
  private String pat_id;
  private String start_date;
  private String end_date;
  private String facility_cd;
  private String treatDays;
  // 指示者ID
  private BigInteger ind_user_id;
  // 更新者ID
  private BigInteger upd_user_id;
  // 治療方法セットフラグ0->治療方法のみ、1->治療方法セット
  private String treat_method_flag;
  // 終了日格納有無
  private String is_deadline;
  // 曜日パターン
  private String week_pattern;
  // 治療方法コード
  private String ind_treatment_cd;
  // クールコード
  private String ind_kur_cd;
  // 治療種別
  private String treat_type;
  // 更新フラグ
  private String is_update;
  // 更新対象曜日パターン
  private String update_week_pattern;
  // 患者治療パターン更新対象曜日
  private String pat_pattern_week;
  // 更新モードフラグ
  private String update_mode;
  /**
   * 治療方法名
   */
  private String treatment_name;
  /**
   * スキップ更新フラグ
   */
  private String is_skip_update;
  /**
   * 指示履歴未登録フラグ
   */
  private String is_unregistered_history;
  // add 373,374修正対応 陳 start
  /**
   * 治療開始時刻
   */
  private String ind_treat_start_time;
  /**
   * ベッドコード
   */
  private String ind_bed_cd;
  /**
   * タイトル
   */
  protected String hosp_pat_id;
  protected String user_id;
  private String invoke_page_name;
  private String nextFlag;
  private Integer device_mode;
  private String startsFlg;
  private String rst_flag;
  /**
   * 2 : 一括編集
   */
  private String update_flag;
  /**
   * 操作画面特定用文字列
   */
  private String screan_string;
}
