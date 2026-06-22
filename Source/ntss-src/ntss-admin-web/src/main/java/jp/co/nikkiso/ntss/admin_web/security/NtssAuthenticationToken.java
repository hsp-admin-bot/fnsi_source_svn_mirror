package jp.co.nikkiso.ntss.admin_web.security;

import java.util.Collection;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.SpringSecurityCoreVersion;

import lombok.Getter;

/**
 * NTSS認証トークンクラス.
 */
public class NtssAuthenticationToken extends UsernamePasswordAuthenticationToken {

  /**
   * SerialVersionID.
   */
  private static final long serialVersionUID = SpringSecurityCoreVersion.SERIAL_VERSION_UID;

  /**
   * 施設コード.
   */
  @Getter
  private final String facilityCd;

  /**
   * 機能コード.
   */
  @Getter
  private final String funcCd;

  /**
   * カードコード
   */
  @Getter
  private String cardCd;

  /**
   * モード.
   */
  @Getter
  private String mode;

  // add #12587 スタッフ切替 start
  @Getter
  private String switchStatus;
  // add #12587 スタッフ切替 end

  /**
   * IDのみでサインインするフラグ(自動サインイン処理で使用)
   */
  @Getter
  private String userIdOnly;

  /**
   * コンストラクタ.
   * <p>
   * 認証前の情報で生成する場合
   * </p>
   * @param principal プリンシパル
   * @param credentials 資格情報
   * @param facilityCd 施設コード
   * @param funcCd 機能コード
   */
  public NtssAuthenticationToken(Object principal, Object credentials, String facilityCd, String funcCd) {
    super(principal, credentials);
    this.facilityCd = facilityCd;
    this.funcCd = funcCd;
  }

  /**
   * カードよりログインの状態で生成する場合
   * @param principal プリンシパル
   * @param credentials 資格情報
   * @param facilityCd 施設コード
   * @param funcCd 機能コード
   * @param cardCd　カードコード
   * @param userIdOnly IDのみでサインインするフラグ
   * @param mode モード
   */
  public NtssAuthenticationToken(Object principal, Object credentials, String facilityCd, String funcCd, String cardCd, String userIdOnly, String mode,String switchStatus) {
    super(principal, credentials);
    this.facilityCd = facilityCd;
    this.funcCd = funcCd;
    this.cardCd = cardCd;
    this.userIdOnly = userIdOnly;
    this.mode = mode;
    this.switchStatus = switchStatus;
  }

  /**
   * コンストラクタ.
   * <p>
   * 認証済みの状態で生成する場合
   * </p>
   * @param principal プリンシパル
   * @param credentials 資格情報
   * @param facilityCd 施設コード
   * @param funcCd 機能コード
   * @param authorities 認可情報
   */
  public NtssAuthenticationToken(Object principal, Object credentials, String facilityCd, String funcCd,
      Collection<? extends GrantedAuthority> authorities) {
    super(principal, credentials, authorities);
    this.facilityCd = facilityCd;
    this.funcCd = funcCd;
  }

  /**
   * カードよりログインの認証済みの状態で生成する場合
   * @param principal プリンシパル
   * @param credentials 資格情報
   * @param facilityCd 施設コード
   * @param funcCd 機能コード
   * @param cardCd　カードコード
   * @param authorities 認可情報
   */
  public NtssAuthenticationToken(Object principal, Object credentials, String facilityCd, String funcCd, String cardCd,
      Collection<? extends GrantedAuthority> authorities) {
    super(principal, credentials, authorities);
    this.facilityCd = facilityCd;
    this.funcCd = funcCd;
    this.cardCd = cardCd;
  }
}
