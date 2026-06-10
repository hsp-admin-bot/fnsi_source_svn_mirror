package jp.co.nikkiso.ntss.admin_web.response;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;

/**
 * データ収集ステータスのResponse.
 */
@AllArgsConstructor
public class GatheringStatusResponse {

  /**
   * データ収集ステータス.
   */
  @JsonProperty("gatheringStatus")
  public Integer gatheringStatus;

}
