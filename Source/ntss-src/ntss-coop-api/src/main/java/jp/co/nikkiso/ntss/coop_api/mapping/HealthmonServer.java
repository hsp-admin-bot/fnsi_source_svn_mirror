package jp.co.nikkiso.ntss.coop_api.mapping;

import java.sql.Timestamp;

import com.fasterxml.jackson.annotation.JsonFormat;
import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import lombok.Data;

/**
 * IFエッジ<->AWS通信情報
 *
 */
@Data
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class HealthmonServer {
  /** ステータス */
  private String status;

// add 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 start
  /** 接続状態チェック間隔(送信) */
  private String journalInterval;

  /** 接続状態チェック間隔(メンテンス) */
  private String mainInterval;
// add 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 end

  /** 更新日時 */
  @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp moniTime;
}
