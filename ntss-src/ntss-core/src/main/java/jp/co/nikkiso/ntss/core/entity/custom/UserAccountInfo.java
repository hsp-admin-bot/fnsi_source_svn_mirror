package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.UserAuthentication;
import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.MstUser;
import lombok.Data;

/**
 * ログインユーザ取得用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Data
public class UserAccountInfo {

  /**
   * 利用者ID.
   */
  private Long userId;

  /**
   * 表示ユーザ名.
   */
  private String dispUserId;

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
  @Column(name="patient_shared")
  private Integer patientShared;

  /**
   * 施設コード.
   */
  private String facilityCd;

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
  @Column(name = "user_email_address_1")
  private String userEmailAddress1;

  /**
   * メールアドレス2.
   */
  @Column(name = "user_email_address_2")
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
   * 郵便番号(上3桁).
   */
  @Column(name = "zipcd_3")
  private String zipcd3;

  /**
   * 郵便番号(下4桁).
   */
  @Column(name = "zipcd_4")
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
   * 仮登録フラグ.
   * 0 : 本登録、1 : 仮登録
   */
  private int isProvisional;

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
   * 管理者への表示許可.
   * 0 : 非表示、1 : 仮表示
   */
  private String infoDispToAdmin;

   /**
   * ユーザー設定.
   */
  private MstUser.UserSettings userSettings;

  /**
   * 患者ID.
   */
  private Long patId;

  /**
   * 登録日時.
   */
  private Timestamp regDate;

  /**
   * 更新日時.
   */
  private Timestamp upDate;

  /**
   * シークレットキー.
   */
  private String secretKey;

  /**
   * 個人情報取扱い同意フラグ
   * 0:未同意、1:同意済
   */
  private int isConsent;

  /**
   * 麻酔施用者免許証番号.
   */
  private String anesthesiologistLicenseNo; 

  /**
   * 秘密キー設定フラグ
   * 0:未設定or破棄済、1:設定済
   */
  private Integer isSetQrCode;

  /**
   * パスワード変更日時.
   */
  private Timestamp regPasswordDate;

  /**
   * 施設
   */
  @Transient
  private List<UserAuthentication> canLoginFacilities;
}
