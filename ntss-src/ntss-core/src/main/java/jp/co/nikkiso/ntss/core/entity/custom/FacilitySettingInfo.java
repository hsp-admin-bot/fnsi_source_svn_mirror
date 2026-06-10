package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 施設設定情報Infoクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class FacilitySettingInfo {
  /**
   * 施設設定番号
   */
  private String facilitySettingNo;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 設定名称
   */
  private String settingName;

  /**
   * 値
   */
  private String value;

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
   * システム利用表示区分
   */
  private String systemUseDisp;

}
