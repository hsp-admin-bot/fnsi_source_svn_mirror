package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(listener = CommonEntityListener.class, naming = NamingType.NONE)
@Table(name = "mst_insurance")
@Getter
@Setter
public class MstInsurance extends BaseBlankEntity {
  @Id
  private Long insu_cd;
  private String facility_cd;
  private String name;
  private String insu_name;
  private String insu_name_short;
  private String futan_g;
  private String futan_n;
  private String insu_type;
  private String reg_date;
  private String up_date;
  private String is_disp;
  private String is_del;
  private String in_hospital_cd_1;
  private String in_hospital_cd_2;
}
