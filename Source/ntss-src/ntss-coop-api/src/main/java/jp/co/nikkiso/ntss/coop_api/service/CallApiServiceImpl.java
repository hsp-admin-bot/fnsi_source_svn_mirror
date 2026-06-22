package jp.co.nikkiso.ntss.coop_api.service;

import tools.jackson.databind.JavaType;
import com.google.common.base.CaseFormat;
import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.request.CallApiJournalRequest;
import jp.co.nikkiso.ntss.coop_api.utils.CoopCdConstant;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants;
import jp.co.nikkiso.ntss.coop_api.web.rest.JournalConvertReceiveResource;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstCoopApilinkDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopApilink;
import jp.co.nikkiso.ntss.core.entity.MstCoopApilink.AfterApiStatus;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

/**
 * API呼び出しサービス
 *
 * @see jp.co.nikkiso.ntss.coop_api.service.CallApiService
 */
@Service
public class CallApiServiceImpl implements CallApiService {

  // DAO群
  @Autowired
  private MstCoopApilinkDao mstCoopApilinkDao;

  @Autowired
  private LogService logService;

  /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
  @Value("${ntss.coop-api.header-name}")
  private String headerKey;
  @Value("${ntss.coop-api.header-value}")
  private String headerValue;
  /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */

  // add 2021-04-07 課題No.1:SQL呼び出しを追加 孫 start
  /**
   * データセットService.
   */
  @Autowired
  private SysDataSetService sysDataSetService;
  // add 2021-04-07 課題No.1:SQL呼び出しを追加 孫 end
  // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
  @Autowired
  private JournalConvertReceiveResource doJournal;
  // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end
  // #8102-GX連携で実装されていない機能（処方情報連携） 周 add start
  /**
   * レコード継続指示(継続有り)
   */
  private final String CONTINUEFLAG_C = "C";

  private final int PREORD_OFFSET_BASEDATE = 124;
  // #8102-GX連携で実装されていない機能（処方情報連携） 周 add end
  /**
   * RestTemplate
   */
  private RestTemplate restTemplate;

  /**
   * コンストラクタ
   */
  public CallApiServiceImpl() {
    HttpComponentsClientHttpRequestFactory clientHttpRequestFactory = new HttpComponentsClientHttpRequestFactory();
    clientHttpRequestFactory.setReadTimeout(0);
    clientHttpRequestFactory.setConnectionRequestTimeout(0);
    restTemplate = new RestTemplate(clientHttpRequestFactory);
  }

