package batch.entity.mongo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class InfectInfo {
    private Integer ctl_no;
    private String infect;
    private String up_date;
    private String exam_date;
    private Integer infection_cd;
    private String infection_name;
}
