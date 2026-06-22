package jp.co.nikkiso.ntss.coop_api.web.rest;

import java.io.UnsupportedEncodingException;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.api.model.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.api.service.deathRelatedProcess.DeathService;
import jp.co.nikkiso.ntss.coop_api.response.JournalNotificationResult;
import jp.co.nikkiso.ntss.coop_api.service.ConvertByFormatService;
import jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService;
import jp.co.nikkiso.ntss.coop_api.service.CoopJournalErrorComponent;
import jp.co.nikkiso.ntss.coop_api.service.HealthService;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.coop_api.service.PatientCaptureService;
import jp.co.nikkiso.ntss.coop_api.service.RegisterService;
import jp.co.nikkiso.ntss.coop_api.service.notification.JournalReceiveNotificationService;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.CoopCdConstant;
import jp.co.nikkiso.ntss.coop_api.utils.CoopIniConvUtil;
import jp.co.nikkiso.ntss.coop_api.utils.CoopMstConvUtil;
import jp.co.nikkiso.ntss.coop_api.utils.DateUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.Key0Constant;
import jp.co.nikkiso.ntss.coop_api.utils.NotificationApiCallUtil;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants;
import jp.co.nikkiso.ntss.coop_api.utils.PatInfoConstant;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopIniDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstExamItemDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.PatCoopDetailDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.PatCoopDetail;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.utils.NtssUtils;
import lombok.Data;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Async;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.SerializationFeature;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.request.JournalConvertReceiveRequest;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultKey;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultMap;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import lombok.extern.slf4j.Slf4j;

import static org.springframework.util.StringUtils.hasLength;


/**
 * ジャーナル受信変換処理のエンドポイントクラス。
 */
@RestController
@RequestMapping("/journal")
@Slf4j
public class JournalConvertReceiveResource {
  /* del by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --start */
  // 定数の定義がConvertCommonServiceImplに移行されました
  // 1電文に複数の患者が含まれる時の区切り文字
//  /** 特殊値: CR */
//  private static final String TELEGRAM_DELIM_CR = "CR";
//
//  /** CR指定に対応する区切り文字 */
//  private static final String TELEGRAM_DELIM_CR_VALUE = "\r";
//
//  /** 特殊値: LF */
//  private static final String TELEGRAM_DELIM_LF = "LF";
//
//  /** LF指定に対応する区切り文字 */
//  private static final String TELEGRAM_DELIM_LF_VALUE = "\n";
//
//  // 正規表現文字列
//  /** レイアウト中のmulti指定の引数を分割する正規表現 */
//  private static final String LAYOUT_MULTI_DELIM = "[:/]";

  // #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 add start
  private static final String JSONARRAY_EMPTY = "[]";
  // #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 add end

  // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 20221220 add start
  private static final String TIMEOUT_MSG = "電文変換処理タイムアウトのため、該当ジャーナルデータの変換ステータスをE1に更新し次の電文変換に移ります。";
  // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 20221220 add end

  // #8750-検査結果の登録が行われない 周 add start
  private static final String EXAM_DETAIL_ITEMCD = "$journal.detail.pat_exam_main.exam_result_info.item_cd";
  // #8750-検査結果の登録が行われない 周 add end
  // 9415-NKK連携 exam_rst 必須項目が空白の場合の処理・メッセージが正しくない zhoubin add start
  private static final String EXAM_RST_REGORDERCLASS = "$journal.pat_exam_main.reg_order_class";
  private static final String EXAM_RST_HOSPPATID = "$journal.pat_personal_main.hosp_pat_id";
  // add #9829 NKK連携 exam_rst 採取時刻が空白の場合、00:00で検査結果がとりこまれる 孟堅　20230921　 start
  private static final String EXAM_RST_RESULT_EXAM_DATE = "$journal.pat_exam_main.result_exam_date";
  // add #9829 NKK連携 exam_rst 採取時刻が空白の場合、00:00で検査結果がとりこまれる 孟堅　20230921　 end
  private static final String EXAM_RST_NAME_DATE = "採取日";
  private static final String EXAM_RST_NAME_REGORDERCLASS = "透析前後";
  private static final String EXAM_RST_NAME_HOSPPATID = "患者ID";
  // add #9829 NKK連携 exam_rst 採取時刻が空白の場合、00:00で検査結果がとりこまれる 孟堅　20230921　 start
  private static final String EXAM_RST_NAME_RESULTEXAMDATE="採取時刻";
  // add #9829 NKK連携 exam_rst 採取時刻が空白の場合、00:00で検査結果がとりこまれる 孟堅　20230921　 end
  private static final String EXAM_RST_EMPTY_MSG_HEAD = "必須項目[";
  private static final String EXAM_RST_EMPTY_MSG_TAIL = "]がありません";

  private static final String STR_TOUTEN = "、";

  private static final int EXAM_RST_DATE_OFFSET = 8;
  private static final int EXAM_RST_DATE_LEN = 8;
  // 9415-NKK連携 exam_rst 必須項目が空白の場合の処理・メッセージが正しくない zhoubin add end
  // 9428-NKK連携 exam_rst 連携設定 死亡・転出患者取込設定がない zhoubin add start
  private static final String KEY1_EXAMINRCV = "EXAMINRCV";
  private static final String KEY2_DIEOUTMODE = "DIE_OUT_MODE";
  // 9428-NKK連携 exam_rst 連携設定 死亡・転出患者取込設定がない zhoubin add end
  private static final int ANALYSIS_ELAPSED_MINUTES = 3;
  private static final int ANALYSIS_SLEEP_MILLIS = 300;

//  /** グループ開始 */
//  private static final String REGEXP_GROUP_START = "(";
//
//  /** グループ終了 */
//  private static final String REGEXP_GROUP_END = ")";
//
//  /** グループ内選択 */
//  private static final String REGEXP_GROUP_OR = "|";
  /* del by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --end */
  // del  #8292 exam_rst連携で受信した検査データの登録ができない 20230203 孟堅　start
  // add 7391 exam_rst連携で受信した検査項目コード  吉 start
  // private String examHospitalCd = "";
  // add 7391 exam_rst連携で受信した検査項目コード  吉 end
  // del  #8292 exam_rst連携で受信した検査データの登録ができない 20230203 孟堅　start
  @Autowired
  private ConvertCommonService convertCommonService;

  @Autowired
  private ConvertByFormatService convertCsvServiceImpl;

  @Autowired
  private ConvertByFormatService convertTextServiceImpl;

  @Autowired
  private ConvertByFormatService convertXmlServiceImpl;

  @Autowired
  private RegisterService registerService;

  @Autowired
  private LogService logService;
      // add FNSI-改修内容 新規患者登録時の各テーブルの初期値登録＆スクリプト走査 dou start
  @Autowired
  private PatientCaptureService patientCaptureService;

  // #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 add start
  @Autowired
  private PatUniqueDao patUniqueDao;
  // #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 add end
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
      // add FNSI-改修内容 新規患者登録時の各テーブルの初期値登録＆スクリプト走査 dou end
  // add 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 start
  @Autowired
  private SysCoopJournalDao sysCoopJournalDao;
  // add 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 end
  // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
  @Autowired
  private NotificationApiCallUtil notificationApiCallUtil;
  // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

  // add 2021-07-06 #5248:処理キャンセルのしくみ 孫 start
  @Autowired
  private MstCoopFacilityDao mstCoopFacilityDao;
  // add 2021-07-06 #5248:処理キャンセルのしくみ 孫 end

  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  // #5607-連動機能の実装確認 周 20230410 add start
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  // #5607-連動機能の実装確認 周 20230410 add end

  // add 2021-12-28 院内コードから本システムコードへの変換の対応 孫 start
  @Autowired
  private CoopMstConvUtil coopMstConvUtil;
  // add 2021-12-28 院内コードから本システムコードへの変換の対応 孫 end

  // add 7391 exam_rst連携で受信した検査項目コード  吉 start
  @Autowired
  private MstExamItemDao mstExamItemDao;

  /* del by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  /**
   * 削除理由：
   *   スレッドセーフの問題が存在したため、該当の変数をメソッド内に移動しました
   */
  // private Map<String,String> examItemMap = new HashMap<String,String>();
  /* del by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
  // add 7391 exam_rst連携で受信した検査項目コード  吉 end

  //add 5607 感染症更新通知 gaoey start
  @Autowired
  private PatMainDao patMainDao;
  //add 5607 感染症更新通知 gaoey end

  // add FNSI7302-ini_dial連携で異常な電文を受信しても正常応答（OK）する 周 start
  @Autowired
  private MstCoopLayoutDao mstCoopLayoutDao;
  // add FNSI7302-ini_dial連携で異常な電文を受信しても正常応答（OK）する 周 end

  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
  @Autowired(required = false)
  MongoTemplate mongoTemplate;
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end

  // add #7717 浄化申込の削除を受信した患者の動作について 王永吉 start
  @Autowired
  PatCoopDetailDao patCoopDetailDao;
  @Autowired
  MstCoopIniDao mstCoopIniDao;
  @Autowired
  JournalReceiveNotificationService  journalReceiveNotificationService;

  // add 9583 by kangjie 20240410 start 通知一覧の連携エラー通知の遷移不正
  @Autowired
  CoopJournalErrorComponent coopJournalErrorComponent;
  // add 9583 by kangjie 20240410 end 通知一覧の連携エラー通知の遷移不正

  // #10453 add 死活監視が動作していない 2024-05-16 荘 start
  @Autowired
  HealthService healthService;
  // #10453 add 死活監視が動作していない 2024-05-16 荘 end

  // add #7717 浄化申込の削除を受信した患者の動作について 王永吉 end
  //add #10901 死亡患者受信時処理について zrx start
  @Autowired
  DeathService deathService;
  //add #10901 死亡患者受信時処理について zrx end

  @Autowired
  private ClockWrapper clockWrapper;

  /* add by chamaojia 2025-03-31 [11637] add thread safe map definition --start */
  private Map<String, String> facilityStatusMap = new ConcurrentHashMap<>();
  /* add by chamaojia 2025-03-31 [11637] add thread safe map definition --end */

//del #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start
//  // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
//  public ConcurrentHashMap<Long, String> convertResultMap = new ConcurrentHashMap<>();
//  public ConcurrentHashMap<Object, String> isDieFlagResultMap = new ConcurrentHashMap<>();
//  // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end
//
//  //mod 6993 【デグレ】profile連携で受信した生存の有無登録 20221123 zhaoqi start
//  //add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221020 start
//  public List<SysCoopJournalExtends> scList;
//  public List<SysCoopJournalExtends> scForCheckList;
//  //add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221020 end
//  //mod 6993 【デグレ】profile連携で受信した生存の有無登録 20221123 zhaoqi end
//del #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end


  // add 2023-03-08 bug #8424 バックアップファイルのOK/NGフォルダへの移動 孫 start
  /**
   * 取得変換処理結果(/journal/convert/get_convert_result)
   *
   * @param request {@link JournalConvertReceiveRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/convert/get_convert_result")
  public ResponseEntity<?> GetConvertResult(@RequestBody JournalConvertReceiveRequest request) {
    try {
      List<Long> ctlNoList = request.getCtlNoList();
      /* modify by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --start */
//      SysCoopJournal coopJournal = sysCoopJournalDao.selectByPK(ctlNoList.get(0));
      // 分割電文が存在するため、一括クエリ
      List<SysCoopJournal> sysCoopJournalList = sysCoopJournalDao.selectByCtlNoList(ctlNoList);

