package jp.co.nikkiso.ntss.coop_api.request;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

/**
 * ジャーナル配信リクエスト
 *
 */
@Data
public class JournalDeliveryRequest {
  @JsonProperty("facility_cd")
  /** 施設コード */
  private String facilityCd;

  // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 start
  @JsonProperty("send_type")
  /** 送信種別 */
  private String sendType;
  // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 end

  // add 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 start
  @JsonProperty("stop_coop_cd_list")
  /** 配信停止の電文種別 */
  private String stopCoopCdList;
  // add 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 end
}
