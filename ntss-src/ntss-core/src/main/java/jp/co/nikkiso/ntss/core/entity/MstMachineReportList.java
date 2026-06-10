package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置帳票
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MstMachineReportList extends BaseBlankEntity {

  /**
   * レポートCD
   */
  private Long reportCd;

  /**
   * 装置番号
   */
  private Long machineNo;
}