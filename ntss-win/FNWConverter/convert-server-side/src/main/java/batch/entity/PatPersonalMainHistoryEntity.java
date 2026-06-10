package batch.entity;
import batch.entity.mongo.DialDiffComInfo;
import batch.entity.mongo.OtherContactInfo;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBHashKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBTable;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;
import java.util.List;

/**
 * pat_group_detail_historyのEntity.
 */
@DynamoDBTable(tableName="pat_personal_main_history")
@Document(collection="pat_personal_main_history")
@Getter
@Setter
public class PatPersonalMainHistoryEntity {

    @DynamoDBHashKey(attributeName = "pat_id")
    @Field("pat_id")
    private String patId;

    @DynamoDBHashKey(attributeName = "fn_pat_id")
    @Field("fn_pat_id")
    private String fnPatId;

    @DynamoDBHashKey(attributeName = "hosp_pat_id")
    @Field("hosp_pat_id")
    private String hospPatId;

    @DynamoDBHashKey(attributeName = "nkk_pat_id")
    @Field("nkk_pat_id")
    private String nkkPatId;

    @DynamoDBHashKey(attributeName = "facility_name")
    @Field("facility_name")
    private String facilityName;

    @DynamoDBHashKey(attributeName = "facility_cd")
    @Field("facility_cd")
    private String facilityCd;

    @DynamoDBHashKey(attributeName = "pat_last_name")
    @Field("pat_last_name")
    private String patLastName;

    @DynamoDBHashKey(attributeName = "pat_first_name")
    @Field("pat_first_name")
    private String patFirstName;

    @DynamoDBHashKey(attributeName = "pat_last_name_kana")
    @Field("pat_last_name_kana")
    private String patLastNameKana;

    @DynamoDBHashKey(attributeName = "pat_first_name_kana")
    @Field("pat_first_name_kana")
    private String patFirstNameKana;

    @DynamoDBHashKey(attributeName = "pat_last_name_alpha")
    @Field("pat_last_name_alpha")
    private String patLastNameAlpha;

    @DynamoDBHashKey(attributeName = "pat_first_name_alpha")
    @Field("pat_first_name_alpha")
    private String patFirstNameAlpha;

    @DynamoDBHashKey(attributeName = "pat_birth_name")
    @Field("pat_birth_name")
    private String patBirthName;

    @DynamoDBHashKey(attributeName = "pat_birth_name_kana")
    @Field("pat_birth_name_kana")
    private String patBirthNameKana;

    @DynamoDBHashKey(attributeName = "pat_birth_name_alpha")
    @Field("pat_birth_name_alpha")
    private String patBirthNameAlpha;

    @DynamoDBHashKey(attributeName = "pat_birthday")
    @Field("pat_birthday")
    private String patBirthday;

    @DynamoDBHashKey(attributeName = "pat_sex")
    @Field("pat_sex")
    private String patSex;

    @DynamoDBHashKey(attributeName = "nationality")
    @Field("nationality")
    private String nationality;

    @DynamoDBHashKey(attributeName = "pat_blood_type_abo")
    @Field("pat_blood_type_abo")
    private String patBloodTypeAbo;

    @DynamoDBHashKey(attributeName = "pat_blood_type_rh")
    @Field("pat_blood_type_rh")
    private String patBloodTypeRh;

    @DynamoDBHashKey(attributeName = "pat_blood_type_serovar")
    @Field("pat_blood_type_serovar")
    private String patBloodTypeSerovar;

    @DynamoDBHashKey(attributeName = "in_out_class")
    @Field("in_out_class")
    private String inOutClass;

    @DynamoDBHashKey(attributeName = "is_die")
    @Field("is_die")
    private String isDie;

    @DynamoDBHashKey(attributeName = "die_cd")
    @Field("die_cd")
    private String dieCd;

    @DynamoDBHashKey(attributeName = "die_name")
    @Field("die_name")
    private String dieName;

    @DynamoDBHashKey(attributeName = "die_date")
    @Field("die_date")
    private String dieDate;

    @DynamoDBHashKey(attributeName = "dial_diff_com_info")
    @Field("dial_diff_com_info")
    private List<DialDiffComInfo> dialDiffComInfo;

    @DynamoDBHashKey(attributeName = "severity_cd")
    @Field("severity_cd")
    private String severityCd;
    @DynamoDBHashKey(attributeName = "severity_name")
    @Field("severity_name")
    private String severityName;
    @DynamoDBHashKey(attributeName = "transport_cd")
    @Field("transport_cd")
    private String transportCd;
    @DynamoDBHashKey(attributeName = "transport_name")
    @Field("transport_name")
    private String transportName;
    @DynamoDBHashKey(attributeName = "pat_contact_info")
    @Field("pat_contact_info")
    private String patContactInfo;

    @DynamoDBHashKey(attributeName = "other_contact_info")
    @Field("other_contact_info")
    private List<OtherContactInfo> otherContactInfo;

    @DynamoDBHashKey(attributeName = "vendor_contact_info")
    @Field("vendor_contact_info")
    private String vendorContactInfo;

    @DynamoDBHashKey(attributeName = "insurance_info")
    @Field("insurance_info")
    private String insuranceInfo;

    @DynamoDBHashKey(attributeName = "is_del")
    @Field("is_del")
    private String isDel;

    @DynamoDBHashKey(attributeName = "up_date")
    @Field("up_date")
    private String upDate;

    @DynamoDBHashKey(attributeName = "reg_date")
    @Field("reg_date")
    private String regDate;

    @DynamoDBHashKey(attributeName = "primary_disease_cd")
    @Field("primary_disease_cd")
    private String primaryDiseaseCd;
    @DynamoDBHashKey(attributeName = "primary_disease_name")
    @Field("primary_disease_name")
    private String primaryDiseaseName;
    @DynamoDBHashKey(attributeName = "remote_monitor_service")
    @Field("remote_monitor_service")
    private String remoteMonitorService;

    @DynamoDBHashKey(attributeName = "remote_monitor_user_id")
    @Field("remote_monitor_user_id")
    private String remoteMonitorUserId;

    @DynamoDBHashKey(attributeName = "remote_monitor_user_pw")
    @Field("remote_monitor_user_pw")
    private String remoteMonitorUserPw;

    @DynamoDBHashKey(attributeName = "old_up_date_personal")
    @Field("old_up_date_personal")
    private String oldUpDatePersonal;

    @DynamoDBHashKey(attributeName = "ins_date")
    @Field("ins_date")
    private Date insDate;

    @DynamoDBHashKey(attributeName = "latest_flag")
    @Field("latest_flag")
    private String latestFlag;

}
