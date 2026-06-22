package jp.co.nikkiso.ntss.coop_api.response;

import org.springframework.http.HttpStatus;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

import jp.co.nikkiso.ntss.coop_api.mapping.DeliveryResult;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage;
import lombok.Data;

/**
 * 連携エッジ指示レスポンス
 *
 */
@Data
public class IfEdgeRestResult {

  public IfEdgeRestResult() {}

  /** {@link HttpStatus} */
  @JsonProperty("status")
  private String status;

  /** List<{@link DeliveryResult}> */
  @JsonProperty("result")
  private MntIfEdgeManage.EdgeResult result;

  /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
  @JsonIgnore
  private String additionalMessage;
  /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
}
