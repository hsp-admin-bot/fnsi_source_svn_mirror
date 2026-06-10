package jp.co.nikkiso.ntss.device_edge.service;

import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;

import com.amazonaws.util.StringUtils;
import com.google.common.base.Strings;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MntFindMachineDao;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineRecordControlDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstSelfMeasureResultDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;
import jp.co.nikkiso.ntss.core.entity.MntFindMachine;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMachineRecord;
import jp.co.nikkiso.ntss.core.entity.MstSelfMeasureResult;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.TestResultDetail;
import jp.co.nikkiso.ntss.core.trigger.MntMotionTrigger;
import jp.co.nikkiso.ntss.core.trigger.OperateType;
import jp.co.nikkiso.ntss.device_edge.constant.Constant.OrdMainConst;
import jp.co.nikkiso.ntss.device_edge.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.device_edge.service.webSocketNotify.WebSocketNotifyService;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.dao.value.MntMotionRecordStaticValues;
import jp.co.nikkiso.ntss.device_edge.util.Utilities;
import jp.co.nikkiso.ntss.device_edge.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.ExternalAlarmCode;
import jp.co.nikkiso.ntss.device_edge.packet.TelegramControl;
import jp.co.nikkiso.ntss.device_edge.packet.TelegramKey;
import jp.co.nikkiso.ntss.device_edge.packet.TelegramItems;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class DatabasePusher {

  @Autowired
  private LogService logService;

  @Autowired
  MntMachineStateService mntMachineStateService;
  @Autowired
  MntMotionRecordService mntMotionRecodeService;
  @Autowired
  MniMonitorService mniMonitorService;
  @Autowired
  MntDeviceEdgeStateService mntDeviceEdgeStateService;
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  @Autowired
  private MntFindMachineDao mntFindMachineDao;
 // add 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 start
  @Autowired
  private MstMachineRecordDao mstMachineRecordDao;
  @Autowired
  private MstMachineDao mstMachineDao;
  @Autowired
  private MntMotionRecordDao mntMotionRecordDao;
  @Autowired
  private MstSelfMeasureResultDao mstSelfMeasureResultDao;
  // add 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 end
  // add サーバ上へ登録した前血圧、後血圧について 高 start
  @Autowired
  private MniMonitorDao mniMonitorDao;
  @Autowired
  private OrdMainDao ordMainDao;
  // add サーバ上へ登録した前血圧、後血圧について 高 end

  //add bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- start
  @Autowired
  MstMachineRecordControlDao mstMachineRecordControlDao;
  //add bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- end

  // add FNSI-バグ #7480 通信サーバ 高 start
  @Autowired
  WebSocketNotifyService sendWsMsg;
  final private String _topicProBase = "NTSS/PROCESS_STATE";
  // add FNSI-バグ #7480 通信サーバ 高 end

  @Autowired
  private PatPersonalMainDao ppmDao;

  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;

  @Autowired
  MntMotionTrigger mntMotionTrigger;

  // add 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 start
  final static String MACHINE_VER_MAX = "99.99Z";       //装置の最大バージョン番号
  final static String MACHINE_VER_MIN = "0.0 ";         //装置の最小バージョン番号
  // mod #10063 自己診断結果レコードのコード不正修正 高 start
//  final static String QUALIFIED_INSERT_CD = "- ";       //自己診断結果合格
//  final static String VIGILANT_INSERT_CD = "-  ";       //自己診断結果合格(注意)
//  final static String UNQUALIFIED_INSERT_CD = "-   ";   //自己診断結果不合格
  final static String QUALIFIED_INSERT_CD = "G100";       //自己診断結果合格
  final static String VIGILANT_INSERT_CD = "G102";       //自己診断結果合格(注意)
  final static String UNQUALIFIED_INSERT_CD = "G101";   //自己診断結果不合格
  // mod #10063 自己診断結果レコードのコード不正修正 高 end
  final static String QUALIFIED_CD = "G100";            //自己診断結果合格
  final static String VIGILANT_CD = "G102";             //自己診断結果合格(注意)
  final static String UNQUALIFIED_CD = "G101";          //自己診断結果不合格
  final static String QUALIFIED_MESSAGE = "自己診断合格";
  final static String UNQUALIFIED_MESSAGE = "自己診断不合格";
  final static String VIGILANT_MESSAGE = "自己診断合格(注意)";
  final static int QUALIFIED_LEVEL = 3;                 //自己診断結果合格
  final static int UNQUALIFIED_LEVEL = 1;               //自己診断結果不合格
  final static int VIGILANT_LEVEL = 2;                  //自己診断結果合格(注意)
  final static int UFRC_RESULT_KEY = 47;                //UFRC結果
  final static int CONCENTRATION_RESULT_KEY = 65;       //濃度結果
  final static int[] measureResultLevel = {UNQUALIFIED_LEVEL, VIGILANT_LEVEL, QUALIFIED_LEVEL, VIGILANT_LEVEL, UNQUALIFIED_LEVEL};
  // add 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 end

  //add サーバ上へ登録した前血圧、後血圧について 劉 start
  final static String NORMAL_BLOOD_PRESSURE = "0101";     //血圧
  final static String TEMPERATURE_CD = "0102";            //体温
  final static String ANTERIOR_BLOOD_PRESSURE = "0104";   //前血圧
  final static String POSTERIOR_BLOOD_PRESSURE = "0105";  //後血圧
  //add サーバ上へ登録した前血圧、後血圧について 劉 end


// #8266 mod 2023.03.27 DB登録処理を別スレッドで行う TDC米沢 start
//  public boolean run(InputStream is) {
//
//    String strTelegram;
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    try {
//      strTelegram = TelegramControl.convertInputStreamToString(is);
//
//      eventLogMessage.setLogMessage("receive Telegram:" + strTelegram);
//      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.REMS, null);
//      if (strTelegram.trim().length() == 0) {
//        // 電文なし
//        eventLogMessage.setLogMessage(LogMessage.INFO_TELEGRAM_EMPTY);
//        logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.REMS, null);
//        return true;
//      }
//
//    } catch (IOException e) {
//      eventLogMessage.setLogMessage(LogMessage.ERROR_TELEGRAM_STREAM + e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.REMS, null);
//      return false;
//    } catch (Exception e) {
//      eventLogMessage.setLogMessage(LogMessage.ERROR_TELEGRAM_STREAM + e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.REMS, null);
//      return false;
//    }
  public boolean run(String strTelegram) {
// #8266 mod 2023.03.27 DB登録処理を別スレッドで行う TDC米沢 end

    TelegramControl.convertTelegramToStringList(strTelegram).forEach(telegramLine -> {

      TelegramItems items = new TelegramItems(telegramLine);
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

      case ADD_DEV:
        // 検出装置を登録
        runInsertMntFindMachine(items);
        break;
      // add 治療記録用データと治療状況用データの登録先を振分けにする --趙-- start
      case RMN:
      case C_RMN:
        //通信共通プロトコルV3、V4
        //日機装装置(NX通信含む)
        runWriteTreatmentStatus(items);
        break;
      // add 治療記録用データと治療状況用データの登録先を振分けにする --趙-- end
      default:
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(String.format("%s : %s", LogMessage.WARN_KIND_UNDEFINED, String.join(",", telegramLine)));
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        break;
      }
    });

    return true;
  }

  /**
   * デバイスエッジ死活状態更新
   * @param facility_cd
   * @param device_edge_no
   * @return
   */
  public boolean runWriteAliveMoni(String facility_cd, int device_edge_no) {

    MntDeviceEdgeState rcd = new MntDeviceEdgeState();
    rcd.setFacilityCd(facility_cd);
    rcd.setDeviceEdgeNo(device_edge_no);
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setDeviceEdgeNo(String.valueOf(device_edge_no));
    try {
      // add FNSI-バグ #7480 通信サーバ 高 start
      List<MntDeviceEdgeState> lstMntDeviceEdgeState = mntDeviceEdgeStateService.findById(facility_cd, device_edge_no);
      if (null != lstMntDeviceEdgeState && 0 != lstMntDeviceEdgeState.size()) {
        if(("F1".equals(lstMntDeviceEdgeState.get(0).getAliveMoniStatus()) || "F2".equals(lstMntDeviceEdgeState.get(0).getAliveMoniStatus()))) {
          String topic = PayloadBuilder.BuildTopic(_topicProBase, facility_cd, device_edge_no);
          if (sendWsMsg.sendMsg(WebSocketNotifyService.SendTarget.main, facility_cd, device_edge_no, topic, "") == false) {
            eventLogMessage.setLogMessage("死活監視PROCESS API：要求失敗　対象施設コード[" + facility_cd + "]、対象デバイスエッジ番号 [" + device_edge_no + "]");
            eventLogMessage.setDeviceEdgeNo(String.valueOf(device_edge_no));
            eventLogMessage.setFacilityCd(facility_cd);
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          }
        }
      }
      // add FNSI-バグ #7480 通信サーバ 高 end
      if (mntDeviceEdgeStateService.updateAliveMoni(rcd) > 0) {
  	  	eventLogMessage.setLogMessage("Update AliveMoni SUCCESS. "
                + "facility_cd[" + facility_cd + "] device_edge_no[" + device_edge_no + "]");
    eventLogMessage.setSqlIdentification("(MntDeviceEdgeState = " + rcd);
    eventLogMessage.setFacilityCd(facility_cd);
		logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS,"mntDeviceEdgeStateService/updateAliveMoni");
        return true;
      }
      	eventLogMessage.setLogMessage(String.format("%s, facility_cd[%s], device_edge_no[%s]",
          LogMessage.WARN_UPDATE_ALIVEMONI, facility_cd, device_edge_no));
    eventLogMessage.setSqlIdentification("(MntDeviceEdgeState = " + rcd);
    eventLogMessage.setFacilityCd(facility_cd);
		logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS,"mntDeviceEdgeStateService/updateAliveMoni");
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_UPDATE_ALIVEMONI + e.getMessage());
      eventLogMessage.setSqlIdentification("(MntDeviceEdgeState = " + rcd);
      eventLogMessage.setFacilityCd(facility_cd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,"mntDeviceEdgeStateService/updateAliveMoni");
    }
    return false;
  }

  // add #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
  // valueの""を追加
  private String jsonValueToString(String json) {
    if (json == null || json.length() < 2) return json;
    return json.replaceAll(
      ":(?!\")([^,}]+)",
      ":\"$1\""
    );
  }
  // add #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end

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
    rcd.setOccurDate(telegramDateToTimestamp(items.getItemValue(TelegramKey.KEY_OCCUR_DATE)));
    // add #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
