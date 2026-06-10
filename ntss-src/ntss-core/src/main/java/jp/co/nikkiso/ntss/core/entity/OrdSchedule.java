package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;


/**
 * ord_schedule(治療スケジュール)のエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_schedule")
@Getter
@Setter
public class OrdSchedule extends BaseBlankEntity {
  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * オーダ番号
   */
  private Long ordNo;

  /**
   * 治療日
   */
  private String treatDate;

  /**
   * クールコード
   */
  private Long kurCd;

  /**
   * ベッドコード
   */
  private Long bedCd;

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * ダミーフラグ
   */
  private String isDummy;

  /**
   * 更新日時
   */
  private Timestamp upDate;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 治療曜日
   */
  private Short treatWeek;
}
