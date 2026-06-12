package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.ILogEventService;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import org.json.JSONArray;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.response.patGroup.PatGroupCustomResponse;
import jp.co.nikkiso.ntss.admin_web.response.patGroup.PatGroupDetailResponse;
import jp.co.nikkiso.ntss.admin_web.response.patGroup.PatGroupResponse;
import jp.co.nikkiso.ntss.admin_web.service.access.FacilityAccessService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.MasterEditService;
import jp.co.nikkiso.ntss.admin_web.service.patGroup.PatGroupService;
import jp.co.nikkiso.ntss.admin_web.service.patGroupDetail.PatGroupDetailService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.PatGroup;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;


/**
 * 患者グループ画面のResourceクラス.
 */

@RestController
@Slf4j
@RequestMapping(Uri.PAT_GROUP)
public class PatGroupResource {
	@Autowired
	private PatGroupService patGroupService;

	@Autowired
	private PatGroupDetailService patGroupDetailService;

	@Autowired
	private PatPersonalMainDao patPersonMainDao;

	@Autowired
	LogService logService;

  // redmine 6471 患者グループの編集した記録がログに残らない  周 start
  @Autowired
  ILogEventService logEventService;
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
  @Autowired
  PatPersonalMainDao patPersonalMainDao;
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

  private final static String ADDPATGROUP_LOG_MESSAGE = "%sが患者グループ%sを追加しました。";
  private final static String UPDPATGROUP_LOG_MESSAGE = "%s(ID：%s)が患者グループ%sを更新しました。";
  private final static String DELPATGROUP_LOG_MESSAGE = "%sが患者グループ%sを削除しました。";
  // delete by YangYongzhuang  2023-02-03 [CodeOptimization]  start /
//  private final static String MODPATGROUP_LOG_MESSAGE = "患者グループ%s→%sが変更されました。";
//  private final static String UPDPATGROUP_LOG_MESSAGE = "患者グループ%sの患者が%sから%sに変更されました。";
  // delete by YangYongzhuang  2023-02-03 [CodeOptimization]  End /
  // redmine 6471 患者グループの編集した記録がログに残らない  周 end

  // add FNSi5712アプリケーションログが出力しない 周 start
  @Autowired
  LogEventUtils logEventUtils;
  // add FNSi5712アプリケーションログが出力しない 周 end

  @Autowired
  private FacilityAccessService facilityAccessService;

