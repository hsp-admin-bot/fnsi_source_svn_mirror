package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstRelationshipEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 続柄クラス
 */
@Entity(listener = MstRelationshipEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_relationship")
@Getter
@Setter
public class MstRelationship extends BaseBlankEntity {
  /**
   * 続柄コード
   */
  @Id
  private Integer relationshipCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 続柄名
   */
  private String relationshipName;
  /**
   * 連携コード1
   */
  private String inHospitalCd_1;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 登録日時
   */
  private Timestamp regDate;
  /**
   * 更新日時
   */
  private Timestamp upDate;
}
