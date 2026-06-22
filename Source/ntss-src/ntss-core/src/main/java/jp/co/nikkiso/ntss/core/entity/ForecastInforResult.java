package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

/**
 * 予実リスト情報のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@EqualsAndHashCode(callSuper = false)
public class ForecastInforResult extends BaseEntity {

  /**
   * 一意なキー項目値
   */
  private Long uniqueSerial;

  /**
   * イベント開始日.
   */
  private String eventStartDate;

  /**
   * イベント終了日.
   */
  private String eventEndDate;

  /**
   * イベント開始時刻.
   */
  private String eventStartTime;

  /**
   * イベント終了時刻.
   */
  private String eventEndTime;

  /**
   * カテゴリ名称.
   */
  private String categoryName;

  /**
   * サブカテゴリ名称.
   */
  private String subCategoryName;

  /**
   * チェック項目のJSON情報.
   */
  private String jsonValue;

  /**
   * 処方分類.
   */
  private String prescriptionType;

  /**
   * 交付状況.
   */
  private String issueState;

  //add #12462 患者共有情報- 患者カレンダー  by zrx start
  private boolean readonly;
  //add #12462 患者共有情報- 患者カレンダー  by zrx end
}
