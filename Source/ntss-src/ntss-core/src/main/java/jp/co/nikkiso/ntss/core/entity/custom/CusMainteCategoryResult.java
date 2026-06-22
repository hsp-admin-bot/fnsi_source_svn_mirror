package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 定期点検カテゴリーカスタマイズEntity
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
@NoArgsConstructor
public class CusMainteCategoryResult {
  /**
   * 点検カテゴリコード
   */
  private Long mainteCategoryCd;
  /**
   * 版数
   */
  private Integer editionNo;

}
