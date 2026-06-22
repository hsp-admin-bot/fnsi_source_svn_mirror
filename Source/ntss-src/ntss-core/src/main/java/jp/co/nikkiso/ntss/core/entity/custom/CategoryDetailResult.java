package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 日常・定期点検履歴
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE, immutable = true)
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class CategoryDetailResult {
  private Long cd;
// mod FNSI-改修内容 点検項目入力の表示順を修正する 陳 start
//  private Long cel_no;
  private Boolean isDisp;
// mod FNSI-改修内容 点検項目入力の表示順を修正する 陳 end

}
