package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 帳票画面の患者一覧でベッド名とクール名の習得用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainBedAndKur {
  private Long patId;
  private Long indKurCd;
  private Long indBedCd;
  private String kurName;
  private String bedName;
  private String treatDate;
  /**
   * 指示：クール開始時刻
   */
  private String indKurStartTime;
  /**
   * 指示：ベッドマスタ表示順
   */
  private Long indBedOrderIndex;
}
