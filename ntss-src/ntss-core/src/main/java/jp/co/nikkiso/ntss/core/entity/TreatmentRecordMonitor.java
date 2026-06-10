package jp.co.nikkiso.ntss.core.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * 治療情報のEntity（モニタ）.
 * <p>
 * {@link MniMonitor}の検索結果を格納する.
 * </p>
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
@EqualsAndHashCode(callSuper = false)
public class TreatmentRecordMonitor extends BaseEntity {
  /**
   * 生体モニタリング管理番号.
   */
  private Long bioMoniCtlNo;

  /**
   * モニタデータ.
   */
  private String monitorData;

  /**
   * 削除フラグ.
   * 0 : 通常、1 : 削除
   */
  private String isDel;

  /**
   * 更新者ID（内部）
   */
  private Long updStaffId;

  /**
   * 利用者名_姓
   */
  private String userLastName;

  /**
   * 利用者名_名
   */
  private String userFirstName;

  /**
   * 発生日時.
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp occurDate;

  // TODO BaseEntityを使用するAPIがすべて返却しないなら、BaseEntityにJsonIgnoreを記載したい。現状テストがないため、判断不可
  @Override
  @JsonIgnore
  public Timestamp getRegDate() {
    return super.getRegDate();
  }

  // TODO BaseEntityを使用するAPIがすべて返却しないなら、BaseEntityにJsonIgnoreを記載したい。現状テストがないため、判断不可
  @Override
  @JsonIgnore
  public Timestamp getUpDate() {
    return super.getUpDate();
  }

  /**
   * 発生日時をLocalDateTimeに変換します.
   * @return 発生日時
   */
  @JsonIgnore
  public LocalDateTime getOccurDateAsLocalDateTime() {
    return this.occurDate.toLocalDateTime();
  }

}
