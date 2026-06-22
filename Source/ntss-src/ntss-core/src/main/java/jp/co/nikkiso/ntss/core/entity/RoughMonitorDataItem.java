package jp.co.nikkiso.ntss.core.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.Map;

@Setter
@Getter
@NoArgsConstructor
public class RoughMonitorDataItem {

  @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
  Timestamp occur_date;

  private Short data_type;

  Map<String, String> monitor_data;

  public RoughMonitorDataItem(Short dataType, Timestamp occurDate, Map<String, String> monitorData) {
    this.data_type = dataType;
    this.occur_date = occurDate;
    this.monitor_data = monitorData;
  }
}
