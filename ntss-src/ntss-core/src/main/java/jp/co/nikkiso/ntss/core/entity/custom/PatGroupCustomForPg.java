package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 患者グループのEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatGroupCustomForPg {
    /**
     * 管理番号
     */
    private Integer ctl_no;

    /**
     * 患者グループID
     */
    private String patGroupCd;

}

