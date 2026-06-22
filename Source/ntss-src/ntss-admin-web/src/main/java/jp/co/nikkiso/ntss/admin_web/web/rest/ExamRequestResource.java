package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.mstSynchro.MstSynchroService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MntRecalcQueDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MntRecalcQue;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatExamPattern;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatPersonalMainData;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.StringUtils;
import org.springframework.util.CollectionUtils;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.exam.ExamRequest;
import jp.co.nikkiso.ntss.admin_web.request.exam.SaveExamRequest;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.response.exam.ExamRequestResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.exam.ExamRequestService;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.PatInfoService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;

import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.access.FacilityAccessService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;


/**
 * 検査依頼（exam-request）系のリソースクラス
 */
@RestController
@RequestMapping(Uri.EXAM)
@Slf4j
public class ExamRequestResource {

  /**
   * 検査依頼サービス.
   */
  @Autowired
  private ExamRequestService examRequestService;

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  /**
   * 患者情報サービス.
   */
  @Autowired
  private PatInfoService patInfoService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  @Autowired
  private FacilityAccessService facilityAccessService;

  // wp アプリケーションログの適正化 Add End

  //add FNSI-患者が死亡した後、検査依頼を削除します 劉全航 start
  @Autowired
  private PatExamMainDao patExamMainDao;
  //add FNSI-患者が死亡した後、検査依頼を削除します 劉全航 start

  //mod FutreNetWeb+SI課題管理 no.6121 劉全航 start
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  //mod FutreNetWeb+SI課題管理 no.6121 劉全航 end

  @Autowired
  private PatExamPatternDao patExamPatternDao;
  @Autowired
  private MstSynchroService mstSynchroService;
  @Autowired
  private FacilitySettingService facilitySettingService;

  @Autowired
  private JournalService journalService;
  // add #7523 「対象患者の並び順が不正」について、対応する。 dengshen start
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  // add #7523 「対象患者の並び順が不正」について、対応する。 dengshen end
  // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
  @Autowired
  private PatMainDao patMainDao;
  // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
  @Autowired
  private MntRecalcQueDao mntRecalcQueDao;
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

