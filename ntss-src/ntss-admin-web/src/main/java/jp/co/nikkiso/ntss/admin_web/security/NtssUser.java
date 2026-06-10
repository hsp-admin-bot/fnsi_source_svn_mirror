package jp.co.nikkiso.ntss.admin_web.security;

import java.util.Collection;
import java.util.Objects;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.MstUser;
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
   * 施設コード.
   */
  @Getter
  private final String facilityCd;

  /**
   * ユーザーID(内部用).
   */
  @Getter
  private final Long userId;

  /**
   * 利用者種別.
   */
  @Getter
  @Setter
  private Integer userType;

  /**
   * 管理者フラグ
   */
  @Getter
  private Integer administrator;

  /**
   * サインイン失敗回数.
   */
  @Getter
  private final Integer failureCnt;

  /**
   * セッションID
   */
  @Getter
  @Setter
  private String sessionId;

  /**
   * 接続先IPアドレス
   */
  @Getter
  @Setter
  private String clientIpAddress;

  /* add by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  @Getter
  @Setter
  private MstUser mstUser;
  /* add by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
  
  // add #12587 スタッフ切替 start
  @Getter
  @Setter
  private String switchStatus;
  // add #12587 スタッフ切替 end

  /**
   * コンストラクタ.
   *
   * @param facilityCd 施設コード
   * @param username ユーザーID(表示用)
   * @param password パスワード
   * @param userId ユーザーID(内部用)
   * @param userType 利用者種別
   * @param failureCnt サインイン失敗回数
   * @param authorities 権限
   */
  /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  public NtssUser(
    String facilityCd,
    String username,
    String password,
    Long userId,
    Integer userType,
    Integer administrator,
    Integer failureCnt,
    Collection<? extends GrantedAuthority> authorities,
    MstUser mstUser) {

    super(username, password, authorities);
    this.facilityCd = facilityCd;
    this.userId = userId;
    this.userType = userType;
    this.administrator = administrator;
    this.failureCnt = failureCnt;
    this.mstUser = mstUser;
  }
  /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  // #11205 -ペンテスト2－4認可制御の不備  add 20260325 shiyw start
  public boolean isNkkAdminUser() {
    /*
      mst_personal_user.administrator == 1
      mst_personal_user.facility_cd == 'nkknkk'
    */
    return Objects.equals(facilityCd, CoreConstant.Administrator.NKK_FACILITY_CD) && Objects.equals(administrator, 1);
  }
  // #11205 -ペンテスト2－4認可制御の不備  add 20260325 shiyw end
}
