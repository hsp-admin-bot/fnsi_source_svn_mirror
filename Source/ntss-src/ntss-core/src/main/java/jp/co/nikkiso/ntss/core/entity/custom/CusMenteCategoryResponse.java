package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 検査のカテゴリ情報Entity
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class CusMenteCategoryResponse {
  /**
   * 点検カテゴリコード
   */
  private Long mainteCategoryCd;
  /**
   * 版数
   */
  private Integer editionNo;
  /**
   * カテゴリー名
   */
  private String categoryName;
  /**
   * 詳細
   */
  private String detail;
  /**
   * 用途
   */
  private String mainteClass;
  /**
   * 更新日時.
   */
  private Timestamp upDate;
}
