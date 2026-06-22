package jp.co.nikkiso.ntss.admin_web.request.userAccount;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * ユーザアカウント情報更新APIのRequestクラス
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class UpdateUserAccountInfoRequest {

  /**
   * ユーザID.
   */
  private Long userId;

  /**
   * 表示用ユーザID.
   */
  private String dispUserId;

  /**
   * パスワード.
   */
  private String userPassword;

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
   * 郵便番号3.
   */
  private String zipcd3;

  /**
   * 郵便番号4.
   */
  private String zipcd4;

  /**
   * 自宅住所.
   */
  private String address;

  /**
   * 自宅住所かな.
   */
  private String addressKana;

  /**
   * 仮登録フラグ.
   */
  private Integer isProvisional;

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
   * メニュー表示フラグ.
   */
  private Integer isDispMenu;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 麻酔施用者免許証番号.
   */
  private String anesthesiologistLicenseNo; 
  /**
   * 管理者への表示許可.
   */
  private String infoDispToAdmin;

  /**
   * パスワード履歴.
   */
  private String userPasswordHistory;

  /**
   * ログイン可能な施設
   */
  private List<UserAuthenticationRequest> canLoginFacilitiesList;

}
