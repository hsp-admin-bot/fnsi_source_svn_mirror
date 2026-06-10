package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.enums;

import java.util.Arrays;
import java.util.Optional;

/** ベース治療状況 */
public enum BaseOmStatusEnum {

  /** 条件送信前 */
  BEFORE_SEND("0"),
  /** 条件送信済 */
  AFTER_SEND("1"),
  /** 条件送信確認済み */
  CHECKED_SEND("2"),
  /** 治療中 */
  DIALYSIS("3"),
  /** 排液済 */
  AFTER_DIALYSIS("4"),
  /** 後体重測定済み(実績未確定) */
  AFTER_WEIGHT("5"),
  /** 後体重確認済み */
  PAST_RECORD("6");

  /** ベース治療状況 */
  private String baseOmRds;

  BaseOmStatusEnum(String baseOmRds) {
    this.baseOmRds = baseOmRds;
  }

  /** 状態による列挙タイプを取得 */
  public static Optional<BaseOmStatusEnum> getBaseOmStatusByCd (String baseOmRds) {
    return Arrays.stream(values()).filter(rds -> rds.getBaseOmRds().equals(baseOmRds)).findFirst();
  }

  public boolean equals (BaseOmStatusEnum baseOmRds) {
    return this.baseOmRds.equals(baseOmRds.getBaseOmRds());
  }
  public boolean equals (String baseOmRds) {
    return this.baseOmRds.equals(baseOmRds);
  }

  public String getBaseOmRds() {
    return baseOmRds;
  }
}
