package batch.entity.mongo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChargeStaffInfo {
    private Integer ctl_no;
    private String is_main;
    private Integer staff_cd;
    private String is_charge;
    private Integer disp_order;
    private String staff_name;
    private String is_puncture;
    private String staff_disp_cd;
}
