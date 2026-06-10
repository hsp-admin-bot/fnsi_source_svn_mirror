package jp.co.nikkiso.ntss.admin_web.web.rest;

import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.constant.MstToMongoEnum;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.request.searchInfo.PatInfoRequest;
import jp.co.nikkiso.ntss.admin_web.response.patInfo.PatByFCAndPIdsResponse;
import jp.co.nikkiso.ntss.admin_web.response.patInfo.PatInfoResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.AsyncService;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.MongoService;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.PatInfoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.nextpat.NextPatService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo.PatMainAcceptanceStatusInfoService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.NotificationDefinition;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstComsvSettingDao;
import jp.co.nikkiso.ntss.core.dao.MstWheelChairDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.DetailedSearchRequest;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.OrdMainContainerWithRange;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.SimpleSearchRequest;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstComsvSetting;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstWheelChair;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatHistoryInfo;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.custom.AdditionInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainBedAndKur;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainKurBed;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainTreatDate;
import jp.co.nikkiso.ntss.core.entity.custom.PatInsuInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatPersonalMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatUniquePhysicalInfo;
import jp.co.nikkiso.ntss.core.entity.custom.SharedPatFacilityInfo;
import jp.co.nikkiso.ntss.core.logevent.ILogEventService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import jp.co.nikkiso.ntss.core.utils.PatSortCommonUtil;
import org.apache.commons.collections.CollectionUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.OptimisticLockException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ExecutorService;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


// add FNSI-患者情報共有よりの改修 江 start
// add FNSI-患者情報共有よりの改修 江 end
// add FNSI-排他処理 劉 start
// add FNSI-排他処理 劉 end
// mod FNSI-連携イベントの登録適正化 楊 start
// mod FNSI-連携イベントの登録適正化 楊 end
/**
 * 患者情報系
 *
 */
@RestController
@RequestMapping(Uri.PAT_INFO)
public class PatInfoResource {
  // add 10389 患者リストのソートが遅い gjn start
  @Autowired
  OrdMainService ordMainService;
  // add 10389 患者リストのソートが遅い gjn start

  @Autowired
  PatInfoService patInfoService;
  @Autowired
  PatPersonalMainDao patPersonalMainDao;

  @Value("${ntss.admin-web.coop-api.url}")
  private String coopApi;

  /**
   * webAPI呼び出し用
   */
  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  @Autowired
  private JournalService journalService;

  @Autowired
  private LogService logService;

  // #7068 add 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start
  @Autowired
  AsyncService asyncService;
  // #7068 add 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 end

  // add FNSi5712アプリケーションログが出力しない 周 start
  @Autowired
  LogEventUtils logEventUtils;
  // add FNSi5712アプリケーションログが出力しない 周 end

  @Autowired
  private PatMainAcceptanceStatusInfoService patMainAcceptanceStatusInfoService;

  //add #10412 次患者更新関連全体見直し対応 朴 start
  /**
   * 次患者更新関連
   */
  @Autowired
  private NextPatService nextPatService;

  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private PatUniqueDao patUniqueDao;

  @Autowired
  private MntMachineStateDao mntMachineStateDao;

  @Autowired
  private MstComsvSettingDao mstComsvSettingDao;
  //add #10412 次患者更新関連全体見直し対応 朴 end
  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
  @Autowired
  private MongoService mongoService;
  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

  // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
  @Autowired
  private MstWheelChairDao mstWheelChairDao;
  // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end

  @Resource(name = "crawlExecutorPool")
  private ExecutorService threadExector;

  // add FNSI-排他処理 劉 start
  private static final String HAITACODE = "22020006";
  // add FNSI-排他処理 劉 end
  // redmine 6471 患者グループの編集した記録がログに残らない  関　start
  private final static String ADDPATGROUP_LOG_MESSAGE = "%sに患者グループ%sを追加しました。";
  private final static String DELPATGROUP_LOG_MESSAGE = "%sから患者グループ%sが削除しました。";
  private final static String MODPATGROUP_LOG_MESSAGE = "%sの患者グループ%s→%sが変更されました。";
  // redmine 6471 患者グループの編集した記録がログに残らない  関　end
  /**
   * 患者登録
   */
  @PostMapping("/createPat")
  public ResponseEntity<Long> createPat(@RequestBody Map<String, String> payload) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/createPat";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      // 患者情報の新規登録
//      log.info("PatInfoResource.createPat is begin"+ System.currentTimeMillis());
      long assignedPatId = patInfoService.create(payload);
//      log.info("PatInfoResource.createPat after create"+ System.currentTimeMillis());
//      modify by maxueqiang
      threadExector.execute(new Runnable() {
        @Override
        public void run() {
          // 通知登録
          patInfoService.registerPushNotification(assignedPatId, payload, null, true);
        }
      });
//      threadExector.shutdown();
//      log.info("PatInfoResource.createPat after registerPushNotification"+ System.currentTimeMillis());
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(assignedPatId, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 患者更新
   */
  @PutMapping("/updatePatById/{pat_id}")
  // mod FNSI-排他処理 劉 start
  //public ResponseEntity<Void> updatePatById(@PathVariable long pat_id, @RequestBody Map<String, String> payload) {
  public ResponseEntity<String> updatePatById(@PathVariable long pat_id, @RequestBody Map<String, String> payload) {
    // mod FNSI-排他処理 劉 end
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/updatePatById/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload));
    // add FNSi5712アプリケーションログが出力しない 周 end

    //add #10412 次患者更新関連全体見直し対応 朴 start
    List<Long> patidListForCheckDoCallNextPat = new ArrayList<>();
    //add #10412 次患者更新関連全体見直し対応 朴 end

