package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.NONE)
@Table(name = "pat_personal_main")
@Getter
@Setter
public class PatIndex extends BaseBlankEntity {
  @Id
  private Long patId;
  private Long index;
}
