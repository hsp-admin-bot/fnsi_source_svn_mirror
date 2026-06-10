package jp.co.nikkiso.ntss.coop_api.request;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeClientConnect;
import lombok.Data;

import java.util.List;

/**
 *  連携エッジクライアント接続状態リクエスト
 *  {@link MntIfEdgeClientConnect}
 */
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
@Data
public class MntIfEdgeClientConnectRequest {
  private String facilityCd;

  private String message;

  private Integer ifEdgeType;

  private List<String> ngIpList;
}
