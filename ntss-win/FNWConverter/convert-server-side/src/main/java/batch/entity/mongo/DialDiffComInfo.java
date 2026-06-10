package batch.entity.mongo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DialDiffComInfo {
    private String is_main;
    private String reg_date;
    private Integer dial_diff_cd;
    private String is_dial_diff;
    private String dial_diff_name;
    private String in_hospital_cd_1;
    private String in_hospital_cd_2;
}