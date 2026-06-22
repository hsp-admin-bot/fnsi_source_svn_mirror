package jp.co.nikkiso.ntss.core.entity;

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
 * トレンドグラフ：モニタ項目一覧セットクラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_trend_graph_monitor_set")
@Getter
@Setter
public class MstTrendGraphMonitorSet extends BaseEntity {

  /**
   * 項目セットコード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long monitorSetCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 項目セット名
   */
  private String monitorSetName;

  /**
   * 装置種別
   */
  private String model;

  /**
   *  モニタ項目一覧セット
   */
  private String seriesInfo;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

  //add FNSI redmine 5702 劉祥霖　表示項目不正再修正　start
  /**
   * DAD,DRYA,DRYBコード
   */
  private String comFormatCd;
  //add FNSI redmine 5702 劉祥霖　表示項目不正再修正　end
}
