package jp.co.nikkiso.ntss.core.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 * 治療情報のEntity（設定値読み込み履歴情報）.
 */
@Entity(immutable = true, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_treat_condition")
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class TreatmentRecordSetting extends BaseBlankEntity {

  /**
   * 条件取得日時.
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private final Timestamp receiveDate;

  /**
   * 治療条件.
   */
  private final String treatCondition;

  /**
   * 区分.
   */
  private final Short treatClass;

  public TreatmentRecordSetting(Timestamp receiveDate, String treatCondition, Short treatClass) {
    this.receiveDate = receiveDate;
    this.treatCondition = treatCondition;
    this.treatClass = treatClass;
  }

  @JsonProperty("receive_date")
  public Timestamp getReceiveDate() {
    return receiveDate;
  }

  @JsonProperty("treat_condition")
  public String getTreatCondition() {
    return treatCondition;
  }

  @JsonProperty("treat_class")
  public Short getTreatClass() {
    return treatClass;
  }
}
