package jp.co.nikkiso.ntss.api.model.indHistory;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.Map;

@Getter
@Setter
public class ValiDeleteIndPlanPatInfo {
  private String pat_id;
  private String facility_cd;
  private String ind_user_id;
  private String upd_user_id;
  private String treatment_cd;
  private String kur_cd;
  // 曜日パターン
  private String week_pattern;
  // 終了日格納有無
  private String is_deadline;
  // 治療方法セットコード
  private String treatment_set_cd;
  // 治療方法更新日時
  private String up_date;
  // 重複対象治療日リスト
  private String dupulicate_treat_date;
  // 指示履歴未登録フラグ
  private String is_unregistered_ind_history;
  // 削除の日時
  private List<delList> del_list;
  // 死亡、又は転出、離脱、移植、通院拒否・不明 (患者情報設定に連動して予定削除を実施する際に判定に使用)
  private Boolean is_die_flg;

  private String event_change;

  // 操作番号
  private String ope_cd;
  // 電文作成区分
  private String crud;
  // 患者番号(電子カルテ連携システム用)
  private String hosp_pat_id;
  //Ord番号
  private String ord_no;
  // 基準日
  private String base_date;
  // 操作者ID
  private String ind_user;
  // 治療日のコレクション
  private List<Map<String, String>> move_out_date;

  @Data
  public static class delList {
    public String startDate;
    public String facilitySettingExamValue;
    public String facilitySettingRadValue;
  }

}
