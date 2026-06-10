package jp.co.nikkiso.ntss.admin_web.web.rest.util;


import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// add FNSI-重要通知設定の追加 江 start
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
// add FNSI-重要通知設定の追加 江 end
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.apache.commons.lang3.StringUtils;
import org.joda.time.DateTime;
import org.json.JSONObject;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.client.DefaultResponseErrorHandler;
import org.springframework.web.client.ResponseErrorHandler;
import org.springframework.web.client.RestTemplate;

import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.admin_web.request.notificationMessage.RegisterRequest;
import jp.co.nikkiso.ntss.admin_web.web.rest.DeviceEdgeOrderResource;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

/**
 * 共通WebAPI処理
 *
 */
@Component
public class WebApiCallCommonUtil {
  @Autowired
  MntMachineStateDao mntMachineStateDao;
  @Autowired
  DeviceEdgeOrderResource deviceEdgeOrderResource;
  @Autowired
  MstMachineDao mstMachineDao;
  @Autowired
	LogService logService;
  //add FNSI-redmine6060 fang start
  /**
   * オーダメインのDaoインタフェース
   */
  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  private PatExamMainDao patExamMainDao;
  //add FNSI-redmine6060 fang end

//接続先はapplication.ymlに設定
@Value("${ntss.admin-web.web-api.url}/util")
private String CONNECT_BASE_URI;
//  @Value("${api.dummyschedule.endpoint}")
//  private String CONNECT_BASE_URI = "http://localhost:8080/ntss-web-api/util";
//  @Value("${ntss.admin-web.data-gathering.header-name}")
//  private String SEC_HEADER_NAME;
//  @Value("${ntss.admin-web.data-gathering.header-value}")
//  private String SEC_HEADER_VALUE;

  /**
   * RestTemplate用エラーハンドラクラス(例外発生回避用)
   * なにもしないエラーハンドラ
   */
  final class NoProcResponseErrorHandler extends DefaultResponseErrorHandler {
    @Override
    public void handleError(ClientHttpResponse response) throws IOException {
        // なにもしない→HttpStatusが異常値でも例外を発生させない
    }
  }

  /**
   * 戻り値が文字列のWebAPI呼び出し処理
   *
   * @param requestUri 呼び出し先(ベースURIへの付加URI)
   * @param jsonBody 送信Bodyデータ
   * @return
   */
  private ResponseEntity<String> webApiCallAsReturnString(
      String requestUri,
      JSONObject jsonBody
    ) throws URISyntaxException,RuntimeException
  {
    HttpStatus status = HttpStatus.OK;
    String ret = null;
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("webApiCallAsReturnString処理開始");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    RestTemplate rt = new RestTemplate();

    //(なにもしない)エラーハンドラのセット
    // ※exchangeメソッドでHttpStatusがOK以外の場合に例外発生させずResponseEntityの回収を行うためなにもしないエラーハンドラを設定する
    ResponseErrorHandler errorHandler = new NoProcResponseErrorHandler();
    rt.setErrorHandler(errorHandler);

    try {
      // 送信URI
      URI uri = new URI(CONNECT_BASE_URI+requestUri);

      // リクエスト作成
      RequestEntity<String> request = RequestEntity
          .post(uri)
          .contentType(MediaType.APPLICATION_JSON)
//          .header(SEC_HEADER_NAME, SEC_HEADER_VALUE)
          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
          .body(jsonBody.toString());
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      // リクエスト処理
      ResponseEntity<String> response = rt.exchange(request, String.class);
      status = response.getStatusCode();
      ret = response.getBody();
      // log start
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil");
      map.put("methodName", "webApiCallAsReturnString");
      map.put("method", request.getMethod());
      map.put("url", request.getUrl());
      map.put("headers", request.getHeaders().toSingleValueMap());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      if (HttpStatus.OK != status) {
        eventLogMessage.setLogMessage("RestAPI側で接続失敗:"+status + " uri: "+uri);
        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(ret, status);
      }
    } catch (Exception ex) {
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      ret = "RestAPI呼び出し処理で例外発生:"+ex.getMessage();
      eventLogMessage.setLogMessage(ret);
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(ret, status);
    }

    eventLogMessage.setLogMessage("webApiCallAsReturnString処理終了");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(ret, status);
  }

