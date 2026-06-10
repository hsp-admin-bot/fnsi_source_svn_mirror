package jp.co.nikkiso.ntss.web_api.web.rest;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import javax.validation.Valid;

import jp.co.nikkiso.ntss.api.service.utils.ConditionSendResultUtil;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.web_api.web.rest.util.NextPatInfoUtils;
import jp.co.nikkiso.ntss.web_api.web.rest.util.NextPatInfoUtils.MachineInfo;
import jp.co.nikkiso.ntss.web_api.web.rest.util.NextPatInfoUtils.PROC_RESULT;


@RestController
@RequestMapping("util")
public class NextPatInfoResource {
  @Autowired
  NextPatInfoUtils nextPatInfoUtils;

  @Autowired
  LogService logService;
  /* add #9144 通信不良復帰後の次患者情報 by zhangruixue 2023-07-12 --start */
  @Autowired
  private MntMachineStateDao mntMachineStateDao;
  @Autowired
  private OrdMainDao ordMainDao;
  /* add #9144 by zhangruixue 2023-07-12 --end */
  /**
   * 現患者クリアAPI
   * @param bodydata　JSON形式データ
   *    施設コード   facility_cd
   *    型式コード   machine_type_cd
   *    製造番号    machine_serial
   *    更新日時(形式:yyyy-MM-dd HH:mm:ss)    up_date ※上位で指定する必要がない場合は定義不要(デフォルト:現在日時)
   * @return ResponseEntity(HttpStatusとメッセージ(JSON文字列))
   *    HttpStatus
   *        200:正常終了(警告終了(処理未実施)含む)
   *        400:チェック処理でのエラー
   *        500:上記以外のエラー全般(Validationの結果で生じたエラーなどもこちらに含まれる)
   *    メッセージ(JSON文字列(キー:retMsg))
   *        正常終了時(HttpStatus(200)):空文字
   *        警告終了時(HttpStatus(200)):メッセージ格納
   *        異常終了時(HttpStatus(400、500)):メッセージ格納
   */
  @PostMapping("/CurrentPatClear")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<String> currentPatClear(
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @Valid @RequestBody String bodydata
  )
  {
    // HTTPステータス格納用
    HttpStatus status = HttpStatus.OK;
    // メッセージ格納用
    JSONObject msgJson = new JSONObject("{}");
    String retMsg = null;

    try {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("現患者クリア処理を開始しました:受信データ(bodydata=" + bodydata + ")");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      JSONObject receiveData= new JSONObject(bodydata);
      // パラメータチェック
      if (false == receiveData.has("facility_cd")) {
        eventLogMessage.setLogMessage("例外発生：" + "対象装置情報(facility_cd=null)が異常なため現患者クリア処理を中断しました");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
        //status = HttpStatus.BAD_REQUEST;
        status = HttpStatus.INTERNAL_SERVER_ERROR;
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
        retMsg = "現患者クリア処理を実施できませんでした";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
        return new ResponseEntity<String>(msgJson.toString(), status);
      }
      if (false == receiveData.has("machine_type_cd")) {
        eventLogMessage.setLogMessage("例外発生：" + "対象装置情報(machine_type_cd=null)が異常なため現患者クリア処理を中断しました");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
        //status = HttpStatus.BAD_REQUEST;
        status = HttpStatus.INTERNAL_SERVER_ERROR;
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
        retMsg = "現患者クリア処理を実施できませんでした";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
        return new ResponseEntity<String>(msgJson.toString(), status);
      }
      if (false == receiveData.has("machine_serial")) {
        eventLogMessage.setLogMessage("例外発生：" + "対象装置情報(machine_serial=null)が異常なため現患者クリア処理を中断しました");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
        //status = HttpStatus.BAD_REQUEST;
        status = HttpStatus.INTERNAL_SERVER_ERROR;
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
        retMsg = "現患者クリア処理を実施できませんでした";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
        return new ResponseEntity<String>(msgJson.toString(), status);
      }
      MachineInfo machineInfo = (new NextPatInfoUtils()).new MachineInfo();
      machineInfo.setFacilityCd(receiveData.get("facility_cd").toString());
      machineInfo.setMachineTypeCd(receiveData.get("machine_type_cd").toString());
      machineInfo.setMachineSerial(receiveData.get("machine_serial").toString());
      // 更新日時設定
      LocalDateTime d = LocalDateTime.now();
      Timestamp ts = Timestamp.valueOf(d);
      DateTimeFormatter format = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
      if ((true == receiveData.has("up_date")) && (false == StringUtils.isEmpty(receiveData.get("up_date")))) {
        try
        {
          ts = Timestamp.valueOf(LocalDateTime.parse(receiveData.get("up_date").toString(), format));
        }
        catch(Exception e)
        {
          eventLogMessage.setLogMessage("例外発生：" + "更新日時(up_date=" + receiveData.get("up_date") + ")が異常なため現在日時(" + d.format(format) + ")で処理を実施します");
          eventLogMessage.setFacilityCd(machineInfo.getFacilityCd());
          logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        }
      }
      PROC_RESULT ret = nextPatInfoUtils.currentPatClear(machineInfo, ts);
      if (PROC_RESULT.ERROR == ret) {
        // エラー処理(ログはサブ関数で出力済み)
        status = HttpStatus.INTERNAL_SERVER_ERROR;
        retMsg = "現患者クリア処理に失敗しました";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
      } else if (PROC_RESULT.PARAM_ERR == ret) {
        // パラメータ異常処理(ログはサブ関数で出力済み)
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
        //status = HttpStatus.BAD_REQUEST;
        status = HttpStatus.INTERNAL_SERVER_ERROR;
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
        retMsg = "現患者クリア処理を実施できませんでした";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
      } else if (PROC_RESULT.WARN == ret) {
        // 警告処理(ログはサブ関数で出力済み)
        retMsg = "現患者クリア処理をスキップしました";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
      }
    }
    catch(Exception e)
    {
      // エラー処理
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      retMsg = "現患者クリア処理に失敗しました";
      msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }

    return new ResponseEntity<String>(msgJson.toString(), status);
  }

