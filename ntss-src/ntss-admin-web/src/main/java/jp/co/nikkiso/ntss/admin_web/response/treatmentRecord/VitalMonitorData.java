package jp.co.nikkiso.ntss.admin_web.response.treatmentRecord;

import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

/**
 * 治療情報（バイタル）のRequest.
 */
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class VitalMonitorData {

  /**
   * バイタル情報.
   */
  private List<MniMonitor> vitalData;
}
