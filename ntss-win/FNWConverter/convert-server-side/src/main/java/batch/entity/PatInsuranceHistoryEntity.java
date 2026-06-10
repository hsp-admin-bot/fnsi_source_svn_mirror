package batch.entity;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBHashKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBTable;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;

/**
 * pat_group_detail_historyのEntity.
 */
@DynamoDBTable(tableName="pat_insurance_history")
@Document(collection="pat_insurance_history")
@Getter
@Setter
public class PatInsuranceHistoryEntity {

    @DynamoDBHashKey(attributeName = "insurance_cd")
    @Field("insurance_cd")
    private String insuranceCd;

    @DynamoDBHashKey(attributeName = "pat_id")
    @Field("pat_id")
    private String patId;

    @DynamoDBHashKey(attributeName = "facility_cd")
    @Field("facility_cd")
    private String facilityCd;

    @DynamoDBHashKey(attributeName = "ctl_no")
    @Field("ctl_no")
    private String ctlNo;

    @DynamoDBHashKey(attributeName = "fn_pat_id")
    @Field("fn_pat_id")
    private String fnPatId;

    @DynamoDBHashKey(attributeName = "insu_class")
    @Field("insu_class")
    private String insuClass;

    @DynamoDBHashKey(attributeName = "insu_name")
    @Field("insu_name")
    private String insuName;

    @DynamoDBHashKey(attributeName = "insu_name_short")
    @Field("insu_name_short")
    private String insuNameShort;

    @DynamoDBHashKey(attributeName = "insu_info")
    @Field("insu_info")
    private String insuInfo;

    @DynamoDBHashKey(attributeName = "insu_pub_info")
    @Field("insu_pub_info")
    private String insuPubInfo;

    @DynamoDBHashKey(attributeName = "insu_set_info")
    @Field("insu_set_info")
    private String insuSetInfo;

    @DynamoDBHashKey(attributeName = "insu_self_info")
    @Field("insu_self_info")
    private String insuSelfInfo;

    @DynamoDBHashKey(attributeName = "is_selected")
    @Field("is_selected")
    private String isSelected;

    @DynamoDBHashKey(attributeName = "is_disp")
    @Field("is_disp")
    private String isDisp;

    @DynamoDBHashKey(attributeName = "is_del")
    @Field("is_del")
    private String isDel;

    @DynamoDBHashKey(attributeName = "coop_code")
    @Field("coop_code")
    private String coopCode;

    @DynamoDBHashKey(attributeName = "is_coop")
    @Field("is_coop")
    private String isCoop;

    @DynamoDBHashKey(attributeName = "reg_date")
    @Field("reg_date")
    private String regDate;

    @DynamoDBHashKey(attributeName = "up_date")
    @Field("up_date")
    private String upDate;

    @DynamoDBHashKey(attributeName = "start_date")
    @Field("start_date")
    private String startDate;

    @DynamoDBHashKey(attributeName = "end_date")
    @Field("end_date")
    private String endDate;

    @DynamoDBHashKey(attributeName = "check_date")
    @Field("check_date")
    private String checkDate;

    @DynamoDBHashKey(attributeName = "old_up_date")
    @Field("old_up_date")
    private String oldUpDate;

    @DynamoDBHashKey(attributeName = "memo1")
    @Field("memo1")
    private String memo1;
      
    @DynamoDBHashKey(attributeName = "memo2")
    @Field("memo2")
    private String memo2;

    @DynamoDBHashKey(attributeName = "fn_ctl_no")
    @Field("fn_ctl_no")
    private String fnCtlNo;

    @DynamoDBHashKey(attributeName = "ins_date")
    @Field("ins_date")
    private Date insDate;
}
