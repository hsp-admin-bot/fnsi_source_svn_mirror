package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstStaffFacilityEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 担当者施設マスタのEntity.
 */
@Entity(listener = MstStaffFacilityEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_staff_facility")
@Getter
@Setter
public class MstStaffFacility extends BaseBlankEntity {

  /**
   * 担当者ID.
   */
  @Id
  private Long userId;

  /**
   * 施設コード.
   */
  @Id
  private String facilityCd;

  /**
   * 登録日時.
   */
  private Timestamp regDate;

  /**
   * 更新日時.
   */
  private Timestamp upDate;

}
