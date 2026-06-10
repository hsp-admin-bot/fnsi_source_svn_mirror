package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadPatternDao;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatRadPattern;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.CollectionUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.request.rad.RadRequest;
import jp.co.nikkiso.ntss.admin_web.request.rad.SaveRadRequest;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.response.rad.RadRequestResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.PatInfoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.rad.RadRequestService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.entity.MstRadSet;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 検査依頼（exam-request）系のリソースクラス
 */
@RestController
@RequestMapping(Uri.RAD)
@Slf4j
public class RadRequestResource {

  /**
   * 検査依頼サービス.
   */
  @Autowired
  private RadRequestService radRequestService;

  @Autowired
	LogService logService;
  /**
   * 患者情報サービス.
   */
  @Autowired
  private PatInfoService patInfoService;
  //add FNSI-患者が死亡した後、検査依頼を削除します 劉全航 start
  @Autowired
  private PatRadMainDao patRadMainDao;
  //add FNSI-患者が死亡した後、検査依頼を削除します 劉全航 end
  //mod FutreNetWeb+SI課題管理 no.6121 劉全航 start
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  //mod FutreNetWeb+SI課題管理 no.6121 劉全航 end
  @Autowired
  private PatRadPatternDao patRadPatternDao;

  @Autowired
  private FacilitySettingService facilitySettingService;

  @Autowired
  private JournalService journalService;

  // add FNSi5712アプリケーションログが出力しない 周 start
  @Autowired
  LogEventUtils logEventUtils;
  // add FNSi5712アプリケーションログが出力しない 周 end
  // add 10553 連携イベント発生部分不正 関 start
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  // add 10553 連携イベント発生部分不正 関 end
  // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
  @Autowired
  private PatMainDao patMainDao;
  // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end

