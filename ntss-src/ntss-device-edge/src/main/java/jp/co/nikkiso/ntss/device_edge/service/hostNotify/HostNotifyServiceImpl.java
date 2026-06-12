package jp.co.nikkiso.ntss.device_edge.service.hostNotify;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.FlagType;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.MniMonitorDataType;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.NotificationDefinition;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstDeviceSetInfoDefaultDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.SysMonitorItemDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.SysMonitorItem;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvIntervalNotificationInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.constant.HostNotifyConstant;
import jp.co.nikkiso.ntss.device_edge.constant.HostNotifyConstant.HostNotificationInfoKey;
import jp.co.nikkiso.ntss.device_edge.constant.HostNotifyConstant.SysMonitorItemKey;
import jp.co.nikkiso.ntss.device_edge.request.hostNotify.AlarmNotifyRequest;
import jp.co.nikkiso.ntss.device_edge.request.hostNotify.MedicineNotifyRequest;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.Utility.PatNameInfo;
import jp.co.nikkiso.ntss.device_edge.service.Utility.PatNameUtilityService;
import jp.co.nikkiso.ntss.device_edge.util.DateTimeUtils;
import jp.co.nikkiso.ntss.device_edge.web.rest.util.WebApiCallCommonUtil;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class HostNotifyServiceImpl implements HostNotifyService {

  @Autowired
  private ObjectMapper mapper;

  @Autowired
  private LogService logService;
  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;
  @Autowired
  private PatMainDao patMainDao;
  @Autowired
  private SysMonitorItemDao sysMonitorItemDao;
  @Autowired
  private MntMachineStateDao mntMachineStateDao;
  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  private MstDeviceSetInfoDefaultDao mstDeviceSetIndoDefaultDao;
  @Autowired
  private MniMonitorDao mniMonitorDao;
  @Autowired
  PatNameUtilityService patNameUtilityService;

  /**
   * {@inheritDoc}
   */
  @Override
  public String hostNotifySettingByPat(String facilityCd, Long deviceEdgeNo, Long patId) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setDeviceEdgeNo(deviceEdgeNo.toString());

    List<SysMonitorItem> sysMonitorItem = sysMonitorItemDao.selectAll();

    JSONObject returnObj;
    if (Objects.isNull(patId)) {
      // 装置設定デフォルトのホスト報知設定を返す
      returnObj = buildHostNotifySettingDefault(facilityCd, deviceEdgeNo, sysMonitorItem, eventLogMessage);
    } else {
      // 患者個人ホスト報知設定を返す
      eventLogMessage.setPatId(patId.toString());
      returnObj = buildHostNotifySettingByPat(facilityCd, deviceEdgeNo, patId, sysMonitorItem, eventLogMessage);
    }

    return Objects.isNull(returnObj) ? null : returnObj.toString();
  }

  /**
   * 患者個別のホスト通知設定をDE用JSONに変換する
   * @param facilityCd 施設コード
   * @param deviceEdgeNo DE番号
   * @param patId 患者ID
   * @param sysMonitorItem モニタデータ定義
   * @param eventLogMessage ログ定義
   * @return
   */
  private JSONObject buildHostNotifySettingByPat(String facilityCd, Long deviceEdgeNo, Long patId, List<SysMonitorItem> sysMonitorItem, EventLogMessage eventLogMessage) {

    String setting = "";
    try {
      setting = patMainDao.selectHostNotificationInfo(patId);
      if (Objects.isNull(setting) || setting.isEmpty()) {
        // 設定なし
        eventLogMessage.setLogMessage("患者のホスト報知設定が未設定");
        eventLogMessage.setSqlIdentification("pat_id = " + patId);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "PatMainDao/selectHostNotificationInfo");
        return null;
      }
    } catch (Exception e) {
      eventLogMessage.setLogMessage("ホスト報知設定の取得に失敗:" + e.getMessage());
      eventLogMessage.setSqlIdentification("pat_id = " + patId);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "PatMainDao/selectHostNotificationInfo");
      return null;
    }

    return convertHostNotificationInfoJson(setting, sysMonitorItem, eventLogMessage);
  }

  /**
   * 装置設定デフォルトのホスト通知設定をDE用JSONに変換する
   * @param facilityCd 施設コード
   * @param deviceEdgeNo DE番号
   * @param sysMonitorItem モニタデータ定義
   * @param eventLogMessage ログ定義
   * @return
   */
  private JSONObject buildHostNotifySettingDefault(String facilityCd, Long deviceEdgeNo, List<SysMonitorItem> sysMonitorItem, EventLogMessage eventLogMessage) {

    String setting = "";
    try {
      setting = mstDeviceSetIndoDefaultDao.selectHostNotificationInfo(facilityCd);
      if (Objects.isNull(setting) || setting.isEmpty()) {
        // 設定なし
        eventLogMessage.setLogMessage("施設デフォルトホスト報知設定が未設定");
        eventLogMessage.setSqlIdentification("facility_cd = " + facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "PatMainDao/selectHostNotificationInfo");
        return null;
      }
    } catch (Exception e) {
      eventLogMessage.setLogMessage("施設デフォルトホスト報知設定の取得に失敗:" + e.getMessage());
      eventLogMessage.setSqlIdentification("facility_cd = " + facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "MstDeviceSetIndoDefaultDao/selectHostNotificationInfo");
      return null;
    }

    return convertHostNotificationInfoJson(setting, sysMonitorItem, eventLogMessage);
  }

  /**
   * ホスト通知設定をDE用JSONに変換する
   * @param setting 設定JSON文字列
   * @param sysMonitorItem モニタデータ定義
   * @param eventLogMessage ログ定義
   * @return
   */
  private JSONObject convertHostNotificationInfoJson(String setting, List<SysMonitorItem> sysMonitorItem, EventLogMessage eventLogMessage) {

    JSONObject resJson = new JSONObject();
    try {
      JsonNode jsonNode = mapper.readTree(setting);

      // 最高血圧
      resJson.put(SysMonitorItemKey.BP_MAX,
          buildHostNotificationInfo2ResponseJson(jsonNode, HostNotificationInfoKey.BP_MAX, sysMonitorItem, SysMonitorItemKey.BP_MAX));
      // 最低血圧
      resJson.put(SysMonitorItemKey.BP_MIN,
          buildHostNotificationInfo2ResponseJson(jsonNode, HostNotificationInfoKey.BP_MIN, sysMonitorItem, SysMonitorItemKey.BP_MIN));
      // 最低血圧
      resJson.put(SysMonitorItemKey.BP_AVE,
          buildHostNotificationInfo2ResponseJson(jsonNode, HostNotificationInfoKey.BP_AVE, sysMonitorItem, SysMonitorItemKey.BP_AVE));
      // 脈拍
      resJson.put(SysMonitorItemKey.PULSE,
          buildHostNotificationInfo2ResponseJson(jsonNode, HostNotificationInfoKey.PULSE, sysMonitorItem, SysMonitorItemKey.PULSE));
      // 血流量
      resJson.put(SysMonitorItemKey.BLOOD_FLOW,
          buildHostNotificationInfo2ResponseJson(jsonNode, HostNotificationInfoKey.BLOOD_FLOW, sysMonitorItem, SysMonitorItemKey.BLOOD_FLOW));
      // IP速度
      resJson.put(SysMonitorItemKey.IP_SPEED,
          buildHostNotificationInfo2ResponseJson(jsonNode, HostNotificationInfoKey.IP_SPEED, sysMonitorItem, SysMonitorItemKey.IP_SPEED));
      // 除水速度
      resJson.put(SysMonitorItemKey.UFR,
          buildHostNotificationInfo2ResponseJson(jsonNode, HostNotificationInfoKey.UFR, sysMonitorItem, SysMonitorItemKey.UFR));
      // 静脈圧
      resJson.put(SysMonitorItemKey.VP,
          buildHostNotificationInfo2ResponseJson(jsonNode, HostNotificationInfoKey.VP, sysMonitorItem, SysMonitorItemKey.VP));
      // 動脈圧
      resJson.put(SysMonitorItemKey.AP,
          buildHostNotificationInfo2ResponseJson(jsonNode, HostNotificationInfoKey.AP, sysMonitorItem, SysMonitorItemKey.AP));
      // Na濃度
      resJson.put(SysMonitorItemKey.NA_CONC,
          buildHostNotificationInfo2ResponseJson(jsonNode, HostNotificationInfoKey.NA_CONC, sysMonitorItem, SysMonitorItemKey.NA_CONC));
      // 透析液温度
      resJson.put(SysMonitorItemKey.DIALYS_TEMP,
          buildHostNotificationInfo2ResponseJson(jsonNode, HostNotificationInfoKey.DIALYS_TEMP, sysMonitorItem, SysMonitorItemKey.DIALYS_TEMP));
      // ΔBV変化率
      resJson.put(SysMonitorItemKey.D_BV_ROC,
          buildHostNotificationInfo2ResponseJson(jsonNode, HostNotificationInfoKey.D_BV_ROC, sysMonitorItem, SysMonitorItemKey.D_BV_ROC));
      // LDQb
      resJson.put(SysMonitorItemKey.LDQP,
          buildHostNotificationInfo2ResponseJson(jsonNode, HostNotificationInfoKey.LDQP, sysMonitorItem, SysMonitorItemKey.LDQP));

      return resJson;

    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      eventLogMessage.setLogMessage("ホスト報知設定の解析に失敗:" + setting);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return null;
    }
  }

  /**
   * 患者のホスト報知設定JSONで上下限値判定項目を解析し、DE通知用の設定JSONを構築する
   * (judgeキーのbooleanを 0/1 に変換し、上下限値はモニタデータ定義の小数点桁数を利用し整数化する)
   * @param notificationInfo 患者のホスト報知JSON
   * @param notificationInfoKey 解析するホスト報知JSONの項目キー
   * @param sysMonitorItem モニタデータ定義
   * @param sysMonitorItenKey モニタデータ定義の使用する項目キー
   * @return 変換したJSON
   */
  private JSONObject buildHostNotificationInfo2ResponseJson(
      JsonNode notificationInfo, String notificationInfoKey, List<SysMonitorItem> sysMonitorItem, String sysMonitorItenKey) {

    JSONObject jsonObj = new JSONObject();
    if (notificationInfo.has(notificationInfoKey)
        && notificationInfo.get(notificationInfoKey).has(HostNotificationInfoKey.value.JUDGE)) {

      SysMonitorItem monitorItem = sysMonitorItem.stream()
          .filter(item -> item.getMoniDataNo().equals(sysMonitorItenKey)).findFirst().get();
      JsonNode node = notificationInfo.get(notificationInfoKey);

      // 有効・無効のTrue/Falseを 1/0 にする
      int tf = node.get(HostNotificationInfoKey.value.JUDGE).booleanValue() ? 1 : 0;
      jsonObj.put(HostNotificationInfoKey.value.JUDGE, tf);

      // 最大値を小数点除去する
      JsonNode upperNode = node.get(HostNotificationInfoKey.value.UPPER);
      if (upperNode.isNull()) {
        jsonObj.put(HostNotificationInfoKey.value.UPPER, JSONObject.NULL);
      } else {
        int upper = (int) (upperNode.doubleValue() * Math.pow(10.0, monitorItem.getDecimalFigure()));
        jsonObj.put(HostNotificationInfoKey.value.UPPER, upper);
      }

      // 最小値を小数点除去する
      JsonNode lowerNode = node.get(HostNotificationInfoKey.value.LOWER);
      if (lowerNode.isNull()) {
        jsonObj.put(HostNotificationInfoKey.value.LOWER, JSONObject.NULL);
      } else {
        int lower = (int) (lowerNode.doubleValue() * Math.pow(10.0, monitorItem.getDecimalFigure()));
        jsonObj.put(HostNotificationInfoKey.value.LOWER, lower);
      }
    }
    return jsonObj;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int hostNotifyIntervalCheck(String facilityCd, Integer deviceEdgeNo) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setDeviceEdgeNo(deviceEdgeNo.toString());

    // DE下の装置で治療中の項目から状態と設定を取得
    List<ComsvIntervalNotificationInfo> states = mntMachineStateDao.selectIntervalNotificationInfo(facilityCd, deviceEdgeNo);

    final LocalDateTime now = LocalDateTime.now();
    final int purification = 9;

    int ret=0;
    for (ComsvIntervalNotificationInfo state : states) {
      /* upd by chamaojia 2026-04-13 [11740] 【#11471】特殊浄化判定処理の見直し --start */
      if (Objects.equals(state.getDeviceMode(), purification)
              && Objects.equals(state.getComType(), 0)) {
        // 特殊浄化治療and通信種別がオフライン運用com_type = 0は通知対象外
        continue;
      }
      /* upd by chamaojia 2026-04-13 [11740] 【#11471】特殊浄化判定処理の見直し --end */
      //add FNSI redmine 6228 再修正　劉祥霖　start
      //????患者の場合、ホスト報知しない
      if(Objects.isNull(state.getPatId())){
        continue;
      }
      //add FNSI redmine 6228 再修正　劉祥霖　end
      // 患者名を取得
      PatNameInfo patNames = patNameUtilityService.fetchPatName(state.getPatId());
      // mod bug #6228 修正 chen start
      Integer bpmiResult = 0;
      Integer careResult = 0;
      // 通知メッセージ及び付加情報の変換用JSONデータを作成(値は文字列型)
      JSONObject replaceData = new JSONObject();
      replaceData.put("FACILITYCD", facilityCd);
      replaceData.put("BEDNAME", state.getBedName());
      replaceData.put("ORDNO", state.getOrdNo().toString());
      replaceData.put("PATID", Objects.isNull(state.getPatId()) ? "" : state.getPatId().toString());
      replaceData.put("LASTNAME", patNames.getLastName());
      replaceData.put("FIRSTNAME", patNames.getFirstName());


      bpmiResult = hostNotifyBpmi(facilityCd, state, now, replaceData, eventLogMessage);
      careResult = hostNotifyCare(facilityCd, state, now, replaceData, eventLogMessage);
      // 通知結果保存
      saveNotifyAlarmState(state, bpmiResult, careResult, eventLogMessage);
      // mod bug #6228 修正 chen end
      ret=1;
    }

    return ret;
  }

  /**
   * 血圧未測定間隔のホスト報知
   * @param facilityCd 施設コード
   * @param state 通知用装置状態
   * @param now
   * @param replaceData 報知内容
   * @param eventLogMessage ログ要素
   */
  private Integer hostNotifyBpmi(
      String facilityCd, ComsvIntervalNotificationInfo state, LocalDateTime now, JSONObject replaceData, EventLogMessage eventLogMessage) {

    // 設定を取得
    Integer interval = getIntervalValue(state.getHostNotificationInfo(), HostNotificationInfoKey.BPMI, eventLogMessage);
    if (Objects.isNull(interval)) {
      // 設定無効
      eventLogMessage.setLogMessage("血圧未測定間隔の監視なし pat_id = " + state.getPatId());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return null;
    }

    // 通知状態
    Integer notifyState = getNotifyAlarmState(state.getAlarmList(), HostNotificationInfoKey.BPMI, eventLogMessage);
    // 最終測定日時
    LocalDateTime lastOccur = null;

    // 透析中血圧のモニタデータを取得
    // # 10373 Add a parameter to improve performance. Added by Zhou.tao
//    MniMonitor monitor = mniMonitorDao.selectByOrdNoDataTypeLast(state.getOrdNo(), MniMonitorDataType.MONITOR_DATA_TYPE_DIALYSIS_BP);
    MniMonitor monitor = mniMonitorDao.selectByOrdNoDataTypeLast(
      facilityCd
      , state.getOrdNo()
      , MniMonitorDataType.MONITOR_DATA_TYPE_DIALYSIS_BP);

    if (Objects.isNull(monitor)) {
      // 血圧測定履歴なし
      if (Objects.isNull(state.getRstStartDate())) {
        eventLogMessage.setLogMessage("血圧未測定間隔の基準日時を取得できませんでした pat_id = " + state.getPatId());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return null;
      }
      // 治療開始日時を使用する
      lastOccur = state.getRstStartDate().toLocalDateTime();
    } else {
      // 血圧測定履歴あり
      lastOccur = monitor.getOccurDate().toLocalDateTime();
    }

    // 通知結果格納用変数
    Integer resultStatus = 0;
    if (now.isAfter(lastOccur.plusMinutes(interval.longValue()))) {
      // 指定時間経過している場合

      if (Objects.equals(notifyState, 1)) {
        // 通知済み
        resultStatus = 1;
      } else {
        // 未通知なので通知する
        replaceData.put("CONTENTS", "前回血圧測定から指定時間経過しています");
        try {
          ResponseEntity<String> res = webApiCallCommonUtil.registerNotification(NotificationDefinition.HOST_NOTIFY, facilityCd, replaceData);

          if (Objects.equals(res.getStatusCode(), HttpStatus.OK)) {
            resultStatus = 1;
          } else {
            eventLogMessage.setLogMessage(res.getBody());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return null;
          }
        } catch (Exception e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          EventLogMessage eventLogMessageNew = new EventLogMessage();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
          eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
          if (facilityCd != null) {
            eventLogMessageNew.setFacilityCd(facilityCd);
          }
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessageNew, null, SERVICE_NAME.FNSI, null);
          return null;
        }
      }
    }

    // 通知結果が変化していた場合は保存
    if (!Objects.equals(notifyState, resultStatus)) {
      return resultStatus;
    }
    return null;
  }

  /**
   * ケア未実施間隔のホスト報知
   * @param facilityCd 施設コード
   * @param state 通知用装置状態
   * @param now
   * @param replaceData 報知内容
   * @param eventLogMessage ログ要素
   */
  private Integer hostNotifyCare(
      String facilityCd, ComsvIntervalNotificationInfo state, LocalDateTime now, JSONObject replaceData, EventLogMessage eventLogMessage) {

    // 設定を取得
    Integer interval = getIntervalValue(state.getHostNotificationInfo(), HostNotificationInfoKey.CARE_I, eventLogMessage);
    if (Objects.isNull(interval)) {
      // 設定無効
      eventLogMessage.setLogMessage("ケア未実施間隔の監視なし pat_id = " + state.getPatId());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return null;
    }
    // 通知状態
    Integer notifyState = getNotifyAlarmState(state.getAlarmList(), HostNotificationInfoKey.CARE_I, eventLogMessage);

    // 最終測定日時
    if (Objects.isNull(state.getRstStartDate())) {
      eventLogMessage.setLogMessage("ケア未実施間隔の基準日時を取得できませんでした pat_id = " + state.getPatId());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return null;
    }
    // 治療開始日時を使用する
    LocalDateTime baseDateTime = state.getRstStartDate().toLocalDateTime();

    // 投薬情報
    String strMediInfo = state.getRstMediInfo();
    // 愁訴情報
    String strCompInfo = state.getRstComplaintInfo();
    // 愁訴処置情報
    String strTreatInfo = state.getRstTreatmentInfo();
    // 処置者
    String strTreatStaffInfo = state.getRstTreatStaffInfo();

    LocalDateTime lastOccur = findLastOccurDate(baseDateTime, strMediInfo, strCompInfo, strTreatInfo, strTreatStaffInfo, eventLogMessage);

    // 通知結果格納用変数
    Integer resultStatus = 0;
    if (now.isAfter(lastOccur.plusMinutes(interval.longValue()))) {
      // 指定時間経過している場合

      if (Objects.equals(notifyState, 1)) {
        // 通知済み
        resultStatus = 1;
      } else {
        // 未通知なので通知する
        replaceData.put("CONTENTS", "前回ケアから指定時間経過しています");
        try {
          ResponseEntity<String> res = webApiCallCommonUtil.registerNotification(NotificationDefinition.HOST_NOTIFY, facilityCd, replaceData);

          if (Objects.equals(res.getStatusCode(), HttpStatus.OK)) {
            resultStatus = 1;
          } else {
            eventLogMessage.setLogMessage(res.getBody());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return null;
          }
        } catch (Exception e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          return null;
        }
      }
    }

    // 通知結果が変化していた場合は保存
    if (!Objects.equals(notifyState, resultStatus)) {
      return resultStatus;
    }
    return null;
  }

  /**
   * 最終のケア時刻を取得
   * @param strMediInfo 投薬実績
   * @param strCompInfo 愁訴実績
   * @param strTreatInfo 愁訴処置実績
   * @param strTreatStaffInfo 処置者実績
   * @return
   */
  private LocalDateTime findLastOccurDate(
      LocalDateTime baseDateTime, String strMediInfo, String strCompInfo, String strTreatInfo, String strTreatStaffInfo, EventLogMessage eventLogMessage) {

    LocalDateTime ldt = baseDateTime;

    if (!Objects.isNull(strMediInfo)) {
      // 投薬日時確認
      JsonNode jsonNode;
      try {
        jsonNode = mapper.readTree(strMediInfo);
        for (JsonNode node : jsonNode) {
          if (!node.has("effect_flg") || node.get("effect_flg").isNull()) {
            // 未投薬
            continue;
          }
          JsonNode effectFlg = node.get("effect_flg");
          if (effectFlg.isInt() && !Objects.equals(effectFlg.intValue(), 1)) {
            // 未投薬(投薬済みフラグが数値)
            continue;
          }
          if (effectFlg.isTextual() && !FlagType.FLAG_ON.equals(node.get("effect_flg").textValue())) {
            // 未投薬(投薬済みフラグがテキスト)
            continue;
          }
          JsonNode dateNode = node.get("effect_date");
          LocalDateTime occurDate = DateTimeUtils.convertLocalDateTimeIso8601(dateNode.textValue());
          if (Objects.isNull(occurDate)) {
            // 投薬日時異常
            continue;
          }
          if (ldt.isBefore(occurDate)) {
            ldt = occurDate;
          }
        }
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }

    // 愁訴日時確認
    ldt = getLastOccurDateFromJsonArray(strCompInfo, ldt, eventLogMessage);
    // 愁訴処置日時確認
    ldt = getLastOccurDateFromJsonArray(strTreatInfo, ldt, eventLogMessage);
    // 処置者日時確認
    ldt = getLastOccurDateFromJsonArray(strTreatStaffInfo, ldt, eventLogMessage);

    return ldt;

  }

  /**
   * JSON 配列の中から最新の"occur_date"を取得する
   * @param jsonStr JSON文字列
   * @param baseLdt 比較する基準日付
   * @param eventLogMessage ログ要素
   * @return 最新の日付
   */
  private LocalDateTime getLastOccurDateFromJsonArray(String jsonStr, LocalDateTime baseLdt, EventLogMessage eventLogMessage) {

    LocalDateTime ldt = baseLdt;
    if (!Objects.isNull(jsonStr)) {
      JsonNode jsonNode;
      try {
        jsonNode = mapper.readTree(jsonStr);
        for (JsonNode node : jsonNode) {
          if (!node.has("occur_date") || node.get("occur_date").isNull()) {
            // 日時未入力
            continue;
          }
          JsonNode dateNode = node.get("occur_date");
          LocalDateTime occurDate = DateTimeUtils.convertLocalDateTimeIso8601(dateNode.textValue());
          if (Objects.isNull(occurDate)) {
            // 日時異常
            continue;
          }
          if (ldt.isBefore(occurDate)) {
            ldt = occurDate;
          }
        }
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }
    return ldt;
  }

  /**
   * ホスト報知設定JSON文字列からIntervalの値を取得
   * @param notifySetting 設定JSON文字列
   * @param notificationInfoKey 指定キー（血圧未測定間隔かケア未実施間隔）
   * @param eventLogMessage ログ要素
   * @return
   */
  private Integer getIntervalValue(String notifySetting, String notificationInfoKey, EventLogMessage eventLogMessage) {
    try {
      JsonNode jsonNode = mapper.readTree(notifySetting);
      if (jsonNode.has(notificationInfoKey) && jsonNode.get(notificationInfoKey).has(HostNotificationInfoKey.value.JUDGE)) {
        JsonNode node = jsonNode.get(notificationInfoKey);

        // 有効・無効を判定
        if (!node.get(HostNotificationInfoKey.value.JUDGE).booleanValue()) {
          // 無効
          eventLogMessage.setLogMessage("ホスト報知設定で" + notificationInfoKey + "の監視が無効");
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          return null;
        }

        // 設定値取得
        JsonNode intervalNode = node.get(HostNotificationInfoKey.value.INTERVAL);
        if (intervalNode.isNull()) {
          // 無効
          eventLogMessage.setLogMessage("ホスト報知設定で" + notificationInfoKey + "の監視間隔がnull");
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          return null;
        } else {
          return intervalNode.intValue();
        }
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      eventLogMessage.setLogMessage("ホスト報知設定の解析に失敗:" + notifySetting);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return null;
    }
    eventLogMessage.setLogMessage("ホスト報知設定の解析に失敗:" + notifySetting);
    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return null;
  }

  /**
   * 装置ごとの報知状態を取得
   * @param alarmList 報知状態JSON
   * @param notificationInfoKey 指定キー（血圧未測定間隔かケア未実施間隔）
   * @param eventLogMessage ログ要素
   * @return
   */
  private Integer getNotifyAlarmState(String alarmList, String notificationInfoKey, EventLogMessage eventLogMessage) {
    if (!Objects.isNull(alarmList)) {
      try {
        JsonNode node = mapper.readTree(alarmList);
        if (node.has(notificationInfoKey)) {
          return node.get(notificationInfoKey).intValue();
        }
      } catch (tools.jackson.core.JacksonException e1) {
        eventLogMessage.setLogMessage("報知状態の解析に失敗:" + alarmList);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }
    return null;
  }

  /**
   * 通知状態を保存
   * @param state 保存先レコード
   * @param notificationInfoKey 指定キー（血圧未測定間隔かケア未実施間隔）
   * @param resultStatus 更新値
   * @param eventLogMessage ログ要素
   */
  private void saveNotifyAlarmState(
      ComsvIntervalNotificationInfo state, Integer bpmiResultStatus, Integer careResultStatus, EventLogMessage eventLogMessage) {

    if (Objects.isNull(bpmiResultStatus) && Objects.isNull(careResultStatus)) {
      // どちらもnullならば更新しない
      return;
    }

    String alarmList = state.getAlarmList();
    JSONObject objAlarmList = new JSONObject();

    // 更新前値取得
    Integer bpmiBaseValue = getNotifyAlarmState(alarmList, HostNotificationInfoKey.BPMI, eventLogMessage);
    Integer careBaseValue = getNotifyAlarmState(alarmList, HostNotificationInfoKey.CARE_I, eventLogMessage);

    if (!Objects.isNull(bpmiBaseValue)) {
      objAlarmList.put(HostNotificationInfoKey.BPMI, bpmiBaseValue);
    }
    if (!Objects.isNull(careBaseValue)) {
      objAlarmList.put(HostNotificationInfoKey.CARE_I, careBaseValue);
    }

    // 値更新
    if (!Objects.isNull(bpmiResultStatus)) {
      objAlarmList.put(HostNotificationInfoKey.BPMI, bpmiResultStatus);
    }
    if (!Objects.isNull(careResultStatus)) {
      objAlarmList.put(HostNotificationInfoKey.CARE_I, careResultStatus);
    }

    // 保存処理
    mntMachineStateDao.updateAlarmList(state.getFacilityCd(), state.getMachineTypeCd(), state.getMachineSerial(),
        objAlarmList.toString());

  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int MedicineTymingNotify(MedicineNotifyRequest param) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(param.getFacilityCd());
    eventLogMessage.setDeviceEdgeNo(param.getDeviceEdgeNo().toString());
    eventLogMessage.setMachineTypeCd(param.getMachineTypeCd());
    eventLogMessage.setPatId(Objects.isNull(param.getPatId()) ? null : param.getPatId().toString());

    // 対象の装置状態を取得
    MntMachineState state = mntMachineStateDao.selectByKey(param.getFacilityCd(), param.getMachineTypeCd(), param.getMachineSerial());
    if (Objects.isNull(state)) {
      // 装置取得失敗
      eventLogMessage.setLogMessage("装置状態取得失敗");
      eventLogMessage.setSqlIdentification(
          "facility_cd = " + param.getFacilityCd() + ", machine_type_cd = " + param.getMachineTypeCd() + ", machine_serial = " + param.getMachineSerial());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "MntMachineStateDao/selectByKey");

      return -1;
    }

    // 患者名を取得
    PatNameInfo patNames = patNameUtilityService.fetchPatName(param.getPatId());

    // 通知メッセージ及び付加情報の変換用JSONデータを作成(値は文字列型)
    JSONObject replaceData = new JSONObject();
    replaceData.put("FACILITYCD", param.getFacilityCd());
    replaceData.put("BEDNAME", state.getBedName());
    replaceData.put("ORDNO", Objects.isNull(param.getOrdNo()) ? "" : param.getOrdNo().toString());
    replaceData.put("PATID", Objects.isNull(param.getPatId()) ? "" : param.getPatId().toString());
    replaceData.put("LASTNAME", patNames.getLastName());
    replaceData.put("FIRSTNAME", patNames.getFirstName());
    replaceData.put("MEDICINENAME", param.getMedicineName());

    try {
      ResponseEntity<String> res = webApiCallCommonUtil.registerNotification(NotificationDefinition.MEDICINE_TYMING, param.getFacilityCd(), replaceData);

      if (Objects.equals(res.getStatusCode(), HttpStatus.OK)) {
        return 1;
      } else {
        eventLogMessage.setLogMessage(res.getBody());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (param != null && param.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(param.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    return 0;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int hostNotify(AlarmNotifyRequest param) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(param.getFacilityCd());
    eventLogMessage.setDeviceEdgeNo(param.getDeviceEdgeNo().toString());
    eventLogMessage.setMachineTypeCd(param.getMachineTypeCd());

    // 対象の装置状態を取得
    MntMachineState state = mntMachineStateDao.selectByKey(param.getFacilityCd(), param.getMachineTypeCd(), param.getMachineSerial());
    if (Objects.isNull(state)) {
      // 装置取得失敗
      eventLogMessage.setLogMessage("装置状態取得失敗");
      eventLogMessage.setSqlIdentification(
          "facility_cd = " + param.getFacilityCd() + ", machine_type_cd = " + param.getMachineTypeCd() + ", machine_serial = " + param.getMachineSerial());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "MntMachineStateDao/selectByKey");

      return -1;
    }
    // オーダー番号から患者IDを取得
    Long ordNo = state.getOrdNo();
    Long patId = null;
    if (!Objects.isNull(ordNo)) {
      OrdMain ord = ordMainDao.selectByOrdNo(ordNo);
      if (!Objects.isNull(ord)) {
        patId = ord.getPatId();
        //add FNSI redmine 6228 劉祥霖 start
        if(Objects.isNull(patId)){
          return 0;
        }
        //add FNSI redmine 6228 劉祥霖 end
      }
    }

    // 患者名を取得
    PatNameInfo patNames = patNameUtilityService.fetchPatName(patId);

    // 通知メッセージ及び付加情報の変換用JSONデータを作成(値は文字列型)
    JSONObject replaceData = new JSONObject();
    replaceData.put("FACILITYCD", param.getFacilityCd());
    replaceData.put("BEDNAME", state.getBedName());
    replaceData.put("ORDNO", Objects.isNull(ordNo) ? "" : ordNo.toString());
    replaceData.put("PATID", Objects.isNull(patId) ? "" : patId.toString());
    replaceData.put("LASTNAME", patNames.getLastName());
    replaceData.put("FIRSTNAME", patNames.getFirstName());

    // 通知登録
    return hostNotifyRegistration(param.getContent(), param.getFacilityCd(), replaceData, eventLogMessage);
  }

  /**
   * ホスト報知実行
   * @param content 報知定義電文
   * @param facilityCd 施設コード
   * @param replaceData 通知付加情報JSON
   * @param eventLogMessage ログメッセージインスタンス
   * @return
   */
  private int hostNotifyRegistration(String content, String facilityCd, JSONObject replaceData, EventLogMessage eventLogMessage) {

    // content 報知定義電文 固定長文字列 モニタ番号[3桁]:通知状態[16進2桁]モニタ番号[3桁]:通知状態[16進2桁]...
    // ※通知状態は 0x01：下限通知、0x02：上限通知 の組み合わせ

    int notifyCount = 0;
    for (int intlop = 0; intlop < content.length(); intlop += 6) {
      // モニタ項目番号[3桁]
      String strItemNo = content.substring(intlop, intlop + 3).replaceFirst("^0+", "");
      // 警報発生状態[HEX：2桁]
      int hostNotifyData = Integer.parseInt(content.substring(intlop + 4, intlop + 4 + 2), 16);
      // ホスト報知項目名
      String itemName = HostNotifyConstant.getHostNotifyItemName(strItemNo);

      if ((hostNotifyData & 0x01) == 0x01) {
        // 下限通知
        replaceData.put("CONTENTS", itemName + "下限を下回りました");
        try {
          ResponseEntity<String> res = webApiCallCommonUtil.registerNotification(NotificationDefinition.HOST_NOTIFY, facilityCd, replaceData);
          if (Objects.equals(res.getStatusCode(), HttpStatus.OK)) {
            notifyCount++;
          } else {
            eventLogMessage.setLogMessage(res.getBody());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          }
        } catch (Exception e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (facilityCd != null) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }
      }

      // NOTE: 0x03で両方通知するケースを許容するため else にしない

      if ((hostNotifyData & 0x02) == 0x02) {
        // 上限通知
        replaceData.put("CONTENTS", itemName + "上限を超えました");
        try {
          ResponseEntity<String> res = webApiCallCommonUtil.registerNotification(NotificationDefinition.HOST_NOTIFY, facilityCd, replaceData);
          if (Objects.equals(res.getStatusCode(), HttpStatus.OK)) {
            notifyCount++;
          } else {
            eventLogMessage.setLogMessage(res.getBody());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          }
        } catch (Exception e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }
      }

    }
    return notifyCount;
  }
}
