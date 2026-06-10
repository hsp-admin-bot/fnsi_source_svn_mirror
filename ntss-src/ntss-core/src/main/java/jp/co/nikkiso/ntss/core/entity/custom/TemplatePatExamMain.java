package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;

import java.sql.Timestamp;

/**
 * テンプレート値
 */
@Entity
@Getter
@Setter
public class TemplatePatExamMain {
  /**
   * 患者ID
   */
  private Long pat_id;

  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ord_no;

  /**
   * 結果時検査日時
   */
  private Timestamp result_exam_date;

  /**
   * 検査結果情報
   */
  private String exam_result_info;

  /**
   * 検査区分
   */
  private String reg_order_class;

  /**
   * 更新日時
   */
  private Timestamp up_date;

}
