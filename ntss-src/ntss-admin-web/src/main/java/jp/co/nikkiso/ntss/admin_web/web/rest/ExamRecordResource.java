package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.OptimisticLockException;
import org.seasar.doma.jdbc.SqlKind;
import org.seasar.doma.jdbc.SqlLogType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.request.exam.examResultFileCaptureRequest;
import jp.co.nikkiso.ntss.admin_web.response.exam.ExamResultFileCaptureResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.DeviceSetInfoService;
import jp.co.nikkiso.ntss.admin_web.service.exam.ExamRecordNotificationService;
import jp.co.nikkiso.ntss.admin_web.service.exam.ExamRecordService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.admin_web.web.service.MaterialsSharingPatientInformation.MaterialsSharingPatientInfomationService;
import jp.co.nikkiso.ntss.api.service.PatMainDeviceSetInfo.PatMainDeviceSetInfoService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstExamItemDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainDao;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstExamRecordItem;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatNameIdentification;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForExamRecord;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForOneOrder;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForPatIdLastDate;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForRecord;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


// add FNSI-小数点桁数制御 江 start
// add FNSI-小数点桁数制御 江 end
/**
 * 検査結果一覧画面のResourceクラス.
 */
@RestController
@RequestMapping(Uri.EXAM)
public class ExamRecordResource {

    /**
     * 検査結果一覧Service
     */
    @Autowired
    private ExamRecordService examRecordService;
  //add 障害票一覧_检查予定 張岩 start
    @Autowired
    private PatExamMainDao patExamMainDao;
  //add 障害票一覧_检查予定 張岩 end

    // add FNSI-小数点桁数制御 江 start
    /**
    * 検査項目Dao.
    */
    @Autowired
    private MstExamItemDao mstExamItemDao;
    // add FNSI-小数点桁数制御 江 end

    // add 障害票一覧_检查予定 高 start
    @Autowired
    DeviceSetInfoService deviceSetInfoService;
    // add 障害票一覧_检查予定 高 end
    /**
     * webAPI呼び出し用
     */
    @Autowired
    WebApiCallCommonUtil webApiCallCommonUtil;

    @Autowired
    MaterialsSharingPatientInfomationService materialsSharingPatientInfomationService;

    /**
     * ロギングのServiceインタフェース
     */
    @Autowired
    LogService logService;

    @Autowired
    private PatRadMainDao patRadMainDao;

  @Autowired
    private ExamRecordNotificationService examRecordNotificationService;

  // add FNSI-終了およびその結果を通知機能で教える 江 start
  /**
   * 施設設定マスタのDaoインタフェース.
   */
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  // add FNSI-終了およびその結果を通知機能で教える 江 end

  // add FNSi5712アプリケーションログが出力しない 周 start
  @Autowired
  LogEventUtils logEventUtils;
  // add FNSi5712アプリケーションログが出力しない 周 end

    // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
    @Autowired
    private PatMainDeviceSetInfoService patMainDeviceSetInfoService;
    // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end

    @Autowired
    private PatMainDao patMainDao;

    /**
    * 検査セットマスタデータ取得.
    *
    * @param facilityCd 取得対象の施設コード
    * @return 検査セットマスタデータのResponse
    *
    */
    @GetMapping("/examRecord/examSet/{facilityCd}")
    public ResponseEntity<?> getExamRecordSetList(@PathVariable String facilityCd) {

      // ログ出力
      // add FNSi5712アプリケーションログが出力しない 周 start
      String mappingUrl = Uri.EXAM + "/examRecord/examSet/";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to get master : ExamSet");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);
      try {
        // レスポンス生成
        List<MstExamSet> response = examRecordService.selectExamRecordSetList(facilityCd);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {

        // マスタ定義が取得できなかった場合
        eventLogMessage.setLogMessage( "Exception message : "+ e.getMessage());
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
        null);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
            HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }


    /**
    * 検査項目マスタ一覧データ取得.
    *
    * @param facilityCd 取得対象の施設コード
    * @param sex 性別コード
    * @return 検査項目マスタデータのResponse
    *
    */
    @GetMapping("/examRecord/examItem/{facilityCd}")
    public ResponseEntity<?> getExamItemList(@PathVariable String facilityCd) {

      // ログ出力
      // add FNSi5712アプリケーションログが出力しない 周 start
      String mappingUrl = Uri.EXAM + "/examRecord/examItem/";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to get master : ExamSet");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);

      try {
        // レスポンス生成
        List<MstExamItem> response = examRecordService.selectExamItemList(facilityCd);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {

        // マスタ定義が取得できなかった場合
        eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
        null);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
            HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }

  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add start
  /**
   * 検査項目マスタ一覧データ取得.
   *
   * @param facilityCd 取得対象の施設コード
   * @param sex 性別コード
   * @return 検査項目マスタデータのResponse
   *
   */
  @GetMapping("/examRecord/examItemForRecalc/{facilityCd}")
  public ResponseEntity<?> getExamItemListForRecalc(@PathVariable String facilityCd) {

    // ログ出力
    String mappingUrl = Uri.EXAM + "/examRecord/examItemForRecalc/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : ExamSet");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);

    try {
      // レスポンス生成
      List<MstExamItem> response = examRecordService.selectExamItemListForRecalc(facilityCd);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
        null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add end

    @PostMapping("/examRecord/ordMain/selectRst")
    public ResponseEntity<?> getRstStartDateList(
      @RequestBody Map<String, Object > req,
      @AuthenticationPrincipal NtssUser ntssUser) {
      // ログ出力
      // add FNSi5712アプリケーションログが出力しない 周 start
      String mappingUrl = Uri.EXAM + "/examRecord/ordMain/selectRst";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to get data :ordmain RstSelectList ");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);
      eventLogMessage.setLogMessage(req.get("patId").toString());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);
      eventLogMessage.setLogMessage(req.get("facilityCd").toString());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);

      try {
        // レスポンス生成
        List<OrdMainForExamRecord> response =
          examRecordService.selectRstStartDateList(
            Long.parseLong(req.get("patId").toString()),
            req.get("facilityCd").toString()
            );
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {

        // マスタ定義が取得できなかった場合
        eventLogMessage.setLogMessage( "Exception message : "+e.getMessage());
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
        null);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
            HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }

    /**
    * 検査結果個別入力時：検査セット対応検査項目取得SQL(dispが有効でマスタにある検査項目追加)
    *
    * @param facilityCd 取得対象の施設コード
    * @param sex 性別コード
    * @return 検査項目マスタデータのResponse
    *
    */
    @PostMapping("/examRecord/examItem/selectSetData")
    public ResponseEntity<?> getExamItemListForItemCd(
      @RequestBody Map<String, Object > req,
      @AuthenticationPrincipal NtssUser ntssUser) {
      // ログ出力
      // add FNSi5712アプリケーションログが出力しない 周 start
      String mappingUrl = Uri.EXAM + "/examRecord/examItem/selectSetData";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "REST request to get master : ExamMain To DetailList");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);
      try {
        // レスポンス生成
        List<MstExamRecordItem> response =
          examRecordService.selectExamItemListForItemCd(
            req.get("facilityCd").toString(),
            (java.util.List)req.get("examItemCd"),
            (java.util.List)req.get("examClass"),
            "1"
            );
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {

        // マスタ定義が取得できなかった場合
        eventLogMessage.setLogMessage( "Exception message : "+e.getMessage());
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
        null);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
            HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }

