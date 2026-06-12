package jp.co.nikkiso.ntss.admin_web.response.treatmentRecord;

import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 治療概要のResponse.
 */
@AllArgsConstructor
@Getter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class TreatmentRecordSummary {
  /**
   * 治療日+曜日.
   */
  private String treatmentDate;

  /**
   * ベッド名.
   */
  private String bedName;

  /**
   * クール名.
   */
  private String kurName;

  /**
   * 治療方法名.
   */
  private String treatmentName;
}
