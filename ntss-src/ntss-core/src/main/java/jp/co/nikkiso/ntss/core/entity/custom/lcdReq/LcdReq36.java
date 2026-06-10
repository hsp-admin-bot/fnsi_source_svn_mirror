package jp.co.nikkiso.ntss.core.entity.custom.lcdReq;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 仮想端末情報（ログ）クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_main")
@Getter
@Setter
public class LcdReq36 {

  /**
   * イベント発生日時
   */
  private String eventRegDate;

  /**
   * 装置記録メッセージ
   */
  private String machineRecordMessage;

  /**
   * ログ総件数
   */
  private int count;

}
