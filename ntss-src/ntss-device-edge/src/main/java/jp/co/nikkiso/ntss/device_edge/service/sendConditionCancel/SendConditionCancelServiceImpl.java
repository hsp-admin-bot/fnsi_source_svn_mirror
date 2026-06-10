package jp.co.nikkiso.ntss.device_edge.service.sendConditionCancel;

import jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo.PatMainAcceptanceStatusInfoService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.rstDialysisState;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.response.sendConditionCancel.SendConditionCancelResponse;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;

@Component
public class SendConditionCancelServiceImpl implements SendConditionCancelService {

  @Autowired
  MstMachineDao mstMachineDao;

  @Autowired
  MntMachineStateDao mntMachineStateDao;

  @Autowired
  PatMainDao patMainDao;

  @Autowired
  OrdMainDao ordMainDao;

  @Autowired
  MntMotionRecordDao mntMotionRecordDao;

  @Autowired
  MniMonitorDao mniMonitorDao;

  @Autowired
  OrdChecklistDao ordChecklistDao;

  @Autowired
  private LogService logService;

  @Autowired
  PatMainAcceptanceStatusInfoService patMainAcceptanceStatusInfoService;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  @Transactional(rollbackFor = Exception.class)
  public SendConditionCancelResponse DoCancelDBAction(Long ordNo, MstMachine machine) throws Exception {
    SendConditionCancelResponse res = new SendConditionCancelResponse();

    // 1 pat_mainの更新
    Long patId = ordMainDao.selectPatIdByOrdNo(ordNo);
    if (patId != null) {
      res = resetPatMain(patId, ordNo);
      if (res.isSuccess == false) {
        // ロールバック実行
        throw new RuntimeException(res.errorMessage);
      }
    }

    // 2 ord_mainの更新
    //    条件送信開始日時を削除＋ステータスを条件送信前に書き換える
    //    それ以外の実績は残す
    res = resetOrdMain(ordNo);
    if (res.isSuccess == false) {
      // ロールバック実行
      throw new RuntimeException(res.errorMessage);
    }

    // 3 mnt_motion_recordの装置記録のorder_noを削除
      //del 9513警報報知一覧で患者名空欄が表示されない。 zhao start
//    res = resetMotionRecord(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
//    if (res.isSuccess == false) {
//      // ロールバック実行
//      throw new RuntimeException(res.errorMessage);
//    }
      //del 9513警報報知一覧で患者名空欄が表示されない。 zhao start

    // 4 mni_monitorのorder_noを削除
    //    血圧・体温・血糖値などはorder_no振替後にも引き継ぐ
    res = resetMniMonitor(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
    if (res.isSuccess == false) {
      // ロールバック実行
      throw new RuntimeException(res.errorMessage);
    }
    // 5 チェックリストのデータを削除
    res = resetCheckList(ordNo);
    if (res.isSuccess == false) {
      // ロールバック実行
      throw new RuntimeException(res.errorMessage);
    }
    // 6 mnt_machine_stateのorder_noを削除(現患者削除)
    res = resetMachineState(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
    if (res.isSuccess == false) {
      // ロールバック実行
      throw new RuntimeException(res.errorMessage);
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse resetPatMain(Long patId, Long ordNo) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();

    try {
      if( patMainAcceptanceStatusInfoService.update(patId, ordNo, rstDialysisState.BEFORE_SEND_CONDITIOM, null, null) > 0 ) {
        res.isSuccess = true;

      } else {
        res.isSuccess = false;
        res.errorMessage = "患者治療状況初期化失敗";
      }
    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = "患者治療状況初期化失敗\n" + e.getMessage();

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage
          .setLogMessage("API resetPatMain() failed. error:" + res.errorMessage);
      eventLogMessage.setPatId(patId.toString());
      eventLogMessage.setSqlIdentification("patId = " + patId);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,
          "PatMainDao/updateResetAcceptanceStatus");
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse resetOrdMain(Long ordNo) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {
      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "ord_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + ordNo + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      /* add by chamaojia 2024-01-22 [10196] When the data is restored to [rst_dialys_state='0'] --start */
      OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
      OrdMain updateOrdMain = new OrdMain();
      updateOrdMain.setOrdNo(ordNo);

      String[] mediAndEquipDeleteKeys = {"class_cd", "class_name",
              "class_type", "name", "short_name", "unit"};
      // 指示：投与薬剤情報
      if (oldOrdMain.getIndMediInfo() != null && !"[]".equals(oldOrdMain.getIndMediInfo())) {
        JSONArray indMediInfoArray = new JSONArray(oldOrdMain.getIndMediInfo());
        for (int i = 0; i < indMediInfoArray.length(); i++) {
          JSONObject indMediInfo = indMediInfoArray.getJSONObject(i);
          for (String deleteKey : mediAndEquipDeleteKeys) {
            indMediInfo.remove(deleteKey);
          }
          indMediInfo.remove("timing_name");
          indMediInfo.remove("procedure_name");
        }
        updateOrdMain.setIndMediInfo(indMediInfoArray.toString());
      } else {
        updateOrdMain.setIndMediInfo(null);
      }

      // 指示：医療材料情報
      if (oldOrdMain.getIndEquipInfo() != null && !"[]".equals(oldOrdMain.getIndEquipInfo())) {
        JSONArray indEquipInfoArray = new JSONArray(oldOrdMain.getIndEquipInfo());
        for (int i = 0; i < indEquipInfoArray.length(); i++) {
          JSONObject indEquipInfo = indEquipInfoArray.getJSONObject(i);
          for (String deleteKey : mediAndEquipDeleteKeys) {
            indEquipInfo.remove(deleteKey);
          }
        }
        updateOrdMain.setIndEquipInfo(indEquipInfoArray.toString());
      } else {
        updateOrdMain.setIndEquipInfo(null);
      }

      // 指示：治療条件情報
      if (oldOrdMain.getIndCondInfo() != null) {
        JSONObject indCondInfo = new JSONObject(oldOrdMain.getIndCondInfo());
//        indCondInfo.remove(TreatmentItemsDef.T_I_DW.getItemCode());
        for (String indCondKey : indCondInfo.keySet()) {
          JSONObject item = (JSONObject)indCondInfo.get(indCondKey);
          item.remove("unit");
          item.remove("value_name_1");
          // "5:ダイアライザ" exist 'value_name_2'
          if ("5".equals(indCondKey)) {
            item.remove("value_name_2");
          }
        }
        updateOrdMain.setIndCondInfo(indCondInfo.toString());
      }
      /* add by chamaojia 2024-01-22 [10196] When the data is restored to [rst_dialys_state='0'] --end */

      int updateCount = ordMainDao.updateCancelSendCondition(updateOrdMain, new Timestamp(System.currentTimeMillis()));

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      if (updateCount > 0) {
        res.isSuccess = true;

      } else {
        res.isSuccess = false;
        res.errorMessage = "治療状況初期化失敗";
      }
    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = "治療状況初期化失敗\n" + e.getMessage();

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage
          .setLogMessage("API resetPatMain() failed. error:" + res.errorMessage);
      eventLogMessage.setSqlIdentification("ordNo = " + ordNo);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "OrdMainDao/updateCancelSendCondition");
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse resetMotionRecord(String facilityCd, String machineTypeCd, String machineSerial,
      Long ordNo) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {
      mntMotionRecordDao.updateClearOrdNo(facilityCd, machineTypeCd, machineSerial, ordNo,
          new Timestamp(System.currentTimeMillis()));
      res.isSuccess = true;

    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = "装置記録情報削除失敗\n" + e.getMessage();

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage
          .setLogMessage("API resetMotionRecord() failed. error:" + res.errorMessage);
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setMachineTypeCd(machineTypeCd);
      eventLogMessage.setSqlIdentification("facility_cd = " + facilityCd + ", machine_type_cd = " + machineTypeCd
          + ", machine_serial = " + machineSerial + ", ordNo = " + ordNo);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "MntMotionRecordDao/updateClearOrdNo");
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse resetMniMonitor(String facilityCd, String machineTypeCd, String machineSerial,
      Long ordNo) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {
      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "mni_monitor";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + ordNo + "\n");
      wheres.append(" AND\n");
      wheres.append(" data_type = 1" + "\n");

      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(mniMonitorDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int updateCount = mniMonitorDao.updateClearOrdNo(ordNo, new Timestamp(System.currentTimeMillis()));

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      res.isSuccess = true;

    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = "モニタデータ情報削除失敗\n" + e.getMessage();

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage
          .setLogMessage("API resetMniMonitor() failed. error:" + res.errorMessage);
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setMachineTypeCd(machineTypeCd);
      eventLogMessage.setSqlIdentification("facility_cd = " + facilityCd + ", machine_type_cd = " + machineTypeCd
          + ", machine_serial = " + machineSerial + ", ordNo = " + ordNo);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "MniMonitorDao/updateClearOrdNo");
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse resetCheckList(Long ordNo) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {
      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "ord_checklist";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + ordNo + "\n");
      wheres.append(" AND\n");
      wheres.append(" is_del = '0'\n");
      wheres.append(" AND\n");
      wheres.append(" is_disp = '1'\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(ordChecklistDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int updateCount = ordChecklistDao.updateClearOrdNo(ordNo, new Timestamp(System.currentTimeMillis()));

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      res.isSuccess = true;

    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = "モニタデータ情報削除失敗\n" + e.getMessage();

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage
          .setLogMessage("API resetCheckList() failed. error:" + res.errorMessage);
      eventLogMessage.setSqlIdentification("ordNo = " + ordNo);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "OrdChecklistDao/updateClearOrdNo");
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse resetMachineState(String facilityCd, String machineTypeCd, String machineSerial,
      Long ordNo) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "mnt_machine_state";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" facility_cd = '" + facilityCd + "'\n");
      wheres.append(" AND\n");
      wheres.append(" machine_type_cd = '" + machineTypeCd + "'\n");
      wheres.append(" AND\n");
      wheres.append(" trim(machine_serial) = '" + machineSerial + "'\n");
      wheres.append(" AND\n");
      wheres.append(" ord_no = " + ordNo + "\n");

      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(mntMachineStateDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int updateCount = mntMachineStateDao.updateClearOrdNo(facilityCd, machineTypeCd, machineSerial, ordNo,
          new Timestamp(System.currentTimeMillis()));

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      res.isSuccess = true;

    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = "装置状態削除失敗\n" + e.getMessage();

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage
          .setLogMessage("API resetMachineState() failed. error:" + res.errorMessage);
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setMachineTypeCd(machineTypeCd);
      eventLogMessage.setSqlIdentification("facility_cd = " + facilityCd + ", machine_type_cd = " + machineTypeCd
          + ", machine_serial = " + machineSerial + ", ordNo = " + ordNo);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "MntMachineStateDao/updateClearOrdNo");
    }
    return res;
  }

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();

    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.NTSS_DEVICE_EDGE + "," + SERVICE_NAME.REMS);
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

