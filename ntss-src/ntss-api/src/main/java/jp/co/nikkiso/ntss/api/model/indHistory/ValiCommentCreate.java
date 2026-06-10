package jp.co.nikkiso.ntss.api.model.indHistory;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * 指示コメント用クラス
 */
@Getter
@Setter
public class ValiCommentCreate {
  /**
   * 指示コメントフラグ("1"->新規登録、"2"->編集、"3"->中止)
   */
  private String comment_flag;

  /**
   * オーダー番号
   */
  private String ord_no;

  /**
   * 患者ID
   */
  private String pat_id;

  /**
   * 施設コード
   */
  private String facility_cd;

  /**
   * 開始日
   */
  private String start_date;

  /**
   * 終了日
   */
  private String end_date;

  /**
   * 指示コメント番号
   */
  private String num_comment;

  /**
   * 指示コメント内容
   */
  private String comment;

  /**
   * 指示コメント内容(変更前)
   */
  private String init_comment;

  /**
   * 曜日
   */
  private String weeks;

  /**
   * 指示者コード
   */
  private String ind_user_id;

  /**
   * 更新者コード
   */
  private String upd_user_id;

  /**
   * 治療方法コード
   */
  private String ind_treatment_cd;

  /**
   * クールコード
   */
  private String ind_kur_cd;

  /**
   * 終了日有無
   */
  private String is_deadline;

  /**
   * 登録区分
   */
  private Integer input_class;

  /**
   * 編集可否
   */
  private String is_editable;

  /**
   * 指示者名_姓
   */
  private String ind_user_last_name;

  /**
   * 指示者名_名
   */
  private String ind_user_first_name;

  /**
   * 更新者名_姓
   */
  private String upd_user_last_name;

  /**
   * 更新者名_名
   */
  private String upd_user_first_name;

  /**
   * 実績更新フラグ
   */
  private String is_rst_update;

  /**
   * 発生元区分(1:患者経過総合ビューア)
   */
  private String genDifferentiation;

  /**
   * 治療方法コードのリスト
   */
  private List<String> treatmentCdList;
  /**
   * タイトル
   */
  protected String hosp_pat_id;
  protected String user_id;

  //指示コメントの更新は共用するため、回診記録から指示コメントへ転記する場合、フラグを追加、実績のみに更新
  /**
   * 指示・実績更新フラグ
   */
  private String ind_rst_flag;

  /**
   * 2 : 一括編集
   */
  private String update_flag;

}
