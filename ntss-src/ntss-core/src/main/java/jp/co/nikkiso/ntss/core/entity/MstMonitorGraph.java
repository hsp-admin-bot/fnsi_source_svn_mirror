package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * モニタグラフマスタのEntity.
 */
@Entity(listener = BaseEntityListener.class , naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_monitor_graph")
@Getter
@Setter
public class MstMonitorGraph extends BaseEntity  {
  /**
   * モニタグラフコード.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer monitorGraphCd;
  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * モニタグラフ名.
   */
  private String monitorGraphName;

  /**
   * 左項目コード.
   */
  private String leftDataIndex;

  /**
   * 左グラフ色.
   */
  private String leftColor;

  //mod FNSI-改修内容 グラフ様式修正 房 start
  /**
   * 左線サイズ
   */
  private String leftLineSize;

  /**
   * 左線タイプ値
   */
  private String leftLineTypeValue;

  /**
   * 左ポイント色
   */
  private String leftPointColor;

  /**
   * 左ポイントサイズ
   */
  private String leftPointSize;

  /**
   * 左ポイントタイプ値
   */
  private String leftPointTypeValue;
  //mod FNSI-改修内容 グラフ様式修正 房 end

  /**
   * 右項目コード.
   */
  private String rightDataIndex;

  /**
   * 右グラフ色.
   */
  private String rightColor;

  /**
   * 表示フラグ.
   */
  private String isDisp;

  /**
   * 削除フラグ.
   */
  private String isDel;

  //mod FNSI-改修内容 グラフ様式修正 房 start
  /**
   * 右線サイズ
   */
  private String rightLineSize;

  /**
   * 右線タイプ値
   */
  private String rightLineTypeValue;

  /**
   * 右ポイント色
   */
  private String rightPointColor;

  /**
   * 右ポイントサイズ
   */
  private String rightPointSize;

  /**
   * 右ポイントタイプ値
   */
  private String rightPointTypeValue;
  //mod FNSI-改修内容 グラフ様式修正 房 end

  /**
   * 左項目元
   */
  private Integer LeftIsMstMonitor;

  /**
   * 右項目元
   */
  private Integer rightIsMstMonitor;

  //mod FNSI-9858-改修内容 グラフ様式追加最大値と最小値 杜天成 start
  /**
   * 左グラフ上限.
   */
  private String leftGraphUpperLimit;

  /**
   * 右グラフ上限.
   */
  private String rightGraphUpperLimit;

  /**
   * 左グラフ下限.
   */
  private String leftGraphLowerLimit;

  /**
   * 右グラフ下限.
   */
  private String rightGraphLowerLimit;
  //mod FNSI-9858-改修内容 グラフ様式追加最大値と最小値 杜天成 end
}
