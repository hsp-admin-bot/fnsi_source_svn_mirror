package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Getter
@Setter
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
public class TreatmentConditionSetting extends BaseEntity{


  private String treatDate;

  private Integer treatmentCd;

  private Integer indKurCd;

  private Short treatWeek;

  private String treatmentConditionSetting;
}