   // add AWSとDEの通信断からの復旧 --趙-- start
  @Transactional(rollbackFor = Exception.class)
  public SendConditionCancelResponse DoCancelDBActionCommFail(Long ordNo, MstMachine machine) throws Exception {
    SendConditionCancelResponse res = new SendConditionCancelResponse();

//    // 1 pat_mainの更新
//    Long patId = ordMainDao.selectPatIdByOrdNo(ordNo);
//    if (patId != null) {
//      res = resetPatMain(patId, ordNo);
//      if (res.isSuccess == false) {
//        // ロールバック実行
//        throw new RuntimeException(res.errorMessage);
//      }
//    }

    // 2 ord_mainの更新
    //    条件送信開始日時を削除＋ステータスを条件送信前に書き換える
    //    それ以外の実績は残す
    res = resetOrdMain(ordNo);
    if (res.isSuccess == false) {
      // ロールバック実行
      throw new RuntimeException(res.errorMessage);
    }

    // 3 mnt_motion_recordの装置記録のorder_noを削除
    res = resetMotionRecord(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
    if (res.isSuccess == false) {
      // ロールバック実行
      throw new RuntimeException(res.errorMessage);
    }

    // 4 mni_monitorのorder_noを削除
    //    血圧・体温・血糖値などはorder_no振替後にも引き継ぐ
    res = resetMniMonitor(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
    if (res.isSuccess == false) {
      // ロールバック実行
      throw new RuntimeException(res.errorMessage);
    }
    // 5 チェックリストのデータを削除
    res = resetCheckList(ordNo);
    if (res.isSuccess == false) {
      // ロールバック実行
      throw new RuntimeException(res.errorMessage);
    }
//    // 6 mnt_machine_stateのorder_noを削除(現患者削除)
//    res = resetMachineState(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
//    if (res.isSuccess == false) {
//      // ロールバック実行
//      throw new RuntimeException(res.errorMessage);
//    }
    return res;
  }
  // add AWSとDEの通信断からの復旧 --趙-- end
}
