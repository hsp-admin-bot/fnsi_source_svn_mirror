package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置状態管理の次患者で指定範囲内で直近の治療日時を取得するEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvMntMachineStateForMinimumTreatDate {

  /**
   * 直近の治療予定日
   */
  private String minTreatDate;
}
