package jp.co.nikkiso.ntss.coop_api.response;

import java.io.IOException;
import java.util.Map;

import org.springframework.http.HttpStatus;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.mapping.HealthmonFacility;
import jp.co.nikkiso.ntss.coop_api.mapping.HealthmonServer;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeHealthmon;
import lombok.Data;

/**
 *  ヘルスモニタ情報更新APIレスポンス
 *
 */
@Data
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class HealthUpdateResult {
  public HealthUpdateResult(HttpStatus httpStatus, MntIfEdgeHealthmon ifEdgeHealthmon) {
    this.status = httpStatus.value();

    this.ctlNo = ifEdgeHealthmon.getCtlNo();
    this.facilityCd = ifEdgeHealthmon.getFacilityCd();
    this.ifEdgeNo = ifEdgeHealthmon.getIfEdgeNo();

    try {
      this.healthmonServerConn = ifEdgeHealthmon.getHealthmonServerConn() == null ? null
          : ObjectMapperUtil.read(
              ifEdgeHealthmon.getHealthmonServerConn(), HealthmonServer.class);
    } catch (IOException e) {
      // 変換に失敗した場合は、null を設定する
      this.healthmonServerConn = null;
    }
    try {
      this.healthmonFacilityConn = ifEdgeHealthmon.getHealthmonFacilityConn() == null ? null
          : ObjectMapperUtil.readTypeReference(ifEdgeHealthmon.getHealthmonFacilityConn(),
              new TypeReference<Map<String, HealthmonFacility>>() {
              });
    } catch (IOException e) {
      // 変換に失敗した場合は、null を設定する
      this.healthmonFacilityConn = null;
    }
  }

  /** {@link HttpStatus} */
  private Integer status;

  /** 管理番号 */
  private Long ctlNo;

  /** 施設コード */
  private String facilityCd;

  /** IFエッジ番号 */
  private Integer ifEdgeNo;

  /** エッジステータス */
  @JsonInclude(JsonInclude.Include.NON_NULL)
  private Map<String, HealthmonFacility> healthmonFacilityConn;

  /** サーバステータス */
  @JsonInclude(JsonInclude.Include.NON_NULL)
  private HealthmonServer healthmonServerConn;

}