  /**
   * 戻り値がOrdScheduleリストのWebAPI呼び出し処理
   *
   * @param requestUri 呼び出し先(ベースURIへの付加URI)
   * @param jsonBody 送信Bodyデータ
   * @return
   */
  private ResponseEntity<List<OrdSchedule>> webApiCallAsReturnOrdScheduleList(
      String requestUri,
      JSONObject jsonBody
    ) throws URISyntaxException,RuntimeException
  {
    HttpStatus status = HttpStatus.OK;
    List<OrdSchedule> ret = null;
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("webApiCallAsReturnOrdScheduleList処理開始");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    try {
      // 送信URI
      URI uri = new URI(CONNECT_BASE_URI+requestUri);
      RestTemplate rt = new RestTemplate();

      // リクエスト作成
      RequestEntity<String> request = RequestEntity
          .post(uri)
          .contentType(MediaType.APPLICATION_JSON)
//          .header(SEC_HEADER_NAME, SEC_HEADER_VALUE)
          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
          .body(jsonBody.toString());

      // リクエスト処理
      //(なにもしない)エラーハンドラのセット
      // ※exchangeメソッドでHttpStatusがOK以外の場合に例外発生させずResponseEntityの回収を行うためなにもしないエラーハンドラを設定する
      ResponseErrorHandler errorHandler = new NoProcResponseErrorHandler();
      rt.setErrorHandler(errorHandler);
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      ResponseEntity<List<OrdSchedule>> response = rt.exchange(request, new ParameterizedTypeReference<List<OrdSchedule>>() {});
      status = response.getStatusCode();
      ret = response.getBody();
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil");
      map.put("methodName", "webApiCallAsReturnOrdScheduleList");
      map.put("method", request.getMethod());
      map.put("url", request.getUrl());
      map.put("headers", request.getHeaders().toSingleValueMap());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      if (HttpStatus.OK != status) {
        eventLogMessage.setLogMessage("RestAPI側で接続失敗:"+status);
        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(ret, status);
      }
    } catch (Exception ex) {
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      String retMsg = "RestAPI呼び出し処理で例外発生:"+ex.getMessage();
      eventLogMessage.setLogMessage(retMsg);
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(ret, status);
    }
    eventLogMessage.setLogMessage("webApiCallAsReturnOrdScheduleList処理終了");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(ret, status);
  }

  /**
   * ダミースケジュール操作Apiの呼び出し処理
   * @param ordNoList メインスケジュールのオーダ番号リスト
   * @param searchBedCd 検索ベッドコード ※nullの場合はメインスケジュールのベッドコードを使用
   * @param searchStartKurCd 検索開始クールコード ※nullの場合はメインスケジュールのクールコードを使用
   * @param opeMode モード "1":登録 "2":削除 "3":再作成(削除+作成)
   * @return ResponseEntity(HttpStatusとメッセージ(JSON文字列))
   *    HttpStatus
   *        200:正常終了
   *        400:チェック処理でのエラー
   *        500:上記以外のエラー全般(Validationの結果で生じたエラーなどもこちらに含まれる)
   *    メッセージ(JSON文字列(キー:retMsg))
   *        正常終了時(HttpStatus(200)):空文字
   *        異常終了時(HttpStatus(400、500)):メッセージ格納
   */
  public ResponseEntity<String> operateDummySchedule(
      List<Long> ordNoList,
      Long searchBedCd,
      Long searchStartKurCd,
      String opeMode
    ) throws URISyntaxException,RuntimeException
  {
    String addUri = "/OpeDummySchedule";
    // body作成
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("ord_no_list", ordNoList);
    if (null != searchBedCd) jsonBody.put("bed_cd", searchBedCd);
    if (null != searchStartKurCd) jsonBody.put("kur_cd", searchStartKurCd);
    jsonBody.put("ope_mode", opeMode);
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("ダミースケジュール更新開始:パラメータ(" + jsonBody.toString() + ")");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    ResponseEntity<String> ret = this.webApiCallAsReturnString(
          addUri,
          jsonBody
        );
        eventLogMessage.setLogMessage("ダミースケジュール更新結果:" + ret.getStatusCode());
        logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    return ret;
  }

