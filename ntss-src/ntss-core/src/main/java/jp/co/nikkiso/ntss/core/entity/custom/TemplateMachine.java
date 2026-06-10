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
public class TemplateMachine {

  /**
   * 患者ID
   */
  private Long pat_id;

  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ord_no;

  /**
   * イベント発生日時
   */
  private String event_reg_date;

  /**
   * 装置記録メッセージ
   */
  private String machine_record_message;

  // add bug 7578 修正 chen start
  /**
   * 治療日
   */
  private String treat_date;
  // add bug 7578 修正 chen end

}
