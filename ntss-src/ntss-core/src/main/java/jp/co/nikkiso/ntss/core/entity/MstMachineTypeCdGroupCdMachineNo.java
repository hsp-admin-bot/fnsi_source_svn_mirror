package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Getter
@Setter
@Entity(naming= NamingType.SNAKE_LOWER_CASE)
public class MstMachineTypeCdGroupCdMachineNo {
  private String machineTypeCd;
  private Long mainteLayoutGroupCd;
  private Long machineNo;
}