  /**
   * ベッド空き状況確認Apiの呼び出し処理(治療日移動なし)
   * @param facilityCd 検索施設コード
   * @param ordNoList 検索対象外治療予定リスト(ベッド割り当て予定のオーダ番号リスト)
   * @param patId 検索対象外患者ID(ベッド割り当て予定の患者ID)
   * @param bedCd 検索ベッドコード
   * @param searchStartDate 検索開始日(形式:yyyyMMdd)
   * @param searchStartKurCd 検索開始クール
   * @return ResponseEntity(HttpStatusと検索にヒットしたスケジュールのリスト)
   *    HttpStatus
   *        200:正常終了
   *        400:チェック処理でのエラー
   *        500:上記以外のエラー全般(Validationの結果で生じたエラーなどもこちらに含まれる)
   *    検索にヒットしたスケジュールのリスト
   *        正常終了時(HttpStatus(200)):検索にヒットしたスケジュールのリスト
   *        異常終了時(HttpStatus(400、500)):null
   */
  public ResponseEntity<List<OrdSchedule>> selectForSearchReservedBed(
      String facilityCd,
      List<Long> ordNoList,
      Long patId,
      Long bedCd,
      String searchStartDate,
      Long searchStartKurCd
    ) throws URISyntaxException,RuntimeException
  {
      return this.selectForSearchReservedBed(facilityCd, ordNoList, patId, bedCd, searchStartDate, searchStartKurCd, false);
  }

  /**
   * ベッド空き状況確認Apiの呼び出し処理
   * @param facilityCd 検索施設コード
   * @param ordNoList 検索対象外治療予定リスト(ベッド割り当て予定のオーダ番号リスト)
   * @param patId 検索対象外患者ID(ベッド割り当て予定の患者ID)
   * @param bedCd 検索ベッドコード
   * @param searchStartDate 検索開始日(形式:yyyyMMdd)
   * @param searchStartKurCd 検索開始クール
   * @param isMoveTreatDate 治療日移動フラグ(true:移動あり、false:移動なし) ※nullの場合はデフォルト:falseを使用
   * @return ResponseEntity(HttpStatusと検索にヒットしたスケジュールのリスト)
   *    HttpStatus
   *        200:正常終了
   *        400:チェック処理でのエラー
   *        500:上記以外のエラー全般(Validationの結果で生じたエラーなどもこちらに含まれる)
   *    検索にヒットしたスケジュールのリスト
   *        正常終了時(HttpStatus(200)):検索にヒットしたスケジュールのリスト
   *        異常終了時(HttpStatus(400、500)):null
   */
  public ResponseEntity<List<OrdSchedule>> selectForSearchReservedBed(
      String facilityCd,
      List<Long> ordNoList,
      Long patId,
      Long bedCd,
      String searchStartDate,
      Long searchStartKurCd,
      Boolean isMoveTreatDate
    ) throws URISyntaxException,RuntimeException
  {
    String addUri = "/selectForSearchReservedBed";
    // body作成
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("facility_cd", facilityCd);
    jsonBody.put("ord_no_list", ordNoList);
    jsonBody.put("pat_id", patId);
    jsonBody.put("bed_cd", bedCd);
    jsonBody.put("search_start_date", searchStartDate);
    jsonBody.put("search_start_kur_cd", searchStartKurCd);
    jsonBody.put("is_move_treat_date", isMoveTreatDate);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("ベッド空き状況確認開始:パラメータ(" + jsonBody.toString() + ")");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    ResponseEntity<List<OrdSchedule>> ret = this.webApiCallAsReturnOrdScheduleList(
          addUri,
          jsonBody
        );
        eventLogMessage.setLogMessage("ベッド空き状況確認結果:" + ret.getStatusCode());
        logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    return ret;
  }

