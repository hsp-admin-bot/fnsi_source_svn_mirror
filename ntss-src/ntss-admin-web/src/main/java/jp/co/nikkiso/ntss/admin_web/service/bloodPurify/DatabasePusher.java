package jp.co.nikkiso.ntss.admin_web.service.bloodPurify;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import com.fasterxml.jackson.core.JsonProcessingException;
import jp.co.nikkiso.ntss.admin_web.request.bloodPurify.EnumRcvDataKind;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstWeightInfo;
import jp.co.nikkiso.ntss.core.entity.custom.RecrclRt;
import jp.co.nikkiso.ntss.core.entity.custom.RecrclRtElement;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.OrdMainConst;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.WebSocketTopic;
import jp.co.nikkiso.ntss.admin_web.request.bloodPurify.TelegramControl;
import jp.co.nikkiso.ntss.admin_web.request.bloodPurify.TelegramItems;
import jp.co.nikkiso.ntss.admin_web.request.bloodPurify.TelegramKey;
import jp.co.nikkiso.ntss.admin_web.request.bloodPurify.dto.MntMotionRecordStaticValues;
import jp.co.nikkiso.ntss.admin_web.response.weight.SendConditionResponse;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfo;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfoItem;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfoService;
import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService.SendTarget;
import jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo.PatMainAcceptanceStatusInfoService;
import jp.co.nikkiso.ntss.core.dao.ComsvOrdMainDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.ExternalAlarmCode;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq41;

