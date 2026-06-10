package jp.co.nikkiso.ntss.admin_web.service.bloodPurify;

import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstWeightInfo;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.lang3.StringUtils;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.ArrayList;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class MniMonitorServiceImpl implements MniMonitorService {

  @Autowired
  MniMonitorDao mniMonitorDao;
  @Autowired
  MntMachineStateDao mntMachineStateDao;
  @Autowired
  OrdMainDao ordMainDao;
  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

  /**
   * モニタデータ登録
   * @param param モニタデータ
   * @param state 装置状態
   * @return
   * @throws Exception
   */
  private int insertMonitorFunc(MniMonitor param, MntMachineState state) {
    try {
      // データ区分を取得
      Short dataType = param.getDataType();

      // mnt_machine_stateからord_noとpat_idを取得
      MntMachineState machineInfo = mntMachineStateDao.selectByKey(state.getFacilityCd(), state.getMachineTypeCd(),
          state.getMachineSerial());
      if (machineInfo != null) {
//        // ord_no設定
//        param.setOrdNo(machineInfo.getOrdNo());
//        // pat_id設定
//        param.setPatId(machineInfo.getPatId());

        // オーダー番号判定
        if ( param.getOrdNo() != null ) {
          // オーダー番号が有効な場合

          // 前/後血圧判定
          if (dataType.equals((short)5) || dataType.equals((short)6)) {

            // DB更新ログ出力ロジック wangzuo Start
            String tableName = "mni_monitor";
            // SQL検索条件
            StringBuffer wheres = new StringBuffer("");
            wheres.append(" WHERE\n");
            wheres.append(" ord_no = " + param.getOrdNo() + "\n");
            wheres.append(" AND\n");
            wheres.append(" data_type = " + dataType + "\n");

            // logCommon設定
            DataUpdateLogCommonNew logCommon = getLogCommon(mniMonitorDao, tableName, wheres, getEventLogMessage());
            // ログ出力カラム情報及び更新前データ情報取得
            boolean setResult = logCommon.setInfo();
            // DB更新ログ出力ロジック wangzuo End

            // 登録前に既に存在している前/後血圧のデータ種別を「2：透析中血圧」に変更する
            int updateCount = mniMonitorDao.updateDataTypeByOrdNoDataType( param.getOrdNo(), dataType, (short)2);

            // DB更新ログ出力ロジック wangzuo Start
            // 更新後データ取得、差分あれば、log出力
            if (setResult && updateCount > 0) {
              logCommon.updateLog();
            }
            // DB更新ログ出力ロジック wangzuo End
          }
//          // statusの下位1bit（治療中ビット）はDBの値を使用する
//          Integer treatState = machineInfo.getMachineStatus() & 0x01;
//          Integer targetState = state.getMachineStatus() & 0xFE;
//          // DBの治療中ビット + 受信値のその他ビット
//          // NOTE: 通信SVが書き換えた治療中ビットが、遅れて送信された装置受信データで上書きされる問題の対策
//          state.setMachineStatus(treatState + targetState);
        }
      }

      // データ登録
      mniMonitorDao.insert(param);
//      mntMachineStateDao.updateMachineState(state);

      // データ種別判定
      if (dataType.equals((short)3) && (param.getOrdNo() != null && 0 < param.getOrdNo())) {
        // 再循環率を登録した場合でord_noがある場合

        //        Integer reLoopRateMain = null;
        //        // モニタデータ取得
        //        ObjectMapper mapMonitor = new ObjectMapper();
        //        JsonNode node = mapMonitor.readTree(param.getMonitorData());
        //
        //        // 89:再循環率を取得
        //        JsonNode item = node.get("89");
        //        if (item != null) {
        //          reLoopRateMain = item.asInt();
        //        }
        // 生体モニタリング管理番号
        Long reLoopRateMain = param.getBioMoniCtlNo();

        // 指定したord_noのord_mainから実績：体重情報を取得
        ObjectMapper mapWeight = new ObjectMapper();
        String weight = ordMainDao.selectWeightInfo(param.getOrdNo());
        OrdMainRstWeightInfo dto = weight == null || weight.isEmpty() ? new OrdMainRstWeightInfo()
            : mapWeight.readValue(weight, OrdMainRstWeightInfo.class);
        // 再循環率を登録
        dto.setReLoopRateMain(reLoopRateMain);

        // add FNSI-改修内容追加OrdMain履歴 付 start
        selectHistoryUtils.insertMangoDbHistory(1, param.getOrdNo(), null, new ArrayList<>(), new ArrayList<>(), null, null,
          null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
          new ArrayList<>(), null, null);
        // mangoDb-updateWeightInfo-insertSuccess
        // add FNSI-改修内容追加OrdMain履歴 付 end

        // 対象のord_noのord_mainに再循環率を登録
        ordMainDao.updateWeightInfo(param.getOrdNo(), mapWeight.writeValueAsString(dto));
      }
    } catch (IOException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (state != null && !StringUtils.isEmpty(state.getFacilityCd())) {
        eventLogMessage.setFacilityCd(state.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    return 1;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int insertMonitor(MniMonitor param, MntMachineState state) {
    //    try {
    //      mniMonitorDao.insertMonitor(param);
    //      mntMachineStateDao.updateMachineState(state);
    //    } catch (RuntimeException e) {
    //      e.printStackTrace();
    //      throw e;
    //    }
    //
    //  return 1;
    return this.insertMonitorFunc(param, state);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int insertMonitorDyalysisStart(MniMonitor param, MntMachineState state) {
    //    mniMonitorDao.insertMonitor(param);
    //    mntMachineStateDao.updateDialStart(state);
    //    return 1;
    return this.insertMonitorFunc(param, state);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int insertMonitorDyalysisFinish(MniMonitor param, MntMachineState state) {
    //    mniMonitorDao.insertMonitor(param);
    //    mntMachineStateDao.updateDialEnd(state);
    //    return 1;
    return this.insertMonitorFunc(param, state);
  }

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

  @Override
  public MniMonitor selectMonitorByFacilityCdAndPatIdAndOrdNo(String facilityCd, Long patId, Long ordNo) {
    return mniMonitorDao.selectMonitorByFacilityCdAndPatIdAndOrdNo(facilityCd,patId,ordNo);
  }
}
