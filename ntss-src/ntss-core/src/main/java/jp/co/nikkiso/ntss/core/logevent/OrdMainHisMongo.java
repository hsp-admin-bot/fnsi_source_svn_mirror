package jp.co.nikkiso.ntss.core.logevent;

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
public class OrdMainHisMongo {
  @DynamoDBHashKey(attributeName = "_id")
  @Field("_id")
  private String _id;

  @DynamoDBHashKey(attributeName = "ord_no")
  @Field("ord_no")
  private String ordNo;

  @DynamoDBHashKey(attributeName = "rst_edition")
  @Field("rst_edition")
  private String rstEdition;

  @DynamoDBHashKey(attributeName = "up_date")
  @Field("up_date")
  private String upDate;

  @DynamoDBHashKey(attributeName = "up_user_id")
  @Field("up_user_id")
  private String upUserId;

  @DynamoDBHashKey(attributeName = "up_user_name")
  @Field("up_user_name")
  private String upUserName;

  @DynamoDBHashKey(attributeName = "message")
  @Field("message")
  private String message;
}
