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
public class TemplateMonitor {
  /**
   * 患者ID
   */
  private Long pat_id;

  /**
   * モニタデータ
   */
  private String monitor_data;

  /**
   * 発生日時
   */
  private String occur_date;

  // add bug 7578 修正 chen start
  /**
   * 治療日
   */
  private String treat_date;
  // add bug 7578 修正 chen end

}
