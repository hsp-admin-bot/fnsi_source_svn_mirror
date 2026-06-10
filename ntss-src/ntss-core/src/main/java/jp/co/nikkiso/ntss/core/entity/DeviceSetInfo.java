package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.DeviceSetInfoEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 装置設定クラス
 */
@Entity(listener = DeviceSetInfoEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class DeviceSetInfo  extends BaseBlankEntity {
  /**
   * 装置設定
   */

  // 装置設定情報
  private String deviceInfo;

  // 風袋情報
  private String tare_info;

  // 除水情報
  private String off_water_info;

  // ホスト報知情報
  private String host_notification_info;

  // 曜日パターン
  private String day_of_week;

  // ord番号
  private String ord_no;

  // 患者ID
  private String pat_id;

  // 治療状況
  private String rstDialysisState;

  // ベッド名
  private String indBedName;

  // クール名
  private String indKurName;

  // 治療日
  private String treatDate;

  // 治療曜日
  private String treatWeek;
}
