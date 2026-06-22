package batch.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

/**
 * ind_historyのEntity.
 */
@Document(collection="ind_history")
@Getter
@Setter
public class IndHistoryEntity {
    @Field("_id")
    private String id;

    @Field("pat_id")
    @JsonProperty("pat_id")
    private String patId;

    @Field("facility_cd")
    @JsonProperty("facility_cd")
    private String facilityCd;

    @Field("log_date")
    @JsonProperty("log_date")
    private String logDate;

    @Field("treatment_start_date")
    @JsonProperty("treatment_start_date")
    private String treatmentStartDate;

    @Field("treatment_end_date")
    @JsonProperty("treatment_end_date")
    private String treatmentEndDate;

    @Field("treatment_weekday")
    @JsonProperty("treatment_weekday")
    private String treatmentWeekday;

    @Field("treatment_method")
    @JsonProperty("treatment_method")
    private String treatmentMethod;

    @Field("treatment_course")
    @JsonProperty("treatment_course")
    private String treatmentCourse;

    @Field("log_target")
    @JsonProperty("log_target")
    private String logTarget;

    @Field("sort_no")
    @JsonProperty("sort_no")
    private String sortNo;

    @Field("log_class")
    @JsonProperty("log_class")
    private String logClass;

    @Field("log_content")
    @JsonProperty("log_content")
    private String logContent;

    @Field("created_by")
    @JsonProperty("created_by")
    private String createdBy;

    @Field("updated_by")
    @JsonProperty("updated_by")
    private String updatedBy;

    @Field("created_user_id")
    @JsonProperty("created_user_id")
    private String createdUserId;

    @Field("updated_user_id")
    @JsonProperty("updated_user_id")
    private String updatedUserId;

    @Field("_class")
    @JsonProperty("_class")
    private String _class;

    /* #8333 FNWで確認済となっているものが、FNSiの詳細画面では未確認 sichengbo start */
    @Field("receiver_1")
    @JsonProperty("receiver_1")
    private String receiver1;
    /* #8333 FNWで確認済となっているものが、FNSiの詳細画面では未確認 sichengbo end */

    /* #8333 FNWで確認済となっているものが、FNSiの詳細画面では未確認 zc start */
    @Field("receiver_1_name")
    @JsonProperty("receiver_1_name")
    private String receiver1Name;
    /* #8333 FNWで確認済となっているものが、FNSiの詳細画面では未確認 zc end */


    @Field("fn_confirm_id")
    @JsonProperty("fn_confirm_id")
    private String fnConfirmId;

    @Field("fn_mng_no")
    @JsonProperty("fn_mng_no")
    private String fnMngNo;

    @Field("fn_category_cd")
    @JsonProperty("fn_category_cd")
    private String fnCategoryCd;

    @Field("fn_category_sub_no")
    @JsonProperty("fn_category_sub_no")
    private String fnCategorySubNo;
}
