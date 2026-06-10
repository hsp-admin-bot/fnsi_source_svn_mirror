package jp.co.nikkiso.ntss.core.entity;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * モニタ項目
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_monitor_item")
@Getter
@Setter
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
@EqualsAndHashCode(callSuper = false)
public class SysMonitorItem extends BaseEntity{

  /**
   * モニタデータ番号
   */
  private String moniDataNo;

  /**
   * モニタデータ種別
   */
  private String moniDataType;

  /**
   * モニタデータ項目名
   */
  private String moniDataName;

  /**
   * モニタデータ短縮名
   */
  private String moniDataShortName;

  /**
   * データ種別
   */
  private Integer dataType;

  /**
   * 小数部桁数
   */
  private Integer decimalFigure;

  /**
   * 単位
   */
  private String unit;

  /**
   * 最大値
   */
  private BigDecimal upper;

  /**
   * 最小値
   */
  private BigDecimal lower;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * バイタル・モニタ区分
   */
  private String vitalMonitorClass;

  /**
   * 変換項目（json)
   */
  private String convItem;

  /**
   * {@inheritDoc}
   * TODO BaseEntityを使用するAPIがすべて返却しないなら、BaseEntityにJsonIgnoreを記載したい。現状テストがないため、判断不可.
   */
  @Override
  public Timestamp getRegDate() {
    return super.getRegDate();
  }

  /**
   * {@inheritDoc}
   * TODO BaseEntityを使用するAPIがすべて返却しないなら、BaseEntityにJsonIgnoreを記載したい。現状テストがないため、判断不可.
   */
  @Override
  public Timestamp getUpDate() {
    return super.getUpDate();
  }
}
