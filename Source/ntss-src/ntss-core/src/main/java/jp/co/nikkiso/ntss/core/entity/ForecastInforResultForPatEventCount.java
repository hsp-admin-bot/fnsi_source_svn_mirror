package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 患者イベントカテゴリ情報のEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ForecastInforResultForPatEventCount extends BaseEntity {

  /**
   * イベント開始日.
   */
  private String eventStartDate;

  /**
   * カテゴリコード
   */
  private int categoryCd;

  /**
   * カテゴリ名
   */
  private String categoryName;
  
  /**
   * サブカテゴリコード
   */
  private int subCategoryCd;

  /**
   * サブカテゴリ名
   */
  private String subCategoryName;

  /**
   * サブカテゴリ件数
   */
  private int subCategoryCount;

  //add #12462 患者共有情報- 患者カレンダー  by zrx start
  private boolean readonly;
  //add #12462 患者共有情報- 患者カレンダー  by zrx end

}
