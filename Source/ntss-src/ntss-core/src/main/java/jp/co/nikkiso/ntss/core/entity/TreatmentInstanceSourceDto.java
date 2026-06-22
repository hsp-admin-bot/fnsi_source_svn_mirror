package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class TreatmentInstanceSourceDto {
  private Long ordNo;

  private Long ctlNo;

  private Long patId;

  private String treatDate;

  private Short treatWeek;

  private Integer indTreatmentCd;

  private Integer indKurCd;

  private Integer indBedCd;

  private String treatStartTime;

  private String treatTime;

  private String schExtEndDate;

  private Integer treatType;

  private String kurName;

  private String bedName;

  private String indMediInfo;

  private String rstDialysisState;
}