    /**
    * 検査項目マスタより、該当施設の有効な検査項目内で指定された検査項目区分のデータを取得
    *
    * @param facilityCd 取得対象の施設コード
    * @param examClass 取得対象の検査項目区分(List形式)
    * @return 検査項目マスタデータのResponse
    *
    */
    @PostMapping("/examRecord/examItem/selectAllData")
    public ResponseEntity<?> getExamItemListForExamClass(
      @RequestBody Map<String, Object > req,
      @AuthenticationPrincipal NtssUser ntssUser) {
      // ログ出力
      // add FNSi5712アプリケーションログが出力しない 周 start
      String mappingUrl = Uri.EXAM + "/examRecord/examItem/selectAllData";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "REST request to get master : ExamMain To DetailList");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);

      try {
        // レスポンス生成
        List<MstExamRecordItem> response =
          examRecordService.selectExamItemListForExamClass(
            req.get("facilityCd").toString(),
            (java.util.List)req.get("examClass"),
            "1"
            );
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {

        // マスタ定義が取得できなかった場合
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (ntssUser != null && ntssUser.getFacilityCd() != null) {
          eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
        }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
        null);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
            HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }

    /**
    * 患者個別一覧用：患者検査結果一覧データ取得.
    *
    * @param patId 取得対象の患者ID
    * @param resultFrom 結果時検査日時FROM
    * @param resultTo 結果時検査日時TO
    * @param examDateOrder 検査結果表示順
    * @param facilityCd ログインユーザ施設コード
    * @return 検査項目マスタデータのResponse
    *
    */
    @GetMapping("/examRecord/examMain/PatRecord")
    public ResponseEntity<?> getExamMainDetailList(
      @RequestParam("patId") String patId,
      @RequestParam("resultFrom") String resultFrom,
      @RequestParam("resultTo") String resultTo,
// mod #11434 検査結果登録でエラー＆フリーズ発生 zkm start
//      @RequestParam("examDateOrder") String examDateOrder,
      @RequestParam(name = "examDateOrder", required = false) String examDateOrder,
// mod #11434 検査結果登録でエラー＆フリーズ発生 zkm end
      //add #12462 患者共有情報取得 by zrx start
      @RequestParam(name = "patientShareMode", required = false) Integer patientShareMode,
      //add #12462 患者共有情報取得 by zrx end
      @AuthenticationPrincipal NtssUser ntssUser) {

      // ログ出力
      // add FNSi5712アプリケーションログが出力しない 周 start
      String mappingUrl = Uri.EXAM + "/examRecord/examMain/PatRecord";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, resultFrom, resultTo, examDateOrder, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to get master : ExamMain To DetailList");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
        null);
      try {
        //del 10188 無効、無意味なコード gjn start
        // レスポンス生成
        List<PatExamMainInfo> responses = examRecordService.selectExamMainToPatId(ntssUser.getFacilityCd(), patId, resultFrom, resultTo, examDateOrder);
        //del 患者共有情報取得#12462 患者情報共有 zrx start
//        List<PatNameIdentification> srcPatIds = materialsSharingPatientInfomationService.getListPatIdSrcFromPatDst(Long.valueOf(patId));
        //del 患者共有情報取得 #12462 患者情報共有 zrx end
        //add #12462 患者情報共有 zrx start\
        if(patientShareMode != null && patientShareMode == 0) {
          List<PatNameIdentification> srcPatIds = materialsSharingPatientInfomationService.getListPatIdSrcFromPatTo(Long.valueOf(patId));
          for (PatNameIdentification patIdsrc : srcPatIds) {
            List<PatExamMainInfo> response = examRecordService.selectExamMainToPatId(patIdsrc.getFacilityCdSrc(), patIdsrc.getPatIdSrc().toString(), resultFrom, resultTo, examDateOrder);
            if(null==response|| response.isEmpty()) {
              continue;
            }
            responses.addAll(response);
          }
        }
        this.appendDefaultCalcExamItemCdForExamResultInfo(ntssUser.getFacilityCd(), responses);
        //add #12462 患者情報共有 zrx end
        //del 10188 無効、無意味なコード gjn end
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, resultFrom, resultTo, examDateOrder, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(responses, HttpStatus.OK);
      } catch (Exception e) {
        // マスタ定義が取得できなかった場合
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
          null);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, resultFrom, resultTo, examDateOrder, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }

    /**
    * 患者一覧用：患者検査結果一覧データ取得.
    *
    * @param patIdList    取得対象の患者IDリスト
    * @param resultFrom   結果時検査日時FROM
    * @param resultTo     結果時検査日時TO
    * @param facilityCd   ログインユーザ施設コード
    * @return             検査項目マスタデータのResponse
    *
    */
    @PostMapping("/examRecord/examMain/Record")
    public ResponseEntity<?> getExamMainRecordList(
      @RequestBody Map<String, Object > req,
      @AuthenticationPrincipal NtssUser ntssUser) {

      // ログ出力
      // add FNSi5712アプリケーションログが出力しない 周 start
      String mappingUrl = Uri.EXAM + "/examRecord/examMain/Record";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "REST request to get master : ExamMain To RecordList");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);
      try {
    	List<Long> listPatId = (List<Long>) req.get("patIdList");
    	String resultFrom = (String)req.get("resultFrom");
    	String resultTo = (String)req.get("resultTo");
        // レスポンス生成
        List<PatExamMainForRecord> response =
          examRecordService.selectExamMainToRecord( ntssUser.getFacilityCd(),listPatId, resultFrom, resultTo);
        //mod #12462 患者情報共有 zrx start
//        List<Long> srcPatIds = materialsSharingPatientInfomationService.getListPatIdSrcFromListPatDst(listPatId);
//        if(!srcPatIds.isEmpty()) {
//	        List<PatExamMainForRecord> responsePast =
//	                examRecordService.selectExamMainToRecord( null,srcPatIds, resultFrom, resultTo);
//	        response.addAll(responsePast);
//        }
        Integer patientShareMode = (Integer)req.get("patientShareMode");
        if(patientShareMode != null && patientShareMode == 0) {
          List<PatNameIdentification> srcPatIds = new ArrayList<>();
          Map<Long, Long> srcPatIdMap = new HashMap<>();
          for(Object obj : listPatId) {
            List<PatNameIdentification> srcPatIdsTemp = new ArrayList<>();
            Long patId = ((Number) obj).longValue();
            srcPatIdsTemp = materialsSharingPatientInfomationService.getListPatIdSrcFromPatTo(patId);
            srcPatIds.addAll(srcPatIdsTemp);
            if(!srcPatIdsTemp.isEmpty()) {
              for(PatNameIdentification pni : srcPatIdsTemp){
                srcPatIdMap.put(pni.getPatIdSrc(), patId);
              }
            }
          }
          for (PatNameIdentification patIdsrc : srcPatIds) {
            List<Long> tempPatIdList = new ArrayList<>();
            tempPatIdList.add(patIdsrc.getPatIdSrc());
            List<PatExamMainForRecord> responsePast =
              examRecordService.selectExamMainToRecord(patIdsrc.getFacilityCdSrc(), tempPatIdList, resultFrom, resultTo);
            if(responsePast != null && !responsePast.isEmpty()) {
              for(PatExamMainForRecord pemr : responsePast) {
                Long srcPatId = pemr.getPatId();
                if (srcPatId != null && srcPatIdMap.containsKey(srcPatId)) {
                  pemr.setPatIdDst(srcPatIdMap.get(srcPatId));
                }
              }
              response.addAll(responsePast);
            }
          }
        }
        //mod #12462 患者情報共有 zrx end
        // del 10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
        // add FNSI-小数点桁数制御 江 start
//        String valueFormat;
//        for(PatExamMainForRecord patExamMain : response){
//          String result=patExamMain.getResult();
//          if(result != null && !result.equals("")){
//            // 検査項目コードの取得
//            Long examItemCd = Long.parseLong(patExamMain.getItemCd());
//            // システム標準計算
//            MstExamItem examItem = mstExamItemDao.selectByExamItemCd(examItemCd);
//            // mod 10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
//            if ("0".equals(examItem.getDataType())) {
//              patExamMain.setResult(result);
//            }else {
//              // mod 7391 exam_rst連携で受信した検査項目コード  吉 start
//              // if (examItem.getInputDecimalFigure() != null ) {
//              if (null != examItem && examItem.getInputDecimalFigure() != null) {
//                // mod 7391 exam_rst連携で受信した検査項目コード  吉 end
//                valueFormat = "%1$." + examItem.getInputDecimalFigure() + "f";
//              } else {
//                valueFormat = "%1$." + 2 + "f";
//              }
//              try {
//                patExamMain.setResult(String.format(valueFormat, Double.parseDouble(result)));
//              } catch (Exception e) {
//                patExamMain.setResult(result);
//              }
//              // mod 10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
//            }
//          }
//        };
        // add FNSI-小数点桁数制御 江 end
        // del 10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {

        // マスタ定義が取得できなかった場合
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (ntssUser != null && ntssUser.getFacilityCd() != null) {
          eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
        }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
        null);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
            HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }

    /**
    * 患者一覧用：患者検査結果一覧　患者ごと最終検査日取得
    *
    * @param patIdList    取得対象の患者IDリスト
    * @param facilityCd   ログインユーザ施設コード
    * @return             検査項目マスタデータのResponse
    *
    */
    @PostMapping("/examRecord/examMain/PatIdLastDate")
    public ResponseEntity<?> getExamMainPatIdLastDate(
      @RequestBody Map<String, Object > req,
      @AuthenticationPrincipal NtssUser ntssUser) {

      // ログ出力
      // add FNSi5712アプリケーションログが出力しない 周 start
      String mappingUrl = Uri.EXAM + "/examRecord/examMain/PatIdLastDate";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "REST request to get master : ExamMain To PatIdLastDate");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);
      try {
        // レスポンス生成
        List<PatExamMainForPatIdLastDate> response =
          examRecordService.selectExamMainToPatIdLastDate(
            ntssUser.getFacilityCd(),
            (java.util.List)req.get("patIdList"));
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {

        // マスタ定義が取得できなかった場合
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (ntssUser != null && ntssUser.getFacilityCd() != null) {
          eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
        }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
        null);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
            HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }


    /**
    * 患者結果：患者検査1オーダー用データ取得(json分解済)
    *
    * @param examMainCd   患者検査結果id
    * @return             検査項目マスタデータのResponse
    *
    */
    @PostMapping("/examRecord/examMain/selectOneOrder")
    public ResponseEntity<?> getExamMainOneOrder(
      @RequestBody Map<String, Object > req) {

      // ログ出力
      // add FNSi5712アプリケーションログが出力しない 周 start
      String mappingUrl = Uri.EXAM + "/examRecord/examMain/selectOneOrder";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req));
      // add FNSi5712アプリケーションログが出力しない 周 end
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "REST request to get master : ExamMain To RecordList");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);

      try {
        // レスポンス生成
        List<PatExamMainForOneOrder> response = new ArrayList<PatExamMainForOneOrder>();
        List<PatExamMainForOneOrder> patExamMainForOneOrderList =
          examRecordService.selectExamMainForOneOrder(
            (String)req.get("examMainCd"));
        // add FNSI-小数点桁数制御 江 start
        String valueFormat;
        for(PatExamMainForOneOrder patExamMain : patExamMainForOneOrderList){
          String result=patExamMain.getResult();
          if(result != null && !result.equals("")){
            // 検査項目コードの取得
            Long examItemCd = Long.parseLong(patExamMain.getItemCd());
            // システム標準計算
            MstExamItem examItem = mstExamItemDao.selectByExamItemCd(examItemCd);
            // mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
//            // mod 10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
//            if ("0".equals(examItem.getDataType())) {
//              patExamMain.setResult(result);
//            }else {
//              if (examItem.getInputDecimalFigure() != null) {
//                valueFormat = "%1$." + examItem.getInputDecimalFigure() + "f";
//              } else {
//                valueFormat = "%1$." + 2 + "f";
//              }
//              try {
//                patExamMain.setResult(String.format(valueFormat, Double.parseDouble(result)));
//              } catch (Exception e) {
                patExamMain.setResult(result);
//              }
//              // mod 10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
//            }
            // mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
            // mst_exam_item.is_dispが「1:表示」の場合はresponseにセット
            if ("1".equals(examItem.getIsDisp())) {
              response.add(patExamMain);
            }
          }
        };
        // add FNSI-小数点桁数制御 江 end
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {

        // マスタ定義が取得できなかった場合
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
        null);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
            HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }


    /**
    * 患者結果：患者検査1オーダー登録
    *
    * @param examMain   患者検査結果
    * @return           アップデート結果の成功・失敗パラメータ
    *
    */
    @PostMapping("/examRecord/examMain/insertOneOrder")
    public ResponseEntity<?> insertExamMainOneOrder(
      @RequestBody Map<String, Object > req,
      @AuthenticationPrincipal NtssUser ntssUser) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      String mappingUrl = Uri.EXAM + "/examRecord/examMain/insertOneOrder";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
    try {

      // 更新時刻
      Timestamp upDt = new Timestamp(System.currentTimeMillis());
      Timestamp setDate = new Timestamp(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(req.get("regExamDate").toString()).getTime());
      Long examMainCd = null;
      List<Long> examMainCdList = new ArrayList<Long>();

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( req.toString());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);
      Long patId = Long.parseLong(req.get("patId").toString());
      PatExamMain setPatExamMain = new PatExamMain();
      setPatExamMain.setPatId(patId);
      setPatExamMain.setFacilityCd(req.get("facilityCd").toString());
      setPatExamMain.setRegExamDate(setDate);
      setPatExamMain.setRegOrderClass(req.get("regOrderClass").toString());

      setPatExamMain.setExamStatus("1");
      setPatExamMain.setOrderExamSetInfo("[]");
      setPatExamMain.setExamOrderInfo("[]");
      setPatExamMain.setOrderLabelInfo("[]");
      setPatExamMain.setDataGenClass("0");

      if(Objects.isNull(req.get("ordNo"))){
        setPatExamMain.setOrdNo(null);
      }else{
        setPatExamMain.setOrdNo(Long.parseLong(req.get("ordNo").toString()));
      }
      setPatExamMain.setResultExamDate(setDate);
      setPatExamMain.setExamResultInfo(req.get("examResultInfo").toString());
      setPatExamMain.setRegDate(upDt);
      setPatExamMain.setRegStaff(Long.parseLong(req.get("regStaff").toString()));
      setPatExamMain.setUpDate(upDt);
      setPatExamMain.setUpStaff(Long.parseLong(req.get("updStaff").toString()));
      setPatExamMain.setIsDel("0");
      setPatExamMain.setIsOrder("0");

      // DB追加
      examMainCd = examRecordService.insertExamMainForOneOrder(setPatExamMain);
	  // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
      int isTpHTDataAvailableFlag = patMainDeviceSetInfoService.isTpHTDataAvailable(req.get("facilityCd").toString(), examMainCd);
      if(isTpHTDataAvailableFlag > 0){
      	Map<String, String> userAuthInfo = this.getUserInfoByAuthentication();
      	patMainDeviceSetInfoService.updDeviceSetInfo(req.get("facilityCd").toString(), patId, userAuthInfo, isTpHTDataAvailableFlag);
      }
      examMainCdList.add(examMainCd);
      PatMain oldPatMain = patMainDao.selectById(patId);

      // 感染症情報更新APIを実行
      ResponseEntity<String> ret = webApiCallCommonUtil.updateInfectinfo(examMainCdList);
      // 失敗時
      if (ret.getStatusCode() != HttpStatus.OK) {
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>("感染症情報更新API実行失敗", HttpStatus.BAD_REQUEST);
      }

      // 自動計算処理API
      ResponseEntity<String> calcRet = webApiCallCommonUtil.updateExamResultCalc(examMainCdList);
      // 失敗時
      if (calcRet.getStatusCode() != HttpStatus.OK) {
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>("自動計算処理API実行失敗", HttpStatus.BAD_REQUEST);
      }
      // 感染情報更新後の患者情報取得
      PatMain newPatMain = patMainDao.selectById(patId);
      //感染症情報更新通知
      examRecordNotificationService.registerInfectionNotification(oldPatMain, newPatMain);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);

    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }
    // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
    public Map<String,String> getUserInfoByAuthentication(){
        Map<String, String> userInfoRst = new HashMap<>();
        NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (user != null) {
            // 利用者ID
            userInfoRst.put("userId", user.getUserId().toString());
            // 施設コード
            userInfoRst.put("facilityCd", user.getFacilityCd());
            // 接続先IPアドレス
            userInfoRst.put("clientIpAddress", user.getClientIpAddress());
            // セッションID
            userInfoRst.put("sessionId", user.getSessionId());
        }
        return userInfoRst.isEmpty() ? null : userInfoRst;
    }
    // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end

    /**
    * 患者結果：患者検査1オーダー更新
    *
    * @param examMain   患者検査結果
    * @return           アップデート結果の成功・失敗パラメータ
    *
    */
    @PostMapping("/examRecord/examMain/updateOneOrder")
    public ResponseEntity<?> updateExamMainOneOrder(
      @RequestBody Map<String, Object > req,
      @AuthenticationPrincipal NtssUser ntssUser) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      String mappingUrl = Uri.EXAM + "/examRecord/examMain/updateOneOrder";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
    List<Long> examMainCdList = new ArrayList<Long>();
    try {

      examRecordService.updateExamMainForOneOrder(
        Long.parseLong(req.get("examMainCd").toString()),
        req.get("examResultInfo").toString(),
        Long.parseLong(req.get("upStaff").toString()),
        req.get("examDate").toString(),
        req.get("regOrderClass").toString()
      );
      // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
      Long examMainCd = Long.valueOf(req.get("examMainCd").toString());
      int isTpHTDataAvailableFlag = patMainDeviceSetInfoService.isTpHTDataAvailable(req.get("facilityCd").toString(), examMainCd);
      Long patId = Long.parseLong(req.get("patId").toString());
      if(isTpHTDataAvailableFlag > 0) {
      	Map<String, String> userAuthInfo = this.getUserInfoByAuthentication();
      	patMainDeviceSetInfoService.updDeviceSetInfo(req.get("facilityCd").toString(), patId, userAuthInfo, isTpHTDataAvailableFlag);
      }
      // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end

      PatMain oldPatMain = patMainDao.selectById(patId);
      // 感染症情報処理APIを実行
      examMainCdList.add(Long.parseLong(req.get("examMainCd").toString()));
      ResponseEntity<String> ret = webApiCallCommonUtil.updateInfectinfo(examMainCdList);
      // 失敗時
      if (ret.getStatusCode() != HttpStatus.OK) {
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>("感染症情報更新API実行失敗", HttpStatus.BAD_REQUEST);
      }

      // 自動計算処理API
      ResponseEntity<String> calcRet = webApiCallCommonUtil.updateExamResultCalc(examMainCdList);
      // 失敗時
      if (calcRet.getStatusCode() != HttpStatus.OK) {
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>("自動計算処理API実行失敗", HttpStatus.BAD_REQUEST);
      }
      // 感染情報更新後の患者情報取得
      PatMain newPatMain = patMainDao.selectById(patId);
      //感染症情報更新通知
      examRecordNotificationService.registerInfectionNotification(oldPatMain, newPatMain);

      // add FNSI-檢查結果通知 関 start
      PatExamMain examInfo = examRecordService.selectPatExamMainByExamMainCd(examMainCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "REST request to get master : ExamMain To RecordList");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  /**
  * 検査結果入力画面：治療情報:透析履歴日付プルダウン用データ取得
  *
  * @param patId 患者id
  * @param facilityCd 取得対象の施設コード
  * @return 検査項目マスタデータのResponse
  *
  */
  @GetMapping("/examRecord/getOrdMainStartDates/{facilityCd}/{sex}")
  public ResponseEntity<?> getOrdMainStartDates(@PathVariable Long patId, @PathVariable String facilityCd) {

    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXAM + "/examRecord/getOrdMainStartDates/{facilityCd}/{sex}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId,facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : ExamSet");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
    null);

    try {
      // レスポンス生成
      List<OrdMainForExamRecord> response = examRecordService.selectOrdMainStartDatesList(patId,facilityCd);

      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId,facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage( "Exception message : "+e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId,facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }


  /**
  * 検査結果ファイル一括登録処理.
  *
  * @param 検査結果ファイル内容(1行=1データのリスト形式)
  * @return 登録成功件数/失敗件数情報
  *
  */
  @PutMapping("/examRecord/fileCapture")
  public ResponseEntity<?> registFileCapture(
      @RequestBody List<examResultFileCaptureRequest> request,
      @AuthenticationPrincipal NtssUser ntssUser
      ){
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXAM + "/examRecord/fileCapture";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(request,ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    if (request.size() != 0) {
      try {
        // add FNSI-終了およびその結果を通知機能で教える 江 start
        boolean isExists = false ;
        // 施設コードを元に施設設定データ(Mst/Sys)を取得:全項目ケースのためfacilitySettingNoは3003セット
        List<FacilitySettingInfo> settingInfoList = mstFacilitySettingDao.selectFacilitySetting(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.CHECK_RESULT_FOR_FACILITY);
        HashSet<String> hashSet = new HashSet<String>();
        for (examResultFileCaptureRequest item : request){
          //ファイルにデータが1つしか取り込まれていない場合、「患者番号は繰り返しています」とエラーが表示されます 修正 20230615 ztc start
//          if(item.getHospPatId().replaceAll("^[  ]+", "").length() != 12 && item.getHospPatId().replaceAll("^[  ]+", "").substring(0,1) == "0"){
          if(item.getHospPatId().replaceAll("^[  ]+", "").length() != 12 && "0".equals(item.getHospPatId().replaceAll("^[  ]+", "").substring(0,1))){
            //ファイルにデータが1つしか取り込まれていない場合、「患者番号は繰り返しています」とエラーが表示されます 修正 20230615 ztc end
            continue;
          }else{
            hashSet.add(item.getHospPatId().replaceAll("^[  ]+", ""));
          }
        }
        for(FacilitySettingInfo settingInfo : settingInfoList){
          if (settingInfo.getValue().equals("1")) {
            for (examResultFileCaptureRequest item : request){
              //del redmine 5696
              /*Integer.parseInt(item.getHospPatId().replaceAll("^[  ]+", ""));*/
              //del redmine 5696
              if(item.getHospPatId().replaceAll("^[  ]+", "").length() != 12 && item.getHospPatId().replaceAll("^[  ]+", "").substring(0,1).equals("0")){
                if(hashSet.contains(item.getHospPatId().replaceAll("^[  ]+", ""))){
                  isExists = true ;
                }
              }
            }
          }
        }
        if(isExists){
          // add FNSi5712アプリケーションログが出力しない 周 start
          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
            AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(request,ntssUser));
          // add FNSi5712アプリケーションログが出力しない 周 end
          return new ResponseEntity<>("患者の番号は重複しています", HttpStatus.OK);
        }
        // add FNSI-終了およびその結果を通知機能で教える 江 end
        // ファイル取り込み処理
        ExamResultFileCaptureResponse result = examRecordService.examResultFileCapture(ntssUser.getUserId(), ntssUser.getFacilityCd(), request);

        // 更新されたexam_main_cdのリストがあるか判定
        if (result.examMainCdList == null || result.examMainCdList.isEmpty()) {
          // 感染症情報更新はしない
        } else {
        // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
        List<Long> dicExamMainCdList = result.examMainCdList.stream().distinct().collect(Collectors.toList());
        for (Long emCd : dicExamMainCdList) {
        	int isTpHTDataAvailableFlag = patMainDeviceSetInfoService.isTpHTDataAvailable(ntssUser.getFacilityCd(), emCd);
        		if(isTpHTDataAvailableFlag > 0) {
        			Map<String, String> userAuthInfo = this.getUserInfoByAuthentication();
        			patMainDeviceSetInfoService.updDeviceSetInfo(ntssUser.getFacilityCd(), result.examMainCdPatIdMap.get(emCd), userAuthInfo, isTpHTDataAvailableFlag);
        		}
        }
        // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end
          // 感染症情報更新APIを実行
          ResponseEntity<String> ret = webApiCallCommonUtil.updateInfectinfo(result.examMainCdList);
          // 失敗時
          if (ret.getStatusCode() != HttpStatus.OK) {
            // add FNSi5712アプリケーションログが出力しない 周 start
            logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
              AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(request,ntssUser));
            // add FNSi5712アプリケーションログが出力しない 周 end
            return new ResponseEntity<>("感染症情報更新API実行失敗", HttpStatus.BAD_REQUEST);
          }
          // 検査計算項目更新APIを実行
          ret = webApiCallCommonUtil.updateExamResultCalc(result.examMainCdList);
          // 失敗時
          if (ret.getStatusCode() != HttpStatus.OK) {
            // add FNSi5712アプリケーションログが出力しない 周 start
            logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
              AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(request,ntssUser));
            // add FNSi5712アプリケーションログが出力しない 周 end
            return new ResponseEntity<>("検査計算項目更新API実行失敗", HttpStatus.BAD_REQUEST);
          }
        }

        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(request,ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(String.valueOf(result.registCnt) + "," + String.valueOf(result.skipCnt()), HttpStatus.OK);
      } catch (Exception e) {
        // 例外発生時、BAD_REQUESTを返す
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage( "REST request error by updateCheckAfterWeight: "+ e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
        null);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(request,ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
      }
    } else {
      // リクエスト内容がNullまたは空の場合、BAD_REQUESTを返す
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get CheckMediDone : recieve data is Null or Empty.");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
      null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(request,ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>("登録データが1件もありません", HttpStatus.BAD_REQUEST);
    }
  }

  // add FNSI-終了およびその結果を通知機能で教える 江 start
  /**
   * 検査結果ファイル一括登録通知登録.
   * @param facilityCd 取得対象の施設コード
   * @param successfulConut 登録成功件数
   * @param failedCount 失敗件数
   * @return 検査項目マスタデータのResponse
   *
   */
  @PutMapping("/examRecord/fileCapture/{facilityCd}/{successfulConut}/{failedCount}")
  public void registerNotificationForReadFiles(@PathVariable String facilityCd
                                             , @PathVariable String successfulConut
                                             , @PathVariable String failedCount)
  {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXAM + "/examRecord/fileCapture/{facilityCd}/{successfulConut}/{failedCount}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd,successfulConut, failedCount));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      examRecordService.registerNotificationForReadFiles(facilityCd, successfulConut, failedCount);

    } catch (Exception e) {
      // マスタ定義が取得できなかった場合
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "Exception message : "+e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
        null);

    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd,successfulConut, failedCount));
    // add FNSi5712アプリケーションログが出力しない 周 end
  }
  // add FNSI-終了およびその結果を通知機能で教える 江 end

  /**
   * 検査結果から感染症の検査結果を登録
   * @param examMainCd 検査結果コード
   */
  @PutMapping("/examRecord/updateInfectinfo")
  public ResponseEntity<String> updateInfectinfo(
    @RequestBody List<Long> examMainCd
    ){
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXAM + "/examRecord/updateInfectinfo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    // 戻り値情報
    JSONObject responseData = new JSONObject();
    // 条件送信処理呼び出し
    try {
      ResponseEntity<String> ret = webApiCallCommonUtil.updateInfectinfo(examMainCd);
      // メッセージ情報を格納
      if (ret.getStatusCode() != HttpStatus.OK) {
        responseData.put("retMsg", 99999998);
      }
    } catch (URISyntaxException | RuntimeException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      // 例外発生時、BAD_REQUESTを返す
      return new ResponseEntity<>("感染症情報更新API実行失敗", HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(responseData.toString(), null, HttpStatus.OK);
  }

  /**
   * 検査結果から検査計算処理を実行
   * @param examMainCd 検査結果コード
   */
  @PutMapping("/examRecord/updateExamResultCalc")
  public ResponseEntity<String> updateExamResultCalc(
    @RequestBody List<Long> examMainCd
    ){
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXAM + "/examRecord/updateExamResultCalc";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    // 戻り値情報
    JSONObject responseData = new JSONObject();
    // 条件送信処理呼び出し
    try {
      ResponseEntity<String> ret = webApiCallCommonUtil.updateExamResultCalc(examMainCd);
      // メッセージ情報を格納
      if (ret.getStatusCode() != HttpStatus.OK) {
        responseData.put("retMsg", 99999998);
      }
    } catch (URISyntaxException | RuntimeException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      // 例外発生時、BAD_REQUESTを返す
      return new ResponseEntity<>("検査計算項目更新API実行失敗", HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(responseData.toString(), null, HttpStatus.OK);
  }


  /**
   * 既に存在する検査結果データの取得.
   * @param req 以下の内部パラメータを持つ.
   *   patId 患者Id.
   *   regOrderClass 検査区分.
   *   resultExamDate 検査日時.
   *   exclExamMainCd 除外する検査結果コード.
   * @return 検査結果データ.
   */
  @PostMapping("/examRecord/examMain/getExistResult")
  public ResponseEntity<?> getExistResult(
    @RequestBody Map<String, Object> req) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXAM + "/examRecord/examMain/getExistResult";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req));
    // add FNSi5712アプリケーションログが出力しない 周 end

    try {
      Long patId = ((Number)req.get("patId")).longValue();
      String regOrderClass = (String)req.get("regOrderClass");
      String resultExamDate = (String)req.get("resultExamDate");
      Long exclExamMainCd = null;
//      if (req.get("exclExamMainCd") != null) {
//        exclExamMainCd = ((Number)req.get("exclExamMainCd")).longValue();
//      }
      // レスポンス生成
      PatExamMain response =
        examRecordService.selectExistResult(
          patId,
          regOrderClass,
          resultExamDate.substring(0,16),
          exclExamMainCd
        );
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req));
      // add FNSi5712アプリケーションログが出力しない 周 end

      // マスタ定義が取得できなかった場合
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 既に存在する検査依頼データの取得.
   * @param req 以下の内部パラメータを持つ.
   *   patId 患者Id.
   *   regOrderClass 検査区分.
   *   regExamDate 検査依頼日.
   *   exclExamMainCd 除外する検査結果コード.
   * @return 検査依頼データ.
   */
  @PostMapping("/examRecord/examMain/getExistOrder")
  public ResponseEntity<?> getExistOrder(
    @RequestBody Map<String, Object> req) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXAM + "/examRecord/examMain/getExistOrder";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req));
    // add FNSi5712アプリケーションログが出力しない 周 end

    try {
      Long patId = ((Number)req.get("patId")).longValue();
      String regOrderClass = (String)req.get("regOrderClass");
      String regExamDate = (String)req.get("regExamDate");
      Long exclExamMainCd = null;
//      if (req.get("exclExamMainCd") != null) {
//        exclExamMainCd = ((Number)req.get("exclExamMainCd")).longValue();
//      }
      // レスポンス生成
      PatExamMain response =
        examRecordService.selectExistOrder(
          patId,
          regOrderClass,
          regExamDate,
          exclExamMainCd
        );
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req));
      // add FNSi5712アプリケーションログが出力しない 周 end

      // マスタ定義が取得できなかった場合
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
  * 検査結果入力画面：移動処理用:検査結果レコードを1件取得
  *
  * @param examMainCd 検査結果ID
  * @return 検査結果データのResponse
  *
  */
  @GetMapping("/examRecord/examMain/getPatExamMainByExamMainCd/{examMainCd}")
  public ResponseEntity<?> getPatExamMainByExamMainCd(@PathVariable Long examMainCd) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXAM + "/examRecord/examMain/getPatExamMainByExamMainCd/{examMainCd}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
    // add FNSi5712アプリケーションログが出力しない 周 end

    try {
      // レスポンス生成
      PatExamMain response = examRecordService.selectPatExamMainByExamMainCd(examMainCd);

      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
      // add FNSi5712アプリケーションログが出力しない 周 end

      // マスタ定義が取得できなかった場合
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
  * 患者結果：検査結果情報をクリアする
  *
  * @param examMain   患者検査結果
  * @return           アップデート結果の成功・失敗パラメータ
  *
  */
  @PostMapping("/examRecord/examMain/clearExamResultInfo/{examMainCd}")
  public ResponseEntity<?> clearExamResultInfo(@PathVariable Long examMainCd) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXAM + "/examRecord/examMain/clearExamResultInfo/{examMainCd}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      examRecordService.clearExamResultInfo(examMainCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
  * 患者結果：検査結果レコードを論理削除する
  *
  * @param examMain   患者検査結果
  * @return           アップデート結果の成功・失敗パラメータ
  *
  */
  @PostMapping("/examRecord/examMain/deletePatExamMain/{examMainCd}")
  public ResponseEntity<?> deletePatExamMain(@PathVariable Long examMainCd) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXAM + "/examRecord/examMain/deletePatExamMain/{examMainCd}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      examRecordService.deletePatExamMain(examMainCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(examMainCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }



  /**
  * 患者結果：患者検査1オーダー削除処理(フラグ有無による)
  *
  * @param examMainCd  削除対象検査コード
  * @param upStaff     更新時スタッフID
  * @param checkDate   排他制御用日時
  * @return           アップデート結果の成功・失敗パラメータ
  *
  */
  @PostMapping("/examRecord/examMain/deleteOneOrder")
  public ResponseEntity<?> deleteExamMainOneOrder(
    @RequestBody Map<String, Object > req,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXAM + "/examRecord/examMain/deleteOneOrder";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to : ExamMainDetail-DeleteUpd"
    + " examMainCd:"+ req.get("examMainCd").toString() + " checkDate:" + (String)req.get("checkDate"));
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
    null);
    //mod 9480 患者检查結果：削除処理 guan start
    Long emcd = Long.parseLong(req.get("examMainCd").toString());
    //削除した検査結果のコードから患者IDを取得する
    PatExamMain patExamMain = patExamMainDao.selectPatExamMainByExamMainCd(emcd);
    try{
      // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
      PatExamMain pem = patExamMainDao.selectPatExamMain(Long.parseLong(req.get("examMainCd").toString()));
      int isTpHTDataAvailableFlag = patMainDeviceSetInfoService.isTpHTDataAvailable(pem.getFacilityCd(), Long.parseLong(req.get("examMainCd").toString()));
      // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end
      examRecordService.deleteExamMainForOneOrder(emcd, Long.parseLong(req.get("upStaff").toString()),
        req.get("checkDate").toString().substring(0,10)
      );
      // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
      if(isTpHTDataAvailableFlag > 0){
        Map<String, String> userAuthInfo = this.getUserInfoByAuthentication();
        patMainDeviceSetInfoService.updDeviceSetInfo(pem.getFacilityCd(), pem.getPatId(), userAuthInfo, isTpHTDataAvailableFlag);
      }
      // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end
      SimpleDateFormat sdfRed = new SimpleDateFormat("yyyyMMdd");
      String currDate_regExamDate = sdfRed.format(patExamMain.getRegExamDate());
      //削除検査結果データを取得した当日内のすべての検査結果データ
      List<Long> examMainCdList = patExamMainDao.selectPatExamMainForAutoCalculation(patExamMain.getPatId(), patExamMain.getFacilityCd(), currDate_regExamDate);
      //削除しようとしているチェック結果をフィルタリングする
      examMainCdList = examMainCdList.stream().filter(f -> !emcd.equals(f)).distinct().collect(Collectors.toList());
      // 自動計算処理API
      ResponseEntity<String> calcRet = webApiCallCommonUtil.updateExamResultCalc(examMainCdList);
      // 失敗時
      if (calcRet.getStatusCode() != HttpStatus.OK) {
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>("自動計算処理API実行失敗", HttpStatus.BAD_REQUEST);
      }
      //mod 9480 患者检查結果：削除処理 guan end
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<String>("OK",null,HttpStatus.OK);
      }catch (EmptyResultDataAccessException e) {
        // 排他制御エラー発生時:専用ログ出力
        eventLogMessage.setLogMessage( "REST request error by ExamMainDetail-DeleteUpd-OptimisticLock: "+ e.getMessage()
        + " examMainCd:"+ req.get("examMainCd").toString() + " checkDate:" + (String)req.get("checkDate"));
        logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI,
        "patExamMainDao/selectIsOrderByExamMainCd");
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        // 排他制御標準エラー処理のためにOptimisticLockExceptionをスロー
        throw new OptimisticLockException(SqlLogType.NONE, SqlKind.SELECT, "", "", "");
      }catch (Exception ee) {
        //その他想定外エラー(論理削除中の排他以外のsqlエラー/取得dataの想定外)
        eventLogMessage.setLogMessage( "REST request error by  ExamMainDetail-DeleteUpd-Exception: "+ ee.getMessage()
        + " examMainCd:"+ req.get("examMainCd").toString() + " checkDate:" + (String)req.get("checkDate"));
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_RECORD, SERVICE_NAME.FNSI, null);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<String>(ee.getMessage(),null,HttpStatus.BAD_REQUEST);
      }
  }
