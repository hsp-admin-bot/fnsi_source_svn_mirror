package jp.co.nikkiso.ntss.core.entity;

import java.sql.Date;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 地域マスタのEntity.
 */
@Entity(naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_area")
@Getter
@Setter
public class MstArea extends BaseBlankEntity {

  /**
   * 地域コード.
   */
  private String areaCd;

  /**
   * 地域名.
   */
  private String areaName;

  /**
   * 登録日時.
   */
  private Date regDate;

  /**
   * 更新日時.
   */
  private Date upDate;

}
