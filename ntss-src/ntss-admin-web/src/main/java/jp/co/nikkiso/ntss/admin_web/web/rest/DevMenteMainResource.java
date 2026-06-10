package jp.co.nikkiso.ntss.admin_web.web.rest;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.periodicInspection.UpdateMainteMainRequest;
import jp.co.nikkiso.ntss.admin_web.response.partsRunning.PartsRunningResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.machine.MstMachineService;
import jp.co.nikkiso.ntss.admin_web.service.mente.DevMenteMainService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.DailySearchRequest;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PeriodSearchRequest;
import jp.co.nikkiso.ntss.core.entity.DevMenteMain;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.custom.CusMenteMainPlan;
import jp.co.nikkiso.ntss.core.entity.custom.MachineInspection;
import jp.co.nikkiso.ntss.core.entity.custom.MaintePassAllDailyParam;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections4.map.HashedMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;


import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 検査結果のResourceクラス.
 */
@Slf4j
@RestController
@RequestMapping(Uri.MENTE_MAIN)
public class DevMenteMainResource {

  /**
   * 検査結果のServiceインタフェース.
   */
  @Autowired
  DevMenteMainService devMenteMainService;

  /**
   * 装置マスタのServiceインタフェース.
   */
  @Autowired
  MstMachineService mstMachineService;

