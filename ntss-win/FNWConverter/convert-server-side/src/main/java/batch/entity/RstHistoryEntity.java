package batch.entity;

import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBHashKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBTable;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

@DynamoDBTable(tableName="rst_history")
@Document(collection="rst_history")
@Getter
@Setter
public class RstHistoryEntity {
    @DynamoDBHashKey(attributeName = "_id")
    @Field("_id")
    private String id;

    @DynamoDBHashKey(attributeName = "ord_no")
    @Field("ord_no")
    private String ord_no;

    @DynamoDBHashKey(attributeName = "rst_edition")
    @Field("rst_edition")
    private String rst_edition;

    @DynamoDBHashKey(attributeName = "up_date")
    @Field("up_date")
    private String up_date;

    @DynamoDBHashKey(attributeName = "up_user_id")
    @Field("up_user_id")
    private String up_user_id;

    @DynamoDBHashKey(attributeName = "up_user_name")
    @Field("up_user_name")
    private String up_user_name;

    @DynamoDBHashKey(attributeName = "message")
    @Field("message")
    private String message;

    @DynamoDBHashKey(attributeName = "facility_cd")
    @Field("facility_cd")
    private String facilityCd;

    @DynamoDBHashKey(attributeName = "_class")
    @Field("_class")
    private String _class;


}
