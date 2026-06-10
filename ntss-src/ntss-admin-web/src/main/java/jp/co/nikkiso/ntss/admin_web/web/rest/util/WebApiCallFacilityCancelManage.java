package jp.co.nikkiso.ntss.admin_web.web.rest.util;


import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.HashMap;
import java.util.Map;

import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.json.JSONObject;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.client.DefaultResponseErrorHandler;
import org.springframework.web.client.ResponseErrorHandler;
import org.springframework.web.client.RestTemplate;

import jp.co.nikkiso.ntss.admin_web.web.rest.DeviceEdgeOrderResource;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

/**
 * 施設解約API処理
 *
 */
@Component
public class WebApiCallFacilityCancelManage {
  @Autowired
  MntMachineStateDao mntMachineStateDao;
  @Autowired
  DeviceEdgeOrderResource deviceEdgeOrderResource;
  @Autowired
  MstMachineDao mstMachineDao;
  @Autowired
  LogService logService;

//接続先はapplication.ymlに設定
@Value("${ntss.admin-web.web-api.url}/facility/cancel")
private String CONNECT_BASE_URI;

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
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.REMS, null);
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
      map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallFacilityCancelManage");
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
        eventLogMessage.setLogMessage("RestAPI側で接続失敗:"+status);
        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(ret, status);
      }
    } catch (Exception ex) {
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      ret = "RestAPI呼び出し処理で例外発生:"+ex.getMessage();
      eventLogMessage.setLogMessage(ret);
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(ret, status);
    }

    eventLogMessage.setLogMessage("webApiCallAsReturnString処理終了");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.REMS, null);
    return new ResponseEntity<>(ret, status);
  }

  /**
   * 戻り値がbyte配列のWebAPI呼び出し処理
   *
   * @param requestUri 呼び出し先(ベースURIへの付加URI)
   * @param jsonBody 送信Bodyデータ
   * @return
   */
  private ResponseEntity<byte[]> webApiCallAsReturnByte(
      String requestUri,
      JSONObject jsonBody
    ) throws URISyntaxException,RuntimeException
  {
    HttpStatus status = HttpStatus.OK;
    byte[] ret = null;
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("webApiCallAsReturnByte処理開始");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.REMS, null);
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
          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
          .body(jsonBody.toString());
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      // リクエスト処理
      ResponseEntity<byte[]> response = rt.exchange(request, byte[].class);
      status = response.getStatusCode();
      ret = response.getBody();
      // log start
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallFacilityCancelManage");
      map.put("methodName", "webApiCallAsReturnByte");
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
        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(ret, status);
      }
    } catch (Exception ex) {
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(ret, status);
    }

    eventLogMessage.setLogMessage("webApiCallAsReturnString処理終了");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.REMS, null);
    return new ResponseEntity<>(ret, status);
  }

  /**
   * 施設解約を登録
   * @param registerData 施設解約登録データ(JSON)
   * @return ResponseEntity(HttpStatusとメッセージ(JSON文字列))
   *    HttpStatus
   *        200:正常終了(警告終了(処理未実施)含む)
   *        400:POSTリクエストに対するパラメータ不正時
   *        500:DB疎通不可,または例外発生時など
   *    メッセージ(JSON文字列(キー:retMsg))
   *        正常終了時(HttpStatus(200)):施設解約を登録しました。
   *        異常終了時(HttpStatus(400)):施設コードが指定されていません。or 解約基準日が指定されていません。
   *        異常終了時(HttpStatus(500)):解約基準日の変換に失敗しました。 解約基準日:[xxxxxx]or 施設解約の登録で内部エラーが発生しました。 施設コード:[xxxxxx]
   */
  public ResponseEntity<String>  registerFacilityCancelManage(JSONObject registerData) throws URISyntaxException,RuntimeException {
    if (registerData == null) {
      return new ResponseEntity<>("施設解約登録情報が不正な値です。", null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    String addUri = "/register";
    ResponseEntity<String> ret = this.webApiCallAsReturnString(
          addUri,
          registerData
        );
    return ret;
  }

  /**
   * 施設解約を取消
   * @param facilityCd 施設コード
   * @return ResponseEntity(HttpStatusとメッセージ(JSON文字列))
   *    HttpStatus
   *        200:正常終了(警告終了(処理未実施)含む)
   *        400:POSTリクエストに対するパラメータ不正時
   *        500:DB疎通不可,または例外発生時など
   *    メッセージ(JSON文字列(キー:retMsg))
   *        正常終了時(HttpStatus(200)):施設解約をキャンセルしました。施設コード:[xxxxxx]
   *        異常終了時(HttpStatus(400)):施設コードが指定されていません。
   *        異常終了時(HttpStatus(500)):施設解約のキャンセルで内部エラーが発生しました。 施設コード:[xxxxxx]
   */
  public ResponseEntity<String>  cancelFacilityCancelManage(JSONObject cancelData) throws URISyntaxException,RuntimeException {
    if (cancelData == null) {
      return new ResponseEntity<>("施設解約キャンセル情報が不正な値です。", null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    String addUri = "/cancel";
    ResponseEntity<String> ret = this.webApiCallAsReturnString(
        addUri,
        cancelData
      );
  return ret;
  }

  /**
   * 解約施設を完全削除
   * @param facilityCd 施設コード
   * @return ResponseEntity(HttpStatusとメッセージ(JSON文字列))
   *    HttpStatus
   *        200:正常終了(警告終了(処理未実施)含む)
   *        400:POSTリクエストに対するパラメータ不正時
   *        500:DB疎通不可,または例外発生時など
   *    メッセージ(JSON文字列(キー:retMsg))
   *        正常終了時(HttpStatus(200)):施設解約をキャンセルしました。施設コード:[xxxxxx]
   *        異常終了時(HttpStatus(400)):施設コードが指定されていません。
   *        異常終了時(HttpStatus(500)):施設解約のキャンセルで内部エラーが発生しました。 施設コード:[xxxxxx]
   */
  public ResponseEntity<String>  completeDeleteFacility(String facilityCd) throws URISyntaxException,RuntimeException {
    if (facilityCd.isEmpty()) {
      return new ResponseEntity<>("施設コードが指定されていません。", null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    String addUri = "/completeDelete";
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("facility_cd", facilityCd);
    ResponseEntity<String> ret = this.webApiCallAsReturnString(
          addUri,
          jsonBody
        );
    return ret;
  }

  /**
   * ReMS/FNSi解約施設のバックアップファイルを削除
   * @param facilityCd 施設コード
   * @return ResponseEntity(HttpStatusとメッセージ(JSON文字列))
   *    HttpStatus
   *        200:正常終了(警告終了(処理未実施)含む)
   *        400:POSTリクエストに対するパラメータ不正時
   *        500:DB疎通不可,または例外発生時など
   *    メッセージ(JSON文字列(キー:retMsg))
   *        正常終了時(HttpStatus(200)):バックアップファイルを削除しました。 施設コード:[xxxxxx]
   *        異常終了時(HttpStatus(400)):施設コードが指定されていません。
   *        異常終了時(HttpStatus(500)):バックアップファイル削除処理で内部エラーが発生しました。 施設コード:[xxxxxx]
   */
  public ResponseEntity<String>  deleteBackupFileFacility(String facilityCd) throws URISyntaxException,RuntimeException {
    if (facilityCd.isEmpty()) {
      return new ResponseEntity<>("施設コードが指定されていません。", null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    String addUri = "/dataDelete";
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("facility_cd", facilityCd);
    ResponseEntity<String> ret = this.webApiCallAsReturnString(
          addUri,
          jsonBody
        );
    return ret;
  }

  /**
   * 解約施設のバックアップデータを取得
   * @param facilityCd 施設コード
   * @return ResponseEntity(HttpStatusとバックアップファイルデータバイト配列)
   *    HttpStatus
   *        200:正常終了(警告終了(処理未実施)含む)
   *        400:POSTリクエストに対するパラメータ不正時
   *        500:DB疎通不可,または例外発生時など
   */
  public ResponseEntity<byte[]> getBackupBinary(JSONObject registerData) throws URISyntaxException,RuntimeException {
    if (registerData == null) {
      return new ResponseEntity<>(null, null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    String addUri = "/getBackupBinary";
    ResponseEntity<byte[]> ret = this.webApiCallAsReturnByte(
          addUri,
          registerData
        );
    return ret;
  }
}
