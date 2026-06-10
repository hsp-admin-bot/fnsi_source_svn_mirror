package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatientInfoSharing {
  private Long patId;
  private Long patNameId;
  private Long patIdSharing;
  private String facilityCd;
  @Transient
  private Integer shareFromCount;
  @Transient
  private Integer shareToCount;
  @Transient
  private Integer pendingCount;
  private Integer prohibitedCount;
  private Integer pat_blood_type_abo;
  private Integer pat_blood_type_rh;
  private Integer pat_blood_type_serovar;
  private String hosp_pat_id;
  private String pat_last_name;
  private String pat_first_name;
  private String pat_last_name_kana;
  private String pat_first_name_kana;
  private String pat_last_name_alpha;
  private String pat_first_name_alpha;
  private String pat_birth_name;
  private String pat_birth_name_kana;
  private String pat_birth_name_alpha;
  private String pat_birthday;
  private String birthday;
  private Integer pat_sex;
  private String is_same;
  private String pat_contact_info;
  private String address;
  private Integer in_out_class;
}
