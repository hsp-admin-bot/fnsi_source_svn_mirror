package jp.co.nikkiso.ntss.coop_api.service.patCoopHistory;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;
@Document(collection="pat_unique_history")
@Getter
@Setter
public class PatUniqueHistory {
  @Field("_id")
  @JsonProperty("_id")
  private String _id;
  @Field("pat_id")
  private String pat_id;
  @Field("medical_hst_info")
  private String medical_hst_info;
  @Field("in_out_visit_history_info")
  private String in_out_visit_history_info;
  @Field("physical_info")
  private String physical_info;
  @Field("is_del")
  private String is_del;
  @Field("up_date")
  private String up_date;
  @Field("reg_date")
  private String reg_date;

  /* modify by chamaojia 2023-08-09 [9239] データ型の変更  --start */
  @Field("ins_date")
//  private Timestamp ins_date = new Timestamp(0);
  private Date ins_date = new Date();
  /* modify by chamaojia 2023-08-09 [9239] データ型の変更  --end */

  //add 11007 「pat_unique_history」で「facility_cd」が登録されていない zhao start
  @Field("facility_cd")
  private String facility_cd;
  //add 11007 「pat_unique_history」で「facility_cd」が登録されていない zhao end
}
