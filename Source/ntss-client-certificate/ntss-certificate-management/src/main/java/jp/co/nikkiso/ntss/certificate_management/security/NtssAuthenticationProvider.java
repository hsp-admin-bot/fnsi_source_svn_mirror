package jp.co.nikkiso.ntss.certificate_management.security;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.authentication.dao.AbstractUserDetailsAuthenticationProvider;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;

import jp.co.nikkiso.ntss.certificate_management.constant.ClientCertificateConstant.ScreenName;
import jp.co.nikkiso.ntss.certificate_management.exception.DataSourceInconsistencyAuthenticationException;
import jp.co.nikkiso.ntss.certificate_management.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.dao.ClFacilityDao;
import jp.co.nikkiso.ntss.core.dao.ClUserDao;
import jp.co.nikkiso.ntss.core.entity.ClUser;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.entity.ClFacility;

/**
 * NTSS認証プロバイダークラス.
 */
public class NtssAuthenticationProvider extends AbstractUserDetailsAuthenticationProvider {

  /**
   * NTSSロックカウント
   */

  @Value("${ntss.cl-certificate.cl-user.lock-count}")
  private int userLockCount;

  @Value("${ntss.cl-certificate.cl-facility.lock-count}")
  private int facilityLockCount;

  /**
   * NTSSユーザー詳細サービス
   */
  @Autowired
  private NtssUserDetailsService service;

  /**
   * パスワードエンコーダ.
   */
  @Autowired
  private PasswordEncoder passwordEncoder;


  /**
   * クライアントユーザー（認証DB）Daoインターフェース.
   */
  @Autowired
  private ClUserDao clUserDao;

  /**
   * クライアント機能（認証DB）Daoインターフェース.
   */
  @Autowired
  private ClFacilityDao clFacilityDao;

  @Autowired
  private LogService logService;
  /**
   * {@inheritDoc}
   */
  @Override
  protected void additionalAuthenticationChecks(UserDetails userDetails,
      UsernamePasswordAuthenticationToken authentication) throws AuthenticationException {
    String presentedPassword = Optional.ofNullable(authentication.getCredentials()).orElse("").toString();
    NtssUser ntssUser = (NtssUser)userDetails;
    boolean failureLimitOver;
    if(ntssUser.isUserLogin()) {
      failureLimitOver = ntssUser.getNumLoginAttempt() >= userLockCount;
    } else {
      failureLimitOver = ntssUser.getNumLoginAttempt() >= facilityLockCount;
    }
    boolean incorrectPassword = !this.passwordEncoder.matches(presentedPassword, userDetails.getPassword());

    if (incorrectPassword || failureLimitOver) {
      if (failureLimitOver) {
        // 連続ログイン失敗でロック中
        if(ntssUser.isUserLogin()) {
          throw new BadCredentialsException("このユーザーはアカウントロックされています。管理者にお問い合わせください。");
        } else {
          throw new BadCredentialsException("この施設アカウントはロックされています。 管理者に連絡してください。");
        }
      } else {
        // サインイン失敗回数が上限に達していない場合、+1で更新
        updateNumLoginAttempt(ntssUser, ntssUser.getNumLoginAttempt() + 1, ntssUser.isUserLogin());
        if(ntssUser.isUserLogin()) {
          if (ntssUser.getNumLoginAttempt() + 1 == userLockCount) {
            // ログイン失敗回数が規定回数に到達
            throw new BadCredentialsException("認証に失敗しました。このユーザーIDのアカウントをロックしました。管理者に問い合わせてください。");
          } else {
            throw new BadCredentialsException("認証に失敗しました。認証情報を確認して下さい。");
          }
        } else {
          if (ntssUser.getNumLoginAttempt() + 1 == facilityLockCount) {
            // ログイン失敗回数が規定回数に到達
            throw new BadCredentialsException("認証に失敗しました。この施設コードのアカウントをロックしました。管理者に問い合わせてください。");
          } else {
            throw new BadCredentialsException("認証に失敗しました。認証情報を確認して下さい。");
          }
        }
      }
    }
    else {
      // 利用者種別を取得し、ntssUserに設定
      if(ntssUser.isUserLogin()) {
        ClUser clUser = clUserDao.selectById(ntssUser.getUsername());
        if (clUser == null) {
          // 取得できない場合はデータ不整合例外を投げる
          throw new DataSourceInconsistencyAuthenticationException(null, DataSourceName.CERTIFICATE);
        }
        ntssUser.setUserRole(clUser.getUserRole());
      } else {
        ClFacility clFacility = clFacilityDao.selectByFacilityCd(ntssUser.getUsername());
        if (clFacility == null) {
          // 取得できない場合はデータ不整合例外を投げる
          throw new DataSourceInconsistencyAuthenticationException(null, DataSourceName.CERTIFICATE);
        }
        ntssUser.setUserRole(NtssAuthenticationConstants.Authority.CL_FACILITY_ROLE);
      }

      // 認証成功の場合、サインイン失敗回数を0に更新
      updateNumLoginAttempt(ntssUser, 0, ntssUser.isUserLogin());
    }
  }

  /**
   * 利用者マスタ.サインイン失敗回数を更新する.
   *
   * @param ntssUser NtssUser
   * @param numLoginAttempt サインイン失敗回数
   */
  private void updateNumLoginAttempt(NtssUser ntssUser, Integer numLoginAttempt, boolean isUserLogin) {
    // サインイン失敗回数が変わった場合、更新する
    if (numLoginAttempt != ntssUser.getNumLoginAttempt()) {
      if(isUserLogin) {
        clUserDao.updateNumLoginAttempt(ntssUser.getUsername(), numLoginAttempt);
      } else {
        clFacilityDao.updateAttemptFail(ntssUser.getUsername(), null, numLoginAttempt);
      }
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected Authentication createSuccessAuthentication(Object principal,
      Authentication authentication, UserDetails user) {
        boolean isUserLogin = ((NtssUser)user).isUserLogin();
    return new NtssAuthenticationToken(user, authentication.getCredentials(), user.getAuthorities(), isUserLogin);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean supports(Class<?> authentication) {
    return NtssAuthenticationToken.class.isAssignableFrom(authentication);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected UserDetails retrieveUser(String username, UsernamePasswordAuthenticationToken authentication)
      throws AuthenticationException {
    NtssAuthenticationToken auth = (NtssAuthenticationToken)authentication;

    try {
            // NTSS認証ユーザーを読み込む
      if(auth.isUserLogin()) {
        return this.service.loadUserByUserId(auth.getPrincipal().toString());
      } else {
        return this.service.loadUserByFacilityCd(auth.getPrincipal().toString());
      }
    } catch (UsernameNotFoundException notFound) {
      throw new BadCredentialsException("認証に失敗しました。認証情報を確認して下さい。");
    } catch (Exception ex) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      String errMsg = ex.getMessage();
      if (errMsg == null) {
        errMsg = ex.toString() + " " + ex.getStackTrace()[0];
      }
      eventLogMessage.setLogMessage("REST to retrieve user: " + errMsg);
      logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_LOGIN, null);
      // mod FNSI-#4443対応 解 start
      // throw new InternalAuthenticationServiceException("システムエラーが発生しました。", ex);
      throw new InternalAuthenticationServiceException("システムエラーが発生しましたので処理を終了します。", ex);
      // mod FNSI-#4443対応 解 end
    }
  }

}