  /**
   * 次患者更新Apiの呼び出し処理
   * @param indBedCd 指示:ベッドコード
   * @param isIndChange 指示変更有無(true:指示(スケジュール情報以外)変更あり、false:指示変更なし)
   * @param upDate 更新日時
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
  public ResponseEntity<String> SetNextPatInfo(
      Long indBedCd,
      boolean isIndChange,
      LocalDateTime upDate
    ) throws URISyntaxException,RuntimeException
  {
    // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 start
//    return OverrideSetNextPatInfo(indBedCd, isIndChange, upDate, false);
    return OverrideSetNextPatInfo(indBedCd, isIndChange, upDate, false, null);
    // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 end
  }

  /**
   * 次患者更新Apiの呼び出し処理
   * @param isSendCondition 条件送信済みフラグ
   */
  public ResponseEntity<String> OverrideSetNextPatInfo(
      Long indBedCd,
      boolean isIndChange,
      LocalDateTime upDate,
      boolean isSendCondition,
      // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 start
      Long sendConditionOrdNo
      // #9290 2023.10.03 mod isSendCondition = true のときは元々のord_noを使用する TDC片口 end
    ) throws URISyntaxException,RuntimeException
  {
    JSONObject msgJson = new JSONObject("{}");
    if (0 == indBedCd) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("未登録ベッドのため次患者更新スキップしました");
      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<String>(msgJson.toString(), HttpStatus.OK);
    }

    // ベッドコードからmnt_machine_stateの主キーを取得
    //mod #9910 治療状況リストに１つ実績が２つで表示される zhangruixue start
    //update   7686 sql最適化    ljg start
    List<MntMachineState> retInfo = mntMachineStateDao.selectByBedCd(indBedCd);
//    List<MntMachineState> retInfo = mntMachineStateDao.selectByBedCdcopy(indBedCd);
    //update   7686 sql最適化    ljg end
    //mod #9910 治療状況リストに１つ実績が２つで表示される zhangruixue end
    if (1 != retInfo.size()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("指定ベッドに紐づく装置情報に異常がある為、次患者更新処理を中断しました(指示:ベッドコード=" + indBedCd + "、装置情報取得件数=" + retInfo.size() + ")");
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      msgJson.put("retMsg", "次患者更新処理を実施できませんでした") ;
      return new ResponseEntity<String>(msgJson.toString(), HttpStatus.INTERNAL_SERVER_ERROR);
    }

    String addUri = "/SetNextPatInfo";
    // body作成
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("facility_cd", retInfo.get(0).getFacilityCd());
    jsonBody.put("machine_type_cd", retInfo.get(0).getMachineTypeCd());
    jsonBody.put("machine_serial", retInfo.get(0).getMachineSerial());
    jsonBody.put("is_ind_change", isIndChange);
    jsonBody.put("up_date", upDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
    jsonBody.put("is_send_condition", isSendCondition);
    // #9290 2023.10.03 add isSendCondition = true のときは元々のord_noを使用する TDC片口 start
    jsonBody.put("send_condition_ord_no", sendConditionOrdNo);
    // #9290 2023.10.03 add isSendCondition = true のときは元々のord_noを使用する TDC片口 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("次患者更新開始:パラメータ(" + jsonBody.toString() + ")");
    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    ResponseEntity<String> ret = this.webApiCallAsReturnString(
      addUri,
      jsonBody
    );
    eventLogMessage.setLogMessage("次患者更新結果:" + ret.getStatusCode());
    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    JSONObject jsonRetInfo = new JSONObject(ret.getBody().toString());
    if (jsonRetInfo.has("device_edge_order")) {
      ret = deviceEdgeOrder(jsonRetInfo);
    }

    return ret;
  }

