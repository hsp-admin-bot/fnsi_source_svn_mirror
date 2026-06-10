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
 * mst_rad_set(放射線検査セットマスタ)のエンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_rad_set")
@Getter
@Setter
public class MstRadSet extends BaseBlankEntity {
  /**
   * システムで管理する一意な放射線検査セットコード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long radSetCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * FNW+で管理する施設内の一意な検査セットコード
   */
  private String fnExamSetCd;

  /**
   * 検査項目名
   */
  private String radSetName;

  /**
   * 省略　検査セット名
   */
  private String radSetAbbName;

  /**
   * 検査項目情報
   */
  private String radItemInfo;

  /**
   * 連携コード1
   */
  private String inHospitalCd1;

  /**
   * 属性コード1
   */
  private String sbtCd1;

  /**
   * 連携コード2
   */
  private String inHospitalCd2;

  /**
   * 属性コード2
   */
  private String sbtCd2;

    /**
   * 連携コード3
   */
  private String inHospitalCd3;

  /**
   * 属性コード3
   */
  private String sbtCd3;

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
