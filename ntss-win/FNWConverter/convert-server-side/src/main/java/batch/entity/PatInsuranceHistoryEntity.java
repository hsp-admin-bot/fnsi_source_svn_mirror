package batch.entity;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;

/**
 * pat_group_detail_historyのEntity.
 */
@Document(collection="pat_insurance_history")
@Getter
@Setter
public class PatInsuranceHistoryEntity {

    @Field("insurance_cd")
    private String insuranceCd;

    @Field("pat_id")
    private String patId;

    @Field("facility_cd")
    private String facilityCd;

    @Field("ctl_no")
    private String ctlNo;

    @Field("fn_pat_id")
    private String fnPatId;

    @Field("insu_class")
    private String insuClass;

    @Field("insu_name")
    private String insuName;

    @Field("insu_name_short")
    private String insuNameShort;

    @Field("insu_info")
    private String insuInfo;

    @Field("insu_pub_info")
    private String insuPubInfo;

    @Field("insu_set_info")
    private String insuSetInfo;

    @Field("insu_self_info")
    private String insuSelfInfo;

    @Field("is_selected")
    private String isSelected;

    @Field("is_disp")
    private String isDisp;

    @Field("is_del")
    private String isDel;

    @Field("coop_code")
    private String coopCode;

    @Field("is_coop")
    private String isCoop;

    @Field("reg_date")
    private String regDate;

    @Field("up_date")
    private String upDate;

    @Field("start_date")
    private String startDate;

    @Field("end_date")
    private String endDate;

    @Field("check_date")
    private String checkDate;

    @Field("old_up_date")
    private String oldUpDate;

    @Field("memo1")
    private String memo1;
      
    @Field("memo2")
    private String memo2;

    @Field("fn_ctl_no")
    private String fnCtlNo;

    @Field("ins_date")
    private Date insDate;
}
