package jp.co.nikkiso.ntss.coop_api.response;

import java.util.List;

import org.springframework.http.HttpStatus;

import com.fasterxml.jackson.annotation.JsonProperty;

import jp.co.nikkiso.ntss.coop_api.mapping.DeliveryResult;
import lombok.Data;

/**
 * ジャーナル配信レスポンス
 *
 */
@Data
public class DeliveryResults {

  public DeliveryResults() {}

  /** {@link HttpStatus} */
  @JsonProperty("status")
  private int status;

  /** List<{@link DeliveryResult}> */
  @JsonProperty("result")
  private List<DeliveryResult> result;
}
