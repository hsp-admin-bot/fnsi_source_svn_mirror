package jp.co.nikkiso.ntss.api.model.indHistory;

import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
public class ValiMoveTreatPlan {
  private String ord_no;
  private String dialysis_date_to;
  private String ind_schedule_user_info;
  private String pat_id;
  private String treat_date;
  private String ind_treatment_cd;
  private String ind_kur_cd;
  private String start_date;
  private String end_date;
  private String ind_user;
  private String upd_user;
  private String weeks;
  private String ind_info;
  private String ind_dates;
  private String facility_cd;
  private String ind_bed_cd;
  private String facilitySettingExamValue;
  private String facilitySettingRadValue;
}