	/**
	 * facilityCDで全患者グループ習得
	 *
	 * @param facility_cd
	 * @return
	 */
	@GetMapping("")
	public ResponseEntity<?> getAllPatGroup(@RequestParam(value = "facility_cd", required = true) String facility_cd,
      @RequestParam(required = false) Long selectedPatId,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260512 start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260512 end
) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, facility_cd, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_GROUP + "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facility_cd));
    // add FNSi5712アプリケーションログが出力しない 周 end
		// 全患者グループ習得
		PatGroupResponse response = patGroupService.getAllPatGroup(facility_cd);

    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facility_cd));
    // add FNSi5712アプリケーションログが出力しない 周 end
		return new ResponseEntity<>(response,
				response.patGroupInfo == null ? HttpStatus.INTERNAL_SERVER_ERROR : HttpStatus.OK);

	}

	/**
	 * 指定した患者グループ詳細データの習得
	 *
	 * @param facility_cd
	 * @param pat_group_cd
	 * @return
	 */
	@GetMapping("/pat_group")
	public ResponseEntity<?> getByPatGroupCd(@RequestParam(value = "facility_cd", required = true) String facility_cd,
			@RequestParam(value = "pat_group_cd", required = true) Long pat_group_cd,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260512 start（GET /pat_group 与 GET '' 对齐：非 NKK 时禁止跨设施查询患者组详情）
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260512 end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260512 start
    if (!ntssUser.isNkkAdminUser() && facility_cd != null && !facility_cd.equals(ntssUser.getFacilityCd())) {
      return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260512 end

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_GROUP + "/pat_group";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facility_cd, pat_group_cd));
    // add FNSi5712アプリケーションログが出力しない 周 end

		PatGroupDetailResponse response = new PatGroupDetailResponse();

		PatGroup patGroup = patGroupService.selectPatGroupByCd(facility_cd, pat_group_cd);

		// 指定された患者グループの存在チェック
		if (patGroup != null) {
			try {
				response.setPatGroupInfo(patGroup);
				response.setPatGroupDetailList(patGroupDetailService.selectByPatGroupCd(pat_group_cd, facility_cd));
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facility_cd, pat_group_cd));
        // add FNSi5712アプリケーションログが出力しない 周 end
				return new ResponseEntity<>(response, HttpStatus.OK);
			} catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (facility_cd != null) {
          eventLogMessage.setFacilityCd(facility_cd);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
				logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_GROUP, SERVICE_NAME.FNSI, null);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
        // add FNSi5712アプリケーションログが出力しない 周 end
				return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
			}

		} else {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facility_cd, pat_group_cd));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
		}

	}

	/**
	 * facilityCdより全患者の習得
	 *
	 * @param facility_cd
	 * @return
	 */
	@GetMapping("/pat_facility_cd")
	public ResponseEntity<?> getAllPatByFacilityCd(
			@RequestParam(value = "facility_cd", required = true) String facility_cd,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260512 start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260512 end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260512 start
    if (!ntssUser.isNkkAdminUser() && facility_cd != null && !facility_cd.equals(ntssUser.getFacilityCd())) {
      return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260512 end

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_GROUP + "/pat_facility_cd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facility_cd));
    // add FNSi5712アプリケーションログが出力しない 周 end

		try {
			List<String> facilityList = new ArrayList<String>();
			facilityList.add(facility_cd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facility_cd));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(patPersonMainDao.selectAll(facilityList), HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facility_cd != null) {
        eventLogMessage.setFacilityCd(facility_cd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_GROUP, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}

	}

	/**
	 * 指定した患者の全グループの取得
	 *
	 * @param pat_id
	 * @return
	 */
	@GetMapping("/pat")
	public ResponseEntity<?> getByPatId(@RequestParam(value = "pat_id", required = true) Long pat_id) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_GROUP + "/pat";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
    // add FNSi5712アプリケーションログが出力しない 周 end
		try {
			PatGroupCustomResponse response = new PatGroupCustomResponse();
			response.setPatGroupList(patGroupDetailService.selectPatGroupByPatId(pat_id));
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(response, HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_GROUP, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 患者のグループ一括更新
	 *
	 * @param pat_id
	 * @param payload
	 * @return
	 */
	@PutMapping("/pat_group_pat_id/{pat_id}")
	public ResponseEntity<Void> updatePatGroupByPatId(@PathVariable long pat_id,
			@RequestBody Map<String, String> payload,
                                                    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                    @AuthenticationPrincipal NtssUser ntssUser
                                                    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      PatPersonalMain userInf = patPersonalMainDao.selectById(pat_id);
      if (userInf != null && userInf.getFacility_cd() != null && !userInf.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + userInf.getFacility_cd() + " " + "pat_id=" + pat_id + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_GROUP + "/pat_group_pat_id/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id));
    // add FNSi5712アプリケーションログが出力しない 周 end
		try {
			patGroupDetailService.updateByPatId(pat_id, payload);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, payload));
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
			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_GROUP, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 患者グループの新規作成
	 *
	 * @param payload
	 * @return
	 */
	@PostMapping("/create")
	public ResponseEntity<Long> create(@RequestBody Map<String, String> payload) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_GROUP + "/create";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
		try {
			long assignedPatGroupId = patGroupService.insert(payload);
      // redmine 6471 患者グループの編集した記録がログに残らない  周 start
      String userName = "";
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      if (user != null) {
        userName = logEventService.getPersonalUserName(user.getUserId());
      }
      String patGroupName = "";
      if(null != payload) {
        JSONArray jsonArray = new JSONArray("[" + payload.get("pat_group") + "]");
        patGroupName = jsonArray.getJSONObject(0).getString("patGroupName");
      }
      String functionName = convertString(payload.get("functionName"));
      outputLog(LogLevel.MONGO, String.format(ADDPATGROUP_LOG_MESSAGE, userName, patGroupName), functionName, null);
      // redmine 6471 患者グループの編集した記録がログに残らない  周 end
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(assignedPatGroupId, HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_GROUP, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * IDで患者グループ更新
	 *
	 * @param pat_group_id
	 * @param payload
	 * @return
	 */
	@PutMapping("/pat_group_id/{pat_group_id}")
	public ResponseEntity<Void> updatePatGroupById(@PathVariable long pat_group_id,
			@RequestBody Map<String, String> payload) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_GROUP + "/pat_group_id/{pat_group_id}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_group_id, payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
		try {
      // delete by YangYongzhuang  2023-02-03 [CodeOptimization]  start /
      // add redmine 6471 患者グループの編集した記録がログに残らない  周 start
//      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
//      PatGroup patGroupOrg = patGroupService.selectPatGroupByCd(user.getFacilityCd(), pat_group_id);
//      List<PatGroupDetail> PGDetailsOrg = patGroupDetailService.selectByPatGroupCd(pat_group_id, user.getFacilityCd());
      // add redmine 6471 患者グループの編集した記録がログに残らない  周 end
      // delete by YangYongzhuang  2023-02-03 [CodeOptimization]  End /
			patGroupService.updateById(pat_group_id, payload);
      // redmine 6471 患者グループの編集した記録がログに残らない  周 start
      // delete by YangYongzhuang  2023-02-03 [CodeOptimization]  start /
//      String functionName = convertString(payload.get("functionName"));
      // delete by YangYongzhuang  2023-02-03 [CodeOptimization]  End /
      // del redmine 6471 患者グループの編集した記録がログに残らない  周 start
//      String userName = "";
//      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
//      if (user != null) {
//        userName = logEventService.getPersonalUserName(user.getUserId());
//      }
      // del redmine 6471 患者グループの編集した記録がログに残らない  周 start
// delete by YangYongzhuang  2023-02-03 [CodeOptimization]  start /
//      String patGroupName = "";
//      if(null != payload) {
//        JSONArray jsonArray = new JSONArray("[" + payload.get("pat_group") + "]");
//        JSONObject jsonObj = jsonArray.getJSONObject(0);
//        patGroupName = jsonObj.getString("patGroupName");
//        // del redmine 6471 患者グループの編集した記録がログに残らない  周 start
//        //PatGroup patGroupOrg = patGroupService.selectPatGroupByCd(user.getFacilityCd(), pat_group_id);
//        // del redmine 6471 患者グループの編集した記録がログに残らない  周 start
//        if(!patGroupOrg.getPatGroupName().equals(patGroupName)) {
//          outputLog(LogLevel.MONGO, String.format(MODPATGROUP_LOG_MESSAGE, patGroupOrg.getPatGroupName(), patGroupName), functionName, null);
//        }
//        // add redmine 6471 患者グループの編集した記録がログに残らない  周 start
//        List<Long> orgUsers = new ArrayList<>();
//        List<Long> newUsers = new ArrayList<>();
//        List<PatGroupDetail> PGDetailsNew = patGroupDetailService.selectByPatGroupCd(pat_group_id, user.getFacilityCd());
//        PGDetailsOrg.stream().forEach(patDetailOrg -> {
//          orgUsers.add(patDetailOrg.getPatId());
//        });
//        PGDetailsNew.stream().forEach(patDetailNew -> {
//          newUsers.add(patDetailNew.getPatId());
//        });
//        outputLog(LogLevel.MONGO, String.format(UPDPATGROUP_LOG_MESSAGE, patGroupName, orgUsers.toString(), newUsers.toString()), functionName, null);
//        // add redmine 6471 患者グループの編集した記録がログに残らない  周 end
//      }
      // delete by YangYongzhuang  2023-02-03 [CodeOptimization]  End /
      // redmine 6471 患者グループの編集した記録がログに残らない  周 end
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_group_id, payload));
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
			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_GROUP, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_group_id, payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 患者グループ一覧の更新
	 *
	 * @param facilityCd 施設コード
	 * @param patGroupList 患者グループリスト
	 * @return
	 */
	@PutMapping("/pat_group_list/{facilityCd}")
	public ResponseEntity<Void> updatePatGroupList(@PathVariable(name = "facilityCd", required = true) String facilityCd, @RequestBody List<PatGroup> patGroupList,
                                                 // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                 @AuthenticationPrincipal NtssUser ntssUser
                                                 // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      if (facilityCd != null && !facilityCd.isEmpty() && !facilityCd.equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

		// 定義
		String mappingUrl = Uri.PAT_GROUP + "/pat_group_list/{facilityCd}";
		String userId = "";
		String userName = "";
		try {
			// ログの出力：FUNCTION_CODE.FUNC_PAT_GROUP = "023"
			logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP, BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patGroupList));
			// ユーザーの取得
			NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
			// ユーザー取得済の場合
			if (user != null) {
				//ユーザーIDの取得
				userId = user.getUsername();
				// ユーザー名の取得
				userName = logEventService.getPersonalUserName(user.getUserId());
			}
			// -----更新処理-----
			for (PatGroup targetPatGroup : patGroupList) {
				// 患者グループ名の取得
				String patGroupName = targetPatGroup.getPatGroupName();
				// (MongoDB)ログ出力
				outputLog(LogLevel.MONGO, String.format(UPDPATGROUP_LOG_MESSAGE, userName, userId, patGroupName), "患者グループ", null);
				// 患者グループの更新
				patGroupService.updatePatGroupById(facilityCd, targetPatGroup);
			}
			// ログの出力：FUNCTION_CODE.FUNC_PAT_GROUP = "023"
			logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP, AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patGroupList));
			// 正常終了
			return new ResponseEntity<>(HttpStatus.OK);

		} catch (Exception e) {
			// 例外処理
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
			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_GROUP, SERVICE_NAME.FNSI, null);
			logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP, AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patGroupList));
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 患者グループ削除
	 *
	 * @param pat_group_id
	 * @return
	 */
	@PutMapping("/pat_group_d/{pat_group_id}")
	public ResponseEntity<Void> deletePatGroupById(@PathVariable long pat_group_id) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_GROUP + "/pat_group_d/{pat_group_id}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_group_id));
    // add FNSi5712アプリケーションログが出力しない 周 end
		try {
      // redmine 6471 患者グループの編集した記録がログに残らない  周 start
      String userName = "";
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      if (user != null) {
        userName = logEventService.getPersonalUserName(user.getUserId());
      }

      PatGroup patGroup = patGroupService.selectPatGroupByCd(user.getFacilityCd(), pat_group_id);
      String patGroupName = patGroup.getPatGroupName();
      // redmine 6471 患者グループの編集した記録がログに残らない  周 end
      // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
//			patGroupService.deleteById(pat_group_id);
      patGroupService.deleteById(pat_group_id, user.getFacilityCd());
      // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
      outputLog(LogLevel.MONGO, String.format(DELPATGROUP_LOG_MESSAGE, userName, patGroupName), "患者グループ", null);
      // redmine 6471 患者グループの編集した記録がログに残らない  周 end
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_group_id));
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
			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_GROUP, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_group_id));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	@Autowired
	MasterEditService mstEditService;

	/**
	 * マスタセレクタ作成
	 *
	 * @param facilityCd 施設コード
	 * @param patGroupList
	 * @return
	 */
	@PutMapping("/mst_selector/{facilityCd}")
	public ResponseEntity<Void> createMstSelector(
			@PathVariable(name = "facilityCd", required = true) String facilityCd,
			@RequestBody List<PatGroup> patGroupList,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      if (facilityCd != null && !facilityCd.isEmpty() && !facilityCd.equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_GROUP + "/mst_selector/{facilityCd}";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patGroupList));
    // add FNSi5712アプリケーションログが出力しない 周 end
		try {
			List<Map<String, Object>> data = new ArrayList<Map<String, Object>>();

			for (PatGroup item : patGroupList) {
				Map<String, Object> map = new HashMap<String, Object>();
				map.put(MasterMaintenanceGenericDao.ALIAS_CODE, item.getPatGroupCd());
				map.put(MasterMaintenanceGenericDao.ALIAS_NAME, item.getPatGroupName());
				data.add(map);
			}
			// mst_selectorに登録する
			mstEditService.createMstSelector(facilityCd, "pat_group", data);

      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patGroupList));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.OK);
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
			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_GROUP, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patGroupList));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

  //add FutreNetWeb+SI課題管理 no.4266 劉全航 start
	@PostMapping("/notification-message")
  public ResponseEntity<Void> registerNotification(@RequestBody Map<String, String> payload){
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_GROUP + "/notification-message";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
	  try{
      patGroupService.registerPatGroupNotification(payload);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    }catch (Exception e){
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_GROUP,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //add FutreNetWeb+SI課題管理 no.4266 劉全航 end

  // redmine 6471 患者グループの編集した記録がログに残らない  周 start
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
  // redmine 6471 患者グループの編集した記録がログに残らない  周 end

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
