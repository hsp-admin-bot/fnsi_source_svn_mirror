package jp.co.nikkiso.ntss.core.dto.ClDetail;

import lombok.Data;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

@Data
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
public class ClDetails {
    private Integer no;

    private Integer curDownload;

    private String facilityCd;

    private String facilityName;

    private String upDate;

    private String isDelete;

    private String manyFacilityName;
    private String manyFacilityCd;
    private String clCertificateId;
}
