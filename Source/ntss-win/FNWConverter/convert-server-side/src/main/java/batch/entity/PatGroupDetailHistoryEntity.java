package batch.entity;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;

/**
 * pat_group_detail_historyのEntity.
 */
@Document(collection="pat_group_detail_history")
@Getter
@Setter
public class PatGroupDetailHistoryEntity {

    @Field("pat_group_cd")
    private String patGroupCd;

    // add #10735 djy start
    @Field("pat_group_name")
    private String patGroupName;
    // add #10735 djy end

    @Field("pat_id")
    private String patId;

    @Field("facility_cd")
    private String facilityCd;

    @Field("up_date")
    private String upDate;

    @Field("reg_date")
    private String regDate;

    @Field("ins_date")
    private Date insDate;

}
