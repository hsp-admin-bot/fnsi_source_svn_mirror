package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import jp.co.nikkiso.ntss.core.entity.entityListener.MstPatCalendarLayoutEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 患者カレンダーレイアウトクラス
 */
@Entity(listener = MstPatCalendarLayoutEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_pat_calendar_layout")
@Getter
@Setter
public class MstPatCalendarLayout extends BaseEntity {
  /**
   * 患者カレンダーレイアウトコード
   */
  @Id
  private long patCalendarLayoutCd;
  /**
   * 施設コード
   */
  @Id
  private String facilityCd;
  /**
   * 患者カレンダーレイアウト名
   */
  private String patCalendarLayoutName;
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
  /**
   * 表示区分
   */
  private String dispClass;
}
