package jp.co.nikkiso.ntss.core.entity.custom.lcdReq;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 仮想端末情報（酸素吸入）クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_main")
@Getter
@Setter
public class LcdReq32 {

  /**
   * 発生日時
   */
  private String occur_date;

  /**
   * 酸素吸入開始日時
   */
  private String oxygen_start;

  /**
   * 酸素吸入量
   */
  private double oxygen_amount;

  /**
   * 処置者コード
   */
  private Long treat_staff_cd;

  /**
   * 処置者名
   */
  private String treat_staff_name;

}
