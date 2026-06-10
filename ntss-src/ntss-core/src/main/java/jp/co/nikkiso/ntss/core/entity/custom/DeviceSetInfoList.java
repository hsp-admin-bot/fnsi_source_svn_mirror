package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置設定共通処理(抽出)
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class DeviceSetInfoList {
  /**
   * 施設コード
   */
  private String facilityCd;
  
  /**
   * 患者ID
   */
  private Long patId;
  
  /**
   * 指示:クールコード
   */
  private Integer indKurCd;
  
  /**
   * 指示:治療方法コード
   */
  private Integer indTreatmentCd;
}