package jp.co.nikkiso.ntss.device_edge.service;

import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.packet.TelegramControl;

@Service
public class SetAlarmList {

  @Autowired
  private LogService logService;
  // モニタ項目最大件数
  private final int MAX_MONITOR_ITEM_COUNT = 150;

  @Autowired
  MntMachineStateService mntMachineStateService;

  public boolean run(String facilityCd, String deviceType, String serialNo, InputStream is) throws Exception {

    String strLogInfo = String.format("facilitycode:%s / devicetype:%s / serialno:%s  ", facilityCd, deviceType,
        serialNo);

    String strList;
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      strList = TelegramControl.convertInputStreamToString(is).trim();
    eventLogMessage.setLogMessage("receive Telegram:" + strList);
    eventLogMessage.setFacilityCd(facilityCd);
	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      if (strList.length() == 0) {
        // 電文なし
        eventLogMessage.setLogMessage(strLogInfo + LogMessage.INFO_TELEGRAM_EMPTY);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return true;
      }

    } catch (IOException e) {
      eventLogMessage.setLogMessage(strLogInfo + LogMessage.ERROR_TELEGRAM_STREAM + ":" + e.getLocalizedMessage());
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    } catch (Exception e) {
      eventLogMessage.setLogMessage(strLogInfo + LogMessage.ERROR_TELEGRAM_STREAM + ":" + e.getLocalizedMessage());
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }

    boolean bret = false;

    // 指定装置の警報・注意発生中リストを取得
    MntMachineState param = mntMachineStateService.selectByKey(facilityCd, deviceType, serialNo);
    if (param != null) {

      // 現在値保持
      String strOldAlarmList = param.getAlarmList();

      //
      //　モニタ項目ごとの警報・注意発生状態をリストに格納
      Map<Integer, Integer> alarm = new HashMap<Integer, Integer>();
      if (strOldAlarmList != null) {
        // 警報・注意発生中情報あり

        ObjectMapper map = new ObjectMapper();
        JsonNode node = map.readTree(strOldAlarmList);

        // モニタ項目判定
        for (int intlop = 1; intlop < MAX_MONITOR_ITEM_COUNT; intlop++) {
          String strkey = Integer.toString(intlop);
          JsonNode item = node.get(strkey);
          if (item != null) {
            // 該当あり

            // 格納
            alarm.put(intlop, Integer.parseInt(item.asText(), 16));
          }
        }
      } else {
        // 警報・注意発生中情報なし

        strOldAlarmList = "";
      }

      // 警報・注意発生中リストを更新
      for (int intlop = 0; intlop < strList.length(); intlop += 6) {
        // モニタ項目番号[3桁]
        String stritemno = strList.substring(intlop, intlop + 3).replaceFirst("^0+", "");
        int nitemno = Integer.parseInt(stritemno);
        // 警報発生状態[HEX：2桁]
        int nnowdata = Integer.parseInt(strList.substring(intlop + 4, intlop + 4 + 2), 16);

        // 該当するモニタ項目の存在チェック
        if (alarm.containsKey(nitemno) == true) {
          // 該当あり

          // 現在の発生状態と結合して再登録
          nnowdata |= alarm.get(nitemno);
          alarm.replace(nitemno, nnowdata);

        } else {
          // 該当なし

          // 新規追加
          alarm.put(nitemno, nnowdata);
        }
      }
      ;

      // モニタ項目順でソート
      Object[] alarmKeys = alarm.keySet().toArray();
      Arrays.sort(alarmKeys);

      //　Json文字列作成
      StringBuilder sbAlarmList = new StringBuilder();
      for (Object nKey : alarmKeys) {
        if (0 < sbAlarmList.length()) {
          sbAlarmList.append(", ");
        }
        sbAlarmList.append(String.format("\"%s\": \"%02x\"", (Integer) nKey, alarm.get(nKey)));
      }
      String strAlarmList = sbAlarmList.toString();
      if (0 < strAlarmList.length()) {
        strAlarmList = "{" + strAlarmList + "}";
      }

      // 変化比較
      if (strOldAlarmList.equals(strAlarmList) == false) {
        // 異なる場合

        //　
        eventLogMessage.setLogMessage(strLogInfo + "Change Alarm List:" + strAlarmList);
        eventLogMessage.setMachineTypeCd(param.getMachineTypeCd());
        eventLogMessage.setMachineType(param.getMachineName());
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        //　警報・注意発生リストを更新
        param.setAlarmList(strAlarmList);
        bret = runUpdateAlarmList(param);
      }
    }

    return bret;
  }

  /**
   * 警報・注意発生中一覧をDB書き込みする処理
   *
   * @param is
   * @return
   */
  public boolean runUpdateAlarmList(MntMachineState param) {

    String strLogInfo = String.format("facilitycode:%s / devicetype:%s / serialno:%s  ", param.getFacilityCd(),
        param.getMachineTypeCd(), param.getMachineSerial());
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setMachineTypeCd(param.getMachineTypeCd());
    eventLogMessage.setMachineType(param.getMachineName());
    try {
      if (mntMachineStateService.updateAlarmList(param.getFacilityCd(), param.getMachineTypeCd(),
          param.getMachineSerial(), param.getAlarmList()) > 0) {
        eventLogMessage.setLogMessage(strLogInfo + LogMessage.SUCCESS_UPDATE_MACHINE_ALARM_LIST);
        eventLogMessage.setFacilityCd(param.getFacilityCd());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return true;
      }
      eventLogMessage.setLogMessage(strLogInfo + LogMessage.WARN_UPDATE_MACHINE_ALARM_LIST);
      eventLogMessage.setFacilityCd(param.getFacilityCd());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(strLogInfo + LogMessage.ERROR_UPDATE_MACHINE_ALARM_LIST);
      eventLogMessage.setFacilityCd(param.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
    }
    return false;
  }
}
