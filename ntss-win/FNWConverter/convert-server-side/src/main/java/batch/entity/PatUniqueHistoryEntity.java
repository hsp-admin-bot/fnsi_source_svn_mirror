package batch.entity;
import batch.entity.mongo.InOutVisitHistoryInfo;
import batch.entity.mongo.MedicalHstInfo;
import batch.entity.mongo.PhysicalInfo;
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
@DynamoDBTable(tableName="pat_unique_history")
@Document(collection="pat_unique_history")
@Getter
@Setter
public class PatUniqueHistoryEntity {

    @DynamoDBHashKey(attributeName = "medical_hst_info")
    @Field("medical_hst_info")
    private List<MedicalHstInfo> medicalHstInfo;

    @DynamoDBHashKey(attributeName = "pat_id")
    @Field("pat_id")
    private String patId;

    @DynamoDBHashKey(attributeName = "in_out_visit_history_info")
    @Field("in_out_visit_history_info")
    private List<InOutVisitHistoryInfo> inOutVisitHistoryInfo;

    @DynamoDBHashKey(attributeName = "physical_info")
    @Field("physical_info")
    private List<PhysicalInfo> physicalInfo;

    @DynamoDBHashKey(attributeName = "is_del")
    @Field("is_del")
    private String isDel;

    @DynamoDBHashKey(attributeName = "up_date")
    @Field("up_date")
    private String upDate;

    @DynamoDBHashKey(attributeName = "reg_date")
    @Field("reg_date")
    private String regDate;

    @DynamoDBHashKey(attributeName = "facility_cd")
    @Field("facility_cd")
    private String facilityCd;

    @DynamoDBHashKey(attributeName = "old_up_date_unique")
    @Field("old_up_date_unique")
    private String oldUpDateUnique;

    @DynamoDBHashKey(attributeName = "ins_date")
    @Field("ins_date")
    private Date insDate;

    @DynamoDBHashKey(attributeName = "latest_flag")
    @Field("latest_flag")
    private String latestFlag;

}
