package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Data;

import java.sql.Timestamp;

/**
 * 利用者マスタのEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Data
public class MstUserData {

  /**
   * 利用者ID.
   */
  private Long userId;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 施設名.
   */
  private String facilityName;

  /**
   * システム利用設定.
   */
  private String systemUseSetting;

  /**
   * 管理者フラグ.
   * 0:一般ユーザ、1:管理者ユーザ
   */
  private int administrator;
  
  /**
   * 患者共有フラグ.
   * 0:非表示、1:表示
   */
  private int patientShared;

  /**
   * 利用者名.
   * mst_personal_user.userLastName + " " + mst_personal_user.userFirstName
   */
  private String userName;

  /**
   * 仮登録フラグ.
   * 0 : 本登録、1 : 仮登録
   */
  private int isProvisional;

  /**
   * サインイン失敗回数.
   */
  private int failure_cnt;

  /**
   * 表示用利用者ID.
   */
  private String dispUserId;

  /**
   * 利用者種別.
   */
  private int userType;

  /**
   * 利用者名苗字.
   */
  private String userLastName;

  /**
   * 利用者名名前.
   */
  private String userFirstName;

  /**
   * ログインパスワード.
   */
  private String userPassword;

  /**
   * ログインURL.
   */
  private String loginUrl;

  /**
   * メールアドレス1.
   */
  private String userEmailAddress1;

  /**
   * メールアドレス2.
   */
  private String userEmailAddress2;

  /**
   * 職種コード.
   */
  private String jobCd;

  /**
   * 患者ID
   */
  private Long patId;

  /*
   * 患者フラグ
   * pat_id に値が存在する場合に true
   */
  private Boolean patFlg;

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
   * 郵便番号7.
   */
  private String zipcd7;

  /**
   * 自宅住所.
   */
  private String address;

  /**
   * 自宅住所かな.
   */
  private String addressKana;

  /**
   * アクセスカード番号.
   */
  private String cardIdm;

  private String secretKey;
  /**
   * 連携コード1
   */
  private String inHospitalCd_1;

  /**
   * 連携コード2
   */
  private String inHospitalCd_2;

  /**
   * サインイン日時
   */
  private Timestamp signinDate;

}
