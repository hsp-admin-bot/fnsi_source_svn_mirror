package jp.co.nikkiso.ntss.certificate_download.security;

import java.util.Collection;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.SpringSecurityCoreVersion;

import lombok.Getter;

// import lombok.Getter;

/**
 * NTSS認証トークンクラス.
 */
public class NtssAuthenticationToken extends UsernamePasswordAuthenticationToken {

  /**
   * SerialVersionID.
   */
//  private static final long serialVersionUID = SpringSecurityCoreVersion.SERIAL_VERSION_UID;

  @Getter
  private final boolean userLogin;

  /**
   * コンストラクタ.
   * <p>
   * 認証前の情報で生成する場合
   * </p>
   * @param principal プリンシパル
   * @param credentials 資格情報
   * @param isUserLogin ユーザーかどうか
   */
  public NtssAuthenticationToken(Object principal, Object credentials, boolean isUserLogin) {
    super(principal, credentials);
    this.userLogin = isUserLogin;
  }

  /**
   * コンストラクタ.
   * <p>
   * 認証済みの状態で生成する場合
   * </p>
   * @param principal プリンシパル
   * @param credentials 資格情報
   * @param authorities 認可情報
   * @param isUserLogin ユーザーかどうか
   */
  public NtssAuthenticationToken(Object principal, Object credentials, Collection<? extends GrantedAuthority> authorities, boolean isUserLogin) {
    super(principal, credentials, authorities);
    this.userLogin = isUserLogin;
  }

}
