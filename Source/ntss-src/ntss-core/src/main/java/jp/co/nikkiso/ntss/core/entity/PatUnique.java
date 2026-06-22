package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.PatUniqueEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;


// mod 10626 データリストのCTR・DW一括登録修正 房 start
@Entity(listener = PatUniqueEntityListener.class, naming = NamingType.NONE)
// mod 10626 データリストのCTR・DW一括登録修正 房 end
@Table(name = "pat_unique")
@Getter
@Setter
public class PatUnique extends BaseBlankEntity {
  @Id
  private Long pat_id;
  private String medical_hst_info;
  private String in_out_visit_history_info;
  private String physical_info;
  private String is_del;
  private String up_date;
  private String reg_date;
  private String facility_cd;
  // add FNSI-排他処理 劉 start
  private String old_up_date_unique;
  // add FNSI-排他処理 劉 end
}
