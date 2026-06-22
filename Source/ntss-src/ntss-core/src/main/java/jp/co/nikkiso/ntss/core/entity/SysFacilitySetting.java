package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * sys_facility_setting(システム施設設定)のエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_facility_setting")
@Getter
@Setter
public class SysFacilitySetting extends BaseBlankEntity {
  /**
   * 施設設定番号
   */
  private String facilitySettingNo;

  /**
   * 設定名称
   */
  private String settingName;

  /**
   * 初期値
   */
  private String defaultValue;

  /**
   * 入力分類
   */
  private Integer inputType;

  /**
   * オプション情報
   */
  private String optionValue;

  /**
   * 機能名
   */
  private String functionName;

  /**
   * 操作権限可否
   */
  private Integer makerSetting;

  /**
   * 設定説明
   */
  private String description;

  /**
   * 表示順
   */
  private Double dispOrder;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;

  /**
   * システム利用表示区分
   */
  private String systemUseDisp;
}
