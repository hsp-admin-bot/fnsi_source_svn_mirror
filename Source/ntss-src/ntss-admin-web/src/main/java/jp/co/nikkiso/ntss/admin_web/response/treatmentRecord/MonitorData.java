package jp.co.nikkiso.ntss.admin_web.response.treatmentRecord;

import com.fasterxml.jackson.annotation.JsonFormat;
import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMonitor;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.List;

/**
 * 治療情報（モニタ）のRequest/Response.
 */
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class MonitorData {

  /**
   * 透析開始日時.
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp rstStartDate;

  /**
   * モニタ情報.
   */
  private List<TreatmentRecordMonitor> ordMonitors;

  /**
   * 更新日時.
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp upDate;

}
