package jp.co.nikkiso.ntss.coop_api.response;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * sys_data_setの取得レスポンス
 *
 * */
@Data
@AllArgsConstructor
public class SysDataSetResult {

  /** {@link HttpStatus} */
  @JsonProperty("status")
  private int status;

  /** error message */
  @JsonProperty("message")
  private String message;

  /** SysDataSet取得結果 */
  @JsonProperty("results")
  private List<Map<String, Object>> result;
}
