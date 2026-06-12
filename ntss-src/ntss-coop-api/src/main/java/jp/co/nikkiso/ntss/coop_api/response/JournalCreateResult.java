package jp.co.nikkiso.ntss.coop_api.response;

import java.util.ArrayList;
import java.util.List;

import org.springframework.http.HttpStatus;

import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 *  ジャーナル作成APIレスポンス
 *
 */
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@Data
@AllArgsConstructor
public class JournalCreateResult {
  @Data
  @NoArgsConstructor
  @JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
  public static class JournalCreateResults {
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

// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    /** 操作番号 */
    private String opeCd;

    /** メッセージ */
    private String message;

    /** 電子カルテ種別 */
    private String key0;

    /** 連携版番号 */
    private String coopVersion;
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  }

    /**
     * コンストラクタ
     * @param httpStatus {@link HttpStatus}
     * @param journal {@link SysCoopJournal} 結果リスト
     * @param error エラーメッセージ
     */
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  public JournalCreateResult(HttpStatus httpStatus, List<SysCoopJournal> journal) {
  public JournalCreateResult(HttpStatus httpStatus, List<SysCoopJournal> journal, String error) {

    this.errorMsg = error;
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    this.status = httpStatus.value();
    this.result = new ArrayList<>();
    // del 2020-10-13 FNSI-改修 外部連携276 夏 start
    //SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    // del 2020-10-13 FNSI-改修 外部連携276 夏 end
    // sys_coop_journal→JournalCreateResultsへ変換
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    if (journal == null || (journal != null && journal.size() == 0)) {
      return;
    }
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    for(SysCoopJournal scj : journal) {
      JournalCreateResults jcr = new JournalCreateResults();
      jcr.setFacilityCd(scj.getFacilityCd());
      jcr.setCtlNo(scj.getCtlNo());
      jcr.setCoopCd(scj.getCoopCd());
      jcr.setCoopCdIndex(scj.getCoopCdIndex());
      jcr.setCrud(scj.getCrud());
      jcr.setDirection(scj.getDirection());
      jcr.setOrdNo(scj.getOrdNo());
      jcr.setCoopOrdNo(scj.getCoopOrdNo());
      jcr.setHospPatId(scj.getHospPatId());
      jcr.setPatId(scj.getPatId());
      // mod 2020-10-13 FNSI-改修 外部連携276 夏 start
      //jcr.baseDate = scj.getBaseDate() == null ? "" : sdf.format(scj.getBaseDate());
      jcr.setBaseDate(scj.getBaseDate() == null ? "" : scj.getBaseDate());
      // mod 2020-10-13 FNSI-改修 外部連携276 夏 end
      jcr.setAnaResult(scj.getAnaResult());
      jcr.setCoopResult(scj.getCoopResult());
      if (scj.getDump() != null) {
        jcr.setMessage64(new String(scj.getDump()));
      }
      jcr.setUserId(scj.getUserId());
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      jcr.setOpeCd(scj.getOpeCd());
      jcr.setMessage(scj.getMessage());
      jcr.setKey0(scj.getKey0());
      jcr.setCoopVersion(scj.getCoopVersion());
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      this.result.add(jcr);
    }
  }

  /** {@link HttpStatus} */
  private int status;

  /** 登録結果 */
  private List<JournalCreateResults> result;

// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /** エラーメッセージ */
  private String errorMsg;
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

}
