package jp.co.nikkiso.ntss.core.entity;

import java.sql.Date;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 系列施設マスタのEntity.
 */
@Entity(naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_series")
@Getter
@Setter
public class MstSeries extends BaseBlankEntity {

  /**
   * 系列施設コード.
   */
  private String seriesCd;

  /**
   * 系列施設名.
   */
  private String seriesName;

  /**
   * 施設コード.
   */
  private String facilityGroupCd;

  /**
   * 登録日時.
   */
  private Date regDate;

  /**
   * 更新日時.
   */
  private Date upDate;

}