  // del 11454 時間外加算自動処理が機能していない zkm start
//  /**
//   * 条件送信呼び出し
//   * @param ord_no オーダー番号
//   * @return ResponseEntity(HttpStatusとメッセージ(JSON文字列))
//   *    HttpStatus
//   *        200:正常終了(警告終了(処理未実施)含む)
//   *        400:チェック処理でのエラー
//   *        500:上記以外のエラー全般(Validationの結果で生じたエラーなどもこちらに含まれる)
//   *    メッセージ(JSON文字列(キー:retMsg))
//   *        正常終了時(HttpStatus(200)):空文字
//   *        警告終了時(HttpStatus(200)):メッセージ格納
//   *        異常終了時(HttpStatus(400、500)):メッセージ格納
//   */
//  public ResponseEntity<String>  sendCondResultOnly(Long ord_no) throws URISyntaxException,RuntimeException {
//    if (ord_no == null) {
//      //引数は、ボディデータ,ヘッダーデータ,ステータス
//      return new ResponseEntity<>("オーダー番号が不正な値です。", null, HttpStatus.INTERNAL_SERVER_ERROR);
//    }
//    String addUri = "/SendCondResultOnly";
//    JSONObject jsonBody = new JSONObject();
//    jsonBody.put("ordNo", ord_no.toString());
////    add 8074 【デグレ】ログに誤った利用者が記録される 関 start
//    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
//    jsonBody.put("user",user.getUserId().toString());
////    add 8074 【デグレ】ログに誤った利用者が記録される 関  end
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("次患者更新開始:パラメータ(" + jsonBody.toString() + ")");
//    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//    ResponseEntity<String> ret = this.webApiCallAsReturnString(
//        addUri,
//        jsonBody
//      );
//    eventLogMessage.setLogMessage("条件送信結果: " + ret.getStatusCode());
//    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//    return ret;
//  }
  // del 11454 時間外加算自動処理が機能していない zkm end

