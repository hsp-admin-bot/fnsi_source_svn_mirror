package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 車いすマスタのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_wheel_chair")
@Getter
@Setter
public class MstWheelChair extends BaseEntity {

  /**
   * 車いす管理コード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long wheelChairCd;
  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * FNW+で管理する施設内で一意な車いす管理コード
   */
  private String fnWheelChairCd;
  /**
   * 車いす名称
   */
  private String wheelChairName;

  /**
   * 車いす重量(g)
   */
  private Integer wheelChairWeight;
  /**
   * 車いす校正日
   */
  private Timestamp scaleDate;

  /**
   * 車いす校正者ID
   */
  private Long scaleUserId;
  /**
   * 個人所有フラグ
   */
  private String isPersonal;
  /**
   * 所有患者ID
   */
  private Long patId;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   *    削除フラグ
   */
  private String isDel;
}
