package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import lombok.Getter;
import lombok.Setter;

@Entity(listener = CommonEntityListener.class, naming = NamingType.NONE)
@Table(name = "pat_insurance")
@Getter
@Setter
public class PatInsurance extends BaseBlankEntity {
  @Id
  private Long insurance_cd;
  private Long pat_id;
  private String facility_cd;
  private Long ctl_no;
  private String fn_pat_id;
  private Integer insu_class;
  private String insu_name;
  private String insu_name_short;
  private String start_date;
  private String end_date;
  private String check_date;
  private String insu_info;
  private String insu_pub_info;
  private String insu_set_info;
  private String insu_self_info;
  private String is_selected;
  private String is_disp;
  private String is_del;
  private String coop_code;
  private String is_coop;
  private String reg_date;
  private String up_date;
  // add FNSI-排他処理 劉 start
  private String old_up_date;
  // add FNSI-排他処理 劉 end
  private String memo1;
  private String memo2;
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 zhaoqi start
  private String fn_ctl_no;
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 zhaoqi end
}
