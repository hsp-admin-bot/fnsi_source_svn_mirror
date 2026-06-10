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
@DynamoDBTable(tableName="pat_group_detail_history")
@Document(collection="pat_group_detail_history")
@Getter
@Setter
public class PatGroupDetailHistoryEntity {

    @DynamoDBHashKey(attributeName = "pat_group_cd")
    @Field("pat_group_cd")
    private String patGroupCd;

    // add #10735 djy start
    @DynamoDBHashKey(attributeName = "pat_group_name")
    @Field("pat_group_name")
    private String patGroupName;
    // add #10735 djy end

    @DynamoDBHashKey(attributeName = "pat_id")
    @Field("pat_id")
    private String patId;

    @DynamoDBHashKey(attributeName = "facility_cd")
    @Field("facility_cd")
    private String facilityCd;

    @DynamoDBHashKey(attributeName = "up_date")
    @Field("up_date")
    private String upDate;

    @DynamoDBHashKey(attributeName = "reg_date")
    @Field("reg_date")
    private String regDate;

    @DynamoDBHashKey(attributeName = "ins_date")
    @Field("ins_date")
    private Date insDate;

}
