package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import jp.co.nikkiso.ntss.core.entity.MstFacility;

/**
 * スケジュール自動延長用施設マスタクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MstFacilityWithSchExtStartEndTime extends MstFacility {
  /**
   * 延長処理開始時刻
   */
  private String schExtStartTime;

  /**
   * 延長処理終了時刻
   */
  private String schExtEndTime;

}
