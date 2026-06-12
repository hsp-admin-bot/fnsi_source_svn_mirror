package jp.co.nikkiso.ntss.coop_api.utils;

import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.json.JSONObject;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.client.DefaultResponseErrorHandler;
import org.springframework.web.client.ResponseErrorHandler;
import org.springframework.web.client.RestTemplate;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.HashMap;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

/**
 * 通知機能API処理
 *
 */
@Component
public class NotificationApiCallUtil {

  //接続先はapplication.ymlに設定
  @Value("${ntss.web-api.url}/util")
  private String CONNECT_BASE_URI;
  @Value("${ntss.web-api.header-name}")
  private String SEC_HEADER_NAME;
  @Value("${ntss.web-api.header-value}")
  private String SEC_HEADER_VALUE;

  @Autowired
  private LogService logService;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

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
   * 電文種別名を取得する
   * @param coopCd 電文種別コード
   * @return String 電文種別名
   */
  public String GetCoopNameByCd(String coopCd) {
      switch (coopCd) {
        case "ini_dial":
          return "浄化申し込み・初回指示";
        case "is_death":
          return "死亡退院";
        case "profile":
          return "患者プロファイル";
        case "ind_dial":
          return "透析予約";
        case "ord_dial":
          return "オーダ受け";
        case "accept":
          return "受付情報";
        case "rst_dial":
          return "透析実績";
        case "rep_dial":
          return "透析レポート";
        case "exam_rst":
          return "検査結果";
        case "exam_ord":
          return "検査オーダ";
        case "rad_ord":
          return "放射線検査オーダ";
        case "phy_ord":
          return "心電図検査オーダ";
        case "shot_ord":
          return "透析注射連携";
        case "pre_ord":
          return "処方情報連携";
        case "staff_mst":
          return "スタッフマスタ連携";
        case "vit_cop":
          return "バイタル連携";
        case "karte_ord":
          return "カルテ記載連携";
        default:
          return "";
      }
  }

  /**
   * 通知処理を行う
   * @param facilityCd 施設コード
   * @param coopCd 連携種別
   * @param hospPatId 患者番号
   * @param baseDate 基準日
   * @return 無し
   * */
  public void registerNotification(Long ctlNo,Long ordNo,String facilityCd, String coopCd, String hospPatId, String baseDate) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    JSONObject replaceData = new JSONObject();

    // ①[HOSP_PAT_ID] : 患者番号、[LASTNAME]：患者名(姓)、[FIRSTNAME]：患者名(名)
    if (StringUtils.isEmpty(hospPatId)) {
      replaceData.put("HOSP_PAT_ID", "");
      replaceData.put("LASTNAME", "");
      replaceData.put("FIRSTNAME", "");
    } else {
      String lastName = "";
      String firstName = "";
      try {
        PatPersonalMain ppm = patPersonalMainDao.selectPatInfoByHospPatId(facilityCd, hospPatId);
        if (ppm != null) {
          lastName = ppm.getPat_last_name()==null?"":ppm.getPat_last_name();
          firstName = ppm.getPat_first_name()==null?"":ppm.getPat_first_name();
        }
      } catch (Exception ppme) {
        eventLogMessage.setInvokeClass(this.getClass().getName());
        eventLogMessage.setLogMessage("通知処理:患者名を取得しません。" + ppme.getMessage());
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }

      replaceData.put("HOSP_PAT_ID", hospPatId);
      replaceData.put("LASTNAME", lastName);
      replaceData.put("FIRSTNAME", firstName);
    }
    // add 9583 by kangjie 20240401 start 通知一覧の連携エラー通知の遷移不正
    replaceData.put("CTLNO",ctlNo==null? null: String.valueOf(ctlNo));
    replaceData.put("ORDNO",ordNo==null? null: String.valueOf(ordNo));
    replaceData.put("COOP_CD",coopCd);
    // add 9583 by kangjie 20240401 end 通知一覧の連携エラー通知の遷移不正
    // ②[COOP_CD] : 連携種別
    replaceData.put("COOP_NAME", GetCoopNameByCd(coopCd));
    // ③[TARGET_DATE] : 対象日
    if (StringUtils.isEmpty(baseDate)) {
      replaceData.put("TARGET_DATE", "");
    } else {
      String baseDateTmp = "";
      try {

        baseDateTmp = DateUtil.convertDateToStringFormat(baseDate);
        if (baseDateTmp == null || JournalConvertConstants.DIE_DATE_ALIVE.equals(baseDateTmp)) {
          baseDateTmp = "";
        }
      } catch (Exception de) {
        eventLogMessage.setInvokeClass(this.getClass().getName());
        eventLogMessage.setLogMessage("通知処理:基準日[" + baseDate + "]の形式不正。" + de.getMessage());
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
      replaceData.put("TARGET_DATE", (StringUtils.isEmpty(baseDateTmp) ? baseDate : baseDateTmp));
    }

    // ④通知定義コード
    // modify 9583 by kangjie 20240401 start 通知一覧の連携エラー通知の遷移不正
//    Long notificationNo =  CoreConstant.NotificationDefinition.CREATE_JOURNAL;
    Long notificationNo =  CoreConstant.NotificationDefinition.COOP_JOURNAL_ERROR;
    // modify 9583 by kangjie 20240401 end 通知一覧の連携エラー通知の遷移不正

    // [通知レシーバーに通知を登録]を呼び出し
    registerNotification(notificationNo, facilityCd, replaceData);
  }

