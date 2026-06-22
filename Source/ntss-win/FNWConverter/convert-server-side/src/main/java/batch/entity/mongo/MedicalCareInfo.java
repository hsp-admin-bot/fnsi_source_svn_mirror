package batch.entity.mongo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MedicalCareInfo {
    private Integer ward_cd;
    private String ward_name;
    private String facility_cd;
    private String facility_name;
    private Integer dialysis_count;
    private Integer main_course_cd;
    private String main_course_name;
    private Integer dialysis_course_cd;
    private Integer pat_dialysis_count;
    private Integer purification_count;
    private String dialysis_start_date;
    private String hospital_start_date;
    private String dialysis_course_name;
    private Integer other_dialysis_count;
    private String main_in_hospital_cd_1;
    private String ward_in_hospital_cd_1;
}
