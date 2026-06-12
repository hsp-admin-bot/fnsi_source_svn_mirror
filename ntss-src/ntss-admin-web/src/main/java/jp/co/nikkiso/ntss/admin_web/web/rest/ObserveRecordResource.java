package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.observeRecord.ObserveRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.observeRecord.MstObsKindService;
import jp.co.nikkiso.ntss.admin_web.service.observeRecord.PatObsRecService;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MstObsKind;
import jp.co.nikkiso.ntss.core.entity.PatObsRec;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainPatObsRecCombo;
import jp.co.nikkiso.ntss.core.entity.custom.PatObsRecView;
import lombok.extern.slf4j.Slf4j;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;


/**
 * pat_obs_recのRestクラス
 */
@Slf4j
@RestController
@RequestMapping(Uri.PAT_OBS_REC)
public class ObserveRecordResource {

  @Autowired
  private PatObsRecService patObsRecService;

	@Autowired
	LogService logService;

  @Autowired
  private MstObsKindService mstObsKindService;

  @Autowired
  private MstSelectorDao mstSelectorDao;

  @Autowired
  private OrdMainDao    ordMainDao;

  /**
   * 利用者マスタのDAOインターフェース
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  // add FNSi5712アプリケーションログが出力しない 周 start
  @Autowired
  LogEventUtils logEventUtils;
  // add FNSi5712アプリケーションログが出力しない 周 end

  /* add by lvzongheng  2023-02-01  start */
  @Autowired
  ObserveRecordService observeRecordService;
  /* add by lvzongheng  2023-02-01  end */

  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
  @Autowired
  PatPersonalMainDao patPersonalMainDao;
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

