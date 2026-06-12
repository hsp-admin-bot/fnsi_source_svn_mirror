package jp.co.nikkiso.ntss.core.entity;

import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 * バイタルモニタ項目追加マスタ
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_add_monitor")
@Getter
@Setter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@EqualsAndHashCode(callSuper = false)
public class MstAddMonitor extends BaseEntity{

  /**
   * バイタル・モニタ項目コード
   */
  @Id
  private Long vitalMonitorItemCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * バイタル・モニタ区分
   */
  private String vitalMonitorClass;

  /**
   * バイタル・モニタ項目名称
   */
  private String vitalMonitorItemName;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

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
