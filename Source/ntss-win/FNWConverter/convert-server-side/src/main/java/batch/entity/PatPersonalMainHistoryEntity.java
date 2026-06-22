package batch.entity;
import batch.entity.mongo.DialDiffComInfo;
import batch.entity.mongo.OtherContactInfo;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;
import java.util.List;

/**
 * pat_group_detail_historyのEntity.
 */
@Document(collection="pat_personal_main_history")
@Getter
@Setter
public class PatPersonalMainHistoryEntity {

    @Field("pat_id")
    private String patId;

    @Field("fn_pat_id")
    private String fnPatId;

    @Field("hosp_pat_id")
    private String hospPatId;

    @Field("nkk_pat_id")
    private String nkkPatId;

    @Field("facility_name")
    private String facilityName;

    @Field("facility_cd")
    private String facilityCd;

    @Field("pat_last_name")
    private String patLastName;

    @Field("pat_first_name")
    private String patFirstName;

    @Field("pat_last_name_kana")
    private String patLastNameKana;

    @Field("pat_first_name_kana")
    private String patFirstNameKana;

    @Field("pat_last_name_alpha")
    private String patLastNameAlpha;

    @Field("pat_first_name_alpha")
    private String patFirstNameAlpha;

    @Field("pat_birth_name")
    private String patBirthName;

    @Field("pat_birth_name_kana")
    private String patBirthNameKana;

    @Field("pat_birth_name_alpha")
    private String patBirthNameAlpha;

    @Field("pat_birthday")
    private String patBirthday;

    @Field("pat_sex")
    private String patSex;

    @Field("nationality")
    private String nationality;

    @Field("pat_blood_type_abo")
    private String patBloodTypeAbo;

    @Field("pat_blood_type_rh")
    private String patBloodTypeRh;

    @Field("pat_blood_type_serovar")
    private String patBloodTypeSerovar;

    @Field("in_out_class")
    private String inOutClass;

    @Field("is_die")
    private String isDie;

    @Field("die_cd")
    private String dieCd;

    @Field("die_name")
    private String dieName;

    @Field("die_date")
    private String dieDate;

    @Field("dial_diff_com_info")
    private List<DialDiffComInfo> dialDiffComInfo;

    @Field("severity_cd")
    private String severityCd;
    @Field("severity_name")
    private String severityName;
    @Field("transport_cd")
    private String transportCd;
    @Field("transport_name")
    private String transportName;
    @Field("pat_contact_info")
    private String patContactInfo;

    @Field("other_contact_info")
    private List<OtherContactInfo> otherContactInfo;

    @Field("vendor_contact_info")
    private String vendorContactInfo;

    @Field("insurance_info")
    private String insuranceInfo;

    @Field("is_del")
    private String isDel;

    @Field("up_date")
    private String upDate;

    @Field("reg_date")
    private String regDate;

    @Field("primary_disease_cd")
    private String primaryDiseaseCd;
    @Field("primary_disease_name")
    private String primaryDiseaseName;
    @Field("remote_monitor_service")
    private String remoteMonitorService;

    @Field("remote_monitor_user_id")
    private String remoteMonitorUserId;

    @Field("remote_monitor_user_pw")
    private String remoteMonitorUserPw;

    @Field("old_up_date_personal")
    private String oldUpDatePersonal;

    @Field("ins_date")
    private Date insDate;

    @Field("latest_flag")
    private String latestFlag;

}
