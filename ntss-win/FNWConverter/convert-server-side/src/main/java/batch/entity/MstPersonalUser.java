package batch.entity;


import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;

import java.sql.Timestamp;

/**
 * 利用者マスタ(個人情報DB)のEntity.
 */
@Entity
@Table(name = "mst_personal_user")
@Getter
@Setter
public class MstPersonalUser extends BaseEntity {

  /**
   * 利用者ID(内部用ID).
   */
  @Id
  private Long userId;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 利用者種別.
   */
  private Integer userType;

  /**
   * 管理者フラグ.
   */
  private Integer administrator;

  /**
   * 患者共有フラグ.
   */
  private Integer patientShared;

  /**
   * 利用者名_姓.
   */
  private String userLastName;

  /**
   * 利用者名_名.
   */
  private String userFirstName;

  /**
   * 利用者カナ名_姓.
   */
  private String userLastNameKana;

  /**
   * 利用者カナ名_名.
   */
  private String userFirstNameKana;

  /**
   * 利用者英字名_姓.
   */
  private String userLastNameAlpha;

  /**
   * 利用者英字名_名.
   */
  private String userFirstNameAlpha;

  /**
   * メールアドレス1.
   */
  private String userEmailAddress1;

  /**
   * メールアドレス2.
   */
  private String userEmailAddress2;

  /**
   * 内線番号.
   */
  private String extensionNo;

  /**
   * 自宅番号.
   */
  private String homeNo;

  /**
   * 携帯番号.
   */
  private String mobilePhoneNo;

  /**
   * FAX番号.
   */
  private String faxNo;

  /**
   * 郵便番号.
   */
  @Column(name="zipcd_3")
  private String zipcd3;

  /**
   * 郵便番号.
   */
  @Column(name="zipcd_4")
  private String zipcd4;

  /**
   * 住所.
   */
  private String address;

  /**
   * 住所ふりがな.
   */
  private String addressKana;

  /**
   * 職種コード.
   */
  private String jobCd;
  
  /**
   * 連携コード1
   */
  private String inHospitalCd_1;

  /**
   * 連携コード2
   */
  private String inHospitalCd_2;

  /**
   * 利用者名を取得します.
   *
   * @return 利用者名_姓+利用者名_名
   */
  public String getUserName() {
    return userLastName + " " + userFirstName;
  }
  
  /**
   * 管理者への表示許可.
   * 0 : 非表示、1 : 仮表示
   */
  private String infoDispToAdmin;
  
  /**
   * 表示フラグ.
   * 0 : 非表示、1 : 仮表示
   */
  private String isDisp;

  /**
   * 削除フラグ.
   * 0 : 通常、1 : 削除
   */
  private String isDel;

  /**
   * 麻酔施用者免許証番号.
   */
  private String anesthesiologistLicenseNo;

  /**
   * サインイン日時.
   */
  private Timestamp signinDate;

  /**
   * 外部キーの取得専用
   */
  private String fnStaffCd;
}