      if (null == sysCoopJournalList || sysCoopJournalList.size() == 0) {
        String errMsg = String.format("[外部連携用ジャーナル]中の番号が[%d]のデータは存在しません。", ctlNoList);
        throw new NtssException(errMsg);
      }

//      // 変換処理結果を取得する
//      String result = coopJournal.getAnaResult();
      // add 2023-03-29 bug #8424 バックアップファイルのOK/NGフォルダへの移動 孫 start
      // 9: 処理に成功しました  1: 処理中  E:処理に失敗しました
      String resultCoop = "9";
      for (SysCoopJournal coopJournal : sysCoopJournalList) {
        if ("0".equals(coopJournal.getAnaResult()) || "1".equals(coopJournal.getAnaResult())) {
          resultCoop = "1";
          break;
        } else if ("9".equals(coopJournal.getAnaResult())) {
          // 処理不要
        } else {
          resultCoop = "E";
          break;
        }
      }
//      if (!NtssCoopApiConstants.CoopResult.DONE.getResult().equals(resultCoop)) {
//        result = String.format("CoopResult=[%s]",resultCoop);
//      }
      // add 2023-03-29 bug #8424 バックアップファイルのOK/NGフォルダへの移動 孫 end
      return new ResponseEntity<>(resultCoop, HttpStatus.OK);
      /* modify by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --end */
    } catch (Exception e) {
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }
  // add 2023-03-08 bug #8424 バックアップファイルのOK/NGフォルダへの移動 孫 end

  /**
   * 変換処理(/journal/convert)
   *
   * @param request {@link JournalConvertReceiveRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/convert/receive")
  public ResponseEntity<?> convert(@RequestBody JournalConvertReceiveRequest request) {
    String facilityCd = request.getFacilityCd();
    if (StringUtils.isEmpty(facilityCd)) {
      String error = String.format("リクエストパラメータが不正または不足しています。facility_cd:[%s]", facilityCd);
      JournalConvertResult result = new JournalConvertResult(HttpStatus.BAD_REQUEST.value(), error);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      // ログメッセージ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setLogMessage(error);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end

      // パラメータ不正(施設コードが無し)の場合、通知機能API（NotificationApiCallUtil）を呼び出さない

      return new ResponseEntity<>(result, HttpStatus.BAD_REQUEST);
    }

    // ana_result=1のまま処理が進まないジャーナルがあるかチェック
    SysCoopJournal stoppedJournal = sysCoopJournalDao.selectByAnalysisElapsedTime(facilityCd, ANALYSIS_ELAPSED_MINUTES);
    if (stoppedJournal != null) {
      Long stoppedCtlNo = stoppedJournal.getCtlNo();
      try {
        // 処理が進まないジャーナルのana_resultをE1に変更
        updateAnaResultByCtlNo(stoppedCtlNo, TIMEOUT_MSG, AnaResult.INTERNAL_ERROR.getResult());

        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(String.format("受信電文の解析に失敗しました。該当ジャーナルデータの変換ステータスをE1に更新します。 facility_cd:[%s], ctl_no:[%s]",
        facilityCd, stoppedCtlNo));
        eventLogMessage.setFacilityCd(facilityCd);
        eventLogMessage.setInvokeClass(this.getClass().getName());
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      } catch (Exception e) {
        //何もしない
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(String.format("sys_coop_journalテーブルの更新に失敗しました。 facility_cd:[%s], ctl_no:[%s]",
        facilityCd, stoppedCtlNo));
        eventLogMessage.setFacilityCd(facilityCd);
        eventLogMessage.setInvokeClass(this.getClass().getName());
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        eventLogMessage.setLogMessage(e.getClass().getName() + ":" + e.getMessage());
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }

    /* add by chamaojia 2025-03-31 [11637] add concurrent restriction logic --start */
    ResponseEntity returnResponse;
    boolean isRunning = getRunningStatus(facilityCd);
    try {
      // determine whether there is an ongoing task being executed
      if (isRunning) {
        String message = "there is an ongoing task that will not be executed this time";

        JournalConvertResult result = new JournalConvertResult(HttpStatus.OK.value(), message);
        returnResponse = new ResponseEntity<>(result, HttpStatus.OK);
      } else {
        //ループで処理完了したら次の対象を取得
        while (true) {
          // 変換対象ジャーナル取得
          List<SysCoopJournal> journalList = convertCommonService.getJournalList(request.getFacilityCd()
            , JournalConvertConstants.DIRECTION_RECEIVE
            , NtssCoopApiConstants.CoopResult.DONE.getResult()
            , null, null, null);
          // 対象ジャーナルが1件も存在しない場合break
          if (CollectionUtils.isEmpty(journalList)) {
            String message = String.format("変換対象ジャーナル 0件でした。facility_cd:[%s]", facilityCd);

            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setFacilityCd(facilityCd);
            eventLogMessage.setLogMessage(message);
            eventLogMessage.setInvokeClass(this.getClass().getName());
            logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);

            JournalConvertResult result = new JournalConvertResult(HttpStatus.OK.value(), message);
            returnResponse = new ResponseEntity<>(result, HttpStatus.OK);
            break;
          }
          returnResponse = convertRun(request);

          if (!HttpStatus.OK.equals(returnResponse.getStatusCode())){
            break;
          } 
        }
      }
    } catch (Exception e) {
      String error = NtssUtils.ExcetionStackTraceToString(e);
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setLogMessage(error);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      JournalConvertResult result = new JournalConvertResult(HttpStatus.INTERNAL_SERVER_ERROR.value(), error);
      returnResponse = new ResponseEntity<>(result, HttpStatus.INTERNAL_SERVER_ERROR);
    } finally {
      if (!isRunning) {
        //　施設ステータスに「停止(stop)」を設定する
        facilityStatusMap.put(request.getFacilityCd(), JournalConvertConstants.STATUS_STOP);
      }
    }
    return returnResponse;
    /* add by chamaojia 2025-03-31 [11637] add concurrent restriction logic --end */
  }

  /* add by chamaojia 2025-03-31 [11637] add new method --start */
  /**
   * determine whether there is an ongoing task being executed
   * @param facilityCd
   * @return  true:running
   */
  private synchronized boolean getRunningStatus(String facilityCd) {
    // 施設ステータスをチェックする
    if (facilityStatusMap.containsKey(facilityCd)) {
      // 施設がありの場合、施設ステータスをチェックする
      if (JournalConvertConstants.STATUS_START.equals(facilityStatusMap.get(facilityCd))) {
        // 施設が「実行(start)」の場合、正常に戻る
        return true;
      } else {
        // 施設が「停止(stop)」の場合、施設ステータスに「実行(start)」を設定する、続行
        facilityStatusMap.replace(facilityCd, JournalConvertConstants.STATUS_START);
      }
    } else {
      //　施設が無しの場合、施設ステータスに「実行(start)」を追加する、続行
      facilityStatusMap.put(facilityCd, JournalConvertConstants.STATUS_START);
    }

    return false;
  }
  /* add by chamaojia 2025-03-31 [11637] add new method --end */

  /* add by chamaojia 2025-03-31 [11637] new method --start */
  // A new method defined from the original interface, with unchanged logic inside
  public ResponseEntity<?> convertRun(JournalConvertReceiveRequest request) {
  /* add by chamaojia 2025-03-31 [11637] new method --end */
    String facilityCd = request.getFacilityCd();
    // del  #8292 exam_rst連携で受信した検査データの登録ができない 20230203 孟堅　start
    // add 7391 exam_rst連携で受信した検査項目コード  吉 start
    // examHospitalCd = "";
    // add 7391 exam_rst連携で受信した検査項目コード  吉 end
    // del  #8292 exam_rst連携で受信した検査データの登録ができない 20230203 孟堅　start
    //　add #5607 連動機能の実装確認 20221205 孟堅　start
    /* del by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --start */
//    convertCommonService.updateJournalListExamRst(facilityCd, request.getCtlNoList());
    /* del by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --end */
    //　add #5607 連動機能の実装確認 20221205 孟堅　end
    // 変換対象ジャーナル取得
    List<SysCoopJournal> journalList = convertCommonService.getJournalListOne(facilityCd
      , JournalConvertConstants.DIRECTION_RECEIVE
      , NtssCoopApiConstants.CoopResult.DONE.getResult()
      /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId, 入力値をnullに設定  --start */
      /* add by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加  --start */
      /* modify by chamaojia 2025-04-15 [11637] passing method parameters to delete ctlNoList --start */
//      , request.getCtlNoList(), null, null);
      // No longer requiring 【ctlNoList】 as a query condition, all retrieved data will be processed in order
      , null, null, null);
      /* modify by chamaojia 2025-04-15 [11637] passing method parameters to delete ctlNoList --end */
      /* add by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加  --end */
      /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId, 入力値をnullに設定  --end */
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(facilityCd + ":convert:journalList" + journalList);
    eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // 対象ジャーナルが1件も存在しない場合
    if (CollectionUtils.isEmpty(journalList)) {
      // 準正常応答とするが、HTTPステータスコードはNO_CONTENTを返す。
      String message = String.format("変換対象ジャーナル 0件でした。facility_cd:[%s]", facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      // ログメッセージ出力
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setLogMessage(message);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end

      // データが無しの場合、通知機能API（NotificationApiCallUtil）を呼び出さない

      // メッセージのみ設定
      // mod 2021-05-19 [JSON parse error:データ無し場合、NOT_FOUNDを返す]の対応 孫 start
//      JournalConvertResult result = new JournalConvertResult(HttpStatus.NO_CONTENT.value(), message);
//      return new ResponseEntity<>(result, HttpStatus.NO_CONTENT);
      // #10841 連携エッジから定期的に404エラーとなるURLが送信されている 2024-07-12 荘 start
      // JournalConvertResult result = new JournalConvertResult(HttpStatus.NOT_FOUND.value(), message);
      // return new ResponseEntity<>(result, HttpStatus.NOT_FOUND);
      JournalConvertResult result = new JournalConvertResult(HttpStatus.OK.value(), message);
      return new ResponseEntity<>(result, HttpStatus.OK);
      // #10841 連携エッジから定期的に404エラーとなるURLが送信されている 2024-07-12 荘 end
      // mod 2021-05-19 [JSON parse error:データ無し場合、NOT_FOUNDを返す]の対応 孫 end
    }

    try {
      //add 5607 感染症更新,担当スタッフ情報更新通知 gaoey start
      Map<Long, PatMain> patMainMap = new HashMap<>();
      // #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 add start
      Map<Long,PatMain> orgPatMainMap = new HashMap<>();
      Map<Long, PatPersonalMain> orgPatPersonalMainMap = new HashMap<>();
      Map<Long, PatUnique> orgPatUniqueMap = new HashMap<>();
      // #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 add end
      for (SysCoopJournal sysCoopJournal:journalList) {
        // add #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 start
        String hospPatIdM = getFacilityHospPatIdMethod(sysCoopJournal.getHospPatId(), facilityCd);
        sysCoopJournal.setHospPatId(hospPatIdM);
        // add #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 end
        Long patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, sysCoopJournal.getHospPatId());
        PatMain patMain = patMainDao.selectById(patId);
        if(patMain != null){
          patMainMap.put(patMain.getPat_id(),patMain);
        }
      }
      //add 5607 感染症更新,担当スタッフ情報更新通知 gaoey end

      // 対象ジャーナルの変換状態を「変換中」に更新する。
      journalList = updateConvStatus(journalList, AnaResult.PROCESSING);

      // 処理中への更新に失敗（他サーバーで更新済みの場合）
      if (CollectionUtils.isEmpty(journalList)) {
        String message = String.format("ジャーナル 0件でした。facility_cd:[%s]", facilityCd);
        // ログメッセージ出力
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setFacilityCd(facilityCd);
        eventLogMessage.setLogMessage(message);
        eventLogMessage.setInvokeClass(this.getClass().getName());
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);

        // メッセージのみ設定
        JournalConvertResult result = new JournalConvertResult(HttpStatus.OK.value(), message);
        return new ResponseEntity<>(result, HttpStatus.OK);
      }

      // add 2021-09-16 #5897:CSI連携ができないの対応 孫 start
      // 連携設定マスタを取得する
      List<MstCoopIni> coopIniList = convertCommonService.getMstCoopIniByFacilityCd(facilityCd);
      /* del by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
      // // 連携設定情報を設定する
      // CoopIniConvUtil.SetData(facilityCd, coopIniList);
      /* del by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
      // add 2021-09-16 #5897:CSI連携ができないの対応 孫 end

      List<ResultMap> resultList = new ArrayList<>();

      // 注: 「変換中」への更新は対象ジャーナルすべてに対して一括で実行するが、
      // 「完了」への更新はDB登録が正常終了したジャーナルのみ、個別に実行する。
      // （更新処理はRegisterServiceImplクラスにある。）

      // ジャーナル→JSON変換
      // mod 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start
      //List<ResultMap> convertResultList = convert(journalList, resultList);
      List<ResultMap> convertResultList = convert(journalList, resultList, facilityCd);
      // mod 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end

      // add 2021-07-06 #5248:処理キャンセルのしくみ 孫 start
      // ①透析患者ではない患者チェックの電文種別を取得する
      List<String> checkCoopCdList = new ArrayList<>();
      // 施設連携設定を取得する
      MstCoopFacility mstCoopFacility =  mstCoopFacilityDao.select(request.getFacilityCd());
      if (mstCoopFacility != null) {
        // 各機能共通設定
        MstCoopFacility.CommonSetting commonSetting = mstCoopFacility.getCommonSetting();
        if (commonSetting != null) {
          checkCoopCdList = commonSetting.getHospPatIdCheckCoop();
        }
      }

      //mod #10901 死亡患者受信時処理について zrx start
      List<Long> patIdListForDieIs0 = new ArrayList<>();
      //mod #10901 死亡患者受信時処理について zrx end
      // ②透析患者ではない患者チェックを実施する
      // 透析患者ではない患者の場合、処理キャンセル
      List<ResultMap> convertResultListOK = new ArrayList<>();
      List<ResultMap> convertResultListNG = new ArrayList<>();
      for (ResultMap convertResult : convertResultList) {
        // 電文種別を取得する
        String coopCd = (String)convertResult.getSpecial(JournalConvertConstants.COOP_CD);
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        // 連携版番号を取得する
        String coopVersion = (String)convertResult.getSpecial(JournalConvertConstants.COOP_VERSION);
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        // 電子カルテ種別を取得する
        String key0 = (String)convertResult.getSpecial(JournalConvertConstants.KEY0);
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        // add #7717 浄化申込の削除を受信した患者の動作について 王永吉 start
        // 患者番号を取得する
        Object hospPatId = convertResult.get("$journal.pat_personal_main.hosp_pat_id");
        // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
        //mod #11780 死亡患者受信時処理について start
//        String isDieFlag = "";
//        if (convertResult.containsKey("$journal.pat_personal_main.hosp_pat_id")) {
//          if (convertResult.get("$journal.pat_personal_main.is_die") != null){
//            isDieFlag = convertResult.get("$journal.pat_personal_main.is_die").toString();
//          }
//          //add #11780 死亡患者受信時処理について end
//        }
//        if("1".equals(isDieFlag) && pp!=null){
//          if(!Objects.equals(pp.getIs_die(), "1")) {
//            patIdListForDie.add(pp.getPat_id());
//          }
//        }
        PatPersonalMain pp = patPersonalMainDao.selectPatInfoByHospPatId(facilityCd, (String) hospPatId);
        if(pp != null && !Objects.equals(pp.getIs_die(), "1")) {
          patIdListForDieIs0.add(pp.getPat_id());
        }
        //mod #11780 死亡患者受信時処理について end
// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        // ini設定を取得する
//        List<MstCoopIni> values = mstCoopIniDao.selectByFacilityCd(facilityCd);
//        if(null != values){
//          String message = "";
//          MstCoopIni value = values.get(0);
//          String memo = value.getCoopIniMemo();
// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          // GXの場合、そして新しい患者じゃないの場合
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        if ("富士通GX".equals(memo) && hospPatId != null && hospPatId != ""){
        if (Key0Constant.GX.equals(key0) && hospPatId != null && hospPatId != ""){
            String message = "";
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            // 患者ID取得
            Long patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, (String)hospPatId);
            if (patId != null && patId != 0){
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//              PatCoopDetail chekPatCoopDetailIn = patCoopDetailDao.selectByPatId(patId, facilityCd);
              PatCoopDetail chekPatCoopDetailIn = patCoopDetailDao.selectByPatId(patId, facilityCd, coopVersion);
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              // 送信種別コードが"患者プロファイル"、"透析予約"、"透析実績"、"透析レポート"、"検査オーダ"、"放射線検査オーダ"、"心電図検査オーダ"の場合、患者の浄化申込をしたかどうかの判定
              if (chekPatCoopDetailIn == null && ("profile".equals(coopCd) || "ind_dial".equals(coopCd) || "rst_dial".equals(coopCd) ||
                        "rep_dial".equals(coopCd) || "exam_ord".equals(coopCd) || "rad_ord".equals(coopCd) || "phy_ord".equals(coopCd))) {
                // mod #7717 浄化申込の削除を受信した患者の動作について 王永吉 start
                // message = "[患者連携情報]データが無し。この患者[" + hospPatId + "]は連携したことがない。";
                message = "[浄化申し込み・初回指示]データが無し。この患者[" + hospPatId + "]は連携したことがない。";
                // mod #7717 浄化申込の削除を受信した患者の動作について 王永吉 end
                Long ctlNo = (Long) convertResult.getSpecial(JournalConvertConstants.KEY_JOURNAL_CTL_NO);
                // 電文登録
                updateAnaResultByCtlNo(ctlNo, message, AnaResult.SKIP.getResult());

                // 処理結果を設定
                convertResult.put(ResultKey.ANA_RESULT.getKey(), AnaResult.SKIP.getResult());
                convertResult.put(ResultKey.MESSAGE.getKey(), message);
                convertResultListNG.add(convertResult);
                continue;
              }
            }
          }
// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        }
// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        // add #7717 浄化申込の削除を受信した患者の動作について 王永吉 end

        // チェック以外の電文種別か
        // mod 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 start
//        if (checkCoopCdList == null || !checkCoopCdList.contains(coopCd)) {
//          convertResultListOK.add(convertResult);
//          continue;
//        }
        if(!"exam_rst".equals(coopCd) && (checkCoopCdList == null || !checkCoopCdList.contains(coopCd))){
          convertResultListOK.add(convertResult);
          continue;
        }
        // mod 6915 存在しない患者の検査結果取り込み時にエラーになる 吉 end

        // del #7717 浄化申込の削除を受信した患者の動作について 王永吉 start
//        // 患者番号を取得する
//        Object hospPatId = convertResult.get("$journal.pat_personal_main.hosp_pat_id");
        // del #7717 浄化申込の削除を受信した患者の動作について 王永吉 end

        if (StringUtils.isEmpty(hospPatId)) {
          Long ctlNo = (Long) convertResult.getSpecial(JournalConvertConstants.KEY_JOURNAL_CTL_NO);
          String message = String.format("処理対象データではありません。管理番号[%d]データの患者番号が無し。", ctlNo);
          updateAnaResultByCtlNo(ctlNo, message, AnaResult.SKIP.getResult());

          convertResult.put(ResultKey.ANA_RESULT.getKey(), AnaResult.SKIP.getResult());
          convertResult.put(ResultKey.MESSAGE.getKey(), message);
          convertResultListNG.add(convertResult);
        } else {
          // add 7391,6915 exam_rst連携で受信した検査項目コード  吉 start
          List<Object> list = new ArrayList<>();
          if(null != convertResult.get("patplurallist")){
            list = (List) convertResult.get("patplurallist");
          }
          if("exam_rst".equals(coopCd)){
            String exceptionMessagePatId = "";
            int count = 0;
            for(int i = list.size() ; i>0 ;i--){
              Long patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, (String)list.get(i-1));
              if (patId == null) {
                exceptionMessagePatId+=list.get(i-1)+",";
                list.remove(i-1);
                count++;
              }
            }
            String message = "";
            //　add #5607 連動機能の実装確認 20221205 孟堅　start
            boolean convertSuccess =true;
            //　add #5607 連動機能の実装確認 20221205 孟堅　end
            // add #8737-検査結果更新不正 周 start
            String strExamDate = "";
            String strMoveInOut = "";
            String patDieDate = "";
            if(Key0Constant.NKK.equals(key0)) {
              Object examDateObj = convertResult.get("$journal.pat_exam_main.result_exam_date");

              SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
              try {
                if (null != examDateObj) {
                  strExamDate = sdf.format(DateUtil.parseDateFormat("yyyyMMdd", examDateObj.toString().substring(0, 8)));
                }
              } catch (Exception ex) {
                //
              }

              PatPersonalMain patPersonalMain = patPersonalMainDao.selectPatInfoByHospPatId(facilityCd, (String) hospPatId);
              //8750-exam_rst 検査結果の登録が行われない 周 mod start
              //if (null != patPersonalMain.getDie_date()) {
              if (null != patPersonalMain && null != patPersonalMain.getDie_date()) {
              //8750-exam_rst 検査結果の登録が行われない 周 mod end
                patDieDate = patPersonalMain.getDie_date().toString().replaceAll("-", "").
                  replaceAll("/", "").substring(0, 8);
              }

              Long patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, (String) hospPatId);
              String strVisitHis = patUniqueDao.selectLatestVisitHisBeforeTargetDate(facilityCd, patId, strExamDate);

              if (!StringUtils.isEmpty(strVisitHis)) {
                Object moveInOut = (new JSONObject(strVisitHis)).get("move_in_out");
                strMoveInOut = (null == moveInOut) ? "" : moveInOut.toString();
              }
            }
            // 9428-NKK連携 exam_rst 連携設定 死亡・転出患者取込設定がない zhoubin add start
            boolean diePatImportFlg = true;
            if(Key0Constant.NKK.equals(key0)) {
              MstCoopIni iniInfo = coopIniList.get(0);
              JSONArray iniJarr = new JSONArray(iniInfo.getCoopIniInfo());
              for(Object jObj : iniJarr) {
                if(KEY1_EXAMINRCV.equals(((JSONObject)jObj).get("key1"))
                  && KEY2_DIEOUTMODE.equals(((JSONObject)jObj).get("key2"))
                  && "1".equals(((JSONObject)jObj).get("value"))) {
                  diePatImportFlg = false;
                  break;
                }
              }
            }
            // 9428-NKK連携 exam_rst 連携設定 死亡・転出患者取込設定がない zhoubin add end
            // add #8737-検査結果更新不正 周 end
            if(count>0) {
              exceptionMessagePatId = exceptionMessagePatId.substring(0, exceptionMessagePatId.lastIndexOf(","));
              message = String.format("処理対象データではない。施設コード[%s]、患者番号[%s]の患者は対象患者ではない。", facilityCd, exceptionMessagePatId);
              // add #5607 連動機能の実装確認 20221205 孟堅　start
              Long ctlNo = (Long) convertResult.getSpecial(JournalConvertConstants.KEY_JOURNAL_CTL_NO);
              updateAnaResultByCtlNo(ctlNo, message, AnaResult.SKIP.getResult());
              convertResult.put(ResultKey.ANA_RESULT.getKey(), AnaResult.SKIP.getResult());
              convertResult.put(ResultKey.MESSAGE.getKey(), message);
              convertResultListNG.add(convertResult);
              convertSuccess = false;
              // add #5607 連動機能の実装確認 20221205 孟堅　end
            // add #8737-検査結果更新不正 周 start
            } else if (Key0Constant.NKK.equals(key0)
              && !StringUtils.isEmpty(patDieDate)
              // 9428-NKK連携 exam_rst 連携設定 死亡・転出患者取込設定がない zhoubin add start
              && !diePatImportFlg
              // 9428-NKK連携 exam_rst 連携設定 死亡・転出患者取込設定がない zhoubin add end
              && (strExamDate.compareTo(patDieDate) > 0)) {
              String errMsg = String.format("採取日[%s]が死亡日[%s]以降の場合、検査結果の取込を行いません。", strExamDate, patDieDate);
              Long ctlNo = (Long) convertResult.getSpecial(JournalConvertConstants.KEY_JOURNAL_CTL_NO);
              updateAnaResultByCtlNo(ctlNo, errMsg, AnaResult.SKIP.getResult());
              Long patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, (String) hospPatId);
              Timestamp now = new Timestamp(clockWrapper.getClockMillis());
              Long ordNo = 0L;
              sysCoopJournalDao.updatePatIdAndHospPatIdByCtlNo(ctlNo, String.valueOf(hospPatId), patId, ordNo, now);
              convertResult.put(ResultKey.ANA_RESULT.getKey(), AnaResult.SKIP.getResult());
              convertResult.put(ResultKey.MESSAGE.getKey(), errMsg);
              convertResultListNG.add(convertResult);
              for (SysCoopJournal journal:journalList) {
                if(journal.getCtlNo() == ctlNo){
                  journal.setHospPatId(String.valueOf(hospPatId));
                }
              }
              convertSuccess = false;
            } else if (Key0Constant.NKK.equals(key0)
              // 9428-NKK連携 exam_rst 連携設定 死亡・転出患者取込設定がない zhoubin add start
              && !diePatImportFlg
              // 9428-NKK連携 exam_rst 連携設定 死亡・転出患者取込設定がない zhoubin add end
              && (PatInfoConstant.InOutVisitHistoryInfo.MOVING_OUT.equals(strMoveInOut)
            || PatInfoConstant.InOutVisitHistoryInfo.WITHDRAWAL.equals(strMoveInOut)
            || PatInfoConstant.InOutVisitHistoryInfo.IMPLANTATION.equals(strMoveInOut))) {
              String errMsg = String.format("採取日[%s]の過去直近の転入出情報が転出／離脱／移植の場合、検査結果の取込を行いません。", strExamDate);
              Long ctlNo = (Long) convertResult.getSpecial(JournalConvertConstants.KEY_JOURNAL_CTL_NO);
              updateAnaResultByCtlNo(ctlNo, errMsg, AnaResult.SKIP.getResult());
              convertResult.put(ResultKey.ANA_RESULT.getKey(), AnaResult.SKIP.getResult());
              convertResult.put(ResultKey.MESSAGE.getKey(), errMsg);
              convertResultListNG.add(convertResult);
              convertSuccess = false;
              // add #8737-検査結果更新不正 周 end
              /* modify by zhangruixue 2023-01-31 [Variable,CodeOptimization] --start */
            // mod  #8292 exam_rst連携で受信した検査データの登録ができない 20230203 孟堅　start
            //}else if(!"".equals(examHospitalCd)){
            }else if(!"".equals(convertResult.get(JournalConvertConstants.EXAMHOSPITALCD))){
              // mod  #8292 exam_rst連携で受信した検査データの登録ができない 20230203 孟堅　start
              /* modify by zhangruixue 2023-01-31 [Variable,CodeOptimization] --end */
              // del #5607 連動機能の実装確認 20221205 孟堅　start
              // add 7391 exam_rst連携で受信した検査項目コード  吉 start
              //examHospitalCd = examHospitalCd.substring(0,examHospitalCd.lastIndexOf(","));
              // add 7391 exam_rst連携で受信した検査項目コード  吉 end
              // message +="処理対象データがない。施設コード["+facilityCd+"]、検査項目連携コード["+examHospitalCd+"]がない;";
              //　del #5607 連動機能の実装確認 20221205 孟堅　end
              // add #5607 連動機能の実装確認 20221205 孟堅　start
              // add  #8292 exam_rst連携で受信した検査データの登録ができない 20230203 孟堅　start
              String examHospitalCd = convertResult.get(JournalConvertConstants.EXAMHOSPITALCD).toString();
              // add  #8292 exam_rst連携で受信した検査データの登録ができない 20230203 孟堅　end
              message +="処理対象データがない。施設コード["+facilityCd+"]、検査項目連携コード["+examHospitalCd.substring(0,examHospitalCd.lastIndexOf(","))+"]がない;";
              /* #8292 exam_rst連携で受信した検査データの登録ができない 2023年1月31日 卓--start*/
              /* #8292 exam_rst連携で受信した検査データの登録ができない 2023年1月31日 卓--end*/
              Long ctlNo = (Long) convertResult.getSpecial(JournalConvertConstants.KEY_JOURNAL_CTL_NO);
              // #8750-検査結果の登録が行われない 周 mod start
//              updateAnaResultByCtlNo(ctlNo, message, AnaResult.SKIP.getResult());
//              convertResult.put(ResultKey.ANA_RESULT.getKey(), AnaResult.SKIP.getResult());
//              convertResult.put(ResultKey.MESSAGE.getKey(), message);
//              convertResultListNG.add(convertResult);
//              convertSuccess = false;
              // #8750-検査結果の登録が行われない 周 20230620 mod start
//              if(null != convertResult.get(EXAM_DETAIL_ITEMCD)) {
//                boolean isAllCdEmpty = true;
//                ArrayList<String> allCdList = (ArrayList<String>)(convertResult.get(EXAM_DETAIL_ITEMCD));
//                for(String itemCd : allCdList) {
//                  if(!StringUtils.isEmpty(itemCd)) {
//                    isAllCdEmpty = false;
//                    break;
//                  }
//                }
//
//                if(isAllCdEmpty) {
//                  updateAnaResultByCtlNo(ctlNo, message, AnaResult.SKIP.getResult());
//                  convertResult.put(ResultKey.ANA_RESULT.getKey(), AnaResult.SKIP.getResult());
//                  convertResult.put(ResultKey.MESSAGE.getKey(), message);
//                  convertResultListNG.add(convertResult);
//                  convertSuccess = false;
//                } else {
//                  updateAnaResultByCtlNo(ctlNo, message, AnaResult.INTERNAL_ERROR.getResult());
//                  convertResult.put(ResultKey.ANA_RESULT.getKey(), AnaResult.INTERNAL_ERROR.getResult());
//                  convertResult.put(ResultKey.MESSAGE.getKey(), message);
//                  convertSuccess = true;
//                }
//              }
              convertResult.put(ResultKey.MESSAGE.getKey(), message);
              convertSuccess = true;
              // #8750-検査結果の登録が行われない 周 20230620 mod end
              // #8750-検査結果の登録が行われない 周 mod end
              // add #5607 連動機能の実装確認 20221205 孟堅　end
            }
            // mod #5607 連動機能の実装確認 20221205 孟堅　start
            // convertResult.put(ResultKey.MESSAGE.getKey(), message);
            // convertResultListOK.add(convertResult);
            if(convertSuccess){
              convertResult.put(ResultKey.MESSAGE.getKey(), message);
              convertResultListOK.add(convertResult);
            }
            // mod #5607 連動機能の実装確認 20221205 孟堅　end
          }else{
          // add 7391,6915 exam_rst連携で受信した検査項目コード  吉 end
            // 透析患者か
            Long patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, (String)hospPatId);
            // 透析患者ではない患者の場合、処理キャンセル
            if (patId == null) {
              Long ctlNo = (Long) convertResult.getSpecial(JournalConvertConstants.KEY_JOURNAL_CTL_NO);
              String message = String.format("処理対象データではない。施設コード[%s]、患者番号[%s]の患者は対象患者ではない。", facilityCd, (String)hospPatId);
              updateAnaResultByCtlNo(ctlNo, message, AnaResult.SKIP.getResult());

              convertResult.put(ResultKey.ANA_RESULT.getKey(), AnaResult.SKIP.getResult());
              convertResult.put(ResultKey.MESSAGE.getKey(), message);
              convertResultListNG.add(convertResult);
            } else {
              convertResultListOK.add(convertResult);
            }
            // add 7391,6915 exam_rst連携で受信した検査項目コード  吉 start
          }
          // add 7391,6915 exam_rst連携で受信した検査項目コード  吉 end
        }
      }
      convertResultList.clear();
      convertResultList.addAll(convertResultListOK);
      // add 2021-07-06 #5248:処理キャンセルのしくみ 孫 end

      // #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 add start
      for(ResultMap o : convertResultList) {
        // mod #8103 GX連携で実装されていない機能（利用者情報）limf start
        if (o.containsKey("$journal.pat_personal_main.hosp_pat_id")){
          String hospPatId = o.get("$journal.pat_personal_main.hosp_pat_id").toString();
          Long patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, hospPatId);
          PatMain patMain = patMainDao.selectById(patId);
          if(patMain != null){
            orgPatMainMap.put(patMain.getPat_id(),patMain);
          }

          PatPersonalMain patPersonalMain =
            patPersonalMainDao.selectPatInfoByHospPatId(facilityCd, hospPatId);
          if(patPersonalMain != null){
            orgPatPersonalMainMap.put(patPersonalMain.getPat_id(),patPersonalMain);
          }

          PatUnique patUnique = patUniqueDao.selectByPatId(patId);
          if(patUnique != null){
            orgPatUniqueMap.put(patId,patUnique);
          }
        }
        // mod #8103 GX連携で実装されていない機能（利用者情報）limf end
      }
      // #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 add end

      // del 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
//      // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
//      // ini設定を取得する
//      List<MstCoopIni> values = mstCoopIniDao.selectByFacilityCd(facilityCd);
//      if(null != values){
//        MstCoopIni value = values.get(0);
//        String memo = value.getCoopIniMemo();
//        // GXの場合
//        if ("富士通GX".equals(memo)){
//          for (ResultMap convertResult : convertResultList){
//            // JSONの患者番号を取得する
//            for (SysCoopJournal sysCoopJournal : journalList){
//              // ジャーナルの患者番号を取得する
//              Long journalPatId = sysCoopJournal.getPatId();
//                // del 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
////              if (patMainMap.containsKey(journalPatId)){
//                // del 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 den
//                // プロファイル電文の3文字目が「C」の場合
//                if ("C".equals(new String(sysCoopJournal.getDump(), 2, 1))){
//                  convertResultMap.put(journalPatId, "C");
//                }
//                // プロファイル電文の3文字目が「E」の場合
//                else if ("E".equals(new String(sysCoopJournal.getDump(), 2, 1))){
//                  if (convertResultMap.containsKey(journalPatId)){
//                    convertResultMap.put(journalPatId, "E");
//                  }
//                }
//                // del 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
////              }
//                // del 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end
//            }
//          }
//        }
//      }
//      // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end
      // del 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end

      // 登録の直列化
      Long checkJournalCtlNo = journalList.get(0).getCtlNo();
      String coopCd = journalList.get(0).getCoopCd();

      //待ちの処理
      while (true) {
        // より先に処理されるべき処理中ジャーナルがあるかチェック
        Long processingJournalCount = sysCoopJournalDao.selectSmallCtlNoJournalCount(
          facilityCd, JournalConvertConstants.DIRECTION_RECEIVE, 
          NtssCoopApiConstants.AnaResult.PROCESSING.getResult(), 
          NtssCoopApiConstants.CoopResult.DONE.getResult(), 
          coopCd, checkJournalCtlNo);
        if (processingJournalCount == 0) {
          // より先に処理されるべき処理中ジャーナルがない → 登録処理に進める
          break;
        }
        try {
          Thread.sleep(ANALYSIS_SLEEP_MILLIS);
        } catch (InterruptedException e) {
        }
      }

      // テーブル登録
      //mod #5607 連動機能の実装確認 20230103 孟堅 start
      //registerService.register(facilityCd, JournalConvertConstants.DIRECTION_RECEIVE, convertResultList);
      registerService.register(facilityCd, JournalConvertConstants.DIRECTION_RECEIVE, convertResultList,journalList);

      //mod #11780 死亡患者受信時処理について start
      //mod #10901 死亡患者受信時処理について zrx start
      if(!patIdListForDieIs0.isEmpty()) {
        List<PatPersonalMain> patPersonalMainList = patPersonalMainDao.selectByIdList(patIdListForDieIs0);
        if(patPersonalMainList != null && patPersonalMainList.size() > 0) {
          List<Long> patIdListForDieIs1 = new ArrayList<>();
          for(PatPersonalMain pp : patPersonalMainList) {
            if(Objects.equals(pp.getIs_die(), "1")) {
              patIdListForDieIs1.add(pp.getPat_id());
            }
          }
          if(patIdListForDieIs1 != null && patIdListForDieIs1.size() > 0) {
            // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
//          List<JournalCreateRequestPayload> journalCreteList = deathService.deathRelatedProcess(facilityCd,  patIdListForDieIs1,  null);
          List<JournalCreateRequestPayload> journalCreteList = deathService.deathRelatedProcess(facilityCd,  patIdListForDieIs1,  null, "PAT_DEATH");
          // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end
          registerService.deathRelatedBusiness(facilityCd, journalCreteList);
          }
        }
      }
      //mod #10901 死亡患者受信時処理について zrx end
      //mod #11780 死亡患者受信時処理について end

      //mod #5607 連動機能の実装確認 20230103 孟堅 end
      // add FNSI-改修内容 新規患者登録時の各テーブルの初期値登録＆スクリプト走査 dou start
      // mod 2021-07-06 #5248:処理キャンセルのしくみ 孫 start
//      // mod 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
//      //List<Object> hospPatIdList = convertResultList.stream().map(x -> x.get("pat_personal_main.hosp_pat_id")).distinct().collect(Collectors.toList());
//      List<Object> hospPatIdList = convertResultList.stream().map(x -> x.get("$journal.pat_personal_main.hosp_pat_id")).distinct().collect(Collectors.toList());
//      // mod 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
      // 新規患者登録、かつ、[9:処理完了]のデータを取得する
      List<Object> hospPatIdList = new ArrayList<>();
      for (ResultMap convertResult : convertResultList) {
        // [9:処理完了]以外、または、新規患者登録以外のデータ場合、次のデータを処理します。
        if (AnaResult.DONE.getResult().equals(convertResult.get(ResultKey.ANA_RESULT.getKey()))
          && !"D".equals(convertResult.getSpecial(JournalConvertConstants.CRUD))
          && ("profile".equals(convertResult.getSpecial(JournalConvertConstants.COOP_CD))
           || "ini_dial".equals(convertResult.getSpecial(JournalConvertConstants.COOP_CD)))
        ) {
          // 患者番号を取得する
          // 2020-05-13 #7352 #7353 profile連携（標準）の複数患者データ取り込みでエラー発生 孟堅　start
          Integer hospPatIdTag = (Integer)convertResult.get(JournalConvertConstants.PATPLURALTAG);
          // 複数患者の場合
          if(hospPatIdTag == JournalConvertConstants.PLURALPAT){
            hospPatIdList.addAll((List)convertResult.get(JournalConvertConstants.PLURALPATLIST));
          // 単数患者の場合
          }else{
            Object hospPatId = convertResult.get("$journal.pat_personal_main.hosp_pat_id");
             if (!StringUtils.isEmpty(hospPatId) && !hospPatIdList.contains(hospPatId)) {
              hospPatIdList.add(hospPatId);
             }
          }
          // 2020-05-13 #7352 profile連携（標準）の複数患者データ取り込みでエラー発生 孟堅　end
        }
      }
      // mod 2021-07-06 #5248:処理キャンセルのしくみ 孫 end
// mod 2022-01-13 #6974:ini_dial連携で処理区分修正を受信するとエラーが発生するの対応 孫 start
//      List<Long> patIdList = hospPatIdList.stream().map(x -> patPersonalMainDao.selectPatIdByHospPatId(facilityCd, (String) x)).collect(Collectors.toList());
      List<Long> patIdList = new ArrayList<>();
      for(Object hospPatId : hospPatIdList) {
        if (hospPatId != null && !StringUtils.isEmpty(hospPatId)) {
          Long patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, (String)hospPatId);
          if (patId != null) {
            patIdList.add(patId);
          }
        }
      }
// mod 2022-01-13 #6974:ini_dial連携で処理区分修正を受信するとエラーが発生するの対応 孫 end
      patientCaptureService.addDefultValue(patIdList, facilityCd);
      // add FNSI-改修内容 新規患者登録時の各テーブルの初期値登録＆スクリプト走査 dou end

      //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
      for (SysCoopJournal journal : journalList) {
        if (mongoTemplate != null && "R".equals(journal.getDirection()) && !"0".equals(journal.getAnaResult())
          && ("profile".equals(journal.getCoopCd()) || "ini_dial".equals(journal.getCoopCd()))) {
          registerService.setDataToMongo(journal);
        }
      }
      //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end

      // 実行結果を一つにまとめる
      resultList.addAll(convertResultList);

      // add 2021-07-06 #5248:処理キャンセルのしくみ 孫 start
      // 透析患者ではない患者の場合、処理キャンセル
      resultList.addAll(convertResultListNG);
      // add 2021-07-06 #5248:処理キャンセルのしくみ 孫 end

      // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
      // 通知機能APIを呼び出し
      // add #5607 連動機能の実装確認 20230411 孟堅　start
      JournalNotificationResult notificationResult = journalReceiveNotificationService.notification(
        resultList, journalList,
        orgPatMainMap,
        orgPatPersonalMainMap,
        orgPatUniqueMap
      );
      if (notificationResult.getBeBad()) {
        return new ResponseEntity<>(notificationResult.getMessage(), HttpStatus.BAD_REQUEST);
      } else {
        return new ResponseEntity<>(new JournalConvertResult(HttpStatus.OK.value(), notificationResult.getResultList()), HttpStatus.OK);
      }
      // add #5607 連動機能の実装確認 20230411 孟堅　end
      // del #5607 連動機能の実装確認 20230411 孟堅　start
