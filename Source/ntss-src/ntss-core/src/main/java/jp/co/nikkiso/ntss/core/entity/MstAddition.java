package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * mst_addition(加算マスタ)のエンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_addition")
@Getter
@Setter
public class MstAddition extends BaseBlankEntity {
  /**
   * 加算コード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long additionCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * FNWコード
   */
  private String fnAddCd;

  /**
   * 加算等名称
   */
  private String additionName;

  /**
   * 加算略称
   */
  private String additionShortName;

  /**
  * 登録区分
  */
  private String additionKind;

  /**
   * 種別区分
   */
  private String additionClass;

  /**
   * 算定間隔
   */
  private String additionSpan;

  /**
   * 算定回数上限
   */
  private Long additionLimit;

  /**
   *
   */
  private String additionLimitType;

  /**
   * 算定順番
   */
  private int addCnt_1;

  /**
   * 算定対象
   */
  private String additionCond;

  /**
   * 算定対象コード
   */
  private String additionTarCd;

  /**
   * 連携コード1
   */
  private String inHospitalCd_1;

  /**
   * 連携コード2
   */
  private String inHospitalCd_2;

  /**
   * 連携コード3
   */
  private String inHospitalCd_3;

  /**
   * 算定透析時間
   */
  private Long additionDialysisTime;

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
