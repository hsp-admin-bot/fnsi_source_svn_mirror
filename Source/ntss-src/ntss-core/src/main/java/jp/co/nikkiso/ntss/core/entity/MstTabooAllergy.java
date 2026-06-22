package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;


import jp.co.nikkiso.ntss.core.entity.entityListener.MstTabooAllergyEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 禁忌・アレルギークラス
 */
@Entity(listener = MstTabooAllergyEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_taboo_allergy")
@Getter
@Setter
public class MstTabooAllergy extends BaseBlankEntity {

  /**
   * 禁忌・アレルギーコード
   */
  @Id
  // mod FNSI-改修内容6618修正 xuty start
  // private Integer tabooAllergyCd;
  private String tabooAllergyCd;
  // mod FNSI-改修内容6618修正 xuty end
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * FNW+で管理する施設内の一意な禁忌・アレルギーコード
   */
  private String fnTabooAllergyCd;
  /**
   * 内容
   */
  private String content;
  /**
   * 詳細
   */
  @Column(name = "detail_info")
  private String detailInfo;
  /**
   * 連携コード1
   */
  private String inHospitalCd_1;
  /**
   * 連携コード2
   */
  private String inHospitalCd_2;
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
