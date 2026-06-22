package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;

/**
 * @className: FluidSpeedAndAmountEntity
 * @author: kangjie
 * @date: 2024/08/30 9:37
 * @Version: 1.0
 * @description: 10150_9664
 */
@Getter
@Setter
public class FluidSpeedAndAmountEntity {
  private Long ordNo;
  /**
   * ind json string
   */
  private String indUpdateObjectString;
  /**
   * rst json string
   */
  private String rstUpdateObjectString;

}
