package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置動作記録詳細_溶解記録取得用Entity
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class DissolutionDetail {
  
  /**
   * 発生日付.
   */
  private String eventRegDate;
  
  /**
   * 発生時刻.
   */
  private String eventRegTime;
  
  /**
   * 内容(溶解記録データ).
   */
  @Column(name = "contents")
  private String dissolutionData;

}
