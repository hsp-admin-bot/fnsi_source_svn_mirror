package jp.co.nikkiso.ntss.core.entity.custom;

import java.math.BigDecimal;
import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;

/**
 * バイタルチャート用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
public class Vital implements Comparable<Vital> {

  /**
   * 血圧区分：設定なし.
   */
  public static final String BP_CLASS_BEFORE = "1";

  /**
   * 血圧区分：前血圧.
   */
  public static final String BP_CLASS_AFTER = "2";

  /**
   * データ種別：透析前血圧.
   */
  public static final Integer DATA_TYPE_BP_BEFORE_DIALYSIS = 5;

  /**
   * データ種別：透析後血圧.
   */
  public static final Integer DATA_TYPE_BP_AFTER_DIALYSIS = 6;

  /**
   * 生体モニタリング管理番号.
   */
  public Long bioMoniCtlNo;

  /**
   * データ種別.
   */
  public Integer dataType;

  /**
   * 発生日時.
   */
  public Timestamp occurDate;

  /**
   * 血液区分.
   */
  public String bpClass;

  /**
   * 最高血圧.
   */
  public BigDecimal bpMax;

  /**
   * 最低血圧.
   */
  public BigDecimal bpMin;

  /**
   * 平均血圧.
   */
  public BigDecimal bpAve;

  /**
   * 脈拍.
   */
  public BigDecimal pulse;

  /**
   * 体温.
   */
  public BigDecimal temperature;

  /**
   * 血糖値.
   */
  public BigDecimal bloodSugarLevel;

  /**
   * 削除フラグ.
   */
  public String isDel;

  /**
   * 削除されているかどうか.
   */
  public boolean isDeleted() {
    return "1".equals(this.isDel);
  }

  /**
   * ord_mainのデータかどうか.
   */
  public boolean isOrdMain() {
    return this.dataType == null;
  }

  /**
   * 透析前血圧かどうか.
   */
  public boolean isBpBefore() {
    return BP_CLASS_BEFORE.equals(this.bpClass) || DATA_TYPE_BP_BEFORE_DIALYSIS.equals(this.dataType);
  }

  /**
   * 透析後血圧かどうか.
   */
  public boolean isBpAfter() {
    return BP_CLASS_AFTER.equals(this.bpClass) || DATA_TYPE_BP_AFTER_DIALYSIS.equals(this.dataType);
  }

  /**
   * UTC形式の発生日時を取得.
   */
  public long getOccurDateUtc() {
    return this.occurDate.getTime();
  }

  /**
   * ソート用比較メソッド.
   */
  @Override
  public int compareTo(Vital o) {
    return this.occurDate.compareTo(o.occurDate);
  }

}