import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class DatabasePusher {

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;

  @Autowired
  MstMachineDao mstMachineDao;
  @Autowired
  MntMachineStateDao mntMachineStateDao;
  @Autowired
  OrdMainDao ordMainDao;
  @Autowired
  ComsvOrdMainDao comsvOrdMainDao;

  @Autowired
  OrdMainService ordMainService;
  @Autowired
  MntMachineStateService mntMachineStateService;
  @Autowired
  MntMotionRecordService mntMotionRecodeService;
  @Autowired
  MniMonitorService mniMonitorService;
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  @Autowired
  PatMainAcceptanceStatusInfoService patMainAcceptanceStatusInfoService;
  @Autowired
  CondInfoService condInfoService;

  @Autowired
  WebSocketNotifyService sendWsMsg;

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


  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  @Autowired
  private TriggerUtil triggerUtil;

  // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 start
  private static class LogData {
    public String data;
  }
  // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 end

  public boolean run(Long ordNo, InputStream is) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    String strTelegram;
    try {
      strTelegram = TelegramControl.convertInputStreamToString(is);
      eventLogMessage.setLogMessage("DatabasePusher.run receive Telegram:" + strTelegram);
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

      if (strTelegram.trim().length() == 0) {
        // 電文なし
        eventLogMessage.setLogMessage(LogMessage.INFO_TELEGRAM_EMPTY);
        logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        return true;
      }

    } catch (IOException e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_TELEGRAM_STREAM + e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return false;
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_TELEGRAM_STREAM + e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return false;
    }

    // 指定されたオーダー番号の治療記録を取得する
    OrdMain ord = ordMainService.selectByOrdNo(ordNo);
    // 施設コードを取得
    String facilityCd = ord.getFacilityCd();
    // 患者Idを取得
    String patId = ord.getPatId() == null ? null : ord.getPatId().toString();
    // 対象装置情報を取得
    String deviceEdgeNo[] = { null };
    String machineTypeCd[] = { null };
    String machineSerial[] = { null };
    String machineFormatCd[] = { null };
    Long machineNo = ord.getRstMachineNo();
    MstMachine machine = mstMachineDao.selectByMachineNo(machineNo);
    if (machine != null) {
      deviceEdgeNo[0] = machine.getDeviceEdgeNo() == null ? null : machine.getDeviceEdgeNo().toString();
      machineTypeCd[0] = machine.getMachineTypeCd();
      machineSerial[0] = machine.getMachineSerial();
      machineFormatCd[0] = machine.getComFormatCd();
    }
    // add #8122 特殊浄化通信アプリからのモニタデータアップロードにてサーバが高負荷となりダウンする。 夏 start
    else {
      List<MstMachine> mstMachineList = mstMachineDao.selectByFacility(facilityCd);
      if(mstMachineList != null && !mstMachineList.isEmpty()){
        mstMachineList.forEach(it -> {if(it.getMachineName().equals(ord.getRstMachineName())){
          deviceEdgeNo[0] = it.getDeviceEdgeNo() == null ? null : it.getDeviceEdgeNo().toString();
          machineTypeCd[0] = it.getMachineTypeCd();
          machineSerial[0] = it.getMachineSerial();
          machineFormatCd[0] = it.getComFormatCd();}
        });
        if(machineTypeCd[0] == null || machineSerial[0] == null){
          return false;
        }
      }else{
        return false;
      }
    }
    // add #8122 特殊浄化通信アプリからのモニタデータアップロードにてサーバが高負荷となりダウンする。 夏 end

    // fixed FNSI-モニタデータ取込 孫灝 20201028 start
    final String CONVERT_FAIL_FLG = "convertFailFlg";
    Map<String, Boolean> convertFailFlgMap = new HashMap<>();
    convertFailFlgMap.put(CONVERT_FAIL_FLG, false);
    // fixed FNSI-モニタデータ取込 孫灝 20201028 end
    TelegramControl.convertTelegramToStringList(strTelegram).forEach(telegramLine -> {

      // 1行分の項目を分解
      TelegramItems items = new TelegramItems(telegramLine);

      // 治療記録から取得した以下の値を設定
      //  施設コード
      items.setItemValue(TelegramKey.KEY_FACILITY_CD, facilityCd);
      //  オーダー番号
      items.setItemValue(TelegramKey.KEY_ORD_NO, ordNo.toString());
      //  患者Id
      items.setItemValue(TelegramKey.KEY_PAT_ID, patId);
      //  デバイスエッジ番号
      if (deviceEdgeNo[0] != null) {
        items.setItemValue(TelegramKey.KEY_EDGE_NO, deviceEdgeNo[0]);
      }
      //  装置型式コード
      if (machineTypeCd[0] != null) {
        items.setItemValue(TelegramKey.KEY_DEVICE_TYPE, machineTypeCd[0]);
      }
      //  装置製造番号
      if (machineSerial[0] != null) {
        items.setItemValue(TelegramKey.KEY_SERIAL_NO, machineSerial[0]);
      }
      //  装置通信フォーマット
      if (machineFormatCd[0] != null) {
        items.setItemValue(TelegramKey.KEY_COMM_FORMAT, machineFormatCd[0]);
      }

      // データ種別判定
      // fixed FNSI-モニタデータ取込 孫灝 20201028 start
      // telKindを空判断
      EnumRcvDataKind telKind = items.getTelegramKind();
      if (telKind == null) {
        eventLogMessage.setLogMessage(LogMessage.WARN_KIND_UNDEFINED + String.join(",", telegramLine));
        logService.log(LogLevel.WARN, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        convertFailFlgMap.put(CONVERT_FAIL_FLG, true);
        return;
      } else {
        // fixed FNSI-モニタデータ取込 孫灝 20201028 end
        switch (items.getTelegramKind()) {
          case LOG:
            // 装置記録
            runWriteMotionRecordLog(items);
            break;

          case MONITER:
          case MONITER_START:
          case MONITER_FINISH:
          case C_MONITER:
            // 透析中モニタデータ/透析開始/透析終了
            runWriteMonitor(items);
            break;
          case MNT_UFRC_SELF:
            // UFRC自己診断
            runWriteMotionRecordMnt(items, MntMotionRecordStaticValues.DataType.SELF_DIAGNOSIS,
                MntMotionRecordStaticValues.TestType.UFRC);
            break;
          case MNT_BLEEDING:
            // 漏血テスト
            runWriteMotionRecordMnt(items, MntMotionRecordStaticValues.DataType.SELF_DIAGNOSIS,
                MntMotionRecordStaticValues.TestType.BLEEDING);
            break;
          case MNT_DIALYSIS_FLOW:
            // 透析液流量自己診断
            runWriteMotionRecordMnt(items, MntMotionRecordStaticValues.DataType.SELF_DIAGNOSIS,
                MntMotionRecordStaticValues.TestType.DIALYSIS_FLOW);
            break;
          case MNT_CONCENTRATION:
            // 濃度自己診断
            runWriteMotionRecordMnt(items, MntMotionRecordStaticValues.DataType.SELF_DIAGNOSIS,
                MntMotionRecordStaticValues.TestType.CONCENTRATION);
            break;
          case MNT_TIME:
          case USE_TIME:
          case C_USE_TIME:
            // 動作時間/稼働時間
            runWriteUseTime(items);
            break;
          case PIPE_TEST:
            // 配管テスト
            runWriteMotionRecordMnt(items, MntMotionRecordStaticValues.DataType.SELF_DIAGNOSIS,
                MntMotionRecordStaticValues.TestType.PIPE_TEST);
            break;
          case DILUTION_TEST:
            // 希釈テスト
            runWriteMotionRecordMnt(items, MntMotionRecordStaticValues.DataType.SELF_DIAGNOSIS,
                MntMotionRecordStaticValues.TestType.DILUTION_TEST);
            break;
          case DISSOLUTION:
            // 溶解記録
            runWriteMotionRecordDar(items);
            break;

          case C_LOG:
            // 装置記録(通信共通)
            runWriteMotionRecordLogCommonComm(items);
            break;
          case C_MNT_SELF:
            // 自己診断結果(通信共通V4)
            runWriteMotionRecordMntCommonCommV4(items, MntMotionRecordStaticValues.DataType.SELF_DIAGNOSIS,
                MntMotionRecordStaticValues.TestType.COMMON_COMM_V4);
            break;

          case BP_START:
            // 治療開始
            this.setRstStartDate(items);
            this.updateMedicatedRstMedi(items);
            break;
          case BP_END:
            // 治療終了
            this.setRstEndDate(items);
            break;
          case BP_DEVICE_TYPE:
            // 治療装置種別
            this.setBloodPurifierName(items);
            break;
          case BP_LAST_MONITOR:
            // 最終モニタ値
            this.setRstMonitor(items);
            break;
          // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 start
          case LOG_MONITOR:
            // ログモニタ値
            this.setLogMonitor(items);
            break;
          // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 end

          default:
            eventLogMessage.setLogMessage(LogMessage.WARN_KIND_UNDEFINED + String.join(",", telegramLine));
            logService.log(LogLevel.WARN, eventLogMessage, "", SERVICE_NAME.FNSI, null);
            break;
        }
      }
    });

    // fixed FNSI-モニタデータ取込 孫灝 20201028 start
    if(convertFailFlgMap.get(CONVERT_FAIL_FLG)) {
      return false;
    }
    // fixed FNSI-モニタデータ取込 孫灝 20201028 end

    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(7, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateIsConfirm-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "ord_main";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    // add #8122 特殊浄化通信アプリからのモニタデータアップロードにてサーバが高負荷となりダウンする。 夏 start
    wheres.append(" ord_no = " + ordNo + "\n");
    wheres.append(" AND\n");
    // add #8122 特殊浄化通信アプリからのモニタデータアップロードにてサーバが高負荷となりダウンする。 夏 end
    wheres.append(" is_confirm = '1'\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    // 版確定フラグが「1：確定」の場合に「0：未確定」にする
    int updateCount = ordMainDao.updateIsConfirm(ordNo, "1", "0");

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    return true;
  }

  /**
   * モニタデータ書き込み
   * @param items
   * @return
   */
  public boolean runWriteMonitor(TelegramItems items) {
    MniMonitor rcd = new MniMonitor();
    rcd.setFacilityCd(items.getItemValue(TelegramKey.KEY_FACILITY_CD));
    rcd.setMachineTypeCd(items.getItemValue(TelegramKey.KEY_DEVICE_TYPE));
    rcd.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    String ordNo = items.getItemValue(TelegramKey.KEY_ORD_NO);
    rcd.setOrdNo(StrUtils.isNumber(ordNo) ? Long.parseLong(ordNo) : null);
    String patId = items.getItemValue(TelegramKey.KEY_PAT_ID);
    rcd.setPatId(StrUtils.isNumber(patId) ? Long.parseLong(patId) : null);
    rcd.setOccurDate(telegramDateToTimestamp(items.getItemValue(TelegramKey.KEY_OCCUR_DATE)));
    rcd.setMonitorData(items.getItemValue(TelegramKey.KEY_ITEMS));
    short nClass = 0;
    String strClass = items.getItemValue(TelegramKey.KEY_CLASS);
    if (strClass != null && StrUtils.isNumber(strClass)) {
      nClass = Short.parseShort(strClass);
    }
    rcd.setDataType(nClass);
    rcd.setIsDel("0");

    MntMachineState state = new MntMachineState();
    state.setFacilityCd(items.getItemValue(TelegramKey.KEY_FACILITY_CD));
    state.setMachineTypeCd(items.getItemValue(TelegramKey.KEY_DEVICE_TYPE));
    state.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    state.setUseTime(items.getItemValue(TelegramKey.KEY_ITEMS));
    state.setUpDate(telegramDateToTimestamp(items.getItemValue(TelegramKey.KEY_OCCUR_DATE)));
    state.setMachineStatus(items.getItemCommStatus());

    switch (items.getTelegramKind()) {
    case MONITER:
    case C_MONITER:
      // 透析中モニタデータ
      return runWriteMonitorDefault(rcd, state);
    case MONITER_START:
      // 透析開始
      return runWriteMonitorStart(rcd, state);
    case MONITER_FINISH:
      // 透析終了
      return runWriteMonitorFinish(rcd, state);
    default:
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(LogMessage.WARN_KIND_UNDEFINED + items.getTelegramKind());
      logService.log(LogLevel.WARN, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return false;
    }
  }

  public boolean runWriteMonitorDefault(MniMonitor rcd, MntMachineState state) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      if (mniMonitorService.insertMonitor(rcd, state) > 0) {
        eventLogMessage.setLogMessage("Insert MniMonitor SUCCESS.");
        logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MONITOR);
      logService.log(LogLevel.WARN, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MONITOR + e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
    return false;
  }

  public boolean runWriteMonitorStart(MniMonitor rcd, MntMachineState state) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      if (mniMonitorService.insertMonitorDyalysisStart(rcd, state) > 0) {
        eventLogMessage.setLogMessage("Insert MniMonitor <Dyalysis Start> SUCCESS.");
        logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MONITOR);
      logService.log(LogLevel.WARN, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MONITOR + e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
    return false;
  }

  public boolean runWriteMonitorFinish(MniMonitor rcd, MntMachineState state) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      if (mniMonitorService.insertMonitorDyalysisFinish(rcd, state) > 0) {
        eventLogMessage.setLogMessage("Insert MniMonitor <Dyalysis Finish> SUCCESS.");
        logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MONITOR);
      logService.log(LogLevel.WARN, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MONITOR + e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
    return false;
  }

  /**
   * 装置記録のDB書き込み
   *
   * @param items
   * @return
   */
  public boolean runWriteMotionRecordLog(TelegramItems items) {
    MntMotionRecord rcd = new MntMotionRecord();
    rcd.setFacilityCd(items.getItemValue(TelegramKey.KEY_FACILITY_CD));
    rcd.setEventRegDate(telegramDateToTimestamp(items.getItemValue(TelegramKey.KEY_OCCUR_DATE)));
    String edgeNo = items.getItemValue(TelegramKey.KEY_EDGE_NO);
    rcd.setDeviceEdgeNo(edgeNo != null && StrUtils.isNumber(edgeNo) ? Integer.parseInt(edgeNo) : null);
    rcd.setMachineTypeCd(items.getItemValue(TelegramKey.KEY_DEVICE_TYPE));
    rcd.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    rcd.setComFormatCd(items.getItemValue(TelegramKey.KEY_COMM_FORMAT));
    rcd.setDataType(MntMotionRecordStaticValues.DataType.LOG);
    rcd.setMachineRecordCd(items.getItemValue(TelegramKey.KEY_CODE));
    String ordNo =  items.getItemValue(TelegramKey.KEY_ORD_NO);
    rcd.setOrdNo( StrUtils.isNumber(ordNo) ? Long.parseLong(ordNo): null ) ;
    short nClass = 0;
    String strClass = items.getItemValue(TelegramKey.KEY_CLASS);
    if (strClass != null && StrUtils.isNumber(strClass)) {
      nClass = Short.parseShort(strClass);
    }
    rcd.setLogType(nClass);
    String machineRecordCd = items.getItemValue(TelegramKey.KEY_CODE);

    String auxDataValue = "";
    List<String> auxDataArray;
    if (items.getItemValue(TelegramKey.KEY_VERSION).equals("00")) {
      // 新通信
      auxDataArray = new ArrayList<>(Arrays.asList(
          items.getItemValue(TelegramKey.KEY_AUX_DATA_1),
          items.getItemValue(TelegramKey.KEY_AUX_DATA_2),
          items.getItemValue(TelegramKey.KEY_AUX_DATA_3),
          items.getItemValue(TelegramKey.KEY_AUX_DATA_4)));

      auxDataValue = String.format("%s,%s,%s,%s",
          auxDataArray.get(0), auxDataArray.get(1),
          auxDataArray.get(2), auxDataArray.get(3));

      // 装置記録補助データ
      rcd.setMachineRecordAuxData(auxDataValue);
    } else {
      // NX通信
      String data0 = items.getItemValue(TelegramKey.KEY_AUX_DATA_0);
      String data2 = items.getItemValue(TelegramKey.KEY_AUX_DATA_2);
      String data3 = items.getItemValue(TelegramKey.KEY_AUX_DATA_3);
      String data4 = items.getItemValue(TelegramKey.KEY_AUX_DATA_4);
      String data5 = items.getItemValue(TelegramKey.KEY_AUX_DATA_5);
      String data6 = items.getItemValue(TelegramKey.KEY_AUX_DATA_6);
      String data7 = items.getItemValue(TelegramKey.KEY_AUX_DATA_7);

      auxDataArray = new ArrayList<>(Arrays.asList(data3, data4, data5, data6));

      if (data2 != null) {
        auxDataValue += String.format("2,%s", data2);
      }
      if (data0 != null || data3 != null) {
        if (auxDataValue.length() > 0) {
          auxDataValue += ",";
        }
        if (data0 != null) {
          if (data3 != null) {
            auxDataValue += String.format("3,%s,%s", data0, data3);
          } else {
            auxDataValue += String.format("3,%s", data0);
          }
        } else {
          auxDataValue += String.format("3,%s", data3);
        }
      }
      if (data4 != null) {
        if (auxDataValue.length() > 0) {
          auxDataValue += ",";
        }
        auxDataValue += String.format("4,%s", data4);
      }
      if (data5 != null) {
        if (auxDataValue.length() > 0) {
          auxDataValue += ",";
        }
        auxDataValue += String.format("5,%s", data5);
      }
      if (data6 != null) {
        if (auxDataValue.length() > 0) {
          auxDataValue += ",";
        }
        auxDataValue += String.format("6,%s", data6);
      }
      if (data7 != null) {
        if (auxDataValue.length() > 0) {
          auxDataValue += ",";
        }
        auxDataValue += String.format("7,%s", data7);
      }

      // 装置記録補助データ
      rcd.setMachineRecordAuxData(auxDataValue);

    }

    EventLogMessage eventLogMessage = new EventLogMessage();

    if (ExternalAlarmCode.EXTERNAL_ALARM_1_ON.equals(machineRecordCd) ||
        ExternalAlarmCode.EXTERNAL_ALARM_2_ON.equals(machineRecordCd) ||
        ExternalAlarmCode.EXTERNAL_ALARM_3_ON.equals(machineRecordCd) ||
        ExternalAlarmCode.EXTERNAL_ALARM_4_ON.equals(machineRecordCd) ||
        ExternalAlarmCode.EXTERNAL_ALARM_1_OFF.equals(machineRecordCd) ||
        ExternalAlarmCode.EXTERNAL_ALARM_2_OFF.equals(machineRecordCd) ||
        ExternalAlarmCode.EXTERNAL_ALARM_3_OFF.equals(machineRecordCd) ||
        ExternalAlarmCode.EXTERNAL_ALARM_4_OFF.equals(machineRecordCd)) {
      // 外部警報メッセージ変換処理を呼び出してメッセージ登録
      rcd.setMachineRecordMessage(convertExternalAlarmMessage(machineRecordCd, items.getItemValue(TelegramKey.KEY_FACILITY_CD), items.getItemValue(TelegramKey.KEY_MSG)));
      // 装置記録書き込み
      try {
        if (mntMotionRecodeService.insertLogMotionMessageAndOrdNo(rcd) > 0) {
          eventLogMessage.setLogMessage("Insert MotionRecode SUCCESS.");
          logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
          return true;
        }
        eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_LOG);
        logService.log(LogLevel.WARN, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      } catch (Exception e) {
        eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_LOG + e);
        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      }
      return false;
    }

    // 装置記録書き込み
    try {
      if (mntMotionRecodeService.insertLogMotionAndOrdNo(rcd,
          auxDataArray.get(0), auxDataArray.get(1),
          auxDataArray.get(2), auxDataArray.get(3)) > 0) {
        eventLogMessage.setLogMessage("Insert MotionRecode SUCCESS.");
        logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_LOG);
      logService.log(LogLevel.WARN, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_LOG + e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
    return false;
  }

  /**
   * メンテナンスのDB書き込み
   *
   * @param items
   * @param dataType
   * @param testType
   * @return
   */
  public boolean runWriteMotionRecordMnt(TelegramItems items, int dataType, int testType) {
    MntMotionRecord rcd = new MntMotionRecord();
    rcd.setFacilityCd(items.getItemValue(TelegramKey.KEY_FACILITY_CD));
    rcd.setEventRegDate(telegramDateToTimestamp(items.getItemValue(TelegramKey.KEY_OCCUR_DATE)));
    String edgeNo = items.getItemValue(TelegramKey.KEY_EDGE_NO);
    rcd.setDeviceEdgeNo(edgeNo != null && StrUtils.isNumber(edgeNo) ? Integer.parseInt(edgeNo) : null);
    rcd.setMachineTypeCd(items.getItemValue(TelegramKey.KEY_DEVICE_TYPE));
    rcd.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    rcd.setComFormatCd(items.getItemValue(TelegramKey.KEY_COMM_FORMAT));
    rcd.setDataType(dataType);
    rcd.setTestType(testType);
    rcd.setMachineRecordMessage(MntMotionRecordStaticValues.MachineRecordMessage.getTestTypeMessage(testType));
    rcd.setContents(items.getItemValue(TelegramKey.KEY_ITEMS));

    EventLogMessage eventLogMessage = new EventLogMessage();

    try {
      if (mntMotionRecodeService.insertMntMotion(rcd) > 0) {
        eventLogMessage.setLogMessage("Insert MotionRecode Maintenance SUCCESS.");
        logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_MNT);
      logService.log(LogLevel.WARN, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_MNT + e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
    return false;
  }

  /**
   * 溶解記録のDB書き込み
   *
   * @param items
   * @return
   */
  public boolean runWriteMotionRecordDar(TelegramItems items) {
    MntMotionRecord rcd = new MntMotionRecord();
    rcd.setFacilityCd(items.getItemValue(TelegramKey.KEY_FACILITY_CD));
    rcd.setEventRegDate(telegramDateToTimestamp(items.getItemValue(TelegramKey.KEY_OCCUR_DATE)));
    String edgeNo = items.getItemValue(TelegramKey.KEY_EDGE_NO);
    rcd.setDeviceEdgeNo(edgeNo != null && StrUtils.isNumber(edgeNo) ? Integer.parseInt(edgeNo) : null);
    rcd.setMachineTypeCd(items.getItemValue(TelegramKey.KEY_DEVICE_TYPE));
    rcd.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    rcd.setComFormatCd(items.getItemValue(TelegramKey.KEY_COMM_FORMAT));
    rcd.setDataType(MntMotionRecordStaticValues.DataType.DISSOLUTION);
    rcd.setMachineRecordMessage(MntMotionRecordStaticValues.MachineRecordMessage.DISSOLUTION);
    rcd.setContents(items.getItemValue(TelegramKey.KEY_ITEMS));

    EventLogMessage eventLogMessage = new EventLogMessage();

    try {
      if (mntMotionRecodeService.insertDarMotion(rcd) > 0) {
        eventLogMessage.setLogMessage("Insert MotionRecode DAR SUCCESS.");
        logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_DAR);
      logService.log(LogLevel.WARN, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_DAR + e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
    return false;
  }

  /**
   * 稼働時間をDB書き込みする処理
   *
   * @param is
   * @return
   */
  public boolean runWriteUseTime(TelegramItems items) {
    MntMachineState param = new MntMachineState();
    param.setFacilityCd(items.getItemValue(TelegramKey.KEY_FACILITY_CD));
    param.setMachineTypeCd(items.getItemValue(TelegramKey.KEY_DEVICE_TYPE));
    param.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    param.setUseTime(items.getItemValue(TelegramKey.KEY_ITEMS));
    param.setUpDate(telegramDateToTimestamp(items.getItemValue(TelegramKey.KEY_OCCUR_DATE)));

    EventLogMessage eventLogMessage = new EventLogMessage();

    try {
      if (mntMachineStateService.updateUseTime(param) > 0) {
        eventLogMessage.setLogMessage("Update USE_TIME SUCCESS.");
        logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_USE_TIME);
      logService.log(LogLevel.WARN, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    } catch (Exception e) {

      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_USE_TIME + e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
    return false;
  }
  /**
   * 外部警報メッセージ変換.
   *
   * @param machineRecordCd 装置記録コード
   * @param facilityCd 施設コード
   * @param message 変換前のメッセージ
   * @return 装置記録コードが外部警報1～4の場合、施設設定マスタに設定されたメッセージ
   *         装置記録コードが上記以外の場合、変換前のメッセージ
   */
  private String convertExternalAlarmMessage(String machineRecordCd, String facilityCd, String message) {
    String rtnMessage = "";
    String facilitySettingNo = "";

    // 装置記録コードのnullチェック
    if (machineRecordCd == null) {
      return message;
    }

    // 施設設定マスタの設定番号判定
    switch (machineRecordCd) {
      case ExternalAlarmCode.EXTERNAL_ALARM_1_ON:
        facilitySettingNo = FacilitySettingNo.EXTERNAL_ALARM1_ON_MESSAGE_CHANGE;
        break;
      case ExternalAlarmCode.EXTERNAL_ALARM_2_ON:
        facilitySettingNo = FacilitySettingNo.EXTERNAL_ALARM2_ON_MESSAGE_CHANGE;
        break;
      case ExternalAlarmCode.EXTERNAL_ALARM_3_ON:
        facilitySettingNo = FacilitySettingNo.EXTERNAL_ALARM3_ON_MESSAGE_CHANGE;
        break;
      case ExternalAlarmCode.EXTERNAL_ALARM_4_ON:
        facilitySettingNo = FacilitySettingNo.EXTERNAL_ALARM4_ON_MESSAGE_CHANGE;
        break;
      case ExternalAlarmCode.EXTERNAL_ALARM_1_OFF:
        facilitySettingNo = FacilitySettingNo.EXTERNAL_ALARM1_OFF_MESSAGE_CHANGE;
        break;
      case ExternalAlarmCode.EXTERNAL_ALARM_2_OFF:
        facilitySettingNo = FacilitySettingNo.EXTERNAL_ALARM2_OFF_MESSAGE_CHANGE;
        break;
      case ExternalAlarmCode.EXTERNAL_ALARM_3_OFF:
        facilitySettingNo = FacilitySettingNo.EXTERNAL_ALARM3_OFF_MESSAGE_CHANGE;
        break;
      case ExternalAlarmCode.EXTERNAL_ALARM_4_OFF:
        facilitySettingNo = FacilitySettingNo.EXTERNAL_ALARM4_OFF_MESSAGE_CHANGE;
        break;
      default:
        // 外部警報1～4以外のメッセージの場合は変換前のメッセージを返す
        return message;
    }

    // 施設設定からメッセージの取得
    FacilitySettingInfo infoMessage = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, facilitySettingNo);
    rtnMessage = infoMessage.getValue();

    return rtnMessage;
  }

  /**
   * 装置記録(通信共通)のDB書き込み
   *
   * @param items
   * @return
   */
  public boolean runWriteMotionRecordLogCommonComm(TelegramItems items) {
    MntMotionRecord rcd = new MntMotionRecord();
    String facilityCd = items.getItemValue(TelegramKey.KEY_FACILITY_CD);
    rcd.setFacilityCd(facilityCd);
    rcd.setEventRegDate(telegramDateToTimestamp(items.getItemValue(TelegramKey.KEY_OCCUR_DATE)));
    String edgeNo = items.getItemValue(TelegramKey.KEY_EDGE_NO);
    rcd.setDeviceEdgeNo(edgeNo != null && StrUtils.isNumber(edgeNo) ? Integer.parseInt(edgeNo) : null);
    rcd.setMachineTypeCd(items.getItemValue(TelegramKey.KEY_DEVICE_TYPE));
    rcd.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    rcd.setComFormatCd(items.getItemValue(TelegramKey.KEY_COMM_FORMAT));
    rcd.setDataType(MntMotionRecordStaticValues.DataType.LOG);
    rcd.setMachineRecordCd(items.getItemValue(TelegramKey.KEY_CODE));
    rcd.setMachineRecordMessage(items.getItemValue(TelegramKey.KEY_MSG));
    rcd.setMachineRecordAuxData(items.getItemValue(TelegramKey.KEY_MSG2));
    String ordNo =  items.getItemValue(TelegramKey.KEY_ORD_NO);
    rcd.setOrdNo( StrUtils.isNumber(ordNo) ? Long.parseLong(ordNo): null ) ;
    short nClass = 0;
    String strClass = items.getItemValue(TelegramKey.KEY_CLASS);
    if (strClass != null && StrUtils.isNumber(strClass)) {
      nClass = Short.parseShort(strClass);
    }
    rcd.setLogType(nClass);

    EventLogMessage eventLogMessage = new EventLogMessage();

    // 装置記録書き込み
    try {
      // 装置記録コード判定
      if (rcd.getMachineRecordCd() != null) {
        // 装置記録コードあり
        if (mntMotionRecodeService.insertLogMotionMessageAndOrdNo(rcd) > 0) {
          eventLogMessage.setLogMessage("Insert MotionRecode SUCCESS.");
          logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
          return true;
        }
      } else {
        // 装置記録コードなし
        if (mntMotionRecodeService.insertLogMotionMessage(rcd) > 0) {
          eventLogMessage.setLogMessage("Insert MotionRecode SUCCESS.");
          logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
          return true;
        }
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_LOG);
      logService.log(LogLevel.WARN, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_LOG + e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
    return false;
  }

  /**
   * メンテナンス(通信共通V4用)のDB書き込み
   *
   * @param items
   * @param dataType
   * @param testType
   * @return
   */
  public boolean runWriteMotionRecordMntCommonCommV4(TelegramItems items, int dataType, int testType) {
    MntMotionRecord rcd = new MntMotionRecord();
    rcd.setFacilityCd(items.getItemValue(TelegramKey.KEY_FACILITY_CD));
    rcd.setEventRegDate(telegramDateToTimestamp(items.getItemValue(TelegramKey.KEY_OCCUR_DATE)));
    String edgeNo = items.getItemValue(TelegramKey.KEY_EDGE_NO);
    rcd.setDeviceEdgeNo(edgeNo != null && StrUtils.isNumber(edgeNo) ? Integer.parseInt(edgeNo) : null);
    rcd.setMachineTypeCd(items.getItemValue(TelegramKey.KEY_DEVICE_TYPE));
    rcd.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    rcd.setComFormatCd(items.getItemValue(TelegramKey.KEY_COMM_FORMAT));
    rcd.setDataType(dataType);
    rcd.setTestType(testType);
    rcd.setMachineRecordMessage(items.getItemValue(TelegramKey.KEY_MSG));
    rcd.setContents(items.getItemValue(TelegramKey.KEY_ITEMS));

    EventLogMessage eventLogMessage = new EventLogMessage();

    try {
      if (mntMotionRecodeService.insertMntMotion(rcd) > 0) {
        eventLogMessage.setLogMessage("Insert MotionRecode SUCCESS.");
        logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_MNT);
      logService.log(LogLevel.WARN, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_MNT + e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
    return false;
  }

  /**
   * 伝文中のyyyyMMddHHmmssまたはyyyyMMddHHmmssSSS形式文字列をTimestampに変換する
   *
   * @param occurDate
   * @return
   */
  public Timestamp telegramDateToTimestamp(String occurDate) {

    Timestamp returnDate;
    String format = "";
    if (occurDate.length() == 14) {
      format = "yyyyMMddHHmmss";
    } else if (occurDate.length() == 17) {
      format = "yyyyMMddHHmmssSSS";
    }

    // occurDateは yyyyMMddHHmmssSSS形式で来る
    try {
      long upDateTime = new SimpleDateFormat(format).parse(occurDate).getTime();
      returnDate = new Timestamp(upDateTime);
    } catch (ParseException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(
          LogMessage.ERROR_DATE_FORMAT + ", [" + occurDate + "]→[" + format + "]\n" + e.getStackTrace().toString());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      returnDate = new Timestamp(System.currentTimeMillis());
    }

    return returnDate;
  }


  /**
   * 作成関数のREST呼び出し動作確認用関数
   * TODO:動作確認後に削除
   */
  public void test() {

    Long ordNo = 749L;
    Timestamp now = new Timestamp(System.currentTimeMillis());
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
    String now_text = sdf.format(now);

    TelegramItems items = new TelegramItems(new String[]{"",""});
    // オーダー番号
    items.setItemValue(TelegramKey.KEY_ORD_NO, ordNo.toString());
    // 発生日時
    items.setItemValue(TelegramKey.KEY_OCCUR_DATE, now_text);
    // 特殊浄化治療装置
    items.setItemValue(TelegramKey.KEY_BP_DEVICE_TYPE, "特殊浄化治療装置？");
    // 最終モニタ値
    items.setItemValue(TelegramKey.KEY_ITEMS,
        "{"
          + "\"1\":\"10\","
          + "\"2\":\"9\","
          + "\"3\":\"8\","
          + "\"4\":\"7\","
          + "\"5\":\"6\","
          + "\"6\":\"5\","
          + "\"7\":\"4\","
          + "\"8\":\"3\","
          + "\"9\":\"2\","
          + "\"10\":\"1\""
          + "}"
    );


    this.setBloodPurifierName(items);
    this.setRstStartDate(items);
    this.updateMedicatedRstMedi(items);
    this.setRstEndDate(items);
    this.setRstMonitor(items);
  }

  /**
   * 血液浄化装置名称を更新
   *
   * @param items パラメータ
   */
  private void setBloodPurifierName( TelegramItems items ) {
    Long ordNo = null;
    String name = null;

    try {
      String work = items.getItemValue(TelegramKey.KEY_ORD_NO);
      ordNo = work != null && StrUtils.isNumber(work) ? Long.parseLong(work) : 0L;
      name = items.getItemValue(TelegramKey.KEY_BP_DEVICE_TYPE);

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("BLOOD PURIFY UPDATE : set ord_main.blood_purifier_name. , ordNo:" + ordNo + " / name:" + name );
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

      Timestamp now = new Timestamp(System.currentTimeMillis());

      // 治療記録を取得
      OrdMain ord = ordMainService.selectByOrdNo(ordNo);

      // 血液浄化装置名称
      ord.setBloodPurifierName(name);
      // 更新日時を更新
      ord.setUpDate(now);

      // 更新
      ordMainService.update( ord );
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(
          "BLOOD PURIFY UPDATE : set ord_main.rst_blood_purifier_name failure. , ordNo:" + ordNo + " / name:" + name + "\n" + e.getStackTrace().toString());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
  }

  /**
   * 治療開始日時を更新
   *
   * @param items パラメータ
   */
  private void setRstStartDate( TelegramItems items ) {
    Long ordNo = null;
    Timestamp date = null;
    // wangzuo アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_TREATMENT_RECORD, BEFORE_LOG_FLG_INFO, "", null, "治療開始日時を更新");
    // wangzuo アプリケーションログの適正化 Add End
    try {
      String work = items.getItemValue(TelegramKey.KEY_ORD_NO);
      ordNo = work != null && StrUtils.isNumber(work) ? Long.parseLong(work) : 0L;
      date = this.telegramDateToTimestamp(items.getItemValue(TelegramKey.KEY_OCCUR_DATE));

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("BLOOD PURIFY UPDATE : ord_main.rst_start_date. , ordNo:" + ordNo + " / date:" + date);
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

      Timestamp now = new Timestamp(System.currentTimeMillis());

      // 治療記録を取得
      OrdMain ord = ordMainService.selectByOrdNo(ordNo);

      // 治療開始日時
      ord.setRstStartDate( date );

      // 治療状態を判定
      String chkStatus = OrdMainConst.DialysisState.DIALYSIS;
      String chgStatus = "";
      if( Objects.compare(ord.getRstDialysisState(), chkStatus, Comparator.naturalOrder()) < 0 ) {
        // 治療中以前の場合は治療中にする
        ord.setRstDialysisState(chkStatus);
        chgStatus = chkStatus;
      }
      // 更新日時を更新
      ord.setUpDate(now);

      // 更新
      ordMainService.update( ord );


      // 治療記録の治療状態を変更した場合
      if( ! chgStatus.isEmpty() ) {
        // 対象患者の治療状態を治療中に変更する

        // 治療時間
        String treatmentTime = null;
        String condInfoText = ord.getRstCondInfo();
        if (null != condInfoText) {
          CondInfo condInfo = condInfoService.createCondInfo(condInfoText);
          CondInfoItem condItem = condInfo.getTreatTime();
          treatmentTime = condItem.getValue();
        }
        // 更新
        patMainAcceptanceStatusInfoService.update(ord.getPatId(), ord.getOrdNo(), chgStatus, date, treatmentTime);
      }


      // オフライン運転開始指示
      postSendWS( ord.getFacilityCd(), ordNo, WebSocketTopic.ComSv.START_TREAT_OFFLINE, now);

      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_TREATMENT_RECORD, AFTER_LOG_FLG_INFO, "",
              "ordNo: " + ordNo + " / date: " + date , "治療開始日時を更新");
      // wangzuo アプリケーションログの適正化 Add End
    } catch (Exception e) {
        // wangzuo アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_TREATMENT_RECORD, AFTER_LOG_FLG_ERROR, "",
                "ordNo: " + ordNo + " / date: " + date , "治療開始日時を更新" + e.getStackTrace().toString());
        // wangzuo アプリケーションログの適正化 Add End
    }
  }

  /**
   * 治療終了日を更新
   *
   * @param items パラメータ
   */
  private void setRstEndDate( TelegramItems items ) {
    Long ordNo = null;
    Timestamp date = null;

    try {
      String work = items.getItemValue(TelegramKey.KEY_ORD_NO);
      ordNo = work != null && StrUtils.isNumber(work) ? Long.parseLong(work) : 0L;
      date = this.telegramDateToTimestamp(items.getItemValue(TelegramKey.KEY_OCCUR_DATE));

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("BLOOD PURIFY UPDATE : set ord_main.rst_end_date. , ordNo:" + ordNo + " / date:" + date);
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

      Timestamp now = new Timestamp(System.currentTimeMillis());

      // 治療記録を取得
      OrdMain ord = ordMainService.selectByOrdNo(ordNo);

      // 治療終了日時
      ord.setRstEndDate( date );
      // 治療状態を判定
      String chkStatus = OrdMainConst.DialysisState.AFTER_DIALYSIS;
      String chgStatus = "";
      if( Objects.compare(ord.getRstDialysisState(), chkStatus, Comparator.naturalOrder()) < 0 ) {
        // 後体重測定前(排液後)以前の場合は後体重測定前にする
        ord.setRstDialysisState(chkStatus);
        chgStatus = chkStatus;
      }
      // 更新日時を更新
      ord.setUpDate(now);

      // 更新
      ordMainService.update( ord );


      // 治療記録の治療状態を変更した場合
      if( ! chgStatus.isEmpty() ) {
        // 対象患者の治療状態を後体重測定前に変更する
        // 更新
        patMainAcceptanceStatusInfoService.update(ord.getPatId(), ord.getOrdNo(), chgStatus, null, null);
      }


      // オフライン運転終了指示
      postSendWS( ord.getFacilityCd(), ordNo, WebSocketTopic.ComSv.END_TREAT_OFFLINE, now);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(
          "BLOOD PURIFY UPDATE : set ord_main.rst_end_date failure. , ordNo:" + ordNo + " / date:" + date + "\n" + e.getStackTrace().toString());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
  }

  /**
   * 投与実施ありの薬剤/調整薬剤をチェック済に更新
   * @param ordNo
   * @param mediInfo
   * @param effectDate
   * @return 空白：変更なし/else：チェック済rst_medicine[JSON文字列]
   */
  private String getMedicatedRstMedi(Long ordNo, String mediInfo, String effectDate) {
    String ret = "";
    StringBuilder sb = new StringBuilder();
    sb.append("[");
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
    if(ObjectUtils.isEmpty(mediInfo)) {
      sb.append("]");
      return sb.toString();
    }
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
    try {
      // 実績：投与薬剤の情報を取得(薬剤/調整薬剤の投薬実施フラグを取得するため)
      List<LcdReq41> rstMediList = ordMainDao.selectMediInfoByNo(ordNo);

      // JSON処理
      JsonNode jsonNode_array = mapper.readTree(mediInfo);
      for (int lop = 0; lop < jsonNode_array.size(); lop++) {
        JsonNode jsonNode = jsonNode_array.get(lop);
        // jsonNodeは読み取り専用のため、ObjectNodeに変換
        ObjectNode objectNode = jsonNode.deepCopy();

        // 同じ番号を持つ薬剤/調整薬剤マスタの投与実施フラグがありで投与実施フラグが未実施の情報を抽出
        LcdReq41 info = rstMediList.stream()
            .filter( item ->
                Objects.equals(objectNode.get("no").asInt(), item.getSno())
                && Objects.equals(item.getIsMedicated(), "1")
                && Objects.equals(item.getEffectFlg(), "0"))
            .findFirst()
            .orElse(null);
        if( info != null ) {
          // 値の変更
          objectNode.put("effect_flg", "1");
          objectNode.put("effect_date", effectDate);

          // 情報変更：あり
          ret = "1";
        }
        // すでに情報がある場合
        if ( 1 < sb.length()) {
          sb.append(",");
        }
        // objectNodeの文字列化
        sb.append(mapper.writeValueAsString(objectNode));
      }
    } catch (IOException e) {
      sb.setLength(0);

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(
          "BLOOD PURIFY UPDATE : getMedicatedRstMedi failure. , ordNo:" + ordNo + "\n" + e.getStackTrace().toString());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
    sb.append("]");

    // 情報変更判定
    if( ret.equals("1") ) {
      ret = sb.toString();
    }

    return ret;
  }
  /**
   * 投与実施ありの薬剤/調整薬剤をチェック済に更新
   *
   * @param items パラメータ
   */
  private void updateMedicatedRstMedi( TelegramItems items ) {
    Long ordNo = null;
    Timestamp date = null;

    try {
      String work = items.getItemValue(TelegramKey.KEY_ORD_NO);
      ordNo = work != null && StrUtils.isNumber(work) ? Long.parseLong(work) : 0L;
      date = this.telegramDateToTimestamp(items.getItemValue(TelegramKey.KEY_OCCUR_DATE));

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("BLOOD PURIFY UPDATE : update ord_main.rst_medicine. , ordNo:" + ordNo + " / date:" + date);
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

      // 治療記録を取得
      OrdMain ord = ordMainService.selectByOrdNo(ordNo);

      // 投薬リストを取得
      String mediInfo = ord.getRstMediInfo();

      // 投薬実施が設定されている未チェックの投薬をチェック済にする
      mediInfo = this.getMedicatedRstMedi(ordNo, mediInfo,  DateTimeUtils.getDateString_iso8601(new Date(date.getTime())));

      // 変更対象がある場合
      if( !mediInfo.isEmpty() ) {

        // add FNSI-改修内容追加OrdMain履歴 付 start
        getHistory(ordNo);
        // mangoDb-updateMediInfo-insertSuccess
        // add FNSI-改修内容追加OrdMain履歴 付 end

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

        // 更新
        OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
        int updateCount = ordMainDao.updateMediInfo( ordNo, mediInfo );
        OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
        triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
          Collections.singletonList(newOrdMain));

        // DB更新ログ出力ロジック wangzuo Start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && updateCount > 0) {
          logCommon.updateLog();
        }
        // DB更新ログ出力ロジック wangzuo End

      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(
          "BLOOD PURIFY UPDATE : update ord_main.rst_medicine failure. , ordNo:" + ordNo + " / date:" + date + "\n" + e.getStackTrace().toString());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
  }

  // add FNSI-改修内容追加OrdMain履歴 付 start
  private void getHistory(Long ordNo){
    selectHistoryUtils.insertMangoDbHistory(1, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }
  // add FNSI-改修内容追加OrdMain履歴 付 end

  /**
   * JsonNodeから指定情報取得
   * @param node
   * @param key
   * @return
   */
  private String getNodeValue( JsonNode node, String key ) {
    String ret = null;

    try {
      if ( key != null ) {
        ret = node.get(key).isNull() ? null : node.get(key).asText();
      }
    } catch( Exception e ) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(
          "BLOOD PURIFY UPDATE : getNodeValue failure. , key:" + key + "\n" + e.getStackTrace().toString());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
    return ret;
  }

  /**
   * 実績値を更新
   * @param items パラメータ
   */
  private void setRstMonitor( TelegramItems items ) {
    Long ordNo = null;                  // オーダ番号
    String rstBloodCirculate = null;  // 血液循環量
    String rstRunningTime = null;      // 透析運転時間
    String rstKtv = null;               // Kt/V
    String waterRemovealRst = null;    // 実績除水量
    String addTotal = null;             // 除水積算値
    String addWaterTotal = null;        // 補液量現在値
    String KtvMeasure = null;           // Kt/V（測定値）
    String urr = null;                    // ＵＲＲ
    String waterRemovealTarget = null; // 目標除水量

    try {
      String work = items.getItemValue(TelegramKey.KEY_ORD_NO);
      ordNo = work != null && StrUtils.isNumber(work) ? Long.parseLong(work) : 0L;
      work = items.getItemValue(TelegramKey.KEY_ITEMS);
      JsonNode node = mapper.readTree(work);
      // 血液循環量
      rstBloodCirculate = this.getNodeValue(node, "1");
      // 透析運転時間
      rstRunningTime = this.getNodeValue(node, "2");
      // Kt/V
      rstKtv = this.getNodeValue(node, "3");
      // 実績除水量
      waterRemovealRst = this.getNodeValue(node, "4");
      // 除水積算値
      addTotal = this.getNodeValue(node, "5");
      // 補液量現在値
      addWaterTotal = this.getNodeValue(node, "6");
      // Kt/V（測定値）
      KtvMeasure = this.getNodeValue(node, "7");
      // ＵＲＲ
      urr = this.getNodeValue(node, "8");
      // 目標除水量
      waterRemovealTarget = this.getNodeValue(node, "9");

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(
          "BLOOD PURIFY UPDATE : set result monitor value. , "
              + "ordNo:" + ordNo
              + " / rstBloodCirculate:" + rstBloodCirculate
              + " / rstRunningTime:" + rstRunningTime
              + " / rstKtv:" + rstKtv
              + " / addTotal:" + addTotal
              + " / addWaterTotal:" + addWaterTotal
              + " / KtvMeasure:" + KtvMeasure
              + " / urr:" + urr
              + " / waterRemovealTarget:" + waterRemovealTarget
          );
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

      ComsvOrdMain comsv = new ComsvOrdMain();

      // オーダ番号
      comsv.setOrdNo(ordNo);

      // 血液循環量
      comsv.setRstBloodCirculate(rstBloodCirculate);
      // 透析運転時間
      comsv.setRstRunningTime(rstRunningTime);
      // Kt/V（測定値）
      comsv.setKtvMeasure(KtvMeasure);

      // 除水積算値(+実績除水量)
      comsv.setAddTotal(addTotal);
      // 補液量現在値
      comsv.setAddWaterTotal(addWaterTotal);
      // Kt/V
      comsv.setRstKtv(rstKtv);
      // ＵＲＲ
      comsv.setUfr(urr);

      // add FNSI-改修内容追加OrdMain履歴 付 start
      getHistory(comsv.getOrdNo());
      // mangoDb-updateRstMonitor-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      comsvOrdMainDao.updateRstMonitor(comsv);

      // add FNSI-改修内容追加OrdMain履歴 付 start
      getHistory(ordNo);
      // mangoDb-updateRstWeight-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // 目標除水量
      comsvOrdMainDao.updateRstWeight(ordNo, waterRemovealTarget);
    } catch( Exception e ) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(
          "BLOOD PURIFY UPDATE : set result monitor value failure. , "
              + "ordNo:" + ordNo
              + " / rstBloodCirculate:" + rstBloodCirculate
              + " / rstRunningTime:" + rstRunningTime
              + " / rstKtv:" + rstKtv
              + " / addTotal:" + addTotal
              + " / addWaterTotal:" + addWaterTotal
              + " / KtvMeasure:" + KtvMeasure
              + " / urr:" + urr
              + " / waterRemovealTarget:" + waterRemovealTarget
              + e.getStackTrace().toString());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
  }

  // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 start
  private void setLogMonitor( TelegramItems items ) {
    Long ord_no = null;                  // オーダ番号
    String strClass = items.getItemValue(TelegramKey.KEY_CLASS);
    String occurdatetime = items.getItemValue(TelegramKey.KEY_OCCUR_DATE);
    String facilitycd = items.getItemValue(TelegramKey.KEY_FACILITY_CD);
    String machinetypecd = items.getItemValue(TelegramKey.KEY_DEVICE_TYPE);
    String machineserial = items.getItemValue(TelegramKey.KEY_SERIAL_NO);
    String work = items.getItemValue(TelegramKey.KEY_ORD_NO);
    ord_no = work != null && StrUtils.isNumber(work) ? Long.parseLong(work) : 0L;
    work = items.getItemValue(TelegramKey.KEY_ITEMS);
    LogData data = new LogData();

    try {
      JsonNode node = mapper.readTree(work);
      data= new LogData();
      data = mapper.readValue(node.toString(), LogData.class);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("setLogMonitor:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }

    String strLogData = "0";

    if (false == StringUtils.isEmpty(data.data)) {
      strLogData = data.data;
    }

    String weight = ordMainService.selectWeightInfo(ord_no);
    OrdMainRstWeightInfo dto = null;
    try {
      dto = weight == null || weight.isEmpty() ? new OrdMainRstWeightInfo()
        : mapper.readValue(weight, OrdMainRstWeightInfo.class);
    } catch (IOException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    switch (strClass) {
      //1:再循環率測定
      case "1":
        if (false == StringUtils.isEmpty(strLogData)) {
          // ＃10847 2024.07.12 mod 登録する再循環率情報修正 TDC米沢 start
          // RecrclRt rec = new RecrclRt();
          // int elem_count = 0;
          //
          // if (dto.getRecrcl_rt() != null && !StringUtils.isEmpty(dto.getRecrcl_rt())) {
          //   rec = dto.getRecrcl_rt();
          //   if(rec.valid_no != null && !StringUtils.isEmpty(rec.valid_no)) {
          //     elem_count = Integer.parseInt(rec.valid_no);
          //   }else{
          //     elem_count = 0;
          //   }
          // } else {
          //   elem_count = 0;
          // }
          //
          // //初期値の場合、recrcl_rtの値の無にする
          // //1件目データを登録時に、データブロック：No１の分のみ作成する、No2以降の分を作成しない。
          // //つまり、できる分のデータブロック分のみ作成する
          // //最大5件、6件目以降データが来るとき、登録しない
          // if (elem_count < 5 && elem_count >= 0) {
          //   RecrclRtElement elem = new RecrclRtElement();
          //   elem.rate = Double.parseDouble(strLogData);
          //   elem.datetime = occurdatetime;
          //   elem.comment = "";
          //   //mnt_machine_state.monitor_dataから「血流量」の値を取得
          //   MntMachineState state = new MntMachineState();
          //   state = mntMachineStateService.selectByKey(facilitycd, machinetypecd, machineserial);
          //   String monitorData = state.getMonitorData();
          //   JsonNode root = null;
          //   try {
          //     if(monitorData != null && !StringUtils.isEmpty(monitorData)) {
          //       root = mapper.readTree(monitorData);
          //       //新通信 8 血流量
          //       // mod #9973 Resolve null exception for key 20240117 ztc start
          //       //String bld_vl = String.valueOf(root.get("8"));
          //       String bld_vl = root.has("8") ? String.valueOf(root.get("8")) : null;
          //       // mod #9973 Resolve null exception for key 20240117 ztc end
          //       if (bld_vl != null && bld_vl.isEmpty() == false && bld_vl.equals("null") == false) {
          //         elem.bld_vl = Integer.valueOf(String.valueOf(root.get("8")));
          //       } else {
          //         elem.bld_vl = 0;
          //       }
          //     }else{
          //       elem.bld_vl = 0;
          //     }
          //   } catch (IOException e) {
          //     e.printStackTrace();
          //   }
          //   switch (elem_count) {
          //     case 4:
          //       rec._5 = elem;
          //       rec.valid_no = "5";
          //       break;
          //     case 3:
          //       rec._4 = elem;
          //       rec.valid_no = "4";
          //       break;
          //     case 2:
          //       rec._3 = elem;
          //       rec.valid_no = "3";
          //       break;
          //     case 1:
          //       rec._2 = elem;
          //       rec.valid_no = "2";
          //       break;
          //     case 0:
          //       rec._1 = elem;
          //       rec.valid_no = "1";
          //       break;
          //     default:
          //       break;
          //   }
          //
          //   dto.setRecrcl_rt(rec);
          //
          // } else {
          //   EventLogMessage eventLogMessage1 = new EventLogMessage();
          //   eventLogMessage1.setLogMessage("最大5件、6件目以降データが来るとき、登録しない");
          //   logService.log(LogLevel.INFO, eventLogMessage1, null, SERVICE_NAME.REMS, null);
          // }

          // 登録する再循環率測定値作成
          RecrclRtElement elem = new RecrclRtElement();
          elem.rate = Double.parseDouble(strLogData);
          elem.comment = "";
          try{
            // yyyymmddHHMMss文字列からISO8601形式文字列への変換
            elem.datetime = DateTimeUtils.getDateString_iso8601(new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(occurdatetime).getTime()));
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
          }

          //mnt_machine_state.monitor_dataから「血流量」の値を取得
          MntMachineState state = new MntMachineState();
          state = mntMachineStateService.selectByKey(facilitycd, machinetypecd, machineserial);
          String monitorData = state.getMonitorData();
          JsonNode root = null;
          try {
            root = mapper.readTree(monitorData);
          } catch (IOException e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
          }
          //新通信 8 血流量
          elem.bld_vl =
            root != null && root.hasNonNull("8") && StringUtils.hasText(root.get("8").asText())
              ? root.get("8").asInt() : null;

          // 再循環率格納情報登録
          List<RecrclRtElement> list = new ArrayList<>();

          // 再循環率初期情報作成
          RecrclRtElement newElem = new RecrclRtElement();
          newElem.rate = null;
          newElem.bld_vl = null;
          newElem.comment = "";
          newElem.datetime = null;

          // 5件の初期化情報をリストに格納
          for(int lop = 0; lop <5; lop++) {
            list.add(newElem);
          }

          // 元の再循環率格納情報チェック
          RecrclRt rec = dto.getRecrcl_rt();
          if (rec != null && !StringUtils.isEmpty(rec)) {
            // 元情報がある場合は再循環率測定情報でリストの情報を差し替え
            if(rec.get_1() != null && !StringUtils.isEmpty(rec.get_1())) list.set(0, rec.get_1());
            if(rec.get_2() != null && !StringUtils.isEmpty(rec.get_2())) list.set(1, rec.get_2());
            if(rec.get_3() != null && !StringUtils.isEmpty(rec.get_3())) list.set(2, rec.get_3());
            if(rec.get_4() != null && !StringUtils.isEmpty(rec.get_4())) list.set(3, rec.get_4());
            if(rec.get_5() != null && !StringUtils.isEmpty(rec.get_5())) list.set(4, rec.get_5());
          }

          // 再循環率測定値ソート用クラス定義
          class RecrclRtElementCompararator implements Comparator<RecrclRtElement> {
            public int compare(RecrclRtElement e1, RecrclRtElement e2) {
              // NULL、空白判定
              if(StringUtils.isEmpty(e1.datetime)) return 1;  // e1が大きい
              if(StringUtils.isEmpty(e2.datetime)) return -1; // e2が大きい
              return e1.datetime.compareTo(e2.datetime);
            }
          }
          RecrclRtElementCompararator comp = new RecrclRtElementCompararator();

          // リストを発生時刻昇順(NULL、空白末尾)でソート
          list.sort(comp);

          // 未測定要素をチェック
          int idx = -1;
          for (int lop = 0; lop < list.size(); lop++) {

            // 再循環率測定値が入っているかどうかをチェック
            RecrclRtElement wkElem = list.get(lop);
            if(StringUtils.isEmpty(wkElem.rate))
            {
              // 値がない

              // 未測定要素検出
              idx = lop;
              break;
            }
          }
          // 処理判定
          if( idx != -1) {
            // 未測定要素がある場合

            // 未測定要素を登録情報で差し替え
            list.set(idx, elem);
          } else {
            // 未測定要素がない場合

            // 一番古い要素を削除
            list.remove(0);
            // 登録情報を追加
            list.add(elem);
          }

          // リストを発生時刻昇順(NULL、空白末尾)でソート
          list.sort(comp);

          // 格納情報作成
          rec = new RecrclRt();
          rec.set_1(list.get(0));
          rec.set_2(list.get(1));
          rec.set_3(list.get(2));
          rec.set_4(list.get(3));
          rec.set_5(list.get(4));
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
          // rec.setValid_no(String.valueOf(1 + list.indexOf(elem)));
          rec.setValid_no(1 + list.indexOf(elem));
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end

          // 再循環率登録
          dto.setRecrcl_rt(rec);
          // ＃10847 2024.07.12 mod 登録する再循環率情報修正 TDC米沢 end
        }
        break;
      //2:プログラム補液引き残し量
      case "2":
        if (false == StringUtils.isEmpty(strLogData)) {
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
          // dto.setIhdf_pll(strLogData)
          dto.setIhdf_pll(new BigDecimal(strLogData));
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
        }
        break;
      //3:静的静脈圧
      case "3":
        if (false == StringUtils.isEmpty(strLogData)) {
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
          // dto.setSttc_vns_prssr(strLogData);
          dto.setSttc_vns_prssr(new BigDecimal(strLogData));
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
        }
        break;
      //4:IAP ratio
      case "4":
        if (false == StringUtils.isEmpty(strLogData)) {
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
          // dto.setIap_rt(strLogData);
          dto.setIap_rt(new BigDecimal(strLogData));
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
        }
        break;
      default:
        break;
    }

    try {
      getHistory(ord_no);
      ordMainService.updateWeightInfo(ord_no, mapper.writeValueAsString(dto));
    } catch (JsonProcessingException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
  }
  // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 end

  /**
   * デバイスエッジに通知する
   * @param facilityCd 施設コード
   * @param ordNo      オーダー番号
   * @param command    通知電文
   * @param date       日付
   * @return
   */
  private SendConditionResponse postSendWS(String facilityCd, Long ordNo, String command, Timestamp date ) {

    SendConditionResponse res = new SendConditionResponse();
    try {
      // 現患者のオーダー番号かどうか判定
      List<MntMachineState> list = mntMachineStateDao.selectByOrdNo(facilityCd, ordNo);
      if( list.isEmpty() ) {
        // 現患者ではない
        res.isSuccess = true;
      } else {
        // 現患者

        // 対象装置判定
        MntMachineState info = list.get(0);
        MstMachine machine = mstMachineDao.selectByCd(info.getMachineTypeCd(), info.getMachineSerial(), facilityCd);
        if( machine == null ) {
          // 装置未確定
          res.isSuccess = false;
          res.errorMessage = "通知先装置の特定失敗";
        } else {
          // 装置確定

          // トピック：電文/{施設コード}/{デバイスエッジ番号}
          String topic = PayloadBuilder.BuildTopic(command, facilityCd,
              machine.getDeviceEdgeNo());

          // データ：装置番号{TAB}日付
          String payload = machine.getMachineNo().toString() + '\t' + new SimpleDateFormat("yyyyMMddHHmmss").format(date) ;

          // EdgeあてにWebsocket通知
          if (sendWsMsg.sendMsg(SendTarget.main, facilityCd, machine.getDeviceEdgeNo(), topic, payload)) {
            res.isSuccess = true;
          } else {
            res.isSuccess = false;
            res.errorMessage = "通信サーバーへの通知失敗";
          }
        }
      }

      if( !res.isSuccess ) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(res.errorMessage);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    return res;
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
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI);
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


  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }

}
