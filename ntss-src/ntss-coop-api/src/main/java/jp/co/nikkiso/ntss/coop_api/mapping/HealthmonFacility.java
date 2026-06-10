package jp.co.nikkiso.ntss.coop_api.mapping;

import java.sql.Timestamp;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import lombok.Data;

/**
 * IFエッジ<->外部システム通信情報
 *
 */
@Data
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class HealthmonFacility {
  /** ステータス */
  private String status;

  /** 電文の種類 */
  private String type;

  /** 更新日時 */
  @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp moniTime;

}
