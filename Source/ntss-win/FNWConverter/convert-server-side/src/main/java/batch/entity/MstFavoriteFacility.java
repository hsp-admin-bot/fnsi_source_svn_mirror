package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_favorite_facility")
@Getter
@Setter
public class MstFavoriteFacility {

    private String facilityCd;

    /**
     * 医療機関コード
     */
    private String medicalInstitutionCd;
    /**
     * 登録日時
     */
    private Timestamp regDate;
    /**
     * 更新日時
     */
    private Timestamp upDate;

    @Override
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append(facilityCd).append(",")
                .append(medicalInstitutionCd == null ? "" : medicalInstitutionCd).append(",")
                .append(regDate == null ? "" : regDate).append(",")
                .append(upDate == null ? "" : upDate).append(",");
        return sb.toString();
    }

}
