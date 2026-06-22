package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.enums;

import java.util.Arrays;
import java.util.Optional;

/** マージ治療状況 */
public enum MergeOmStatusEnum {

  /** ？？患者治療中 */
  DIALYSIS_U("3", true),
  /** ？？患者排液済 */
  AFTER_DIALYSIS_U("4", true),
  /** ？？患者後体重測定済み(実績未確定) */
  AFTER_WEIGHT_U("5", true),
  /** 指定患者条件送信前 */
  BEFORE_SEND_D("0", false),
  /** 指定患者条件送信済 */
  AFTER_SEND_D("1", false),
  /** 指定患者条件送信確認済み */
  CHECKED_SEND_D("2", false),
  /** 指定患者治療中 */
  DIALYSIS_D("3", false),
  /** 指定患者排液済 */
  AFTER_DIALYSIS_D("4", false),
  /** 指定患者後体重測定済み(実績未確定) */
  AFTER_WEIGHT_D("5", false),
  /** 指定患者後体重確認済み */
  PAST_RECORD_D("6", false);


  /** マージ治療状況 */
  private String mergeOmRds;

  private boolean unknownPat;


  MergeOmStatusEnum(String rds, boolean unknownPat) {
    this.mergeOmRds = rds;
    this.unknownPat = unknownPat;
  }

  public static Optional<MergeOmStatusEnum> getMergeOmStatusByCond(String cd, boolean unknownPat) {

    return Arrays.stream(values())
      .filter(rds -> rds.getMergeOmRds().equals(cd) && rds.getUnknownPat() == unknownPat)
      .findFirst();
  }

  public boolean equals (MergeOmStatusEnum statusEnum) {
    return this.mergeOmRds.equals(statusEnum.getMergeOmRds())
      && this.unknownPat == statusEnum.unknownPat;
  }
  public boolean equals (String rds, boolean unknownPat) {
    return this.mergeOmRds.equals(rds) && this.unknownPat == unknownPat;
  }

  public String getMergeOmRds() {
    return mergeOmRds;
  }

  public boolean getUnknownPat() {
    return unknownPat;
  }
}
