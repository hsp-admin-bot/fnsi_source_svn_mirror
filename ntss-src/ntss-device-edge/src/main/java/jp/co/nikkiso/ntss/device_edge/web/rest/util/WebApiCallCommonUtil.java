package jp.co.nikkiso.ntss.device_edge.web.rest.util;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.utils.NtssUtils;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.client.DefaultResponseErrorHandler;
import org.springframework.web.client.ResponseErrorHandler;
import org.springframework.web.client.RestTemplate;

import jp.co.nikkiso.ntss.api.service.additionInfo.AdditionCalculationService;
import jp.co.nikkiso.ntss.api.request.AdditionCalculationRequest;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.WebApiCallProperties;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

/**
 * 共通WebAPI処理
 *
 */
@Component
public class WebApiCallCommonUtil {
  @Autowired
  LogService logService;

  @Autowired
  WebApiCallProperties webApiCallProperties;

  //9480 排液済，検査計算 gjn start
  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  private PatExamMainDao patExamMainDao;
  //9480 排液済，検査計算 gjn end

  @Autowired
  private AdditionCalculationService additionCalculationService;

  /**
   * RestTemplate用エラーハンドラクラス(例外発生回避用)
   * なにもしないエラーハンドラ
   */
  final class NoProcResponseErrorHandler extends DefaultResponseErrorHandler {
    @Override
    public void handleError(URI url, HttpMethod method, ClientHttpResponse response) throws IOException {
      // なにもしない→HttpStatusが異常値でも例外を発生させない
    }
  }

  /**
   * ntss-web-api/util のURLをプロパティから生成して返す
   * @return
   */
  private String BaseWebApiUri() {

    String baseUrl = webApiCallProperties.getUrl();
    if (Objects.isNull(baseUrl) || baseUrl.isEmpty()) {
      baseUrl = "http://localhost:8080/ntss-web-api";
    }

    return baseUrl + "/util";
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
      JSONObject jsonBody) throws URISyntaxException, RuntimeException {
    HttpStatus status = HttpStatus.OK;
    String ret = null;
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("webApiCallAsReturnString処理開始");
    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    RestTemplate rt = new RestTemplate();

    //(なにもしない)エラーハンドラのセット
    // ※exchangeメソッドでHttpStatusがOK以外の場合に例外発生させずResponseEntityの回収を行うためなにもしないエラーハンドラを設定する
    ResponseErrorHandler errorHandler = new NoProcResponseErrorHandler();
    rt.setErrorHandler(errorHandler);

    try {
      // 送信URI
      URI uri = new URI(this.BaseWebApiUri() + requestUri);

      // リクエスト作成
      RequestEntity<String> request = RequestEntity
          .post(uri)
          .contentType(MediaType.APPLICATION_JSON)
          // .header(SEC_HEADER_NAME, SEC_HEADER_VALUE)
          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
          .body(jsonBody.toString());
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      // リクエスト処理
      ResponseEntity<String> response = rt.exchange(request, String.class);
      status = HttpStatus.valueOf(response.getStatusCode().value());
      // log start
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.device_edge.web.rest.util.WebApiCallCommonUtil");
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
      ret = response.getBody();
      if (HttpStatus.OK != status) {
        eventLogMessage.setLogMessage("RestAPI側で接続失敗:" + status);
        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(ret, status);
      }
    } catch (Exception ex) {
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      ret = "RestAPI呼び出し処理で例外発生:" + ex.getMessage();
      eventLogMessage.setLogMessage(ret);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(ret, status);
    }

    eventLogMessage.setLogMessage("webApiCallAsReturnString処理終了");
    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(ret, status);
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
  public ResponseEntity<String> registerNotification(Long notificationNo, String facilityCd, JSONObject replaceData)
      throws URISyntaxException, RuntimeException {
    if (notificationNo == null || replaceData == null) {
      //引数は、ボディデータ,ヘッダーデータ,ステータス
      return new ResponseEntity<>("通知メッセージ情報が不正な値です。", (org.springframework.http.HttpHeaders) null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    String addUri = "/notificationReciever";
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("notificationNo", notificationNo);
    jsonBody.put("facilityCd", facilityCd);
    // 変換用文字列のエンコード処理(UTF-8)
    String base64replaceData = new String(
        Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
    jsonBody.put("replaceData", base64replaceData);
    ResponseEntity<String> ret = this.webApiCallAsReturnString(
        addUri,
        jsonBody);
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
//      return new ResponseEntity<>("リクエストパラメータが不正な値です。", (org.springframework.http.HttpHeaders) null, HttpStatus.INTERNAL_SERVER_ERROR);
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

  //9480 排液済，検査計算 gjn start
  public void doAutoCalculation(Long ordNo){
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    //自動計算
    List<Long> examMainCds = patExamMainDao.selectPatExamMainForAutoCalculation(ordMain.getPatId(), ordMain.getFacilityCd(), ordMain.getTreatDate());
    try {
      if (examMainCds != null && examMainCds.size() > 0) {
        this.updateExamResultCalc(examMainCds);
      }
      // 加算処理
      AdditionCalculationRequest addReq = new AdditionCalculationRequest();
      addReq.setFacilityCd(ordMain.getFacilityCd());
      addReq.setPatId(ordMain.getPatId());
      addReq.setOrdNo(ordNo);
      addReq.setEventId(2);
      additionCalculationService.calculationAddition(addReq);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(NtssUtils.ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, "");
    }
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
      return new ResponseEntity<>("検査結果コードが不正な値です。", (org.springframework.http.HttpHeaders) null, HttpStatus.INTERNAL_SERVER_ERROR);
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
  //9480 排液済，検査計算 gjn end
}
