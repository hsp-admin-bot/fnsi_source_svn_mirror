package jp.co.nikkiso.ntss.admin_web.service.patHistory;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;

// add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
@Document(collection="pat_group_detail_history")
@Getter
@Setter
public class PatGroupDetailHistory {
  @Field("_id")
  @JsonProperty("_id")
  private String _id;

  /**
   * 患者コード
   */
  @Field("pat_id")
  private String pat_id;
  /**
   * 施設コード
   */
  @Field("facility_cd")
  private String facility_cd;
  /**
   * 患者グループコード
   */
  @Field("pat_group_cd")
  private String pat_group_cd;
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  /**
   * 患者グループ名
   */
  @Field("pat_group_name")
  private String pat_group_name;
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
  @Field("up_date")
  private String up_date;
  @Field("reg_date")
  private String reg_date;

  /* modify by chamaojia 2023-08-09 [9239] データ型の変更  --start */
  @Field("ins_date")
//  private Timestamp ins_date = new Timestamp(0);
  private Date ins_date = new Date();
  /* modify by chamaojia 2023-08-09 [9239] データ型の変更  --end */
}
// add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
