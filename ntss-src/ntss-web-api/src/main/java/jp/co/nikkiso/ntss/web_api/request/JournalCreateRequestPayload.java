package jp.co.nikkiso.ntss.web_api.request;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

import lombok.Data;

/**
 * ジャーナル更新APIリクエスト
 *
 */
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
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

  /** 基準日 */
  private String baseDate;

// mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
  /** 操作番号 */
//  private String opeId;
  private String opeCd;
// mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

  /* add #9056 by zhangruixue 2023-07-03 --start */
  /**登録時検査区分 0:その他; 1:透析前; 2-透析後 */
  private String regOrderClass;
  /* add #9056 by zhangruixue 2023-07-03 --end */

}
