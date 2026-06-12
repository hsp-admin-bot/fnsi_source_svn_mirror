package jp.co.nikkiso.ntss.admin_web.web.rest.validation;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;

import jp.co.nikkiso.ntss.admin_web.request.validator.NtssFlexibleDateTime;
import jp.co.nikkiso.ntss.admin_web.request.validator.NtssFlexibleDateTimeParseMode;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogServiceImpl;
import jp.co.nikkiso.ntss.core.entity.custom.WeekChangeInfo;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import java.math.BigInteger;
import java.util.List;
import java.util.Map;

import jakarta.validation.constraints.NotBlank;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

public class ApiEntityOrdMain {

  @Data
  public static class delList {
    public String startDate;
    public String facilitySettingExamValue;
    public String facilitySettingRadValue;
  }

  /**
   * 透析情報編集用共通情報
   */
  @Getter
  @Setter
  public static class ValiIndCommSearchConditions {
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
    // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
    // del #7627 患者経過総合ビューアで治療方法・治療条件を変更して新規イベントが作成されることがある zs start
//    // 操作番号
//    private String ope_cd;
//    // 電文作成区分
//    private String crud;
//    //Ord番号
//    private String ord_no;
//    // 基準日
//    private String base_date;
    // del #7627 患者経過総合ビューアで治療方法・治療条件を変更して新規イベントが作成されることがある zs end
    // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
    /* add by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --start */
    private Integer patShareMode;
    /* add by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --end */
  }

  /**
   * 治療情報スケジュール編集情報
   */
  @Getter
  @Setter
  public static class ValiIndMediInfoSearchCondition{
    //施設コード
    private String facilityCd;
    //患者idです
    private String patId;
    //ページ最大日付です
    private String startTime;
    /* add by chamaojia 2026-03-17 [12462] 患者情報共有->患者経過総合ビューア --start */
    // 患者共有設定
    private Integer patShareMode;
    /* add by chamaojia 2026-03-17 [12462] 患者情報共有->患者経過総合ビューア --end */
  }
  @Getter
  @Setter
  public static class ValiUpdateIndSchedule extends ValiIndCommSearchConditions implements Cloneable {
    /**
     * 編集データ（指示：クールコード）
     */
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String edit_ind_kur_cd;
    /**
     * 編集データ（指示：クール名）
     */
    private String edit_ind_kur_name;
    /**
     * 編集データ（指示：治療開始時刻）
     */
    private String edit_ind_treat_start_time;
    /**
     * 編集データ（治療日）
     */
    private String edit_ind_treat_date;
    /**
     * 編集データ（指示：ベッドコード）
     */
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String edit_ind_bed_cd;
    /**
     * 編集データ（指示：ベッド名）
     */
    private String edit_ind_bed_name;
    /**
     * 編集データ（指示者コード）
     */
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ind_user_id;
    /**
     * 編集データ（更新者コード）
     */
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String upd_user_id;
    /**
     * 更新モードフラグ
     */
    private String update_mode;
    // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 start
    /**
     * 治療情報スケジュールフラグ
     */
    private String is_ind_sch_edit;

    /**
     * 実績更新フラグ
     */
    private String is_rst_update;
    // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 end

    //add #10266 start
    /**
     * 2 : 一括編集
     */
    private String update_flag;
    //add #10266 end

    /**
     * ValiUpdateIndScheduleのディープコピー関数
     */
    @Override
    public ValiUpdateIndSchedule clone() {
      ValiUpdateIndSchedule b=new ValiUpdateIndSchedule();

      try {
          b=(ValiUpdateIndSchedule)super.clone();
      }catch (Exception e){
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
          LogServiceImpl logService = new LogServiceImpl();
          EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
      return b;
    }
  }

    /**
   * 治療情報治療条件編集情報
   */
  @Getter
  @Setter
  public static class ValiUpdateIndCond extends ValiIndCommSearchConditions {
    /**
     * 編集データ（指示：クールコード）
     */
    @NotBlank(message="値がありません")
    private String ind_cond_info;

    /**
     * 更新対象治療状況
     */
    private String target_dialysis_state;

    /**
     * 条件送信用データ
     */
    private String send_condition_info;

    // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 start
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
    // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 end
    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
    /**
     * 実績更新フラグ
     */
    private String is_rst_update;
    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end

