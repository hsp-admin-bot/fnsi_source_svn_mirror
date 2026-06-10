package jp.co.nikkiso.ntss.coop_api.request;

import java.util.Map;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * WebSocketで利用するdata-setリクエスト
 */
@Data
@NoArgsConstructor
public class WebSocketDataSetRequest {
  public WebSocketDataSetRequest(Map<String, Object> map) {
    // datakey配下はdatasetにおけるwhere句だけの用途となるのでsqlCodeはdatakeyと同列にする
    if (map.containsKey("sqlCode")) {
      this.sqlCode = Long.parseLong(String.valueOf(map.get("sqlCode")));
      map.remove("sqlCode");
    }
    this.dataKey = map;
  }

  /** sys_data_set.sql_code */
  @JsonProperty("sqlCode")
  private Long sqlCode;

  /** data-setの結果Map<sqlCode, result> */
  @JsonProperty("dataKey")
  private Map<String, Object> dataKey;

}
