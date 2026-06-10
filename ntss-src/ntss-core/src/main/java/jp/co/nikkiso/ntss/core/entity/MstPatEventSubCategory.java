package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 患者イベントサブカテゴリ
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_pat_event_sub_category")
@Getter
@Setter
public class MstPatEventSubCategory extends BaseEntity {

  /**
   * サブカテゴリコード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long subCategoryCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * カテゴリ名
   */
  private String subCategoryName;
  /**
   * カテゴリコード
   */
  private Long categoryCd;
  /**
   * テンプレートコード
   */
  private Long templateCd;
  /**
   * テンプレートコード
   */
  private Integer useType;
  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

  /**
   * 利用開始日A
   */
  @Column(name = "in_hosp_a_startdate")
  private String inHospAStartdate;
  /**
   * 利用開始日B
   */
  @Column(name = "in_hosp_b_startdate")
  private String inHospBStartdate;
  /**
   * 連携コードA-1
   */
  private String inHospitalCdA1;
  /**
   * 連携コードA-2
   */
  private String inHospitalCdA2;
  /**
   * 連携コードA-3
   */
  private String inHospitalCdA3;
  /**
   * 連携コードA-4
   */
  private String inHospitalCdA4;
  /**
   * 連携コードB-1
   */
  private String inHospitalCdB1;
  /**
   * 連携コードB-2
   */
  private String inHospitalCdB2;
  /**
   * 連携コードB-3
   */
  private String inHospitalCdB3;
  /**
   * 連携コードB-4
   */
  private String inHospitalCdB4;
  /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 start*/
  private String dispItemInfo;
  /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 end*/
}
