package batch.entity.mongo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class TabooAllergyInfo {
    private String memo;
    private Integer ctl_no;
    private String content;
    private Integer disp_order;
    private String category_class;
    private String taboo_allergy_cd;
    private String taboo_allergy_class;
}
