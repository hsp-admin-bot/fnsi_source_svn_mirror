package batch.entity.mongo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdditionInfo {
    private Integer cd;
    private String kind;
    private String name;
    private String reg_date;
    private String is_enable;
    private String last_date;
}