//    rcd.setMonitorData(items.getItemValue(TelegramKey.KEY_ITEMS));
    String monitorData = jsonValueToString(items.getItemValue(TelegramKey.KEY_ITEMS));
    // add #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end
    rcd.setMonitorData(monitorData);
    short nClass = 0;
    String strClass = items.getItemValue(TelegramKey.KEY_CLASS);
    if (strClass != null && Utilities.isNumber(strClass)) {
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

    // add FNSI-バグ #7679 通信サーバ 高 start
    String formatCd;
    formatCd = items.getItemValue(TelegramKey.KEY_COMM_FORMAT);
    // add FNSI-バグ #7679 通信サーバ 高 end

    switch (items.getTelegramKind()) {
    case MONITER:
      // add サーバ上へ登録した前血圧、後血圧について, #7679 高 start
      return runUpdateOrWriteMonitor(rcd, state, formatCd);
      // add サーバ上へ登録した前血圧、後血圧について, #7679 高 end
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
    eventLogMessage.setLogMessage(String.format("%s : %s", LogMessage.WARN_KIND_UNDEFINED, items.getTelegramKind()));
    eventLogMessage.setMachineTypeCd(rcd.getMachineTypeCd());
    eventLogMessage.setFacilityCd(rcd.getFacilityCd());
    logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }
  }

  // add サーバ上へ登録した前血圧、後血圧について, #7679 高 start
  /**
   * モニタデータ更新
   * @param param モニタデータクラス
   * @param state 装置状態管理のEntity
   * @return
   */
  public boolean runUpdateOrWriteMonitor(MniMonitor param, MntMachineState state, String formatCd) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(state.getFacilityCd());
    eventLogMessage.setMachineTypeCd(state.getMachineTypeCd());

    short dataType = param.getDataType();
    try {
      //2:血圧  5:前血圧  6:後血圧
      if (2 != param.getDataType() && 5 != param.getDataType() && 6 != param.getDataType()) {
        eventLogMessage.setLogMessage("Not Blood Pressure Monitor Data.");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return false;
      }
      dataType = 2;   //デフォルトの血圧データ種別

      //装置状態管理取得
      MntMachineState mntMachineState = mntMachineStateService.selectByKey(state.getFacilityCd(), state.getMachineTypeCd(), state.getMachineSerial());
      if (null == mntMachineState) {
        eventLogMessage.setLogMessage("Get MntMachineState Fail.");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return false;
      }

      //強制オフラインは前/後血圧を処理しません
      if (checkIsForceOffline(mntMachineState)) {
        eventLogMessage.setLogMessage("Force Offline Device.");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return false;
      }

      //実績：治療状況取得
      Long ordNo = mntMachineState.getOrdNo();
      OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
      if (null == ordMain) {
        eventLogMessage.setLogMessage("Get OrdMain Fail.");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return false;
      }
      String rstDialysisState = ordMain.getRstDialysisState();
      if (null == rstDialysisState) {
        eventLogMessage.setLogMessage("RstDialysisState is null.");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return false;
      }

      //モニタデータ更新
      try {
        //V3,V4の場合。
        if(formatCd.equals("V") || formatCd.equals("W")) {
          //前回の前/後血圧データは血圧に更新されました
          if (OrdMainConst.DialysisState.AFTER_SEND.equals(rstDialysisState) || OrdMainConst.DialysisState.CHECKED_SEND.equals(rstDialysisState)) {
            //前血圧判定
            dataType = 5;
          } else if (OrdMainConst.DialysisState.DIALYSIS.equals(rstDialysisState)) {
            //前血圧判定
            Timestamp occurDate = param.getOccurDate();
            Timestamp rstStartDate = ordMain.getRstStartDate();
            if (null != occurDate && null != rstStartDate && occurDate.compareTo(rstStartDate) <= 0) {
              dataType = 5;
              // add FNSI-バグ #7679 通信サーバ 高 start
              if(occurDate.compareTo(rstStartDate) == 0) {
                // 前血圧のモニタデータを取得
                MniMonitor monitor = mniMonitorDao.selectByOrdNoDataTypeLast(
                  // #10373 Add a parameter to improve performance
                  param.getFacilityCd(),
                  ordNo, CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_BEFORE_BP);
                if (Objects.nonNull(monitor)) {
                  if (occurDate.compareTo(monitor.getOccurDate()) == 0) {
                    dataType = CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_DIALYSIS_BP;
                  }
                }
              }
              // add FNSI-バグ #7679 通信サーバ 高 end
            }
          } else if (OrdMainConst.DialysisState.AFTER_DIALYSIS.equals(rstDialysisState)) {
            //後血圧判定
            Timestamp occurDate = param.getOccurDate();
            Timestamp rstEndDate = ordMain.getRstEndDate();
            if (null != occurDate && null != rstEndDate && occurDate.compareTo(rstEndDate) >= 0) {
              dataType = 6;
            }
          } else if (OrdMainConst.DialysisState.AFTER_WEIGHT.equals(rstDialysisState) || OrdMainConst.DialysisState.PAST_RECORD.equals(rstDialysisState)) {
            //後血圧判定
            dataType = 6;
          }
        }
        else {
          dataType = param.getDataType();
        }

        // dataType = 2 の場合は update 処理不要
        if (dataType == 2) {
          eventLogMessage.setLogMessage("No update required.");
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
          return true;
        }
        if (0 < mniMonitorDao.updateDataTypeByOrdNoDataType(ordNo, dataType, (short)2)) {
          eventLogMessage.setLogMessage("Update MniMonitor Success.");
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
          return true;
        }
        eventLogMessage.setLogMessage("Update MniMonitor Fail.");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return false;
      } catch (Exception e) {
        eventLogMessage.setLogMessage("Update MniMonitor Error.");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return false;
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      if (state != null && state.getFacilityCd() != null) {
        eventLogMessageNew.setFacilityCd(state.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    } finally {
      //最新の血圧データ登録
      param.setDataType(dataType);
      runWriteMonitorDefault(param, state);
    }

    return false;
  }
  // add サーバ上へ登録した前血圧、後血圧について, #7679 高 end

  public boolean runWriteMonitorDefault(MniMonitor rcd, MntMachineState state) {
	EventLogMessage eventLogMessage = new EventLogMessage();
	eventLogMessage.setMachineTypeCd(rcd.getMachineTypeCd());
    try {
      if (mniMonitorService.insertMonitor(rcd, state) > 0) {
  	  	eventLogMessage.setLogMessage("Insert MniMonitor SUCCESS.");
        eventLogMessage.setSqlIdentification("(MniMonitor = " + rcd + ", MntMachineState = " + state + ")");
        eventLogMessage.setFacilityCd(rcd.getFacilityCd());
  	  	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, "mniMonitorService/insertMonitor");
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MONITOR);
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
	    logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MONITOR);
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
	    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
    }
    return false;
  }

  public boolean runWriteMonitorStart(MniMonitor rcd, MntMachineState state) {
	EventLogMessage eventLogMessage = new EventLogMessage();
	eventLogMessage.setMachineTypeCd(state.getMachineTypeCd());
	eventLogMessage.setMachineType(state.getMachineName());
    try {
      if (mniMonitorService.insertMonitorDyalysisStart(rcd, state) > 0) {
        eventLogMessage.setLogMessage("Insert MniMonitor <Dyalysis Start> SUCCESS.");
        eventLogMessage.setSqlIdentification("(MniMonitor = " + rcd + ", MntMachineState = " + state + ")");
        eventLogMessage.setFacilityCd(rcd.getFacilityCd());
  	  	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, "mniMonitorService/insertMonitorDyalysisStart");
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MONITOR);
      eventLogMessage.setSqlIdentification("(MniMonitor = " + rcd + ", MntMachineState = " + state + ")");
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
	    logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mniMonitorService/insertMonitorDyalysisStart");
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MONITOR);
      eventLogMessage.setSqlIdentification("(MniMonitor = " + rcd + ", MntMachineState = " + state + ")");
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
	    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "mniMonitorService/insertMonitorDyalysisStart");
    }
    return false;
  }

  public boolean runWriteMonitorFinish(MniMonitor rcd, MntMachineState state) {
	EventLogMessage eventLogMessage = new EventLogMessage();
	eventLogMessage.setMachineTypeCd(state.getMachineTypeCd());
	eventLogMessage.setMachineType(state.getMachineName());
    try {
      if (mniMonitorService.insertMonitorDyalysisFinish(rcd, state) > 0) {
        eventLogMessage.setLogMessage("Insert MniMonitor <Dyalysis Finish> SUCCESS.");
        eventLogMessage.setSqlIdentification("(MniMonitor = " + rcd + ", MntMachineState = " + state + ")");
        eventLogMessage.setFacilityCd(rcd.getFacilityCd());
  	  	logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, "mniMonitorService/insertMonitorDyalysisFinish");
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MONITOR);
      eventLogMessage.setSqlIdentification("(MniMonitor = " + rcd + ", MntMachineState = " + state + ")");
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mniMonitorService/insertMonitorDyalysisFinish");
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MONITOR);
      eventLogMessage.setSqlIdentification("(MniMonitor = " + rcd + ", MntMachineState = " + state + ")");
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "mniMonitorService/insertMonitorDyalysisFinish");
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
    rcd.setDeviceEdgeNo(Integer.parseInt(items.getItemValue(TelegramKey.KEY_EDGE_NO)));
    rcd.setMachineTypeCd(items.getItemValue(TelegramKey.KEY_DEVICE_TYPE));
    rcd.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    rcd.setComFormatCd(items.getItemValue(TelegramKey.KEY_COMM_FORMAT));
    rcd.setDataType(MntMotionRecordStaticValues.DataType.LOG);
    rcd.setMachineRecordCd(items.getItemValue(TelegramKey.KEY_CODE));
    // add FNSI-バグ #7108 通信サーバ 高 start
    String machineRecordCode = items.getItemValue(TelegramKey.KEY_CODE);
    if(machineRecordCode.isEmpty() || "0000".equals(machineRecordCode))
    {
      return true;
    }
    // add FNSI-バグ #7108 通信サーバ 高 end
    short nClass = 0;
    String strClass = items.getItemValue(TelegramKey.KEY_CLASS);
    if (strClass != null && Utilities.isNumber(strClass)) {
      nClass = Short.parseShort(strClass);
    }
    rcd.setLogType(nClass);

    String auxDataValue = "";
    List<String> auxDataArray;
    if (items.getItemValue(TelegramKey.KEY_VERSION).equals("00")) {
      // 新通信
      // mod FNSI-バグ #7108 通信サーバ 高 start
      String data1 = items.getItemValue(TelegramKey.KEY_AUX_DATA_1);
      String data2 = items.getItemValue(TelegramKey.KEY_AUX_DATA_2);
      String data3 = items.getItemValue(TelegramKey.KEY_AUX_DATA_3);
      String data4 = items.getItemValue(TelegramKey.KEY_AUX_DATA_4);
      if(data1 == null)
        data1 = "0";
      if(data2 == null)
        data2 = "0";
      if(data3 == null)
        data3 = "0";
      if(data4 == null)
        data4 = "0";
//      auxDataArray = new ArrayList<>(Arrays.asList(
//      items.getItemValue(TelegramKey.KEY_AUX_DATA_1),
//        items.getItemValue(TelegramKey.KEY_AUX_DATA_2),
//        items.getItemValue(TelegramKey.KEY_AUX_DATA_3),
//        items.getItemValue(TelegramKey.KEY_AUX_DATA_4)));
      auxDataArray = new ArrayList<>(Arrays.asList(data1, data2, data3, data4));
      // mod FNSI-バグ #7108 通信サーバ 高 end
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
      // add FNSI-バグ #7108 通信サーバ 高 start
      if(data3 == null)
        data3 = "0";
      if(data4 == null)
        data4 = "0";
      if(data5 == null)
        data5 = "0";
      if(data6 == null)
        data6 = "0";
      // add FNSI-バグ #7108 通信サーバ 高 end

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

    //add bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- start
    //・データをMNT_MOTION_RECORDにデータを登録する時、
    //「装置記録コード」で、MST_MACHINE_RECORD_CONTROLに該当するメッセージと表示フラグ（disp_flg）を取得する
    //MST_MACHINE_RECORD_CONTROLで該当するデータを見つかれない場合、MST_MACHINE_RECORDに該当するメッセージと表示フラグ（disp_flg）を取得する
    //・取得した表示フラグ（disp_flg）で下記ロジックを行う：
    //表示フラグ（disp_flg）の値は ’2’ である時、レポート表示フラグ（report_disp_flg）は'1'に設定する
    //表示フラグ（disp_flg）の値は ’2’ 以外である時、レポート表示フラグ（report_disp_flg）は'0'に設定する
    //・上記ロジックで取得した　メッセージと表示フラグ（disp_flg）を利用してMNT_MOTION_RECORDにデータを登録
    if(items.getItemValue(TelegramKey.KEY_COMM_FORMAT).equals("V") || items.getItemValue(TelegramKey.KEY_COMM_FORMAT).equals("W")) {
      rcd.setReportDispFlg("0");
    } else {
      String dispFlg = mstMachineRecordControlDao.selectDispFlg(rcd.getMachineRecordCd(), items.getItemValue(TelegramKey.KEY_FACILITY_CD));
      if(Strings.isNullOrEmpty(dispFlg)){
        MstMachineRecord mstMachineRecord = new MstMachineRecord();
        mstMachineRecord = mstMachineRecordDao.selectByCd(rcd.getMachineRecordCd());
        if(mstMachineRecord != null){
          dispFlg = mstMachineRecord.getDispFlg();
          if("2".equals(dispFlg)){
            rcd.setReportDispFlg("1");
          } else {
            rcd.setReportDispFlg("0");
          }
        } else {
          rcd.setReportDispFlg("0");
        }
      } else {
        if("2".equals(dispFlg)){
          rcd.setReportDispFlg("1");
        } else {
          rcd.setReportDispFlg("0");
        }
      }
    }
    //add bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setMachineTypeCd(rcd.getMachineTypeCd());
    eventLogMessage.setDeviceEdgeNo(String.valueOf(rcd.getDeviceEdgeNo()));

    //add #269:強制オフライン 劉 start
    boolean isForceOff = false;   //強制オフライン
    boolean isNotOrdNo = false;   //ordNoに登録しない
    try {
      MntMachineState mntMachineState = mntMachineStateService.selectByKey(rcd.getFacilityCd(), rcd.getMachineTypeCd(), rcd.getMachineSerial());
      isForceOff = checkIsForceOffline(mntMachineState);
      if (isForceOff) {
        if (null != rcd.getMachineRecordCd()) {
          if (!rcd.getMachineRecordCd().equals(NORMAL_BLOOD_PRESSURE) &&
              !rcd.getMachineRecordCd().equals(TEMPERATURE_CD) &&
              !rcd.getMachineRecordCd().equals(ANTERIOR_BLOOD_PRESSURE) &&
              !rcd.getMachineRecordCd().equals(POSTERIOR_BLOOD_PRESSURE)) {
            isNotOrdNo = true;
          }
        } else {
          isNotOrdNo = true;
        }
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      if (rcd.getFacilityCd() != null) {
        eventLogMessageNew.setFacilityCd(rcd.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    //add #269:強制オフライン 劉 end

    //add サーバ上へ登録した前血圧、後血圧について 劉 start
    if (!isForceOff &&
        (rcd.getMachineRecordCd().equals(NORMAL_BLOOD_PRESSURE) ||
         rcd.getMachineRecordCd().equals(ANTERIOR_BLOOD_PRESSURE) ||
         rcd.getMachineRecordCd().equals(POSTERIOR_BLOOD_PRESSURE))) {
      //強制オフラインは前/後血圧を処理しません
      String bloodPressureCd = updateBloodPressureMotionRecord(rcd);
      rcd.setMachineRecordCd(bloodPressureCd);
    }
    //add サーバ上へ登録した前血圧、後血圧について 劉 end

    if (ExternalAlarmCode.EXTERNAL_ALARM_1_ON.equals(rcd.getMachineRecordCd()) ||
        ExternalAlarmCode.EXTERNAL_ALARM_2_ON.equals(rcd.getMachineRecordCd()) ||
        ExternalAlarmCode.EXTERNAL_ALARM_3_ON.equals(rcd.getMachineRecordCd()) ||
        ExternalAlarmCode.EXTERNAL_ALARM_4_ON.equals(rcd.getMachineRecordCd()) ||
        ExternalAlarmCode.EXTERNAL_ALARM_1_OFF.equals(rcd.getMachineRecordCd()) ||
        ExternalAlarmCode.EXTERNAL_ALARM_2_OFF.equals(rcd.getMachineRecordCd()) ||
        ExternalAlarmCode.EXTERNAL_ALARM_3_OFF.equals(rcd.getMachineRecordCd()) ||
        ExternalAlarmCode.EXTERNAL_ALARM_4_OFF.equals(rcd.getMachineRecordCd())) {

      //mod bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- start
      if(!items.getItemValue(TelegramKey.KEY_COMM_FORMAT).equals("V") && !items.getItemValue(TelegramKey.KEY_COMM_FORMAT).equals("W")) {
        String machineRecordMessage = mstMachineRecordControlDao.selectMachineRecordMessage(rcd.getMachineRecordCd(), items.getItemValue(TelegramKey.KEY_FACILITY_CD));
        if (Strings.isNullOrEmpty(machineRecordMessage)) {
          MstMachineRecord mstMachineRecord = mstMachineRecordDao.selectByCd(rcd.getMachineRecordCd());
          if (mstMachineRecord != null) {
            machineRecordMessage = mstMachineRecord.getMachineRecordMessage();
          }
        }
        rcd.setMachineRecordMessage(machineRecordMessage);
      }
      //mod bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- end

      // 装置記録書き込み
      try {
        //mod #269:強制オフライン 劉 start
        //if (mntMotionRecodeService.insertLogMotionMessage(rcd) > 0) {
        int ret = 0;
        if (isNotOrdNo) {
          rcd.setOrdNo(null);
          ret = mntMotionRecodeService.insertLogMotionMessageAndOrdNo(rcd);
        } else {
          ret = mntMotionRecodeService.insertLogMotionMessage(rcd);
        }

        if (0 < ret) {
        //mod #269:強制オフライン 劉 end
          eventLogMessage.setLogMessage("Insert MotionRecode SUCCESS.");
          eventLogMessage.setFacilityCd(rcd.getFacilityCd());
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
          return true;
        }
        eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_LOG);
        eventLogMessage.setFacilityCd(rcd.getFacilityCd());
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
      } catch (Exception e) {
        eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_LOG);
        eventLogMessage.setFacilityCd(rcd.getFacilityCd());
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
      return false;
    }

    // 装置記録書き込み
    try {

      //mod bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- start
      //V3,V4の場合、装置からのメッセージ内容をそのまま登録する。（MST_MACHINE_RECORD_xx）テーブルを参照していない認識です。
      //表示フラグは非表示で登録する。
      //上記以外の場合、（MST_MACHINE_RECORD_xx）テーブルからメッセージを取得し、MNT_MOTION_RECORDにデータを登録すうる。
      //表示フラグの登録仕様は上記➁を参照。
      //
      //確認必要なポイント：
      //V3,V4の場合、mst_machine_record参照していない。
      //V3,V4以外の場合、装置からもらったメッセージコードでmst_machine_recordからメッセージ内容を取得する。
      if(!items.getItemValue(TelegramKey.KEY_COMM_FORMAT).equals("V") && !items.getItemValue(TelegramKey.KEY_COMM_FORMAT).equals("W")) {
        String machineRecordMessage = mstMachineRecordControlDao.selectMachineRecordMessage(rcd.getMachineRecordCd(), items.getItemValue(TelegramKey.KEY_FACILITY_CD));
        if(Strings.isNullOrEmpty(machineRecordMessage)) {
          MstMachineRecord mstMachineRecord = new MstMachineRecord();
          mstMachineRecord = mstMachineRecordDao.selectByCd(rcd.getMachineRecordCd());
          if(mstMachineRecord != null) {
            machineRecordMessage = mstMachineRecord.getMachineRecordMessage();
            if (!Strings.isNullOrEmpty(machineRecordMessage)) {
              rcd.setMachineRecordMessage(machineRecordMessage);
            }
          } else {
            rcd.setMachineRecordMessage("");
          }
        } else {
          rcd.setMachineRecordMessage(machineRecordMessage);
        }
      }
      //mod bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- end

      //mod #269:強制オフライン 劉 start
      //if (mntMotionRecodeService.insertLogMotion(rcd, auxDataArray.get(0), auxDataArray.get(1), auxDataArray.get(2), auxDataArray.get(3)) > 0) {
      int ret = 0;
      if (isNotOrdNo) {
        rcd.setOrdNo(null);
        ret = mntMotionRecodeService.insertLogMotionAndOrdNo(rcd, auxDataArray.get(0), auxDataArray.get(1), auxDataArray.get(2), auxDataArray.get(3));
      } else {
        ret = mntMotionRecodeService.insertLogMotion(rcd, auxDataArray.get(0), auxDataArray.get(1), auxDataArray.get(2), auxDataArray.get(3));
      }

      if (0 < ret) {
      //mod #269:強制オフライン 劉 end
        eventLogMessage.setLogMessage("Insert MotionRecode SUCCESS.");
        eventLogMessage.setFacilityCd(rcd.getFacilityCd());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

        // ナースコール書き込み時
        if (rcd.getMachineRecordCd().equals("4200")) {
          registerNotify(rcd);
        }

        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_LOG);
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_LOG);
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
    }
    return false;
  }

  //add サーバ上へ登録した前血圧、後血圧について 劉 start
  /**
   * 前回の前/後血圧記録更新
   *
   * @param rcd      装置動作記録のEntity
   * @return 血圧記録コード
   */
  public String updateBloodPressureMotionRecord(MntMotionRecord rcd) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(rcd.getFacilityCd());
    eventLogMessage.setMachineType(rcd.getMachineTypeCd());

    String bloodPressureCd = NORMAL_BLOOD_PRESSURE;
    try {
      //装置状態管理取得
      MntMachineState mntMachineState = mntMachineStateService.selectByKey(rcd.getFacilityCd(), rcd.getMachineTypeCd(), rcd.getMachineSerial());
      if (null == mntMachineState) {
        eventLogMessage.setLogMessage("Get MntMachineState Fail.");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return bloodPressureCd;
      }

      //実績：治療状況取得
      Long ordNo = mntMachineState.getOrdNo();
      OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
      if (null == ordMain) {
        eventLogMessage.setLogMessage("Get OrdMain Fail.");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return bloodPressureCd;
      }
      String rstDialysisState = ordMain.getRstDialysisState();
      if (null == rstDialysisState) {
        eventLogMessage.setLogMessage("RstDialysisState is null.");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return bloodPressureCd;
      }

      // add FNSI-バグ #7679 通信サーバ 高 start
      MntMotionRecord mntMotionRecord = null;
      if (("V").equals(rcd.getComFormatCd()) || ("W").equals(rcd.getComFormatCd())) {
        // add FNSI-バグ #7679 通信サーバ 高 end
        //前/後血圧判定
        if (OrdMainConst.DialysisState.AFTER_SEND.equals(rstDialysisState) || OrdMainConst.DialysisState.CHECKED_SEND.equals(rstDialysisState)) {
          //前血圧判定
          bloodPressureCd = ANTERIOR_BLOOD_PRESSURE;
          /* modify by chamaojia 2023-05-11 [8229] facilityCdクエリー条件の追加  --start */
          mntMotionRecord = mntMotionRecordDao.selectByOrdNoAndRecordCd(ordNo, ANTERIOR_BLOOD_PRESSURE, rcd.getFacilityCd());
          /* modify by chamaojia 2023-05-11 [8229] facilityCdクエリー条件の追加  --end */
        } else if (OrdMainConst.DialysisState.DIALYSIS.equals(rstDialysisState)) {
          //前血圧判定
          Timestamp eventRegDate = rcd.getEventRegDate();
          Timestamp rstStartDate = ordMain.getRstStartDate();
          if (null != eventRegDate && null != rstStartDate && eventRegDate.compareTo(rstStartDate) <= 0) {
            bloodPressureCd = ANTERIOR_BLOOD_PRESSURE;
            /* modify by chamaojia 2023-05-11 [8229] facilityCdクエリー条件の追加  --start */
            mntMotionRecord = mntMotionRecordDao.selectByOrdNoAndRecordCd(ordNo, ANTERIOR_BLOOD_PRESSURE, rcd.getFacilityCd());
            /* modify by chamaojia 2023-05-11 [8229] facilityCdクエリー条件の追加  --end */
            // add FNSI-バグ #7679 通信サーバ 高 start
            if(mntMotionRecord != null) {
              if(eventRegDate.compareTo(rstStartDate) == 0) {
                if (eventRegDate.compareTo(mntMotionRecord.getEventRegDate()) == 0) {
                  mntMotionRecord = null;
                  bloodPressureCd = NORMAL_BLOOD_PRESSURE;
                }
              }
            }
            // add FNSI-バグ #7679 通信サーバ 高 end
          }
        } else if (OrdMainConst.DialysisState.AFTER_DIALYSIS.equals(rstDialysisState)) {
          //後血圧判定
          Timestamp eventRegDate = rcd.getEventRegDate();
          Timestamp rstEndDate = ordMain.getRstEndDate();
          if (null != eventRegDate && null != rstEndDate && eventRegDate.compareTo(rstEndDate) >= 0) {
            bloodPressureCd = POSTERIOR_BLOOD_PRESSURE;
            /* modify by chamaojia 2023-05-11 [8229] facilityCdクエリー条件の追加  --start */
            mntMotionRecord = mntMotionRecordDao.selectByOrdNoAndRecordCd(ordNo, POSTERIOR_BLOOD_PRESSURE, rcd.getFacilityCd());
            /* modify by chamaojia 2023-05-11 [8229] facilityCdクエリー条件の追加  --end */
          }
        } else if (OrdMainConst.DialysisState.AFTER_WEIGHT.equals(rstDialysisState) || OrdMainConst.DialysisState.PAST_RECORD.equals(rstDialysisState)) {
          //後血圧判定
          bloodPressureCd = POSTERIOR_BLOOD_PRESSURE;
          /* modify by chamaojia 2023-05-11 [8229] facilityCdクエリー条件の追加  --start */
          mntMotionRecord = mntMotionRecordDao.selectByOrdNoAndRecordCd(ordNo, POSTERIOR_BLOOD_PRESSURE, rcd.getFacilityCd());
          /* modify by chamaojia 2023-05-11 [8229] facilityCdクエリー条件の追加  --end */
        }
      }
      // add FNSI-バグ #7679 通信サーバ 高 start
      else {
        bloodPressureCd = rcd.getMachineRecordCd();
        if(!rcd.getMachineRecordCd().equals(NORMAL_BLOOD_PRESSURE)) {
          /* modify by chamaojia 2023-05-11 [8229] facilityCdクエリー条件の追加  --start */
          mntMotionRecord = mntMotionRecordDao.selectByOrdNoAndRecordCd(ordNo, rcd.getMachineRecordCd(), rcd.getFacilityCd());
          /* modify by chamaojia 2023-05-11 [8229] facilityCdクエリー条件の追加  --end */
        }
      }
      // add FNSI-バグ #7679 通信サーバ 高 end
      if (null == mntMotionRecord) {
        eventLogMessage.setLogMessage("Get MntMotionRecord Fail.");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return bloodPressureCd;
      }

      //更新装置記録
      try {
        String machineRecordMessage;
        if (!("V").equals(rcd.getComFormatCd()) && !("W").equals(rcd.getComFormatCd())) {
          machineRecordMessage = mstMachineRecordControlDao.selectMachineRecordMessage(NORMAL_BLOOD_PRESSURE, rcd.getFacilityCd());
          if (Strings.isNullOrEmpty(machineRecordMessage)) {
            machineRecordMessage = mstMachineRecordDao.selectMachineRecordMessage(NORMAL_BLOOD_PRESSURE);
          }
        } else {
          machineRecordMessage = mstMachineRecordDao.selectMachineRecordMessage(NORMAL_BLOOD_PRESSURE);
        }
        mntMotionRecord.setMachineRecordCd(NORMAL_BLOOD_PRESSURE);
        mntMotionRecord.setMachineRecordMessage(machineRecordMessage);
        if (0 < mntMotionRecordDao.update(mntMotionRecord)) {
          mntMotionTrigger.triggerMntMotionRecord(mntMotionRecord, OperateType.UPDATE);// add by shiyw for Trigger:sync_mnt_motion_record 20230306
          eventLogMessage.setLogMessage("Update MntMotionRecord Success.");
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
          return bloodPressureCd;
        }
        eventLogMessage.setLogMessage("Update MntMotionRecord Fail.");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return bloodPressureCd;
      } catch (Exception e) {
        eventLogMessage.setLogMessage("Update MntMotionRecord Error.");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return bloodPressureCd;
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      if (rcd != null && rcd.getFacilityCd() != null) {
        eventLogMessageNew.setFacilityCd(rcd.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }

    return bloodPressureCd;
  }
  //add サーバ上へ登録した前血圧、後血圧について 劉 end

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
    rcd.setDeviceEdgeNo(Integer.parseInt(items.getItemValue(TelegramKey.KEY_EDGE_NO)));
    rcd.setMachineTypeCd(items.getItemValue(TelegramKey.KEY_DEVICE_TYPE));
    rcd.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    rcd.setComFormatCd(items.getItemValue(TelegramKey.KEY_COMM_FORMAT));
    rcd.setDataType(dataType);
    rcd.setTestType(testType);
    rcd.setMachineRecordMessage(MntMotionRecordStaticValues.MachineRecordMessage.getTestTypeMessage(testType));
    rcd.setContents(items.getItemValue(TelegramKey.KEY_ITEMS));
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setMachineTypeCd(rcd.getMachineTypeCd());
    eventLogMessage.setDeviceEdgeNo(rcd.getDeviceEdgeNo().toString());

    // mod 装置の自己診断の結果を施設カレンダーに反映する必要。#7801 劉 start
    String facilityCd = items.getItemValue(TelegramKey.KEY_FACILITY_CD);
    String machineTypeCd = items.getItemValue(TelegramKey.KEY_DEVICE_TYPE);
    String machineSerial = items.getItemValue(TelegramKey.KEY_SERIAL_NO);
    MstMachine mstMachine = null;
    List<MstSelfMeasureResult> resultList = null;
    String version;
    int index = -1;
    String strSelfMeasureResult = null;

    try {
      //装置情報を取得
      mstMachine = mstMachineDao.selectByCd(machineTypeCd, machineSerial, facilityCd);
      if (null == mstMachine) {
        eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_MNT);
        eventLogMessage.setSqlIdentification("(MntMotionRecord = " + rcd + ")");
        eventLogMessage.setFacilityCd(rcd.getFacilityCd());
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertMntMotion");
        return false;
      }

      //装置自己診断情報を取得
      resultList = mstSelfMeasureResultDao.selectByFacilityCd(facilityCd);
      if (null == resultList) {
        eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_MNT);
        eventLogMessage.setSqlIdentification("(MntMotionRecord = " + rcd + ")");
        eventLogMessage.setFacilityCd(rcd.getFacilityCd());
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertMntMotion");
        return false;
      }
      //バージョン番号にマッチする索引を検索します
      version = mstMachine.getVersion();
      index = checkVersionIsValid(rcd, version, resultList);
      if (0 > index || resultList.size() <= index) {
        eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_MNT);
        eventLogMessage.setSqlIdentification("(MntMotionRecord = " + rcd + ")");
        eventLogMessage.setFacilityCd(rcd.getFacilityCd());
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertMntMotion");
        return false;
      }
      strSelfMeasureResult = resultList.get(index).getSelfMeasureResult();
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_MNT +":"+e.getMessage());
      eventLogMessage.setSqlIdentification("(MntMotionRecord = " + rcd + ")");
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertMntMotion");
      return false;
    }
    finally {
      try {
        if(strSelfMeasureResult != null ) {
          String strContents = rcd.getContents();
          int iPos = strContents.lastIndexOf("}");
          if(iPos > -1) {
            strContents = strContents.substring(0, iPos) +
                                  ",\"999\":"+ strSelfMeasureResult + "}" +
                                  strContents.substring(iPos + 1, strContents.length());
          }
          rcd.setContents(strContents);
        }
        if (mntMotionRecodeService.insertMntMotion(rcd) > 0) {
          eventLogMessage.setLogMessage("Insert MotionRecode SUCCESS.");
          eventLogMessage.setSqlIdentification("(MntMotionRecord = " + rcd + ")");
          eventLogMessage.setFacilityCd(rcd.getFacilityCd());
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertMntMotion");
        } else {
          eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_MNT);
          eventLogMessage.setSqlIdentification("(MntMotionRecord = " + rcd + ")");
          eventLogMessage.setFacilityCd(rcd.getFacilityCd());
          logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertMntMotion");
          return false;
        }
      } catch (Exception e) {
        eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_MNT +":"+e.getMessage());
        eventLogMessage.setSqlIdentification("(MntMotionRecord = " + rcd + ")");
        eventLogMessage.setFacilityCd(rcd.getFacilityCd());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertMntMotion");
        return false;
      }
    }

    // add FNSI-バグ #7108 通信サーバ 高 start
    try {
    // add FNSI-バグ #7108 通信サーバ 高 end
      //自己診断結果判定
      JSONArray selfMeasureResultArray = new JSONArray(resultList.get(index).getSelfMeasureResult());
      int judgeCnt = 0;//判定が必要なkeyの数
      for (int k = 0; k < selfMeasureResultArray.length(); k++) {
        JSONObject selfMeasureResultData = selfMeasureResultArray.getJSONObject(k);
        int judge = getMeasureResultLimit("judge", selfMeasureResultData).intValue();
        if (0 < judge) {judgeCnt++;}
      }

      //最新の自己診断合格結果を抽出
      Long maxMotionRecordNo = mntMotionRecordDao.selectMaxMotionRecordNo(facilityCd, machineTypeCd, machineSerial);
      List<TestResultDetail> mntMotionRecordList;
      if (null != maxMotionRecordNo) {
        mntMotionRecordList = mntMotionRecordDao.selectSelfMeasureResultByMotionRecordNo(facilityCd, machineTypeCd, machineSerial, maxMotionRecordNo);
      } else {
        mntMotionRecordList = mntMotionRecordDao.selectSelfMeasureResultByCurrentDate(facilityCd, machineTypeCd, machineSerial);
      }
      if (null == mntMotionRecordList) {
        eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_MNT);
        eventLogMessage.setSqlIdentification("(MntMotionRecord = " + rcd + ")");
        eventLogMessage.setFacilityCd(rcd.getFacilityCd());
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertMntMotion");
        return false;
      }

      HashMap<Integer, String> selfMeasureResultMap = new HashMap<Integer, String>();
      for (int j = 0; j < mntMotionRecordList.size(); ++j) {
        TestResultDetail mntMotionRecord = mntMotionRecordList.get(j);
        //add redmine bug #7108 劉 start
        if (Strings.isNullOrEmpty(mntMotionRecord.getTestResultData())) {
          continue;
        }
        //add redmine bug #7108 劉 end
        JSONObject contentsData = new JSONObject(mntMotionRecord.getTestResultData());
        for (int i = 0; i < selfMeasureResultArray.length(); i++) {
          JSONObject selfMeasureResultData = selfMeasureResultArray.getJSONObject(i);
          int judge = getMeasureResultLimit("judge", selfMeasureResultData).intValue();
          if (0 == judge) {
            continue;
          }
          int selfMeasureResultKey = getMeasureResultLimit("key", selfMeasureResultData).intValue();
          if (!contentsData.has(Integer.toString(selfMeasureResultKey, 10))) {
            continue;
          }
          if (selfMeasureResultMap.containsKey(selfMeasureResultKey)) {
            continue;
          }

          //しきい値を取得
          ArrayList<Float> resultLimitList = new ArrayList<Float>();
          resultLimitList.add(getMeasureResultLimit("failure_low", selfMeasureResultData));
          resultLimitList.add(getMeasureResultLimit("caution_low", selfMeasureResultData));
          resultLimitList.add(getMeasureResultLimit("caution_up", selfMeasureResultData));
          resultLimitList.add(getMeasureResultLimit("failure_up", selfMeasureResultData));

          //自己診断の結果判断
          int resultLevel = checkMeasureResult(selfMeasureResultKey, contentsData, resultLimitList);
          if (QUALIFIED_LEVEL == resultLevel) {
            //自己診断結果合格
            selfMeasureResultMap.put(selfMeasureResultKey, QUALIFIED_CD);
          } else if (VIGILANT_LEVEL == resultLevel) {
            //自己診断結果合格(注意)
            selfMeasureResultMap.put(selfMeasureResultKey, VIGILANT_CD);
          } else if (0 == j && UNQUALIFIED_LEVEL == resultLevel) {
            //最新の自己診断結果不合格,データの登録が必要
            return insertMeasureResultLogMotion(rcd, UNQUALIFIED_INSERT_CD, UNQUALIFIED_CD, UNQUALIFIED_MESSAGE);
          }

          if (0 < judgeCnt && selfMeasureResultMap.size() == judgeCnt) {
            if (selfMeasureResultMap.containsValue(VIGILANT_CD)) {
              //装置自己診断結果合格(注意)
              return insertMeasureResultLogMotion(rcd, VIGILANT_INSERT_CD, VIGILANT_CD, VIGILANT_MESSAGE);
            } else {
              //装置自己診断結果合格
              return insertMeasureResultLogMotion(rcd, QUALIFIED_INSERT_CD, QUALIFIED_CD, QUALIFIED_MESSAGE);
            }
          }
        }
      }
    }
    // add FNSI-バグ #7108 通信サーバ 高 start
    catch (Exception e) {
      return false;
    }
    // add FNSI-バグ #7108 通信サーバ 高 end
    // mod 装置の自己診断の結果を施設カレンダーに反映する必要。 #7801 劉 end
    return false;
  }

  // add 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 start
  /**
   * バージョン番号にマッチする索引を検索します。
   *
   * @param mntMotionRecord   装置動作記録
   * @param version           バージョン
   * @param resultList        自己診断判定マスタ
   * @return
   */
  public int checkVersionIsValid(MntMotionRecord mntMotionRecord, String version, List<MstSelfMeasureResult> resultList) {
    int index = -1;
    String machineTypeCd = mntMotionRecord.getMachineTypeCd();
    Long selfMeasureResultCdBak = 0L;
    String verLowBak = "";
    String verUpBak = "";

    for (int i = 0; i < resultList.size(); i++) {
      JSONArray machineInfoDataArray = new JSONArray(resultList.get(i).getMachineInfo());
      for (int j = 0; j < machineInfoDataArray.length(); j++) {
        JSONObject machineInfoData = machineInfoDataArray.getJSONObject(j);
        if (machineInfoData.has("type_cd") && machineTypeCd.equals(machineInfoData.getString("type_cd"))) {
          //型式コードが同じ場合はバージョン番号を判断します
          Long selfMeasureResultCd = resultList.get(i).getSelfMeasureResultCd();
          String verLow = getVersionLimit("ver_low", machineInfoData);
          String verUp = getVersionLimit("ver_up", machineInfoData);
          // del #10095 自己診断結果判定にバージョンによる区分がおこなわれていない 高 start
//          if (Strings.isNullOrEmpty(verLowBak) && Strings.isNullOrEmpty(verUpBak)) {
//            verLowBak = verLow;
//            verUpBak = verUp;
//            selfMeasureResultCdBak = selfMeasureResultCd;
//            index = i;
//            continue;
//          }
          // del #10095 自己診断結果判定にバージョンによる区分がおこなわれていない 高 end

          if (Strings.isNullOrEmpty(version)) {
            //装置バージョン番号が設定されていません
            // mod #10095 自己診断結果判定にバージョンによる区分がおこなわれていない 高 start
            // if (isReplaceVersion(mntMotionRecord, verLowBak, verUpBak, selfMeasureResultCdBak, verLow, verUp, selfMeasureResultCd)) {
            if (isReplaceVersion(mntMotionRecord, verLow, verUp, selfMeasureResultCd, verLowBak, verUpBak, selfMeasureResultCdBak)) {
            // mod #10095 自己診断結果判定にバージョンによる区分がおこなわれていない 高 end
              verLowBak = verLow;
              verUpBak = verUp;
              selfMeasureResultCdBak = selfMeasureResultCd;
              index = i;
            }
          } else {
            //装置バージョン番号が設定されています
            int resOfLow = versionCompare(mntMotionRecord, version, verLow);
            int resOfUp = versionCompare(mntMotionRecord, verUp, version);
            if (0 <= resOfLow && 0 <= resOfUp) {
              if (isReplaceVersion(mntMotionRecord, verLow, verUp, selfMeasureResultCd, verLowBak, verUpBak, selfMeasureResultCdBak)) {
                verLowBak = verLow;
                verUpBak = verUp;
                selfMeasureResultCdBak = selfMeasureResultCd;
                index = i;
              }
            }
          }
        }
      }
    }
    return index;
  }

  /**
   * バージョン番号上下限を取得。
   *
   * @param key               上下限のkey
   * @param machineInfo       対象機種情報
   * @return  バージョン番号上下限
   */
  public String getVersionLimit(String key, JSONObject machineInfo) {
    String verLimit = "";
    if (key.equals("ver_low")) verLimit = MACHINE_VER_MIN;
    if (key.equals("ver_up")) verLimit = MACHINE_VER_MAX;

    if (machineInfo.has(key) && !Strings.isNullOrEmpty(machineInfo.getString(key))) {
      verLimit = machineInfo.getString(key);
    }
    return verLimit;
  }

  /**
   * バージョン番号にマッチする索引を検索します。
   *
   * @param mntMotionRecord   装置動作記録
   * @param verLow_1          第一グループバージョン番号下限
   * @param verUp_1           第一グループバージョン番号上限
   * @param code_1            第一グループコード
   * @param verLow_2          第二グループバージョン番号下限
   * @param verUp_2           第二グループバージョン番号上限
   * @param code_2            第二グループコード
   * @return
   */
  public boolean isReplaceVersion(MntMotionRecord mntMotionRecord, String verLow_1, String verUp_1, Long code_1, String verLow_2, String verUp_2, Long code_2) {
    // add #10095 自己診断結果判定にバージョンによる区分がおこなわれていない 高 start
    if (Strings.isNullOrEmpty(verLow_2) && Strings.isNullOrEmpty(verUp_2)) {
      return true;
    }
    // add #10095 自己診断結果判定にバージョンによる区分がおこなわれていない 高 end
    int res = versionCompare(mntMotionRecord, verLow_1, verLow_2);
    if (1 == res) {
      //verLow_1はverLow_2より大きい
      return true;
    } else if (0 == res) {
      ///verLow_1イコールverLow_2、verUp_1とverUp_2を比較する
      res = versionCompare(mntMotionRecord, verUp_1, verUp_2);
      if (1 == res) {
        //verUp_1はverUp_2より大きい
        return true;
      } else if (0 == res) {
        //verUp_1イコールverUp_2、code_1とcode_2を比較する
        return code_1 > code_2;
      }
    }
    return false;
  }

  /**
   * バージョン番号のサイズを比較,version書式:[1~99].[1~99][[space]|[A~Z]]
   *                                        ____   ____   ____________
   *                                          |     |           |_____________3桁
   *                                          |     |_________________________2桁
   *                                          |_______________________________1桁
   *
   * @param mntMotionRecord   装置動作記録
   * @param verFirst          第一グループバージョン番号
   * @param verSecond         第二グループバージョン番号
   * @return verFirst > verSecond : return 1
   *         verFirst = verSecond : return 0
   *         verFirst < verSecond : return -1
   */
  public int versionCompare(MntMotionRecord mntMotionRecord, String verFirst, String verSecond) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(mntMotionRecord.getFacilityCd());
    eventLogMessage.setMachineTypeCd(mntMotionRecord.getMachineTypeCd());

    int indexFirst = verFirst.indexOf(".");
    int indexSecond = verSecond.indexOf(".");
    if (0 > indexFirst || 0 > indexSecond) {return -99;}

    String subVerFirst = verFirst.substring(0, indexFirst);
    String subVerSecond = verSecond.substring(0, indexSecond);
    try {
      //比較1桁
      int subVerFirstValue = Integer.parseInt(subVerFirst);
      int subVerSecondValue = Integer.parseInt(subVerSecond);
      if (subVerFirstValue > subVerSecondValue) {return 1;}
      if (subVerFirstValue < subVerSecondValue) {return -1;}

      // add #10095 自己診断結果判定にバージョンによる区分がおこなわれていない 高 start
      int indexThird_1, indexThird_2;
      char c;
      for (indexThird_1 = indexFirst + 1; indexThird_1 < verFirst.length(); indexThird_1++) {
        c = verFirst.charAt(indexThird_1);
        if(c >= '0' && c <= '9')
          continue;
        break;
      }
      for (indexThird_2 = indexSecond + 1; indexThird_2 < verSecond.length(); indexThird_2++) {
        c = verSecond.charAt(indexThird_2);
        if(c >= '0' && c <= '9')
          continue;
        break;
      }
      // add #10095 自己診断結果判定にバージョンによる区分がおこなわれていない 高 end

      //1桁は同じで,比較2桁
      // mod #10095 自己診断結果判定にバージョンによる区分がおこなわれていない 高 start
      // subVerFirst = verFirst.substring(indexFirst + 1, verFirst.length() - 1);
      // subVerSecond = verSecond.substring(indexSecond + 1, verSecond.length() - 1);
      subVerFirst = verFirst.substring(indexFirst + 1, indexThird_1);
      subVerSecond = verSecond.substring(indexSecond + 1, indexThird_2);
      subVerFirstValue = Integer.parseInt(subVerFirst);
      subVerSecondValue = Integer.parseInt(subVerSecond);
      if (subVerFirstValue > subVerSecondValue) {return 1;}
      if (subVerFirstValue < subVerSecondValue) {return -1;}

      //2桁は同じで,比較3桁
      subVerFirst = verFirst.substring(indexThird_1, verFirst.length());
      subVerSecond = verSecond.substring(indexThird_2, verSecond.length());
      if (0 < subVerFirst.compareTo(subVerSecond)) {return 1;}
      if (0 > subVerFirst.compareTo(subVerSecond)) {return -1;}
      if (0 == subVerFirst.compareTo(subVerSecond)) {return 0;}
    } catch (NumberFormatException ex) {
      eventLogMessage.setLogMessage("Version Compare Error.");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return -99;
    }
    // mod #10095 自己診断結果判定にバージョンによる区分がおこなわれていない 高 end
    return 0;
  }

  /**
   * 自己診断の結果上下限を取得。
   *
   * @param key               上下限のkey
   * @param measureResult     自己診断情報
   * @return  自己診断の結果上下限
   */
  public Float getMeasureResultLimit(String key, JSONObject measureResult) {
    Float resLimit = null;
    if (measureResult.has(key) && !Strings.isNullOrEmpty(measureResult.getString(key))) {
      // mod FNSI-バグ 通信サーバ #8080 高 start
      // resLimit = measureResult.getNumber(key).floatValue();
      try {
        resLimit = measureResult.getNumber(key).floatValue();
      } catch (Exception e) {
        resLimit = null;
      }
      // mod FNSI-バグ 通信サーバ #8080 高 end
    }
    return resLimit;
  }

  /**
   * 自己診断の結果判断
   *
   * @param selfMeasureResultKey   自己診断のkey
   * @param contentsData          上下限のkey
   * @param resultLimitList       自己診断情報
   * @return  自己診断の結果
   */
  public int checkMeasureResult(int selfMeasureResultKey, JSONObject contentsData, ArrayList<Float> resultLimitList) {
    int level = UNQUALIFIED_LEVEL;
    if (UFRC_RESULT_KEY == selfMeasureResultKey || CONCENTRATION_RESULT_KEY == selfMeasureResultKey) {
      //文字列型
      String path = contentsData.get(Integer.toString(selfMeasureResultKey, 10)).toString();
      if (2 <= path.length() && "01".equals(path.substring(path.length() - 2))) {
        //自己診断結果合格
        level = QUALIFIED_LEVEL;
      }
    } else {
      //数値型
      level = measureResultLevel[0];
      float value = contentsData.getNumber(Integer.toString(selfMeasureResultKey, 10)).floatValue();
      for (int i = 0; i < resultLimitList.size(); ++i) {
        Float limitValue = resultLimitList.get(i);
        if (null == limitValue) {
          //しきい値が空の場合
          level = Integer.max(level, measureResultLevel[i + 1]);
        } else {
          if (1 > i) {
            //下限の判断
            if ((0 == Float.compare(value, resultLimitList.get(i))) || (1 == Float.compare(value, resultLimitList.get(i)))) {
              level = measureResultLevel[i + 1];
            } else {
              break;
            }
          } else {
            //上限の判断
            if (1 == Float.compare(value, resultLimitList.get(i))) {
              level = measureResultLevel[i + 1];
            } else {
              break;
            }
          }
        }
      }
    }

    return level;
  }

  /**
   * 自己診断結果登録
   *
   * @param rcd       装置動作記録
   * @param cd        コード
   * @param message   ニュース
   * @return
   */
  public boolean insertMeasureResultLogMotion(MntMotionRecord rcd, String insertCd, String cd, String message) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setMachineTypeCd(rcd.getMachineTypeCd());
    eventLogMessage.setDeviceEdgeNo(rcd.getDeviceEdgeNo().toString());

    String machineRecordMessageByCd = mstMachineRecordDao.selectMachineRecordMessage(cd);
    if (Strings.isNullOrEmpty(machineRecordMessageByCd)) {
      machineRecordMessageByCd = message;
    }
    rcd.setMachineRecordMessage(machineRecordMessageByCd);
    rcd.setDataType(MntMotionRecordStaticValues.DataType.LOG);
    rcd.setMachineRecordCd(insertCd);
    // add #10063 自己診断結果レコードのコード不正修正 高 start
    String dispFlg = mstMachineRecordControlDao.selectDispFlg(insertCd, rcd.getFacilityCd());
    if(Strings.isNullOrEmpty(dispFlg)){
      MstMachineRecord mstMachineRecord;
      mstMachineRecord = mstMachineRecordDao.selectByCd(rcd.getMachineRecordCd());
      if(mstMachineRecord != null){
        dispFlg = mstMachineRecord.getDispFlg();
        if("2".equals(dispFlg)){
          rcd.setReportDispFlg("1");
        } else {
          rcd.setReportDispFlg("0");
        }
      } else {
        rcd.setReportDispFlg("0");
      }
    } else {
      if("2".equals(dispFlg)){
        rcd.setReportDispFlg("1");
      } else {
        rcd.setReportDispFlg("0");
      }
    }
    // add #10063 自己診断結果レコードのコード不正修正 高 end
    try {
      if (mntMotionRecodeService.insertLogMotion(rcd, null, null, null, null) > 0) {
        eventLogMessage.setLogMessage("Insert MotionRecode SUCCESS.");
        eventLogMessage.setFacilityCd(rcd.getFacilityCd());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertLogMotion");
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_LOG);
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertLogMotionMessage");
      return false;
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_LOG);
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertLogMotionMessage");
      return false;
    }
  }
  // add 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 end

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
    rcd.setDeviceEdgeNo(Integer.parseInt(items.getItemValue(TelegramKey.KEY_EDGE_NO)));
    rcd.setMachineTypeCd(items.getItemValue(TelegramKey.KEY_DEVICE_TYPE));
    rcd.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    rcd.setComFormatCd(items.getItemValue(TelegramKey.KEY_COMM_FORMAT));
    rcd.setDataType(MntMotionRecordStaticValues.DataType.DISSOLUTION);
    rcd.setMachineRecordMessage(MntMotionRecordStaticValues.MachineRecordMessage.DISSOLUTION);
    rcd.setContents(items.getItemValue(TelegramKey.KEY_ITEMS));
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setMachineTypeCd(rcd.getMachineTypeCd());
    eventLogMessage.setDeviceEdgeNo(rcd.getDeviceEdgeNo().toString());
    eventLogMessage.setSqlIdentification("(MntMotionRecord = " + rcd + ")");
    try {
      if (mntMotionRecodeService.insertDarMotion(rcd) > 0) {
        eventLogMessage.setLogMessage("Insert MotionRecord SUCCESS.");
        eventLogMessage.setFacilityCd(rcd.getFacilityCd());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertDarMotion");
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_DAR);
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertDarMotion");
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_DAR);
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertDarMotion");;
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
    eventLogMessage.setMachineTypeCd(param.getMachineTypeCd());
    eventLogMessage.setSqlIdentification("(MntMachineState = " + param + ")");
    try {
      if (mntMachineStateService.updateUseTime(param) > 0) {
        eventLogMessage.setLogMessage("Update USE_TIME SUCCESS.");
        eventLogMessage.setFacilityCd(param.getFacilityCd());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, "mntMachineStateService/updateUseTime");
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_USE_TIME);
      eventLogMessage.setFacilityCd(param.getFacilityCd());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mntMachineStateService/updateUseTime");
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_USE_TIME);
      eventLogMessage.setFacilityCd(param.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "mntMachineStateService/updateUseTime");
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
    rcd.setDeviceEdgeNo(Integer.parseInt(items.getItemValue(TelegramKey.KEY_EDGE_NO)));
    rcd.setMachineTypeCd(items.getItemValue(TelegramKey.KEY_DEVICE_TYPE));
    rcd.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    rcd.setComFormatCd(items.getItemValue(TelegramKey.KEY_COMM_FORMAT));
    rcd.setDataType(MntMotionRecordStaticValues.DataType.LOG);
    String machineRecordCd = items.getItemValue(TelegramKey.KEY_CODE);
    rcd.setMachineRecordCd(machineRecordCd);
    short nClass = 0;
    String strClass = items.getItemValue(TelegramKey.KEY_CLASS);
    if (strClass != null && Utilities.isNumber(strClass)) {
      nClass = Short.parseShort(strClass);
    }
    rcd.setLogType(nClass);
    // mod FNSI-バグ 通信サーバ 高 start
    if(StringUtils.isNullOrEmpty(machineRecordCd)) {
      rcd.setMachineRecordMessage(items.getItemValue(TelegramKey.KEY_MSG));
    }
    // mod FNSI-バグ 通信サーバ 高 end
    rcd.setMachineRecordAuxData(items.getItemValue(TelegramKey.KEY_MSG2));

    //mod bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- start
    //V3,V4の場合、装置からのメッセージ内容をそのまま登録する。（MST_MACHINE_RECORD_xx）テーブルを参照していない認識です。
    //表示フラグは非表示で登録する。
    //上記以外の場合、（MST_MACHINE_RECORD_xx）テーブルからメッセージを取得し、MNT_MOTION_RECORDにデータを登録すうる。
    //表示フラグの登録仕様は上記➁を参照。
    //
    //確認必要なポイント：
    //V3,V4の場合、mst_machine_record参照していない。
    //V3,V4以外の場合、装置からもらったメッセージコードでmst_machine_recordからメッセージ内容を取得する。
    rcd.setReportDispFlg("0");
    //mod bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setMachineTypeCd(rcd.getMachineTypeCd());
    eventLogMessage.setSqlIdentification("(MntMotionRecord = " + rcd + ")");

    //add #269:強制オフライン 劉 start
    boolean isNotOrdNo = false;   //ordNoに登録しない
    try {
      MntMachineState mntMachineState = mntMachineStateService.selectByKey(rcd.getFacilityCd(), rcd.getMachineTypeCd(), rcd.getMachineSerial());
      if (checkIsForceOffline(mntMachineState)) {
        isNotOrdNo = true;
      }
    } catch (Exception e) {
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    //add #269:強制オフライン 劉 end

    // 装置記録書き込み
    try {
      // 装置記録コード判定
      //add #269:強制オフライン 劉 start
      int ret = 0;
      //add #269:強制オフライン 劉 end
      if (rcd.getMachineRecordCd() != null) {
        // 装置記録コードあり
        //mod #269:強制オフライン 劉 start
        //if (mntMotionRecodeService.insertLogMotion(rcd, null, null, null, null) > 0) {
        if (isNotOrdNo) {
          rcd.setOrdNo(null);
          ret = mntMotionRecodeService.insertLogMotionAndOrdNo(rcd, null, null, null, null);
        } else {
          ret = mntMotionRecodeService.insertLogMotion(rcd, null, null, null, null);
        }

        if (0 < ret) {
        //mod #269:強制オフライン 劉 end
          eventLogMessage.setLogMessage("Insert MotionRecode SUCCESS.");
          eventLogMessage.setFacilityCd(rcd.getFacilityCd());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertLogMotion");
          return true;
        }
      } else {
        // 装置記録コードなし
        //mod #269:強制オフライン 劉 start
        //if (mntMotionRecodeService.insertLogMotionMessage(rcd) > 0) {
        if (isNotOrdNo) {
          rcd.setOrdNo(null);
          ret = mntMotionRecodeService.insertLogMotionMessageAndOrdNo(rcd);
        } else {
          ret = mntMotionRecodeService.insertLogMotionMessage(rcd);
        }

        if (0 < ret) {
        //mod #269:強制オフライン 劉 end
          eventLogMessage.setLogMessage("Insert MotionRecode SUCCESS.");
          eventLogMessage.setFacilityCd(rcd.getFacilityCd());
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertLogMotionMessage");
          return true;
        }
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_LOG);
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertLogMotionMessage");
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_LOG);
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertLogMotionMessage");
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
    rcd.setDeviceEdgeNo(Integer.parseInt(items.getItemValue(TelegramKey.KEY_EDGE_NO)));
    rcd.setMachineTypeCd(items.getItemValue(TelegramKey.KEY_DEVICE_TYPE));
    rcd.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    rcd.setComFormatCd(items.getItemValue(TelegramKey.KEY_COMM_FORMAT));
    rcd.setDataType(dataType);
    rcd.setTestType(testType);
  // mod 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 start
    //rcd.setMachineRecordMessage(items.getItemValue(TelegramKey.KEY_MSG));
    String machineRecordMessage = items.getItemValue(TelegramKey.KEY_MSG);
    rcd.setMachineRecordMessage(machineRecordMessage);
  // mod 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 end
    rcd.setContents(items.getItemValue(TelegramKey.KEY_ITEMS));
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setDeviceEdgeNo(rcd.getDeviceEdgeNo().toString());
    eventLogMessage.setMachineTypeCd(rcd.getMachineTypeCd());
    try {
      if (mntMotionRecodeService.insertMntMotion(rcd) > 0) {

		eventLogMessage.setLogMessage("Insert MotionRecode SUCCESS.");
    eventLogMessage.setSqlIdentification("(MntMotionRecord = " + ")");
    eventLogMessage.setFacilityCd(rcd.getFacilityCd());
		logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertMntMotion");
  // mod 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 start
         //return true;
         // }
       }else {
  // mod 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 end
	  eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_MNT);
    eventLogMessage.setSqlIdentification("(MntMotionRecord = " + ")");
    eventLogMessage.setFacilityCd(rcd.getFacilityCd());
	  logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertMntMotion");
  // add 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 start
         return false;
       }
  // add 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 end
    } catch (Exception e) {
	  eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_MNT + e.getMessage());
    eventLogMessage.setSqlIdentification("(MntMotionRecord = " + ")");
    eventLogMessage.setFacilityCd(rcd.getFacilityCd());
	  logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertMntMotion");
	  // add 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 start
	  return false;
	  // add 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 end
    }
    // add #10063 自己診断結果レコードのコード不正修正 高 start
    rcd.setReportDispFlg("0");
    // add #10063 自己診断結果レコードのコード不正修正 高 end
  // add 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 start
    String machineRecordCd = "";
    String subMessage = "";
    String strOK = "OK";  //自己診断の結果OK
    String strNG = "NG";  //自己診断の結果NG
    int index = machineRecordMessage.indexOf("：");
    subMessage = machineRecordMessage.substring(index + 1);
    if(strOK.equals(subMessage)){
      machineRecordCd = QUALIFIED_CD;
      rcd.setMachineRecordCd(QUALIFIED_INSERT_CD);
    }else if(strNG.equals(subMessage)){
      machineRecordCd = UNQUALIFIED_CD;
      rcd.setMachineRecordCd(UNQUALIFIED_INSERT_CD);
    }
    rcd.setDataType(MntMotionRecordStaticValues.DataType.LOG);
    String machineRecordMessageByCd = mstMachineRecordDao.selectMachineRecordMessage(machineRecordCd);
    if (Strings.isNullOrEmpty(machineRecordMessageByCd)) {
      if (QUALIFIED_CD.equals(machineRecordCd)) {
        machineRecordMessageByCd = QUALIFIED_MESSAGE;
      } else {
        machineRecordMessageByCd = UNQUALIFIED_MESSAGE;
      }
    }
    rcd.setMachineRecordMessage(machineRecordMessageByCd);
    try {
      if (mntMotionRecodeService.insertLogMotion(rcd, null, null, null, null) > 0) {
        eventLogMessage.setLogMessage("Insert MotionRecode SUCCESS.");
        eventLogMessage.setFacilityCd(rcd.getFacilityCd());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertLogMotion");
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MOTION_LOG);
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertLogMotionMessage");
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MOTION_LOG);
      eventLogMessage.setFacilityCd(rcd.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "mntMotionRecodeService/insertLogMotionMessage");
    }
  // add 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 end
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
      eventLogMessage.setLogMessage(String.format(LogMessage.ERROR_DATE_FORMAT + ",[" + occurDate + "]→[" + format + "]\n" + e.getStackTrace().toString()));
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      returnDate = new Timestamp(System.currentTimeMillis());
    }

    return returnDate;
  }

  /**
   * 検出装置の登録
   *
   * @param items
   * @return
   */
  public boolean runInsertMntFindMachine(TelegramItems items) {
    MntFindMachine mfm = new MntFindMachine();
    mfm.setFacilityCd(items.getItemValue(TelegramKey.KEY_FACILITY_CD));
    mfm.setDeviceEdgeNo(Integer.parseInt(items.getItemValue(TelegramKey.KEY_EDGE_NO)));
    mfm.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    mfm.setComFormatCd(items.getItemValue(TelegramKey.KEY_COMM_FORMAT));
    mfm.setComType(Integer.parseInt(items.getItemValue(TelegramKey.KEY_COMM_TYPE)));
    mfm.setIpAddress(items.getItemValue(TelegramKey.KEY_IP));
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(mfm.getFacilityCd());
    eventLogMessage.setDeviceEdgeNo(mfm.getDeviceEdgeNo().toString());
    eventLogMessage.setSqlIdentification("(MntFindMachine = insert)");
    try {
      if (mntFindMachineDao.insert(mfm) > 0) {
        eventLogMessage.setLogMessage("Insert MntFindMachine SUCCESS.");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, "mntFindMachineDao/insert");
        return true;
      }
      eventLogMessage.setLogMessage(LogMessage.WARN_INSERT_MNT_FIND_MACHINE);
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, "mntFindMachineDao/insert");
    } catch (Exception e) {
      eventLogMessage.setLogMessage(LogMessage.ERROR_INSERT_MNT_FIND_MACHINE +":"+e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "mntFindMachineDao/insert");
    }
    return false;
  }