    try {
      //add #10412 次患者更新関連全体見直し対応 朴 start
      List<OrdMain> doCallNextPatOrdMainList = new ArrayList<>();
      PatMain beforePatMain = patMainDao.selectById(pat_id);
      PatPersonalMain beforePatPersonalMain = patPersonalMainDao.selectById(pat_id);
      //add #10412 次患者更新関連全体見直し対応 朴 end

      // 患者グループの差異を検索
      JSONObject patGroupDiff = patInfoService.getPatGroupDiff(pat_id, payload);
      // 患者情報の更新
      // mod 6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 周安寧　start
      //patInfoService.updateById(pat_id, payload);
      patInfoService.updateById(pat_id, payload ,patGroupDiff);
      // mod 6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 周安寧　end

      // mod 10147 患者情報を更新時に検査計算(更新)されない gjn start
      //add 9480 患者更新-検査計算 gjn start
      // mod #10147 患者情報を更新時に検査計算(更新)されない zkm start
      if (payload.containsKey("changed_record") && !StringUtils.isEmpty(payload.get("changed_record"))) {
        boolean xujs = false;
        JSONObject changed_record = new JSONObject(payload.get("changed_record"));
        //性別
        if (changed_record.has("pat_sex")) {
//          JSONObject pat_sex = new JSONObject(changed_record.get("pat_sex"));
          JSONObject pat_sex = (JSONObject) changed_record.get("pat_sex");
          if (pat_sex.has("initValue") && pat_sex.has("editValue")
            && !pat_sex.get("initValue").equals(pat_sex.get("editValue"))) {
            xujs = true;
          }
        }
        //年齢（歳）
        if (!xujs && changed_record.has("pat_birthday")) {
//          JSONObject pat_birthday = new JSONObject(changed_record.get("pat_birthday"));
          JSONObject pat_birthday = (JSONObject) changed_record.get("pat_birthday");
          if (pat_birthday.has("initValue") && pat_birthday.has("editValue")) {
            LocalDate today = LocalDate.now();
            LocalDate initDate = LocalDate.parse(pat_birthday.get("initValue").toString(), DateTimeFormatter.ofPattern("yyyyMMdd"));
            LocalDate editDate = LocalDate.parse(pat_birthday.get("editValue").toString(), DateTimeFormatter.ofPattern("yyyyMMdd"));
            if (Period.between(initDate, today).getYears() != Period.between(editDate, today).getYears()) {
              xujs = true;
            }
          }
        }

        if (xujs) {
          threadExector.execute(() -> webApiCallCommonUtil.doAutoCalculationByPatIdAndTreatDate(pat_id, null, null));
        } else {
          //患者メモ
          if (!xujs && changed_record.has("pat_memo_info")) {
//          JSONObject pat_memo_info = new JSONObject(changed_record.get("pat_memo_info"));
            JSONObject pat_memo_info = (JSONObject) changed_record.get("pat_memo_info");
            if (pat_memo_info.has("title")) {
              JSONObject title = new JSONObject(changed_record.get("title"));
              if (title.has("initValue") && title.has("editValue")
                && !title.get("initValue").equals(title.get("editValue"))) {
                xujs = true;
              }
            }
          }
          if (xujs) {
            String facilityCd = String.valueOf(payload.get("facilityCd"));
            //mod 10147 患者情報を更新時に検査計算(更新)されない gjn start
            threadExector.execute(new Runnable() {
              @Override
              public void run() {
                webApiCallCommonUtil.doAutoCalculationByPatId(pat_id);
              }
            });
            //mod 10147 患者情報を更新時に検査計算(更新)されない gjn end
          }
        }

      }
      //add 9480 患者更新-検査計算 gjn end
      // mod 10147 患者情報を更新時に検査計算(更新)されない gjn start
      threadExector.execute(new Runnable() {
        @Override
        public void run() {
          // 通知登録
          patInfoService.registerPushNotification(pat_id, payload, patGroupDiff, false);
        }
      });
//      threadExector.shutdown();
      // mod FNSI-排他処理 劉 start
      //return new ResponseEntity<>(HttpStatus.OK);

      //add #10412 次患者更新関連全体見直し対応 朴 start
      PatMain afterPatMain = patMainDao.selectById(pat_id);
      PatPersonalMain afterPatPersonalMain = patPersonalMainDao.selectById(pat_id);

      String facilityCd = beforePatMain.getFacility_cd();
      List<MntMachineState> mntMachineStateList = mntMachineStateDao.selectByNextPatIdList(facilityCd, Arrays.asList(pat_id));
      List<Long> ordNoList = mntMachineStateList.stream().map(item -> item.getNextOrdNo()).distinct().collect(Collectors.toList());
      List<OrdMain> ordMainList = ordMainDao.selectByOrdNoList(ordNoList);

      if(nextPatService.CheckDoCallNextPatChangeForPat(facilityCd, beforePatMain, afterPatMain, beforePatPersonalMain, afterPatPersonalMain)){
        doCallNextPatOrdMainList.addAll(ordMainList);
      } else {
        List<Integer> bedCdList = mntMachineStateList.stream().map(item -> item.getBedCd().intValue()).distinct().collect(Collectors.toList());
        List<MstComsvSetting> mstComsvInfos = mstComsvSettingDao.selectByBedCds(facilityCd, bedCdList);
        Map<Integer,MstComsvSetting> mstComsvInfosMap = mstComsvInfos.stream().collect(Collectors.toMap(o -> o.getNextPatMode(), o -> o));
        for(OrdMain ordMain: ordMainList){
          if(nextPatService.CheckDoCallNextPatChangeForPatMemo(facilityCd, ordMain.getIndBedCd(), beforePatMain, afterPatMain, beforePatPersonalMain, afterPatPersonalMain, mstComsvInfosMap.get(ordMain.getIndBedCd()))){
            doCallNextPatOrdMainList.add(ordMain);
          }
        }
      }

      nextPatService.CallNextPatChange(facilityCd, doCallNextPatOrdMainList);
      //add #10412 次患者更新関連全体見直し対応 朴 end

      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>("",HttpStatus.OK);
    } catch (OptimisticLockException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HAITACODE, HttpStatus.BAD_REQUEST);
      // mod FNSI-排他処理 劉 end
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      // mod FNSI-排他処理 劉 start
      return new ResponseEntity<>("",HttpStatus.BAD_REQUEST);
      // mod FNSI-排他処理 劉 end
    }
  }

  /**
   * 一括で患者保険情報を変更する
   */
  @PutMapping("/bulkUpdatePatInsu")
  // mod FNSI-排他処理 劉 start
  //public ResponseEntity<Void> updateBulkUpdatePatInsu(@RequestBody List<PatInsuInfo> patInsuInfos) {
  public ResponseEntity<String> updateBulkUpdatePatInsu(@RequestBody List<PatInsuInfo> patInsuInfos) {
  // mod FNSI-排他処理 劉 end
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/bulkUpdatePatInsu";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patInsuInfos));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patInfoService.updateBulkUpdatePatInsu(patInsuInfos);
      // mod FNSI-排他処理 劉 start
      //return new ResponseEntity<>(HttpStatus.OK);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patInsuInfos));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>("",HttpStatus.OK);
    } catch (OptimisticLockException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HAITACODE, HttpStatus.BAD_REQUEST);
      // mod FNSI-排他処理 劉 end
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patInsuInfos));
      // add FNSi5712アプリケーションログが出力しない 周 end
      // mod FNSI-排他処理 劉 start
      //return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      return new ResponseEntity<>("",HttpStatus.BAD_REQUEST);
      // mod FNSI-排他処理 劉 end
    }
  }
  //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  start
  /**
   * 一括で患者保険情報を変更する
   */
  @PutMapping("/allUpdatePatInsu")
  public ResponseEntity<String> updateUpdatePatInsu(@RequestBody List<PatInsuInfo> patInsuInfos) {
    String mappingUrl = Uri.PAT_INFO + "/allUpdatePatInsu";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patInsuInfos));
    try {
      patInfoService.updateUpdatePatInsu(patInsuInfos);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patInsuInfos));
      return new ResponseEntity<>("",HttpStatus.OK);
    } catch (OptimisticLockException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      return new ResponseEntity<>(HAITACODE, HttpStatus.BAD_REQUEST);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patInsuInfos));
      return new ResponseEntity<>("",HttpStatus.BAD_REQUEST);
    }
  }
  //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  end

  /**
   * 患者保険情報を変更する
   */
  @PutMapping("/updatePatInsu")
  // mod FNSI-排他処理 劉 start
  //public ResponseEntity<Void> updatePatInsuById(@RequestBody PatInsuInfo patInsuInfo) {
  public ResponseEntity<String> updatePatInsuById(@RequestBody PatInsuInfo patInsuInfo) {
  // mod FNSI-排他処理 劉 end
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/updatePatInsu";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patInsuInfo));
    // add FNSi5712アプリケーションログが出力しない 周 end
  try {
      patInfoService.updateInsuById(patInsuInfo);
      // mod FNSI-排他処理 劉 start
      //return new ResponseEntity<>(HttpStatus.OK);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patInsuInfo));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>("",HttpStatus.OK);
    } catch (OptimisticLockException e) {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
    EventLogMessage eventLogMessage = new EventLogMessage();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
    eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HAITACODE, HttpStatus.BAD_REQUEST);
      // mod FNSI-排他処理 劉 end
    } catch (Exception e) {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
    EventLogMessage eventLogMessage = new EventLogMessage();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
    eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      // mod FNSI-排他処理 劉 start
      //return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      return new ResponseEntity<>("",HttpStatus.BAD_REQUEST);
      // mod FNSI-排他処理 劉 end
    }
  }

  /**
   * 患者保険情報を登録する
   */
  @PostMapping("/insertPatInsu")
  public ResponseEntity<Void> insertPatInsuById(@RequestBody PatInsuInfo patInsuInfo) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/insertPatInsu";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patInsuInfo));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patInfoService.insertInsu(patInsuInfo);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patInsuInfo));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (patInsuInfo != null && patInsuInfo.getFacility_cd() != null) {
        eventLogMessage.setFacilityCd(patInsuInfo.getFacility_cd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 患者更新(マルチ)
   */
  @PutMapping("/updatePatByList")
  public ResponseEntity<Void> updatePatByList(@RequestBody List<Map<String, String>> payload, @AuthenticationPrincipal NtssUser user) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/updatePatByList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {

      //add #10412 次患者更新関連全体見直し対応 朴 start
      List<OrdMain> doCallNextPatOrdMainList = new ArrayList<>();
      List<Long> patidListForCheckDoCallNextPat = new ArrayList<>();

      List<Long> patidList = new ArrayList<>();
      String facilityCd = null;
      for (Map<String, String> patRecord: payload) {
        if(patRecord.get("pat_id") != null) {
          patidList.add(Long.parseLong(patRecord.get("pat_id")));
        }
      }

      List<PatMain> beforePatMainList = patMainDao.selectByIdList(patidList);
      Map<Long,PatMain> beforePatMainListMap = beforePatMainList.stream().collect(Collectors.toMap(o -> o.getPat_id(), o -> o));

      List<PatPersonalMain> beforePatPersonalMainList = patPersonalMainDao.selectByIdList(patidList);
      Map<Long,PatPersonalMain> beforePatPersonalMainListMap = beforePatPersonalMainList.stream().collect(Collectors.toMap(o -> o.getPat_id(), o -> o));

      List<PatUnique> beforPatUniqueList = patUniqueDao.selectByIdList(patidList);
      Map<Long,PatUnique> beforPatUniqueListMap = beforPatUniqueList.stream().collect(Collectors.toMap(o -> o.getPat_id(), o -> o));
      //add #10412 次患者更新関連全体見直し対応 朴 end

      // #10553 Mod データリスト保存排他チェックロジック最適化 Start
//      patInfoService.updateByList(payload);
      patInfoService.segmentedUpdateByList(payload);
      // #10553 Mod データリスト保存排他チェックロジック最適化 End

      //add #10412 次患者更新関連全体見直し対応 朴 start
      List<PatMain> afterPatMainList = patMainDao.selectByIdList(patidList);
      Map<Long,PatMain> afterPatMainListMap = afterPatMainList.stream().collect(Collectors.toMap(o -> o.getPat_id(), o -> o));

      List<PatPersonalMain> afterPatPersonalMainList = patPersonalMainDao.selectByIdList(patidList);
      Map<Long,PatPersonalMain> afterPatPersonalMainListMap = afterPatPersonalMainList.stream().collect(Collectors.toMap(o -> o.getPat_id(), o -> o));

      List<PatUnique> afterPatUniqueList = patUniqueDao.selectByIdList(patidList);
      Map<Long,PatUnique> afterPatUniqueListMap = afterPatUniqueList.stream().collect(Collectors.toMap(o -> o.getPat_id(), o -> o));

      if(beforePatMainList != null && !beforePatMainList.isEmpty()) facilityCd = beforePatMainList.get(0).getFacility_cd();
      if(facilityCd == null && beforePatPersonalMainList != null && !beforePatPersonalMainList.isEmpty()) facilityCd = beforePatPersonalMainList.get(0).getFacility_cd();

      if(facilityCd != null){
        List<MntMachineState> mntMachineStateList = mntMachineStateDao.selectByNextPatIdList(facilityCd, patidList);
        List<Long> ordNoList = mntMachineStateList.stream().map(item -> item.getNextOrdNo()).distinct().collect(Collectors.toList());
        List<OrdMain> ordMainList = ordMainDao.selectByOrdNoList(ordNoList);
        for(Long patId : patidList){
          List<OrdMain> ordMainListForOnePat = ordMainList.stream().filter(o -> Objects.equals(o.getPatId(), patId)).collect(Collectors.toList());
          if(nextPatService.CheckDoCallNextPatChangeForPat(facilityCd, beforePatMainListMap.get(patId), afterPatMainListMap.get(patId), beforePatPersonalMainListMap.get(patId), afterPatPersonalMainListMap.get(patId))){
            doCallNextPatOrdMainList.addAll(ordMainListForOnePat);
          } else {
            List<Integer> bedCdList = ordMainListForOnePat.stream().map(item -> item.getIndBedCd()).distinct().collect(Collectors.toList());
            List<MstComsvSetting> mstComsvInfos = mstComsvSettingDao.selectByBedCds(facilityCd, bedCdList);
            Map<Integer,MstComsvSetting> mstComsvInfosMap = mstComsvInfos.stream().collect(Collectors.toMap(o -> o.getNextPatMode(), o -> o));
            for(OrdMain ordMain: ordMainListForOnePat){
              if(nextPatService.CheckDoCallNextPatChangeForPatMemo(facilityCd, ordMain.getIndBedCd(), beforePatMainListMap.get(patId), afterPatMainListMap.get(patId), beforePatPersonalMainListMap.get(patId), afterPatPersonalMainListMap.get(patId), mstComsvInfosMap.get(ordMain.getIndBedCd()))){
                doCallNextPatOrdMainList.add(ordMain);
              }
            }
          }
          doCallNextPatOrdMainList.addAll(nextPatService.FilterNextPatInfo1or2ChangedForDw(facilityCd, beforPatUniqueListMap.get(patId), afterPatUniqueListMap.get(patId)));
        }
        nextPatService.CallNextPatChange(facilityCd, doCallNextPatOrdMainList);
      }
      //add #10412 次患者更新関連全体見直し対応 朴 end

      //add #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 start
      journalService.sendJournalForDw(payload, user);
      //add #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 end

      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (user != null && user.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(user.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
	 *
	 * @param pat_id
	 * @return
	 */
	@PutMapping("/updateAdditionInfo/{pat_id}")
	public ResponseEntity<Void> updateAddInfoById(@PathVariable long pat_id,
			@RequestBody Map<String, String> payload) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/updateAdditionInfo/{pat_id}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
		try {
			patInfoService.updateAddInfoById(pat_id, payload.get("additionInfo"));
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      eventLogMessage.setPatId(String.valueOf(pat_id));
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

  /**
   * 患者更新(身体情報)
   */
  @PutMapping("/updatePhysicalInfoById/{pat_id}")
  // mod FNSI-排他処理 劉 start
  //public ResponseEntity<Void> updatePhysicalInfoById(@PathVariable long pat_id, @RequestBody Map<String, String> payload) {
  public ResponseEntity<String> updatePhysicalInfoById(@PathVariable long pat_id, @RequestBody Map<String, String> payload) {
    // mod FNSI-排他処理 劉 end
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/updatePhysicalInfoById/{pat_id}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      // Op
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

      //10147 患者情報を更新時に検査計算(更新)されない gjn start
      //9480 患者更新(身体情報),检查计算 gjn start
      List<Map<String, String>> yuanExamDateHight = new ArrayList<>();
      //更新前の一番最新の身体情報（身長）を取得する
       List<PatUnique> patUniqueList = patInfoService.selectPatInfoById(pat_id);
       for (PatUnique patUnique : patUniqueList) {
         String phyStr = patUnique.getPhysical_info();
         JSONArray physical_info = new JSONArray(phyStr);
         for (Object phy : physical_info) {
           if (((JSONObject) phy).has("exam_date") && JSONObject.NULL != ((JSONObject) phy).get("height")) {
             String date = String.valueOf(((JSONObject) phy).get("exam_date"));
             Map<String, String> row = new HashMap<>();
             row.put("date", date);
             row.put("height", String.valueOf(((JSONObject) phy).get("height")));
             yuanExamDateHight.add(row);
           }
         }
       }

      //add #10412 次患者更新関連全体見直し対応 朴 start
      PatUnique beforPatUnique = patUniqueDao.selectById(pat_id);
      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(pat_id);
      //add #10412 次患者更新関連全体見直し対応 朴 end

      //mod #10412 次患者更新関連全体見直し対応 朴 start
//      //mod FNSI-redmine4498 房 start
//      if (payload.containsKey("needle_flag")) {
//        patInfoService.updatePhysicalInfoById(pat_id);
//      } else {
//        patInfoService.updatePhysicalInfoById(pat_id, payload);
//      }
//      //mod FNSI-redmine4498 房 end
      List<OrdMainTreatDate> effectsIntervalOrdNoList =
        patInfoService.updatePhysicalInfoById(pat_id, payload, user.getUserId());

      //mod #10412 次患者更新関連全体見直し対応 朴 end

      //add #10412 次患者更新関連全体見直し対応 朴 start
      if(beforPatUnique != null){
        PatUnique afterPatUnique = patUniqueDao.selectById(pat_id);
        // mod #10601 スケジュール表動作不正 start
//        String facilityCd = beforPatUnique.getFacility_cd();
        String facilityCd = patPersonalMain.getFacility_cd();
        // mod #10601 スケジュール表動作不正 end
        nextPatService.CallNextPatChange(facilityCd, nextPatService.FilterNextPatInfo1or2ChangedForDw(facilityCd, beforPatUnique, afterPatUnique));
      }
      //add #10412 次患者更新関連全体見直し対応 朴 end

      if (payload.containsKey("pat_unique") && !StringUtils.isEmpty(payload.get("pat_unique"))) {
        JSONObject pat_unique = new JSONObject(payload.get("pat_unique"));
        String phyStr = String.valueOf(pat_unique.get("physical_info"));
        phyStr = phyStr.substring(phyStr.indexOf("["), phyStr.lastIndexOf("]")+1);
        JSONArray physical_info = new JSONArray(phyStr);
        List<Map<String, String>> examDateHight = new ArrayList<>();
        for (Object phy : physical_info) {
          if (((JSONObject)phy).has("exam_date") && JSONObject.NULL != ((JSONObject) phy).get("height")) {
            String date = String.valueOf(((JSONObject) phy).get("exam_date"));
            Map<String, String> row = new HashMap<>();
            row.put("date", date);
            row.put("height", (String) ((JSONObject) phy).get("height"));
            examDateHight.add(row);
          }
        }
        //身長（m/cm）、患者の修正前最大日付の身長と修正後最大日付の身長が等しくない場合、計算インタフェースを呼び出す必要がある
//        if (yuanExamDateHight.size() != examDateHight.size() || !yuanExamDateHight.equals(examDateHight)) {
        List<String> diffDateList = findFirstDifference(yuanExamDateHight, examDateHight);
        if (org.apache.commons.collections4.CollectionUtils.isNotEmpty(diffDateList)) {
          webApiCallCommonUtil.doAutoCalculationByPatIdAndTreatDate(pat_id, diffDateList.get(0), diffDateList.get(1));
        }
      }
      // mod #10147 患者情報を更新時に検査計算(更新)されない zkm end
      //9480 患者更新(身体情報),检查计算 gjn end
      //10147 患者情報を更新時に検査計算(更新)されない gjn end

      //通知送信
      // 次患者情報（コメントデータ）が更新されない 張 start
      if (payload.containsKey("has_been_added")) {
      // 次患者情報（コメントデータ）が更新されない 張 end
        String hasBeenAdded = payload.get("has_been_added");
        // #10443 身体情報DW更新時、連携イベント
        String editMod = payload.get("edit_mod");
        // #9929 mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-07-01 start
        String targetWeightFlag = payload.get("target_weight_flag");
        // if (hasBeenAdded.equals("1")) {
        if ("1".equals(hasBeenAdded) || "1".equals(targetWeightFlag)) {

          if ("I".equals(editMod)) {
            // 基本的情報を持った変換用JSONデータを作成
            JSONObject replaceData = new JSONObject();
            String facilityCd = patPersonalMain.getFacility_cd();
            replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
            replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
            replaceData.put("PATID", String.valueOf(pat_id));
            replaceData.put("FACILITYCD", facilityCd);
            webApiCallCommonUtil.registerNotification(NotificationDefinition.ADD_DW, facilityCd, replaceData);
          }

          // #10553 mod 連携イベント発生部分不正【最優先】③ 荘 2024-07-01 start
        }
//          // #10443 身体情報DW更新時、連携イベント
//          String opeCd;
//          // switch (editMod) {
//          //   case "I" -> opeCd = "004014";
//          //   case "U", "D" -> opeCd = "004013";
//          //   default -> opeCd = null;
//          // }
//          // #9929 mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-07-01 end
//
//          // #9929 mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-07-03 start
//          // if (CollectionUtils.isNotEmpty(effectsIntervalOrdNoList) && StringUtils.hasText(opeCd)) {
//          if (CollectionUtils.isNotEmpty(effectsIntervalOrdNoList)) {
//          // #9929 mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-07-03 end
//            List<JournalCreateRequestPayload> journalCreateRequestPayloadList
//              = new ArrayList<>(effectsIntervalOrdNoList.size());
//            for (int i = 0; i < effectsIntervalOrdNoList.size(); i++) {
//              // #9929 add 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-24 start
//              // クールなしの治療予定の連携イベントが発行しない
//              if (0 == effectsIntervalOrdNoList.get(i).getIndKurCd()) {
//                continue;
//              }
//              // ope_cdの設定
//              if (effectsIntervalOrdNoList.get(i).getIndTreatmentCd() != null
//                && !effectsIntervalOrdNoList.get(i).getIndTreatmentCd().isEmpty()) {
//                opeCd = "004014";
//              } else {
//                opeCd = "004013";
//              }
//              // #9929 add 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-24 end
//              // ャーナルパラメータ作成
//              journalCreateRequestPayloadList.add(
//                BeanBuilderUtils.of(JournalCreateRequestPayload::new)
//                  .with(JournalCreateRequestPayload::setFacilityCd, user.getFacilityCd())
//                  .with(JournalCreateRequestPayload::setOpeCd, opeCd)
//                  .with(JournalCreateRequestPayload::setCoopCd, "ind_dial")
//                  .with(JournalCreateRequestPayload::setCoopCdIndex, "")
//                  .with(JournalCreateRequestPayload::setCrud, "U")
//                  .with(JournalCreateRequestPayload::setDirection, "S")
//                  .with(JournalCreateRequestPayload::setAnaResult, "0")
//                  .with(JournalCreateRequestPayload::setCoopResult, "0")
//                  .with(JournalCreateRequestPayload::setPatId, pat_id)
//                  .with(JournalCreateRequestPayload::setHospPatId, patPersonalMain.getHosp_pat_id())
//                  .with(JournalCreateRequestPayload::setOrdNo, effectsIntervalOrdNoList.get(i).getOrdNo())
//                  .with(JournalCreateRequestPayload::setBaseDate, effectsIntervalOrdNoList.get(i).getTreatDate())
//                  .with(JournalCreateRequestPayload::setUserId, user.getUserId())
//                  .build()
//              );
//            }
//            //ャーナル更新APIリクエスト
//            journalService.callCreateJournalForCtrNo(journalCreateRequestPayloadList);
//          }
//        }
//        // #9929 del 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 start
//        // else {
//        // #9929 del 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 end
//        String opeCd;
//        switch (editMod) {
//          case "I" -> opeCd = "007004";
//          case "U" -> opeCd = "007005";
//          case "D" -> opeCd = "007006";
//          default -> opeCd = null;
//        }
//
//        // #9929 add 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 start
//        String baseDate;
//        if ((Boolean) (new JSONObject(payload.get("dw_log_info")).get("is_delete"))) {
//          baseDate = new JSONObject(payload.get("dw_log_info")).get("examTime_pre").toString();
//        } else {
//          baseDate = new JSONObject(payload.get("dw_log_info")).get("examTime_aft").toString();
//        }
//        LocalDate localDate;
//        if (baseDate.length() > 10) {
//          localDate = OffsetDateTime.parse(baseDate, DateTimeFormatter.ISO_OFFSET_DATE_TIME).toLocalDate();
//        } else {
//          localDate = LocalDate.parse(baseDate, DateTimeFormatter.ISO_DATE);
//        }
//
//        // #9929 add 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 end
//
//        if (StringUtils.hasText(opeCd)) {
//          List<JournalCreateRequestPayload> journalCreateRequestPayloadList = List.of(
//            BeanBuilderUtils.of(JournalCreateRequestPayload::new)
//              .with(JournalCreateRequestPayload::setFacilityCd, user.getFacilityCd())
//              .with(JournalCreateRequestPayload::setOpeCd, opeCd)
//              .with(JournalCreateRequestPayload::setCrud, "U")
//              .with(JournalCreateRequestPayload::setPatId, pat_id)
//              .with(JournalCreateRequestPayload::setHospPatId, patPersonalMain.getHosp_pat_id())
//              .with(JournalCreateRequestPayload::setOrdNo, null)
//              // #9929 mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 start
//              //.with(JournalCreateRequestPayload::setBaseDate, LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")))
//              .with(JournalCreateRequestPayload::setBaseDate, localDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")))
//              // #9929 mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 end
//              .with(JournalCreateRequestPayload::setUserId, user.getUserId())
//              .build()
//          );
//
//          //ャーナル更新APIリクエスト
//          journalService.callCreateJournalForCtrNo(journalCreateRequestPayloadList);
//        // #9929 del 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 start
//        // }
//        // #9929 del 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 end
//        }
        String baseDate;
        if ((Boolean) (new JSONObject(payload.get("dw_log_info")).get("is_delete"))) {
          baseDate = new JSONObject(payload.get("dw_log_info")).get("examTime_pre").toString();
        } else {
          baseDate = new JSONObject(payload.get("dw_log_info")).get("examTime_aft").toString();
        }
        // mod #10553 連携イベント発生部分不正【最優先】ope_cd修正 荘 2024-07-30 start
        // journalService.sendJournalForDwAndTw(pat_id, effectsIntervalOrdNoList, user.getUserId(), user.getFacilityCd(), editMod, baseDate);
        if ("1".equals(hasBeenAdded) || "1".equals(targetWeightFlag)){
          journalService.sendJournalForDwAndTw(pat_id, effectsIntervalOrdNoList, user.getUserId(), user.getFacilityCd(), editMod, baseDate);
        } else {
          journalService.sendJournalForNotDwAndTw(pat_id, user.getUserId(), user.getFacilityCd(), editMod, baseDate);
        }
        // mod #10553 連携イベント発生部分不正【最優先】ope_cd修正 荘 2024-07-30 end

        // #10553 mod 連携イベント発生部分不正【最優先】③ 荘 2024-07-01 start
      //6590 次患者情報（コメントデータ）が更新されない 張 start
      }
      //6590 次患者情報（コメントデータ）が更新されない 張 end
      // mod FNSI-排他処理 劉 start
      //return new ResponseEntity<>(HttpStatus.OK);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>("",HttpStatus.OK);
    } catch (OptimisticLockException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HAITACODE, HttpStatus.BAD_REQUEST);
      // mod FNSI-排他処理 劉 end
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      eventLogMessage.setPatId(String.valueOf(pat_id));
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // mod FNSI-排他処理 劉 start
      //return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>("",HttpStatus.BAD_REQUEST);
      // mod FNSI-排他処理 劉 end
    }
  }

  // add #10147 患者情報を更新時に検査計算(更新)されない zkm start
  private List<String> findFirstDifference(List<Map<String, String>> before, List<Map<String, String>> after) {
    before.sort(Comparator.comparing(m -> m.get("date")));
    after.sort(Comparator.comparing(m -> m.get("date")));
    int size = Math.min(before.size(), after.size());
    if (0 == size || before.equals(after)) {
      return new ArrayList<>();
    }
    for (int i = 0; i < size; i++) {
      Map<String, String> b = before.get(i);
      Map<String, String> a = after.get(i);
      boolean dateDiff = !b.get("date").equals(a.get("date"));
      boolean heightDiff = !b.get("height").equals(a.get("height"));
      if (dateDiff || heightDiff) {
        if (after.size() >= before.size()) {
          return Arrays.asList(a.get("date").substring(0, 10), size > i + 1 ? after.get(i + 1).get("date").substring(0, 10) : null);
        } else {
          return Arrays.asList(b.get("date").substring(0, 10), size > i + 1 ? before.get(i + 1).get("date").substring(0, 10) : null);
        }
      }
    }
    if (after.size() > before.size()) {
      return Arrays.asList(after.get(size).get("date").substring(0, 10), null);
    } else {
      return Arrays.asList(before.get(size).get("date").substring(0, 10), null);
    }
  }
  // add #10147 患者情報を更新時に検査計算(更新)されない zkm end

  // add FNSI-保険選択の変更 関 start
  @PutMapping("/updateInsuranceSelectById/{patId}")
  public ResponseEntity<String> updateInsuranceSelectById(@PathVariable long patId, @RequestBody Map<String, Long> payload) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/updateInsuranceSelectById/{patId}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patInfoService.updateInsuranceSelectById(patId, payload.get("insuranceCd"), payload.get("isSelected").intValue());
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>("",HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      eventLogMessage.setPatId(String.valueOf(patId));
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 患者情報取得
   * @param pat_id 該当患者の患者ID
   * @return 対象患者の患者情報
   */
  @GetMapping("/getPatById/{pat_id}")
  public ResponseEntity<Map<String, String>> getPatById(
      @PathVariable long pat_id,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getPatById/{pat_id}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    Map<String, String> patInfoJson = null;
    try {
      patInfoJson = patInfoService.selectById(pat_id, ntssUser.getFacilityCd());
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      eventLogMessage.setPatId(String.valueOf(pat_id));
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    if (patInfoJson == null) {
      // 患者0件
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(patInfoJson, HttpStatus.OK);
  }

//  nkk-外部結合テストNo.80 姜 start
  /**
   * 患者情報取得
   * @param pat_id 該当患者の患者ID
   * @return 対象患者の患者情報
   */
  @GetMapping("/getPatInfoById/{pat_id}")
  public ResponseEntity<List<PatUnique>>  getPatInfoById(
    @PathVariable long pat_id) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getPatInfoById/{pat_id}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<PatUnique> patInfoJson = null;
    try {
      patInfoJson = patInfoService.selectPatInfoById(pat_id);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      eventLogMessage.setPatId(String.valueOf(pat_id));
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    if (patInfoJson == null) {
      // 患者0件
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(patInfoJson, HttpStatus.OK);
  }
//  nkk-外部結合テストNo.80 姜 end

  // mod #12462 患者情報共有- 患者カレンダー zrx start
//  @GetMapping("/getPatSharingById/{pat_id}")
  @GetMapping({"/getPatSharingById/{pat_id}", "/getPatSharingById/{pat_id}/{facilityCd}"})
  public ResponseEntity<Map<String, String>> getPatById(
      @PathVariable long pat_id,
      @PathVariable(required = false) String facilityCd) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getPatSharingById/{pat_id}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
    // add FNSi5712アプリケーションログが出力しない 周 end
    Map<String, String> patInfoJson = null;
    try {
      if (StringUtils.isEmpty(facilityCd)) {
        patInfoJson = patInfoService.selectPatSharingById(pat_id);
      } else {
        patInfoJson = patInfoService.selectPatSharingById(pat_id,facilityCd);
      }
      // mod #12462 患者情報共有- 患者カレンダー zrx end
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_PAT_INFO,SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    if (patInfoJson == null) {
      // 患者0件
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(patInfoJson, HttpStatus.OK);
  }

  //add #12462 患者共有情報- 患者カレンダー  by zrx start
  /**
   * 現在の施しidは過去の施し情報を取得する
   * @param pat_id 現在の施しid
   * @return
   */
  @GetMapping("/getPatHospitalById/{pat_id}")
  public ResponseEntity<List<PatHistoryInfo>> getPatHospitalById(@PathVariable long pat_id, @AuthenticationPrincipal NtssUser ntssUser) {
    String mappingUrl = Uri.PAT_INFO + "/getPatHospitalById/{pat_id}";
    try {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
      List<PatHistoryInfo> patHospitalById = patInfoService.getPatHospitalById(pat_id,ntssUser.getFacilityCd());
      return new ResponseEntity<>(patHospitalById, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_PAT_INFO,SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  //add #12462 患者共有情報- 患者カレンダー  by zrx end

  /**
   * 患者情報取得
   * @param pat_id 該当患者の患者ID
   * @return 対象患者の患者情報
  */
  @GetMapping({"/getPatInsuById/{pat_id}","/getPatInsuById/{pat_id}/{facilityCd}"})
  public ResponseEntity<?> getPatInsuById(@PathVariable long pat_id,@PathVariable(required = false) String facilityCd) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getPatInsuById/{pat_id}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      return new ResponseEntity<>(patInfoService.selectInsuById(pat_id,facilityCd), HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      eventLogMessage.setPatId(String.valueOf(pat_id));
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 簡易検索
   * @param searchConditions 検索条件
   * @return 条件を満たす患者のリスト
   */
  @PostMapping("/getSimpleSearchResult")
  public ResponseEntity<List<PatPersonalMainData>> getSimpleSearchResult(
      @RequestBody SimpleSearchRequest searchConditions,
      @AuthenticationPrincipal NtssUser ntssUser) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getSimpleSearchResult";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchConditions, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<String> facilityCdList = searchConditions.getFacilityCdList();
    if (facilityCdList == null || facilityCdList.size() == 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("詳細検索条件に施設コードリストが含まれていない");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchConditions, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
    }

    try {
      List<PatPersonalMainData> patList = patInfoService.getPatInfoBySimpleSearchCondition(searchConditions, ntssUser.getFacilityCd());
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchConditions, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(patList, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchConditions, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  // add マスタ一覧 1･施設切替を可能とする 孔 start
  @PostMapping("/getSimpleSearchResult/{facilityCd}")
  public ResponseEntity<List<PatPersonalMainData>> getSimpleSearchResultByFacilityCd(
      @RequestBody SimpleSearchRequest searchConditions,
      @PathVariable String facilityCd) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getSimpleSearchResult/{facilityCd}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchConditions, facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<String> facilityCdList = searchConditions.getFacilityCdList();
    if (facilityCdList == null || facilityCdList.size() == 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("詳細検索条件に施設コードリストが含まれていない");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchConditions, facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
    }
    try {
      List<PatPersonalMainData> patList = patInfoService.getPatInfoBySimpleSearchCondition(searchConditions, facilityCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchConditions, facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(patList, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchConditions, facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add マスタ一覧 1･施設切替を可能とする 孔 end

  /**
   * 詳細検索
   * @param searchConditions 検索条件
   * @return 条件を満たす患者のリスト
   */
  @PostMapping("/getDetailedSearchResult")
  public ResponseEntity<List<PatPersonalMainData>> getDetailedSearchResult(
      @RequestBody DetailedSearchRequest searchConditions,
      @AuthenticationPrincipal NtssUser ntssUser) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getDetailedSearchResult";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchConditions, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<String> facilityCdList = searchConditions.getFacilityCdList();
    if (facilityCdList == null || facilityCdList.size() == 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("詳細検索条件に施設コードリストが含まれていない");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchConditions, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
    }

    try {
      List<PatPersonalMainData> patList = patInfoService.getPatInfoByDetailedSearchCondition(searchConditions, ntssUser.getFacilityCd());
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchConditions, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(patList, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchConditions, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  //add 5127 透析レポート印刷時の条件について 吉 start
  @GetMapping("/checkIsPrint")
  public ResponseEntity<Object> checkIsPrint(
    @RequestParam(value = "facility_cd", required = true) String facility_cd,
    @RequestParam(value = "pat_id", required = true) String pat_id,
    @RequestParam(value = "treatDate", required = false) String treatDate,
    @RequestParam(value = "reportCd", required = true) Integer reportCd,
    @AuthenticationPrincipal NtssUser ntssUser) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/checkIsPrint";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facility_cd,
        pat_id, treatDate, treatDate, reportCd, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    Map<String,Object>parm = new HashMap<>();
    parm.put("facilityCd",facility_cd);
    parm.put("patId",pat_id);
    parm.put("treatDate",treatDate);
    parm.put("reportCd",reportCd);
    try {
      int count = patInfoService.checkIsPrint(parm);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facility_cd,
          pat_id, treatDate, treatDate, reportCd, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(count, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facility_cd != null) {
        eventLogMessage.setFacilityCd(facility_cd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facility_cd,
          pat_id, treatDate, treatDate, reportCd, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
//add 5127 透析レポート印刷時の条件について 吉 start
  /**
   * 患者情報検索
   * @return 条件を満たす患者のリスト
   */
  @PostMapping("/getPatPersonalMainByList")
  public ResponseEntity<List<PatPersonalMainData>> getPatPersonalMainByList(
      @RequestBody List<Long> patIdList,
      @AuthenticationPrincipal NtssUser ntssUser
      ) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getPatPersonalMainByList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patIdList, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      List<PatPersonalMainData> patList = patInfoService.getPatPersonalMainByList(patIdList, ntssUser.getFacilityCd());
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patIdList, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(patList, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patIdList, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 患者情報リスト取得
   * @return 対象患者の患者情報リスト
   */
  @PostMapping("/getPatByIdList/{postType}")
  public ResponseEntity<Map<String, String>> getPatByIdList(
    @RequestBody PatInfoRequest bodyData,
    @PathVariable Integer postType,
    @AuthenticationPrincipal NtssUser ntssUser
    ) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getPatByIdList/{postType}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bodyData, postType, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    if (null != bodyData.getPatIdList()) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("patIdList:" + bodyData.getPatIdList().toString());
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    } else {
      bodyData.setPatIdList(new ArrayList<Long>());
    }

    List<Map<String, Object>> tmpPatListSort = new ArrayList<>();
    Map<String, String> patInfoJson = null;
    try {
      //mod 10389 バックエンド患者リスト順序付け機能処理 gjn start
      long startTime = System.currentTimeMillis();
      if (postType == 1) {
        // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
        long endTime = System.currentTimeMillis();
        long executionTime = (endTime - startTime); // Convert milliseconds to millisecond
        System.err.println("QUERY: （ミリ秒）" + executionTime + " millisecond");
        long startTimeSort = System.currentTimeMillis();
        tmpPatListSort = bodyData.getTmpPatList();
        if (!Objects.isNull(tmpPatListSort) && !tmpPatListSort.isEmpty()) {
          List<OrdMainKurBed> list = null;
          List<Map<String, Object>> sortConditions = bodyData.getSortConditions().isEmpty() ? makeSortRule() : bodyData.getSortConditions();
          boolean treatSortFlag = sortConditions.stream()
            .filter(map -> map.get("key") != null).anyMatch(map ->map.get("key").equals("pat_kur") || map.get("key").equals("pat_bed_name")
            || map.get("key").equals("ind_tr_cd"));
          // 治療のソートに関するデータの収集
          if (treatSortFlag && bodyData.getDetailedCondtion() != null) {
            list = patInfoService.getDetailedSimpleConditionFilterOrdMain(bodyData.getDetailedCondtion(), bodyData.getPatIdList(), ntssUser.getFacilityCd());
          }
          // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
          // 患者のソートに関するデータの収集
          patInfoJson = patInfoService.selectPatByIdList(sortConditions,bodyData.getPatIdList(), ntssUser.getFacilityCd());

          // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
          List<MstWheelChair> chairs = mstWheelChairDao.selectByFacility(bodyData.getFacilityCd(), "1", "0");

          // ソートキーが全てnullの場合、デフォルトソートにする(患者id, 昇順)
          if (sortConditions.stream().filter(map -> map.get("key") != null).toList().isEmpty()) {
            sortConditions.get(0).put("key", "hosp_pat_id");
            sortConditions.get(0).put("isAsc", 1);
          }
          // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end

          // 共通storesを除く患者の順序は患者id昇順に表示される
          PatSortCommonUtil.sortList(tmpPatListSort, sortConditions, patInfoJson, list, chairs);
          //パフォーマンステスト
          long endTimeSort = System.currentTimeMillis();
          long executionTimeSort = (endTimeSort - startTimeSort); // Convert milliseconds to millisecond
          System.err.println("Sort: （ミリ秒）" + executionTimeSort + " millisecond");
          ObjectMapper mapper = new ObjectMapper();
          patInfoJson.put("tmpPatListSort", mapper.writeValueAsString(tmpPatListSort));
        }
      } else {
        //データリスト postType == 2
        patInfoJson = patInfoService.selectByIdList(bodyData.getPatIdList(), ntssUser.getFacilityCd(), postType);
      }
      //mod 10389 バックエンド患者リスト順序付け機能処理 gjn end
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bodyData, postType, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    if (patInfoJson == null) {
      // 患者件数異常
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bodyData, postType, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bodyData, postType, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(patInfoJson, HttpStatus.OK);
  }

  /**
   * 患者のデフォルト順序付け規則
   *
   * @return
   */
  private List<Map<String, Object>> makeSortRule() {
    List<Map<String, Object>> mapList = new ArrayList<>();
    Map<String, Object> map = new HashMap<>();
    map.put("key", null);
    map.put("isAsc", 0);
    for (int i=0; i<3; i++) {
      mapList.add(map);
    }
    return mapList;
  }

  /**
   * 患者情報リスト取得用.
   * @param request 抽出条件
   * @param ntssUser 認証利用者情報
   * @return 患者リスト
   * @throws Exception
   */
  @PostMapping("/getPatMainByIdList")
  public ResponseEntity<?> getPatMainByIdList(
    @RequestBody PatInfoRequest request,
    @AuthenticationPrincipal NtssUser ntssUser
    ) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getPatMainByIdList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(request, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    if (null == request.getPatIdList()) {
        request.setPatIdList(new ArrayList<Long>());
    }
    try {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(request, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(patInfoService.selectPatMainByIdList(request.getPatIdList(), ntssUser.getFacilityCd()), HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(request, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 施設内の患者名一覧取得
   * @return 患者名リスト
   */
  @PostMapping("/getPatByFacilityCd")
  public ResponseEntity<List<PatPersonalMain>> getPatByFacilityCd(@RequestBody List<String> facilityCdList) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getPatByFacilityCd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCdList));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      List<PatPersonalMain> patList = patInfoService.getPatByFacilityCd(facilityCdList);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCdList));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(patList, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCdList));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /* add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --start */
  /**
   * 患者情報リスト取得
   * @return 対象患者の患者情報リスト
   */
  @PostMapping("/getPatByIdList")
  public ResponseEntity<List<PatByFCAndPIdsResponse>> getPatByIdList(@RequestBody List<Long> patIdList,
                                                                     @AuthenticationPrincipal NtssUser ntssUser) throws Exception {
    String mappingUrl = Uri.PAT_INFO + "/getPatByIdList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
            BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patIdList, ntssUser));
    try {
      List<PatByFCAndPIdsResponse> patList = patInfoService.getPatByFacilityAndIds(patIdList, ntssUser.getFacilityCd());
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
              AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patIdList, ntssUser));
      return new ResponseEntity<>(patList, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
              AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patIdList, ntssUser));
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  /* add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --end */

  /**
   * 院内表示用患者ID重複患者件数取得
   * @param PatPersonalMain 抽出条件
   * @return 院内表示用患者ID重複患者件数
   */
  @PostMapping("/getSameHospPatIdCnt")
  public ResponseEntity<Long> getSameHospPatIdCnt(
    @RequestBody PatPersonalMain bodyData
    ) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getSameHospPatIdCnt";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bodyData));
    // add FNSi5712アプリケーションログが出力しない 周 end
    // 受信データチェック
    if (null != bodyData.getFacility_cd()) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("facility_cd:" + bodyData.getFacility_cd());
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    } else {
      // 施設情報異常
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("施設が指定されていません");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bodyData));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    if (null != bodyData.getPat_id()) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("pat_id:" + bodyData.getPat_id().toString());
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    }
    if (null != bodyData.getHosp_pat_id()) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("hosp_pat_id:" + bodyData.getHosp_pat_id());
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    } else {
      // 院内表示用患者ID異常
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("院内表示用患者IDが指定されていません");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bodyData));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    Long patCnt = null;
    try {
      patCnt = patPersonalMainDao.selectByHospPatId(bodyData.getFacility_cd(), bodyData.getHosp_pat_id(), bodyData.getPat_id());
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bodyData));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bodyData));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(patCnt, HttpStatus.OK);
  }

  /**
   * 同姓同名患者リスト取得
   * @param PatPersonalMain 抽出条件
   * @return 対象患者の患者情報リスト
   */
  @PostMapping("/getSameNamePatInfoList")
  public ResponseEntity<List<PatInfoResponse>> getSameNamePatInfoList(
    @RequestBody PatPersonalMain bodyData
    ) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getSameNamePatInfoList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bodyData));
    // add FNSi5712アプリケーションログが出力しない 周 end
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    // 受信データチェック
    if (null != bodyData.getFacility_cd()) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("facility_cd:" + bodyData.getFacility_cd());
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    } else {
      // 施設情報異常
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      //EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage = new EventLogMessage();
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      eventLogMessage.setLogMessage("施設が指定されていません");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bodyData));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    if (null != bodyData.getPat_id()) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("pat_id:" + bodyData.getPat_id().toString());
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    }
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("pat_last_name:" + bodyData.getPat_last_name()
      +" pat_first_name:" + bodyData.getPat_first_name()
      +" pat_last_name_kana:" + bodyData.getPat_last_name_kana()
      +" pat_first_name_kana:" + bodyData.getPat_first_name_kana()
      +" pat_last_name_alpha:" + bodyData.getPat_last_name_alpha()
      +" pat_first_name_alpha:" + bodyData.getPat_first_name_alpha()
    );
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end

    List<PatPersonalMain> patInfo = null;
    try {
      patInfo = patPersonalMainDao.selectByPatName(
          bodyData.getFacility_cd(),
          bodyData.getPat_last_name(),
          bodyData.getPat_first_name(),
          bodyData.getPat_last_name_kana(),
          bodyData.getPat_first_name_kana(),
          bodyData.getPat_last_name_alpha(),
          bodyData.getPat_first_name_alpha(),
          bodyData.getPat_id());
    } catch (Exception e) {
//      e.printStackTrace();
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      //EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage = new EventLogMessage();
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bodyData));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    List<PatInfoResponse> retInfoList = new ArrayList<PatInfoResponse>();
    for (int i = 0; i < patInfo.size(); i++) {
      PatInfoResponse retInfo = new PatInfoResponse();
      retInfo.setPat_id(patInfo.get(i).getPat_id());
      retInfo.setHosp_pat_id(patInfo.get(i).getHosp_pat_id());
      retInfo.setFacility_cd(patInfo.get(i).getFacility_cd());
      retInfo.setPat_last_name(patInfo.get(i).getPat_last_name());
      retInfo.setPat_first_name(patInfo.get(i).getPat_first_name());
      retInfo.setPat_last_name_kana(patInfo.get(i).getPat_last_name_kana());
      retInfo.setPat_first_name_kana(patInfo.get(i).getPat_first_name_kana());
      retInfo.setPat_last_name_alpha(patInfo.get(i).getPat_last_name_alpha());
      retInfo.setPat_first_name_alpha(patInfo.get(i).getPat_first_name_alpha());
      retInfoList.add(retInfo);
    }

    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bodyData));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(retInfoList, HttpStatus.OK);
  }

  /**
   * 施設内患者の連絡先参照
   * @param PatInfoRequest 抽出条件
   * @return 対象患者の患者情報リスト
   */
  @GetMapping("/getPatContactInfo")
  public ResponseEntity<List<PatPersonalMain>> getPatContactInfo(
      @AuthenticationPrincipal NtssUser ntssUser) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getPatContactInfo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<PatPersonalMain> patList = null;
    try {
      // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
      // 施設内の全患者を取得
      // patList = patPersonalMainDao.selectByIdListFacilityCd(new ArrayList<Long>(), ntssUser.getFacilityCd());
      patList = patPersonalMainDao.selectByIdListFacilityCdIncludeDel(new ArrayList<Long>(), ntssUser.getFacilityCd());
      // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    // 連絡先設定に必要な情報のみにする
    List<PatPersonalMain> patListOnlyContactInfo = new ArrayList<PatPersonalMain>();
    for (PatPersonalMain pat: patList) {
      PatPersonalMain patOnlyContactInfo = new PatPersonalMain();
      patOnlyContactInfo.setPat_id(pat.getPat_id());
      patOnlyContactInfo.setFacility_cd(pat.getFacility_cd());
      patOnlyContactInfo.setHosp_pat_id(pat.getHosp_pat_id());
      patOnlyContactInfo.setPat_last_name(pat.getPat_last_name());
      patOnlyContactInfo.setPat_first_name(pat.getPat_first_name());
      patOnlyContactInfo.setPat_last_name_kana(pat.getPat_last_name_kana());
      patOnlyContactInfo.setPat_first_name_kana(pat.getPat_first_name_kana());
      patOnlyContactInfo.setPat_contact_info(pat.getPat_contact_info());
      // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
      patOnlyContactInfo.setIs_del(pat.getIs_del());
      // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
      patListOnlyContactInfo.add(patOnlyContactInfo);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(patListOnlyContactInfo, HttpStatus.OK);
  }

  /**
   * 同姓同名フラグ更新
   */
  @PostMapping("/updateIsSame")
  public ResponseEntity<Void> updateIsSame(@RequestBody Map<String, String> payload) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/updateIsSame";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patInfoService.updateIsSame(payload);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 確定・予定転入出状態更新
   */
  @PostMapping("/updateInOutState/{pat_id}")
  public ResponseEntity<Map<String, Object>> updateInOutState(
      @PathVariable long pat_id,
      @RequestBody Map<String, String> payload,
      @AuthenticationPrincipal NtssUser ntssUser) throws Exception {

    //add #10412 次患者更新関連全体見直し対応 朴 start
    ResponseEntity<Map<String, Object>> response = null;
    //add #10412 次患者更新関連全体見直し対応 朴 end

    //add #10412 次患者更新関連全体見直し対応 朴 start
    List<OrdMain> doCallNextPatOrdMainList = new ArrayList<>();
    PatPersonalMain beforePatPersonalMain = patPersonalMainDao.selectById(pat_id);
    //add #10412 次患者更新関連全体見直し対応 朴 end

    //mod #10412 次患者更新関連全体見直し対応 朴 start
    /* add by chenshijie  2023-02-02 [CodeOptimization]  */
    response =  patInfoService.updateInOutStateService(pat_id,payload,ntssUser);
    /* del by chenshijie  2023-02-02 [CodeOptimization]  start */
    //mod #10412 次患者更新関連全体見直し対応 朴 end

    //add #10412 次患者更新関連全体見直し対応 朴 start
    PatPersonalMain afterPatPersonalMain = patPersonalMainDao.selectById(pat_id);

    String facilityCd = beforePatPersonalMain.getFacility_cd();
    List<MntMachineState> mntMachineStateList = mntMachineStateDao.selectByNextPatIdList(facilityCd, Arrays.asList(pat_id));
    List<Long> ordNoList = mntMachineStateList.stream().map(item -> item.getNextOrdNo()).distinct().collect(Collectors.toList());
    List<OrdMain> ordMainList = ordMainDao.selectByOrdNoList(ordNoList);

    List<Integer> bedCdList = mntMachineStateList.stream().map(item -> item.getBedCd().intValue()).distinct().collect(Collectors.toList());
    List<MstComsvSetting> mstComsvInfos = mstComsvSettingDao.selectByBedCds(facilityCd, bedCdList);
    Map<Integer,MstComsvSetting> mstComsvInfosMap = mstComsvInfos.stream().collect(Collectors.toMap(o -> o.getNextPatMode(), o -> o));
    for(OrdMain ordMain: ordMainList){
      if(nextPatService.CheckDoCallNextPatChangeForPatMemo(facilityCd, ordMain.getIndBedCd(), null, null, beforePatPersonalMain, afterPatPersonalMain, mstComsvInfosMap.get(ordMain.getIndBedCd()))){
        doCallNextPatOrdMainList.add(ordMain);
      }
    }

    nextPatService.CallNextPatChange(facilityCd, doCallNextPatOrdMainList);
    //add #10412 次患者更新関連全体見直し対応 朴 end

    //add #10412 次患者更新関連全体見直し対応 朴 start
    return response;
    //add #10412 次患者更新関連全体見直し対応 朴 end

//    // add FNSi5712アプリケーションログが出力しない 周 start
//    String mappingUrl = Uri.PAT_INFO + "/updateInOutState/{pat_id}";
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
//      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload, ntssUser));
//    // add FNSi5712アプリケーションログが出力しない 周 end
//    try {
//      Map<String, String> patInfo = patInfoService.selectById(pat_id, ntssUser.getFacilityCd());
//      ObjectMapper mapper = new ObjectMapper();
//      PatPersonalMain patPersonalMain = mapper.readValue(patInfo.get("pat_personal_main"), PatPersonalMain.class);
//      String is_die = patPersonalMain.getIs_die();
//      String facility_cd = payload.get("facility_cd");
//      // DB入外区分取得
//      Map<String, String> patInfoJson = null;
//      patInfoJson = patInfoService.selectById(pat_id, ntssUser.getFacilityCd());
//      PatPersonalMain initPatPersonalMain = mapper.readValue(patInfoJson.get("pat_personal_main"), PatPersonalMain.class);
//      Integer initInOutClass = initPatPersonalMain.getIn_out_class();
//
//      if ("1".equals(is_die)) {
//        // 死亡フラグが立っている場合
//
//        // 死亡コード
//        Integer death_cd = 2;
//        // 確定・予定転入出状態更新・入外区分更新
//        // 確定・予定転入出状態死亡設定がないためnullへ・入外区分死亡へ
//        patInfoService.updateInOut(pat_id, null, null, null, death_cd, payload);
//        // modify by maxueqiang
//        if (null != initInOutClass) {
//          // 入外区分が変更された場合:次患者更新
//          patInfoService.comSvNotifySetNextPatInfo(facility_cd, pat_id);
//        }
//        //add FNSI-画面部品デザイン じょはく start
//        //mod No.20 じょはく start
//        patInfoService.updateInOut(pat_id, null, null, null, 2, payload);
//        //mod No.20 じょはく end
//        //add FNSI-画面部品デザイン じょはく end
//        Map<String, Object> in_out_info = setMoveInOutInfo(null, death_cd);
//        // add FNSi5712アプリケーションログが出力しない 周 start
//        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
//          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload, ntssUser));
//        // add FNSi5712アプリケーションログが出力しない 周 end
//        return new ResponseEntity<>(in_out_info, HttpStatus.OK);
//      }
//
//      /* 転入・転出履歴取得 */
//      //  mod FNSI- 徐博 start
//      List<Map<String, Object>> inOut = patInfoService.selectInOut(pat_id, ntssUser.getFacilityCd());
//      //  mod FNSI- 徐博 end
//      if (inOut == null) {
//        // 確定・予定転入出状態null更新・入外区分null更新
//        // mod FNSI- 徐博 start
//        // 本人情報の入外は不明の時、in_out_classは3(不明)に変わる
//        // patInfoService.updateInOut(pat_id, null, null, null, null, payload);
//        patInfoService.updateInOut(pat_id, null, null, null, 3, payload);
//        // mod FNSI- 徐博 end
//        if (initInOutClass != null) {
//          // 入外区分が変更された場合:次患者更新
//          patInfoService.comSvNotifySetNextPatInfo(facility_cd, pat_id);
//        }
//
//        Map<String, Object> in_out_info = setMoveInOutInfo(null, null);
//        // add FNSi5712アプリケーションログが出力しない 周 start
//        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
//          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload, ntssUser));
//        // add FNSi5712アプリケーションログが出力しない 周 end
//        return new ResponseEntity<>(in_out_info, HttpStatus.OK);
//      }
//
//      // 転入出履歴を1件ずつチェック
//      int numberDate = Integer.parseInt(DateTimeFormatter.ofPattern("uuuuMMdd").format(LocalDateTime.now()));
//      String targetDt = "";
//      // 翌日処理する転入出情報("転出","離脱","移植","一時転出")
//      List<String> lstMoveInOutNextDay = new ArrayList<String>();
//      lstMoveInOutNextDay.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_MOVING_OUT);
//      lstMoveInOutNextDay.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_WITHDRAWAL);
//      lstMoveInOutNextDay.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_IMPLANTATION);
//      lstMoveInOutNextDay.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_TEMPORARILY_MOVING_OUT);
//
//      //add FNSI-「本人情報」の「入外区分」と「入外・転入出」の「区分」を一致させる 鄧シン start
//      if (inOut.get(inOut.size() - 1).get("move_in_out") == null && initInOutClass != null){
//        Integer inoutClass = null;
//        if ("0".equals(initInOutClass.toString()) || "1".equals(initInOutClass.toString())){
//          inoutClass = initInOutClass + 2;
//          inOut.get(inOut.size() - 1).put("move_in_out", inoutClass.toString());
//          patInfoService.updateInOut(pat_id, null, initInOutClass.toString(), null, null, payload);
//        }
//      } else if (inOut.get(inOut.size() - 1).get("move_in_out") != null && initInOutClass == null){
//        if ("2".equals(inOut.get(inOut.size() - 1).get("move_in_out")) || "3".equals(inOut.get(inOut.size() - 1).get("move_in_out"))){
//          initInOutClass = Integer.valueOf(inOut.get(inOut.size() - 1).get("move_in_out").toString());
//          patInfoService.updateInOutClassById(pat_id, initInOutClass, payload);
//        }
//      }
//      //add FNSI-「本人情報」の「入外区分」と「入外・転入出」の「区分」を一致させる 鄧シン end
//
//      for (int i = 0; inOut.size() > i; i++) {
//        if (inOut.get(i).get("move_in_out") == null || inOut.get(i).get("period_start") == null) {
//          //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
//          EventLogMessage eventLogMessage = new EventLogMessage();
//          eventLogMessage.setLogMessage("区分または日付が入力されていません");
//          logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
//          //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
//          Map<String, Object> in_out_info = setMoveInOutInfo(null, null);
//          // add FNSi5712アプリケーションログが出力しない 周 start
//          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
//            AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload, ntssUser));
//          // add FNSi5712アプリケーションログが出力しない 周 end
//          return new ResponseEntity<>(in_out_info, HttpStatus.OK);
//        }
//        // 当日を含む直近過去日付を保持
//        if (targetDt.equals("")) {
//          int periodStart = Integer.parseInt(inOut.get(i).get("period_start").toString());
//          String moveInOut = inOut.get(i).get("move_in_out").toString();
//          // 当日以前の日付
//          if (periodStart == numberDate && !lstMoveInOutNextDay.contains(moveInOut)) {
//            // 当日分は"導入","転入","入院","退院","外来","通院拒否・不明"のみを処理
//            targetDt = inOut.get(i).get("period_start").toString();
//          } else if (periodStart < numberDate) {
//            // 過去日の入外区分
//            if (lstMoveInOutNextDay.contains(moveInOut)) {
//              // "転出","離脱","移植","一時転出"は翌日処理なので１日加算
//              targetDt = DateTimeFormatter.ofPattern("uuuuMMdd").format(LocalDate.parse(inOut.get(i).get("period_start").toString(), DateTimeFormatter.ofPattern("uuuuMMdd")).plusDays(1));
//            } else {
//              targetDt = inOut.get(i).get("period_start").toString();
//            }
//          }
//        }
//      }
//
//      if (targetDt.equals("")) {
//        // 未来日以降の入外情報のみ存在する場合
//        if (inOut.size() > 0) {
//          // 直近未来の入外情報取得
//          String moveInOut = inOut.get(inOut.size() - 1).get("move_in_out").toString();
//          String periodStart = inOut.get(inOut.size() - 1).get("period_start").toString();
//          String inOutState = null;
//
//          if (InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_INTRODUCTION.equals(moveInOut)) {
//            // 導入 → 導入予定、予定在院状態：在院
//            inOutState = PatInfoMoveInOut.MOVE_IN_OUT_INTRODUCTION_PLAN;
//            moveInOut = PatInfoMoveInOut.MOVE_IN_OUT_HOSPITALIZATION;
//          } else if (InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_MOVE_IN.equals(moveInOut)) {
//            // 転入 → 転入予定、予定在院状態：在院
//            inOutState = PatInfoMoveInOut.MOVE_IN_OUT_MOVE_IN_PLAN;
//            moveInOut = PatInfoMoveInOut.MOVE_IN_OUT_HOSPITALIZATION;
//          } else if (InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_MOVING_OUT.equals(moveInOut)) {
//            // 転出 → 在院
//            inOutState = PatInfoMoveInOut.MOVE_IN_OUT_HOSPITALIZATION;
//          } else if (InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_HOSPITALIZATION.equals(moveInOut)
//              || InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_DISCHARGE.equals(moveInOut)
//              || InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_OUTPATIENT.equals(moveInOut)) {
//            // 入院・退院・外来 → 予定在院状態：在院
//            moveInOut = PatInfoMoveInOut.MOVE_IN_OUT_HOSPITALIZATION;
//          } else if (InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_TEMPORARILY_MOVING_OUT.equals(moveInOut)) {
//            // 一時転出 → 在院
//            inOutState = PatInfoMoveInOut.MOVE_IN_OUT_HOSPITALIZATION;
//          }
//
//          // 確定・予定転入出状態更新・入外区分更新
//          patInfoService.updateInOut(pat_id, inOutState, moveInOut, periodStart, null, payload);
//        }
//      } else {
//        // 一部の当日分入外情報もしくは過去日の入外情報が存在する場合は、入外区分・在院状態更新APIをコール
//        List<Long> patIdList = new ArrayList<Long>();
//        patIdList.add(pat_id);
//        ResponseEntity<String> ret = webApiCallCommonUtil.updatePatInOutInfo(targetDt, patIdList);
//        // 失敗時
//        if (ret.getStatusCode() != HttpStatus.OK) {
//          // add FNSi5712アプリケーションログが出力しない 周 start
//          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
//            AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload, ntssUser));
//          // add FNSi5712アプリケーションログが出力しない 周 end
//          return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
//        }
//      }
//
//      // 更新処理実行後の確定・予定転入出状態取得
//      Map<String, Object> updInOutInfoState = patInfoService.selectInOutState(facility_cd, pat_id);
//
//      // 更新後の入外区分を取得
//      patInfoJson = patInfoService.selectById(pat_id, ntssUser.getFacilityCd());
//      PatPersonalMain updPatPersonalMain = mapper.readValue(patInfoJson.get("pat_personal_main"), PatPersonalMain.class);
//      Integer updInOutClass = updPatPersonalMain.getIn_out_class();
//
//      if (updInOutClass == null) {
//        // 入外区分がnullの場合、過去の転入出履歴内に入外区分を設定した履歴が存在しないか確認
//        // 直近過去日に区分："一時転出"の履歴のみ存在する場合は入外区分が正しく設定できないため、そこをフォローする
//        for (int i = 0; inOut.size() > i; i++) {
//          int periodStart = Integer.parseInt(inOut.get(i).get("period_start").toString());
//          if (periodStart < numberDate) {
//            if (inOut.get(i).get("in_out") != null) {
//              // 入外区分が設定されている中で2番目に近い過去履歴の入外区分で更新をかける
//              updInOutClass = Integer.parseInt(inOut.get(i).get("in_out").toString());
//              patInfoService.updateInOutClassById(pat_id, updInOutClass, payload);
//              break;
//            }
//          }
//        }
//      }
//
//      // 入外区分変更時には次患者更新処理を呼び出し
//      if (updInOutClass == null) {
//        if (updInOutClass != initInOutClass) {
//          patInfoService.comSvNotifySetNextPatInfo(facility_cd, pat_id);
//        }
//      } else if (! updInOutClass.equals(initInOutClass)) {
//        patInfoService.comSvNotifySetNextPatInfo(facility_cd, pat_id);
//      }
//
//      Map<String, Object> in_out_info = setMoveInOutInfo(updInOutInfoState.get("in_out_current_state") == null ? null : updInOutInfoState.get("in_out_current_state").toString(), updInOutClass);
//      // add FNSi5712アプリケーションログが出力しない 周 start
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
//        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload, ntssUser));
//      // add FNSi5712アプリケーションログが出力しない 周 end
//      return new ResponseEntity<>(in_out_info, HttpStatus.OK);
//    } catch (Exception e) {
//      e.printStackTrace();
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
//      // add FNSi5712アプリケーションログが出力しない 周 start
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
//        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload, ntssUser));
//      // add FNSi5712アプリケーションログが出力しない 周 end
//      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
//    }
    /* del by chenshijie  2023-02-02 [CodeOptimization]  end */
  }

  /**
   * @description 入外区分返却値を生成
   */
  private static Map<String, Object> setMoveInOutInfo(String in_out_current_state, Integer in_out) {
    Map<String, Object> in_out_info = new HashMap<String, Object>();

    in_out_info.put("in_out_current_state", in_out_current_state);
    in_out_info.put("in_out_class", in_out);

    return in_out_info;
  }

  @PostMapping("/getPatIdByTreatDate")
  public ResponseEntity<List<Long>> getPatIdByTreatDate(@RequestBody Map<String, String> payload) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getPatIdByTreatDate";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      List<Long> patIdList = patInfoService.selectPatIdByTreatDate(payload.get("treatDate"), payload.get("facilityCd"));
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(patIdList, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 患者情報論理削除
   */
  @PutMapping("/deletePatInfo/{pat_id}")
  // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
//  public ResponseEntity<?> updateIsDelById(@PathVariable long pat_id) {
  public ResponseEntity<?> updateIsDelById(@PathVariable long pat_id, @AuthenticationPrincipal NtssUser ntssUser) {
    // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getPatIdByTreatDate";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      // mod 10880 start
//      patInfoService.updateIsDelById(pat_id);
      List<OrdMain> oldOrdMains = ordMainDao.selectByPatId(pat_id);
      //治療中rst_dialysis_state＝3のデータが存在するときは、削除不可とする。メッセージ表示
      List<OrdMain> state3OrdMainList = new ArrayList<>();
      if(oldOrdMains != null && !oldOrdMains.isEmpty()){
        state3OrdMainList = oldOrdMains.stream().filter(item -> "3".equals(item.getRstDialysisState())).collect(Collectors.toList());
        if(!state3OrdMainList.isEmpty()){
          return new ResponseEntity<>("22020005",HttpStatus.OK);
        }
      }
      // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
//      patInfoService.updateIsDelById(pat_id, oldOrdMains);
      patInfoService.updateIsDelById(pat_id, oldOrdMains, ntssUser);
      // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end
      //次患者更新
      if(oldOrdMains != null && !oldOrdMains.isEmpty()){
        nextPatService.CallNextPatChange(oldOrdMains.get(0).getFacilityCd(), oldOrdMains);
      }
      // mod 10880 end */

      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
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
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  // add FutreNetWeb+SI課題管理No6227 趙 start
  @PutMapping("/copyPatInfo/{pat_id}")
  public ResponseEntity<Void> copyDataById(@PathVariable long pat_id) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/copyPatInfo/{pat_id}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patInfoService.copyDataById(pat_id);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add FutreNetWeb+SI課題管理No6227 趙 end

  /**
   * 患者IDでベッド名とクール名の習得
   * @param payload
   * @return
   */
  @PostMapping("/getBedAndPatInfoRange")
  public ResponseEntity<List<OrdMainBedAndKur>> getBedAndPatInfoRange(@RequestBody OrdMainContainerWithRange payload) {
    String mappingUrl = Uri.PAT_INFO + "/getBedAndPatInfoRange";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      try {
      List<OrdMainBedAndKur> ordMainBedAndKurs = new ArrayList<>();
      List<Long> patIds = payload.getPatIds();
      String facilityCd = payload.getFacilityCd();
      String treatDate = payload.getTreatDate();
      String treatDateStart = payload.getTreatDateStart();
      String treatDateEnd = payload.getTreatDateEnd();

      ordMainBedAndKurs = patInfoService.getBedAndKurByIdsAndRange(patIds, facilityCd, treatDateStart, treatDateEnd, treatDate);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      return new ResponseEntity<>(ordMainBedAndKurs, HttpStatus.OK);
    } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (payload != null && payload.getFacilityCd() != null) {
          eventLogMessage.setFacilityCd(payload.getFacilityCd());
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 在宅患者の検索
   */
  @PutMapping("/findHomeDialysisPat/{pat_id}")
  public ResponseEntity<MstUser> findHomeDialysisPat(@PathVariable long pat_id, @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/findHomeDialysisPat/{pat_id}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      MstUser mstUser = patInfoService.selectByPatId(pat_id, ntssUser.getFacilityCd());
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(mstUser, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 患者身体情報の取得
   * @param patId
   * @return
   */
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // @GetMapping("physical-info/{patId}")
  // public ResponseEntity<?> findPhysicalInfo(@PathVariable Long patId) {
  @GetMapping("physical-info/{patId}/{patShareMode}")
  public ResponseEntity<?> findPhysicalInfo(@PathVariable Long patId, @PathVariable Integer patShareMode) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/physical-info/{patId}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      // List<PatUniquePhysicalInfo> physical = patInfoService.selectPhysicalInfoOfOrderNewest(patId);
      List<PatUniquePhysicalInfo> physical = patInfoService.selectPhysicalInfoOfOrderNewest(patId, patShareMode);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(physical, HttpStatus.OK);
    } catch (Exception ex) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
    }
  }
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */

  /**
   * 患者メモマスタ更新に伴う患者メモ展開
   * @param facilityCd 施設コード
   * @param strSql JSON更新用SQL
   * @return
   */
  @PostMapping("/updatePatMemo")
  public ResponseEntity<Void> getMstPatMemoAll(
      @RequestBody Map<String, String> payload,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/updatePatMemo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patInfoService.updatePatMemoInfo(ntssUser.getFacilityCd(), payload.get("strSql"));
      // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
      threadExector.execute(new Runnable() {
        @Override
        public void run() {
          // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//          patInfoService.insertPatMainHistoryList(ntssUser.getFacilityCd());
          mongoService.updateAndInsertPatMain(ntssUser.getFacilityCd(), null, true, null, MstToMongoEnum.MSTPATMEMO);
          // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
        }
      });
      // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end

      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   *
   * @param patId
   * @return
   */
  @GetMapping("pat-addition-info/{facilityCd}/{patId}")
  public ResponseEntity<?> getPatAdditionInfo(@PathVariable String facilityCd, @PathVariable Long patId) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/pat-addition-info/{facilityCd}/{patId}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      List<AdditionInfo> additionList = patInfoService.selectPatAdditionInfo(facilityCd, patId);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(additionList, HttpStatus.OK);
    } catch (Exception ex) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * ャーナル更新APIリクエスト
   *
   * @param payload
   * @param ntssUser
   * @return
   * @throws Exception
   * @throws RuntimeException
   */
  @PostMapping("/create")
  public ResponseEntity<?> create(@RequestBody JournalCreateRequestPayload payload, @AuthenticationPrincipal NtssUser ntssUser) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/create";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {

// edit  2021/01/29 FNSI-連携イベントの登録適正化 馮 start
//      boolean callFlg = true;
//      // add FNSI-連携イベントの登録適正化 楊 start
//      MstCoopFacility.CoopOrdCd coopCd = journalService.getCoopOrdCd(payload.getFacilityCd(), payload.getOpeCd());
//      if (null != coopCd) {
//        payload.setCoopCd(coopCd.getCoopCd());
//      }
//      // add FNSI-連携イベントの登録適正化 楊 end

//      if(!payload.getCrud().equals("C")) {
//        List<OrdCoopNo> list = new ArrayList<OrdCoopNo>();
//        list = journalService.getByCondition(payload.getFacilityCd(), payload.getOrdNo(), payload.getCoopCd());
//        if (list.size() == 0) {
//          callFlg = false;
//        }
//      }
//      if (callFlg) {
//        RestTemplate rt = new RestTemplate();
//        URI uri = new URI(coopApi + "/journal/create");
//        RequestEntity<JournalCreateRequestPayload> request = RequestEntity
//                .post(uri)
//                .contentType(MediaType.APPLICATION_JSON)
//                .body(payload);
//        rt.exchange(request, Object.class);
//      }
      // #7068 mod 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start
      asyncService.sendExternalConnection(payload);
//      RestTemplate rt = new RestTemplate();
//      URI uri = new URI(coopApi + "/journal/create");
//      RequestEntity<JournalCreateRequestPayload> request = RequestEntity
//        .post(uri)
//        .contentType(MediaType.APPLICATION_JSON)
//        .body(payload);
//      rt.exchange(request, Object.class);
      // #7068 mod 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 end
// edit 2021/01/29 FNSI-連携イベントの登録適正化 馮 end

      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);

    } catch (Exception ex) {
      //patInfoService.createNotificationMessage(ntssUser.getUserId(), payload);
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    }
  }
  // add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
  /**
   * ャーナル更新APIリクエスト
   *
   * @param JournalList
   * @param ntssUser
   * @return
   * @throws Exception
   * @throws RuntimeException
   */
  @PostMapping("/create/list")
  public ResponseEntity<?> createList(@RequestBody List<JournalCreateRequestPayload> JournalList, @AuthenticationPrincipal NtssUser ntssUser) throws Exception {
    String mappingUrl = Uri.PAT_INFO + "/create/list";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(JournalList, ntssUser));
    try {
      if (!CollectionUtils.isEmpty(JournalList)){
        journalService.callCreateJournalForCtrNo(JournalList);
      }
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(JournalList, ntssUser));
      return new ResponseEntity<>(HttpStatus.OK);

    } catch (Exception ex) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(JournalList, ntssUser));
      return new ResponseEntity<>(HttpStatus.OK);
    }
  }
 // add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
  /**
   * 患者治療進捗状態を取得する
   * @param patId 患者ID
   * @return
   */
  @GetMapping("/getAcceptanceStatusInfo/{patId}")
  public ResponseEntity<?> getAcceptanceStatusInfo(@PathVariable Long patId) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getAcceptanceStatusInfo/{patId}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {

      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(patMainAcceptanceStatusInfoService.get( patId ), HttpStatus.OK);
    } catch( Exception ex ) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setPatId(String.valueOf(patId));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  /**
   * 患者治療進捗状態を再構築する
   * @param patId 患者ID
   * @return
   */
  @PostMapping("/rebuildAcceptanceStatusInfo/{patId}")
  public ResponseEntity<?> rebuildAcceptanceStatusInfo(@PathVariable Long patId) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/rebuildAcceptanceStatusInfo/{patId}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(patMainAcceptanceStatusInfoService.rebuild( patId ), HttpStatus.OK);
    } catch( Exception ex ) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setPatId(String.valueOf(patId));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
