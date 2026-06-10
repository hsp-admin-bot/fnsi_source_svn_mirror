package batch.entity;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SysFacility {

    /**
     * 医療機関コード
     */
    private String medicalInstitutionCd;

    /**
     * 医都道府県コード
     */
    private String prefecturesCd;

    /**
     * 施設名
     */
    private String   facilityName;
}
