package jp.co.nikkiso.ntss.certificate_download.security;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.certificate_download.constant.ClientCertificateConstant.ScreenName;
import jp.co.nikkiso.ntss.certificate_download.service.log.LogService;
import jp.co.nikkiso.ntss.core.dao.ClFacilityDao;
import jp.co.nikkiso.ntss.core.dao.ClUserDao;
import jp.co.nikkiso.ntss.core.entity.ClFacility;
import jp.co.nikkiso.ntss.core.entity.ClUser;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

/**
 * NTSSユーザー詳細サービスクラス.
 */
@Service
public class NtssUserDetailsServiceImpl implements NtssUserDetailsService {

  @Autowired
  private ClUserDao clUserDao;

  @Autowired
  private ClFacilityDao clFacilityDao;

  /**
   * 利用者に全権限を付与するかどうか.
   */
  @Value("${ntss.authority.full-authority:#{false}}")
  private boolean fullAuthority;

  // ロギングサービス
  @Autowired
  LogService logService;

  /**
   * {@inheritDoc}
   */
  @Override
  public UserDetails loadUserByUserId(String userId) throws UsernameNotFoundException {

    ClUser clUser = clUserDao.selectById(userId);
    if (clUser == null) {
      throw new UsernameNotFoundException(String.format("不正な施設コードハッシュ値です。(施設コードハッシュ値=%s)", userId));
    }
    List<GrantedAuthority> authorities = getAllAuthorities(clUser.getUserRole());
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(String.format("利用者権限情報（ユーザーID=%s、許可権限=%s）", clUser.getUserId(), authorities));
    logService.log(LogLevel.INFO, eventLogMessage, null, ScreenName.MANAGEMENT_LOGIN, null);
    return new NtssUser(clUser.getUserId(), clUser.getUserPass(), clUser.getUserRole(), Long.toString(clUser.getId()), clUser.getUserName(), true, clUser.getNumLoginAttempt(),
        authorities);
  }

  @Override
  public UserDetails loadUserByFacilityCd(String facilityCd) throws UsernameNotFoundException {
    ClFacility clFacility = clFacilityDao.selectByFacilityCd(facilityCd);
    if (clFacility == null) {
      throw new UsernameNotFoundException(String.format("不正な施設コードハッシュ値です。(施設コードハッシュ値=%s)", facilityCd));
    }
    List<GrantedAuthority> authorities = getAllAuthorities(NtssAuthenticationConstants.Authority.CL_FACILITY_ROLE);
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(String.format("利用者権限情報（施設コード=%s、許可権限=%s）", clFacility.getFacilityCd(), authorities));
    logService.log(LogLevel.INFO, eventLogMessage, null, ScreenName.DOWNLOAD_LOGIN, null);
    return new NtssUser(
      clFacility.getFacilityCd(),
      clFacility.getFacilityPassword(),
      NtssAuthenticationConstants.Authority.CL_FACILITY_ROLE,
      clFacility.getFacilityCd(),
      "",
      false,
      clFacility.getAttemptFail(),
        authorities);
  }

  private List<GrantedAuthority> getAllAuthorities(String userRole) {
    List<GrantedAuthority> authorities = AuthorityUtils.createAuthorityList("ROLE_" + userRole);
    return authorities;
}
}
