package jp.co.nikkiso.ntss.core.entity.custom;

import java.math.BigDecimal;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 車いすつき風袋JSON
 *
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Data
@EqualsAndHashCode(callSuper=true)
public class OrdMainRstTareChild extends TareOrOffWaterJson {

  @JsonProperty("wheel_chair_cd")
  private Long wheelChairCd;
  @JsonProperty("wheel_chair_name")
  private String wheelChairName;
  @JsonProperty("wheel_chair_weight")
  private BigDecimal wheelChairWeight;
}
