package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * ini連携設定マスタEntity
 *
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MstCoopIniKey extends BaseEntity {
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  private String key0;
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  private String key1;
  private String key2;
  private String keyvalue;
  private String defaultValue;
}
