package jp.co.nikkiso.ntss.core.dto.mstWeight;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 体重計マスタから設定済みのスケールベッドの紐づくベッドコードを取得
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ScaleBedSettingBedCd {

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * ベッドコード.
   */
  private Long itemBedCd;

  /**
   * 体重計設定の主キー
   */
  private Long weightCd;

}
