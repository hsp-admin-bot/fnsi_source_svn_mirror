package jp.co.nikkiso.ntss.coop_api.request;

import org.springframework.util.StringUtils;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

import lombok.Data;

/**
 *  * ジャーナル作成APIリクエスト
 *
 */
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
@Data
public class JournalCreateRequest {
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

  /** 基準日 */
  private String baseDate;

  /** 変換ステータス */
  private String anaResult;

  /** 通信ステータス */
  private String coopResult;

  /** Base64でエンコードされた送信電文 */
  private String message64;

  /** 操作者ID */
  private Long userId;

  // mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
  /** 操作番号 */
//  private String opeId;
  private String opeCd;
  // mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

  // add 2021-02-20 No.538：連携イベントの登録適正化:外部連携api呼び出しタイミング一覧の「患者イベント」対応 孫 start
  /** 患者イベントコード */
  private Long patEventCd;
  // add 2021-02-20 No.538：連携イベントの登録適正化:外部連携api呼び出しタイミング一覧の「患者イベント」対応 孫 end

  // add 2021-06-17 #5261:TSHPlusにおけるデータのジャーナル反映について 孫 start
  /** メッセージ */
  private String message;
  // add 2021-06-17 #5261:TSHPlusにおけるデータのジャーナル反映について 孫 end

  //add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない zhaoqi start
  /** 登録時検査区分 */
  private String regOrderClass;
  //add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない zhaoqi end

// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /** 電子カルテ種別 */
  private String key0;

  /** 連携版番号 */
  private String coopVersion;
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  // #9336 処理保留イベントの最適化処理が正常に行われない 2023-08-09 卓 start
  private String baStatus;
  // #9336 処理保留イベントの最適化処理が正常に行われない 2023-08-09 卓 end

  //add #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 start
  private Long acceptNo;
  //add #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 end

  /**
   * validate
   * @return true OK | false NG
   */
  public boolean validate() {
    // exists
    if (StringUtils.isEmpty(facilityCd) ||
// add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
        StringUtils.isEmpty(opeCd) ||
// add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
        StringUtils.isEmpty(coopCd) ||
        coopCdIndex == null ||
        StringUtils.isEmpty(crud) ||
        StringUtils.isEmpty(direction) ||
        StringUtils.isEmpty(anaResult) ||
        StringUtils.isEmpty(coopResult) ||
        userId == null
        ) return false;

    return true;
  }
}
