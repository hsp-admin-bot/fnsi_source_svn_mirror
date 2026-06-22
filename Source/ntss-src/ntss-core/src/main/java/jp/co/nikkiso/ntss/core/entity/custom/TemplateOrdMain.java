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
public class TemplateOrdMain {
  /**
   * 患者ID
   */
  private Long pat_id;

  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ord_no;

  // add bug 7578 修正 chen start
  /**
   * 治療日
   */
  private String treat_date;
  // add bug 7578 修正 chen end

  /**
   * 実績：愁訴情報
   */
  private String rst_complaint_info;

  /**
   * 実績：愁訴処置情報
   */
  private String rst_treatment_info;

  /**
   * 実績：愁訴処置者情報
   */
  private String rst_treat_staff_info;
}