  /**
   * コンボボックス用治療情報データ取得
   * @param patId
   * @param treatDate
   * @param dialysisState
   * @return
   */
  @GetMapping("/ord_main_combo/{patId}/{treatDate}/{ordNo}")
  public ResponseEntity<?> getOrdMainPatObsRecCombo(
      @PathVariable(name = "patId", required = true) String patId,
      @PathVariable(name = "treatDate", required = true) String treatDate,
      @PathVariable(name = "ordNo", required = true) String ordNo,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_OBS_REC + "/ord_main_combo/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, treatDate, ordNo, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<OrdMainPatObsRecCombo> res;

    try {
      /* modify by lvzongheng  2023-02-02 [CodeOptimization]  start */
      res = observeRecordService.getOrdMainPatObsRecCombo(patId,treatDate,ordNo,ntssUser);
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("call getOrdMainPatObsRecCombo arg is "+patId+","+treatDate+","+ordNo);
//      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_OBSERVE_RECORD, SERVICE_NAME.FNSI,
//      null);
//      res = new ArrayList<OrdMainPatObsRecCombo>();
//      boolean getIndTreatFlg = false;
//      if ((StrUtils.isNumber(patId) && StrUtils.isNumber(treatDate))) {
//        String sysDate = DateTimeUtils.getSysDate();
//        if (sysDate.equals(treatDate)) {
//          // 対象治療日がシステム日付の場合、未来日の治療予定を取得
//          getIndTreatFlg = true;
//        }
//        res = patObsRecService.selectPatObsRecCombo(ntssUser.getFacilityCd(), Long.parseLong(patId), treatDate, null,
//            toTimestampStart(treatDate, Timestamp.valueOf("1970-01-01 00:00:00")),
//            toTimestampEnd(treatDate, Timestamp.valueOf("9999-01-01 00:00:00")),
//            getIndTreatFlg);
//      } else {
//        res = patObsRecService.selectPatObsRecCombo(ntssUser.getFacilityCd(), null, null, Long.parseLong(ordNo),
//            toTimestampStart(treatDate, Timestamp.valueOf("1970-01-01 00:00:00")),
//            toTimestampEnd(treatDate, Timestamp.valueOf("9999-01-01 00:00:00")),
//            getIndTreatFlg);
//      }
      /* modify by lvzongheng  2023-02-01 [CodeOptimization]  end */
    } catch (Exception e) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
    	// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_OBSERVE_RECORD, SERVICE_NAME.FNSI,
    	null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }

    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, treatDate, ordNo, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * データ取得
   * @param patId
   * @param ctlNo
   * @return
   */
  @GetMapping("/{patId}/{ctlNo}")
  public ResponseEntity<?> getPatObsRecAll(
      @PathVariable(name = "patId", required = true) String patId,
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //@PathVariable(name = "ctlNo", required = true) String ctlNo) {
      @PathVariable(name = "ctlNo", required = true) Long ctlNo,
      @AuthenticationPrincipal NtssUser ntssUser) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_OBS_REC + "/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, ctlNo));
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (patId != null && StrUtils.isNumber(patId)) {
        PatPersonalMain userInf = patPersonalMainDao.selectById(Long.parseLong(patId));
        if (userInf != null && userInf.getFacility_cd() != null && !userInf.getFacility_cd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + userInf.getFacility_cd() + " " + "pat_id=" + patId + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<PatObsRecView> res = new ArrayList<PatObsRecView>();

    if (patId != null && StrUtils.isNumber(patId)) {
      /* modify by lvzongheng  2023-02-01 [CodeOptimization]  start */
      res = observeRecordService.getPatObsRecAll(patId,ctlNo);
//      if (ctlNo != null && StrUtils.isNumber(ctlNo)) {
//        //
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage( patId + "/" + ctlNo);
//        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_OBSERVE_RECORD, SERVICE_NAME.FNSI,
//        null);
//        res.add(patObsRecService.selectByViewKey(Long.parseLong(patId), Long.parseLong(ctlNo)));
//      } else {
//        //
//        res = patObsRecService.selectByViewSpan(Long.parseLong(patId),
//            Timestamp.valueOf("1970-01-01 00:00:00"),
//            Timestamp.valueOf("9999-01-01 00:00:00"),
//            null,
//            null);
//      }
//
//      // スタッフID格納リスト
//      List<Long> userIdList = new ArrayList<Long>();
//
//      // スタッフIDを取得
//      for (int lop = 0; lop < res.size(); lop++) {
//
//        // 情報取得
//        PatObsRecView rec = res.get(lop);
//        // 起票者情報
//        String info = rec.getRegStaffInfo();
//        Long regUserId = this.getStaffId(info, "reg_staff_cd");
//        if (regUserId != null) {
//          // リストにユーザーIDを追加
//          userIdList.add(regUserId);
//        }
//        // 更新者情報
//        info = rec.getUpStaffInfo();
//        Long updateUserId = this.getStaffId(info, "up_staff_cd");
//        if (updateUserId != null) {
//          // リストにユーザーIDを追加
//          userIdList.add(updateUserId);
//        }
//      }
//
//      // userIdListの重複排除
//      List<Long> userIdList_Distinct = userIdList.stream().distinct().collect(Collectors.toList());
//      // スタッフ名取得
//      List<MstPersonalUser> personaUserlList = mstPersonalUserDao.selectByIdList(userIdList_Distinct);
//
//      // スタッフIDを取得
//      for (int lop = 0; lop < res.size(); lop++) {
//
//        // 情報取得
//        PatObsRecView rec = res.get(lop);
//        // 起票者情報
//        String info = rec.getRegStaffInfo();
//        Long regUserId = this.getStaffId(info, "reg_staff_cd");
//        if (regUserId != null) {
//          // 名前を取得
//          String name = this.getStaffName(personaUserlList, regUserId);
//          // 起票者情報に名前を割り当て
//          rec.setRegStaffInfo(makeStaffInfo(info, "reg_staff_name", name));
//        }
//        // 更新者情報
//        info = rec.getUpStaffInfo();
//        Long updateUserId = this.getStaffId(info, "up_staff_cd");
//        if (updateUserId != null) {
//          // 名前を取得
//          String name = this.getStaffName(personaUserlList, updateUserId);
//          // 更新者情報に名前を割り当て
//          rec.setUpStaffInfo(makeStaffInfo(info, "up_staff_name", name));
//        }
//      }
      /* modify by lvzongheng  2023-02-01 [CodeOptimization]  end */
    } else {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, ctlNo));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, ctlNo));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * データ取得
   * @param patId
   * @param startDate
   * @param endDate
   * @return
   */
  @GetMapping("/{patId}/{startDate}/{endDate}/{isDel}/{isNewest}")
  public ResponseEntity<?> getPatObsRecAll(
      @PathVariable(name = "patId", required = true) String patId,
      @PathVariable(name = "startDate", required = true) String startDate,
      @PathVariable(name = "endDate", required = true) String endDate,
      @PathVariable(name = "isDel", required = true) String isDel,
      @PathVariable(name = "isNewest", required = true) String isNewest,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_OBS_REC + "/{patId}/{startDate}/{endDate}/{isDel}/{isNewest}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, startDate, endDate, isDel, isNewest));
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (patId != null && StrUtils.isNumber(patId)) {
        PatPersonalMain userInf = patPersonalMainDao.selectById(Long.parseLong(patId));
        if (userInf != null && userInf.getFacility_cd() != null && !userInf.getFacility_cd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + userInf.getFacility_cd() + " " + "pat_id=" + patId + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<PatObsRecView> res = new ArrayList<PatObsRecView>();

    if (isDel.equals("")) {
      isDel = null;
    }
    if (isNewest.equals("")) {
      isNewest = null;
    }

    if (patId != null && StrUtils.isNumber(patId)) {
      /* modify by lvzongheng  2023-02-01 [CodeOptimization]  start */
      res = observeRecordService.getPatObsRecAll(patId,startDate,endDate,isDel,isNewest);
//      //患者ID、起票日時で検索
//      res = patObsRecService.selectByViewSpan(Long.parseLong(patId),
//          toTimestampStart(startDate, Timestamp.valueOf("1970-01-01 00:00:00")),
//          toTimestampEnd(endDate, Timestamp.valueOf("9999-01-01 00:00:00")),
//          isDel,
//          isNewest);
//
//      // スタッフID格納リスト
//      List<Long> userIdList = new ArrayList<Long>();
//
//      // スタッフIDを取得
//      for (int lop = 0; lop < res.size(); lop++) {
//
//        // 情報取得
//        PatObsRecView rec = res.get(lop);
//        // 起票者情報
//        String info = rec.getRegStaffInfo();
//        Long regUserId = this.getStaffId(info, "reg_staff_cd");
//        if (regUserId != null) {
//          // リストにユーザーIDを追加
//          userIdList.add(regUserId);
//        }
//        // 更新者情報
//        info = rec.getUpStaffInfo();
//        Long updateUserId = this.getStaffId(info, "up_staff_cd");
//        if (updateUserId != null) {
//          // リストにユーザーIDを追加
//          userIdList.add(updateUserId);
//        }
//      }
//
//      // userIdListの重複排除
//      List<Long> userIdList_Distinct = userIdList.stream().distinct().collect(Collectors.toList());
//      // スタッフ名取得
//      List<MstPersonalUser> personaUserlList = mstPersonalUserDao.selectByIdList(userIdList_Distinct);
//
//      // スタッフIDを取得
//      for (int lop = 0; lop < res.size(); lop++) {
//
//        // 情報取得
//        PatObsRecView rec = res.get(lop);
//        // 起票者情報
//        String info = rec.getRegStaffInfo();
//        Long regUserId = this.getStaffId(info, "reg_staff_cd");
//        if (regUserId != null) {
//          // 名前を取得
//          String name = this.getStaffName(personaUserlList, regUserId);
//          // 起票者情報に名前を割り当て
//          rec.setRegStaffInfo(makeStaffInfo(info, "reg_staff_name", name));
//        }
//        // 更新者情報
//        info = rec.getUpStaffInfo();
//        Long updateUserId = this.getStaffId(info, "up_staff_cd");
//        if (updateUserId != null) {
//          // 名前を取得
//          String name = this.getStaffName(personaUserlList, updateUserId);
//          // 更新者情報に名前を割り当て
//          rec.setUpStaffInfo(makeStaffInfo(info, "up_staff_name", name));
//        }
//      }
      /* modify by lvzongheng  2023-02-01 [CodeOptimization]  end */
    } else {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, startDate, endDate, isDel, isNewest));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, startDate, endDate, isDel, isNewest));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * データ取得
   * @param ordNo
   * @param startDate
   * @param endDate
   * @return
   */
  @GetMapping("/ordno/{ordNo}/{isDel}/{isNewest}")
  public ResponseEntity<?> getPatObsRecAll(
      @PathVariable(name = "ordNo", required = true) Long ordNo,
      @PathVariable(name = "isDel", required = true) String isDel,
      @PathVariable(name = "isNewest", required = true) String isNewest,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_OBS_REC + "/ordno/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ordNo, isDel, isNewest));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<PatObsRecView> res = new ArrayList<PatObsRecView>();

    if (isDel.equals("")) {
      isDel = null;
    }
    if (isNewest.equals("")) {
      isNewest = null;
    }

    if (ordNo != null) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
        boolean hasAccess = ordMain == null || ordMain.getFacilityCd() == null
                || ordMain.getFacilityCd().equals(ntssUser.getFacilityCd());
        if (!hasAccess) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "ordMain.getFacilityCd()=" + ordMain.getFacilityCd() + " " + "ordNo=" + ordNo + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
      /* modify by lvzongheng  2023-02-01 [CodeOptimization]  start */
      res = observeRecordService.getPatObsRecAll(ordNo,isDel,isNewest);
//      //オーダ番号で検索
//      res = patObsRecService.selectByOrdNo(ordNo,
//          isDel,
//          isNewest);
//
//      // スタッフID格納リスト
//      List<Long> userIdList = new ArrayList<Long>();
//
//      // スタッフIDを取得
//      for (int lop = 0; lop < res.size(); lop++) {
//
//        // 情報取得
//        PatObsRecView rec = res.get(lop);
//        // 起票者情報
//        String info = rec.getRegStaffInfo();
//        Long regUserId = this.getStaffId(info, "reg_staff_cd");
//        if (regUserId != null) {
//          // リストにユーザーIDを追加
//          userIdList.add(regUserId);
//        }
//        // 更新者情報
//        info = rec.getUpStaffInfo();
//        Long updateUserId = this.getStaffId(info, "up_staff_cd");
//        if (updateUserId != null) {
//          // リストにユーザーIDを追加
//          userIdList.add(updateUserId);
//        }
//      }
//
//      // userIdListの重複排除
//      List<Long> userIdList_Distinct = userIdList.stream().distinct().collect(Collectors.toList());
//      // スタッフ名取得
//      List<MstPersonalUser> personaUserlList = mstPersonalUserDao.selectByIdList(userIdList_Distinct);
//
//      // スタッフIDを取得
//      for (int lop = 0; lop < res.size(); lop++) {
//
//        // 情報取得
//        PatObsRecView rec = res.get(lop);
//        // 起票者情報
//        String info = rec.getRegStaffInfo();
//        Long regUserId = this.getStaffId(info, "reg_staff_cd");
//        if (regUserId != null) {
//          // 名前を取得
//          String name = this.getStaffName(personaUserlList, regUserId);
//          // 起票者情報に名前を割り当て
//          rec.setRegStaffInfo(makeStaffInfo(info, "reg_staff_name", name));
//        }
//        // 更新者情報
//        info = rec.getUpStaffInfo();
//        Long updateUserId = this.getStaffId(info, "up_staff_cd");
//        if (updateUserId != null) {
//          // 名前を取得
//          String name = this.getStaffName(personaUserlList, updateUserId);
//          // 更新者情報に名前を割り当て
//          rec.setUpStaffInfo(makeStaffInfo(info, "up_staff_name", name));
//        }
//      }
      /* modify by lvzongheng  2023-02-01 [CodeOptimization]  end */
    } else {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ordNo, isDel, isNewest));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ordNo, isDel, isNewest));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /* del by lvzongheng  2023-02-02 [CodeOptimization]  start */
