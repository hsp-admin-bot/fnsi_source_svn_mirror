package jp.co.nikkiso.ntss.core.entity;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.NONE)
@Data
@Getter
@Setter
public class EntityDao {
  private Long pat_id;
  private String pat_name;
  private String value1;
  private String value2;
  private String value3;
  // add FNSI-No.25　帳票の追加順位  吉 start
  private Integer value4;
  // add FNSI-No.25　帳票の追加順位  吉 end
}
