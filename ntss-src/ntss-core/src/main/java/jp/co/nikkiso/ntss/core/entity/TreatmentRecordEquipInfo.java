package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 医療材料のEntityクラス（治療記録用）
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_main")
@Getter
@Setter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class TreatmentRecordEquipInfo extends BaseEntity {
  /**
   * システムで管理する一意なオーダ番号.
   */
  @Id
  @JsonIgnore
  private Long ordNo;

  /**
   * 実績：治療状況.
   */
  @JsonProperty("rst_dialysis_state")
  private String rstDialysisState;

  /**
   * 実績：医療材料情報.（jsonb型だが、プロパティの型情報がないので文字列として扱う）
   */
  @JsonProperty("rst_equip_info")
  private String rstEquipInfo;

  // TODO BaseEntityを使用するAPIがすべて返却しないなら、BaseEntityにJsonIgnoreを記載したい。現状テストがないため、判断不可
  @Override
  @JsonIgnore
  public Timestamp getRegDate() {
    return super.getRegDate();
  }

  @Override
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  public Timestamp getUpDate() {
    return super.getUpDate();
  }

  @Override
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  public void setUpDate(Timestamp value) {
    super.setUpDate(value);
  }
}