//  /**
//   * スタッフ情報リストから指定したスタッフコードの名前を取得する
//   * @param list
//   * @param staffCd
//   * @return
//   */
//  private String getStaffName(List<MstPersonalUser> list, Long staffCd) {
//    String ret = "";
//
//    for (MstPersonalUser info : list) {
//      if (info.getUserId().equals(staffCd)) {
//        ret = info.getUserLastName() + "　" + info.getUserFirstName();
//        break;
//      }
//    }
//
//    return ret;
//  }
//
//  /**
//   * スタッフ情報(json)からスタッフコードを取得する
//   * @param info スタッフ情報(json)
//   * @param keyName スタッフ番号を取得するキー名称
//   * @return スタッフコード(null:該当なし/else：スタッフコード)
//   */
//  private Long getStaffId(String info, String keyName) {
//    Long ret = null;
//
//    try {
//      // json情報判定
//      if (info != null) {
//        // null以外
//
//        // json分解
//        ObjectMapper map = new ObjectMapper();
//        JsonNode root = map.readTree(info);
//
//        // キー判定
//        JsonNode item = root.get(keyName);
//        if (item != null) {
//          // 該当あり
//
//          // スタッフコードを取得
//          ret = Long.parseLong(item.asText());
//        }
//      }
//    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage( "スタッフ情報からスタッフコードの取得に失敗"+ e);
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_OBSERVE_RECORD, SERVICE_NAME.FNSI,
//      null);
//    }
//
//    return ret;
//  }

