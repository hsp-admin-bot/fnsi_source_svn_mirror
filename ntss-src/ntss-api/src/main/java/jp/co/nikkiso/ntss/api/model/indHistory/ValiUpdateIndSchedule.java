package jp.co.nikkiso.ntss.api.model.indHistory;

import jp.co.nikkiso.ntss.api.service.LogServiceImpl;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Getter
@Setter
public class ValiUpdateIndSchedule implements Cloneable {
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
  private String edit_ind_bed_cd;
  /**
   * 編集データ（指示：ベッド名）
   */
  private String edit_ind_bed_name;
  /**
   * 編集データ（指示者コード）
   */
  private String ind_user_id;
  /**
   * 編集データ（更新者コード）
   */
  private String upd_user_id;
  /**
   * 更新モードフラグ
   */
  private String update_mode;
  /**
   * 治療情報スケジュールフラグ
   */
  private String is_ind_sch_edit;

  /**
   * 実績更新フラグ
   */
  private String is_rst_update;

  /**
   * 2 : 一括編集
   */
  private String update_flag;

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
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    return b;
  }
}