    //add #10266 start
    /**
     * 2 : 一括編集
     */
    private String update_flag;
    //add #10266 end

      // add 10150_9664 by kangjie 20240628 start
      /**
       * 装置の種類 noIv、onLine、offLine
       */
    private String ind_treat_cond_iv_mode;
    // add 10150_9664 by kangjie 20240628 end

  }

  @Getter
  @Setter
  public static class ValiIsTreatOnlyDateList {
    /**
     * 基準日
     */
    private String base_date;

    /**
     * 期間(未来分)
     */
    private String period;

    /**
     * 期間(過去分)
     */
    private String pastPeriod;

    /**
     * 施設コード
     */
    private String facility_cd;

    /**
     * 患者ID
     */
    private String pat_id;

    /* add by chamaojia 2026-03-23 [12462] 患者情報共有->患者経過総合ビューア --start */
    /**
     * 患者共有設定
     */
    private Integer patShareMode;
    /* add by chamaojia 2026-03-23 [12462] 患者情報共有->患者経過総合ビューア --end */
  }

  @Getter
  @Setter
  public static class ValiMoveTreatPlan {
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+",message="数値ではありません。")
    private String ord_no;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String dialysis_date_to;
    @NotBlank(message="値がありません")
    private String ind_schedule_user_info;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String pat_id;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String treat_date;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ind_treatment_cd;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ind_kur_cd;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String start_date;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String end_date;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ind_user;
    private String upd_user;
    @NotBlank(message="値がありません")
    private String weeks;
    @NotBlank(message="値がありません")
    private String ind_info;
    @NotBlank(message="値がありません")
    private String ind_dates;
    @NotBlank(message="値がありません")
    private String facility_cd;
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ind_bed_cd;
//
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String facilitySettingExamValue;
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String facilitySettingRadValue;
//
  }

  /**
   * 指示コメント用クラス
   */
  @Getter
  @Setter
  public static class ValiCommentCreate {
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
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //private String input_class;
    private Integer input_class;
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

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

    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
    /**
     * 実績更新フラグ
     */
    private String is_rst_update;
    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end

    // add FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 start
    /**
     * 発生元区分(1:患者経過総合ビューア)
     */
    private String genDifferentiation;
    // add FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 end

    /**
     * 治療方法コードのリスト
     */
    private List<String> treatmentCdList;
    /**
     * タイトル
     */
    protected String hosp_pat_id;
    protected String user_id;

    //add FNSI-redmine8338 ljx start
    //指示コメントの更新は共用するため、回診記録から指示コメントへ転記する場合、フラグを追加、実績のみに更新
    /**
     * 指示・実績更新フラグ
     */
    private String ind_rst_flag;
    //add FNSI-redmine8338 ljx end

    //add #10266 start
    /**
     * 2 : 一括編集
     */
    private String update_flag;
    //add #10266 end

  }

  @Getter
  @Setter
  public static class ValiCopyTreatPlan {
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+",message="数値ではありません。")
    private String ord_no;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String dialysis_date_to;
    @NotBlank(message="値がありません")
    private String facility_cd;
    private String pat_id;
    private String ind_user;
    private String upd_user;
    private String ind_kur_cd;
    private String ind_bed_cd;
    private Boolean is_including_medicine;
  }

  @Getter
  @Setter
  public static class ValiCreateTreatPlan {
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String treatment_set_cd;
    @NotBlank(message="値がありません")
    private String up_date;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String pat_id;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String start_date;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String end_date;
    @NotBlank(message="値がありません")
    private String facility_cd;
    // del 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  start
    // @NotBlank(message="値がありません")
    // del 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
    private String treatDays;
    // 指示者ID
    private BigInteger ind_user_id;
    // 更新者ID
    private BigInteger upd_user_id;
    // 更新対象治療方法コード
    // del 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  strat
    // private String target_treatment_cd;
    // 更新対象クールコード
    // private String target_kur_cd;
    // del 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
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
    // add 373,374修正対応 陳 end
    // add FNSI-7325 劉全航 start
    private String invoke_page_name;
    // add FNSI-7325 劉全航 end
    // add 7760 【デグレ】治療方法マスタを編集すると全透析装置へ次患者情報が再送される zhao start
    private String nextFlag;
    // add 7760 【デグレ】治療方法マスタを編集すると全透析装置へ次患者情報が再送される zhao end
    // add 9281 日次処理にて正しくスケジュールが作成されない事がある 関 start
    private Integer device_mode;
    // add 9281 日次処理にて正しくスケジュールが作成されない事がある 関 end
    // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  start
    private String startsFlg;
    private String rst_flag;
    // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end