//  /**
//   * スタッフ情報(json)にスタッフ名を追加したjson文字列を作成する
//   * @param info スタッフ情報(json)
//   * @param keyName 追加するスタッフ名のキー名称
//   * @param strffName 追加するスタッフ名
//   * @return 作成したスタッフ情報(json)
//   */
//  private String makeStaffInfo(String info, String keyName, String stuffName) {
//    String ret = "";
//    Map<String, Object> valueMap = new HashMap<String, Object>();
//
//    try {
//      // json情報判定
//      if (info != null) {
//        // null以外
//        // json分解
//        ObjectMapper map = new ObjectMapper();
//        JsonNode root = map.readTree(info);
//        Iterator<String> fieldNames = root.propertyNames().iterator();
//
//        while (fieldNames.hasNext()) {
//          String fieldName = fieldNames.next();
//          // スタッフ名称のキー判定
//          if (fieldName.equals(keyName)) {
//            // スタッフ名称のキーと一致
//
//            // 指定したスタッフ名称に置き換えて追加
//            valueMap.put(fieldName, stuffName);
//          } else {
//            // スタッフ名称のキーと一致しない
//
//            // そのまま追加
//            valueMap.put(fieldName, root.get(fieldName));
//          }
//        }
//        // スタッフ名のキーの存在判定
//        if (valueMap.containsKey(keyName) == false) {
//          // スタッフ名のキーがないので追加
//          valueMap.put(keyName, stuffName);
//        }
//
//        // JSON文字列作成
//        ret = map.writeValueAsString(valueMap);
//      }
//    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("スタッフ情報にスタッフ名の追加に失敗"+ e);
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_OBSERVE_RECORD, SERVICE_NAME.FNSI,
//      null);
//    }
//
//    return ret;
//  }
//
//
//  /**
//   * 日付をTimestampへ変換(yyyyMMddからTimestampへ)
//   * @param dt  日付文字列(yyyyMMdd)
//   * @param def デフォルト
//   * @return
//   */
//  private Timestamp toTimestampStart(String dt, Timestamp def) {
//    if (dt != null && dt.length() == 8 && StrUtils.isNumber(dt)) {
//      return Timestamp.valueOf(dt.substring(0, 4) + "-" +
//          dt.substring(4, 6) + "-" +
//          dt.substring(6, 8) + " " +
//          "00:00:00");
//    } else {
//      return def;
//    }
//  };
//
//  /**
//   * 日付をTimestampへ変換(yyyyMMddからTimestampへ)
//   * @param dt  日付文字列(yyyyMMdd)
//   * @param def デフォルト
//   * @return
//   */
//  private Timestamp toTimestampEnd(String dt, Timestamp def) {
//    if (dt != null && dt.length() == 8 && StrUtils.isNumber(dt)) {
//      return Timestamp.valueOf(dt.substring(0, 4) + "-" +
//          dt.substring(4, 6) + "-" +
//          dt.substring(6, 8) + " " +
//          "23:59:59");
//    } else {
//      return def;
//    }
//  };
  /* del by lvzongheng  2023-02-02 [CodeOptimization]  end */

  /**
   * 新規登録
   * @param PatObsRec
   * @return
   * @throws URISyntaxException
   */
  @PostMapping({ "/renew" })
  public ResponseEntity<Void> renewPatObsRec(
      @RequestBody PatObsRec patObsRec,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) throws URISyntaxException {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      boolean hasAccess = ntssUser.isNkkAdminUser() || patObsRec.getFacilityCd() == null
              || patObsRec.getFacilityCd().equals(ntssUser.getFacilityCd());
      if (!hasAccess) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "patObsRec.getFacilityCd()=" + patObsRec.getFacilityCd();
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_OBS_REC + "/renew";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patObsRec));
    // add FNSi5712アプリケーションログが出力しない 周 end

    try {
      patObsRecService.insertRenew(patObsRec);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patObsRec));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return ResponseEntity.ok().build();
    } catch (DuplicateKeyException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
  }

  /**
  * 更新
  * @param mstComsvSetting
  * @return
  */
  @PutMapping("/{ctlNo}")
  public ResponseEntity<Void> updatePatObsRec(
      @RequestBody PatObsRec patObsRec,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      PatObsRec checkPatObsRec = patObsRecService.selectByObsRecNo(patObsRec.getObsRecNo());
      if (checkPatObsRec != null) {
        if (checkPatObsRec.getFacilityCd() != null && !checkPatObsRec.getFacilityCd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "checkPatObsRec.getFacilityCd()=" + checkPatObsRec.getFacilityCd() + " " + "patObsRec.getObsRecNo()=" + patObsRec.getObsRecNo() + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_OBS_REC + "/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patObsRec));
    // add FNSi5712アプリケーションログが出力しない 周 end

    try {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("updatePatObsRec.update("+patObsRec.getObsRecNo().toString()+")");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_OBSERVE_RECORD, SERVICE_NAME.FNSI,
      null);
      patObsRecService.update(patObsRec);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patObsRec));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return ResponseEntity.ok().build();

    } catch (DuplicateKeyException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();

    }
  }

  /**
   * 観察記録マスタデータ取得
   * @param patId
   * @param ctlNo
   * @return
   */
  @GetMapping("/mst/kind-all/{facilityCd}")
  public ResponseEntity<?> getMstObsKindAll(
      @PathVariable(name = "facilityCd", required = true) String facilityCd,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_OBS_REC + "/mst/kind-all/{facilityCd}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<MstObsKind> res = new ArrayList<MstObsKind>();

    if (facilityCd != null) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        boolean hasAccess = ntssUser.isNkkAdminUser() || facilityCd == null
                || facilityCd.equals(ntssUser.getFacilityCd());
        if (!hasAccess) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd;
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
      /* modify by lvzongheng  2023-02-01 [CodeOptimization]  start */
      res = observeRecordService.getMstObsKindAll(facilityCd);
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("getMstObsKindAll facilityCd:" + facilityCd);
//      logService.log(LogLevel.DEBUG, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_OBSERVE_RECORD, LoggingConstant.SERVICE_NAME.FNSI,
//        null);
//      res = mstObsKindService.selectAll(facilityCd);
//
//      // mstSelectorから並び順を取得
//      MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_obs_kind");
//
//      if (mstSelector != null) {
//        // ソート後データ
//        List<MstObsKind> sortedData = new ArrayList<>();
//
//        // ソート用配列作成
//        List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
//          .stream().map(e -> e.getCode()).collect(Collectors.toList());
//
//        // ソート用配列順にデータを並び替え
//        for (Long sortedCode : sortedCodes) {
//          for (MstObsKind item : res) {
//            if (sortedCode.equals(item.getKindNo())) {
//              sortedData.add(item);
//            }
//          }
//        }
//
//        res = sortedData;
//      }
      /* modify by lvzongheng  2023-02-01 [CodeOptimization]  end */
    } else {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * データ取得
   * @param kindNo
   * @return
   */
  @GetMapping("/mst/kind/{kindNo}")
  public ResponseEntity<?> getMstObsKind(
      @PathVariable(name = "kindNo", required = true) String kindNo,
      @AuthenticationPrincipal NtssUser ntssUser) {

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_OBS_REC + "/mst/kind/{kindNo}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(kindNo));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<MstObsKind> res = new ArrayList<MstObsKind>();

    if (kindNo != null && StrUtils.isNumber(kindNo)) {
      //
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("getMstObsKind kindNo:" + kindNo);
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_OBSERVE_RECORD, SERVICE_NAME.FNSI,
      null);
      res = mstObsKindService.selectByKindNo(Long.parseLong(kindNo));
      if (!ntssUser.isNkkAdminUser()) {
        for (MstObsKind mstObsKind : res) {
          if (mstObsKind.getFacilityCd() != null && !mstObsKind.getFacilityCd().equals(ntssUser.getFacilityCd())) {
            // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstObsKind.getFacilityCd() + " " + "kindNo=" + kindNo + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
            // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end
          }
        }
      }
    } else {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(kindNo));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(kindNo));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * 新規登録
   * @param MstObsKind
   * @return
   * @throws URISyntaxException
   */
  @PostMapping({ "/mst/insert" })
  public ResponseEntity<Void> insertMstObsKind(
      @RequestBody MstObsKind mstObsKind,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) throws URISyntaxException {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      boolean hasAccess = ntssUser.isNkkAdminUser() || mstObsKind.getFacilityCd() == null
              || mstObsKind.getFacilityCd().equals(ntssUser.getFacilityCd());
      if (!hasAccess) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "mstObsKind.getFacilityCd()=" + mstObsKind.getFacilityCd();
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_OBS_REC + "/mst/insert";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(mstObsKind));
    // add FNSi5712アプリケーションログが出力しない 周 end

    try {
      mstObsKindService.insert(mstObsKind);

      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(mstObsKind));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return ResponseEntity.ok().build();
    } catch (DuplicateKeyException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
  }

  /**
  * 更新
  * @param mstObsKind
  * @return
  */
  @PostMapping("/mst/update")
  public ResponseEntity<Void> updateMstObsKind(
      @RequestBody MstObsKind mstObsKind,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      if (mstObsKind.getFacilityCd() != null && !mstObsKind.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstObsKind.getFacilityCd() + " " + "kindNo=" + mstObsKind.getKindNo() + " " + "kindName=" + mstObsKind.getKindName() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_OBS_REC + "/mst/update";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(mstObsKind));
    // add FNSi5712アプリケーションログが出力しない 周 end

    try {
      mstObsKindService.update(mstObsKind);

      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(mstObsKind));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return ResponseEntity.ok().build();
    } catch (DuplicateKeyException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();

    }
  }

  /**
  * 削除
  * @param mstObsKind
  * @return
  */
  @PostMapping("/mst/delete")
  public ResponseEntity<Void> deleteMstObsKind(
      @RequestBody MstObsKind mstObsKind,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      if (mstObsKind.getFacilityCd() != null && !mstObsKind.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstObsKind.getFacilityCd() + " " + "kindNo=" + mstObsKind.getKindNo() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_OBS_REC + "/mst/delete";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(mstObsKind));
    // add FNSi5712アプリケーションログが出力しない 周 end

    try {
      mstObsKindService.delete(mstObsKind);

      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(mstObsKind));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return ResponseEntity.ok().build();
    } catch (DuplicateKeyException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();

    }
  }

  /**
   * データ取得
   * @param bbsCtlNo
   * @return
   */
  @GetMapping("/getObsRecByBbsCtlNo/{bbsCtlNo}")
  public ResponseEntity<?> getObsRecByBbsCtlNo(
      @PathVariable(name = "bbsCtlNo", required = true) long bbsCtlNo,
      @AuthenticationPrincipal NtssUser ntssUser) {

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_OBS_REC + "/getObsRecByBbsCtlNo/{bbsCtlNo}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bbsCtlNo));
    // add FNSi5712アプリケーションログが出力しない 周 end

    List<PatObsRec> res = patObsRecService.getObsRecByBbsCtlNo(bbsCtlNo);
    if (!ntssUser.isNkkAdminUser()) {
      for (PatObsRec patObsRec : res) {
        if (patObsRec.getFacilityCd() != null && !patObsRec.getFacilityCd().equals(ntssUser.getFacilityCd())) {
          // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patObsRec.getFacilityCd() + " " + "bbsCtlNo=" + bbsCtlNo + " " + "obsRecNo=" + patObsRec.getObsRecNo() + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end
        }
      }
    }

    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_OBSERVE_RECORD,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(bbsCtlNo));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
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
