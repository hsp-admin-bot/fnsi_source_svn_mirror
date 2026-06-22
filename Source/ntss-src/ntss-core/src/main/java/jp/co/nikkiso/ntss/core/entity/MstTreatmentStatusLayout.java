package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 治療状況レイアウトマスタ情報クラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_treatment_status_layout")
@Getter
@Setter
public class MstTreatmentStatusLayout extends BaseEntity {
  /**
   * 治療状況レイアウト管理番号
   */
  @Id
  private Long layoutNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * レイアウト名
   */
  private String layoutName;
  /**
   * 使用区分
   */
  private String useClass;
  /**
   * DCS表示項目一覧
   */
  private String dcsViewItems;
  /**
   * DAB表示項目一覧
   */
  private String dabViewItems;
  /**
   * DAD表示項目一覧
   */
  private String dadViewItems;
  /**
   * DRO表示項目一覧
   */
  private String droViewItems;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
}
