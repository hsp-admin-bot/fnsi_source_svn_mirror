package jp.co.nikkiso.ntss.admin_web.response.details;

import com.fasterxml.jackson.annotation.JsonProperty;

import jp.co.nikkiso.ntss.core.entity.custom.MNoticeDetail;
import lombok.NoArgsConstructor;

/**
 * 装置動作記録詳細_緊急発報記録のResponse.
 */
@NoArgsConstructor
public class MNoticeDetailResponse {
  
  /**
   * 緊急発報記録Entity.
   */
  @JsonProperty("mNoticeDetail")
  public MNoticeDetail mNoticeDetail;

}
