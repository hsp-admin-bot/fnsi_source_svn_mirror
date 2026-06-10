package jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class NumberOfInspectionResultExtends extends NumberOfInspectionResult{

  private String layoutCd;

}
