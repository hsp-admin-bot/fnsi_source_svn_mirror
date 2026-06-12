package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;
import java.util.Map;
import java.util.ArrayList;
//#10407:変更なしでも画面を表示させる Start
import java.util.HashMap;
//#10407:変更なしでも画面を表示させる End
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.dto.PatIndApproveHistory.PatIndApproveHistoryDTO;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONArray;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.util.CollectionUtils;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.PatIndApproveService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.core.logger.LogLevel;


import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import tools.jackson.core.type.TypeReference;

/**
 * 指示受け・承認画面のResourceクラス.
 */
@RestController
@RequestMapping(Uri.PAT_IND_APPROVE)
public class PatIndApproveResource {
	@Autowired
	PatIndApproveService patIndApproveService;

	@Autowired
	LogService logService;
  // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
  @Autowired
  JournalService journalService;
  // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
  //add #9507 一括指示受けに時間がかかる zrx start
  @Autowired
  LogEventUtils logEventUtils;
  //add #9507 一括指示受けに時間がかかる zrx end
	/**
	 * 指示受け1の更新
	 *
	 * @param ord_no
	 * @param payload
	 * @return
	 */
	@PutMapping("/check/{ord_no}")
	public ResponseEntity<Void> updateChecker(@PathVariable Long ord_no, @RequestBody Map<String, String> payload,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                            @AuthenticationPrincipal NtssUser ntssUser
                                            // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(ord_no);
      if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + ord_no + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

		try {
			patIndApproveService.updateChecker(ord_no, payload);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 承認者の更新
	 *
	 * @param ord_no
	 * @param payload
	 * @return
	 */
	@PutMapping("/approve/{ord_no}")
	public ResponseEntity<Void> updateApprover(@PathVariable Long ord_no, @RequestBody Map<String, String> payload,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                             @AuthenticationPrincipal NtssUser ntssUser
                                             // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(ord_no);
      if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + ord_no + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

		try {
			patIndApproveService.updateApprover(ord_no, payload);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

  // add #9507 一括指示受けに時間がかかる zrx start
  /**
   * 指示受け、指示承認の更新
   */
  @PostMapping("/bulkCheckOrApprove")
  public ResponseEntity<Void> updateCheckOrApproveList(@RequestBody PatIndApproveHistoryDTO patIndApproveHistoryDTO) {

    String mappingUrl = Uri.PAT_IND_APPROVE ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);

    if (patIndApproveHistoryDTO.getOrdNo() == null
      || patIndApproveHistoryDTO.getOrdNo().size() == 0
      || patIndApproveHistoryDTO.getApproveKind() == null
      || patIndApproveHistoryDTO.getApproveKind().size() == 0
      || !StringUtils.isNotBlank(patIndApproveHistoryDTO.getFacilityCd())) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(HttpStatus.NOT_MODIFIED);
    }

    try {
      patIndApproveService.updateCheckOrApproveList(patIndApproveHistoryDTO);
      //連携
      //指示受け1
      String strUnchecked1Json = patIndApproveHistoryDTO.getUnchecked1Indications();
      //指示受け２
      String strUnchecked2Json = patIndApproveHistoryDTO.getUnchecked2Indications();
      //指示承認1
      String strApproved1Json = patIndApproveHistoryDTO.getUnapproved1Indications();
      //指示承認2
      String strApproved2Json = patIndApproveHistoryDTO.getUnapproved2Indications();
      String opeCd = "";
      if(StringUtils.isNotBlank(strUnchecked1Json) || StringUtils.isNotBlank(strUnchecked2Json)
        || StringUtils.isNotBlank(strApproved1Json) || StringUtils.isNotBlank(strApproved2Json)) {
        JSONArray uncheckedIndicationsList = null;
        if(StringUtils.isNotBlank(strUnchecked1Json)) {
          uncheckedIndicationsList = new JSONArray(strUnchecked1Json);
          if (!uncheckedIndicationsList.getJSONObject(0).isNull("user_id")) {//OK
            opeCd = "028001";
          } else { //ALL OK
            opeCd = "028012";
          }
        } else if(StringUtils.isNotBlank(strUnchecked2Json)) {
          uncheckedIndicationsList = new JSONArray(strUnchecked2Json);
          if (!uncheckedIndicationsList.getJSONObject(0).isNull("user_id")) {//OK
            opeCd = "028001";
          } else { //ALL OK
            opeCd = "028013";
          }
        } else if(StringUtils.isNotBlank(strApproved1Json)) {
          uncheckedIndicationsList = new JSONArray(strApproved1Json);
          if (!uncheckedIndicationsList.getJSONObject(0).isNull("user_id")) {//OK
            opeCd = "028019";
          } else { //ALL OK
            opeCd = "028021";
          }
        } else if(StringUtils.isNotBlank(strApproved2Json)) {
          uncheckedIndicationsList = new JSONArray(strApproved2Json);
          if (!uncheckedIndicationsList.getJSONObject(0).isNull("user_id")) {//OK
            opeCd = "028020";
          } else { //ALL OK
            opeCd = "028022";
          }
        }
        List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
        if (uncheckedIndicationsList != null && uncheckedIndicationsList.length() > 0) {
          for (int i = 0; i < uncheckedIndicationsList.length(); i++) {
            Integer rstDialysisState = 0;
            if (!uncheckedIndicationsList.getJSONObject(i).isNull("rst_dialysis_state")) {
              rstDialysisState = Integer.parseInt(uncheckedIndicationsList.getJSONObject(i).get("rst_dialysis_state").toString());
            }
            Integer indKurCd = 0;
            if (!uncheckedIndicationsList.getJSONObject(i).isNull("ind_kur_cd")) {
              indKurCd = Integer.parseInt(uncheckedIndicationsList.getJSONObject(i).get("ind_kur_cd").toString());
            }
            if (rstDialysisState < 6 && indKurCd != 0) {
              JournalCreateRequestPayload payloadJournal = new JournalCreateRequestPayload();
              payloadJournal.setOpeCd(opeCd);
              payloadJournal.setCrud("U");
              if (!uncheckedIndicationsList.getJSONObject(i).isNull("pat_id")) {
                payloadJournal.setPatId(Long.valueOf(uncheckedIndicationsList.getJSONObject(i).get("pat_id").toString()));
              }
              payloadJournal.setFacilityCd(patIndApproveHistoryDTO.getFacilityCd());
              if (!uncheckedIndicationsList.getJSONObject(i).isNull("hosp_pat_id")) {
                payloadJournal.setHospPatId(uncheckedIndicationsList.getJSONObject(i).get("hosp_pat_id").toString());
              }
              if (!uncheckedIndicationsList.getJSONObject(i).isNull("ord_no")) {
                payloadJournal.setOrdNo(Long.valueOf(uncheckedIndicationsList.getJSONObject(i).get("ord_no").toString()));
              }
              if (!uncheckedIndicationsList.getJSONObject(i).isNull("treat_date")) {
                payloadJournal.setBaseDate(uncheckedIndicationsList.getJSONObject(i).get("treat_date").toString());
              }
              payloadJournal.setUserId(patIndApproveHistoryDTO.getUserId());
              ctlNoList.add(payloadJournal);
            }
          }
        }
        if (!CollectionUtils.isEmpty(ctlNoList)){
          journalService.callCreateJournalForCtrNo(ctlNoList);
        }
      }
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      e.printStackTrace();
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

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
  // add #9507 一括指示受けに時間がかかる zrx end

	/**
	 * 指示受け1の更新
	 *
	 * @param ord_no
	 * @param payload
	 * @return
	 */
	@PutMapping("/check1")
	public ResponseEntity<Void> updateCheck1(@RequestBody Map<String, String> payload,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                           @AuthenticationPrincipal NtssUser ntssUser
                                           // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    try {
      if(!ntssUser.isNkkAdminUser()) {
        ObjectMapper mapper = new ObjectMapper();
        PatIndApprove readValue = mapper.readValue(payload.get("pat_ind_approve"), PatIndApprove.class);
        Long ord_no = readValue.getOrd_no();
        PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(ord_no);
        if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + ord_no + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    } catch (tools.jackson.core.JacksonException e) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end
		try {
			patIndApproveService.updateCheck1(payload);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
             // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
             EventLogMessage eventLogMessage = new EventLogMessage();
             // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
             eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
             // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 指示受け2の更新
	 *
	 * @param ord_no
	 * @param payload
	 * @return
	 */
	@PutMapping("/check2")
	public ResponseEntity<Void> updateCheck2(@RequestBody Map<String, String> payload,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                           @AuthenticationPrincipal NtssUser ntssUser
                                           // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    try {
      if(!ntssUser.isNkkAdminUser()) {
        ObjectMapper mapper = new ObjectMapper();
        PatIndApprove readValue = mapper.readValue(payload.get("pat_ind_approve"), PatIndApprove.class);
        Long ord_no = readValue.getOrd_no();
        PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(ord_no);
        if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + ord_no + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    } catch (tools.jackson.core.JacksonException e) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end
		try {
			patIndApproveService.updateCheck2(payload);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 指示承認1の更新
	 *
	 * @param ord_no
	 * @param payload
	 * @return
	 */
	@PutMapping("/approve1")
	public ResponseEntity<Void> updateApprove1(@RequestBody Map<String, String> payload,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                             @AuthenticationPrincipal NtssUser ntssUser
                                             // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    try {
      if(!ntssUser.isNkkAdminUser()) {
        ObjectMapper mapper = new ObjectMapper();
        PatIndApprove approve = mapper.readValue(payload.get("pat_ind_approve"), PatIndApprove.class);
        if (approve != null && approve.getOrd_no() != null) {
          PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(approve.getOrd_no());
          if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + approve.getOrd_no() + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          }
        }
      }
    } catch (tools.jackson.core.JacksonException e) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end
		try {
			patIndApproveService.updateApprove1(payload);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 一括チェック１
	 *
	 * @param ord_no
	 * @param payload
	 * @return
	 */
	@PutMapping("/bulkCheck1")
	public ResponseEntity<Void> updateCheck1List(@RequestBody Map<String, String> payload,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                               @AuthenticationPrincipal NtssUser ntssUser
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    try {
      if(!ntssUser.isNkkAdminUser()) {
        ObjectMapper mapper = new ObjectMapper();
        List<PatIndApprove> patIndApproves = mapper.readValue(payload.get("pat_ind_approve_list"), new TypeReference<List<PatIndApprove>>() {});
        for (PatIndApprove approve : patIndApproves) {
            PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(approve.getOrd_no());
            if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
              String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + approve.getOrd_no() + " ";
              InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
              return new ResponseEntity<>(HttpStatus.FORBIDDEN);
            }
        }
      }
    } catch (Exception e) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end
		try {
			patIndApproveService.updateCheck1List(payload);
      // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
      String strJson = payload.get("unchecked1Indications");
      JSONArray unchecked1IndicationsList = new JSONArray(strJson);
      List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
      if (unchecked1IndicationsList != null && unchecked1IndicationsList.length() > 0) {
        for (int i = 0; i < unchecked1IndicationsList.length(); i++) {
          Integer rstDialysisState = 0;
          if (!unchecked1IndicationsList.getJSONObject(i).isNull("rst_dialysis_state")) {
            rstDialysisState = Integer.parseInt(unchecked1IndicationsList.getJSONObject(i).get("rst_dialysis_state").toString());
          }
          Integer indKurCd = 0;
          if (!unchecked1IndicationsList.getJSONObject(i).isNull("ind_kur_cd")) {
            indKurCd = Integer.parseInt(unchecked1IndicationsList.getJSONObject(i).get("ind_kur_cd").toString());
          }
          if (rstDialysisState < 6 && indKurCd != 0) {
            JournalCreateRequestPayload payloadJournal = new JournalCreateRequestPayload();
            payloadJournal.setOpeCd("028012");
            payloadJournal.setCrud("U");
            if (!unchecked1IndicationsList.getJSONObject(i).isNull("pat_id")) {
              payloadJournal.setPatId(Long.valueOf(unchecked1IndicationsList.getJSONObject(i).get("pat_id").toString()));
            }
            payloadJournal.setFacilityCd(payload.get("facility_cd"));
            if (!unchecked1IndicationsList.getJSONObject(i).isNull("hosp_pat_id")) {
              payloadJournal.setHospPatId(unchecked1IndicationsList.getJSONObject(i).get("hosp_pat_id").toString());
            }
            if (!unchecked1IndicationsList.getJSONObject(i).isNull("ord_no")) {
              payloadJournal.setOrdNo(Long.valueOf(unchecked1IndicationsList.getJSONObject(i).get("ord_no").toString()));
            }
            if (!unchecked1IndicationsList.getJSONObject(i).isNull("treat_date")) {
              payloadJournal.setBaseDate(unchecked1IndicationsList.getJSONObject(i).get("treat_date").toString());
            }
            if (payload.get("user_id") != null) {
              payloadJournal.setUserId(Long.valueOf(payload.get("user_id")));
            }
            ctlNoList.add(payloadJournal);
          }
        }
      }
      if (!CollectionUtils.isEmpty(ctlNoList)){
        journalService.callCreateJournalForCtrNo(ctlNoList);
      }
      // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 一括チェック２
	 *
	 * @param ord_no
	 * @param payload
	 * @return
	 */
	@PutMapping("/bulkCheck2")
	public ResponseEntity<Void> updateCheck2List(@RequestBody Map<String, String> payload,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                               @AuthenticationPrincipal NtssUser ntssUser
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    try {
      if(!ntssUser.isNkkAdminUser()) {
        ObjectMapper mapper = new ObjectMapper();
        List<PatIndApprove> patIndApproves = mapper.readValue(payload.get("pat_ind_approve_list"), new TypeReference<List<PatIndApprove>>() {
        });
        for (PatIndApprove approve : patIndApproves) {
          PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(approve.getOrd_no());
          if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + approve.getOrd_no() + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          }
        }
      }
    } catch (tools.jackson.core.JacksonException e) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end
		try {
			patIndApproveService.updateCheck2List(payload);
      // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
      String strJson = payload.get("unchecked2Indications");
      JSONArray unchecked2IndicationsList = new JSONArray(strJson);
      List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
      if (unchecked2IndicationsList != null && unchecked2IndicationsList.length() > 0) {
        for (int i = 0; i < unchecked2IndicationsList.length(); i++) {
          Integer rstDialysisState = 0;
          if (!unchecked2IndicationsList.getJSONObject(i).isNull("rst_dialysis_state")) {
            rstDialysisState = Integer.parseInt(unchecked2IndicationsList.getJSONObject(i).get("rst_dialysis_state").toString());
          }
          Integer indKurCd = 0;
          if (!unchecked2IndicationsList.getJSONObject(i).isNull("ind_kur_cd")) {
            indKurCd = Integer.parseInt(unchecked2IndicationsList.getJSONObject(i).get("ind_kur_cd").toString());
          }
          if (rstDialysisState < 6 && indKurCd != 0) {
            JournalCreateRequestPayload payloadJournal = new JournalCreateRequestPayload();
            payloadJournal.setOpeCd("028013");
            payloadJournal.setCrud("U");
            if (!unchecked2IndicationsList.getJSONObject(i).isNull("pat_id")) {
              payloadJournal.setPatId(Long.valueOf(unchecked2IndicationsList.getJSONObject(i).get("pat_id").toString()));
            }
            payloadJournal.setFacilityCd(payload.get("facility_cd"));
            if (!unchecked2IndicationsList.getJSONObject(i).isNull("hosp_pat_id")) {
              payloadJournal.setHospPatId(unchecked2IndicationsList.getJSONObject(i).get("hosp_pat_id").toString());
            }
            if (!unchecked2IndicationsList.getJSONObject(i).isNull("ord_no")) {
              payloadJournal.setOrdNo(Long.valueOf(unchecked2IndicationsList.getJSONObject(i).get("ord_no").toString()));
            }
            if (!unchecked2IndicationsList.getJSONObject(i).isNull("treat_date")) {
              payloadJournal.setBaseDate(unchecked2IndicationsList.getJSONObject(i).get("treat_date").toString());
            }
            if (payload.get("user_id") != null) {
              payloadJournal.setUserId(Long.valueOf(payload.get("user_id")));
            }
            ctlNoList.add(payloadJournal);
          }
        }
      }
      if (!CollectionUtils.isEmpty(ctlNoList)){
        journalService.callCreateJournalForCtrNo(ctlNoList);
      }
      // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 一括承認１
	 *
	 * @param ord_no
	 * @param payload
	 * @return
	 */
	@PutMapping("/bulkApprove1")
	public ResponseEntity<Void> updateApprove1List(@RequestBody Map<String, String> payload,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                                 @AuthenticationPrincipal NtssUser ntssUser
                                                 // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    try {
      if(!ntssUser.isNkkAdminUser()) {
        ObjectMapper mapper = new ObjectMapper();
        List<PatIndApprove> patIndApproves = mapper.readValue(payload.get("pat_ind_approve_list"), new TypeReference<List<PatIndApprove>>() {
        });
        for (PatIndApprove approve : patIndApproves) {
          PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(approve.getOrd_no());
          if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + approve.getOrd_no() + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          }
        }
      }
    } catch (tools.jackson.core.JacksonException e) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end
		try {
			patIndApproveService.updateApprove1List(payload);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 一括承認２
	 *
	 * @param ord_no
	 * @param payload
	 * @return
	 */
	@PutMapping("/bulkApprove2")
	public ResponseEntity<Void> updateApprove2List(@RequestBody Map<String, String> payload,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                                 @AuthenticationPrincipal NtssUser ntssUser
                                                 // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    try {
      if(!ntssUser.isNkkAdminUser()) {
        ObjectMapper mapper = new ObjectMapper();
        List<PatIndApprove> patIndApproves = mapper.readValue(payload.get("pat_ind_approve_list"), new TypeReference<List<PatIndApprove>>() {
        });
        for (PatIndApprove approve : patIndApproves) {
          PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(approve.getOrd_no());
          if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + approve.getOrd_no() + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          }
        }
      }
    } catch (tools.jackson.core.JacksonException e) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end
		try {
			patIndApproveService.updateApprove2List(payload);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 指示承認2の更新
	 *
	 * @param ord_no
	 * @param payload
	 * @return
	 */
	@PutMapping("/approve2")
	public ResponseEntity<Void> updateApprove2(@RequestBody Map<String, String> payload,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                             @AuthenticationPrincipal NtssUser ntssUser
                                             // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    try {
      if(!ntssUser.isNkkAdminUser()) {
        ObjectMapper mapper = new ObjectMapper();
        PatIndApprove approve = mapper.readValue(payload.get("pat_ind_approve"), PatIndApprove.class);
        if (approve != null && approve.getOrd_no() != null) {
          PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(approve.getOrd_no());
          if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + approve.getOrd_no() + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          }
        }
      }
    } catch (tools.jackson.core.JacksonException e) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end
		try {
			patIndApproveService.updateApprove2(payload);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 指示受け1を取り消す
	 *
	 * @param ord_no
	 * @return
	 */
	@PutMapping("/uncheck1/{ord_no}")
	public ResponseEntity<Void> updateUncheck1(@PathVariable Long ord_no,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                             @AuthenticationPrincipal NtssUser ntssUser
                                             // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(ord_no);
      if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + ord_no + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

		try {
			patIndApproveService.updateUncheck1(ord_no);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 指示受け2を取り消す
	 *
	 * @param ord_no
	 * @return
	 */
	@PutMapping("/uncheck2/{ord_no}")
	public ResponseEntity<Void> updateUncheck2(@PathVariable Long ord_no,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                             @AuthenticationPrincipal NtssUser ntssUser
                                             // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(ord_no);
      if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + ord_no + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

		try {
			patIndApproveService.updateUncheck2(ord_no);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 指示承認1を取り消す
	 *
	 * @param ord_no
	 * @return
	 */
	@PutMapping("/unapprove1/{ord_no}")
	public ResponseEntity<Void> updateUnapprove1(@PathVariable Long ord_no,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                               @AuthenticationPrincipal NtssUser ntssUser
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(ord_no);
      if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + ord_no + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

		try {
			patIndApproveService.updateUnapprove1(ord_no);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 指示承認2を取り消す
	 *
	 * @param ord_no
	 * @return
	 */
	@PutMapping("/unapprove2/{ord_no}")
	public ResponseEntity<Void> updateUnapprove2(@PathVariable Long ord_no,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                               @AuthenticationPrincipal NtssUser ntssUser
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(ord_no);
      if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + ord_no + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

		try {
			patIndApproveService.updateUnapprove2(ord_no);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * ordNoで指示受け・承認の習得
	 *
	 * @param ord_no
	 * @return
	 */
	@GetMapping("/{ord_no}")
	public ResponseEntity<Map<String, String>> getPatIndApproveByOrdNo(@PathVariable Long ord_no,
                                                                      @AuthenticationPrincipal NtssUser ntssUser) {
		//#10407:変更なしでも画面を表示させる Start
		Map<String, String> patIndApproveJson = new HashMap<String, String>();
		//#10407:変更なしでも画面を表示させる End
    if(!ntssUser.isNkkAdminUser()) {
      PatIndApprove patIndApprove = patIndApproveService.selectByOrdNoLast(ord_no);
      if (patIndApprove != null && !patIndApprove.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + patIndApprove.getFacility_cd() + " " + "ord_no=" + ord_no + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
		try {
			patIndApproveJson = patIndApproveService.selectPatIndApproveByOrdNo(ord_no);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//            e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
		return new ResponseEntity<>(patIndApproveJson, HttpStatus.OK);
	}
}
