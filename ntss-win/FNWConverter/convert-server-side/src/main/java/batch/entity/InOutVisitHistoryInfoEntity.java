package batch.entity;

import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

@Getter
@Setter
public class InOutVisitHistoryInfoEntity implements Comparable<InOutVisitHistoryInfoEntity>  {
    private Integer ctl_no;
    private String disp_order;
    private String facility_cd;
    private String move_in_out;
    private String period_start;
    private String period_start_date;
    private String period_start_year;
    private String period_start_month;
    private String period_start_day;
    private String period_start_input_free;
    private String period_end;
    private String period_end_date;
    private String period_end_year;
    private String period_end_month;
    private String period_end_day;
    private String period_end_input_free;
    private Integer in_out;
    private String reason;
    private String from_facility;
    private String from_course;
    private String from_doctor;
    private String to_facility;
    private String to_course;
    private String to_doctor;
    private String facility_is_free;
    private String course_is_free;
    private String doctor_is_free;
    private String to_medicalInstitutionCd;
    private String from_medicalInstitutionCd;

    private LocalDate periodStartDate;

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd");

    public LocalDate getPeriodStartDate() {
        if (this.periodStartDate == null && this.period_start_date != null) {
            try {
                this.periodStartDate = LocalDate.parse(this.period_start_date, DATE_FORMATTER);
            } catch (DateTimeParseException e) {
                return null;
            }
        }
        return this.periodStartDate;
    }

    @Override
    public int compareTo(InOutVisitHistoryInfoEntity other) {
        return this.ctl_no.compareTo(other.ctl_no);
    }
}