// add 治療記録用データと治療状況用データの登録先を振分けにする --趙-- start
  /**
   * 治療記録用データと治療状況用データの登録先を振分けにす
   * @param items
   * @return
   */
  public boolean runWriteTreatmentStatus(TelegramItems items) {
    MntMachineState state = new MntMachineState();
    if(items.getItemValue(TelegramKey.KEY_FACILITY_CD).isEmpty()
      || items.getItemValue(TelegramKey.KEY_DEVICE_TYPE).isEmpty()
      || items.getItemValue(TelegramKey.KEY_SERIAL_NO).isEmpty()){
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "FacilityCd = "+items.getItemValue(TelegramKey.KEY_FACILITY_CD)
        +" MachineTypeCd = "+items.getItemValue(TelegramKey.KEY_DEVICE_TYPE)
        +" MachineSerial = "+items.getItemValue(TelegramKey.KEY_SERIAL_NO)
      );
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return  false;
    }else{
      state.setFacilityCd(items.getItemValue(TelegramKey.KEY_FACILITY_CD));
      state.setMachineTypeCd(items.getItemValue(TelegramKey.KEY_DEVICE_TYPE));
      state.setMachineSerial(items.getItemValue(TelegramKey.KEY_SERIAL_NO));
    }

    state.setMonitorData(items.getItemValue(TelegramKey.KEY_ITEMS));

    //state.setProcessState(items.getItemValue(TelegramKey.KEY_PROCESS_STATE));
    //state.setMNoticeCnt(Integer.parseInt(items.getItemValue(TelegramKey.KEY_M_NOTICE_CNT)));
    //state.setIsPreventiveMainte(Integer.parseInt(items.getItemValue(TelegramKey.KEY_IS_PREVENTIVE)));
    //state.setUseTime(items.getItemValue(TelegramKey.KEY_USE_TIME));
    //state.setMachineStatus(Integer.parseInt(items.getItemValue(TelegramKey.KEY_MACHINE_STATUS)));

    mntMachineStateService.updateTreatmentStatus(state);
    return  true;
  }
