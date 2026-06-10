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
 * バイトルグラフマスタのEntity.
 */
@Entity(listener = BaseEntityListener.class , naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_vital_graph")
@Getter
@Setter
public class MstVitalGraph extends BaseEntity  {
  /**
   * バイトルグラフコード.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer vitalGraphCd;
  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * バイタルグラフ名.
   */
  private String vitalGraphName;

  /**
   * 線色.
   */
  private String vitalLineColor;

  /**
   * 線サイズ.
   */
  private String vitalLineSize;

  /**
   * 線タイプ値
   */
  private String vitalLineTypeValue;

  /**
   * ポイント色
   */
  private String vitalPointColor;

  /**
   * ポイントサイズ
   */
  private String vitalPointSize;

  /**
   * ポイントタイプ値
   */
  private String vitalPointTypeValue;
}
