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
public class JournalUpdateRequest {
  /** 管理番号 */
  private Long ctlNo;

  //add #9799 クールマスタ変更の場合、「連携エッジヘルスモニタ」を更新しない zhaoqi 20231215 start
  /** 操作番号 */
  private String opeCd;
  //add #9799 クールマスタ変更の場合、「連携エッジヘルスモニタ」を更新しない zhaoqi 20231215 start

  /** 変換ステータス */
  private String anaResult;

  /** 通信ステータス */
  private String coopResult;

  /** 送信電文(Amazon S3に格納されているファイルパス) */
  private String dumpPath;

  /** 操作者ID */
  private Long userId;

  // add 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 start
  /** メッセージ */
  private String message;

  /** レポートコード */
  private Long reportCd;
  // add 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 end

  // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
  /** 次世代FutureNetオーダ番号 */
  private Long ordNo;
  /** 基準日 */
  private String baseDate;
  // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end

  /** 連携オーダ番号 */
  private String coopOrdNo;

  /**
   * validate
   *
   * @return true OK | false NG
   */
  public boolean validate() {
    // exists
    if (ctlNo == null || userId == null) return false;

    return true;
  }
}
