package jp.co.nikkiso.ntss.core.entity;

import lombok.Data;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Data
public class PatientFacilityInfo {
  private Long patientId;
  private String facilityCd;
}
