package jp.co.nikkiso.ntss.admin_web.service.userAccount;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.json.JSONArray;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.ProvisionalUserResponse;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.exception.DataSourceInconsistencyException;

import java.util.Objects;

/**
 * 仮ユーザー画面の実装クラス.
 */
@Service
public class ProvisionalUserServiceImpl implements ProvisionalUserService {

  /**
   * 仮ユーザー画面での利用者マスタのDaoインタフェース.
   */
  @Autowired
  private MstUserDao mstUserDao;

  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  /**
   * 利用者マスタ(個人情報DB)のDaoインタフェース.
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * アカウント編集画面のServiceインタフェース.
   */
  @Autowired
  private UserAccountService userAccountService;

  /**
   * パスワードエンコーダ.
   */
  @Autowired
  private PasswordEncoder passwordEncoder;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  @Autowired
  private LogService logService;

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional(TransactionManagerName.ALL)
  public ProvisionalUserResponse updateProvisionalUser(
    String dispUserIdPre, String dispUserIdNew, String userPasswordNew,
    String facilityCd, Long userId, String userLastName, String userFirstName,
    Boolean isProvisional, Boolean isConsent) {

    // ユーザーIDを基にDB4/DB5/DB6の各対応マスタを取得
    MstUser mstUser = mstUserDao.selectById(userId);
    MstUserAuthentication mstUserAuthentication = mstUserAuthenticationDao.selectById(userId);
    MstPersonalUser personalUser = mstPersonalUserDao.selectById(userId);

    // いずれか１つのレコードでも存在しない場合、データソース間不整合を返す
    if (Objects.isNull(mstUser) || Objects.isNull(mstUserAuthentication) || Objects.isNull(personalUser)) {
      throw new DataSourceInconsistencyException(userId, DataSourceName.DEFAULT, DataSourceName.AUTH, DataSourceName.PERSONAL);
    }

    // 新規ユーザーIDの重複チェック(仮登録時のみ)
    if (isProvisional && userAccountService.selectDuplicateCount(dispUserIdNew, mstUser.getUserId()) > 0) {
      return new ProvisionalUserResponse(AdminWebMessage.Error.USER_ID_EXISTED.getMessage());
    }

    // 仮登録時の更新処理
    if(isProvisional){
      // 仮ユーザーフラグを有効化
      validateUpdateCount(updateUserIsProvisional(mstUser), userId);
    }

    // 個人情報取扱い同意情報を有効化
    if(isConsent){
      validateUpdateCount(updateIsConsent(userId),userId);
    }

    // 仮登録時の更新処理
    if(isProvisional){
      // DispUserId・パスワードを変更
      validateUpdateCount(updateUserAuth(dispUserIdNew, userPasswordNew, mstUserAuthentication), userId);

      // パスワード変更日時の登録
      validateUpdateCount(updateUserRegPasswordDate(mstUser), userId);

      // ユーザー名を変更
      validateUpdateCount(updateUserName(userId,userLastName,userFirstName),userId);
    }
    // 仮登録時以外で、パスワード入力時処理（パスワード有効期限切れ時）
    else if(!userPasswordNew.isEmpty()) {
      // パスワードを変更
      validateUpdateCount(updateUserAuth(userPasswordNew, mstUserAuthentication), userId);

      // パスワード変更日時の登録
      validateUpdateCount(updateUserRegPasswordDate(mstUser), userId);
    }

    return new ProvisionalUserResponse();
  }

  /**
   * 更新件数を判定してデータソース間不整合例外を投げる.
   * @param updateCount 更新件数
   * @param userId ユーザーID
   */
  private void validateUpdateCount(int updateCount, Long userId) {
    if (updateCount != 1) {
      // DBの更新件数が1以外の場合、データソース間不整合を返し、Rollbackさせる
      throw new DataSourceInconsistencyException(userId, DataSourceName.DEFAULT, DataSourceName.AUTH);
    }
  }

  /**
   * ユーザー情報の仮登録フラグを更新し、結果を取得.
   * @param mstUser ユーザー情報
   * @return 更新件数
   */
  private int updateUserIsProvisional(MstUser mstUser) {
    mstUser.setIsProvisional(CoreConstant.ProvisionalStatus.NOT_PROVISIONAL);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(mstUser,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mstUserDao.updateIsProvisional(mstUser);
  }

  /**
   * ユーザー情報のパスワード変更日時を更新し、結果を取得.
   * @param mstUser ユーザー情報
   * @return 更新件数
   */
  private int updateUserRegPasswordDate(MstUser mstUser) {
    return mstUserDao.updateRegPasswordDate(mstUser.getUserId());
  }

  /**
   * ユーザー情報を更新し、結果を取得(個人情報取扱い同意)
   * @param userId ユーザーID
   * @return 更新結果
   */
  private int updateIsConsent(Long userId){

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "mst_user";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" user_id = " + userId + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(mstUserDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = mstUserDao.updateIsConsent(userId);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    return updateCount;
  }

  /**
   * ユーザー情報(認証DB)を更新し、結果を取得.
   * @param dispUserIdNew 表示用利用者ID(新)
   * @param userPasswordNew パスワード(新)
   * @param mstUserAuthentication
   * @return
   */
  private int updateUserAuth(String dispUserIdNew, String userPasswordNew, MstUserAuthentication mstUserAuthentication) {
    mstUserAuthentication.setDispUserId(dispUserIdNew);
    return updateUserAuth(userPasswordNew, mstUserAuthentication);
  }

  /**
   * ユーザー情報(認証DB)を更新し、結果を取得（パスワードのみ）.
   * @param userPasswordNew パスワード(新)
   * @param mstUserAuthentication
   * @return
   */
  private int updateUserAuth(String userPasswordNew, MstUserAuthentication mstUserAuthentication) {
    String encodedPassword = passwordEncoder.encode(userPasswordNew);
    JSONArray passwordHistory = userAccountService.updatePasswordHistory(encodedPassword, mstUserAuthentication.getUserId());
    mstUserAuthentication.setUserPassword(encodedPassword);
    mstUserAuthentication.setUserPasswordHistory(passwordHistory.toString());


    int updateResult = mstUserAuthenticationDao.updateDispUserIdAndUserPassword(mstUserAuthentication);

    return updateResult;
  }

  /**
   * ユーザー情報(PersonalUser)を更新し、結果を取得
   * @param userId ユーザーID番号
   * @param userLastName ユーザー名（姓）
   * @param userFirstName ユーザー名（名）
   * @return
   */
  private int updateUserName(Long userId, String userLastName, String userFirstName){
    MstPersonalUser updPersonalUser = new MstPersonalUser();
    updPersonalUser.setUserId(userId);
    updPersonalUser.setUserLastName(userLastName);
    updPersonalUser.setUserFirstName(userFirstName);
    return mstPersonalUserDao.updateUserName(updPersonalUser);
  }

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End
}

