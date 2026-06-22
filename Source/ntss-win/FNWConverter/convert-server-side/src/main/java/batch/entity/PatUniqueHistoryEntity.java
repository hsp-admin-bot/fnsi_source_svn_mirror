package batch.entity;
import batch.entity.mongo.InOutVisitHistoryInfo;
import batch.entity.mongo.MedicalHstInfo;
import batch.entity.mongo.PhysicalInfo;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import java.util.Date;
import java.util.List;

/**
 * pat_group_detail_historyのEntity.
 */
@Document(collection="pat_unique_history")
@Getter
@Setter
public class PatUniqueHistoryEntity {

    @Field("medical_hst_info")
    private List<MedicalHstInfo> medicalHstInfo;

    @Field("pat_id")
    private String patId;

    @Field("in_out_visit_history_info")
    private List<InOutVisitHistoryInfo> inOutVisitHistoryInfo;

    @Field("physical_info")
    private List<PhysicalInfo> physicalInfo;

    @Field("is_del")
    private String isDel;

    @Field("up_date")
    private String upDate;

    @Field("reg_date")
    private String regDate;

    @Field("facility_cd")
    private String facilityCd;

    @Field("old_up_date_unique")
    private String oldUpDateUnique;

    @Field("ins_date")
    private Date insDate;

    @Field("latest_flag")
    private String latestFlag;

}
