package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

@Document(collection="rst_history")
@Getter
@Setter
public class RstHistoryEntity {
    @Field("_id")
    private String id;

    @Field("ord_no")
    private String ord_no;

    @Field("rst_edition")
    private String rst_edition;

    @Field("up_date")
    private String up_date;

    @Field("up_user_id")
    private String up_user_id;

    @Field("up_user_name")
    private String up_user_name;

    @Field("message")
    private String message;

    @Field("facility_cd")
    private String facilityCd;

    @Field("_class")
    private String _class;


}
