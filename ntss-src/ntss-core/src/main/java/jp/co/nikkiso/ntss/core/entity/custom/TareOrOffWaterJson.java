package jp.co.nikkiso.ntss.core.entity.custom;

import java.math.BigDecimal;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Data;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Data
public class TareOrOffWaterJson {
  private String name_1;
  private String name_2;
  private String name_3;
  private String name_4;
  private String name_5;
  private BigDecimal weight_1;
  private BigDecimal weight_2;
  private BigDecimal weight_3;
  private BigDecimal weight_4;
  private BigDecimal weight_5;
}
