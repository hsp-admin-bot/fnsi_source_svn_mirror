package jp.co.nikkiso.ntss.api.model.indHistory;

import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
public class ValiCopyTreatPlan {
  private String ord_no;
  private String dialysis_date_to;
  private String facility_cd;
  private String pat_id;
  private String ind_user;
  private String upd_user;
  private String ind_kur_cd;
  private String ind_bed_cd;
  private Boolean is_including_medicine;
}
