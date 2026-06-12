package jp.co.nikkiso.ntss.admin_web.response.treatmentRecord;

import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.ZonedDateTime;

/**
 * 再循環率のResponse.
 */
@AllArgsConstructor
@Getter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class RecirculationRate  {
  /**
   * 生体モニタリング管理番号.
   */
  private Long bioMoniCtlNo;

  /**
   * 日時.
   */
  private ZonedDateTime date;

  /**
   * 再循環率.
   */
  private Integer recirculationRate;

  /**
   * 血流量.
   */
  private Integer bloodFlow;

}
