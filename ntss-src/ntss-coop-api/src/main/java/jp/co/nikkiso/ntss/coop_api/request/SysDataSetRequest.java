package jp.co.nikkiso.ntss.coop_api.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.Map;

/**
 * 連携エッジwebsocket通信リクエスト
 *
 */
@Data
public class SysDataSetRequest {
  /** SQLコード */
  @JsonProperty("sqlCode")
  private Long sqlCode;

  /** 施設コード */
  @JsonProperty("facilityCd")
  private String facilityCd;

  /** キーデータセット */
  @JsonProperty("dataKey")
  private Map<String, Object> dataKey;

}
