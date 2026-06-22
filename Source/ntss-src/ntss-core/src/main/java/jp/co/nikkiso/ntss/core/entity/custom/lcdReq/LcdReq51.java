package jp.co.nikkiso.ntss.core.entity.custom.lcdReq;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 仮想端末情報（穿刺／回収／担当）クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class LcdReq51 {

  /**
   * 穿刺日時
   */
  private String punctureDate;

  /**
   * 穿刺者コード１
   */
  private Long puserId1;

  /**
   * 穿刺者名１
   */
  private String puserName1;

  /**
   * 穿刺者登録日時１
   */
  private String puserDate1;

  /**
   * 穿刺者コード２
   */
  private Long puserId2;

  /**
   * 穿刺者名２
   */
  private String puserName2;

  /**
   * 穿刺者登録日時２
   */
  private String puserDate2;

  /**
   * 返血日時
   */
  private String returnDate;

  /**
   * 返血者コード１
   */
  private Long ruserId1;

  /**
   * 返血者名１
   */
  private String ruserName1;

  /**
   * 返血者登録日時１
   */
  private String ruserDate1;

  /**
   * 返血者コード２
   */
  private Long ruserId2;

  /**
   * 返血者名２
   */
  private String ruserName2;

  /**
   * 返血者登録日時２
   */
  private String ruserDate2;

  /**
   * 担当者コード１
   */
  private Long cuserId1;

  /**
   * 担当者名１
   */
  private String cuserName1;

  /**
   * 担当者登録日時１
   */
  private String cuserDate1;

  /**
   * 担当者コード２
   */
  private Long cuserId2;

  /**
   * 担当者名２
   */
  private String cuserName2;

  /**
   * 担当者登録日時２
   */
  private String cuserDate2;

  // #11827 2025.05.15 add 必要な項目を追加 TDC米沢 start
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 穿刺者１：姓
   */
  private String puserLastName1;
  /**
   * 穿刺者１：名
   */
  private String puserFirstName1;
  /**
   * 穿刺者２：姓
   */
  private String puserLastName2;
  /**
   * 穿刺者２：名
   */
  private String puserFirstName2;
  /**
   * 返血者１：姓
   */
  private String ruserLastName1;
  /**
   * 返血者１：名
   */
  private String ruserFirstName1;
  /**
   * 返血者２：姓
   */
  private String ruserLastName2;
  /**
   * 返血者２：名
   */
  private String ruserFirstName2;
  /**
   * 担当者１：姓
   */
  private String cuserLastName1;
  /**
   * 担当者１：名
   */
  private String cuserFirstName1;
  /**
   * 担当者２：姓
   */
  private String cuserLastName2;
  /**
   * 担当者２：名
   */
  private String cuserFirstName2;
  // #11827 2025.05.15 add 必要な項目を追加 TDC米沢 end
}
