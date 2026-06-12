package jp.co.nikkiso.ntss.web_api.web.rest;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import jakarta.validation.Valid;

import jp.co.nikkiso.ntss.api.service.utils.ConditionSendResultUtil;
import org.json.JSONArray;
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
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.web_api.web.rest.util.DummyScheduleUtils;
import jp.co.nikkiso.ntss.web_api.web.rest.util.DummyScheduleUtils.PROC_MODE;
import jp.co.nikkiso.ntss.web_api.web.rest.util.DummyScheduleUtils.PROC_RESULT;


@RestController
@RequestMapping("util")
public class ScheduleInfoResource {
  @Autowired
  DummyScheduleUtils dummyScheduleUtils;

  @Autowired
  LogService logService;
  /**
   * ベッド空き状況確認API
   * @param bodydata　JSON形式データ
   *    検索施設コード facility_cd
   *    検索対象外治療予定リスト(ベッド割り当て予定(処理対象のクール、曜日、期間(開始日、終了日)を加味した)オーダ番号リスト) ord_no_list
   *    検索対象外患者ID(ベッド割り当て予定の患者ID) pat_id
   *    検索ベッドコード bed_cd
   *    検索開始日(形式:yyyyMMdd) search_start_date
   *    検索開始クール search_start_kur_cd
   *    治療日移動フラグ(true:移動あり、false:移動なし) is_move_treat_date ※上位で指定する必要がない場合は定義不要(デフォルト:false)
   * @return ResponseEntity(HttpStatusと検索にヒットしたスケジュールのリスト)
   *    HttpStatus
   *        200:正常終了
   *        400:チェック処理でのエラー
   *        500:上記以外のエラー全般(Validationの結果で生じたエラーなどもこちらに含まれる)
   *    検索にヒットしたスケジュールのリスト
   *        正常終了時(HttpStatus(200)):検索にヒットしたスケジュールのリスト
   *        異常終了時(HttpStatus(400、500)):null
   */
  @PostMapping("/selectForSearchReservedBed")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<List<OrdSchedule>> selectForSearchReservedBed(
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @Valid @RequestBody String bodydata
  )
  {
      List<OrdSchedule> listRet = null;
      try {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("空きベッド検索処理を開始しました:受信データ(bodydata=" + bodydata + ")");
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          JSONObject receiveData= new JSONObject(bodydata);
          // パラメータチェック
          String strParam = null;
          // 施設コード取得
          String facilityCd = null;
          if (false == receiveData.has("facility_cd")) {
              eventLogMessage.setLogMessage("例外発生：" + "空きベッド検索のパラメータ(facility_cd=null)が異常なため空きベッド検索処理を中断しました");
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
              return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
          }
          facilityCd = receiveData.get("facility_cd").toString();
          // オーダ番号リスト取得
          List<Long> ordNoList = null;
          if (false == receiveData.has("ord_no_list")) {
            eventLogMessage.setLogMessage("例外発生：" + "空きベッド検索のパラメータ(ord_no_list=null)が異常なため空きベッド検索処理を中断しました");
            eventLogMessage.setFacilityCd(facilityCd);
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
            return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
          }
          else
          {
            JSONArray list = null;
            try {
              list = new JSONArray(receiveData.get("ord_no_list").toString());
            } catch (Exception e) {
              eventLogMessage.setLogMessage("例外発生：" +  "空きベッド検索のパラメータ(ord_no_list=" + receiveData.get("ord_no_list").toString() + ")が異常なため空きベッド検索処理を中断しました");
              eventLogMessage.setFacilityCd(facilityCd);
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
              return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
            }
            ordNoList = new ArrayList<Long>();
            if (0 < list.length()) {
              for (int i = 0; i < list.length(); i++) {
                if (false == list.get(i).toString().matches("^[0-9]+$")) {
                    eventLogMessage.setLogMessage("例外発生：" +  "空きベッド検索のパラメータ(ord_no_list=" + receiveData.get("ord_no_list").toString() + ")が異常なため空きベッド検索処理を中断しました");
                    eventLogMessage.setFacilityCd(facilityCd);
                    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
                    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
                }
                ordNoList.add(Long.parseLong(list.get(i).toString()));
              }
            }
          }
          // 患者ID取得
          Long patId = null;
          if ((false == receiveData.has("pat_id")) || (false == receiveData.get("pat_id").toString().matches("^[0-9]+$"))) {
              if (true == receiveData.has("pat_id")) strParam = receiveData.get("pat_id").toString();
              eventLogMessage.setLogMessage("例外発生：" +  "空きベッド検索のパラメータ(pat_id=" + strParam + ")が異常なため空きベッド検索処理を中断しました");
              eventLogMessage.setFacilityCd(facilityCd);
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
              return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
          }
          patId = Long.parseLong (receiveData.get("pat_id").toString());
          // ベッドコード取得
          Long bedCd = null;
          if ((false == receiveData.has("bed_cd")) || (false == receiveData.get("bed_cd").toString().matches("^[0-9]+$"))) {
              if (true == receiveData.has("bed_cd")) strParam = receiveData.get("bed_cd").toString();
                  eventLogMessage.setLogMessage("例外発生：" +  "空きベッド検索のパラメータ(bed_cd=" + strParam + ")が異常なため空きベッド検索処理を中断しました");
                  eventLogMessage.setFacilityCd(facilityCd);
                  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
                  return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
              }
              bedCd = Long.parseLong (receiveData.get("bed_cd").toString());
          // 検索開始日取得
          String searchStartDate = null;
          if (false == receiveData.has("search_start_date")) {
            eventLogMessage.setLogMessage("例外発生：" +  "空きベッド検索のパラメータ(search_start_date=null)が異常なため空きベッド検索処理を中断しました");
            eventLogMessage.setFacilityCd(facilityCd);
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
            return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
          }
          searchStartDate = receiveData.get("search_start_date").toString();
          // 検索開始クール取得
          Long searchStartKurCd = null;
          if ((false == receiveData.has("search_start_kur_cd")) || (false == receiveData.get("search_start_kur_cd").toString().matches("^[0-9]+$"))) {
              if (true == receiveData.has("search_start_kur_cd")) strParam = receiveData.get("search_start_kur_cd").toString();
              eventLogMessage.setLogMessage("例外発生：" +  "空きベッド検索のパラメータ(search_start_kur_cd=" + strParam + ")が異常なため空きベッド検索処理を中断しました");
              eventLogMessage.setFacilityCd(facilityCd);
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
              return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
          }
          searchStartKurCd = Long.parseLong(receiveData.get("search_start_kur_cd").toString());
          // 治療日移動フラグ取得
          Boolean isMoveTreatDate = false;
          if (true == receiveData.has("is_move_treat_date")) {
              isMoveTreatDate = Boolean.valueOf(receiveData.get("is_move_treat_date").toString());
          }

          // ベッド空き状況確認実施
          listRet = dummyScheduleUtils.selectForSearchReservedBed(facilityCd, ordNoList, patId, bedCd, searchStartDate, searchStartKurCd, isMoveTreatDate);
          // 戻り値チェック
          if (null == listRet) {
              // エラー処理(ログはサブ関数で出力済み)
              return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.INTERNAL_SERVER_ERROR);
          }
      }
      catch(Exception e)
      {
          // エラー処理
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("例外発生：" +  e.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.INTERNAL_SERVER_ERROR);
      }

