package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 掲示板登録情報クラス
 */
//FNSI-修正 ログ対応 xiebzh add start
@Entity(listener = CommonEntityListener.class, naming = NamingType.NONE)
//FNSI-修正 ログ対応 xiebzh add end
@Table(name = "bbs_info")
@Getter
@Setter
public class BbsInfo extends BaseBlankEntity {
  /**
   * 掲示板番号
   */
  @Id
  private Long bbs_ctl_no;

  /**
   * 施設コード
   */
  private String facility_cd;

  /**
   * 対象患者
   */
  private String pat_info;

  /**
   * 対象スタッフ
   */
  private String staff_info;

  /**
   * 機能コード
   */
  private String func_cd;

  /**
   * 種別番号
   */
  private Long kind_no;

  /**
   * 管理番号
   */
  private Long fn_seq_id;

  /**
   * タイトル
   */
  private String title;

  /**
   * 内容
   */
  private String content;

  /**
   * ファイル情報
   */
  private String file_info;
// mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
//  /**
//   * 掲載開始日時
//   */
//  private Timestamp notice_start_date;
//
//  /**
//   * 掲載終了日時
//   */
//  private Timestamp notice_end_date;

  /**
   * 掲載開始日時
   */
  private String notice_start_date;


  /**
   * 掲載終了日時
   */
  private String notice_end_date;
  // mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end

  /**
   * 起票者ID
   */
  private Long reg_staff_id;

  /**
   * 起票名
   */
  private String reg_staff_name;

  /**
   * 最終更新者ID
   */
  private Long upd_staff_id;

  /**
   * 最終更新者名
   */
  private String upd_staff_name;

  /**
   * 遷移先機能パス
   */
  private String transition_router_path;

  /**
   * 登録日時
   */
  private Timestamp reg_date;

  /**
   * 更新日時
   */
  private Timestamp up_date;

  /**
   * 表示フラグ.
   */
  private String is_disp;

  /**
   * 削除フラグ.
   */
  private String is_del;

  // mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
//  /**
//   * 施設カレンダーの開始日に投稿.
//   */
//  private String notice_fac_cal_start_date;
//
//  /**
//   * 施設カレンダーの終了日に投稿.
//   */
//  private String notice_fac_cal_end_date;
  /**
   * 施設カレンダーの開始日に日付.
   */
  private String notice_fac_cal_start_date;

  /**
   * 施設カレンダーの終了日に日付.
   */
  private String notice_fac_cal_end_date;
  // mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end

  /**
   * 掲示板フラグに表示.
   */
  private String is_disp_bbs;

  /**
   * 色.
   */
  private String color;

//  add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start
  /**
   * 文字色.
   */
  private String font_color;
//  add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end

  /**
   * 登録元機能
   */
  private Integer reg_func_class;

  /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start*/
  private String html_content;
  /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end*/

// add FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
  /**
   * 施設カレンダーイベント開始時刻
   */
  private String notice_fac_cal_start_time;

  /**
   * 施設カレンダーイベント終了時刻
   */
  private String notice_fac_cal_end_time;

  /**
   * 施設カレンダーイベント開始時刻入力フラグ
   */
  private String is_time_start_flg;

  /**
   * 施設カレンダーイベント終了時刻入力フラグ
   */
  private String is_time_end_flg;
  // add FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end

}
