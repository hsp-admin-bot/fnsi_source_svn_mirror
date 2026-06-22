package jp.co.nikkiso.ntss.coop_api.request;

import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;

import lombok.Data;

/**
 * ジャーナル転送APIリクエスト
 *
 */
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@Data
public class CallApiJournalRequest {

  /** 施設コード */
  private String facilityCd;

  /** 電文種別 */
  private String coopCd;

  /** 付帯情報（電文） */
  private String coopCdIndex;

  /** 作成更新区分 */
  private String crud;

  /** 向き（送受信） */
  private String direction;

  /** 発行タイミング（更新） */
  private String apiTimingIo;

  /** 発行タイミング（前後） */
  private String apiTimingBa;

  /** 変換処理ステータス */
  private String anaResult;

  /** 配信処理ステータス */
  private String coopResult;

  /** ユーザID */
  private Long userId;

}
