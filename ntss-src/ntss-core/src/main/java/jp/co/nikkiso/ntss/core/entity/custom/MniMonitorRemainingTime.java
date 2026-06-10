package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * モニタデータクラス(必要なフィールドのみ)
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MniMonitorRemainingTime {
  /**
   * 生体モニタリング管理番号
   */
  private long bioMoniCtlNo;

  /**
  * 一意なオーダー番号
  */
  private long ordNo;

  /**
   * 発生日時
   */
  private Timestamp occurDate; 

  /**
  * 経過時間
  */
  private String elapsedTime;

  /**
  * 除水残り時間
  */
  private String remainingTimeRemoval;

  /**
  * 透析残り時間
  */
  private String remainingTimeDialysis;

  // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 start
  /**
   * 終了予定
   * */
  private String ind_end_date;

  /**
   * 終了予測
   * */
  private String ind_end_date_time;
  // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 end
}
