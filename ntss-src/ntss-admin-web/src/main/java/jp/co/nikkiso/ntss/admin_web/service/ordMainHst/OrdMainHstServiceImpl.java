package jp.co.nikkiso.ntss.admin_web.service.ordMainHst;
import com.mongodb.bulk.BulkWriteResult;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.mongodb.core.BulkOperations;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;

import java.util.List;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


@Service
public class OrdMainHstServiceImpl implements OrdMainHstService {

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

	@Autowired(required = false)
	MongoTemplate mongoTemplate;
	//システム起動時のprofiles(MongoDBに接続しているなら"mongo",そうでないなら空)
	//@Value("${spring.config.activate:on-profile}")
	//private String profiles;

  @Override
  public OrdMainHst create(OrdMainHst params) {
    try {
      //MongoDBに接続しているか判定
      //if("mongo".equals(this.profiles))
      if (mongoTemplate != null) {
        //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
        try {
          if (MongoHealthCheckService.getMongoDBConnected()) {
            mongoTemplate.insert(params);
          }
        } catch (DataAccessResourceFailureException exception) {
          MongoHealthCheckService.setMongoDBConnected(false);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          if (params != null && !StringUtils.isEmpty(params.getFacilityCd())) {
            eventLogMessage.setFacilityCd(params.getFacilityCd());
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        }
        //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (params != null && !StringUtils.isEmpty(params.getFacilityCd())) {
        eventLogMessage.setFacilityCd(params.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    return params;
  }

  @Override
  public int bulkOpsCreate(List<OrdMainHst> dataList) {
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        BulkWriteResult bulkWriteResult = mongoTemplate.bulkOps(BulkOperations.BulkMode.ORDERED,OrdMainHst.class).insert(dataList).execute();
        return bulkWriteResult.getInsertedCount();
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    return 0;
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end

  }


}
