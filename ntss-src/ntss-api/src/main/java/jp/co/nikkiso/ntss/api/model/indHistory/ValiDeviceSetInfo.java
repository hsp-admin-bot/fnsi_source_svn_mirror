package jp.co.nikkiso.ntss.api.model.indHistory;

import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
public class ValiDeviceSetInfo {
  /**
   * 施設コード
   */
  private String facility_cd;

  /**
   * 患者ID
   */
  private String pat_id;

  /**
   * Ord番号
   */
  private String ord_no;

  /**
   * テーブル区分
   */
  private String table_flag;

  /**
   * テーブル区分2
   * TODO: 2つのテーブルを更新する際、使用
   */
  private String second_table_flag;
  //add by ztc 2023-02-27 [Optimize runtime No.5482] --start
  /**
   * 患者番号(電子カルテ連携システム用)
   */
  private String hosp_pat_id;
  /**
   * 操作者ID
   */
  private String ind_user;
  /**
   * 基準日
   */
  private String base_date;
  /**
   * 操作番号
   */
  private String ope_cd;
  /**
   * 電文作成区分
   */
  private String crud;
  //add by ztc 2023-02-27 [Optimize runtime No.5482] --end
  /**
   * 画面キー
   */
  private String screen_key;

  /**
   * 治療開始日
   */
  private String start_date;

  /**
   * 治療終了日
   */
  private String end_date;

  /**
   * 曜日
   */
  private String week;

  /**
   * 治療方法:治療方法
   */
  private String treat_method;

  /**
   * 指示:クールコード
   */
  private String kur_cd;

  /**
   * 更新データ
   */
  private String update_data;

  /**
   * 治療曜日
   */
  private String weeks;

  /**
   * 治療方法コード
   */
  private String ind_treatment_cd;

  /**
   * クールコード
   */
  private String ind_kur_cd;

  /**
   * 装置設定情報
   */
  private String ind_device_set_info;

  /**
   * 終了日有無
   */
  private String is_deadline;

  /**
   * 終了日有無
   */
  private String image_flg;

  /**
   * 2 : 一括編集
   */
  private String update_flag;
}
