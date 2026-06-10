package jp.co.nikkiso.ntss.coop_api.response;

import org.springframework.http.HttpStatus;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import lombok.Data;

@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
@Data
public class JournalUpdateResult {
  public JournalUpdateResult(HttpStatus httpStatus, SysCoopJournal journal) {
    this.status = httpStatus.value();
    this.facilityCd = journal.getFacilityCd();
    this.ctlNo = journal.getCtlNo();
    this.coopCd = journal.getCoopCd();
    this.coopCdIndex = journal.getCoopCdIndex();
    this.crud = journal.getCrud();
    this.direction = journal.getDirection();
    this.anaResult = journal.getAnaResult();
    this.coopResult = journal.getCoopResult();
    this.dumpPath = journal.getDumpPath();
    this.userId = journal.getUserId();
  }

  /** {@link HttpStatus} */
  private Integer status;

  /** 施設コード */
  private String facilityCd;

  /** 管理番号 */
  private Long ctlNo;

  /** 電文種別 */
  private String coopCd;

  /** IBM向け_電文付帯情報 */
  private String coopCdIndex;

  /** 電文作成区分 */
  private String crud;

  /** 送信か受信かの向き先(S : 送信, R : 受信) */
  private String direction;

  /** 変換ステータス */
  private String anaResult;

  /** 通信ステータス */
  private String coopResult;

  /** 送信電文(Amazon S3に格納されているファイルパス) */
  private String dumpPath;

  /** 操作者ID */
  private Long userId;
}
