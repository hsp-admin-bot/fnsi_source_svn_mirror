package jp.co.nikkiso.ntss.admin_web.service.master.machineRecord;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
// add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 start
import jp.co.nikkiso.ntss.core.dao.MstDiseaseDao;
import jp.co.nikkiso.ntss.core.entity.MstDisease;
// add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 end
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.dao.MstMachineRecordControlDao;
import jp.co.nikkiso.ntss.core.entity.MstMachineRecordControl;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

/**
 * 装置記録マスタのService実装クラス.
 */
@Service
public class MasterMachineRecordServiceImpl implements MasterMachineRecordService {

  //DB更新ログ出力ロジック wp start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  //DB更新ログ出力ロジック wp end

  @Autowired
  private LogService logService;

  /**
   * 装置記録マスタ
   */
  @Autowired
  private MstMachineRecordControlDao mstMachineRecordControlDao;

  // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 start
  /**
   * 病名マスタ
   */
  @Autowired
  private MstDiseaseDao mstDiseaseDao;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 end


  @Override
  @Transactional
	public void updateMasterData(Map<String, List<String>> payload) throws Exception {
			ObjectMapper mapper = new ObjectMapper();
			// 登録処理
			for (int i = 0; payload.get("insertRecord").size() > i; i++) {
				MstMachineRecordControl mstMachineRecordControl = mapper.readValue(payload.get("insertRecord").get(i),
						MstMachineRecordControl.class);
				// update実行し対象がない場合にinsertを追加実行
        //DB更新ログ出力ロジック wp start

        String mmsTbN = "mst_machine_record_control";

        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" machine_record_cd = '" + mstMachineRecordControl.getMachineRecordCd() + "'" +"\n");
        wheres.append(" and \n");
        wheres.append(" facility_cd = '" + mstMachineRecordControl.getFacilityCd() + "'" +"\n");
        // logCommon設定
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(mmsTbN, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        //DB更新ログ出力ロジック wp end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(mstMachineRecordControl,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
				int result = mstMachineRecordControlDao.update(mstMachineRecordControl);
				if(result == 0 ) {
					result = mstMachineRecordControlDao.insert(mstMachineRecordControl);
				}
        //DB更新ログ出力ロジック wp start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && result > 0) {
          logCommon.updateLog();
        }
        //DB更新ログ出力ロジック wp end
			}
	}

  // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 start
  /**
   * 病名マスタを件数取得する
   */
  @Override
  public String getTotal(String facilityCd) {
    return mstDiseaseDao.getTotal(facilityCd);
  }

  /**
   * 病名マスタを全件取得する.分頁
   */
  @Override
  public List<MstDisease> getMstDiseaseByLimitAndOffset(Integer limit, String facilityCd, Integer offset) {
    return mstDiseaseDao.getMstDiseaseByLimitAndOffset(limit, facilityCd, offset);
  }
  // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 end

  //DB更新ログ出力ロジック wp start

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
  private DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }

  //DB更新ログ出力ロジック wp end
}