// add FNSI-患者情報共有よりの改修 江 start
  /**
   * 施設一覧のデータを取得
   */
  @GetMapping("/getFacilityList/{facilityCd}/{patId}")
  public ResponseEntity<?> getFacilityList(
    @PathVariable String facilityCd, @PathVariable Long patId
  ) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getFacilityList/{facilityCd}/{patId}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      List<SharedPatFacilityInfo> facilityList = patInfoService.selectFacilityList(facilityCd, patId);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(facilityList, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  /**
   * 施設一覧のデータを取得
   */
  @GetMapping("/getNewPatFacility/{facilityCd}")
  public ResponseEntity<?> getNewPatFacility(
    @PathVariable String facilityCd
  ) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getNewPatFacility/{facilityCd}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      List<MstFacility> facilityList = patInfoService.selectNewPatFacility(facilityCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(facilityList, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
// add FNSI-患者情報共有よりの改修 江 end
  /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
  @PutMapping("/updatePatUniqueById/{pat_id}")
  public ResponseEntity<String> updatePatUniqueById(@PathVariable long pat_id, @RequestBody Map<String, String> payload) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/updatePatUniqueById/{pat_id}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patInfoService.updateUniqueById(pat_id, payload);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>("",HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>("",HttpStatus.BAD_REQUEST);
    }
  }
  /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
  // add MongoDB共通インターフェース 関 start
  @GetMapping("/getPatMainHistory")
  public ResponseEntity<?> getPatHistory(@RequestBody(required = false) Map<String, ?> payload) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getPatMainHistory";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List patMainHistory = patInfoService.getPatHistory(payload);
//    return new ResponseEntity<>(payload, HttpStatus.OK);
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(patMainHistory, HttpStatus.OK);
  }
  // add MongoDB共通インターフェース 関 end
  // add FNSI-NO423入院患者名の配布 関 start
  @PostMapping("/getPatSameAndInOutClass")
  public ResponseEntity<?> getPatSameAndInOutClass(@RequestBody Map<String, ?> payload, @AuthenticationPrincipal NtssUser ntssUser) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getPatSameAndInOutClass";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    Map patMessage = patInfoService.getPatSameAndInOutClass(payload);
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(patMessage, HttpStatus.OK);
  }
  // add FNSI-NO423入院患者名の配布 関 end
  // redmine 6471 患者グループの編集した記録がログに残らない  関　start
  @PutMapping("/addpatGrouplog")
  public ResponseEntity<?> outputCondition(@RequestBody Map param) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/addpatGrouplog";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(param));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      if (param != null && param.size() > 0) {
        String functionName = convertString(param.get("functionName"));
        String message = convertString(param.get("message"));
        String patid = convertString(param.get("pat_id"));
        outputLog(LogLevel.MONGO, String.format(ADDPATGROUP_LOG_MESSAGE, convertString(functionName), message), functionName,patid);
      }
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(param));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(param));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    }
  }
  @PutMapping("/delpatGrouplog")
  public ResponseEntity<?> outputConditiondel(@RequestBody Map param) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/delpatGrouplog";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(param));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      if (param != null && param.size() > 0) {
        String functionName = convertString(param.get("functionName"));
        String message = convertString(param.get("message"));
        String patid = convertString(param.get("pat_id"));
        outputLog(LogLevel.MONGO, String.format(DELPATGROUP_LOG_MESSAGE, convertString(functionName), message), functionName,patid);
      }
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(param));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(param));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    }
  }
  @PutMapping("/modpatGrouplog")
  public ResponseEntity<?> outputConditionmod(@RequestBody Map param) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/modpatGrouplog";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(param));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      if (param != null && param.size() > 0) {
        String functionName = convertString(param.get("functionName"));
        String arrTemp = convertString(param.get("arrTemp"));
        String arrTempEdit = convertString(param.get("arrTempEdit"));
        String patid = convertString(param.get("pat_id"));
        outputLog(LogLevel.MONGO, String.format(MODPATGROUP_LOG_MESSAGE, convertString(functionName), arrTemp,arrTempEdit), functionName,patid);
      }
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(param));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(param));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    }
  }
  private void outputLog(LogLevel level, String message, String functionName,String patid) {
    if (StringUtils.isEmpty(message)) {
      return;
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
    eventLogMessage.setLogMessage(message);
    eventLogMessage.setInvokeClass(this.getClass().getName());
    eventLogMessage.setFunctionName(convertString(functionName));
    eventLogMessage.setPatId(patid);
    logService.log(level, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
  }
  public String convertString(Object obj) {
    if (obj == null) {
      return "";
    }

    return obj.toString();
  }
  // redmine 6471 患者グループの編集した記録がログに残らない  関　end

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

  //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある zhao start
  @GetMapping("/selectMedicalCareInfoByIdAndFacilityCd/{facilityCd}/{patId}")
  public ResponseEntity<?> selectMedicalCareInfoByIdAndFacilityCd(
    @PathVariable String facilityCd, @PathVariable Long patId
  ) throws Exception {
    String mappingUrl = Uri.PAT_INFO + "/selectMedicalCareInfoByIdAndFacilityCd/{facilityCd}/{patId}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId));
    try {
      PatMain patMain = patMainDao.selectMedicalCareInfoByIdAndFacilityCd(facilityCd, patId);
      Map<String,String> newMap = new HashMap();
      if(!ObjectUtils.isEmpty(patMain.getMedical_care_info())){
        JSONObject jSONObject = new JSONObject(patMain.getMedical_care_info());
        String dialysisCount = "";
        String purificationCount = "";
        if(jSONObject.has("dialysis_count")){
          dialysisCount = jSONObject.get("dialysis_count").toString();
        }
        if(jSONObject.has("dialysis_count")){
          purificationCount = jSONObject.get("purification_count").toString();
        }
        newMap.put("dialysisCount",dialysisCount);
        newMap.put("purificationCount",purificationCount);
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId));
      }
      return new ResponseEntity<>(newMap, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId));
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある zhao end

  /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --start */
  /**
   * 患者に関連する禁忌情報を取得する
   * @param facilityCd  施設コード
   * @param patId
   * @return
   * @throws Exception
   */
  @GetMapping("/selectPatTabooAllergyByPatId/{facilityCd}/{patId}")
  public ResponseEntity<?> selectPatTabooAllergyByPatId(
          @PathVariable String facilityCd, @PathVariable Long patId
  ) throws Exception {
    String mappingUrl = Uri.PAT_INFO + "/selectPatTabooAllergyByPatId/{facilityCd}/{patId}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
            BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId));
    try {
      return new ResponseEntity<>(patInfoService.selectPatTabooAllergyByPatId(facilityCd, patId), HttpStatus.OK);
    } catch (Exception e) {
      e.printStackTrace();
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
              AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId));
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --end */

  /**
   * 対象車いす割当済みの患者IDリストを取得
   */
  @GetMapping("/getWheelChairAssigningPatIdList/{facilityCd}/{wheelChairCd}")
  public ResponseEntity<?> getWheelChairAssigningPatIdList(
      @PathVariable String facilityCd, @PathVariable Long wheelChairCd
  ) throws Exception {
    String mappingUrl = Uri.PAT_INFO + "/getWheelChairAssigningPatIdList/{wheelChairCd}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd,wheelChairCd));
    try {
      List<Long> patIdList = patInfoService.getWheelChairAssigningPatIdList(facilityCd,wheelChairCd);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd,wheelChairCd));
      return new ResponseEntity<>(patIdList, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd,wheelChairCd));
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
}
