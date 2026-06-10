package batch.entity;

import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBHashKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBTable;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

/**
 * ind_historyのEntity.
 */
@DynamoDBTable(tableName="ind_history")
@Document(collection="ind_history")
@Getter
@Setter
public class IndHistoryEntity {
    @DynamoDBHashKey(attributeName = "_id")
    @Field("_id")
    private String id;

    @DynamoDBHashKey(attributeName = "pat_id")
    @Field("pat_id")
    @JsonProperty("pat_id")
    private String patId;

    @DynamoDBHashKey(attributeName = "facility_cd")
    @Field("facility_cd")
    @JsonProperty("facility_cd")
    private String facilityCd;

    @DynamoDBHashKey(attributeName = "log_date")
    @Field("log_date")
    @JsonProperty("log_date")
    private String logDate;

    @DynamoDBHashKey(attributeName = "treatment_start_date")
    @Field("treatment_start_date")
    @JsonProperty("treatment_start_date")
    private String treatmentStartDate;

    @DynamoDBHashKey(attributeName = "treatment_end_date")
    @Field("treatment_end_date")
    @JsonProperty("treatment_end_date")
    private String treatmentEndDate;

    @DynamoDBHashKey(attributeName = "treatment_weekday")
    @Field("treatment_weekday")
    @JsonProperty("treatment_weekday")
    private String treatmentWeekday;

    @DynamoDBHashKey(attributeName = "treatment_method")
    @Field("treatment_method")
    @JsonProperty("treatment_method")
    private String treatmentMethod;

    @DynamoDBHashKey(attributeName = "treatment_course")
    @Field("treatment_course")
    @JsonProperty("treatment_course")
    private String treatmentCourse;

    @DynamoDBHashKey(attributeName = "log_target")
    @Field("log_target")
    @JsonProperty("log_target")
    private String logTarget;

    @DynamoDBHashKey(attributeName = "sort_no")
    @Field("sort_no")
    @JsonProperty("sort_no")
    private String sortNo;

    @DynamoDBHashKey(attributeName = "log_class")
    @Field("log_class")
    @JsonProperty("log_class")
    private String logClass;

    @DynamoDBHashKey(attributeName = "log_content")
    @Field("log_content")
    @JsonProperty("log_content")
    private String logContent;

    @DynamoDBHashKey(attributeName = "created_by")
    @Field("created_by")
    @JsonProperty("created_by")
    private String createdBy;

    @DynamoDBHashKey(attributeName = "updated_by")
    @Field("updated_by")
    @JsonProperty("updated_by")
    private String updatedBy;

    @DynamoDBHashKey(attributeName = "created_user_id")
    @Field("created_user_id")
    @JsonProperty("created_user_id")
    private String createdUserId;

    @DynamoDBHashKey(attributeName = "updated_user_id")
    @Field("updated_user_id")
    @JsonProperty("updated_user_id")
    private String updatedUserId;

    @DynamoDBHashKey(attributeName = "_class")
    @Field("_class")
    @JsonProperty("_class")
    private String _class;

    /* #8333 FNWで確認済となっているものが、FNSiの詳細画面では未確認 sichengbo start */
    @DynamoDBHashKey(attributeName = "receiver_1")
    @Field("receiver_1")
    @JsonProperty("receiver_1")
    private String receiver1;
    /* #8333 FNWで確認済となっているものが、FNSiの詳細画面では未確認 sichengbo end */

    /* #8333 FNWで確認済となっているものが、FNSiの詳細画面では未確認 zc start */
    @DynamoDBHashKey(attributeName = "receiver_1_name")
    @Field("receiver_1_name")
    @JsonProperty("receiver_1_name")
    private String receiver1Name;
    /* #8333 FNWで確認済となっているものが、FNSiの詳細画面では未確認 zc end */


    @DynamoDBHashKey(attributeName = "fn_confirm_id")
    @Field("fn_confirm_id")
    @JsonProperty("fn_confirm_id")
    private String fnConfirmId;

    @DynamoDBHashKey(attributeName = "fn_mng_no")
    @Field("fn_mng_no")
    @JsonProperty("fn_mng_no")
    private String fnMngNo;

    @DynamoDBHashKey(attributeName = "fn_category_cd")
    @Field("fn_category_cd")
    @JsonProperty("fn_category_cd")
    private String fnCategoryCd;

    @DynamoDBHashKey(attributeName = "fn_category_sub_no")
    @Field("fn_category_sub_no")
    @JsonProperty("fn_category_sub_no")
    private String fnCategorySubNo;
}
