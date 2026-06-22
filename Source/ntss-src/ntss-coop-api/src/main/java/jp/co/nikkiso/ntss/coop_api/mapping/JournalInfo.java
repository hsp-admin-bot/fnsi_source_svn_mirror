package jp.co.nikkiso.ntss.coop_api.mapping;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * ジャーナル情報
 *
 */
@AllArgsConstructor
@NoArgsConstructor
@Data
public class JournalInfo {
  /** 管理番号 */
  @JsonProperty("ctl_no")
  private Long ctlNo;
  /** 電文種別 */
  @JsonProperty("coop_cd")
  private String coopCd;
  /** 電文付帯情報 */
  @JsonProperty("coop_cd_index")
  private String coopCdIndex;
  // add bug 7351 ope_cd 追加 chen start
  /** 操作番号 */
  @JsonProperty("ope_cd")
  private String opeCd;
  // add bug 7351 ope_cd 追加 chen end

  // add FNSI-7053 劉全航 start
  // mod 2023-04-13 bug #8550と#8551と#8553の対応 孫 start
  @JsonProperty("reg_date")
  //  private Timestamp regDate;
  private String regDate;
  // mod 2023-04-13 bug #8550と#8551と#8553の対応 孫 end
  //#8551 mod 処理対象となるbackupフォルダの日付が古い 2023-06-05 卓 start
  /** 配信処理開始日時 */
  @JsonProperty("in_reg_date")
  private String inRegDate;
  /** 変換処理開始日時 */
  @JsonProperty("out_reg_date")
  private String outRegDate;
  //#8551 mod 処理対象となるbackupフォルダの日付が古い 2023-06-05 卓 end
  // add FNSI-7053 劉全航 end

  // add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /** 連携版番号 */
  @JsonProperty("coop_version")
  private String coopVersion;
  // add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
}
