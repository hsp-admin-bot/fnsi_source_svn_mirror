package batch.entity.mongo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PhysicalInfo {
    private String ctr;
    private Integer ctl_no;
    private String changer_cd;
    private String ctr_weight;
    private String indicator_cd;
    private String indicator_name;
    private String memo;
    private String chest_dia;
    private String facility_name;
    private String inspect_date;
    private String dw;
    private String indicator_start_date;
    private String facility_cd;
    private String changer_name;
    private String pre_scale_upper;
    private String pre_scale_lower;
    private String target_weight;
    private String breast_dia;
    private String exam_date;
    private Integer order_class;
    private String height;
}