  /**
   * 次患者更新API
   * @param bodydata　JSON形式データ
   *    施設コード   facility_cd
   *    型式コード   machine_type_cd
   *    製造番号    machine_serial
   *    指示変更有無(形式:boolean(true:指示(スケジュール情報以外)変更あり、false:指示変更なし))   is_ind_change ※上位で指定する必要がない場合は定義不要(デフォルト:false)
   *    検索開始時刻(形式:HHmmss) search_start_time ※上位で指定する必要がない場合は定義不要(デフォルト:"000000")
   *    更新日時(形式:yyyy-MM-dd HH:mm:ss)    up_date ※上位で指定する必要がない場合は定義不要(デフォルト:現在日時)
   * @return ResponseEntity(HttpStatusとメッセージ(JSON文字列))
   *    HttpStatus
   *        200:正常終了(警告終了(処理未実施)含む)
   *        400:チェック処理でのエラー
   *        500:上記以外のエラー全般(Validationの結果で生じたエラーなどもこちらに含まれる)
   *    メッセージ(JSON文字列(キー:retMsg))
   *        正常終了時(HttpStatus(200)):空文字
   *        警告終了時(HttpStatus(200)):メッセージ格納
   *        異常終了時(HttpStatus(400、500)):メッセージ格納
   */
  @PostMapping("/SetNextPatInfo")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<String> setNextPatInfo(
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @Valid @RequestBody String bodydata
  )
  {
    // HTTPステータス格納用
    HttpStatus status = HttpStatus.OK;
    // メッセージ格納用
    JSONObject msgJson = new JSONObject("{}");
    String retMsg = "";
    msgJson.put("retMsg", retMsg);
    String facility_cd = "";
    try {
      JSONObject receiveData= new JSONObject(bodydata);

      if (receiveData.has("facility_cd")) {
        facility_cd = receiveData.get("facility_cd").toString();
      }
      EventLogMessage eventLogMessage = new EventLogMessage();
      if (!StringUtils.isEmpty(facility_cd)) {
        eventLogMessage.setFacilityCd(facility_cd);
        eventLogMessage.setLogMessage("次患者更新処理を開始しました:受信データ(bodydata=" + bodydata + ")");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      }

      // パラメータチェック
      if (false == receiveData.has("facility_cd")) {
//        eventLogMessage.setLogMessage("例外発生：" + "対象装置情報(facility_cd=null)が異常なため次患者更新処理を中断しました");
//        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
        //status = HttpStatus.BAD_REQUEST;
        status = HttpStatus.INTERNAL_SERVER_ERROR;
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
        retMsg = "次患者更新処理を実施できませんでした";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
        return new ResponseEntity<String>(msgJson.toString(), status);
      }
      if (false == receiveData.has("machine_type_cd")) {
        if (!StringUtils.isEmpty(facility_cd)) {
          eventLogMessage.setLogMessage("例外発生：" + "対象装置情報(machine_type_cd=null)が異常なため次患者更新処理を中断しました");
          eventLogMessage.setFacilityCd(facility_cd);
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        }
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
        //status = HttpStatus.BAD_REQUEST;
        status = HttpStatus.INTERNAL_SERVER_ERROR;
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
        retMsg = "次患者更新処理を実施できませんでした";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
        return new ResponseEntity<String>(msgJson.toString(), status);
      }
      if (false == receiveData.has("machine_serial")) {
        if (!StringUtils.isEmpty(facility_cd)) {
          eventLogMessage.setFacilityCd(facility_cd);
          eventLogMessage.setLogMessage("例外発生：" + "対象装置情報(machine_serial=null)が異常なため次患者更新処理を中断しました");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        }
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
        //status = HttpStatus.BAD_REQUEST;
        status = HttpStatus.INTERNAL_SERVER_ERROR;
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
        retMsg = "次患者更新処理を実施できませんでした";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
        return new ResponseEntity<String>(msgJson.toString(), status);
      }
      MachineInfo machineInfo = (new NextPatInfoUtils()).new MachineInfo();
      machineInfo.setFacilityCd(receiveData.get("facility_cd").toString());
      machineInfo.setMachineTypeCd(receiveData.get("machine_type_cd").toString());
      machineInfo.setMachineSerial(receiveData.get("machine_serial").toString());
      // 指示変更有無設定
      boolean isIndChange = false;
      if ((true == receiveData.has("is_ind_change")) && (false == StringUtils.isEmpty(receiveData.get("is_ind_change")))) {
        isIndChange = Boolean.parseBoolean(receiveData.get("is_ind_change").toString());
      }
      // 条件送信済みフラグ
      boolean isSendCondition = false;
      if ((true == receiveData.has("is_send_condition")) && (false == StringUtils.isEmpty(receiveData.get("is_send_condition")))) {
        isSendCondition = Boolean.parseBoolean(receiveData.get("is_send_condition").toString());
      }
      // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 start
      // 条件送信済みオーダー
      Long sendConditionOrdNo = null;
      if (isSendCondition && receiveData.has("send_condition_ord_no") && (!receiveData.get("send_condition_ord_no").toString().isEmpty())) {
        String strOrdNo = receiveData.get("send_condition_ord_no").toString();
        try {
          sendConditionOrdNo = Long.parseLong(strOrdNo);
        } catch (Exception e) {
          e.getStackTrace();
        }
      }
      // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 end
      /* add #9144 通信不良復帰後の次患者情報 by zhangruixue 2023-07-12 --start */
      if(!receiveData.has("is_send_condition") && !isSendCondition){
        MntMachineState mntMachineStateInfo = mntMachineStateDao.selectByKey(receiveData.get("facility_cd").toString(),
          receiveData.get("machine_type_cd").toString(),receiveData.get("machine_serial").toString());
        if(mntMachineStateInfo != null &&
          // #9290 2023.09.13 add null参照例外対応 TDC片口 start
          mntMachineStateInfo.getOrdNo() != null &&
          // #9290 2023.09.13 add null参照例外対応 TDC片口 end
          mntMachineStateInfo.getOrdNo().equals(mntMachineStateInfo.getNextOrdNo())
        ){
          OrdMain ordMain = ordMainDao.selectByOrdNo(mntMachineStateInfo.getOrdNo());
          // #9290 2023.09.13 mod 治療中を考慮 TDC片口 start
          // if(ordMain != null && (ordMain.getRstDialysisState().equals("1") || ordMain.getRstDialysisState().equals("2"))){
          if(ordMain != null && (
              ordMain.getRstDialysisState().equals("1") ||
              ordMain.getRstDialysisState().equals("2") ||
              ordMain.getRstDialysisState().equals("3")
            )
          ){
            isSendCondition = true;
            // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 start
            sendConditionOrdNo = ordMain.getOrdNo();
            // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 end
          }
          // #9290 2023.09.13 mod 治療中を考慮 TDC片口 end
        }
      }
      /* add #9144 by zhangruixue 2023-07-12 --end */
      // 検索開始時刻設定
      String searchStartTime = null;
      if ((true == receiveData.has("search_start_time")) && (false == StringUtils.isEmpty(receiveData.get("search_start_time")))) {
        searchStartTime = receiveData.get("search_start_time").toString();
      }
      // 更新日時設定
      LocalDateTime d = LocalDateTime.now();
      Timestamp ts = Timestamp.valueOf(d);
      DateTimeFormatter format = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
      if ((true == receiveData.has("up_date")) && (false == StringUtils.isEmpty(receiveData.get("up_date")))) {
        try
        {
          ts = Timestamp.valueOf(LocalDateTime.parse(receiveData.get("up_date").toString(), format));
        }
        catch(Exception e)
        {
          eventLogMessage.setLogMessage("例外発生：" + "更新日時(up_date=" + receiveData.get("up_date") + ")が異常なため現在日時(" + d.format(format) + ")で処理を実施します");
          eventLogMessage.setFacilityCd(machineInfo.getFacilityCd());
          logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        }
      }
      // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 start
//      String retInfo = nextPatInfoUtils.setNextPatInfo(machineInfo, isIndChange, searchStartTime, ts, isSendCondition);
      String retInfo = nextPatInfoUtils.setNextPatInfo(machineInfo, isIndChange, searchStartTime, ts, isSendCondition, sendConditionOrdNo);
      // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 end

      JSONObject retObject = new JSONObject(retInfo);
      PROC_RESULT ret = PROC_RESULT.valueOf(retObject.get("PROC_RESULT").toString());
      if (retObject.has("device_edge_order")) {
        msgJson.put("device_edge_order", retObject.get("device_edge_order"));
        msgJson.put("facilityCd", retObject.get("facilityCd"));
        msgJson.put("machineTypeCd", retObject.get("machineTypeCd"));
        msgJson.put("machineSerial", retObject.get("machineSerial"));
      }
      if (PROC_RESULT.ERROR == ret) {
        // エラー処理(ログはサブ関数で出力済み)
        status = HttpStatus.INTERNAL_SERVER_ERROR;
        retMsg = "次患者更新処理に失敗しました";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
      } else if (PROC_RESULT.PARAM_ERR == ret) {
        // パラメータ異常処理(ログはサブ関数で出力済み)
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
        //status = HttpStatus.BAD_REQUEST;
        status = HttpStatus.INTERNAL_SERVER_ERROR;
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
        retMsg = "次患者更新処理を実施できませんでした";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
      } else if (PROC_RESULT.WARN == ret) {
        // 警告処理(ログはサブ関数で出力済み)
        retMsg = "次患者更新処理をスキップしました";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
      }
    }
    catch(Exception e)
    {
      // エラー処理
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      retMsg = "次患者更新処理に失敗しました";
      msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
      if (!StringUtils.isEmpty(facility_cd)) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setFacilityCd(facility_cd);
        eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      }
    }

    return new ResponseEntity<String>(msgJson.toString(), status);
  }
}