  /**
   * 検査結果から感染症の検査結果を登録
   * @param examMainCd 検査結果コード
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
  public ResponseEntity<String>  updateInfectinfo(List<Long> examMainCd) throws URISyntaxException,RuntimeException {
    if (examMainCd == null) {
      //引数は、ボディデータ,ヘッダーデータ,ステータス
      return new ResponseEntity<>("検査結果コードが不正な値です。", null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    String addUri = "/updateInfectinfo";
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("examMainCd", examMainCd);
    ResponseEntity<String> ret = this.webApiCallAsReturnString(
          addUri,
          jsonBody
        );
    return ret;
  }

  /**
   * 検査結果からシステム標準計算項目・検査計算項目の検査結果を登録
   * @param examMainCd 検査結果コードのリスト
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
  public ResponseEntity<String>  updateExamResultCalc(List<Long> examMainCd) throws URISyntaxException,RuntimeException {
    if (examMainCd == null) {
      //引数は、ボディデータ,ヘッダーデータ,ステータス
      return new ResponseEntity<>("検査結果コードが不正な値です。", null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    String addUri = "/updateExamResultCalc";
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("examMainCd", examMainCd);
    ResponseEntity<String> ret = this.webApiCallAsReturnString(
          addUri,
          jsonBody
        );
    return ret;
  }

  private ResponseEntity<String> deviceEdgeOrder(JSONObject jsonRetInfo) {
    String facilityCd = jsonRetInfo.getString("facilityCd");
    String machineSerial = jsonRetInfo.getString("machineSerial");
    String machineTypeCd = jsonRetInfo.getString("machineTypeCd");

    MstMachine mstMachineInfo = mstMachineDao.selectByCd(machineTypeCd, machineSerial, facilityCd);

    Integer deviceEdgeNo = mstMachineInfo.getDeviceEdgeNo();
    Long machineNo = mstMachineInfo.getMachineNo();

    DeviceEdgeOrderRequest deviceEdgeOrder = new DeviceEdgeOrderRequest();
    deviceEdgeOrder.setFacilityCd(facilityCd);
    deviceEdgeOrder.setDeviceEdgeNo(deviceEdgeNo);
    deviceEdgeOrder.setMachineNo(machineNo);

    JSONObject json = new JSONObject("{}");
    json.put("retMsg", "");
    HttpStatus status = HttpStatus.OK;
    try {
      ResponseEntity<?> res = deviceEdgeOrderResource.PostOrderSendNextPat(deviceEdgeOrder, null);

      status = res.getStatusCode();
      if (status != HttpStatus.OK) {
        json.put("retMsg", "通信サーバーへの通知失敗");
        json.put("isSuccess", false);
        status = HttpStatus.INTERNAL_SERVER_ERROR;
      }
    } catch (Exception ex) {
      json.put("retMsg", "通信サーバーへの通知失敗");
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    return new ResponseEntity<String>(json.toString(), null, status);
  }

  /**
   * 入外区分、在院状態更新API呼び出し
   * @param patIds 更新対象の患者ID
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
  public ResponseEntity<String> updatePatInOutInfo(String targetDt, List<Long> patIds) throws URISyntaxException,RuntimeException {
    if (patIds == null) {
      patIds = new ArrayList<Long>();
    }
    String addUri = "/UpdateInOutState";
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("target_dt", targetDt);
    jsonBody.put("pat_id_list", patIds);
    ResponseEntity<String> ret = this.webApiCallAsReturnString(
          addUri,
          jsonBody
        );
    return ret;
  }

  /**
   * メーカー通知を登録
   * @param request 検査結果コード
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
  public ResponseEntity<String>  registerMakerNotice(RegisterRequest request) throws URISyntaxException,RuntimeException {
    if (request == null) {
      //引数は、ボディデータ,ヘッダーデータ,ステータス
      return new ResponseEntity<>("通知メッセージ情報が不正な値です。", null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    String addUri = "/makerNoticeReciever";
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("content", request.getContent());
    jsonBody.put("recipients", request.getRecipients());
    jsonBody.put("additionalInfo", request.getAdditionalInfo());
    jsonBody.put("facilityCd", request.getFacilityCd());
    // add FNSI-重要通知設定の追加 江 start
    jsonBody.put("notificationNo", CoreConstant.NotificationDefinition.Maker_Notice);
    // add FNSI-重要通知設定の追加 江 end
    ResponseEntity<String> ret = this.webApiCallAsReturnString(
          addUri,
          jsonBody
        );
    return ret;
  }

  /**
   * 通知レシーバーに通知を登録
   * @param notificationNo 通知定義コード
   * @param facilityCd 通知対象の施設コード
   * @param replaceData 変換用文字列(JSON)
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
  public ResponseEntity<String>  registerNotification(Long notificationNo, String facilityCd, JSONObject replaceData) throws URISyntaxException,RuntimeException {
    if (notificationNo == null || replaceData == null) {
      //引数は、ボディデータ,ヘッダーデータ,ステータス
      return new ResponseEntity<>("通知メッセージ情報が不正な値です。", null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    String addUri = "/notificationReciever";
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("notificationNo", notificationNo);
    jsonBody.put("facilityCd", facilityCd);
    // 変換用文字列のエンコード処理(UTF-8)
    String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
    jsonBody.put("replaceData", base64replaceData);
    ResponseEntity<String> ret = this.webApiCallAsReturnString(
          addUri,
          jsonBody
        );
    return ret;
  }

  /**
   * 患者情報共有の解除処理API呼び出し
   *
   * @param facilityCdList 施設コードリスト
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
  public ResponseEntity<String> cancelSharePatientInfo(List<String> facilityCdList) throws URISyntaxException,RuntimeException {
    if (facilityCdList == null) {
      //引数は、ボディデータ,ヘッダーデータ,ステータス
      return new ResponseEntity<>("施設コードが不正な値です。", null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    String addUri = "/cancelSharePatientInfo";
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("facilityCdList", facilityCdList);
    ResponseEntity<String> ret = this.webApiCallAsReturnString(
          addUri,
          jsonBody
        );
    return ret;
  }

  // del 11454 時間外加算自動処理が機能していない zkm start
//  /**
//   * 加算処理実施
//   * @param AdditionCalculationRequest 加算用リクエストパラメータ
//   * @return ResponseEntity(HttpStatusとメッセージ(JSON文字列))
//   *    HttpStatus
//   *        200:正常終了(警告終了(処理未実施)含む)
//   *        400:チェック処理でのエラー
//   *        500:上記以外のエラー全般(Validationの結果で生じたエラーなどもこちらに含まれる)
//   *    メッセージ(JSON文字列(キー:retMsg))
//   *        正常終了時(HttpStatus(200)):空文字
//   *        警告終了時(HttpStatus(200)):メッセージ格納
//   *        異常終了時(HttpStatus(400、500)):メッセージ格納
//   */
//  public ResponseEntity<String>  calculationAddition(AdditionCalculationRequest request) throws URISyntaxException,RuntimeException {
//    if (request == null) {
//      return new ResponseEntity<>("リクエストパラメータが不正な値です。", null, HttpStatus.INTERNAL_SERVER_ERROR);
//    }
//    String addUri = "/calculation";
//    JSONObject jsonBody = new JSONObject();
//    jsonBody.put("facilityCd", request.getFacilityCd());
//    jsonBody.put("patId", request.getPatId());
//    jsonBody.put("ordNo", request.getOrdNo());
//    jsonBody.put("eventId", request.getEventId());
//    ResponseEntity<String> ret = this.webApiCallAsReturnString(
//          addUri,
//          jsonBody
//        );
//    return ret;
//  }
  // del 11454 時間外加算自動処理が機能していない zkm end

