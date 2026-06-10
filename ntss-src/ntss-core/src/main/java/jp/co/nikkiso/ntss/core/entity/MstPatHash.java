package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 患者用施設マスタハッシュのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_pat_hash")
@Getter
@Setter
public class MstPatHash extends BaseEntity {
  
  /**
   * 施設コード.
   */
  @Id
  private String facilityCd;
  
  /**
   * ハッシュ値.
   */
  private String hashValue;
  
}