  /**
     * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  // add FNSi5712アプリケーションログが出力しない 周 start
  @Autowired
  LogEventUtils logEventUtils;
  // add FNSi5712アプリケーションログが出力しない 周 end

  /**
   * 検索条件に該当する型式とベッドの装置情報一覧を取得する
   *
   * @return 型式とベッドの条件を満たす装置情報一覧
   */
  @PostMapping("/getMachineSearchResult")
  public ResponseEntity<List<MachineInspection>> getMachineSearchResult(
    @RequestBody PeriodSearchRequest periodSearchRequest, @AuthenticationPrincipal NtssUser ntssUser
    ) throws Exception {
    String mappingUrl = Uri.MENTE_MAIN + "/getMachineSearchResult";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(periodSearchRequest, ntssUser));
    try {
      List<MachineInspection> machineInspection = devMenteMainService.getMachineSearchResult(periodSearchRequest, ntssUser);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(periodSearchRequest, ntssUser));
      return new ResponseEntity<>(machineInspection, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_BBS_INFO, SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 型式マスタリストを取得する
   *
   * @return 型式マスタリスト
   */
  @GetMapping("getMachineTypeList")
  public ResponseEntity<List<MstMachineType>> getMachineTypeList() {
    String mappingUrl = Uri.MENTE_MAIN + "getMachineTypeList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      FUNCTION_CODE.FUNC_DAILY_CHECK, BEFORE_LOG_FLG_INFO,
      mappingUrl, null, null);
    try {
      List<MstMachineType> res = mstMachineService.selectMachineTypeAll();
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO,
        mappingUrl, null, null);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,
        FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @GetMapping("getBedGroupList")
  public ResponseEntity<List<MstRoomBedGroup>> getBedGroupList(@AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.MENTE_MAIN + "getBedGroupList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<MstRoomBedGroup> res = new ArrayList<>();
    try {
      final String facilityCd = ntssUser.getFacilityCd();
      res = devMenteMainService.getBedGroupList(facilityCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 検査用のマシンリストを取得する
   *
   * @param ntssUser NTSS認証ユーザ
   * @return マシン情報リスト
   */
  @GetMapping("/machines-inspection")
  public ResponseEntity<List<MachineInspection>> getListMachine(@AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.MENTE_MAIN + "/machines-inspection";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<MachineInspection> res = new ArrayList<>();
    try {
      final String facilityCd = ntssUser.getFacilityCd();
      res = devMenteMainService.getListMachineForInspection(facilityCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

  }

  /**
   * （日常点検用）指定した日付の検査結果リストを取得する
   *
   * @param ntssUser NTSS認証ユーザ
   * @param mainteClass 検査型式（用途）
   * @param mainteDate 点検日（YYYY-MM-DD）
   * @return 検査結果リスト
   */
  @GetMapping("/results/{mainteClass}/{mainteDate}")
  public ResponseEntity<List<DevMenteMain>> getListResults(
      @AuthenticationPrincipal NtssUser ntssUser,
      @PathVariable(name = "mainteClass", required = true) String mainteClass,
      @PathVariable(name = "mainteDate", required = true) String mainteDate) {
    String mappingUrl = Uri.MENTE_MAIN + "/results/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, mainteClass, mainteDate));

    try {
      final String facilityCd = ntssUser.getFacilityCd();
      List<DevMenteMain> res = devMenteMainService
        .getResultInspectionByMainteDateAndClass(
          facilityCd, mainteDate, mainteClass);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, mainteClass, mainteDate));
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * （定期点検用）指定した日付範囲の検査結果リストを取得する
   * （引数の点検日の値が空文字列の場合、それぞれの条件は未指定であることを表す）
   *
   * @param ntssUser NTSS認証ユーザ
   * @param mainteClass 検査型式（用途）
   * @param mainteDateStart 点検日範囲開始（下限）（YYYY-MM-DD）
   * @param mainteDateEnd 点検日範囲終了（上限）（YYYY-MM-DD）
   * @return 検査結果リスト
   */
  @GetMapping("/results/date-span")
  public ResponseEntity<List<DevMenteMain>> getListResultsByMainteDateSpan(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestParam(name = "mainteClass", required = true) String mainteClass,
      @RequestParam(name = "mainteDateStart", required = true) String mainteDateStart,
      @RequestParam(name = "mainteDateEnd", required = true) String mainteDateEnd) {
    String mappingUrl = Uri.MENTE_MAIN + "/results/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      FUNCTION_CODE.FUNC_DAILY_CHECK, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(ntssUser, mainteClass, mainteDateStart, mainteDateEnd));

    try {
      final String facilityCd = ntssUser.getFacilityCd();
      List<DevMenteMain> res = devMenteMainService.getResultByMainteDateSpan(
        facilityCd, mainteClass, mainteDateStart, mainteDateEnd);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ntssUser, mainteClass, mainteDateStart, mainteDateEnd));
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setSqlIdentification(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,
        FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(e.getMessage()));
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 点検日と点検用途と装置番号を指定して点検結果リストを取得する
   *
   * @param ntssUser NTSS認証ユーザ
   * @param mainteDate 点検日（YYYY-MM-DD）
   * @param mainteClass 検査型式（用途）
   * @param machineNo 装置番号
   * @return 点検結果一覧
   */
  @GetMapping("/result-detail/{machineNo}/{mainteClass}/{mainteDate}")
  public ResponseEntity<List<DevMenteMain>> getResultDetailOfMachine(
      @AuthenticationPrincipal NtssUser ntssUser,
      @PathVariable(name = "machineNo", required = true) Long machineNo,
      @PathVariable(name = "mainteClass", required = true) String mainteClass,
      @PathVariable(name = "mainteDate", required = true) String mainteDate) {
    String mappingUrl = Uri.MENTE_MAIN + "/result-detail/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      FUNCTION_CODE.FUNC_DAILY_CHECK, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(ntssUser, mainteClass, mainteDate));

    try {
      String facilityCd = ntssUser.getFacilityCd();
      List<DevMenteMain> res = devMenteMainService.getResultInspectionByMachineAndMainteDateAndClass(
        facilityCd, mainteDate, mainteClass, machineNo);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ntssUser, mainteClass, mainteDate));
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,
        FUNCTION_CODE.FUNC_DAILY_CHECK, SERVICE_NAME.FNSI, null);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO, mappingUrl, null,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 検査用のマシンリストを取得する
   *
   * @param ntssUser NTSS認証ユーザ
   * @return マシン情報リスト
   */
  @GetMapping("/history/peri")
  public ResponseEntity<List<DevMenteMain>> getHistoryOfPeriodicInspection(@AuthenticationPrincipal NtssUser ntssUser,
      @RequestParam Map<String, String> params) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.MENTE_MAIN + "/history/peri";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, params));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<DevMenteMain> res = new ArrayList<>();
    try {
      String facilityCd = ntssUser.getFacilityCd();
      res = devMenteMainService.getPeriodicHistory(facilityCd, params);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, params));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 日常点検の点検項目ごとの点検結果を更新
   *
   * @param ntssUser NTSS認証ユーザ
   * @param params.devMenteNo 点検結果コード
   * @param params.machineNo 装置番号
   * @param params.menteDate 点検日
   * @param params.menteLayoutCd 点検レイアウトコード
   * @param params.menteAns1 結果入力パターン
   * @param params.detail 内容（JSON文字列）
   * @param params.mainteCategoryCd 点検カテゴリコード版数（JSON文字列）
   * @return 点検結果レコードの更新結果
   */
  @PostMapping("/daily/changeStatusList")
  public ResponseEntity<DevMenteMain> updateInspectionResultList(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestBody DevMenteMain params) {
    String mappingUrl = Uri.MENTE_MAIN + "/daily/changeStatusList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, params));
    try {
      String facilityCd = ntssUser.getFacilityCd();
      Long checkerId = ntssUser.getUserId();
      DevMenteMain res = devMenteMainService.changeResultOfDailyInspectionList(params, facilityCd, checkerId);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, params));
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DAILY_CHECK, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      if (e instanceof DuplicateKeyException || e instanceof SQLException) {
        return new ResponseEntity<>(HttpStatus.CONFLICT);
      }
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 点検レイアウト単位で点検結果を更新
   *
   * @param ntssUser NTSS認証ユーザ
   * @param params.devMenteNo 点検結果コード
   * @param params.machineNo 装置番号
   * @param params.menteDate 点検日
   * @param params.menteLayoutCd 点検レイアウトコード
   * @param params.menteAns1 結果入力パターン
   * @return 点検結果レコードの更新結果
   */
  @PostMapping("/daily/changeStatus")
  public ResponseEntity<DevMenteMain> updateInspectionResult(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestBody DevMenteMain params) {
    String mappingUrl = Uri.MENTE_MAIN + "/daily/changeStatus";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, params));
    try {
      String facilityCd = ntssUser.getFacilityCd();
      Long checkerId = ntssUser.getUserId();
      DevMenteMain res = devMenteMainService.changeResultOfDailyInspection(params, facilityCd, checkerId);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, params));
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DAILY_CHECK, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      if (e instanceof DuplicateKeyException || e instanceof SQLException) {
        return new ResponseEntity<>(HttpStatus.CONFLICT);
      }
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 点検日と点検レイアウトコードによる全台合格処理を行う
   *
   * @param ntssUser NTSS認証ユーザ
   * @param params.params.menteDate 点検日
   * @param params.params.menteLayoutCd 点検レイアウトコード
   * @param params.machineNoList 全台合格処理の対象とする装置番号のリスト
   * @return 更新後の点検結果レコード
   */
  @PostMapping("/daily/passAll")
  public ResponseEntity<List<DevMenteMain>> updatePassAllDaily(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestBody MaintePassAllDailyParam params) {
    String mappingUrl = Uri.MENTE_MAIN + "/daily/passAll";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, params));
    try {
      String facilityCd = ntssUser.getFacilityCd();
      Long checkerId = ntssUser.getUserId();
      List<DevMenteMain> res = devMenteMainService.changeStatusPassAllDaily(params, facilityCd, checkerId);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, params));
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DAILY_CHECK, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      if (e instanceof DuplicateKeyException) {
        return new ResponseEntity<>(HttpStatus.CONFLICT);
      }
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 更新結果検査の詳細
   *
   * @param devMenteMain 結果検査詳細
   * @return 検査結果更新
   */
  @PostMapping("/detail-update")
  //mod FNSI-No.757  タップやクリックだけで直接入力更新せず、意図して「確定」「キャンセル」を選ばせたい 吉 start