    //add #10266 start
    /**
     * 2 : 一括編集
     */
    private String update_flag;
    //add #10266 end

    // add #10553 #10125 ????患者予定作成元識別parm追加 piao start
    /**
     * 操作画面特定用文字列
     */
    private String screan_string;
    // add #10553 #10125 ????患者予定作成元識別parm追加 piao end
  }

  @Getter
  @Setter
  public static class ValiDeleteTreatPlan {
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String pat_id;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String start_date;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String end_date;
    @NotBlank(message="値がありません")
    private String facility_cd;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ind_user_id;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
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
    // add 9273 start
    private String event_change;
    // add 9273 end
    //upd by ztc 2023-02-27 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
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
    //upd by ztc 2023-02-27 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end

    // add #11716 曜日パターン変更の不正 関 start
    private String facilitySettingExamValue;

    private String facilitySettingRadValue;

    private String facilitySettingEventValue;

    private String examDeadlineSelectedVal;

    private String radDeadlineSelectedVal;
    // add #11716 曜日パターン変更の不正 関 end
  }

  // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
  @Getter
  @Setter
  public static class ValiDeleteIndPlanPatInfo {
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String pat_id;
    @NotBlank(message="値がありません")
    private String facility_cd;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ind_user_id;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
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

    // add 9273 start
    private String event_change;
    // add 9273 end

    //upd by ztc 2023-02-27 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
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
    //upd by ztc 2023-02-27 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
    // 治療日のコレクション
    @NotEmpty(message="値がありません")
    private List<Map<String, String>> move_out_date;
  }
  // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end

  @Getter
  @Setter
  public static class ValiOrdEquip {
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+",message="数値ではありません。")
    private String ord_no;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String dialysis_date_to;
    @NotBlank(message="値がありません")
    private String ind_schedule_user_info;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String pat_id;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String treat_date;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ind_treatment_cd;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ind_kur_cd;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String start_date;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String end_date;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ind_user;
    @NotBlank(message="値がありません")
    private String weeks;
    @NotBlank(message="値がありません")
    private String ind_info;
    @NotBlank(message="値がありません")
    private String ind_dates;
    @NotBlank(message="値がありません")
    private String facility_cd;
    // 穴埋め
    @NotBlank(message="値がありません")
    private String auto_insert;
    // 編集対象
    @NotBlank(message="値がありません")
    private String target_equip_edit;
    private String is_deadline;
    private String is_edit_other_amount;
    // 編集対象医療材料の区分
    @NotBlank(message="値がありません")
    private String target_equip_edit_type;
    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
    private String is_rst_update;
    /**
     * タイトル
     */
    protected String hosp_pat_id;
    protected String user_id;
    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end

    //add #10266 start
    /**
     * 2 : 一括編集
     */
    private String update_flag;
    //add #10266 end

    // add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm start
    /**
     * 条件送信用データ
     */
    private String send_equip_info;
    // add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm end
  }

  @Getter
  @Setter
  public static class ValiOrdMedi {
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+",message="数値ではありません。")
    private String ord_no;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String dialysis_date_to;
    @NotBlank(message="値がありません")
    private String ind_schedule_user_info;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String pat_id;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String treat_date;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ind_treatment_cd;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ind_kur_cd;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String start_date;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}",message="形式がyyyy-mm-ddではありません。")
    private String end_date;
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ind_user;
    @NotBlank(message="値がありません")
    private String weeks;
    @NotBlank(message="値がありません")
    private String ind_info;
    @NotBlank(message="値がありません")
    private String ind_dates;
    @NotBlank(message="値がありません")
    private String facility_cd;
    @NotBlank(message="値がありません")
    private String date_interval;
    private String count_before;
    private String count_after;
    private String init_date;
    private String is_deadline;
    private String is_edit_other_amount;
    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
    private String is_rst_update;
    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
    // add FNSI-投与薬剤編集にて「投薬パターン」、「曜日パターン」の変更 興 start
    private List<String> treat_dates;
    private List<String> treat_date_list_all;
    // add FNSI-投与薬剤編集にて「投薬パターン」、「曜日パターン」の変更 興 end
    // add FNSI-FutreNetWeb+SI課題管理No.3848 李 start
    private Boolean interval_flg;
    /**
     * タイトル
     */
    protected String hosp_pat_id;
    protected String user_id;
    // add FNSI-FutreNetWeb+SI課題管理No.3848 李 end

