package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Entity(listener = CommonEntityListener.class, naming = NamingType.NONE)
@Table(name = "pat_main")
@Getter
@Setter
public class PatMain extends BaseBlankEntity {

  @Id
  private Long pat_id;
  private String facility_cd;
  private String is_same;
  private String is_implant;
  private String is_infect;
  private String is_diabetes;
  private String is_blood_suger_exam;
  private String is_wheel_chair;
  private String in_out_current_state;
  private String in_out_plan_state;
  private Timestamp in_out_plan_date;
  private String pat_memo_info;
  private String addition_info;
  private String charge_staff_info;
  private String pat_group_info;
  private String taboo_allergy_info;
  private String infect_info;
  private String implant_info;
  private String tare_info;
  private String off_water_info;
  private String device_set_info;
  private String acceptance_status_info;
  private String is_del;
  private String up_date;
  private String reg_date;
  // 共通診療情報
  private String medical_care_info;
  // スケジュール延長最終日
  private String sch_ext_end_date;
  // スケジュール延長処理ステータス
  private String sch_ext_status;
  // add FNSI-排他処理 劉 start
  private String old_up_date;
  // add FNSI-排他処理 劉 end
  // ホスト報知情報
  private String host_notification_info;
  private Long wheel_chair_cd;

}