  /**
   * 患者経過総合ビューア取得用
   * @param pat_id 患者ID
   * @param date_from 表示開始日(YYYYMMDD)
   * @param date_to 表示終了日(YYYYMMDD)
   * @param facility_cd 施設コード
   * @return 検査結果
   */
  @PostMapping("/TreatDateList/{pat_id}/{date_from}/{date_to}")
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  public ResponseEntity<List<PatRadMain>> getPatRadMainTreatDateList(
      @PathVariable int pat_id,
      @PathVariable String date_from,
      @PathVariable String date_to,
      @RequestBody Map<String, Object> requestBody
      ) throws Exception
  {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.RAD + "/TreatDateList/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, date_from, date_to));
    // add FNSi5712アプリケーションログが出力しない 周 end
    String dateFrom = ((null != date_from) && (false == "".equals(date_from))) ? date_from.replaceAll("-", "") : null;
    String dateTo = ((null != date_to) && (false == "".equals(date_to))) ? date_to.replaceAll("-", "") : null;
    Integer patShareMode = Integer.parseInt(requestBody.get("patShareMode").toString());
    // List<PatRadMain> listRet = radRequestService.FindPatRadMainByDateCd(pat_id, dateFrom, dateTo);
    List<PatRadMain> listRet = radRequestService.FindPatRadMainByDateCd(pat_id, dateFrom, dateTo, patShareMode);
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, date_from, date_to));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(listRet, HttpStatus.OK);
  }
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  // add FNSI-放射線検査の表示の修正 楊 start

  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  /**
   * 患者経過総合ビューア取得用
   * @param pat_id 患者ID
   * @param date_from 表示開始日(YYYYMMDD)
   * @param date_to 表示終了日(YYYYMMDD)
   * @param facility_cd 施設コード
   * @return 検査結果
   */
  @PostMapping("/TreatDateListByIsOrder/{pat_id}/{date_from}/{date_to}")
  public ResponseEntity<List<PatRadMain>> getPatRadMainByIsOrderTreatDateList(
    @PathVariable int pat_id,
    @PathVariable String date_from,
    @PathVariable String date_to
  ) throws Exception
  {
    String mappingUrl = Uri.RAD + "/TreatDateListByIsOrder/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, date_from, date_to));
    String dateFrom = ((null != date_from) && (false == "".equals(date_from))) ? date_from.replaceAll("-", "") : null;
    String dateTo = ((null != date_to) && (false == "".equals(date_to))) ? date_to.replaceAll("-", "") : null;
    List<PatRadMain> listRet = radRequestService.FindPatRadMainByIsOrder(pat_id, dateFrom, dateTo);
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, date_from, date_to));
    return new ResponseEntity<>(listRet, HttpStatus.OK);
  }
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
  /**
   * 放射線検査前回検査日取得
   * @param pat_id 患者ID
   * @param date_from 表示開始日(YYYYMMDD)
   * @return 前回放射線検査結果のResponse
   * @throws Exception Exception
   */
  @PostMapping("/TreatDateList/{pat_id}/{date_from}")
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  public ResponseEntity<?> getPatRadMainLastDate(
    @PathVariable long pat_id,
    @PathVariable String date_from,
    @RequestBody Map<String, Object> requestBody
  ) throws Exception
  {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.RAD + "/TreatDateList/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, date_from));
    // add FNSi5712アプリケーションログが出力しない 周 end
    String dateFrom = ((null != date_from) && (false == "".equals(date_from))) ? date_from.replaceAll("-", "") : null;
    Integer patShareMode = Integer.parseInt(requestBody.get("patShareMode").toString());
    // PatRadMain response = radRequestService.FindPatRadMainLastDateByDateCd(pat_id, dateFrom);
    PatRadMain response = radRequestService.FindPatRadMainLastDateByDateCd(pat_id, dateFrom, patShareMode);
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, date_from));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  // add FNSI-放射線検査の表示の修正 楊 end

  @PutMapping("/updateRegRadDate")
  /**
   * 透析予定日変更時、放射線検査依頼日追従
   * @param params 患者ID,変更前日付,変更後日付
   */
  public ResponseEntity<Void> updateRegRadDate(@RequestBody Map<String,String> params) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.RAD + "/updateRegRadDate";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(params));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      radRequestService.updateRegRadDate(params);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(params));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_RAD_REQUEST, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @PutMapping("/updateIsDel")
  /**
   * 透析予定日変更時、放射線検査依頼削除
   * @param params 患者ID,日付
   */
  public ResponseEntity<Void> updateIsDel(@RequestBody Map<String,String> params) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.RAD + "/updateIsDel";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(params));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      radRequestService.updateIsDel(params);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(params));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_RAD_REQUEST, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 放射線検査結果のデータを取得する.
   * @return 検査結果
   */
  @PostMapping("/radRequest")
  public ResponseEntity<?> getExamRequestList(
      @RequestBody RadRequest reqData,
      @AuthenticationPrincipal NtssUser ntssUser
      ) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.RAD + "/radRequest";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(reqData, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    //mod #12462 患者情報共有 zrx start
//    final RadRequestResponse radRequestResponse = radRequestService.createRadRequestResponse(reqData.getPatIdList(), reqData.getStartDate(), ntssUser.getFacilityCd());
    final RadRequestResponse radRequestResponse = radRequestService.createRadRequestResponse(
      reqData.getPatIdList(), reqData.getStartDate(), ntssUser.getFacilityCd(), reqData.getPatientShareMode());
    //mod #12462 患者情報共有 zrx end
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(reqData, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(radRequestResponse, HttpStatus.OK);
  }


  /**
   * 検査依頼 保存処理.
   *
   * @param masterName マスタ物理名称
   * @param request    マスタデータ更新のrequest
   * @param ntssUser   NTSS認証ユーザー
   * @return
   */
  @PutMapping("/radRequest/save")
  public ResponseEntity<?> updatePatRadMainRequest(
      @RequestBody SaveRadRequest request,
      @AuthenticationPrincipal NtssUser ntssUser
      ) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.RAD + "/radRequest/save";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(request, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end

    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
    List<Long> patIds = new ArrayList<>();
    if (!CollectionUtils.isEmpty(request.getPatRadPatternList())) {
      patIds = request.getPatRadPatternList().stream().map(PatRadPattern::getPatId).toList();
    }
    List<PatMain> patMains = patMainDao.selectByIdList(patIds);
    // スケジュール延長処理中の場合、予定作成を中止する
    List<Long> schExtPatIds = patMains.stream().filter(p -> ("1").equals(p.getSch_ext_status())).map(PatMain::getPat_id).toList();
    if (!CollectionUtils.isEmpty(schExtPatIds)) {
      JSONObject msgJson = new JSONObject("{}");
      msgJson.put("msgCd", 22020004);
      return new ResponseEntity<>(msgJson.toString(), HttpStatus.OK);
    }
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end

    try {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(request, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
      List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
      // add 10553 連携イベント発生部分不正 関 start
      List<Long> patIdList = new ArrayList<>();
      List<PatPersonalMain> listPats = new ArrayList<>();
      // add 10553 連携イベント発生部分不正 関 end
      boolean response = false;
      if (request.getPatRadMainList() != null && request.getPatRadMainList().size() > 0) {
        //#add 10125 検査予定に関する連携イベント作成不備 zrx start
        response = radRequestService.updateMasterData(request.getPatRadMainList(), ntssUser.getFacilityCd(), ntssUser.getUserId(), request.getPatRadPatternList(), request.getPatExtInfoList());
        //#add 10125 検査予定に関する連携イベント作成不備 zrx end
        // 一般撮影検査依頼一覧画面
        if (request.getIsRadDetail() != null && "0".equals(request.getIsRadDetail())) {
          // add 10553 連携イベント発生部分不正 関 start
          patIdList = request.getPatRadMainList().stream()
            .filter(obj -> Objects.nonNull(obj.get("patId")) && !obj.get("patId").isEmpty())
            .map(obj -> Long.parseLong(obj.get("patId")))
            .collect(Collectors.toList());
          if (patIdList.size() >0) {
            listPats = patPersonalMainDao.selectByIdList(patIdList);
          }
          // add 10553 連携イベント発生部分不正 関 end
          for (Map<String, String> requestJournal : request.getPatRadMainList()) {

            // 患者放射線検査を取得
            PatRadMain patRadMain = new PatRadMain();
            if (requestJournal.get("radResultCd") != null) {
              patRadMain = patRadMainDao.selectPatRadMain(Long.parseLong(requestJournal.get("radResultCd")));
            }

            JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
            payload.setFacilityCd(ntssUser.getFacilityCd());
            payload.setCoopCd("rad_ord");
            payload.setCoopCdIndex("");
            payload.setDirection("S");
            payload.setAnaResult("0");
            payload.setCoopResult("0");
            if (requestJournal.get("patId") != null) {
              payload.setPatId(Long.valueOf(requestJournal.get("patId")));
              // add 10553 連携イベント発生部分不正 関 start
              if (listPats.size() > 0) {
                List<PatPersonalMain> patPersonalMainList =  listPats.stream().filter(obj -> obj.getPat_id().equals(payload.getPatId()))
                  .distinct().collect(Collectors.toList());
                if (patPersonalMainList.size() > 0) {
                  payload.setHospPatId(patPersonalMainList.get(0).getHosp_pat_id());
                }
              }
              // add 10553 連携イベント発生部分不正 関 end
            }
            if (requestJournal.get("ordNo") != null) {
              payload.setOrdNo(Long.valueOf(requestJournal.get("ordNo")));
            }
            if (requestJournal.get("regRadDate") != null) {
              String regRadDate = requestJournal.get("regRadDate");
              if (regRadDate.length() > 8) {
                regRadDate = regRadDate.substring(0, 10).replaceAll("-", "");
              }
              payload.setBaseDate(regRadDate);
            }
            payload.setUserId(ntssUser.getUserId());
            if ("1".equals(requestJournal.get("operation"))) {
              payload.setCrud("C");
              payload.setOpeCd("022001");
              //#add 10125 検査予定に関する連携イベント作成不備 zrx start
              if (requestJournal.get("radResultCd") != null) {
                payload.setOrdNo(Long.valueOf(requestJournal.get("radResultCd")));
              }
              //#add 10125 検査予定に関する連携イベント作成不備 zrx end
            } else if ("2".equals(requestJournal.get("operation")) && "0".equals(requestJournal.get("isDel"))) {
              payload.setCrud("U");
              payload.setOpeCd("022002");
              if (requestJournal.get("radResultCd") != null) {
                payload.setOrdNo(Long.valueOf(requestJournal.get("radResultCd")));
              }
              // 予定を再設定する場合はsys_coop_journalに`C`レコードを挿入する
              ObjectMapper mapper = new ObjectMapper();
              if (mapper.readTree(patRadMain.getOrderRadSetInfo()).isEmpty()) {
                payload.setCrud("C");
                payload.setOpeCd("022001");
              }
            } else {
              payload.setCrud("D");
              payload.setOpeCd("022004");
              if (requestJournal.get("radResultCd") != null) {
                payload.setOrdNo(Long.valueOf(requestJournal.get("radResultCd")));
              }
            }
            ctlNoList.add(payload);
          }
          // 一般撮影検査依頼画面
        } else if (request.getIsRadDetail() != null && "1".equals(request.getIsRadDetail())) {
          // add 10553 連携イベント発生部分不正 関 start
          patIdList = request.getPatRadMainList().stream()
            .filter(obj -> Objects.nonNull(obj.get("patId")) && !obj.get("patId").isEmpty())
            .map(obj -> Long.parseLong(obj.get("patId")))
            .collect(Collectors.toList());
          if (patIdList.size() >0) {
            listPats = patPersonalMainDao.selectByIdList(patIdList);
          }
          // add 10553 連携イベント発生部分不正 関 end
          for (Map<String, String> requestJournal : request.getPatRadMainList()) {

            // 患者放射線検査を取得
            PatRadMain patRadMain = new PatRadMain();
            if (requestJournal.get("radResultCd") != null) {
              patRadMain = patRadMainDao.selectPatRadMain(Long.parseLong(requestJournal.get("radResultCd")));
            }

            JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
            payload.setFacilityCd(ntssUser.getFacilityCd());
            payload.setCoopCd("rad_ord");
            payload.setCoopCdIndex("");
            payload.setDirection("S");
            payload.setAnaResult("0");
            payload.setCoopResult("0");
            if (requestJournal.get("patId") != null) {
              payload.setPatId(Long.valueOf(requestJournal.get("patId")));
              // add 10553 連携イベント発生部分不正 関 start
              if (listPats.size() > 0) {
                List<PatPersonalMain> patPersonalMainList =  listPats.stream().filter(obj -> obj.getPat_id().equals(payload.getPatId()))
                  .distinct().collect(Collectors.toList());
                if (patPersonalMainList.size() > 0) {
                  payload.setHospPatId(patPersonalMainList.get(0).getHosp_pat_id());
                }
              }
              // add 10553 連携イベント発生部分不正 関 end
            }
            if (requestJournal.get("ordNo") != null) {
              payload.setOrdNo(Long.valueOf(requestJournal.get("ordNo")));
            }
            if (requestJournal.get("regRadDate") != null) {
              String regRadDate = requestJournal.get("regRadDate");
              if (regRadDate.length() > 8) {
                regRadDate = regRadDate.substring(0, 10).replaceAll("-", "");
              }
              payload.setBaseDate(regRadDate);
            }
            payload.setUserId(ntssUser.getUserId());
            if ("1".equals(requestJournal.get("operation"))) {
              payload.setCrud("C");
              payload.setOpeCd("022005");
              //#add 10125 検査予定に関する連携イベント作成不備 zrx start
              if (requestJournal.get("radResultCd") != null) {
                payload.setOrdNo(Long.valueOf(requestJournal.get("radResultCd")));
              }
              //#add 10125 検査予定に関する連携イベント作成不備 zrx end
            } else if ("2".equals(requestJournal.get("operation")) && "0".equals(requestJournal.get("isDel"))) {
              payload.setCrud("U");
              payload.setOpeCd("022006");
              if (requestJournal.get("radResultCd") != null) {
                payload.setOrdNo(Long.valueOf(requestJournal.get("radResultCd")));
              }
              // 予定を再設定する場合はsys_coop_journalに`C`レコードを挿入する
              ObjectMapper mapper = new ObjectMapper();
              if (mapper.readTree(patRadMain.getOrderRadSetInfo()).isEmpty()) {
                payload.setCrud("C");
                payload.setOpeCd("022005");
              }
            } else {
              payload.setCrud("D");
              payload.setOpeCd("022008");
              if (requestJournal.get("radResultCd") != null) {
                payload.setOrdNo(Long.valueOf(requestJournal.get("radResultCd")));
              }
            }
            ctlNoList.add(payload);
          }
        }
      /* add by chamaojia 2025-07-03 [11994] supplementary processing logic --start */
      } else {
        response = radRequestService.updateMasterData(request.getPatRadMainList(), ntssUser.getFacilityCd(), ntssUser.getUserId(), request.getPatRadPatternList(), request.getPatExtInfoList());
      }
      /* add by chamaojia 2025-07-03 [11994] supplementary processing logic --end */

      //#del 10125 検査予定に関する連携イベント作成不備 zrx start
//      response = radRequestService.updateMasterData(request.getPatRadMainList(), ntssUser.getFacilityCd(), ntssUser.getUserId(), request.getPatRadPatternList(), request.getPatExtInfoList());
      //#del 10125 検査予定に関する連携イベント作成不備 zrx end
      if (!CollectionUtils.isEmpty(ctlNoList)){
        journalService.callCreateJournalForCtrNo(ctlNoList);
      }
      // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
      // 戻り値用
      // mod by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
      //return new ResponseEntity<>(
      //    radRequestService.updateMasterData(request.getPatRadMainList(), ntssUser.getFacilityCd(), ntssUser.getUserId(), request.getPatRadPatternList(), request.getPatExtInfoList()),
      //    HttpStatus.OK);
      return new ResponseEntity<>(response, HttpStatus.OK);
      // mod by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
    } catch (Exception e) {
      // 更新処理ができなかった場合
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_RAD_REQUEST, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
  }

  /**
  * 放射線検査セットマスタデータ取得.
  *
  * @param facilityCd 取得対象の施設コード
  * @return 放射線検査セットマスタデータのResponse
  *
  */
  @GetMapping("/radRequest/radSet/{facilityCd}")
  public ResponseEntity<?> getRadSetList(@PathVariable String facilityCd) {

    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.RAD + "/radRequest/radSet/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : RadSet");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_RAD_REQUEST, SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      List<MstRadSet> response = radRequestService.selectRadSetList(facilityCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_RAD_REQUEST, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 患者IDリストから患者情報を取得する
   * @param Map<String, String> payload 患者IDリスト
   * @return
   * @throws Exception
   */
  @PostMapping("/radRequest/getPatInfoList")
  public ResponseEntity<?> getPatInfoList(
      @RequestBody Map<String, String> payload
    ) throws Exception
    {
      // add FNSi5712アプリケーションログが出力しない 周 start
      String mappingUrl = Uri.RAD + "/radRequest/getPatInfoList";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
        BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      List<Long> patIdList = this.getLongValueList(payload.get("patIdList"));
      List<PatMain> response = patInfoService.getPatSchExtEndDateList(patIdList);

      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end

      // レスポンス生成
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_RAD_REQUEST, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   *add FNSI-患者が死亡した後、検査依頼を削除します 劉全航 start
   * @param payload
   * @return overDeadlineCount 締切日を過ぎていて削除されなかった予定の件数
   */
  @PostMapping("/deletePatRadRequest")
  public ResponseEntity<?> deleteDeadPatRequest(@RequestBody Map<String, Object> payload, @AuthenticationPrincipal NtssUser ntssUser){
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.RAD + "/deletePatRadRequest";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    int overDeadlineCount = 0;
    // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
    ArrayList<Map<String, String>> moveOutDateMapList = CollectionUtils.isEmpty(Collections.singleton(payload.get("move_out_date")))
            ? new ArrayList<>() : (ArrayList<Map<String, String>>) payload.get("move_out_date");
    if(!CollectionUtils.isEmpty(moveOutDateMapList)){
      Long patId = Long.parseLong(Objects.isNull(payload.get("patId")) ? "0" : payload.get("patId").toString());
      String facilityCd = Objects.isNull(payload.get("facilityCd")) ? "0" : payload.get("facilityCd").toString();
      for(Map<String, String> moveOutDate : moveOutDateMapList) {
        try {
//          String dateFrom = payload.get("deleteDate").toString();
//          String indStartDate = payload.get("ind_start_date").toString();
//          String indEndDate = payload.get("ind_end_date").toString();
          String indStartDate = moveOutDate.get("ind_start_date");
          String indEndDate = moveOutDate.get("ind_end_date");
          // 死亡/転出、離脱、移植、通院拒否・不明日以降の予定データを取得
//          List<PatRadMain> radList = patRadMainDao.selectDeleteTarget(patId, facilityCd, dateFrom);
          List<PatRadMain> radList = patRadMainDao.selectDeleteTarget(patId, facilityCd, indStartDate, indEndDate);
          if (!CollectionUtils.isEmpty(radList)) {
            // 一般撮影検査依頼変更締切り有無 1016
            String radChangeOnOffWithOrder = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.RAD_CHANGE_ON_OFF_WITH_ORDER);
            // 締切りを過ぎているデータを削除対象から除外する
            if (radChangeOnOffWithOrder.equals("1")) {
              // 放射線検査依頼変更締切り日数 1013
              String radScheduleChangeLimitDay = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.RAD_SCHEDULE_CHANGE_LIMIT_DAY);
              // 放射線検査依頼変更締切り時間 1014
              String radScheduleChangeLimitTime = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.RAD_SCHEDULE_CHANGE_LIMIT_TIME);
              // 初期値の"0000"はエラーになる為補正
              if (radScheduleChangeLimitTime.equals("0000")) {
                radScheduleChangeLimitTime = "00:00";
              }
              int minutes = Integer.valueOf(radScheduleChangeLimitTime.substring(0, 2)) * 60 + Integer.valueOf(radScheduleChangeLimitTime.substring(3, 5));
              Long aLong = Long.valueOf(minutes);
              // 現在日に、締切り日数、時間を加算
              LocalDateTime nowLdt = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd").format(new Date()) + " 00:00:00").toLocalDateTime();
              LocalDateTime deadlineLdt = nowLdt.plusDays(Long.valueOf(radScheduleChangeLimitDay)).plusMinutes(aLong);
              String deadlineDate = Timestamp.valueOf(deadlineLdt).toString();

              boolean timeOverFlg = false;
              String nowTime = new SimpleDateFormat("HH:mm:ss").format(new Date());
              if (nowTime.compareTo(deadlineDate.substring(11, 19)) > 0) {
                // 現在時刻が、締切り時間を過ぎていた場合、現在日 + 締切り日数 の日付の予定を、締め切りを過ぎたものとして扱う
                timeOverFlg = true;
              }

              // 締切りを過ぎているレコードをリストに取得する
              List<PatRadMain> overList = new ArrayList<>();
              SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
              String deadlineDay = deadlineDate.substring(0, 10);
              for (PatRadMain rad : radList) {
                String regRadDate = sdf.format(rad.getRegRadDate());
                if (timeOverFlg) {
                  if (deadlineDay.compareTo(regRadDate) >= 0) {
                    overList.add(rad);
                  }
                } else {
                  if (deadlineDay.compareTo(regRadDate) > 0) {
                    overList.add(rad);
                  }
                }
              }
              // 締切りを過ぎているレコードを除外する
              for (PatRadMain idx : overList) {
                radList.remove(idx);
              }
              // 締切りを過ぎていたレコード件数を応答に含める
//            overDeadlineCount = overList.size();
              overDeadlineCount += overList.size();
            }

            // 削除対象の rad_result_cd リストを作成
            List<Long> radResultCdList = radList.stream().map(item -> item.getRadResultCd()).distinct().collect(Collectors.toList());
            // 削除を実施
            Long upStaff = ntssUser.getUserId();
            Long indUserId = Long.parseLong(Objects.isNull(payload.get("indUserId")) ? ntssUser.getUserId().toString() : payload.get("indUserId").toString());
            int i = patRadMainDao.deleteRadRequestByPatId(facilityCd, patId, upStaff, indUserId, radResultCdList);
            // 削除完了後の処理
            if (i > 0) {
              SimpleDateFormat baseDateFormat = new SimpleDateFormat("yyyyMMdd");
              String type = payload.get("type").toString();
              String opeCd = type.equals("death") ? "031004" : "007011";
              // 連携イベントの登録処理
              for (PatRadMain rad : radList) {
                // rad_result_cd 毎に連携イベントの登録処理を実施する
                JournalCreateRequestPayload sendPayload = new JournalCreateRequestPayload();
                sendPayload.setFacilityCd(facilityCd);
                sendPayload.setCoopCd("rad_ord");
                sendPayload.setCrud("D");
                sendPayload.setPatId(patId);
                sendPayload.setOrdNo(rad.getRadResultCd());
                sendPayload.setBaseDate(baseDateFormat.format(rad.getRegRadDate()));
                sendPayload.setOpeCd(opeCd);
                // mod #10553 ②死亡、転出、一時転出のスケジュール(治療、検査依頼、一般撮影検査依頼)の削除に合わせて連携イベントを発生させるように修正が必要 start
                // sendPayload.setUserId(indUserId);
                sendPayload.setUserId(ntssUser.getUserId());
                // mod #10553 ②死亡、転出、一時転出のスケジュール(治療、検査依頼、一般撮影検査依頼)の削除に合わせて連携イベントを発生させるように修正が必要 end
                journalService.callCreateJournalForPayload(sendPayload);
              }
              // 削除処理が実施された場合に、パターンの削除処理も実施
              // mod #10553 ②死亡、転出、一時転出のスケジュール(治療、検査依頼、一般撮影検査依頼)の削除に合わせて連携イベントを発生させるように修正が必要 start
              if("99991231".equals(indEndDate)){
//            patRadPatternDao.updateIsDelByPatIdAndRadTo(patId, facilityCd, dateFrom, ntssUser.getUserId(), indUserId);
                patRadPatternDao.updateIsDelByPatIdAndRadTo(patId, facilityCd, indStartDate, indEndDate, ntssUser.getUserId(), indUserId);
              }
              // mod #10553 ②死亡、転出、一時転出のスケジュール(治療、検査依頼、一般撮影検査依頼)の削除に合わせて連携イベントを発生させるように修正が必要 end
            }
          }
        }catch(Exception e){
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
        }
      }
    }
    // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_RAD_REQUEST,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(overDeadlineCount, HttpStatus.OK);
  }
  /**
   * add FNSI-患者が死亡した後、検査依頼を削除します 劉全航 end
   */

  /**
   * JSON配列データから値を取得し、Long型配列データを返す
   * @param stringList
   * @return Long型配列データ
   */
  private List<Long> getLongValueList(String stringList)
  {
    JSONArray json;
    List<Long> valueArry = new ArrayList<Long>();
    try {
      if (null == stringList) return valueArry;
      json = new JSONArray(stringList);
      // 選択された値を配列に格納
      for (int i = 0; i < json.length(); i++) {
        int intDate = Integer.parseInt(json.get(i).toString());
        long l = intDate;
        valueArry.add(l);
      }
    } catch (JSONException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_RAD_REQUEST, SERVICE_NAME.FNSI, null);
      return null;
    }
    return valueArry;
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
