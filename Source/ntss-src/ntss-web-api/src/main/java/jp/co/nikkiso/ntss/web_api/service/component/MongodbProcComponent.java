package jp.co.nikkiso.ntss.web_api.service.component;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.KEY_FACILITY_CD;

import java.util.ArrayList;
import java.util.List;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Component;

import com.mongodb.client.result.DeleteResult;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.service.component.IndHistory;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.web_api.util.ErrorMessageUtil;

/**
 * MongoDBの処理をするコンポーネントクラス。
 */
@Component
public class MongodbProcComponent {

  // サービス
  /** ログサービス */
  @Autowired
  private LogService logService;

  @Autowired(required = false)
  private MongoTemplate mongoTemplate;

  /**
   * バックアップ対象レコードを取得する。
   *
   * @param facilityCd 施設コード
   * @return バックアップ対象レコードリスト
   */
  public List<IndHistory> getBackupTarget(String facilityCd) throws Exception {
    Query query = new Query(Criteria.where(KEY_FACILITY_CD).is(facilityCd));
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        return mongoTemplate.find(query, IndHistory.class);
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    return new ArrayList<IndHistory>();
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
  }

  /**
   * 削除対象の件数取得する。
   *
   * @param facilityCd 施設コード
   * @return 削除対象の件数
   */
  public Long getDeleteTargetCount(String facilityCd) {
    Query recordCount = new Query(Criteria.where(KEY_FACILITY_CD).is(facilityCd));
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        return mongoTemplate.count(recordCount, IndHistory.class);
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    return 0L;
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
  }

  /**
   * 削除対象レコードの削除。
   *
   * @param facilityCd 施設コード
   * @return 削除した件数
   */
  public Long deleteTarget(String facilityCd) {
    Query recordCount = new Query(Criteria.where(KEY_FACILITY_CD).is(facilityCd));
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        DeleteResult delRtn = mongoTemplate.remove(recordCount, IndHistory.class);
        return delRtn.getDeletedCount();
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      String errMsg = "MongoDBの解約施設のレコード削除でDBエラーが発生しました。";
      EventLogMessage msg = ErrorMessageUtil.createMessage(facilityCd, errMsg);
      msg.setSupportMessage(exception.toString());
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      if (facilityCd != null) {
        msg.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
      logService.log(LogLevel.ERROR, msg, null, SERVICE_NAME.REMS, null);
      throw new NtssException(errMsg, exception);
    }
    return 0L;
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
  }
}
