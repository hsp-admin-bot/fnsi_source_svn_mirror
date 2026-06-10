package jp.co.nikkiso.ntss.admin_web.response.treatmentRecord;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
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
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class VitalMonitorData {

  /**
   * バイタル情報.
   */
  private List<MniMonitor> vitalData;
}