  /**
   * 患者経過総合ビューア取得用
   * @param pat_id 患者ID
   * @param date_from 表示開始日(YYYYMMDD)
   * @param date_to 表示終了日(YYYYMMDD)
   * @return 検査結果
   */
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  @PostMapping("/TreatDateList/{pat_id}/{date_from}/{date_to}")
  public ResponseEntity<List<PatExamMain>> getPatExamMainTreatDateList(
          @PathVariable int pat_id,
          @PathVariable String date_from,
          @PathVariable String date_to,
          @RequestBody Map<String, Object> requestBody
  ) throws Exception
  {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXAM + "/TreatDateList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
            Arrays.asList(pat_id, date_from,date_to));
    // wp アプリケーションログの適正化 Add End
    String dateFrom = ((null != date_from) && (false == "".equals(date_from))) ? date_from.replaceAll("-", "") : null;
    String dateTo = ((null != date_to) && (false == "".equals(date_to))) ? date_to.replaceAll("-", "") : null;
    Integer patShareMode = Integer.parseInt(requestBody.get("patShareMode").toString());
    List<PatExamMain> listRet = examRequestService.FindPatExamMainByDateCd(pat_id, dateFrom, dateTo, patShareMode);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, null,
            Arrays.asList(pat_id, date_from,date_to));
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(listRet, HttpStatus.OK);
  }
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */

  //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  /**
   * 患者経過総合ビューア取得用
   * @param pat_id 患者ID
   * @param date_from 表示開始日(YYYYMMDD)
   * @param date_to 表示終了日(YYYYMMDD)
   * @return 検査結果
   */
  @PostMapping("/TreatDateListByIsOrder/{pat_id}/{date_from}/{date_to}")
  public ResponseEntity<List<PatExamMain>> getPatExamMainByIsOrderTreatDateList(
    @PathVariable int pat_id,
    @PathVariable String date_from,
    @PathVariable String date_to
  ) throws Exception
  {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXAM + "/TreatDateListByIsOrder";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(pat_id, date_from,date_to));
    // wp アプリケーションログの適正化 Add End
    String dateFrom = ((null != date_from) && (false == "".equals(date_from))) ? date_from.replaceAll("-", "") : null;
    String dateTo = ((null != date_to) && (false == "".equals(date_to))) ? date_to.replaceAll("-", "") : null;
    List<PatExamMain> listRet = examRequestService.FindPatExamMainByIsOrder(pat_id, dateFrom, dateTo);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(pat_id, date_from,date_to));
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(listRet, HttpStatus.OK);
  }
  //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start

  // add FNSI-患者検査結果取得用 杜 start
  /**
   * 患者検査結果取得用
   * @param facility_cd 施設コード
   * @return 患者検査結果
   */
  @GetMapping("/TreatDateList/{facility_cd}")
  public ResponseEntity<List<PatExamMain>> getPatExamMainDateListByFacilityCd(
          @PathVariable String facility_cd
  ,
          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
          @AuthenticationPrincipal NtssUser ntssUser
          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws Exception
  {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facility_cd != null && !facility_cd.isEmpty() &&
          !facility_cd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facility_cd=" + facility_cd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXAM + "/TreatDateList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, facility_cd,
            null);
    // wp アプリケーションログの適正化 Add End
    List<PatExamMain> listRet = examRequestService.FindPatExamMainByFacilityCd(facility_cd);
    // add #7523 「対象患者の並び順が不正」について、対応する。 dengshen start
    List<PatExamMain> listRetResault = new ArrayList<>();
    List<String> facilityCdList = new ArrayList<>();
    facilityCdList.add(facility_cd);
    List<PatPersonalMain> patList = patPersonalMainDao.selectAll(facilityCdList);
    for (PatPersonalMain pat: patList) {
      for (PatExamMain listRetItem : listRet) {
        if (pat.getPat_id().equals(Long.valueOf(listRetItem.getPatId()))) {
          listRetResault.add(listRetItem);
          break;
        }
      }
    }
    // add #7523 「対象患者の並び順が不正」について、対応する。 dengshen end
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, facility_cd,
            null);
    // wp アプリケーションログの適正化 Add End
    // mod #7523 「対象患者の並び順が不正」について、対応する。 dengshen start
    // return new ResponseEntity<>(listRet, HttpStatus.OK);
    return new ResponseEntity<>(listRetResault, HttpStatus.OK);
    // mod #7523 「対象患者の並び順が不正」について、対応する。 dengshen end
  }

  // 検査再計算依頼キューテーブル取得用 杜 start
  /**
   * 検査再計算依頼キューテーブル取得用
   * @param facility_cd 施設コード
   * @return 検査再計算依頼キューテーブルリスト
   */
  @GetMapping("/MntRecalcQue/{facility_cd}")
  public ResponseEntity<List<MntRecalcQue>> getMntRecalcQueByFacilityCd(
          @PathVariable String facility_cd
  ,
          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
          @AuthenticationPrincipal NtssUser ntssUser
          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws Exception
  {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facility_cd != null && !facility_cd.isEmpty() &&
          !facility_cd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facility_cd=" + facility_cd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXAM + "/MntRecalcQue";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, facility_cd,
            null);
    // wp アプリケーションログの適正化 Add End

    List<MntRecalcQue> listRet = examRequestService.FindMntRecalcQueByFacilityCd(facility_cd);
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, facility_cd,
            null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(listRet, HttpStatus.OK);
  }

  // 検査再計算依頼キューテーブル追加 杜 start
  /**
   * 検査再計算依頼キューテーブル追加
   * param params
   */
  @PostMapping("/createMntRecalcQue")
  public ResponseEntity<Void> createMntRecalcQue(@RequestBody Map<String,String> params,
                                                 // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                 @AuthenticationPrincipal NtssUser ntssUser
                                                 // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        String facilityCd = params.get("facilityCd");
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXAM + "/createMntRecalcQue";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
            params);
    // wp アプリケーションログの適正化 Add End

    try {
      // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add start
      String facilityCd = params.get("facilityCd");
      if (!StringUtils.hasLength(facilityCd)) {
        String content = params.get("content");
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST,
          AFTER_LOG_FLG_INFO, mappingUrl, facilityCd, Arrays.asList(facilityCd, content));
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
      // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add end

      examRequestService.createMntRecalcQue(params);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, null,
              params);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_REQUEST, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  // 検査再計算依頼キューテーブル更新 杜 start
  /**
   * 検査再計算依頼キューテーブル更新
   * @param params SEQ,ステータス,施設コード,依頼日時,完了日時,内容,進捗,依頼者id,更新者ID
   */
  @PostMapping("/updateMntRecalcQue")
  public ResponseEntity<Void> updateMntRecalcQue(@RequestBody Map<String,String> params,
                                                 // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                 @AuthenticationPrincipal NtssUser ntssUser
                                                 // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
      if(!ntssUser.isNkkAdminUser()) {
        long recalcQueCd = Long.parseLong(params.get("recalcQueCd"));
        MntRecalcQue mntRecalcQue = mntRecalcQueDao.selectById(recalcQueCd);
        if (mntRecalcQue != null && mntRecalcQue.getFacilityCd() != null &&
          !mntRecalcQue.getFacilityCd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mntRecalcQue.getFacilityCd() + " " + "recalcQueCd=" + recalcQueCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXAM + "/updateMntRecalcQue";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
            params);
    // wp アプリケーションログの適正化 Add End
    try {
      examRequestService.updateMntRecalcQue(params);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, null,
              params);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  // add FNSI-検体検査の表示の修正 楊 start
  /**
   * 検査予定前回検査日取得
   * @param pat_id 患者ID
   * @param date_from 表示開始日(YYYYMMDD)
   * @return 前回検査結果
   * @throws Exception Exception
   */
   /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  @PostMapping("/TreatDateList/{pat_id}/{date_from}")
  public ResponseEntity<?> getExamMainDataLastDate(
          @PathVariable int pat_id,
          @PathVariable String date_from,
          @RequestBody Map<String, Object> requestBody
  ,
          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
          @AuthenticationPrincipal NtssUser ntssUser
          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws Exception
  {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXAM + "/TreatDateList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
            Arrays.asList(pat_id, date_from));
    // wp アプリケーションログの適正化 Add End

    String dateFrom = ((null != date_from) && (false == "".equals(date_from))) ? date_from.replaceAll("-", "") : null;
    Integer patShareMode = Integer.parseInt(requestBody.get("patShareMode").toString());
    PatExamMain response = examRequestService.FindPatExamMainLastDateByDateCd(pat_id, dateFrom, patShareMode);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, null,
            Arrays.asList(pat_id, date_from));
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  // add FNSI-検体検査の表示の修正 楊 end

  /**
   * 検査結果マスタのデータを取得する.
   * @return 検査結果
   */
  @PostMapping("/examRequest")
  public ResponseEntity<?> getExamRequestList(
          //mod #12663 #12665 securify】SQLインジェクション(High) まとめ zrx start
          @Valid @RequestBody ExamRequest reqData,
          //mod #12663 #12665 securify】SQLインジェクション(High) まとめ zrx end
          @AuthenticationPrincipal NtssUser ntssUser
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
    if(!ntssUser.isNkkAdminUser() && !CollectionUtils.isEmpty(reqData.getPatIdList())) {
      for (Long patId : reqData.getPatIdList()) {
        if (patId == null) {
          continue;
        }
        long count = patMainDao.countByPatIdAndFacilityCd(patId, ntssUser.getFacilityCd());
        if (count == 0) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "pat_id=" + patId + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!患者は存在しない", HttpStatus.FORBIDDEN);
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end

    String mappingUrl = Uri.EXAM + "/examRequest";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, null, null);
    try{
      //mod #12462 患者情報共有 zrx start
//    final ExamRequestResponse examRequestResponse = examRequestService.createExamRequestResponse(reqData.getPatIdList(), reqData.getStartDate(), reqData.getEndDate(), ntssUser.getFacilityCd());
      final ExamRequestResponse examRequestResponse = examRequestService.createExamRequestResponse(
        reqData.getPatIdList(), reqData.getStartDate(), reqData.getEndDate(), ntssUser.getFacilityCd(), reqData.getPatientShareMode());

      //mod #12462 患者情報共有 zrx end
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, null, null);
    return new ResponseEntity<>(examRequestResponse, HttpStatus.OK);
    } catch(Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang end
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 検査依頼 保存処理.
   *
   * @param request    マスタデータ更新のrequest
   * @param ntssUser   NTSS認証ユーザー
   * @return
   */
  @PutMapping("/examRequest/save")
  public ResponseEntity<?> updatePatExamMainRequest(
          @RequestBody SaveExamRequest request,
          @AuthenticationPrincipal NtssUser ntssUser
  ) throws Exception {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXAM + "/examRequest/save";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
            null);
    // wp アプリケーションログの適正化 Add End
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
    List<Long> patIds = new ArrayList<>();
    if (!CollectionUtils.isEmpty(request.getPatExamPatternList())) {
      patIds = request.getPatExamPatternList().stream().map(PatExamPattern::getPatId).toList();
    }
    List<PatMain> patMains = patMainDao.selectByIdList(patIds);
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      for (PatMain patMain : patMains) {
        if (patMain != null && patMain.getFacility_cd() != null && !patMain.getFacility_cd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facility_cd=" + patMain.getFacility_cd() + " " + "pat_id=" + patMain.getPat_id() + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    }

    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    // スケジュール延長処理中の場合、予定作成を中止する
    List<Long> schExtPatIds = patMains.stream().filter(p -> ("1").equals(p.getSch_ext_status())).map(PatMain::getPat_id).toList();
    if (!CollectionUtils.isEmpty(schExtPatIds)) {
      JSONObject msgJson = new JSONObject("{}");
      msgJson.put("msgCd", 22020004);
      return new ResponseEntity<>(msgJson.toString(), HttpStatus.OK);
    }
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
    try {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, null,
              null);
      // wp アプリケーションログの適正化 Add End

      //del 7322 exam_ord連携の出力グループ 20221116 zhaoqi start
      //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 start
//      List<Map<String, String>> patExamMainList = request.getPatExamMainList();
//      List<Map<String, String>> needToRemoveList = new LinkedList<>();
//      for(int i=0;i<patExamMainList.size();i++){
//        Map<String, String> patMap = patExamMainList.get(i);
//        String regOrderClass = patMap.get("regOrderClass");
//        String isDel = patMap.get("isDel");
//        if("0".equals(regOrderClass) && !"1".equals(isDel)){
//          needToRemoveList.add(patMap);
//        }
//      }
//      for(int i=0;i<needToRemoveList.size();i++){
//        Map<String, String> patMap = needToRemoveList.get(i);
//        String orderExamSetInfo = patMap.get("orderExamSetInfo");
//        String examOrderInfo = patMap.get("examOrderInfo");
//        JSONArray orderArray = new JSONArray(orderExamSetInfo);
//        JSONArray examArray = new JSONArray(examOrderInfo);
//        for(int j=0;j<orderArray.length();j++){
//          JSONObject orderExamSetInfoObject = orderArray.getJSONObject(j);
//          String orderNo = "";
//          if(orderExamSetInfoObject.get("no") != null){
//            orderNo = orderExamSetInfoObject.get("no").toString();
//          }
//          JSONArray newExamOrderInfoArray = new JSONArray();
//          for(int m=0;m<examArray.length();m++){
//            JSONObject examOrderInfoObject = examArray.getJSONObject(m);
//            String examNo = "";
//            if(examOrderInfoObject.get("no") != null){
//              examNo = examOrderInfoObject.get("no").toString();
//            }
//            if(orderNo.equals(examNo)){
//              newExamOrderInfoArray.put(examOrderInfoObject);
//            }
//          }
//
//          Map<String, String> newData = new HashMap<>();
//          Iterator it = patMap.entrySet().iterator();
//          while (it.hasNext()) {
//            Map.Entry entry = (Map.Entry) it.next();
//            String key = entry.getKey().toString();
//            newData.put(key, patMap.get(key));
//            JSONArray newOrderExamSetInfoArray = new JSONArray();
//            newOrderExamSetInfoArray.put(orderExamSetInfoObject);
//            newData.put("orderExamSetInfo", newOrderExamSetInfoArray.toString());
//            newData.put("examOrderInfo", newExamOrderInfoArray.toString());
//            newData.put("operation", "1");
//          }
//          patExamMainList.add(newData);
//        }
//      }
//      patExamMainList.removeAll(needToRemoveList);
      //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 end
      //del 7322 exam_ord連携の出力グループ 20221116 zhaoqi end
      // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
      List<MstExamSet>  phyclasslist =  examRequestService.selectExamsetByPhyOrdClass(ntssUser.getFacilityCd());
      Integer phyclass =  mstSynchroService.selectAllSysFunctionAdvanceds("A12",ntssUser.getFacilityCd());
      List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
      List<JournalCreateRequestPayload> ctlNoListphy = new ArrayList<>();
      // add 10553 連携イベント発生部分不正 関 start
      List<Long> patIdList = new ArrayList<>();
      List<PatPersonalMain> listPats = new ArrayList<>();
      // add 10553 連携イベント発生部分不正 関 end
      boolean response = false;
      if(phyclass == 1){
        // 検査依頼一覧画面
        if (request.getRequestJournalList() != null && request.getRequestJournalList().size() > 0) {

          //#add 10125 検査予定に関する連携イベント作成不備 zrx start
          response = examRequestService.updateMasterData(request.getRequestJournalList(), ntssUser.getFacilityCd(), ntssUser.getUserId(), request.getPatExamPatternList(), request.getPatExtInfoList());
          //#add 10125 検査予定に関する連携イベント作成不備 zrx end

          // add 10553 連携イベント発生部分不正 関 start
          patIdList = request.getRequestJournalList().stream()
            .filter(obj -> Objects.nonNull(obj.get("patId")) && !obj.get("patId").isEmpty())
            .map(obj -> Long.parseLong(obj.get("patId")))
            .collect(Collectors.toList());
          if (patIdList.size() >0) {
            listPats = patPersonalMainDao.selectByIdList(patIdList);
          }
          // add 10553 連携イベント発生部分不正 関 end
          for (Map<String, String> requestJournal : request.getRequestJournalList()) {
            Integer phyOrdclassheckonecopy = 0;
            Integer phyOrdclassheckonecopy1 = 0;
            String orderExamSetInfo = requestJournal.get("orderExamSetInfo");
            JSONArray orderArray = new JSONArray(orderExamSetInfo);
            Integer   orderArraylenth = orderArray.length();
            for (int i = 0; i < orderArray.length(); i++) {
              JSONObject orderExamSetInfoObject = orderArray.getJSONObject(i);
              for (int j = 0; j < phyclasslist.size(); j++)
                if (phyclasslist.get(j).getExamSetCd().toString().equals(orderExamSetInfoObject.get("set_cd").toString())) {
                  phyOrdclassheckonecopy = 1;
                  phyOrdclassheckonecopy1++;
                }
            }
            boolean phyordclassNull = requestJournal.containsKey("phyOrdClass");
            if (phyordclassNull &&  "1".equals(requestJournal.get("phyOrdClass"))
                    ||(!phyordclassNull && phyOrdclassheckonecopy == 1)) {
              JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
              requestJournal.get("orderExamSetInfo");
              requestJournal.get("orderExamSetInfo");
              payload.setFacilityCd(ntssUser.getFacilityCd());
              payload.setCoopCd("phy_ord");
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
              if (requestJournal.get("regExamDate") != null) {
                String regExamDate = requestJournal.get("regExamDate");
                if (regExamDate.length() > 8) {
                  regExamDate = regExamDate.substring(0, 10).replaceAll("-", "");
                }
                payload.setBaseDate(regExamDate);
              }
              payload.setUserId(ntssUser.getUserId());
              payload.setRegOrderClass(requestJournal.get("regOrderClass"));
              if ("1".equals(requestJournal.get("operation"))) {
                payload.setCrud("C");
                payload.setOpeCd("021011");
                // add 10553 連携イベント発生部分不正 関 start
                if (requestJournal.get("examMainCd") != null) {
                  payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
                }
                // add 10553 連携イベント発生部分不正 関 end
              } else if ("2".equals(requestJournal.get("operation")) && "0".equals(requestJournal.get("isDel"))) {
                payload.setCrud("U");
                payload.setOpeCd("021012");
                if (requestJournal.get("examMainCd") != null) {
                  payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
                }
              } else {
                payload.setCrud("D");
                payload.setOpeCd("021014");
                if (requestJournal.get("examMainCd") != null) {
                  payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
                }
              }
              ctlNoListphy.add(payload);
            }
            if((phyordclassNull && (requestJournal.get("phyOrdClass")==null)
                    ||(!phyordclassNull && phyOrdclassheckonecopy1 != orderArraylenth && orderArraylenth !=0)
            )){
              JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
              requestJournal.get("orderExamSetInfo");
              requestJournal.get("orderExamSetInfo");
              payload.setFacilityCd(ntssUser.getFacilityCd());
              payload.setCoopCd("exam_ord");
              payload.setCoopCdIndex("");
              payload.setDirection("S");
              payload.setAnaResult("0");
              payload.setCoopResult("0");
              if (requestJournal.get("patId") != null) {
                payload.setPatId(Long.valueOf(requestJournal.get("patId")));
                // mod 10553 連携イベント発生部分不正 関 start
                if (listPats.size() > 0) {
                  List<PatPersonalMain> patPersonalMainList =  listPats.stream().filter(obj -> obj.getPat_id().equals(payload.getPatId()))
                    .distinct().collect(Collectors.toList());
                  if (patPersonalMainList.size() > 0) {
                    payload.setHospPatId(patPersonalMainList.get(0).getHosp_pat_id());
                  }
                }
                // mod 10553 連携イベント発生部分不正 関 end
              }
              if (requestJournal.get("ordNo") != null) {
                payload.setOrdNo(Long.valueOf(requestJournal.get("ordNo")));
              }
              if (requestJournal.get("regExamDate") != null) {
                String regExamDate = requestJournal.get("regExamDate");
                if (regExamDate.length() > 8) {
                  regExamDate = regExamDate.substring(0, 10).replaceAll("-", "");
                }
                payload.setBaseDate(regExamDate);
              }
              payload.setUserId(ntssUser.getUserId());
              payload.setRegOrderClass(requestJournal.get("regOrderClass"));
              if ("1".equals(requestJournal.get("operation"))) {
                payload.setCrud("C");
                payload.setOpeCd("021001");
                // add 10553 連携イベント発生部分不正 関 start
                if (requestJournal.get("examMainCd") != null) {
                  payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
                }
                // add 10553 連携イベント発生部分不正 関 end
              } else if ("2".equals(requestJournal.get("operation")) && "0".equals(requestJournal.get("isDel"))) {
                payload.setCrud("U");
                payload.setOpeCd("021002");
                if (requestJournal.get("examMainCd") != null) {
                  payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
                }
              } else {
                payload.setCrud("D");
                payload.setOpeCd("021004");
                if (requestJournal.get("examMainCd") != null) {
                  payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
                }
              }
              ctlNoList.add(payload);
            }

            // 検査依頼画面
          }
        }else if (request.getPatExamMainList() != null && request.getPatExamMainList().size() > 0) {

          //#add 10125 検査予定に関する連携イベント作成不備 zrx start
          response = examRequestService.updateMasterData(request.getPatExamMainList(), ntssUser.getFacilityCd(), ntssUser.getUserId(), request.getPatExamPatternList(), request.getPatExtInfoList());
          //#add 10125 検査予定に関する連携イベント作成不備 zrx end

          // add 10553 連携イベント発生部分不正 関 start
          patIdList = request.getPatExamMainList().stream()
            .filter(obj -> Objects.nonNull(obj.get("patId")) && !obj.get("patId").isEmpty())
            .map(obj -> Long.parseLong(obj.get("patId")))
            .collect(Collectors.toList());
          if (patIdList.size() >0) {
            listPats = patPersonalMainDao.selectByIdList(patIdList);
          }
          // add 10553 連携イベント発生部分不正 関 end
          for (Map<String, String> requestJournal : request.getPatExamMainList()) {
            Integer phyOrdclassheckonecopy = 0;
            Integer phyOrdclassheckonecopy1 = 0;
            String orderExamSetInfo = requestJournal.get("orderExamSetInfo");
            JSONArray orderArray = new JSONArray(orderExamSetInfo);
            Integer orderArraylenth = orderArray.length();
            for (int i = 0; i < orderArray.length(); i++) {
              JSONObject orderExamSetInfoObject = orderArray.getJSONObject(i);
              for (int j = 0; j < phyclasslist.size(); j++)
                if (phyclasslist.get(j).getExamSetCd().toString().equals(orderExamSetInfoObject.get("set_cd").toString())) {
                  phyOrdclassheckonecopy = 1;
                  phyOrdclassheckonecopy1++;
                }
            }
            boolean phyordclassNull = requestJournal.containsKey("phyOrdClass");
            if (phyordclassNull &&  "1".equals(requestJournal.get("phyOrdClass"))
                    ||(!phyordclassNull && phyOrdclassheckonecopy == 1)) {
              JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
              payload.setFacilityCd(ntssUser.getFacilityCd());
              payload.setCoopCd("phy_ord");
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
              if (requestJournal.get("regExamDate") != null) {
                String regExamDate = requestJournal.get("regExamDate");
                if (regExamDate.length() > 8) {
                  regExamDate = regExamDate.substring(0, 10).replaceAll("-", "");
                }
                payload.setBaseDate(regExamDate);
              }
              payload.setUserId(ntssUser.getUserId());
              payload.setRegOrderClass(requestJournal.get("regOrderClass"));
              if ("1".equals(requestJournal.get("operation"))) {
                payload.setCrud("C");
                payload.setOpeCd("021015");
                // add 10553 連携イベント発生部分不正 関 start
                if (requestJournal.get("examMainCd") != null) {
                  payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
                }
                // add 10553 連携イベント発生部分不正 関 end
              } else if ("2".equals(requestJournal.get("operation")) && "0".equals(requestJournal.get("isDel"))) {
                payload.setCrud("U");
                payload.setOpeCd("021016");
                if (requestJournal.get("examMainCd") != null) {
                  payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
                }
              } else {
                payload.setCrud("D");
                payload.setOpeCd("021018");
                if (requestJournal.get("examMainCd") != null) {
                  payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
                }
              }
              ctlNoListphy.add(payload);
            }
            if((phyordclassNull && (requestJournal.get("phyOrdClass")==null)
                    ||(!phyordclassNull && phyOrdclassheckonecopy1 != orderArraylenth&& orderArraylenth !=0)
            )){
              JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
              payload.setFacilityCd(ntssUser.getFacilityCd());
              payload.setCoopCd("exam_ord");
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
              if (requestJournal.get("regExamDate") != null) {
                String regExamDate = requestJournal.get("regExamDate");
                if (regExamDate.length() > 8) {
                  regExamDate = regExamDate.substring(0, 10).replaceAll("-", "");
                }
                payload.setBaseDate(regExamDate);
              }
              payload.setUserId(ntssUser.getUserId());
              payload.setRegOrderClass(requestJournal.get("regOrderClass"));
              if ("1".equals(requestJournal.get("operation"))) {
                payload.setCrud("C");
                payload.setOpeCd("021005");
                // add 10553 連携イベント発生部分不正 関 start
                if (requestJournal.get("examMainCd") != null) {
                  payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
                }
                // add 10553 連携イベント発生部分不正 関 end
              } else if ("2".equals(requestJournal.get("operation")) && "0".equals(requestJournal.get("isDel"))) {
                payload.setCrud("U");
                payload.setOpeCd("021006");
                if (requestJournal.get("examMainCd") != null) {
                  payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
                }
              } else {
                payload.setCrud("D");
                payload.setOpeCd("021008");
                if (requestJournal.get("examMainCd") != null) {
                  payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
                }
              }
              ctlNoList.add(payload);
            }

          }
        /* add by chamaojia 2025-07-03 [11994] supplementary processing logic --start */
        } else {
          response = examRequestService.updateMasterData(request.getPatExamMainList(), ntssUser.getFacilityCd()
                  , ntssUser.getUserId(), request.getPatExamPatternList(), request.getPatExtInfoList());
        }
        /* add by chamaojia 2025-07-03 [11994] supplementary processing logic --end */

        //#del 10125 検査予定に関する連携イベント作成不備 zrx start
//        response = examRequestService.updateMasterData(request.getPatExamMainList(), ntssUser.getFacilityCd(), ntssUser.getUserId(), request.getPatExamPatternList(), request.getPatExtInfoList());
        //#del 10125 検査予定に関する連携イベント作成不備 zrx end
        if (!CollectionUtils.isEmpty(ctlNoList)) {
          journalService.callCreateJournalForCtrNo(ctlNoList);
        }
        if (!CollectionUtils.isEmpty(ctlNoListphy)) {
          journalService.callCreateJournalForCtrNo(ctlNoListphy);
        }
      }else if (phyclass == 0){
        // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
        // 検査依頼一覧画面
        if (request.getRequestJournalList() != null && request.getRequestJournalList().size() > 0) {

          //#add 10125 検査予定に関する連携イベント作成不備 zrx start
          response = examRequestService.updateMasterData(request.getRequestJournalList(), ntssUser.getFacilityCd(), ntssUser.getUserId(), request.getPatExamPatternList(), request.getPatExtInfoList());
          //#add 10125 検査予定に関する連携イベント作成不備 zrx end

          // add 10553 連携イベント発生部分不正 関 start
          patIdList = request.getRequestJournalList().stream()
            .filter(obj -> Objects.nonNull(obj.get("patId")) && !obj.get("patId").isEmpty())
            .map(obj -> Long.parseLong(obj.get("patId")))
            .collect(Collectors.toList());
          if (patIdList.size() >0) {
            listPats = patPersonalMainDao.selectByIdList(patIdList);
          }
          // add 10553 連携イベント発生部分不正 関 end
          for (Map<String, String> requestJournal : request.getRequestJournalList()) {
            JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
            payload.setFacilityCd(ntssUser.getFacilityCd());
            payload.setCoopCd("exam_ord");
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
            if (requestJournal.get("regExamDate") != null) {
              String regExamDate = requestJournal.get("regExamDate");
              if (regExamDate.length() > 8) {
                regExamDate = regExamDate.substring(0, 10).replaceAll("-", "");
              }
              payload.setBaseDate(regExamDate);
            }
            payload.setUserId(ntssUser.getUserId());
            payload.setRegOrderClass(requestJournal.get("regOrderClass"));
            if ("1".equals(requestJournal.get("operation"))) {
              payload.setCrud("C");
              payload.setOpeCd("021001");
              // add 10553 連携イベント発生部分不正 関 start
              if (requestJournal.get("examMainCd") != null) {
                payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
              }
              // add 10553 連携イベント発生部分不正 関 end
            } else if ("2".equals(requestJournal.get("operation")) && "0".equals(requestJournal.get("isDel"))) {
              payload.setCrud("U");
              payload.setOpeCd("021002");
              if (requestJournal.get("examMainCd") != null) {
                payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
              }
            } else {
              payload.setCrud("D");
              payload.setOpeCd("021004");
              if (requestJournal.get("examMainCd") != null) {
                payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
              }
            }
            ctlNoList.add(payload);
          }
          // 検査依頼画面
        } else if (request.getPatExamMainList() != null && request.getPatExamMainList().size() > 0) {

          //#add 10125 検査予定に関する連携イベント作成不備 zrx start
          response = examRequestService.updateMasterData(request.getPatExamMainList(), ntssUser.getFacilityCd(), ntssUser.getUserId(), request.getPatExamPatternList(), request.getPatExtInfoList());
          //#add 10125 検査予定に関する連携イベント作成不備 zrx end

          // add 10553 連携イベント発生部分不正 関 start
          patIdList = request.getPatExamMainList().stream()
            .filter(obj -> Objects.nonNull(obj.get("patId")) && !obj.get("patId").isEmpty())
            .map(obj -> Long.parseLong(obj.get("patId")))
            .collect(Collectors.toList());
          if (patIdList.size() >0) {
            listPats = patPersonalMainDao.selectByIdList(patIdList);
          }
          // add 10553 連携イベント発生部分不正 関 end
          for (Map<String, String> requestJournal : request.getPatExamMainList()) {
            JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
            payload.setFacilityCd(ntssUser.getFacilityCd());
            payload.setCoopCd("exam_ord");
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
            if (requestJournal.get("regExamDate") != null) {
              String regExamDate = requestJournal.get("regExamDate");
              if (regExamDate.length() > 8) {
                regExamDate = regExamDate.substring(0, 10).replaceAll("-", "");
              }
              payload.setBaseDate(regExamDate);
            }
            payload.setUserId(ntssUser.getUserId());
            payload.setRegOrderClass(requestJournal.get("regOrderClass"));
            if ("1".equals(requestJournal.get("operation"))) {
              payload.setCrud("C");
              payload.setOpeCd("021005");
              // add 10553 連携イベント発生部分不正 関 start
              if (requestJournal.get("examMainCd") != null) {
                payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
              }
              // add 10553 連携イベント発生部分不正 関 end
            } else if ("2".equals(requestJournal.get("operation")) && "0".equals(requestJournal.get("isDel"))) {
              payload.setCrud("U");
              payload.setOpeCd("021006");
              if (requestJournal.get("examMainCd") != null) {
                payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
              }
            } else {
              payload.setCrud("D");
              payload.setOpeCd("021008");
              if (requestJournal.get("examMainCd") != null) {
                payload.setOrdNo(Long.valueOf(requestJournal.get("examMainCd")));
              }
            }
            ctlNoList.add(payload);
          }
        /* add by chamaojia 2025-07-03 [11994] supplementary processing logic --start */
        } else {
          response = examRequestService.updateMasterData(request.getPatExamMainList(), ntssUser.getFacilityCd(), ntssUser.getUserId(), request.getPatExamPatternList(), request.getPatExtInfoList());
        }
        /* add by chamaojia 2025-07-03 [11994] supplementary processing logic --end */

        //#del 10125 検査予定に関する連携イベント作成不備 zrx start
//         response = examRequestService.updateMasterData(request.getPatExamMainList(), ntssUser.getFacilityCd(), ntssUser.getUserId(), request.getPatExamPatternList(), request.getPatExtInfoList());
        //#del 10125 検査予定に関する連携イベント作成不備 zrx end
        if (!CollectionUtils.isEmpty(ctlNoList)){
          journalService.callCreateJournalForCtrNo(ctlNoList);
        }
        // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
      }

      // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
      // 戻り値用
      // mod by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
      //return new ResponseEntity<>(
      //    examRequestService.updateMasterData(request.getPatExamMainList(), ntssUser.getFacilityCd(), ntssUser.getUserId(), request.getPatExamPatternList(), request.getPatExtInfoList()),
      //    HttpStatus.OK);
      return new ResponseEntity<>(response, HttpStatus.OK);
      // mod by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
    } catch (Exception e) {
      // 更新処理ができなかった場合
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_REQUEST, SERVICE_NAME.FNSI, null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
              HttpStatus.BAD_REQUEST);
    }
  }
  /**
   * 検査セットマスタデータ取得.
   *
   * @param facilityCd 取得対象の施設コード
   * @return 検査セットマスタデータのResponse
   *
  */
  @GetMapping("/examRequest/examSet/{facilityCd}")
  public ResponseEntity<?> getExamSetList(@PathVariable String facilityCd,
                                          @RequestParam(required = false) Long selectedPatId,
                                          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                          @AuthenticationPrincipal NtssUser ntssUser
                                          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, facilityCd, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXAM + "/examRequest/examSet";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
            null);
    // wp アプリケーションログの適正化 Add End

//		// ログ出力
//		EventLogMessage eventLogMessage = new EventLogMessage();
//		eventLogMessage.setLogMessage("REST request to get master : ExamSet");
//		logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_REQUEST, SERVICE_NAME.FNSI, null);
    try {
      // レスポンス生成
      List<MstExamSet> response = examRequestService.selectExamSetList(facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, null,
              null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {

//			// マスタ定義が取得できなかった場合
//			eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
//			logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_REQUEST, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(
              new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
              HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 検査セットマスタデータ取得.
   * NOTE: 施設に紐づく全レコード取得用
   *
   * @param facilityCd 取得対象の施設コード
   * @return 検査セットマスタデータのResponse
   *
  */
  @GetMapping("/examRequest/examSet/all/{facilityCd}")
  public ResponseEntity<?> getAllExamSetsByFacility(@PathVariable String facilityCd,
                                                    @RequestParam(required = false) Long selectedPatId,
                                                    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                    @AuthenticationPrincipal NtssUser ntssUser
                                                    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, facilityCd, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    String mappingUrl = Uri.EXAM + "/examRequest/examSet/all/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, null, null);

    try {
      // レスポンス生成
      List<MstExamSet> response = examRequestService.selectAllExamSetListByFacility(facilityCd);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, null, null);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>( new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @PutMapping("/updateRegExamDate")
  /**
   * 透析予定日変更時、検査依頼日追従
   * @param params 患者ID,変更前日付,変更後日付
   */
  public ResponseEntity<Void> updateRegExamDate(@RequestBody Map<String,String> params,
                                                // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                @AuthenticationPrincipal NtssUser ntssUser
                                                // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        PatMain patMain = patMainDao.selectById(Long.valueOf(params.get("patId")));
        if (patMain != null && patMain.getFacility_cd() != null &&
          !patMain.getFacility_cd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facility_cd=" + patMain.getFacility_cd() + " " + "pat_id=" + params.get("patId") + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXAM + "/updateRegExamDate";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
            params);
    // wp アプリケーションログの適正化 Add End

    try {
      examRequestService.updateRegExamDate(params);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, null,
              params);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
//			EventLogMessage eventLogMessage = new EventLogMessage();
//			eventLogMessage.setLogMessage(e.getMessage());
//			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_REQUEST, SERVICE_NAME.FNSI, null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @PutMapping("/updateIsDel")
  /**
   * 透析予定日変更時、検査依頼削除
   * @param params 患者ID,日付
   */
  public ResponseEntity<Void> updateIsDel(@RequestBody Map<String,String> params,
                                          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                          @AuthenticationPrincipal NtssUser ntssUser
                                          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
      if(!ntssUser.isNkkAdminUser()) {
        String facilityCd = params.get("facilityCd");
        if (facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
          String mappingUrl = Uri.EXAM + "/updateIsDel";
          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_ERROR, mappingUrl, null, "セキュリティチェックの例外!");
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXAM + "/updateIsDel";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
            params);
    // wp アプリケーションログの適正化 Add End


    try {
      examRequestService.updateIsDel(params);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, null,
              params);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
//			EventLogMessage eventLogMessage = new EventLogMessage();
//			eventLogMessage.setLogMessage(e.getMessage());
//			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_REQUEST, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @PostMapping("/createPatExamMain")
  /**
   * 期間内に当てはまる検査パターンを登録
   * @param params 以下の３つを含む
   *   patId 患者ID
   *   fromDate 期間開始日 ('YYYY/MM/DD')
   *   toDate 期間終了日 ('YYYY/MM/DD')
   */
  public ResponseEntity<Void> createPatExamMain(@RequestBody Map<String,String> params,
                                                @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
    if (!ntssUser.isNkkAdminUser()) {
      String patIdValue = params.get("patId");
      if (patIdValue != null && !patIdValue.isEmpty()) {
        PatMain patMain = patMainDao.selectById(Long.valueOf(patIdValue));
        if (patMain != null && patMain.getFacility_cd() != null
          && !patMain.getFacility_cd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facility_cd=" + patMain.getFacility_cd() + " " + "patId=" + patIdValue + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXAM + "/createPatExamMain";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
            params);
    // wp アプリケーションログの適正化 Add End

    try {
      examRequestService.createPatExamMain(params);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, null,
              params);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//			eventLogMessage.setLogMessage(e.getMessage());
//			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_REQUEST, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 患者IDリストから患者情報を取得する
   * @param  payload 患者IDリスト
   * @return
   * @throws Exception
   */
  @PostMapping("/examRequest/getPatInfoList")
  public ResponseEntity<?> getPatInfoList(
          @RequestBody Map<String, String> payload,
          @RequestParam(required = false) Long selectedPatId
  ,
          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
          @AuthenticationPrincipal NtssUser ntssUser
          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws Exception {
    List<Long> patIdList = this.getLongValueList(payload.get("patIdList"));
    if (!facilityAccessService.hasPatIdsOrSelectedPatShareAccess(ntssUser, patIdList, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXAM + "/examRequest/getPatInfoList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
            payload);
    // wp アプリケーションログの適正化 Add End
    try {
      List<PatMain> response = patInfoService.getPatSchExtEndDateList(patIdList);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, null,
              payload);
      // wp アプリケーションログの適正化 Add End

      // レスポンス生成
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_REQUEST, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
              HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

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
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_REQUEST, SERVICE_NAME.FNSI,
              null);
      return null;
    }
    return valueArry;
  }

  /* add #6358 by zhangruixue 2023-06-13 --start */
  @PostMapping("/examRequest/sch_ext_end_date_post")
  public ResponseEntity<?> getMinSchExtEndDatePost(@RequestBody Map<String, String> payload,
                                                   // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                   @AuthenticationPrincipal NtssUser ntssUser
                                                   // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
      if(!ntssUser.isNkkAdminUser()) {
        String facilityCd = payload.get("facilityCd");
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end


    String mappingUrl = Uri.EXAM + "/examRequest/sch_ext_end_date_post";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      payload);
    try {
      List<Long> patIdList = this.getLongValueList(payload.get("patIdList"));
      // レスポンス生成
      String response = examRequestService.selectMinSchExtEndDatePost(payload.get("facilityCd"),patIdList);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        payload);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(
        new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  /* add #6358 by zhangruixue 2023-06-13 --end */

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

  /**
   *add FNSI-患者が死亡した後、検査依頼を削除します 劉全航 start
   * @param payload
   * @return overDeadlineCount 締切日を過ぎていて削除されなかった予定の件数
   */
  @PostMapping("/deletePatExamRequest")
  public ResponseEntity<?> deleteDeadPatRequest(@RequestBody Map<String, Object> payload, @AuthenticationPrincipal NtssUser ntssUser){
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
    if (!ntssUser.isNkkAdminUser()) {
      Object facilityCdValue = payload.get("facilityCd");
      if (facilityCdValue != null) {
        String facilityCd = facilityCdValue.toString();
        if (!facilityCd.isEmpty() && !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
      Object patIdValue = payload.get("patId");
      if (patIdValue != null) {
        PatMain patMain = patMainDao.selectById(Long.valueOf(patIdValue.toString()));
        if (patMain != null && patMain.getFacility_cd() != null
          && !patMain.getFacility_cd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facility_cd=" + patMain.getFacility_cd() + " " + "patId=" + patIdValue + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXAM + "/deletePatExamRequest";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST,
            BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    int overDeadlineCount = 0;
    try {
      /* add by Lm.Mingyue  2023-02-01 [Transaction] start */
      overDeadlineCount = examRequestService.deleteDeadPatRequest(overDeadlineCount, payload, ntssUser);
      /* add by Lm.Mingyue  2023-02-01 [Transaction] end */

      /* del by Lm.Mingyue  2023-02-01 [Transaction] start */
//      Long patId = Long.parseLong(Objects.isNull(payload.get("patId")) ? "0" : payload.get("patId").toString());
//      String facilityCd = Objects.isNull(payload.get("facilityCd")) ? "0" : payload.get("facilityCd").toString();
//      String dateFrom = payload.get("deleteDate").toString();
//
//      // 死亡/転出、離脱、移植、通院拒否・不明日以降の予定データを取得
//      List<PatExamMain> examList = patExamMainDao.selectDeleteTarget(patId, facilityCd, dateFrom);
//
//      // 検査依頼変更締切り有無 1015
//      String examChangeOnOffWithOrder = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.EXAM_CHANGE_ON_OFF_WITH_ORDER);
//      // 締切りを過ぎているデータを削除対象から除外する
//      if (examChangeOnOffWithOrder.equals("1")) {
//        // 検査依頼変更締切り日数 1011
//        String examScheduleChangeLimitDay = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_DAY);
//        // 検査依頼変更締切り時間 1012
//        String examScheduleChangeLimitTime = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_TIME);
//        // 初期値の"0000"はエラーになる為補正
//        if (examScheduleChangeLimitTime.equals("0000")) {
//          examScheduleChangeLimitTime = "00:00";
//        }
//        int minutes = Integer.valueOf(examScheduleChangeLimitTime.substring(0, 2)) * 60 + Integer.valueOf(examScheduleChangeLimitTime.substring(3, 5));
//        Long aLong = Long.valueOf(minutes);
//        // 現在日に、締切り日数、時間を加算
//        LocalDateTime nowLdt = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd").format(new Date()) + " 00:00:00").toLocalDateTime();
//        LocalDateTime deadlineLdt = nowLdt.plusDays(Long.valueOf(examScheduleChangeLimitDay)).plusMinutes(aLong);
//        String deadlineDate = Timestamp.valueOf(deadlineLdt).toString();
//
//        boolean timeOverFlg = false;
//        String nowTime = new SimpleDateFormat("HH:mm:ss").format(new Date());
//        if(nowTime.compareTo(deadlineDate.substring(11, 19)) > 0) {
//          // 現在時刻が、締切り時間を過ぎていた場合、現在日 + 締切り日数 の日付の予定を、締め切りを過ぎたものとして扱う
//          timeOverFlg = true;
//        }
//
//        // 締切りを過ぎているレコードをリストに取得する
//        List<PatExamMain> overList = new ArrayList<>();
//        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//        String deadlineDay = deadlineDate.substring(0, 10);
//        for (PatExamMain exam : examList) {
//          String regExamDate = sdf.format(exam.getRegExamDate());
//          if (timeOverFlg) {
//            if (deadlineDay.compareTo(regExamDate) >= 0) {
//              overList.add(exam);
//            }
//          } else {
//            if (deadlineDay.compareTo(regExamDate) > 0) {
//              overList.add(exam);
//            }
//          }
//        }
//        // 締切りを過ぎているレコードを除外する
//        for (PatExamMain idx : overList) {
//          examList.remove(idx);
//        }
//        // 締切りを過ぎていたレコード件数を応答に含める
//        overDeadlineCount = overList.size();
//      }
//
//      // 削除対象の exam_main_cd リストを作成
//      List<Long> examMainCdList = examList.stream().map(item -> item.getExamMainCd()).distinct().collect(Collectors.toList());
//      // 削除を実施
//      Long upStaff = ntssUser.getUserId();
//      Long indUserId = Long.parseLong(Objects.isNull(payload.get("indUserId")) ? ntssUser.getUserId().toString() : payload.get("indUserId").toString());
//      int i = patExamMainDao.deleteExamRequestByPatId(facilityCd, patId, upStaff, indUserId, examMainCdList);
//      // 削除完了後の処理
//      if (i > 0) {
//        SimpleDateFormat sdf2 = new SimpleDateFormat("yyyyMMdd");
//        String type = payload.get("type").toString();
//        String opeCd = type.equals("death") ? "031003" : "007010";
//        // 連携イベントの登録処理
//        for (PatExamMain exam : examList) {
//          // exam_main_cd 毎に連携イベントの登録処理を実施する
//          JournalCreateRequestPayload sendPayload = new JournalCreateRequestPayload();
//          sendPayload.setFacilityCd(facilityCd);
//          sendPayload.setCoopCd("exam_ord");
//          sendPayload.setCrud("D");
//          sendPayload.setPatId(patId);
//          sendPayload.setOrdNo(exam.getExamMainCd());
//          sendPayload.setBaseDate(sdf2.format(exam.getRegExamDate()));
//          sendPayload.setOpeCd(opeCd);
//          sendPayload.setUserId(indUserId);
//          journalService.callCreateJournalForPayload(sendPayload);
//        }
//        // 削除処理が実施された場合に、パターンの削除処理も実施
//        patExamPatternDao.updateIsDelByPatIdAndExamTo(patId, facilityCd, dateFrom, ntssUser.getUserId(), indUserId);
//      }
      /* del by Lm.Mingyue  2023-02-01 [Transaction] end   */
    }catch (Exception e){
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && !StringUtils.isEmpty(ntssUser.getFacilityCd())) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST,
            AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(overDeadlineCount, HttpStatus.OK);
  }
  /**
   * add FNSI-患者が死亡した後、検査依頼を削除します 劉全航 end
   */

  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add start
  /**
   * 患者検査結果取得用(再計算用)
   * @param params
   * @return
   */
  @PostMapping("/getPatListByFacilityCd")
  public ResponseEntity<?> getPatListByFacilityCd(@RequestBody Map<String, String> params,
                                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                  @AuthenticationPrincipal NtssUser ntssUser
                                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    String mappingUrl = Uri.EXAM + "/getPatListByFacilityCd";
    String facilityCd = params.get("facilityCd");
    String startDate = params.get("startDate");
    String endDate = params.get("endDate");
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end

    try {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST,
        BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd, Arrays.asList(facilityCd, startDate, endDate));

      if (!StringUtils.hasLength(facilityCd)) {
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST,
          AFTER_LOG_FLG_INFO, mappingUrl, facilityCd, Arrays.asList(facilityCd, startDate, endDate));
        return new ResponseEntity<>("施設コードが指定されていません。", HttpStatus.BAD_REQUEST);
      }

      List<PatPersonalMainData> resultList = examRequestService.getPatListByFacilityCd(facilityCd, startDate, endDate);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXAM_REQUEST,
        AFTER_LOG_FLG_INFO, mappingUrl, facilityCd, Arrays.asList(facilityCd, startDate, endDate));

      return new ResponseEntity<>(resultList, HttpStatus.OK);
    } catch (Exception ex) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      ex.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXAM_REQUEST, SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_EXAM_REQUEST, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd, Arrays.asList(facilityCd, startDate, endDate));
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.NOT_EXIST_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add end
}
