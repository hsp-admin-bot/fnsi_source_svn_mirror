package jp.co.nikkiso.ntss.api.model;

import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;
import lombok.Data;

/**
 * ジャーナル更新APIリクエスト
 *
 */
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@Data
public class JournalCreateRequestPayload {
  /** 施設コード */
  private String facilityCd;

  /** 電文種別 */
  private String coopCd;

  /** IBM向け_電文付帯情報 */
  private String coopCdIndex;

  /** 電文作成区分 */
  private String crud;

  /** 送信か受信かの向き先(S : 送信, R : 受信) */
  private String direction;

  /** 次世代FutureNetオーダ番号 */
  private Long ordNo;

  /** 電子カルテ連携システムオーダ番号 */
  private String coopOrdNo;

  /** 患者番号(電子カルテ連携システム用) */
  private String hospPatId;

  /** 患者番号(次世代FutureNet用) */
  private Long patId;

  /** 変換ステータス */
  private String anaResult;

  /** 通信ステータス */
  private String coopResult;

  /** Base64でエンコードされた送信電文 */
  private String message64;

  /** 操作者ID */
  private Long userId;

  // mod FNSI-連携イベントの登録適正化 楊 start
  /** 基準日 */
  private String baseDate;

  /** 操作番号 */
  private String opeCd;

  private Long patEventCd;

  /** 登録時検査区分 */
  private String regOrderClass;
}