// add 治療記録用データと治療状況用データの登録先を振分けにする --趙-- end

  public void registerNotify(MntMotionRecord rcd) throws URISyntaxException, RuntimeException {
    JSONObject replaceData = new JSONObject();

    try {
      // 装置状態管理
      MntMachineState mntMachineState = mntMachineStateService.selectByKey(rcd.getFacilityCd(), rcd.getMachineTypeCd(), rcd.getMachineSerial());

      String patName = "";
      String patIdStr = "";
      String ordNoStr = "";
      // 不明な患者判定
      if (mntMachineState.getPatId() == null || mntMachineState.getOrdNo() == null ) {
        patName = "不明な患者";
      } else {
        PatPersonalMain patPersonalMain = ppmDao.selectById(mntMachineState.getPatId());
        // #9485 mod  患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。2024-05-15 卓 start
        String pat_last_name = patPersonalMain.getPat_last_name() == null?"":patPersonalMain.getPat_last_name();
        String pat_first_name = patPersonalMain.getPat_first_name() == null?"":patPersonalMain.getPat_first_name();
        patName = pat_last_name + " " + pat_first_name;
//        patName = patPersonalMain.getPat_last_name() + " " + patPersonalMain.getPat_first_name();
        // #9485 mod  患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。2024-05-15 卓 end

        patIdStr = mntMachineState.getPatId().toString();
        ordNoStr = mntMachineState.getOrdNo().toString();
      }

      replaceData.put("PATID", patIdStr);
      replaceData.put("NAME", patName);
      replaceData.put("BEDNAME", mntMachineState.getBedName());
      replaceData.put("FACILITYCD", mntMachineState.getFacilityCd());
      replaceData.put("ORDNO", ordNoStr);
      webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.NURSE_CALL, mntMachineState.getFacilityCd(), replaceData);
    } catch (Exception e) {
    }
  }

  //add #269:強制オフライン 劉 start
  /**
   * 強制オフライン装置かどうかチェックします
   * @param mntMachineState   装置状態管理
   * @return
   */
  public boolean checkIsForceOffline(MntMachineState mntMachineState) {
    if (null == mntMachineState) {
      return false;
    }

    return ordMainDao.checkSpecialPurification(mntMachineState.getOrdNo());
  }
  //add #269:強制オフライン 劉 end
}
