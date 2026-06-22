package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_facility")
@Getter
@Setter
public class MstFacility {


    /**
     * 施設コード.
     */
    private String No;
    /**
     * 施設コード.
     */
    private String facilityCd;

    /**
     * 施設名.
     */
    private String facilityName;

    /**
     * 自動延長の実行ステータス '0：実行中、１：停止
     */
    private String isSchextException;


}
