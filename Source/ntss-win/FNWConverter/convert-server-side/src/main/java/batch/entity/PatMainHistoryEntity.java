package batch.entity;

import batch.entity.mongo.*;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;
import java.util.List;

/**
 * pat_group_detail_historyのEntity.
 */
@Document(collection="pat_main_history")
@Getter
@Setter
public class PatMainHistoryEntity {

    @Field("pat_id")
    private String patId;

    @Field("facility_cd")
    private String facilityCd;

    @Field("facility_name")
    private String facilityName;

    @Field("is_same")
    private String isSame;

    @Field("is_implant")
    private String isImplant;

    @Field("is_infect")
    private String isInfect;

    @Field("is_diabetes")
    private String isDiabetes;

    @Field("is_blood_suger_exam")
    private String isBloodSugerExam;

    @Field("in_out_current_state")
    private String inOutCurrentState;

    @Field("in_out_plan_state")
    private String inOutPlanState;

    @Field("in_out_plan_date")
    private Date inOutPlanDate;

    @Field("pat_memo_info")
    private List<PatMemoInfo> patMemoInfo;

    @Field("addition_info")
    private List<AdditionInfo> additionInfo;

    @Field("charge_staff_info")
    private List<ChargeStaffInfo>  chargeStaffInfo;

    @Field("pat_group_info")
    private List<PatGroupInfo> patGroupInfo;

    @Field("taboo_allergy_info")
    private List<TabooAllergyInfo> tabooAllergyInfo;

    @Field("infect_info")
    private List<InfectInfo> infectInfo;

    @Field("implant_info")
    private List<ImplantInfo> implantInfo;

    @Field("tare_info")
    private String tareInfo;

    @Field("off_water_info")
    private String offWaterInfo;

    @Field("device_set_info")
    private String deviceSetInfo;

    @Field("acceptance_status_info")
    private String acceptanceStatusInfo;

    @Field("is_del")
    private String isDel;

    @Field("up_date")
    private String upDate;

    @Field("reg_date")
    private String regDate;

    @Field("is_wheel_chair")
    private String isWheelChair;

    @Field("medical_care_info")
    private MedicalCareInfo medicalCareInfo;

    @Field("sch_ext_end_date")
    private String schExtEndDate;

    @Field("sch_ext_status")
    private String schExtStatus;

    @Field("card_idm")
    private String cardIdm;

    @Field("old_up_date")
    private String oldUpDate;

    @Field("host_notification_info")
    private String hostNotificationInfo;

    @Field("ins_date")
    private Date insDate;

    @Field("latest_flag")
    private String latestFlag;

    // add #10735 djy start
    @Field("dialysis_underlying_disease")
    private String dialysisUnderlyingDisease;

    @Field("wheel_chair_cd")
    private Long wheelChairCd;

    @Field("wheel_chair_name")
    private String wheelChairName;

    @Field("wheel_chair_weight")
    private Integer wheelChairWeight;
    // add #10735 djy end

}
