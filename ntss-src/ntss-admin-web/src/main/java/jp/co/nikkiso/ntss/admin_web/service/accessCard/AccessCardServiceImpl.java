package jp.co.nikkiso.ntss.admin_web.service.accessCard;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.AccessCardDao;
import jp.co.nikkiso.ntss.core.dao.MntCardappPortDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.MntCardappPort;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import lombok.extern.slf4j.Slf4j;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Slf4j
public class AccessCardServiceImpl implements AccessCardService {

  @Autowired
  private AccessCardDao accessCardDao;

  @Autowired
  private MstUserDao mstUserDao;
  //add 7328 IDｍが医療情報DBにて管理されている 関俊楠 start
  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;
  //add 7328 IDｍが医療情報DBにて管理されている 関俊楠 end
  // add 2020-08-13 FNSI-仕様追加 患者基本情報(pat_main)にアクセスカード番号(card_idm)の追加処理 夏 start
  @Autowired
  private PatMainDao patMainDao;
  // add 2020-08-13 FNSI-仕様追加 患者基本情報(pat_main)にアクセスカード番号(card_idm)の追加処理 夏 end

  // add 2020-09-25 FNSI-4200ポートを使用している 孫 start
  @Autowired
  private MntCardappPortDao mntCardappPortDao;
  // add 2020-09-25 FNSI-4200ポートを使用している 孫 end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある add yangxuewang end

  @Override
  public String selectPatInfoWriteCard(Long patId) throws Exception {
    return accessCardDao.selectPatInfoWriteCard(patId);
  }

  @Override
  public Boolean setAccessCardIdm(String cardIdm, long idm) throws Exception {

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "mst_user";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" user_id = " + idm + "\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(mstUserDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End
    //mod 7328 IDｍが医療情報DBにて管理されている 関俊楠 start
    int result = mstUserAuthenticationDao.setCardIdm(cardIdm, idm);
    //mod 7328 IDｍが医療情報DBにて管理されている 関俊楠 end
    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && result > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    if (result > 0) {
      return true;
    }
    return false;
  }

  // add 2020-08-13 FNSI-仕様追加 患者基本情報(pat_main)にアクセスカード番号(card_idm)の追加処理 夏 start
  @Override
  public Boolean setPatCardIdm(String cardIdm, long patId) throws Exception {


    long instant = System.currentTimeMillis();

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_main";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" pat_id = " + patId + "\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(patMainDao, tableName, wheres, getEventLogMessage());
    instant = System.currentTimeMillis();

    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End
    instant = System.currentTimeMillis();

    int result = patMainDao.setPatCardIdm(cardIdm, patId);

    instant = System.currentTimeMillis();

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && result > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End


    if (result > 0) {
      return true;
    }
    return false;
  }
  // add 2020-08-13 FNSI-仕様追加 患者基本情報(pat_main)にアクセスカード番号(card_idm)の追加処理 夏 end

  // add 2020-09-25 FNSI-4200ポートを使用している 孫 start
  @Override
  @Transactional
  public Boolean updateCarAppPortInfo(MntCardappPort cardAppPortInfo) throws Exception {

    // クエリーのentity
    MntCardappPort cardAppEntity =  new MntCardappPort();
    cardAppEntity.setGuid(cardAppPortInfo.getGuid());
    cardAppEntity.setFacilityCd(cardAppPortInfo.getFacilityCd());
    cardAppEntity.setClientKey(cardAppPortInfo.getClientKey());

    List<MntCardappPort> resultList = mntCardappPortDao.selectByGuidOrClientKey(cardAppEntity);

    // カードアプリのGUIDで更新FLAG(false:更新無し、true:更新あり)
    boolean updateByGuidFalg = false;
    // クライアント識別子で更新FLAG(false:更新無し、true:更新あり)
    boolean updateByClientKeyFalg = false;

    int result = 0;

    // データがなし場合
    if (resultList == null || resultList.isEmpty() || resultList.size() == 0) {
      // insert データ
      cardAppEntity.setPort(cardAppPortInfo.getPort());

      result = mntCardappPortDao.insert(cardAppEntity);
    } else {
      if (resultList.size() == 1) {
        MntCardappPort data = resultList.get(0);

        if (data.getGuid().equals(cardAppPortInfo.getGuid())
        && data.getClientKey().equals(cardAppPortInfo.getClientKey())
        && data.getPort().equals(cardAppPortInfo.getPort())) {

          // 更新無し
          result = 1;

        } else {
          // カードアプリのGUIDで更新?
          if (data.getGuid().equals(cardAppPortInfo.getGuid())) {
            // カードアプリのGUID更新
            updateByGuidFalg = true;
          } else {
            // ライアント識別子更新
            updateByClientKeyFalg = true;
          }

          // ポートの更新?
          if (!data.getPort().equals(cardAppPortInfo.getPort())) {
            cardAppEntity.setPort(cardAppPortInfo.getPort());
          }
        }
      } else {
        for (MntCardappPort data : resultList) {

          updateByGuidFalg = true;
          if (data.getGuid().equals(cardAppPortInfo.getGuid())) {
            if (!data.getPort().equals(cardAppPortInfo.getPort())) {
              cardAppEntity.setPort(cardAppPortInfo.getPort());
            }
            break;
          }
        }
      }

      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(cardAppEntity,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
      if (updateByGuidFalg) {
        result = mntCardappPortDao.updateByGuid(cardAppEntity);
      } else if (updateByClientKeyFalg) {
        result = mntCardappPortDao.updateByClientKey(cardAppEntity);
      }
    }

    if (result > 0) {
      return true;
    }
    return false;
  }

  @Override
  public List<Integer> selectByFacility(String facilityCd) throws Exception {
    List<Integer> result = mntCardappPortDao.selectByFacility(facilityCd);
    return result;
  }
  // add 2020-09-25 FNSI-4200ポートを使用している 孫 end

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
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
    return   eventLogMessage;
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
