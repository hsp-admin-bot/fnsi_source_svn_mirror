package jp.co.nikkiso.ntss.coop_api.request;

import java.util.Map;

import org.springframework.util.StringUtils;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.coop_api.mapping.HealthmonFacility;
import jp.co.nikkiso.ntss.coop_api.mapping.HealthmonServer;
import lombok.Data;

/**
 * ヘルスモニタ情報更新APIリクエスト
 *
 */
@Data
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class HealthUpdateRequest {
  /** 施設コード */
  private String facilityCd;

// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /** 連携版番号 */
  private String coopVersion;
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /** IFエッジ番号 */
  private Integer ifEdgeNo;

  /** エッジステータス */
  private Map<String, HealthmonFacility> healthmonFacilityConn;

  /** サーバステータス */
  private HealthmonServer healthmonServerConn;

  /**
   * validate
   * @return true OK | false NG
   */
  public boolean validate() {
    // 検索条件のため必須
    if (StringUtils.isEmpty(facilityCd)
        || ifEdgeNo == null
        // 更新する項目のため どちらか必須
        || (healthmonServerConn == null && healthmonFacilityConn == null))
      return false;

    // 下の階層も確認
    // サーバステータス
    if (healthmonServerConn != null && StringUtils.isEmpty(healthmonServerConn.getStatus())) {
      return false;
    }

    // エッジステータス
    if (healthmonFacilityConn != null) {
      if(healthmonFacilityConn.isEmpty()) {
        return false;
      }

      for (HealthmonFacility healthmonFacility : healthmonFacilityConn.values()) {
        if (healthmonFacility == null
            || StringUtils.isEmpty(healthmonFacility.getStatus())) {
          return false;
        }
      }
    }

    return true;
  }
}
