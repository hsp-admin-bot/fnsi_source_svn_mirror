package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

/**
 * P-Ca9分割グラフ設定情報Infoクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE,  immutable = true)
@Getter
@Setter
@AllArgsConstructor
public class GraphSettingInfo {
  /**
   * P-Ca9分割グラフ設定番号
   */
  private String graphSettingNo;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * デフォルト値
   */
  private String defaultValue;

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
   * 設定名称
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

}
