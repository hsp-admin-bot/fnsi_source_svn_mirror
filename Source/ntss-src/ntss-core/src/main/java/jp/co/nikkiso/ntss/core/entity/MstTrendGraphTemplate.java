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

import java.math.BigDecimal;

/**
 * トレンドグラフ：グラフテンプレートクラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_trend_graph_template")
@Getter
@Setter
public class MstTrendGraphTemplate extends BaseEntity {

  /**
   * テンプレートコード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long templateCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * テンプレート名称
   */
  private String templateName;

  /**
   * 装置種別
   */
  private String model;

  /**
  *  縦軸範囲（右）最大値
  */
  private BigDecimal verticalRangeRightMax;

  /**
  *  縦軸範囲（右）最小値
  */
  private BigDecimal verticalRangeRightMin;

  /**
  *  縦軸範囲（左）最大値
  */
  private BigDecimal verticalRangeLeftMax;

  /**
  *  縦軸範囲（左）最小値
  */
  private BigDecimal verticalRangeLeftMin;

  /**
  *  グラフ系列情報
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