//  public ResponseEntity<DevMenteMain> updateDetailCellClick(@RequestBody DevMenteMain devmenteMain) {
  public ResponseEntity<DevMenteMain> updateDetailCellClick(@RequestBody List<Object> updateList) {
    //mod FNSI-No.757  タップやクリックだけで直接入力更新せず、意図して「確定」「キャンセル」を選ばせたい 吉 end
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.MENTE_MAIN + "/detail-update";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(updateList));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      //mod FNSI-No.757  タップやクリックだけで直接入力更新せず、意図して「確定」「キャンセル」を選ばせたい 吉 start
//      DevMenteMain res = devMenteMainService.updateDetailWhenCellClick(devmenteMain);
//      return new ResponseEntity<>(res, HttpStatus.OK);
      int count = 0;
      List<DevMenteMain> devMenteMainList = new ArrayList<>();
      if(null != updateList && updateList.size()>0){
        for(Object obj : updateList){
          Map<String,Object> map= (Map<String, Object>) obj;
          ObjectMapper objectMapper = new ObjectMapper();
          //mod 吉 start
//          DevMenteMain ment =objectMapper.convertValue(map.get("item"), DevMenteMain.class);
//          devMenteMainList.add(ment);
          if(null != map.get("item") && ""!= map.get("item")){
            DevMenteMain ment =objectMapper.convertValue(map.get("item"), DevMenteMain.class);
            devMenteMainList.add(ment);
          }
          //mod 吉 end
        }
      }
      count = devMenteMainService.updateDetailWhenCellClick(devMenteMainList);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(updateList));
      // add FNSi5712アプリケーションログが出力しない 周 end
      if(count  == devMenteMainList.size()){
        return new ResponseEntity<>(HttpStatus.OK);
      }else{
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
      //mod FNSI-No.757  タップやクリックだけで直接入力更新せず、意図して「確定」「キャンセル」を選ばせたい 吉 end-->
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 end
      if (e instanceof DuplicateKeyException) {
        return new ResponseEntity<>(HttpStatus.CONFLICT);
      }
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

  }

  // add 11021 定期点検結果のみ削除仕様 zkm start
  /**
   * 検査結果の削除
   *
   * @param requestData 削除キー
   * @return 検査結果削除
   */
  @PostMapping("/detail-del")
  public ResponseEntity<DevMenteMain> delDetailCellClick(@RequestBody Map<String, Long> requestData) {
    String mappingUrl = Uri.MENTE_MAIN + "/detail-del";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Collections.singletonList(requestData));
    try {
      Long devMenteNo = requestData.get("devMenteNo");
      if (devMenteNo == null) {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
      devMenteMainService.delDetailWhenCellClick(devMenteNo);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, List.of(requestData));
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Collections.singletonList(ExcetionStackTraceToString(e)));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      if (e instanceof DuplicateKeyException) {
        return new ResponseEntity<>(HttpStatus.CONFLICT);
      }
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add 11021 定期点検結果のみ削除仕様 zkm end

  @PostMapping("/get-condition-machines")
  public ResponseEntity<List<MachineInspection>> getConditionListMachine(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestBody DailySearchRequest dailySearchRequest) {
    String mappingUrl = Uri.MENTE_MAIN + "/get-condition-machines";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      FUNCTION_CODE.FUNC_DAILY_CHECK, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(ntssUser, dailySearchRequest));

    ObjectMapper mapper = new ObjectMapper();

    try {
      List<String> machineList = new ArrayList<String>();
      List<Long> listBedCd = new ArrayList<Long>();

      if (dailySearchRequest.getBedGroupCd() != null) {
        List<MstRoomBedGroup> bedGroupList = devMenteMainService.selectConditionBedList(
          dailySearchRequest.getBedGroupCd());
        bedGroupList.stream().forEach(bedGroup -> {
          try {
            if (bedGroup.getBedList() != null) {
              List<Long> bedList = mapper.readValue(
                bedGroup.getBedList(), new TypeReference<List<Long>>() {});
              listBedCd.addAll(bedList);
            }
          } catch (IOException e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            if (ntssUser != null && ntssUser.getFacilityCd() != null) {
              eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
            }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
          }
        });
      }

      if (dailySearchRequest.getMachineTypeList() != null) {
        machineList = dailySearchRequest.getMachineTypeList();
      }

      List<MachineInspection> res = devMenteMainService.getConditionListMachineForInspection(
        ntssUser.getFacilityCd(), machineList, listBedCd,
        dailySearchRequest.getKeyword());

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ntssUser, dailySearchRequest));

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,
        FUNCTION_CODE.FUNC_DAILY_CHECK, SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO, mappingUrl, null,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 定期検査の結果を取得する
   *
   * @param ntssUser   NTSS認証ユーザ
   * @param machineNo  機械番号
   * @param devMenteNo 検査結果
   * @return 定期検査の結果
   */
  @GetMapping("peri/result-detail")
  public ResponseEntity<?> getPeriodicResultDetailOfMachine(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestParam(name = "machineNo", required = false) Long machineNo,
      @RequestParam(name = "menteLayoutGroupCd", required = false) Long mainteLayoutGroupCd,
      @RequestParam(name = "devMenteNo", required = false) Long devMenteNo) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.MENTE_MAIN + "/peri/result-detail";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(machineNo, mainteLayoutGroupCd, devMenteNo));
    // add FNSi5712アプリケーションログが出力しない 周 end
    HashedMap<String, Object> res = new HashedMap<>();
    try {
      if(machineNo == null && devMenteNo == null && mainteLayoutGroupCd == null) {
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(machineNo, mainteLayoutGroupCd, devMenteNo));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
      }
      final String facilityCd = ntssUser.getFacilityCd();

      res = devMenteMainService.getResultDetailOfPeriodic(facilityCd, machineNo, devMenteNo, mainteLayoutGroupCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(machineNo, mainteLayoutGroupCd, devMenteNo));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * ユーザーコードリストによるユーザー情報リストの取得
   *
   * @param userIdList ユーザーコードリスト
   * @return ユーザー情報リスト
   */
  @GetMapping("users-info")
  public ResponseEntity<List<MstPersonalUser>> getListPersonalUserByListId(
      @RequestParam(name = "userIdList", required = true) List<Long> userIdList) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.MENTE_MAIN + "/users-info";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(userIdList));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<MstPersonalUser> res = new ArrayList<>();
    try {
      res = devMenteMainService.getUsersInfoByIdList(userIdList);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(userIdList));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * ユーザー情報を取得する
   *
   * @param userId ユーザーコード
   * @return ユーザー情報リスト
   */
  @GetMapping("user-info/{userId}")
  public ResponseEntity<MstPersonalUser> getPersonalUserInfo(
      @PathVariable(name = "userId", required = true) Long userId) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.MENTE_MAIN + "/users-info/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(userId));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      MstPersonalUser res = devMenteMainService.getUsersInfo(userId);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(userId));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 定期検査スケジュールの変更
   *
   * @param facilityCd       施設コード
   * @param cusMenteMainPlan リスト変更
   */
  @PostMapping("/plan")
  public ResponseEntity<?> addAndCancelPlan(@AuthenticationPrincipal NtssUser ntssUser,
      @RequestBody CusMenteMainPlan cusMenteMainPlan) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.MENTE_MAIN + "/plan";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, cusMenteMainPlan));
    // add FNSi5712アプリケーションログが出力しない 周 end

    try {
      if (cusMenteMainPlan == null
        || (cusMenteMainPlan.getAddMoreList() == null && cusMenteMainPlan.getCancelIdList() == null))
      // mod FNSi5712アプリケーションログが出力しない 周 start
//        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      {
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, cusMenteMainPlan));
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
      // mod FNSi5712アプリケーションログが出力しない 周 end
      final String facilityCd = ntssUser.getFacilityCd();
      devMenteMainService.addAndCancelPlan(cusMenteMainPlan, facilityCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, cusMenteMainPlan));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 end
      if (e instanceof DuplicateKeyException || e instanceof SQLException) {
        return new ResponseEntity<>(HttpStatus.CONFLICT);
      }
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 点検結果の削除
   *
   * @param payload {listMainNo(点検結果コードのリスト)}
   */
  @PostMapping("/delete")
  public ResponseEntity<?> deleteInspectionResult(@RequestBody Map<String, List<Long>> payload) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.MENTE_MAIN + "/delete";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      List<Long> listMainNo = payload.get("listMainNo");
      if (listMainNo == null || listMainNo.isEmpty()) {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
      boolean res = devMenteMainService.deleleMainteMain(listMainNo);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      if (res) {
        return new ResponseEntity<>(HttpStatus.OK);
      }
      return new ResponseEntity<>(HttpStatus.CONFLICT);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

  }

  /*add FNSI-改修内容定期点検画面で装置名の固定部をタップすると当該装置の運転時間を表示するモーダル画面が展開されるようにする 任 start*/
  @GetMapping("/parts_running/{facilityCd}/{machineTypeCd}/{machineSerial}")
  public ResponseEntity<?> getPartsRunning(@PathVariable String facilityCd, @PathVariable String machineTypeCd,
                                           @PathVariable String machineSerial) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.MENTE_MAIN + "/parts_running/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, machineTypeCd, machineSerial));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      PartsRunningResponse response = devMenteMainService.createPartsRunningResponse(facilityCd, machineTypeCd,
        machineSerial);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, machineTypeCd, machineSerial));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (IOException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  /*add FNSI-改修内容定期点検画面で装置名の固定部をタップすると当該装置の運転時間を表示するモーダル画面が展開されるようにする 任 end*/

  // add FNSI-No.746 「×」のセルを押して、予定を入力しても「○」にならない。 吉 start
  /**
   * 定期点検の一括予定中止 対象日付で結果を持たない予定のみを削除する
   *
   * @param req 一括予定中止する条件
   */
  @PostMapping("/delele_mainte_by_temDate")
  public ResponseEntity<?> deleleMainteMainByTemDate(@RequestBody UpdateMainteMainRequest req) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.MENTE_MAIN + "/delele_mainte_by_temDate/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      String temDate = req.getMainteDate();
      List<Long> machineNoList = req.getMachineNoList();
      if (temDate == null || temDate.isEmpty() ||
          machineNoList == null || machineNoList.isEmpty())
      {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
      boolean res = devMenteMainService.deleleMainteMainByTemDate(req);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(req));
      // add FNSi5712アプリケーションログが出力しない 周 end
      if (res) {
        return new ResponseEntity<>(HttpStatus.OK);
      }
      return new ResponseEntity<>(HttpStatus.CONFLICT);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ExcetionStackTraceToString(e)));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add FNSI-No.746 「×」のセルを押して、予定を入力しても「○」にならない。 吉 end

  /**
   * （日常点検用）点検日範囲と装置番号を指定して点検結果リストを取得する
   *
   * @param startDate 点検日範囲上限（YYYY-MM-DD）
   * @param machineNo 装置番号
   * @param endDate 点検日範囲下限（YYYY-MM-DD）
   * @param facilityCd 施設コード
   * @return 点検結果レコードリスト
   */
  @GetMapping("/getLayout/{machineNo}/{startDate}/{endDate}/{facilityCd}")
  public ResponseEntity<List<DevMenteMain>> getLayout(
      @PathVariable(name = "startDate", required = true) String startDate,
      @PathVariable(name = "machineNo", required = true) Long machineNo,
      @PathVariable(name = "endDate", required = true) String endDate,
      @PathVariable(name = "facilityCd", required = true) String facilityCd)
      throws Exception {
    String mappingUrl = Uri.MENTE_MAIN + "/getLayout/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DAILY_CHECK,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(startDate, machineNo, endDate, facilityCd));

    try {
      List<DevMenteMain> res = devMenteMainService.getLayout(startDate, machineNo, endDate, facilityCd);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(startDate, machineNo, endDate, facilityCd));
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,
        FUNCTION_CODE.FUNC_DAILY_CHECK, SERVICE_NAME.FNSI, null);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO, mappingUrl, null,
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
                    Arrays.asList(ExcetionStackTraceToString(e)));
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
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
