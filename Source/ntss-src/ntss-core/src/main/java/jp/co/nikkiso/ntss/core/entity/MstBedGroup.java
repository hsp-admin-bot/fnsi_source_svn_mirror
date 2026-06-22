package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 地域マスタのEntity.
 */
@Entity(naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_bed_group")
@Getter
@Setter
public class MstBedGroup extends BaseBlankEntity {

  /**
   * 施設コード.
   */
  private String facilityCd;
  /**
   * ベッドグループコード.
   */
  private String bedGroupCd;
  /**
   * ベッドグループ名.
   */
  private String bedGroupName;
  /**
   * ベッド一覧.
   */
  private String bedList;
  /**
   * FNW+で管理する施設内の一意なベッドグループ番号.
   */
  private int fnBedGroupNo;

  /**
   * 登録日時.
   */
  private Timestamp regDate;

  /**
   * 更新日時.
   */
  private Timestamp upDate;
}
