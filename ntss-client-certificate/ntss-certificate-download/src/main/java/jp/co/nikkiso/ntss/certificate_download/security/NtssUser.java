package jp.co.nikkiso.ntss.certificate_download.security;

import java.util.Collection;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.SpringSecurityCoreVersion;
import org.springframework.security.core.userdetails.User;

import lombok.Getter;
import lombok.Setter;

/**
 * {@inheritDoc}
 */
public class NtssUser extends User {

  /**
   * serialVersionUID
   */
  private static final long serialVersionUID = SpringSecurityCoreVersion.SERIAL_VERSION_UID;

  /**
   * ユーザータイプ.
   */
  @Getter
  @Setter
  private String userRole;

  /**
   * ID.
   */
  @Getter
  @Setter
  private String id;

  /**
   * ユーザー名.
   */
  @Getter
  @Setter
  private String userFullname;

  /**
   * ユーザーかどうか.
   */
  @Getter
  @Setter
  private boolean userLogin;

  /**
   * サインイン失敗回数.
   */
  @Getter
  private final Integer numLoginAttempt;

  /**
   * コンストラクタ.
   *
   * @param userId ユーザーID(表示用)
   * @param password パスワード
   * @param id ID
   * @param userFullname ユーザー名
   * @param userRole 利用者種別
   * @param numLoginAttempt サインイン失敗回数
   * @param authorities 権限
   */
  public NtssUser(
    String userId,
    String password,
    String userRole,
    String id,
    String userFullname,
    boolean isUserLogin,
    Integer numLoginAttempt,
    Collection<? extends GrantedAuthority> authorities) {

    super(userId, password, authorities);
    this.userRole = userRole;
    this.id = id;
    this.userFullname = userFullname;
    this.userLogin = isUserLogin;
    this.numLoginAttempt = numLoginAttempt;
  }

}
