package jp.co.nikkiso.ntss.admin_web.web.rest.validation;

import javax.validation.constraints.Pattern;

import javax.validation.constraints.NotBlank;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

public class ApiEntityDeviceSetInfo {
  /**
   * 装置設定抽出条件
   */
  @Getter
  @Setter
  public static class ValiDeviceSetInfo {
    /**
     * 施設コード
     */
    @NotBlank(message="値がありません(facility)")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String facility_cd;

    /**
     * 患者ID
     */
    @NotBlank(message="値がありません(pat_id)")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String pat_id;

    /**
     * Ord番号
     */
    private String ord_no;

    /**
     * テーブル区分
     */
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
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
    @Pattern(regexp = "^[0-9]{8}",message="形式がyyyymmddではありません。")
    private String start_date;

    /**
     * 治療終了日
     */
    @Pattern(regexp = "^[0-9]{8}",message="形式がyyyymmddではありません。")
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
//FNSI-指示値・装置設定・装置プログラムの相関チェック

    /**
     * 終了日有無
     */
    private String image_flg;

    //add #10266 start
    /**
     * 2 : 一括編集
     */
    private String update_flag;
    //add #10266 end
  }
//FNSI-指示値・装置設定・装置プログラムの相関チェック

  @Data
  @Getter
  @Setter
  public static class ValiTareAndOffWater {
    // オーダー番号
    private String ord_no;
    // 患者ID
    private String pat_id;
    // 施設コード
    private String facility_cd;
    //add by ztc 2023-02-27 [Optimize runtime No.5482] --start
    // 患者番号(電子カルテ連携システム用)
    private String hosp_pat_id;
    // 操作者ID
    private String ind_user;
    // 基準日
    private String base_date;
    // 操作番号
    private String ope_cd;
    // 電文作成区分
    private String crud;
    //add by ztc 2023-02-27 [Optimize runtime No.5482] --end
    // 治療開始日
    private String start_date;
    // 治療終了日
    private String end_date;
    // 治療曜日
    private String weeks;
    // 治療方法コード
    private String ind_treatment_cd;
    // クールコード
    private String ind_kur_cd;
    // 風袋情報
    private String tare_info;
    // 除水補正情報
    private String off_water_info;
    // 更新日時
    private String up_date;
    // テーブルフラグ
    private String table_flag;
    // 終了日選択有無
    private String is_deadline;
    // DEL  8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou START
//    // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
//    // 治療日
//    private String treatDate;
//    // 治療情報リスト(対象患者のすべての治療情報)
//    private List<Map<String, Object>> oldOrdMainList;
    // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
    // DEL  8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
    //add #10266 start
    /**
     * 2 : 一括編集
     */
    private String update_flag;
    //add #10266 end
  }

  @Data
  @Getter
  @Setter
  public static class ValiHostNotification {
    // 患者ID
    private String pat_id;
    // 施設コード
    private String facility_cd;
    // ホスト報知情報
    private String host_notification_info;
    // 更新日時
    private String up_date;
    // dataSourceタイプ
    private String data_source_type;
  }

}