      return new ResponseEntity<>(listRet, HttpStatus.OK);
  }

  /**
   * ダミースケジュール操作API
   * @param bodydata　JSON形式データ
   *    メインスケジュールのオーダ番号リスト   ord_no_list
   *    操作モード   ope_mode(形式:int(1:作成、2:削除、3:再作成(削除+作成)))
   *    登録処理対象ベッドコード bed_cd ※登録処理対象のベッドコードを指定したい場合に使用(未使用の場合は定義不要)
   *    登録処理対象クールコード kur_cd ※登録処理対象のクールコードを指定したい場合に使用(未使用の場合は定義不要)
   *    更新日時(形式:yyyy-MM-dd HH:mm:ss) up_date ※上位で指定する必要がない場合は定義不要(デフォルト:現在日時)
   * @return ResponseEntity(HttpStatusとメッセージ(JSON文字列))
   *    HttpStatus
   *        200:正常終了
   *        400:チェック処理でのエラー
   *        500:上記以外のエラー全般(Validationの結果で生じたエラーなどもこちらに含まれる)
   *    メッセージ(JSON文字列(キー:retMsg))
   *        正常終了時(HttpStatus(200)):空文字
   *        異常終了時(HttpStatus(400、500)):メッセージ格納
   */
  @PostMapping("/OpeDummySchedule")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<String> opeDummySchedule(
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
      eventLogMessage.setLogMessage("ダミースケジュール操作処理を開始しました:受信データ(bodydata=" + bodydata + ")");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      JSONObject receiveData= new JSONObject(bodydata);
      // パラメータチェック
      // メインスケジュールのオーダ番号リスト取得
      if (false == receiveData.has("ord_no_list")) {
        eventLogMessage.setLogMessage("例外発生：" + "ダミースケジュール操作のパラメータ(ord_no_list=null)が異常なためダミースケジュール操作処理を中断しました");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        status = HttpStatus.BAD_REQUEST;
        retMsg = "ダミースケジュール操作処理を実施できませんでした";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg);
        return new ResponseEntity<String>(msgJson.toString(), status);
      }
      JSONArray list = null;
      try {
        list = new JSONArray(receiveData.get("ord_no_list").toString());
      } catch (Exception e) {
        eventLogMessage.setLogMessage("例外発生：" + "ダミースケジュール操作のパラメータ(ord_no_list=" + receiveData.get("ord_no_list").toString() + ")が異常なためダミースケジュール操作処理を中断しました");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        status = HttpStatus.BAD_REQUEST;
        retMsg = "ダミースケジュール操作処理を実施できませんでした";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg);
        return new ResponseEntity<String>(msgJson.toString(), status);
      }
      List<Long> ordNoList = null;
      ordNoList = new ArrayList<Long>();
      if (0 < list.length()) {
        for (int i = 0; i < list.length(); i++) {
          if (false == list.get(i).toString().matches("^[0-9]+$")) {
              eventLogMessage.setLogMessage("例外発生：" + "ダミースケジュール操作のパラメータ(ord_no_list=" + receiveData.get("ord_no_list").toString() + ")が異常なためダミースケジュール操作処理を中断しました");
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
              status = HttpStatus.BAD_REQUEST;
              retMsg = "ダミースケジュール操作処理を実施できませんでした";
              msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg);
              return new ResponseEntity<String>(msgJson.toString(), status);
          }
          ordNoList.add(Long.parseLong(list.get(i).toString()));
        }
      }
      // 操作モード取得
      PROC_MODE opeMode = null;
      if ((false == receiveData.has("ope_mode")) || (false == PROC_MODE.isHas(receiveData.get("ope_mode").toString()))) {
        String strParam = null;
        if (true == receiveData.has("ope_mode")) strParam = receiveData.get("ope_mode").toString();
        eventLogMessage.setLogMessage("例外発生：" + "ダミースケジュール操作のパラメータ(ope_mode=" + strParam + ")が異常なためダミースケジュール操作処理を中断しました");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        status = HttpStatus.BAD_REQUEST;
        retMsg = "ダミースケジュール操作処理を実施できませんでした";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg);
        return new ResponseEntity<String>(msgJson.toString(), status);
      }
      opeMode = PROC_MODE.getProcMode(receiveData.get("ope_mode").toString());
      // 登録処理対象ベッドコード設定
      Long searchBedCd = null;
      if (true == receiveData.has("bed_cd")) {
        if (false == receiveData.get("bed_cd").toString().matches("^[0-9]+$")) {
          eventLogMessage.setLogMessage("例外発生：" + "ダミースケジュール操作のパラメータ(bed_cd=" + receiveData.get("bed_cd").toString() + ")が異常なためダミースケジュール操作処理を中断しました");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          status = HttpStatus.BAD_REQUEST;
          retMsg = "ダミースケジュール操作処理を実施できませんでした";
          msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg);
          return new ResponseEntity<String>(msgJson.toString(), status);
        }
        searchBedCd = Long.parseLong(receiveData.get("bed_cd").toString());
      }
      // 登録処理対象クールコード設定
      Long searchStartKurCd = null;
      if (true == receiveData.has("kur_cd")) {
        if (false == receiveData.get("kur_cd").toString().matches("^[0-9]+$")) {
          eventLogMessage.setLogMessage("例外発生：" + "ダミースケジュール操作のパラメータ(kur_cd=" + receiveData.get("kur_cd").toString() + ")が異常なためダミースケジュール操作処理を中断しました");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          status = HttpStatus.BAD_REQUEST;
          retMsg = "ダミースケジュール操作処理を実施できませんでした";
          msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg);
          return new ResponseEntity<String>(msgJson.toString(), status);
        }
        searchStartKurCd = Long.parseLong(receiveData.get("kur_cd").toString());
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
          logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        }
      }

      // ダミースケジュール操作実施
      PROC_RESULT ret = PROC_RESULT.SUCCESS;
      /*mod #8494 by zhangruixue 2023-03-28  GC overhead limit exceeded start*/
      switch (opeMode) {
        /** 作成 */
        case CREATE:
          List<List<Long>> splitCreatList = this.splitList(ordNoList,1000);
          if(splitCreatList.size() > 0){
            for(List<Long> paramList : splitCreatList){
              ret = dummyScheduleUtils.createDummySchedule(paramList, searchBedCd, searchStartKurCd, ts);
            }
          }
          break;
        /** 削除 */
        case DELETE:
          List<List<Long>> splitDeleteList = this.splitList(ordNoList,1000);
          if(splitDeleteList.size() > 0){
            for(List<Long> paramList : splitDeleteList){
              ret = dummyScheduleUtils.deleteDummySchedule(paramList);
            }
          }
          break;
        /** 削除+作成 */
        case DELETE_AND_CREATE:
          List<List<Long>> splitList = this.splitList(ordNoList,1000);
          if(splitList.size() > 0){
            for(List<Long> paramList : splitList){
              ret = dummyScheduleUtils.deleteAndCreateDummySchedule(paramList, searchBedCd, searchStartKurCd, ts);
            }
          }
          break;
      }
      /*mod #8494 by zhangruixue 2023-03-28  GC overhead limit exceeded end*/
      if (PROC_RESULT.ERROR == ret) {
        // エラー処理(ログはサブ関数で出力済み)
        status = HttpStatus.INTERNAL_SERVER_ERROR;
        retMsg = "ダミースケジュール操作処理に失敗しました";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg);
      } else if (PROC_RESULT.PARAM_ERR == ret) {
        // パラメータ異常処理(ログはサブ関数で出力済み)
        status = HttpStatus.BAD_REQUEST;
        retMsg = "ダミースケジュール操作処理を実施できませんでした";
        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg);
      }
    }
    catch(Exception e)
    {
      // エラー処理
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      retMsg = "ダミースケジュール操作処理に失敗しました";
      msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg);
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" +   e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }

    return new ResponseEntity<String>(msgJson.toString(), status);
  }

  /**
   * list  Split
   * @param list
   * @param size
   * @param <T>
   * @return
   */
  public static <T> List<List<T>> splitList(List<T> list, int size) {
    if (list == null || list.isEmpty() || size <= 0) {
      return Collections.emptyList();
    }
    int total = list.size();
    int count = (total + size - 1) / size;
    List<List<T>> result = new ArrayList<>(count);
    for (int i = 0; i < count; i++) {
      int start = i * size;
      int end = Math.min(start + size, total);
      result.add(list.subList(start, end));
    }
    return result;
  }
  /*mod #8495 by zhangruixue 2023-03-28  GC overhead limit exceeded end*/
}
