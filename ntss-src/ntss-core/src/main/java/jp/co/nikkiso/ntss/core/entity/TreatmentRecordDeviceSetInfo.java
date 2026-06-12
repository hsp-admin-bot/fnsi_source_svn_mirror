package jp.co.nikkiso.ntss.core.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;
import lombok.AllArgsConstructor;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 治療情報のEntity（装置設定情報用）.
 */
@Entity(immutable = true, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_main")
@AllArgsConstructor
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class TreatmentRecordDeviceSetInfo extends BaseBlankEntity {
  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//  /**
//   * 実績：装置設定情報.
//   */
//  private final String rstDeviceSetInfo;
  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
  /**
   * システムで管理する一意な患者ID.
   */
  private final Long patId;

  /**
   * 施設コード.
   */
  private final String facilityCd;

  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//  @JsonProperty("rst_device_set_info")
//  public String getRstDeviceSetInfo() {
//    return rstDeviceSetInfo;
//  }
  /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
  @JsonProperty("pat_id")
  public Long getPatId() {
    return patId;
  }

  @JsonProperty("facility_cd")
  public String getFacilityCd() {
    return facilityCd;
  }
}
