package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 医材のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class Equipment extends BaseEntity {

  /**
   * 分類コード
   */
  private int classType;

  /**
   * 分類名称.
   */
  private String className;

  /**
   * 医療材料コード
   */
  private int equipmentCd;

  /**
   * 医療材料名
   */
  private String equipmentName;

}
