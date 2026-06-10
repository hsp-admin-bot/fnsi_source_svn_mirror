package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Entity(listener = CommonEntityListener.class, naming = NamingType.NONE)
@Table(name = "pat_personal_main")
@Getter
@Setter
public class PatPersonalMain extends BaseBlankEntity {
  @Id
  private Long pat_id;
  private String fn_pat_id;
  private String hosp_pat_id;
  private String nkk_pat_id;
  private String facility_cd;
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
  private Integer pat_sex;
  private String nationality;
  private Integer pat_blood_type_abo;
  private Integer pat_blood_type_rh;
  private Integer pat_blood_type_serovar;
  private Integer in_out_class;
  private String is_die;
  private Integer die_cd;
  private Timestamp die_date;
  private String dial_diff_com_info;
  private Integer severity_cd;
  private Integer transport_cd;
  private String pat_contact_info;
  private String other_contact_info;
  private String vendor_contact_info;
  private String insurance_info;
  private String is_del;
  private String up_date;
  private String reg_date;
  private Integer primary_disease_cd;
  private Integer remote_monitor_service;
  private String remote_monitor_user_id;
  private String remote_monitor_user_pw;
  // add FNSI-排他処理 劉 start
  private String old_up_date_personal;
  // add FNSI-排他処理 劉 end

}
