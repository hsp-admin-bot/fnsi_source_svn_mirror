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
 * 採血管マスタのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_spitz")
@Getter
@Setter
public class MstSpitz extends BaseEntity{

  /**
   * 採血管コード.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long spitzCd;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 採血管名.
   */
  private String spitzName;

  /**
   * ラベル印字項目.
   */
  private String labelPrint;

  // del 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm start
//  /**
//   * 院内院外フラグ.
//   */
//  private String isInHospital;
  // del 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm end

  /**
   * 表示フラグ.
   */
  private String isDisp;

  /**
   * 削除フラグ.
   */
  private String isDel;

}