//      for (ResultMap result : resultList) {
//        for (SysCoopJournal journal : journalList) {
//// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
//// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//          // 変換対象ジャーナルから、データを取得する
//          // mod #5607 連動機能の実装確認 20230103 孟堅 start
//          // if (journal.getCtlNo() ==result .get(ResultKey.CTL_NO.getKey())) {
//          if (journal.getCtlNo() == result.get(JournalParametersUtil.journal_ctl_no)||journal.getCtlNo() ==result .get(ResultKey.CTL_NO.getKey())) {
//          // mod #5607 連動機能の実装確認 20230103 孟堅 end
//            // 成功の場合
//            if (AnaResult.DONE.getResult().equals(result.get(ResultKey.ANA_RESULT.getKey()))) {
//
//              if ("ini_dial".equals(journal.getCoopCd())) {
//
//                // 「ini_dial:浄化申し込み・初回指示」処理 成功時
//                Long notificationNo = CoreConstant.NotificationDefinition.COOP_JOURNAL_INI_DIAL;
//                notificationApiCallUtil.registerNotification(notificationNo, facilityCd, new JSONObject());
//              } else if ("profile".equals(journal.getCoopCd())) {
//                // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
////                if (convertResultMap.containsKey(journal.getPatId())){
////                  if ("C".equals(convertResultMap.get(journal.getPatId()))){
////                    continue;
////                  }
////                }
//                if ("C".equals(new String(journal.getDump(), 2, 1))){
//                  continue;
//                }
//                // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end
//                Object hospPatId = result.get("$journal.pat_personal_main.hosp_pat_id");
//                Long patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, (String) hospPatId);
//                // del #5607 連動機能の実装確認 20221114 孟堅　start
//                //add 5607 感染症更新通知 gaoey start
//      /*          Boolean infectInfoFlag = false;
//                PatMain patMain = patMainMap.get(patId);
//                if(patMain != null){
//                  String infectInfo = patMain.getInfect_info();
//                  if(!"[]".equals(infectInfo)){
//                    JSONArray infectInfoJsonList = new JSONArray(infectInfo);
//                    List<String> infectionCdList = new ArrayList<>();
//                    for(int i=0;i<infectInfoJsonList.length();i++){
//                      JSONObject jsonObj = infectInfoJsonList.getJSONObject(i);
//                      String code =jsonObj.get("infection_cd").toString();
//                      infectionCdList.add(code);
//                    }
//                    List<String> infectcdStrList = new ArrayList<>();
//                    List<String> infectCdCoopList = (List<String>)result.get("$journal.detail.pat_main_2.infect_info.infection_cd");
//                    List<String> infectList = (List<String>) result.get("$journal.detail.pat_main_2.infect_info.infect");
//                    // mod 7435 未処理だったレコードの処理が正常に行われない 修正 chen start
//                    if (infectList != null) {
//                      for (int i = 0; i < infectList.size(); i++) {
//                        if(infectList.get(i).equals("2")){
//                          infectcdStrList.add(infectCdCoopList.get(i));
//                        }
//                      }
//                      if(infectcdStrList.size() > 0){
//                        for (int i = 0; i < infectcdStrList.size(); i++) {
//                          if(!infectionCdList.contains(infectcdStrList.get(i))){
//                            infectInfoFlag = true;
//                            break;
//                          }
//                        }
//                      }
//                    }
//                    // mod 7435 未処理だったレコードの処理が正常に行われない 修正 chen end
//                  }else{
//                    infectInfoFlag = true;
//                  }
//                }else{
//                  infectInfoFlag = true;
//                }
//                result.put("$journal.detail.pat_main_2.infect_info.infectInfoFlag",infectInfoFlag);*/
//                //add 5607 感染症更新通知 gaoey end
//                // del #5607 連動機能の実装確認 20221114 孟堅　end
//                // add #5607 連動機能の実装確認 20221114 孟堅　start
//                PatMain patMain = patMainMap.get(patId);
//                infectUpdate(patMain,result);
//                // add #5607 連動機能の実装確認 20221114 孟堅　end
//                //add 5607 担当スタッフ情報更新通知 gaoey start
//                Boolean chargeStaffInfoFlag = false;
//                if(patMain != null){
//                  String chargeStaffInfo = patMain.getCharge_staff_info();
//                  if(!"[]".equals(chargeStaffInfo)){
//                    JSONArray chargeStaffInfoJsonList = new JSONArray(chargeStaffInfo);
//                    List<String> chargeStaffInfoCdList = new ArrayList<>();
//                    for(int i=0;i<chargeStaffInfoJsonList.length();i++){
//                      JSONObject jsonObj = chargeStaffInfoJsonList.getJSONObject(i);
//                      String code =jsonObj.get("staff_cd").toString();
//                      chargeStaffInfoCdList.add(code);
//                    }
//                    List<String> chargeStaffInfoCoopList = (List<String>)result.get("$journal.detail.pat_main.charge_staff_info.staff_cd");
//                    // mod 7435 未処理だったレコードの処理が正常に行われない 修正 chen start
//                    if(chargeStaffInfoCoopList != null && chargeStaffInfoCoopList.size() > 0){
//                      for (int i = 0; i < chargeStaffInfoCoopList.size(); i++) {
//                        if(!chargeStaffInfoCdList.contains(chargeStaffInfoCoopList.get(i))){
//                          chargeStaffInfoFlag = true;
//                          break;
//                        }
//                      }
//                    }
//                    // mod 7435 未処理だったレコードの処理が正常に行われない 修正 chen end
//                  }else{
//                    chargeStaffInfoFlag = true;
//                  }
//                }else{
//                  chargeStaffInfoFlag = true;
//                }
//                result.put("$journal.detail.detail.pat_main.charge_staff_info.chargeStaffInfoFlag",chargeStaffInfoFlag);
//
//                //add 5607 担当スタッフ情報更新通知 gaoey end
//                PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
//                // 「profile:患者プロファイル」処理 成功時
//                if (!patPersonalMain.getReg_date().substring(0, 19).equals(patPersonalMain.getUp_date().substring(0, 19))) {
//                  // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
//                  // add #7631 【デグレ】profile連携で患者登録した通知が行われない 20221124 孟堅　start
//                  String lastName = Objects.isNull(patPersonalMain) ? (String) result.get("$journal.pat_personal_main.pat_last_name") : patPersonalMain.getPat_last_name();
//                  String firstName = Objects.isNull(patPersonalMain) ? (String) result.get("$journal.pat_personal_main.pat_first_name") : patPersonalMain.getPat_first_name();
//                  JSONObject baseReplaceData = new JSONObject();
//                  baseReplaceData.put("LASTNAME", lastName);
//                  baseReplaceData.put("FIRSTNAME", firstName);
//                  baseReplaceData.put("PATID",patId.toString());
//                  baseReplaceData.put("FACILITYCD",facilityCd);
//                  JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
//                  // add #7631 【デグレ】profile連携で患者登録した通知が行われない 20221124 孟堅　end
//                  Long notificationNo = CoreConstant.NotificationDefinition.COOP_JOURNAL_PROFILE;
//                  // mod #7631 【デグレ】profile連携で患者登録した通知が行われない 20221124 孟堅　start
//                  //notificationApiCallUtil.registerNotification(notificationNo, facilityCd, new JSONObject());
//                  // #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 mod start
//                  //notificationApiCallUtil.registerNotification(notificationNo, facilityCd,replaceData);
//                  PatMain oldPatMain = orgPatMainMap.get(patId);
//                  PatUnique oldPatUnique = orgPatUniqueMap.get(patId);
//                  PatPersonalMain oldPatPersonalMain = orgPatPersonalMainMap.get(patId);
//                  PatMain newPatMain = patMainDao.selectById(patId);
//                  PatUnique newPatUnique = patUniqueDao.selectByPatId(patId);
//                  PatPersonalMain newPatpersonMain = patPersonalMainDao.selectById(patId);
//                  //mod #8181 【デグレ】profile連携の電文解析処理で失敗しする 20221214 zhaoqi start
//                  if(oldPatMain != null && oldPatUnique != null && oldPatPersonalMain != null
//                    // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 20221220 add start
//                    && newPatMain != null && newPatUnique != null && newPatpersonMain != null
//                    // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 20221220 add end
//                    && isPatUpdated(oldPatMain, oldPatUnique, oldPatPersonalMain, newPatMain, newPatUnique, newPatpersonMain)) {
//                    notificationApiCallUtil.registerNotification(notificationNo, facilityCd,replaceData);
//                  }
//                  //mod #8181 【デグレ】profile連携の電文解析処理で失敗しする 20221214 zhaoqi end
//                  // #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 mod end
//                  // mod #7631 【デグレ】profile連携で患者登録した通知が行われない 20221124 孟堅　end
//                }
//                sendInfectionNotification(result,facilityCd);
//                // add #5607 連動機能の実装確認 20221114 孟堅　start
//                // 自動計算処理API
//                ResponseEntity<String> calcRet=notificationApiCallUtil.updateExamResultCalc(journal.getPatId());
//                // 失敗時
//                if (calcRet.getStatusCode() != HttpStatus.OK) {
//                  return new ResponseEntity<>("自動計算処理API実行失敗", HttpStatus.BAD_REQUEST);
//                }
//                // add 2021-07-28 #5607：連動機能の実装確認  wangchen end
//                // add #5607 連動機能の実装確認 20221114 孟堅　end
//
//              }else if("exam_rst".equals(journal.getCoopCd())){
//                // add 2021-07-28 #5607：連動機能の実装確認  wangchen start
//                // add #5607 連動機能の実装確認 20221114 孟堅　start
//                Object hospPatId = result.get("$journal.pat_personal_main.hosp_pat_id");
//                Long patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, (String) hospPatId);
//                // #5607-連動機能の実装確認 周 20230410 mod start
//                //PatMain patMain = patMainMap.get(patId);
//                //nnkExamrstInfectUpdate(patMain,result);
//                PatMain patMain = orgPatMainMap.get(patId);
//                nnkExamrstInfectUpdate(patMain,result, facilityCd);
//                // #5607-連動機能の実装確認 周 20230410 mod end
//                //　add #5607 連動機能の実装確認 20221114 孟堅　end
//                sendInfectionNotification(result,facilityCd);
//                // 自動計算処理API
//                ResponseEntity<String> calcRet=notificationApiCallUtil.updateExamResultCalc(journal.getPatId());
//                // 失敗時
//                if (calcRet.getStatusCode() != HttpStatus.OK) {
//                  return new ResponseEntity<>("自動計算処理API実行失敗", HttpStatus.BAD_REQUEST);
//                }
//                // add 2021-07-28 #5607：連動機能の実装確認  wangchen end
//              }
//
//            } else {
//
//              // 失敗の場合
//              JSONObject replaceData = new JSONObject();
//              replaceData.put("COOP_CD", notificationApiCallUtil.GetCoopNameByCd(journal.getCoopCd()));
//              // add FNSI-7860 テスト用 劉全航 start
//              EventLogMessage eventLogMessage1 = new EventLogMessage();
//              eventLogMessage1.setFacilityCd(journal.getFacilityCd());
//              eventLogMessage1.setInvokeClass(this.getClass().getName());
//              eventLogMessage1.setLogMessage(
//                "bug #7860 不要なデスクトップ通知が発生する," +
//                "facility_cd:[" + facilityCd + "], " +
//                  "ctl_no:[" + journal.getCtlNo() + "]," +
//                  "message:[" + journal.getMessage() + "]," +
//                  "direction:[" + journal.getDirection() + "]," +
//                "coop_cd:["+ journal.getCoopCd() + "]," +
//// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//                  "coop_version:["+ coopVersion + "]," +
//// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//                  "crud:[" + journal.getCrud() + "]," +
//                  "coopResult:[" + journal.getCoopResult() + "]" +
//                  "anaResult:[" + journal.getAnaResult() + "]");
//              logService.log(LogLevel.ERROR, eventLogMessage1, null, SERVICE_NAME.FNSI, null);
//              // add FNSI-7860 テスト用 劉全航 end
//              Long notificationNo = CoreConstant.NotificationDefinition.COOP_JOURNAL_RECEIVE;
//              notificationApiCallUtil.registerNotification(notificationNo, facilityCd, replaceData);
//            }
//
//            break;
//          }
//        }
//      }
//      // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
//      JournalConvertResult results = new JournalConvertResult(HttpStatus.OK.value(), resultList);
//      return new ResponseEntity<>(results, HttpStatus.OK);
      // del #5607 連動機能の実装確認 20230411 孟堅　end

    } catch (Exception e) {
// mod 2021-11-11 #5896:SSI連携ができない(患者プロファイル) 孫 start
//      String error = String.format("変換処理(受信)で予期せぬエラーが発生しました。[%s]", e);
      StackTraceElement[]  list = null;
      String errAdd = "";
      if (e.getCause() != null && e.getCause().getStackTrace() != null
        && e.getCause().getStackTrace().length > 0) {
        list = e.getCause().getStackTrace();
        for (StackTraceElement err : list) {
          if (err != null && err.toString().startsWith("jp.co.")) {
            errAdd = errAdd + "\r\n" + err.toString();
          }
        }
      }
      if (StringUtils.isEmpty(errAdd)) {
        list = e.getStackTrace();
        for (StackTraceElement err : list) {
          if (err != null && err.toString().startsWith("jp.co.")) {
            errAdd = errAdd + "\r\n" + err.toString();
          }
        }
      }
      String error = String.format("変換処理(受信)で予期せぬエラーが発生しました。[%s][%s]", e, errAdd);
// mod 2021-11-11 #5896:SSI連携ができない(患者プロファイル) 孫 end
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      eventLogMessage.setLogMessage(error);
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // 変換ステータスが「処理中」のレコードをすべて「内部エラー」に更新
      // ※未処理のジャーナルのみ更新対象とする
      journalList.stream()
          .filter(journal -> AnaResult.PROCESSING.getResult().equals(journal.getAnaResult()))
          .forEach(journal -> updateAnaResult(journal, error, AnaResult.INTERNAL_ERROR));

      // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
      // 通知機能APIを呼び出し
      for (SysCoopJournal journal : journalList) {
        if (AnaResult.INTERNAL_ERROR.getResult().equals(journal.getAnaResult())) {
          // modify 9583 by kangjie 20240410 start 通知一覧の連携エラー通知の遷移不正
//          JSONObject replaceData = new JSONObject();
//          replaceData.put("COOP_CD", notificationApiCallUtil.GetCoopNameByCd(journal.getCoopCd()));
//          // add #5607 連動機能の実装確認 20230411 孟堅　start
//          replaceData.put("TITLE", "");
//          replaceData.put("HOSPPATID","");
//          // add #5607 連動機能の実装確認 20230411 孟堅　end
//          Long notificationNo =  CoreConstant.NotificationDefinition.COOP_JOURNAL_RECEIVE;
//          notificationApiCallUtil.registerNotification(notificationNo, facilityCd, replaceData);
          coopJournalErrorComponent.sendCoopJournalError(journal);
          // modify 9583 by kangjie 20240410 end  通知一覧の連携エラー通知の遷移不正
        }
      }
      // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
      JournalConvertResult result = new JournalConvertResult(HttpStatus.INTERNAL_SERVER_ERROR.value(), error);
      return new ResponseEntity<>(result, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
//  del #5607 連動機能の実装確認 20230411 孟堅　start
//  // #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 add start
//  private boolean isPatUpdated(PatMain oldPatMain, PatUnique oldPatUnique, PatPersonalMain oldPatPersonalMain,
//                               PatMain newPatMain, PatUnique newPatUnique, PatPersonalMain newPatPersonalMain)
//  {
//    // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod start
////    if(isPatMainUpdated(oldPatMain, newPatMain))
////    {
////      return true;
////    }
////
////    if(isPatUniqueUpdated(oldPatUnique, newPatUnique))
////    {
////      return true;
////    }
////
////    if(isPatPersonalMainUpdated(oldPatPersonalMain, newPatPersonalMain))
////    {
////      return true;
////    }
////
////    return false;
//
//    return isPatMainUpdated(oldPatMain, newPatMain)
//      || isPatUniqueUpdated(oldPatUnique, newPatUnique)
//      || isPatPersonalMainUpdated(oldPatPersonalMain, newPatPersonalMain);
//    // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod end
//  }
//
//  private boolean isPatMainUpdated(PatMain oldPatMain, PatMain newPatMain) {
//    //インプラント
//    if(null != newPatMain.getImplant_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatMain.getImplant_info())) {
//      if(null == oldPatMain.getImplant_info()
//        || 0 == JSONARRAY_EMPTY.compareTo(oldPatMain.getImplant_info())) {
//        return true;
//      }
//
//      List<Object> oldImplantList = (new JSONArray(oldPatMain.getImplant_info())).toList();
//      List<Object> newImplantList = (new JSONArray(newPatMain.getImplant_info())).toList();
//      if(oldImplantList.size() != newImplantList.size()) {
//        return true;
//      }
//
//      int implantCount = 0;
//      for (Object o1 : newImplantList) {
//        boolean isMatch = false;
//        for (Object o2 : oldImplantList) {
//          if (0 == ((HashMap)o1).get("implant_cd").toString().compareTo(((HashMap)o2).get("implant_cd").toString())) {
//            implantCount++;
//            isMatch = true;
//            break;
//          }
//        }
//        if(!isMatch) {
//          return true;
//        }
//      }
//      if(implantCount != newImplantList.size()) {
//        return true;
//      }
//    }
//
//    //感染症有無
//    if(null != newPatMain.getInfect_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatMain.getInfect_info())) {
//      if(null == oldPatMain.getInfect_info()
//        || 0 == JSONARRAY_EMPTY.compareTo(oldPatMain.getInfect_info())) {
//        return true;
//      }
//
//      List<Object> oldInfectList = (new JSONArray(oldPatMain.getInfect_info())).toList();
//      List<Object> newInfectList = (new JSONArray(newPatMain.getInfect_info())).toList();
//      if(oldInfectList.size() != newInfectList.size()) {
//        return true;
//      }
//
//      int infectCount = 0;
//      for (Object o1 : newInfectList) {
//        boolean isMatch = false;
//        for (Object o2 : oldInfectList) {
//          if (0 == ((HashMap)o1).get("infection_cd").toString().compareTo(((HashMap)o2).get("infection_cd").toString())) {
//            infectCount++;
//            isMatch = true;
//            break;
//          }
//        }
//        if(!isMatch) {
//          return true;
//        }
//      }
//      if(infectCount != newInfectList.size()) {
//        return true;
//      }
//    }
//
//    //糖尿病患者扱いなし？
//    //血糖検査有無なし？
//    //確定転入出状態なし？
//    //予定転入出状態なし？
//    //予定転入出日時なし？
//    //患者メモ情報
//    if(null != newPatMain.getPat_memo_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatMain.getPat_memo_info())) {
//      if(null == oldPatMain.getPat_memo_info()
//        || 0 == JSONARRAY_EMPTY.compareTo(oldPatMain.getPat_memo_info())) {
//        return true;
//      }
//
//      List<Object> oldMemoList = (new JSONArray(oldPatMain.getPat_memo_info())).toList();
//      List<Object> newMemoList = (new JSONArray(newPatMain.getPat_memo_info())).toList();
//      if(oldMemoList.size() != newMemoList.size()) {
//        return true;
//      }
//
//      int memoCount = 0;
//      for (Object o1 : newMemoList) {
//        boolean isMatch = false;
//        for (Object o2 : oldMemoList) {
//          if (((null == ((HashMap)o1).get("title") && null == ((HashMap)o2).get("title"))
//            || (null != ((HashMap)o1).get("title") && null != ((HashMap)o2).get("title")
//            && 0 == ((HashMap)o1).get("title").toString().compareTo(((HashMap)o2).get("title").toString())))
//          && ((null == ((HashMap)o1).get("content") && null == ((HashMap)o2).get("content"))
//            || (null != ((HashMap)o1).get("content") && null != ((HashMap)o2).get("content")
//            && 0 == ((HashMap)o1).get("content").toString().compareTo(((HashMap)o2).get("content").toString())))) {
//            memoCount++;
//            isMatch = true;
//            break;
//          }
//        }
//        if(!isMatch) {
//          return true;
//        }
//      }
//      if(memoCount != newMemoList.size()) {
//        return true;
//      }
//    }
//
//    //加算情報なし？
//    //担当スタッフ情報
//    if(null != newPatMain.getCharge_staff_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatMain.getCharge_staff_info())) {
//      if(null == oldPatMain.getCharge_staff_info()
//        || 0 == JSONARRAY_EMPTY.compareTo(oldPatMain.getCharge_staff_info())) {
//        return true;
//      }
//
//      List<Object> oldStaffList = (new JSONArray(oldPatMain.getCharge_staff_info())).toList();
//      List<Object> newStaffList = (new JSONArray(newPatMain.getCharge_staff_info())).toList();
//      if(oldStaffList.size() != newStaffList.size()) {
//        return true;
//      }
//
//      int staffCount = 0;
//      for (Object o1 : newStaffList) {
//        boolean isMatch = false;
//        for (Object o2 : oldStaffList) {
//          if (((null == ((HashMap)o1).get("staff_cd") && null == ((HashMap)o2).get("staff_cd"))
//          || (null != ((HashMap)o1).get("staff_cd") && null != ((HashMap)o2).get("staff_cd")
//          && 0 == ((HashMap)o1).get("staff_cd").toString().compareTo(((HashMap)o2).get("staff_cd").toString())))
//            && ((null == ((HashMap)o1).get("is_charge") && null == ((HashMap)o2).get("is_charge"))
//            || (null != ((HashMap)o1).get("is_charge") && null != ((HashMap)o2).get("is_charge")
//            && 0 == ((HashMap)o1).get("is_charge").toString().compareTo(((HashMap)o2).get("is_charge").toString())))
//            && ((null == ((HashMap)o1).get("is_puncture") && null == ((HashMap)o2).get("is_puncture"))
//            || (null != ((HashMap)o1).get("is_puncture") && null != ((HashMap)o2).get("is_puncture")
//            && 0 == ((HashMap)o1).get("is_puncture").toString().compareTo(((HashMap)o2).get("is_puncture").toString())))
//            && ((null == ((HashMap)o1).get("is_main") && null == ((HashMap)o2).get("is_main"))
//            || (null != ((HashMap)o1).get("is_main") && null != ((HashMap)o2).get("is_main")
//            && 0 == ((HashMap)o1).get("is_main").toString().compareTo(((HashMap)o2).get("is_main").toString())))
//            && ((null == ((HashMap)o1).get("flg") && null == ((HashMap)o2).get("flg"))
//            || (null != ((HashMap)o1).get("flg") && null != ((HashMap)o2).get("flg")
//            && 0 == ((HashMap)o1).get("flg").toString().compareTo(((HashMap)o2).get("flg").toString())))) {
//            staffCount++;
//            isMatch = true;
//            break;
//          }
//        }
//        if(!isMatch) {
//          return true;
//        }
//      }
//      if(staffCount != newStaffList.size()) {
//        return true;
//      }
//    }
//    //患者グループ情報なし？
//    //禁忌・アレルギー情報
//    if(null != newPatMain.getTaboo_allergy_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatMain.getTaboo_allergy_info())) {
//      if(null == oldPatMain.getTaboo_allergy_info()
//        || 0 == JSONARRAY_EMPTY.compareTo(oldPatMain.getTaboo_allergy_info())) {
//        return true;
//      }
//
//      List<Object> oldAllergyList = (new JSONArray(oldPatMain.getTaboo_allergy_info())).toList();
//      List<Object> newAllergyList = (new JSONArray(newPatMain.getTaboo_allergy_info())).toList();
//      if(oldAllergyList.size() != newAllergyList.size()) {
//        return true;
//      }
//
//      int tabooAllergyCount = 0;
//      for (Object o1 : newAllergyList) {
//        boolean isMatch = false;
//        for (Object o2 : oldAllergyList) {
//          // #8102-GX連携で実装されていない機能（処方情報連携） 周 mod start
////          if ((!StringUtils.isEmpty(((HashMap)o1).get("taboo_allergy_cd").toString())
//          if (null == ((HashMap)o1).get("taboo_allergy_cd") && null == ((HashMap)o1).get("taboo_allergy_cd")
//            || null != ((HashMap)o1).get("taboo_allergy_cd") && null != ((HashMap)o2).get("taboo_allergy_cd")
//            && !StringUtils.isEmpty(((HashMap)o1).get("taboo_allergy_cd").toString())
//          // #8102-GX連携で実装されていない機能（処方情報連携） 周 mod end
//            && 0 == ((HashMap)o1).get("taboo_allergy_cd").toString().compareTo(
//            ((HashMap)o2).get("taboo_allergy_cd").toString())
//            || (StringUtils.isEmpty(((HashMap)o1).get("taboo_allergy_cd").toString())
//            && 0 == ((HashMap)o1).get("content").toString().compareTo(((HashMap)o2).get("content").toString()))) {
//            tabooAllergyCount++;
//            isMatch = true;
//            break;
//          }
//        }
//        if(!isMatch) {
//          return true;
//        }
//      }
//      if(tabooAllergyCount != newAllergyList.size()) {
//        return true;
//      }
//    }
//
//    //風袋補正情報なし？
//    //除水補正情報なし？
//    //装置設定情報なし？
//    //治療進捗状態なし？
//    //車いす有無なし？
//    //共通診療情報
//    if(null != newPatMain.getMedical_care_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatMain.getMedical_care_info())) {
//      if(null == oldPatMain.getMedical_care_info()
//        || 0 == JSONARRAY_EMPTY.compareTo(oldPatMain.getMedical_care_info())) {
//        return true;
//      }
//
//      JSONObject oldMedicalCare = new JSONObject(oldPatMain.getMedical_care_info());
//      JSONObject newMedicalCare = new JSONObject(newPatMain.getMedical_care_info());
//
//      if (null != newMedicalCare.get("ward_cd")
//        && !StringUtils.isEmpty(newMedicalCare.get("ward_cd").toString())
//        && (null == oldMedicalCare.get("ward_cd")
//        || StringUtils.isEmpty(oldMedicalCare.get("ward_cd").toString()))) {
//        return true;
//      }
//      if (null != newMedicalCare.get("ward_cd")
//        && !StringUtils.isEmpty(newMedicalCare.get("ward_cd").toString())
//        && null != oldMedicalCare.get("ward_cd")
//        && !StringUtils.isEmpty(oldMedicalCare.get("ward_cd").toString())
//        && 0 != newMedicalCare.get("ward_cd").toString().compareTo(oldMedicalCare.get("ward_cd").toString())) {
//        return true;
//      }
//      //透析導入日
//      if ((null == newMedicalCare.get("dialysis_start_date") && null != oldMedicalCare.get("dialysis_start_date"))
//        || (null != newMedicalCare.get("dialysis_start_date") && null == oldMedicalCare.get("dialysis_start_date"))
//        || (null != newMedicalCare.get("dialysis_start_date") && null != oldMedicalCare.get("dialysis_start_date")
//      && 0 != newMedicalCare.get("dialysis_start_date").toString().compareTo(oldMedicalCare.get("dialysis_start_date").toString()))) {
//        return true;
//      }
//      if ((null == newMedicalCare.get("main_course_cd") && null != oldMedicalCare.get("main_course_cd"))
//        || (null != newMedicalCare.get("main_course_cd") && null == oldMedicalCare.get("main_course_cd"))
//        || (null != newMedicalCare.get("main_course_cd") && null != oldMedicalCare.get("main_course_cd")
//        && 0 != newMedicalCare.get("main_course_cd").toString().compareTo(oldMedicalCare.get("main_course_cd").toString()))) {
//        return true;
//      }
//    }
//
//    return false;
//  }
//
//  private boolean isPatUniqueUpdated(PatUnique oldPatUnique, PatUnique newPatUnique) {
//    //既往歴情報なし？
//    //入外・転入出情報なし？
//    //身体情報
//    if(null != newPatUnique.getPhysical_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatUnique.getPhysical_info())) {
//      String strOldPhysicalinfo = oldPatUnique.getPhysical_info();
//      if(StringUtils.isEmpty(strOldPhysicalinfo) || 0 == JSONARRAY_EMPTY.compareTo(strOldPhysicalinfo)) {
//        return true;
//      } else {
//        String strNewPhysicalinfo = newPatUnique.getPhysical_info();
//        List<Object> newPhysicalinfoList = (new JSONArray(strNewPhysicalinfo)).toList();
//
//        List<Object> orgPhysicalinfoList = (new JSONArray(strOldPhysicalinfo)).toList();
//        if(newPhysicalinfoList.size() != orgPhysicalinfoList.size()) {
//          return true;
//        }
//        int physicalInfoCount = 0;
//        for(Object o1 : newPhysicalinfoList) {
//          boolean isMatch = false;
//          for(Object o2 : orgPhysicalinfoList) {
//            if(((null == ((HashMap)o1).get("ctr") && null == ((HashMap)o2).get("ctr"))
//              || (null != ((HashMap)o1).get("ctr") && null != ((HashMap)o2).get("ctr")
//              && 0 == ((HashMap)o1).get("ctr").toString().compareTo(((HashMap)o2).get("ctr").toString())))
//              && ((null == ((HashMap)o1).get("height") && null == ((HashMap)o2).get("height"))
//              || (null != ((HashMap)o1).get("height") && null != ((HashMap)o2).get("height")
//              && 0 == ((HashMap)o1).get("height").toString().compareTo(((HashMap)o2).get("height").toString())))
//              && ((null == ((HashMap)o1).get("exam_date") && null == ((HashMap)o2).get("exam_date"))
//              || (null != ((HashMap)o1).get("exam_date") && null != ((HashMap)o2).get("exam_date")
//              && 0 == ((HashMap)o1).get("exam_date").toString().compareTo(((HashMap)o2).get("exam_date").toString())))
//              && ((null == ((HashMap)o1).get("chest_dia") && null == ((HashMap)o2).get("chest_dia"))
//              || (null != ((HashMap)o1).get("chest_dia") && null != ((HashMap)o2).get("chest_dia")
//              && 0 == ((HashMap)o1).get("chest_dia").toString().compareTo(((HashMap)o2).get("chest_dia").toString())))
//              && ((null == ((HashMap)o1).get("breast_dia") && null == ((HashMap)o2).get("breast_dia"))
//              || (null != ((HashMap)o1).get("breast_dia") && null != ((HashMap)o2).get("breast_dia")
//              && 0 == ((HashMap)o1).get("breast_dia").toString().compareTo(((HashMap)o2).get("breast_dia").toString())))) {
//              physicalInfoCount++;
//              isMatch = true;
//              break;
//            }
//          }
//          if(!isMatch) {
//            return true;
//          }
//        }
//        if(physicalInfoCount != newPhysicalinfoList.size()) {
//          return true;
//        }
//      }
//    }
//
//    //原疾患コード
//    if(null != newPatUnique.getMedical_hst_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatUnique.getMedical_hst_info())) {
//      if(null == oldPatUnique.getMedical_hst_info()
//        || 0 == JSONARRAY_EMPTY.compareTo(oldPatUnique.getMedical_hst_info())) {
//        return true;
//      }
//
//      List<Object> oldMedicalHstInfoList = (new JSONArray(oldPatUnique.getMedical_hst_info())).toList();
//      List<Object> newMedicalHstInfoList = (new JSONArray(newPatUnique.getMedical_hst_info())).toList();
//      if(oldMedicalHstInfoList.size() != newMedicalHstInfoList.size()) {
//        return true;
//      }
//
//      int medicalHstInfoCount = 0;
//      for(Object o1 : newMedicalHstInfoList) {
//        boolean isMatch = false;
//        for(Object o2 : oldMedicalHstInfoList) {
//          if((null == ((HashMap)o1).get("disease_cd") && null == ((HashMap)o2).get("disease_cd"))
//            || (null != ((HashMap)o1).get("disease_cd") && null != ((HashMap)o2).get("disease_cd")
//            && 0 == ((HashMap)o1).get("disease_cd").toString().compareTo(((HashMap)o2).get("disease_cd").toString()))) {
//            medicalHstInfoCount++;
//            isMatch = true;
//            break;
//          }
//        }
//        if(!isMatch) {
//          return true;
//        }
//      }
//      if(medicalHstInfoCount != newMedicalHstInfoList.size()) {
//        return true;
//      }
//    }
//
//    return false;
//  }

//  private boolean isPatPersonalMainUpdated(PatPersonalMain oldPatPersonalMain, PatPersonalMain newPatPersonalMain) {
//    //患者氏名(漢字姓)
//    // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod start
//    //if (0 != newPatPersonalMain.getPat_last_name().compareTo(oldPatPersonalMain.getPat_last_name())) {
//    if (null == newPatPersonalMain.getPat_last_name() && null != oldPatPersonalMain.getPat_last_name()
//      || null != newPatPersonalMain.getPat_last_name() && null == oldPatPersonalMain.getPat_last_name()
//      || null != newPatPersonalMain.getPat_last_name() && null != oldPatPersonalMain.getPat_last_name()
//      && 0 != newPatPersonalMain.getPat_last_name().compareTo(oldPatPersonalMain.getPat_last_name())) {
//      // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod end
//      return true;
//    }
//    //患者氏名(漢字名)
//    // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod start
//    //if (0 != newPatPersonalMain.getPat_first_name().compareTo(oldPatPersonalMain.getPat_first_name())) {
//    if (null == newPatPersonalMain.getPat_first_name() && null != oldPatPersonalMain.getPat_first_name()
//      || null != newPatPersonalMain.getPat_first_name() && null == oldPatPersonalMain.getPat_first_name()
//      || null != newPatPersonalMain.getPat_first_name() && null != oldPatPersonalMain.getPat_first_name()
//      && 0 != newPatPersonalMain.getPat_first_name().compareTo(oldPatPersonalMain.getPat_first_name())) {
//      // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod end
//      return true;
//    }
//    //患者氏名(カタカナ姓)
//    // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod start
//    //if (0 != newPatPersonalMain.getPat_last_name_kana().compareTo(oldPatPersonalMain.getPat_last_name_kana())) {
//    if (null == newPatPersonalMain.getPat_last_name_kana() && null != oldPatPersonalMain.getPat_last_name_kana()
//      || null != newPatPersonalMain.getPat_last_name_kana() && null == oldPatPersonalMain.getPat_last_name_kana()
//      || null != newPatPersonalMain.getPat_last_name_kana() && null != oldPatPersonalMain.getPat_last_name_kana()
//      && 0 != newPatPersonalMain.getPat_last_name_kana().compareTo(oldPatPersonalMain.getPat_last_name_kana())) {
//      // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod end
//      return true;
//    }
//    //患者氏名(カタカナ名)
//    // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod start
//    //if (0 != newPatPersonalMain.getPat_first_name_kana().compareTo(oldPatPersonalMain.getPat_first_name_kana())) {
//    if (null == newPatPersonalMain.getPat_first_name_kana() && null != oldPatPersonalMain.getPat_first_name_kana()
//      || null != newPatPersonalMain.getPat_first_name_kana() && null == oldPatPersonalMain.getPat_first_name_kana()
//      || null != newPatPersonalMain.getPat_first_name_kana() && null != oldPatPersonalMain.getPat_first_name_kana()
//      && 0 != newPatPersonalMain.getPat_first_name_kana().compareTo(oldPatPersonalMain.getPat_first_name_kana())) {
//      // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod end
//      return true;
//    }
//
//    //患者氏名(英字姓)なし
//    //患者氏名(英字名)なし
//    //患者誕生時氏名(旧姓)(漢字)なし
//    //患者誕生時氏名(旧姓)(カタカナ)なし
//    //患者誕生時氏名(旧姓)(英字)なし
//    //生年月日(YYYYMMDD)
//    // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod start
//    //if (0 != newPatPersonalMain.getPat_birthday().compareTo(oldPatPersonalMain.getPat_birthday())) {
//    if (null == newPatPersonalMain.getPat_birthday() && null != oldPatPersonalMain.getPat_birthday()
//      || null != newPatPersonalMain.getPat_birthday() && null == oldPatPersonalMain.getPat_birthday()
//      || null != newPatPersonalMain.getPat_birthday() && null != oldPatPersonalMain.getPat_birthday()
//      && 0 != newPatPersonalMain.getPat_birthday().compareTo(oldPatPersonalMain.getPat_birthday())) {
//      // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod end
//      return true;
//    }
//    //性別
//    if (!newPatPersonalMain.getPat_sex().equals(oldPatPersonalMain.getPat_sex())) {
//      return true;
//    }
//    //国籍なし
//    //血液型ABO
//    if (!newPatPersonalMain.getPat_blood_type_abo().equals(oldPatPersonalMain.getPat_blood_type_abo())) {
//      return true;
//    }
//    //血液型RH
//    if (!newPatPersonalMain.getPat_blood_type_rh().equals(oldPatPersonalMain.getPat_blood_type_rh())) {
//      return true;
//    }
//    //血液型亜型なし
//    //入外区分
//    if (!newPatPersonalMain.getIn_out_class().equals(oldPatPersonalMain.getIn_out_class())) {
//      return true;
//    }
//    //死亡患者
//    // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod start
//    //if ((StringUtils.isEmpty(newPatPersonalMain.getIs_die()) && !StringUtils.isEmpty(oldPatPersonalMain.getIs_die()))
//    //  || (!StringUtils.isEmpty(newPatPersonalMain.getIs_die()) && StringUtils.isEmpty(oldPatPersonalMain.getIs_die()))
//    //  || (!StringUtils.isEmpty(newPatPersonalMain.getIs_die()) && !StringUtils.isEmpty(oldPatPersonalMain.getIs_die())
//    //  && 0 != newPatPersonalMain.getIs_die().compareTo(oldPatPersonalMain.getIs_die()))) {
//    if (null == newPatPersonalMain.getIs_die() && null != oldPatPersonalMain.getIs_die()
//      || null != newPatPersonalMain.getIs_die() && null == oldPatPersonalMain.getIs_die()
//      || null != newPatPersonalMain.getIs_die() && null != oldPatPersonalMain.getIs_die()
//      && 0 != newPatPersonalMain.getIs_die().compareTo(oldPatPersonalMain.getIs_die())) {
//      // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod end
//      return true;
//    }
//    //死因コードなし
//    //死亡日
//    if ((null == newPatPersonalMain.getDie_date() && null != oldPatPersonalMain.getDie_date())
//      || (null != newPatPersonalMain.getDie_date() && null == oldPatPersonalMain.getDie_date())
//      || (null != newPatPersonalMain.getDie_date() && null != oldPatPersonalMain.getDie_date()
//      && !newPatPersonalMain.getDie_date().equals(oldPatPersonalMain.getDie_date()))) {
//      return true;
//    }
//
//    //透析困難情報なし
//    //重症度コード
//    if ((null == newPatPersonalMain.getSeverity_cd() && null != oldPatPersonalMain.getSeverity_cd())
//      || (null != newPatPersonalMain.getSeverity_cd() && null == oldPatPersonalMain.getSeverity_cd())
//      || (null != newPatPersonalMain.getSeverity_cd() && null != oldPatPersonalMain.getSeverity_cd()
//      && !newPatPersonalMain.getSeverity_cd().equals(oldPatPersonalMain.getSeverity_cd()))) {
//      return true;
//    }
//
//    //搬送区分コード
//    if ((null == newPatPersonalMain.getTransport_cd() && null != oldPatPersonalMain.getTransport_cd())
//      || (null != newPatPersonalMain.getTransport_cd() && null == oldPatPersonalMain.getTransport_cd())
//      || (null != newPatPersonalMain.getTransport_cd() && null != oldPatPersonalMain.getTransport_cd()
//      && !newPatPersonalMain.getTransport_cd().equals(oldPatPersonalMain.getTransport_cd()))) {
//      return true;
//    }
//
//    //本人連絡先情報
//    if ((null == newPatPersonalMain.getPat_contact_info() && null != oldPatPersonalMain.getPat_contact_info())
//      || (null != newPatPersonalMain.getPat_contact_info() && null == oldPatPersonalMain.getPat_contact_info())
//      || (null != newPatPersonalMain.getPat_contact_info() && null != oldPatPersonalMain.getPat_contact_info()
//      && !newPatPersonalMain.getPat_contact_info().equals(oldPatPersonalMain.getPat_contact_info()))) {
//      return true;
//    }
//
//    //連絡先情報
//    if ((null == newPatPersonalMain.getOther_contact_info() && null != oldPatPersonalMain.getOther_contact_info())
//      || (null != newPatPersonalMain.getOther_contact_info() && null == oldPatPersonalMain.getOther_contact_info())
//      || (null != newPatPersonalMain.getOther_contact_info() && null != oldPatPersonalMain.getOther_contact_info()
//      && !newPatPersonalMain.getOther_contact_info().equals(oldPatPersonalMain.getOther_contact_info()))) {
//      return true;
//    }
//
//    //障害者加算
//    if ((null == newPatPersonalMain.getDial_diff_com_info() && null != oldPatPersonalMain.getDial_diff_com_info())
//      || (null != newPatPersonalMain.getDial_diff_com_info() && null == oldPatPersonalMain.getDial_diff_com_info())
//      || (null != newPatPersonalMain.getDial_diff_com_info() && null != oldPatPersonalMain.getDial_diff_com_info()
//      && !newPatPersonalMain.getDial_diff_com_info().equals(oldPatPersonalMain.getDial_diff_com_info()))) {
//      return true;
//    }
//
//    //業者連絡先情報なし
//    //保険情報なし?
//    //原疾患コード(patUnique)
//    //遠隔モニタリングサービス業者なし
//    //遠隔モニタリングサービス利用者IDなし
//    //遠隔モニタリングサービス利用者パスワードなし
//
//    return false;
//  }
//  // #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 add end
//  del #5607 連動機能の実装確認 20230411 孟堅　end
  /**
   * 電文を変換する。
   *
   * @param journalList ジャーナルのリスト
   * @param errorList 変換時エラーリスト
   * @param facilityCode 施設コード
   * @return 電文変換結果
   * @throws UnsupportedEncodingException
   */
  // mod 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start
  //  private List<ResultMap> convert(List<SysCoopJournal> journalList, List<ResultMap> errorList)
  //      throws UnsupportedEncodingException {
  private List<ResultMap> convert(List<SysCoopJournal> journalList, List<ResultMap> errorList, String facilityCode)
    throws UnsupportedEncodingException {
    // mod 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end
    List<ResultMap> resultList = new ArrayList<>();

    EventLogMessage eventLogMessage = new EventLogMessage();

    // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start
    List<MstCoopFacility.CoopOrdCd> coopOrdCdList = convertCommonService.getCoopOrdCdList(facilityCode);
    // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end
    /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    List<MstCoopIni> coopIniList = convertCommonService.getMstCoopIniByFacilityCd(facilityCode);
    MstCoopIni coopIni = CollectionUtils.isEmpty(coopIniList) ? null : coopIniList.get(0);
    /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

    for (SysCoopJournal journal : journalList) {
      // 施設コード
      String facilityCd = journal.getFacilityCd();

      // 向き（送受信）
      String direction = journal.getDirection();

      // 電文種別
      String coopCd = journal.getCoopCd();

// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      // 電子カルテ種別
      String key0 = StringUtils.isEmpty(journal.getKey0())?"":journal.getKey0();
      // 連携版番号
      String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

      // add 7391 exam_rst連携で受信した検査項目コード  吉 start
      /* add by chamaojia 2026-04-30 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
      final Map<String,String> examItemMap = new HashMap<String,String>();
      /* add by chamaojia 2026-04-30 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
      if(coopCd.equals("exam_rst")){
        List<MstExamItem> itemList = mstExamItemDao.selectByFacilityCd(facilityCd);
        if(null!=itemList && itemList.size()>0){
          for(MstExamItem item : itemList){
            examItemMap.put(item.getExamItemCd().toString(),item.getExamItemName());
          }
        }
      }
      // add 7391 exam_rst連携で受信した検査項目コード  吉 end
      // 付帯情報（電文）
      String coopCdIndex = journal.getCoopCdIndex();

      // 電文本体
      byte[] telegram = journal.getDump();

      // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start
      ExecutorService executor = Executors.newFixedThreadPool(1);
      Callable callable = new Callable() {
        @Override
        public String call() throws UnsupportedEncodingException {
          // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end
          try {
            // 患者単位の電文
            List<byte[]> telegramByPatientList = Collections.singletonList(telegram);

            // 1電文に複数の患者が含まれる場合
            // 区切り文字で分割した電文を処理対象とする。
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//            String[] multiSetting = getMultiSetting(facilityCd, direction, coopCd, coopCdIndex);
            String[] multiSetting = convertCommonService.getMultiSetting(facilityCd, direction, coopCd, coopCdIndex, coopVersion);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            if (Boolean.valueOf(multiSetting[0])) {
              String[] delimStrs = Arrays.copyOfRange(multiSetting, 1, multiSetting.length);
              telegramByPatientList = convertCommonService.splitTelegram(telegram, delimStrs);
            }

            for (byte[] b : telegramByPatientList) {
              //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
//              String s = new String(b, JournalConvertConstants.TELEGRAM_ENCODING_BY_SJIS);
              String s = new String(b, JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932);
              //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
              eventLogMessage.setLogMessage(String.format("teregram=[%s]", s));
              eventLogMessage.setFacilityCd(facilityCd);
              // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
              eventLogMessage.setInvokeClass(this.getClass().getName());
              // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
              logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

            }

// add 2021-09-16 #5897:CSI連携ができないの対応 孫 start
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//            MstCoopLayout mcl = convertCommonService.getMstCoopLayout(facilityCd, direction, coopCd, coopCdIndex,
//              JournalConvertConstants.AUX_CODE_PRELOGIC);
            MstCoopLayout mcl = convertCommonService.getMstCoopLayout(facilityCd, direction, coopCd, coopCdIndex,
              coopVersion, JournalConvertConstants.AUX_CODE_PRELOGIC);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

            String coopCdSubLayout = mcl.getCoopCdSub();
            String formatLayout = mcl.getCoopFormat();
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//            eventLogMessage.setLogMessage("[" + this.getClass().getSimpleName() + "]#convertByFormat: facility_cd:[" + facilityCd + "], "
//              + "direction:[" + direction + "], coop_cd:["+ coopCd + "], coop_cd_sub:[" + coopCdSubLayout + "], coop_format:[" + formatLayout + "]");
            eventLogMessage.setLogMessage("[" + this.getClass().getSimpleName() + "]#convertByFormat: facility_cd:[" + facilityCd + "], "
              + "direction:[" + direction + "], coop_cd:["+ coopCd + "], coop_version:["+ coopVersion
              + "], coop_cd_sub:[" + coopCdSubLayout + "], coop_format:[" + formatLayout + "]");
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            eventLogMessage.setFacilityCd(facilityCd);
            eventLogMessage.setInvokeClass(this.getClass().getName());
            logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
// add 2021-09-16 #5897:CSI連携ができないの対応 孫 end

// mod 2021-10-26 #5890:Medicom連携ができない(複数電文) 孫 start
//            for (byte[] tele : telegramByPatientList) {
//              // 1電文解析（患者単位）
//              ResultMap keyResult = new ResultMap();
//// mod 2021-09-16 #5897:CSI連携ができないの対応 孫 start
////              ResultMap colResult = convertByFormat(facilityCd, direction, coopCd, coopCdIndex, tele, keyResult, protocol);
//              ResultMap colResult = convertByFormat(facilityCd, direction, coopCd, coopCdIndex, coopCdSubLayout, formatLayout, tele, keyResult, protocol);
//// mod 2021-09-16 #5897:CSI連携ができないの対応 孫 end
//// mod 2021-08-25 受信時、電文内容を解析した後、sys_coop_journalのcrudを更新するの対応 孫 start
////              // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
////              updateTempContent(journal.getCtlNo(),colResult);
////              // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
//              String crud = "";
//              if (colResult.containsKey("$journal.const.crud")) {
//                crud = colResult.get("$journal.const.crud").toString();
//              }
//              if (StringUtils.isEmpty(crud)) {
//                crud = journal.getCrud();
//              } else {
//                  journal.setCrud(crud);
//              }
//// mod 2021-09-16 #5897:CSI連携ができないの対応 孫 start
////              updateTempContent(journal.getCtlNo(), colResult, crud);
//              updateTempContent(journal.getCtlNo(), colResult, crud, mcl);
//// mod 2021-09-16 #5897:CSI連携ができないの対応 孫 end
//// mod 2021-08-25 受信時、電文内容を解析した後、sys_coop_journalのcrudを更新するの対応 孫 end
//              resultList.add(colResult);
//
//              // pre処理時にkey属性で与えられる処理区分を返す。
//              String coopCdSub = (String) keyResult.get(JournalConvertConstants.KEY_SHORI_KUBUN);
//              colResult.putSpecial(JournalConvertConstants.KEY_SHORI_KUBUN, coopCdSub);
//
//              // ジャーナルの管理番号をDB登録処理に渡す。
//              colResult.putSpecial(JournalConvertConstants.KEY_JOURNAL_CTL_NO, journal.getCtlNo());
//
//              // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
//              colResult.putSpecial(JournalConvertConstants.COOP_CD, journal.getCoopCd());
//              colResult.putSpecial(JournalConvertConstants.COOP_CD_INDEX, journal.getCoopCdIndex());
//              colResult.putSpecial(JournalConvertConstants.DIRECTION, journal.getDirection());
//              colResult.putSpecial(JournalConvertConstants.USER_ID, journal.getUserId());
//              colResult.putSpecial(JournalConvertConstants.CRUD, journal.getCrud());
//              // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
//              //マップの文字をtrimする
//              trimMap(colResult);
//            }

            // add 2021-01-18 No.707:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
// add 2023-03-01 bug #8365 profile連携で登録された患者で患者経過総合ビューアを開くとエラーが発生し治療予定が作成できない 孫 start
            try {
// add 2023-03-01 bug #8365 profile連携で登録された患者で患者経過総合ビューアを開くとエラーが発生し治療予定が作成できない 孫 end
              // XMLのエンコーディングを取得する。
              String xmlEncoding = "";
              // XMLの有効ノードを取得する。
              String validNode = "";
              // XMLの複数結果ノードを取得する。
              String multiNode = "";
              LayoutExtSetting layoutExtSetting = mcl.getCoopExtSetting();
              if (layoutExtSetting != null && layoutExtSetting.containsKey("soap")) {
                Map<String, String> soapSetting = ObjectMapperUtil.castToStringStringMap(layoutExtSetting.get("soap"));
                if (soapSetting != null && soapSetting.containsKey("xmlEncoding")) {
                  xmlEncoding = soapSetting.get("xmlEncoding");
                }
                if (soapSetting != null && soapSetting.containsKey("validNode")) {
                  validNode = soapSetting.get("validNode");
                }
                if (soapSetting != null && soapSetting.containsKey("multiNode")) {
                  multiNode = soapSetting.get("multiNode");
                }

                // 電文再処理
                List<byte[]> newTelegramList = new ArrayList<>();
                for (byte[] tele : telegramByPatientList) {
                  //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
//                String teleString = new String(tele, JournalConvertConstants.TELEGRAM_ENCODING_BY_SJIS);
                  String teleString = new String(tele, JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932);
                  //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
                  // エンコーディングでエンコーディング再設定する
                  if (!StringUtils.isEmpty(xmlEncoding)) {
                    teleString = new String(tele, xmlEncoding);
                  }

                  // 有効ノードでXMLの有効データを取得する
                  if (!StringUtils.isEmpty(validNode)) {
                    String startNode = String.format("<%s>", validNode);
                    String endNode = String.format("</%s>", validNode);
                    int startIndex = teleString.indexOf(startNode);
                    int endIndex = teleString.indexOf(endNode) + endNode.length();
                    teleString = teleString.substring(startIndex, endIndex);
                  }

                  // 複数結果ノードでXMLの複数結果データを取得する
                  if (!StringUtils.isEmpty(multiNode)) {
                    String startmulti = String.format("<%s>", multiNode);
                    String endtmulti = String.format("</%s>", multiNode);
                    int startIndex = teleString.indexOf(startmulti);
                    int endIndex = teleString.lastIndexOf(endtmulti);
                    String startXmlData = teleString.substring(0, startIndex);
                    String endXmlData = teleString.substring(endIndex + endtmulti.length());

                    startIndex = endIndex = 0;
                    do {
                      // 新しい電文を作成する
                      startIndex = teleString.indexOf(startmulti, endIndex);
                      endIndex = teleString.indexOf(endtmulti, endIndex) + endtmulti.length();
                      String teleData = teleString.substring(startIndex, endIndex);
                      String newTeleString = startXmlData + teleData + endXmlData;

                      //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
//                    byte[] teleNew = newTeleString.getBytes(JournalConvertConstants.TELEGRAM_ENCODING_BY_SJIS);
                      byte[] teleNew = newTeleString.getBytes(JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932);
                      //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
                      newTelegramList.add(teleNew);
                    } while (teleString.indexOf(startmulti, endIndex) > 0);
                  } else {
                    //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
//                  byte[] teleNew = teleString.getBytes(JournalConvertConstants.TELEGRAM_ENCODING_BY_SJIS);
                    byte[] teleNew = teleString.getBytes(JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932);
                    //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
                    newTelegramList.add(teleNew);
                  }
                }

                // 新しい電文を再設定する
                telegramByPatientList = new ArrayList<>();
                telegramByPatientList.addAll(newTelegramList);
              }
// add 2023-03-01 bug #8365 profile連携で登録された患者で患者経過総合ビューアを開くとエラーが発生し治療予定が作成できない 孫 start
            } catch (Exception ex) {
              String errMsg = "連携電文設定マスタの拡張設定(coop_ext_setting->soap->validNode/xmlEncoding)の設定内容不正。電文より、再設定してください。";
              throw new NtssException(errMsg);
            }
// add 2023-03-01 bug #8365 profile連携で登録された患者で患者経過総合ビューアを開くとエラーが発生し治療予定が作成できない 孫 end
            // add 2021-01-18 No.707:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end

            int teleCnt = 0;
            // 2020-05-13 #7352 #7353 profile連携（標準）の複数患者データ取り込みでエラー発生 孟堅　start
            List<Object> pluralHostIp = new ArrayList<>();
            // 2020-05-13 #7352 #7353  profile連携（標準）の複数患者データ取り込みでエラー発生 孟堅　end
            for (byte[] tele : telegramByPatientList) {
              teleCnt ++;
              // 1電文解析（患者単位）
              ResultMap keyResult = new ResultMap();
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//              ResultMap colResult = convertByFormat(facilityCd, direction, coopCd, coopCdIndex, coopCdSubLayout, formatLayout, tele, keyResult);
              ResultMap colResult = convertByFormat(facilityCd, direction, coopCd, coopCdIndex, coopVersion, key0,
                coopCdSubLayout, formatLayout, tele, keyResult);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

              // 作成更新区分を再設定する
              if (colResult.containsKey("$journal.const.crud")) {
                String crud = colResult.get("$journal.const.crud").toString();
                if (!StringUtils.isEmpty(crud)) {
                  journal.setCrud(crud);
                }
              }

              // pre処理時にkey属性で与えられる処理区分を返す。
              String coopCdSub = (String) keyResult.get(JournalConvertConstants.KEY_SHORI_KUBUN);
              colResult.putSpecial(JournalConvertConstants.KEY_SHORI_KUBUN, coopCdSub);
              // ジャーナルの管理番号をDB登録処理に渡す。
              colResult.putSpecial(JournalConvertConstants.KEY_JOURNAL_CTL_NO, journal.getCtlNo());
              // 受信のプロセス項目を追加する
              colResult.putSpecial(JournalConvertConstants.COOP_CD, journal.getCoopCd());
              colResult.putSpecial(JournalConvertConstants.COOP_CD_INDEX, journal.getCoopCdIndex());
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
              colResult.putSpecial(JournalConvertConstants.COOP_VERSION, coopVersion);
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
              colResult.putSpecial(JournalConvertConstants.KEY0, key0);
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              colResult.putSpecial(JournalConvertConstants.DIRECTION, journal.getDirection());
              colResult.putSpecial(JournalConvertConstants.USER_ID, journal.getUserId());
              colResult.putSpecial(JournalConvertConstants.CRUD, journal.getCrud());
              // 2020-05-13 #7352 #7353 profile連携（標準）の複数患者データ取り込みでエラー発生 孟堅　start
              // 複数患者の場合hosp pat id　取得する
              String hosp_pat_id = (String)colResult.get("$journal.pat_personal_main.hosp_pat_id");
              // mod #8103 GX連携で実装されていない機能（利用者情報）limf start
              if (colResult.containsKey("$journal.pat_personal_main.hosp_pat_id")) {
                // add #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 start
                if (colResult.get("%%journal_ctl_no") == journal.getCtlNo()) {
                  hosp_pat_id = getFacilityHospPatIdMethod((String) colResult.get("$journal.pat_personal_main.hosp_pat_id"), facilityCd);
                  colResult.put("$journal.pat_personal_main.hosp_pat_id", hosp_pat_id);
                }
                // 9415-NKK連携 exam_rst 必須項目が空白の場合の処理・メッセージが正しくない zhoubin add start
                if(Key0Constant.NKK.equals(key0) && CoopCdConstant.EXAM_RST.equals(journal.getCoopCd())) {
                  checkExamRstForNKK(journal, colResult);
                }
                // 9415-NKK連携 exam_rst 必須項目が空白の場合の処理・メッセージが正しくない zhoubin add end
                if ("".equals(hosp_pat_id)) {
                  String errMsg = "連携設定マスタの各機能共通設定に患者番号の比較方法または右切り取り数を設定されません。 比較方法=[hosp_pat_id_company_method_code], 右切り取り数=[cut_off_digits]";
                  throw new NtssException(errMsg);
                }
              }
              // add #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 end
              // mod #8103 GX連携で実装されていない機能（利用者情報）limf end
              if( hosp_pat_id!= null && !"".equals(hosp_pat_id)){
                pluralHostIp.add(hosp_pat_id);
              }
              // 2020-05-13 #7352 #7353 profile連携（標準）の複数患者データ取り込みでエラー発生 孟堅　end
              //マップの文字をtrimする
              trimMap(colResult);
              // ジャーナルのtemp_contentを更新する
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//              updateTempContent(journal.getCtlNo(), colResult, journal.getCrud(), mcl);
              /* upd by chamaojia 2026-04-24 [10959] add param coopIni、examItemMap --start */
              updateTempContent(journal.getCtlNo(), colResult, journal.getCrud(), mcl, journal.getKey0(), coopIni, examItemMap);
              /* upd by chamaojia 2026-04-24 [10959] add param coopIni、examItemMap --end */
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

              // 電文変換結果を追加する
              // 外部連携用ジャーナルの１つデータに電文変換結果の先頭の１つデータを追加する。※このデータを利用しません。
              // 複数患者場合、ャーナルのtemp_contentに複数データを更新する
              if (teleCnt == 1) {
                // 単数の患者番号を追加する
                colResult.putSpecial(JournalConvertConstants.PATPLURALTAG,JournalConvertConstants.ONEPAT);
                resultList.add(colResult);
              }
            }
            // 2020-05-13 #7352 #7353 profile連携（標準）の複数患者データ取り込みでエラー発生 孟堅　start
            if(Boolean.valueOf(multiSetting[0])){
              // 複数数の患者番号を追加する
              //　mod #5607 連動機能の実装確認 20221205 孟堅　start
              //resultList.get(0).put(JournalConvertConstants.PATPLURALTAG,JournalConvertConstants.PLURALPAT);
              //resultList.get(0).put(JournalConvertConstants.PLURALPATLIST,pluralHostIp);
              resultList.get(resultList.size()-1).put(JournalConvertConstants.PATPLURALTAG,JournalConvertConstants.PLURALPAT);
              resultList.get(resultList.size()-1).put(JournalConvertConstants.PLURALPATLIST,pluralHostIp);
              //　mod #5607 連動機能の実装確認 20221205 孟堅　end
            }
            // 2020-05-13 #7352 #7353 profile連携（標準）の複数患者データ取り込みでエラー発生 孟堅　end
// mod 2021-10-26 #5890:Medicom連携ができない(複数電文) 孫 end

          } catch (NtssException e) {
            String error = StringUtils.isEmpty(e.getMessage()) ? "電文変換に失敗しました" : e.getMessage();
// add 2021-11-03 #5904:日機装連携ができない(患者プロファイル) 孫 start
            StackTraceElement[]  list = null;
            String errAdd = "";
            if (e.getCause() != null && e.getCause().getStackTrace() != null
              && e.getCause().getStackTrace().length > 0) {
              list = e.getCause().getStackTrace();
              for (StackTraceElement err : list) {
                if (err != null && err.toString().startsWith("jp.co.")) {
                  errAdd = errAdd + "\r\n" + err.toString();
                }
              }
            }
            if (StringUtils.isEmpty(errAdd)) {
              list = e.getStackTrace();
              for (StackTraceElement err : list) {
                if (err != null && err.toString().startsWith("jp.co.")) {
                  errAdd = errAdd + "\r\n" + err.toString();
                }
              }
            }
            error = error + errAdd;
// add 2021-11-03 #5904:日機装連携ができない(患者プロファイル) 孫 end
            // 処理中のジャーナルの変換ステータスを「内部エラー」に更新
            updateAnaResult(journal, error, AnaResult.INTERNAL_ERROR);

            // #10453 add 死活監視が動作していない 2024-05-16 荘 start
            healthService.update(journal, AnaResult.INTERNAL_ERROR.getResult());
            // #10453 add 死活監視が動作していない 2024-05-16 荘 end

            // エラーリストに追加
            ResultMap rm = new ResultMap();
            rm.put(ResultKey.MESSAGE.getKey(), journal.getMessage());
            rm.put(ResultKey.CTL_NO.getKey(), journal.getCtlNo());
            rm.put(ResultKey.ANA_RESULT.getKey(), journal.getAnaResult());
            // 9415-NKK連携 exam_rst 必須項目が空白の場合の処理・メッセージが正しくない zhoubin add start
            rm.put(EXAM_RST_HOSPPATID, journal.getHospPatId());
            // 9415-NKK連携 exam_rst 必須項目が空白の場合の処理・メッセージが正しくない zhoubin add end
            errorList.add(rm);
          }
          // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start
          return "Success";
        }
      };
      Future<String> future = executor.submit(callable);
      try {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        String result = future.get(getTimeOutSecond(journal.getCoopCd(),coopOrdCdList), TimeUnit.SECONDS);
        String coopVersionForTimeout = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
        String result = future.get(getTimeOutSecond(journal.getCoopCd(), coopVersionForTimeout, coopOrdCdList), TimeUnit.SECONDS);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        // mod 2021/04/20 bug #4267　エラーのはずがスキップになる 対応 start
        //} catch (InterruptedException | ExecutionException | TimeoutException e) {
      } catch (TimeoutException e) {
        // mod 2021/04/20 bug #4267　エラーのはずがスキップになる 対応 end
        future.cancel(true);
        // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 20221220 mod start
        //String error = StringUtils.isEmpty(e.getMessage()) ? "電文変換に失敗しました" : e.getMessage();
        String error = TIMEOUT_MSG;
        // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 20221220 mod end
// add 2021-11-03 #5904:日機装連携ができない(患者プロファイル) 孫 start
        StackTraceElement[]  list = null;
        String errAdd = "";
        if (e.getCause() != null && e.getCause().getStackTrace() != null
          && e.getCause().getStackTrace().length > 0) {
          list = e.getCause().getStackTrace();
          for (StackTraceElement err : list) {
            if (err != null && err.toString().startsWith("jp.co.")) {
              errAdd = errAdd + "\r\n" + err.toString();
            }
          }
        }
        if (StringUtils.isEmpty(errAdd)) {
          list = e.getStackTrace();
          for (StackTraceElement err : list) {
            if (err != null && err.toString().startsWith("jp.co.")) {
              errAdd = errAdd + "\r\n" + err.toString();
            }
          }
        }
        error = error + errAdd;
// add 2021-11-03 #5904:日機装連携ができない(患者プロファイル) 孫 end
        // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 mod start
        // 処理中のジャーナルの変換ステータスを「スキップ」に更新
        //updateAnaResult(journal, error, AnaResult.SKIP);
        updateAnaResult(journal, error, AnaResult.INTERNAL_ERROR);
        // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 mod end

        // #10453 add 死活監視が動作していない 2024-05-16 荘 start
        healthService.update(journal, AnaResult.INTERNAL_ERROR.getResult());
        // #10453 add 死活監視が動作していない 2024-05-16 荘 end

        // エラーリストに追加
        ResultMap rm = new ResultMap();
        rm.put(ResultKey.MESSAGE.getKey(), journal.getMessage());
        rm.put(ResultKey.CTL_NO.getKey(), journal.getCtlNo());
        rm.put(ResultKey.ANA_RESULT.getKey(), journal.getAnaResult());
        // 9415-NKK連携 exam_rst 必須項目が空白の場合の処理・メッセージが正しくない zhoubin add start
        rm.put(EXAM_RST_HOSPPATID, journal.getHospPatId());
        // 9415-NKK連携 exam_rst 必須項目が空白の場合の処理・メッセージが正しくない zhoubin add end
        errorList.add(rm);
      }
      // add 2021/04/20 bug #4267　エラーのはずがスキップになる 対応 start
      catch (InterruptedException | ExecutionException e) {
        String error = StringUtils.isEmpty(e.getMessage()) ? "電文変換に失敗しました" : e.getMessage();
// add 2021-11-03 #5904:日機装連携ができない(患者プロファイル) 孫 start
        StackTraceElement[]  list = null;
        String errAdd = "";
        if (e.getCause() != null && e.getCause().getStackTrace() != null
          && e.getCause().getStackTrace().length > 0) {
          list = e.getCause().getStackTrace();
          for (StackTraceElement err : list) {
            if (err != null && err.toString().startsWith("jp.co.")) {
              errAdd = errAdd + "\r\n" + err.toString();
            }
          }
        }
        if (StringUtils.isEmpty(errAdd)) {
          list = e.getStackTrace();
          for (StackTraceElement err : list) {
            if (err != null && err.toString().startsWith("jp.co.")) {
              errAdd = errAdd + "\r\n" + err.toString();
            }
          }
        }
        error = error + errAdd;
// add 2021-11-03 #5904:日機装連携ができない(患者プロファイル) 孫 end
        // 処理中のジャーナルの変換ステータスを「内部エラー」に更新
        updateAnaResult(journal, error, AnaResult.INTERNAL_ERROR);

        // #10453 add 死活監視が動作していない 2024-05-16 荘 start
        healthService.update(journal, AnaResult.INTERNAL_ERROR.getResult());
        // #10453 add 死活監視が動作していない 2024-05-16 荘 end

        // エラーリストに追加
        ResultMap rm = new ResultMap();
        rm.put(ResultKey.MESSAGE.getKey(), journal.getMessage());
        rm.put(ResultKey.CTL_NO.getKey(), journal.getCtlNo());
        rm.put(ResultKey.ANA_RESULT.getKey(), journal.getAnaResult());
        // 9415-NKK連携 exam_rst 必須項目が空白の場合の処理・メッセージが正しくない zhoubin add start
        rm.put(EXAM_RST_HOSPPATID, journal.getHospPatId());
        // 9415-NKK連携 exam_rst 必須項目が空白の場合の処理・メッセージが正しくない zhoubin add end
        errorList.add(rm);
      }
      // add 2021/04/20 bug #4267　エラーのはずがスキップになる 対応 end
      executor.shutdownNow();
      // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end

      // JSON変換結果をログに出力する。（デバッグモード時のみ、動作確認用）
      if (log.isDebugEnabled()) {
        outputConversionLog(facilityCd, resultList);
      }
    }

    return resultList;
  }

  // 9415-NKK連携 exam_rst 必須項目が空白の場合の処理・メッセージが正しくない zhoubin add start
  private void checkExamRstForNKK(SysCoopJournal journal, JournalConvertResult.ResultMap colResult) {

    StringBuilder errorMsg = new StringBuilder();
    errorMsg.append(EXAM_RST_EMPTY_MSG_HEAD);
    String examDate = new String(journal.getDump(), EXAM_RST_DATE_OFFSET, EXAM_RST_DATE_LEN);
    //採取日
    if (!hasLength(examDate.trim())) {
      errorMsg.append(EXAM_RST_NAME_DATE + STR_TOUTEN);
    }
    // add #9829 NKK連携 exam_rst 採取時刻が空白の場合、00:00で検査結果がとりこまれる 孟堅　20230921　 start
    //採取時刻
    if(!hasLength(colResult.get(EXAM_RST_RESULT_EXAM_DATE).toString().substring(8))){
      errorMsg.append(EXAM_RST_NAME_RESULTEXAMDATE + STR_TOUTEN);
    }
    // add #9829 NKK連携 exam_rst 採取時刻が空白の場合、00:00で検査結果がとりこまれる 孟堅　20230921　 end
    //透析前後
    if(!hasLength(colResult.get(EXAM_RST_REGORDERCLASS).toString())) {
      errorMsg.append(EXAM_RST_NAME_REGORDERCLASS + STR_TOUTEN);
    }

    //患者ID
    if(!hasLength(colResult.get(EXAM_RST_HOSPPATID).toString())) {
      errorMsg.append(EXAM_RST_NAME_HOSPPATID + STR_TOUTEN);
    }

    errorMsg = EXAM_RST_EMPTY_MSG_HEAD.equals(errorMsg.toString()) ? new StringBuilder()
      : errorMsg.deleteCharAt(errorMsg.toString().length() - 1).append(EXAM_RST_EMPTY_MSG_TAIL);

    if(hasLength(errorMsg.toString())) {
      journal.setHospPatId(colResult.get(EXAM_RST_HOSPPATID).toString());
      throw new NtssException(errorMsg.toString());
    }

  }
  // 9415-NKK連携 exam_rst 必須項目が空白の場合の処理・メッセージが正しくない zhoubin add end
  /* del by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --start */
