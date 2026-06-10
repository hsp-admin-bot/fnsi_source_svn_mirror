package jp.co.nikkiso.ntss.admin_web.security;

import java.util.Optional;

import jp.co.nikkiso.ntss.admin_web.service.userAccount.UserAccountService;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.authentication.dao.AbstractUserDetailsAuthenticationProvider;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.admin_web.exception.DataSourceInconsistencyAuthenticationException;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService.ForceSignOutReason;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;

/**
 * NTSS認証プロバイダークラス.
 */
public class NtssAuthenticationProvider extends AbstractUserDetailsAuthenticationProvider {

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
   * 利用者マスタ(認証DB)Daoインタフェース.
   */
  @Autowired
  private MstUserAuthenticationDao userAuthenticationDao;

  /**
   * 利用者マスタ(個人情報DB)Daoインタフェース.
   */
  @Autowired
  private MstPersonalUserDao personalUserDao;

  /**
   * 施設マスタハッシュのDaoインタフェース.
   */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  /**
   * サインイン管理のServiceインターフェース
   */
  @Autowired
  SysSigninManagerService sysSigninManagerService;

  // add #12587 スタッフ切替 start
  @Autowired
  UserAccountService userAccountService;
  // add #12587 スタッフ切替 end

  // add #8323 【デグレ】体重計モードのサインインにて、パスワードが間違っていてもサインインできる dou start
  // 帳票 未サインイン状態だったら事前入力情報でサインインを試行
  private final static String REPORT_NOT_LOGIN = "_";
  // add #8323 【デグレ】体重計モードのサインインにて、パスワードが間違っていてもサインインできる dou end

  /**
   * {@inheritDoc}
   */
  @Override
  protected void additionalAuthenticationChecks(UserDetails userDetails,
      UsernamePasswordAuthenticationToken authentication) throws AuthenticationException {
    String presentedPassword = Optional.ofNullable(authentication.getCredentials()).orElse("").toString();
    NtssUser ntssUser = (NtssUser)userDetails;
    NtssAuthenticationToken ntssAuthToken = (NtssAuthenticationToken)authentication;
    // 施設マスタハッシュデータ取得
    MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByFacilityCd(ntssUser.getFacilityCd());

    boolean failureLimitOver = false;
    boolean incorrectPassword = false;
    // アカウントロックする設定の場合
    if (mstFacilityHash.getAccountLockSetting().equals("1")) {
      failureLimitOver = ntssUser.getFailureCnt() >= mstFacilityHash.getFailureCnt();
    }
    // IDのみでサインインするフラグがあるときは、パスワード判定を行わない
    if (!Boolean.valueOf(ntssAuthToken.getUserIdOnly())) {
      // mod #8323 【デグレ】体重計モードのサインインにて、パスワードが間違っていてもサインインできる dou start
      // incorrectPassword = ntssAuthToken.getFuncCd().length() == 0 && !this.passwordEncoder.matches(presentedPassword, userDetails.getPassword());
      // mod #12587 スタッフ切替 start
	  if(ntssUser.getSwitchStatus() != null && "true".equalsIgnoreCase(ntssUser.getSwitchStatus())){
        //查询mst_user_switch表中是否有关系 用户判断是否是切换进来的用户
        boolean isQuals = false;
        Long userId = ntssUser.getUserId();
        String groupId = userAccountService.getGroupId(userId);
        Long userId1 = ((NtssUser) userDetails).getUserId();
        String groupId1 = userAccountService.getGroupId(userId1);
        if(StringUtils.hasText(groupId) && StringUtils.hasText(groupId1) && groupId.equals(groupId1)){
          isQuals = true;
        }
        incorrectPassword = !REPORT_NOT_LOGIN.equals(ntssAuthToken.getFuncCd()) && !isQuals;
      }else{
        incorrectPassword = !REPORT_NOT_LOGIN.equals(ntssAuthToken.getFuncCd()) && !this.passwordEncoder.matches(presentedPassword, userDetails.getPassword());
      }
//      incorrectPassword = !REPORT_NOT_LOGIN.equals(ntssAuthToken.getFuncCd()) && !this.passwordEncoder.matches(presentedPassword, userDetails.getPassword());
      // mod #12587 スタッフ切替 end
	  // mod #8323 【デグレ】体重計モードのサインインにて、パスワードが間違っていてもサインインできる dou end
    }
    if (!ntssAuthToken.getCardCd().equals("")) {
      if (ntssUser.getUserId().toString().equals(ntssAuthToken.getCardCd())) {
        incorrectPassword = false;
      }
    }
    if (incorrectPassword || failureLimitOver) {
      if (failureLimitOver) {
        // 連続ログイン失敗でロック中
        throw new BadCredentialsException("このユーザーはアカウントロックされています。管理者にお問い合わせください。");
      } else {
        // サインイン失敗回数が上限に達していない場合、+1で更新
        updateFailureCnt(ntssUser, ntssUser.getFailureCnt() + 1);
        // サインイン失敗回数が上限に達して、アカウントロックする設定の場合
        if (ntssUser.getFailureCnt() + 1 == mstFacilityHash.getFailureCnt()
            && mstFacilityHash.getAccountLockSetting().equals("1")) {
          // ロックされた利用者をタイムアウトさせる
          // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
          // sysSigninManagerService.signOutUser(ntssUser.getUserId());
          sysSigninManagerService.signOutUserForMultiServer(ntssUser.getFacilityCd(), ntssUser.getUserId(),
            ForceSignOutReason.ACCOUNT_LOCK);
          // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
          // ログイン失敗回数が規定回数に到達
          throw new BadCredentialsException("認証に失敗しました。<br>認証失敗の回数が規定回数に達したため、このユーザーIDのアカウントをロックしました。<br>管理者に問い合わせてください。");
        } else {
          throw new BadCredentialsException("認証に失敗しました。認証情報を確認して下さい。");
        }
      }
    }
    else {
      // 利用者種別を取得し、ntssUserに設定
      MstPersonalUser personalUser = personalUserDao.selectById(ntssUser.getUserId());
      if (personalUser == null) {
        // 取得できない場合はデータ不整合例外を投げる
        throw new DataSourceInconsistencyAuthenticationException(ntssUser.getUserId(), DataSourceName.AUTH, DataSourceName.PERSONAL);
      }
      ntssUser.setUserType(personalUser.getUserType());

      // 認証成功の場合、サインイン失敗回数を0に更新
      updateFailureCnt(ntssUser, 0);
    }
  }

