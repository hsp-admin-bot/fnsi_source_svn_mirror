package jp.co.nikkiso.ntss.coop_api.mapping;

import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.coop_api.mapping.ProtocolInfoWrapper.ProtocolInfo;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 配信(/journal/delivery)レスポンス用のMapping
 *
 */
@AllArgsConstructor
@NoArgsConstructor
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@Data
public class DeliveryResult {
  /** ジャーナル情報 */
  @JsonProperty("journalInfo")
  private JournalInfo journalInfo;

  /** 配信先プロトコル情報 */
  @JsonProperty("protocolInfo")
  private ProtocolInfo protocolInfo;

  /** 配信電文情報 */
  @JsonProperty("data")
  private TelegramMetaData data;
}
