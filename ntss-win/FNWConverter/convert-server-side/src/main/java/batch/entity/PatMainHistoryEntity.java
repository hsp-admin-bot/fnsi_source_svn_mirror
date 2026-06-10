package batch.entity;

import batch.entity.mongo.*;
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
@DynamoDBTable(tableName="pat_main_history")
@Document(collection="pat_main_history")
@Getter
@Setter
public class PatMainHistoryEntity {

    @DynamoDBHashKey(attributeName = "pat_id")
    @Field("pat_id")
    private String patId;

    @DynamoDBHashKey(attributeName = "facility_cd")
    @Field("facility_cd")
    private String facilityCd;

    @DynamoDBHashKey(attributeName = "facility_name")
    @Field("facility_name")
    private String facilityName;

    @DynamoDBHashKey(attributeName = "is_same")
    @Field("is_same")
    private String isSame;

    @DynamoDBHashKey(attributeName = "is_implant")
    @Field("is_implant")
    private String isImplant;

    @DynamoDBHashKey(attributeName = "is_infect")
    @Field("is_infect")
    private String isInfect;

    @DynamoDBHashKey(attributeName = "is_diabetes")
    @Field("is_diabetes")
    private String isDiabetes;

    @DynamoDBHashKey(attributeName = "is_blood_suger_exam")
    @Field("is_blood_suger_exam")
    private String isBloodSugerExam;

    @DynamoDBHashKey(attributeName = "in_out_current_state")
    @Field("in_out_current_state")
    private String inOutCurrentState;

    @DynamoDBHashKey(attributeName = "in_out_plan_state")
    @Field("in_out_plan_state")
    private String inOutPlanState;

    @DynamoDBHashKey(attributeName = "in_out_plan_date")
    @Field("in_out_plan_date")
    private Date inOutPlanDate;

    @DynamoDBHashKey(attributeName = "pat_memo_info")
    @Field("pat_memo_info")
    private List<PatMemoInfo> patMemoInfo;

    @DynamoDBHashKey(attributeName = "addition_info")
    @Field("addition_info")
    private List<AdditionInfo> additionInfo;

    @DynamoDBHashKey(attributeName = "charge_staff_info")
    @Field("charge_staff_info")
    private List<ChargeStaffInfo>  chargeStaffInfo;

    @DynamoDBHashKey(attributeName = "pat_group_info")
    @Field("pat_group_info")
    private List<PatGroupInfo> patGroupInfo;

    @DynamoDBHashKey(attributeName = "taboo_allergy_info")
    @Field("taboo_allergy_info")
    private List<TabooAllergyInfo> tabooAllergyInfo;

    @DynamoDBHashKey(attributeName = "infect_info")
    @Field("infect_info")
    private List<InfectInfo> infectInfo;

    @DynamoDBHashKey(attributeName = "implant_info")
    @Field("implant_info")
    private List<ImplantInfo> implantInfo;

    @DynamoDBHashKey(attributeName = "tare_info")
    @Field("tare_info")
    private String tareInfo;

    @DynamoDBHashKey(attributeName = "off_water_info")
    @Field("off_water_info")
    private String offWaterInfo;

    @DynamoDBHashKey(attributeName = "device_set_info")
    @Field("device_set_info")
    private String deviceSetInfo;

    @DynamoDBHashKey(attributeName = "acceptance_status_info")
    @Field("acceptance_status_info")
    private String acceptanceStatusInfo;

    @DynamoDBHashKey(attributeName = "is_del")
    @Field("is_del")
    private String isDel;

    @DynamoDBHashKey(attributeName = "up_date")
    @Field("up_date")
    private String upDate;

    @DynamoDBHashKey(attributeName = "reg_date")
    @Field("reg_date")
    private String regDate;

    @DynamoDBHashKey(attributeName = "is_wheel_chair")
    @Field("is_wheel_chair")
    private String isWheelChair;

    @DynamoDBHashKey(attributeName = "medical_care_info")
    @Field("medical_care_info")
    private MedicalCareInfo medicalCareInfo;

    @DynamoDBHashKey(attributeName = "sch_ext_end_date")
    @Field("sch_ext_end_date")
    private String schExtEndDate;

    @DynamoDBHashKey(attributeName = "sch_ext_status")
    @Field("sch_ext_status")
    private String schExtStatus;

    @DynamoDBHashKey(attributeName = "card_idm")
    @Field("card_idm")
    private String cardIdm;

    @DynamoDBHashKey(attributeName = "old_up_date")
    @Field("old_up_date")
    private String oldUpDate;

    @DynamoDBHashKey(attributeName = "host_notification_info")
    @Field("host_notification_info")
    private String hostNotificationInfo;

    @DynamoDBHashKey(attributeName = "ins_date")
    @Field("ins_date")
    private Date insDate;

    @DynamoDBHashKey(attributeName = "latest_flag")
    @Field("latest_flag")
    private String latestFlag;

    // add #10735 djy start
    @DynamoDBHashKey(attributeName = "dialysis_underlying_disease")
    @Field("dialysis_underlying_disease")
    private String dialysisUnderlyingDisease;

    @DynamoDBHashKey(attributeName = "wheel_chair_cd")
    @Field("wheel_chair_cd")
    private Long wheelChairCd;

    @DynamoDBHashKey(attributeName = "wheel_chair_name")
    @Field("wheel_chair_name")
    private String wheelChairName;

    @DynamoDBHashKey(attributeName = "wheel_chair_weight")
    @Field("wheel_chair_weight")
    private Integer wheelChairWeight;
    // add #10735 djy end

}
