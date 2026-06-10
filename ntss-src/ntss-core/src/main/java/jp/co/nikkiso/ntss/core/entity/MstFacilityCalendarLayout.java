package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 施設カレンダーレイアウトマスタ
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_facility_calendar_layout")
@Getter
@Setter
public class MstFacilityCalendarLayout extends BaseEntity {

  /**
   * 施設カレンダーレイアウトコード
   */
  @Id
  private Long facilityCalendarLayoutCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 施設カレンダーのレイアウト名
   */
  private String facilityCalendarLayoutName;

  /**
   * 表示項目
   */
  private String dispItemInfo;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;
}
