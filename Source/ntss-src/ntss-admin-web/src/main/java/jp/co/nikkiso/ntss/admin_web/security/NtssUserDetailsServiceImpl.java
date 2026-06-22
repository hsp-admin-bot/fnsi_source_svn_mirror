package jp.co.nikkiso.ntss.admin_web.security;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import jakarta.servlet.http.HttpServletRequest;

import jp.co.nikkiso.ntss.admin_web.service.userAccount.UserAccountServiceImpl;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstPatHashDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstPatHash;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.MODULE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.authority.UserAuthorityService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLogger;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import org.springframework.util.StringUtils;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
/**
 * NTSSユーザー詳細サービスクラス.
 */
@Service
@Slf4j
public class NtssUserDetailsServiceImpl implements NtssUserDetailsService {

  /**
   * 利用者権限Serviceインタフェース.
   */
  @Autowired
  private UserAuthorityService userAuthorityService;

  /**
   * 利用者マスタDaoインタフェース.
   */
  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  /**
   * 利用者マスタDaoインターフェース
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * 施設マスタハッシュDaoインタフェース.
   */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  /**
   * 在宅透析患者ログイン用施設マスタハッシュDaoインタフェース.
   */
  @Autowired
  private MstPatHashDao mstPatHashDao;

  /**
   * ロガー生成コンポーネント
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  HttpServletRequest request;

  /**
   * 利用者に全権限を付与するかどうか.
   */
  @Value("${ntss.authority.full-authority:#{false}}")
  private boolean fullAuthority;


 /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 start
  @Autowired
  private UserAccountServiceImpl serAccountServiceImpl;
  // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 end

  /* add by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  @Autowired
  private MstUserDao mstUserDao;
  /* add by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * {@inheritDoc}
   */
  @Override
  public UserDetails loadUserByUsernameAndFacilityCd(String username, String facilityHashValue, String cardCd)
      throws UsernameNotFoundException {
    // 施設コードハッシュ値から施設コードを取得
    MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(facilityHashValue);
    if (mstFacilityHash == null) {
      // 在宅患者ログイン用施設コードを検索
      MstPatHash mstPatHash = mstPatHashDao.selectByHashValue(facilityHashValue);
      if ( mstPatHash == null ) {
        throw new UsernameNotFoundException(String.format("不正な施設コードハッシュ値です。(施設コードハッシュ値=%s)", facilityHashValue));
      } else {
        // 後続処理のためにmstFacilityHashに値を詰めなおす
        mstFacilityHash = new MstFacilityHash() {
          {
            setFacilityCd(mstPatHash.getFacilityCd());
            setHashValue(mstPatHash.getHashValue());
            setRegDate(mstPatHash.getRegDate());
            setUpDate(mstPatHash.getUpDate());
          }
        };
      }
    }

    // 表示用ユーザーIDと施設コードで利用者マスタを検索
    MstUserAuthentication mstUser = null;
    if (!cardCd.equals("")) {
      mstUser = mstUserAuthenticationDao.selectByCardCd(cardCd, mstFacilityHash.getFacilityCd());
    } else {
      mstUser = mstUserAuthenticationDao.selectForLogin(username, mstFacilityHash.getFacilityCd());
    }
    if (mstUser == null) {
      throw new UsernameNotFoundException(String.format("該当する利用者マスタが存在しません。(ユーザーID=%s, 施設コード=%s)", username, mstFacilityHash.getFacilityCd()));
    }

    /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    // // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 start
    // serAccountServiceImpl.doInginSoming(true, null, mstUser.getUserId());
    // // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 end
    /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
    // ロガー取得
    //FNSI-修正 ログ対応 xiebzh add start
    //EventLogger logger = eventLoggerFactory.getLogger(mstUser.getFacilityCd());
    EventLogger logger = eventLoggerFactory.getLogger(mstUser.getFacilityCd(), LogClass.APP);
    //FNSI-修正 ログ対応 xiebzh add end

    // 利用者が許可されている権限を取得
    List<GrantedAuthority> authorities =
      userAuthorityService.getAuthorizedAuthorities(mstUser.getUserId()).stream()
        .map(SimpleGrantedAuthority::new)
        .collect(Collectors.toList());

    // 権限情報が未設定の場合は「参照権限のみ」と出力
    String message = String.format(
      "利用者権限情報（ユーザーID=%s、許可権限=%s）",
      mstUser.getUserId(), authorities.isEmpty()
        ? "参照権限のみ"
        : authorities);
    logger.info(createEventLogMessage(request, mstUser, message));

    if (fullAuthority) {
      // 利用者に全権限を設定する
      authorities = getAllAuthorities();
      String fullAuthMessage = "起動設定より利用者に全権限を付与しています。";
      logger.info(createEventLogMessage(request, mstUser, fullAuthMessage));
    }

    // 利用者を取得（種別と管理者フラグをNtssUserに設定するため。）
    final MstPersonalUser mstPersonalUser = mstPersonalUserDao.selectById(mstUser.getUserId());

    /* add by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    // 利用者マスタ
    MstUser mstUserSession = mstUserDao.selectById(mstUser.getUserId());
    /* add by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

    return new NtssUser(
        mstUser.getFacilityCd(),
        mstUser.getDispUserId(),
        mstUser.getUserPassword(),
        mstUser.getUserId(),
        mstPersonalUser == null ? null : mstPersonalUser.getUserType(),
        mstPersonalUser == null ? null : mstPersonalUser.getAdministrator(),
        mstUser.getFailureCnt(),
        authorities,
        /* add by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
        mstUserSession);
        /* add by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
  }

  /**
   * 利用者権限の全権限コードを取得します.
   *
   * @return 権限コードのリスト
   */
  private List<GrantedAuthority> getAllAuthorities() {

    // 定数クラスから全権限コードを取得する
    Class<? extends Object> cls = AdminWebConstant.Authority.class;
    return Arrays.stream(cls.getFields())
      .map(f -> {
        try {
          return String.valueOf(f.get(cls));
        } catch (IllegalAccessException e) {
          return null;
        }
      })
      .filter(f -> !StringUtils.isEmpty(f))
      .map(SimpleGrantedAuthority::new)
      .collect(Collectors.toList());
  }

  /**
   * 与えられた情報から{@link EventLogMessage}を生成する.
   *
   * @param request リクエスト情報
   * @param mstUserAuthentication 認証DBの利用者マスタ
   * @param message 出力メッセージ
   * @return 生成した {@link EventLogMessage}
   */
  private EventLogMessage createEventLogMessage(
    HttpServletRequest request,
    MstUserAuthentication mstUserAuthentication,
    String message) {
    // アプリケーションを実行しているサーバの識別を取得
    String hostIp = "";
    try {
      hostIp = LogObjectUtils.getHostAddress();
    } catch (NtssException ex) {
      // 例外が発生するのはホストIPが取得できなかった場合.
      // エラーとは扱わない.

     EventLogMessage eventLogMessage = new EventLogMessage();
     eventLogMessage.setLogMessage(ex.getMessage());
     logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    return new EventLogMessage(
        mstUserAuthentication.getFacilityCd()
      , mstUserAuthentication.getUserId().toString()
      , request.getRemoteAddr()
      , request.getRequestedSessionId()
      , ""
      , ""
      , ""
      , ""
      , hostIp
      , MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNM
      , ""
      , ""
      , ""
      , message
      , ""
    , this.getClass().getName(),
      "");
  }

}
