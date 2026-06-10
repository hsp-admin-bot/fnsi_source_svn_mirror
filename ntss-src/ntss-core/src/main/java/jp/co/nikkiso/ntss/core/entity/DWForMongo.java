package jp.co.nikkiso.ntss.core.entity;

import org.springframework.data.mongodb.core.mapping.Document;

//mongodbに情報を保存する
@Document(collection="ind_history")
public class DWForMongo {
  private String _class;
  private String _id;
  private String approver_1;
  private String approver_2;
  private String created_by;
  private String created_user_id;
  private String facility_cd;
  private String log_class;
  private String log_content;
  private String log_date;
  private String log_target;
  private String pat_id;
  private String receiver_1;
  private String receiver_2;
  private Integer sort_no;
  private String treatment_course;
  private String treatment_end_date;
  private String treatment_method;
  private String treatment_start_date;
  private String treatment_weekday;
  private String updated_by;
  private String updated_user_id;

  public String get_class() {
    return _class;
  }

  public void set_class(String _class) {
    this._class = _class;
  }

  public String get_id() {
    return _id;
  }

  public void set_id(String _id) {
    this._id = _id;
  }

  public String getApprover_1() {
    return approver_1;
  }

  public void setApprover_1(String approver_1) {
    this.approver_1 = approver_1;
  }

  public String getApprover_2() {
    return approver_2;
  }

  public void setApprover_2(String approver_2) {
    this.approver_2 = approver_2;
  }

  public String getCreated_by() {
    return created_by;
  }

  public void setCreated_by(String created_by) {
    this.created_by = created_by;
  }

  public String getCreated_user_id() {
    return created_user_id;
  }

  public void setCreated_user_id(String created_user_id) {
    this.created_user_id = created_user_id;
  }

  public String getFacility_cd() {
    return facility_cd;
  }

  public void setFacility_cd(String facility_cd) {
    this.facility_cd = facility_cd;
  }

  public String getLog_class() {
    return log_class;
  }

  public void setLog_class(String log_class) {
    this.log_class = log_class;
  }

  public String getLog_content() {
    return log_content;
  }

  public void setLog_content(String log_content) {
    this.log_content = log_content;
  }

  public String getLog_date() {
    return log_date;
  }

  public void setLog_date(String log_date) {
    this.log_date = log_date;
  }

  public String getLog_target() {
    return log_target;
  }

  public void setLog_target(String log_target) {
    this.log_target = log_target;
  }

  public String getPat_id() {
    return pat_id;
  }

  public void setPat_id(String pat_id) {
    this.pat_id = pat_id;
  }

  public String getReceiver_1() {
    return receiver_1;
  }

  public void setReceiver_1(String receiver_1) {
    this.receiver_1 = receiver_1;
  }

  public String getReceiver_2() {
    return receiver_2;
  }

  public void setReceiver_2(String receiver_2) {
    this.receiver_2 = receiver_2;
  }

  public Integer getSort_no() {
    return sort_no;
  }

  public void setSort_no(Integer sort_no) {
    this.sort_no = sort_no;
  }

  public String getTreatment_course() {
    return treatment_course;
  }

  public void setTreatment_course(String treatment_course) {
    this.treatment_course = treatment_course;
  }

  public String getTreatment_end_date() {
    return treatment_end_date;
  }

  public void setTreatment_end_date(String treatment_end_date) {
    this.treatment_end_date = treatment_end_date;
  }

  public String getTreatment_method() {
    return treatment_method;
  }

  public void setTreatment_method(String treatment_method) {
    this.treatment_method = treatment_method;
  }

  public String getTreatment_start_date() {
    return treatment_start_date;
  }

  public void setTreatment_start_date(String treatment_start_date) {
    this.treatment_start_date = treatment_start_date;
  }

  public String getTreatment_weekday() {
    return treatment_weekday;
  }

  public void setTreatment_weekday(String treatment_weekday) {
    this.treatment_weekday = treatment_weekday;
  }

  public String getUpdated_by() {
    return updated_by;
  }

  public void setUpdated_by(String updated_by) {
    this.updated_by = updated_by;
  }

  public String getUpdated_user_id() {
    return updated_user_id;
  }

  public void setUpdated_user_id(String updated_user_id) {
    this.updated_user_id = updated_user_id;
  }

}
