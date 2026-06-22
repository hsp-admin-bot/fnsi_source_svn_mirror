package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdCheckListParams extends BaseEntity  implements Cloneable{

  private Long ordNo;

  private String rstDialysisState;

}
