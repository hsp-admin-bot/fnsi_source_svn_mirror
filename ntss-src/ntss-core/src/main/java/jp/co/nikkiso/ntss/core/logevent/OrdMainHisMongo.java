package jp.co.nikkiso.ntss.core.logevent;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
@Document(collection="rst_history")
@Getter
@Setter
public class OrdMainHisMongo {
  @Field("_id")
  @JsonProperty("_id")
  private String _id;
  @Field("ord_no")
  private String ordNo;
  @Field("rst_edition")
  private String rstEdition;
  @Field("up_date")
  private String upDate;
  @Field("up_user_id")
  private String upUserId;
  @Field("up_user_name")
  private String upUserName;
  @Field("message")
  private String message;
}
