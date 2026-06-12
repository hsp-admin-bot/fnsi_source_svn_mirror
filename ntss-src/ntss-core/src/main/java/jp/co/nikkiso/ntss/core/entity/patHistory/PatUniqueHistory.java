package jp.co.nikkiso.ntss.core.entity.patHistory;

import com.fasterxml.jackson.annotation.JsonProperty;
import jp.co.nikkiso.ntss.core.entity.patHistory.patUniqueHistoryDetail.InOutVisitHistoryInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patUniqueHistoryDetail.MedicalHstInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patUniqueHistoryDetail.PhysicalInfo;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;
import java.util.List;
@Document(collection="pat_unique_history")
@Getter
@Setter
public class PatUniqueHistory {
  @Field("_id")
  @JsonProperty("_id")
  private String _id;
  @Field("pat_id")
  private String pat_id;

  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
  @Field("medical_hst_info")
  // private String medical_hst_info;
  private List<MedicalHstInfo> medical_hst_info;
  @Field("in_out_visit_history_info")
  // private String in_out_visit_history_info;
  private List<InOutVisitHistoryInfo> in_out_visit_history_info;
  @Field("physical_info")
  // private String physical_info;
  private List<PhysicalInfo> physical_info;
  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
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

  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
  @Field("latest_flag")
  private String latest_flag;
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end

  //add 11007 「pat_unique_history」で「facility_cd」が登録されていない zhao start
  @Field("facility_cd")
  private String facility_cd;
  //add 11007 「pat_unique_history」で「facility_cd」が登録されていない zhao end
}