//  add マスタ削除対応 張 start
  @PostMapping("/examRecord/examItem/selectSetDataForFacilityCd")
  public ResponseEntity<?> getExamItemListForItemCd(@RequestBody Map<String, Object > req) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXAM + "/examRecord/examItem/selectSetDataForFacilityCd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req));
    // add FNSi5712アプリケーションログが出力しない 周 end
      List<Long> response = examRecordService.selectExamItemListForFacilityCd(req.get("facilityCd").toString());
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req));
    // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.OK);
  }
//  add マスタ削除対応 張 end
/*add FNSI-改修内容redmain6287 任 start*/
  @PostMapping("/examRecord/examMain/deleteRefresh")
  public ResponseEntity<?> deleteRefresh(
    @RequestBody Map<String, Object > req,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXAM + "/examRecord/examMain/deleteRefresh";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end

    List<Long> examMainCd = patExamMainDao.getExamCds(Long.parseLong(req.get("patId").toString()));

    // 条件送信処理呼び出し
    try {
      ResponseEntity<String> ret = webApiCallCommonUtil.updateExamResultCalc(examMainCd);
      // メッセージ情報を格納
      if (ret.getStatusCode() != HttpStatus.OK) {
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>("検査計算項目更新API実行失敗", HttpStatus.BAD_REQUEST);
      }
    } catch (URISyntaxException | RuntimeException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      // 例外発生時、BAD_REQUESTを返す
      return new ResponseEntity<>("検査計算項目更新API実行失敗", HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_RECORD,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(HttpStatus.OK);
  }
  /*add FNSI-改修内容redmain6287 任 end*/

  private void appendDefaultCalcExamItemCdForExamResultInfo(String facilityCd, List<PatExamMainInfo> responses) {
    if (responses == null || responses.isEmpty()) {
      return;
    }
    Map<Long, String> defaultCalcExamItemCdMap = new HashMap<>();
    for (PatExamMainInfo response : responses) {
      if (response == null || response.getExamResultInfo() == null || response.getExamResultInfo().isEmpty()) {
        continue;
      }
      if(Objects.equals(facilityCd, response.getFacilityCd())) {
        continue;
      }
      try {
        JSONArray examResultInfoArray = new JSONArray(response.getExamResultInfo());
        for (int i = 0; i < examResultInfoArray.length(); i++) {
          JSONObject examResultInfoObj = examResultInfoArray.optJSONObject(i);
          if (examResultInfoObj == null || !"1".equals(examResultInfoObj.optString("exam_class", null))) {
            continue;
          }
          String itemCdStr = examResultInfoObj.optString("item_cd", null);
          if (itemCdStr == null || itemCdStr.isEmpty()) {
            examResultInfoObj.put("defaultCalcExamItemCd", JSONObject.NULL);
            continue;
          }
          try {
            Long itemCd = Long.parseLong(itemCdStr);
            String defaultCalcExamItemCd;
            if (defaultCalcExamItemCdMap.containsKey(itemCd)) {
              defaultCalcExamItemCd = defaultCalcExamItemCdMap.get(itemCd);
            } else {
              MstExamItem examItem = mstExamItemDao.selectByExamItemCd(itemCd);
              defaultCalcExamItemCd = examItem == null ? null : examItem.getDefaultCalcExamItemCd();
              defaultCalcExamItemCdMap.put(itemCd, defaultCalcExamItemCd);
            }
            if (defaultCalcExamItemCd == null || defaultCalcExamItemCd.isEmpty()) {
              examResultInfoObj.put("defaultCalcExamItemCd", JSONObject.NULL);
            } else {
              examResultInfoObj.put("defaultCalcExamItemCd", defaultCalcExamItemCd);
            }
          } catch (NumberFormatException e) {
            examResultInfoObj.put("defaultCalcExamItemCd", JSONObject.NULL);
          }
        }
        response.setExamResultInfo(examResultInfoArray.toString());
      } catch (Exception e) {
        // examResultInfo が不正なJSONの場合は元データをそのまま返す
      }
    }
  }

  // add FNSi5712アプリケーションログが出力しない 周 start
  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }
  // add FNSi5712アプリケーションログが出力しない 周 end
    }