  //add FNSI-redmine6060 fang start
  public void doAutoCalculation(Long ordNo){
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    //自動計算
    List<Long> examMainCds = patExamMainDao.selectPatExamMainForAutoCalculation(ordMain.getPatId(), ordMain.getFacilityCd(), ordMain.getTreatDate());
    try {
      if (examMainCds != null && examMainCds.size() > 0) {
        updateExamResultCalc(examMainCds);
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, "");
    }
  }
  //add FNSI-redmine6060 fang end

  //add FNSI-redmine7573 gaoey start
  public void doAutoCalculationByPatId(Long patId){
    //自動計算
    String treatDate =  DateTime.now().toString("yyyyMMdd");
    List<Long> examMainCds = patExamMainDao.selectPatExamMainForAutoCalculationById(patId, treatDate);
    try {
      if (examMainCds != null && examMainCds.size() > 0) {
        updateExamResultCalc(examMainCds);
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, "");
    }
  }
  //add FNSI-redmine7573 gaoey end

  // add #10147 患者情報を更新時に検査計算(更新)されない zkm start
  public void doAutoCalculationByPatIdAndTreatDate(Long patId, String treatDateFrom, String treatDateTo) throws RuntimeException {
    //自動計算
    List<Long> examMainCds = patExamMainDao.doAutoCalculationByPatIdAndTreatDate(patId, treatDateFrom, treatDateTo);
    try {
      if (examMainCds != null && !examMainCds.isEmpty()) {
        updateExamResultCalc(examMainCds);
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, "");
    }
  }
  // add #10147 患者情報を更新時に検査計算(更新)されない zkm end

}