    //add #10266 start
    /**
     * 2 : 一括編集
     */
    private String update_flag;
    //add #10266 end
    //add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
    /**
     * 変更画面終了日或いは回数を選択する(true：回数、false：終了日)
     */
    private Boolean number_of_doses;
    //add 11555 指示履歴への記録の残り方が仕様と異なる zkm end
  }

  /**
   * 予定登録（byオーダ番号）
   */
  @Getter
  @Setter
  public static class ValiCreateTreatPlanByOrdNo {
    /**
     * オーダ番号
     */
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ord_no;
    /**
     * 治療予定の更新日時
     */
    @NotBlank(message="値がありません")
    private String up_date;
    /**
     * 患者ID
     */
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String pat_id;
    /**
     * 施設コード
     */
    @NotBlank(message="値がありません")
    private String facility_cd;
    @NotBlank(message="値がありません")
    /**
     * 治療日リスト
     */
    private String treatDays;
    /**
     * 指示者
     */
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String ind_user_id;
    /**
     * 更新者
     */
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+", message="数値ではありません。")
    private String upd_user_id;

    /**
     * 終了日有無
     */
    private String is_deadline;

    /**
     * 治療種別
     */
    private String treat_type;
  }


  @Getter
  @Setter
    public static class ValiSearchPatTreatmentPattern {
    /**
     * 施設コード
     */
    private String facility_cd;

    /**
     * 患者ID
     */
    private String pat_id;

    /**
     * 指示:治療方法
     */
    private String ind_treatment_cd;


    /**
     * 指示:クール
     */
    private String ind_kur_cd;

    /**
     * 曜日パターン
     */
    private String week_pattern;
  }

  /**
   * 曜日パターン変更
   */
  @Getter
  @Setter
  public static class ValiWeekPattern {
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
    // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end
    //add 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない start
    private String hosp_pat_id;
    //add 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない end
    //add 7307 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 start
    private Boolean cover;
    //add 7307 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 end
    //add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 start
    private Boolean skip;
    //add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 end
    //9273 start
    private String facilitySettingExamValue;
    private String facilitySettingRadValue;
    private String facilitySettingEventValue;
    // add #11716 曜日パターン変更の不正 関 start
    private String examDeadlineSelectedVal;
    private String radDeadlineSelectedVal;
    // add #11716 曜日パターン変更の不正 関 end
    //9273 end

    // add 10284 by kangjie 20240204 start
    private Boolean is_deadline;
    // add 10284 by kangjie 20240204 end

    // add #11717【因島】曜日パターン変更の動作が遅い fang start
    private List<WeekChangeInfo> updateList;

    private List<WeekChangeInfo> copyList;

    private List<WeekChangeInfo> delList;
    // add #11717【因島】曜日パターン変更の動作が遅い fang end

    // add #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
    private String max_date;
    // add #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
  }

  /**
   * 治療情報治療条件編集情報(マルチ患者一覧使用)
   */
  @Getter
  @Setter
  public static class ValiUpdateIndCondInfo extends ValiUpdateIndCond {
    @NotBlank(message="値がありません")
    private Double dw;

    @NotBlank(message="値がありません")
    private Double ctr;

    @NotBlank(message="値がありません")
    private Double target_weight;

    @NotBlank(message="値がありません")
    private Long indicator_cd;

    @NotBlank(message="値がありません")
    private Long upd_user_cd;
  }


  @Getter
  @Setter
  public static class ValiIndRstDw {
    // オーダー番号
    private Long ord_no;
    // dw
    private Double dw;
  }

  // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 start
  @Getter
  @Setter
  public static class ValiOrdMaterialSave {
    // 処理タイプ(1:予定作成、2:予定コーピ)
    private Integer species;
    // 治療方法セットコード
    private String treatment_set_cd;
    // 施設コード
    private String facility_cd;
    // 患者ID
    private String pat_id;
    // データ基準日(復数可能)
    private List<String> supplies_base_date;
    // データ基準日
    private String base_date;
    // データ基準番号
    private String supplies_base_no;
    // データ元基準番号
    private String original_base_no;
    // 削除されたOrdNoList
    private List<Long> ord_no_list;
    // データ発生元区分
    private String supplies_source_class;
    // 物品区分
    private String supplies_class;
    // 物品コード
    private String supplies_cd;
    // 調整薬剤コード
    private String medicine_mix_cd;
    // 分類コード
    private String class_cd;
    // 指示・実績区分
    private String ind_rst_class;
    // 指示・実績値
    private String ind_rst_value;
    // レセ値
    private String receipt_value;
    // 確定フラグ
    private String is_confirm;

    // 物品区分List
    private List<String> supplies_class_list;
    // 物品代码List
    private List<String> supplies_cd_list;
    // 指示・実績区分 search contion
    private List<String> indRstClassList;
  }
  // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 end

  // add FNSI-計算材料保持テーブルから長期グラフ表示データを取得「235」「236」「660」「661」 周 start
  @Getter
  @Setter
  public static class ValiOrdMaterialSaveGraph {
    // 施設コード
    private String facility_cd;
    // 患者ID
    private Long pat_id;
    // データ基準日「条件開始」
    private String supplies_base_date_begin;
    // データ基準日「条件終了」
    private String supplies_base_date_end;

    // add #12462 患者情報共有->患者経過総合ビューア fang start
    private String suppliesClass;

    private String shareMode;
    // add #12462 患者情報共有->患者経過総合ビューア fang end
  }
  // add FNSI-計算材料保持テーブルから長期グラフ表示データを取得「235」「236」「660」「661」 周 end

  // add FNSI-425,426 姜 start
  @Getter
  @Setter
  public static class ValiOrdMainUpdateRadExam {
    // 変更前オーダー番号
    private String before_ord_no;
    // 施設コード
    private String facility_cd;
    // 患者ID
    private String pat_id;
    // 変更前日時
    private String before_treat_date;
    // 変更後日時
    private String after_treat_date;
    // 施設設定により処理分岐(検体検査)
    private String facility_setting_exam_value;
    // 施設設定により処理分岐(放射線検査)
    private String facility_setting_rad_value;
  }
  // add FNSI-425,426 姜 end
  // redmine 4672  姜 start
  @Getter
  @Setter
  public static class CheckFuicchi {
    private Long ord_no;
    private Long pat_id;
    private String ind_bed_cd;
    private String facility_cd;
    private String before_bed_cd;
  }
  // redmine 4672  姜 end
//add 5127 透析レポート印刷時の条件について 吉 start
  public static class CheckIsPrint {
    private Long pat_id;
    private String facility_cd;
    private String treatDate;
    private String reportCd;
  }
  //add 5127 透析レポート印刷時の条件について 吉 end

  // add 10443 身体情報・DW・目標体重バグ 関  start
  @Getter
  @Setter
  public static class ValiSearchTreatDateDw{
    /**
     * 治療予定の開始日
     */
    //mod #12660 【securify】SQLインジェクション(High) まとめ zrx start
    @NtssFlexibleDateTime(mode = NtssFlexibleDateTimeParseMode.DATE_ONLY, allowEmpty = true)
    private String ind_start_date;
    /**
     * 治療予定の曜日パターン
     */
    private String week_pattern;
    /**
     * 治療方法
     */
    private String ind_treatment_cd;
    /**
     * クール
     */
    private String ind_kur_cd;
    /**
     * 施設コード
     */
    @Pattern(regexp = "^[A-Za-z0-9]{6}$", message="形式が不正です。")
    private String facility_cd;
    /**
     * 患者ID
     */
    @Pattern(regexp = "^[0-9]+$", message="数値ではありません。")
    private String pat_id;

    /**
     * オーダー番号
     */
    @Pattern(regexp = "^[0-9]+$", message="数値ではありません。")
    private String ord_no;
    //mod #12660 【securify】SQLインジェクション(High) まとめ zrx end
  }
  // add 10443 身体情報・DW・目標体重バグ 関  end
}
