package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 予実リスト情報のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
@EqualsAndHashCode(callSuper = false)
public class ForecastInforResultForCount extends BaseEntity {

  /**
   * イベント開始日.
   */
  private String eventStartDate;

  /**
   * 院外処方済み件.
   */
  private Integer outOkCount = 0;

  /**
   * 院外処方全件.
   */
  private Integer outCount = 0;

  /**
   * 院内処方済み件.
   */
  private Integer inOkCount = 0;

  /**
   * 院内処方全件.
   */
  private Integer inCount = 0;

  /**
   * 全件済み件.
   */
  private Integer allOkCount = 0;

  /**
   * 全件.
   */
  private Integer allCount = 0;

  //add #12462 患者共有情報- 患者カレンダー  by zrx start
  private boolean readonly;
  //add #12462 患者共有情報- 患者カレンダー  by zrx end
}
