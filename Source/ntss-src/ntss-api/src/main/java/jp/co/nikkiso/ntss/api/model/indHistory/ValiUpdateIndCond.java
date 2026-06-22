package jp.co.nikkiso.ntss.api.model.indHistory;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class ValiUpdateIndCond {
  /**
   * 抽出データ（処理対象施設の施設コード）
   */
  protected String facility_cd;
  /**
   * 抽出データ（処理対象患者の患者ID）
   */
  protected String pat_id;
  /**
   * 抽出データ（処理対象治療予定の開始日）
   */
  protected String ind_start_date;
  /**
   * 抽出データ（処理対象治療予定の終了日）
   */
  protected String ind_end_date;
  /**
   * 抽出データ（処理対象治療予定の曜日パターン）
   */
  protected String week_pattern;
  /**
   * 抽出データ（処理対象治療予定の指示：クールコード）
   */
  protected String ind_kur_cd;
  /**
   * 抽出データ（処理対象治療予定の指示：ベッドコード）
   */
  private String ind_bed_cd;
  /**
   * 抽出データ（処理対象治療予定の指示：治療方法コード）
   */
  protected String ind_treatment_cd;
  /**
   * 終了日存在フラグ
   */
  private String is_deadline;
  /**
   * スキップ更新フラグ
   */
  private String is_skip_update;
  /**
   * 登録時検査区分
   */
  private List<String> reg_order_class;
  /**
   * タイトル
   */
  protected String header_title;
  protected String hosp_pat_id;
  protected String user_id;

  /**
   * 編集データ（指示：クールコード）
   */
  private String ind_cond_info;

  /**
   * 更新対象治療状況
   */
  private String target_dialysis_state;

  /**
   * 条件送信用データ
   */
  private String send_condition_info;

  /**
   * OK/Cancel
   */
  private String answer_Flg;
  /**
   * 抗凝固剤数量のbefore
   */
  private String quantity_before;
  /**
   * 抗凝固剤数量のafter
   */
  private String quantity_after;
  /**
   * 表示計算項目コード
   */
  private String accountItem_Cd;
  /**
   * チェックボックス
   */
  private String checkBox_Flg;
  /**
   * 実績更新フラグ
   */
  private String is_rst_update;
  /**
   * 2 : 一括編集
   */
  private String update_flag;
  /**
   * 装置の種類 noIv、onLine、offLine
   */
  private String ind_treat_cond_iv_mode;

}
