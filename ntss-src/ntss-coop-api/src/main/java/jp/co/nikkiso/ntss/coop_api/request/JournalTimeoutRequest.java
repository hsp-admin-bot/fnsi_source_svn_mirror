package jp.co.nikkiso.ntss.coop_api.request;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import lombok.Data;

/**
 * ジャーナル更新APIリクエスト
 *
 */
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
@Data
public class JournalTimeoutRequest {

  /** 操作者ID */
  private Long id;
  /** 操作時間 */
  private Long idtime;
  /** 施設コード */
  private String facilityCd;
  /** 電文種別 */
  private String coopCd;
}
