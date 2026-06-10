package jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
public class TargetPhysicalInfo {
  private BigDecimal dw;
  private BigDecimal preScaleLower;
  private BigDecimal preScaleUpper;
  private BigDecimal patHeight;
}
