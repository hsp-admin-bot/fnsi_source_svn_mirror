package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * スケジュール表定期点検・水質管理予定表示用のカスタムエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class SchedulePlanData {

  /**
   * 日付(集計用文字列).
   */
  private String strDate;
  /**
   * ベッドコード
   */
  private Long bedCd;

}
