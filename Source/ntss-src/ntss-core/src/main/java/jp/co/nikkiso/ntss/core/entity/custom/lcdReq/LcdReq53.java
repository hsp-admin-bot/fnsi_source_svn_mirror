package jp.co.nikkiso.ntss.core.entity.custom.lcdReq;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 仮想端末情報（CTRトレンド）クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class LcdReq53 {

  /**
   * CTR測定日
   */
  private String treatDate;

  /**
   * CTR
   */
  private String ctr;

  /**
   * CTR体重
   */
  // #11175 2024.10.17 mod ctr_weight は文字列で保存されている TDC片口 start
//  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
//  // private String ctrWeight;
//  private BigDecimal ctrWeight;
//  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  private String ctrWeight;
  // #11175 2024.10.17 mod ctr_weight は文字列で保存されている TDC片口 end

}