  /**
   * 通知レシーバーに通知を登録
   * @param notificationNo 通知定義コード
   * @param facilityCd 通知対象の施設コード
   * @param replaceData 変換用文字列(JSON)
   */
  public void  registerNotification(Long notificationNo, String facilityCd,JSONObject replaceData) {
    if (replaceData == null || StringUtils.isEmpty(facilityCd)) {
      //引数は、ボディデータ,ヘッダーデータ,ステータス
      String error = "通知メッセージ情報が不正な値です。"
        + "facilityCd:[" + facilityCd + "],"
        + "replaceData:[" + (replaceData == null ? "" : replaceData.toString()) + "]";

      // ログメッセージ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setLogMessage(error);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return;
    }

    try {
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
    } catch (Exception e) {
      return;
    }

    return;
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
  ) throws RuntimeException
  {
    // add 2021-03-26 通知機能を改善 孫 start
    // ExecutorService singleThreadExecutor = Executors.newSingleThreadExecutor();
    // singleThreadExecutor.execute(new Runnable() {
    //   @Override public void run() {
        // add 2021-03-26 通知機能を改善 孫 end
        HttpStatus status = HttpStatus.OK;
        String ret = null;
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("webApiCallAsReturnString処理開始");
        eventLogMessage.setInvokeClass(this.getClass().getName());
        logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        RestTemplate rt = new RestTemplate();

        //(なにもしない)エラーハンドラのセット
        // ※exchangeメソッドでHttpStatusがOK以外の場合に例外発生させずResponseEntityの回収を行うためなにもしないエラーハンドラを設定する
        ResponseErrorHandler errorHandler = new NoProcResponseErrorHandler();
        rt.setErrorHandler(errorHandler);

        try {
          // 送信URI
          URI uri = new URI(CONNECT_BASE_URI + requestUri);

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
          status = HttpStatus.valueOf(response.getStatusCode().value());
          long cost = System.currentTimeMillis() - start;
          Map<String, Object> map = new HashMap<>();
          map.put("logType", "RESTTEMPLATE-LOG");
          map.put("className", "jp.co.nikkiso.ntss.coop_api.utils.NotificationApiCallUtil");
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
            eventLogMessage.setLogMessage("RestAPI側で接続失敗:" + status + " uri: " + uri);
            eventLogMessage.setInvokeClass(this.getClass().getName());
            logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
            //return new ResponseEntity<>(ret, status);
          }
        } catch (Exception ex) {
          status = HttpStatus.INTERNAL_SERVER_ERROR;
          ret = "RestAPI呼び出し処理で例外発生:" + ex.getMessage();
          eventLogMessage.setLogMessage(ret);
          eventLogMessage.setInvokeClass(this.getClass().getName());
          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
          //return new ResponseEntity<>(ret, status);
        }

        eventLogMessage.setLogMessage("webApiCallAsReturnString処理終了");
        eventLogMessage.setInvokeClass(this.getClass().getName());
        logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//        return new ResponseEntity<>(ret, status);
        // add 2021-03-26 通知機能を改善 孫 start
    //   }
    // });
    return new ResponseEntity<>("OK", HttpStatus.OK);
    // add 2021-03-26 通知機能を改善 孫 end
  }

  /**
   * 検査結果からシステム標準計算項目・検査計算項目の検査結果を登録
   * @param patId システムで管理する一意な患者ID
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
  public ResponseEntity<String>  updateExamResultCalc(Long patId) throws URISyntaxException,RuntimeException {
    if (patId == null) {
      //引数は、ボディデータ,ヘッダーデータ,ステータス
      return new ResponseEntity<>("patIdが不正な値です。", (org.springframework.http.HttpHeaders) null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    String addUri = "/updateExamResultCalcForCoop";
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("patId", patId.toString());
    ResponseEntity<String> ret = this.webApiCallAsReturnString(
      addUri,
      jsonBody
    );
    return ret;
  }

}
