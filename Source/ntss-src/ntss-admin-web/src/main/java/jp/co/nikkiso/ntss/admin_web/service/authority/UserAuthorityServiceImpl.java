package jp.co.nikkiso.ntss.admin_web.service.authority;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.core.dao.MntClientConnectDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logevent.ILogEventService;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.security.core.session.SessionInformation;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.stereotype.Service;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService.ForceSignOutReason;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import java.util.List;
import java.util.Map;

/**
 * 利用者権限Serviceの実装クラス.
 */
@Service
@Slf4j
public class UserAuthorityServiceImpl implements UserAuthorityService {

  private static final String FORCE_SIGN_OUT_LOG_MESSAGE = "%sが%sにより強制サインアウトされました。";
  private static final String SIGN_OUT_FUNCTION_NAME = "サインアウト";

	/**
	 * 利用者マスタのDaoインタフェース.
	 */
	@Autowired
	private MstUserDao mstUserDao;

	/**
	 * ロギングのServiceインタフェース.
	 */
	@Autowired
	LogService logService;

  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  private ILogEventService logEventService;

	/**
	 * サインイン管理のServiceインターフェース
	 */
	@Autowired
	SysSigninManagerService sysSigninManagerService;

  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
  /**
   * WebSocketクライアント接続状態のDaoインタフェース
   */
  @Autowired
  MntClientConnectDao mntClientConnectDao;

  /**
   * {@link SessionRegistry}
   */
  @Autowired
  private SessionRegistry sessionRegistry;
  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end

	/**
	 * {@inheritDoc}
	 */
	@Override
	public List<String> getAuthorizedAuthorities(Long userId) throws NotExistException {
		// 利用者情報を取得し、許可する権限を返却する
		MstUser mstUser = getMstUser(userId);
		return mstUser.getUserSettings().getAuthorizedAuthorities();
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public void updateAuthorizedAuthorities(Long userId, List<String> authorities, Boolean signoutFlg) throws NotExistException {
		// 利用者情報を取得する
		MstUser mstUser = getMstUser(userId);

    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
    if (signoutFlg) {
      List<String> authorizedAuthorities = mstUser.getUserSettings().getAuthorizedAuthorities();
      boolean isAdd = authorities.containsAll(authorizedAuthorities);
      // 許可機能・拡張機能が増えた場合はサインアウトさせない。
      if (isAdd) {
        signoutFlg = false;
      }
    }
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end

		// 権限情報を設定し、更新する
		mstUser.getUserSettings().setAuthorizedAuthorities(authorities);
		final int updatedUserCount = mstUserDao.updateUserSettings(mstUser);
		if (updatedUserCount <= 0) {
			EventLogMessage eventLogMessage = new EventLogMessage();
			eventLogMessage.setLogMessage("There is no User.");
			eventLogMessage.setSqlIdentification(mstUser.toString());
			logService.log(LogLevel.DEBUG, eventLogMessage,null, SERVICE_NAME.FNSI, "MstUserDao/updateUserSettings");
			throw new NotExistException("存在しない利用者のユーザーIDを指定されています。");
		}

		if (signoutFlg) {
      // 権限を変更した利用者をサインアウトさせる
      // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
      // sysSigninManagerService.signOutUser(userId);
      sysSigninManagerService.signOutUserForMultiServer(mstUser.getFacilityCd(), userId,
        ForceSignOutReason.USER_AUTHORITY_CHANGED);
      // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
		}
	}

	/**
	 * 利用者マスタを取得します.
	 *
	 * @param userId ユーザーID
	 * @return 利用者マスタ
	 * @throws NotExistException ユーザーIDに該当するレコードが存在しない場合
	 */
	private MstUser getMstUser(Long userId) throws NotExistException {
		try {
			MstUser mstUser = mstUserDao.selectById(userId);
			if (mstUser == null) {
				throw new EmptyResultDataAccessException(0);
			}
			return mstUser;

		} catch (EmptyResultDataAccessException e) {
			EventLogMessage eventLogMessage = new EventLogMessage();
			eventLogMessage.setLogMessage("There is no User.");
			eventLogMessage.setSqlIdentification("(userId=" + userId + ")");
			logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, "MstUserDao/selectById");
			throw new NotExistException("存在しない利用者のユーザーIDを指定されています。");
		}
	}

  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
  /**
   * サインアウト
   *
   * @param userId
   */
  @Override
  public void signOut(Long userId) {
    signOut(userId, ForceSignOutReason.USER_AUTHORITY_CHANGED);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void signOut(Long userId, ForceSignOutReason reason) {
    sysSigninManagerService.signOutUser(userId, reason);
  }
  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
  // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou start
  /**
   * 自分自身以外のサインアウト
   *
   * @param params
   */
  @Override
  public void signOutAnother(Map<String, String> params) {
    // アクセス元のcookie：JSESSIONIDを取得
    String sessionId = params.get("sessionId");
    Long userId = StrUtils.isNumber(params.get("userId")) ? Long.parseLong(params.get("userId")) : 0L;
    ForceSignOutReason reason = ForceSignOutReason.fromName(params.get("forceSignOutReason"),
      ForceSignOutReason.MULTI_BROWSER_SIGN_IN_PROHIBITED);

    for (Object principal : sessionRegistry.getAllPrincipals()) {
      if (principal instanceof NtssUser) {
        NtssUser userDetails = (NtssUser) principal;
        // 指定IDに該当する場合
        if (userDetails.getUserId().equals(userId)) {
          List<SessionInformation> sessions = sessionRegistry.getAllSessions(principal, false);
          sessions.forEach(session -> {
            if (sessionId.equals(session.getSessionId())) {
              // 自身のセッションは処理しない
              return;
            }
            outputForceSignOutLog(userDetails, session.getSessionId(), reason);
            // 他端末のセッションはタイムアウトさせる
            session.expireNow();
          });
        }
      }
    }
    // 自身以外の同じ利用者のサインイン管理情報を削除
    sysSigninManagerService.deleteByUserId(userId, params.get("terminalUniqueString"));
  }

  private void outputForceSignOutLog(NtssUser userDetails, String sessionId, ForceSignOutReason reason) {
    if (userDetails == null || reason == null) {
      return;
    }

    String userName = logEventService.getPersonalUserName(userDetails.getUserId());
    if (StringUtils.isEmpty(userName)) {
      userName = userDetails.getUsername();
    }

    logServiceCore.log(
      LogLevel.INFO,
      new EventLogMessage(
        userDetails.getFacilityCd(),
        userDetails.getUsername(),
        userDetails.getClientIpAddress(),
        sessionId,
        "",
        "",
        "",
        "",
        "",
        LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI,
        "",
        "",
        "",
        String.format(FORCE_SIGN_OUT_LOG_MESSAGE, userName, reason.getLogReason()),
        "",
        this.getClass().getName(),
        SIGN_OUT_FUNCTION_NAME
      ),
      null,
      LoggingConstant.MODULE_NAME.ADMIN_WEB,
      SERVICE_NAME.FNSI,
      null
    );
  }
  // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou end

}