  /**
   * 利用者マスタ.サインイン失敗回数を更新する.
   *
   * @param ntssUser NtssUser
   * @param failureCnt サインイン失敗回数
   */
  private void updateFailureCnt(NtssUser ntssUser, Integer failureCnt) {
    // サインイン失敗回数が変わった場合、更新する
    if (failureCnt != ntssUser.getFailureCnt()) {
      MstUserAuthentication userAuthentication = new MstUserAuthentication() {
          {
          setUserId(ntssUser.getUserId());
          setFailureCnt(failureCnt);
          }
        };

      userAuthenticationDao.updateFailureCnt(userAuthentication);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected Authentication createSuccessAuthentication(Object principal,
      Authentication authentication, UserDetails user) {
    String facilityCd = ((NtssUser)user).getFacilityCd();
    return new NtssAuthenticationToken(user, authentication.getCredentials(),
        facilityCd, "", user.getAuthorities());
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
	  // mod #12587 スタッフ切替 start
      UserDetails userDetails = this.service.loadUserByUsernameAndFacilityCd(auth.getPrincipal().toString(), auth.getFacilityCd(), auth.getCardCd());
      NtssUser userDetails1 = (NtssUser) userDetails;
      userDetails1.setSwitchStatus(((NtssAuthenticationToken) authentication).getSwitchStatus());
      return userDetails;
	  // mod #12587 スタッフ切替 end
    } catch (UsernameNotFoundException notFound) {
      throw notFound;
    } catch (NotExistException ne) {
      throw new BadCredentialsException("認証に失敗しました。認証情報を確認して下さい。");
    } catch (Exception ex) {
      throw new InternalAuthenticationServiceException(ex.getMessage(), ex);
    }
  }

}
