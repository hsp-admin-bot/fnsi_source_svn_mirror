package jp.co.nikkiso.ntss.core.entity.patHistory.patUniqueHistoryDetail;

import lombok.Getter;
import lombok.Setter;

// 入外・転入出情報
@Getter
@Setter
public class InOutVisitHistoryInfo {
    // 管理番号
    private Integer ctl_no;
    // 表示順
    private Integer disp_order;
    // 登録施設コード
    private String facility_cd;
    // 登録施設名
    private String facility_name;
    // 登録施設がフリー入力されているか
    private String facility_is_free;
    // 転入出区分
    private String move_in_out;
    // 転入出期間(開始)
    private String period_start;
    //
    private String period_start_date;
    //
    private String period_start_day;
    //
    private String period_start_input_free;
    //
    private String period_start_month;
    //
    private String period_start_year;
    // 転入出期間(終了)
    private String period_end;
    //
    private String period_end_date;
    //
    private String period_end_day;
    //
    private String period_end_input_free;
    //
    private String period_end_month;
    //
    private String period_end_year;
    // 入外区分
    private String in_out;
    // 入出理由
    private String reason;
    // 元施設
    private String from_facility;
    // 元施設名
    private String from_facility_name;
    // 元科
    private Object from_course;
    // 元科名
    private String from_course_name;
    // 元施設医
    private Object from_doctor;
    // 元施設医名
    private String from_doctor_name;
    //
    private String from_medicalInstitutionCd;
    //
    private String from_medicalInstitution_name;
    // 先施設
    private String to_facility;
    // 先施設名
    private String to_facility_name;
    // 先科
    private Object to_course;
    // 先科名
    private String to_course_name;
    // 先施設医
    private Object to_doctor;
    // 先施設医名
    private String to_doctor_name;
    //
    private String to_medicalInstitutionCd;
    //
    private String to_medicalInstitution_name;
    //
    private String doctor_is_free;
    // 元施設への返信
    private String is_reply;
    //
    private String course_is_free;
    // コメント
    private String comment;


    // 出入り確認
    private Boolean in_out_check;
    // 編集不可
    private String readonly;

}
