package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstImplantEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

/**
 * インプラントクラス
 */
@Entity(listener = MstImplantEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_implant")
@Getter
@Setter
public class MstImplant extends BaseBlankEntity {
  /**
   * インプラントコード
   */
  @Id
  private Integer implantCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * インプラント名
   */
  private String implantName;
  /**
   * 標準インプラントコード
   */
  private String standardImplantCd;
  /**
   * 連携コード
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
