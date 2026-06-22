package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;

/**
 * テンプレート値
 */
@Entity
@Getter
@Setter
public class TemplateMedicine {
  /**
   * 薬剤コード
   */
  private String medicine_cd;

  /**
   * 分類名称
   */
  private String class_name;

}