  /**
   * 連携API関連付けに定義されているAPIの呼び出し。
   *
   * @param request           ジャーナル転送APIリクエスト
   * @param journal           外部連携用ジャーナル
   * @param afterApiStatusMap 処理後ステータスentity
   * @return 処理後続行可否
   */
  //mod #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start
  @Override
  public boolean callApiJournal(CallApiJournalRequest request, SysCoopJournal journal, Map<String, AfterApiStatus> afterApiStatusMap) {

    long startTime = System.currentTimeMillis();
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(request.getFacilityCd());

    // 連携API関連付けマスタを取得
    MstCoopApilink searchMstCoopApilink = new MstCoopApilink();
    BeanUtils.copyProperties(request, searchMstCoopApilink);
// add 2023-02-05 bug #7237 連携イベントが処理されないタイミングが存在する 孫 start
    String coopCdIndex = StringUtils.isEmpty(journal.getCoopCdIndex())?"":journal.getCoopCdIndex();
    searchMstCoopApilink.setCoopCdIndex(coopCdIndex);
// add 2023-02-05 bug #7237 連携イベントが処理されないタイミングが存在する 孫 end
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
    searchMstCoopApilink.setCoopVersion(coopVersion);
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // mod 2021-04-01 課題No.1:API連動設定（mst_coop_apilink）につてい、異常処理を追加する 孫 start
//    List<MstCoopApilink> mstCoopApilinkList = mstCoopApilinkDao.selectRelation(searchMstCoopApilink);
    List<MstCoopApilink> mstCoopApilinkList = new ArrayList<>();
    try {
      mstCoopApilinkList = mstCoopApilinkDao.selectRelation(searchMstCoopApilink);
    } catch (Exception ex) {
      eventLogMessage.setLogMessage("指定のジャーナルAPIに対応した連携API関連付けデータの取得に失敗しました。"
        + " facility_cd:[" + searchMstCoopApilink.getFacilityCd() + "]"
// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        + " coop_version:[" + coopVersion + "]"
// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        + " coop_cd:[" + searchMstCoopApilink.getCoopCd() + "]"
        + " coop_cd_index:[" + searchMstCoopApilink.getCoopCdIndex() + "]"
        + " crud:[" + searchMstCoopApilink.getCrud() + "]"
        + " direction:[" + searchMstCoopApilink.getDirection() + "]"
        + " api_timing_io:[" + searchMstCoopApilink.getApiTimingIo() + "]"
        + " api_timing_ba:[" + searchMstCoopApilink.getApiTimingBa() + "]"
        + " Message:[" + ex.getMessage() + "]");
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(eventLogMessage.getLogMessage());
    }
    // mod 2021-04-01 課題No.1:API連動設定（mst_coop_apilink）につてい、異常処理を追加する 孫 end
    // 転送指定なし
    if (CollectionUtils.isEmpty(mstCoopApilinkList)) {
      eventLogMessage.setLogMessage("$$$$$$callApiJournal 1.1 " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return true;
    }

    for (MstCoopApilink mstCoopApilink : mstCoopApilinkList) {
      // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
      if ("GX".equals(journal.getCoopVersion())) {
        if (CoopCdConstant.PROFILE.equals(request.getCoopCd())) {
          // mod 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
          // if (!("C".equals(doJournal.convertResultMap.get(patidd)) && mstCoopApilink.getApiBody().startsWith("{\"crud\": \"C\""))){
          //dumpの3文字目が"C"かつapilink設定が"{\"crud\": \"C\""始まり　の場合のみAPILINK処理を行う
          if (!(CONTINUEFLAG_C.equals(new String(journal.getDump(), 2, 1)) && mstCoopApilink.getApiBody().startsWith("{\"crud\": \"C\""))) {
            // mod 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end
            continue;
          }
        }
        // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end
        // #8102-GX連携で実装されていない機能（処方情報連携） 周 add start
        else if (CoopCdConstant.PRE_ORD.equals(request.getCoopCd())) {
          if(!CONTINUEFLAG_C.equals(new String(journal.getDump(), 2, 1))) {
            continue;
          } else {
            journal.setBaseDate(new String(journal.getDump(), PREORD_OFFSET_BASEDATE, 8));
          }
        }
      }
      // #8102-GX連携で実装されていない機能（処方情報連携） 周 add end
      // add 2021-04-02 課題No.1:API連動設定:SQL呼び出しを追加 孫 start
      // API種別をチェックする
      if (mstCoopApilink.getApiType() != null
        && NtssCoopApiConstants.ApiType.SQL.getValue().equals(mstCoopApilink.getApiType())) {
        // sqlの場合
        // 処理後続行可否
        boolean result = callApiJournalForSql(request, journal, mstCoopApilink);
        if (!result) {
          eventLogMessage.setLogMessage("$$$$$$callApiJournal 1.2 " + (System.currentTimeMillis() - startTime));
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          return false;
        }
      } else {
        // httpの場合
        // add 2021-04-02 課題No.1:API連動設定:SQL呼び出しを追加 孫 end

        // URI作成
        URI uri;
        StringBuilder builder = new StringBuilder(mstCoopApilink.getApiUri());

        // ヘッダ作成
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
        headers.set(headerKey, headerValue);
        /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */
        String apiBody = replaceApiBody(mstCoopApilink.getApiBody(), request, journal);

        try {
          uri = new URI(builder.toString());
        } catch (URISyntaxException use) {
          eventLogMessage.setLogMessage("連携API関連付けURLの生成に失敗しました。url:[" + builder + "]");
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
          eventLogMessage.setInvokeClass(this.getClass().getName());
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          throw new NtssException(eventLogMessage.getLogMessage());
        }
        //add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221020 start
        // #6993-profile連携で受信した生存の有無登録 周 20230204 mod start
        //if("1".equals(doJournal.isDieFlagResultMap.get(hospPatIdd)) && "profile".equals(request.getCoopCd()) && "R".equals(request.getDirection())){
        if (CoopCdConstant.PROFILE.equals(request.getCoopCd())
          && JournalConvertConstants.DIRECTION_RECEIVE.equals(request.getDirection())) {
          // #6993-profile連携で受信した生存の有無登録 周 20230204 mod end
          try {
            // リクエスト作成
            RequestEntity<?> req = new RequestEntity<>(apiBody, headers, HttpMethod.valueOf(mstCoopApilink.getApiMethod()), uri);
            // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
			long start = System.currentTimeMillis();
            // リクエスト処理
            ResponseEntity<?> response = restTemplate.exchange(req, String.class);
            long cost = System.currentTimeMillis() - start;
            Map<String, Object> map = new HashMap<>();
            map.put("logType", "RESTTEMPLATE-LOG");
            map.put("className", "jp.co.nikkiso.ntss.coop_api.service.CallApiServiceImpl");
            map.put("methodName", "callApiJournal");
            map.put("method", req.getMethod());
            map.put("url", req.getUrl());
            map.put("headers", req.getHeaders().toSingleValueMap());
            map.put("requestParameter", req.getBody());
            map.put("status",response.getStatusCode());
            map.put("cost", cost);
            map.put("result",response.getBody());
            EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
            if(searchMstCoopApilink != null && !StringUtils.isEmpty(searchMstCoopApilink.getFacilityCd())){
              restTemplateEventLogMessage.setFacilityCd(searchMstCoopApilink.getFacilityCd());
            }
            restTemplateEventLogMessage.setLogMessage(toJson(map));
            logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
            eventLogMessage.setLogMessage("連携API関連付け呼び出し結果:" + response);
            eventLogMessage.setInvokeClass(this.getClass().getName());
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            // 処理後続行可否
            boolean result = false;
            for (Integer continueProcessCode : mstCoopApilink.getContinueApiStatus().getContinueCode()) {
              if (continueProcessCode == response.getStatusCode().value()) {
			  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
                result = true;
              }
            }
            if (afterApiStatusMap != null && (mstCoopApilink.getAfterApiStatus().getAnaResult() != null || mstCoopApilink.getAfterApiStatus().getCoopResult() != null)) {
              afterApiStatusMap.put("afterApiStatus", mstCoopApilink.getAfterApiStatus());
            }
            if (!result) {
              eventLogMessage.setLogMessage("$$$$$$callApiJournal 1.3 " + (System.currentTimeMillis() - startTime));
              logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              return false;
            }
          } catch (Exception ex) {
            eventLogMessage.setLogMessage("連携API関連付けの呼び出しに失敗しました。"
              + " api_uri:[" + mstCoopApilink.getApiUri() + "]"
              + " api_method:[" + mstCoopApilink.getApiMethod() + "]"
              + " api_body:[" + apiBody + "]"
              + " Message:[" + ex.getMessage() + "]");
            eventLogMessage.setInvokeClass(this.getClass().getName());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            throw new NtssException(eventLogMessage.getLogMessage());
          }

        } else {
          //add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221020 end
          // add 2021-04-01 課題No.1:API連動設定（mst_coop_apilink）につてい、異常処理を追加する 孫 start
          try {
            // add 2021-04-01 課題No.1:API連動設定（mst_coop_apilink）につてい、異常処理を追加する 孫 end
			// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
            long start = System.currentTimeMillis();
            // リクエスト作成
            RequestEntity<?> req = new RequestEntity<>(apiBody, headers, HttpMethod.valueOf(mstCoopApilink.getApiMethod()), uri);
            // リクエスト処理
            ResponseEntity<?> response = restTemplate.exchange(req, String.class);
            // log start
            long cost = System.currentTimeMillis() - start;
            Map<String, Object> map = new HashMap<>();
            map.put("logType", "RESTTEMPLATE-LOG");
            map.put("className", "jp.co.nikkiso.ntss.alive_moni.service.util.NtssComIOServiceImpl");
            map.put("methodName", "callApiJournal");
            map.put("method", req.getMethod());
            map.put("url", req.getUrl());
            map.put("headers", req.getHeaders().toSingleValueMap());
            map.put("requestParameter", req.getBody());
            map.put("status",response.getStatusCode());
            map.put("cost", cost);
            map.put("result",response.getBody());
            EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
            restTemplateEventLogMessage.setLogMessage(toJson(map));
            if(searchMstCoopApilink != null && !StringUtils.isEmpty(searchMstCoopApilink.getFacilityCd())){
              restTemplateEventLogMessage.setFacilityCd(searchMstCoopApilink.getFacilityCd());
            }
            logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
            // log end
            eventLogMessage.setLogMessage("連携API関連付け呼び出し結果:" + response);
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
            eventLogMessage.setInvokeClass(this.getClass().getName());
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

            // 処理後続行可否
            boolean result = false;

            for (Integer continueProcessCode : mstCoopApilink.getContinueApiStatus().getContinueCode()) {
              if (continueProcessCode == response.getStatusCode().value()) {
			  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
                result = true;
              }
            }

            if (afterApiStatusMap != null && (mstCoopApilink.getAfterApiStatus().getAnaResult() != null || mstCoopApilink.getAfterApiStatus().getCoopResult() != null)) {
              afterApiStatusMap.put("afterApiStatus", mstCoopApilink.getAfterApiStatus());
            }

            if (!result) {
              eventLogMessage.setLogMessage("$$$$$$callApiJournal 1.5 " + (System.currentTimeMillis() - startTime));
              logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              return false;
            }

            // add 2021-04-01 課題No.1:API連動設定（mst_coop_apilink）につてい、異常処理を追加する 孫 start
          } catch (Exception ex) {
            eventLogMessage.setLogMessage("連携API関連付けの呼び出しに失敗しました。"
              + " api_uri:[" + mstCoopApilink.getApiUri() + "]"
              + " api_method:[" + mstCoopApilink.getApiMethod() + "]"
              + " api_body:[" + apiBody + "]"
              + " Message:[" + ex.getMessage() + "]");
            eventLogMessage.setInvokeClass(this.getClass().getName());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            throw new NtssException(eventLogMessage.getLogMessage());
          }
          //add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221020 start
        }
        //add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221020 end
        // add 2021-04-02 課題No.1:API連動設定:SQL呼び出しを追加 孫 start
      }
      // add 2021-04-02 課題No.1:API連動設定:SQL呼び出しを追加 孫 end
      // add 2021-04-01 課題No.1:API連動設定（mst_coop_apilink）につてい、異常処理を追加する 孫 end
    }

    eventLogMessage.setLogMessage("$$$$$$callApiJournal end " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return true;
  }
  //mod #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end
  // add 2021-04-02 課題No.1:API連動設定:SQL呼び出しを追加 孫 start

  /**
   * 連携API関連付けに定義されているAPIの呼び出し(SQL)。
   *
   * @param request        ジャーナル転送APIリクエスト
   * @param journal        外部連携用ジャーナル
   * @param mstCoopApilink 連携API関連付け
   * @return 処理後続行可否
   */
  private boolean callApiJournalForSql(CallApiJournalRequest request, SysCoopJournal journal, MstCoopApilink mstCoopApilink) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(request.getFacilityCd());

    LayoutExtSetting sqlSetting = mstCoopApilink.getSqlSetting();
    if (sqlSetting == null || !sqlSetting.containsKey("dataset")) {
      eventLogMessage.setLogMessage("連携API関連付けのsql設定が不正です。[sqlSettingがnull、または、key[dataset]が無し]"
        + " ctl_no:[" + mstCoopApilink.getCtlNo() + "]"
        + " sql_setting:[" + sqlSetting.toString() + "]");
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(eventLogMessage.getLogMessage());
    }

    try {
      // sqlSettingをループ、"dataset"を取得する
      for (Map.Entry<String, Object> keyValue : sqlSetting.entrySet()) {
        // dataset情報じゃなかったらスキップ
        if (!keyValue.getKey().equals("dataset")) continue;

        // 本当であればmapping用クラスを作成し読み込みたいが、layoutExtSettingがHashMapで分離されていることから一番コストが少ない未検査キャストで行う
        List<Map<String, Object>> dataSetList = cast(keyValue.getValue());

        // "dataset"のSQLをループ
        for (Map<String, Object> dataSetMap : dataSetList) {
          //datasetのKEY値のnullチェックを行う
          checkDatasetValue(dataSetMap);

          // sqlCodeが有りか？
          Long sqlCode = null;
          if (dataSetMap.containsKey("sqlCode")) {
            sqlCode = Long.valueOf(dataSetMap.get("sqlCode").toString());
          }
          // sqlCrudが有りか？
          String sqlCrud = null;
          if (dataSetMap.containsKey("sqlCrud")) {
            sqlCrud = dataSetMap.get("sqlCrud").toString();
          }
          // continueConditionが有りか？
          String[] continueCondition = null;
          if (dataSetMap.containsKey("continueCondition")) {
            continueCondition = dataSetMap.get("continueCondition").toString().split(",");
          }

          // sqlCode,sqlCrud,continueConditionが有りか？
          if (sqlCode == null || sqlCrud == null || continueCondition == null || continueCondition.length == 0) {
            eventLogMessage.setLogMessage("連携API関連付けのsql設定が不正です。[datasetのkey[sqlCode,sqlCrud,continueCondition]が無し]"
              + " ctl_no:[" + mstCoopApilink.getCtlNo() + "]"
              + " sql_setting:[" + sqlSetting.toString() + "]");
            eventLogMessage.setInvokeClass(this.getClass().getName());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            throw new NtssException(eventLogMessage.getLogMessage());
          }
          // sqlCrudがC,S,U,Dか
          if (!"C".equals(sqlCrud) && "S".equals(sqlCrud) && "U".equals(sqlCrud) && "D".equals(sqlCrud)) {
            eventLogMessage.setLogMessage("連携API関連付けのsql設定が不正です。[sqlCrudは[C,S,U,D]に設定されていません。]"
              + " ctl_no:[" + mstCoopApilink.getCtlNo() + "]"
              + " sql_setting:[" + sqlSetting.toString() + "]");
            eventLogMessage.setInvokeClass(this.getClass().getName());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            throw new NtssException(eventLogMessage.getLogMessage());
          }
          // continueConditionが0,1,Nか
          for (int i = 0; i < continueCondition.length; i++) {
            if (!"0".equals(continueCondition[i]) && !"1".equals(continueCondition[i]) && !"N".equals(continueCondition[i])) {
              eventLogMessage.setLogMessage("連携API関連付けのsql設定が不正です。[continueConditionは[0,1,N]に設定されていません。]"
                + " ctl_no:[" + mstCoopApilink.getCtlNo() + "]"
                + " sql_setting:[" + sqlSetting.toString() + "]");
              eventLogMessage.setInvokeClass(this.getClass().getName());
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              throw new NtssException(eventLogMessage.getLogMessage());
            }
          }

          Map<String, Object> dataSetMapForSql = new HashMap<>();
          for (String key : dataSetMap.keySet()) {
            if (!dataSetMapForSql.containsKey(key) && dataSetMap.get(key) != null) {
              dataSetMapForSql.put("@" + key, dataSetMap.get(key));
            }
          }
          // 外部連携用ジャーナルを流用する
          Map<String, Object> journalMap = Object2Map(journal);
          for (String key : journalMap.keySet()) {
            if (!dataSetMapForSql.containsKey(key) && journalMap.get(key) != null) {
              dataSetMapForSql.put("@" + key, journalMap.get(key));
            }
          }
          // ジャーナル転送APIリクエストを流用する
          Map<String, Object> requestMap = Object2Map(request);
          for (String key : requestMap.keySet()) {
            if (!dataSetMapForSql.containsKey(key) && requestMap.get(key) != null) {
              dataSetMapForSql.put("@" + key, requestMap.get(key));
            }
          }

          String sqlResult = null;
          if ("C".equals(sqlCrud)) {
            // insertの場合
            int dataCnt = sysDataSetService.insertData(sqlCode, dataSetMapForSql, null);
            sqlResult = ConvertDataCnt(dataCnt);
          } else if ("S".equals(sqlCrud)) {
            // selectの場合
            List<Map<String, Object>> dataList = sysDataSetService.getDataList(sqlCode, dataSetMapForSql);
            sqlResult = ConvertDataCnt(dataList.size());
          } else if ("U".equals(sqlCrud)) {
            // updateの場合
            int dataCnt = sysDataSetService.updateData(sqlCode, dataSetMapForSql, null);
            sqlResult = ConvertDataCnt(dataCnt);
          } else if ("D".equals(sqlCrud)) {
            // deleteの場合
            int dataCnt = sysDataSetService.deleteData(sqlCode, dataSetMapForSql, null);
            sqlResult = ConvertDataCnt(dataCnt);
          }

          // 処理後続行可否
          boolean result = false;
          for (String continueCode : continueCondition) {
            if (continueCode.equals(sqlResult)) {
              result = true;
            }
          }

          if (!result) {
            return false;
          }
        }
      }
    } catch (Exception ex) {
      eventLogMessage.setLogMessage("連携API関連付けの呼び出しに失敗しました。 message:[" + ex.getMessage() + "], "
        + " ctl_no:[" + mstCoopApilink.getCtlNo() + "]"
        + " sql_setting:[" + sqlSetting.toString() + "]");
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(eventLogMessage.getLogMessage());
    }

    return true;
  }

  /**
   * Object2Map
   *
   * @param object
   * @return Map<String, Object>
   */
  public Map<String, Object> Object2Map(Object object) throws IllegalAccessException {
    Map<String, Object> result = new HashMap<String, Object>();

    Field[] fields = object.getClass().getDeclaredFields();
    for (Field field : fields) {
      field.setAccessible(true);

      // カラム名を取得する
      String name = new String(field.getName());

      // 値を取得する
      Object obj = field.get(object);

      if (obj instanceof String) {
        result.put(name, DataUpdateLogInfoUtil.convertString(obj));
      } else if (obj instanceof Integer) {
        result.put(name, (Integer) obj);
      } else if (obj instanceof Long) {
        result.put(name, (Long) obj);
      } else if (obj instanceof Timestamp) {
        result.put(name, (Timestamp) obj);
      } else if (obj instanceof List) {
        List list = (List) obj;
        int mapNumber = 0;
        List<Map<String, Object>> listObj = new ArrayList<>();
        for (Object obj0 : list) {
          Map<String, Object> tempMap = Object2Map(obj0);
          listObj.add(tempMap);
        }
        result.put(name, listObj);
      } else {
        result.put(name, obj);
      }
    }
    return result;
  }

  /**
   * 処理継続条件変換
   *
   * @param String
   */
  private String ConvertDataCnt(int dataCnt) {
    // データ件数「0:0件、1:1件、N:複数件」
    if (dataCnt == 0) {
      return "0";
    } else if (dataCnt == 1) {
      return "1";
    } else {
      return "N";
    }
  }

  /**
   * 未検査キャスト用メソッド
   *
   * @param target - キャスト対象
   * @return T
   */
  @SuppressWarnings("unchecked")
  private <T> T cast(Object target) {
    T castTarget = (T) target;
    return castTarget;
  }

  /**
   * datasetのKEY値のnullチェックを行う
   *
   * @param dataSetMap
   */
  private void checkDatasetValue(Map<String, Object> dataSetMap) {
    for (Map.Entry<String, Object> entrySet : dataSetMap.entrySet()) {
      if (StringUtils.isEmpty(entrySet.getValue())) {
        throw new NtssException("datasetのKEY値がnullです。 KEY:[" + entrySet.getKey() + "]");
      }
    }
  }
  // add 2021-04-02 課題No.1:API連動設定:SQL呼び出しを追加 孫 end

  /**
   * リクエストbodyentityの項目の指定文字列を置換する。
   *
   * @param apiBody        リクエストbodyentity
   * @param request        リクエスト
   * @param sysCoopJournal ジャーナル
   * @return 変換後ApiBody文字列
   */
  private String replaceApiBody(String apiBody, CallApiJournalRequest request, SysCoopJournal sysCoopJournal) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(request.getFacilityCd());
// add 2023-01-06 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    String coopVersionKey = "coop_version";
// add 2023-01-06 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    try {
      Class<SysCoopJournal> journalClass = SysCoopJournal.class;
      Class<CallApiJournalRequest> requestClass = CallApiJournalRequest.class;

      // add 9317 mst_coop_apilinkのapi_bodyに解析ロジックを追加すること 20230804 zhaoqi start
      JavaType colType2 = ObjectMapperUtil.constructMapType(String.class, Object.class);
      Map<String, Object> apiBodyMap2 = ObjectMapperUtil.read(apiBody, colType2);
      // add 9317 mst_coop_apilinkのapi_bodyに解析ロジックを追加すること 20230804 zhaoqi end

      // del 9317 mst_coop_apilinkのapi_bodyに解析ロジックを追加すること 20230804 zhaoqi start
//      JavaType colType = ObjectMapperUtil.constructMapType(String.class, String.class);
//      Map<String, String> apiBodyMap = ObjectMapperUtil.read(apiBody, colType);
      // del 9317 mst_coop_apilinkのapi_bodyに解析ロジックを追加すること 20230804 zhaoqi end
      for (Map.Entry<String, Object> apiBodyEntry : apiBodyMap2.entrySet()) {
// add 2023-01-06 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        if (coopVersionKey.equals(apiBodyEntry.getKey()) && apiBodyEntry.getValue() == null) {
          continue;
        }

        // add 9317 mst_coop_apilinkのapi_bodyに解析ロジックを追加すること 20230804 zhaoqi start
        if(apiBodyEntry.getValue() instanceof Map){
          Map<String, Object> dataMap = (Map<String, Object>) apiBodyEntry.getValue();
          for(Map.Entry<String, Object> dataMapEntry : dataMap.entrySet()){
            String snakeEntityName = dataMapEntry.getValue().toString().replace("$JOURNAL.", "");
            String camelEntityName = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.UPPER_CAMEL, snakeEntityName);
            try {
              Method method = journalClass.getMethod("get" + camelEntityName);
              String replaceItemBody = method.invoke(sysCoopJournal).toString();
              dataMapEntry.setValue(replaceItemBody);
            } catch (Exception me) {
              eventLogMessage.setLogMessage("項目：[" + snakeEntityName + "]の変換に失敗しました。" + me.getMessage());
              eventLogMessage.setInvokeClass(this.getClass().getName());
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            }
          }
          continue;
        }
        // add 9317 mst_coop_apilinkのapi_bodyに解析ロジックを追加すること 20230804 zhaoqi end

// add 2023-01-06 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        // ジャーナルから取得
        if (sysCoopJournal != null && apiBodyEntry.getValue().toString().contains("$JOURNAL.")) {
          String snakeEntityName = apiBodyEntry.getValue().toString().replace("$JOURNAL.", "");
          String camelEntityName = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.UPPER_CAMEL, snakeEntityName);
          try {
            Method method = journalClass.getMethod("get" + camelEntityName);
            String replaceItemBody = method.invoke(sysCoopJournal).toString();
            apiBodyEntry.setValue(replaceItemBody);
          } catch (Exception me) {
            eventLogMessage.setLogMessage("項目：[" + snakeEntityName + "]の変換に失敗しました。" + me.getMessage());
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
            eventLogMessage.setInvokeClass(this.getClass().getName());
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          }
        }
        // リクエストから取得
        if (request != null && apiBodyEntry.getValue().toString().contains("$REQUEST.")) {
          String snakeEntityName = apiBodyEntry.getValue().toString().replace("$REQUEST.", "");
          String camelEntityName = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.UPPER_CAMEL, snakeEntityName);
          try {
            Method method = requestClass.getMethod("get" + camelEntityName);
            String replaceItemBody = method.invoke(request).toString();
            apiBodyEntry.setValue(replaceItemBody);
          } catch (Exception me) {
            eventLogMessage.setLogMessage("項目：[" + snakeEntityName + "]の変換に失敗しました。" + me.getMessage());
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
            eventLogMessage.setInvokeClass(this.getClass().getName());
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          }
        }
      }
// add 2023-01-06 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      // ジャーナルの連携版番号より、apiBodyに連携版番号(coop_version )を追加する。
      String coopVersionValue = StringUtils.isEmpty(sysCoopJournal.getCoopVersion()) ? "" : sysCoopJournal.getCoopVersion();
      if (apiBodyMap2.containsKey(coopVersionKey)) {
        if (apiBodyMap2.get(coopVersionKey) == null) {
          apiBodyMap2.replace(coopVersionKey, coopVersionValue);
        }
      } else {
        apiBodyMap2.put(coopVersionKey, coopVersionValue);
      }
// add 2023-01-06 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      apiBody = ObjectMapperUtil.write(apiBodyMap2);
    } catch (IOException ioe) {
      eventLogMessage.setLogMessage("連携API関連付けリクエストBODYの変換処理に失敗しました。");
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    return apiBody;
  }
}