//  /**
//   * 複数患者指定を取得する。
//   *
//   * @param facilityCd 施設コード
//   * @param direction 向き（送受信）
//   * @param coopCd 電文種別
//   * @param coopCdIndex 付帯情報（電文）
//   * @param coopVersion 連携版番号
//   * @return 先頭が複数患者対応可否文字列（"true"/"false"）、残りが区切り文字を表す文字列配列
//   */
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////  private String[] getMultiSetting(String facilityCd, String direction, String coopCd, String coopCdIndex) {
////    MstCoopLayout mcl = convertCommonService.getMstCoopLayout(facilityCd, direction, coopCd, coopCdIndex,
////      JournalConvertConstants.AUX_CODE_PRELOGIC);
//  private String[] getMultiSetting(String facilityCd, String direction, String coopCd, String coopCdIndex,
//                                   String coopVersion) {
//    MstCoopLayout mcl = convertCommonService.getMstCoopLayout(facilityCd, direction, coopCd, coopCdIndex, coopVersion,
//      JournalConvertConstants.AUX_CODE_PRELOGIC);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//    String multi = mcl.getCoopSettingRoot().getMulti();
//    EventLogMessage eventLogMessage = new EventLogMessage();
//
//    if (StringUtils.isEmpty(multi)) {
//      return new String[] { Boolean.FALSE.toString(), null };
//    }
//
//    String[] sp = multi.split(CoopConstant.LAYOUT_MULTI_DELIM);
//    if (sp.length == 1) {
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////      String errMsg = String.format("1電文複数患者指定で、区切り文字が指定されていません。 施設コード=[%s], 電文種別=[%s]", facilityCd, coopCd);
//      String errMsg = String.format("1電文複数患者指定で、区切り文字が指定されていません。 施設コード=[%s], 電文種別=[%s], 連携版番号=[%s]",
//        facilityCd, coopCd, coopVersion);
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
//      eventLogMessage.setLogMessage(errMsg);
//      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//      throw new NtssException(errMsg);
//    }
//
//    return Arrays.asList(sp).stream().map(e -> e.replaceAll(CoopConstant.TELEGRAM_DELIM_CR, CoopConstant.TELEGRAM_DELIM_CR_VALUE)
//        .replaceAll(CoopConstant.TELEGRAM_DELIM_LF, CoopConstant.TELEGRAM_DELIM_LF_VALUE)).toArray(String[]::new);
//  }
//
//  /**
//   * 電文を区切り文字で分割する。
//   *
//   * @param telegram 電文
//   * @param delimStrs 電文区切り文字列（複数）
//   * @return 分割された電文
//   * @throws UnsupportedEncodingException
//   */
//  private List<byte[]> splitTelegram(byte[] telegram, String[] delimStrs) throws UnsupportedEncodingException {
//    // 分割用の正規表現
//    String s = CoopConstant.REGEXP_GROUP_START + String.join(CoopConstant.REGEXP_GROUP_OR, delimStrs) + CoopConstant.REGEXP_GROUP_END;
//    Pattern p = Pattern.compile(s);
//
//    // 一旦文字列に変換してから分割する。
//    // byte配列のまま複数の区切り文字で分割すると、処理が非常に複雑になる。
//    // この後に項目を抽出して文字列に変換しており冗長だが、処理の読解性・保守性を優先した。
//    //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
////    String telegramStr = new String(telegram, JournalConvertConstants.TELEGRAM_ENCODING_BY_SJIS);
//    String telegramStr = new String(telegram, JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932);
//    //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
//    String[] telegramParts = p.split(telegramStr);
//
//    // 分割した電文文字列をbyte配列に変換する。
//    // （Streamで変換したいところだが、明示的にループで処理する方法を採った。
//    // Streamのmapやcollect処理では検査例外を処理できないことによる。
//    // 検査例外: 下記の処理ではString.getBytes()で発生するUnsupportedEncodingException）
//    List<byte[]> result = new ArrayList<>();
//    for (String t : telegramParts) {
//      //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
////      result.add(t.getBytes(JournalConvertConstants.TELEGRAM_ENCODING_BY_SJIS));
//      result.add(t.getBytes(JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932));
//      //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
//    }
//
//    return result;
//  }
  /* del by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --end */

  /**
   * マップの文字をtrimする
   * @param paramMap  電文から抽出した項目のマップ
   */
  @SuppressWarnings("unchecked")
  public static void trimMap(Map<String, Object> paramMap) {
    if (paramMap == null) {
      return;
    }
    Set<String> keySets = paramMap.keySet();
    for (String key : keySets) {
      Object obj = paramMap.get(key);
      if (obj != null && obj instanceof String) {
        //Stringの場合trimする
        paramMap.put(key, StringUtils.trimWhitespace((String) obj));
      } else if (obj instanceof Map) {
        //Mapの場合
        Map<String, Object> mapObj = (Map<String, Object>) obj;
        trimMap(mapObj);
      } else if (obj instanceof Map[]) {
        //配列の場合
        Map<String, Object>[] arrayObj = (Map<String, Object>[]) obj;
        for (Map<String, Object> map : arrayObj) {
          trimMap(map);
        }
      }
    }
  }

  /**
   * フォーマット別に振り分けて変換する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param key0 電子カルテ種別
   * @param coopCdSub 電文種別補足コード
   * @param format 電文フォーマット
   * @param telegram 電文
   * @param keyResult key属性抽出結果
   * @param protocol 配信プロトコル
   * @return col属性抽出結果
   */
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//// mod 2021-09-16 #5897:CSI連携ができないの対応 孫 start
////  private ResultMap convertByFormat(String facilityCd, String direction, String coopCd, String coopCdIndex,
////      byte[] telegram, ResultMap keyResult, String protocol) {
////
////    MstCoopLayout mcl = convertCommonService.getMstCoopLayout(facilityCd, direction, coopCd, coopCdIndex,
////        JournalConvertConstants.AUX_CODE_PRELOGIC);
////
////    String coopCdSub = mcl.getCoopCdSub();
////    String format = mcl.getCoopFormat();
////    EventLogMessage eventLogMessage = new EventLogMessage();
////    eventLogMessage.setLogMessage("[" + this.getClass().getSimpleName() + "]#convertByFormat: facility_cd:[" + facilityCd + "], "
////        + "direction:[" + direction + "], coop_cd:["+ coopCd + "], coop_cd_sub:[" + coopCdSub + "], coop_format:[" + format + "]");
////    eventLogMessage.setFacilityCd(facilityCd);
////    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
////    eventLogMessage.setInvokeClass(this.getClass().getName());
////    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
////    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//  private ResultMap convertByFormat(String facilityCd, String direction, String coopCd, String coopCdIndex,
//      String coopCdSub, String format, byte[] telegram, ResultMap keyResult) {
//    EventLogMessage eventLogMessage = new EventLogMessage();
//// mod 2021-09-16 #5897:CSI連携ができないの対応 孫 end
  private ResultMap convertByFormat(String facilityCd, String direction, String coopCd, String coopCdIndex,
                  String coopVersion, String key0, String coopCdSub, String format, byte[] telegram, ResultMap keyResult) {
      EventLogMessage eventLogMessage = new EventLogMessage();
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    try {
      switch (format) {
        case JournalConvertConstants.FORMAT_TEXT:
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          return convertTextServiceImpl.convert(facilityCd, direction, coopCd, coopCdIndex, coopCdSub, telegram, keyResult);
          return convertTextServiceImpl.convert(facilityCd, direction, coopCd, coopCdIndex, coopVersion, key0,
            coopCdSub, telegram, keyResult);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

        case JournalConvertConstants.FORMAT_XML:
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          return convertXmlServiceImpl.convert(facilityCd, direction, coopCd, coopCdIndex, coopCdSub, telegram, keyResult);
          return convertXmlServiceImpl.convert(facilityCd, direction, coopCd, coopCdIndex, coopVersion, key0,
            coopCdSub, telegram, keyResult);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

        case JournalConvertConstants.FORMAT_CSV:
// mod 22023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          return convertCsvServiceImpl.convert(facilityCd, direction, coopCd, coopCdIndex, coopCdSub, telegram, keyResult);
          return convertCsvServiceImpl.convert(facilityCd, direction, coopCd, coopCdIndex, coopVersion, key0,
            coopCdSub, telegram, keyResult);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

        default:
          String errMsg = String.format("未対応の電文フォーマットです。フォーマット:[%s]", format);
          eventLogMessage.setLogMessage(errMsg);
          eventLogMessage.setFacilityCd(facilityCd);
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
          eventLogMessage.setInvokeClass(this.getClass().getName());
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
          logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          throw new NtssException(errMsg);
      }
    } catch (UnsupportedEncodingException e) {
      throw new NtssException("電文のエンコーディングがサポートされていない形式です。", e);
    }
  }

  /**
   * ジャーナルのJSON変換結果をログに出力する。
   *
   * @param resultList ジャーナル変換結果
   */
  private void outputConversionLog(String facilityCd, List<ResultMap> resultList) {
    try {
      EventLogMessage eventLogMessage = new EventLogMessage();
      String conversionJson = ObjectMapperUtil.getObjectMapper()
          .writer(SerializationFeature.INDENT_OUTPUT)
          .writeValueAsString(resultList);
      eventLogMessage.setLogMessage(facilityCd + ":電文解析結果（JSON変換）:" + conversionJson);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    } catch (JacksonException e) {
    }
  }

  /* modify by chamaojia 2023-06-20 プロセスを続行するために成功したレコードを返す  --start */
  /**
   * ジャーナルの変換ステータスを更新する。
   *
   * @param journalList ジャーナルのリスト
   * @param status 変換ステータス
   * @return 更新件数
   */
  private List<SysCoopJournal> updateConvStatus(List<SysCoopJournal> journalList, AnaResult status) {
    journalList.forEach(e -> e.setAnaResult(status.getResult()));
    List<Long> ctlNoList = journalList.stream().map(e -> e.getCtlNo()).collect(Collectors.toList());
    List<Long> successCtlNoList = convertCommonService.updateConvStatus(ctlNoList, status.getResult(), JournalConvertConstants.DIRECTION_RECEIVE);
    return journalList.stream().filter(t -> successCtlNoList.contains(t.getCtlNo())).collect(Collectors.toList());
  }
  /* modify by chamaojia 2023-06-20 プロセスを続行するために成功したレコードを返す  --end */

  /**
   * ジャーナルの変換ステータスを更新する
   * ※レコード単位での更新
   *
   * @param journal 更新対象のジャーナル
   * @param status 更新する変換ステータス
   * */
  private int updateAnaResult(SysCoopJournal journal, String message, AnaResult status) {
    journal.setAnaResult(status.getResult());
    journal.setMessage(message);
    return convertCommonService.updateAnaResult(journal.getCtlNo(), message, status.getResult());
  }

  // add 2021-07-06 #5248:処理キャンセルのしくみ 孫 start
  /**
   * ジャーナルの変換ステータスを更新する
   * ※管理番号での更新
   *
   * @param ctlNo 更新対象の管理番号
   * @param message 更新するメッセージ
   * @param status 更新する変換ステータス
   * */
  private int updateAnaResultByCtlNo(Long ctlNo, String message, String status) {
    return convertCommonService.updateAnaResult(ctlNo, message, status);
  }
  // add 2021-07-06 #5248:処理キャンセルのしくみ 孫 end

  // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start
  /**
   * タイムアウト時間取得
   *
   * @param coopCd 電文種別
   * @param coopVersion 連携版番号
   * @param coopOrdCdList 各機能共通設定
   * @return timeOutSecond タイムアウト時間
   */
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private int getTimeOutSecond(String coopCd, List<MstCoopFacility.CoopOrdCd> coopOrdCdList) {
  private int getTimeOutSecond(String coopCd, String coopVersion, List<MstCoopFacility.CoopOrdCd> coopOrdCdList) {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    int defaultTimeOut = 20;
    if (coopOrdCdList != null && coopOrdCdList.size() > 0) {
      for (int i = 0; i < coopOrdCdList.size(); i++) {
        // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 20221208 mod start
        //if (coopCd.equals(coopOrdCdList.get(i).getCoopCd())) {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        if (coopCd.equals(coopOrdCdList.get(i).getCoopCd())
        String coopVersionDef = StringUtils.isEmpty(coopOrdCdList.get(i).getCoopVersion())?"":coopOrdCdList.get(i).getCoopVersion();
        if (coopCd.equals(coopOrdCdList.get(i).getCoopCd()) && coopVersion.equals(coopVersionDef)
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          && 0 == JournalConvertConstants.DIRECTION_RECEIVE.compareTo(coopOrdCdList.get(i).getDirection())) {
        // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 20221208 mod end
          if (!StringUtils.isEmpty(coopOrdCdList.get(i).getTimeOutSecond())) {
            return Integer.parseInt(coopOrdCdList.get(i).getTimeOutSecond());
          }
        }
      }
    }
    return defaultTimeOut;
  }
  // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end

  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
// mod 2021-09-16 #5897:CSI連携ができないの対応 孫 start
//  /**
//   * ジャーナルのtemp_contentを更新する。
//   *
//   * @param ctlNo 管理番号
//   * @param rm key属性抽出結果
//   * @param crud 電文内容の処理区分
//   */
//// mod 2021-08-25 受信時、電文内容を解析した後、sys_coop_journalのcrudを更新するの対応 孫 start
////  private void updateTempContent(Long ctlNo,ResultMap rm) {
//  private void updateTempContent(Long ctlNo,ResultMap rm, String crud) {
//// mod 2021-08-25 受信時、電文内容を解析した後、sys_coop_journalのcrudを更新するの対応 孫 end
//    String tempContent = getTempContentValue(rm);
//// mod 2021-08-25 受信時、電文内容を解析した後、sys_coop_journalのcrudを更新するの対応 孫 start
////    convertCommonService.updateTempContent(ctlNo, tempContent);
//    convertCommonService.updateTempContent(ctlNo, tempContent, crud);
//// mod 2021-08-25 受信時、電文内容を解析した後、sys_coop_journalのcrudを更新するの構築の対応 孫 end
//  }

  /**
   * ジャーナルのtemp_contentを更新する。
   *
   * @param ctlNo 管理番号
   * @param rm key属性抽出結果
   * @param crud 電文内容の処理区分
   * @param mcl MstCoopLayout
   * @param key0 電子カルテ種別
   */
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private void updateTempContent(Long ctlNo,ResultMap rm, String crud, MstCoopLayout mcl) {
//    String tempContent = getTempContentValue(rm, mcl);
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、examItemMap --start */
  private void updateTempContent(Long ctlNo,ResultMap rm, String crud, MstCoopLayout mcl, String key0, MstCoopIni coopIni,
      Map<String,String> examItemMap) {
    String tempContent = getTempContentValue(rm, mcl, key0, coopIni, examItemMap);
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、examItemMap --end */
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    convertCommonService.updateTempContent(ctlNo, tempContent, crud);
  }
// mod 2021-09-16 #5897:CSI連携ができないの対応 孫 end

  /**
   * temp_contentの更新値を取得する。
   *
   * @param rm key属性抽出結果
   * @param mcl MstCoopLayout
   * @return 更新値
   */
// mod 2021-09-16 #5897:CSI連携ができないの対応 孫 start
//  private String getTempContentValue(ResultMap rm) {
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private String getTempContentValue(ResultMap rm, MstCoopLayout mcl) {
    /* upd by chamaojia 2026-04-24 [10959] add param coopIni、examItemMap --start */
    private String getTempContentValue(ResultMap rm, MstCoopLayout mcl, String key0, MstCoopIni coopIni,
      Map<String,String> examItemMap) {
    /* upd by chamaojia 2026-04-24 [10959] add param coopIni、examItemMap --end */
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
// mod 2021-09-16 #5897:CSI連携ができないの対応 孫 end
    if (rm.isEmpty()) {
      return null;
    }
    // add 7391 exam_rst連携で受信した検査項目コード  吉 start
    String examHospiteStr ="";
    // add #8292 exam_rst連携で受信した検査データの登録ができない 孟堅　start
    String examHospitalCd ="";
    // add #8292 exam_rst連携で受信した検査データの登録ができない 孟堅　end
    // add 7391 exam_rst連携で受信した検査項目コード  吉 end
// add 2021-09-16 #5897:CSI連携ができないの対応 孫 start
    // 外部連携のコード→本システムコード変換の初期化処理
    // 施設コード
    String facilityCd = mcl.getFacilityCd();
    // ①変換項目を取得する
    LayoutExtSetting layoutExtSetting = mcl.getCoopExtSetting();
    // コード変換項目設定が有りか
    Map<String, String> coopIniConvItem = null;
    if (layoutExtSetting.containsKey("CoopIniConvUtil")) {
      try {
        coopIniConvItem = ObjectMapperUtil.castToStringStringMap(layoutExtSetting.get("CoopIniConvUtil"));
      } catch (Exception ex) {
        String message = String.format("連携電文設定マスタの拡張設定の[CoopIniConvUtil]はjson形式のデータではありません。施設コード:[%s] 管理番号:[%d] 内容:[%s]",
          facilityCd, mcl.getCtlNo(), ex.getMessage());
        throw new NtssException(message);
      }
    }

    // add 2021-12-28 院内コードから本システムコードへの変換の対応 孫 start
    // 院内コードから本システムコードへの変換項目を取得する
    Map<String, Object> coopMstConvItem = null;
    if (layoutExtSetting.containsKey("CoopMstConvUtil")) {
      try {
        coopMstConvItem = ObjectMapperUtil.castToStringObjectMap(layoutExtSetting.get("CoopMstConvUtil"));
      } catch (Exception ex) {
        String message = String.format("連携電文設定マスタの拡張設定の[CoopMstConvUtil]はjson形式のデータではありません。施設コード:[%s] 管理番号:[%d] 内容:[%s]",
          facilityCd, mcl.getCtlNo(), ex.getMessage());
        throw new NtssException(message);
      }
    }
    // add 2021-12-28 院内コードから本システムコードへの変換の対応 孫 end

    // ②KEYマッピングを取得する
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      Map<String, String> keyMappingData = CoopIniConvUtil.GetKeyMapping(facilityCd, "R");
      /* upd by chamaojia 2026-04-24 [10959] param facilityCd -> coopIni --start */
      Map<String, String> keyMappingData = CoopIniConvUtil.GetKeyMapping(coopIni, key0, "R");
      /* upd by chamaojia 2026-04-24 [10959] param facilityCd -> coopIni --end */
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // コード変換項目が有りか
    if (coopIniConvItem != null  && coopIniConvItem.size() > 0
      && keyMappingData!=null && keyMappingData.size() > 0){
      // ③変換項目とKEYマッピングをマッピングする
      for (String key : coopIniConvItem.keySet()) {
        String convKey = coopIniConvItem.get(key);
        if (StringUtils.isEmpty(convKey)) {
          convKey = key;
        }
        if (keyMappingData.containsKey(convKey)) {
          String mappingKey = keyMappingData.get(convKey);
          if (!StringUtils.isEmpty(mappingKey)) {
            coopIniConvItem.put(key, mappingKey);
          }
        }
      }
    }
    // ④連携設定情報を取得する
    /* upd by chamaojia 2026-04-24 [10959] param facilityCd -> coopIni --start */
    Map<String, String> convertData = CoopIniConvUtil.GetCoopIniInfo(coopIni);
    /* upd by chamaojia 2026-04-24 [10959] param facilityCd -> coopIni --end */
// add 2021-09-16 #5897:CSI連携ができないの対応 孫 end

    Set<String> keySet = rm.keySet();
    //List<Map<String,Object>> tableList = new ArrayList<Map<String,Object>>();
    Map<String,Object> tableMap = new HashMap<String,Object>();
    Map<String,Object> detailTableMap = new HashMap<String,Object>();
    for (String key : keySet) {
      if (key.startsWith("$journal.")) {
        Object value = rm.get(key);
// add 2021-09-16 #5897:CSI連携ができないの対応 孫 start
        // 外部連携のコード→本システムコードを変換します
        if (coopIniConvItem != null && coopIniConvItem.containsKey(key) && convertData != null  && convertData.size() > 0) {
          if (value instanceof List) {
            List<Object> valueList =  (List)value;
            for (int i=0; i<valueList.size(); i++) {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//              String convKey = coopIniConvItem.get(key) + CoopIniConvUtil.MARK + valueList.get(i).toString();
              String convKey = key0 + CoopIniConvUtil.MARK + coopIniConvItem.get(key) + CoopIniConvUtil.MARK + valueList.get(i).toString();
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              if (convertData != null && convertData.containsKey(convKey)) {
                valueList.set(i, convertData.get(convKey));
              }
            }
          } else {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//            String convKey = coopIniConvItem.get(key) + CoopIniConvUtil.MARK + value.toString();
            String convKey = key0 + CoopIniConvUtil.MARK + coopIniConvItem.get(key) + CoopIniConvUtil.MARK + value.toString();
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            if (convertData != null && convertData.containsKey(convKey)) {
              value = convertData.get(convKey);
            }
          }
        }
// add 2021-09-16 #5897:CSI連携ができないの対応 孫 end
// add 2021-12-28 院内コードから本システムコードへの変換の対応 孫 start
        // 院内コードから本システムコードへの変換項目を取得する
        if (coopMstConvItem != null && coopMstConvItem.containsKey(key) && coopMstConvItem.get(key) != null && !StringUtils.isEmpty(value)) {
          Map<String, Object> settingMap = null;
          try {
            settingMap = ObjectMapperUtil.castToStringObjectMap(coopMstConvItem.get(key));
          } catch (Exception ex) {
            String message = String.format("連携電文設定マスタの拡張設定の[CoopMstConvUtil]のKEYが[%s]の設定内容はjson形式のデータではありません。", key);
            throw new NtssException(message);
          }
          if (settingMap == null || settingMap.size() == 0) {
            String message = String.format("連携電文設定マスタの拡張設定の[CoopMstConvUtil]のKEYが[%s]の設定内容が無し。", key);
            throw new NtssException(message);
          }
          if (!settingMap.containsKey("conv_type") || !settingMap.containsKey("hospital_cd_names")) {
            String message = String.format("連携電文設定マスタの拡張設定の[CoopMstConvUtil]のKEYが[%s]の設定内容のKEY[conv_type,hospital_cd_names]が無し。", key);
            throw new NtssException(message);
          }
          Object convType = settingMap.get("conv_type");
          // add 7391 exam_rst連携で受信した検査項目コード  吉 start
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          if(convertData.containsKey("EXAMINRCV" + CoopIniConvUtil.MARK + "EXAMIN_CODE_TYPE") &&  "mst_exam_item".equals(convType)){
//            Object hospitalNum = "in_hospital_cd";
//            hospitalNum += convertData.get("EXAMINRCV" + CoopIniConvUtil.MARK + "EXAMIN_CODE_TYPE");
          if(convertData.containsKey(key0 + CoopIniConvUtil.MARK + KEY1_EXAMINRCV + CoopIniConvUtil.MARK + "EXAMIN_CODE_TYPE") &&  "mst_exam_item".equals(convType)){
            Object hospitalNum = "in_hospital_cd";
            hospitalNum += convertData.get(key0 + CoopIniConvUtil.MARK + KEY1_EXAMINRCV + CoopIniConvUtil.MARK + "EXAMIN_CODE_TYPE");
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            List list = new ArrayList();
            list.add(hospitalNum);
            settingMap.put("hospital_cd_names",list);
          }
          // add 7391 exam_rst連携で受信した検査項目コード  吉 end
          Object hospitalCdNames = settingMap.get("hospital_cd_names");
          if (StringUtils.isEmpty(convType) || StringUtils.isEmpty(hospitalCdNames)) {
            String message = String.format("連携電文設定マスタの拡張設定の[CoopMstConvUtil]のKEYが[%s]の設定内容のKEY[conv_type,hospital_cd_names]の内容が無し。", key);
            throw new NtssException(message);
          }
          List<String> hospitalCdNameList = new ArrayList<String>();
          try {
            List<String> tempList = ObjectMapperUtil.castToStringList(hospitalCdNames);
            if (tempList == null || tempList.size() == 0) {
              String message = String.format("連携電文設定マスタの拡張設定の[CoopMstConvUtil]のKEYが[%s]の設定内容のKEY[hospital_cd_names]の内容が無し。", key);
              throw new NtssException(message);
            }
            for (String valueTemp : tempList) {
              if (!StringUtils.isEmpty(valueTemp)) {
                hospitalCdNameList.add(valueTemp);
              }
            }
            if (hospitalCdNameList.size() == 0) {
              String message = String.format("連携電文設定マスタの拡張設定の[CoopMstConvUtil]のKEYが[%s]の設定内容のKEY[hospital_cd_names]の内容が無し。", key);
              throw new NtssException(message);
            }
          } catch (Exception ex) {
            String message = String.format("連携電文設定マスタの拡張設定の[CoopMstConvUtil]のKEYが[%s]の設定内容のKEY[hospital_cd_names]の内容はリストではない。", key);
            throw new NtssException(message);
          }
          // マスタチェック設定をチェックする
          List<Map<String, Object>> mstCheckSettingList = new ArrayList<Map<String, Object>>();
          if (settingMap.containsKey("mst_check_settings")) {
            Object mstCheckSettings = settingMap.get("mst_check_settings");
            if (!StringUtils.isEmpty(mstCheckSettings)) {
              try {
                mstCheckSettingList = ObjectMapperUtil.castToStringObjectMapList(mstCheckSettings);
                if (mstCheckSettingList != null && mstCheckSettingList.size() > 0) {
                  for (Map<String, Object> checkSetting : mstCheckSettingList) {
                    for (String keyCheck : checkSetting.keySet()) {
                      if (StringUtils.isEmpty(keyCheck) || StringUtils.isEmpty(checkSetting.get(keyCheck))) {
                        String message = String.format("[連携電文設定マスタ->拡張設定->CoopHospitalConvUtil]の変換種類[%s]の[mst_check_settings]の内容[key=%s,value=%s]が正しくありません。",
                          convType.toString(), keyCheck, checkSetting.get(keyCheck));
                        throw new NtssException(message);
                      }
                      // mst_check_settingsが「mst_medicine、mst_equipment、mst_dialyzer」以外の場合
                      if (!"mst_medicine".equals(keyCheck) && !"mst_equipment".equals(keyCheck) && !"mst_dialyzer".equals(keyCheck)) {
                        String message = String.format("[連携電文設定マスタ->拡張設定->CoopHospitalConvUtil]の変換種類[%s]の[mst_check_settings]のKEYは[mst_medicine、mst_equipment、mst_dialyzer]以外を設定しません。",
                          convType.toString());
                        throw new NtssException(message);
                      }
                      try {
                        List<String> tempList = ObjectMapperUtil.castToStringList(checkSetting.get(keyCheck));
                        if (tempList == null || tempList.size() == 0) {
                          String message = String.format("[連携電文設定マスタ->拡張設定->CoopHospitalConvUtil]の変換種類[%s]の[mst_check_settings]のKEY[%s]の内容が無し。",
                            convType.toString(), keyCheck);
                          throw new NtssException(message);
                        }
                        List<String> checkDateList = new ArrayList<>();
                        for (String valueTemp : tempList) {
                          if (!StringUtils.isEmpty(valueTemp)) {
                            checkDateList.add(valueTemp);
                          }
                        }
                        if (checkDateList.size() == 0) {
                          String message = String.format("[連携電文設定マスタ->拡張設定->CoopHospitalConvUtil]の変換種類[%s]の[mst_check_settings]のKEY[%s]の内容が無し。",
                            convType.toString(), keyCheck);
                          throw new NtssException(message);
                        }
                      } catch (Exception e1) {
                        String message = String.format("[連携電文設定マスタ->拡張設定->CoopHospitalConvUtil]の変換種類[%s]の[mst_check_settings]のKEY[%s]の内容[%s]はリストではない。",
                          convType.toString(), keyCheck, checkSetting.get(keyCheck));
                        throw new NtssException(message);
                      }
                    }
                  }
                }
              } catch (NtssException ex) {
                throw ex;
              } catch (Exception ex) {
                String message = String.format("[連携電文設定マスタ->拡張設定->CoopHospitalConvUtil]の変換種類[%s]の[mst_check_settings]の内容[%s]はjson形式のデータではありません。", convType.toString(), mstCheckSettings.toString());
                throw new NtssException(message);
              }
            }
          }
          // マスタデータ設定をチェックする
          Map<String, String> masterDataSettingMap = new HashMap<>();
          if (settingMap.containsKey("master_data_settings")) {
            Object masterDataSettings = settingMap.get("master_data_settings");
            if (!StringUtils.isEmpty(masterDataSettings)) {
              try {
                masterDataSettingMap = ObjectMapperUtil.castToStringStringMap(masterDataSettings);
              } catch (Exception ex) {
                String message = String.format("[連携電文設定マスタ->拡張設定->CoopHospitalConvUtil]の変換種類[%s]の[master_data_settings]の内容[%s]はjson形式のデータではありません。", convType.toString(), masterDataSettings.toString());
                throw new NtssException(message);
              }
            }
          }
          // 0件データの処理
          String data0Event = "";
          if (settingMap.containsKey("data_0_event")) {
            data0Event = settingMap.get("data_0_event").toString();
          }
          // フリー連携コード
          String freeHospitalCd = "";
          if (settingMap.containsKey("free_hospital_cd")) {
            freeHospitalCd = settingMap.get("free_hospital_cd").toString();
          }
          if (value instanceof List) {
            List<Object> valueList =  (List)value;
            for (int i=0; i<valueList.size(); i++) {
              if (StringUtils.isEmpty(valueList.get(i))) {
                valueList.set(i, valueList.get(i));
              } else {
                // マスタデータ設定のvalueを置換する
                Map<String, String> masterDataMap = new HashMap<>();
                for (String keyData : masterDataSettingMap.keySet()) {
                  String keyRm = masterDataSettingMap.get(keyData);
                  String valueRm = masterDataSettingMap.get(keyData);
                  if (keyRm.startsWith("$journal.")) {
                    if (rm.containsKey(keyRm)) {
                      List<Object> tmpData = (List)rm.get(keyRm);
                      valueRm = tmpData.get(i).toString();
                    } else {
                      String message = String.format("[連携電文設定マスタ->拡張設定->CoopHospitalConvUtil]の変換種類[%s]の[master_data_settings]のkey[%s]の内容[%s]に連携電文設定マスタが無し。", convType.toString(), keyRm, valueRm);
                      throw new NtssException(message);
                    }
                  }
                  masterDataMap.put(keyData, valueRm);
                }
                // mod 7391 exam_rst連携で受信した検査項目コード  吉 start
                // valueList.set(i, coopMstConvUtil.GetFnwCdByHospitalCd(facilityCd, convType.toString(), valueList.get(i).toString(), hospitalCdNameList, mstCheckSettingList, masterDataMap, data0Event, freeHospitalCd));
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//                String fnwCd = coopMstConvUtil.GetFnwCdByHospitalCd(facilityCd, convType.toString(), valueList.get(i).toString(), hospitalCdNameList, mstCheckSettingList, masterDataMap, data0Event, freeHospitalCd);
                String fnwCd = coopMstConvUtil.GetFnwCdByHospitalCd(facilityCd, convType.toString(), valueList.get(i).toString(), hospitalCdNameList, mstCheckSettingList, masterDataMap, data0Event, freeHospitalCd, key0);
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                if("".equals(fnwCd)){
                  examHospiteStr += valueList.get(i).toString()+",";
                }
                valueList.set(i, fnwCd);
                // mod 7391 exam_rst連携で受信した検査項目コード  吉 end
              }
           }
            // add 7391 exam_rst連携で受信した検査項目コード  吉 start
            if("mst_exam_item".equals(settingMap.get("conv_type"))){
              if(!"".equals(examHospiteStr)){
                // mod 7391 exam_rst連携で受信した検査項目コード  吉 start
                // examHospitalCd+= examHospiteStr.substring(0,examHospiteStr.lastIndexOf(","));
                examHospitalCd+= examHospiteStr;
                // mod 7391 exam_rst連携で受信した検査項目コード  吉 end
              }
            }
            // add 7391 exam_rst連携で受信した検査項目コード  吉 end

          } else {
            // マスタデータ設定のvalueを置換する
            Map<String, String> masterDataMap = new HashMap<>();
            for (String keyData : masterDataSettingMap.keySet()) {
              String keyRm = masterDataSettingMap.get(keyData);
              String valueRm = masterDataSettingMap.get(keyData);
              if (keyRm.startsWith("$journal.")) {
                if (rm.containsKey(keyRm)) {
                  Object tmpData = rm.get(keyRm);
                  valueRm = tmpData.toString();
                } else {
                  String message = String.format("[連携電文設定マスタ->拡張設定->CoopHospitalConvUtil]の変換種類[%s]の[master_data_settings]のkey[%s]の内容[%s]に連携電文設定マスタが無し。", convType.toString(), keyRm, valueRm);
                  throw new NtssException(message);
                }
              }
              masterDataMap.put(keyData, valueRm);
             }
            // mod 7391 exam_rst連携で受信した検査項目コード  吉 start
            // value = coopMstConvUtil.GetFnwCdByHospitalCd(facilityCd, convType.toString(), value.toString(), hospitalCdNameList, mstCheckSettingList, masterDataMap, data0Event, freeHospitalCd);
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//            String fnwCd = coopMstConvUtil.GetFnwCdByHospitalCd(facilityCd, convType.toString(), value.toString(), hospitalCdNameList, mstCheckSettingList, masterDataMap, data0Event, freeHospitalCd);
            String fnwCd = coopMstConvUtil.GetFnwCdByHospitalCd(facilityCd, convType.toString(), value.toString(), hospitalCdNameList, mstCheckSettingList, masterDataMap, data0Event, freeHospitalCd, key0);
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            if("mst_exam_item".equals(settingMap.get("conv_type")) && "".equals(fnwCd)){
              examHospitalCd += value.toString();
            }
            value = fnwCd;
            // mod 7391 exam_rst連携で受信した検査項目コード  吉 end
          }
        }
// add 2021-12-28 院内コードから本システムコードへの変換の対応 孫 end
        key = key.replace("$journal.","");
        boolean detailFlg = false;
        if (key.startsWith("detail.")) {
// mod 2021-12-03 #5888:NEC連携ができない(処方情報連携) 孫 start
//          key = key.replace("detail.","");
          // keyの頭部以外部分が「detail.」を含む場合、「detail.」を削除しません。
          key = key.substring("detail.".length());
// mod 2021-12-03 #5888:NEC連携ができない(処方情報連携) 孫 end
          detailFlg = true;
        }
// add 2022-01-05 [富士通連携ができない]再対応→浄化申し込み・初回指示 孫 start
        else {
          // 浄化申し込み・初回指示の場合、曜日データが複数データです。
          // detail以外の場合、valueがListの場合、List->Stringを変更すする
          if (value instanceof List) {
            List<Object> valueList =  (List)value;
            String newValue = "";
            for (int i=0; i<valueList.size(); i++) {
              if (valueList.get(i) == null || StringUtils.isEmpty(valueList.get(i))) {
                continue;
              }
              if (StringUtils.isEmpty(newValue)) {
                newValue = valueList.get(i).toString();
              } else {
                newValue = newValue + "," + valueList.get(i).toString();
              }
            }
            value = newValue;
          }
        }
// add 2022-01-05 [富士通連携ができない]再対応→浄化申し込み・初回指示 孫 end
        // add FNSI7519-profile連携（XML）で受信した詳細情報（患者フリーコメント） 周 start
        // change for json
        if(value instanceof List) {
          List<Object> tempVal = new ArrayList<>();
          for(Object e : (List<Object>)value) {
            //Object tempE = e.toString().replaceAll("\\\"", "\\\\\"").replace("\\\\", "\\\\\\\\").replace("\\\\/", "\\\\\\\\/");
            if(!StringUtils.isEmpty(e.toString())
              && (e.toString().contains("\"") || e.toString().contains("\\") || e.toString().contains("\\/"))) {
              String tempColVal = "";
              for(int idx = 0; idx < e.toString().length(); idx++) {
                if('"' == e.toString().charAt(idx) || '\\' == e.toString().charAt(idx) || '/' == e.toString().charAt(idx)) {
                  tempColVal = tempColVal + "\\" + e.toString().charAt(idx);
                } else {
                  tempColVal = tempColVal + e.toString().charAt(idx);
                }
              }
              tempVal.add(tempColVal);
            } else {
              tempVal.add(e);
            }
          }
          value = tempVal;
        }
        // add FNSI7519-profile連携（XML）で受信した詳細情報（患者フリーコメント） 周 end
        String[] keys = key.split("\\.");
        switch (keys.length) {
          case 1:
            // shori_kbn等の特殊値はここでは処理対象外とし、無視する。
            break;

          case 2:
            if (detailFlg == false) {
              // key[0]=テーブル名、key[1]=カラム名
              addMap(tableMap,keys[0],keys[1],value);
              break;
            } else {
              addMap(detailTableMap,keys[0],keys[1],value);
              break;
            }

          case 3:
            // key[0]=テーブル名、key[1].key[2]=カラム名
            String colKey12 = String.join(".", keys[1], keys[2]);
            if (detailFlg == false) {
              addMap(tableMap,keys[0],colKey12,value);
              break;
            } else {
              addMap(detailTableMap,keys[0],colKey12,value);
              break;
            }

          case 4:
            // key[0]=テーブル名、key[1].key[2].key[3]=カラム名
            String colKey123 = String.join(".", keys[1], keys[2], keys[3]);
            if (detailFlg == false) {
              addMap(tableMap,keys[0],colKey123,value);
              break;
            } else {
              addMap(detailTableMap,keys[0],colKey123,value);
              break;
            }

          default:
            // ここには到達しないはず。
            String errMsg2 = String.format("ジャーナルから取得したテーブル名とカラム名が不正です。 [%s]", key);
            throw new NtssException(errMsg2);
        }
      }
    }
    // add  #8292 exam_rst連携で受信した検査データの登録ができない 20230203 孟堅　start
    if(CoopCdConstant.EXAM_RST.equals(rm.getSpecial(JournalConvertConstants.COOP_CD))){
      rm.put(JournalConvertConstants.EXAMHOSPITALCD,examHospitalCd);
    }
    // add  #8292 exam_rst連携で受信した検査データの登録ができない 20230203 孟堅　end
    StringBuilder sb = new StringBuilder();
    // main json
    StringBuilder mainSB = new StringBuilder();
    // detail json
    StringBuilder detailSB = new StringBuilder();
    sb.append("{");
    if (tableMap.size() > 0) {
      for (String key : tableMap.keySet()) {
        mainSB.append("\"").append(key).append("\":").append("{").append(getColumnValue(tableMap.get(key))).append("}")
          .append(",");
      }
    }
    if (detailTableMap.size() > 0) {
      detailSB.append("\"").append("detail").append("\":").append("{");
      for (String key : detailTableMap.keySet()) {
        detailSB.append("\"").append(key).append("\":").append("[");
        int count = getDetailCount(detailTableMap.get(key));
        StringBuilder detailValSB = new StringBuilder();
        for (int i = 0; i < count; i++) {
          // mod 7391 exam_rst連携で受信した検査項目コード  吉 start
          // detailValSB.append(getDetailValue(detailTableMap.get(key),i));
          if(key.equals("pat_exam_main")){
            /* upd by chamaojia 2026-04-30 [10959] add param examItemMap --start */
            // detailValSB.append(getDetailValue(detailTableMap.get(key),i,true));
            detailValSB.append(getDetailValue(detailTableMap.get(key),i,true, examItemMap));
            /* upd by chamaojia 2026-04-30 [10959] add param examItemMap --end */
          }else{
            /* upd by chamaojia 2026-04-30 [10959] add param examItemMap --start */
            // detailValSB.append(getDetailValue(detailTableMap.get(key),i,false));
            detailValSB.append(getDetailValue(detailTableMap.get(key),i,false, examItemMap));
            /* upd by chamaojia 2026-04-30 [10959] add param examItemMap --end */
          }
          // mod 7391 exam_rst連携で受信した検査項目コード  吉 start
          detailValSB.append(",");
        }
        if (detailValSB.length() > 0) {
          detailValSB.deleteCharAt(detailValSB.lastIndexOf(","));
        }
        detailSB.append(detailValSB).append("]").append(",");
      }
      detailSB.append("}");
    }
    sb.append(mainSB).append(detailSB);
// mod 2021-12-02 #5888:NEC連携ができない(処方情報連携) 孫 start
//    sb.deleteCharAt(sb.lastIndexOf(","));
    if (sb.lastIndexOf(",") > 0) {
      sb.deleteCharAt(sb.lastIndexOf(","));
    }
// mod 2021-12-02 #5888:NEC連携ができない(処方情報連携) 孫 end
    sb.append("}");
    return sb.toString();
  }

  /**
   * 明細値を取得する。
   *
   * @param obj
   * @param index
   * @return 明細値
   */
  // mod 7391 exam_rst連携で受信した検査項目コード  吉 start
  // private StringBuilder getDetailValue(Object obj, int index) {
  /* upd by chamaojia 2026-04-30 [10959] add param examItemMap --start */
  // private StringBuilder getDetailValue(Object obj, int index,boolean flag) {
  private StringBuilder getDetailValue(Object obj, int index,boolean flag, Map<String,String> examItemMap) {
  /* upd by chamaojia 2026-04-30 [10959] add param examItemMap --end */
    // mod 7391 exam_rst連携で受信した検査項目コード  吉 end
    StringBuilder sb = new StringBuilder();
    // add 7391 exam_rst連携で受信した検査項目コード  吉 start
    String itemCd ="";
    // add 7391 exam_rst連携で受信した検査項目コード  吉 end
    if (obj instanceof Map) {
      Map<String, Object> map = ObjectMapperUtil.castToStringObjectMap(obj);
      Set<String> keySet = map.keySet();
      sb.append("{");
      for (String key : keySet) {
        if (map.get(key) instanceof List) {
          List<Object> list = ObjectMapperUtil.castToObjectList(map.get(key));
          // mod 2021-11-30 #5888:NEC連携ができない(検査結果) 孫 start
//          sb.append("\"").append(key).append("\":\"").append(list.get(index)).append("\"").append(",");
          if (list.size() <= index) {
            // データが無しの場合、空の文字列を設定する。
            sb.append("\"").append(key).append("\":\"").append("").append("\"").append(",");
          } else {
            sb.append("\"").append(key).append("\":\"").append(list.get(index)).append("\"").append(",");
          }
          // add 7391 exam_rst連携で受信した検査項目コード  吉 start
          if("exam_result_info.item_cd".equals(key)){
            itemCd= list.get(index).toString();
          }
          // add 7391 exam_rst連携で受信した検査項目コード  吉 end
          // mod 2021-11-30 #5888:NEC連携ができない(検査結果) 孫 end
        }
        if (map.get(key) instanceof String) {
          sb.append("\"").append(key).append("\":\"").append(map.get(key)).append("\"").append(",");
        }
      }
      // add 7391 exam_rst連携で受信した検査項目コード  吉 start
      if(flag){
        sb.append("\"").append("exam_result_info.item_name").append("\":\"").append(examItemMap.get(itemCd)).append("\"").append(",");
      }
      // add 7391 exam_rst連携で受信した検査項目コード  吉 end
      sb.deleteCharAt(sb.lastIndexOf(","));
      sb.append("}");
    }
    return sb;
  }

  /**
   * 明細数を取得する。
   *
   * @param obj
   * @return 明細数
   */
  private int getDetailCount(Object obj) {
    int count = 0;
    int totalCount = 0;
    int tempCount = 0;
    if (obj instanceof Map) {
      Map<String, Object> map = ObjectMapperUtil.castToStringObjectMap(obj);
      Set<String> keySet = map.keySet();
      for (String key : keySet) {
        if (map.get(key) instanceof List) {
          List<Object> list = ObjectMapperUtil.castToObjectList(map.get(key));
          tempCount = list.size();
          if (tempCount > totalCount) {
            totalCount = tempCount;
          }
        }
        if (map.get(key) instanceof String) {
          tempCount = 1;
          if (tempCount > totalCount) {
            totalCount = tempCount;
          }
        }
      }
      for (int i = 0; i < totalCount; i++) {
        boolean flg = false;
        for (String key : keySet) {
          if (map.get(key) instanceof List) {
            List<Object> list = ObjectMapperUtil.castToObjectList(map.get(key));
            if (!StringUtils.isEmpty(String.valueOf(list.get(i)))) {
              flg = true;
              count = count + 1;
              break;
            }
          }
        }
        if (flg == false) {
          break;
        }
      }
    }
    return count;
  }

  /**
   * 更新用のJson値を取得する。
   *
   * @param preStr
   * @param obj
   * @return Json値
   */
  private StringBuilder getJsonValue(String preStr, Object obj) {
    StringBuilder sb = new StringBuilder();

    if (obj instanceof Map) {
      Map<String, Object> map = ObjectMapperUtil.castToStringObjectMap(obj);
      Set<String> keySet = map.keySet();
      for (String key : keySet) {
        sb.append("\"");
        Object jsonObj = map.get(key);
        if (jsonObj instanceof List) {
          List<Object> list = ObjectMapperUtil.castToObjectList(jsonObj);
          for (Object o : list) {
            String str = preStr + "." + key;
            sb.append(getJsonValue(str,o));
          }
        } else if (jsonObj instanceof String) {
          sb.append(preStr).append(".").append(key).append("\":\"").append(String.valueOf(map.get(key)).trim()).append("\"").append(",");
        }
      }
    }
    return sb;
  }

  /**
   * 更新用のColumn値を取得する。
   *
   * @param obj JSON形式データ
   * @return Column値
   */
  private StringBuilder getColumnValue(Object obj) {
    StringBuilder sb = new StringBuilder();
    if (obj instanceof Map) {
      Map<String, Object> map = ObjectMapperUtil.castToStringObjectMap(obj);
      for (String key : map.keySet()) {
        Object colObj = map.get(key);
        if (colObj instanceof List) {
          List<Object> list = ObjectMapperUtil.castToObjectList(colObj);
          for (Object o : list) {
            sb.append(getJsonValue(key,o));
          }
        } else if (colObj instanceof String) {
          sb.append("\"");
          sb.append(key).append("\":\"").append(String.valueOf(map.get(key)).trim()).append("\"").append(",");
        }
      }
    }
    sb.deleteCharAt(sb.lastIndexOf(","));
    return sb;
  }

  /**
   * addMap
   *
   * @param tableMap
   * @param tableKey
   * @param columnKey
   * @param value
   */
  private void addMap(Map<String,Object> tableMap, String tableKey, String columnKey, Object value) {
    if (tableMap.containsKey(tableKey)) {
      Object obj = tableMap.get(tableKey);
      if (obj instanceof Map) {
        Map<String, Object> columnMap = ObjectMapperUtil.castToStringObjectMap(obj);
        // ObjectMapper#convertValue()は引数の型を変換する前にディープコピーを作る。
        // そのため、同一キーで再登録しないと、返値にputされても元の構造に反映されない。
        columnMap.put(columnKey, value);
        tableMap.put(tableKey,columnMap);
      }
    } else {
      Map<String,Object> columnMap = new HashMap<String,Object>();
      columnMap.put(columnKey,value);
      tableMap.put(tableKey,columnMap);
    }
  }
  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
//  del #5607 連動機能の実装確認 20230411 孟堅　start
//  //連携が成功したらお知らせします
//  private void sendInfectionNotification(ResultMap resultMap,String facilityCd){
//// add 2021-11-11 #5896:SSI連携ができない(患者プロファイル) 孫 start
//    try {
//// add 2021-11-11 #5896:SSI連携ができない(患者プロファイル) 孫 end
//      Object hospPatId = resultMap.get("$journal.pat_personal_main.hosp_pat_id");
//      Long patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, (String) hospPatId);
//      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
//      String lastName = Objects.isNull(patPersonalMain) ? (String) resultMap.get("$journal.pat_personal_main.pat_last_name") : patPersonalMain.getPat_last_name();
//      String firstName = Objects.isNull(patPersonalMain) ? (String) resultMap.get("$journal.pat_personal_main.pat_first_name") : patPersonalMain.getPat_first_name();
//      JSONObject baseReplaceData = new JSONObject();
//      baseReplaceData.put("LASTNAME", lastName);
//      baseReplaceData.put("FIRSTNAME", firstName);
//
//      // No.1 新規患者登録通知
//      // mod 2022-06-14 5607連動機能の実装確認 修正 李 start
//      //if (Objects.isNull(patId)) {
//      if (patPersonalMain.getReg_date().substring(0, 19).equals(patPersonalMain.getUp_date().substring(0, 19))) {
//      // mod 2022-06-14 5607連動機能の実装確認 修正 李 end
//        // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
//        JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
//        // mod 2022-11-16 5607連動機能の実装確認  孟堅 start
//        //　replaceData.put("PATID", "");
//        replaceData.put("PATID", patId.toString());
//        // mod 2022-11-16 5607連動機能の実装確認  孟堅 end
//        replaceData.put("HOSPPATID", hospPatId);
//        replaceData.put("FACILITYCD", facilityCd);
//        notificationApiCallUtil.registerNotification(NotificationDefinition.CREATE_PAT, facilityCd, replaceData);
//      }
//      // No.2 感染症患者ON通知
//      if ("1".equals(resultMap.get("$journal.pat_main.is_infect"))) {
//        // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
//        JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
//        replaceData.put("PATID", patId.toString());
//        replaceData.put("FACILITYCD", facilityCd);
//        notificationApiCallUtil.registerNotification(NotificationDefinition.REGISTER_INFECT_PAT, facilityCd, replaceData);
//      }
//
//      // add 5607検査結果ファイル取込処理結果通知 gaoey start
//      if(resultMap.containsKey("$journal.detail.pat_exam_main.exam_result_info.result")){
//        JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
//        replaceData.put("PATID", patId.toString());
//        replaceData.put("FACILITYCD", facilityCd);
//        notificationApiCallUtil.registerNotification(NotificationDefinition.EXAM_RECORD_ReadFile, facilityCd, replaceData);
//      }
//      // add 5607検査結果ファイル取込処理結果通知 gaoey end
//
//      // No.3 感染症(＋)に変更通知
//      // mod 5607連動機能の実装確認 修正 ljx
//      if (resultMap.containsKey("$journal.detail.pat_main_2.infect_info.infect")) {
//        //mod 5607 感染症更新通知 gaoey start
//        Boolean infectInfoFlag = (Boolean) resultMap.get("$journal.detail.pat_main_2.infect_info.infectInfoFlag");
//        if(infectInfoFlag){
//          //mod 5607 感染症更新通知 gaoey end
//          JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
//          replaceData.put("PATID", patId.toString());
//          replaceData.put("FACILITYCD", facilityCd);
//          notificationApiCallUtil.registerNotification(NotificationDefinition.CHANGE_INFECT_POSITIVE, facilityCd, replaceData);
//        }
//      }
//
//      // No.4 禁忌・ｱﾚﾙｷﾞｰ追加・更新・削除通知
//      // mod 5607連動機能の実装確認 修正 ljx
//      if (resultMap.containsKey("$journal.detail.pat_main_4.taboo_allergy_info.taboo_allergy_cd")) {
//        // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
//        JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
//        replaceData.put("PATID", patId.toString());
//        replaceData.put("FACILITYCD", facilityCd);
//        notificationApiCallUtil.registerNotification(NotificationDefinition.UPDATE_TABOO_ALLERGY, facilityCd, replaceData);
//      }
//
//      // No.5～10 入外・転入出
//      if (resultMap.containsKey("$journal.detail.pat_unique.in_out_visit_history_info.move_in_out")) {
//
//        // 入外・転入出レコードをそれぞれ検索
//        for (int idx = 0; idx < ((List) resultMap.get("$journal.detail.pat_unique.in_out_visit_history_info.move_in_out")).size(); idx++) {
//          // 入外区分
//          String moveInOut = (String) ((List) resultMap.get("$journal.detail.pat_unique.in_out_visit_history_info.move_in_out")).get(idx);
//
//          // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
//          JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
//          replaceData.put("STARTDATE", "");
//          replaceData.put("PATID", patId.toString());
//          replaceData.put("FACILITYCD", facilityCd);
//
//          switch (moveInOut) {
//            case "2":
//              // No.5 転入通知
//              notificationApiCallUtil.registerNotification(NotificationDefinition.MOVE_IN, facilityCd, replaceData);
//              break;
//            case "3":
//              // No.6 転出通知
//              notificationApiCallUtil.registerNotification(NotificationDefinition.MOVING_OUT, facilityCd, replaceData);
//              break;
//            case "7":
//              // No.8 離脱通知
//              notificationApiCallUtil.registerNotification(NotificationDefinition.WITHDRAWAL, facilityCd, replaceData);
//              break;
//            case "8":
//              // No.9 移植通知
//              notificationApiCallUtil.registerNotification(NotificationDefinition.IMPLANTATION, facilityCd, replaceData);
//              break;
//            case "9":
//              // No.7 一時転出通知
//              // 日付データ（終了日）
//              replaceData.put("ENDDATE", "");
//              notificationApiCallUtil.registerNotification(NotificationDefinition.TEMPORARILY_MOVING_OUT, facilityCd, replaceData);
//              break;
//            default:
//              break;
//          }
//        }
//      }
//
//      // No.10 死亡通知
//      if ("1".equals(resultMap.get("$journal.pat_personal_main.is_die"))) {
//        //del 6993 【デグレ】profile連携で受信した生存の有無登録 20221123 zhaoqi start
//        //String dieDate = "未指定";
//        //del 6993 【デグレ】profile連携で受信した生存の有無登録 20221123 zhaoqi end
//        //add 6993 【デグレ】profile連携で受信した生存の有無登録 20221123 zhaoqi start
//        String dieDate = resultMap.get("$journal.pat_personal_main.die_date").toString();
//        //add 6993 【デグレ】profile連携で受信した生存の有無登録 20221123 zhaoqi end
//        // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
//        JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
//        replaceData.put("DIEDATE", dieDate);
//        replaceData.put("PATID", patId.toString());
//        replaceData.put("FACILITYCD", facilityCd);
//        notificationApiCallUtil.registerNotification(NotificationDefinition.DEATH, facilityCd, replaceData);
//      }
//
//      // No.13 患者グループ通知
//      if (resultMap.containsKey("$journal.detail.pat_main.pat_group_info.pat_group_name")) {
//        for (int idx = 0; idx < ((List) resultMap.get("$journal.detail.pat_main.pat_group_info.pat_group_name")).size(); idx++) {
//          // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
//          JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
//          replaceData.put("PATGROUP", ((List) resultMap.get("$journal.detail.pat_main.pat_group_info.pat_group_name")).get(idx));
//          replaceData.put("OPERATION", "に追加");
//          replaceData.put("PATID", patId.toString());
//          replaceData.put("FACILITYCD", facilityCd);
//          notificationApiCallUtil.registerNotification(NotificationDefinition.ADD_PAT_GROUP, facilityCd, replaceData);
//        }
//      }
//      // No.15 担当者に設定通知
//      // mod 5607連動機能の実装確認 修正 ljx
///*      if (resultMap.containsKey("$journal.detail.pat_main.charge_staff_info.staff_cd") &&
//        resultMap.containsKey("$journal.detail.pat_main.charge_staff_info.is_main") &&
//        resultMap.containsKey("$journal.detail.pat_main.charge_staff_info.is_charge") &&
//        resultMap.containsKey("$journal.detail.pat_main.charge_staff_info.is_puncture")
//      ) {*/
//        if (resultMap.containsKey("$journal.detail.pat_main.charge_staff_info.staff_cd")
//        ) {
//
//          //mod 5607 担当スタッフ情報更新通知 gaoey start
//          Boolean infectInfoFlag = (Boolean) resultMap.get("$journal.detail.detail.pat_main.charge_staff_info.chargeStaffInfoFlag");
//          if(infectInfoFlag) {
//            // 何かしら値の入っている場合個別に通知
//            for (int idx = 0; idx < ((List) resultMap.get("$journal.detail.pat_main.charge_staff_info.staff_cd")).size(); idx++) {
//// mod 2021-11-11 #5896:SSI連携ができない(患者プロファイル) 孫 start
////        Long userId = (Long)((List)resultMap.get("$journal.detail.pat_main.charge_staff_info.staff_cd")).get(idx);
//              Long userId = Long.valueOf((String) ((List) resultMap.get("$journal.detail.pat_main.charge_staff_info.staff_cd")).get(idx));
//// mod 2021-11-11 #5896:SSI連携ができない(患者プロファイル) 孫 end
//              // 利用者名の取得
//              MstPersonalUser staffUser = mstPersonalUserDao.selectById(userId);
//// add 2021-11-11 #5896:SSI連携ができない(患者プロファイル) 孫 start
//              if (staffUser == null) {
//                continue;
//              }
//// add 2021-11-11 #5896:SSI連携ができない(患者プロファイル) 孫 end
//              String staffLastName = staffUser.getUserLastName();
//              String staffFirstName = staffUser.getUserFirstName();
//              // 担当者種別の取得
//              // mod 5607連動機能の実装確認 修正 ljx
//              String mainStaff = "", chargeStaff = "", punctureStaff = "";
//              // mod 5607連動機能の実装確認 修正 ljx
//              if (resultMap.containsKey("$journal.detail.pat_main.charge_staff_info.is_main")) {
//                mainStaff = "1".equals((String) ((List) resultMap.get("$journal.detail.pat_main.charge_staff_info.is_main")).get(idx))
//                  ? "主治医"
//                  : "";
//              }
//              // mod 5607連動機能の実装確認 修正 ljx
//              if (resultMap.containsKey("$journal.detail.pat_main.charge_staff_info.is_charge")) {
//                chargeStaff = "1".equals((String) ((List) resultMap.get("$journal.detail.pat_main.charge_staff_info.is_charge")).get(idx))
//                  ? "担当"
//                  : "";
//              }
//              // mod 5607連動機能の実装確認 修正 ljx
//              if (resultMap.containsKey("$journal.detail.pat_main.charge_staff_info.is_puncture")) {
//                punctureStaff = "1".equals((String) ((List) resultMap.get("$journal.detail.pat_main.charge_staff_info.is_puncture")).get(idx))
//                  ? "穿刺"
//                  : "";
//              }
//              String comma1 = !mainStaff.equals("") && !chargeStaff.equals("") ? "、" : "";
//              String comma2 = !chargeStaff.equals("") && !punctureStaff.equals("") ? "、" : "";
//              String StaffType = mainStaff + comma1 + chargeStaff + comma2 + punctureStaff;
//              // チェックONにしたときのみ通知する
//              if (!StaffType.equals("")) {
//                // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
//                JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
//                replaceData.put("STAFFLASTNAME", staffLastName);
//                replaceData.put("STAFFFIRSTNAME", staffFirstName);
//                replaceData.put("STAFFTYPE", StaffType);
//                replaceData.put("PATID", patId.toString());
//                replaceData.put("FACILITYCD", facilityCd);
//                notificationApiCallUtil.registerNotification(NotificationDefinition.SET_CHARGE_STAFF, facilityCd, replaceData);
//              }
//            }
//          }
//      }
//        // add #5607 連動機能の実装確認 20221114 孟堅　start
//        // 検査結果(rst_exam)受信時  患者情報への感染症情報連携および通知連動
//        if (resultMap.containsKey("$journal.detail.pat_exam_main.exam_result_info.result")) {
//          //mod 5607 感染症更新通知 gaoey start
//          Boolean infectInfoFlag = (Boolean) resultMap.get("$journal.detail.pat_main_2.infect_info.infectInfoFlag");
//          if(infectInfoFlag){
//            //mod 5607 感染症更新通知 gaoey end
//            JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
//            replaceData.put("PATID", patId.toString());
//            replaceData.put("FACILITYCD", facilityCd);
//            notificationApiCallUtil.registerNotification(NotificationDefinition.CHANGE_INFECT_POSITIVE, facilityCd, replaceData);
//          }
//        }
//      // add #5607 連動機能の実装確認 20221114 孟堅　end
//// add 2021-11-11 #5896:SSI連携ができない(患者プロファイル) 孫 start
//    } catch (Exception e) {
//      StackTraceElement[]  list = null;
//      String errAdd = "";
//      if (e.getCause() != null && e.getCause().getStackTrace() != null
//        && e.getCause().getStackTrace().length > 0) {
//        list = e.getCause().getStackTrace();
//        for (StackTraceElement err : list) {
//          if (err != null && err.toString().startsWith("jp.co.")) {
//            errAdd = errAdd + "\r\n" + err.toString();
//          }
//        }
//      }
//      if (StringUtils.isEmpty(errAdd)) {
//        list = e.getStackTrace();
//        for (StackTraceElement err : list) {
//          if (err != null && err.toString().startsWith("jp.co.")) {
//            errAdd = errAdd + "\r\n" + err.toString();
//          }
//        }
//      }
//      String error = String.format("[連携が成功したらお知らせします]処理で予期せぬエラーが発生しました。[%s][%s]", e, errAdd);
//
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(error);
//      eventLogMessage.setFacilityCd(facilityCd);
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//    }
//// add 2021-11-11 #5896:SSI連携ができない(患者プロファイル) 孫 end
//  }
//  del #5607 連動機能の実装確認 20230411 孟堅　end
  // mod 7391 exam_rst連携で受信した検査項目コード  吉 start
  private static void convertJsonToMap(Object json, Map<String, Object> resultMap) {
    if (json instanceof JSONObject) {
      JSONObject jsonObject = ((JSONObject) json);
      Iterator iterator = jsonObject.keySet().iterator();
      while (iterator.hasNext()) {
        String key = convertString(iterator.next());
        Object value = jsonObject.get(key);
        resultMap.put(key, value);
      }
    }
  }

  /**
   * String変換
   * @param obj 変換用オブジェクト
   * @return 変換したデータ
   */
  public static String convertString(Object obj) {
    if (obj == null) {
      return "";
    }

    try {
      if (obj instanceof Timestamp) {
        DateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS");
        return sdf.format(obj);
      }
    } catch (Exception e) {}

    if ("null".equals(obj.toString())) {
      return "";
    }

    return obj.toString();
  }
  // mod 7391 exam_rst連携で受信した検査項目コード  吉 start

  // add FNSI7302-ini_dial連携で異常な電文を受信しても正常応答（OK）する 周 start
  /**
   * 取得処理(/getDataInfo)
   *
   * @param request {@link MstCoopLayout}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/getDataInfo")
  public ResponseEntity<?> getDataInfo(@RequestBody MstCoopLayout request) {
    try {
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////      MstCoopLayout mcl = mstCoopLayoutDao.select(request.getFacilityCd(), request.getCoopCd(),
////        request.getCoopCdIndex(), request.getDirection(), request.getCoopCdSub());
//      // 連携版番号
//      String coopVersion = StringUtils.isEmpty(request.getCoopVersion())?"":request.getCoopVersion();
//
//      MstCoopLayout mcl = mstCoopLayoutDao.select(request.getFacilityCd(), request.getCoopCd(), request.getCoopCdIndex(),
//        coopVersion, request.getDirection(), request.getCoopCdSub());
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//      if(null == mcl) {
//        return new ResponseEntity<>("連携設定マスタ(mst_coop_layout)にデータがありません。", HttpStatus.BAD_REQUEST);
//      }
      // 連携版番号
      String coopVersion = StringUtils.isEmpty(request.getCoopVersion())?"":request.getCoopVersion();
      MstCoopLayout mcl = convertCommonService.getMstCoopLayoutBySub(request.getFacilityCd(), request.getDirection(),
        request.getCoopCd(), request.getCoopCdIndex(), coopVersion, request.getCoopCdSub());
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
      List<Item> itemList = mcl.getCoopSettingRoot().getItemList();
      List<CheckItem> result = getCheckDataList(request.getCoopCd(), coopVersion, itemList);
      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * チェック項目の取得処理
   *
   * @param coopCd
   * @param itemList
   * @return {@link List<CheckItem>}
   */
  private List<CheckItem> getCheckDataList(String coopCd, String coopVersion, List<Item> itemList) {
    List<CheckItem> result = new ArrayList<>();

    if ("GX".equals(coopVersion)){
    switch (coopCd) {
      case "ini_dial":
        for (Item item : itemList) {
          if("電文種別".equals(item.getName())) {
            List<String> validVal = new ArrayList<>();
            validVal.add("VI");
            CheckItem chkItem = new CheckItem();
            chkItem.setName(item.getName());
            chkItem.setLen(item.getLen());
            chkItem.setChkTarget(true);
            chkItem.setValidVal(validVal);
            chkItem.setErrorFlg("N2");
            result.add(chkItem);
            continue;
          }
          if("発信元システムコード".equals(item.getName())) {
            List<String> validVal = new ArrayList<>();
            validVal.add("XX");
            CheckItem chkItem = new CheckItem();
            chkItem.setName(item.getName());
            chkItem.setLen(item.getLen());
            chkItem.setChkTarget(true);
            chkItem.setValidVal(validVal);
            chkItem.setErrorFlg("N2");
            result.add(chkItem);
            continue;
          }
          if("処理区分".equals(item.getName())) {
            List<String> validVal = new ArrayList<>();
            validVal.add("01");
            validVal.add("02");
            validVal.add("03");
            CheckItem chkItem = new CheckItem();
            chkItem.setName(item.getName());
            chkItem.setLen(item.getLen());
            chkItem.setChkTarget(true);
            chkItem.setValidVal(validVal);
            chkItem.setErrorFlg("N2");
            result.add(chkItem);
            continue;
          }
          if("伝票情報.入外区分".equals(item.getName())) {
            List<String> validVal = new ArrayList<>();
            validVal.add("1");
            validVal.add("2");
            CheckItem chkItem = new CheckItem();
            chkItem.setName(item.getName());
            chkItem.setLen(item.getLen());
            chkItem.setChkTarget(true);
            chkItem.setValidVal(validVal);
            chkItem.setErrorFlg("N2");
            result.add(chkItem);
            continue;
          }
          if("患者情報.患者番号".equals(item.getName()) || "伝票情報.オーダ番号".equals(item.getName())
            || "伝票情報.親文書番号".equals(item.getName()) || "伝票情報.文書番号".equals(item.getName())
            || "伝票情報.文書版数".equals(item.getName()) || "伝票情報.更新後実施日時.実施日".equals(item.getName())
            || "伝票情報.更新後実施日時.実施時間".equals(item.getName())
            || "伝票情報.オーダ作成日.オーダ日付_オーダ時間".equals(item.getName())
            || "伝票情報.保険パターン番号".equals(item.getName())
            || "伝票情報.診療科コード".equals(item.getName()) || "伝票情報.診療科名称".equals(item.getName())
            || "伝票情報.オーダ発行利用者番号".equals(item.getName())
            || "伝票情報.オーダ発行利用者名".equals(item.getName())
            || "伝票情報.依頼医利用者番号".equals(item.getName())
            || "伝票情報.依頼医名".equals(item.getName())
            || "伝票情報.伝票種別".equals(item.getName())
            || "伝票情報.伝票コード".equals(item.getName())
            || "明細行数".equals(item.getName())) {
            CheckItem chkItem = new CheckItem();
            chkItem.setName(item.getName());
            chkItem.setLen(item.getLen());
            chkItem.setChkTarget(true);
            chkItem.setErrorFlg("N2");
            result.add(chkItem);
            continue;
          }

          CheckItem chkItem = new CheckItem();
          chkItem.setName(item.getName());
          chkItem.setLen(item.getLen());
          chkItem.setChkTarget(false);
          result.add(chkItem);
        }

        break;
      default:
        break;
    }
    }
    return result;
  }

  @Data
  private class CheckItem {
    String name;

    int len;

    boolean isChkTarget;

    List<String> validVal;

    String errorFlg;
  }
  // add FNSI7302-ini_dial連携で異常な電文を受信しても正常応答（OK）する 周 end
  //　add #5607 連動機能の実装確認 20221114 孟堅　start

  /**
   * 患者プロファイル(profile)受信時の
   * 患者情報の感染症情報更新時の通知連動
   *
   * @param patMain 患者情報
   * @param result  処理結果
   */
  private  void infectUpdate(PatMain patMain,ResultMap result){
      //add 5607 感染症更新通知 gaoey start
      Boolean infectInfoFlag = false;
      if(patMain != null){
        String infectInfo = patMain.getInfect_info();
        if(!"[]".equals(infectInfo)){
          JSONArray infectInfoJsonList = new JSONArray(infectInfo);
          List<String> infectionCdList = new ArrayList<>();
          for(int i=0;i<infectInfoJsonList.length();i++){
            JSONObject jsonObj = infectInfoJsonList.getJSONObject(i);
            if(!jsonObj.get("infect").equals("2")){
              String code =jsonObj.get("infection_cd").toString();
              infectionCdList.add(code);
            }

          }
          List<String> infectcdStrList = new ArrayList<>();
          List<String> infectCdCoopList = (List<String>)result.get("$journal.detail.pat_main_2.infect_info.infection_cd");
          List<String> infectList = (List<String>) result.get("$journal.detail.pat_main_2.infect_info.infect");
          // mod 7435 未処理だったレコードの処理が正常に行われない 修正 chen start
          if (infectList != null) {
            for (int i = 0; i < infectList.size(); i++) {
              if(infectList.get(i).equals("2")){
                infectcdStrList.add(infectCdCoopList.get(i));
              }
            }
            if(infectcdStrList.size() > 0){
              for (int i = 0; i < infectcdStrList.size(); i++) {
                if(infectionCdList.contains(infectcdStrList.get(i))){
                  infectInfoFlag = true;
                  break;
                }
              }
            }
          }
          // mod 7435 未処理だったレコードの処理が正常に行われない 修正 chen end
        }else{
          infectInfoFlag = true;
        }
      }else{
        infectInfoFlag = true;
      }
      result.put("$journal.detail.pat_main_2.infect_info.infectInfoFlag",infectInfoFlag);
      //add 5607 感染症更新通知 gaoey end
    }

  /**
   * 検査結果(rst_exam)受信時の
   * 患者情報への感染症情報連携および通知連動
   * @param patMain　患者情報
   * @param result　処理結果
   */
  // del #5607 連動機能の実装確認 20230411 孟堅　start
   // #5607-連動機能の実装確認 周 20230410 mod start
   //private   void nnkExamrstInfectUpdate(PatMain patMain,ResultMap result){
//   private   void nnkExamrstInfectUpdate(PatMain patMain,ResultMap result, String facilityCd){
//   	// #5607-連動機能の実装確認 周 20230410 mod end
//     // #5607-連動機能の実装確認 周 20230410 mod start
//      //Boolean infectInfoFlag = false;
//     boolean infectInfoFlag = false;
//     // #5607-連動機能の実装確認 周 20230410 mod end
//      List<MstExamItem> MstExamItemLists = new ArrayList<>();
//      // #5607-連動機能の実装確認 周 20230410 mod start
//      //List<String> exam_List = (List<String>) result.get("$journal.detail.pat_exam_main.exam_result_info.item_cd")!=null?(List<String>) result.get("$journal.detail.pat_exam_main.exam_result_info.item_cd"):new ArrayList<>();
//     List<String> exam_List = result.get("$journal.detail.pat_exam_main.exam_result_info.item_cd")!=null?(List<String>) result.get("$journal.detail.pat_exam_main.exam_result_info.item_cd"):new ArrayList<>();
//     List<String> examRstList = result.get("$journal.detail.pat_exam_main.exam_result_info.result")!=null?
//       (List<String>) result.get("$journal.detail.pat_exam_main.exam_result_info.result"):new ArrayList<>();
//     // #5607-連動機能の実装確認 周 20230410 mod end
//        for (int i = 0;i < exam_List.size() ; i++){
//          //　mod #5607 連動機能の実装確認 20221122 孟堅　start
//          // if(exam_List.get(i)!=null && exam_List.get(i)!="") {
//          if(exam_List.get(i)!=null && !"".equals(exam_List.get((i)))) {
//          //　mod #5607 連動機能の実装確認 20221122 孟堅　end
//            MstExamItem mstExamItem = mstExamItemDao.selectByExamItemCd(Long.valueOf(exam_List.get(i)));
//            // #5607-連動機能の実装確認 周 20230410 add start
//            String examRst = examRstList.get(i);
//            // #5607-連動機能の実装確認 周 20230410 add end
//            // #5607-連動機能の実装確認 周 20230410 mod start
//            //if (mstExamItem.getInfectionCd() != null) {
//            if (mstExamItem.getInfectionCd() != null && isInfectCode(facilityCd, examRst)) {
//              // #5607-連動機能の実装確認 周 20230410 mod end
//              MstExamItemLists.add(mstExamItem);
//            }
//          }
//        }
//        if(patMain != null){
//          String infectInfo = patMain.getInfect_info();
//          // #5607-連動機能の実装確認 周 20230411 mod start
//          //if(!"[]".equals(infectInfo)){
//            if(!StringUtils.isEmpty(infectInfo) && !"[]".equals(infectInfo)){
//            // #5607-連動機能の実装確認 周 20230411 mod end
//            JSONArray infectInfoJsonList = new JSONArray(infectInfo);
//            List<String> infectionCdList = new ArrayList<>();
//            // #5607-連動機能の実装確認 周 20230410 add start
//            Map<String, String> orgInfect = new HashMap<>();
//            // #5607-連動機能の実装確認 周 20230410 add end
//            for(int i = 0;i < infectInfoJsonList.length() ; i++){
//              JSONObject jsonObj = infectInfoJsonList.getJSONObject(i);
//                String code = jsonObj.get("infection_cd").toString();
//
//                if(code != null){
//                  infectionCdList.add(code);
//                }
//              // #5607-連動機能の実装確認 周 20230410 mod start
//              String infect = jsonObj.get("infect").toString();
//              if(code != null)
//              {
//                orgInfect.put(code, infect);
//              }
//              // #5607-連動機能の実装確認 周 20230410 mod end
//            }
//           for (int i = 0;i < MstExamItemLists.size() ; i++) {
////             if(!infectionCdList.contains(MstExamItemLists.get(i).getInfectionCd())){
////                infectInfoFlag = true;
////                break;
////             }
//             // #5607-連動機能の実装確認 周 20230410 mod start
//             if(!orgInfect.containsKey(MstExamItemLists.get(i).getInfectionCd()))
//             {
//               infectInfoFlag = true;
//               break;
//             }
//             else if(!"2".equals(orgInfect.get(MstExamItemLists.get(i).getInfectionCd())))
//             {
//               infectInfoFlag = true;
//               break;
//             }
//             // #5607-連動機能の実装確認 周 20230410 mod end
//           }
//          }
//          // #5607-連動機能の実装確認 周 20230410 add start
//          else if(!CollectionUtils.isEmpty(MstExamItemLists))
//          {
//            infectInfoFlag = true;
//          }
//          // #5607-連動機能の実装確認 周 20230410 add end
//        }
//      result.put("$journal.detail.pat_main_2.infect_info.infectInfoFlag",infectInfoFlag);
//    }
//  //　add #5607 連動機能の実装確認 20221114 孟堅　end
//
//  // #5607-連動機能の実装確認 周 20230410 add start
//  private boolean isInfectCode(String facilityCd, String reslt)
//  {
//    List<FacilitySettingInfo> settingInfos = mstFacilitySettingDao.selectFacilitySetting(facilityCd, null);
//    FacilitySettingInfo infectSetting;
//    for(FacilitySettingInfo info : settingInfos)
//    {
//      if("検査結果".equals(info.getFunctionName()) && "感染症検査結果反映時 陽性結果値群".equals(info.getSettingName())
//        && info.getValue().contains(reslt))
//      {
//        return true;
//      }
//    }
//
//    return false;
//  }
//  // #5607-連動機能の実装確認 周 20230410 add end
  // del #5607 連動機能の実装確認 20230411 孟堅　end
  /* del by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --start */
  //　add #5607 連動機能の実装確認 20221205 孟堅　strat

//  /***
//   * 電文フォーマットがmultiの場合、1電文に複数患者の検査結果があります。
//   *    * 1行１ジャーナルで処理する  from : 明石　
//   * @param facilityCd  施設コード
//   */
//  private List<Long> updateJournalListExamRst(String facilityCd, List<Long> ctlNoList) {
//// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////    List<MstCoopIni> values = mstCoopIniDao.selectByFacilityCd(facilityCd);
////    if (null != values) {
////      MstCoopIni value = values.get(0);
////      String memo = value.getCoopIniMemo();
////      if (CoopCdConstant.CoopIniMemo.NKKNKK.isSameResult(memo)) {
//// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//    // mod #8103 GX連携で実装されていない機能（利用者情報）limf start
//    // upd #8567 （#8179问题调查结果）外部連携全般に必要な機能が制限されている改正 ztc 0508 start
////    List<SysCoopJournal> coopCdsAndKey0s =new ArrayList<>();
////    SysCoopJournal sysCoopJournal = new SysCoopJournal();
////    sysCoopJournal.setCoopCd(CoopCdConstant.EXAM_RST);
////    sysCoopJournal.setKey0(Key0Constant.NKK);
////    coopCdsAndKey0s.add(sysCoopJournal);
////    sysCoopJournal = new SysCoopJournal();
////    sysCoopJournal.setCoopCd(CoopCdConstant.STAFF_MST);
////    sysCoopJournal.setKey0(Key0Constant.GX);
////    coopCdsAndKey0s.add(sysCoopJournal);
////    List<SysCoopJournal> sysCoopJournals = sysCoopJournalDao.selectCoopByCoopCdKey0s(facilityCd,JournalConvertConstants.DIRECTION_RECEIVE,
////      NtssCoopApiConstants.CoopResult.UNPROCESS.getResult(),NtssCoopApiConstants.CoopResult.DONE.getResult(),
////      coopCdsAndKey0s);
//    List<Long> ctlNoListToReturn = new ArrayList<>();
//    List<SysCoopJournal> sysCoopJournals = sysCoopJournalDao.selectCoopByCoopCdKey0s(facilityCd,JournalConvertConstants.DIRECTION_RECEIVE,
//            NtssCoopApiConstants.CoopResult.UNPROCESS.getResult(),NtssCoopApiConstants.CoopResult.DONE.getResult()
//            , ctlNoList == null ? new ArrayList<>() : ctlNoList);
//    // upd #8567 （#8179问题调查结果）外部連携全般に必要な機能が制限されている改正 ztc 0508 end
////    List<SysCoopJournal> exam_rst = sysCoopJournalDao.selectCoop(
////// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//////          facilityCd, JournalConvertConstants.DIRECTION_RECEIVE,
////          facilityCd, Key0Constant.NKK, JournalConvertConstants.DIRECTION_RECEIVE,
////// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
////          NtssCoopApiConstants.CoopResult.UNPROCESS.getResult(),
////          NtssCoopApiConstants.CoopResult.DONE.getResult(),
////          CoopCdConstant.EXAM_RST);
//        if (sysCoopJournals != null) {
//          for (SysCoopJournal item : sysCoopJournals) {
////            splitMultJournal(item);
//            ctlNoListToReturn.addAll(splitMultJournal(item));
//          }
//          // mod #8103 GX連携で実装されていない機能（利用者情報）limf end
//
//        }
//// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////      }
////    }
//// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//    return ctlNoListToReturn;
//  }
//
//  /**
//   * ジャーナルの複数のデータの分割
//   *
//   * @param journal ジャーナル
//   */
//  private List<Long> splitMultJournal(SysCoopJournal journal) {
//    List<Long> ctlNoList = new ArrayList<>();
//    if (journal != null) {
//// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      // 電子カルテ種別
//      String key0 = StringUtils.isEmpty(journal.getKey0())?"":journal.getKey0();
//      // 連携版番号
//      String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
//// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//      // 電文本体
//      byte[] telegram = journal.getDump();
//      // 患者単位の電文
//      List<byte[]> telegramByPatientList = Collections.singletonList(telegram);
//      try {
//        // 1電文に複数の患者が含まれる場合
//        // 区切り文字で分割した電文を処理対象とする。
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////        String[] multiSetting = getMultiSetting(journal.getFacilityCd(), journal.getDirection(), journal.getCoopCd(), journal.getCoopCdIndex());
//        String[] multiSetting = getMultiSetting(journal.getFacilityCd(), journal.getDirection(), journal.getCoopCd(),
//          journal.getCoopCdIndex(), coopVersion);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//        if (Boolean.valueOf(multiSetting[0])) {
//          String[] delimStrs = Arrays.copyOfRange(multiSetting, 1, multiSetting.length);
//          telegramByPatientList = splitTelegram(telegram, delimStrs);
//          if (telegramByPatientList.size() == 1) {
//            return ctlNoList;
//          }
//          // mod #8103 GX連携で実装されていない機能（利用者情報）limf start
//          List<SysCoopJournal> sysCoopJournals = new ArrayList<>();
//          for (byte[] b : telegramByPatientList) {
//            SysCoopJournal newJournal = new SysCoopJournal() {
//            };
//            newJournal.setFacilityCd(journal.getFacilityCd());
//            Long ctlNo = sysCoopJournalDao.selectNextSeqCtlNo();
//            newJournal.setCtlNo(ctlNo);
//            newJournal.setCoopCd(journal.getCoopCd());
//            newJournal.setCoopCdIndex(journal.getCoopCdIndex());
//// add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//            newJournal.setKey0(key0);
//            newJournal.setCoopVersion(coopVersion);
//// add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//            newJournal.setCrud(journal.getCrud());
//            newJournal.setDirection(journal.getDirection());
//            newJournal.setAnaResult(journal.getAnaResult());
//            newJournal.setCoopResult(journal.getCoopResult());
//            newJournal.setCrud(journal.getCrud());
//            newJournal.setDump(b);
//            newJournal.setOpeCd(journal.getOpeCd());
//            newJournal.setBaseDate(journal.getBaseDate());
//            newJournal.setUserId(journal.getUserId());
//            newJournal.setAcceptNo(journal.getAcceptNo());
//            sysCoopJournals.add(newJournal);
////            sysCoopJournalDao.insert(newJournal);
//            ctlNoList.add(ctlNo);
//          }
//          int[] insert = sysCoopJournalDao.insert(sysCoopJournals);
//          // mod #8103 GX連携で実装されていない機能（利用者情報）limf end
//          sysCoopJournalDao.deleteSysCoopJournalByCtlNo(journal.getCtlNo());
//        }
//
//      } catch (UnsupportedEncodingException e) {
//        e.printStackTrace();
//      } catch (Exception ex) {
//      }
//    }
//    return ctlNoList;
//  }
  //　add #5607 連動機能の実装確認 20221205 孟堅　end
  /* del by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --end */
  // add #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 start
  private String getFacilityHospPatIdMethod(String hospPM, String facilityCd){
    // 患者番号比較方法を取得する
    String method = "";
    Integer cutNo = 0;
    // 患者番号を取得する
    String hospPatIdM = "";
    // 施設連携設定を取得する
    MstCoopFacility mstCoopFacilityM =  mstCoopFacilityDao.select(facilityCd);
    if (mstCoopFacilityM != null) {
      // 各機能共通設定
      MstCoopFacility.CommonSetting commonSetting = mstCoopFacilityM.getCommonSetting();
      if (commonSetting != null) {
        // 比較方法を設定する  ("0":そのまま、"1":左ゼロを除去する、"2":右切り取り桁数)
        method = commonSetting.getHospPatIdCompanyMethodCode();
        // 比較方法は、”2”が場合時に、右切り取り数を設定する
        cutNo = commonSetting.getCutOffDigits();
      }
    }
    Object hopsM = hospPM;
    // "0":そのまま
    if ("0".equals(method) && null != hopsM){
      hospPatIdM = hopsM.toString();
    }
    // "1":左ゼロを除去する
    else if ("1".equals(method) && null != hopsM){
      hospPatIdM = hopsM.toString().replaceFirst("^0*", "");
    }
    // "2":右切り取り桁数
    else if ("2".equals(method) && cutNo > 0 && null != hopsM){
      if (hopsM.toString().length() == cutNo){
        hospPatIdM = hopsM.toString();
      } else if (hopsM.toString().length() > cutNo) {
        hospPatIdM = hopsM.toString().substring(hopsM.toString().length() - cutNo, hopsM.toString().length());
      } else if (hopsM.toString().length() < cutNo) {
        hospPatIdM = String.format("%0" + cutNo + "d",Integer.valueOf(hopsM.toString()));
      }
    }
    return hospPatIdM;
  }
  // add #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 end

  @Async
  public void reconvert(JournalConvertReceiveRequest request) {
    convert(request);
  }
}
